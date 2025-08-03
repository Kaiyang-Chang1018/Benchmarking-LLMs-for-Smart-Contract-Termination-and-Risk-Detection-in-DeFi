// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IAuthorizationUtilsV0.sol";
import "./ITemplateUtilsV0.sol";
import "./IWithdrawalUtilsV0.sol";

interface IAirnodeRrpV0 is
    IAuthorizationUtilsV0,
    ITemplateUtilsV0,
    IWithdrawalUtilsV0
{
    event SetSponsorshipStatus(
        address indexed sponsor,
        address indexed requester,
        bool sponsorshipStatus
    );

    event MadeTemplateRequest(
        address indexed airnode,
        bytes32 indexed requestId,
        uint256 requesterRequestCount,
        uint256 chainId,
        address requester,
        bytes32 templateId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes parameters
    );

    event MadeFullRequest(
        address indexed airnode,
        bytes32 indexed requestId,
        uint256 requesterRequestCount,
        uint256 chainId,
        address requester,
        bytes32 endpointId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes parameters
    );

    event FulfilledRequest(
        address indexed airnode,
        bytes32 indexed requestId,
        bytes data
    );

    event FailedRequest(
        address indexed airnode,
        bytes32 indexed requestId,
        string errorMessage
    );

    function setSponsorshipStatus(address requester, bool sponsorshipStatus)
        external;

    function makeTemplateRequest(
        bytes32 templateId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata parameters
    ) external returns (bytes32 requestId);

    function makeFullRequest(
        address airnode,
        bytes32 endpointId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata parameters
    ) external returns (bytes32 requestId);

    function fulfill(
        bytes32 requestId,
        address airnode,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata data,
        bytes calldata signature
    ) external returns (bool callSuccess, bytes memory callData);

    function fail(
        bytes32 requestId,
        address airnode,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        string calldata errorMessage
    ) external;

    function sponsorToRequesterToSponsorshipStatus(
        address sponsor,
        address requester
    ) external view returns (bool sponsorshipStatus);

    function requesterToRequestCountPlusOne(address requester)
        external
        view
        returns (uint256 requestCountPlusOne);

    function requestIsAwaitingFulfillment(bytes32 requestId)
        external
        view
        returns (bool isAwaitingFulfillment);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAuthorizationUtilsV0 {
    function checkAuthorizationStatus(
        address[] calldata authorizers,
        address airnode,
        bytes32 requestId,
        bytes32 endpointId,
        address sponsor,
        address requester
    ) external view returns (bool status);

    function checkAuthorizationStatuses(
        address[] calldata authorizers,
        address airnode,
        bytes32[] calldata requestIds,
        bytes32[] calldata endpointIds,
        address[] calldata sponsors,
        address[] calldata requesters
    ) external view returns (bool[] memory statuses);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITemplateUtilsV0 {
    event CreatedTemplate(
        bytes32 indexed templateId,
        address airnode,
        bytes32 endpointId,
        bytes parameters
    );

    function createTemplate(
        address airnode,
        bytes32 endpointId,
        bytes calldata parameters
    ) external returns (bytes32 templateId);

    function getTemplates(bytes32[] calldata templateIds)
        external
        view
        returns (
            address[] memory airnodes,
            bytes32[] memory endpointIds,
            bytes[] memory parameters
        );

    function templates(bytes32 templateId)
        external
        view
        returns (
            address airnode,
            bytes32 endpointId,
            bytes memory parameters
        );
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWithdrawalUtilsV0 {
    event RequestedWithdrawal(
        address indexed airnode,
        address indexed sponsor,
        bytes32 indexed withdrawalRequestId,
        address sponsorWallet
    );

    event FulfilledWithdrawal(
        address indexed airnode,
        address indexed sponsor,
        bytes32 indexed withdrawalRequestId,
        address sponsorWallet,
        uint256 amount
    );

    function requestWithdrawal(address airnode, address sponsorWallet) external;

    function fulfillWithdrawal(
        bytes32 withdrawalRequestId,
        address airnode,
        address sponsor
    ) external payable;

    function sponsorToWithdrawalRequestCount(address sponsor)
        external
        view
        returns (uint256 withdrawalRequestCount);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IAirnodeRrpV0.sol";

/// @title The contract to be inherited to make Airnode RRP requests
contract RrpRequesterV0 {
    IAirnodeRrpV0 public immutable airnodeRrp;

    /// @dev Reverts if the caller is not the Airnode RRP contract.
    /// Use it as a modifier for fulfill and error callback methods, but also
    /// check `requestId`.
    modifier onlyAirnodeRrp() {
        require(msg.sender == address(airnodeRrp), "Caller not Airnode RRP");
        _;
    }

    /// @dev Airnode RRP address is set at deployment and is immutable.
    /// RrpRequester is made its own sponsor by default. RrpRequester can also
    /// be sponsored by others and use these sponsorships while making
    /// requests, i.e., using this default sponsorship is optional.
    /// @param _airnodeRrp Airnode RRP contract address
    constructor(address _airnodeRrp) {
        airnodeRrp = IAirnodeRrpV0(_airnodeRrp);
        IAirnodeRrpV0(_airnodeRrp).setSponsorshipStatus(address(this), true);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
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

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";
import {IERC20Permit} from "../extensions/IERC20Permit.sol";
import {Address} from "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    /**
     * @dev An operation with an ERC20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or
     *   {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.20;

import {IERC721} from "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
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
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/Math.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Muldiv operation overflow.
     */
    error MathOverflowedMulDiv();

    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            return a / b;
        }

        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0 = x * y; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
            }

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator.
            // Always >= 1. See https://cs.stackexchange.com/q/138556/92363.

            uint256 twos = denominator & (0 - denominator);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (unsignedRoundsUp(rounding) && 1 << (result << 3) < value ? 1 : 0);
        }
    }

    /**
     * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
     */
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/structs/Checkpoints.sol)
// This file was procedurally generated from scripts/generate/templates/Checkpoints.js.

pragma solidity ^0.8.20;

import {Math} from "../math/Math.sol";

/**
 * @dev This library defines the `Trace*` struct, for checkpointing values as they change at different points in
 * time, and later looking up past values by block number. See {Votes} as an example.
 *
 * To create a history of checkpoints define a variable type `Checkpoints.Trace*` in your contract, and store a new
 * checkpoint for the current transaction block using the {push} function.
 */
library Checkpoints {
    /**
     * @dev A value was attempted to be inserted on a past checkpoint.
     */
    error CheckpointUnorderedInsertion();

    struct Trace224 {
        Checkpoint224[] _checkpoints;
    }

    struct Checkpoint224 {
        uint32 _key;
        uint224 _value;
    }

    /**
     * @dev Pushes a (`key`, `value`) pair into a Trace224 so that it is stored as the checkpoint.
     *
     * Returns previous value and new value.
     *
     * IMPORTANT: Never accept `key` as a user input, since an arbitrary `type(uint32).max` key set will disable the
     * library.
     */
    function push(Trace224 storage self, uint32 key, uint224 value) internal returns (uint224, uint224) {
        return _insert(self._checkpoints, key, value);
    }

    /**
     * @dev Returns the value in the first (oldest) checkpoint with key greater or equal than the search key, or zero if
     * there is none.
     */
    function lowerLookup(Trace224 storage self, uint32 key) internal view returns (uint224) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _lowerBinaryLookup(self._checkpoints, key, 0, len);
        return pos == len ? 0 : _unsafeAccess(self._checkpoints, pos)._value;
    }

    /**
     * @dev Returns the value in the last (most recent) checkpoint with key lower or equal than the search key, or zero
     * if there is none.
     */
    function upperLookup(Trace224 storage self, uint32 key) internal view returns (uint224) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _upperBinaryLookup(self._checkpoints, key, 0, len);
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns the value in the last (most recent) checkpoint with key lower or equal than the search key, or zero
     * if there is none.
     *
     * NOTE: This is a variant of {upperLookup} that is optimised to find "recent" checkpoint (checkpoints with high
     * keys).
     */
    function upperLookupRecent(Trace224 storage self, uint32 key) internal view returns (uint224) {
        uint256 len = self._checkpoints.length;

        uint256 low = 0;
        uint256 high = len;

        if (len > 5) {
            uint256 mid = len - Math.sqrt(len);
            if (key < _unsafeAccess(self._checkpoints, mid)._key) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        uint256 pos = _upperBinaryLookup(self._checkpoints, key, low, high);

        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns the value in the most recent checkpoint, or zero if there are no checkpoints.
     */
    function latest(Trace224 storage self) internal view returns (uint224) {
        uint256 pos = self._checkpoints.length;
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns whether there is a checkpoint in the structure (i.e. it is not empty), and if so the key and value
     * in the most recent checkpoint.
     */
    function latestCheckpoint(Trace224 storage self) internal view returns (bool exists, uint32 _key, uint224 _value) {
        uint256 pos = self._checkpoints.length;
        if (pos == 0) {
            return (false, 0, 0);
        } else {
            Checkpoint224 memory ckpt = _unsafeAccess(self._checkpoints, pos - 1);
            return (true, ckpt._key, ckpt._value);
        }
    }

    /**
     * @dev Returns the number of checkpoint.
     */
    function length(Trace224 storage self) internal view returns (uint256) {
        return self._checkpoints.length;
    }

    /**
     * @dev Returns checkpoint at given position.
     */
    function at(Trace224 storage self, uint32 pos) internal view returns (Checkpoint224 memory) {
        return self._checkpoints[pos];
    }

    /**
     * @dev Pushes a (`key`, `value`) pair into an ordered list of checkpoints, either by inserting a new checkpoint,
     * or by updating the last one.
     */
    function _insert(Checkpoint224[] storage self, uint32 key, uint224 value) private returns (uint224, uint224) {
        uint256 pos = self.length;

        if (pos > 0) {
            // Copying to memory is important here.
            Checkpoint224 memory last = _unsafeAccess(self, pos - 1);

            // Checkpoint keys must be non-decreasing.
            if (last._key > key) {
                revert CheckpointUnorderedInsertion();
            }

            // Update or push new checkpoint
            if (last._key == key) {
                _unsafeAccess(self, pos - 1)._value = value;
            } else {
                self.push(Checkpoint224({_key: key, _value: value}));
            }
            return (last._value, value);
        } else {
            self.push(Checkpoint224({_key: key, _value: value}));
            return (0, value);
        }
    }

    /**
     * @dev Return the index of the last (most recent) checkpoint with key lower or equal than the search key, or `high`
     * if there is none. `low` and `high` define a section where to do the search, with inclusive `low` and exclusive
     * `high`.
     *
     * WARNING: `high` should not be greater than the array's length.
     */
    function _upperBinaryLookup(
        Checkpoint224[] storage self,
        uint32 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (_unsafeAccess(self, mid)._key > key) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }
        return high;
    }

    /**
     * @dev Return the index of the first (oldest) checkpoint with key is greater or equal than the search key, or
     * `high` if there is none. `low` and `high` define a section where to do the search, with inclusive `low` and
     * exclusive `high`.
     *
     * WARNING: `high` should not be greater than the array's length.
     */
    function _lowerBinaryLookup(
        Checkpoint224[] storage self,
        uint32 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (_unsafeAccess(self, mid)._key < key) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
        return high;
    }

    /**
     * @dev Access an element of the array without performing bounds check. The position is assumed to be within bounds.
     */
    function _unsafeAccess(
        Checkpoint224[] storage self,
        uint256 pos
    ) private pure returns (Checkpoint224 storage result) {
        assembly {
            mstore(0, self.slot)
            result.slot := add(keccak256(0, 0x20), pos)
        }
    }

    struct Trace208 {
        Checkpoint208[] _checkpoints;
    }

    struct Checkpoint208 {
        uint48 _key;
        uint208 _value;
    }

    /**
     * @dev Pushes a (`key`, `value`) pair into a Trace208 so that it is stored as the checkpoint.
     *
     * Returns previous value and new value.
     *
     * IMPORTANT: Never accept `key` as a user input, since an arbitrary `type(uint48).max` key set will disable the
     * library.
     */
    function push(Trace208 storage self, uint48 key, uint208 value) internal returns (uint208, uint208) {
        return _insert(self._checkpoints, key, value);
    }

    /**
     * @dev Returns the value in the first (oldest) checkpoint with key greater or equal than the search key, or zero if
     * there is none.
     */
    function lowerLookup(Trace208 storage self, uint48 key) internal view returns (uint208) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _lowerBinaryLookup(self._checkpoints, key, 0, len);
        return pos == len ? 0 : _unsafeAccess(self._checkpoints, pos)._value;
    }

    /**
     * @dev Returns the value in the last (most recent) checkpoint with key lower or equal than the search key, or zero
     * if there is none.
     */
    function upperLookup(Trace208 storage self, uint48 key) internal view returns (uint208) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _upperBinaryLookup(self._checkpoints, key, 0, len);
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns the value in the last (most recent) checkpoint with key lower or equal than the search key, or zero
     * if there is none.
     *
     * NOTE: This is a variant of {upperLookup} that is optimised to find "recent" checkpoint (checkpoints with high
     * keys).
     */
    function upperLookupRecent(Trace208 storage self, uint48 key) internal view returns (uint208) {
        uint256 len = self._checkpoints.length;

        uint256 low = 0;
        uint256 high = len;

        if (len > 5) {
            uint256 mid = len - Math.sqrt(len);
            if (key < _unsafeAccess(self._checkpoints, mid)._key) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        uint256 pos = _upperBinaryLookup(self._checkpoints, key, low, high);

        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns the value in the most recent checkpoint, or zero if there are no checkpoints.
     */
    function latest(Trace208 storage self) internal view returns (uint208) {
        uint256 pos = self._checkpoints.length;
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns whether there is a checkpoint in the structure (i.e. it is not empty), and if so the key and value
     * in the most recent checkpoint.
     */
    function latestCheckpoint(Trace208 storage self) internal view returns (bool exists, uint48 _key, uint208 _value) {
        uint256 pos = self._checkpoints.length;
        if (pos == 0) {
            return (false, 0, 0);
        } else {
            Checkpoint208 memory ckpt = _unsafeAccess(self._checkpoints, pos - 1);
            return (true, ckpt._key, ckpt._value);
        }
    }

    /**
     * @dev Returns the number of checkpoint.
     */
    function length(Trace208 storage self) internal view returns (uint256) {
        return self._checkpoints.length;
    }

    /**
     * @dev Returns checkpoint at given position.
     */
    function at(Trace208 storage self, uint32 pos) internal view returns (Checkpoint208 memory) {
        return self._checkpoints[pos];
    }

    /**
     * @dev Pushes a (`key`, `value`) pair into an ordered list of checkpoints, either by inserting a new checkpoint,
     * or by updating the last one.
     */
    function _insert(Checkpoint208[] storage self, uint48 key, uint208 value) private returns (uint208, uint208) {
        uint256 pos = self.length;

        if (pos > 0) {
            // Copying to memory is important here.
            Checkpoint208 memory last = _unsafeAccess(self, pos - 1);

            // Checkpoint keys must be non-decreasing.
            if (last._key > key) {
                revert CheckpointUnorderedInsertion();
            }

            // Update or push new checkpoint
            if (last._key == key) {
                _unsafeAccess(self, pos - 1)._value = value;
            } else {
                self.push(Checkpoint208({_key: key, _value: value}));
            }
            return (last._value, value);
        } else {
            self.push(Checkpoint208({_key: key, _value: value}));
            return (0, value);
        }
    }

    /**
     * @dev Return the index of the last (most recent) checkpoint with key lower or equal than the search key, or `high`
     * if there is none. `low` and `high` define a section where to do the search, with inclusive `low` and exclusive
     * `high`.
     *
     * WARNING: `high` should not be greater than the array's length.
     */
    function _upperBinaryLookup(
        Checkpoint208[] storage self,
        uint48 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (_unsafeAccess(self, mid)._key > key) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }
        return high;
    }

    /**
     * @dev Return the index of the first (oldest) checkpoint with key is greater or equal than the search key, or
     * `high` if there is none. `low` and `high` define a section where to do the search, with inclusive `low` and
     * exclusive `high`.
     *
     * WARNING: `high` should not be greater than the array's length.
     */
    function _lowerBinaryLookup(
        Checkpoint208[] storage self,
        uint48 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (_unsafeAccess(self, mid)._key < key) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
        return high;
    }

    /**
     * @dev Access an element of the array without performing bounds check. The position is assumed to be within bounds.
     */
    function _unsafeAccess(
        Checkpoint208[] storage self,
        uint256 pos
    ) private pure returns (Checkpoint208 storage result) {
        assembly {
            mstore(0, self.slot)
            result.slot := add(keccak256(0, 0x20), pos)
        }
    }

    struct Trace160 {
        Checkpoint160[] _checkpoints;
    }

    struct Checkpoint160 {
        uint96 _key;
        uint160 _value;
    }

    /**
     * @dev Pushes a (`key`, `value`) pair into a Trace160 so that it is stored as the checkpoint.
     *
     * Returns previous value and new value.
     *
     * IMPORTANT: Never accept `key` as a user input, since an arbitrary `type(uint96).max` key set will disable the
     * library.
     */
    function push(Trace160 storage self, uint96 key, uint160 value) internal returns (uint160, uint160) {
        return _insert(self._checkpoints, key, value);
    }

    /**
     * @dev Returns the value in the first (oldest) checkpoint with key greater or equal than the search key, or zero if
     * there is none.
     */
    function lowerLookup(Trace160 storage self, uint96 key) internal view returns (uint160) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _lowerBinaryLookup(self._checkpoints, key, 0, len);
        return pos == len ? 0 : _unsafeAccess(self._checkpoints, pos)._value;
    }

    /**
     * @dev Returns the value in the last (most recent) checkpoint with key lower or equal than the search key, or zero
     * if there is none.
     */
    function upperLookup(Trace160 storage self, uint96 key) internal view returns (uint160) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _upperBinaryLookup(self._checkpoints, key, 0, len);
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns the value in the last (most recent) checkpoint with key lower or equal than the search key, or zero
     * if there is none.
     *
     * NOTE: This is a variant of {upperLookup} that is optimised to find "recent" checkpoint (checkpoints with high
     * keys).
     */
    function upperLookupRecent(Trace160 storage self, uint96 key) internal view returns (uint160) {
        uint256 len = self._checkpoints.length;

        uint256 low = 0;
        uint256 high = len;

        if (len > 5) {
            uint256 mid = len - Math.sqrt(len);
            if (key < _unsafeAccess(self._checkpoints, mid)._key) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        uint256 pos = _upperBinaryLookup(self._checkpoints, key, low, high);

        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns the value in the most recent checkpoint, or zero if there are no checkpoints.
     */
    function latest(Trace160 storage self) internal view returns (uint160) {
        uint256 pos = self._checkpoints.length;
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns whether there is a checkpoint in the structure (i.e. it is not empty), and if so the key and value
     * in the most recent checkpoint.
     */
    function latestCheckpoint(Trace160 storage self) internal view returns (bool exists, uint96 _key, uint160 _value) {
        uint256 pos = self._checkpoints.length;
        if (pos == 0) {
            return (false, 0, 0);
        } else {
            Checkpoint160 memory ckpt = _unsafeAccess(self._checkpoints, pos - 1);
            return (true, ckpt._key, ckpt._value);
        }
    }

    /**
     * @dev Returns the number of checkpoint.
     */
    function length(Trace160 storage self) internal view returns (uint256) {
        return self._checkpoints.length;
    }

    /**
     * @dev Returns checkpoint at given position.
     */
    function at(Trace160 storage self, uint32 pos) internal view returns (Checkpoint160 memory) {
        return self._checkpoints[pos];
    }

    /**
     * @dev Pushes a (`key`, `value`) pair into an ordered list of checkpoints, either by inserting a new checkpoint,
     * or by updating the last one.
     */
    function _insert(Checkpoint160[] storage self, uint96 key, uint160 value) private returns (uint160, uint160) {
        uint256 pos = self.length;

        if (pos > 0) {
            // Copying to memory is important here.
            Checkpoint160 memory last = _unsafeAccess(self, pos - 1);

            // Checkpoint keys must be non-decreasing.
            if (last._key > key) {
                revert CheckpointUnorderedInsertion();
            }

            // Update or push new checkpoint
            if (last._key == key) {
                _unsafeAccess(self, pos - 1)._value = value;
            } else {
                self.push(Checkpoint160({_key: key, _value: value}));
            }
            return (last._value, value);
        } else {
            self.push(Checkpoint160({_key: key, _value: value}));
            return (0, value);
        }
    }

    /**
     * @dev Return the index of the last (most recent) checkpoint with key lower or equal than the search key, or `high`
     * if there is none. `low` and `high` define a section where to do the search, with inclusive `low` and exclusive
     * `high`.
     *
     * WARNING: `high` should not be greater than the array's length.
     */
    function _upperBinaryLookup(
        Checkpoint160[] storage self,
        uint96 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (_unsafeAccess(self, mid)._key > key) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }
        return high;
    }

    /**
     * @dev Return the index of the first (oldest) checkpoint with key is greater or equal than the search key, or
     * `high` if there is none. `low` and `high` define a section where to do the search, with inclusive `low` and
     * exclusive `high`.
     *
     * WARNING: `high` should not be greater than the array's length.
     */
    function _lowerBinaryLookup(
        Checkpoint160[] storage self,
        uint96 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (_unsafeAccess(self, mid)._key < key) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
        return high;
    }

    /**
     * @dev Access an element of the array without performing bounds check. The position is assumed to be within bounds.
     */
    function _unsafeAccess(
        Checkpoint160[] storage self,
        uint256 pos
    ) private pure returns (Checkpoint160 storage result) {
        assembly {
            mstore(0, self.slot)
            result.slot := add(keccak256(0, 0x20), pos)
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/structs/EnumerableMap.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableMap.js.

pragma solidity ^0.8.20;

import {EnumerableSet} from "./EnumerableSet.sol";

/**
 * @dev Library for managing an enumerable variant of Solidity's
 * https://solidity.readthedocs.io/en/latest/types.html#mapping-types[`mapping`]
 * type.
 *
 * Maps have the following properties:
 *
 * - Entries are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Entries are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableMap for EnumerableMap.UintToAddressMap;
 *
 *     // Declare a set state variable
 *     EnumerableMap.UintToAddressMap private myMap;
 * }
 * ```
 *
 * The following map types are supported:
 *
 * - `uint256 -> address` (`UintToAddressMap`) since v3.0.0
 * - `address -> uint256` (`AddressToUintMap`) since v4.6.0
 * - `bytes32 -> bytes32` (`Bytes32ToBytes32Map`) since v4.6.0
 * - `uint256 -> uint256` (`UintToUintMap`) since v4.7.0
 * - `bytes32 -> uint256` (`Bytes32ToUintMap`) since v4.7.0
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableMap, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableMap.
 * ====
 */
library EnumerableMap {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    // To implement this library for multiple types with as little code repetition as possible, we write it in
    // terms of a generic Map type with bytes32 keys and values. The Map implementation uses private functions,
    // and user-facing implementations such as `UintToAddressMap` are just wrappers around the underlying Map.
    // This means that we can only create new EnumerableMaps for types that fit in bytes32.

    /**
     * @dev Query for a nonexistent map key.
     */
    error EnumerableMapNonexistentKey(bytes32 key);

    struct Bytes32ToBytes32Map {
        // Storage of keys
        EnumerableSet.Bytes32Set _keys;
        mapping(bytes32 key => bytes32) _values;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(Bytes32ToBytes32Map storage map, bytes32 key, bytes32 value) internal returns (bool) {
        map._values[key] = value;
        return map._keys.add(key);
    }

    /**
     * @dev Removes a key-value pair from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(Bytes32ToBytes32Map storage map, bytes32 key) internal returns (bool) {
        delete map._values[key];
        return map._keys.remove(key);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bool) {
        return map._keys.contains(key);
    }

    /**
     * @dev Returns the number of key-value pairs in the map. O(1).
     */
    function length(Bytes32ToBytes32Map storage map) internal view returns (uint256) {
        return map._keys.length();
    }

    /**
     * @dev Returns the key-value pair stored at position `index` in the map. O(1).
     *
     * Note that there are no guarantees on the ordering of entries inside the
     * array, and it may change when more entries are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32ToBytes32Map storage map, uint256 index) internal view returns (bytes32, bytes32) {
        bytes32 key = map._keys.at(index);
        return (key, map._values[key]);
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bool, bytes32) {
        bytes32 value = map._values[key];
        if (value == bytes32(0)) {
            return (contains(map, key), bytes32(0));
        } else {
            return (true, value);
        }
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bytes32) {
        bytes32 value = map._values[key];
        if (value == 0 && !contains(map, key)) {
            revert EnumerableMapNonexistentKey(key);
        }
        return value;
    }

    /**
     * @dev Return the an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(Bytes32ToBytes32Map storage map) internal view returns (bytes32[] memory) {
        return map._keys.values();
    }

    // UintToUintMap

    struct UintToUintMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(UintToUintMap storage map, uint256 key, uint256 value) internal returns (bool) {
        return set(map._inner, bytes32(key), bytes32(value));
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToUintMap storage map, uint256 key) internal returns (bool) {
        return remove(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToUintMap storage map, uint256 key) internal view returns (bool) {
        return contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToUintMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintToUintMap storage map, uint256 index) internal view returns (uint256, uint256) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (uint256(key), uint256(value));
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(UintToUintMap storage map, uint256 key) internal view returns (bool, uint256) {
        (bool success, bytes32 value) = tryGet(map._inner, bytes32(key));
        return (success, uint256(value));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToUintMap storage map, uint256 key) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(key)));
    }

    /**
     * @dev Return the an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(UintToUintMap storage map) internal view returns (uint256[] memory) {
        bytes32[] memory store = keys(map._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintToAddressMap

    struct UintToAddressMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {
        return set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {
        return remove(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {
        return contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToAddressMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (uint256(key), address(uint160(uint256(value))));
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool, address) {
        (bool success, bytes32 value) = tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint160(uint256(get(map._inner, bytes32(key)))));
    }

    /**
     * @dev Return the an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(UintToAddressMap storage map) internal view returns (uint256[] memory) {
        bytes32[] memory store = keys(map._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressToUintMap

    struct AddressToUintMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(AddressToUintMap storage map, address key, uint256 value) internal returns (bool) {
        return set(map._inner, bytes32(uint256(uint160(key))), bytes32(value));
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(AddressToUintMap storage map, address key) internal returns (bool) {
        return remove(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(AddressToUintMap storage map, address key) internal view returns (bool) {
        return contains(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(AddressToUintMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressToUintMap storage map, uint256 index) internal view returns (address, uint256) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (address(uint160(uint256(key))), uint256(value));
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(AddressToUintMap storage map, address key) internal view returns (bool, uint256) {
        (bool success, bytes32 value) = tryGet(map._inner, bytes32(uint256(uint160(key))));
        return (success, uint256(value));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(AddressToUintMap storage map, address key) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(uint256(uint160(key)))));
    }

    /**
     * @dev Return the an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(AddressToUintMap storage map) internal view returns (address[] memory) {
        bytes32[] memory store = keys(map._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // Bytes32ToUintMap

    struct Bytes32ToUintMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(Bytes32ToUintMap storage map, bytes32 key, uint256 value) internal returns (bool) {
        return set(map._inner, key, bytes32(value));
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(Bytes32ToUintMap storage map, bytes32 key) internal returns (bool) {
        return remove(map._inner, key);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(Bytes32ToUintMap storage map, bytes32 key) internal view returns (bool) {
        return contains(map._inner, key);
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(Bytes32ToUintMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32ToUintMap storage map, uint256 index) internal view returns (bytes32, uint256) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (key, uint256(value));
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(Bytes32ToUintMap storage map, bytes32 key) internal view returns (bool, uint256) {
        (bool success, bytes32 value) = tryGet(map._inner, key);
        return (success, uint256(value));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(Bytes32ToUintMap storage map, bytes32 key) internal view returns (uint256) {
        return uint256(get(map._inner, key));
    }

    /**
     * @dev Return the an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(Bytes32ToUintMap storage map) internal view returns (bytes32[] memory) {
        bytes32[] memory store = keys(map._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.20;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position is the index of the value in the `values` array plus 1.
        // Position 0 is used to mean a value is not in the set.
        mapping(bytes32 value => uint256) _positions;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._positions[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We cache the value's position to prevent multiple reads from the same storage slot
        uint256 position = set._positions[value];

        if (position != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 valueIndex = position - 1;
            uint256 lastIndex = set._values.length - 1;

            if (valueIndex != lastIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the lastValue to the index where the value to delete is
                set._values[valueIndex] = lastValue;
                // Update the tracked position of the lastValue (that was just moved)
                set._positions[lastValue] = position;
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the tracked position for the deleted slot
            delete set._positions[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._positions[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

// Common.sol
//
// Common mathematical functions used in both SD59x18 and UD60x18. Note that these global functions do not
// always operate with SD59x18 and UD60x18 numbers.

/*//////////////////////////////////////////////////////////////////////////
                                CUSTOM ERRORS
//////////////////////////////////////////////////////////////////////////*/

/// @notice Thrown when the resultant value in {mulDiv} overflows uint256.
error PRBMath_MulDiv_Overflow(uint256 x, uint256 y, uint256 denominator);

/// @notice Thrown when the resultant value in {mulDiv18} overflows uint256.
error PRBMath_MulDiv18_Overflow(uint256 x, uint256 y);

/// @notice Thrown when one of the inputs passed to {mulDivSigned} is `type(int256).min`.
error PRBMath_MulDivSigned_InputTooSmall();

/// @notice Thrown when the resultant value in {mulDivSigned} overflows int256.
error PRBMath_MulDivSigned_Overflow(int256 x, int256 y);

/*//////////////////////////////////////////////////////////////////////////
                                    CONSTANTS
//////////////////////////////////////////////////////////////////////////*/

/// @dev The maximum value a uint128 number can have.
uint128 constant MAX_UINT128 = type(uint128).max;

/// @dev The maximum value a uint40 number can have.
uint40 constant MAX_UINT40 = type(uint40).max;

/// @dev The unit number, which the decimal precision of the fixed-point types.
uint256 constant UNIT = 1e18;

/// @dev The unit number inverted mod 2^256.
uint256 constant UNIT_INVERSE = 78156646155174841979727994598816262306175212592076161876661_508869554232690281;

/// @dev The the largest power of two that divides the decimal value of `UNIT`. The logarithm of this value is the least significant
/// bit in the binary representation of `UNIT`.
uint256 constant UNIT_LPOTD = 262144;

/*//////////////////////////////////////////////////////////////////////////
                                    FUNCTIONS
//////////////////////////////////////////////////////////////////////////*/

/// @notice Calculates the binary exponent of x using the binary fraction method.
/// @dev Has to use 192.64-bit fixed-point numbers. See https://ethereum.stackexchange.com/a/96594/24693.
/// @param x The exponent as an unsigned 192.64-bit fixed-point number.
/// @return result The result as an unsigned 60.18-decimal fixed-point number.
/// @custom:smtchecker abstract-function-nondet
function exp2(uint256 x) pure returns (uint256 result) {
    unchecked {
        // Start from 0.5 in the 192.64-bit fixed-point format.
        result = 0x800000000000000000000000000000000000000000000000;

        // The following logic multiplies the result by $\sqrt{2^{-i}}$ when the bit at position i is 1. Key points:
        //
        // 1. Intermediate results will not overflow, as the starting point is 2^191 and all magic factors are under 2^65.
        // 2. The rationale for organizing the if statements into groups of 8 is gas savings. If the result of performing
        // a bitwise AND operation between x and any value in the array [0x80; 0x40; 0x20; 0x10; 0x08; 0x04; 0x02; 0x01] is 1,
        // we know that `x & 0xFF` is also 1.
        if (x & 0xFF00000000000000 > 0) {
            if (x & 0x8000000000000000 > 0) {
                result = (result * 0x16A09E667F3BCC909) >> 64;
            }
            if (x & 0x4000000000000000 > 0) {
                result = (result * 0x1306FE0A31B7152DF) >> 64;
            }
            if (x & 0x2000000000000000 > 0) {
                result = (result * 0x1172B83C7D517ADCE) >> 64;
            }
            if (x & 0x1000000000000000 > 0) {
                result = (result * 0x10B5586CF9890F62A) >> 64;
            }
            if (x & 0x800000000000000 > 0) {
                result = (result * 0x1059B0D31585743AE) >> 64;
            }
            if (x & 0x400000000000000 > 0) {
                result = (result * 0x102C9A3E778060EE7) >> 64;
            }
            if (x & 0x200000000000000 > 0) {
                result = (result * 0x10163DA9FB33356D8) >> 64;
            }
            if (x & 0x100000000000000 > 0) {
                result = (result * 0x100B1AFA5ABCBED61) >> 64;
            }
        }

        if (x & 0xFF000000000000 > 0) {
            if (x & 0x80000000000000 > 0) {
                result = (result * 0x10058C86DA1C09EA2) >> 64;
            }
            if (x & 0x40000000000000 > 0) {
                result = (result * 0x1002C605E2E8CEC50) >> 64;
            }
            if (x & 0x20000000000000 > 0) {
                result = (result * 0x100162F3904051FA1) >> 64;
            }
            if (x & 0x10000000000000 > 0) {
                result = (result * 0x1000B175EFFDC76BA) >> 64;
            }
            if (x & 0x8000000000000 > 0) {
                result = (result * 0x100058BA01FB9F96D) >> 64;
            }
            if (x & 0x4000000000000 > 0) {
                result = (result * 0x10002C5CC37DA9492) >> 64;
            }
            if (x & 0x2000000000000 > 0) {
                result = (result * 0x1000162E525EE0547) >> 64;
            }
            if (x & 0x1000000000000 > 0) {
                result = (result * 0x10000B17255775C04) >> 64;
            }
        }

        if (x & 0xFF0000000000 > 0) {
            if (x & 0x800000000000 > 0) {
                result = (result * 0x1000058B91B5BC9AE) >> 64;
            }
            if (x & 0x400000000000 > 0) {
                result = (result * 0x100002C5C89D5EC6D) >> 64;
            }
            if (x & 0x200000000000 > 0) {
                result = (result * 0x10000162E43F4F831) >> 64;
            }
            if (x & 0x100000000000 > 0) {
                result = (result * 0x100000B1721BCFC9A) >> 64;
            }
            if (x & 0x80000000000 > 0) {
                result = (result * 0x10000058B90CF1E6E) >> 64;
            }
            if (x & 0x40000000000 > 0) {
                result = (result * 0x1000002C5C863B73F) >> 64;
            }
            if (x & 0x20000000000 > 0) {
                result = (result * 0x100000162E430E5A2) >> 64;
            }
            if (x & 0x10000000000 > 0) {
                result = (result * 0x1000000B172183551) >> 64;
            }
        }

        if (x & 0xFF00000000 > 0) {
            if (x & 0x8000000000 > 0) {
                result = (result * 0x100000058B90C0B49) >> 64;
            }
            if (x & 0x4000000000 > 0) {
                result = (result * 0x10000002C5C8601CC) >> 64;
            }
            if (x & 0x2000000000 > 0) {
                result = (result * 0x1000000162E42FFF0) >> 64;
            }
            if (x & 0x1000000000 > 0) {
                result = (result * 0x10000000B17217FBB) >> 64;
            }
            if (x & 0x800000000 > 0) {
                result = (result * 0x1000000058B90BFCE) >> 64;
            }
            if (x & 0x400000000 > 0) {
                result = (result * 0x100000002C5C85FE3) >> 64;
            }
            if (x & 0x200000000 > 0) {
                result = (result * 0x10000000162E42FF1) >> 64;
            }
            if (x & 0x100000000 > 0) {
                result = (result * 0x100000000B17217F8) >> 64;
            }
        }

        if (x & 0xFF000000 > 0) {
            if (x & 0x80000000 > 0) {
                result = (result * 0x10000000058B90BFC) >> 64;
            }
            if (x & 0x40000000 > 0) {
                result = (result * 0x1000000002C5C85FE) >> 64;
            }
            if (x & 0x20000000 > 0) {
                result = (result * 0x100000000162E42FF) >> 64;
            }
            if (x & 0x10000000 > 0) {
                result = (result * 0x1000000000B17217F) >> 64;
            }
            if (x & 0x8000000 > 0) {
                result = (result * 0x100000000058B90C0) >> 64;
            }
            if (x & 0x4000000 > 0) {
                result = (result * 0x10000000002C5C860) >> 64;
            }
            if (x & 0x2000000 > 0) {
                result = (result * 0x1000000000162E430) >> 64;
            }
            if (x & 0x1000000 > 0) {
                result = (result * 0x10000000000B17218) >> 64;
            }
        }

        if (x & 0xFF0000 > 0) {
            if (x & 0x800000 > 0) {
                result = (result * 0x1000000000058B90C) >> 64;
            }
            if (x & 0x400000 > 0) {
                result = (result * 0x100000000002C5C86) >> 64;
            }
            if (x & 0x200000 > 0) {
                result = (result * 0x10000000000162E43) >> 64;
            }
            if (x & 0x100000 > 0) {
                result = (result * 0x100000000000B1721) >> 64;
            }
            if (x & 0x80000 > 0) {
                result = (result * 0x10000000000058B91) >> 64;
            }
            if (x & 0x40000 > 0) {
                result = (result * 0x1000000000002C5C8) >> 64;
            }
            if (x & 0x20000 > 0) {
                result = (result * 0x100000000000162E4) >> 64;
            }
            if (x & 0x10000 > 0) {
                result = (result * 0x1000000000000B172) >> 64;
            }
        }

        if (x & 0xFF00 > 0) {
            if (x & 0x8000 > 0) {
                result = (result * 0x100000000000058B9) >> 64;
            }
            if (x & 0x4000 > 0) {
                result = (result * 0x10000000000002C5D) >> 64;
            }
            if (x & 0x2000 > 0) {
                result = (result * 0x1000000000000162E) >> 64;
            }
            if (x & 0x1000 > 0) {
                result = (result * 0x10000000000000B17) >> 64;
            }
            if (x & 0x800 > 0) {
                result = (result * 0x1000000000000058C) >> 64;
            }
            if (x & 0x400 > 0) {
                result = (result * 0x100000000000002C6) >> 64;
            }
            if (x & 0x200 > 0) {
                result = (result * 0x10000000000000163) >> 64;
            }
            if (x & 0x100 > 0) {
                result = (result * 0x100000000000000B1) >> 64;
            }
        }

        if (x & 0xFF > 0) {
            if (x & 0x80 > 0) {
                result = (result * 0x10000000000000059) >> 64;
            }
            if (x & 0x40 > 0) {
                result = (result * 0x1000000000000002C) >> 64;
            }
            if (x & 0x20 > 0) {
                result = (result * 0x10000000000000016) >> 64;
            }
            if (x & 0x10 > 0) {
                result = (result * 0x1000000000000000B) >> 64;
            }
            if (x & 0x8 > 0) {
                result = (result * 0x10000000000000006) >> 64;
            }
            if (x & 0x4 > 0) {
                result = (result * 0x10000000000000003) >> 64;
            }
            if (x & 0x2 > 0) {
                result = (result * 0x10000000000000001) >> 64;
            }
            if (x & 0x1 > 0) {
                result = (result * 0x10000000000000001) >> 64;
            }
        }

        // In the code snippet below, two operations are executed simultaneously:
        //
        // 1. The result is multiplied by $(2^n + 1)$, where $2^n$ represents the integer part, and the additional 1
        // accounts for the initial guess of 0.5. This is achieved by subtracting from 191 instead of 192.
        // 2. The result is then converted to an unsigned 60.18-decimal fixed-point format.
        //
        // The underlying logic is based on the relationship $2^{191-ip} = 2^{ip} / 2^{191}$, where $ip$ denotes the,
        // integer part, $2^n$.
        result *= UNIT;
        result >>= (191 - (x >> 64));
    }
}

/// @notice Finds the zero-based index of the first 1 in the binary representation of x.
///
/// @dev See the note on "msb" in this Wikipedia article: https://en.wikipedia.org/wiki/Find_first_set
///
/// Each step in this implementation is equivalent to this high-level code:
///
/// ```solidity
/// if (x >= 2 ** 128) {
///     x >>= 128;
///     result += 128;
/// }
/// ```
///
/// Where 128 is replaced with each respective power of two factor. See the full high-level implementation here:
/// https://gist.github.com/PaulRBerg/f932f8693f2733e30c4d479e8e980948
///
/// The Yul instructions used below are:
///
/// - "gt" is "greater than"
/// - "or" is the OR bitwise operator
/// - "shl" is "shift left"
/// - "shr" is "shift right"
///
/// @param x The uint256 number for which to find the index of the most significant bit.
/// @return result The index of the most significant bit as a uint256.
/// @custom:smtchecker abstract-function-nondet
function msb(uint256 x) pure returns (uint256 result) {
    // 2^128
    assembly ("memory-safe") {
        let factor := shl(7, gt(x, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    // 2^64
    assembly ("memory-safe") {
        let factor := shl(6, gt(x, 0xFFFFFFFFFFFFFFFF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    // 2^32
    assembly ("memory-safe") {
        let factor := shl(5, gt(x, 0xFFFFFFFF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    // 2^16
    assembly ("memory-safe") {
        let factor := shl(4, gt(x, 0xFFFF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    // 2^8
    assembly ("memory-safe") {
        let factor := shl(3, gt(x, 0xFF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    // 2^4
    assembly ("memory-safe") {
        let factor := shl(2, gt(x, 0xF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    // 2^2
    assembly ("memory-safe") {
        let factor := shl(1, gt(x, 0x3))
        x := shr(factor, x)
        result := or(result, factor)
    }
    // 2^1
    // No need to shift x any more.
    assembly ("memory-safe") {
        let factor := gt(x, 0x1)
        result := or(result, factor)
    }
}

/// @notice Calculates x*y÷denominator with 512-bit precision.
///
/// @dev Credits to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv.
///
/// Notes:
/// - The result is rounded toward zero.
///
/// Requirements:
/// - The denominator must not be zero.
/// - The result must fit in uint256.
///
/// @param x The multiplicand as a uint256.
/// @param y The multiplier as a uint256.
/// @param denominator The divisor as a uint256.
/// @return result The result as a uint256.
/// @custom:smtchecker abstract-function-nondet
function mulDiv(uint256 x, uint256 y, uint256 denominator) pure returns (uint256 result) {
    // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
    // use the Chinese Remainder Theorem to reconstruct the 512-bit result. The result is stored in two 256
    // variables such that product = prod1 * 2^256 + prod0.
    uint256 prod0; // Least significant 256 bits of the product
    uint256 prod1; // Most significant 256 bits of the product
    assembly ("memory-safe") {
        let mm := mulmod(x, y, not(0))
        prod0 := mul(x, y)
        prod1 := sub(sub(mm, prod0), lt(mm, prod0))
    }

    // Handle non-overflow cases, 256 by 256 division.
    if (prod1 == 0) {
        unchecked {
            return prod0 / denominator;
        }
    }

    // Make sure the result is less than 2^256. Also prevents denominator == 0.
    if (prod1 >= denominator) {
        revert PRBMath_MulDiv_Overflow(x, y, denominator);
    }

    ////////////////////////////////////////////////////////////////////////////
    // 512 by 256 division
    ////////////////////////////////////////////////////////////////////////////

    // Make division exact by subtracting the remainder from [prod1 prod0].
    uint256 remainder;
    assembly ("memory-safe") {
        // Compute remainder using the mulmod Yul instruction.
        remainder := mulmod(x, y, denominator)

        // Subtract 256 bit number from 512-bit number.
        prod1 := sub(prod1, gt(remainder, prod0))
        prod0 := sub(prod0, remainder)
    }

    unchecked {
        // Calculate the largest power of two divisor of the denominator using the unary operator ~. This operation cannot overflow
        // because the denominator cannot be zero at this point in the function execution. The result is always >= 1.
        // For more detail, see https://cs.stackexchange.com/q/138556/92363.
        uint256 lpotdod = denominator & (~denominator + 1);
        uint256 flippedLpotdod;

        assembly ("memory-safe") {
            // Factor powers of two out of denominator.
            denominator := div(denominator, lpotdod)

            // Divide [prod1 prod0] by lpotdod.
            prod0 := div(prod0, lpotdod)

            // Get the flipped value `2^256 / lpotdod`. If the `lpotdod` is zero, the flipped value is one.
            // `sub(0, lpotdod)` produces the two's complement version of `lpotdod`, which is equivalent to flipping all the bits.
            // However, `div` interprets this value as an unsigned value: https://ethereum.stackexchange.com/q/147168/24693
            flippedLpotdod := add(div(sub(0, lpotdod), lpotdod), 1)
        }

        // Shift in bits from prod1 into prod0.
        prod0 |= prod1 * flippedLpotdod;

        // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
        // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
        // four bits. That is, denominator * inv = 1 mod 2^4.
        uint256 inverse = (3 * denominator) ^ 2;

        // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
        // in modular arithmetic, doubling the correct bits in each step.
        inverse *= 2 - denominator * inverse; // inverse mod 2^8
        inverse *= 2 - denominator * inverse; // inverse mod 2^16
        inverse *= 2 - denominator * inverse; // inverse mod 2^32
        inverse *= 2 - denominator * inverse; // inverse mod 2^64
        inverse *= 2 - denominator * inverse; // inverse mod 2^128
        inverse *= 2 - denominator * inverse; // inverse mod 2^256

        // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
        // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
        // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
        // is no longer required.
        result = prod0 * inverse;
    }
}

/// @notice Calculates x*y÷1e18 with 512-bit precision.
///
/// @dev A variant of {mulDiv} with constant folding, i.e. in which the denominator is hard coded to 1e18.
///
/// Notes:
/// - The body is purposely left uncommented; to understand how this works, see the documentation in {mulDiv}.
/// - The result is rounded toward zero.
/// - We take as an axiom that the result cannot be `MAX_UINT256` when x and y solve the following system of equations:
///
/// $$
/// \begin{cases}
///     x * y = MAX\_UINT256 * UNIT \\
///     (x * y) \% UNIT \geq \frac{UNIT}{2}
/// \end{cases}
/// $$
///
/// Requirements:
/// - Refer to the requirements in {mulDiv}.
/// - The result must fit in uint256.
///
/// @param x The multiplicand as an unsigned 60.18-decimal fixed-point number.
/// @param y The multiplier as an unsigned 60.18-decimal fixed-point number.
/// @return result The result as an unsigned 60.18-decimal fixed-point number.
/// @custom:smtchecker abstract-function-nondet
function mulDiv18(uint256 x, uint256 y) pure returns (uint256 result) {
    uint256 prod0;
    uint256 prod1;
    assembly ("memory-safe") {
        let mm := mulmod(x, y, not(0))
        prod0 := mul(x, y)
        prod1 := sub(sub(mm, prod0), lt(mm, prod0))
    }

    if (prod1 == 0) {
        unchecked {
            return prod0 / UNIT;
        }
    }

    if (prod1 >= UNIT) {
        revert PRBMath_MulDiv18_Overflow(x, y);
    }

    uint256 remainder;
    assembly ("memory-safe") {
        remainder := mulmod(x, y, UNIT)
        result :=
            mul(
                or(
                    div(sub(prod0, remainder), UNIT_LPOTD),
                    mul(sub(prod1, gt(remainder, prod0)), add(div(sub(0, UNIT_LPOTD), UNIT_LPOTD), 1))
                ),
                UNIT_INVERSE
            )
    }
}

/// @notice Calculates x*y÷denominator with 512-bit precision.
///
/// @dev This is an extension of {mulDiv} for signed numbers, which works by computing the signs and the absolute values separately.
///
/// Notes:
/// - The result is rounded toward zero.
///
/// Requirements:
/// - Refer to the requirements in {mulDiv}.
/// - None of the inputs can be `type(int256).min`.
/// - The result must fit in int256.
///
/// @param x The multiplicand as an int256.
/// @param y The multiplier as an int256.
/// @param denominator The divisor as an int256.
/// @return result The result as an int256.
/// @custom:smtchecker abstract-function-nondet
function mulDivSigned(int256 x, int256 y, int256 denominator) pure returns (int256 result) {
    if (x == type(int256).min || y == type(int256).min || denominator == type(int256).min) {
        revert PRBMath_MulDivSigned_InputTooSmall();
    }

    // Get hold of the absolute values of x, y and the denominator.
    uint256 xAbs;
    uint256 yAbs;
    uint256 dAbs;
    unchecked {
        xAbs = x < 0 ? uint256(-x) : uint256(x);
        yAbs = y < 0 ? uint256(-y) : uint256(y);
        dAbs = denominator < 0 ? uint256(-denominator) : uint256(denominator);
    }

    // Compute the absolute value of x*y÷denominator. The result must fit in int256.
    uint256 resultAbs = mulDiv(xAbs, yAbs, dAbs);
    if (resultAbs > uint256(type(int256).max)) {
        revert PRBMath_MulDivSigned_Overflow(x, y);
    }

    // Get the signs of x, y and the denominator.
    uint256 sx;
    uint256 sy;
    uint256 sd;
    assembly ("memory-safe") {
        // "sgt" is the "signed greater than" assembly instruction and "sub(0,1)" is -1 in two's complement.
        sx := sgt(x, sub(0, 1))
        sy := sgt(y, sub(0, 1))
        sd := sgt(denominator, sub(0, 1))
    }

    // XOR over sx, sy and sd. What this does is to check whether there are 1 or 3 negative signs in the inputs.
    // If there are, the result should be negative. Otherwise, it should be positive.
    unchecked {
        result = sx ^ sy ^ sd == 0 ? -int256(resultAbs) : int256(resultAbs);
    }
}

/// @notice Calculates the square root of x using the Babylonian method.
///
/// @dev See https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method.
///
/// Notes:
/// - If x is not a perfect square, the result is rounded down.
/// - Credits to OpenZeppelin for the explanations in comments below.
///
/// @param x The uint256 number for which to calculate the square root.
/// @return result The result as a uint256.
/// @custom:smtchecker abstract-function-nondet
function sqrt(uint256 x) pure returns (uint256 result) {
    if (x == 0) {
        return 0;
    }

    // For our first guess, we calculate the biggest power of 2 which is smaller than the square root of x.
    //
    // We know that the "msb" (most significant bit) of x is a power of 2 such that we have:
    //
    // $$
    // msb(x) <= x <= 2*msb(x)$
    // $$
    //
    // We write $msb(x)$ as $2^k$, and we get:
    //
    // $$
    // k = log_2(x)
    // $$
    //
    // Thus, we can write the initial inequality as:
    //
    // $$
    // 2^{log_2(x)} <= x <= 2*2^{log_2(x)+1} \\
    // sqrt(2^k) <= sqrt(x) < sqrt(2^{k+1}) \\
    // 2^{k/2} <= sqrt(x) < 2^{(k+1)/2} <= 2^{(k/2)+1}
    // $$
    //
    // Consequently, $2^{log_2(x) /2} is a good first approximation of sqrt(x) with at least one correct bit.
    uint256 xAux = uint256(x);
    result = 1;
    if (xAux >= 2 ** 128) {
        xAux >>= 128;
        result <<= 64;
    }
    if (xAux >= 2 ** 64) {
        xAux >>= 64;
        result <<= 32;
    }
    if (xAux >= 2 ** 32) {
        xAux >>= 32;
        result <<= 16;
    }
    if (xAux >= 2 ** 16) {
        xAux >>= 16;
        result <<= 8;
    }
    if (xAux >= 2 ** 8) {
        xAux >>= 8;
        result <<= 4;
    }
    if (xAux >= 2 ** 4) {
        xAux >>= 4;
        result <<= 2;
    }
    if (xAux >= 2 ** 2) {
        result <<= 1;
    }

    // At this point, `result` is an estimation with at least one bit of precision. We know the true value has at
    // most 128 bits, since it is the square root of a uint256. Newton's method converges quadratically (precision
    // doubles at every iteration). We thus need at most 7 iteration to turn our partial result with one bit of
    // precision into the expected uint128 result.
    unchecked {
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;

        // If x is not a perfect square, round the result toward zero.
        uint256 roundedResult = x / result;
        if (result >= roundedResult) {
            result = roundedResult;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

/*

██████╗ ██████╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗  ██╗
██╔══██╗██╔══██╗██╔══██╗████╗ ████║██╔══██╗╚══██╔══╝██║  ██║
██████╔╝██████╔╝██████╔╝██╔████╔██║███████║   ██║   ███████║
██╔═══╝ ██╔══██╗██╔══██╗██║╚██╔╝██║██╔══██║   ██║   ██╔══██║
██║     ██║  ██║██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║  ██║
╚═╝     ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝

██╗   ██╗██████╗  ██████╗  ██████╗ ██╗  ██╗ ██╗ █████╗
██║   ██║██╔══██╗██╔════╝ ██╔═████╗╚██╗██╔╝███║██╔══██╗
██║   ██║██║  ██║███████╗ ██║██╔██║ ╚███╔╝ ╚██║╚█████╔╝
██║   ██║██║  ██║██╔═══██╗████╔╝██║ ██╔██╗  ██║██╔══██╗
╚██████╔╝██████╔╝╚██████╔╝╚██████╔╝██╔╝ ██╗ ██║╚█████╔╝
 ╚═════╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚═╝  ╚═╝ ╚═╝ ╚════╝

*/

import "./ud60x18/Casting.sol";
import "./ud60x18/Constants.sol";
import "./ud60x18/Conversions.sol";
import "./ud60x18/Errors.sol";
import "./ud60x18/Helpers.sol";
import "./ud60x18/Math.sol";
import "./ud60x18/ValueType.sol";
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "../Common.sol" as Common;
import "./Errors.sol" as CastingErrors;
import { SD59x18 } from "../sd59x18/ValueType.sol";
import { UD2x18 } from "../ud2x18/ValueType.sol";
import { UD60x18 } from "../ud60x18/ValueType.sol";
import { SD1x18 } from "./ValueType.sol";

/// @notice Casts an SD1x18 number into SD59x18.
/// @dev There is no overflow check because the domain of SD1x18 is a subset of SD59x18.
function intoSD59x18(SD1x18 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(int256(SD1x18.unwrap(x)));
}

/// @notice Casts an SD1x18 number into UD2x18.
/// - x must be positive.
function intoUD2x18(SD1x18 x) pure returns (UD2x18 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD1x18_ToUD2x18_Underflow(x);
    }
    result = UD2x18.wrap(uint64(xInt));
}

/// @notice Casts an SD1x18 number into UD60x18.
/// @dev Requirements:
/// - x must be positive.
function intoUD60x18(SD1x18 x) pure returns (UD60x18 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD1x18_ToUD60x18_Underflow(x);
    }
    result = UD60x18.wrap(uint64(xInt));
}

/// @notice Casts an SD1x18 number into uint256.
/// @dev Requirements:
/// - x must be positive.
function intoUint256(SD1x18 x) pure returns (uint256 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD1x18_ToUint256_Underflow(x);
    }
    result = uint256(uint64(xInt));
}

/// @notice Casts an SD1x18 number into uint128.
/// @dev Requirements:
/// - x must be positive.
function intoUint128(SD1x18 x) pure returns (uint128 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD1x18_ToUint128_Underflow(x);
    }
    result = uint128(uint64(xInt));
}

/// @notice Casts an SD1x18 number into uint40.
/// @dev Requirements:
/// - x must be positive.
/// - x must be less than or equal to `MAX_UINT40`.
function intoUint40(SD1x18 x) pure returns (uint40 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD1x18_ToUint40_Underflow(x);
    }
    if (xInt > int64(uint64(Common.MAX_UINT40))) {
        revert CastingErrors.PRBMath_SD1x18_ToUint40_Overflow(x);
    }
    result = uint40(uint64(xInt));
}

/// @notice Alias for {wrap}.
function sd1x18(int64 x) pure returns (SD1x18 result) {
    result = SD1x18.wrap(x);
}

/// @notice Unwraps an SD1x18 number into int64.
function unwrap(SD1x18 x) pure returns (int64 result) {
    result = SD1x18.unwrap(x);
}

/// @notice Wraps an int64 number into SD1x18.
function wrap(int64 x) pure returns (SD1x18 result) {
    result = SD1x18.wrap(x);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { SD1x18 } from "./ValueType.sol";

/// @dev Euler's number as an SD1x18 number.
SD1x18 constant E = SD1x18.wrap(2_718281828459045235);

/// @dev The maximum value an SD1x18 number can have.
int64 constant uMAX_SD1x18 = 9_223372036854775807;
SD1x18 constant MAX_SD1x18 = SD1x18.wrap(uMAX_SD1x18);

/// @dev The maximum value an SD1x18 number can have.
int64 constant uMIN_SD1x18 = -9_223372036854775808;
SD1x18 constant MIN_SD1x18 = SD1x18.wrap(uMIN_SD1x18);

/// @dev PI as an SD1x18 number.
SD1x18 constant PI = SD1x18.wrap(3_141592653589793238);

/// @dev The unit number, which gives the decimal precision of SD1x18.
SD1x18 constant UNIT = SD1x18.wrap(1e18);
int64 constant uUNIT = 1e18;
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { SD1x18 } from "./ValueType.sol";

/// @notice Thrown when trying to cast a SD1x18 number that doesn't fit in UD2x18.
error PRBMath_SD1x18_ToUD2x18_Underflow(SD1x18 x);

/// @notice Thrown when trying to cast a SD1x18 number that doesn't fit in UD60x18.
error PRBMath_SD1x18_ToUD60x18_Underflow(SD1x18 x);

/// @notice Thrown when trying to cast a SD1x18 number that doesn't fit in uint128.
error PRBMath_SD1x18_ToUint128_Underflow(SD1x18 x);

/// @notice Thrown when trying to cast a SD1x18 number that doesn't fit in uint256.
error PRBMath_SD1x18_ToUint256_Underflow(SD1x18 x);

/// @notice Thrown when trying to cast a SD1x18 number that doesn't fit in uint40.
error PRBMath_SD1x18_ToUint40_Overflow(SD1x18 x);

/// @notice Thrown when trying to cast a SD1x18 number that doesn't fit in uint40.
error PRBMath_SD1x18_ToUint40_Underflow(SD1x18 x);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "./Casting.sol" as Casting;

/// @notice The signed 1.18-decimal fixed-point number representation, which can have up to 1 digit and up to 18
/// decimals. The values of this are bound by the minimum and the maximum values permitted by the underlying Solidity
/// type int64. This is useful when end users want to use int64 to save gas, e.g. with tight variable packing in contract
/// storage.
type SD1x18 is int64;

/*//////////////////////////////////////////////////////////////////////////
                                    CASTING
//////////////////////////////////////////////////////////////////////////*/

using {
    Casting.intoSD59x18,
    Casting.intoUD2x18,
    Casting.intoUD60x18,
    Casting.intoUint256,
    Casting.intoUint128,
    Casting.intoUint40,
    Casting.unwrap
} for SD1x18 global;
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "./Errors.sol" as CastingErrors;
import { MAX_UINT128, MAX_UINT40 } from "../Common.sol";
import { uMAX_SD1x18, uMIN_SD1x18 } from "../sd1x18/Constants.sol";
import { SD1x18 } from "../sd1x18/ValueType.sol";
import { uMAX_UD2x18 } from "../ud2x18/Constants.sol";
import { UD2x18 } from "../ud2x18/ValueType.sol";
import { UD60x18 } from "../ud60x18/ValueType.sol";
import { SD59x18 } from "./ValueType.sol";

/// @notice Casts an SD59x18 number into int256.
/// @dev This is basically a functional alias for {unwrap}.
function intoInt256(SD59x18 x) pure returns (int256 result) {
    result = SD59x18.unwrap(x);
}

/// @notice Casts an SD59x18 number into SD1x18.
/// @dev Requirements:
/// - x must be greater than or equal to `uMIN_SD1x18`.
/// - x must be less than or equal to `uMAX_SD1x18`.
function intoSD1x18(SD59x18 x) pure returns (SD1x18 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < uMIN_SD1x18) {
        revert CastingErrors.PRBMath_SD59x18_IntoSD1x18_Underflow(x);
    }
    if (xInt > uMAX_SD1x18) {
        revert CastingErrors.PRBMath_SD59x18_IntoSD1x18_Overflow(x);
    }
    result = SD1x18.wrap(int64(xInt));
}

/// @notice Casts an SD59x18 number into UD2x18.
/// @dev Requirements:
/// - x must be positive.
/// - x must be less than or equal to `uMAX_UD2x18`.
function intoUD2x18(SD59x18 x) pure returns (UD2x18 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD59x18_IntoUD2x18_Underflow(x);
    }
    if (xInt > int256(uint256(uMAX_UD2x18))) {
        revert CastingErrors.PRBMath_SD59x18_IntoUD2x18_Overflow(x);
    }
    result = UD2x18.wrap(uint64(uint256(xInt)));
}

/// @notice Casts an SD59x18 number into UD60x18.
/// @dev Requirements:
/// - x must be positive.
function intoUD60x18(SD59x18 x) pure returns (UD60x18 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD59x18_IntoUD60x18_Underflow(x);
    }
    result = UD60x18.wrap(uint256(xInt));
}

/// @notice Casts an SD59x18 number into uint256.
/// @dev Requirements:
/// - x must be positive.
function intoUint256(SD59x18 x) pure returns (uint256 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD59x18_IntoUint256_Underflow(x);
    }
    result = uint256(xInt);
}

/// @notice Casts an SD59x18 number into uint128.
/// @dev Requirements:
/// - x must be positive.
/// - x must be less than or equal to `uMAX_UINT128`.
function intoUint128(SD59x18 x) pure returns (uint128 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD59x18_IntoUint128_Underflow(x);
    }
    if (xInt > int256(uint256(MAX_UINT128))) {
        revert CastingErrors.PRBMath_SD59x18_IntoUint128_Overflow(x);
    }
    result = uint128(uint256(xInt));
}

/// @notice Casts an SD59x18 number into uint40.
/// @dev Requirements:
/// - x must be positive.
/// - x must be less than or equal to `MAX_UINT40`.
function intoUint40(SD59x18 x) pure returns (uint40 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD59x18_IntoUint40_Underflow(x);
    }
    if (xInt > int256(uint256(MAX_UINT40))) {
        revert CastingErrors.PRBMath_SD59x18_IntoUint40_Overflow(x);
    }
    result = uint40(uint256(xInt));
}

/// @notice Alias for {wrap}.
function sd(int256 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(x);
}

/// @notice Alias for {wrap}.
function sd59x18(int256 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(x);
}

/// @notice Unwraps an SD59x18 number into int256.
function unwrap(SD59x18 x) pure returns (int256 result) {
    result = SD59x18.unwrap(x);
}

/// @notice Wraps an int256 number into SD59x18.
function wrap(int256 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(x);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { SD59x18 } from "./ValueType.sol";

// NOTICE: the "u" prefix stands for "unwrapped".

/// @dev Euler's number as an SD59x18 number.
SD59x18 constant E = SD59x18.wrap(2_718281828459045235);

/// @dev The maximum input permitted in {exp}.
int256 constant uEXP_MAX_INPUT = 133_084258667509499440;
SD59x18 constant EXP_MAX_INPUT = SD59x18.wrap(uEXP_MAX_INPUT);

/// @dev Any value less than this returns 0 in {exp}.
int256 constant uEXP_MIN_THRESHOLD = -41_446531673892822322;
SD59x18 constant EXP_MIN_THRESHOLD = SD59x18.wrap(uEXP_MIN_THRESHOLD);

/// @dev The maximum input permitted in {exp2}.
int256 constant uEXP2_MAX_INPUT = 192e18 - 1;
SD59x18 constant EXP2_MAX_INPUT = SD59x18.wrap(uEXP2_MAX_INPUT);

/// @dev Any value less than this returns 0 in {exp2}.
int256 constant uEXP2_MIN_THRESHOLD = -59_794705707972522261;
SD59x18 constant EXP2_MIN_THRESHOLD = SD59x18.wrap(uEXP2_MIN_THRESHOLD);

/// @dev Half the UNIT number.
int256 constant uHALF_UNIT = 0.5e18;
SD59x18 constant HALF_UNIT = SD59x18.wrap(uHALF_UNIT);

/// @dev $log_2(10)$ as an SD59x18 number.
int256 constant uLOG2_10 = 3_321928094887362347;
SD59x18 constant LOG2_10 = SD59x18.wrap(uLOG2_10);

/// @dev $log_2(e)$ as an SD59x18 number.
int256 constant uLOG2_E = 1_442695040888963407;
SD59x18 constant LOG2_E = SD59x18.wrap(uLOG2_E);

/// @dev The maximum value an SD59x18 number can have.
int256 constant uMAX_SD59x18 = 57896044618658097711785492504343953926634992332820282019728_792003956564819967;
SD59x18 constant MAX_SD59x18 = SD59x18.wrap(uMAX_SD59x18);

/// @dev The maximum whole value an SD59x18 number can have.
int256 constant uMAX_WHOLE_SD59x18 = 57896044618658097711785492504343953926634992332820282019728_000000000000000000;
SD59x18 constant MAX_WHOLE_SD59x18 = SD59x18.wrap(uMAX_WHOLE_SD59x18);

/// @dev The minimum value an SD59x18 number can have.
int256 constant uMIN_SD59x18 = -57896044618658097711785492504343953926634992332820282019728_792003956564819968;
SD59x18 constant MIN_SD59x18 = SD59x18.wrap(uMIN_SD59x18);

/// @dev The minimum whole value an SD59x18 number can have.
int256 constant uMIN_WHOLE_SD59x18 = -57896044618658097711785492504343953926634992332820282019728_000000000000000000;
SD59x18 constant MIN_WHOLE_SD59x18 = SD59x18.wrap(uMIN_WHOLE_SD59x18);

/// @dev PI as an SD59x18 number.
SD59x18 constant PI = SD59x18.wrap(3_141592653589793238);

/// @dev The unit number, which gives the decimal precision of SD59x18.
int256 constant uUNIT = 1e18;
SD59x18 constant UNIT = SD59x18.wrap(1e18);

/// @dev The unit number squared.
int256 constant uUNIT_SQUARED = 1e36;
SD59x18 constant UNIT_SQUARED = SD59x18.wrap(uUNIT_SQUARED);

/// @dev Zero as an SD59x18 number.
SD59x18 constant ZERO = SD59x18.wrap(0);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { SD59x18 } from "./ValueType.sol";

/// @notice Thrown when taking the absolute value of `MIN_SD59x18`.
error PRBMath_SD59x18_Abs_MinSD59x18();

/// @notice Thrown when ceiling a number overflows SD59x18.
error PRBMath_SD59x18_Ceil_Overflow(SD59x18 x);

/// @notice Thrown when converting a basic integer to the fixed-point format overflows SD59x18.
error PRBMath_SD59x18_Convert_Overflow(int256 x);

/// @notice Thrown when converting a basic integer to the fixed-point format underflows SD59x18.
error PRBMath_SD59x18_Convert_Underflow(int256 x);

/// @notice Thrown when dividing two numbers and one of them is `MIN_SD59x18`.
error PRBMath_SD59x18_Div_InputTooSmall();

/// @notice Thrown when dividing two numbers and one of the intermediary unsigned results overflows SD59x18.
error PRBMath_SD59x18_Div_Overflow(SD59x18 x, SD59x18 y);

/// @notice Thrown when taking the natural exponent of a base greater than 133_084258667509499441.
error PRBMath_SD59x18_Exp_InputTooBig(SD59x18 x);

/// @notice Thrown when taking the binary exponent of a base greater than 192e18.
error PRBMath_SD59x18_Exp2_InputTooBig(SD59x18 x);

/// @notice Thrown when flooring a number underflows SD59x18.
error PRBMath_SD59x18_Floor_Underflow(SD59x18 x);

/// @notice Thrown when taking the geometric mean of two numbers and their product is negative.
error PRBMath_SD59x18_Gm_NegativeProduct(SD59x18 x, SD59x18 y);

/// @notice Thrown when taking the geometric mean of two numbers and multiplying them overflows SD59x18.
error PRBMath_SD59x18_Gm_Overflow(SD59x18 x, SD59x18 y);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in SD1x18.
error PRBMath_SD59x18_IntoSD1x18_Overflow(SD59x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in SD1x18.
error PRBMath_SD59x18_IntoSD1x18_Underflow(SD59x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in UD2x18.
error PRBMath_SD59x18_IntoUD2x18_Overflow(SD59x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in UD2x18.
error PRBMath_SD59x18_IntoUD2x18_Underflow(SD59x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in UD60x18.
error PRBMath_SD59x18_IntoUD60x18_Underflow(SD59x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in uint128.
error PRBMath_SD59x18_IntoUint128_Overflow(SD59x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in uint128.
error PRBMath_SD59x18_IntoUint128_Underflow(SD59x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in uint256.
error PRBMath_SD59x18_IntoUint256_Underflow(SD59x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in uint40.
error PRBMath_SD59x18_IntoUint40_Overflow(SD59x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in uint40.
error PRBMath_SD59x18_IntoUint40_Underflow(SD59x18 x);

/// @notice Thrown when taking the logarithm of a number less than or equal to zero.
error PRBMath_SD59x18_Log_InputTooSmall(SD59x18 x);

/// @notice Thrown when multiplying two numbers and one of the inputs is `MIN_SD59x18`.
error PRBMath_SD59x18_Mul_InputTooSmall();

/// @notice Thrown when multiplying two numbers and the intermediary absolute result overflows SD59x18.
error PRBMath_SD59x18_Mul_Overflow(SD59x18 x, SD59x18 y);

/// @notice Thrown when raising a number to a power and the intermediary absolute result overflows SD59x18.
error PRBMath_SD59x18_Powu_Overflow(SD59x18 x, uint256 y);

/// @notice Thrown when taking the square root of a negative number.
error PRBMath_SD59x18_Sqrt_NegativeInput(SD59x18 x);

/// @notice Thrown when the calculating the square root overflows SD59x18.
error PRBMath_SD59x18_Sqrt_Overflow(SD59x18 x);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { wrap } from "./Casting.sol";
import { SD59x18 } from "./ValueType.sol";

/// @notice Implements the checked addition operation (+) in the SD59x18 type.
function add(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    return wrap(x.unwrap() + y.unwrap());
}

/// @notice Implements the AND (&) bitwise operation in the SD59x18 type.
function and(SD59x18 x, int256 bits) pure returns (SD59x18 result) {
    return wrap(x.unwrap() & bits);
}

/// @notice Implements the AND (&) bitwise operation in the SD59x18 type.
function and2(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    return wrap(x.unwrap() & y.unwrap());
}

/// @notice Implements the equal (=) operation in the SD59x18 type.
function eq(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = x.unwrap() == y.unwrap();
}

/// @notice Implements the greater than operation (>) in the SD59x18 type.
function gt(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = x.unwrap() > y.unwrap();
}

/// @notice Implements the greater than or equal to operation (>=) in the SD59x18 type.
function gte(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = x.unwrap() >= y.unwrap();
}

/// @notice Implements a zero comparison check function in the SD59x18 type.
function isZero(SD59x18 x) pure returns (bool result) {
    result = x.unwrap() == 0;
}

/// @notice Implements the left shift operation (<<) in the SD59x18 type.
function lshift(SD59x18 x, uint256 bits) pure returns (SD59x18 result) {
    result = wrap(x.unwrap() << bits);
}

/// @notice Implements the lower than operation (<) in the SD59x18 type.
function lt(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = x.unwrap() < y.unwrap();
}

/// @notice Implements the lower than or equal to operation (<=) in the SD59x18 type.
function lte(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = x.unwrap() <= y.unwrap();
}

/// @notice Implements the unchecked modulo operation (%) in the SD59x18 type.
function mod(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    result = wrap(x.unwrap() % y.unwrap());
}

/// @notice Implements the not equal operation (!=) in the SD59x18 type.
function neq(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = x.unwrap() != y.unwrap();
}

/// @notice Implements the NOT (~) bitwise operation in the SD59x18 type.
function not(SD59x18 x) pure returns (SD59x18 result) {
    result = wrap(~x.unwrap());
}

/// @notice Implements the OR (|) bitwise operation in the SD59x18 type.
function or(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    result = wrap(x.unwrap() | y.unwrap());
}

/// @notice Implements the right shift operation (>>) in the SD59x18 type.
function rshift(SD59x18 x, uint256 bits) pure returns (SD59x18 result) {
    result = wrap(x.unwrap() >> bits);
}

/// @notice Implements the checked subtraction operation (-) in the SD59x18 type.
function sub(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    result = wrap(x.unwrap() - y.unwrap());
}

/// @notice Implements the checked unary minus operation (-) in the SD59x18 type.
function unary(SD59x18 x) pure returns (SD59x18 result) {
    result = wrap(-x.unwrap());
}

/// @notice Implements the unchecked addition operation (+) in the SD59x18 type.
function uncheckedAdd(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    unchecked {
        result = wrap(x.unwrap() + y.unwrap());
    }
}

/// @notice Implements the unchecked subtraction operation (-) in the SD59x18 type.
function uncheckedSub(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    unchecked {
        result = wrap(x.unwrap() - y.unwrap());
    }
}

/// @notice Implements the unchecked unary minus operation (-) in the SD59x18 type.
function uncheckedUnary(SD59x18 x) pure returns (SD59x18 result) {
    unchecked {
        result = wrap(-x.unwrap());
    }
}

/// @notice Implements the XOR (^) bitwise operation in the SD59x18 type.
function xor(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    result = wrap(x.unwrap() ^ y.unwrap());
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "../Common.sol" as Common;
import "./Errors.sol" as Errors;
import {
    uEXP_MAX_INPUT,
    uEXP2_MAX_INPUT,
    uEXP_MIN_THRESHOLD,
    uEXP2_MIN_THRESHOLD,
    uHALF_UNIT,
    uLOG2_10,
    uLOG2_E,
    uMAX_SD59x18,
    uMAX_WHOLE_SD59x18,
    uMIN_SD59x18,
    uMIN_WHOLE_SD59x18,
    UNIT,
    uUNIT,
    uUNIT_SQUARED,
    ZERO
} from "./Constants.sol";
import { wrap } from "./Helpers.sol";
import { SD59x18 } from "./ValueType.sol";

/// @notice Calculates the absolute value of x.
///
/// @dev Requirements:
/// - x must be greater than `MIN_SD59x18`.
///
/// @param x The SD59x18 number for which to calculate the absolute value.
/// @param result The absolute value of x as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function abs(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    if (xInt == uMIN_SD59x18) {
        revert Errors.PRBMath_SD59x18_Abs_MinSD59x18();
    }
    result = xInt < 0 ? wrap(-xInt) : x;
}

/// @notice Calculates the arithmetic average of x and y.
///
/// @dev Notes:
/// - The result is rounded toward zero.
///
/// @param x The first operand as an SD59x18 number.
/// @param y The second operand as an SD59x18 number.
/// @return result The arithmetic average as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function avg(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    int256 yInt = y.unwrap();

    unchecked {
        // This operation is equivalent to `x / 2 +  y / 2`, and it can never overflow.
        int256 sum = (xInt >> 1) + (yInt >> 1);

        if (sum < 0) {
            // If at least one of x and y is odd, add 1 to the result, because shifting negative numbers to the right
            // rounds toward negative infinity. The right part is equivalent to `sum + (x % 2 == 1 || y % 2 == 1)`.
            assembly ("memory-safe") {
                result := add(sum, and(or(xInt, yInt), 1))
            }
        } else {
            // Add 1 if both x and y are odd to account for the double 0.5 remainder truncated after shifting.
            result = wrap(sum + (xInt & yInt & 1));
        }
    }
}

/// @notice Yields the smallest whole number greater than or equal to x.
///
/// @dev Optimized for fractional value inputs, because every whole value has (1e18 - 1) fractional counterparts.
/// See https://en.wikipedia.org/wiki/Floor_and_ceiling_functions.
///
/// Requirements:
/// - x must be less than or equal to `MAX_WHOLE_SD59x18`.
///
/// @param x The SD59x18 number to ceil.
/// @param result The smallest whole number greater than or equal to x, as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function ceil(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    if (xInt > uMAX_WHOLE_SD59x18) {
        revert Errors.PRBMath_SD59x18_Ceil_Overflow(x);
    }

    int256 remainder = xInt % uUNIT;
    if (remainder == 0) {
        result = x;
    } else {
        unchecked {
            // Solidity uses C fmod style, which returns a modulus with the same sign as x.
            int256 resultInt = xInt - remainder;
            if (xInt > 0) {
                resultInt += uUNIT;
            }
            result = wrap(resultInt);
        }
    }
}

/// @notice Divides two SD59x18 numbers, returning a new SD59x18 number.
///
/// @dev This is an extension of {Common.mulDiv} for signed numbers, which works by computing the signs and the absolute
/// values separately.
///
/// Notes:
/// - Refer to the notes in {Common.mulDiv}.
/// - The result is rounded toward zero.
///
/// Requirements:
/// - Refer to the requirements in {Common.mulDiv}.
/// - None of the inputs can be `MIN_SD59x18`.
/// - The denominator must not be zero.
/// - The result must fit in SD59x18.
///
/// @param x The numerator as an SD59x18 number.
/// @param y The denominator as an SD59x18 number.
/// @param result The quotient as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function div(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    int256 yInt = y.unwrap();
    if (xInt == uMIN_SD59x18 || yInt == uMIN_SD59x18) {
        revert Errors.PRBMath_SD59x18_Div_InputTooSmall();
    }

    // Get hold of the absolute values of x and y.
    uint256 xAbs;
    uint256 yAbs;
    unchecked {
        xAbs = xInt < 0 ? uint256(-xInt) : uint256(xInt);
        yAbs = yInt < 0 ? uint256(-yInt) : uint256(yInt);
    }

    // Compute the absolute value (x*UNIT÷y). The resulting value must fit in SD59x18.
    uint256 resultAbs = Common.mulDiv(xAbs, uint256(uUNIT), yAbs);
    if (resultAbs > uint256(uMAX_SD59x18)) {
        revert Errors.PRBMath_SD59x18_Div_Overflow(x, y);
    }

    // Check if x and y have the same sign using two's complement representation. The left-most bit represents the sign (1 for
    // negative, 0 for positive or zero).
    bool sameSign = (xInt ^ yInt) > -1;

    // If the inputs have the same sign, the result should be positive. Otherwise, it should be negative.
    unchecked {
        result = wrap(sameSign ? int256(resultAbs) : -int256(resultAbs));
    }
}

/// @notice Calculates the natural exponent of x using the following formula:
///
/// $$
/// e^x = 2^{x * log_2{e}}
/// $$
///
/// @dev Notes:
/// - Refer to the notes in {exp2}.
///
/// Requirements:
/// - Refer to the requirements in {exp2}.
/// - x must be less than 133_084258667509499441.
///
/// @param x The exponent as an SD59x18 number.
/// @return result The result as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function exp(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();

    // Any input less than the threshold returns zero.
    // This check also prevents an overflow for very small numbers.
    if (xInt < uEXP_MIN_THRESHOLD) {
        return ZERO;
    }

    // This check prevents values greater than 192e18 from being passed to {exp2}.
    if (xInt > uEXP_MAX_INPUT) {
        revert Errors.PRBMath_SD59x18_Exp_InputTooBig(x);
    }

    unchecked {
        // Inline the fixed-point multiplication to save gas.
        int256 doubleUnitProduct = xInt * uLOG2_E;
        result = exp2(wrap(doubleUnitProduct / uUNIT));
    }
}

/// @notice Calculates the binary exponent of x using the binary fraction method using the following formula:
///
/// $$
/// 2^{-x} = \frac{1}{2^x}
/// $$
///
/// @dev See https://ethereum.stackexchange.com/q/79903/24693.
///
/// Notes:
/// - If x is less than -59_794705707972522261, the result is zero.
///
/// Requirements:
/// - x must be less than 192e18.
/// - The result must fit in SD59x18.
///
/// @param x The exponent as an SD59x18 number.
/// @return result The result as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function exp2(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    if (xInt < 0) {
        // The inverse of any number less than the threshold is truncated to zero.
        if (xInt < uEXP2_MIN_THRESHOLD) {
            return ZERO;
        }

        unchecked {
            // Inline the fixed-point inversion to save gas.
            result = wrap(uUNIT_SQUARED / exp2(wrap(-xInt)).unwrap());
        }
    } else {
        // Numbers greater than or equal to 192e18 don't fit in the 192.64-bit format.
        if (xInt > uEXP2_MAX_INPUT) {
            revert Errors.PRBMath_SD59x18_Exp2_InputTooBig(x);
        }

        unchecked {
            // Convert x to the 192.64-bit fixed-point format.
            uint256 x_192x64 = uint256((xInt << 64) / uUNIT);

            // It is safe to cast the result to int256 due to the checks above.
            result = wrap(int256(Common.exp2(x_192x64)));
        }
    }
}

/// @notice Yields the greatest whole number less than or equal to x.
///
/// @dev Optimized for fractional value inputs, because for every whole value there are (1e18 - 1) fractional
/// counterparts. See https://en.wikipedia.org/wiki/Floor_and_ceiling_functions.
///
/// Requirements:
/// - x must be greater than or equal to `MIN_WHOLE_SD59x18`.
///
/// @param x The SD59x18 number to floor.
/// @param result The greatest whole number less than or equal to x, as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function floor(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    if (xInt < uMIN_WHOLE_SD59x18) {
        revert Errors.PRBMath_SD59x18_Floor_Underflow(x);
    }

    int256 remainder = xInt % uUNIT;
    if (remainder == 0) {
        result = x;
    } else {
        unchecked {
            // Solidity uses C fmod style, which returns a modulus with the same sign as x.
            int256 resultInt = xInt - remainder;
            if (xInt < 0) {
                resultInt -= uUNIT;
            }
            result = wrap(resultInt);
        }
    }
}

/// @notice Yields the excess beyond the floor of x for positive numbers and the part of the number to the right.
/// of the radix point for negative numbers.
/// @dev Based on the odd function definition. https://en.wikipedia.org/wiki/Fractional_part
/// @param x The SD59x18 number to get the fractional part of.
/// @param result The fractional part of x as an SD59x18 number.
function frac(SD59x18 x) pure returns (SD59x18 result) {
    result = wrap(x.unwrap() % uUNIT);
}

/// @notice Calculates the geometric mean of x and y, i.e. $\sqrt{x * y}$.
///
/// @dev Notes:
/// - The result is rounded toward zero.
///
/// Requirements:
/// - x * y must fit in SD59x18.
/// - x * y must not be negative, since complex numbers are not supported.
///
/// @param x The first operand as an SD59x18 number.
/// @param y The second operand as an SD59x18 number.
/// @return result The result as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function gm(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    int256 yInt = y.unwrap();
    if (xInt == 0 || yInt == 0) {
        return ZERO;
    }

    unchecked {
        // Equivalent to `xy / x != y`. Checking for overflow this way is faster than letting Solidity do it.
        int256 xyInt = xInt * yInt;
        if (xyInt / xInt != yInt) {
            revert Errors.PRBMath_SD59x18_Gm_Overflow(x, y);
        }

        // The product must not be negative, since complex numbers are not supported.
        if (xyInt < 0) {
            revert Errors.PRBMath_SD59x18_Gm_NegativeProduct(x, y);
        }

        // We don't need to multiply the result by `UNIT` here because the x*y product picked up a factor of `UNIT`
        // during multiplication. See the comments in {Common.sqrt}.
        uint256 resultUint = Common.sqrt(uint256(xyInt));
        result = wrap(int256(resultUint));
    }
}

/// @notice Calculates the inverse of x.
///
/// @dev Notes:
/// - The result is rounded toward zero.
///
/// Requirements:
/// - x must not be zero.
///
/// @param x The SD59x18 number for which to calculate the inverse.
/// @return result The inverse as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function inv(SD59x18 x) pure returns (SD59x18 result) {
    result = wrap(uUNIT_SQUARED / x.unwrap());
}

/// @notice Calculates the natural logarithm of x using the following formula:
///
/// $$
/// ln{x} = log_2{x} / log_2{e}
/// $$
///
/// @dev Notes:
/// - Refer to the notes in {log2}.
/// - The precision isn't sufficiently fine-grained to return exactly `UNIT` when the input is `E`.
///
/// Requirements:
/// - Refer to the requirements in {log2}.
///
/// @param x The SD59x18 number for which to calculate the natural logarithm.
/// @return result The natural logarithm as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function ln(SD59x18 x) pure returns (SD59x18 result) {
    // Inline the fixed-point multiplication to save gas. This is overflow-safe because the maximum value that
    // {log2} can return is ~195_205294292027477728.
    result = wrap(log2(x).unwrap() * uUNIT / uLOG2_E);
}

/// @notice Calculates the common logarithm of x using the following formula:
///
/// $$
/// log_{10}{x} = log_2{x} / log_2{10}
/// $$
///
/// However, if x is an exact power of ten, a hard coded value is returned.
///
/// @dev Notes:
/// - Refer to the notes in {log2}.
///
/// Requirements:
/// - Refer to the requirements in {log2}.
///
/// @param x The SD59x18 number for which to calculate the common logarithm.
/// @return result The common logarithm as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function log10(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    if (xInt < 0) {
        revert Errors.PRBMath_SD59x18_Log_InputTooSmall(x);
    }

    // Note that the `mul` in this block is the standard multiplication operation, not {SD59x18.mul}.
    // prettier-ignore
    assembly ("memory-safe") {
        switch x
        case 1 { result := mul(uUNIT, sub(0, 18)) }
        case 10 { result := mul(uUNIT, sub(1, 18)) }
        case 100 { result := mul(uUNIT, sub(2, 18)) }
        case 1000 { result := mul(uUNIT, sub(3, 18)) }
        case 10000 { result := mul(uUNIT, sub(4, 18)) }
        case 100000 { result := mul(uUNIT, sub(5, 18)) }
        case 1000000 { result := mul(uUNIT, sub(6, 18)) }
        case 10000000 { result := mul(uUNIT, sub(7, 18)) }
        case 100000000 { result := mul(uUNIT, sub(8, 18)) }
        case 1000000000 { result := mul(uUNIT, sub(9, 18)) }
        case 10000000000 { result := mul(uUNIT, sub(10, 18)) }
        case 100000000000 { result := mul(uUNIT, sub(11, 18)) }
        case 1000000000000 { result := mul(uUNIT, sub(12, 18)) }
        case 10000000000000 { result := mul(uUNIT, sub(13, 18)) }
        case 100000000000000 { result := mul(uUNIT, sub(14, 18)) }
        case 1000000000000000 { result := mul(uUNIT, sub(15, 18)) }
        case 10000000000000000 { result := mul(uUNIT, sub(16, 18)) }
        case 100000000000000000 { result := mul(uUNIT, sub(17, 18)) }
        case 1000000000000000000 { result := 0 }
        case 10000000000000000000 { result := uUNIT }
        case 100000000000000000000 { result := mul(uUNIT, 2) }
        case 1000000000000000000000 { result := mul(uUNIT, 3) }
        case 10000000000000000000000 { result := mul(uUNIT, 4) }
        case 100000000000000000000000 { result := mul(uUNIT, 5) }
        case 1000000000000000000000000 { result := mul(uUNIT, 6) }
        case 10000000000000000000000000 { result := mul(uUNIT, 7) }
        case 100000000000000000000000000 { result := mul(uUNIT, 8) }
        case 1000000000000000000000000000 { result := mul(uUNIT, 9) }
        case 10000000000000000000000000000 { result := mul(uUNIT, 10) }
        case 100000000000000000000000000000 { result := mul(uUNIT, 11) }
        case 1000000000000000000000000000000 { result := mul(uUNIT, 12) }
        case 10000000000000000000000000000000 { result := mul(uUNIT, 13) }
        case 100000000000000000000000000000000 { result := mul(uUNIT, 14) }
        case 1000000000000000000000000000000000 { result := mul(uUNIT, 15) }
        case 10000000000000000000000000000000000 { result := mul(uUNIT, 16) }
        case 100000000000000000000000000000000000 { result := mul(uUNIT, 17) }
        case 1000000000000000000000000000000000000 { result := mul(uUNIT, 18) }
        case 10000000000000000000000000000000000000 { result := mul(uUNIT, 19) }
        case 100000000000000000000000000000000000000 { result := mul(uUNIT, 20) }
        case 1000000000000000000000000000000000000000 { result := mul(uUNIT, 21) }
        case 10000000000000000000000000000000000000000 { result := mul(uUNIT, 22) }
        case 100000000000000000000000000000000000000000 { result := mul(uUNIT, 23) }
        case 1000000000000000000000000000000000000000000 { result := mul(uUNIT, 24) }
        case 10000000000000000000000000000000000000000000 { result := mul(uUNIT, 25) }
        case 100000000000000000000000000000000000000000000 { result := mul(uUNIT, 26) }
        case 1000000000000000000000000000000000000000000000 { result := mul(uUNIT, 27) }
        case 10000000000000000000000000000000000000000000000 { result := mul(uUNIT, 28) }
        case 100000000000000000000000000000000000000000000000 { result := mul(uUNIT, 29) }
        case 1000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 30) }
        case 10000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 31) }
        case 100000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 32) }
        case 1000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 33) }
        case 10000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 34) }
        case 100000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 35) }
        case 1000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 36) }
        case 10000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 37) }
        case 100000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 38) }
        case 1000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 39) }
        case 10000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 40) }
        case 100000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 41) }
        case 1000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 42) }
        case 10000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 43) }
        case 100000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 44) }
        case 1000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 45) }
        case 10000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 46) }
        case 100000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 47) }
        case 1000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 48) }
        case 10000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 49) }
        case 100000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 50) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 51) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 52) }
        case 100000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 53) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 54) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 55) }
        case 100000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 56) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 57) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 58) }
        default { result := uMAX_SD59x18 }
    }

    if (result.unwrap() == uMAX_SD59x18) {
        unchecked {
            // Inline the fixed-point division to save gas.
            result = wrap(log2(x).unwrap() * uUNIT / uLOG2_10);
        }
    }
}

/// @notice Calculates the binary logarithm of x using the iterative approximation algorithm:
///
/// $$
/// log_2{x} = n + log_2{y}, \text{ where } y = x*2^{-n}, \ y \in [1, 2)
/// $$
///
/// For $0 \leq x \lt 1$, the input is inverted:
///
/// $$
/// log_2{x} = -log_2{\frac{1}{x}}
/// $$
///
/// @dev See https://en.wikipedia.org/wiki/Binary_logarithm#Iterative_approximation.
///
/// Notes:
/// - Due to the lossy precision of the iterative approximation, the results are not perfectly accurate to the last decimal.
///
/// Requirements:
/// - x must be greater than zero.
///
/// @param x The SD59x18 number for which to calculate the binary logarithm.
/// @return result The binary logarithm as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function log2(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    if (xInt <= 0) {
        revert Errors.PRBMath_SD59x18_Log_InputTooSmall(x);
    }

    unchecked {
        int256 sign;
        if (xInt >= uUNIT) {
            sign = 1;
        } else {
            sign = -1;
            // Inline the fixed-point inversion to save gas.
            xInt = uUNIT_SQUARED / xInt;
        }

        // Calculate the integer part of the logarithm.
        uint256 n = Common.msb(uint256(xInt / uUNIT));

        // This is the integer part of the logarithm as an SD59x18 number. The operation can't overflow
        // because n is at most 255, `UNIT` is 1e18, and the sign is either 1 or -1.
        int256 resultInt = int256(n) * uUNIT;

        // Calculate $y = x * 2^{-n}$.
        int256 y = xInt >> n;

        // If y is the unit number, the fractional part is zero.
        if (y == uUNIT) {
            return wrap(resultInt * sign);
        }

        // Calculate the fractional part via the iterative approximation.
        // The `delta >>= 1` part is equivalent to `delta /= 2`, but shifting bits is more gas efficient.
        int256 DOUBLE_UNIT = 2e18;
        for (int256 delta = uHALF_UNIT; delta > 0; delta >>= 1) {
            y = (y * y) / uUNIT;

            // Is y^2 >= 2e18 and so in the range [2e18, 4e18)?
            if (y >= DOUBLE_UNIT) {
                // Add the 2^{-m} factor to the logarithm.
                resultInt = resultInt + delta;

                // Halve y, which corresponds to z/2 in the Wikipedia article.
                y >>= 1;
            }
        }
        resultInt *= sign;
        result = wrap(resultInt);
    }
}

/// @notice Multiplies two SD59x18 numbers together, returning a new SD59x18 number.
///
/// @dev Notes:
/// - Refer to the notes in {Common.mulDiv18}.
///
/// Requirements:
/// - Refer to the requirements in {Common.mulDiv18}.
/// - None of the inputs can be `MIN_SD59x18`.
/// - The result must fit in SD59x18.
///
/// @param x The multiplicand as an SD59x18 number.
/// @param y The multiplier as an SD59x18 number.
/// @return result The product as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function mul(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    int256 yInt = y.unwrap();
    if (xInt == uMIN_SD59x18 || yInt == uMIN_SD59x18) {
        revert Errors.PRBMath_SD59x18_Mul_InputTooSmall();
    }

    // Get hold of the absolute values of x and y.
    uint256 xAbs;
    uint256 yAbs;
    unchecked {
        xAbs = xInt < 0 ? uint256(-xInt) : uint256(xInt);
        yAbs = yInt < 0 ? uint256(-yInt) : uint256(yInt);
    }

    // Compute the absolute value (x*y÷UNIT). The resulting value must fit in SD59x18.
    uint256 resultAbs = Common.mulDiv18(xAbs, yAbs);
    if (resultAbs > uint256(uMAX_SD59x18)) {
        revert Errors.PRBMath_SD59x18_Mul_Overflow(x, y);
    }

    // Check if x and y have the same sign using two's complement representation. The left-most bit represents the sign (1 for
    // negative, 0 for positive or zero).
    bool sameSign = (xInt ^ yInt) > -1;

    // If the inputs have the same sign, the result should be positive. Otherwise, it should be negative.
    unchecked {
        result = wrap(sameSign ? int256(resultAbs) : -int256(resultAbs));
    }
}

/// @notice Raises x to the power of y using the following formula:
///
/// $$
/// x^y = 2^{log_2{x} * y}
/// $$
///
/// @dev Notes:
/// - Refer to the notes in {exp2}, {log2}, and {mul}.
/// - Returns `UNIT` for 0^0.
///
/// Requirements:
/// - Refer to the requirements in {exp2}, {log2}, and {mul}.
///
/// @param x The base as an SD59x18 number.
/// @param y Exponent to raise x to, as an SD59x18 number
/// @return result x raised to power y, as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function pow(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    int256 yInt = y.unwrap();

    // If both x and y are zero, the result is `UNIT`. If just x is zero, the result is always zero.
    if (xInt == 0) {
        return yInt == 0 ? UNIT : ZERO;
    }
    // If x is `UNIT`, the result is always `UNIT`.
    else if (xInt == uUNIT) {
        return UNIT;
    }

    // If y is zero, the result is always `UNIT`.
    if (yInt == 0) {
        return UNIT;
    }
    // If y is `UNIT`, the result is always x.
    else if (yInt == uUNIT) {
        return x;
    }

    // Calculate the result using the formula.
    result = exp2(mul(log2(x), y));
}

/// @notice Raises x (an SD59x18 number) to the power y (an unsigned basic integer) using the well-known
/// algorithm "exponentiation by squaring".
///
/// @dev See https://en.wikipedia.org/wiki/Exponentiation_by_squaring.
///
/// Notes:
/// - Refer to the notes in {Common.mulDiv18}.
/// - Returns `UNIT` for 0^0.
///
/// Requirements:
/// - Refer to the requirements in {abs} and {Common.mulDiv18}.
/// - The result must fit in SD59x18.
///
/// @param x The base as an SD59x18 number.
/// @param y The exponent as a uint256.
/// @return result The result as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function powu(SD59x18 x, uint256 y) pure returns (SD59x18 result) {
    uint256 xAbs = uint256(abs(x).unwrap());

    // Calculate the first iteration of the loop in advance.
    uint256 resultAbs = y & 1 > 0 ? xAbs : uint256(uUNIT);

    // Equivalent to `for(y /= 2; y > 0; y /= 2)`.
    uint256 yAux = y;
    for (yAux >>= 1; yAux > 0; yAux >>= 1) {
        xAbs = Common.mulDiv18(xAbs, xAbs);

        // Equivalent to `y % 2 == 1`.
        if (yAux & 1 > 0) {
            resultAbs = Common.mulDiv18(resultAbs, xAbs);
        }
    }

    // The result must fit in SD59x18.
    if (resultAbs > uint256(uMAX_SD59x18)) {
        revert Errors.PRBMath_SD59x18_Powu_Overflow(x, y);
    }

    unchecked {
        // Is the base negative and the exponent odd? If yes, the result should be negative.
        int256 resultInt = int256(resultAbs);
        bool isNegative = x.unwrap() < 0 && y & 1 == 1;
        if (isNegative) {
            resultInt = -resultInt;
        }
        result = wrap(resultInt);
    }
}

/// @notice Calculates the square root of x using the Babylonian method.
///
/// @dev See https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method.
///
/// Notes:
/// - Only the positive root is returned.
/// - The result is rounded toward zero.
///
/// Requirements:
/// - x cannot be negative, since complex numbers are not supported.
/// - x must be less than `MAX_SD59x18 / UNIT`.
///
/// @param x The SD59x18 number for which to calculate the square root.
/// @return result The result as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function sqrt(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    if (xInt < 0) {
        revert Errors.PRBMath_SD59x18_Sqrt_NegativeInput(x);
    }
    if (xInt > uMAX_SD59x18 / uUNIT) {
        revert Errors.PRBMath_SD59x18_Sqrt_Overflow(x);
    }

    unchecked {
        // Multiply x by `UNIT` to account for the factor of `UNIT` picked up when multiplying two SD59x18 numbers.
        // In this case, the two numbers are both the square root.
        uint256 resultUint = Common.sqrt(uint256(xInt * uUNIT));
        result = wrap(int256(resultUint));
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "./Casting.sol" as Casting;
import "./Helpers.sol" as Helpers;
import "./Math.sol" as Math;

/// @notice The signed 59.18-decimal fixed-point number representation, which can have up to 59 digits and up to 18
/// decimals. The values of this are bound by the minimum and the maximum values permitted by the underlying Solidity
/// type int256.
type SD59x18 is int256;

/*//////////////////////////////////////////////////////////////////////////
                                    CASTING
//////////////////////////////////////////////////////////////////////////*/

using {
    Casting.intoInt256,
    Casting.intoSD1x18,
    Casting.intoUD2x18,
    Casting.intoUD60x18,
    Casting.intoUint256,
    Casting.intoUint128,
    Casting.intoUint40,
    Casting.unwrap
} for SD59x18 global;

/*//////////////////////////////////////////////////////////////////////////
                            MATHEMATICAL FUNCTIONS
//////////////////////////////////////////////////////////////////////////*/

using {
    Math.abs,
    Math.avg,
    Math.ceil,
    Math.div,
    Math.exp,
    Math.exp2,
    Math.floor,
    Math.frac,
    Math.gm,
    Math.inv,
    Math.log10,
    Math.log2,
    Math.ln,
    Math.mul,
    Math.pow,
    Math.powu,
    Math.sqrt
} for SD59x18 global;

/*//////////////////////////////////////////////////////////////////////////
                                HELPER FUNCTIONS
//////////////////////////////////////////////////////////////////////////*/

using {
    Helpers.add,
    Helpers.and,
    Helpers.eq,
    Helpers.gt,
    Helpers.gte,
    Helpers.isZero,
    Helpers.lshift,
    Helpers.lt,
    Helpers.lte,
    Helpers.mod,
    Helpers.neq,
    Helpers.not,
    Helpers.or,
    Helpers.rshift,
    Helpers.sub,
    Helpers.uncheckedAdd,
    Helpers.uncheckedSub,
    Helpers.uncheckedUnary,
    Helpers.xor
} for SD59x18 global;

/*//////////////////////////////////////////////////////////////////////////
                                    OPERATORS
//////////////////////////////////////////////////////////////////////////*/

// The global "using for" directive makes it possible to use these operators on the SD59x18 type.
using {
    Helpers.add as +,
    Helpers.and2 as &,
    Math.div as /,
    Helpers.eq as ==,
    Helpers.gt as >,
    Helpers.gte as >=,
    Helpers.lt as <,
    Helpers.lte as <=,
    Helpers.mod as %,
    Math.mul as *,
    Helpers.neq as !=,
    Helpers.not as ~,
    Helpers.or as |,
    Helpers.sub as -,
    Helpers.unary as -,
    Helpers.xor as ^
} for SD59x18 global;
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "../Common.sol" as Common;
import "./Errors.sol" as Errors;
import { uMAX_SD1x18 } from "../sd1x18/Constants.sol";
import { SD1x18 } from "../sd1x18/ValueType.sol";
import { SD59x18 } from "../sd59x18/ValueType.sol";
import { UD60x18 } from "../ud60x18/ValueType.sol";
import { UD2x18 } from "./ValueType.sol";

/// @notice Casts a UD2x18 number into SD1x18.
/// - x must be less than or equal to `uMAX_SD1x18`.
function intoSD1x18(UD2x18 x) pure returns (SD1x18 result) {
    uint64 xUint = UD2x18.unwrap(x);
    if (xUint > uint64(uMAX_SD1x18)) {
        revert Errors.PRBMath_UD2x18_IntoSD1x18_Overflow(x);
    }
    result = SD1x18.wrap(int64(xUint));
}

/// @notice Casts a UD2x18 number into SD59x18.
/// @dev There is no overflow check because the domain of UD2x18 is a subset of SD59x18.
function intoSD59x18(UD2x18 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(int256(uint256(UD2x18.unwrap(x))));
}

/// @notice Casts a UD2x18 number into UD60x18.
/// @dev There is no overflow check because the domain of UD2x18 is a subset of UD60x18.
function intoUD60x18(UD2x18 x) pure returns (UD60x18 result) {
    result = UD60x18.wrap(UD2x18.unwrap(x));
}

/// @notice Casts a UD2x18 number into uint128.
/// @dev There is no overflow check because the domain of UD2x18 is a subset of uint128.
function intoUint128(UD2x18 x) pure returns (uint128 result) {
    result = uint128(UD2x18.unwrap(x));
}

/// @notice Casts a UD2x18 number into uint256.
/// @dev There is no overflow check because the domain of UD2x18 is a subset of uint256.
function intoUint256(UD2x18 x) pure returns (uint256 result) {
    result = uint256(UD2x18.unwrap(x));
}

/// @notice Casts a UD2x18 number into uint40.
/// @dev Requirements:
/// - x must be less than or equal to `MAX_UINT40`.
function intoUint40(UD2x18 x) pure returns (uint40 result) {
    uint64 xUint = UD2x18.unwrap(x);
    if (xUint > uint64(Common.MAX_UINT40)) {
        revert Errors.PRBMath_UD2x18_IntoUint40_Overflow(x);
    }
    result = uint40(xUint);
}

/// @notice Alias for {wrap}.
function ud2x18(uint64 x) pure returns (UD2x18 result) {
    result = UD2x18.wrap(x);
}

/// @notice Unwrap a UD2x18 number into uint64.
function unwrap(UD2x18 x) pure returns (uint64 result) {
    result = UD2x18.unwrap(x);
}

/// @notice Wraps a uint64 number into UD2x18.
function wrap(uint64 x) pure returns (UD2x18 result) {
    result = UD2x18.wrap(x);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { UD2x18 } from "./ValueType.sol";

/// @dev Euler's number as a UD2x18 number.
UD2x18 constant E = UD2x18.wrap(2_718281828459045235);

/// @dev The maximum value a UD2x18 number can have.
uint64 constant uMAX_UD2x18 = 18_446744073709551615;
UD2x18 constant MAX_UD2x18 = UD2x18.wrap(uMAX_UD2x18);

/// @dev PI as a UD2x18 number.
UD2x18 constant PI = UD2x18.wrap(3_141592653589793238);

/// @dev The unit number, which gives the decimal precision of UD2x18.
UD2x18 constant UNIT = UD2x18.wrap(1e18);
uint64 constant uUNIT = 1e18;
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { UD2x18 } from "./ValueType.sol";

/// @notice Thrown when trying to cast a UD2x18 number that doesn't fit in SD1x18.
error PRBMath_UD2x18_IntoSD1x18_Overflow(UD2x18 x);

/// @notice Thrown when trying to cast a UD2x18 number that doesn't fit in uint40.
error PRBMath_UD2x18_IntoUint40_Overflow(UD2x18 x);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "./Casting.sol" as Casting;

/// @notice The unsigned 2.18-decimal fixed-point number representation, which can have up to 2 digits and up to 18
/// decimals. The values of this are bound by the minimum and the maximum values permitted by the underlying Solidity
/// type uint64. This is useful when end users want to use uint64 to save gas, e.g. with tight variable packing in contract
/// storage.
type UD2x18 is uint64;

/*//////////////////////////////////////////////////////////////////////////
                                    CASTING
//////////////////////////////////////////////////////////////////////////*/

using {
    Casting.intoSD1x18,
    Casting.intoSD59x18,
    Casting.intoUD60x18,
    Casting.intoUint256,
    Casting.intoUint128,
    Casting.intoUint40,
    Casting.unwrap
} for UD2x18 global;
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "./Errors.sol" as CastingErrors;
import { MAX_UINT128, MAX_UINT40 } from "../Common.sol";
import { uMAX_SD1x18 } from "../sd1x18/Constants.sol";
import { SD1x18 } from "../sd1x18/ValueType.sol";
import { uMAX_SD59x18 } from "../sd59x18/Constants.sol";
import { SD59x18 } from "../sd59x18/ValueType.sol";
import { uMAX_UD2x18 } from "../ud2x18/Constants.sol";
import { UD2x18 } from "../ud2x18/ValueType.sol";
import { UD60x18 } from "./ValueType.sol";

/// @notice Casts a UD60x18 number into SD1x18.
/// @dev Requirements:
/// - x must be less than or equal to `uMAX_SD1x18`.
function intoSD1x18(UD60x18 x) pure returns (SD1x18 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > uint256(int256(uMAX_SD1x18))) {
        revert CastingErrors.PRBMath_UD60x18_IntoSD1x18_Overflow(x);
    }
    result = SD1x18.wrap(int64(uint64(xUint)));
}

/// @notice Casts a UD60x18 number into UD2x18.
/// @dev Requirements:
/// - x must be less than or equal to `uMAX_UD2x18`.
function intoUD2x18(UD60x18 x) pure returns (UD2x18 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > uMAX_UD2x18) {
        revert CastingErrors.PRBMath_UD60x18_IntoUD2x18_Overflow(x);
    }
    result = UD2x18.wrap(uint64(xUint));
}

/// @notice Casts a UD60x18 number into SD59x18.
/// @dev Requirements:
/// - x must be less than or equal to `uMAX_SD59x18`.
function intoSD59x18(UD60x18 x) pure returns (SD59x18 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > uint256(uMAX_SD59x18)) {
        revert CastingErrors.PRBMath_UD60x18_IntoSD59x18_Overflow(x);
    }
    result = SD59x18.wrap(int256(xUint));
}

/// @notice Casts a UD60x18 number into uint128.
/// @dev This is basically an alias for {unwrap}.
function intoUint256(UD60x18 x) pure returns (uint256 result) {
    result = UD60x18.unwrap(x);
}

/// @notice Casts a UD60x18 number into uint128.
/// @dev Requirements:
/// - x must be less than or equal to `MAX_UINT128`.
function intoUint128(UD60x18 x) pure returns (uint128 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > MAX_UINT128) {
        revert CastingErrors.PRBMath_UD60x18_IntoUint128_Overflow(x);
    }
    result = uint128(xUint);
}

/// @notice Casts a UD60x18 number into uint40.
/// @dev Requirements:
/// - x must be less than or equal to `MAX_UINT40`.
function intoUint40(UD60x18 x) pure returns (uint40 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > MAX_UINT40) {
        revert CastingErrors.PRBMath_UD60x18_IntoUint40_Overflow(x);
    }
    result = uint40(xUint);
}

/// @notice Alias for {wrap}.
function ud(uint256 x) pure returns (UD60x18 result) {
    result = UD60x18.wrap(x);
}

/// @notice Alias for {wrap}.
function ud60x18(uint256 x) pure returns (UD60x18 result) {
    result = UD60x18.wrap(x);
}

/// @notice Unwraps a UD60x18 number into uint256.
function unwrap(UD60x18 x) pure returns (uint256 result) {
    result = UD60x18.unwrap(x);
}

/// @notice Wraps a uint256 number into the UD60x18 value type.
function wrap(uint256 x) pure returns (UD60x18 result) {
    result = UD60x18.wrap(x);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { UD60x18 } from "./ValueType.sol";

// NOTICE: the "u" prefix stands for "unwrapped".

/// @dev Euler's number as a UD60x18 number.
UD60x18 constant E = UD60x18.wrap(2_718281828459045235);

/// @dev The maximum input permitted in {exp}.
uint256 constant uEXP_MAX_INPUT = 133_084258667509499440;
UD60x18 constant EXP_MAX_INPUT = UD60x18.wrap(uEXP_MAX_INPUT);

/// @dev The maximum input permitted in {exp2}.
uint256 constant uEXP2_MAX_INPUT = 192e18 - 1;
UD60x18 constant EXP2_MAX_INPUT = UD60x18.wrap(uEXP2_MAX_INPUT);

/// @dev Half the UNIT number.
uint256 constant uHALF_UNIT = 0.5e18;
UD60x18 constant HALF_UNIT = UD60x18.wrap(uHALF_UNIT);

/// @dev $log_2(10)$ as a UD60x18 number.
uint256 constant uLOG2_10 = 3_321928094887362347;
UD60x18 constant LOG2_10 = UD60x18.wrap(uLOG2_10);

/// @dev $log_2(e)$ as a UD60x18 number.
uint256 constant uLOG2_E = 1_442695040888963407;
UD60x18 constant LOG2_E = UD60x18.wrap(uLOG2_E);

/// @dev The maximum value a UD60x18 number can have.
uint256 constant uMAX_UD60x18 = 115792089237316195423570985008687907853269984665640564039457_584007913129639935;
UD60x18 constant MAX_UD60x18 = UD60x18.wrap(uMAX_UD60x18);

/// @dev The maximum whole value a UD60x18 number can have.
uint256 constant uMAX_WHOLE_UD60x18 = 115792089237316195423570985008687907853269984665640564039457_000000000000000000;
UD60x18 constant MAX_WHOLE_UD60x18 = UD60x18.wrap(uMAX_WHOLE_UD60x18);

/// @dev PI as a UD60x18 number.
UD60x18 constant PI = UD60x18.wrap(3_141592653589793238);

/// @dev The unit number, which gives the decimal precision of UD60x18.
uint256 constant uUNIT = 1e18;
UD60x18 constant UNIT = UD60x18.wrap(uUNIT);

/// @dev The unit number squared.
uint256 constant uUNIT_SQUARED = 1e36;
UD60x18 constant UNIT_SQUARED = UD60x18.wrap(uUNIT_SQUARED);

/// @dev Zero as a UD60x18 number.
UD60x18 constant ZERO = UD60x18.wrap(0);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { uMAX_UD60x18, uUNIT } from "./Constants.sol";
import { PRBMath_UD60x18_Convert_Overflow } from "./Errors.sol";
import { UD60x18 } from "./ValueType.sol";

/// @notice Converts a UD60x18 number to a simple integer by dividing it by `UNIT`.
/// @dev The result is rounded toward zero.
/// @param x The UD60x18 number to convert.
/// @return result The same number in basic integer form.
function convert(UD60x18 x) pure returns (uint256 result) {
    result = UD60x18.unwrap(x) / uUNIT;
}

/// @notice Converts a simple integer to UD60x18 by multiplying it by `UNIT`.
///
/// @dev Requirements:
/// - x must be less than or equal to `MAX_UD60x18 / UNIT`.
///
/// @param x The basic integer to convert.
/// @param result The same number converted to UD60x18.
function convert(uint256 x) pure returns (UD60x18 result) {
    if (x > uMAX_UD60x18 / uUNIT) {
        revert PRBMath_UD60x18_Convert_Overflow(x);
    }
    unchecked {
        result = UD60x18.wrap(x * uUNIT);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { UD60x18 } from "./ValueType.sol";

/// @notice Thrown when ceiling a number overflows UD60x18.
error PRBMath_UD60x18_Ceil_Overflow(UD60x18 x);

/// @notice Thrown when converting a basic integer to the fixed-point format overflows UD60x18.
error PRBMath_UD60x18_Convert_Overflow(uint256 x);

/// @notice Thrown when taking the natural exponent of a base greater than 133_084258667509499441.
error PRBMath_UD60x18_Exp_InputTooBig(UD60x18 x);

/// @notice Thrown when taking the binary exponent of a base greater than 192e18.
error PRBMath_UD60x18_Exp2_InputTooBig(UD60x18 x);

/// @notice Thrown when taking the geometric mean of two numbers and multiplying them overflows UD60x18.
error PRBMath_UD60x18_Gm_Overflow(UD60x18 x, UD60x18 y);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in SD1x18.
error PRBMath_UD60x18_IntoSD1x18_Overflow(UD60x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in SD59x18.
error PRBMath_UD60x18_IntoSD59x18_Overflow(UD60x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in UD2x18.
error PRBMath_UD60x18_IntoUD2x18_Overflow(UD60x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in uint128.
error PRBMath_UD60x18_IntoUint128_Overflow(UD60x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in uint40.
error PRBMath_UD60x18_IntoUint40_Overflow(UD60x18 x);

/// @notice Thrown when taking the logarithm of a number less than 1.
error PRBMath_UD60x18_Log_InputTooSmall(UD60x18 x);

/// @notice Thrown when calculating the square root overflows UD60x18.
error PRBMath_UD60x18_Sqrt_Overflow(UD60x18 x);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { wrap } from "./Casting.sol";
import { UD60x18 } from "./ValueType.sol";

/// @notice Implements the checked addition operation (+) in the UD60x18 type.
function add(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() + y.unwrap());
}

/// @notice Implements the AND (&) bitwise operation in the UD60x18 type.
function and(UD60x18 x, uint256 bits) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() & bits);
}

/// @notice Implements the AND (&) bitwise operation in the UD60x18 type.
function and2(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() & y.unwrap());
}

/// @notice Implements the equal operation (==) in the UD60x18 type.
function eq(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = x.unwrap() == y.unwrap();
}

/// @notice Implements the greater than operation (>) in the UD60x18 type.
function gt(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = x.unwrap() > y.unwrap();
}

/// @notice Implements the greater than or equal to operation (>=) in the UD60x18 type.
function gte(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = x.unwrap() >= y.unwrap();
}

/// @notice Implements a zero comparison check function in the UD60x18 type.
function isZero(UD60x18 x) pure returns (bool result) {
    // This wouldn't work if x could be negative.
    result = x.unwrap() == 0;
}

/// @notice Implements the left shift operation (<<) in the UD60x18 type.
function lshift(UD60x18 x, uint256 bits) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() << bits);
}

/// @notice Implements the lower than operation (<) in the UD60x18 type.
function lt(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = x.unwrap() < y.unwrap();
}

/// @notice Implements the lower than or equal to operation (<=) in the UD60x18 type.
function lte(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = x.unwrap() <= y.unwrap();
}

/// @notice Implements the checked modulo operation (%) in the UD60x18 type.
function mod(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() % y.unwrap());
}

/// @notice Implements the not equal operation (!=) in the UD60x18 type.
function neq(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = x.unwrap() != y.unwrap();
}

/// @notice Implements the NOT (~) bitwise operation in the UD60x18 type.
function not(UD60x18 x) pure returns (UD60x18 result) {
    result = wrap(~x.unwrap());
}

/// @notice Implements the OR (|) bitwise operation in the UD60x18 type.
function or(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() | y.unwrap());
}

/// @notice Implements the right shift operation (>>) in the UD60x18 type.
function rshift(UD60x18 x, uint256 bits) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() >> bits);
}

/// @notice Implements the checked subtraction operation (-) in the UD60x18 type.
function sub(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() - y.unwrap());
}

/// @notice Implements the unchecked addition operation (+) in the UD60x18 type.
function uncheckedAdd(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    unchecked {
        result = wrap(x.unwrap() + y.unwrap());
    }
}

/// @notice Implements the unchecked subtraction operation (-) in the UD60x18 type.
function uncheckedSub(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    unchecked {
        result = wrap(x.unwrap() - y.unwrap());
    }
}

/// @notice Implements the XOR (^) bitwise operation in the UD60x18 type.
function xor(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() ^ y.unwrap());
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "../Common.sol" as Common;
import "./Errors.sol" as Errors;
import { wrap } from "./Casting.sol";
import {
    uEXP_MAX_INPUT,
    uEXP2_MAX_INPUT,
    uHALF_UNIT,
    uLOG2_10,
    uLOG2_E,
    uMAX_UD60x18,
    uMAX_WHOLE_UD60x18,
    UNIT,
    uUNIT,
    uUNIT_SQUARED,
    ZERO
} from "./Constants.sol";
import { UD60x18 } from "./ValueType.sol";

/*//////////////////////////////////////////////////////////////////////////
                            MATHEMATICAL FUNCTIONS
//////////////////////////////////////////////////////////////////////////*/

/// @notice Calculates the arithmetic average of x and y using the following formula:
///
/// $$
/// avg(x, y) = (x & y) + ((xUint ^ yUint) / 2)
/// $$
///
/// In English, this is what this formula does:
///
/// 1. AND x and y.
/// 2. Calculate half of XOR x and y.
/// 3. Add the two results together.
///
/// This technique is known as SWAR, which stands for "SIMD within a register". You can read more about it here:
/// https://devblogs.microsoft.com/oldnewthing/20220207-00/?p=106223
///
/// @dev Notes:
/// - The result is rounded toward zero.
///
/// @param x The first operand as a UD60x18 number.
/// @param y The second operand as a UD60x18 number.
/// @return result The arithmetic average as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function avg(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();
    uint256 yUint = y.unwrap();
    unchecked {
        result = wrap((xUint & yUint) + ((xUint ^ yUint) >> 1));
    }
}

/// @notice Yields the smallest whole number greater than or equal to x.
///
/// @dev This is optimized for fractional value inputs, because for every whole value there are (1e18 - 1) fractional
/// counterparts. See https://en.wikipedia.org/wiki/Floor_and_ceiling_functions.
///
/// Requirements:
/// - x must be less than or equal to `MAX_WHOLE_UD60x18`.
///
/// @param x The UD60x18 number to ceil.
/// @param result The smallest whole number greater than or equal to x, as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function ceil(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();
    if (xUint > uMAX_WHOLE_UD60x18) {
        revert Errors.PRBMath_UD60x18_Ceil_Overflow(x);
    }

    assembly ("memory-safe") {
        // Equivalent to `x % UNIT`.
        let remainder := mod(x, uUNIT)

        // Equivalent to `UNIT - remainder`.
        let delta := sub(uUNIT, remainder)

        // Equivalent to `x + remainder > 0 ? delta : 0`.
        result := add(x, mul(delta, gt(remainder, 0)))
    }
}

/// @notice Divides two UD60x18 numbers, returning a new UD60x18 number.
///
/// @dev Uses {Common.mulDiv} to enable overflow-safe multiplication and division.
///
/// Notes:
/// - Refer to the notes in {Common.mulDiv}.
///
/// Requirements:
/// - Refer to the requirements in {Common.mulDiv}.
///
/// @param x The numerator as a UD60x18 number.
/// @param y The denominator as a UD60x18 number.
/// @param result The quotient as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function div(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(Common.mulDiv(x.unwrap(), uUNIT, y.unwrap()));
}

/// @notice Calculates the natural exponent of x using the following formula:
///
/// $$
/// e^x = 2^{x * log_2{e}}
/// $$
///
/// @dev Requirements:
/// - x must be less than 133_084258667509499441.
///
/// @param x The exponent as a UD60x18 number.
/// @return result The result as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function exp(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();

    // This check prevents values greater than 192e18 from being passed to {exp2}.
    if (xUint > uEXP_MAX_INPUT) {
        revert Errors.PRBMath_UD60x18_Exp_InputTooBig(x);
    }

    unchecked {
        // Inline the fixed-point multiplication to save gas.
        uint256 doubleUnitProduct = xUint * uLOG2_E;
        result = exp2(wrap(doubleUnitProduct / uUNIT));
    }
}

/// @notice Calculates the binary exponent of x using the binary fraction method.
///
/// @dev See https://ethereum.stackexchange.com/q/79903/24693
///
/// Requirements:
/// - x must be less than 192e18.
/// - The result must fit in UD60x18.
///
/// @param x The exponent as a UD60x18 number.
/// @return result The result as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function exp2(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();

    // Numbers greater than or equal to 192e18 don't fit in the 192.64-bit format.
    if (xUint > uEXP2_MAX_INPUT) {
        revert Errors.PRBMath_UD60x18_Exp2_InputTooBig(x);
    }

    // Convert x to the 192.64-bit fixed-point format.
    uint256 x_192x64 = (xUint << 64) / uUNIT;

    // Pass x to the {Common.exp2} function, which uses the 192.64-bit fixed-point number representation.
    result = wrap(Common.exp2(x_192x64));
}

/// @notice Yields the greatest whole number less than or equal to x.
/// @dev Optimized for fractional value inputs, because every whole value has (1e18 - 1) fractional counterparts.
/// See https://en.wikipedia.org/wiki/Floor_and_ceiling_functions.
/// @param x The UD60x18 number to floor.
/// @param result The greatest whole number less than or equal to x, as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function floor(UD60x18 x) pure returns (UD60x18 result) {
    assembly ("memory-safe") {
        // Equivalent to `x % UNIT`.
        let remainder := mod(x, uUNIT)

        // Equivalent to `x - remainder > 0 ? remainder : 0)`.
        result := sub(x, mul(remainder, gt(remainder, 0)))
    }
}

/// @notice Yields the excess beyond the floor of x using the odd function definition.
/// @dev See https://en.wikipedia.org/wiki/Fractional_part.
/// @param x The UD60x18 number to get the fractional part of.
/// @param result The fractional part of x as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function frac(UD60x18 x) pure returns (UD60x18 result) {
    assembly ("memory-safe") {
        result := mod(x, uUNIT)
    }
}

/// @notice Calculates the geometric mean of x and y, i.e. $\sqrt{x * y}$, rounding down.
///
/// @dev Requirements:
/// - x * y must fit in UD60x18.
///
/// @param x The first operand as a UD60x18 number.
/// @param y The second operand as a UD60x18 number.
/// @return result The result as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function gm(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();
    uint256 yUint = y.unwrap();
    if (xUint == 0 || yUint == 0) {
        return ZERO;
    }

    unchecked {
        // Checking for overflow this way is faster than letting Solidity do it.
        uint256 xyUint = xUint * yUint;
        if (xyUint / xUint != yUint) {
            revert Errors.PRBMath_UD60x18_Gm_Overflow(x, y);
        }

        // We don't need to multiply the result by `UNIT` here because the x*y product picked up a factor of `UNIT`
        // during multiplication. See the comments in {Common.sqrt}.
        result = wrap(Common.sqrt(xyUint));
    }
}

/// @notice Calculates the inverse of x.
///
/// @dev Notes:
/// - The result is rounded toward zero.
///
/// Requirements:
/// - x must not be zero.
///
/// @param x The UD60x18 number for which to calculate the inverse.
/// @return result The inverse as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function inv(UD60x18 x) pure returns (UD60x18 result) {
    unchecked {
        result = wrap(uUNIT_SQUARED / x.unwrap());
    }
}

/// @notice Calculates the natural logarithm of x using the following formula:
///
/// $$
/// ln{x} = log_2{x} / log_2{e}
/// $$
///
/// @dev Notes:
/// - Refer to the notes in {log2}.
/// - The precision isn't sufficiently fine-grained to return exactly `UNIT` when the input is `E`.
///
/// Requirements:
/// - Refer to the requirements in {log2}.
///
/// @param x The UD60x18 number for which to calculate the natural logarithm.
/// @return result The natural logarithm as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function ln(UD60x18 x) pure returns (UD60x18 result) {
    unchecked {
        // Inline the fixed-point multiplication to save gas. This is overflow-safe because the maximum value that
        // {log2} can return is ~196_205294292027477728.
        result = wrap(log2(x).unwrap() * uUNIT / uLOG2_E);
    }
}

/// @notice Calculates the common logarithm of x using the following formula:
///
/// $$
/// log_{10}{x} = log_2{x} / log_2{10}
/// $$
///
/// However, if x is an exact power of ten, a hard coded value is returned.
///
/// @dev Notes:
/// - Refer to the notes in {log2}.
///
/// Requirements:
/// - Refer to the requirements in {log2}.
///
/// @param x The UD60x18 number for which to calculate the common logarithm.
/// @return result The common logarithm as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function log10(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();
    if (xUint < uUNIT) {
        revert Errors.PRBMath_UD60x18_Log_InputTooSmall(x);
    }

    // Note that the `mul` in this assembly block is the standard multiplication operation, not {UD60x18.mul}.
    // prettier-ignore
    assembly ("memory-safe") {
        switch x
        case 1 { result := mul(uUNIT, sub(0, 18)) }
        case 10 { result := mul(uUNIT, sub(1, 18)) }
        case 100 { result := mul(uUNIT, sub(2, 18)) }
        case 1000 { result := mul(uUNIT, sub(3, 18)) }
        case 10000 { result := mul(uUNIT, sub(4, 18)) }
        case 100000 { result := mul(uUNIT, sub(5, 18)) }
        case 1000000 { result := mul(uUNIT, sub(6, 18)) }
        case 10000000 { result := mul(uUNIT, sub(7, 18)) }
        case 100000000 { result := mul(uUNIT, sub(8, 18)) }
        case 1000000000 { result := mul(uUNIT, sub(9, 18)) }
        case 10000000000 { result := mul(uUNIT, sub(10, 18)) }
        case 100000000000 { result := mul(uUNIT, sub(11, 18)) }
        case 1000000000000 { result := mul(uUNIT, sub(12, 18)) }
        case 10000000000000 { result := mul(uUNIT, sub(13, 18)) }
        case 100000000000000 { result := mul(uUNIT, sub(14, 18)) }
        case 1000000000000000 { result := mul(uUNIT, sub(15, 18)) }
        case 10000000000000000 { result := mul(uUNIT, sub(16, 18)) }
        case 100000000000000000 { result := mul(uUNIT, sub(17, 18)) }
        case 1000000000000000000 { result := 0 }
        case 10000000000000000000 { result := uUNIT }
        case 100000000000000000000 { result := mul(uUNIT, 2) }
        case 1000000000000000000000 { result := mul(uUNIT, 3) }
        case 10000000000000000000000 { result := mul(uUNIT, 4) }
        case 100000000000000000000000 { result := mul(uUNIT, 5) }
        case 1000000000000000000000000 { result := mul(uUNIT, 6) }
        case 10000000000000000000000000 { result := mul(uUNIT, 7) }
        case 100000000000000000000000000 { result := mul(uUNIT, 8) }
        case 1000000000000000000000000000 { result := mul(uUNIT, 9) }
        case 10000000000000000000000000000 { result := mul(uUNIT, 10) }
        case 100000000000000000000000000000 { result := mul(uUNIT, 11) }
        case 1000000000000000000000000000000 { result := mul(uUNIT, 12) }
        case 10000000000000000000000000000000 { result := mul(uUNIT, 13) }
        case 100000000000000000000000000000000 { result := mul(uUNIT, 14) }
        case 1000000000000000000000000000000000 { result := mul(uUNIT, 15) }
        case 10000000000000000000000000000000000 { result := mul(uUNIT, 16) }
        case 100000000000000000000000000000000000 { result := mul(uUNIT, 17) }
        case 1000000000000000000000000000000000000 { result := mul(uUNIT, 18) }
        case 10000000000000000000000000000000000000 { result := mul(uUNIT, 19) }
        case 100000000000000000000000000000000000000 { result := mul(uUNIT, 20) }
        case 1000000000000000000000000000000000000000 { result := mul(uUNIT, 21) }
        case 10000000000000000000000000000000000000000 { result := mul(uUNIT, 22) }
        case 100000000000000000000000000000000000000000 { result := mul(uUNIT, 23) }
        case 1000000000000000000000000000000000000000000 { result := mul(uUNIT, 24) }
        case 10000000000000000000000000000000000000000000 { result := mul(uUNIT, 25) }
        case 100000000000000000000000000000000000000000000 { result := mul(uUNIT, 26) }
        case 1000000000000000000000000000000000000000000000 { result := mul(uUNIT, 27) }
        case 10000000000000000000000000000000000000000000000 { result := mul(uUNIT, 28) }
        case 100000000000000000000000000000000000000000000000 { result := mul(uUNIT, 29) }
        case 1000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 30) }
        case 10000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 31) }
        case 100000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 32) }
        case 1000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 33) }
        case 10000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 34) }
        case 100000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 35) }
        case 1000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 36) }
        case 10000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 37) }
        case 100000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 38) }
        case 1000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 39) }
        case 10000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 40) }
        case 100000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 41) }
        case 1000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 42) }
        case 10000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 43) }
        case 100000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 44) }
        case 1000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 45) }
        case 10000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 46) }
        case 100000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 47) }
        case 1000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 48) }
        case 10000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 49) }
        case 100000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 50) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 51) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 52) }
        case 100000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 53) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 54) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 55) }
        case 100000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 56) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 57) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 58) }
        case 100000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 59) }
        default { result := uMAX_UD60x18 }
    }

    if (result.unwrap() == uMAX_UD60x18) {
        unchecked {
            // Inline the fixed-point division to save gas.
            result = wrap(log2(x).unwrap() * uUNIT / uLOG2_10);
        }
    }
}

/// @notice Calculates the binary logarithm of x using the iterative approximation algorithm:
///
/// $$
/// log_2{x} = n + log_2{y}, \text{ where } y = x*2^{-n}, \ y \in [1, 2)
/// $$
///
/// For $0 \leq x \lt 1$, the input is inverted:
///
/// $$
/// log_2{x} = -log_2{\frac{1}{x}}
/// $$
///
/// @dev See https://en.wikipedia.org/wiki/Binary_logarithm#Iterative_approximation
///
/// Notes:
/// - Due to the lossy precision of the iterative approximation, the results are not perfectly accurate to the last decimal.
///
/// Requirements:
/// - x must be greater than zero.
///
/// @param x The UD60x18 number for which to calculate the binary logarithm.
/// @return result The binary logarithm as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function log2(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();

    if (xUint < uUNIT) {
        revert Errors.PRBMath_UD60x18_Log_InputTooSmall(x);
    }

    unchecked {
        // Calculate the integer part of the logarithm.
        uint256 n = Common.msb(xUint / uUNIT);

        // This is the integer part of the logarithm as a UD60x18 number. The operation can't overflow because n
        // n is at most 255 and UNIT is 1e18.
        uint256 resultUint = n * uUNIT;

        // Calculate $y = x * 2^{-n}$.
        uint256 y = xUint >> n;

        // If y is the unit number, the fractional part is zero.
        if (y == uUNIT) {
            return wrap(resultUint);
        }

        // Calculate the fractional part via the iterative approximation.
        // The `delta >>= 1` part is equivalent to `delta /= 2`, but shifting bits is more gas efficient.
        uint256 DOUBLE_UNIT = 2e18;
        for (uint256 delta = uHALF_UNIT; delta > 0; delta >>= 1) {
            y = (y * y) / uUNIT;

            // Is y^2 >= 2e18 and so in the range [2e18, 4e18)?
            if (y >= DOUBLE_UNIT) {
                // Add the 2^{-m} factor to the logarithm.
                resultUint += delta;

                // Halve y, which corresponds to z/2 in the Wikipedia article.
                y >>= 1;
            }
        }
        result = wrap(resultUint);
    }
}

/// @notice Multiplies two UD60x18 numbers together, returning a new UD60x18 number.
///
/// @dev Uses {Common.mulDiv} to enable overflow-safe multiplication and division.
///
/// Notes:
/// - Refer to the notes in {Common.mulDiv}.
///
/// Requirements:
/// - Refer to the requirements in {Common.mulDiv}.
///
/// @dev See the documentation in {Common.mulDiv18}.
/// @param x The multiplicand as a UD60x18 number.
/// @param y The multiplier as a UD60x18 number.
/// @return result The product as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function mul(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(Common.mulDiv18(x.unwrap(), y.unwrap()));
}

/// @notice Raises x to the power of y.
///
/// For $1 \leq x \leq \infty$, the following standard formula is used:
///
/// $$
/// x^y = 2^{log_2{x} * y}
/// $$
///
/// For $0 \leq x \lt 1$, since the unsigned {log2} is undefined, an equivalent formula is used:
///
/// $$
/// i = \frac{1}{x}
/// w = 2^{log_2{i} * y}
/// x^y = \frac{1}{w}
/// $$
///
/// @dev Notes:
/// - Refer to the notes in {log2} and {mul}.
/// - Returns `UNIT` for 0^0.
/// - It may not perform well with very small values of x. Consider using SD59x18 as an alternative.
///
/// Requirements:
/// - Refer to the requirements in {exp2}, {log2}, and {mul}.
///
/// @param x The base as a UD60x18 number.
/// @param y The exponent as a UD60x18 number.
/// @return result The result as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function pow(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();
    uint256 yUint = y.unwrap();

    // If both x and y are zero, the result is `UNIT`. If just x is zero, the result is always zero.
    if (xUint == 0) {
        return yUint == 0 ? UNIT : ZERO;
    }
    // If x is `UNIT`, the result is always `UNIT`.
    else if (xUint == uUNIT) {
        return UNIT;
    }

    // If y is zero, the result is always `UNIT`.
    if (yUint == 0) {
        return UNIT;
    }
    // If y is `UNIT`, the result is always x.
    else if (yUint == uUNIT) {
        return x;
    }

    // If x is greater than `UNIT`, use the standard formula.
    if (xUint > uUNIT) {
        result = exp2(mul(log2(x), y));
    }
    // Conversely, if x is less than `UNIT`, use the equivalent formula.
    else {
        UD60x18 i = wrap(uUNIT_SQUARED / xUint);
        UD60x18 w = exp2(mul(log2(i), y));
        result = wrap(uUNIT_SQUARED / w.unwrap());
    }
}

/// @notice Raises x (a UD60x18 number) to the power y (an unsigned basic integer) using the well-known
/// algorithm "exponentiation by squaring".
///
/// @dev See https://en.wikipedia.org/wiki/Exponentiation_by_squaring.
///
/// Notes:
/// - Refer to the notes in {Common.mulDiv18}.
/// - Returns `UNIT` for 0^0.
///
/// Requirements:
/// - The result must fit in UD60x18.
///
/// @param x The base as a UD60x18 number.
/// @param y The exponent as a uint256.
/// @return result The result as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function powu(UD60x18 x, uint256 y) pure returns (UD60x18 result) {
    // Calculate the first iteration of the loop in advance.
    uint256 xUint = x.unwrap();
    uint256 resultUint = y & 1 > 0 ? xUint : uUNIT;

    // Equivalent to `for(y /= 2; y > 0; y /= 2)`.
    for (y >>= 1; y > 0; y >>= 1) {
        xUint = Common.mulDiv18(xUint, xUint);

        // Equivalent to `y % 2 == 1`.
        if (y & 1 > 0) {
            resultUint = Common.mulDiv18(resultUint, xUint);
        }
    }
    result = wrap(resultUint);
}

/// @notice Calculates the square root of x using the Babylonian method.
///
/// @dev See https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method.
///
/// Notes:
/// - The result is rounded toward zero.
///
/// Requirements:
/// - x must be less than `MAX_UD60x18 / UNIT`.
///
/// @param x The UD60x18 number for which to calculate the square root.
/// @return result The result as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function sqrt(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();

    unchecked {
        if (xUint > uMAX_UD60x18 / uUNIT) {
            revert Errors.PRBMath_UD60x18_Sqrt_Overflow(x);
        }
        // Multiply x by `UNIT` to account for the factor of `UNIT` picked up when multiplying two UD60x18 numbers.
        // In this case, the two numbers are both the square root.
        result = wrap(Common.sqrt(xUint * uUNIT));
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "./Casting.sol" as Casting;
import "./Helpers.sol" as Helpers;
import "./Math.sol" as Math;

/// @notice The unsigned 60.18-decimal fixed-point number representation, which can have up to 60 digits and up to 18
/// decimals. The values of this are bound by the minimum and the maximum values permitted by the Solidity type uint256.
/// @dev The value type is defined here so it can be imported in all other files.
type UD60x18 is uint256;

/*//////////////////////////////////////////////////////////////////////////
                                    CASTING
//////////////////////////////////////////////////////////////////////////*/

using {
    Casting.intoSD1x18,
    Casting.intoUD2x18,
    Casting.intoSD59x18,
    Casting.intoUint128,
    Casting.intoUint256,
    Casting.intoUint40,
    Casting.unwrap
} for UD60x18 global;

/*//////////////////////////////////////////////////////////////////////////
                            MATHEMATICAL FUNCTIONS
//////////////////////////////////////////////////////////////////////////*/

// The global "using for" directive makes the functions in this library callable on the UD60x18 type.
using {
    Math.avg,
    Math.ceil,
    Math.div,
    Math.exp,
    Math.exp2,
    Math.floor,
    Math.frac,
    Math.gm,
    Math.inv,
    Math.ln,
    Math.log10,
    Math.log2,
    Math.mul,
    Math.pow,
    Math.powu,
    Math.sqrt
} for UD60x18 global;

/*//////////////////////////////////////////////////////////////////////////
                                HELPER FUNCTIONS
//////////////////////////////////////////////////////////////////////////*/

// The global "using for" directive makes the functions in this library callable on the UD60x18 type.
using {
    Helpers.add,
    Helpers.and,
    Helpers.eq,
    Helpers.gt,
    Helpers.gte,
    Helpers.isZero,
    Helpers.lshift,
    Helpers.lt,
    Helpers.lte,
    Helpers.mod,
    Helpers.neq,
    Helpers.not,
    Helpers.or,
    Helpers.rshift,
    Helpers.sub,
    Helpers.uncheckedAdd,
    Helpers.uncheckedSub,
    Helpers.xor
} for UD60x18 global;

/*//////////////////////////////////////////////////////////////////////////
                                    OPERATORS
//////////////////////////////////////////////////////////////////////////*/

// The global "using for" directive makes it possible to use these operators on the UD60x18 type.
using {
    Helpers.add as +,
    Helpers.and2 as &,
    Math.div as /,
    Helpers.eq as ==,
    Helpers.gt as >,
    Helpers.gte as >=,
    Helpers.lt as <,
    Helpers.lte as <=,
    Helpers.or as |,
    Helpers.mod as %,
    Math.mul as *,
    Helpers.neq as !=,
    Helpers.not as ~,
    Helpers.sub as -,
    Helpers.xor as ^
} for UD60x18 global;
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}
// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;
//////////////////////////////////////////////////////////////////////////////// Linq Modules
import "../interfaces/IMainHub.sol";
import "../interfaces/IProjectDiamond.sol";
import "../interfaces/ICertificateNFTManager.sol";
import {ShareType, OptionType, DistributionType} from "../types/Enums.sol";
import "../types/Structs.sol";
//////////////////////////////////////////////////////////////////////////////// API3  Modules
import "@api3/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol";
//////////////////////////////////////////////////////////////////////////////// Openzeppelin Modules
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

/*


01000101 01111000 01110000 01100101 
01110010 01101001 01100101 01101110
01100011 01100101 00100000 01101001
01110011 00100000 01110100 01101000
01100101 00100000 01110100 01100101 
01100001 01100011 01101000 01100101
01110010 00100000 01101111 01100110
00100000 01100001 01101100 01101100
00100000 01110100 01101000 01101001 
01101110 01100111 01110011 00101110

"Praise be to the bold
for they know themselves,
and the fear of lesser men"

This contract is for fun, 
we hope this encourages others to not take the easy path,
and instead be creative.

We use API3 Oracles for randomness.
We use Linq Secure for rewarding sacrifice.

Disclaimer:
by interacting with this contract you do so of your own volition, 
and by interacting with it 
confirm that you are doing so in full accordance of the law in your jurisdiction. 
By interacting with this contract you agree that you do so
without the expectation of financial gain, and if you incur 
financial loss or gain you do not hold Linq Group inc. 
or any of its represenatives responsible or liable in anyway

If you wish to mimic this for your own project feel free :) we left notes so you may easily follow in our footsteps.


https://t.me/PotOfGreed_Entry

https://x.com/PotOfGreedX



*/

contract Pot_Of_Greed is RrpRequesterV0, ERC20, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableMap.UintToAddressMap private winners;

    /////////////////////////////////
    // Token Vars//
    /////////////////////////////////
    IUniswapV2Router02 public router;
    address public pair;

    bool private swapping;
    bool public swapEnabled = true;
    bool public tradingEnabled;

    Taxes public buyTaxes = Taxes(3, 0, 7); 
    Taxes public sellTaxes = Taxes(3, 0, 7); 

    uint256 public totalBuyTax = 10;
    uint256 public totalSellTax = 10;

    uint256 public swapTokensAtAmount;
    uint256 public maxBuyAmount;
    uint256 public maxSellAmount;
    uint256 public maxWallet;

    address devWallet;

    /////////////////////////////////
    // LocQer Vars //
    /////////////////////////////////
    // init the main hub - required
    IMainHub MainHub = IMainHub(0xF1C20999905B969b8DBC8350f4Cb5e8450a65230);

    // init the Certificate Mananger - required
    ICertificateNFTManager CertificateManager =
        ICertificateNFTManager(0x0679E1393F84a06Cce947f49948ac688B2Ebfe0A);

    address public POGLOCQER;
    address public LPLOCQER;

    IProjectDiamond LocQer;
    IProjectDiamond LiquiditylocQer;

    /////////////////////////////////
    // Oracle Vars //
    /////////////////////////////////

    address public airnode;
    bytes32 public endpointIdUint256;
    address public sponsorWallet;

    uint256 lastTicketMintTime;
    bool public firstCycleInitialized = false;
    uint256 lastCycleStartTime;
    uint256 currentRoundId = 0;
    bool ticketPriceOverride = false;
    uint256 overRidePrice = 0;
    uint256 defaultTicketPrice = 1000 * 10 ** 18;
    bool public RoundsActive = false;

    ///////////////
    // Structs   //
    ///////////////

    struct RoundDetails {
        uint256 ticketPrice; // price to enter the round
        uint256 timeInterval; //  time interval to round end  --> how long do we wait betwene tickets to end round
        uint256 startTime; // round start time
        uint256 endTime; // round end time
        uint256 roundFunds; // amount of POG depositted in this round
        EnumerableSet.AddressSet participants; // partiicpants in the round
        bool roundActive; // is the round still active
        address winner; // winner of the draw round
        uint256 winnerTokenId;
        uint256 numberOfTickets;
    }

    struct Taxes {
        uint256 pogpot;
        uint256 lp;
        uint256 dev;
    }

    struct CreationVars {
        address _tokenRouterAddress;
        address _originalDeployerAddress;
        string _projectName;
        DistributionType _distributionType;
        address _depositTokenAddress;
        bool _vSharesEnabled;
        bool _certificateCreateEnabled;
        bool _certificateCreateCapEnabled;
        bool _certificateAllowMerge;
        bool _certificateAllowSplit;
        bool _certificateAllowLiquidation;
        bool _certificateAllowDeposit;
        bool _certificateDepositCapEnabled;
        bool _certificateEarlyWithdrawalFeeEnabled;
        uint256 _depositCap;
        uint32 _depositFeePercentage;
        uint32 _earlyWithdrawalFeePercentage;
        uint32 _earlyWithdrawalFeeDuration;
        uint16 _certificateCap;
        bool _certificateMinimumDepositEnabled;
        uint256 _depositMinimumAmount;
    }

    ///////////////
    // Mappings //
    ///////////////

    mapping(uint256 => RoundDetails) round_info;
    mapping(address => uint256[]) _rounds_won;
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) private _isExcludedFromMaxWallet;
    mapping(bytes32 => bool) public expectingRequestWithIdToBeFulfilled;

    ///////////////
    //   Events  //
    ///////////////

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event RequestedUint256(bytes32 indexed requestId);
    event winnerDeclared(
        address indexed winner,
        uint256 indexed winningID,
        uint256 indexed BurnAmount
    );
    event RoundEnded(uint256 indexed time);
    event winnerClaim(address indexed winner, uint256 indexed winnerTokenid);
    event PogPotDrop(uint256 indexed LPDROP);
    event LPDrop(uint256 indexed POGPOTDROP);

    constructor(
        address _airnodeRrpAddress,
        address _tokenRouterAddress,
        bool _certificateCreateEnabled,
        uint256 _depositCap,
        address _pog_marketing
    )
        ERC20("Pot Of Greed", "POG")
        Ownable(msg.sender)
        RrpRequesterV0(_airnodeRrpAddress)
    {
        POGLOCQER = createProject(
            CreationVars({
                _tokenRouterAddress: _tokenRouterAddress,
                _originalDeployerAddress: _tokenRouterAddress,
                _projectName: "POG POT",
                _distributionType: DistributionType.PROGRESSIVE,
                _depositTokenAddress: address(0),
                _vSharesEnabled: true,
                _certificateCreateEnabled: _certificateCreateEnabled,
                _certificateCreateCapEnabled: false,
                _certificateAllowMerge: true,
                _certificateAllowSplit: true,
                _certificateAllowLiquidation: false,
                _certificateAllowDeposit: false,
                _certificateDepositCapEnabled: false,
                _certificateEarlyWithdrawalFeeEnabled: false,
                _depositCap: _depositCap,
                _depositFeePercentage: 0,
                _earlyWithdrawalFeePercentage: 0,
                _earlyWithdrawalFeeDuration: 0,
                _certificateCap: 10000, /// disable
                _certificateMinimumDepositEnabled: false,
                _depositMinimumAmount: 0
            })
        );

        IUniswapV2Router02 _router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        address _pair = IUniswapV2Factory(_router.factory()).createPair(
            address(this),
            _router.WETH()
        );

        router = _router;
        pair = _pair;

        // initilize locker object
        LocQer = IProjectDiamond(POGLOCQER);

        devWallet = _pog_marketing;

        // create WETH reward slot
        LocQer.createRewardTokenSlot(_router.WETH());

        setSwapTokensAtAmount(20000); //
        updateMaxWalletAmount(2000000);
        setMaxBuyAndSell(2000000, 2000000);

        excludeFromMaxWallet(address(_pair), true);
        excludeFromMaxWallet(address(this), true);
        excludeFromMaxWallet(address(_router), true);

        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);

        setRoundDetails(1000 * (10 ** 18), 1800); // 1000 tokens, 30 mins

        _mint(owner(), 100000000 * (10 ** 18)); // 100 mil
    }

    receive() external payable {}

    function createProject(
        CreationVars memory _creationDetails
    ) public payable returns (address) {
        require(msg.sender == address(this) || msg.sender == owner());
        ProjectArgs memory initArgs = ProjectArgs({
            projectName: _creationDetails._projectName,
            distributionType: _creationDetails._distributionType,
            depositTokenAddress: _creationDetails._depositTokenAddress,
            settingsFlags: SettingsFlags({
                vSharesEnabled: _creationDetails._vSharesEnabled,
                certificateCreateEnabled: _creationDetails
                    ._certificateCreateEnabled,
                certificateCreateCapEnabled: _creationDetails
                    ._certificateCreateCapEnabled,
                certificateAllowMerge: _creationDetails._certificateAllowMerge,
                certificateAllowSplit: _creationDetails._certificateAllowSplit,
                certificateAllowLiquidation: _creationDetails
                    ._certificateAllowLiquidation,
                certificateAllowDeposit: _creationDetails
                    ._certificateAllowDeposit,
                certificateDepositCapEnabled: _creationDetails
                    ._certificateDepositCapEnabled,
                certificateEarlyWithdrawalFeeEnabled: _creationDetails
                    ._certificateEarlyWithdrawalFeeEnabled,
                certificateMinimumDepositEnabled: _creationDetails
                    ._certificateMinimumDepositEnabled
            }),
            settingsData: SettingsData({
                depositCap: _creationDetails._depositCap,
                depositMinimumAmount: _creationDetails._depositMinimumAmount,
                depositFeePercentage: _creationDetails._depositFeePercentage,
                earlyWithdrawalFeePercentage: _creationDetails
                    ._earlyWithdrawalFeePercentage,
                earlyWithdrawalFeeDuration: _creationDetails
                    ._earlyWithdrawalFeeDuration,
                certificateCap: _creationDetails._certificateCap
            })
        });

        return MainHub.createProject(initArgs);
    }

    function setDevWallet(address user) public onlyOwner {
        devWallet = user;
    }

    // Function to add an address to the set
    function addParticipant(address _address) internal {
        round_info[currentRoundId].participants.add(_address);
    }

    // Function to check if an address is in the set
    function isAParticipant(address _address) public view returns (bool) {
        return round_info[currentRoundId].participants.contains(_address);
    }

    // Function to get the number of addresses in the set
    function getParticpantCount() public view returns (uint256) {
        return round_info[currentRoundId].participants.length();
    }

    // Function to get an address by index
    function getParticpantByIndex(uint256 index) public view returns (address) {
        require(
            index < round_info[currentRoundId].participants.length(),
            "Index out of bounds"
        );
        return round_info[currentRoundId].participants.at(index);
    }

    function setDefaultTicketPrice(uint256 _price) public onlyOwner {
        defaultTicketPrice = _price * 18 ** 18;
    }

    function RoundsState(bool state) public onlyOwner {
        RoundsActive = state;
    }

    // Enters a user into the currenct Draw Round
    function enterDrawRound(uint256 amount) public {
        // require them to deposit the ticket price
        require(
            amount == VshareAmount(),
            "you must deposit the current ticket price"
        );
        // rquire the round to be active
        require(
            round_info[currentRoundId].roundActive == true,
            "the current round is not active "
        );
        require(RoundsActive == true, " Rounds must be active");
        // require the tokens to be trasnfered
        require(
            IERC20(address(this)).transferFrom(
                msg.sender,
                address(this),
                amount
            ),
            "transfer failed, make sure to approve pog to take your pog "
        );

        round_info[currentRoundId].roundFunds += amount;
        // add them to the participants array
        addParticipant(msg.sender);

        round_info[currentRoundId].numberOfTickets += 1;

        /// time out period --> esentially if a ticket isnt submitted within a set duration say 10 minutes the round will auto close
        if (
            lastTicketMintTime + round_info[currentRoundId].timeInterval >=
            block.timestamp
        ) {
            endRound();
            emit RoundEnded(block.timestamp);
        }
        lastTicketMintTime = block.timestamp; 
    }

    /// @notice This ends the current draw round
    function endRound() private {
        // Create certificate for the correct round
        uint256 id = LocQer.createVShareCertificate(VshareAmount(), 1)[0];

        uint256 tokenid = CertificateManager.getTokenId(POGLOCQER, id);

        round_info[currentRoundId].winnerTokenId = tokenid;
        round_info[currentRoundId].roundActive = false;
        round_info[currentRoundId].endTime = block.timestamp;
        makeRequestUint256();
    }

    // Makes the Oracle Request
    function makeRequestUint256() internal {
        bytes32 requestId = airnodeRrp.makeFullRequest(
            airnode,
            endpointIdUint256,
            address(this),
            sponsorWallet,
            address(this),
            this.fulfillUint256.selector,
            ""
        );
        expectingRequestWithIdToBeFulfilled[requestId] = true;
        emit RequestedUint256(requestId);
    }

    // Fufills the Oracle request
    function fulfillUint256(
        bytes32 requestId,
        bytes calldata data
    ) external onlyAirnodeRrp {
        require(
            expectingRequestWithIdToBeFulfilled[requestId],
            "Request ID not known"
        );
        expectingRequestWithIdToBeFulfilled[requestId] = false;
        uint256 qrngUint256 = abi.decode(data, (uint256));

        uint256 scaledNumber;

        if (getParticpantCount() > 1) {
            scaledNumber = (qrngUint256 % (getParticpantCount()));
        } else {
            scaledNumber = 0;
        }

        round_info[currentRoundId].winner = getParticpantByIndex(scaledNumber);

        uint256 burnAmount = round_info[currentRoundId].roundFunds;
        address winner = round_info[currentRoundId].winner;
        uint256 winnerid = round_info[currentRoundId].winnerTokenId;

        _rounds_won[winner].push(currentRoundId);

        _burn(address(this), burnAmount);

        currentRoundId += 1;

        setRoundDetails(
            defaultTicketPrice,
            round_info[currentRoundId - 1].timeInterval
        );

        emit winnerDeclared(winner, winnerid, burnAmount);
    }

    function returnRoundsWon(
        address user
    ) public view returns (uint256[] memory) {
        return _rounds_won[user];
    }

    function ClaimWinningCertificate(uint256 roundId) public {
        require(
            msg.sender == round_info[roundId].winner,
            "You cannot claim this certificate because you are not the winner of the round"
        );
        require(
            CertificateManager.ownerOf(round_info[roundId].winnerTokenId) ==
                address(this),
            "You cannot claim this certificate because it has already been claimed"
        );
        CertificateManager.safeTransferFrom(
            address(this),
            round_info[roundId].winner,
            round_info[roundId].winnerTokenId
        );
        emit winnerClaim(
            round_info[roundId].winner,
            round_info[roundId].winnerTokenId
        );
    }

    function ClaimWinningCertificates() public {
        for (uint256 i = 0; i < currentRoundId; i++) {
            require(
                msg.sender == round_info[i].winner,
                "You cannot claim this certificate because you are not the winner"
            );
            require(
                CertificateManager.ownerOf(round_info[i].winnerTokenId) ==
                    address(this),
                "You cannot claim this certificate because it has already been claimed"
            );
            CertificateManager.safeTransferFrom(
                address(this),
                round_info[i].winner,
                round_info[i].winnerTokenId
            );
            emit winnerClaim(round_info[i].winner, round_info[i].winnerTokenId);
        }
    }

    function emergencyClaim(uint256 tokenId) public onlyOwner {
        CertificateManager.safeTransferFrom(address(this), msg.sender, tokenId);
    }


    function getCurrentTicketCount() public view returns(uint256){
        return round_info[currentRoundId].numberOfTickets;
    }

    /// @notice This starts a new reward cycle
    /// @param cycleTime this is the cycle time in seconds
    /// @dev 2592000 month // 2 weeks 1209600
    /// @dev 31536000 year
    function startCycle(uint256 cycleTime) internal {
        if (firstCycleInitialized == false) {
            firstCycleInitialized = true;
        }
        LocQer.startNewCycle(cycleTime, false);
    }

    /// @notice This overrides the internal function to set a cycle
    /// @param cycleTime this is the cycle time in seconds
    function cycle_over_ride(uint256 cycleTime) public onlyOwner {
        LocQer.startNewCycle(cycleTime, false);
    }

    /////////////////////////////////////
    // Exclude Include and SET functions/
    /////////////////////////////////////

    function setRequestParameters(
        address _airnode,
        bytes32 _endpointIdUint256,
        address _sponsorWallet
    ) external onlyOwner {
        airnode = _airnode;
        endpointIdUint256 = _endpointIdUint256;
        sponsorWallet = _sponsorWallet;
    }

    function setRoundDetails(
        uint256 ticketPrice,
        uint256 timeInterval
    ) internal {
        round_info[currentRoundId].ticketPrice = ticketPrice;
        round_info[currentRoundId].timeInterval = timeInterval;
        round_info[currentRoundId].roundFunds = 0;
        round_info[currentRoundId].roundActive = true;
        round_info[currentRoundId].startTime = block.timestamp;
    }

    function VshareAmount() internal view returns (uint256) {
        if (ticketPriceOverride == true) {
            return overRidePrice;
        } else {
            return round_info[currentRoundId].ticketPrice;
        }
    }

    function overRideShareAmount(bool state, uint256 price) public onlyOwner {
        ticketPriceOverride = state;
        overRidePrice = price * 10 ** 18;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(
            _isExcludedFromFees[account] != excluded,
            "Account is already the value of excluded"
        );
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeFromMaxWallet(
        address account,
        bool excluded
    ) public onlyOwner {
        _isExcludedFromMaxWallet[account] = excluded;
    }

    function updateMaxWalletAmount(uint256 maxWalletFactor) public onlyOwner {
        maxWallet = maxWalletFactor * 10 ** 18;
    }

    function setMaxBuyAndSell(
        uint256 maxBuyFactor,
        uint256 maxsellFactor
    ) public onlyOwner {
        maxBuyAmount = maxBuyFactor * 10 ** 18;
        maxSellAmount = maxsellFactor * 10 ** 18;
    }

    function setSwapTokensAtAmount(uint256 swapFactor) public onlyOwner {
        swapTokensAtAmount = swapFactor * 10 ** 18;
    }

    function setBuyTaxes(
        uint256 pogpot,
        uint256 lp,
        uint256 dev
    ) external onlyOwner {
        require(pogpot + dev + lp <= 40, "Fee must be <= 40%");
        buyTaxes = Taxes(pogpot, lp, dev);
        totalBuyTax = pogpot + dev + lp;
    }

    function setSellTaxes(
        uint256 pogpot,
        uint256 lp,
        uint256 dev
    ) external onlyOwner {
        require(pogpot + dev + lp <= 40, "Fee must be <= 40%");
        sellTaxes = Taxes(pogpot, lp, dev);
        totalSellTax = pogpot + dev + lp;
    }

    /// @notice Enable or disable internal swaps
    /// @dev Set "true" to enable internal swaps for liquidity, treasury and dividends
    function setSwapEnabled(bool _enabled) external onlyOwner {
        swapEnabled = _enabled;
    }

    function activateTrading() external {
        require(msg.sender == devWallet);
        require(!tradingEnabled, "Trading already enabled");
        tradingEnabled = true;
    }

    function updateRouter(address newRouter) external onlyOwner {
        router = IUniswapV2Router02(newRouter);
    }

    //////////////////////
    // Getter Functions //
    //////////////////////

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    ////////////////////////
    // Transfer Functions //
    ////////////////////////

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (
            !_isExcludedFromFees[from] && !_isExcludedFromFees[to] && !swapping
        ) {
            require(tradingEnabled, "Trading not active");
            if (to == pair) {
                require(
                    amount <= maxSellAmount,
                    "You are exceeding maxSellAmount"
                );
            } else if (from == pair)
                require(
                    amount <= maxBuyAmount,
                    "You are exceeding maxBuyAmount"
                );
            if (!_isExcludedFromMaxWallet[to]) {
                require(
                    amount + balanceOf(to) <= maxWallet,
                    "Unable to exceed Max Wallet"
                );
            }
        }

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        uint256 contractTokenBalance;

        if (balanceOf(address(this)) > round_info[currentRoundId].roundFunds) {
            contractTokenBalance =
                balanceOf(address(this)) -
                round_info[currentRoundId].roundFunds;
        } else {
            contractTokenBalance = balanceOf(address(this));
        }

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (
            canSwap &&
            !swapping &&
            swapEnabled &&
            to == pair &&
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to]
        ) {
            swapping = true;

            if (totalSellTax > 0) {
                swapAndLiquify(swapTokensAtAmount);
            }

            swapping = false;
        }

        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if (pair != to && from != pair) takeFee = false;

        if (takeFee) {
            uint256 feeAmt;
            if (to == pair) feeAmt = (amount * totalSellTax) / 100;
            else if (from == pair) feeAmt = (amount * totalBuyTax) / 100;

            amount = amount - feeAmt;
            super._transfer(from, address(this), feeAmt);
        }
        super._transfer(from, to, amount);
    }

    function swapAndLiquify(uint256 tokens) private {
        uint256 toSwapForDevAndPot = tokens;

        if (sellTaxes.lp > 0) {
            uint256 toSwapForLiq = ((tokens * sellTaxes.lp) / totalSellTax) / 2;
            uint256 tokensToAddLiquidityWith = ((tokens * sellTaxes.lp) /
                totalSellTax) / 2;

            swapTokensForETH(toSwapForLiq);

            uint256 currentbalance = address(this).balance;

            if (currentbalance > 0) {
                // Add liquidity to uni
                addLiquidity(tokensToAddLiquidityWith, currentbalance);
            }

            uint256 lpBalance = IERC20(pair).balanceOf(address(this));

            if (lpBalance > 0) {
                IERC20(pair).approve(
                    address(LiquiditylocQer),
                    IERC20(pair).balanceOf(address(this))
                );

                LiquiditylocQer.depositReward(
                    pair,
                    IERC20(pair).balanceOf(address(this))
                );
                emit LPDrop(lpBalance);
            }

            toSwapForDevAndPot =
                tokens -
                (toSwapForLiq + tokensToAddLiquidityWith);
        }

        swapTokensForETH(toSwapForDevAndPot);

        if (sellTaxes.dev > 0) {
            uint256 devAmt = (address(this).balance * sellTaxes.dev) /
                totalSellTax;

            if (devAmt > 0) {
                (bool success, ) = payable(devWallet).call{value: devAmt}("");
                require(success, "Failed to send ETH to dev wallet");
            }
        }

        if (sellTaxes.pogpot > 0) {
            uint256 POGPOT = (address(this).balance * sellTaxes.pogpot) /
                totalSellTax;

            LocQer.depositReward{value: POGPOT}(router.WETH(), POGPOT);

            emit PogPotDrop(POGPOT);
        }
        if (firstCycleInitialized == false) {
            startCycle(1209600); // 2 weeks
        }
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(router), tokenAmount);

        // add the liquidity
        router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function cycle_over_ride_LP(uint256 cycleTime) public onlyOwner {
        LiquiditylocQer.startNewCycle(cycleTime, false);
    }

    function decentralizeLP(uint256 amount) public onlyOwner {
        LiquiditylocQer.depositReward(pair, amount);
    }

    function initializeDecentralizedLPPool(
        address _tokenRouterAddress,
        uint256 cycleTime
    ) public {
        require(msg.sender == address(this) || msg.sender == owner());
        CreationVars memory creationsDetails = CreationVars({
            _tokenRouterAddress: _tokenRouterAddress,
            _originalDeployerAddress: msg.sender, // confirm what admin settings this allows
            _projectName: "POG LP LocQer",
            _distributionType: DistributionType.PROGRESSIVE,
            _depositTokenAddress: address(this),
            _vSharesEnabled: false,
            _certificateCreateEnabled: true,
            _certificateCreateCapEnabled: false,
            _certificateAllowMerge: true,
            _certificateAllowSplit: true,
            _certificateAllowLiquidation: false,
            _certificateAllowDeposit: true,
            _certificateDepositCapEnabled: false,
            _certificateEarlyWithdrawalFeeEnabled: false,
            _depositCap: 100000000 * 10 ** 18,
            _depositFeePercentage: 0,
            _earlyWithdrawalFeePercentage: 0,
            _earlyWithdrawalFeeDuration: 0,
            _certificateCap: 10000,
            _certificateMinimumDepositEnabled: false,
            _depositMinimumAmount: 0
        });
        LPLOCQER = createProject(creationsDetails);

        excludeFromMaxWallet(LPLOCQER, true);

        LiquiditylocQer = IProjectDiamond(LPLOCQER);

        LiquiditylocQer.createRewardTokenSlot(pair);

        cycle_over_ride_LP(cycleTime);
    }

    /// @notice Withdraw tokens sent by mistake.
    /// @param tokenAddress The address of the token to withdraw
    function rescueETH20Tokens(address tokenAddress) external {
        require(msg.sender == devWallet);
        IERC20(tokenAddress).transfer(
            devWallet,
            IERC20(tokenAddress).balanceOf(address(this))
        );
    }

    /// @notice Send remaining ETH to dev
    /// @dev It will send all ETH to dev
    function forceSend() external {
        require(msg.sender == devWallet);
        uint256 ETHbalance = address(this).balance;
        (bool success, ) = payable(devWallet).call{value: ETHbalance}("");
        require(success);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

library console {
    address constant CONSOLE_ADDRESS =
        0x000000000000000000636F6e736F6c652e6c6f67;

    function _sendLogPayloadImplementation(bytes memory payload) internal view {
        address consoleAddress = CONSOLE_ADDRESS;
        /// @solidity memory-safe-assembly
        assembly {
            pop(
                staticcall(
                    gas(),
                    consoleAddress,
                    add(payload, 32),
                    mload(payload),
                    0,
                    0
                )
            )
        }
    }

    function _castToPure(
      function(bytes memory) internal view fnIn
    ) internal pure returns (function(bytes memory) pure fnOut) {
        assembly {
            fnOut := fnIn
        }
    }

    function _sendLogPayload(bytes memory payload) internal pure {
        _castToPure(_sendLogPayloadImplementation)(payload);
    }

    function log() internal pure {
        _sendLogPayload(abi.encodeWithSignature("log()"));
    }
    function logInt(int256 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(int256)", p0));
    }

    function logUint(uint256 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256)", p0));
    }

    function logString(string memory p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string)", p0));
    }

    function logBool(bool p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
    }

    function logAddress(address p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address)", p0));
    }

    function logBytes(bytes memory p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
    }

    function logBytes1(bytes1 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
    }

    function logBytes2(bytes2 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
    }

    function logBytes3(bytes3 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
    }

    function logBytes4(bytes4 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
    }

    function logBytes5(bytes5 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
    }

    function logBytes6(bytes6 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
    }

    function logBytes7(bytes7 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
    }

    function logBytes8(bytes8 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
    }

    function logBytes9(bytes9 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
    }

    function logBytes10(bytes10 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
    }

    function logBytes11(bytes11 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
    }

    function logBytes12(bytes12 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
    }

    function logBytes13(bytes13 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
    }

    function logBytes14(bytes14 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
    }

    function logBytes15(bytes15 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
    }

    function logBytes16(bytes16 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
    }

    function logBytes17(bytes17 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
    }

    function logBytes18(bytes18 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
    }

    function logBytes19(bytes19 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
    }

    function logBytes20(bytes20 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
    }

    function logBytes21(bytes21 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
    }

    function logBytes22(bytes22 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
    }

    function logBytes23(bytes23 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
    }

    function logBytes24(bytes24 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
    }

    function logBytes25(bytes25 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
    }

    function logBytes26(bytes26 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
    }

    function logBytes27(bytes27 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
    }

    function logBytes28(bytes28 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
    }

    function logBytes29(bytes29 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
    }

    function logBytes30(bytes30 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
    }

    function logBytes31(bytes31 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
    }

    function logBytes32(bytes32 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
    }

    function log(uint256 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256)", p0));
    }

    function log(string memory p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string)", p0));
    }

    function log(bool p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
    }

    function log(address p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address)", p0));
    }

    function log(uint256 p0, uint256 p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256)", p0, p1));
    }

    function log(uint256 p0, string memory p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string)", p0, p1));
    }

    function log(uint256 p0, bool p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool)", p0, p1));
    }

    function log(uint256 p0, address p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address)", p0, p1));
    }

    function log(string memory p0, uint256 p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256)", p0, p1));
    }

    function log(string memory p0, string memory p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
    }

    function log(string memory p0, bool p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
    }

    function log(string memory p0, address p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
    }

    function log(bool p0, uint256 p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256)", p0, p1));
    }

    function log(bool p0, string memory p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
    }

    function log(bool p0, bool p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
    }

    function log(bool p0, address p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
    }

    function log(address p0, uint256 p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256)", p0, p1));
    }

    function log(address p0, string memory p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
    }

    function log(address p0, bool p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
    }

    function log(address p0, address p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
    }

    function log(uint256 p0, uint256 p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256)", p0, p1, p2));
    }

    function log(uint256 p0, uint256 p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string)", p0, p1, p2));
    }

    function log(uint256 p0, uint256 p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool)", p0, p1, p2));
    }

    function log(uint256 p0, uint256 p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address)", p0, p1, p2));
    }

    function log(uint256 p0, string memory p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256)", p0, p1, p2));
    }

    function log(uint256 p0, string memory p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,string)", p0, p1, p2));
    }

    function log(uint256 p0, string memory p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool)", p0, p1, p2));
    }

    function log(uint256 p0, string memory p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,address)", p0, p1, p2));
    }

    function log(uint256 p0, bool p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256)", p0, p1, p2));
    }

    function log(uint256 p0, bool p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string)", p0, p1, p2));
    }

    function log(uint256 p0, bool p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool)", p0, p1, p2));
    }

    function log(uint256 p0, bool p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address)", p0, p1, p2));
    }

    function log(uint256 p0, address p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256)", p0, p1, p2));
    }

    function log(uint256 p0, address p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,string)", p0, p1, p2));
    }

    function log(uint256 p0, address p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool)", p0, p1, p2));
    }

    function log(uint256 p0, address p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,address)", p0, p1, p2));
    }

    function log(string memory p0, uint256 p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256)", p0, p1, p2));
    }

    function log(string memory p0, uint256 p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,string)", p0, p1, p2));
    }

    function log(string memory p0, uint256 p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool)", p0, p1, p2));
    }

    function log(string memory p0, uint256 p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,address)", p0, p1, p2));
    }

    function log(string memory p0, string memory p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,uint256)", p0, p1, p2));
    }

    function log(string memory p0, string memory p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
    }

    function log(string memory p0, string memory p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
    }

    function log(string memory p0, string memory p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
    }

    function log(string memory p0, bool p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256)", p0, p1, p2));
    }

    function log(string memory p0, bool p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
    }

    function log(string memory p0, bool p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
    }

    function log(string memory p0, bool p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
    }

    function log(string memory p0, address p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,uint256)", p0, p1, p2));
    }

    function log(string memory p0, address p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
    }

    function log(string memory p0, address p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
    }

    function log(string memory p0, address p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
    }

    function log(bool p0, uint256 p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256)", p0, p1, p2));
    }

    function log(bool p0, uint256 p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string)", p0, p1, p2));
    }

    function log(bool p0, uint256 p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool)", p0, p1, p2));
    }

    function log(bool p0, uint256 p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address)", p0, p1, p2));
    }

    function log(bool p0, string memory p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256)", p0, p1, p2));
    }

    function log(bool p0, string memory p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
    }

    function log(bool p0, string memory p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
    }

    function log(bool p0, string memory p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
    }

    function log(bool p0, bool p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256)", p0, p1, p2));
    }

    function log(bool p0, bool p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
    }

    function log(bool p0, bool p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
    }

    function log(bool p0, bool p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
    }

    function log(bool p0, address p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256)", p0, p1, p2));
    }

    function log(bool p0, address p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
    }

    function log(bool p0, address p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
    }

    function log(bool p0, address p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
    }

    function log(address p0, uint256 p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256)", p0, p1, p2));
    }

    function log(address p0, uint256 p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,string)", p0, p1, p2));
    }

    function log(address p0, uint256 p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool)", p0, p1, p2));
    }

    function log(address p0, uint256 p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,address)", p0, p1, p2));
    }

    function log(address p0, string memory p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,uint256)", p0, p1, p2));
    }

    function log(address p0, string memory p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
    }

    function log(address p0, string memory p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
    }

    function log(address p0, string memory p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
    }

    function log(address p0, bool p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256)", p0, p1, p2));
    }

    function log(address p0, bool p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
    }

    function log(address p0, bool p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
    }

    function log(address p0, bool p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
    }

    function log(address p0, address p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,uint256)", p0, p1, p2));
    }

    function log(address p0, address p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
    }

    function log(address p0, address p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
    }

    function log(address p0, address p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
    }

    function log(uint256 p0, uint256 p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,string)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,address)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,string)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,address)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,string)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,address)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,string)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,address)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,string)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,address)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,string)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,address)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,string)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,address)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,string)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,bool)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,address)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,string)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,bool)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,address)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,string)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,bool)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,address)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,string)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,bool)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,address)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,string)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,bool)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,address)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,string)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,bool)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,address)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,string)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,bool)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,address)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
    }

}
// SPDX-License-Identifier: MIT
// openZeppelin Contracts v4.4.1 (access/IAccessControlEnumerable.sol)

pragma solidity 0.8.25;

import "./IAccessControlUpgradeable.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerableUpgradeable is IAccessControlUpgradeable {
  /**
   * @dev Returns one of the accounts that have `role`. `index` must be a
   * value between 0 and {getRoleMemberCount}, non-inclusive.
   *
   * Role bearers are not sorted in any particular way, and their ordering may
   * change at any point.
   *
   * WARNING: When using and {getRoleMemberCount}, make sure
   * you perform all queries on the same block. See the following
   * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
   * for more information.
   */
  function getRoleMember(bytes32 role, uint256 index) external view returns (address);

  /**
   * @dev Returns the number of accounts that have `role`. Can be used
   * together with to enumerate all bearers of a role.
   */
  function getRoleMemberCount(bytes32 role) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
// openZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity 0.8.25;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
  /**
   * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
   *
   * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
   * not being emitted signaling this.
   *
   * _Available since v3.1._
   */
  event RoleAdminChanged(
    bytes32 indexed role,
    bytes32 indexed previousAdminRole,
    bytes32 indexed newAdminRole
  );

  /**
   * @dev Emitted when `account` is granted `role`.
   *
   * `sender` is the account that originated the contract call, an admin role
   * bearer except when using {AccessControl-_setupRole}.
   */
  event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

  /**
   * @dev Emitted when `account` is revoked `role`.
   *
   * `sender` is the account that originated the contract call:
   *   - if using `revokeRole`, it is the admin role bearer
   *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
   */
  event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

  /**
   * @dev Returns `true` if `account` has been granted `role`.
   */
  function hasRole(bytes32 role, address account) external view returns (bool);

  /**
   * @dev Returns the admin role that controls `role`. See and
   * {revokeRole}.
   *
   * To change a role's admin, use {AccessControl-_setRoleAdmin}.
   */
  function getRoleAdmin(bytes32 role) external view returns (bytes32);

  /**
   * @dev Grants `role` to `account`.
   *
   * If `account` had not been already granted `role`, emits a {RoleGranted}
   * event.
   *
   * Requirements:
   *
   * - the caller must have ``role``'s admin role.
   */
  function grantRole(bytes32 role, address account) external;

  /**
   * @dev Revokes `role` from `account`.
   *
   * If `account` had been granted `role`, emits a event.
   *
   * Requirements:
   *
   * - the caller must have ``role``'s admin role.
   */
  function revokeRole(bytes32 role, address account) external;

  /**
   * @dev Revokes `role` from the calling account.
   *
   * Roles are often managed via and {revokeRole}: this function's
   * purpose is to provide a mechanism for accounts to lose their privileges
   * if they are compromised (such as when a trusted device is misplaced).
   *
   * If the calling account had been granted `role`, emits a {RoleRevoked}
   * event.
   *
   * Requirements:
   *
   * - the caller must be `account`.
   */
  function renounceRole(bytes32 role, address account) external;
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.25;

import {EnumerableMap} from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {
  IERC721Enumerable
} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

import {IEvents} from "../types/Events.sol";

interface ICertificateNFTManager is IERC721Enumerable, IEvents {
  /**
   * @notice Keeps track of certificates for a project
   * @param projectAddress Address of the project
   * @param certificateId Id of the certificate
   */
  struct TokenAttachedCertificate {
    address projectAddress;
    uint256 certificateId;
  }

  /**
   * @notice Keeps track of tokens for an account
   * @param globalTokens A set of all token ids owned by the account
   * @param participatingProjects A map of project addresses to the amount of tokens owned by the account in that project
   * @param tokensByProject Mapping of project addresses to sets of tokenIds owned by the account in that project
   */
  struct AccountTracker {
    EnumerableSet.UintSet globalTokens;
    EnumerableMap.AddressToUintMap participatingProjects;
    mapping(address => EnumerableSet.UintSet) tokensByProject;
  }

  /**
   * @notice Keeps track of token metadata
   * so it can be used on pagination without the caller needing to decode the token id
   * into project address and certificate id
   * @param tokenId The NFT token id
   * @param projectAddress `ProjectDiamond` address
   * @param certificateId Certificate id within the project
   */
  struct TokenTriplet {
    uint256 tokenId;
    address projectAddress;
    uint256 certificateId;
  }

  /**
   * @notice Emitted whenever a certificate is updated
   * @param tokenId The token id
   * @dev This allows for automatic metadata updates on Marketplaces
   */
  event MetadataUpdate(uint256 tokenId);

  /**
   * @notice Emitted whenever the main hub address is updated by the super admin
   * @param oldMainHubAddress The old main hub address
   * @param newMainHubAddress The new main hub address
   */
  event MainHubChange(address oldMainHubAddress, address newMainHubAddress);

  /**
   * @notice Emitted whenever the metadata base URI is updated by the super admin
   * @param oldBaseURI The old base URI
   * @param newBaseURI The new base URI
   */
  event MetadataBaseURIChange(string oldBaseURI, string newBaseURI);

  /**
   * @notice Returns the current `MainHub` address connected to the contract
   * @return hubAddress The `MainHub` address
   */
  function mainHubAddress() external view returns (address hubAddress);

  /**
   * @notice Sets the connected `MainHub` address
   * @param mainHubAddress The new `MainHub` address
   */
  function setMainHub(address mainHubAddress) external;

  /**
   * @dev Mints a new token.
   * @notice This function can only be called by a validated
   *         `ProjectDiamond` within the connected `MainHub` instance.
   * @param beneficiary The address of the token beneficiary (account to receive the token)
   * @param certificateId The certificate id within the caller project
   * @return newTokenId The newly minted token id
   * @dev The `ProjectDiamond` address is inferred from `msg.sender`
   */
  function createFromCertificate(
    address beneficiary,
    uint256 certificateId
  ) external returns (uint256 newTokenId);

  /**
   * @notice Returns the certificate owner based on the project address and certificate id
   * @param projectAddress The address of the token project
   * @param certificateId The certificate id within the project
   * @return ownerAddress The certificate owner account address
   */
  function getCertificateOwner(
    address projectAddress,
    uint256 certificateId
  ) external view returns (address ownerAddress);

  /**
   * @notice Returns the project address connected to the NFT token
   * @param tokenId The token id
   * @return projectAddress The token project address connected to the token id
   */
  function getTokenProjectAddress(uint256 tokenId) external view returns (address projectAddress);

  /**
   * @notice Returns a NFT token id derived from the project address and certificate id
   * @param projectAddress The address of the token project
   * @param certificateId The certificate id within the project
   * @return tokenId The resulting token id
   * @dev The token id is the `uint256` representation of the
   * `keccak256` hash of the token project address and the certificate id
   */
  function getTokenId(
    address projectAddress,
    uint256 certificateId
  ) external pure returns (uint256 tokenId);

  /**
   * @notice Returns the token triplet for a token id
   * @param tokenId The token id
   * @return triplet The token triplet
   * @dev The token triplet contains the token id, project address and certificate id
   */
  function getTokenTriplet(uint256 tokenId) external view returns (TokenTriplet memory triplet);

  /**
   * @notice Returns the count of tokens a user has globally
   * @param account The account address
   * @return tokenCount The count of tokens the user has
   * @dev This includes all tokens across all projects
   */
  function getAccountTokenCount(address account) external view returns (uint256 tokenCount);

  /**
   * @notice Returns all the tokens an account has globally, paginated.
   * @param account The account address
   * @param offset The offset to start from.
   * @param limit The limit of tokens to return.
   * @return tokens The tokens array.
   * @dev This includes all tokens across all projects
   */
  function getAccountPaginatedTokens(
    address account,
    uint256 offset,
    uint256 limit
  ) external view returns (TokenTriplet[] memory tokens);

  /**
   * @notice Returns the projects an account has at least 1 token in, paginated.
   * @param account The account address
   * @param offset The offset to start from.
   * @param limit The limit of projects to return.
   * @return projectAddresses The project addresses array.
   */
  function getAccountPaginatedProjects(
    address account,
    uint256 offset,
    uint256 limit
  ) external view returns (address[] memory projectAddresses);

  /**
   * @notice Returns the amount of tokens a user has scoped to a specific project
   * @param account The account address
   * @param projectAddress The project address
   * @return tokenCount The amount of tokens
   */
  function getAccountTokenCountByProject(
    address account,
    address projectAddress
  ) external view returns (uint256 tokenCount);

  /**
   * @notice Returns the token ids an account has, per project, paginated.
   * @param account The account address
   * @param projectAddress The project address
   * @param offset The offset to start from
   * @param limit The limit of tokens to return
   * @return triplets The tokens triplets array
   */
  function getAccountPaginatedTokensByProject(
    address account,
    address projectAddress,
    uint256 offset,
    uint256 limit
  ) external view returns (TokenTriplet[] memory triplets);

  /**
   * @notice It is called by a `ProjectDiamond` when a certificate needs to be burned.
   * Merging certificates, for example, is a common use case
   * @param certificateId The certificate id
   * @dev This function validates if the caller is a valid `ProjectDiamond` inside the `MainHub`.
   */
  function certificateBurnedCallback(uint256 certificateId) external;

  /**
   * @notice It is called by a `ProjectDiamond` when a certificate NFT needs to be updated
   * @notice This is useful for updating metadata on Marketplaces
   * @param certificateId The certificate id
   * @dev This function does not validate the caller and can be used to force metadata updates
   */
  function certificateUpdatedCallback(uint256 certificateId) external;

  /**
   * @notice Represents the URI for the contract metadata
   * @return uri The contract URI
   * @dev It inherits baseURI set by the platform
   */
  function contractURI() external view returns (string memory uri);

  /**
   * @notice Represents the URI for the token metadata
   * @param tokenId The token id
   * @return uri The token URI
   * @dev It inherits baseURI set by the platform
   */
  function tokenURI(uint256 tokenId) external view returns (string memory uri);

  /**
   * @notice Sets the token metadata base URI to be used as a prefix for the tokenURI
   * @param newMetadataBaseURI The new metadata base URI
   * @dev This function can only be called by a platform super admin
   */
  function setMetadataBaseURI(string memory newMetadataBaseURI) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

/**
 * @title IDiamondCut
 * @notice Inspired by [EIP-2535 Diamond interface](https://eips.ethereum.org/EIPS/eip-2535)
 * @dev This interface is used by the diamondCut function of the Diamond contract
 * to execute a cut on the diamond
 */
interface IDiamondCut {
  /**
   * @notice Enum for the action to be taken on a given facet
   * - **Add:** Add a new facet to the diamond
   * - **Replace:** Replace the functions of a facet in the diamond
   * - **Remove:** Remove a facet from the diamond
   */
  enum FacetCutAction {
    Add,
    Replace,
    Remove
  }

  /**
   * @notice Represents a cut to a diamond
   * @param facetAddress The facet address to be added, replaced, or removed
   * @param action The action to be taken on the given facet
   * @param functionSelectors The selectors to be added or removed
   */
  struct FacetCut {
    address facetAddress;
    FacetCutAction action;
    bytes4[] functionSelectors;
  }

  /**
   * @notice Add/replace/remove any number of functions and optionally execute a function with
   * delegatecall
   * @param diamondCutFacetCut Contains the facet addresses and function selectors
   * @param initAddress The address of the contract or facet to execute initCalldata
   * @param initCalldata A function call, including function selector and arguments
   * @dev initCalldata is executed with delegatecall on initAddress
   */
  function diamondCut(
    FacetCut[] calldata diamondCutFacetCut,
    address initAddress,
    bytes calldata initCalldata
  ) external;

  /**
   * @notice Event emitted when diamondCut is called
   * @param diamondCut Contains the facet addresses and function selectors
   * @param initAddress The address of the contract or facet to execute initCalldata
   * @param initCalldata A function call, including function selector and arguments
   * @dev initCalldata is executed with delegatecall on initAddress
   */
  event DiamondCut(FacetCut[] diamondCut, address initAddress, bytes initCalldata);
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.25;

import {InitArgs} from "../types/Structs.sol";

/**
 * @title IDiamondInit
 * @notice Inspired by [EIP-2535 Diamond interface](https://eips.ethereum.org/EIPS/eip-2535)
 * @dev The IDiamondInit contract defines the init function used by the diamond
 * @dev It is an Interface so that it can be imported and used in other contracts
 */
interface IDiamondInit {
  /**
   * @notice The init function is called by the diamondCut function
   * @param args The arguments needed to initialize the diamond
   */
  function init(InitArgs calldata args) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

/**
 * @title IDiamondLoupe
 * @notice Inspired by [EIP-2535 Diamond interface](https://eips.ethereum.org/EIPS/eip-2535)
 * @dev A loupe is a small magnifying glass used to look at diamonds.
 * These functions look at diamonds and facet addresses and are expected to be called frequently by tools.
 */
interface IDiamondLoupe {
  /**
   * @notice Facet
   * @param facetAddress The facet address.
   * @param functionSelectors The function selectors.
   */
  struct Facet {
    address facetAddress;
    bytes4[] functionSelectors;
  }

  /**
   * @notice Gets all facet addresses and their four byte function selectors.
   * @return facets The facet addresses and their four byte function selectors.
   */
  function facets() external view returns (Facet[] memory facets);

  /**
   * @notice Gets all the function selectors supported by a specific facet.
   * @param facet The facet address.
   * @return facetFunctionSelectors The facet function selectors.
   */
  function facetFunctionSelectors(
    address facet
  ) external view returns (bytes4[] memory facetFunctionSelectors);

  /**
   * @notice Get all the facet addresses used by a diamond.
   * @return facetAddresses Facet addresses list
   */
  function facetAddresses() external view returns (address[] memory facetAddresses);

  /**
   * @notice Gets the facet that supports the given selector.
   * @dev If facet is not found return address(0).
   * @param functionSelector The function selector.
   * @return facetAddress The facet address.
   */
  function facetAddress(bytes4 functionSelector) external view returns (address facetAddress);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

interface IERC165 {
  /**
   * @notice Checks if the contract supports an interface
   * @param interfaceId The interface identifier, as specified in ERC-165
   * @return isSupported `true` if the contract supports `interfaceId`, `false` otherwise
   * @dev This function uses less than 30,000 gas
   */
  function supportsInterface(bytes4 interfaceId) external view returns (bool isSupported);
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.25;

import {ProjectArgs} from "../types/Structs.sol";

import {IDiamondCut} from "./IDiamondCut.sol";
import {IDiamondInit} from "./IDiamondInit.sol";

interface IMainHub {
  // ---------------------------------------------
  // enums
  // ---------------------------------------------

  /**
   * @notice ChargeType is an enum to represent the different types of charges
   * - **PERCENTAGE** The charge is a percentage of the original amount
   * - **FLAT** The charge is a flat amount
   */
  enum ChargeType {
    PERCENTAGE,
    FLAT
  }

  /**
   * @notice FeeType is an enum to represent the different types of fees
   * - **PROJECT_CREATION** The fee for creating a project
   * - **REWARD_SLOT_CREATION** The fee for creating a reward slot
   * - **REWARD_DEPOSIT** The fee for depositing rewards
   * - **EARLY_WITHDRAWAL** The fee for early withdrawal (taken from the project owner when a user withdraws early from a reward slot)
   * - **CERTIFICATE_LIQUIDATION** The fee for liquidating a certificate
   * - **REWARD_COMPOUNDING** The fee for compounding rewards
   */
  enum FeeType {
    PROJECT_CREATION,
    REWARD_SLOT_CREATION,
    REWARD_DEPOSIT,
    EARLY_WITHDRAWAL,
    CERTIFICATE_LIQUIDATION,
    REWARD_COMPOUNDING
  }

  // ---------------------------------------------
  // structs
  // ---------------------------------------------

  /**
   * @notice FeeToken is a struct to represent the token used for fees
   * @param tokenAddress The address of the token
   * @param isEther Whether the token is Ether
   * @param isAnyToken Whether to accept any token
   */
  struct FeeToken {
    address tokenAddress;
    bool isEther;
    bool isAnyToken;
  }

  /**
   * @notice HolderDiscount is a struct to represent the discount for holders
   * @param percentage The percentage of the discount
   * @param requiredBalance The required balance to receive the discount
   */
  struct HolderDiscount {
    uint256 percentage;
    uint256 requiredBalance;
  }

  /**
   * @notice HolderDiscountTier is a struct to represent the discount tiers for holders
   * @param tokenAddress The address of the token
   * @param discountTiers The discount tiers
   */
  struct HolderDiscountTier {
    address tokenAddress;
    HolderDiscount[] discountTiers;
  }

  /**
   * @notice PlatformFee is a struct to represent the fees for the platform
   * @param chargeType The type of charge (percentage or flat)
   * @param chargeAmount The amount of the charge
   * @param feeToken The token used for the fee
   * @param holderDiscountTier The discount tier for holders
   */
  struct PlatformFee {
    ChargeType chargeType;
    uint256 chargeAmount;
    FeeToken feeToken;
    HolderDiscountTier holderDiscountTier;
  }

  /**
   * @notice RoyaltyFee is a struct to represent the royalty fee for a project
   * @param active Whether the royalty fee is active
   * @param percentage The percentage of the royalty fee
   */
  struct RoyaltyFee {
    bool active;
    uint256 percentage;
  }

  /**
   * @notice ProjectDiamondData is a struct to represent the diamond data for a project
   * @param diamondCutFacetAddress The address of the diamond cut facet
   * @param diamondInitAddress The address of the diamond init
   * @param cuts The facet cuts for the diamond
   */
  struct ProjectDiamondData {
    address diamondCutFacetAddress;
    address diamondInitAddress;
    IDiamondCut.FacetCut[] cuts;
  }

  // ---------------------------------------------
  // errors
  // ---------------------------------------------

  /**
   * @notice Error for when the address is the zero address
   * @dev Used when the zero address could catastrophically affect the system
   */
  error ZeroAddress();

  /**
   * @notice Error for when the address is not a project
   */
  error NotAProject();

  /**
   * @notice Error for when the charge type for quoting/payment is invalid
   */
  error InvalidChargeType();

  /**
   * @notice Error for when the sent ether is insufficient
   */
  error InsufficientEth();

  /**
   * @notice Error for when the fee cannot be sent to the recipient
   */
  error SendFeeFailed();

  /**
   * @notice Error for when ETH is sent directly to the MainHub
   */
  error CannotReceiveEther();

  /**
   * @notice Error for when the fee is too high
   */
  error FeeTooHigh();

  /**
   * @notice Error for when the token for payment is not a valid token
   * @param expectedTokenAddress The expected token address
   * @param receivedTokenAddress The received token address
   */
  error InvalidPaymentToken(address expectedTokenAddress, address receivedTokenAddress);

  /**
   * @notice Error for when the allowance is insufficient
   */
  error InsufficientAllowance();

  /**
   * @notice Error for when the token balance is insufficient
   * @param expectedBalance The expected balance
   * @param actualBalance The actual balance
   */
  error InsufficientTokenBalance(uint256 expectedBalance, uint256 actualBalance);

  // ---------------------------------------------
  // events
  // ---------------------------------------------

  /**
   * @notice Event emitted when a project is created
   * @param projectAddress The address of the project
   * @param baseTokenAddress The address of the base token
   */
  event ProjectCreated(address indexed projectAddress, address indexed baseTokenAddress);

  event FeeRecipientAddressChange(address oldFeeRecipientAddress, address newFeeRecipientAddress);

  event SuperAdminAddressChange(address oldSuperAdminAddress, address newSuperAdminAddress);

  event CertificateNFTManagerAddressChange(
    address oldCertificateNFTManagerAddress,
    address newCertificateNFTManagerAddress
  );

  event TokenRouterAddressChange(address oldTokenRouterAddress, address newTokenRouterAddress);

  /**
   * @notice Event emitted when a project diamond data is changed
   * @param newDiamondData The new diamond data, see ProjectDiamondData struct
   */
  event ProjectDiamondDataChange(ProjectDiamondData newDiamondData);

  /**
   * @notice Event emitted when a royalty fee is changed
   * @param projectAddress (indexed) The project address
   * @param newRoyaltyFee The new royalty fee, see RoyaltyFee struct
   */
  event RoyaltyFeeChange(address indexed projectAddress, RoyaltyFee newRoyaltyFee);

  /**
   * @notice Event emitted when a royalty fee is removed
   * @param projectAddress (indexed) The project address
   */
  event RoyaltyFeeRemoval(address indexed projectAddress);

  /**
   * @notice Event emitted when a platform fee is changed
   * @param beneficiary {indexed} The beneficiary of the fee
   * @param feeType {indexed} The type of fee (FeeType enum)
   * @param newFee The new fee details, see PlatformFee struct
   */
  event PlatformFeeChange(address indexed beneficiary, FeeType indexed feeType, PlatformFee newFee);

  // ---------------------------------------------
  // getters
  // ---------------------------------------------

  /**
   * @notice Returns the version of the MainHub.
   */
  function version() external pure returns (uint256);

  /**
   * @notice Returns the root admin address for projects created by the main hub.
   */
  function superAdminAddress() external view returns (address);

  /**
   * @notice Returns the current platform fee recipient address.
   * @return feeRecipient The fee recipient address.
   */
  function feeRecipientAddress() external view returns (address feeRecipient);

  /**
   * @notice Returns the `CertificateNFTManager` address.
   * @dev This contract controls the NFT minting and ownerships.
   * @return nftManagerAddress The `CertificateNFTManager` address.
   */
  function getCertificateNFTManagerAddress() external view returns (address nftManagerAddress);

  /**
   * @notice Returns the `TokenRouter` address.
   * @dev The `TokenRouter` is used to interact with Uniswap, among other things.
   * @return tokenRouterAddress The `TokenRouter` address.
   */
  function getTokenRouterAddress() external view returns (address tokenRouterAddress);

  /**
   * @notice Checks if an address is a project.
   * @param projectAddress The project address.
   * @return isProject Whether the address is a project.
   */
  function isProject(address projectAddress) external view returns (bool isProject);

  /**
   * @notice Returns the projects count.
   * @return projectsCount The projects count.
   * @dev This function is used for pagination.
   */
  function getProjectsCount() external view returns (uint256 projectsCount);

  /**
   * @notice Returns the projects paginated.
   * @param offset The offset to start from.
   * @param limit The limit.
   * @return projects The projects.
   */
  function getPaginatedProjects(
    uint256 offset,
    uint256 limit
  ) external view returns (address[] memory projects);

  /**
   * @notice Returns the deposit tokens count.
   * @return tokensCount The deposit tokens count.
   * @dev This function is used for pagination.
   */
  function getDepositTokensCount() external view returns (uint256 tokensCount);

  /**
   * @notice Returns the deposit tokens paginated.
   * @param offset The offset.
   * @param limit The limit.
   * @return tokens The deposit tokens.
   */
  function getPaginatedDepositTokens(
    uint256 offset,
    uint256 limit
  ) external view returns (address[] memory tokens);

  /**
   * @notice Returns paginated projects by deposit token.
   * @param depositTokenAddress The deposit token address.
   * @param offset The offset.
   * @param limit The limit.
   */
  function getPaginatedProjectsByDepositToken(
    address depositTokenAddress,
    uint256 offset,
    uint256 limit
  ) external view returns (address[] memory projects);

  /**
   * @notice Gets the unique deployer addresses count.
   * @return count The deployer addresses count.
   * @dev This function is used for pagination.
   */
  function getDeployerAddressesCount() external view returns (uint256 count);

  /**
   * @notice Returns the unique deployer addresses in paginated format.
   * @param offset The offset to start from.
   * @param limit The limit of deployer addresses to return.
   * @return deployerAddresses The deployer addresses array.
   */
  function getPaginatedDeployerAddresses(
    uint256 offset,
    uint256 limit
  ) external view returns (address[] memory deployerAddresses);

  /**
   * @notice Returns the count of projects deployed by an address.
   * @dev This function is used for pagination.
   * @param deployerAddress The deployer address.
   * @return The count of projects deployed by the address.
   */
  function getProjectsCountByDeployerAddress(
    address deployerAddress
  ) external view returns (uint256);

  /**
   * @notice Returns paginated projects by deployer address.
   * @param deployerAddress The deployer address.
   * @param offset The offset.
   * @param limit The limit.
   * @return projects The projects.
   */
  function getPaginatedProjectsByDeployerAddress(
    address deployerAddress,
    uint256 offset,
    uint256 limit
  ) external view returns (address[] memory projects);

  /**
   * @notice Returns a preview quote for a specific fee.
   * @param feeType The fee type.
   * @param accountPaying The account paying the fee.
   * @param originalAmount The original amount.
   * @return chargeToken The token address to charge.
   * @return chargeAmount The amount to charge.
   */
  function previewFee(
    FeeType feeType,
    address accountPaying,
    uint256 originalAmount
  ) external view returns (address chargeToken, uint256 chargeAmount);

  /**
   * @notice Returns the certificate manager address.
   * @return nftManagerAddress The certificate manager address.
   */
  function certificateNFTManagerAddress() external view returns (address nftManagerAddress);

  /**
   * @notice This function is used to get the fee details.
   * @param feeType The fee type.
   * @param accountPaying The account paying the fee.
   * @return feeDetails The fee details.
   */
  function getPlatformFee(
    FeeType feeType,
    address accountPaying
  ) external view returns (PlatformFee memory feeDetails);

  /**
   * @notice This function is used to get the current royalty fee.
   * @param projectAddress The project address.
   * @return royaltyFee The current royalty fee.
   */
  function getRoyaltyFee(address projectAddress) external view returns (uint256 royaltyFee);

  // ---------------------------------------------
  // setters
  // ---------------------------------------------

  /**
   * @notice Sets the certificate manager address.
   * @param newCertificateNFTManagerAddress The address of the certificate manager.
   * @dev Only the root admin can call this function.
   */
  function setCertificateNFTManagerAddress(address newCertificateNFTManagerAddress) external;

  /**
   * @notice Sets the fee recipient address.
   * @param newFeeRecipientAddress The address of the fee recipient.
   * @dev Only the root admin can call this function.
   */
  function setFeeRecipientAddress(address newFeeRecipientAddress) external;

  /**
   * @notice Sets the super admin address.
   * @param newSuperAdminAddress The address of the super admin.
   * @dev Only the root admin can call this function.
   */
  function setSuperAdminAddress(address newSuperAdminAddress) external;

  /**
   * @notice Sets the TokenRouter address.
   * @param newTokenRouterAddress The address of the TokenRouter.
   * @dev Only the root admin can call this function.
   */
  function setTokenRouterAddress(address newTokenRouterAddress) external;

  /**
   * @notice Sets the project facet cuts.
   * @param data The project diamond data.
   * @dev Only the root admin can call this function.
   */
  function setProjectDiamondData(ProjectDiamondData calldata data) external;

  /**
   * @notice Sets the platform fee.
   * @param feeType The fee type.
   * @param platformFee The platform fee.
   * @param accountOverride The account to override the fee for.
   * @dev Only the root admin can call this function.
   */
  function setPlatformFee(
    FeeType feeType,
    PlatformFee calldata platformFee,
    address accountOverride
  ) external;

  /**
   * @notice Sets the royalty fee in the Marketplace for a project.
   * @param projectAddress The project address to set the royalty fee for.
   * @param royaltyFee The royalty fee to set bps (1/100000).
   * @dev Use address(0) for global default.
   */
  function setRoyaltyFee(address projectAddress, uint256 royaltyFee) external;

  /**
   * @notice This function effectively charges the fee.
   * @param feeType The fee type.
   * @param accountPaying The account paying the fee.
   * @param paymentTokenAddress The payment token address suggested by the project (will be checked against the fee token)
   * @param originalAmount The original amount.
   * @return chargeAmount The amount charged.
   */
  function payFee(
    FeeType feeType,
    address accountPaying,
    address paymentTokenAddress,
    uint256 originalAmount
  ) external returns (uint256 chargeAmount);

  // ---------------------------------------------
  // project creation
  // ---------------------------------------------

  /**
   * @notice Creates a project.
   * @param projectArgs The init args.
   * @return projectAddress The project address.
   */
  function createProject(
    ProjectArgs calldata projectArgs
  ) external payable returns (address projectAddress);
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.25;

import {IDiamondCut} from "./IDiamondCut.sol";
import {IDiamondLoupe} from "./IDiamondLoupe.sol";

import {IAccessControlFacet} from "./facets/IAccessControlFacet.sol";
import {IAssetRecoveryFacet} from "./facets/IAssetRecoveryFacet.sol";
import {IBalanceFacet} from "./facets/IBalanceFacet.sol";
import {ICertificateFacet} from "./facets/ICertificateFacet.sol";
import {ICycleFacet} from "./facets/ICycleFacet.sol";
import {IExitAndLiquidationFacet} from "./facets/IExitAndLiquidationFacet.sol";
import {IReadingFacet} from "./facets/IReadingFacet.sol";
import {IRewardFacet} from "./facets/IRewardFacet.sol";
import {ISettingsFacet} from "./facets/ISettingsFacet.sol";
import {IVerificationFacet} from "./facets/IVerificationFacet.sol";

import {IEvents} from "../types/Events.sol";
import {ISharedErrors} from "../types/Errors.sol";
import {ShareType} from "../types/Enums.sol";

import {IERC165} from "./IERC165.sol";

/**
 * @title IProjectDiamond
 * @notice The interface for the `ProjectDiamond` contract
 * @notice Relevant interfaces:
 * - `IEvents`: Events used by the project
 * - `ISharedErrors`: Shared errors used by the project
 * - `IAccessControlFacet`: Manages access control and roles
 * - `IAssetRecoveryFacet`: `Platform Admin only` Recovers stuck assets that are not part of the project
 * - `IBalanceFacet`: Manages the balance of certificates
 * - `ICertificateFacet`: Manages certificates
 * - `ICycleFacet`: Manages cycles (reward distribution periods)
 * - `IExitAndLiquidationFacet`: Manages exits (quick depositToken and rewardTokens withdrawals) and liquidations (sell the depositToken and rewardTokens for ETH)
 * - `IReadingFacet`: Allows querying project's data in a human-readable format, compatible with `JSON` consumers
 * - `IRewardFacet`: Manages and distributes rewards (rewardTokens) to certificate holders, respecting the distribution rules
 * - `ISettingsFacet`: Manages the settings of the project (flags and data). The settings are used to control the project's behaviour
 * - `IVerificationFacet`: Manages the verification level of the project. The verification level is used in the frontend to display the project's status
 */
interface IProjectDiamond is
  IEvents,
  ISharedErrors,
  IDiamondCut,
  IDiamondLoupe,
  IAccessControlFacet,
  IAssetRecoveryFacet,
  IBalanceFacet,
  ICertificateFacet,
  ICycleFacet,
  IExitAndLiquidationFacet,
  IReadingFacet,
  IRewardFacet,
  ISettingsFacet,
  IVerificationFacet,
  IERC165
{
  // * this interface combines all the facets into one interface
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.25;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title IWETH
 * @notice The IWETH contract defines the interface for the Wrapped Ether token
 * @dev It is an Interface so that it can be imported and used in other contracts
 */
interface IWETH is IERC20 {
  /**
   * @notice `payable` Deposit ether to get wrapped ether
   */
  function deposit() external payable;

  /**
   * @notice Withdraw wrapped ether to get ether
   * @param amount The amount of wrapped ether to withdraw
   */
  function withdraw(uint256 amount) external;
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.25;

import {
  IAccessControlEnumerableUpgradeable
} from "../../helpers/access/IAccessControlEnumerableUpgradeable.sol";

import {AvailableRoles} from "../../types/Structs.sol";

/**
 * @title IAccessControlFacet
 * @notice Extends the AccessControlEnumerableUpgradeable contract interface
 * @dev This contract allows for the management and reading of access control roles
 */
interface IAccessControlFacet is IAccessControlEnumerableUpgradeable {
  /**
   * @notice Gets the available roles for the project
   * @return availableRoles The available roles
   */
  function getAvailableRoles() external pure returns (AvailableRoles memory availableRoles);
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.25;

/**
 * @title IAssetRecoveryFacet
 * @notice The AssetRecoveryFacet contract interface
 * @notice **This is a security feature to ensure that no assets are locked in the contract**
 * @dev This contract allows for the recovery of assets from the contract
 */
interface IAssetRecoveryFacet {
  /**
   * @notice Recovers an ERC20 token from the contract
   * @notice **This ensures that the token is not the deposit token or a reward token**
   * @param tokenAddress The address of the token to recover
   * @dev Only the admin can call this function
   */
  function recoverERC20(address tokenAddress) external;

  /**
   * @notice Recovers all ETH from the contract
   * @notice **This is safe because the contract is not supposed to hold any ETH, just WETH**
   * @dev Only the admin can call this function
   */
  function recoverETH() external;
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.25;

/**
 * @title IBalanceFacet
 * @notice The BalanceFacet contract interface
 * @dev This contract allows for the management of certificate balances
 */
interface IBalanceFacet {
  /**
   * @notice Returns the balance of a certificate
   * @param certificateId The Certificate ID to get the balance for
   * @return balance The balance of the certificate
   */
  function balanceOf(uint256 certificateId) external view returns (uint256 balance);

  /**
   * @notice Deposits tokens in the pool to earn rewards
   * @param certificateId The Certificate to deposit tokens for
   * @param amount The amount of tokens to deposit
   */
  function deposit(uint256 certificateId, uint256 amount) external;

  /**
   * @notice Deposits tokens in the pool to earn rewards
   * @param certificateId The Certificate to deposit tokens for
   * @param amount The amount of tokens to deposit
   * @param ignoreEarlyWithdrawal Whether to ignore the early withdrawal period
   * @param ignoreTransferFrom Whether to ignore the transferFrom call
   * @dev This function is only callable by the contract itself
   */
  function deposit(
    uint256 certificateId,
    uint256 amount,
    bool ignoreEarlyWithdrawal,
    bool ignoreTransferFrom
  ) external;

  /**
   * @notice Deposits tokens in the pool to earn rewards in behalf of a user
   * @param certificateId The Certificate ID to deposit tokens for
   * @param amount The amount of tokens to deposit
   * @dev This function is only callable by the project manager
   */
  function depositFor(uint256 certificateId, uint256 amount) external;

  /**
   * @notice Withdraws tokens from the pool
   * @param certificateId The Certificate to withdraw tokens from
   * @param desiredAmount The amount of tokens to withdraw
   * @return withdrawAmount The amount of tokens actually withdrawn after fees
   */
  function withdraw(
    uint256 certificateId,
    uint256 desiredAmount
  ) external returns (uint256 withdrawAmount);

  /**
   * @notice Withdraws tokens from the pool
   * @param certificateId The Certificate to withdraw tokens from
   * @param amount The amount of tokens to withdraw
   * @param overrideRecipient The address to send the tokens to
   * @return withdrawAmount The amount of tokens actually withdrawn after fees
   */
  function withdraw(
    uint256 certificateId,
    uint256 amount,
    address overrideRecipient
  ) external returns (uint256 withdrawAmount);

  /**
   * @notice Enforces that the minimum deposit is reached for other facets
   * @param certificateId The Certificate ID to check the minimum deposit for
   * @param amount The amount to check against the minimum deposit
   * @dev This function will revert if the minimum deposit is not reached
   */
  function enforceMinimumDeposit(uint256 certificateId, uint256 amount) external view;
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.25;

/**
 * @title ICertificateFacet
 * @notice The CertificateFacet contract interface
 * @dev This contract allows for the management of certificates
 */
interface ICertificateFacet {
  /**
   * @notice Gets the certificate owner
   * @param certificateId The certificate ID to check
   * @return ownerAddress The address of the certificate owner
   */
  function ownerOf(uint256 certificateId) external view returns (address ownerAddress);

  /**
   * @notice Checks if a certificate is frozen
   * @param certificateId The certificate ID to check
   * @return isFrozen Whether the certificate is frozen
   * @return frozenUntil The time remaining until the certificate is unfrozen
   */
  function isCertificateFrozen(
    uint256 certificateId
  ) external view returns (bool isFrozen, uint256 frozenUntil);

  /**
   * @notice Creates a new certificate that wraps token shares and mints a new NFT
   * @notice representing the certificate. The certificate ID is returned.
   * @param shareAmount The amount of token shares to be added to the certificate
   * @return newCertificateId The newly created certificate ID
   */
  function createTShareCertificate(uint256 shareAmount) external returns (uint256 newCertificateId);

  /**
   * @notice Creates a new certificate that wraps virtual shares and mints new NFTs
   * @notice representing the certificates. The certificate IDs are returned.
   * @param shareAmount The amount of virtual shares to be added to the certificate
   * @param certificateCount The number of certificates to create
   * @return certificateIds The newly created certificate IDs in an array
   */
  function createVShareCertificate(
    uint256 shareAmount,
    uint256 certificateCount
  ) external returns (uint256[] memory certificateIds);

  /**
   * @notice Merges two certificates of the same type and returns the new certificate ID
   * @param certificateId1 The first certificate ID to merge
   * @param certificateId2 The second certificate ID to merge
   * @return newCertificateId Is actually `certificateId1` if the merge was successful
   */
  function mergeCertificates(
    uint256 certificateId1,
    uint256 certificateId2
  ) external returns (uint256 newCertificateId);

  /**
   * @notice Splits a certificate into two certificates and returns the new certificate ID
   * @param certificateId The certificate ID to split
   * @param percentageToKeep The percentage of the certificate to keep `(1_000 = 1%)`
   * @return originalCertificateId The original certificate ID
   * @return newCertificateId The new certificate ID
   */
  function splitCertificate(
    uint256 certificateId,
    uint256 percentageToKeep
  ) external returns (uint256 originalCertificateId, uint256 newCertificateId);

  /**
   * @notice Updates the certificate state. This function is called by various facets
   *         to update the certificate state when certain actions are performed.
   * @param certificateId The certificate ID to update
   */
  function updateCertificateState(uint256 certificateId) external;

  /**
   * @notice Receives a notification from the certificate manager that a certificate
   *         has been burned. This function will withdraw the deposit and rewards
   *         from the certificate and remove it from the ledger.
   * @param certificateId The certificate ID that has been burned
   * @dev This function can only be called by the CertificateNFTManager contract.
   */
  function certificateBurnedCallback(uint256 certificateId) external;

  /**
   * @notice Ensures that the caller is the certificate owner.
   * @param certificateId The Certificate to check.
   * @param account The account to check.
   * @dev This function will revert if the certificate owner is not the account.
   */
  function enforceCertificateOwnership(uint256 certificateId, address account) external view;

  /**
   * @notice Ensures that the certificate is not frozen
   * @param certificateId The Certificate to check
   * @notice This function will revert if the certificate is frozen
   */
  function enforceCertificateNotFrozen(uint256 certificateId) external view;

  /**
   * @notice Freezes the NFT certificate transfer when it's balance is changed
   *         or rewards are withdrawn
   * @param certificateId The Certificate to freeze
   */
  function freezeCertificateTransfer(uint256 certificateId) external;
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.25;

/**
 * @title ICycleFacet
 * @notice ICycleFacet is the interface for the CycleFacet contract.
 * @dev This contract is responsible for managing the cycle state of the project.
 */
interface ICycleFacet {
  /**
   * @notice Updates the state of the cycle. This function is called by various facets
   *         to update the cycle state when certain actions are performed.
   * @param cycleId The cycle ID.
   * @dev This function is payable to allow delegatecalls to it while the caller is receiving ether.
   */
  function updateCycleState(uint256 cycleId) external payable;

  /**
   * @notice Returns the remaining time (in seconds) for the cycle to end.
   * @param cycleId The cycle ID.
   * @return remainingTime The time remaining (in seconds) for the cycle to end.
   */
  function cycleTimeRemaining(uint256 cycleId) external view returns (uint256 remainingTime);

  /**
   * @notice Returns the last time the cycle is applicable. This timestamp is a `Math.min` of the
   *        cycle finish time and the current `block.timestamp`.
   * @param cycleId The cycle ID.
   * @return lastTimeApplicable The last time the cycle is applicable.
   */
  function lastTimeCycleApplicable(
    uint256 cycleId
  ) external view returns (uint256 lastTimeApplicable);

  /**
   * @notice Starts a new cycle.
   * @param cycleDuration The duration of the cycle (in seconds).
   * @param issueCertificateIfNone A flag to issue a certificate upon cycle start if none exists.
   */
  function startNewCycle(uint256 cycleDuration, bool issueCertificateIfNone) external;

  /**
   * @notice Extends the duration of the cycle.
   * @param secondsToIncrease The number of seconds to increase the cycle duration by.
   * @dev The cycle duration cannot be less than 60 seconds.
   * @dev The extension is only applicable if the manager owns 100% of the certificates.
   * @dev Only the manager can call this function.
   */
  function extendCycleDuration(uint256 secondsToIncrease) external;
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.25;

/**
 * @title IExitAndLiquidationFacet
 * @notice The ExitAndLiquidationFacet contract interface
 * @dev This contract allows for the exiting and liquidation of certificates
 */
interface IExitAndLiquidationFacet {
  /**
   * @notice Exits or Liquidates a certificate
   * - Exiting a certificate will withdraw the user's funds and rewards
   * - Liquidating a certificate will sell the user's funds and rewards at market and transfer the ether proceeds to the user
   * @param certificateId Certificate ID to exit
   * @param slippageTolerance Slippage tolerance for the exit
   * @param shouldLiquidate Whether to liquidate the certificate
   * @dev When `shouldLiquidate === true`, liquidation must be enabled for the project
   * @dev When liquidating, the `slippageTolerance` must be greater than `0`
   */
  function exitOrLiquidate(
    uint256 certificateId,
    uint256 slippageTolerance,
    bool shouldLiquidate
  ) external;
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.25;

import {Outputs} from "../../types/Structs.sol";

interface IReadingFacet {
  /**
   * @notice Gets the project details in readable format
   * @return projectDetails The project details
   */
  function getProjectDetails() external view returns (Outputs.ProjectDetails memory projectDetails);

  /**
   * @notice Gets the cycle by its ID in readable format
   * @param cycleId The cycle ID
   * @return cycleDetails The cycle details
   */
  function getCycleDetails(
    uint256 cycleId
  ) external view returns (Outputs.CycleDetails memory cycleDetails);

  /**
   * @notice Gets the certificate by its ID in readable format
   * @param certificateId The certificate ID
   * @return certificateDetails The certificate details
   */
  function getCertificateDetails(
    uint256 certificateId
  ) external view returns (Outputs.CertificateDetails memory certificateDetails);

  /**
   * @notice Gets the certificate claimable rewards (available for withdrawal)
   * @param certificateId The certificate ID
   * @param rewardTokenAddress The reward token address
   * @return claimableAmount The current claimable rewards amount
   */
  function getCertificateClaimableRewardsForToken(
    uint256 certificateId,
    address rewardTokenAddress
  ) external view returns (uint256 claimableAmount);

  /**
   * @notice Gets the reward token data in readable format
   * @param rewardTokenAddress The reward token address
   * @return slotDetails The reward token slot data
   */
  function getRewardTokenDetails(
    address rewardTokenAddress
  ) external view returns (Outputs.RewardSlotDetails memory slotDetails);

  /**
   * @notice Gets the reward slots details in readable format
   * @return rewardList The reward slots details in an array
   */
  function getAllRewardSlotsDetails()
    external
    view
    returns (Outputs.RewardSlotDetails[] memory rewardList);

  /**
   * @notice Gets the certificate NFT details in readable format
   * @param certificateId The certificate ID
   * @return certificateNFTDetails The certificate NFT details
   * @dev This function is used to render the NFT metadata in external applications.
   */
  function getCertificateNFTDetails(
    uint256 certificateId
  ) external view returns (Outputs.CertificateNFTDetails memory certificateNFTDetails);
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.25;

import {UD60x18} from "@prb/math/src/UD60x18.sol";

/**
 * @title IRewardFacet
 * @notice Interface for the RewardFacet contract.
 * @dev This contract allows for the management of rewards for the project
 *      and the withdrawal of rewards by certificate holders
 */
interface IRewardFacet {
  /**
   * @notice Returns the maximum number of reward slots.
   * @return maxRewardSlots The maximum number of reward slots.
   */
  function MAX_REWARD_SLOTS() external view returns (uint256 maxRewardSlots);

  /**
   * @notice Adds a new reward token to the project
   * @param rewardTokenAddress The address of the reward token to add
   * @dev The Manager or RewardDistributor roles are required to call this function.
   */
  function createRewardTokenSlot(address rewardTokenAddress) external payable;

  /**
   * @notice Register the deposit of token rewards into the pool
   * @param rewardTokenAddress The address of the reward token to deposit
   * @param amount The amount of reward tokens to deposit
   * @dev The Manager or RewardDistributor roles are required to call this function.
   * @dev The reward tokens will be transferred from the caller to the contract
   */
  function depositReward(address rewardTokenAddress, uint256 amount) external payable;

  /**
   * @notice Withdraws a single token rewards from a certificate
   * @param certificateId Certificate ID to withdraw rewards for
   * @param rewardTokenAddress Reward token address to withdraw rewards for
   * @param overrideRecipient Address to override the proceeds recipient
   * @param ignoreFreeze Whether to ignore the freeze
   * @param inETH Whether the reward should be withdrawn in ETH
   * @param slippageTolerance Slippage tolerance for the reward withdrawal
   * @return rewardAmount Amount of rewards actually withdrawn after fees
   * @dev `ignoreFreeze` can only be set to `true` by the contract itself
   *      and will revert if called by an external account
   */
  function withdrawReward(
    uint256 certificateId,
    address rewardTokenAddress,
    address overrideRecipient,
    bool ignoreFreeze,
    bool inETH,
    uint256 slippageTolerance
  ) external returns (uint256 rewardAmount);

  /**
   * @notice Withdraws all tokens rewards from a certificate
   * @param certificateId Certificate to withdraw rewards for
   * @param overrideRecipient Address to override the proceeds recipient
   * @param inETH Whether the reward should be withdrawn in ETH
   * @param slippageTolerance Slippage tolerance for the reward withdrawal
   */
  function withdrawAllRewards(
    uint256 certificateId,
    address overrideRecipient,
    bool inETH,
    uint256 slippageTolerance
  ) external;

  /**
   * @notice Compounds a single token rewards for a certificate by selling them for the underlying token
   * @param certificateId Certificate ID to compound rewards for
   * @param rewardTokenAddress Address of the reward token to compound
   * @param slippageTolerance Slippage tolerance for the reward swap
   */
  function compoundReward(
    uint256 certificateId,
    address rewardTokenAddress,
    uint256 slippageTolerance
  ) external;

  /**
   * @notice Compounds all rewards for a certificate by selling them for the underlying token
   * @param certificateId Certificate ID to compound rewards for
   * @param slippageTolerance Slippage tolerance for the reward swap
   */
  function compoundAllRewards(uint256 certificateId, uint256 slippageTolerance) external;

  /**
   * @notice Allows the project owner to withdraw the rewards that have not been redeemed
   *         after the grace period has passed
   * @param rewardTokenAddress The reward token address to withdraw from
   * @dev This function is used by the project admin to recover rewards that have not yet been
   *      redeemed for a long time and are 'stuck' in the contract
   */
  function withdrawUnredeemedRewards(address rewardTokenAddress) external;
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.25;

import {SettingsFlags, SettingsData} from "../../types/Structs.sol";

/**
 * @title ISettingsFacet
 * @notice Interface for the SettingsFacet contract.
 * @dev The SettingsFacet contract manages the settings of the project.
 *      It is used to store and retrieve the settings flags and data.
 */
interface ISettingsFacet {
  /**
   * @notice Returns the settings flags
   * @return flags The current settings flags
   */
  function settingsFlags() external view returns (SettingsFlags memory flags);

  /**
   * @notice Returns the settings data
   * @return data The current settings data
   */
  function settingsData() external view returns (SettingsData memory data);

  /**
   * @notice Returns the address of the certificate manager contract.
   * @return nftManagerAddress The address of the certificate manager contract.
   */
  function certificateManager() external view returns (address nftManagerAddress);

  /**
   * @notice Returns the address of the deposit token contract.
   * @return tokenAddress The address of the deposit token contract.
   * @dev Returns `address(0x0)` if there's no deposit token set.
   */
  function depositTokenAddress() external view returns (address tokenAddress);

  /**
   * @notice Updates the settings with the given flags and data.
   * @param flags The new settings flags
   * @param data The new settings data
   * @dev The caller must have the `MANAGER` role.
   * @dev The settings will be validated before updating.
   */
  function updateSettings(SettingsFlags calldata flags, SettingsData calldata data) external;
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.25;

import {VerificationLevel} from "../../types/Enums.sol";

/**
 * @title IVerificationFacet
 * @notice The VerificationFacet contract interface
 * @dev This contract allows for the platform superAdmin to manage the project's verification level
 */
interface IVerificationFacet {
  /**
   * @notice Returns the current verification level
   * @return currentLevel The current verification level
   */
  function getVerificationLevel() external view returns (VerificationLevel currentLevel);

  /**
   * @notice Sets the verification level
   * @param level The new verification level
   */
  function setVerificationLevel(VerificationLevel level) external;
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.25;

import {console} from "hardhat/console.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import {IMainHub} from "../interfaces/IMainHub.sol";
import {ICycleFacet} from "../interfaces/facets/ICycleFacet.sol";
import {ICertificateFacet} from "../interfaces/facets/ICertificateFacet.sol";

import {WILDCARD_ADDRESS} from "../types/Constants.sol";
import {ISharedErrors} from "../types/Errors.sol";

import {Percentages} from "../periphery/utils/Percentages.sol";
import {ProjectStorage} from "../storages/ProjectStorage.sol";

import {
  Cycle,
  Certificate,
  RewardSlot,
  ProjectData,
  SettingsFlags,
  SettingsData
} from "../types/Structs.sol";

import {LibRouter} from "./LibRouter.sol";

library LibCommon {
  using SafeERC20 for IERC20;
  using EnumerableSet for EnumerableSet.UintSet;
  using EnumerableSet for EnumerableSet.AddressSet;

  /**
   * @notice Gets a Cycle by its ID
   * @param cycleId The ID of the cycle
   * @return cycle The Cycle storage instance
   */
  function getCycleById(uint256 cycleId) internal view returns (Cycle storage cycle) {
    return ProjectStorage.get().cycles[cycleId];
  }

  /**
   * @notice Gets the latest cycle available
   * @return latestCycle The current cycle
   */
  function getLatestCycle() internal view returns (Cycle storage latestCycle) {
    ProjectData storage pd = ProjectStorage.get();
    return pd.cycles[pd.cycleCount];
  }

  /**
   * @notice Gets the latest cycle ID
   * @return latestCycleId The latest cycle ID
   */
  function getLatestCycleId() internal view returns (uint256 latestCycleId) {
    return ProjectStorage.get().cycleCount;
  }

  /**
   * @notice Gets the active cycle. If the current block timestamp is less than the
   * reward finish time, then the active cycle is the running cycle. Otherwise,
   * the active cycle is the next cycle.
   * @return cycleFound Whether the active cycle was found
   * @return activeCycle The active cycle
   */
  function tryGetActiveCycle() internal view returns (bool cycleFound, Cycle storage activeCycle) {
    Cycle storage latestCycle = getLatestCycle();

    // if the current block timestamp is less than the reward finish time
    // then return the running cycle
    if (block.timestamp < latestCycle.finishTime) {
      return (true, latestCycle);
    }

    return (false, latestCycle);
  }

  /**
   * @notice Gets the certificate by the certificate ID
   * @param certificateId The certificate ID
   * @return cycle The certificate storage instance
   * @dev This function will revert if the certificate ID is invalid
   */
  function getCertificateById(
    uint256 certificateId
  ) internal view returns (Certificate storage cycle) {
    ProjectData storage pd = ProjectStorage.get();

    if (!pd.certificates.contains(certificateId)) {
      revert ISharedErrors.CertificateIdInvalid();
    }

    return pd.ledger[certificateId];
  }

  /**
   * @notice Gets the reward slot by the reward token address
   * @param rewardTokenAddress The reward token address
   * @return rewardSlot The reward slot
   * @dev This function will revert if the reward token address is invalid
   */
  function getRewardSlot(
    address rewardTokenAddress
  ) internal view returns (RewardSlot storage rewardSlot) {
    ProjectData storage pd = ProjectStorage.get();

    if (!pd.rewardTokens.contains(rewardTokenAddress)) {
      revert ISharedErrors.InvalidRewardToken();
    }

    return pd.rewardSlots[rewardTokenAddress];
  }

  /**
   * @notice Collects the fee from the user
   * @param feeType The type of fee that is being collected (e.g. deposit, withdrawal, etc.)
   * @param tokenAddress The address of the token that is being used to pay the fee
   * @param originalAmount The original amount that the fee is being collected on
   */
  function collectFee(
    IMainHub.FeeType feeType,
    address tokenAddress,
    uint256 originalAmount
  ) internal {
    ProjectData storage pd = ProjectStorage.get();

    // preview the fee to check the enforced charge token and amount
    // based on the fee type and platform settings
    (address chargeTokenAddress, uint256 chargeAmount) = pd.mainHub.previewFee(
      feeType,
      msg.sender,
      originalAmount
    );

    // if the charge token is ETH, then check if the user sent enough ETH
    // to cover the fee. If not, revert the transaction
    if (chargeTokenAddress == address(pd.WETH)) {
      if (msg.value < chargeAmount) {
        revert ISharedErrors.InvalidETHAmount(chargeAmount, msg.value);
      }
    }

    // if the charge token is a wildcard address (accepts any token as payment)
    // or the charge token is the same as the token being used to pay the fee
    // or the charge token is ETH
    // then transfer the token from the user to the main hub and pay the fee
    if (
      chargeTokenAddress == WILDCARD_ADDRESS ||
      tokenAddress == chargeTokenAddress ||
      chargeTokenAddress == address(pd.WETH)
    ) {
      IERC20(tokenAddress).forceApprove(address(pd.mainHub), chargeAmount);

      pd.mainHub.payFee(feeType, msg.sender, tokenAddress, originalAmount);
    } else {
      // the charge token is the zero address, so no fee is being charged
      if (chargeTokenAddress == address(0)) {
        return;
      }

      // the token is not the charge token, so transfer the charge token from the user
      IERC20 chargeToken = IERC20(chargeTokenAddress);

      chargeToken.safeTransferFrom(msg.sender, address(this), chargeAmount);
      chargeToken.forceApprove(address(pd.mainHub), chargeAmount);

      pd.mainHub.payFee(feeType, msg.sender, chargeTokenAddress, originalAmount);
    }
  }

  /**
   * @notice Updates the state of a certificate
   * @param certificateId The certificate id
   * @dev This function will revert if the certificate id is invalid
   */
  function updateCertificateState(uint256 certificateId) internal {
    LibRouter.delegateToFacet(
      LibRouter.FacetCall({
        selector: ICertificateFacet.updateCertificateState.selector,
        data: abi.encode(certificateId)
      })
    );
  }

  /**
   * @notice Updates the state of a cycle
   * @param cycleId The cycle ID
   * @dev This function will revert if the cycle ID is invalid
   */
  function updateCycleState(uint256 cycleId) internal {
    LibRouter.delegateToFacet(
      LibRouter.FacetCall({
        selector: ICycleFacet.updateCycleState.selector,
        data: abi.encode(cycleId)
      })
    );
  }

  /**
   * @notice Transfers an ERC20 token from the user and return its actual delta
   * @param token The ERC20 token to transfer
   * @param from The address to transfer the token from
   * @param to The address to transfer the token to
   * @param amount The amount of the token to transfer
   * @return The actual delta of the token transferred
   * @dev Reverts if the transfer fails
   * Reverts if the token transfer returns false
   * Reverts if the token transfer returns a zero balance
   */
  function transferFromReturningDelta(
    IERC20 token,
    address from,
    address to,
    uint256 amount
  ) internal returns (uint256) {
    uint256 balanceBefore = token.balanceOf(to);

    // transferFrom wrapped in a try block to catch any errors
    // from the origin token contract
    try token.transferFrom(from, to, amount) {
      uint256 balanceAfter = token.balanceOf(to);

      // token misbehaving, balance decreased
      if (balanceBefore > balanceAfter) {
        revert ISharedErrors.NegativeReceivedDelta();
      }

      return balanceAfter - balanceBefore;
    } catch {
      revert ISharedErrors.TokenTransferFailed();
    }
  }

  /**
   * @notice Counts the number of trailing zeros in a number
   * @param num The number to count the trailing zeros of
   * @return count The count of trailing zeros
   */
  function countTrailingZeros(uint256 num) internal pure returns (uint8 count) {
    while (num > 0 && num % 10 == 0) {
      count += 1;
      num /= 10;
    }

    return uint8(count);
  }

  /**
   * @notice Validates the settings of the project
   * @param flags The settings flags
   * @param data The settings data
   * @dev This function will revert if the settings are invalid
   */
  function validateSettings(
    SettingsFlags calldata flags,
    SettingsData calldata data
  ) internal view {
    if (
      !flags.certificateAllowDeposit && !flags.certificateCreateEnabled && !flags.vSharesEnabled
    ) {
      revert ISharedErrors.NoShareCreationPossible();
    }

    if (
      flags.certificateEarlyWithdrawalFeeEnabled &&
      (data.earlyWithdrawalFeePercentage == 0 ||
        data.earlyWithdrawalFeePercentage > Percentages.ONE_HUNDRED_PERCENT ||
        data.earlyWithdrawalFeeDuration == 0)
    ) {
      revert ISharedErrors.InvalidEarlyWithdrawFee();
    }

    ProjectData storage pd = ProjectStorage.get();

    // irreversible settings
    if (flags.vSharesEnabled && !pd.settingsFlags.vSharesEnabled) {
      revert ISharedErrors.VirtualSharesDisabled();
    }

    if (data.depositFeePercentage > Percentages.ONE_HUNDRED_PERCENT) {
      revert ISharedErrors.InvalidDepositFee();
    }

    // if (flags.certificateAllowDeposit && pd.depositToken.getAddress() == address(0)) {
    //   revert ISharedErrors.ZeroAddress();
    // }
  }

  /**
   * @notice Transfers ETH to the specified address
   * @param to The address to transfer ETH to
   * @param amount The amount of ETH to transfer
   * @dev This function will revert if the transfer fails
   */
  function transferEth(address to, uint256 amount) internal {
    bool previousDelegatingStatus = LibRouter.getDelegatingStatus();

    LibRouter.setDelegatingStatus(false);

    (bool success, ) = payable(to).call{value: amount}(new bytes(0));

    if (!success) {
      revert ISharedErrors.EtherTransferFailed();
    }

    LibRouter.setDelegatingStatus(previousDelegatingStatus);
  }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import {ISharedErrors} from "../types/Errors.sol";

import {IDiamondCut} from "../interfaces/IDiamondCut.sol";

/**
 * @title LibDiamond
 * @notice This library manages the diamond storage and facets.
 * @dev This library is used by the Diamond contract.
 */
library LibDiamond {
  /// @dev The diamond storage position.
  bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");
  /// @dev Mask is used to obtain the function selector from the first 4 bytes of the calldata
  bytes32 constant CLEAR_ADDRESS_MASK = bytes32(uint256(0xffffffffffffffffffffffff));
  /// @dev Mask is used to clear the lowest 5 bytes of a slot in the selectorSlots array
  bytes32 constant CLEAR_SELECTOR_MASK = bytes32(uint256(0xffffffff << 224));

  /**
   * @notice Emitted when a new facet is added to the diamond.
   * @param diamondCut Contains the facet addresses and function selectors.
   * @param initAddress Address of the contract or facet to execute initCalldata.
   * @param initCalldata A function call, including function selector and arguments.
   */
  event DiamondCut(IDiamondCut.FacetCut[] diamondCut, address initAddress, bytes initCalldata);

  /**
   * @notice Emitted when ownership of the contract changes.
   * @param previousOwner Address of the previous owner.
   * @param newOwner Address of the new owner.
   */
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @notice DiamondStorage struct is used to store the facets and the selector slots.
   * @param facets Maps function selectors to the facets that execute the functions.
   * @param selectorSlots Array of slots of function selectors.
   * @param selectorCount Number of function selectors in selectorSlots.
   * @param supportedInterfaces Used to query if a contract implements an interface.
   * @param contractOwner Toot owner of the contract.
   * @dev This struct is stored in the diamond storage position
   * and is used by the internal functions of the Diamond contract.
   */
  struct DiamondStorage {
    mapping(bytes4 => bytes32) facets;
    mapping(uint256 => bytes32) selectorSlots;
    uint16 selectorCount;
    mapping(bytes4 => bool) supportedInterfaces;
    address contractOwner;
  }

  /**
   * @notice This pure function gets the diamond storage.
   * @return ds DiamondStorage struct.
   */
  function diamondStorage() internal pure returns (DiamondStorage storage ds) {
    bytes32 position = DIAMOND_STORAGE_POSITION;

    assembly {
      ds.slot := position
    }
  }

  /**
   * @notice This internal function sets the contract owner.
   * @param newOwnerAddress Address of the new contract owner.
   */
  function setContractOwner(address newOwnerAddress) internal {
    DiamondStorage storage ds = diamondStorage();

    address previousOwner = ds.contractOwner;
    ds.contractOwner = newOwnerAddress;

    emit OwnershipTransferred(previousOwner, newOwnerAddress);
  }

  /**
   * @notice Gets the current contract owner.
   * @return currentContractOwner Address of the contract owner.
   */
  function contractOwner() internal view returns (address currentContractOwner) {
    currentContractOwner = diamondStorage().contractOwner;
  }

  /**
   * @notice This internal function enforces that the caller is the contract owner.
   */
  function enforceIsContractOwner() internal view {
    require(msg.sender == diamondStorage().contractOwner, "LibDiamond: Must be contract owner");
  }

  /**
   * @notice This internal function executes a diamond cut.
   * @dev This code is almost the same as the external diamondCut,
   * except it is using 'Facet[] memory rawDiamondCut' instead of
   * 'Facet[] calldata rawDiamondCut'.
   * The code is duplicated to prevent copying calldata to memory which
   * causes an error for a two-dimensional array.
   * @param rawDiamondCut Contains the facet addresses and function selectors.
   * @param initAddress Address of the contract or facet to execute initCalldata.
   * @param initCalldata A function call, including function selector and arguments.
   */
  function diamondCut(
    IDiamondCut.FacetCut[] memory rawDiamondCut,
    address initAddress,
    bytes memory initCalldata
  ) internal {
    DiamondStorage storage ds = diamondStorage();

    uint256 originalSelectorCount = ds.selectorCount;
    uint256 selectorCount = originalSelectorCount;
    bytes32 selectorSlot;

    // check if last selector slot is not full
    // 'selectorCount & 7' is a gas efficient modulo by eight 'selectorCount % 8'
    if (selectorCount & 7 > 0) {
      // get last selectorSlot
      // 'selectorSlot >> 3' is a gas efficient division by 8 'selectorSlot / 8'
      selectorSlot = ds.selectorSlots[selectorCount >> 3];
    }

    // loop through diamond cut
    for (uint256 facetIndex; facetIndex < rawDiamondCut.length; facetIndex++) {
      (selectorCount, selectorSlot) = addReplaceRemoveFacetSelectors(
        selectorCount,
        selectorSlot,
        rawDiamondCut[facetIndex].facetAddress,
        rawDiamondCut[facetIndex].action,
        rawDiamondCut[facetIndex].functionSelectors
      );
    }

    if (selectorCount != originalSelectorCount) {
      ds.selectorCount = uint16(selectorCount);
    }

    // if last selector slot is not full
    // 'selectorCount & 7' is a gas efficient modulo by eight 'selectorCount % 8'
    if (selectorCount & 7 > 0) {
      // 'selectorSlot >> 3' is a gas efficient division by 8 'selectorSlot / 8'
      ds.selectorSlots[selectorCount >> 3] = selectorSlot;
    }

    // emit event
    emit DiamondCut(rawDiamondCut, initAddress, initCalldata);

    // initialize diamond cut using _init and _calldata
    initializeDiamondCut(initAddress, initCalldata);
  }

  /**
   * @notice This internal function adds, replaces, or removes selectors.
   * @param selectorCount Number of selectors in the selectorSlots array.
   * @param selectorSlot Current selector slot.
   * @param newFacetAddress Facet address to add, replace, or remove.
   * @param action Action to take.
   * @param selectors Slectors to add, replace, or remove.
   * @return newSelectorCount New number of selectors.
   * @return newSelectorSlot New selector slot.
   */
  function addReplaceRemoveFacetSelectors(
    uint256 selectorCount,
    bytes32 selectorSlot,
    address newFacetAddress,
    IDiamondCut.FacetCutAction action,
    bytes4[] memory selectors
  ) internal returns (uint256 newSelectorCount, bytes32 newSelectorSlot) {
    DiamondStorage storage ds = diamondStorage();

    if (selectors.length == 0) {
      revert ISharedErrors.NoSelectorsInFacet();
    }

    if (action == IDiamondCut.FacetCutAction.Add) {
      enforceHasContractCode(newFacetAddress);

      for (uint256 selectorIndex; selectorIndex < selectors.length; selectorIndex++) {
        bytes4 selector = selectors[selectorIndex];
        bytes32 oldFacet = ds.facets[selector];

        if (address(bytes20(oldFacet)) != address(0)) {
          revert ISharedErrors.FunctionAlreadyExists();
        }

        // add facet for selector
        ds.facets[selector] = bytes20(newFacetAddress) | bytes32(selectorCount);

        // '_selectorCount & 7' is a gas efficient modulo by eight '_selectorCount % 8'
        // ' << 5 is the same as multiplying by 32 ( * 32)
        uint256 selectorInSlotPosition = (selectorCount & 7) << 5;

        // clear selector position in slot and add selector
        selectorSlot =
          (selectorSlot & ~(CLEAR_SELECTOR_MASK >> selectorInSlotPosition)) |
          (bytes32(selector) >> selectorInSlotPosition);

        // if slot is full then write it to storage
        if (selectorInSlotPosition == 224) {
          // '_selectorSlot >> 3' is a gas efficient division by 8 '_selectorSlot / 8'
          ds.selectorSlots[selectorCount >> 3] = selectorSlot;
          selectorSlot = 0;
        }

        selectorCount++;
      }
    } else if (action == IDiamondCut.FacetCutAction.Replace) {
      enforceHasContractCode(newFacetAddress);

      for (uint256 selectorIndex; selectorIndex < selectors.length; selectorIndex++) {
        bytes4 selector = selectors[selectorIndex];
        bytes32 oldFacet = ds.facets[selector];
        address oldFacetAddress = address(bytes20(oldFacet));

        if (oldFacetAddress == address(0)) {
          revert ISharedErrors.FunctionNotFound();
        }

        if (oldFacetAddress == address(this)) {
          revert ISharedErrors.FunctionIsImmutable();
        }

        if (oldFacetAddress == newFacetAddress) {
          revert ISharedErrors.ReplaceWithSameFunction();
        }

        // replace old facet address
        ds.facets[selector] = (oldFacet & CLEAR_ADDRESS_MASK) | bytes20(newFacetAddress);
      }
    } else if (action == IDiamondCut.FacetCutAction.Remove) {
      if (newFacetAddress != address(0)) {
        revert ISharedErrors.RemoveFacetAddressMustBeZero();
      }

      // '_selectorCount >> 3' is a gas efficient division by 8 '_selectorCount / 8'
      uint256 selectorSlotCount = selectorCount >> 3;

      // '_selectorCount & 7' is a gas efficient modulo by eight '_selectorCount % 8'
      uint256 selectorInSlotIndex = selectorCount & 7;

      for (uint256 selectorIndex; selectorIndex < selectors.length; selectorIndex++) {
        if (selectorSlot == 0) {
          // get last selectorSlot
          selectorSlotCount--;
          selectorSlot = ds.selectorSlots[selectorSlotCount];
          selectorInSlotIndex = 7;
        } else {
          selectorInSlotIndex--;
        }

        bytes4 lastSelector;
        uint256 oldSelectorsSlotCount;
        uint256 oldSelectorInSlotPosition;

        // adding a block here prevents stack too deep error
        {
          bytes4 selector = selectors[selectorIndex];
          bytes32 oldFacet = ds.facets[selector];

          if (address(bytes20(oldFacet)) == address(0)) {
            revert ISharedErrors.FunctionNotFound();
          }

          if (address(bytes20(oldFacet)) == address(this)) {
            revert ISharedErrors.FunctionIsImmutable();
          }

          // replace selector with last selector in ds.facets
          // gets the last selector
          // ' << 5 is the same as multiplying by 32 ( * 32)
          lastSelector = bytes4(selectorSlot << (selectorInSlotIndex << 5));

          if (lastSelector != selector) {
            // update last selector slot position info
            ds.facets[lastSelector] =
              (oldFacet & CLEAR_ADDRESS_MASK) |
              bytes20(ds.facets[lastSelector]);
          }

          delete ds.facets[selector];

          uint256 oldSelectorCount = uint16(uint256(oldFacet));

          // 'oldSelectorCount >> 3' is a gas efficient division by 8 'oldSelectorCount / 8'
          oldSelectorsSlotCount = oldSelectorCount >> 3;

          // 'oldSelectorCount & 7' is a gas efficient modulo by eight 'oldSelectorCount % 8'
          // ' << 5 is the same as multiplying by 32 ( * 32)
          oldSelectorInSlotPosition = (oldSelectorCount & 7) << 5;
        }

        if (oldSelectorsSlotCount != selectorSlotCount) {
          bytes32 oldSelectorSlot = ds.selectorSlots[oldSelectorsSlotCount];

          // clears the selector we are deleting and puts the last selector in its place.
          oldSelectorSlot =
            (oldSelectorSlot & ~(CLEAR_SELECTOR_MASK >> oldSelectorInSlotPosition)) |
            (bytes32(lastSelector) >> oldSelectorInSlotPosition);

          // update storage with the modified slot
          ds.selectorSlots[oldSelectorsSlotCount] = oldSelectorSlot;
        } else {
          // clears the selector we are deleting and puts the last selector in its place.
          selectorSlot =
            (selectorSlot & ~(CLEAR_SELECTOR_MASK >> oldSelectorInSlotPosition)) |
            (bytes32(lastSelector) >> oldSelectorInSlotPosition);
        }

        if (selectorInSlotIndex == 0) {
          delete ds.selectorSlots[selectorSlotCount];
          selectorSlot = 0;
        }
      }

      selectorCount = selectorSlotCount * 8 + selectorInSlotIndex;
    } else {
      revert ISharedErrors.IncorrectFacetCutAction();
    }

    return (selectorCount, selectorSlot);
  }

  /**
   * @notice This internal function initializes a diamond cut.
   * @param initAddress the address of the contract or facet to execute _calldata.
   * @param initCalldata a function call, including function selector and arguments.
   */
  function initializeDiamondCut(address initAddress, bytes memory initCalldata) internal {
    if (initAddress == address(0)) {
      if (initCalldata.length > 0) {
        revert ISharedErrors.InitializationFunctionReverted(initAddress, initCalldata);
      }

      return;
    }

    // enforce that the contract exists by having bytecode at the address
    enforceHasContractCode(initAddress);

    (bool callSucceeded, bytes memory callResponse) = initAddress.delegatecall(initCalldata);

    if (!callSucceeded) {
      if (callResponse.length > 0) {
        // bubble up error message
        assembly ("memory-safe") {
          let returndata_size := mload(callResponse)
          revert(add(32, callResponse), returndata_size)
        }
      } else {
        revert ISharedErrors.InitializationFunctionReverted(initAddress, initCalldata);
      }
    }
  }

  /**
   * @notice This internal function enforces that a contract exists at an address.
   * @param contractAddress address to check.
   */
  function enforceHasContractCode(address contractAddress) internal view {
    uint256 contractSize;

    assembly {
      contractSize := extcodesize(contractAddress)
    }

    if (contractSize == 0) {
      revert ISharedErrors.NoCodeAtAddress(contractAddress);
    }
  }
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.25;

import {console} from "hardhat/console.sol";

import {ISharedErrors} from "../types/Errors.sol";

import {LibDiamond} from "./LibDiamond.sol";

/**
 * @title LibRouter
 * @notice The LibRouter library provides functions for routing function calls to the correct facet
 * @dev Delegates function calls to a specific facet based on the function selector.
 * @dev Uses the LibDiamond library to get the facet address for a given function selector.
 * @dev Provides functions to check if the message sender is delegating and to set the delegating status.
 */
library LibRouter {
  /**
   * @notice A struct for a facet call
   * @param selector The function selector
   * @param data The function call data
   */
  struct FacetCall {
    bytes4 selector;
    bytes data;
  }

  /**
   * @notice The slot for the delegating status
   */
  bytes32 constant _DELEGATING_SLOT = keccak256("transient.delegating");

  /**
   * @notice Delegates a function call to the correct facet
   * @param facetCall A FacetCall struct
   * @return returnData The return data from the function call (bytes)
   */
  function _delegateToFacet(FacetCall memory facetCall) internal returns (bytes memory returnData) {
    // get facet from function selector
    address facetAddress = getFacetAddress(facetCall.selector);

    // delegate call to facet
    (bool success, bytes memory callReturnData) = facetAddress.delegatecall(
      abi.encodePacked(facetCall.selector, facetCall.data)
    );

    // delegate call to facet
    return _decodeReturnData(success, callReturnData);
  }

  /**
   * @notice Delegates a function call to the correct facet
   * @param facetCall A FacetCall struct
   * @return returnData The return data from the function call (bytes)
   */
  function delegateToFacet(FacetCall memory facetCall) internal returns (bytes memory returnData) {
    setDelegatingStatus(true);

    bytes memory callReturnData = _delegateToFacet(facetCall);

    setDelegatingStatus(false);

    // delegate call to facet
    return callReturnData;
  }

  /**
   * @notice Delegates multiple function calls to the correct facets
   * @param calls An array of FacetCall structs
   * @return returnDatas An array of return data from the function calls
   */
  function delegateToFacets(
    FacetCall[] memory calls
  ) internal returns (bytes[] memory returnDatas) {
    bytes[] memory callsReturndata = new bytes[](calls.length);

    setDelegatingStatus(true);

    for (uint256 i = 0; i < calls.length; i++) {
      callsReturndata[i] = _delegateToFacet(calls[i]);
    }

    setDelegatingStatus(false);

    return callsReturndata;
  }

  /**
   * @notice Decodes the return data from a function call
   * @param success The success status of the call
   * @param returnData The return data from the call
   * @return decodedReturnData The decoded return data
   */
  function _decodeReturnData(
    bool success,
    bytes memory returnData
  ) internal pure returns (bytes memory decodedReturnData) {
    // check if call was successful
    if (!success) {
      // check if there is a revert reason
      if (returnData.length > 0) {
        // bubble up the error
        assembly {
          let returnDataSize := mload(returnData)
          revert(add(32, returnData), returnDataSize)
        }
      } else {
        revert ISharedErrors.FacetCallFailed();
      }
    }

    return returnData;
  }

  /**
   * @notice Gets the facet address for a given function selector
   * @param selector The function selector (bytes4)
   * @return facetAddress The address of the facet
   */
  function getFacetAddress(bytes4 selector) internal view returns (address facetAddress) {
    address selectorFacetAddress = address(bytes20(LibDiamond.diamondStorage().facets[selector]));

    if (selectorFacetAddress == address(0)) {
      revert ISharedErrors.FacetNotFound();
    }

    return selectorFacetAddress;
  }

  /**
   * @notice Gets the delegating status of the message sender
   * @return delegatingStatus The delegating status
   */
  function getDelegatingStatus() internal view returns (bool delegatingStatus) {
    bytes32 slot = _DELEGATING_SLOT;

    bool status;

    assembly {
      status := tload(slot)
    }

    return status;
  }

  /**
   * @notice Checks if the message sender is delegating
   * @return delegating True if the message sender is delegating
   */
  function isDelegating() internal view returns (bool delegating) {
    return getDelegatingStatus();
  }

  /**
   * @notice Sets the delegating status of the message sender
   * @param status The delegating status
   */
  function setDelegatingStatus(bool status) internal {
    bytes32 slot = _DELEGATING_SLOT;

    assembly {
      tstore(slot, status)
    }
  }
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.25;

import {
  IUniswapV2Router02
} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Factory} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {IWETH} from "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITokenRouter {
  /**
   * @notice TokenDetails represents the details of a token
   * @param tokenAddress The address of the token
   * @param name The name of the token
   * @param symbol The symbol of the token
   * @param decimals The decimals of the token
   * @param totalSupply The total supply of the token
   * @param isLiquidityPoolToken Wether the token is a liquidity pool token
   */
  struct TokenDetails {
    address tokenAddress;
    string name;
    string symbol;
    uint8 decimals;
    uint256 totalSupply;
    bool isLiquidityPoolToken;
  }

  // errors
  error ETHTransferFailed();
  error WETHTransferFailed();
  error TransferFromFailed();
  error NotWethPair();
  error NotLPToken();
  error NotAPair();
  error InvalidSlippageTolerance();
  error FullLiquidationNotPossible();
  error InternalPoolTokensNotPairedWithWeth();
  error InsuficcientWETHBalance();
  error SwapImpossible(address inputToken, address outputToken);

  /**
   * @notice Returns the address of the Uniswap router
   * @return The Uniswap router
   */
  function uniswapRouter() external returns (IUniswapV2Router02);

  /**
   * @notice Returns the address of the Uniswap factory
   * @return The Uniswap factory
   */
  function uniswapFactory() external returns (IUniswapV2Factory);

  /**
   * @notice Returns the address of the WETH token
   * @return The WETH token
   */
  function WETH() external returns (IWETH);

  /**
   * @notice Returns the address of the USDT token
   * @return The USDT token
   */
  function USDT() external returns (IERC20);

  /**
   * @notice Returns the token details for a given token address
   * @param tokenAddress The address of the token
   * @return tokenDetails The token details
   */
  function getTokenDetails(
    address tokenAddress
  ) external view returns (TokenDetails memory tokenDetails);

  /**
   * @notice Returns wether a token is a liquidity pool token
   * @param tokenAddress The address of the token
   * @return isLiquidityPoolToken Wether the token is a liquidity pool token
   */
  function isLiquidityPoolToken(
    address tokenAddress
  ) external view returns (bool isLiquidityPoolToken);

  /**
   * @notice Returns wether a token is paired with WETH
   * @param tokenAddress The address of the token
   * @return isPaired Wether the token is paired with WETH
   */
  function isTokenPairedWithWeth(address tokenAddress) external view returns (bool isPaired);

  /**
   * @notice Returns wether a pair is based on WETH
   * @param pairAddress The address of the pair
   */
  function isPairBasedOnWeth(address pairAddress) external view returns (bool isBasedOnWeth);

  /**
   * @notice Returns wether a pair is a liquidity pool token
   * @param lpTokenAddress The address of the liquidity pool token
   */
  function isLPLiquidatableToWeth(
    address lpTokenAddress
  ) external view returns (bool isLiquidatable);

  /**
   * @notice Returns wether a pair is mintable by checking its tokens and verifying if they are paired with WETH
   * @param pair The pair
   * @return isMintable Wether the pair is mintable
   */
  function isLPMintable(IUniswapV2Pair pair) external view returns (bool isMintable);

  /**
   * @notice Returns the pair address for two tokens
   * @param token0Address The address of the first token
   * @param token1Address The address of the second token
   * @return pairAddress The address of the pair (address(0) if not found)
   */
  function getPairAddress(
    address token0Address,
    address token1Address
  ) external view returns (address pairAddress);

  /**
   * @notice mints a liquidity pool token for a given pair from WETH
   * @param pair The pair
   * @param wethAmount The amount of WETH to use
   * @param slippageTolerance The slippage tolerance
   * @param recipientOverride The recipient override
   * @return amountMinted The amount of liquidity pool tokens minted
   */
  function mintLPToken(
    IUniswapV2Pair pair,
    uint256 wethAmount,
    uint256 slippageTolerance,
    address recipientOverride
  ) external returns (uint256 amountMinted);

  /**
   * @notice Liquidates (with 1 depth recursiveness) a liquidity pool token to WETH
   * @param lpTokenAddress The address of the liquidity pool token
   * @param liquidityAmount The amount of liquidity pool tokens to liquidate
   * @param slippageTolerance The slippage tolerance
   * @param recipientOverride The recipient override
   * @param liquidateToEth Wether to liquidate to WETH
   * @return amountWethReturned The amount of WETH returned
   */
  function liquidateLPToken(
    address lpTokenAddress,
    uint256 liquidityAmount,
    uint256 slippageTolerance,
    address recipientOverride,
    bool liquidateToEth
  ) external returns (uint256 amountWethReturned);

  /**
   * @notice Unwraps a liquidity pool token to its underlying tokens
   * @param lpTokenAddress The address of the liquidity pool token
   * @param liquidityAmount The amount of liquidity pool tokens to unwrap
   * @param slippageTolerance The slippage tolerance
   * @param recipientOverride The recipient override
   * @return tokens The underlying tokens
   * @return amounts The amounts of the underlying tokens
   */
  function unwrapLPToken(
    address lpTokenAddress,
    uint256 liquidityAmount,
    uint256 slippageTolerance,
    address recipientOverride
  ) external returns (address[2] memory tokens, uint256[2] memory amounts);

  /**
   * @notice Swaps tokens for another token and returns best amount to swap and add liquidity
   * @param pair The Uniswap pair to swap through
   * @param amountIn The amount of input tokens
   * @return optimalAmount The optimal amount of input tokens to swap
   */
  function getOptimalSwapAmount(
    IUniswapV2Pair pair,
    uint256 amountIn
  ) external view returns (uint256 optimalAmount);

  /**
   * @notice Swap tokens for another token and returns the delta
   * @param inputTokenAddress The address of the input token
   * @param outputTokenAddress The address of the output token
   * @param amountIn The amount of input tokens
   * @param slippageTolerance The slippage tolerance
   * @param recipientOverride The recipient override
   * @return delta The delta
   */
  function swapTokensReturningDelta(
    address inputTokenAddress,
    address outputTokenAddress,
    uint256 amountIn,
    uint256 slippageTolerance,
    address recipientOverride
  ) external returns (uint256 delta);

  /**
   * @notice Returns wether a token is liquidatable to WETH (single token or liquidity pool token)
   * @param tokenAddress The address of the token
   * @return isLiquidatable Wether the token is liquidatable to WETH
   */
  function isLiquidatableToWeth(address tokenAddress) external view returns (bool isLiquidatable);

  /**
   * @notice Liquidates a token to WETH (single token or liquidity pool token)
   * @param tokenAddress The address of the token
   * @param amount The amount of tokens to liquidate
   * @param slippageTolerance The slippage tolerance
   * @param recipientOverride The recipient override
   * @return amountWethReturned The amount of WETH returned
   */
  function liquidateToWeth(
    address tokenAddress,
    uint256 amount,
    uint256 slippageTolerance,
    address recipientOverride
  ) external returns (uint256 amountWethReturned);

  /**
   * @notice Swaps WETH for a token
   * @param tokenAddress The address of the token
   * @param wethAmount The amount of WETH to swap
   * @param slippageTolerance The slippage tolerance
   * @param recipientOverride The recipient override
   * @return amountReceived The amount of tokens received
   */
  function swapWethForToken(
    address tokenAddress,
    uint256 wethAmount,
    uint256 slippageTolerance,
    address recipientOverride
  ) external returns (uint256 amountReceived);

  /**
   * @notice Gets the value of a token in USD
   * @param tokenAddress The address of the token
   * @param amount The amount of tokens to convert to USD
   * @return valueInUSD The value in USD (0 if not found)
   */
  function getTokenValueInUSD(
    address tokenAddress,
    uint256 amount
  ) external view returns (uint256 valueInUSD);

  /**
   * @notice Gets the value of a token in WETH
   * @param tokenAddress The address of the token
   * @param amount The amount of tokens to convert to WETH
   * @return valueInWeth The value in WETH (0 if not found)
   */
  function getTokenValueInWeth(
    address tokenAddress,
    uint256 amount
  ) external view returns (uint256);

  /**
   * @notice Recovers a token from the contract
   * @param tokenAddress The address of the token
   */
  function recoverERC20(address tokenAddress) external;

  /**
   * @notice Recovers ETH from the contract
   */
  function recoverETH() external;
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.25;

import {mulDiv} from "@prb/math/src/Common.sol";

/**
 * @title Percentages
 * @notice Library for managing percentages.
 * - Precision is `1 ether`.
 * - Maximum percentage is `100%` (`100_000`).
 * - Maximum value is `1e36`.
 */
library Percentages {
  /// @dev 100% in precision units.
  uint256 internal constant ONE_HUNDRED_PERCENT = 100_000;

  /// @dev The number of units in a percentage.
  uint256 private constant PERCENTAGE_UNITS = 1 ether;
  /// @dev The divisor for percentage calculations.
  uint256 private constant PERCENTAGE_DIVISOR = (PERCENTAGE_UNITS * ONE_HUNDRED_PERCENT);

  /**
   * @notice Gets the rate of a number related to another number.
   * @param a The number.
   * @param b The other number.
   * @return rate The rate of a to b.
   */
  function getRate(uint256 a, uint256 b) internal pure returns (uint256 rate) {
    if (b == 0) {
      return 0;
    }

    return mulDiv(a, PERCENTAGE_UNITS, b);
  }

  /**
   * @notice Gets the number based on a rate.
   * @param number The number.
   * @param rate The rate to apply.
   * @return n The number based on the rate.
   */
  function fromRate(uint256 number, uint256 rate) internal pure returns (uint256 n) {
    return mulDiv(number, rate, PERCENTAGE_UNITS);
  }

  /**
   * @notice Gets a number after applying a percentage.
   * @param number The number.
   * @param perc The percentage.
   * @return n The number after applying the percentage.
   */
  function fraction(uint256 number, uint256 perc) internal pure returns (uint256 n) {
    return mulDiv(number, perc * PERCENTAGE_UNITS, PERCENTAGE_DIVISOR);
  }
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.25;

import {ProjectData} from "../types/Structs.sol";
import {WETH_ADDRESS} from "../types/Constants.sol";

import {IWETH} from "../interfaces/IWETH.sol";

/**
 * @title ProjectStorage
 * @notice The library provides functions for reading and writing to the project storage
 * @dev Used to store all the project data, state variables, and other data related to the project
 */
library ProjectStorage {
  /// @dev The storage key for the project storage slot
  bytes32 internal constant PROJECT_STORAGE_POSITION = keccak256("project.storage");

  /**
   * @notice Initialises the default values for the project storage
   * @return pd The project data storage
   */
  function initialiseDefaults() internal returns (ProjectData storage pd) {
    pd = get();

    pd.WETH = IWETH(WETH_ADDRESS);
    pd.nextCertificateId = 0;

    return pd;
  }

  /**
   * @notice Gets the project storage slot
   * @return pd The project data storage
   */
  function get() internal pure returns (ProjectData storage pd) {
    bytes32 position = PROJECT_STORAGE_POSITION;

    assembly {
      pd.slot := position
    }
  }
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.25;

import {UD60x18} from "@prb/math/src/UD60x18.sol";

/// @dev Pseudo-address used to represent ETH in transactions
/// This address is used to differentiate between ETH and other tokens
address constant ETH_PSEUDO_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

/// @dev Address of the Wrapped Ether (WETH) contract on Ethereum mainnet
address constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

/// @dev Address of the Tether (USDT) contract on Ethereum mainnet
address constant USDT_ADDRESS = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

/// @dev Wildcard address used for special conditions or permissions
/// Often used to represent "any address" in access control or similar contexts
address constant WILDCARD_ADDRESS = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;

/// @dev Represents 1 Ether in the UD60x18 fixed-point format
/// Used for precise calculations involving Ether amounts
UD60x18 constant UD_ONE_ETHER = UD60x18.wrap(1 ether);

/// @dev Function selector for the internal withdraw function
/// Calculated as the first 4 bytes of the keccak256 hash of "withdraw(uint256,uint256,address)"
bytes4 constant INTERNAL_WITHDRAW_SELECTOR = bytes4(keccak256("withdraw(uint256,uint256,address)"));

/// @dev Function selector for the internal deposit function
/// Calculated as the first 4 bytes of the keccak256 hash of "deposit(uint256,uint256,bool,bool)"
bytes4 constant INTERNAL_DEPOSIT_SELECTOR = bytes4(keccak256("deposit(uint256,uint256,bool,bool)"));
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.25;

/**
 * @notice The VerificationLevel enum represents the different levels of verification for a project
 * - **UNTRUSTED:** Untrusted verification (projects that might be scams)
 * - **NONE:** No verification
 * - **BASIC:** Basic verification
 * - **AUDITED:** Audited verification
 * - **CERTIFIED:** Certified verification (only for projects that have been verified by the team)
 * - **OFFICIAL:** Official verification (only for projects deployed by the team)
 */
enum VerificationLevel {
  UNTRUSTED,
  NONE,
  BASIC,
  AUDITED,
  CERTIFIED,
  OFFICIAL
}

library VerificationStrings {
  /**
   * @notice Converts a VerificationLevel to a string
   * @param level VerificationLevel to convert
   * @return stringLevel String representation of the VerificationLevel
   */
  function toString(VerificationLevel level) internal pure returns (string memory stringLevel) {
    return
      level == VerificationLevel.UNTRUSTED ? "Untrusted" : level == VerificationLevel.NONE
        ? "None"
        : level == VerificationLevel.BASIC
        ? "Basic"
        : level == VerificationLevel.AUDITED
        ? "Audited"
        : level == VerificationLevel.CERTIFIED
        ? "Certified"
        : "Official";
  }
}

/**
 * @notice The type of options that can be enabled or disabled
 * @notice This enum defines the following options:
 * - **VSHARES_ENABLED:** Allows the issuing of virtual shares by the project manager
 * - **CERTIFICATE_CREATE_ENABLED:** Allows the creation of new certificates
 * - **CERTIFICATE_CREATE_CAP_ENABLED:** Limits the amount of certificates that can be created
 * - **CERTIFICATE_ALLOW_MERGE:** Allows the merge of 2 or more certificates into a single certificate
 * - **CERTIFICATE_ALLOW_SPLIT:** Allows the split of a certificate into 2 certificates
 * - **CERTIFICATE_ALLOW_LIQUIDATION:** Allows the liquidation of all assets in a certificate at market rates
 * - **CERTIFICATE_ALLOW_DEPOSIT:** Allows the accounts to deposit tokens
 * - **CERTIFICATE_DEPOSIT_CAP_ENABLED:** Limits the amount of tokens that can be deposited in a certificate
 */
enum OptionType {
  VSHARES_ENABLED,
  CERTIFICATE_CREATE_ENABLED,
  CERTIFICATE_CREATE_CAP_ENABLED,
  CERTIFICATE_ALLOW_MERGE,
  CERTIFICATE_ALLOW_SPLIT,
  CERTIFICATE_ALLOW_LIQUIDATION,
  CERTIFICATE_ALLOW_DEPOSIT,
  CERTIFICATE_DEPOSIT_CAP_ENABLED
}

/**
 * @notice The type of reward distribution
 * - **UPON_CYCLE_END:** Will release all tokens upon cycle end
 * - **PROGRESSIVE:** Will release tokens gradually over the cycle in a per second basis
 */
enum DistributionType {
  UPON_CYCLE_END,
  PROGRESSIVE
}

/**
 * @notice The type of shares that can be issued
 * - **UNKNOWN:** Represents an unknown share type
 * - **VSHARE:** Represents the share of a certificate that does not contain actual tokens
 * but are matched 1:1 with the equivalent amount of t-shares
 * - **TSHARE:** Represents the share of a certificate that is deposited with actual tokens
 */
enum ShareType {
  UNKNOWN,
  TSHARE,
  VSHARE
}

/**
 * @notice The type of supply action for global shares management
 * - **INCREASE:** Increase the supply
 * - **DECREASE:** Decrease the supply
 */
enum SupplyAction {
  INCREASE,
  DECREASE
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {ShareType, OptionType} from "./Enums.sol";

/**
 * @title ISharedErrors
 * @notice The interface for the shared errors
 * @dev Contains all the shared errors that are used across the project core
 */
interface ISharedErrors {
  // ----------------------------------
  // General Errors
  // ----------------------------------

  /// @notice Thrown when a zero address is provided where a non-zero address is required
  error ZeroAddress();

  /// @notice Thrown when a zero amount is provided where a non-zero amount is required
  error ZeroAmount();

  /// @notice Thrown when a zero duration is provided where a non-zero duration is required
  error ZeroDuration();

  /// @notice Thrown when an index is out of the valid range for an array or mapping
  error IndexOutOfBounds();

  /// @notice Thrown when an invalid percentage value is provided (e.g., not between 0 and 100)
  error InvalidPercentage();

  /// @notice Thrown when a function is called by an address that is not authorized to do so
  error InvalidCaller();

  /// @notice Thrown when an invalid slippage tolerance is provided
  error InvalidSlippageTolerance();

  /// @notice Thrown when an amount exceeds the maximum allowed value
  error AmountTooLarge();

  /// @notice Thrown when an operation requires more balance than is available
  /// @param balance The current balance
  /// @param requiredBalance The balance required for the operation
  error InsufficientBalance(uint256 balance, uint256 requiredBalance);

  /// @notice Thrown when the amount of ETH received does not match the expected amount
  /// @param expectedAmount The amount of ETH expected
  /// @param receivedAmount The amount of ETH actually received
  error InvalidETHAmount(uint256 expectedAmount, uint256 receivedAmount);

  /// @notice Thrown when an Ether transfer fails
  error EtherTransferFailed();

  /// @notice Thrown when a token transfer fails
  error TokenTransferFailed();

  /// @notice Thrown when attempting to use a setting that is currently disabled
  /// @param optionType The type of option that is disabled
  error SettingDisabled(OptionType optionType);

  /// @notice Thrown when attempting to enable a setting that is already enabled
  /// @param optionType The type of option that is already enabled
  error SettingEnabled(OptionType optionType);

  /// @notice Thrown when there's no code at the specified contract address
  /// @param contractAddress The address where code was expected but not found
  error NoCodeAtAddress(address contractAddress);

  /// @notice Thrown when the contract receives Ether but is not set up to handle it
  error CannotReceiveEther();

  // ----------------------------------
  // Deposit & Withdrawal Errors
  // ----------------------------------

  /// @notice Thrown when a deposit is attempted but deposits are currently disabled
  error DepositDisabled();

  /// @notice Thrown when a deposit operation fails
  error DepositFailed();

  /// @notice Thrown when a deposit amount is below the minimum required
  /// @param minimumDeposit The minimum deposit amount required
  /// @param depositAmount The amount attempted to deposit
  error MinimumDepositNotReached(uint256 minimumDeposit, uint256 depositAmount);

  /// @notice Thrown when a deposit would exceed the deposit cap
  /// @param triedAmount The amount attempted to deposit
  /// @param cap The current deposit cap
  error DepositCapReached(uint256 triedAmount, uint256 cap);

  /// @notice Thrown when an invalid withdrawal amount is provided
  /// @param amount The amount attempted to withdraw
  /// @param balance The actual balance available
  error InvalidWithdrawalAmount(uint256 amount, uint256 balance);

  /// @notice Thrown when an invalid deposit fee is provided
  error InvalidDepositFee();

  /// @notice Thrown when an invalid early withdraw fee is provided
  error InvalidEarlyWithdrawFee();

  /// @notice Thrown when Ether is sent with a non-Ether reward token
  error EtherSentWithNonEtherRewardToken();

  /// @notice Thrown when the amount of Ether sent does not match the reward amount
  error EtherSentDoesNotMatchRewardAmount();

  /// @notice Thrown when attempting to recover the deposit token, which is not allowed
  error CannotRecoverDepositToken();

  /// @notice Thrown when attempting to recover a reward token, which is not allowed
  error CannotRecoverRewardToken();

  // ----------------------------------
  // Cycle Errors
  // ----------------------------------

  /// @notice Thrown when a cycle ID is out of the valid range
  error CycleIdOutOfBounds();

  /// @notice Thrown when an invalid cycle ID is provided
  error InvalidCycleId();

  /// @notice Thrown when an invalid cycle duration is provided
  error InvalidCycleDuration();

  /// @notice Thrown when attempting to change a cycle ID that should not be changed
  error CycleIdCannotBeChanged();

  /// @notice Thrown when attempting to change a cycle start time that should not be changed
  error CycleStartTimeCannotBeChanged();

  /// @notice Thrown when attempting to change a cycle finish time that should not be changed
  error CycleFinishTimeCannotBeChanged();

  /// @notice Thrown when a cycle start time is set to a time in the past
  error CycleStartTimeInPast();

  /// @notice Thrown when a cycle finish time is set to a time in the past
  error CycleFinishTimeInPast();

  /// @notice Thrown when a cycle finish time is set before its start time
  error CycleFinishTimeBeforeStartTime();

  /// @notice Thrown when a cycle is active
  error CycleStillActive(uint256 cycleId, uint256 finishTime);

  // ----------------------------------
  // Certificate Errors
  // ----------------------------------

  /// @notice Thrown when an invalid certificate ID is provided
  error CertificateIdInvalid();

  /// @notice Thrown when an invalid certificate NFT manager is provided
  error CertificateNFTManagerInvalid();

  /// @notice Thrown when a certificate ID is out of the valid range
  error CertificateIdOutOfBounds();

  /// @notice Thrown when a certificate balance operation would result in an overflow
  error CertificateBalanceOverflow();

  /// @notice Thrown when attempting to change a certificate ID that should not be changed
  error CertificateIdCannotBeChanged();

  /// @notice Thrown when attempting to change a certificate share type that should not be changed
  error CertificateShareTypeCannotBeChanged();

  /// @notice Thrown when a certificate update time is set to a time in the past
  error CertificateUpdateTimeInPast();

  /// @notice Thrown when an operation is attempted on a frozen certificate
  error CertificateFrozen();

  /// @notice Thrown when a certificate operation would exceed the certificate cap
  /// @param cap The current certificate cap
  error CertificateCapReached(uint256 cap);

  /// @notice Thrown when an operation requires certificates but none exist
  error NoCertificates();

  /// @notice Thrown when an operation requires more certificates than the user owns
  /// @param requiredShares The number of shares required for the operation
  /// @param ownedShares The number of shares owned by the user
  error NotEnoughCertificates(uint256 requiredShares, uint256 ownedShares);

  /// @notice Thrown when a requested certificate cannot be found
  error CertificateNotFound();

  // ----------------------------------
  // Reward Errors
  // ----------------------------------

  /// @notice Thrown when an invalid reward token is provided
  error InvalidRewardToken();

  /// @notice Thrown when attempting to add a reward token that already exists
  error RewardTokenAlreadyExists();

  /// @notice Thrown when an action is attempted while a reward period is still active
  error RewardPeriodStillActive();

  /// @notice Thrown when an action is attempted when a reward period is not active
  error RewardPeriodNotActive();

  /// @notice Thrown when attempting to add more reward slots than the maximum allowed
  /// @param maxRewardSlots The maximum number of reward slots allowed
  /// @param triedToAddRewardSlotsCount The number of reward slots attempted to add
  error RewardSlotsLimitReached(uint256 maxRewardSlots, uint256 triedToAddRewardSlotsCount);

  /// @notice Thrown when an operation involving virtual shares is attempted but virtual shares are disabled
  error VirtualSharesDisabled();

  /// @notice Thrown when the deposit token is not paired with WETH and the operation requires it
  error DepositTokenNotPairedWithWeth();

  // ----------------------------------
  // Share Errors
  // ----------------------------------

  /// @notice Thrown when share creation is not possible due to current conditions
  error NoShareCreationPossible();

  /// @notice Thrown when an invalid share type is provided
  /// @param expectedShareType The share type that was expected
  /// @param providedShareType The share type that was provided
  error InvalidShareType(ShareType expectedShareType, ShareType providedShareType);

  /// @notice Thrown when an unknown share type is encountered
  error UnknownShareType();

  /// @notice Thrown when a total shares calculation would result in an overflow
  error TotalSharesOverflow();

  /// @notice Thrown when a received delta value is negative but should be positive
  error NegativeReceivedDelta();

  /// @notice Thrown when an invalid virtual share amount is provided
  error InvalidVShareAmount();

  // ----------------------------------
  // CertificateNFTManager Errors
  // ----------------------------------

  /// @notice Thrown when an operation is attempted while a grace period is still active
  error GracePeriodNotOver();

  // ----------------------------------
  // Specific Contract Errors
  // ----------------------------------

  /// @notice Thrown when an action is attempted by an address that is not the certificate owner
  error NotCertificateOwner();

  /// @notice Thrown when attempting to merge a certificate with itself
  error MergeCertificateWithItself();

  /// @notice Thrown when an invalid address is provided for the main hub
  error InvalidMainHubAddress();

  /// @notice Thrown when an operation is attempted on an address that is not recognized as a valid project
  error NotAProject();

  /// @notice Thrown when attempting to transfer a certificate that is currently frozen
  error TransferFrozenCertificate();

  // ----------------------------------
  // Diamond Standard Facet Errors
  // ----------------------------------

  /// @notice Thrown when a requested facet is not found in a diamond contract
  error FacetNotFound();

  /// @notice Thrown when a call to a facet in a diamond contract fails
  error FacetCallFailed();

  /// @notice Thrown when an initialization function reverts during diamond cut
  /// @param initAddress The address of the initialization contract
  /// @param initCalldata The calldata sent to the initialization function
  error InitializationFunctionReverted(address initAddress, bytes initCalldata);

  /// @notice Thrown when an incorrect facet cut action is specified
  error IncorrectFacetCutAction();

  /// @notice Thrown when trying to add a facet with no selectors
  error NoSelectorsInFacet();

  /// @notice Thrown when trying to add a facet with a zero address
  error FacetAddressZero();

  /// @notice Thrown when trying to add a function that already exists in the diamond
  error FunctionAlreadyExists();

  /// @notice Thrown when trying to replace a function with the same function
  error ReplaceWithSameFunction();

  /// @notice Thrown when trying to remove a function but the facet address is not zero
  error RemoveFacetAddressMustBeZero();

  /// @notice Thrown when trying to remove a function that doesn't exist
  error CantRemoveFunction();

  /// @notice Thrown when trying to remove an immutable function
  error CantRemoveImmutableFunction();

  /// @notice Thrown when a function is not found in the diamond
  error FunctionNotFound();

  /// @notice Thrown when trying to modify an immutable function
  error FunctionIsImmutable();
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.25;

import {ShareType, VerificationLevel} from "./Enums.sol";
import {SettingsFlags, SettingsData} from "./Structs.sol";

/**
 * @title IEvents
 * @dev The IEvents contract defines the events used by the project
 * @dev It is an Interface so that it can be imported and used in other contracts
 */
interface IEvents {
  /**
   * @notice Emitted when the settings of the project are updated
   * @param flags The settings flags of the project
   * @param data The settings data of the project
   */
  event SettingsUpdated(SettingsFlags flags, SettingsData data);

  /**
   * @notice Emitted when the verification level of the project is updated
   * @param level The new verification level
   */
  event VerificationLevelUpdated(VerificationLevel level);

  /**
   * @notice Emitted when a new cycle is started
   * @param cycleId The ID of the new cycle
   * @param startTime The timestamp of when the cycle started
   * @param finishTime The timestamp of when the cycle will end
   */
  event CycleStart(uint256 indexed cycleId, uint256 startTime, uint256 finishTime);

  /**
   * @notice Emitted when a Cycle finishes
   * @param cycleId The ID of the cycle
   * @param finishTime The timestamp of when the cycle finished
   * @dev A Cycle only finishes upon a call is made to the contract after the finish time
   * @dev So the timestamp of this event is not the exact time the cycle finished
   */
  event CycleFinish(uint256 indexed cycleId, uint256 finishTime);

  /**
   * @notice Emitted when a cycle is extended
   * @param cycleId The ID of the cycle
   * @param secondsExtended The amount of seconds extended
   * @param newFinishTime The timestamp of when the cycle will end
   */
  event CycleDurationExtended(
    uint256 indexed cycleId,
    uint256 secondsExtended,
    uint256 newFinishTime
  );

  /**
   * @notice Emitted when a reward token slot is added to the pool
   * @param rewardTokenAddress The address of the reward token
   */
  event RewardSlotCreate(address indexed rewardTokenAddress);

  /**
   * @notice Emitted when a reward is paid to a certificate
   * @param accountAddress The address of the account that received the reward
   * @param tokenAddress The address of the reward token
   * @param rewardAmount The amount of reward tokens paid
   */
  event RewardPayment(
    address indexed accountAddress,
    address indexed tokenAddress,
    uint256 rewardAmount
  );

  /**
   * @notice Emitted when an account creates a new certificate
   * @param accountAddress The address of the account
   * @param certificateId The ID of the newly created certificate
   * @param shareType The type of share (TSHARE or VSHARE)
   */
  event CertificateCreate(
    address indexed accountAddress,
    uint256 indexed certificateId,
    ShareType shareType
  );

  /**
   * @notice Emitted when an account deposits tokens
   * @param accountAddress The address of the account
   * @param certificateId The ID of the certificate
   * @param amount The amount of tokens deposited
   */
  event CertificateDeposit(
    address indexed accountAddress,
    uint256 indexed certificateId,
    uint256 amount
  );

  /**
   * @notice Emitted when an account deposits tokens on behalf of another account
   * @param senderAddress The address of the user who called depositFor
   * @param certificateId The ID of the certificate
   * @param amount The amount of tokens deposited
   */
  event CertificateDepositFor(
    address indexed senderAddress,
    uint256 indexed certificateId,
    uint256 amount
  );

  /**
   * @notice Emitted when an account withdraws tokens
   * @param accountAddress The address of the account
   * @param certificateId The ID of the certificate
   * @param amount The amount of tokens withdrawn
   */
  event CertificateWithdrawal(
    address indexed accountAddress,
    uint256 indexed certificateId,
    uint256 amount
  );

  /**
   * @notice Emitted when the early withdrawal fee is applied
   * @param certificateId The ID of the certificate
   * @param fullAmount The full amount of tokens withdrawn
   * @param feeAmount The amount of tokens taken as a fee
   */
  event EarlyWithdrawalFeeApplied(
    uint256 indexed certificateId,
    uint256 fullAmount,
    uint256 feeAmount
  );

  /**
   * @notice Emitted when the deposit fee is applied
   * @param certificateId The ID of the certificate
   * @param receivedTokenAmount The amount of tokens received
   * @param depositFee The amount of tokens taken as a fee
   */
  event DepositFeeApplied(
    uint256 indexed certificateId,
    uint256 receivedTokenAmount,
    uint256 depositFee
  );

  /**
   * @notice Emitted when an account withdraws a certificate's rewards
   * @param accountAddress The address of the account
   * @param certificateId The ID of the certificate
   * @param tokenAddress The address of the reward token
   * @param rewardAmount The amount of rewards withdrawn
   */
  event CertificateRewardsPay(
    address indexed accountAddress,
    uint256 indexed certificateId,
    address indexed tokenAddress,
    uint256 rewardAmount
  );

  /**
   * @notice Emitted when a certificate is liquidated (all tokens withdrawn and rewards paid sold for ETH)
   * @param certificateId The ID of the certificate
   * @param beneficiary The address of the beneficiary
   * @param amountInETH The sum of tokens liquidated in ETH
   */
  event CertificateLiquidation(
    uint256 indexed certificateId,
    address indexed beneficiary,
    uint256 amountInETH
  );

  /**
   * @notice Emitted when a certificate is exited (all tokens withdrawn and rewards paid)
   * @param certificateId The ID of the certificate
   * @param beneficiary The address of the beneficiary
   */
  event CertificateExit(uint256 indexed certificateId, address indexed beneficiary);

  /**
   * @notice Emitted when a certificate is burned
   * @param certificateId The ID of the certificate
   */
  event CertificateBurned(uint256 indexed certificateId);

  /**
   * @notice Emitted when a token is recovered
   * @param tokenAddress The address of the token that was recovered
   * @param amount The amount of tokens that were recovered
   */
  event TokenRecovered(address tokenAddress, uint256 amount);

  /**
   * @notice Emitted when ETH is recovered
   * @param amount The amount of ETH that was recovered
   */
  event EtherRecovered(uint256 amount);

  /**
   * @notice Emitted when a certificate is split
   * @param certificateId1 The ID of the original certificate
   * @param certificateId2 The ID of the newly created certificate
   */
  event CertificateSplit(uint256 indexed certificateId1, uint256 indexed certificateId2);

  /**
   * @notice Emitted when a certificate is liquidated
   * @param certificateId The ID of the certificate
   * @param amountInETH The sum of tokens liquidated in ETH
   */
  event CertificateLiquidation(uint256 indexed certificateId, uint256 amountInETH);

  /**
   * @notice Emitted when unredeemed rewards are withdrawn by the admin
   * @param tokenAddress The address of the reward token
   * @param amount The amount of tokens withdrawn
   */
  event UnredeemedRewardsWithdrawal(address indexed tokenAddress, uint256 amount);

  /**
   * @notice Emitted when a certificate is frozen
   * @param certificateId The ID of the certificate
   * @param frozenUntil The timestamp of when the certificate will be unfrozen
   */
  event CertificateFreeze(uint256 indexed certificateId, uint256 frozenUntil);

  /**
   * @notice Emitted when two certificates are merged
   * @param certificateId1 The ID of the first certificate
   * @param certificateId2 The ID of the second certificate
   */
  event CertificatesMerge(uint256 indexed certificateId1, uint256 indexed certificateId2);

  /**
   * @notice Emitted when new rewards are added to the pool
   * @param tokenAddress The address of the reward token
   * @param amount The amount of tokens added
   */
  event RewardDeposit(address indexed tokenAddress, uint256 amount);

  /**
   * @notice Emitted when an ERC20 token is recovered
   * @param tokenAddress The address of the token that was recovered
   * @param amount The amount of tokens that were recovered
   */
  event ERC20Recovered(address tokenAddress, uint256 amount);

  /**
   * @notice Emitted when ETH is recovered
   * @param amount The amount of ETH that was recovered
   */
  event ETHRecovered(uint256 amount);
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.25;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {EnumerableMap} from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import {Checkpoints} from "@openzeppelin/contracts/utils/structs/Checkpoints.sol";

import {IWETH} from "../interfaces/IWETH.sol";

import {UD60x18} from "@prb/math/src/UD60x18.sol";

import {IMainHub} from "../interfaces/IMainHub.sol";
import {ITokenRouter} from "../periphery/interfaces/ITokenRouter.sol";
import {ICertificateNFTManager} from "../interfaces/ICertificateNFTManager.sol";

import {IBalanceFacet} from "../interfaces/facets/IBalanceFacet.sol";
import {ICycleFacet} from "../interfaces/facets/ICycleFacet.sol";
import {ICertificateFacet} from "../interfaces/facets/ICertificateFacet.sol";
import {IReadingFacet} from "../interfaces/facets/IReadingFacet.sol";
import {IRewardFacet} from "../interfaces/facets/IRewardFacet.sol";

import {LibCommon} from "../lib/LibCommon.sol";

import {ShareType, OptionType, DistributionType, VerificationLevel} from "./Enums.sol";

/**
 * @notice Represents the arguments needed to initialise a project
 * @param tokenRouterAddress Address of the TokenRouter contract
 * @param originalDeployerAddress Address of the original deployer
 * @param projectName Name of the project
 * @param distributionType Distribution type of the project
 * @param depositTokenAddress Address of the deposit token
 * @param settingsFlags Settings flags of the project
 * @param settingsData Settings data of the project
 */
struct InitArgs {
  // <immutable>
  address tokenRouterAddress;
  address originalDeployerAddress;
  string projectName;
  DistributionType distributionType;
  address depositTokenAddress;
  // </immutable>

  SettingsFlags settingsFlags;
  SettingsData settingsData;
}

/**
 * @notice Represents the arguments internally needed from MainHub to create a project
 * @param projectName Name of the project
 * @param distributionType Distribution type of the project
 * @param depositTokenAddress Address of the deposit token
 * @param settingsFlags Settings flags of the project
 * @param settingsData Settings data of the project
 */
struct ProjectArgs {
  // <immutable>
  string projectName;
  DistributionType distributionType;
  address depositTokenAddress;
  // </immutable>

  SettingsFlags settingsFlags;
  SettingsData settingsData;
}

/**
 * @notice Represents the state of a project
 * @param WETH WETH contract
 * @param verificationLevel Verification level of the project
 * @param projectName Name of the project
 * @param tokenRouter TokenRouter contract
 * @param nftManager CertificateNFTManager contract
 * @param originalDeployerAddress Address of the original deployer
 * @param depositToken Deposit token (if any)
 * @param distributionType Distribution type of the project
 * @param mainHub MainHub contract
 * @param settingsFlags Settings flags of the project
 * @param settingsData Settings data of the project
 * @param nextCertificateId Next certificate ID. Starts at 1 because 0 is a reserved certificate ID. Makes more sense to start Serial #s at 1
 * @param ledger Ledger of certificates
 * @param certificates Set of certificates
 * @param freezer Frozen certificates
 * @param rewardTokens Reward tokens
 * @param rewardSlots Reward slots
 * @param cycles Cycles
 * @param cycleCount Cycle count
 * @param totalTokenShares Total tShares
 * @param totalVirtualShares Total vShares
 * @param totalShares Total shares (tShares + vShares)
 * @param totalSharesHistory Total shares history checkpoints
 * @param vSharesMultiplier Virtual shares multiplier (to make them equivalent to token shares)
 */
struct ProjectData {
  IWETH WETH;
  VerificationLevel verificationLevel;
  string projectName;
  ITokenRouter tokenRouter;
  ICertificateNFTManager nftManager;
  address originalDeployerAddress;
  IERC20 depositToken;
  DistributionType distributionType;
  IMainHub mainHub;
  // -----------------------------------------------------------------------
  // storage variables
  // -----------------------------------------------------------------------

  SettingsFlags settingsFlags;
  SettingsData settingsData;
  // -----------------------------------------------------------------------
  // certificates
  // -----------------------------------------------------------------------

  uint256 nextCertificateId;
  mapping(uint256 => Certificate) ledger;
  EnumerableSet.UintSet certificates;
  mapping(uint256 => FrozenCertificate) freezer;
  // -----------------------------------------------------------------------
  // rewards
  // -----------------------------------------------------------------------

  EnumerableSet.AddressSet rewardTokens;
  mapping(address => RewardSlot) rewardSlots;
  // -----------------------------------------------------------------------
  // cycles
  // -----------------------------------------------------------------------

  mapping(uint256 => Cycle) cycles;
  uint256 cycleCount;
  // -----------------------------------------------------------------------
  // shares stored in the project
  // -----------------------------------------------------------------------

  uint256 totalTokenShares;
  uint256 totalVirtualShares;
  uint256 totalShares;
  Checkpoints.Trace160 totalSharesHistory;
  uint256 vSharesMultiplier;
}

/**
 * @notice This struct represents a frozen certificate.
 * @param certificateId The ID of the certificate
 * @param frozenUntil The timestamp of when the certificate will be unfrozen
 */
struct FrozenCertificate {
  uint256 certificateId;
  uint256 frozenUntil;
}

/**
 * @notice This struct represents a cycle
 * @param id The ID of the cycle
 * @param startTime The timestamp of when the cycle started
 * @param finishTime The timestamp of when the cycle will end
 * @param activated Whether the cycle is activated
 * @param finished Whether the cycle is finished
 * @param lastUpdateTime The timestamp of the last time the cycle was updated
 * @param lastCumulativeRewardRates The last cumulative reward rates for each reward token when the cycle ended.
 */
struct Cycle {
  uint256 id;
  uint256 startTime;
  uint256 finishTime;
  bool activated;
  bool finished;
  uint256 lastUpdateTime;
  mapping(address => UD60x18) lastCumulativeRewardRates;
}

/**
 * @notice This struct represents a reward slot
 * @param rewardToken The reward token
 * @param cumulativeRewardRate The amount of rewards per share that was previously calculated
 * @param rewardRate The amount of rewards per share that is currently calculated
 * @param pendingDeposits The amount of tokens that were deposited inbetween cycles
 * @param lastUpdateTime The timestamp of the last time the rewards were updated
 */
struct RewardSlot {
  IERC20 rewardToken;
  UD60x18 cumulativeRewardRate;
  UD60x18 rewardRate;
  uint256 pendingDeposits;
  uint256 lastUpdateTime;
}

/**
 * @notice This struct represents a certificate's reward tracker for a specific reward token.
 * @param lastTouchedCycle The ID of the last cycle that the certificate was updated in.
 * @param cumulativeRewardRate The amount of rewards per share that was previously calculated.
 * @param rewardsClaimable The amount of rewards that the certificate has earned but not yet claimed.
 * @param rewardsLocked The amount of rewards that the certificate has earned but cannot claim yet.
 * @param rewardsPaid The amount of rewards that the certificate has earned and claimed.
 */
struct CertificateRewardTracker {
  UD60x18 cumulativeRewardRate;
  uint256 rewardsClaimable;
  uint256 rewardsLocked;
  uint256 rewardsPaid;
  uint256 lastUpdateTime;
}

/**
 * @notice Represents an account's certificate in the pool
 * @param id The ID of the certificate
 * @param balance The amount of tokens deposited
 * @param shareType The type of share (TSHARE or VSHARE)
 * @param rewardTrackers The reward trackers for each reward token
 * @param lastUpdateTime The timestamp of the last time the certificate was updated
 * @param lastDepositTime The timestamp of the last time the certificate was deposited
 */
struct Certificate {
  uint256 id;
  ShareType shareType;
  uint256 balance;
  Checkpoints.Trace160 balanceHistory;
  mapping(address rewardTokenAddress => CertificateRewardTracker) rewardTrackers;
  uint256 lastUpdateTime;
  uint256 lastDepositTime;
  uint256 lastBalanceUpdateTime;
}

/**
 * @notice Represents the settings flags of the project
 * @param vSharesEnabled Whether the project allows the creation of virtual shares
 * @param certificateCreateEnabled Whether the project allows the creation of new certificates
 * @param certificateCreateCapEnabled Whether the project has a cap on the amount of certificates that can be created
 * @param certificateAllowMerge Whether the project allows the merge of 2 or more certificates into a single certificate
 * @param certificateAllowSplit Whether the project allows the split of a certificate into 2 certificates
 * @param certificateAllowLiquidation Whether the project allows the liquidation of all assets in a certificate at market rates
 * @param certificateAllowDeposit Whether the project allows the accounts to deposit tokens
 * @param certificateDepositCapEnabled Whether the project has a cap on the amount of tokens that can be deposited in a certificate
 * @param certificateEarlyWithdrawalFeeEnabled Whether the project has an early withdrawal fee
 * @param certificateMinimumDepositEnabled Whether the project has a minimum deposit amount
 */
struct SettingsFlags {
  // once disabled, this option is irreversible.
  bool vSharesEnabled;
  // doesn't affect existing certificates
  bool certificateCreateEnabled;
  // doesn't affect existing certificates if the number of existing certificates
  // is higher than the cap
  bool certificateCreateCapEnabled;
  // rewards of the merged certificates will be withdrawn to the user
  // and the deposit will be added to the resulting certificate
  bool certificateAllowMerge;
  // will be rejected if the resulting certificates will have a balance
  // higher than the deposit cap or if the resulting certificates count will be higher
  // than the certificate creation cap
  // rewards of the original certificate will be withdrawn to the user
  // and the deposit will be split between the resulting certificates
  // (if the deposit is an odd number, the extra token will be sent to the first certificate)
  // (rejects if certificate is frozen)
  bool certificateAllowSplit;
  // (rejects if the certificate is frozen)
  bool certificateAllowLiquidation;
  // if enabled, the deposit function will be rejected
  // * but the withdraw function will always be allowed
  // (respects the early withdrawal fee)
  // (doesn't affect existing deposits or certificates)
  bool certificateAllowDeposit;
  // if enabled, the deposit function will be rejected if the deposit
  // will cause the certificate to have a balance higher than the deposit cap
  // ? SUGGESTION: Maybe the frontend should check the max amount of tokens that
  // ? SUGGESTION: : can be deposited and show a warning if the deposit will be rejected
  // (current deposits will not be affected)
  // (doesn't affect existing deposits or certificates)
  bool certificateDepositCapEnabled;
  // if enabled, the early withdrawal fee will be applied
  bool certificateEarlyWithdrawalFeeEnabled;
  // if enabled, it a minimum amount of tokens will be required to deposit
  bool certificateMinimumDepositEnabled;
}

/**
 * @notice Represents the settings of the project
 * @param depositCap Maximum amount of tokens that can be deposited in a certificate
 * @param depositMinimumAmount Minimum amount of tokens that can be deposited in a certificate
 * @param depositFeePercentage Percentage of the deposit fee
 * @param earlyWithdrawalFeePercentage Percentage of the early withdrawal fee
 * @param earlyWithdrawalFeeDuration Period of time (in seconds) that the early withdrawal fee is active
 * @param certificateCap Maximum amount of certificates that can be created
 */
struct SettingsData {
  uint256 depositCap;
  uint256 depositMinimumAmount;
  uint32 depositFeePercentage;
  uint32 earlyWithdrawalFeePercentage;
  uint32 earlyWithdrawalFeeDuration;
  uint16 certificateCap;
}

/**
 * @notice Represents the available roles in the project
 * @param adminRole Can manage the project settings and manage all roles
 * @param managerRole Can only manage the project settings
 * @param rewardRole Can only manage the project rewards
 */
struct AvailableRoles {
  bytes32 adminRole;
  bytes32 managerRole;
  bytes32 rewardRole;
}

library Outputs {
  /**
   * @notice Represents the details of a project in a readable format
   * @param projectOwner Address of the project original deployer
   * @param projectName Name of the project
   * @param verificationLevel Verification level of the project (unknown, standard, ...)
   * @param distributionType Distribution type of the project (all at once, progressive)
   * @param depositToken Struct with details and metadata of the deposit token
   * @param settingsFlags Settings flags of the project
   * @param settingsData Settings data of the project
   * @param totalTokenShares Total amount of token shares deposited in the pool
   * @param totalVirtualShares Total amount of virtual shares in the pool
   * @param totalShares Global amount of vshares + tshares supply
   * @param cycleCount Current cycle count
   */
  struct ProjectDetails {
    address projectOwner;
    string projectName;
    VerificationLevel verificationLevel;
    DistributionType distributionType;
    ITokenRouter.TokenDetails depositToken;
    SettingsFlags settingsFlags;
    SettingsData settingsData;
    uint256 totalTokenShares;
    uint256 totalVirtualShares;
    uint256 totalShares;
    uint256 cycleCount;
  }

  /**
   * @notice Represents the details of a cycle in a readable format
   * @param id ID of the cycle
   * @param startTime Timestamp of when the cycle started
   * @param finishTime Timestamp of when the cycle will end
   * @param activated Whether the cycle is activated
   * @param finished Whether the cycle is finished
   */
  struct CycleDetails {
    uint256 id;
    uint256 startTime;
    uint256 finishTime;
    bool activated;
    bool finished;
  }

  /**
   * @notice Represents the details of a certificate reward item in a readable format
   * @param tokenDetails Struct with details and metadata of the token
   * @param cumulativeRewardRate Amount of rewards per share that was previously calculated
   * @param rewardsClaimable Amount of rewards that the certificate has earned but not yet claimed
   * @param rewardsPaid Amount of rewards that the certificate has earned and claimed
   * @param rewardsLocked Amount of rewards that the certificate has earned but cannot claim yet
   */
  struct CertificateRewardItem {
    ITokenRouter.TokenDetails tokenDetails;
    uint256 cumulativeRewardRate;
    uint256 rewardsClaimable;
    uint256 rewardsPaid;
    uint256 rewardsLocked;
  }

  /**
   * @notice Represents the details of a freezer in a readable format
   * @param isFrozen Whether the certificate is frozen
   * @param frozenUntil Timestamp of when the certificate will be unfrozen
   */
  struct FreezerDetails {
    bool isFrozen;
    uint256 frozenUntil;
  }

  /**
   * @notice Represents a certificate in a readable format
   * @param id ID of the certificate
   * @param shareType Type of share (TSHARE or VSHARE)
   * @param balance Balance of the certificate in shares
   * @param rewards Reward details of the certificate
   * @param freezer Details of the freezer (lock status, lock time)
   * @param lastDepositTime Timestamp of the last time the certificate was deposited
   * @param lastUpdateTime Timestamp of the last time the certificate was updated
   */
  struct CertificateDetails {
    uint256 id;
    ShareType shareType;
    uint256 balance;
    CertificateRewardItem[] rewards;
    FreezerDetails freezer;
    uint256 lastDepositTime;
    uint256 lastUpdateTime;
  }

  /**
   * @notice Represents a reward slot in a readable format
   * @param tokenDetails Struct with details and metadata of the token
   * @param cumulativeRewardRate Amount of rewards per share that was previously calculated
   * @param rewardRate Amount of rewards per second that is currently calculated
   * @param remainingTokens Amount of tokens remaining for the reward slot in this cycle
   * @param remainingValueInUSD Value of the remaining tokens in USD
   * @param rewardsPerShare Amount of rewards per share that is currently calculated
   * @param pendingDeposits Amount of tokens that were deposited inbetween cycles to be added in the next cycle
   * @param lastUpdateTime Timestamp of the last time the rewards were updated
   */
  struct RewardSlotDetails {
    ITokenRouter.TokenDetails tokenDetails;
    uint256 cumulativeRewardRate;
    uint256 rewardRate;
    uint256 remainingTokens;
    uint256 remainingValueInUSD;
    uint256 rewardsPerShare;
    uint256 pendingDeposits;
    uint256 lastUpdateTime;
  }

  /**
   * @notice Represents a token with its balance and balance in USD
   * @param tokenDetails Details of the token
   * @param balance Balance of the token
   * @param balanceInUSD Balance of the token in USD
   */
  struct TokenWithBalanceDetails {
    ITokenRouter.TokenDetails tokenDetails;
    uint256 balance;
    uint256 balanceInUSD;
  }

  /**
   * @notice Represents a certificate NFT in a readable format
   * @param id ID of the certificate
   * @param tokenId ID of the NFT
   * @param owner Owner of the NFT
   * @param shareType Type of share (TSHARE or VSHARE)
   * @param depositBalance Balance of the deposit token
   * @param rewardBalances Balances of the reward tokens
   * @param totalValueInUSD Total value of the certificate in USD
   * @param lastUpdateTime Timestamp of the last time the certificate was updated
   * @param lastDepositTime Timestamp of the last time the certificate was deposited
   */
  struct CertificateNFTDetails {
    uint256 id;
    uint256 tokenId;
    address owner;
    ShareType shareType;
    TokenWithBalanceDetails depositBalance;
    TokenWithBalanceDetails[] rewardBalances;
    uint256 totalValueInUSD;
    uint256 lastUpdateTime;
    uint256 lastDepositTime;
  }
}