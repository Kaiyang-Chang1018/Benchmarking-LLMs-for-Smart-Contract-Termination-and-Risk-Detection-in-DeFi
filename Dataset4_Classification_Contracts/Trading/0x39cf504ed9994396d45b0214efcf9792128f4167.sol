// Sources flattened with hardhat v2.22.17 https://hardhat.org

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts/utils/Context.sol@v5.1.0

// Original license: SPDX_License_Identifier: MIT
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


// File @openzeppelin/contracts/access/Ownable.sol@v5.1.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

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


// File @openzeppelin/contracts/utils/cryptography/ECDSA.sol@v5.1.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/cryptography/ECDSA.sol)

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
    function tryRecover(
        bytes32 hash,
        bytes memory signature
    ) internal pure returns (address recovered, RecoverError err, bytes32 errArg) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly ("memory-safe") {
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
     * See https://eips.ethereum.org/EIPS/eip-2098[ERC-2098 short signatures]
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address recovered, RecoverError err, bytes32 errArg) {
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
    ) internal pure returns (address recovered, RecoverError err, bytes32 errArg) {
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


// File contracts/Presale.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.26;
interface IERC20 {
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract Presale is Ownable {
    using ECDSA for bytes32;
    // EIP-712 domain separator
    bytes32 private immutable DOMAIN_SEPARATOR;

    // EIP-712 type hash for Mint struct
    bytes32 private constant TOKEN_PURCHASE_TYPEHASH =
        keccak256(
            "tokenPurchase(address to,address paymentToken,uint256 amount,uint256 nonce,uint256 price)"
        );

    uint256 public startTime;
    uint256 public endTime;
    uint256 public minPurchase = 16650e18;
    uint256 public maxPurchase = 832500e18;

    uint256 public usdcPrice = 333e18; // Price in USDC (6 decimals)

    // State variables to store taxes for each token
    uint256 public totalUSDCContractTax;
    uint256 public totalCROContractTax;
    uint256 public totalETHContractTax;

    uint256 public tokensSold = 9030548447095000000000000; // Total tokens sold for ETh

    // Hardcoded values for presale 26_400_000 26.4 million tokens for cronos
    uint256 public constant totalTokensForPresale = 105_600_000e18; // 105_600_000e18 = 105.6 million tokens for ETH

    address public immutable crotchToken; // Token being sold
    address public immutable usdc; // USDC token address
    address public immutable cro; // CRON token address
    address public ownerTaxAddress = 0xe6565Edb482a663D0e7aD70A8006b97D97D15Ab6;

    address public signatureAddress =
        0x8EEC21e9C4C66A78370F697B78837ED5cf8871A5;
    bool public isPresaleActive; // Tracks if the presale is active

    mapping(address => uint256) public contributions;
    // Mapping to track nonces for each address
    mapping(address => uint256) public nonces;

    event TokensPurchased(
        address indexed buyer,
        uint256 amount,
        address paymentToken
    );
    event PresaleTimesUpdated(uint256 newStartTime, uint256 newEndTime);
    event FundsWithdrawn(
        address indexed recipient,
        uint256 amount,
        address token
    );
    event PresaleStatusUpdated(bool isActive);
    event TokenPriceUpdated(address token, uint256 price);
    event PurchaseLimitsUpdated(uint256 newMinPurchase, uint256 newMaxPurchase);

    constructor(
        address _crotchToken,
        address _usdc,
        address _cro,
        uint256 _startTime,
        uint256 _endTime
    ) Ownable(msg.sender) {
        require(
            _startTime > block.timestamp,
            "Start time must be in the future"
        );
        require(_endTime > _startTime, "End time must be after start time");

        crotchToken = _crotchToken;
        usdc = _usdc;
        cro = _cro;
        startTime = _startTime;
        endTime = _endTime;
        isPresaleActive = true;
        // Set up EIP-712 domain separator
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256("Crotch"),
                keccak256("1"),
                block.chainid,
                address(this)
            )
        );
    }

    function validateSignature(
        address paymentToken,
        uint256 amount,
        uint256 nonce,
        uint256 _price,
        bytes memory signature
    ) internal view returns (address) {
        // Verify the signature using EIP-712
        bytes32 structHash = keccak256(
            abi.encode(
                TOKEN_PURCHASE_TYPEHASH,
                msg.sender,
                paymentToken,
                amount,
                nonce,
                _price
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash)
        );
        address signer = digest.recover(signature);

        return signer;
    }

    function tooglePresale() external onlyOwner {
        isPresaleActive = !isPresaleActive;
        emit PresaleStatusUpdated(isPresaleActive);
    }

    function setSignatureAddress(address _signatureAddress) external onlyOwner {
        signatureAddress = _signatureAddress;
    }

    function tokenPurchase(
        address paymentToken,
        uint256 amount,
        uint256 nonce,
        uint256 price,
        bytes memory signature
    ) external payable {
        require(isPresaleActive, "Presale is not active");
        require(block.timestamp >= startTime, "Presale has not started");
        require(block.timestamp <= endTime, "Presale has ended");
        require(amount > 0, "Amount must be greater than 0");
        address signer = validateSignature(
            paymentToken,
            amount,
            nonce,
            price,
            signature
        );
        // Ensure the signer is the owner and nonce is correct
        uint256 userNonce = nonces[msg.sender] + 1;
        require(
            signer == signatureAddress && nonce == userNonce,
            "Invalid signature"
        );
        nonces[msg.sender]++;
        uint256 tax = (amount * 4) / 100; // Calculate 4% tax
        uint256 netAmount = amount - tax; // Remaining 96% after tax
        uint256 contractTax = (amount * 1) / 100; // 1% for the presale contract
        uint256 ownerTax = (amount * 3) / 100; // 3% for the owner

        uint256 tokensToBuy = amountToToken(netAmount, price, paymentToken);
        require(tokensToBuy > 0, "Insufficient payment for tokens");

        require(
            tokensSold + tokensToBuy <= totalTokensForPresale,
            "Exceeds total tokens for presale"
        );

        contributions[msg.sender] += tokensToBuy;
        tokensSold += tokensToBuy;
        bool success;
        if (paymentToken == usdc) {
            success = IERC20(usdc).transferFrom(
                msg.sender,
                address(this),
                netAmount + tax
            );
            require(success, "Transfer failed");
            bool successful = IERC20(usdc).transfer(ownerTaxAddress, ownerTax); // Transfer 3% tax to the specific address
            require(successful, "Transfer failed");
            totalUSDCContractTax += contractTax; // Store 1% tax for USDC
        } else if (paymentToken == cro) {
            success = IERC20(cro).transferFrom(
                msg.sender,
                address(this),
                netAmount + tax
            );
            require(success, "Transfer failed");
            bool successful = IERC20(cro).transfer(ownerTaxAddress, ownerTax); // Transfer 3% tax to the specific address
            require(successful, "Transfer failed");
            totalCROContractTax += contractTax; // Store 1% tax for CRO
        } else if (paymentToken == address(0)) {
            // ETH payment
            require(msg.value == amount, "ETH value must be equal to amount");
            totalETHContractTax += (msg.value * 1) / 100; // Add 1% tax for ETH
            payable(ownerTaxAddress).transfer((msg.value * 3) / 100); // Send 3% tax to the specific address
        } else {
            revert("Unsupported payment token");
        }

        // Enforce minimum and maximum purchase limits
        require(
            contributions[msg.sender] + tokensToBuy >= minPurchase,
            "Purchase amount below minimum limit"
        );
        require(
            contributions[msg.sender] + tokensToBuy <= maxPurchase,
            "Cumulative purchase exceeds maximum limit"
        );

        success = IERC20(crotchToken).transfer(msg.sender, tokensToBuy);
        require(success, "Transfer failed");

        emit TokensPurchased(msg.sender, tokensToBuy, paymentToken);
    }

    function setTokenPrice(uint256 price) external onlyOwner {
        require(price > 0, "Price must be greater than 0");

        usdcPrice = price;

        emit TokenPriceUpdated(usdc, price);
    }

    // Withdraw funds collected from presale
    function withdrawFunds(address tokenAddress) external onlyOwner {
        uint256 balance;
        if (tokenAddress == address(0)) {
            // Withdraw ETH
            balance = address(this).balance;
            require(balance > 0, "No ETH to withdraw");
            payable(owner()).transfer(balance);
        } else {
            // Withdraw ERC20 tokens (USDC or CRON)
            balance = IERC20(tokenAddress).balanceOf(address(this));
            require(balance > 0, "No tokens to withdraw");
            bool success = IERC20(tokenAddress).transfer(owner(), balance);
            require(success, "Transfer failed");
        }

        emit FundsWithdrawn(owner(), balance, tokenAddress);
    }

    // Withdraw unsold CROTCH tokens
    function withdrawUnsoldTokens() external onlyOwner {
        // Withdraw Crotch tokens
        uint256 unsoldCrotchTokens = IERC20(crotchToken).balanceOf(
            address(this)
        );
        if (unsoldCrotchTokens > 0) {
            bool success = IERC20(crotchToken).transfer(
                owner(),
                unsoldCrotchTokens
            );
            require(success, "Transfer failed");
        }

        // Withdraw CRO tokens
        uint256 unsoldCROTokens = IERC20(cro).balanceOf(address(this));
        if (unsoldCROTokens > 0) {
            bool success = IERC20(cro).transfer(owner(), unsoldCROTokens);
            require(success, "Transfer failed");
        }

        // Withdraw USDC tokens
        uint256 unsoldUSDCTokens = IERC20(usdc).balanceOf(address(this));
        if (unsoldUSDCTokens > 0) {
            bool success = IERC20(usdc).transfer(owner(), unsoldUSDCTokens);
            require(success, "Transfer failed");
        }

        // Withdraw ETH
        uint256 contractETHBalance = address(this).balance;
        if (contractETHBalance > 0) {
            payable(owner()).transfer(contractETHBalance);
        }
    }

    // Getter function: Calculate payment needed for a specific number of tokens
    function tokenToAmount(
        uint256 tokenAmount,
        uint256 _price,
        address paymentToken
    ) external view returns (uint256) {
        require(tokenAmount > 0, "Token amount must be greater than 0");
        require(_price > 0, "Payment price must be greater than 0");

        if (paymentToken == usdc) {
            require(usdcPrice > 0, "USDC price is not set");
            return (tokenAmount * 10 ** 6) / usdcPrice; // Payment in USDC (6 decimals)
        } else if (paymentToken == cro) {
            return (tokenAmount * 10 ** 8) / _price; // Payment in CRO (8 decimals)
        } else if (paymentToken == address(0)) {
            return (tokenAmount * 10 ** 18) / _price; // Payment in ETH (18 decimals)
        } else {
            revert("Unsupported payment token");
        }
    }

    // Getter function: Calculate tokens received for a specific payment amount
    function amountToToken(
        uint256 paymentAmount,
        uint256 _price,
        address paymentToken
    ) public view returns (uint256) {
        require(paymentAmount > 0, "Payment amount must be greater than 0");
        require(_price > 0, "Payment price must be greater than 0");

        if (paymentToken == usdc) {
            require(usdcPrice > 0, "USDC price is not set");
            return (paymentAmount * usdcPrice) / 10 ** 6; // Tokens for payment in USDC
        } else if (paymentToken == cro) {
            return (paymentAmount * _price) / 10 ** 8; // Tokens for payment in CRO
        } else if (paymentToken == address(0)) {
            return (paymentAmount * _price) / 10 ** 18; // Tokens for payment in ETH
        } else {
            revert("Unsupported payment token");
        }
    }

    function updateOwnerTaxAddress(address newAddress) external onlyOwner {
        require(
            newAddress != address(0),
            "New address cannot be the zero address"
        );
        ownerTaxAddress = newAddress;
    }

    function updatePresaleTimes(
        uint256 newStartTime,
        uint256 newEndTime
    ) external onlyOwner {
        require(
            newStartTime > block.timestamp,
            "Start time must be in the future"
        );
        require(
            newEndTime > newStartTime,
            "End time must be after the new start time"
        );

        startTime = newStartTime;
        endTime = newEndTime;

        emit PresaleTimesUpdated(newStartTime, newEndTime);
    }

    function updatePurchaseLimits(
        uint256 newMinPurchase,
        uint256 newMaxPurchase
    ) external onlyOwner {
        require(newMinPurchase > 0, "Minimum purchase must be greater than 0");
        require(
            newMaxPurchase >= newMinPurchase,
            "Maximum purchase must be greater than or equal to minimum purchase"
        );

        minPurchase = newMinPurchase;
        maxPurchase = newMaxPurchase;

        emit PurchaseLimitsUpdated(newMinPurchase, newMaxPurchase);
    }

    // Fallback to receive ETH
    receive() external payable {}
}