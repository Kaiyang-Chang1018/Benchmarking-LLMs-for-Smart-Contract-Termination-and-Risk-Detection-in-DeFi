// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
// SPDX-License-Identifier: UNLICENSED

import { ProxyOwnable } from "./utils/ProxyOwnable.sol";
import { MerkleProofLib } from "./utils/MerkleProofLib.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { Errors } from "./library/errors/Errors.sol";

pragma solidity >=0.8.4 <0.9.0;

contract BpxClaim is ProxyOwnable {
    struct ClaimWindow {
        IERC20 bpxContract;
        uint48 startTime;
        uint48 endTime;
    }

    event CurrencyClaimed(address indexed claimant, uint256 indexed amount, address indexed operator);

    bytes32 public authRoot;
    ClaimWindow private _claim;

    mapping(address => bool) private _claimed;

    constructor(address bpx) {
        if (bpx.code.length == 0) {
            revert Errors.NotAContract();
        }

        _claim.bpxContract = IERC20(bpx);
    }

    function bpxSupply() public view returns (uint256) {
        return _claim.bpxContract.balanceOf(address(this));
    }

    function getClaimMetadata() public view returns (ClaimWindow memory) {
        return _claim;
    }

    function claimed(address claimant) public view returns (bool) {
        return _claimed[claimant];
    }

    function withdraw(address recipient) external onlyAuthorized {
        _claim.bpxContract.transfer(recipient, bpxSupply());
    }

    function setClaimWindow(uint48 startTime, uint48 endTime, bytes32 merkleRoot) external onlyAuthorized {
        if (endTime < startTime) {
            revert Errors.InvalidTimeRange(startTime, endTime);
        }
        _claim.startTime = startTime;
        _claim.endTime = endTime;
        authRoot = merkleRoot;
    }

    function claim(address recipient, uint256 quantity, bytes32[] calldata proof) external {
        uint256 windowStart = _claim.startTime;
        uint256 windowEnd = _claim.endTime;
        IERC20 bpx = _claim.bpxContract;

        if (block.timestamp < windowStart) {
            revert Errors.ClaimWindowClosed();
        }
        if (block.timestamp > windowEnd) {
            revert Errors.ClaimWindowClosed();
        }
        if (_claimed[recipient]) {
            revert Errors.DuplicateCall();
        }

        bytes32 leaf = keccak256(abi.encodePacked(recipient, quantity));
        if (!MerkleProofLib.verify(proof, authRoot, leaf)) {
            revert Errors.UserPermissions();
        }

        _claimed[recipient] = true;
        emit CurrencyClaimed(recipient, quantity, msg.sender);
        bpx.transfer(recipient, quantity);
    }
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.4 <0.9.0;

library Errors {
    error LinkError();
    error ArrayMismatch();
    error OutOfRange(uint256 value);
    error OutOfRangeSigned(int256 value);
    error UnsignedOverflow(uint256 value);
    error SignedOverflow(int256 value);
    error DuplicateCall();

    error NotAContract();
    error InterfaceNotSupported();
    error NotInitialized();
    error BadSender(address expected, address caller);
    error AddressTarget(address target);
    error UserPermissions();

    error InsufficientBalance(uint256 available, uint256 required);
    error InsufficientSupply(uint256 supply, uint256 available, int256 requested);  // 0x5437b336
    error InsufficientAvailable(uint256 available, uint256 requested);
    error InvalidToken(uint256 tokenId);                                            // 0x925d6b18
    error TokenNotMintable(uint256 tokenId);
    error MintingClosed();
    error ClaimWindowClosed();
    error ClaimActive();
    error InvalidTimeRange(uint256 startTime, uint256 endTime);

    error ERC1155Receiver();

    error ContractPaused();

    error PaymentFailed(uint256 amount);
    error IncorrectPayment(uint256 required, uint256 provided);                     // 0x0d35e921
	error TooManyForTransaction(uint256 mintLimit, uint256 amount);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/// @notice Gas optimized merkle proof verification library.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/MerkleProofLib.sol)
/// @author Modified from Solady (https://github.com/Vectorized/solady/blob/main/src/utils/MerkleProofLib.sol)
library MerkleProofLib {
    function verify(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool isValid) {
        /// @solidity memory-safe-assembly
        assembly {
            if proof.length {
                // Left shifting by 5 is like multiplying by 32.
                let end := add(proof.offset, shl(5, proof.length))

                // Initialize offset to the offset of the proof in calldata.
                let offset := proof.offset

                // Iterate over proof elements to compute root hash.
                // prettier-ignore
                for {} 1 {} {
                    // Slot where the leaf should be put in scratch space. If
                    // leaf > calldataload(offset): slot 32, otherwise: slot 0.
                    let leafSlot := shl(5, gt(leaf, calldataload(offset)))

                    // Store elements to hash contiguously in scratch space.
                    // The xor puts calldataload(offset) in whichever slot leaf
                    // is not occupying, so 0 if leafSlot is 32, and 32 otherwise.
                    mstore(leafSlot, leaf)
                    mstore(xor(leafSlot, 32), calldataload(offset))

                    // Reuse leaf to store the hash to reduce stack operations.
                    leaf := keccak256(0, 64) // Hash both slots of scratch space.

                    offset := add(offset, 32) // Shift 1 word per cycle.

                    // prettier-ignore
                    if iszero(lt(offset, end)) { break }
                }
            }

            isValid := eq(leaf, root) // The proof is valid if the roots match.
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4 <0.9.0;

import { Errors } from "../library/errors/Errors.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there are two accounts (an owner and a proxy) that can be granted exclusive
 * access to specific functions. Only the owner can set the proxy.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This contract enables a pattern whereby another contract can be set as a
 * proxy to interact with the inheriting contract with administrative privs.
 * It also enables a pattern whereby the contract owner is never used for
 * general contract admin actions. It's only used to set privileged accounts,
 * while the proxy account operates the contract as the administrator.
 *
 * This module is used through inheritance. It will make available the modifiers
 * `onlyOwner` and `onlyAuthorized`, which can be applied to your functions to
 * restrict their use to the owner or the proxy.
 */
abstract contract ProxyOwnable {
    address public _owner;
    address public _proxy;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(msg.sender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Returns the address of the current proxy.
     */
    function proxy() public view virtual returns (address) {
        return _proxy;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        if (owner() != msg.sender) revert Errors.UserPermissions();
        _;
    }

    /**
     * @dev Throws if called by any account other than the proxy or the owner.
     */
    modifier onlyAuthorized() {
        if (
            proxy() != msg.sender &&
            owner() != msg.sender
        ) revert Errors.UserPermissions();
        _;
    }

    function checkAuthorized(address operator) public view virtual {
        if (
            proxy() != operator &&
            owner() != operator
        ) revert Errors.UserPermissions();
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) revert Errors.AddressTarget(newOwner);
        _setOwner(newOwner);
    }

    /**
     * @dev Sets the proxy for the contract to a new account (`newProxy`).
     * Can only be called by the current owner.
     */
    function setProxy(address newProxy) public virtual onlyOwner {
        _proxy = newProxy;
    }

    function _setOwner(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}