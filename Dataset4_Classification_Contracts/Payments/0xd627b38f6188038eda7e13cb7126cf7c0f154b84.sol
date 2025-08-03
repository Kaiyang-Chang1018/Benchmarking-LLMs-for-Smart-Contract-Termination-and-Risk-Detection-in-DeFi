// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Simple single owner authorization mixin.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)
abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.22;

/**
 * @dev the interface has been combined / truncated to only our needs
 */

/**
 * @dev Interface of the ERC-20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[ERC-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC-20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
 */
interface IERC20Permit {
    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     *
     * CAUTION: See Security Considerations above.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {Owned} from "solmate-6.8.0/src/auth/Owned.sol";

import {IERC20Permit} from "lib/shared/IERC20Permit.sol";

import {IBatch} from "./IBatch.sol";
import {Types} from "./Types.sol";

contract AlloyBatch is IBatch, Owned(msg.sender) {
    uint8 public version = 1;

    enum BatchType {
        Permit,
        TransferFrom
    }

    /// @return boolean derived from comparing the number of permits given and the number of permits succeeded
    function batchPermit(address token, Types.Permit[] calldata permits) external onlyOwner returns (bool) {
        IERC20Permit ERC20 = IERC20Permit(token);
        uint256 len = permits.length;
        uint256 batched = 0;

        // NOTE sol compiler as of ..22 no longer needs the unchecked i increments
        for (uint256 i = 0; i < len; ++i) {
            unchecked {
                batched += doPermit(ERC20, permits[i]);
            }
        }

        emit Batched(uint256(BatchType.Permit), token, batched, (len - batched));

        return batched == len;
    }

    function doPermit(IERC20Permit ERC20, Types.Permit calldata permit) internal returns (uint256) {
        // base case is that the permit has already been done
        if (permit.done) return 1;

        uint256 res = 0;

        try ERC20.permit(permit.owner, permit.spender, permit.value, permit.deadline, permit.v, permit.r, permit.s) {
            res = 1;
        } catch Panic(uint256 code) {
            // catches any illegal operations and assert failures
            emit BatchFail(uint256(BatchType.Permit), address(ERC20), permit.owner, code);
        } catch Error(string memory reason) {
            // catches any revert(string) and require(.., '')
            emit BatchFail(uint256(BatchType.Permit), address(ERC20), permit.owner, reason);
        } catch (bytes memory data) {
            // catch all for anything not described above
            emit BatchFail(uint256(BatchType.Permit), address(ERC20), permit.owner, data);
        }

        return res;
    }

    // ****** from many to one *****************************************************************************************

    function batchTransferFrom(address token, address[] calldata from, address to) external onlyOwner returns (bool) {
        IERC20Permit ERC20 = IERC20Permit(token);
        uint256 len = from.length;
        uint256 batched = 0;

        for (uint256 i = 0; i < len; ++i) {
            uint256 bal = ERC20.balanceOf(from[i]);

            // TODO we could check the allowance here, but likely not necessary as we will have mass permitted MAX_UINT

            if (bal > 0) {
                unchecked {
                    batched += doTransferFrom(ERC20, from[i], to, bal);
                }
            }
        }

        emit Batched(uint256(BatchType.TransferFrom), token, batched, (len - batched));

        return batched == len;
    }

    /// @dev there is a case here where a permit succeeds and a transferFrom fails. this is acceptable
    /// as the token itself will emit Approval if verification is needed. the 'failed' count here is
    /// representative of failed transfers. also a found 0 balance is a noop
    function batchTransferFrom(address token, Types.Permit[] calldata permits, address to)
        external
        onlyOwner
        returns (bool)
    {
        IERC20Permit ERC20 = IERC20Permit(token);
        uint256 len = permits.length;
        uint256 batched = 0;

        for (uint256 i = 0; i < len; ++i) {
            // first, the permit must adjust the allowance, if this fails do not proceed this iteration
            uint256 permitted = doPermit(ERC20, permits[i]);
            // then, we can transfer
            address from = permits[i].owner;

            if (permitted == 1) {
                uint256 bal = ERC20.balanceOf(from);

                if (bal > 0) {
                    unchecked {
                        batched += doTransferFrom(ERC20, from, to, bal);
                    }
                }
            }
        }

        emit Batched(uint256(BatchType.TransferFrom), token, batched, (len - batched));

        return batched == len;
    }

    // ****** from one to many *****************************************************************************************

    function batchTransferFrom(address token, address from, address[] calldata to, uint256 amount)
        external
        onlyOwner
        returns (bool)
    {
        IERC20Permit ERC20 = IERC20Permit(token);
        uint256 len = to.length;
        uint256 batched = 0;

        for (uint256 i = 0; i < len; ++i) {
            unchecked {
                batched += doTransferFrom(ERC20, from, to[i], amount);
            }
        }

        emit Batched(uint256(BatchType.TransferFrom), token, batched, (len - batched));

        return batched == len;
    }

    function batchTransferFrom(address token, Types.Permit calldata permit, address[] calldata to, uint256 amount)
        external
        onlyOwner
        returns (bool)
    {
        IERC20Permit ERC20 = IERC20Permit(token);
        uint256 len = to.length;
        uint256 batched = 0;

        for (uint256 i = 0; i < len; ++i) {
            uint256 permitted = doPermit(ERC20, permit);

            if (permitted == 1) {
                unchecked {
                    batched += doTransferFrom(ERC20, permit.owner, to[i], amount);
                }
            }
        }

        emit Batched(uint256(BatchType.TransferFrom), token, batched, (len - batched));

        return batched == len;
    }

    /// @dev invariant that the array args are of equivalent length
    function batchTransferFrom(address token, address from, address[] calldata to, uint256[] calldata amounts)
        external
        onlyOwner
        returns (bool)
    {
        uint256 len = to.length;

        if (len != amounts.length) revert arrayLengthMismatch();

        IERC20Permit ERC20 = IERC20Permit(token);
        uint256 batched = 0;

        for (uint256 i = 0; i < len; ++i) {
            unchecked {
                batched += doTransferFrom(ERC20, from, to[i], amounts[i]);
            }
        }

        emit Batched(uint256(BatchType.TransferFrom), token, batched, (len - batched));

        return batched == len;
    }

    function batchTransferFrom(
        address token,
        Types.Permit calldata permit,
        address[] calldata to,
        uint256[] calldata amounts
    ) external onlyOwner returns (bool) {
        uint256 len = to.length;

        if (len != amounts.length) revert arrayLengthMismatch();

        IERC20Permit ERC20 = IERC20Permit(token);
        uint256 batched = 0;

        for (uint256 i = 0; i < len; ++i) {
            uint256 permitted = doPermit(ERC20, permit);

            if (permitted == 1) {
                unchecked {
                    batched += doTransferFrom(ERC20, permit.owner, to[i], amounts[i]);
                }
            }
        }

        emit Batched(uint256(BatchType.TransferFrom), token, batched, (len - batched));

        return batched == len;
    }

    function doTransferFrom(IERC20Permit ERC20, address from, address to, uint256 amount) internal returns (uint256) {
        uint256 res = 0;

        try ERC20.transferFrom(from, to, amount) {
            res = 1;
        } catch Panic(uint256 code) {
            // catches any illegal operations and assert failures
            emit BatchFail(uint256(BatchType.TransferFrom), address(ERC20), from, code);
        } catch Error(string memory reason) {
            // catches any revert(string) and require(.., '')
            emit BatchFail(uint256(BatchType.TransferFrom), address(ERC20), from, reason);
        } catch (bytes memory data) {
            // catch all for anything not described above
            emit BatchFail(uint256(BatchType.TransferFrom), address(ERC20), from, data);
        }

        return res;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {Types} from "./Types.sol";

interface IBatch {
    /**
     * @dev Emitted at the conclusion of a batch operation.
     *   args:
     * kind - Type of batch
     * token - address of the token called
     * succeeded - the number of successful calls
     * failed - the number which failed
     */
    event Batched(uint256 indexed kind, address indexed token, uint256 succeeded, uint256 failed);

    /**
     * @dev Emmitted for each fail that occurs in a batching loop.
     *   args:
     * kind - Type of batch
     * token - address of the token called
     * user - address of the user whose tx failed
     * code / reason / data - returned data depending on error type
     */
    event BatchFail(uint256 indexed kind, address indexed token, address indexed user, uint256 code);
    event BatchFail(uint256 indexed kind, address indexed token, address indexed user, string reason);
    event BatchFail(uint256 indexed kind, address indexed token, address indexed user, bytes data);

    /// @notice given a target permit token and a list of permit payloads, execute the permit call for each
    function batchPermit(address token, Types.Permit[] calldata permits) external returns (bool);

    // ****** from many to one *******************************************************************************************

    /// @notice given a target token and a list of senders, transfer their entire balance to a given receiver
    /// @dev a permit is assumed to have already been performed in this case
    function batchTransferFrom(address token, address[] calldata from, address to) external returns (bool);

    /// @notice given a target token, an array of permits and a recipient, perform both the permit and transfer
    /// @dev the permits will need to allow address(this) for the an amount >= the owner's balance. also, from
    /// is not required as permit.owner will be used
    function batchTransferFrom(address token, Types.Permit[] calldata permits, address to) external returns (bool);

    // ****** from one to many ******************************************************************************************

    /// @notice given a target token, a sender, a list of receivers and an amount, transfer to each
    /// @dev a permit is assumed to have already been performed in this case
    function batchTransferFrom(address token, address from, address[] calldata to, uint256 amount)
        external
        returns (bool);

    /// @notice same as the above, however include a permit authorizing address(this)
    /// @dev the permit is expected to allow (at a minimum) the sum of all amounts sent. also,
    /// from is not passed here, permit.owner will be used
    function batchTransferFrom(address token, Types.Permit calldata permit, address[] calldata to, uint256 amount)
        external
        returns (bool);

    /// @notice given a target token, a sender, a list of recievers and a list of amounts, transfer to each
    function batchTransferFrom(address token, address from, address[] calldata to, uint256[] calldata amounts)
        external
        returns (bool);

    /// @notice same as above, however include a permit authorizing address(this)
    /// @dev the permit is expected to allow (at a minimum) the sum of all amounts sent. also,
    /// from is not passed here, permit.owner will be used
    function batchTransferFrom(
        address token,
        Types.Permit calldata permit,
        address[] calldata to,
        uint256[] calldata amounts
    ) external returns (bool);

    error arrayLengthMismatch();
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

/// @dev the `done` boolean is a flag to indicate that a permit call for this owner has aleady happened.
/// we do this to allow an API to pass 'mixed' arrays of permitted/nonpermitted users - preventing them from
/// needing to make multiple calls. Note that in the `done` case, only `owner` is needed.
library Types {
    struct Permit {
        bool done;
        address owner;
        address spender;
        uint256 value;
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }
}