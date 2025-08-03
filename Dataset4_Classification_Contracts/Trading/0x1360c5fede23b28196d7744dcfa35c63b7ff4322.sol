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
     * @dev Handles the receipt of a single ERC-1155 token type. This function is
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
     * @dev Handles the receipt of a multiple ERC-1155 token types. This function
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
 * @dev Simple implementation of `IERC1155Receiver` that will allow a contract to hold ERC-1155 tokens.
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
 * @title ERC-721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC-721 asset contracts.
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

import {Errors} from "./Errors.sol";

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

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
            revert Errors.InsufficientBalance(address(this).balance, amount);
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert Errors.FailedCall();
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
     * {Errors.FailedCall} error.
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
            revert Errors.InsufficientBalance(address(this).balance, value);
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
     * was not a contract or bubbling up the revert reason (falling back to {Errors.FailedCall}) in case
     * of an unsuccessful call.
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
     * revert reason or with a default {Errors.FailedCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {Errors.FailedCall}.
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
            revert Errors.FailedCall();
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/**
 * @dev Collection of common custom errors used in multiple contracts
 *
 * IMPORTANT: Backwards compatibility is not guaranteed in future versions of the library.
 * It is recommended to avoid relying on the error API for critical functionality.
 */
library Errors {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error InsufficientBalance(uint256 balance, uint256 needed);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedCall();

    /**
     * @dev The deployment failed.
     */
    error FailedDeployment();

    /**
     * @dev A necessary precompile is missing.
     */
    error MissingPrecompile(address);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/ERC165.sol)

pragma solidity ^0.8.20;

import {IERC165} from "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC-165 should inherit from this contract and override {supportsInterface} to check
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
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
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
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
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

import {ERC20} from "./ERC20.sol";

import {SafeTransferLib} from "../utils/SafeTransferLib.sol";

/// @notice Minimalist and modern Wrapped Ether implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/WETH.sol)
/// @author Inspired by WETH9 (https://github.com/dapphub/ds-weth/blob/master/src/weth9.sol)
contract WETH is ERC20("Wrapped Ether", "WETH", 18) {
    using SafeTransferLib for address;

    event Deposit(address indexed from, uint256 amount);

    event Withdrawal(address indexed to, uint256 amount);

    function deposit() public payable virtual {
        _mint(msg.sender, msg.value);

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public virtual {
        _burn(msg.sender, amount);

        emit Withdrawal(msg.sender, amount);

        msg.sender.safeTransferETH(amount);
    }

    receive() external payable virtual {
        deposit();
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
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { ERC721Holder } from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import { ERC1155Holder } from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import { FixedPointMathLib } from "@solmate/utils/FixedPointMathLib.sol";
import { SafeTransferLib } from "@solmate/utils/SafeTransferLib.sol";
import { ERC20 } from "@solmate/tokens/ERC20.sol";
import { BeforeTransferHook } from "src/interfaces/BeforeTransferHook.sol";
import { Auth, Authority } from "@solmate/auth/Auth.sol";

/**
 * @title BoringVault
 * @custom:security-contact security@molecularlabs.io
 */
contract BoringVault is ERC20, Auth, ERC721Holder, ERC1155Holder {
    using Address for address;
    using SafeTransferLib for ERC20;
    using FixedPointMathLib for uint256;

    // ========================================= STATE =========================================

    /**
     * @notice Contract responsible for implementing `beforeTransfer`.
     */
    BeforeTransferHook public hook;

    //============================== EVENTS ===============================

    event Enter(address indexed from, address indexed asset, uint256 amount, address indexed to, uint256 shares);
    event Exit(address indexed to, address indexed asset, uint256 amount, address indexed from, uint256 shares);

    //============================== CONSTRUCTOR ===============================

    constructor(
        address _owner,
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    )
        ERC20(_name, _symbol, _decimals)
        Auth(_owner, Authority(address(0)))
    { }

    //============================== MANAGE ===============================

    /**
     * @notice Allows manager to make an arbitrary function call from this contract.
     * @dev Callable by MANAGER_ROLE.
     */
    function manage(
        address target,
        bytes calldata data,
        uint256 value
    )
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
    function manage(
        address[] calldata targets,
        bytes[] calldata data,
        uint256[] calldata values
    )
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
    function enter(
        address from,
        ERC20 asset,
        uint256 assetAmount,
        address to,
        uint256 shareAmount
    )
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
    function exit(
        address to,
        ERC20 asset,
        uint256 assetAmount,
        address from,
        uint256 shareAmount
    )
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
     * @notice Check if from addresses shares are locked, reverting if so.
     */
    function _callBeforeTransfer(address from) internal view {
        if (address(hook) != address(0)) hook.beforeTransfer(from);
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        _callBeforeTransfer(msg.sender);
        return super.transfer(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        _callBeforeTransfer(from);
        return super.transferFrom(from, to, amount);
    }

    //============================== RECEIVE ===============================

    receive() external payable { }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { FixedPointMathLib } from "@solmate/utils/FixedPointMathLib.sol";
import { IRateProvider } from "src/interfaces/IRateProvider.sol";
import { ERC20 } from "@solmate/tokens/ERC20.sol";
import { SafeTransferLib } from "@solmate/utils/SafeTransferLib.sol";
import { BoringVault } from "src/base/BoringVault.sol";
import { Auth, Authority } from "@solmate/auth/Auth.sol";

/**
 * @title AccountantWithRateProviders
 * @custom:security-contact security@molecularlabs.io
 */
contract AccountantWithRateProviders is Auth, IRateProvider {
    using FixedPointMathLib for uint256;
    using SafeTransferLib for ERC20;

    // ========================================= STRUCTS =========================================

    /**
     * @param payoutAddress the address `claimFees` sends fees to
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
     */
    struct AccountantState {
        address payoutAddress;
        uint128 feesOwedInBase;
        uint128 totalSharesLastUpdate;
        uint96 exchangeRate;
        uint16 allowedExchangeRateChangeUpper;
        uint16 allowedExchangeRateChangeLower;
        uint64 lastUpdateTimestamp;
        bool isPaused;
        uint32 minimumUpdateDelayInSeconds;
        uint16 managementFee;
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
    error AccountantWithRateProviders__Paused();
    error AccountantWithRateProviders__ZeroFeesOwed();
    error AccountantWithRateProviders__OnlyCallableByBoringVault();
    error AccountantWithRateProviders__UpdateDelayTooLarge();

    //============================== EVENTS ===============================

    event Paused();
    event Unpaused();
    event DelayInSecondsUpdated(uint32 oldDelay, uint32 newDelay);
    event UpperBoundUpdated(uint16 oldBound, uint16 newBound);
    event LowerBoundUpdated(uint16 oldBound, uint16 newBound);
    event ManagementFeeUpdated(uint16 oldFee, uint16 newFee);
    event PayoutAddressUpdated(address oldPayout, address newPayout);
    event RateProviderUpdated(address asset, bool isPegged, address rateProvider);
    event ExchangeRateUpdated(uint96 oldRate, uint96 newRate, uint64 currentTime);
    event FeesClaimed(address indexed feeAsset, uint256 amount);

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
        uint32 minimumUpdateDelayInSeconds,
        uint16 managementFee
    )
        Auth(_owner, Authority(address(0)))
    {
        base = ERC20(_base);
        decimals = ERC20(_base).decimals();
        vault = BoringVault(payable(_vault));
        ONE_SHARE = 10 ** vault.decimals();
        accountantState = AccountantState({
            payoutAddress: payoutAddress,
            feesOwedInBase: 0,
            totalSharesLastUpdate: uint128(vault.totalSupply()),
            exchangeRate: startingExchangeRate,
            allowedExchangeRateChangeUpper: allowedExchangeRateChangeUpper,
            allowedExchangeRateChangeLower: allowedExchangeRateChangeLower,
            lastUpdateTimestamp: uint64(block.timestamp),
            isPaused: false,
            minimumUpdateDelayInSeconds: minimumUpdateDelayInSeconds,
            managementFee: managementFee
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
    function updateDelay(uint32 minimumUpdateDelayInSeconds) external requiresAuth {
        if (minimumUpdateDelayInSeconds > 14 days) revert AccountantWithRateProviders__UpdateDelayTooLarge();
        uint32 oldDelay = accountantState.minimumUpdateDelayInSeconds;
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
            RateProviderData({ isPeggedToBase: isPeggedToBase, rateProvider: IRateProvider(rateProvider) });
        emit RateProviderUpdated(address(asset), isPeggedToBase, rateProvider);
    }

    // ========================================= UPDATE EXCHANGE RATE/FEES FUNCTIONS
    // =========================================

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
            // Instead of reverting, pause the contract. This way the exchange rate updater is able to update the
            // exchange rate
            // to a better value, and pause it.
            state.isPaused = true;
        } else {
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

            state.feesOwedInBase += uint128(newFeesOwedInBase);
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
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { TellerWithMultiAssetSupport } from "../TellerWithMultiAssetSupport.sol";
import { ERC20 } from "@solmate/tokens/ERC20.sol";

struct BridgeData {
    uint32 chainSelector;
    address destinationChainReceiver;
    ERC20 bridgeFeeToken;
    uint64 messageGas;
    bytes data;
}

/**
 * @title CrossChainTellerBase
 * @notice Base contract for the CrossChainTeller, includes functions to overload with specific bridge method
 */
abstract contract CrossChainTellerBase is TellerWithMultiAssetSupport {
    event MessageSent(bytes32 messageId, uint256 shareAmount, address to);
    event MessageReceived(bytes32 messageId, uint256 shareAmount, address to);

    constructor(
        address _owner,
        address _vault,
        address _accountant
    )
        TellerWithMultiAssetSupport(_owner, _vault, _accountant)
    { }

    /**
     * @notice function to deposit into the vault AND bridge crosschain in 1 call
     * @param depositAsset ERC20 to deposit
     * @param depositAmount amount of deposit asset to deposit
     * @param minimumMint minimum required shares to receive
     * @param data Bridge Data
     */
    function depositAndBridge(
        ERC20 depositAsset,
        uint256 depositAmount,
        uint256 minimumMint,
        BridgeData calldata data
    )
        external
        payable
        requiresAuth
        nonReentrant
    {
        if (!isSupported[depositAsset]) {
            revert TellerWithMultiAssetSupport__AssetNotSupported();
        }

        uint256 shareAmount = _erc20Deposit(depositAsset, depositAmount, minimumMint, msg.sender);
        _afterPublicDeposit(msg.sender, depositAsset, depositAmount, shareAmount, shareLockPeriod);
        bridge(shareAmount, data);
    }

    /**
     * @notice Preview fee required to bridge shares in a given feeToken.
     */
    function previewFee(uint256 shareAmount, BridgeData calldata data) external view returns (uint256 fee) {
        return _quote(shareAmount, data);
    }

    /**
     * @notice bridging code to be done without deposit, for users who already have vault tokens
     * @param shareAmount to bridge
     * @param data bridge data
     */
    function bridge(
        uint256 shareAmount,
        BridgeData calldata data
    )
        public
        payable
        requiresAuth
        returns (bytes32 messageId)
    {
        if (isPaused) revert TellerWithMultiAssetSupport__Paused();

        _beforeBridge(data);

        // Since shares are directly burned, call `beforeTransfer` to enforce before transfer hooks.
        beforeTransfer(msg.sender);

        // Burn shares from sender
        vault.exit(address(0), ERC20(address(0)), 0, msg.sender, shareAmount);

        messageId = _bridge(shareAmount, data);
        _afterBridge(shareAmount, data, messageId);
    }

    /**
     * @notice the virtual bridge function to be overridden
     * @param data bridge data
     * @return messageId
     */
    function _bridge(uint256 shareAmount, BridgeData calldata data) internal virtual returns (bytes32);

    /**
     * @notice the virtual function to override to get bridge fees
     * @param shareAmount to send
     * @param data bridge data
     */
    function _quote(uint256 shareAmount, BridgeData calldata data) internal view virtual returns (uint256);

    /**
     * @notice after bridge code, just an emit but can be overridden
     * @notice the before bridge hook to perform additional checks
     * @param data bridge data
     */
    function _beforeBridge(BridgeData calldata data) internal virtual;

    /**
     * @notice after bridge code, just an emit but can be overridden
     * @param shareAmount share amount burned
     * @param data bridge data
     * @param messageId message id returned when bridged
     */
    function _afterBridge(uint256 shareAmount, BridgeData calldata data, bytes32 messageId) internal virtual {
        emit MessageSent(messageId, shareAmount, data.destinationChainReceiver);
    }

    /**
     * @notice a before receive hook to call some logic before a receive is processed
     */
    function _beforeReceive() internal virtual {
        if (isPaused) revert TellerWithMultiAssetSupport__Paused();
    }

    /**
     * @notice a hook to execute after receiving
     * @param shareAmount the shareAmount that was minted
     * @param destinationChainReceiver the receiver of the shares
     * @param messageId the message ID
     */
    function _afterReceive(uint256 shareAmount, address destinationChainReceiver, bytes32 messageId) internal virtual {
        emit MessageReceived(messageId, shareAmount, destinationChainReceiver);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {
    MultiChainTellerBase,
    MultiChainTellerBase_MessagesNotAllowedFrom,
    MultiChainTellerBase_MessagesNotAllowedFromSender,
    Chain
} from "./MultiChainTellerBase.sol";
import { BridgeData, ERC20 } from "./CrossChainTellerBase.sol";
import { StandardHookMetadata } from "../../../helper/StandardHookMetadata.sol";
import { IMailbox } from "../../../interfaces/hyperlane/IMailbox.sol";
import { IInterchainSecurityModule } from "../../../interfaces/hyperlane/IInterchainSecurityModule.sol";
import { IPostDispatchHook } from "../../../interfaces/hyperlane/IPostDispatchHook.sol";

/**
 * @title MultiChainHyperlaneTellerWithMultiAssetSupport
 * @notice Hyperlane implementation of MultiChainTeller
 * @custom:security-contact security@molecularlabs.io
 */
contract MultiChainHyperlaneTellerWithMultiAssetSupport is MultiChainTellerBase {
    // ========================================= STATE =========================================

    /**
     * @notice The Hyperlane mailbox contract.
     */
    IMailbox public immutable mailbox;

    /**
     * @notice The Hyperlane interchain security module.
     * @dev If `address(0)`, uses the mailbox's default ISM.
     */
    IInterchainSecurityModule public interchainSecurityModule;

    /**
     * @notice The hook invoked after `dispatch`.
     */
    IPostDispatchHook public hook;

    /**
     * @notice A nonce used to generate unique message IDs.
     */
    uint128 public nonce;

    //============================== EVENTS ===============================

    event SetInterChainSecurityModule(address _interchainSecurityModule);
    event SetPostDispatchHook(address _hook);

    //============================== ERRORS ===============================

    error MultiChainHyperlaneTellerWithMultiAssetSupport_InvalidBridgeFeeToken();
    error MultiChainHyperlaneTellerWithMultiAssetSupport_CallerMustBeMailbox(address caller);
    error MultiChainHyperlaneTellerWithMultiAssetSupport_InvalidBytes32Address(bytes32 _address);
    error MultiChainHyperlaneTellerWithMultiAssetSupport_ZeroAddressDestinationReceiver();

    constructor(
        address _owner,
        address _vault,
        address _accountant,
        IMailbox _mailbox
    )
        MultiChainTellerBase(_owner, _vault, _accountant)
    {
        mailbox = _mailbox;
    }

    /**
     * @notice Sets the post dispatch hook for Hyperlane mailbox.
     */
    function setHook(IPostDispatchHook _hook) external requiresAuth {
        hook = _hook;
        emit SetPostDispatchHook(address(_hook));
    }

    /**
     * @notice Sets a custom interchain security module for Hyperlane.
     */
    function setInterchainSecurityModule(IInterchainSecurityModule _interchainSecurityModule) external requiresAuth {
        interchainSecurityModule = _interchainSecurityModule;
        emit SetInterChainSecurityModule(address(_interchainSecurityModule));
    }

    /**
     * @notice function override to return the fee quote
     * @param shareAmount to be sent as a message
     * @param data Bridge data
     */
    function _quote(uint256 shareAmount, BridgeData calldata data) internal view override returns (uint256) {
        uint256 nextNonce = nonce + 1;
        bytes32 messageId = keccak256(abi.encodePacked(nextNonce, address(this), block.chainid));

        bytes memory _payload = abi.encode(shareAmount, data.destinationChainReceiver, messageId);

        bytes32 msgRecipient = _addressToBytes32(selectorToChains[data.chainSelector].targetTeller);

        return mailbox.quoteDispatch(
            data.chainSelector, msgRecipient, _payload, StandardHookMetadata.overrideGasLimit(data.messageGas), hook
        );
    }

    /**
     * @notice Called when data is received from the protocol. It overrides the equivalent function in the parent
     * contract.
     * Protocol messages are defined as packets, comprised of the following parameters.
     * @param origin A struct containing information about where the packet came from.
     * @param sender The contract that sent this message.
     * @param payload Encoded message.
     */
    function handle(uint32 origin, bytes32 sender, bytes calldata payload) external payable {
        _beforeReceive();

        Chain memory chain = selectorToChains[origin];

        // Three things must be checked.
        // 1. This function must only be called by the mailbox
        // 2. The sender must be the teller from the source chain
        // 3. The origin aka chainSelector must be allowed to send message to this
        // contract through the `Chain` config.
        if (msg.sender != address(mailbox)) {
            revert MultiChainHyperlaneTellerWithMultiAssetSupport_CallerMustBeMailbox(msg.sender);
        }

        if (sender != _addressToBytes32(chain.targetTeller)) {
            revert MultiChainTellerBase_MessagesNotAllowedFromSender(uint256(origin), _bytes32ToAddress(sender));
        }

        if (!chain.allowMessagesFrom) {
            revert MultiChainTellerBase_MessagesNotAllowedFrom(origin);
        }

        (uint256 shareAmount, address receiver, bytes32 messageId) = abi.decode(payload, (uint256, address, bytes32));

        // This should never be the case since zero address
        // `destinationChainReceiver` in `_bridge` is not allowed, but we have
        // this as a sanity check.
        if (receiver == address(0)) {
            revert MultiChainHyperlaneTellerWithMultiAssetSupport_ZeroAddressDestinationReceiver();
        }

        vault.enter(address(0), ERC20(address(0)), 0, receiver, shareAmount);

        _afterReceive(shareAmount, receiver, messageId);
    }

    /**
     * @notice bridge override to allow bridge logic to be done for bridge() and depositAndBridge()
     * @param shareAmount to be moved across chain
     * @param data BridgeData
     * @return messageId a unique hash for the message
     */
    function _bridge(uint256 shareAmount, BridgeData calldata data) internal override returns (bytes32 messageId) {
        // We create our own guid and pass it into the payload for it to be
        // parsed in `handle`. There is no way to pass the return `messageId`
        // from `dispatch` to `handle`.
        unchecked {
            messageId = keccak256(abi.encodePacked(++nonce, address(this), block.chainid));
        }

        if (address(data.bridgeFeeToken) != NATIVE) {
            revert MultiChainHyperlaneTellerWithMultiAssetSupport_InvalidBridgeFeeToken();
        }

        if (data.destinationChainReceiver == address(0)) {
            revert MultiChainHyperlaneTellerWithMultiAssetSupport_ZeroAddressDestinationReceiver();
        }

        bytes memory _payload = abi.encode(shareAmount, data.destinationChainReceiver, messageId);

        // Unlike L0 that has a built in peer check, this contract must
        // constrain the message recipient itself. We do this by our own
        // configuration.
        bytes32 msgRecipient = _addressToBytes32(selectorToChains[data.chainSelector].targetTeller);

        mailbox.dispatch{ value: msg.value }(
            data.chainSelector, // must be `destinationDomain` on hyperlane
            msgRecipient, // must be the teller address left-padded to bytes32
            _payload,
            StandardHookMetadata.overrideGasLimit(data.messageGas), // Sets the refund address to msg.sender, sets
                // `_msgValue` to zero
            hook
        );
    }

    function _addressToBytes32(address _address) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_address)));
    }

    function _bytes32ToAddress(bytes32 _address) internal pure returns (address) {
        if (uint256(_address) > uint256(type(uint160).max)) {
            revert MultiChainHyperlaneTellerWithMultiAssetSupport_InvalidBytes32Address(_address);
        }

        return address(uint160(uint256(_address)));
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { CrossChainTellerBase, BridgeData } from "./CrossChainTellerBase.sol";

struct Chain {
    bool allowMessagesFrom;
    bool allowMessagesTo;
    address targetTeller;
    uint64 messageGasLimit;
    uint64 minimumMessageGas;
}

error MultiChainTellerBase_MessagesNotAllowedFrom(uint32 chainSelector);
error MultiChainTellerBase_MessagesNotAllowedFromSender(uint256 chainSelector, address sender);
error MultiChainTellerBase_MessagesNotAllowedTo(uint256 chainSelector);
error MultiChainTellerBase_TargetTellerIsZeroAddress();
error MultiChainTellerBase_DestinationChainReceiverIsZeroAddress();
error MultiChainTellerBase_ZeroMessageGasLimit();
error MultiChainTellerBase_GasLimitExceeded();
error MultiChainTellerBase_GasTooLow();

/**
 * @title MultiChainTellerBase
 * @notice Base contract for the MultiChainTellers,
 * We've noticed that many bridge options are L1 -> L2 only, which are quite simple IE Optimism Messenger
 * While others like LZ that can contact many bridges, contain lots of additional complexity to manage the configuration
 * for these chains
 * To keep this separated we are using this MultiChain syntax for the > 2 chain messaging while only CrossChain for 2
 * chain messengers like OP
 */
abstract contract MultiChainTellerBase is CrossChainTellerBase {
    event ChainAdded(
        uint256 chainSelector,
        bool allowMessagesFrom,
        bool allowMessagesTo,
        address targetTeller,
        uint64 messageGasLimit,
        uint64 messageGasMin
    );
    event ChainRemoved(uint256 chainSelector);
    event ChainAllowMessagesFrom(uint256 chainSelector, address targetTeller);
    event ChainAllowMessagesTo(uint256 chainSelector, address targetTeller);
    event ChainStopMessagesFrom(uint256 chainSelector);
    event ChainStopMessagesTo(uint256 chainSelector);
    event ChainSetGasLimit(uint256 chainSelector, uint64 messageGasLimit);

    mapping(uint32 => Chain) public selectorToChains;

    constructor(
        address _owner,
        address _vault,
        address _accountant
    )
        CrossChainTellerBase(_owner, _vault, _accountant)
    { }

    /**
     * @dev Callable by OWNER_ROLE.
     * @notice adds an acceptable chain to bridge to
     * @param chainSelector chainSelector of chain
     * @param allowMessagesFrom allow messages from this chain
     * @param allowMessagesTo allow messages to the chain
     * @param targetTeller address of the target teller on this chain
     * @param messageGasLimit to pass to bridge
     * @param messageGasMin to require a minimum provided gas for this chain
     */
    function addChain(
        uint32 chainSelector,
        bool allowMessagesFrom,
        bool allowMessagesTo,
        address targetTeller,
        uint64 messageGasLimit,
        uint64 messageGasMin
    )
        external
        requiresAuth
    {
        if (allowMessagesTo && messageGasLimit == 0) {
            revert MultiChainTellerBase_ZeroMessageGasLimit();
        }
        selectorToChains[chainSelector] =
            Chain(allowMessagesFrom, allowMessagesTo, targetTeller, messageGasLimit, messageGasMin);

        emit ChainAdded(chainSelector, allowMessagesFrom, allowMessagesTo, targetTeller, messageGasLimit, messageGasMin);
    }

    /**
     * @dev Callable by OWNER_ROLE.
     * @notice block messages from a particular chain
     * @param chainSelector of chain
     */
    function stopMessagesFromChain(uint32 chainSelector) external requiresAuth {
        Chain storage chain = selectorToChains[chainSelector];
        chain.allowMessagesFrom = false;

        emit ChainStopMessagesFrom(chainSelector);
    }

    /**
     * @dev Callable by OWNER_ROLE.
     * @notice allow messages from a particular chain
     * @param chainSelector of chain
     */
    function allowMessagesFromChain(uint32 chainSelector, address targetTeller) external requiresAuth {
        Chain storage chain = selectorToChains[chainSelector];
        chain.allowMessagesFrom = true;
        chain.targetTeller = targetTeller;

        emit ChainAllowMessagesFrom(chainSelector, targetTeller);
    }

    /**
     * @dev Callable by OWNER_ROLE.
     * @notice Remove a chain from the teller.
     * @dev Callable by OWNER_ROLE.
     */
    function removeChain(uint32 chainSelector) external requiresAuth {
        delete selectorToChains[chainSelector];

        emit ChainRemoved(chainSelector);
    }

    /**
     * @dev Callable by OWNER_ROLE.
     * @notice Allow messages to a chain.
     */
    function allowMessagesToChain(
        uint32 chainSelector,
        address targetTeller,
        uint64 messageGasLimit
    )
        external
        requiresAuth
    {
        if (messageGasLimit == 0) {
            revert MultiChainTellerBase_ZeroMessageGasLimit();
        }
        Chain storage chain = selectorToChains[chainSelector];
        chain.allowMessagesTo = true;
        chain.targetTeller = targetTeller;
        chain.messageGasLimit = messageGasLimit;

        emit ChainAllowMessagesTo(chainSelector, targetTeller);
    }

    /**
     * @dev Callable by OWNER_ROLE.
     * @notice Stop messages to a chain.
     */
    function stopMessagesToChain(uint32 chainSelector) external requiresAuth {
        Chain storage chain = selectorToChains[chainSelector];
        chain.allowMessagesTo = false;

        emit ChainStopMessagesTo(chainSelector);
    }

    /**
     * @dev Callable by OWNER_ROLE.
     * @notice Set the gas limit for messages to a chain.
     */
    function setChainGasLimit(uint32 chainSelector, uint64 messageGasLimit) external requiresAuth {
        if (messageGasLimit == 0) {
            revert MultiChainTellerBase_ZeroMessageGasLimit();
        }
        Chain storage chain = selectorToChains[chainSelector];
        chain.messageGasLimit = messageGasLimit;

        emit ChainSetGasLimit(chainSelector, messageGasLimit);
    }

    /**
     * @notice override beforeBridge to check Chain struct
     * @param data bridge data
     */
    function _beforeBridge(BridgeData calldata data) internal override {
        Chain memory chain = selectorToChains[data.chainSelector];

        if (!chain.allowMessagesTo) {
            revert MultiChainTellerBase_MessagesNotAllowedTo(data.chainSelector);
        }

        if (chain.targetTeller == address(0)) {
            revert MultiChainTellerBase_TargetTellerIsZeroAddress();
        }

        if (data.destinationChainReceiver == address(0)) {
            revert MultiChainTellerBase_DestinationChainReceiverIsZeroAddress();
        }

        if (data.messageGas > chain.messageGasLimit) {
            revert MultiChainTellerBase_GasLimitExceeded();
        }

        if (data.messageGas < chain.minimumMessageGas) {
            revert MultiChainTellerBase_GasTooLow();
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { ERC20 } from "@solmate/tokens/ERC20.sol";
import { WETH } from "@solmate/tokens/WETH.sol";
import { BoringVault } from "src/base/BoringVault.sol";
import { AccountantWithRateProviders } from "src/base/Roles/AccountantWithRateProviders.sol";
import { FixedPointMathLib } from "@solmate/utils/FixedPointMathLib.sol";
import { SafeTransferLib } from "@solmate/utils/SafeTransferLib.sol";
import { BeforeTransferHook } from "src/interfaces/BeforeTransferHook.sol";
import { Auth, Authority } from "@solmate/auth/Auth.sol";
import { ReentrancyGuard } from "@solmate/utils/ReentrancyGuard.sol";

/**
 * @title TellerWithMultiAssetSupport
 * @custom:security-contact security@molecularlabs.io
 */
contract TellerWithMultiAssetSupport is Auth, BeforeTransferHook, ReentrancyGuard {
    using FixedPointMathLib for uint256;
    using SafeTransferLib for ERC20;
    using SafeTransferLib for WETH;

    // ========================================= CONSTANTS =========================================

    /**
     * @notice Native address used to tell the contract to handle native asset deposits.
     */
    address internal constant NATIVE = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /**
     * @notice The maximum possible share lock period.
     */
    uint256 internal constant MAX_SHARE_LOCK_PERIOD = 3 days;

    // ========================================= STATE =========================================

    /**
     * @notice Mapping ERC20s to an isSupported bool.
     */
    mapping(ERC20 => bool) public isSupported;

    /**
     * @notice The deposit nonce used to map to a deposit hash.
     */
    uint96 public depositNonce = 1;

    /**
     * @notice After deposits, shares are locked to the msg.sender's address
     *         for `shareLockPeriod`.
     * @dev During this time all transfers from msg.sender will revert, and
     *      deposits are refundable.
     */
    uint64 public shareLockPeriod;

    /**
     * @notice Used to pause calls to `deposit` and `depositWithPermit`.
     */
    bool public isPaused;

    /**
     * @dev Maps deposit nonce to keccak256(address receiver, address depositAsset, uint256 depositAmount, uint256
     * shareAmount, uint256 timestamp, uint256 shareLockPeriod).
     */
    mapping(uint256 => bytes32) public publicDepositHistory;

    /**
     * @notice Maps user address to the time their shares will be unlocked.
     */
    mapping(address => uint256) public shareUnlockTime;

    //============================== ERRORS ===============================

    error TellerWithMultiAssetSupport__ShareLockPeriodTooLong();
    error TellerWithMultiAssetSupport__SharesAreLocked();
    error TellerWithMultiAssetSupport__SharesAreUnLocked();
    error TellerWithMultiAssetSupport__BadDepositHash();
    error TellerWithMultiAssetSupport__AssetNotSupported();
    error TellerWithMultiAssetSupport__ZeroAssets();
    error TellerWithMultiAssetSupport__MinimumMintNotMet();
    error TellerWithMultiAssetSupport__MinimumAssetsNotMet();
    error TellerWithMultiAssetSupport__PermitFailedAndAllowanceTooLow();
    error TellerWithMultiAssetSupport__ZeroShares();
    error TellerWithMultiAssetSupport__Paused();

    //============================== EVENTS ===============================

    event Paused();
    event Unpaused();
    event AssetAdded(address indexed asset);
    event AssetRemoved(address indexed asset);
    event Deposit(
        uint256 indexed nonce,
        address indexed receiver,
        address indexed depositAsset,
        uint256 depositAmount,
        uint256 shareAmount,
        uint256 depositTimestamp,
        uint256 shareLockPeriodAtTimeOfDeposit
    );
    event BulkDeposit(address indexed asset, uint256 depositAmount);
    event BulkWithdraw(address indexed asset, uint256 shareAmount);
    event DepositRefunded(uint256 indexed nonce, bytes32 depositHash, address indexed user);

    //============================== IMMUTABLES ===============================

    /**
     * @notice The BoringVault this contract is working with.
     */
    BoringVault public immutable vault;

    /**
     * @notice The AccountantWithRateProviders this contract is working with.
     */
    AccountantWithRateProviders public immutable accountant;

    /**
     * @notice One share of the BoringVault.
     */
    uint256 internal immutable ONE_SHARE;

    constructor(address _owner, address _vault, address _accountant) Auth(_owner, Authority(address(0))) {
        vault = BoringVault(payable(_vault));
        ONE_SHARE = 10 ** vault.decimals();
        accountant = AccountantWithRateProviders(_accountant);
    }

    // ========================================= ADMIN FUNCTIONS =========================================

    /**
     * @notice Pause this contract, which prevents future calls to `deposit` and `depositWithPermit`.
     * @dev Callable by MULTISIG_ROLE.
     */
    function pause() external requiresAuth {
        isPaused = true;
        emit Paused();
    }

    /**
     * @notice Unpause this contract, which allows future calls to `deposit` and `depositWithPermit`.
     * @dev Callable by MULTISIG_ROLE.
     */
    function unpause() external requiresAuth {
        isPaused = false;
        emit Unpaused();
    }

    /**
     * @notice Adds this asset as a deposit asset.
     * @dev The accountant must also support pricing this asset, else the `deposit` call will revert.
     * @dev Callable by OWNER_ROLE.
     */
    function addAsset(ERC20 asset) external requiresAuth {
        isSupported[asset] = true;
        emit AssetAdded(address(asset));
    }

    /**
     * @notice Removes this asset as a deposit asset.
     * @dev Callable by OWNER_ROLE.
     */
    function removeAsset(ERC20 asset) external requiresAuth {
        isSupported[asset] = false;
        emit AssetRemoved(address(asset));
    }

    /**
     * @notice Sets the share lock period.
     * @dev This not only locks shares to the user address, but also serves as the pending deposit period, where
     * deposits can be reverted.
     * @dev If a new shorter share lock period is set, users with pending share locks could make a new deposit to
     * receive 1 wei shares,
     *      and have their shares unlock sooner than their original deposit allows. This state would allow for the user
     * deposit to be refunded,
     *      but only if they have not transferred their shares out of there wallet. This is an accepted limitation, and
     * should be known when decreasing
     *      the share lock period.
     * @dev Callable by OWNER_ROLE.
     */
    function setShareLockPeriod(uint64 _shareLockPeriod) external requiresAuth {
        if (_shareLockPeriod > MAX_SHARE_LOCK_PERIOD) revert TellerWithMultiAssetSupport__ShareLockPeriodTooLong();
        shareLockPeriod = _shareLockPeriod;
    }

    // ========================================= BeforeTransferHook FUNCTIONS =========================================

    /**
     * @notice Implement beforeTransfer hook to check if shares are locked.
     */
    function beforeTransfer(address from) public view {
        if (shareUnlockTime[from] > block.timestamp) revert TellerWithMultiAssetSupport__SharesAreLocked();
    }

    // ========================================= REVERT DEPOSIT FUNCTIONS =========================================

    /**
     * @notice Allows DEPOSIT_REFUNDER_ROLE to revert a pending deposit.
     * @dev Once a deposit share lock period has passed, it can no longer be reverted.
     * @dev It is possible the admin does not setup the BoringVault to call the transfer hook,
     *      but this contract can still be saving share lock state. In the event this happens
     *      deposits are still refundable if the user has not transferred their shares.
     *      But there is no guarantee that the user has not transferred their shares.
     * @dev Callable by STRATEGIST_MULTISIG_ROLE.
     */
    function refundDeposit(
        uint256 nonce,
        address receiver,
        address depositAsset,
        uint256 depositAmount,
        uint256 shareAmount,
        uint256 depositTimestamp,
        uint256 shareLockUpPeriodAtTimeOfDeposit
    )
        external
        requiresAuth
    {
        if ((block.timestamp - depositTimestamp) > shareLockUpPeriodAtTimeOfDeposit) {
            // Shares are already unlocked, so we can not revert deposit.
            revert TellerWithMultiAssetSupport__SharesAreUnLocked();
        }
        bytes32 depositHash = keccak256(
            abi.encode(
                receiver, depositAsset, depositAmount, shareAmount, depositTimestamp, shareLockUpPeriodAtTimeOfDeposit
            )
        );
        if (publicDepositHistory[nonce] != depositHash) revert TellerWithMultiAssetSupport__BadDepositHash();

        // Delete hash to prevent refund gas.
        delete publicDepositHistory[nonce];

        // Burn shares and refund assets to receiver.
        vault.exit(receiver, ERC20(depositAsset), depositAmount, receiver, shareAmount);

        emit DepositRefunded(nonce, depositHash, receiver);
    }

    // ========================================= USER FUNCTIONS =========================================

    /**
     * @notice Allows users to deposit into the BoringVault, if this contract is not paused.
     * @dev Publicly callable.
     */
    function deposit(
        ERC20 depositAsset,
        uint256 depositAmount,
        uint256 minimumMint
    )
        external
        requiresAuth
        nonReentrant
        returns (uint256 shares)
    {
        if (isPaused) revert TellerWithMultiAssetSupport__Paused();
        if (!isSupported[depositAsset]) revert TellerWithMultiAssetSupport__AssetNotSupported();

        shares = _erc20Deposit(depositAsset, depositAmount, minimumMint, msg.sender);

        _afterPublicDeposit(msg.sender, depositAsset, depositAmount, shares, shareLockPeriod);
    }

    /**
     * @notice Allows users to deposit into BoringVault using permit.
     * @dev Publicly callable.
     */
    function depositWithPermit(
        ERC20 depositAsset,
        uint256 depositAmount,
        uint256 minimumMint,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        requiresAuth
        nonReentrant
        returns (uint256 shares)
    {
        if (isPaused) revert TellerWithMultiAssetSupport__Paused();
        if (!isSupported[depositAsset]) revert TellerWithMultiAssetSupport__AssetNotSupported();

        // solhint-disable-next-line no-empty-blocks
        try depositAsset.permit(msg.sender, address(vault), depositAmount, deadline, v, r, s) { }
        catch {
            if (depositAsset.allowance(msg.sender, address(vault)) < depositAmount) {
                revert TellerWithMultiAssetSupport__PermitFailedAndAllowanceTooLow();
            }
        }
        shares = _erc20Deposit(depositAsset, depositAmount, minimumMint, msg.sender);

        _afterPublicDeposit(msg.sender, depositAsset, depositAmount, shares, shareLockPeriod);
    }

    /**
     * @notice Allows on ramp role to deposit into this contract.
     * @dev Does NOT support native deposits.
     * @dev Callable by SOLVER_ROLE.
     */
    function bulkDeposit(
        ERC20 depositAsset,
        uint256 depositAmount,
        uint256 minimumMint,
        address to
    )
        external
        requiresAuth
        nonReentrant
        returns (uint256 shares)
    {
        if (!isSupported[depositAsset]) revert TellerWithMultiAssetSupport__AssetNotSupported();

        shares = _erc20Deposit(depositAsset, depositAmount, minimumMint, to);
        emit BulkDeposit(address(depositAsset), depositAmount);
    }

    /**
     * @notice Allows off ramp role to withdraw from this contract.
     * @dev Callable by SOLVER_ROLE.
     */
    function bulkWithdraw(
        ERC20 withdrawAsset,
        uint256 shareAmount,
        uint256 minimumAssets,
        address to
    )
        external
        requiresAuth
        returns (uint256 assetsOut)
    {
        if (!isSupported[withdrawAsset]) revert TellerWithMultiAssetSupport__AssetNotSupported();

        if (shareAmount == 0) revert TellerWithMultiAssetSupport__ZeroShares();
        assetsOut = shareAmount.mulDivDown(accountant.getRateInQuoteSafe(withdrawAsset), ONE_SHARE);
        if (assetsOut < minimumAssets) revert TellerWithMultiAssetSupport__MinimumAssetsNotMet();
        vault.exit(to, withdrawAsset, assetsOut, msg.sender, shareAmount);
        emit BulkWithdraw(address(withdrawAsset), shareAmount);
    }

    // ========================================= INTERNAL HELPER FUNCTIONS =========================================

    /**
     * @notice Implements a common ERC20 deposit into BoringVault.
     */
    function _erc20Deposit(
        ERC20 depositAsset,
        uint256 depositAmount,
        uint256 minimumMint,
        address to
    )
        internal
        returns (uint256 shares)
    {
        if (depositAmount == 0) revert TellerWithMultiAssetSupport__ZeroAssets();
        shares = depositAmount.mulDivDown(ONE_SHARE, accountant.getRateInQuoteSafe(depositAsset));
        if (shares < minimumMint) revert TellerWithMultiAssetSupport__MinimumMintNotMet();
        vault.enter(msg.sender, depositAsset, depositAmount, to, shares);
    }

    /**
     * @notice Handle share lock logic, and event.
     */
    function _afterPublicDeposit(
        address user,
        ERC20 depositAsset,
        uint256 depositAmount,
        uint256 shares,
        uint256 currentShareLockPeriod
    )
        internal
    {
        shareUnlockTime[user] = block.timestamp + currentShareLockPeriod;

        uint256 nonce = depositNonce;
        publicDepositHistory[nonce] =
            keccak256(abi.encode(user, depositAsset, depositAmount, shares, block.timestamp, currentShareLockPeriod));
        depositNonce++;
        emit Deposit(nonce, user, address(depositAsset), depositAmount, shares, block.timestamp, currentShareLockPeriod);
    }
}
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.0;

/*@@@@@@@       @@@@@@@@@
 @@@@@@@@@       @@@@@@@@@
  @@@@@@@@@       @@@@@@@@@
   @@@@@@@@@       @@@@@@@@@
    @@@@@@@@@@@@@@@@@@@@@@@@@
     @@@@@  HYPERLANE  @@@@@@@
    @@@@@@@@@@@@@@@@@@@@@@@@@
   @@@@@@@@@       @@@@@@@@@
  @@@@@@@@@       @@@@@@@@@
 @@@@@@@@@       @@@@@@@@@
@@@@@@@@@       @@@@@@@@*/

/**
 * Format of metadata:
 *
 * [0:2] variant
 * [2:34] msg.value
 * [34:66] Gas limit for message (IGP)
 * [66:86] Refund address for message (IGP)
 * [86:] Custom metadata
 */
library StandardHookMetadata {
    struct Metadata {
        uint16 variant;
        uint256 msgValue;
        uint256 gasLimit;
        address refundAddress;
    }

    uint8 private constant VARIANT_OFFSET = 0;
    uint8 private constant MSG_VALUE_OFFSET = 2;
    uint8 private constant GAS_LIMIT_OFFSET = 34;
    uint8 private constant REFUND_ADDRESS_OFFSET = 66;
    uint256 private constant MIN_METADATA_LENGTH = 86;

    uint16 public constant VARIANT = 1;

    /**
     * @notice Returns the variant of the metadata.
     * @param _metadata ABI encoded standard hook metadata.
     * @return variant of the metadata as uint8.
     */
    function variant(bytes calldata _metadata) internal pure returns (uint16) {
        if (_metadata.length < VARIANT_OFFSET + 2) return 0;
        return uint16(bytes2(_metadata[VARIANT_OFFSET:VARIANT_OFFSET + 2]));
    }

    /**
     * @notice Returns the specified value for the message.
     * @param _metadata ABI encoded standard hook metadata.
     * @param _default Default fallback value.
     * @return Value for the message as uint256.
     */
    function msgValue(bytes calldata _metadata, uint256 _default) internal pure returns (uint256) {
        if (_metadata.length < MSG_VALUE_OFFSET + 32) return _default;
        return uint256(bytes32(_metadata[MSG_VALUE_OFFSET:MSG_VALUE_OFFSET + 32]));
    }

    /**
     * @notice Returns the specified gas limit for the message.
     * @param _metadata ABI encoded standard hook metadata.
     * @param _default Default fallback gas limit.
     * @return Gas limit for the message as uint256.
     */
    function gasLimit(bytes calldata _metadata, uint256 _default) internal pure returns (uint256) {
        if (_metadata.length < GAS_LIMIT_OFFSET + 32) return _default;
        return uint256(bytes32(_metadata[GAS_LIMIT_OFFSET:GAS_LIMIT_OFFSET + 32]));
    }

    /**
     * @notice Returns the specified refund address for the message.
     * @param _metadata ABI encoded standard hook metadata.
     * @param _default Default fallback refund address.
     * @return Refund address for the message as address.
     */
    function refundAddress(bytes calldata _metadata, address _default) internal pure returns (address) {
        if (_metadata.length < REFUND_ADDRESS_OFFSET + 20) return _default;
        return address(bytes20(_metadata[REFUND_ADDRESS_OFFSET:REFUND_ADDRESS_OFFSET + 20]));
    }

    /**
     * @notice Returns any custom metadata.
     * @param _metadata ABI encoded standard hook metadata.
     * @return Custom metadata.
     */
    function getCustomMetadata(bytes calldata _metadata) internal pure returns (bytes calldata) {
        if (_metadata.length < MIN_METADATA_LENGTH) return _metadata[0:0];
        return _metadata[MIN_METADATA_LENGTH:];
    }

    /**
     * @notice Formats the specified gas limit and refund address into standard hook metadata.
     * @param _msgValue msg.value for the message.
     * @param _gasLimit Gas limit for the message.
     * @param _refundAddress Refund address for the message.
     * @param _customMetadata Additional metadata to include in the standard hook metadata.
     * @return ABI encoded standard hook metadata.
     */
    function formatMetadata(
        uint256 _msgValue,
        uint256 _gasLimit,
        address _refundAddress,
        bytes memory _customMetadata
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(VARIANT, _msgValue, _gasLimit, _refundAddress, _customMetadata);
    }

    /**
     * @notice Formats the specified gas limit and refund address into standard hook metadata.
     * @param _msgValue msg.value for the message.
     * @return ABI encoded standard hook metadata.
     */
    function overrideMsgValue(uint256 _msgValue) internal view returns (bytes memory) {
        return formatMetadata(_msgValue, uint256(0), msg.sender, "");
    }

    /**
     * @notice Formats the specified gas limit and refund address into standard hook metadata.
     * @param _gasLimit Gas limit for the message.
     * @return ABI encoded standard hook metadata.
     */
    function overrideGasLimit(uint256 _gasLimit) internal view returns (bytes memory) {
        return formatMetadata(uint256(0), _gasLimit, msg.sender, "");
    }

    /**
     * @notice Formats the specified refund address into standard hook metadata.
     * @param _refundAddress Refund address for the message.
     * @return ABI encoded standard hook metadata.
     */
    function overrideRefundAddress(address _refundAddress) internal pure returns (bytes memory) {
        return formatMetadata(uint256(0), uint256(0), _refundAddress, "");
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

interface BeforeTransferHook {
    function beforeTransfer(address from) external view;
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
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.0;

interface IInterchainSecurityModule {
    enum Types {
        UNUSED,
        ROUTING,
        AGGREGATION,
        LEGACY_MULTISIG,
        MERKLE_ROOT_MULTISIG,
        MESSAGE_ID_MULTISIG,
        NULL, // used with relayer carrying no metadata
        CCIP_READ,
        ARB_L2_TO_L1,
        WEIGHTED_MERKLE_ROOT_MULTISIG,
        WEIGHTED_MESSAGE_ID_MULTISIG,
        OP_L2_TO_L1
    }

    /**
     * @notice Returns an enum that represents the type of security model
     * encoded by this ISM.
     * @dev Relayers infer how to fetch and format metadata.
     */
    function moduleType() external view returns (uint8);

    /**
     * @notice Defines a security model responsible for verifying interchain
     * messages based on the provided metadata.
     * @param _metadata Off-chain metadata provided by a relayer, specific to
     * the security model encoded by the module (e.g. validator signatures)
     * @param _message Hyperlane encoded interchain message
     * @return True if the message was verified
     */
    function verify(bytes calldata _metadata, bytes calldata _message) external returns (bool);
}

interface ISpecifiesInterchainSecurityModule {
    function interchainSecurityModule() external view returns (IInterchainSecurityModule);
}
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.0;

import { IInterchainSecurityModule } from "./IInterchainSecurityModule.sol";
import { IPostDispatchHook } from "./IPostDispatchHook.sol";

interface IMailbox {
    // ============ Events ============
    /**
     * @notice Emitted when a new message is dispatched via Hyperlane
     * @param sender The address that dispatched the message
     * @param destination The destination domain of the message
     * @param recipient The message recipient address on `destination`
     * @param message Raw bytes of message
     */
    event Dispatch(address indexed sender, uint32 indexed destination, bytes32 indexed recipient, bytes message);

    /**
     * @notice Emitted when a new message is dispatched via Hyperlane
     * @param messageId The unique message identifier
     */
    event DispatchId(bytes32 indexed messageId);

    /**
     * @notice Emitted when a Hyperlane message is processed
     * @param messageId The unique message identifier
     */
    event ProcessId(bytes32 indexed messageId);

    /**
     * @notice Emitted when a Hyperlane message is delivered
     * @param origin The origin domain of the message
     * @param sender The message sender address on `origin`
     * @param recipient The address that handled the message
     */
    event Process(uint32 indexed origin, bytes32 indexed sender, address indexed recipient);

    function localDomain() external view returns (uint32);

    function delivered(bytes32 messageId) external view returns (bool);

    function defaultIsm() external view returns (IInterchainSecurityModule);

    function defaultHook() external view returns (IPostDispatchHook);

    function requiredHook() external view returns (IPostDispatchHook);

    function latestDispatchedId() external view returns (bytes32);

    function dispatch(
        uint32 destinationDomain,
        bytes32 recipientAddress,
        bytes calldata messageBody
    )
        external
        payable
        returns (bytes32 messageId);

    function quoteDispatch(
        uint32 destinationDomain,
        bytes32 recipientAddress,
        bytes calldata messageBody
    )
        external
        view
        returns (uint256 fee);

    function dispatch(
        uint32 destinationDomain,
        bytes32 recipientAddress,
        bytes calldata body,
        bytes calldata defaultHookMetadata
    )
        external
        payable
        returns (bytes32 messageId);

    function quoteDispatch(
        uint32 destinationDomain,
        bytes32 recipientAddress,
        bytes calldata messageBody,
        bytes calldata defaultHookMetadata
    )
        external
        view
        returns (uint256 fee);

    function dispatch(
        uint32 destinationDomain,
        bytes32 recipientAddress,
        bytes calldata body,
        bytes calldata customHookMetadata,
        IPostDispatchHook customHook
    )
        external
        payable
        returns (bytes32 messageId);

    function quoteDispatch(
        uint32 destinationDomain,
        bytes32 recipientAddress,
        bytes calldata messageBody,
        bytes calldata customHookMetadata,
        IPostDispatchHook customHook
    )
        external
        view
        returns (uint256 fee);

    function process(bytes calldata metadata, bytes calldata message) external payable;

    function recipientIsm(address recipient) external view returns (IInterchainSecurityModule module);
}
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.0;

/*@@@@@@@       @@@@@@@@@
 @@@@@@@@@       @@@@@@@@@
  @@@@@@@@@       @@@@@@@@@
   @@@@@@@@@       @@@@@@@@@
    @@@@@@@@@@@@@@@@@@@@@@@@@
     @@@@@  HYPERLANE  @@@@@@@
    @@@@@@@@@@@@@@@@@@@@@@@@@
   @@@@@@@@@       @@@@@@@@@
  @@@@@@@@@       @@@@@@@@@
 @@@@@@@@@       @@@@@@@@@
@@@@@@@@@       @@@@@@@@*/

interface IPostDispatchHook {
    enum Types {
        UNUSED,
        ROUTING,
        AGGREGATION,
        MERKLE_TREE,
        INTERCHAIN_GAS_PAYMASTER,
        FALLBACK_ROUTING,
        ID_AUTH_ISM,
        PAUSABLE,
        PROTOCOL_FEE,
        LAYER_ZERO_V1,
        RATE_LIMITED,
        ARB_L2_TO_L1,
        OP_L2_TO_L1
    }

    /**
     * @notice Returns an enum that represents the type of hook
     */
    function hookType() external view returns (uint8);

    /**
     * @notice Returns whether the hook supports metadata
     * @param metadata metadata
     * @return Whether the hook supports metadata
     */
    function supportsMetadata(bytes calldata metadata) external view returns (bool);

    /**
     * @notice Post action after a message is dispatched via the Mailbox
     * @param metadata The metadata required for the hook
     * @param message The message passed from the Mailbox.dispatch() call
     */
    function postDispatch(bytes calldata metadata, bytes calldata message) external payable;

    /**
     * @notice Compute the payment required by the postDispatch call
     * @param metadata The metadata required for the hook
     * @param message The message passed from the Mailbox.dispatch() call
     * @return Quoted payment for the postDispatch call
     */
    function quoteDispatch(bytes calldata metadata, bytes calldata message) external view returns (uint256);
}