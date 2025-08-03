// Sources flattened with hardhat v2.22.17 https://hardhat.org

// SPDX-License-Identifier: MIT AND UNLICENSED

// File @openzeppelin/contracts/utils/Context.sol@v4.7.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
}


// File @openzeppelin/contracts/access/Ownable.sol@v4.7.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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


// File @openzeppelin/contracts/utils/Strings.sol@v4.7.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}


// File @openzeppelin/contracts/utils/cryptography/ECDSA.sol@v4.7.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.3) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

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
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
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
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
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
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}


// File @openzeppelin/contracts/security/ReentrancyGuard.sol@v4.7.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.7.3

// Original license: SPDX_License_Identifier: MIT
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


// File contracts/PresaleControl.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity =0.8.19;

contract PresaleControl is Ownable, ReentrancyGuard {
    using ECDSA for bytes32;

    event Buy(int8 round, address indexed from, uint256 value, uint256 token);
    event Transfer(address indexed to, uint256 token);

    address public tokenAddr; // erc20 token address, decimals 1e18
    address public treasuryAddr; // ETH treasure address
    int8 public roundLatest = -1; // round is start at 0
    string public name = 'GLS sale';

    struct RoundOpt {
        uint256 startTime; // round start at
        uint256 endTime; // round end at
        uint256 totalSupply; // total erc20 token supply for this round
        uint256 raiseCap; // total raise cap, 0 means nolimit
        uint256 perUnit; // token amount = perUnit * 1ETH, 0 means we should wait for the round to end
        uint256 minBuy; //  minimun amount per wallet
        uint256 maxBuy; // maximum amount per wallet, 0 means nolimit
        address signerAddress; // signer for whitelist, empty means nolimit

        // vesting period
        uint256 vestingStartTime; // vestingStartTime > tokenReleaseAt
        uint256 vestingEndTime; //
        uint256 initVestedPerc; // 0~100
    }

    struct RoundStat {
        uint256 totalRaised; // eth
        uint256 totalToken; // token
        uint256 totalClaim; // token
    }

    struct Wallet {
        uint256 totalDeposited; // eth
        uint256 totalToken; // token
        uint256 totalClaim; // token
    }

    mapping(int8 => RoundOpt) public roundOpts;
    mapping(int8 => RoundStat) public roundStat;
    mapping(int8 => mapping(address => Wallet)) public wallets;

    constructor(address _tokenAddr, address _treasuryAddr) {
        tokenAddr = _tokenAddr;
        treasuryAddr = _treasuryAddr;
    }

    // ============= State Function  =============
    
    function currentRound() public view returns (int8) {
        int8 _currentRound = -1;
        for (int8 roundNum = 0; roundNum <= roundLatest; roundNum++) {
            RoundOpt storage opt = roundOpts[roundNum];
            if (opt.startTime <= block.timestamp) {
                _currentRound = roundNum;
            }
        } 
        return _currentRound;
    }

    // ============= Exchange Function  =============

    function buy(bytes memory signature) external payable {
        int8 _currentRound = currentRound();

        RoundOpt storage opt = roundOpts[_currentRound];
        RoundStat storage stat = roundStat[_currentRound];
        Wallet storage wallet = wallets[_currentRound][msg.sender];

        _requireValidRoundWallet(_currentRound, wallet, opt, stat, signature);

        // record raise
        stat.totalRaised += msg.value;
        wallet.totalDeposited += msg.value;

        // exchange token (if perUnit == 0, the amount is determined at the end of the round)
        uint256 amount = opt.perUnit * msg.value;

        // transfer to treasure
       (payable(treasuryAddr)).transfer(msg.value);

        emit Buy(_currentRound, msg.sender, msg.value, amount);

        if (amount > 0) {
            wallet.totalToken += amount;
            stat.totalToken += amount;
        }
    }

    // ============= Claim Fuciton ===============

    // User claim
    function totalToken(address addr) external view returns (uint256 deposited, uint256 amount, uint256 claimable, uint256 claimed) {
        int8 _currentRound = currentRound();

        for (int8 roundNum = 0; roundNum <= _currentRound; roundNum++) {
            RoundOpt storage opt = roundOpts[roundNum];
            RoundStat storage stat = roundStat[roundNum];
            Wallet storage wallet = wallets[roundNum][addr];

            amount += _getBoughtToken(wallet, opt, stat);
            claimable += _claimableToken(wallet, opt, stat);
            claimed += wallet.totalClaim;
            deposited += wallet.totalDeposited;
        }

        return (deposited, amount, claimable, claimed);
    }

    function _getBoughtToken(
        Wallet storage wallet,
        RoundOpt storage opt,
        RoundStat storage stat
    ) private view returns (uint256) {
        if (opt.perUnit == 0) {
            if (opt.endTime > block.timestamp) {
                return 0;
            } else {
                return opt.totalSupply / stat.totalRaised * wallet.totalDeposited;
            }
        } else {
            return wallet.totalToken;
        }
    }

    function _claimableToken(
        Wallet storage wallet,
        RoundOpt storage opt,
        RoundStat storage stat
    ) private view returns (uint256) {
        uint256 _totalToken = _getBoughtToken(wallet, opt, stat);

        uint256 vested = getVestedAmount(_totalToken, opt);

        require(vested <= _totalToken, "AssertionFailed: vested <= _totalToken");
        require(vested >= wallet.totalClaim, "AssertionFailed: vested >= wallet.totalClaim");

        return vested - wallet.totalClaim;
    }

    function getVestedAmount(uint256 boughtAmount, RoundOpt storage opt) private view returns (uint256) {
        if (opt.vestingStartTime > block.timestamp) {
            return 0;
        }

        uint256 initVestedAmount = boughtAmount / 100 * opt.initVestedPerc;

        uint256 vestingAmount = boughtAmount - initVestedAmount;

        uint256 vestedAmount = 0;
        if (opt.vestingEndTime < block.timestamp) {
            vestedAmount = vestingAmount;
        } else {
            vestedAmount = vestingAmount / (opt.vestingEndTime - opt.vestingStartTime) * (block.timestamp - opt.vestingStartTime);
        }

        return vestedAmount + initVestedAmount;
    }

    // claimAll claimable token
    function claimAll(address addr) external nonReentrant {
        int8 _currentRound = currentRound();

        for (int8 roundNum = 0; roundNum <= _currentRound; roundNum++) {
            _claim(addr, roundNum);
        }
    }
    
    function _claim(address addr, int8 roundNum) private {
        RoundStat storage stat = roundStat[roundNum];
        Wallet storage wallet = wallets[roundNum][addr];

        uint256 claimable = _claimableToken(wallet, roundOpts[roundNum], stat);
        if (claimable == 0) {
            return;
        }

        wallet.totalClaim += claimable;
        stat.totalClaim += claimable;
    
        IERC20(tokenAddr).transfer(addr, claimable);
        emit Transfer(addr, claimable);
    }

    // =========== Admin Fuction (onlyOwner)============

    // setup round
    function setupRound(
        int8 roundNum,
        RoundOpt calldata opt
    ) external onlyOwner {
        require(roundNum >= 0 && roundNum <= roundLatest + 1, "Presale: invalid roundNum");
        require(
            opt.startTime > 0 && opt.endTime > opt.startTime,
            "Presale: invalid startTime or endTime"
        );
        require(opt.minBuy > 0, "Presale: invalid minBuy");
        require(
            opt.raiseCap >= 0 && opt.totalSupply > 0,
            "Presale: invalid raiseCap or totalSupply"
        );

        if (opt.raiseCap > 0 && opt.totalSupply > 0) {
            require(opt.perUnit > 0, "Presale: invalid perUnit");
        }

        if (roundNum > roundLatest) {
            roundLatest = roundNum;
        }

        roundOpts[roundNum] = opt;
    }

    // withdraw
    function withdraw() external onlyOwner {
        uint256 count = address(this).balance;
        (payable(msg.sender)).transfer(count);
    }

    function withdrawToken(address addr) external onlyOwner {
        uint256 count = IERC20(tokenAddr).balanceOf(address(this));
        IERC20(tokenAddr).transfer(addr, count);
    }

    // internal helper
    function _requireValidRoundWallet(
        int8 _currentRound, 
        Wallet storage wallet,
        RoundOpt storage opt,
        RoundStat storage stat,
        bytes memory signature
    ) internal {
        // check basic
        require(_currentRound >= 0, "Presale Launch is not init");
        require(
            opt.startTime <= block.timestamp && block.timestamp <= opt.endTime,
            "Presale Launch: wrong time for this round"
        );

        require(msg.value >= opt.minBuy, "Presale: less than minBuy");

        // check whitelist
        if (opt.signerAddress != address(0)) {
            bytes32 messageHash = keccak256(abi.encodePacked(msg.sender));
            require(
                opt.signerAddress ==
                    messageHash.toEthSignedMessageHash().recover(signature),
                    "Presale: sender not in whitelist"
            );
        }

        // check round totalRaised
        if (opt.raiseCap > 0) {
            require(
                stat.totalRaised + msg.value <= opt.raiseCap,
                "Presale: more than raise cap!"
            );
        }

        // check user totalDeposited
        if (opt.maxBuy > 0) {
            require(
                wallet.totalDeposited + msg.value <= opt.maxBuy,
                "Presale: totalDeposited more than maxBuy"
            );
        }
    }
}