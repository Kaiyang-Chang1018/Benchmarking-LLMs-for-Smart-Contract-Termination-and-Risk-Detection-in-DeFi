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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.20;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS
    }

    /**
     * @dev The signature derives the `address(0)`.
     */
    error ECDSAInvalidSignature();

    /**
     * @dev The signature has an invalid length.
     */
    error ECDSAInvalidSignatureLength(uint256 length);

    /**
     * @dev The signature has an S value that is in the upper half order.
     */
    error ECDSAInvalidSignatureS(bytes32 s);

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with `signature` or an error. This will not
     * return address(0) without also returning an error description. Errors are documented using an enum (error type)
     * and a bytes32 providing additional information about the error.
     *
     * If no error is returned, then the address can be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError, bytes32) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength, bytes32(signature.length));
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, signature);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     */
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError, bytes32) {
        unchecked {
            bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
            // We do not check for an overflow here since the shift operation results in 0 or 1.
            uint8 v = uint8((uint256(vs) >> 255) + 27);
            return tryRecover(hash, v, r, s);
        }
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, r, vs);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError, bytes32) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS, s);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature, bytes32(0));
        }

        return (signer, RecoverError.NoError, bytes32(0));
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, v, r, s);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Optionally reverts with the corresponding custom error according to the `error` argument provided.
     */
    function _throwError(RecoverError error, bytes32 errorArg) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert ECDSAInvalidSignature();
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert ECDSAInvalidSignatureLength(uint256(errorArg));
        } else if (error == RecoverError.InvalidSignatureS) {
            revert ECDSAInvalidSignatureS(errorArg);
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


/*
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░ ░▒▓██████▓▒░  
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░        
░▒▓████████▓▒░░▒▓██████▓▒░░▒▓███████▓▒░░▒▓█▓▒░        
░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░      ░▒▓█▓▒░        
░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░       ░▒▓██████▓▒░  
                                                     
                                                      


/// @title NodemarketClaim - A contract for claiming ERC20 tokens with signature verification
/// @notice This contract allows users to claim ERC20 tokens based on off-chain signature verification
/// @dev Uses EIP-712 for secure signature verification and supports both single and batch claims
*/ contract NodemarketClaim is Ownable {
    using ECDSA for bytes32;

    // EIP-712 typehash for the claim
    bytes32 public constant CLAIM_TYPEHASH =
        keccak256("Claim(address holder,uint256 tokenId,uint256 amount,uint256 nonce,uint256 lastClaimTimestamp)");
    // EIP-712 typehash for the multi-claim
    bytes32 public constant MULTI_CLAIM_TYPEHASH = keccak256(
        "MultiClaim(address holder,uint256[] tokenIds,uint256[] amounts,uint256 nonce,uint256[] lastClaimTimestamps)"
    );
    // EIP-712 domain separator
    bytes32 public immutable DOMAIN_SEPARATOR;

    /// @notice The ERC20 token that can be claimed
    IERC20 public claimToken;

    /// @notice Mapping of authorized signers
    mapping(address => bool) public signers;

    /// @notice Mapping of last claim timestamp per holder and token ID
    mapping(address => mapping(uint256 => uint256)) public lastClaimTimestamp;

    /// @notice Mapping of nonces per holder to prevent replay attacks
    mapping(address => uint256) public nonces;

    /// @notice The daily rate at which tokens can be claimed
    uint256 public dailyClaimRate;
    /// @notice The timestamp when claiming becomes available
    uint256 public claimStartTimestamp;

    /// @notice Emitted when tokens are claimed
    /// @param holder The address claiming tokens
    /// @param tokenId The ID of the token being claimed for
    /// @param amount The amount of tokens claimed
    event Claimed(address indexed holder, uint256 indexed tokenId, uint256 amount);
    /// @notice Emitted when the daily claim rate is updated
    event UpdatedDailyClaimRate(uint256 dailyClaimRate);
    /// @notice Emitted when the claim start timestamp is updated
    event UpdatedClaimStartTimestamp(uint256 claimStartTimestamp);
    /// @notice Emitted when a signer's status is updated
    event UpdateSigner(address signer, bool value);

    error InvalidNonce();
    error InvalidSignature();
    error ArrayLengthMismatch();
    error InvalidSigner();

    /// @notice Initializes the contract with the claim token and initial signer
    /// @param _claimToken Address of the ERC20 token that can be claimed
    /// @param signer Address of the initial authorized signer
    constructor(address _claimToken, address signer) Ownable(msg.sender) {
        require(signer != address(0), InvalidSigner());
        claimToken = IERC20(_claimToken);

        signers[signer] = true;
        emit UpdateSigner(signer, true);

        _setClaimStartTimestamp(block.timestamp);

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes("NodemarketClaim")),
                keccak256(bytes("1")),
                block.chainid,
                address(this)
            )
        );
    }

    /// @notice Claims tokens for a single token ID
    /// @param tokenId The ID of the token to claim for
    /// @param amount The amount of tokens to claim
    /// @param signature The EIP-712 signature authorizing the claim
    function claim(uint256 tokenId, uint256 amount, bytes calldata signature) external {
        uint256 nonce = nonces[msg.sender];
        bytes32 structHash = keccak256(
            abi.encode(CLAIM_TYPEHASH, msg.sender, tokenId, amount, nonce, lastClaimTimestamp[msg.sender][tokenId])
        );
        bytes32 hash = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));
        address signer = hash.recover(signature);

        require(signers[signer], InvalidSignature());

        lastClaimTimestamp[msg.sender][tokenId] = block.timestamp;

        unchecked {
            nonces[msg.sender]++;
        }

        require(claimToken.transfer(msg.sender, amount), "Token transfer failed");
        emit Claimed(msg.sender, tokenId, amount);
    }

    /// @notice Claims tokens for multiple token IDs in a single transaction
    /// @param tokenIds Array of token IDs to claim for
    /// @param amounts Array of amounts to claim for each token ID
    /// @param signature The EIP-712 signature authorizing the multi-claim
    function multiClaim(uint256[] calldata tokenIds, uint256[] calldata amounts, bytes calldata signature) payable external {
        require(tokenIds.length == amounts.length && amounts.length > 0, ArrayLengthMismatch());

        uint256 nonce = nonces[msg.sender];
        uint256[] memory lastClaimTimestamps = new uint256[](tokenIds.length);
        uint256 totalAmount = 0;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            lastClaimTimestamps[i] = lastClaimTimestamp[msg.sender][tokenIds[i]];
            lastClaimTimestamp[msg.sender][tokenIds[i]] = block.timestamp;
            totalAmount += amounts[i];
            emit Claimed(msg.sender, tokenIds[i], amounts[i]);
        }

        bytes32 structHash = keccak256(
            abi.encode(
                MULTI_CLAIM_TYPEHASH,
                msg.sender,
                keccak256(abi.encodePacked(tokenIds)),
                keccak256(abi.encodePacked(amounts)),
                nonce,
                keccak256(abi.encodePacked(lastClaimTimestamps))
            )
        );

        bytes32 hash = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));
        address signer = hash.recover(signature);

        require(signers[signer], InvalidSignature());

        unchecked {
            nonces[msg.sender] += tokenIds.length;
        }

        require(claimToken.transfer(msg.sender, totalAmount), "Token transfer failed");
    }

    /// @notice Sets the daily rate at which tokens can be claimed
    /// @param _dailyClaimRate The new daily claim rate
    function setDailyClaimRate(uint256 _dailyClaimRate) external onlyOwner {
        dailyClaimRate = _dailyClaimRate;
        emit UpdatedDailyClaimRate(_dailyClaimRate);
    }

    /// @notice Adds or removes an authorized signer
    /// @param signer Address of the signer to update
    /// @param value True to authorize, false to revoke
    function setSigner(address signer, bool value) external onlyOwner {
        require(signer != address(0), InvalidSigner());
        signers[signer] = value;
        emit UpdateSigner(signer, value);
    }

    /// @notice Allows the owner to withdraw any ERC20 tokens from the contract
    /// @param token The ERC20 token to withdraw
    /// @param to The address to send the tokens to
    /// @param amount The amount of tokens to withdraw
    function withdraw(IERC20 token, address to, uint256 amount) external onlyOwner {
        require(token.transfer(to, amount), "Token transfer failed");
    }

    function withdrawEth(address to, uint256 amount) external onlyOwner {
        payable(to).call{value: amount}("");
    }

    /// @notice Sets the timestamp when claiming becomes available
    /// @param _claimStartTimestamp The new claim start timestamp
    function setClaimStartTimestamp(uint256 _claimStartTimestamp) external onlyOwner {
        _setClaimStartTimestamp(_claimStartTimestamp);
    }

    /// @dev Internal function to set the claim start timestamp
    function _setClaimStartTimestamp(uint256 _claimStartTimestamp) internal {
        claimStartTimestamp = _claimStartTimestamp;
        emit UpdatedClaimStartTimestamp(_claimStartTimestamp);
    }

    /// @notice Gets the last claim timestamps for multiple token IDs
    /// @param owner The address to check timestamps for
    /// @param tokenIds Array of token IDs to check
    /// @return Array of last claim timestamps corresponding to the input token IDs
    function getMultiLastClaimTimestamp(address owner, uint256[] memory tokenIds)
        public
        view
        returns (uint256[] memory)
    {
        uint256[] memory values = new uint256[](tokenIds.length);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            values[i] = lastClaimTimestamp[owner][tokenIds[i]];
        }

        return values;
    }
}