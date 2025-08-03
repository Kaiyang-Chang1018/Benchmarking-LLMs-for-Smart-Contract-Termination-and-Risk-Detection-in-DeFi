// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../../utils/introspection/IERC165.sol";

/**
 * @dev Interface that must be implemented by smart contracts in order to receive
 * ERC-1155 token transfers.
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.20;

import {IERC165, ERC165} from "../../../utils/introspection/ERC165.sol";
import {IERC1155Receiver} from "../IERC1155Receiver.sol";

/**
 * @dev Simple implementation of `IERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 */
abstract contract ERC1155Holder is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.20;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be
     * reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.20;

import {IERC721Receiver} from "../IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or
 * {IERC721-setApprovalForAll}.
 */
abstract contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(address, address, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

pragma solidity ^0.8.20;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {FailedInnerCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {FailedInnerCall}) in case of an
     * unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {FailedInnerCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {FailedInnerCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/ERC165.sol)

pragma solidity ^0.8.20;

import {IERC165} from "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Provides a flexible and updatable auth pattern which is completely separate from application logic.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Auth.sol)
/// @author Modified from Dappsys (https://github.com/dapphub/ds-auth/blob/master/src/auth.sol)
abstract contract Auth {
    event OwnershipTransferred(address indexed user, address indexed newOwner);

    event AuthorityUpdated(address indexed user, Authority indexed newAuthority);

    address public owner;

    Authority public authority;

    constructor(address _owner, Authority _authority) {
        owner = _owner;
        authority = _authority;

        emit OwnershipTransferred(msg.sender, _owner);
        emit AuthorityUpdated(msg.sender, _authority);
    }

    modifier requiresAuth() virtual {
        require(isAuthorized(msg.sender, msg.sig), "UNAUTHORIZED");

        _;
    }

    function isAuthorized(address user, bytes4 functionSig) internal view virtual returns (bool) {
        Authority auth = authority; // Memoizing authority saves us a warm SLOAD, around 100 gas.

        // Checking if the caller is the owner only after calling the authority saves gas in most cases, but be
        // aware that this makes protected functions uncallable even to the owner if the authority is out of order.
        return (address(auth) != address(0) && auth.canCall(user, address(this), functionSig)) || user == owner;
    }

    function setAuthority(Authority newAuthority) public virtual {
        // We check if the caller is the owner first because we want to ensure they can
        // always swap out the authority even if it's reverting or using up a lot of gas.
        require(msg.sender == owner || authority.canCall(msg.sender, address(this), msg.sig));

        authority = newAuthority;

        emit AuthorityUpdated(msg.sender, newAuthority);
    }

    function transferOwnership(address newOwner) public virtual requiresAuth {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}

/// @notice A generic interface for a contract which provides authorization data to an Auth instance.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Auth.sol)
/// @author Modified from Dappsys (https://github.com/dapphub/ds-auth/blob/master/src/auth.sol)
interface Authority {
    function canCall(
        address user,
        address target,
        bytes4 functionSig
    ) external view returns (bool);
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Arithmetic library with operations for fixed-point numbers.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/FixedPointMathLib.sol)
/// @author Inspired by USM (https://github.com/usmfum/USM/blob/master/contracts/WadMath.sol)
library FixedPointMathLib {
    /*//////////////////////////////////////////////////////////////
                    SIMPLIFIED FIXED POINT OPERATIONS
    //////////////////////////////////////////////////////////////*/

    uint256 internal constant MAX_UINT256 = 2**256 - 1;

    uint256 internal constant WAD = 1e18; // The scalar of ETH and most ERC20s.

    function mulWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivDown(x, y, WAD); // Equivalent to (x * y) / WAD rounded down.
    }

    function mulWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivUp(x, y, WAD); // Equivalent to (x * y) / WAD rounded up.
    }

    function divWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivDown(x, WAD, y); // Equivalent to (x * WAD) / y rounded down.
    }

    function divWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivUp(x, WAD, y); // Equivalent to (x * WAD) / y rounded up.
    }

    /*//////////////////////////////////////////////////////////////
                    LOW LEVEL FIXED POINT OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function mulDivDown(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to require(denominator != 0 && (y == 0 || x <= type(uint256).max / y))
            if iszero(mul(denominator, iszero(mul(y, gt(x, div(MAX_UINT256, y)))))) {
                revert(0, 0)
            }

            // Divide x * y by the denominator.
            z := div(mul(x, y), denominator)
        }
    }

    function mulDivUp(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to require(denominator != 0 && (y == 0 || x <= type(uint256).max / y))
            if iszero(mul(denominator, iszero(mul(y, gt(x, div(MAX_UINT256, y)))))) {
                revert(0, 0)
            }

            // If x * y modulo the denominator is strictly greater than 0,
            // 1 is added to round up the division of x * y by the denominator.
            z := add(gt(mod(mul(x, y), denominator), 0), div(mul(x, y), denominator))
        }
    }

    function rpow(
        uint256 x,
        uint256 n,
        uint256 scalar
    ) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            switch x
            case 0 {
                switch n
                case 0 {
                    // 0 ** 0 = 1
                    z := scalar
                }
                default {
                    // 0 ** n = 0
                    z := 0
                }
            }
            default {
                switch mod(n, 2)
                case 0 {
                    // If n is even, store scalar in z for now.
                    z := scalar
                }
                default {
                    // If n is odd, store x in z for now.
                    z := x
                }

                // Shifting right by 1 is like dividing by 2.
                let half := shr(1, scalar)

                for {
                    // Shift n right by 1 before looping to halve it.
                    n := shr(1, n)
                } n {
                    // Shift n right by 1 each iteration to halve it.
                    n := shr(1, n)
                } {
                    // Revert immediately if x ** 2 would overflow.
                    // Equivalent to iszero(eq(div(xx, x), x)) here.
                    if shr(128, x) {
                        revert(0, 0)
                    }

                    // Store x squared.
                    let xx := mul(x, x)

                    // Round to the nearest number.
                    let xxRound := add(xx, half)

                    // Revert if xx + half overflowed.
                    if lt(xxRound, xx) {
                        revert(0, 0)
                    }

                    // Set x to scaled xxRound.
                    x := div(xxRound, scalar)

                    // If n is even:
                    if mod(n, 2) {
                        // Compute z * x.
                        let zx := mul(z, x)

                        // If z * x overflowed:
                        if iszero(eq(div(zx, x), z)) {
                            // Revert if x is non-zero.
                            if iszero(iszero(x)) {
                                revert(0, 0)
                            }
                        }

                        // Round to the nearest number.
                        let zxRound := add(zx, half)

                        // Revert if zx + half overflowed.
                        if lt(zxRound, zx) {
                            revert(0, 0)
                        }

                        // Return properly scaled zxRound.
                        z := div(zxRound, scalar)
                    }
                }
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                        GENERAL NUMBER UTILITIES
    //////////////////////////////////////////////////////////////*/

    function sqrt(uint256 x) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            let y := x // We start y at x, which will help us make our initial estimate.

            z := 181 // The "correct" value is 1, but this saves a multiplication later.

            // This segment is to get a reasonable initial estimate for the Babylonian method. With a bad
            // start, the correct # of bits increases ~linearly each iteration instead of ~quadratically.

            // We check y >= 2^(k + 8) but shift right by k bits
            // each branch to ensure that if x >= 256, then y >= 256.
            if iszero(lt(y, 0x10000000000000000000000000000000000)) {
                y := shr(128, y)
                z := shl(64, z)
            }
            if iszero(lt(y, 0x1000000000000000000)) {
                y := shr(64, y)
                z := shl(32, z)
            }
            if iszero(lt(y, 0x10000000000)) {
                y := shr(32, y)
                z := shl(16, z)
            }
            if iszero(lt(y, 0x1000000)) {
                y := shr(16, y)
                z := shl(8, z)
            }

            // Goal was to get z*z*y within a small factor of x. More iterations could
            // get y in a tighter range. Currently, we will have y in [256, 256*2^16).
            // We ensured y >= 256 so that the relative difference between y and y+1 is small.
            // That's not possible if x < 256 but we can just verify those cases exhaustively.

            // Now, z*z*y <= x < z*z*(y+1), and y <= 2^(16+8), and either y >= 256, or x < 256.
            // Correctness can be checked exhaustively for x < 256, so we assume y >= 256.
            // Then z*sqrt(y) is within sqrt(257)/sqrt(256) of sqrt(x), or about 20bps.

            // For s in the range [1/256, 256], the estimate f(s) = (181/1024) * (s+1) is in the range
            // (1/2.84 * sqrt(s), 2.84 * sqrt(s)), with largest error when s = 1 and when s = 256 or 1/256.

            // Since y is in [256, 256*2^16), let a = y/65536, so that a is in [1/256, 256). Then we can estimate
            // sqrt(y) using sqrt(65536) * 181/1024 * (a + 1) = 181/4 * (y + 65536)/65536 = 181 * (y + 65536)/2^18.

            // There is no overflow risk here since y < 2^136 after the first branch above.
            z := shr(18, mul(z, add(y, 65536))) // A mul() is saved from starting z at 181.

            // Given the worst case multiplicative error of 2.84 above, 7 iterations should be enough.
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))

            // If x+1 is a perfect square, the Babylonian method cycles between
            // floor(sqrt(x)) and ceil(sqrt(x)). This statement ensures we return floor.
            // See: https://en.wikipedia.org/wiki/Integer_square_root#Using_only_integer_division
            // Since the ceil is rare, we save gas on the assignment and repeat division in the rare case.
            // If you don't care whether the floor or ceil square root is returned, you can remove this statement.
            z := sub(z, lt(div(x, z), z))
        }
    }

    function unsafeMod(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Mod x by y. Note this will return
            // 0 instead of reverting if y is zero.
            z := mod(x, y)
        }
    }

    function unsafeDiv(uint256 x, uint256 y) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            // Divide x by y. Note this will return
            // 0 instead of reverting if y is zero.
            r := div(x, y)
        }
    }

    function unsafeDivUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Add 1 to x * y if x % y > 0. Note this will
            // return 0 instead of reverting if y is zero.
            z := add(gt(mod(x, y), 0), div(x, y))
        }
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Gas optimized reentrancy protection for smart contracts.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/ReentrancyGuard.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol)
abstract contract ReentrancyGuard {
    uint256 private locked = 1;

    modifier nonReentrant() virtual {
        require(locked == 1, "REENTRANCY");

        locked = 2;

        _;

        locked = 1;
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "../tokens/ERC20.sol";

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.
/// @dev Note that none of the functions in this library check that a token has code at all! That responsibility is delegated to the caller.
library SafeTransferLib {
    /*//////////////////////////////////////////////////////////////
                             ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(from, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "from" argument.
            mstore(add(freeMemoryPointer, 36), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "APPROVE_FAILED");
    }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.21;

import {FixedPointMathLib} from "@solmate/utils/FixedPointMathLib.sol";
import {SafeTransferLib} from "@solmate/utils/SafeTransferLib.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";
import {ReentrancyGuard} from "@solmate/utils/ReentrancyGuard.sol";
import {IAtomicSolver} from "./IAtomicSolver.sol";
import {AccountantWithRateProviders} from "src/base/Roles/AccountantWithRateProviders.sol";
import {IPausable} from "src/interfaces/IPausable.sol";
import {Auth, Authority} from "@solmate/auth/Auth.sol";

/**
 * @title AtomicQueue
 * @notice Allows users to create `AtomicRequests` that specify an ERC20 asset to `offer`
 *         and an ERC20 asset to `want` in return.
 * @notice Making atomic requests where the exchange rate between offer and want is not
 *         relatively stable is effectively the same as placing a limit order between
 *         those assets, so requests can be filled at a rate worse than the current market rate.
 * @notice It is possible for a user to make multiple requests that use the same offer asset.
 *         If this is done it is important that the user has approved the queue to spend the
 *         total amount of assets aggregated from all their requests, and to also have enough
 *         `offer` asset to cover the aggregate total request of `offerAmount`.
 * @author crispymangoes
 */
contract AtomicQueue is Auth, ReentrancyGuard, IPausable {
    using SafeTransferLib for ERC20;
    using FixedPointMathLib for uint256;

    // ========================================= STRUCTS =========================================

    /**
     * @notice Stores request information needed to fulfill a users atomic request.
     * @param deadline unix timestamp for when request is no longer valid
     * @param atomicPrice the price in terms of `want` asset the user wants their `offer` assets "sold" at
     * @dev atomicPrice MUST be in terms of `want` asset decimals.
     * @param offerAmount the amount of `offer` asset the user wants converted to `want` asset
     * @param inSolve bool used during solves to prevent duplicate users, and to prevent redoing multiple checks
     */
    struct AtomicRequest {
        uint64 deadline; // deadline to fulfill request
        uint88 atomicPrice; // In terms of want asset decimals
        uint96 offerAmount; // The amount of offer asset the user wants to sell.
        bool inSolve; // Indicates whether this user is currently having their request fulfilled.
    }

    /**
     * @notice Used in `viewSolveMetaData` helper function to return data in a clean struct.
     * @param user the address of the user
     * @param flags 8 bits indicating the state of the user only the first 4 bits are used XXXX0000
     *              Either all flags are false(user is solvable) or only 1 is true(an error occurred).
     *              From right to left
     *              - 0: indicates user deadline has passed.
     *              - 1: indicates user request has zero offer amount.
     *              - 2: indicates user does not have enough offer asset in wallet.
     *              - 3: indicates user has not given AtomicQueue approval.
     * @param assetsToOffer the amount of offer asset to solve
     * @param assetsForWant the amount of assets users want for their offer assets
     */
    struct SolveMetaData {
        address user;
        uint8 flags;
        uint256 assetsToOffer;
        uint256 assetsForWant;
    }

    /**
     * @notice Used in `viewVerboseSolveMetaData` helper function to return data in a clean struct.
     * @param user the address of the user
     * @param deadlineExceeded indicates if the user has passed their deadline
     * @param zeroOfferAmount indicates if the user has a zero offer amount
     * @param insufficientOfferBalance indicates if the user has insufficient offer balance
     * @param insufficientOfferAllowance indicates if the user has insufficient offer allowance
     * @param assetsToOffer the amount of offer asset to solve
     * @param assetsForWant the amount of assets users want for their offer assets
     */
    struct VerboseSolveMetaData {
        address user;
        bool deadlineExceeded;
        bool zeroOfferAmount;
        bool insufficientOfferBalance;
        bool insufficientOfferAllowance;
        uint256 assetsToOffer;
        uint256 assetsForWant;
    }

    // ========================================= CONSTANTS =========================================

    /**
     * @notice When using safeUpdateAtomicRequest, this is the max discount that can be applied.
     */
    uint256 public constant MAX_DISCOUNT = 0.01e6;

    // ========================================= GLOBAL STATE =========================================

    /**
     * @notice Maps user address to offer asset to want asset to a AtomicRequest struct.
     */
    mapping(address => mapping(ERC20 => mapping(ERC20 => AtomicRequest))) public userAtomicRequest;

    /**
     * @notice Used to pause calls to `updateAtomicRequest` and `solve`.
     */
    bool public isPaused;

    //============================== ERRORS ===============================

    error AtomicQueue__UserRepeated(address user);
    error AtomicQueue__RequestDeadlineExceeded(address user);
    error AtomicQueue__UserNotInSolve(address user);
    error AtomicQueue__ZeroOfferAmount(address user);
    error AtomicQueue__SafeRequestOfferAmountGreaterThanOfferBalance(uint256 offerAmount, uint256 offerBalance);
    error AtomicQueue__SafeRequestDeadlineExceeded(uint256 deadline);
    error AtomicQueue__SafeRequestInsufficientOfferAllowance(uint256 offerAmount, uint256 offerAllowance);
    error AtomicQueue__SafeRequestOfferAmountZero();
    error AtomicQueue__SafeRequestDiscountTooLarge();
    error AtomicQueue__SafeRequestAccountantOfferMismatch();
    error AtomicQueue__SafeRequestCannotCastToUint88();
    error AtomicQueue__Paused();

    //============================== EVENTS ===============================

    /**
     * @notice Emitted when `updateAtomicRequest` is called.
     */
    event AtomicRequestUpdated(
        address indexed user,
        address indexed offerToken,
        address indexed wantToken,
        uint256 amount,
        uint256 deadline,
        uint256 minPrice,
        uint256 timestamp
    );

    /**
     * @notice Emitted when `solve` exchanges a users offer asset for their want asset.
     */
    event AtomicRequestFulfilled(
        address indexed user,
        address indexed offerToken,
        address indexed wantToken,
        uint256 offerAmountSpent,
        uint256 wantAmountReceived,
        uint256 timestamp
    );

    /**
     * @notice Emitted when the contract is paused.
     */
    event Paused();

    /**
     * @notice Emitted when the contract is unpaused.
     */
    event Unpaused();

    //============================== IMMUTABLES ===============================

    constructor(address _owner, Authority _auth) Auth(_owner, _auth) {}

    // ========================================= ADMIN FUNCTIONS =========================================

    /**
     * @notice Pause this contract, which prevents future calls to `updateExchangeRate`, and any safe rate
     *         calls will revert.
     * @dev Callable by MULTISIG_ROLE.
     */
    function pause() external requiresAuth {
        isPaused = true;
        emit Paused();
    }

    /**
     * @notice Unpause this contract, which allows future calls to `updateExchangeRate`, and any safe rate
     *         calls will stop reverting.
     * @dev Callable by MULTISIG_ROLE.
     */
    function unpause() external requiresAuth {
        isPaused = false;
        emit Unpaused();
    }

    //============================== USER FUNCTIONS ===============================

    /**
     * @notice Get a users Atomic Request.
     * @param user the address of the user to get the request for
     * @param offer the ERC0 token they want to exchange for the want
     * @param want the ERC20 token they want in exchange for the offer
     */
    function getUserAtomicRequest(address user, ERC20 offer, ERC20 want) external view returns (AtomicRequest memory) {
        return userAtomicRequest[user][offer][want];
    }

    /**
     * @notice Helper function that returns either
     *         true: Withdraw request is valid.
     *         false: Withdraw request is not valid.
     * @dev It is possible for a withdraw request to return false from this function, but using the
     *      request in `updateAtomicRequest` will succeed, but solvers will not be able to include
     *      the user in `solve` unless some other state is changed.
     * @param offer the ERC0 token they want to exchange for the want
     * @param user the address of the user making the request
     * @param userRequest the request struct to validate
     */
    function isAtomicRequestValid(ERC20 offer, address user, AtomicRequest calldata userRequest)
        external
        view
        returns (bool)
    {
        // Validate amount.
        if (userRequest.offerAmount > offer.balanceOf(user)) return false;
        // Validate deadline.
        if (block.timestamp > userRequest.deadline) return false;
        // Validate approval.
        if (offer.allowance(user, address(this)) < userRequest.offerAmount) return false;
        // Validate offerAmount is nonzero.
        if (userRequest.offerAmount == 0) return false;
        // Validate atomicPrice is nonzero.
        if (userRequest.atomicPrice == 0) return false;

        return true;
    }

    /**
     * @notice Allows user to add/update their withdraw request.
     * @notice It is possible for a withdraw request with a zero atomicPrice to be made, and solved.
     *         If this happens, users will be selling their shares for no assets in return.
     *         To determine a safe atomicPrice, share.previewRedeem should be used to get
     *         a good share price, then the user can lower it from there to make their request fill faster.
     * @param offer the ERC20 token the user is offering in exchange for the want
     * @param want the ERC20 token the user wants in exchange for offer
     * @param userRequest the users request
     */
    function updateAtomicRequest(ERC20 offer, ERC20 want, AtomicRequest memory userRequest)
        external
        nonReentrant
        requiresAuth
    {
        _updateAtomicRequest(offer, want, userRequest);
    }

    /**
     * @notice Mostly identical to `updateAtomicRequest` but with additional checks to ensure the request is safe.
     * @notice Adds in accountant and discount to calculate a safe atomicPrice.
     * @dev This function will completely ignore the provided atomic price and calculate a new one based off the
     *      the accountant rate in quote and the discount provided.
     * @param accountant the accountant to use to get the rate in quote
     * @param discount the discount to apply to the rate in quote
     */
    function safeUpdateAtomicRequest(
        ERC20 offer,
        ERC20 want,
        AtomicRequest memory userRequest,
        AccountantWithRateProviders accountant,
        uint256 discount
    ) external nonReentrant requiresAuth {
        // Validate amount.
        uint256 offerBalance = offer.balanceOf(msg.sender);
        if (userRequest.offerAmount > offerBalance) {
            revert AtomicQueue__SafeRequestOfferAmountGreaterThanOfferBalance(userRequest.offerAmount, offerBalance);
        }
        // Validate deadline.
        if (block.timestamp > userRequest.deadline) {
            revert AtomicQueue__SafeRequestDeadlineExceeded(userRequest.deadline);
        }
        // Validate approval.
        uint256 offerAllowance = offer.allowance(msg.sender, address(this));
        if (offerAllowance < userRequest.offerAmount) {
            revert AtomicQueue__SafeRequestInsufficientOfferAllowance(userRequest.offerAmount, offerAllowance);
        }
        // Validate offerAmount is nonzero.
        if (userRequest.offerAmount == 0) revert AtomicQueue__SafeRequestOfferAmountZero();
        // Calculate atomic price.
        if (discount > MAX_DISCOUNT) revert AtomicQueue__SafeRequestDiscountTooLarge();
        if (address(offer) != address(accountant.vault())) revert AtomicQueue__SafeRequestAccountantOfferMismatch();
        uint256 safeRate = accountant.getRateInQuoteSafe(want);
        uint256 safeAtomicPrice = safeRate.mulDivDown(1e6 - discount, 1e6);
        if (safeAtomicPrice > type(uint88).max) revert AtomicQueue__SafeRequestCannotCastToUint88();
        userRequest.atomicPrice = uint88(safeAtomicPrice);
        _updateAtomicRequest(offer, want, userRequest);
    }

    //============================== SOLVER FUNCTIONS ===============================

    /**
     * @notice Called by solvers in order to exchange offer asset for want asset.
     * @notice Solvers are optimistically transferred the offer asset, then are required to
     *         approve this contract to spend enough of want assets to cover all requests.
     * @dev It is very likely `solve` TXs will be front run if broadcasted to public mem pools,
     *      so solvers should use private mem pools.
     * @param offer the ERC20 offer token to solve for
     * @param want the ERC20 want token to solve for
     * @param users an array of user addresses to solve for
     * @param runData extra data that is passed back to solver when `finishSolve` is called
     * @param solver the address to make `finishSolve` callback to
     */
    function solve(ERC20 offer, ERC20 want, address[] calldata users, bytes calldata runData, address solver)
        external
        nonReentrant
        requiresAuth
    {
        if (isPaused) revert AtomicQueue__Paused();

        // Save offer asset decimals.
        uint8 offerDecimals = offer.decimals();

        uint256 assetsToOffer;
        uint256 assetsForWant;
        for (uint256 i; i < users.length; ++i) {
            AtomicRequest storage request = userAtomicRequest[users[i]][offer][want];

            if (request.inSolve) revert AtomicQueue__UserRepeated(users[i]);
            if (block.timestamp > request.deadline) revert AtomicQueue__RequestDeadlineExceeded(users[i]);
            if (request.offerAmount == 0) revert AtomicQueue__ZeroOfferAmount(users[i]);

            // User gets whatever their atomic price * offerAmount is.
            assetsForWant += _calculateAssetAmount(request.offerAmount, request.atomicPrice, offerDecimals);

            // If all checks above passed, the users request is valid and should be fulfilled.
            assetsToOffer += request.offerAmount;
            request.inSolve = true;
            // Transfer shares from user to solver.
            offer.safeTransferFrom(users[i], solver, request.offerAmount);
        }

        IAtomicSolver(solver).finishSolve(runData, msg.sender, offer, want, assetsToOffer, assetsForWant);

        for (uint256 i; i < users.length; ++i) {
            AtomicRequest storage request = userAtomicRequest[users[i]][offer][want];

            if (request.inSolve) {
                // We know that the minimum price and deadline arguments are satisfied since this can only be true if they were.

                // Send user their share of assets.
                uint256 assetsToUser = _calculateAssetAmount(request.offerAmount, request.atomicPrice, offerDecimals);

                want.safeTransferFrom(solver, users[i], assetsToUser);

                emit AtomicRequestFulfilled(
                    users[i], address(offer), address(want), request.offerAmount, assetsToUser, block.timestamp
                );

                // Set shares to withdraw to 0.
                request.offerAmount = 0;
                request.inSolve = false;
            } else {
                revert AtomicQueue__UserNotInSolve(users[i]);
            }
        }
    }

    /**
     * @notice Helper function solvers can use to determine if users are solvable, and the required amounts to do so.
     * @notice Repeated users are not accounted for in this setup, so if solvers have repeat users in their `users`
     *         array the results can be wrong.
     * @dev Since a user can have multiple requests with the same offer asset but different want asset, it is
     *      possible for `viewSolveMetaData` to report no errors, but for a solve to fail, if any solves were done
     *      between the time `viewSolveMetaData` and before `solve` is called.
     * @param offer the ERC20 offer token to check for solvability
     * @param want the ERC20 want token to check for solvability
     * @param users an array of user addresses to check for solvability
     */
    function viewSolveMetaData(ERC20 offer, ERC20 want, address[] calldata users)
        external
        view
        returns (SolveMetaData[] memory metaData, uint256 totalAssetsForWant, uint256 totalAssetsToOffer)
    {
        // Save offer asset decimals.
        uint8 offerDecimals = offer.decimals();

        // Setup meta data.
        metaData = new SolveMetaData[](users.length);

        for (uint256 i; i < users.length; ++i) {
            AtomicRequest memory request = userAtomicRequest[users[i]][offer][want];

            metaData[i].user = users[i];

            if (block.timestamp > request.deadline) {
                metaData[i].flags |= uint8(1);
            }
            if (request.offerAmount == 0) {
                metaData[i].flags |= uint8(1) << 1;
            }
            if (offer.balanceOf(users[i]) < request.offerAmount) {
                metaData[i].flags |= uint8(1) << 2;
            }
            if (offer.allowance(users[i], address(this)) < request.offerAmount) {
                metaData[i].flags |= uint8(1) << 3;
            }

            metaData[i].assetsToOffer = request.offerAmount;

            // User gets whatever their execution share price is.
            uint256 userAssets = _calculateAssetAmount(request.offerAmount, request.atomicPrice, offerDecimals);
            metaData[i].assetsForWant = userAssets;

            // If flags is zero, no errors occurred.
            if (metaData[i].flags == 0) {
                totalAssetsForWant += userAssets;
                totalAssetsToOffer += request.offerAmount;
            }
        }
    }

    /**
     * @notice Helper function solvers can use to determine if users are solvable, and the required amounts to do so.
     * @notice Repeated users are not accounted for in this setup, so if solvers have repeat users in their `users`
     *         array the results can be wrong.
     * @dev Since a user can have multiple requests with the same offer asset but different want asset, it is
     *      possible for `viewSolveMetaData` to report no errors, but for a solve to fail, if any solves were done
     *      between the time `viewSolveMetaData` and before `solve` is called.
     * @param offer the ERC20 offer token to check for solvability
     * @param want the ERC20 want token to check for solvability
     * @param users an array of user addresses to check for solvability
     */
    function viewVerboseSolveMetaData(ERC20 offer, ERC20 want, address[] calldata users)
        external
        view
        returns (VerboseSolveMetaData[] memory metaData, uint256 totalAssetsForWant, uint256 totalAssetsToOffer)
    {
        // Save offer asset decimals.
        uint8 offerDecimals = offer.decimals();

        // Setup meta data.
        metaData = new VerboseSolveMetaData[](users.length);

        for (uint256 i; i < users.length; ++i) {
            AtomicRequest memory request = userAtomicRequest[users[i]][offer][want];

            metaData[i].user = users[i];

            if (block.timestamp > request.deadline) {
                metaData[i].deadlineExceeded = true;
            }
            if (request.offerAmount == 0) {
                metaData[i].zeroOfferAmount = true;
            }
            if (offer.balanceOf(users[i]) < request.offerAmount) {
                metaData[i].insufficientOfferBalance = true;
            }
            if (offer.allowance(users[i], address(this)) < request.offerAmount) {
                metaData[i].insufficientOfferAllowance = true;
            }

            metaData[i].assetsToOffer = request.offerAmount;

            // User gets whatever their execution share price is.
            uint256 userAssets = _calculateAssetAmount(request.offerAmount, request.atomicPrice, offerDecimals);
            metaData[i].assetsForWant = userAssets;

            // If flags is zero, no errors occurred.
            if (
                !metaData[i].deadlineExceeded && !metaData[i].zeroOfferAmount && !metaData[i].insufficientOfferBalance
                    && !metaData[i].insufficientOfferAllowance
            ) {
                totalAssetsForWant += userAssets;
                totalAssetsToOffer += request.offerAmount;
            }
        }
    }

    //============================== INTERNAL FUNCTIONS ===============================

    /**
     * @notice Allows user to add/update their withdraw request.
     * @notice It is possible for a withdraw request with a zero atomicPrice to be made, and solved.
     *         If this happens, users will be selling their shares for no assets in return.
     *         To determine a safe atomicPrice, share.previewRedeem should be used to get
     *         a good share price, then the user can lower it from there to make their request fill faster.
     * @param offer the ERC20 token the user is offering in exchange for the want
     * @param want the ERC20 token the user wants in exchange for offer
     * @param userRequest the users request
     */
    function _updateAtomicRequest(ERC20 offer, ERC20 want, AtomicRequest memory userRequest) internal {
        if (isPaused) revert AtomicQueue__Paused();
        AtomicRequest storage request = userAtomicRequest[msg.sender][offer][want];

        request.deadline = userRequest.deadline;
        request.atomicPrice = userRequest.atomicPrice;
        request.offerAmount = userRequest.offerAmount;

        // Emit full amount user has.
        emit AtomicRequestUpdated(
            msg.sender,
            address(offer),
            address(want),
            userRequest.offerAmount,
            userRequest.deadline,
            userRequest.atomicPrice,
            block.timestamp
        );
    }

    /**
     * @notice Helper function to calculate the amount of want assets a users wants in exchange for
     *         `offerAmount` of offer asset.
     */
    function _calculateAssetAmount(uint256 offerAmount, uint256 atomicPrice, uint8 offerDecimals)
        internal
        pure
        returns (uint256)
    {
        return atomicPrice.mulDivDown(offerAmount, 10 ** offerDecimals);
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.0;

import { ERC20 } from "@solmate/tokens/ERC20.sol";

interface IAtomicSolver {
    /**
     * @notice This function must be implemented in order for an address to be a `solver`
     *         for the AtomicQueue
     * @param runData arbitrary bytes data that is dependent on how each solver is setup
     *        it could contain swap data, or flash loan data, etc..
     * @param initiator the address that initiated a solve
     * @param offer the ERC20 asset sent to the solver
     * @param want the ERC20 asset the solver must approve the queue for
     * @param assetsToOffer the amount of `offer` sent to the solver
     * @param assetsForWant the amount of `want` the solver must approve the queue for
     */
    function finishSolve(
        bytes calldata runData,
        address initiator,
        ERC20 offer,
        ERC20 want,
        uint256 assetsToOffer,
        uint256 assetsForWant
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import {FixedPointMathLib} from "@solmate/utils/FixedPointMathLib.sol";
import {SafeTransferLib} from "@solmate/utils/SafeTransferLib.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";
import {BeforeTransferHook} from "src/interfaces/BeforeTransferHook.sol";
import {Auth, Authority} from "@solmate/auth/Auth.sol";

contract BoringVault is ERC20, Auth, ERC721Holder, ERC1155Holder {
    using Address for address;
    using SafeTransferLib for ERC20;
    using FixedPointMathLib for uint256;

    // ========================================= STATE =========================================

    /**
     * @notice Contract responsbile for implementing `beforeTransfer`.
     */
    BeforeTransferHook public hook;

    //============================== EVENTS ===============================

    event Enter(address indexed from, address indexed asset, uint256 amount, address indexed to, uint256 shares);
    event Exit(address indexed to, address indexed asset, uint256 amount, address indexed from, uint256 shares);

    //============================== CONSTRUCTOR ===============================

    constructor(address _owner, string memory _name, string memory _symbol, uint8 _decimals)
        ERC20(_name, _symbol, _decimals)
        Auth(_owner, Authority(address(0)))
    {}

    //============================== MANAGE ===============================

    /**
     * @notice Allows manager to make an arbitrary function call from this contract.
     * @dev Callable by MANAGER_ROLE.
     */
    function manage(address target, bytes calldata data, uint256 value)
        external
        requiresAuth
        returns (bytes memory result)
    {
        result = target.functionCallWithValue(data, value);
    }

    /**
     * @notice Allows manager to make arbitrary function calls from this contract.
     * @dev Callable by MANAGER_ROLE.
     */
    function manage(address[] calldata targets, bytes[] calldata data, uint256[] calldata values)
        external
        requiresAuth
        returns (bytes[] memory results)
    {
        uint256 targetsLength = targets.length;
        results = new bytes[](targetsLength);
        for (uint256 i; i < targetsLength; ++i) {
            results[i] = targets[i].functionCallWithValue(data[i], values[i]);
        }
    }

    //============================== ENTER ===============================

    /**
     * @notice Allows minter to mint shares, in exchange for assets.
     * @dev If assetAmount is zero, no assets are transferred in.
     * @dev Callable by MINTER_ROLE.
     */
    function enter(address from, ERC20 asset, uint256 assetAmount, address to, uint256 shareAmount)
        external
        requiresAuth
    {
        // Transfer assets in
        if (assetAmount > 0) asset.safeTransferFrom(from, address(this), assetAmount);

        // Mint shares.
        _mint(to, shareAmount);

        emit Enter(from, address(asset), assetAmount, to, shareAmount);
    }

    //============================== EXIT ===============================

    /**
     * @notice Allows burner to burn shares, in exchange for assets.
     * @dev If assetAmount is zero, no assets are transferred out.
     * @dev Callable by BURNER_ROLE.
     */
    function exit(address to, ERC20 asset, uint256 assetAmount, address from, uint256 shareAmount)
        external
        requiresAuth
    {
        // Burn shares.
        _burn(from, shareAmount);

        // Transfer assets out.
        if (assetAmount > 0) asset.safeTransfer(to, assetAmount);

        emit Exit(to, address(asset), assetAmount, from, shareAmount);
    }

    //============================== BEFORE TRANSFER HOOK ===============================
    /**
     * @notice Sets the share locker.
     * @notice If set to zero address, the share locker logic is disabled.
     * @dev Callable by OWNER_ROLE.
     */
    function setBeforeTransferHook(address _hook) external requiresAuth {
        hook = BeforeTransferHook(_hook);
    }

    /**
     * @notice Call `beforeTransferHook` passing in `from` `to`, and `msg.sender`.
     */
    function _callBeforeTransfer(address from, address to) internal view {
        if (address(hook) != address(0)) hook.beforeTransfer(from, to, msg.sender);
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        _callBeforeTransfer(msg.sender, to);
        return super.transfer(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        _callBeforeTransfer(from, to);
        return super.transferFrom(from, to, amount);
    }

    //============================== RECEIVE ===============================

    receive() external payable {}
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {FixedPointMathLib} from "@solmate/utils/FixedPointMathLib.sol";
import {IRateProvider} from "src/interfaces/IRateProvider.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "@solmate/utils/SafeTransferLib.sol";
import {BoringVault} from "src/base/BoringVault.sol";
import {Auth, Authority} from "@solmate/auth/Auth.sol";
import {IPausable} from "src/interfaces/IPausable.sol";

contract AccountantWithRateProviders is Auth, IRateProvider, IPausable {
    using FixedPointMathLib for uint256;
    using SafeTransferLib for ERC20;

    // ========================================= STRUCTS =========================================

    /**
     * @param payoutAddress the address `claimFees` sends fees to
     * @param highwaterMark the highest value of the BoringVault's share price
     * @param feesOwedInBase total pending fees owed in terms of base
     * @param totalSharesLastUpdate total amount of shares the last exchange rate update
     * @param exchangeRate the current exchange rate in terms of base
     * @param allowedExchangeRateChangeUpper the max allowed change to exchange rate from an update
     * @param allowedExchangeRateChangeLower the min allowed change to exchange rate from an update
     * @param lastUpdateTimestamp the block timestamp of the last exchange rate update
     * @param isPaused whether or not this contract is paused
     * @param minimumUpdateDelayInSeconds the minimum amount of time that must pass between
     *        exchange rate updates, such that the update won't trigger the contract to be paused
     * @param managementFee the management fee
     * @param performanceFee the performance fee
     */
    struct AccountantState {
        address payoutAddress;
        uint96 highwaterMark;
        uint128 feesOwedInBase;
        uint128 totalSharesLastUpdate;
        uint96 exchangeRate;
        uint16 allowedExchangeRateChangeUpper;
        uint16 allowedExchangeRateChangeLower;
        uint64 lastUpdateTimestamp;
        bool isPaused;
        uint24 minimumUpdateDelayInSeconds;
        uint16 managementFee;
        uint16 performanceFee;
    }

    /**
     * @param isPeggedToBase whether or not the asset is 1:1 with the base asset
     * @param rateProvider the rate provider for this asset if `isPeggedToBase` is false
     */
    struct RateProviderData {
        bool isPeggedToBase;
        IRateProvider rateProvider;
    }

    // ========================================= STATE =========================================

    /**
     * @notice Store the accountant state in 3 packed slots.
     */
    AccountantState public accountantState;

    /**
     * @notice Maps ERC20s to their RateProviderData.
     */
    mapping(ERC20 => RateProviderData) public rateProviderData;

    //============================== ERRORS ===============================

    error AccountantWithRateProviders__UpperBoundTooSmall();
    error AccountantWithRateProviders__LowerBoundTooLarge();
    error AccountantWithRateProviders__ManagementFeeTooLarge();
    error AccountantWithRateProviders__PerformanceFeeTooLarge();
    error AccountantWithRateProviders__Paused();
    error AccountantWithRateProviders__ZeroFeesOwed();
    error AccountantWithRateProviders__OnlyCallableByBoringVault();
    error AccountantWithRateProviders__UpdateDelayTooLarge();
    error AccountantWithRateProviders__ExchangeRateAboveHighwaterMark();

    //============================== EVENTS ===============================

    event Paused();
    event Unpaused();
    event DelayInSecondsUpdated(uint24 oldDelay, uint24 newDelay);
    event UpperBoundUpdated(uint16 oldBound, uint16 newBound);
    event LowerBoundUpdated(uint16 oldBound, uint16 newBound);
    event ManagementFeeUpdated(uint16 oldFee, uint16 newFee);
    event PerformanceFeeUpdated(uint16 oldFee, uint16 newFee);
    event PayoutAddressUpdated(address oldPayout, address newPayout);
    event RateProviderUpdated(address asset, bool isPegged, address rateProvider);
    event ExchangeRateUpdated(uint96 oldRate, uint96 newRate, uint64 currentTime);
    event FeesClaimed(address indexed feeAsset, uint256 amount);
    event HighwaterMarkReset();

    //============================== IMMUTABLES ===============================

    /**
     * @notice The base asset rates are provided in.
     */
    ERC20 public immutable base;

    /**
     * @notice The decimals rates are provided in.
     */
    uint8 public immutable decimals;

    /**
     * @notice The BoringVault this accountant is working with.
     *         Used to determine share supply for fee calculation.
     */
    BoringVault public immutable vault;

    /**
     * @notice One share of the BoringVault.
     */
    uint256 internal immutable ONE_SHARE;

    constructor(
        address _owner,
        address _vault,
        address payoutAddress,
        uint96 startingExchangeRate,
        address _base,
        uint16 allowedExchangeRateChangeUpper,
        uint16 allowedExchangeRateChangeLower,
        uint24 minimumUpdateDelayInSeconds,
        uint16 managementFee,
        uint16 performanceFee
    ) Auth(_owner, Authority(address(0))) {
        base = ERC20(_base);
        decimals = ERC20(_base).decimals();
        vault = BoringVault(payable(_vault));
        ONE_SHARE = 10 ** vault.decimals();
        accountantState = AccountantState({
            payoutAddress: payoutAddress,
            highwaterMark: startingExchangeRate,
            feesOwedInBase: 0,
            totalSharesLastUpdate: uint128(vault.totalSupply()),
            exchangeRate: startingExchangeRate,
            allowedExchangeRateChangeUpper: allowedExchangeRateChangeUpper,
            allowedExchangeRateChangeLower: allowedExchangeRateChangeLower,
            lastUpdateTimestamp: uint64(block.timestamp),
            isPaused: false,
            minimumUpdateDelayInSeconds: minimumUpdateDelayInSeconds,
            managementFee: managementFee,
            performanceFee: performanceFee
        });
    }

    // ========================================= ADMIN FUNCTIONS =========================================
    /**
     * @notice Pause this contract, which prevents future calls to `updateExchangeRate`, and any safe rate
     *         calls will revert.
     * @dev Callable by MULTISIG_ROLE.
     */
    function pause() external requiresAuth {
        accountantState.isPaused = true;
        emit Paused();
    }

    /**
     * @notice Unpause this contract, which allows future calls to `updateExchangeRate`, and any safe rate
     *         calls will stop reverting.
     * @dev Callable by MULTISIG_ROLE.
     */
    function unpause() external requiresAuth {
        accountantState.isPaused = false;
        emit Unpaused();
    }

    /**
     * @notice Update the minimum time delay between `updateExchangeRate` calls.
     * @dev There are no input requirements, as it is possible the admin would want
     *      the exchange rate updated as frequently as needed.
     * @dev Callable by OWNER_ROLE.
     */
    function updateDelay(uint24 minimumUpdateDelayInSeconds) external requiresAuth {
        if (minimumUpdateDelayInSeconds > 14 days) revert AccountantWithRateProviders__UpdateDelayTooLarge();
        uint24 oldDelay = accountantState.minimumUpdateDelayInSeconds;
        accountantState.minimumUpdateDelayInSeconds = minimumUpdateDelayInSeconds;
        emit DelayInSecondsUpdated(oldDelay, minimumUpdateDelayInSeconds);
    }

    /**
     * @notice Update the allowed upper bound change of exchange rate between `updateExchangeRateCalls`.
     * @dev Callable by OWNER_ROLE.
     */
    function updateUpper(uint16 allowedExchangeRateChangeUpper) external requiresAuth {
        if (allowedExchangeRateChangeUpper < 1e4) revert AccountantWithRateProviders__UpperBoundTooSmall();
        uint16 oldBound = accountantState.allowedExchangeRateChangeUpper;
        accountantState.allowedExchangeRateChangeUpper = allowedExchangeRateChangeUpper;
        emit UpperBoundUpdated(oldBound, allowedExchangeRateChangeUpper);
    }

    /**
     * @notice Update the allowed lower bound change of exchange rate between `updateExchangeRateCalls`.
     * @dev Callable by OWNER_ROLE.
     */
    function updateLower(uint16 allowedExchangeRateChangeLower) external requiresAuth {
        if (allowedExchangeRateChangeLower > 1e4) revert AccountantWithRateProviders__LowerBoundTooLarge();
        uint16 oldBound = accountantState.allowedExchangeRateChangeLower;
        accountantState.allowedExchangeRateChangeLower = allowedExchangeRateChangeLower;
        emit LowerBoundUpdated(oldBound, allowedExchangeRateChangeLower);
    }

    /**
     * @notice Update the management fee to a new value.
     * @dev Callable by OWNER_ROLE.
     */
    function updateManagementFee(uint16 managementFee) external requiresAuth {
        if (managementFee > 0.2e4) revert AccountantWithRateProviders__ManagementFeeTooLarge();
        uint16 oldFee = accountantState.managementFee;
        accountantState.managementFee = managementFee;
        emit ManagementFeeUpdated(oldFee, managementFee);
    }

    /**
     * @notice Update the performance fee to a new value.
     * @dev Callable by OWNER_ROLE.
     */
    function updatePerformanceFee(uint16 performanceFee) external requiresAuth {
        if (performanceFee > 0.5e4) revert AccountantWithRateProviders__PerformanceFeeTooLarge();
        uint16 oldFee = accountantState.performanceFee;
        accountantState.performanceFee = performanceFee;
        emit PerformanceFeeUpdated(oldFee, performanceFee);
    }

    /**
     * @notice Update the payout address fees are sent to.
     * @dev Callable by OWNER_ROLE.
     */
    function updatePayoutAddress(address payoutAddress) external requiresAuth {
        address oldPayout = accountantState.payoutAddress;
        accountantState.payoutAddress = payoutAddress;
        emit PayoutAddressUpdated(oldPayout, payoutAddress);
    }

    /**
     * @notice Update the rate provider data for a specific `asset`.
     * @dev Rate providers must return rates in terms of `base` or
     * an asset pegged to base and they must use the same decimals
     * as `asset`.
     * @dev Callable by OWNER_ROLE.
     */
    function setRateProviderData(ERC20 asset, bool isPeggedToBase, address rateProvider) external requiresAuth {
        rateProviderData[asset] =
            RateProviderData({isPeggedToBase: isPeggedToBase, rateProvider: IRateProvider(rateProvider)});
        emit RateProviderUpdated(address(asset), isPeggedToBase, rateProvider);
    }

    /**
     * @notice Reset the highwater mark to the current exchange rate.
     * @dev Callable by OWNER_ROLE.
     */
    function resetHighwaterMark() external requiresAuth {
        AccountantState storage state = accountantState;

        if (state.exchangeRate > state.highwaterMark) {
            revert AccountantWithRateProviders__ExchangeRateAboveHighwaterMark();
        }

        uint64 currentTime = uint64(block.timestamp);
        uint256 currentTotalShares = vault.totalSupply();
        _calculateFeesOwed(state, state.exchangeRate, state.exchangeRate, currentTotalShares, currentTime);
        state.totalSharesLastUpdate = uint128(currentTotalShares);
        state.highwaterMark = accountantState.exchangeRate;
        state.lastUpdateTimestamp = currentTime;

        emit HighwaterMarkReset();
    }

    // ========================================= UPDATE EXCHANGE RATE/FEES FUNCTIONS =========================================

    /**
     * @notice Updates this contract exchangeRate.
     * @dev If new exchange rate is outside of accepted bounds, or if not enough time has passed, this
     *      will pause the contract, and this function will NOT calculate fees owed.
     * @dev Callable by UPDATE_EXCHANGE_RATE_ROLE.
     */
    function updateExchangeRate(uint96 newExchangeRate) external requiresAuth {
        AccountantState storage state = accountantState;
        if (state.isPaused) revert AccountantWithRateProviders__Paused();
        uint64 currentTime = uint64(block.timestamp);
        uint256 currentExchangeRate = state.exchangeRate;
        uint256 currentTotalShares = vault.totalSupply();
        if (
            currentTime < state.lastUpdateTimestamp + state.minimumUpdateDelayInSeconds
                || newExchangeRate > currentExchangeRate.mulDivDown(state.allowedExchangeRateChangeUpper, 1e4)
                || newExchangeRate < currentExchangeRate.mulDivDown(state.allowedExchangeRateChangeLower, 1e4)
        ) {
            // Instead of reverting, pause the contract. This way the exchange rate updater is able to update the exchange rate
            // to a better value, and pause it.
            state.isPaused = true;
        } else {
            _calculateFeesOwed(state, newExchangeRate, currentExchangeRate, currentTotalShares, currentTime);
        }

        state.exchangeRate = newExchangeRate;
        state.totalSharesLastUpdate = uint128(currentTotalShares);
        state.lastUpdateTimestamp = currentTime;

        emit ExchangeRateUpdated(uint96(currentExchangeRate), newExchangeRate, currentTime);
    }

    /**
     * @notice Claim pending fees.
     * @dev This function must be called by the BoringVault.
     * @dev This function will lose precision if the exchange rate
     *      decimals is greater than the feeAsset's decimals.
     */
    function claimFees(ERC20 feeAsset) external {
        if (msg.sender != address(vault)) revert AccountantWithRateProviders__OnlyCallableByBoringVault();

        AccountantState storage state = accountantState;
        if (state.isPaused) revert AccountantWithRateProviders__Paused();
        if (state.feesOwedInBase == 0) revert AccountantWithRateProviders__ZeroFeesOwed();

        // Determine amount of fees owed in feeAsset.
        uint256 feesOwedInFeeAsset;
        RateProviderData memory data = rateProviderData[feeAsset];
        if (address(feeAsset) == address(base)) {
            feesOwedInFeeAsset = state.feesOwedInBase;
        } else {
            uint8 feeAssetDecimals = ERC20(feeAsset).decimals();
            uint256 feesOwedInBaseUsingFeeAssetDecimals =
                changeDecimals(state.feesOwedInBase, decimals, feeAssetDecimals);
            if (data.isPeggedToBase) {
                feesOwedInFeeAsset = feesOwedInBaseUsingFeeAssetDecimals;
            } else {
                uint256 rate = data.rateProvider.getRate();
                feesOwedInFeeAsset = feesOwedInBaseUsingFeeAssetDecimals.mulDivDown(10 ** feeAssetDecimals, rate);
            }
        }
        // Zero out fees owed.
        state.feesOwedInBase = 0;
        // Transfer fee asset to payout address.
        feeAsset.safeTransferFrom(msg.sender, state.payoutAddress, feesOwedInFeeAsset);

        emit FeesClaimed(address(feeAsset), feesOwedInFeeAsset);
    }

    // ========================================= RATE FUNCTIONS =========================================

    /**
     * @notice Get this BoringVault's current rate in the base.
     */
    function getRate() public view returns (uint256 rate) {
        rate = accountantState.exchangeRate;
    }

    /**
     * @notice Get this BoringVault's current rate in the base.
     * @dev Revert if paused.
     */
    function getRateSafe() external view returns (uint256 rate) {
        if (accountantState.isPaused) revert AccountantWithRateProviders__Paused();
        rate = getRate();
    }

    /**
     * @notice Get this BoringVault's current rate in the provided quote.
     * @dev `quote` must have its RateProviderData set, else this will revert.
     * @dev This function will lose precision if the exchange rate
     *      decimals is greater than the quote's decimals.
     */
    function getRateInQuote(ERC20 quote) public view returns (uint256 rateInQuote) {
        if (address(quote) == address(base)) {
            rateInQuote = accountantState.exchangeRate;
        } else {
            RateProviderData memory data = rateProviderData[quote];
            uint8 quoteDecimals = ERC20(quote).decimals();
            uint256 exchangeRateInQuoteDecimals = changeDecimals(accountantState.exchangeRate, decimals, quoteDecimals);
            if (data.isPeggedToBase) {
                rateInQuote = exchangeRateInQuoteDecimals;
            } else {
                uint256 quoteRate = data.rateProvider.getRate();
                uint256 oneQuote = 10 ** quoteDecimals;
                rateInQuote = oneQuote.mulDivDown(exchangeRateInQuoteDecimals, quoteRate);
            }
        }
    }

    /**
     * @notice Get this BoringVault's current rate in the provided quote.
     * @dev `quote` must have its RateProviderData set, else this will revert.
     * @dev Revert if paused.
     */
    function getRateInQuoteSafe(ERC20 quote) external view returns (uint256 rateInQuote) {
        if (accountantState.isPaused) revert AccountantWithRateProviders__Paused();
        rateInQuote = getRateInQuote(quote);
    }

    // ========================================= INTERNAL HELPER FUNCTIONS =========================================
    /**
     * @notice Used to change the decimals of precision used for an amount.
     */
    function changeDecimals(uint256 amount, uint8 fromDecimals, uint8 toDecimals) internal pure returns (uint256) {
        if (fromDecimals == toDecimals) {
            return amount;
        } else if (fromDecimals < toDecimals) {
            return amount * 10 ** (toDecimals - fromDecimals);
        } else {
            return amount / 10 ** (fromDecimals - toDecimals);
        }
    }

    /**
     * @notice Calculate fees owed in base.
     * @dev This function will update the highwater mark if the new exchange rate is higher.
     */
    function _calculateFeesOwed(
        AccountantState storage state,
        uint96 newExchangeRate,
        uint256 currentExchangeRate,
        uint256 currentTotalShares,
        uint64 currentTime
    ) internal {
        // Only update fees if we are not paused.
        // Update fee accounting.
        uint256 shareSupplyToUse = currentTotalShares;
        // Use the minimum between current total supply and total supply for last update.
        if (state.totalSharesLastUpdate < shareSupplyToUse) {
            shareSupplyToUse = state.totalSharesLastUpdate;
        }

        // Determine management fees owned.
        uint256 timeDelta = currentTime - state.lastUpdateTimestamp;
        uint256 minimumAssets = newExchangeRate > currentExchangeRate
            ? shareSupplyToUse.mulDivDown(currentExchangeRate, ONE_SHARE)
            : shareSupplyToUse.mulDivDown(newExchangeRate, ONE_SHARE);
        uint256 managementFeesAnnual = minimumAssets.mulDivDown(state.managementFee, 1e4);
        uint256 newFeesOwedInBase = managementFeesAnnual.mulDivDown(timeDelta, 365 days);

        // Account for performance fees.
        if (newExchangeRate > state.highwaterMark) {
            if (state.performanceFee > 0) {
                uint256 changeInExchangeRate = newExchangeRate - state.highwaterMark;
                uint256 yieldEarned = changeInExchangeRate.mulDivDown(shareSupplyToUse, ONE_SHARE);
                uint256 performanceFeesOwedInBase = yieldEarned.mulDivDown(state.performanceFee, 1e4);
                newFeesOwedInBase += performanceFeesOwedInBase;
            }
            // Always update the highwater mark if the new exchange rate is higher.
            // This way if we are not iniitiall taking performance fees, we can start taking them
            // without back charging them on past performance.
            state.highwaterMark = newExchangeRate;
        }

        state.feesOwedInBase += uint128(newFeesOwedInBase);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

interface BeforeTransferHook {
    function beforeTransfer(address from, address to, address operator) external view;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

interface IPausable {
    function pause() external;
    function unpause() external;
}
// SPDX-License-Identifier: GPL-3.0-or-later
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.8.0;

interface IRateProvider {
    function getRate() external view returns (uint256);
}