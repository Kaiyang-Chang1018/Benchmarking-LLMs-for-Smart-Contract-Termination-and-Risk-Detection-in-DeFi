// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../lib/Signing.sol";
import {IWETH} from "../IWETH.sol";
import "./interfaces/IWasabiBNPL.sol";
import "./interfaces/IWasabiOption.sol";
import "./interfaces/IFlashloan.sol";
import "./interfaces/ILendingAddressProvider.sol";
import "./interfaces/INFTLending.sol";

contract WasabiBNPL is IWasabiBNPL, Ownable, IERC721Receiver, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Address for address;

    /// @notice Wasabi Option
    IWasabiOption public wasabiOption;

    /// @notice Wasabi Flashloan
    IFlashloan public flashloan;

    /// @notice Wasabi Address Provider
    ILendingAddressProvider public addressProvider;

    /// @notice Wasabi Pool Factory
    address public factory;

    /// @notice Option ID to LoanInfo mapping
    mapping(uint256 => LoanInfo) public optionToLoan;

    /// @notice
    address public wethAddress;

    /// @notice WasabiBNPL Constructor
    /// @param _wasabiOption Wasabi Option address
    /// @param _flashloan Wasabi Flashloan address
    /// @param _addressProvider Wasabi Address Provider address
    /// @param _wethAddress Wrapped ETH address
    /// @param _factory Wasabi Pool Factory address
    constructor(
        IWasabiOption _wasabiOption,
        IFlashloan _flashloan,
        ILendingAddressProvider _addressProvider,
        address _wethAddress,
        address _factory
    ) {
        wasabiOption = _wasabiOption;
        flashloan = _flashloan;
        addressProvider = _addressProvider;
        wethAddress = _wethAddress;
        factory = _factory;
    }

    /// @dev Returns the option data for the given option id
    function getOptionData(
        uint256 _optionId
    ) external view returns (WasabiStructs.OptionData memory optionData) {
        LoanInfo memory loanInfo = optionToLoan[_optionId];
        INFTLending.LoanDetails memory loanDetails = INFTLending(
            loanInfo.nftLending
        ).getLoanDetails(loanInfo.loanId);
        bool active = wasabiOption.ownerOf(_optionId) != address(0) &&
            loanDetails.loanExpiration > block.timestamp;

        optionData = WasabiStructs.OptionData(
            active,
            WasabiStructs.OptionType.CALL,
            loanDetails.repayAmount,
            loanDetails.loanExpiration,
            loanDetails.tokenId
        );
    }

    /// @notice Executes BNPL flow
    /// @dev BNLP flow
    ///      1. take flashloan
    ///      2. buy nft from marketplace
    ///      3. get loan from nft lending protocol
    /// @param _nftLending NFTLending contract address
    /// @param _borrowData Borrow data
    /// @param _flashLoanAmount Call value
    /// @param _marketplaceCallData List of marketplace calldata
    /// @param _signatures Signatures
    function bnpl(
        address _nftLending,
        bytes calldata _borrowData,
        uint256 _flashLoanAmount,
        FunctionCallData[] calldata _marketplaceCallData,
        bytes[] calldata _signatures
    ) external payable nonReentrant returns (uint256) {
        validate(_marketplaceCallData, _signatures);

        if (!addressProvider.isLending(_nftLending)) {
            revert InvalidParam();
        }

        // 1. Get flash loan
        uint256 flashLoanRepayAmount = flashloan.borrow(_flashLoanAmount);

        // 2. Buy NFT
        bool marketSuccess = executeFunctions(_marketplaceCallData);
        if (!marketSuccess) {
            revert FunctionCallFailed();
        }

        // 3. Get loan
        bytes memory result = _nftLending.functionDelegateCall(
            abi.encodeWithSelector(INFTLending.borrow.selector, _borrowData)
        );
        uint256 loanId = abi.decode(result, (uint256));

        uint256 optionId = wasabiOption.mint(_msgSender(), factory);
        optionToLoan[optionId] = LoanInfo({
            nftLending: _nftLending,
            loanId: loanId
        });

        // 4. Repay flashloan
        if (address(this).balance < flashLoanRepayAmount) {
            revert LoanNotPaid();
        }
        uint256 payout = address(this).balance - flashLoanRepayAmount;

        (bool sent, ) = payable(address(flashloan)).call{
            value: flashLoanRepayAmount
        }("");
        if (!sent) {
            revert EthTransferFailed();
        }
        if (payout > 0) {
            (sent, ) = payable(_msgSender()).call{value: payout}("");
            if (!sent) {
                revert EthTransferFailed();
            }
        }

        return optionId;
    }

    /// @notice Executes a given list of functions
    /// @param _marketplaceCallData List of marketplace calldata
    function executeFunctions(
        FunctionCallData[] memory _marketplaceCallData
    ) internal returns (bool) {
        uint256 length = _marketplaceCallData.length;
        for (uint256 i; i != length; ++i) {
            FunctionCallData memory functionCallData = _marketplaceCallData[i];
            (bool success, ) = functionCallData.to.call{
                value: functionCallData.value
            }(functionCallData.data);
            if (success == false) {
                return false;
            }
        }
        return true;
    }

    /// @notice Validates if the FunctionCallData list has been approved
    /// @param _marketplaceCallData List of marketplace calldata
    /// @param _signatures Signatures
    function validate(
        FunctionCallData[] calldata _marketplaceCallData,
        bytes[] calldata _signatures
    ) internal view {
        uint256 calldataLength = _marketplaceCallData.length;
        require(calldataLength > 0, "Need marketplace calls");
        require(calldataLength == _signatures.length, "Length is invalid");
        for (uint256 i; i != calldataLength; ++i) {
            bytes32 ethSignedMessageHash = Signing.getEthSignedMessageHash(
                getMessageHash(_marketplaceCallData[i])
            );
            require(
                Signing.recoverSigner(ethSignedMessageHash, _signatures[i]) ==
                    owner(),
                "Owner is not signer"
            );
        }
    }

    /// @notice Returns the message hash for the given _data
    function getMessageHash(
        FunctionCallData calldata _data
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(_data.to, _data.value, _data.data));
    }

    /// @dev Withdraws any stuck ETH in this contract
    function withdrawETH(uint256 _amount) external payable onlyOwner {
        if (_amount > address(this).balance) {
            _amount = address(this).balance;
        }
        (bool sent, ) = payable(owner()).call{value: _amount}("");
        if (!sent) {
            revert EthTransferFailed();
        }
    }

    /// @dev Withdraws any stuck ERC20 in this contract
    function withdrawERC20(IERC20 _token, uint256 _amount) external onlyOwner {
        _token.safeTransfer(_msgSender(), _amount);
    }

    /// @dev Withdraws any stuck ERC721 in this contract
    function withdrawERC721(
        IERC721 _token,
        uint256 _tokenId
    ) external onlyOwner {
        _token.safeTransferFrom(address(this), owner(), _tokenId);
    }

    function onERC721Received(
        address /* operator */,
        address /* from */,
        uint256 /* tokenId */,
        bytes memory /* data */
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    receive() external payable {}

    /**
     * @dev Executes the given option id
     * @param _optionId The option id
     */
    function executeOption(uint256 _optionId) external payable nonReentrant {
        require(
            wasabiOption.ownerOf(_optionId) == _msgSender(),
            "Only owner can exercise option"
        );

        LoanInfo storage loanInfo = optionToLoan[_optionId];
        require(loanInfo.nftLending != address(0), "Invalid Option");

        INFTLending.LoanDetails memory loanDetails = INFTLending(
            loanInfo.nftLending
        ).getLoanDetails(loanInfo.loanId);
        require(
            loanDetails.loanExpiration > block.timestamp,
            "Loan has expired"
        );
        require(
            msg.value >= loanDetails.repayAmount,
            "Insufficient repay amount supplied"
        );

        loanInfo.nftLending.functionDelegateCall(
            abi.encodeWithSelector(
                INFTLending.repay.selector,
                loanInfo.loanId,
                _msgSender()
            )
        );

        wasabiOption.burn(_optionId);
        emit OptionExecuted(_optionId);
    }

    /**
     * @dev Executes the given option id and sells the NFT to the market
     * @param _optionId The option id
     * @param _marketplaceCallData List of marketplace calldata
     * @param _signatures List of signatures of the marketplace call data
     */
    function executeOptionWithArbitrage(
        uint256 _optionId,
        FunctionCallData[] calldata _marketplaceCallData,
        bytes[] calldata _signatures
    ) external payable nonReentrant {
        validate(_marketplaceCallData, _signatures);
        require(
            wasabiOption.ownerOf(_optionId) == _msgSender(),
            "Only owner can exercise option"
        );

        LoanInfo storage loanInfo = optionToLoan[_optionId];
        require(loanInfo.nftLending != address(0), "Invalid Option");

        INFTLending.LoanDetails memory loanDetails = INFTLending(
            loanInfo.nftLending
        ).getLoanDetails(loanInfo.loanId);
        require(
            loanDetails.loanExpiration > block.timestamp,
            "Loan has expired"
        );

        uint256 initialBalance = address(this).balance;

        // 1. Get flash loan
        uint256 flashLoanRepayAmount = flashloan.borrow(
            loanDetails.repayAmount
        );

        // 2. Repay loan
        loanInfo.nftLending.functionDelegateCall(
            abi.encodeWithSelector(
                INFTLending.repay.selector,
                loanInfo.loanId,
                address(this)
            )
        );
        wasabiOption.burn(_optionId);

        // 3. Sell NFT
        bool marketSuccess = executeFunctions(_marketplaceCallData);
        if (!marketSuccess) {
            revert FunctionCallFailed();
        }

        // Withdraw any WETH received
        IWETH weth = IWETH(wethAddress);
        uint256 wethBalance = weth.balanceOf(address(this));
        if (wethBalance > 0) {
            weth.withdraw(wethBalance);
        }

        uint256 balanceChange = address(this).balance - initialBalance;

        // 4. Repay flashloan
        if (balanceChange < flashLoanRepayAmount) {
            revert LoanNotPaid();
        }
        (bool sent, ) = payable(address(flashloan)).call{
            value: flashLoanRepayAmount
        }("");
        if (!sent) {
            revert EthTransferFailed();
        }

        // 5. Give payout
        uint256 payout = balanceChange - flashLoanRepayAmount;
        if (payout > 0) {
            (sent, ) = payable(_msgSender()).call{value: payout}("");
            if (!sent) {
                revert EthTransferFailed();
            }
        }

        emit OptionExecutedWithArbitrage(_optionId, payout);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @title Flashloan Interface
interface IFlashloan {
    /// @notice Flashloan Info Struct
    /// @param enabled Enabled flag
    /// @param flashloanPremiumValue;
    struct FlashLoanInfo {
        bool enabled;
        uint256 flashloanPremiumValue;
    }

    /// @notice ETH Transfer Failed
    error EthTransferFailed();

    /// @notice Borrow ETH
    /// @param amount Flashloan amount
    /// @return flashLoanRepayAmount Flashloan repayment amount
    function borrow(uint256 amount) external returns (uint256 flashLoanRepayAmount);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface ILendingAddressProvider {
    event LendingAdded(address indexed lending);

    event LendingRemoved(address indexed lending);

    function isLending(address) external view returns (bool);

    function addLending(address _lending) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @notice NFTLending Interface
interface INFTLending {
    /// @notice Loan Details struct
    /// @param borrowAmount Borrow amount
    /// @param repayAmount Repay amount
    /// @param loanExpiration Loan expiration
    struct LoanDetails {
        uint256 borrowAmount;
        uint256 repayAmount;
        uint256 loanExpiration;
        address nftAddress;
        uint256 tokenId;
    }

    /// @notice Get loan details for given loan id
    /// @param _loanId The loan id
    function getLoanDetails(
        uint256 _loanId
    ) external view returns (LoanDetails memory);

    /// @notice Borrow WETH from the protocol
    /// @param _inputData Encoded input parameters
    /// @return _loanId The loan id
    function borrow(
        bytes calldata _inputData
    ) external payable returns (uint256 _loanId);

    /// @notice Repay the loan
    /// @param _loanId The loan id to repay
    /// @param _receiver The user address to receive collateral NFT
    function repay(uint256 _loanId, address _receiver) external payable;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @title WasabiBNPL Interface
interface IWasabiBNPL {
    /// @notice Function Calldata Struct
    /// @param to to address
    /// @param value call value
    /// @param data call data
    struct FunctionCallData {
        address to;
        uint256 value;
        bytes data;
    }

    /// @notice Loan Info Struct
    /// @param nftLending INFTLending address
    /// @param loanId loan id
    struct LoanInfo {
        address nftLending;
        uint256 loanId;
    }

    /// @notice Function Call Failed
    error FunctionCallFailed();

    /// @notice Loan Not Paid
    error LoanNotPaid();

    /// @notice ETH Transfer Failed
    error EthTransferFailed();

    /// @notice Invalid Param
    error InvalidParam();

    /// @dev Emitted when an option is executed
    event OptionExecuted(uint256 optionId);

    /// @dev Emitted when an option is executed and the NFT is sold to the market
    event OptionExecutedWithArbitrage(uint256 optionId, uint256 payout);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IWasabiOption {
    function mint(address, address) external returns (uint256);

    function burn(uint256) external;

    function ownerOf(uint256 tokenId) external view returns (address owner);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {WasabiStructs} from "./WasabiStructs.sol";

/**
 * @dev Signature Verification
 */
library Signing {

    /**
     * @dev Returns the message hash for the given request
     */
    function getMessageHash(WasabiStructs.PoolAsk calldata _request) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                _request.id,
                _request.poolAddress,
                _request.optionType,
                _request.strikePrice,
                _request.premium,
                _request.expiry,
                _request.tokenId,
                _request.orderExpiry));
    }

    /**
     * @dev Returns the message hash for the given request
     */
    function getAskHash(WasabiStructs.Ask calldata _ask) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                _ask.id,
                _ask.price,
                _ask.tokenAddress,
                _ask.orderExpiry,
                _ask.seller,
                _ask.optionId));
    }

    function getBidHash(WasabiStructs.Bid calldata _bid) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                _bid.id,
                _bid.price,
                _bid.tokenAddress,
                _bid.collection,
                _bid.orderExpiry,
                _bid.buyer,
                _bid.optionType,
                _bid.strikePrice,
                _bid.expiry,
                _bid.expiryAllowance));
    }

    /**
     * @dev creates an ETH signed message hash
     */
    function getEthSignedMessageHash(bytes32 _messageHash) internal pure returns (bytes32) {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    function getSigner(
        WasabiStructs.PoolAsk calldata _request,
        bytes memory signature
    ) internal pure returns (address) {
        bytes32 messageHash = getMessageHash(_request);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature);
    }

    function getAskSigner(
        WasabiStructs.Ask calldata _ask,
        bytes memory signature
    ) internal pure returns (address) {
        bytes32 messageHash = getAskHash(_ask);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature);
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        internal
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        internal
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

library WasabiStructs {
    enum OptionType {
        CALL,
        PUT
    }

    struct OptionData {
        bool active;
        OptionType optionType;
        uint256 strikePrice;
        uint256 expiry;
        uint256 tokenId; // Locked token for CALL options
    }

    struct PoolAsk {
        uint256 id;
        address poolAddress;
        OptionType optionType;
        uint256 strikePrice;
        uint256 premium;
        uint256 expiry;
        uint256 tokenId; // Token to lock for CALL options
        uint256 orderExpiry;
    }

    struct PoolBid {
        uint256 id;
        uint256 price;
        address tokenAddress;
        uint256 orderExpiry;
        uint256 optionId;
    }

    struct Bid {
        uint256 id;
        uint256 price;
        address tokenAddress;
        address collection;
        uint256 orderExpiry;
        address buyer;
        OptionType optionType;
        uint256 strikePrice;
        uint256 expiry;
        uint256 expiryAllowance;
        address optionTokenAddress;
    }

    struct Ask {
        uint256 id;
        uint256 price;
        address tokenAddress;
        uint256 orderExpiry;
        address seller;
        uint256 optionId;
    }

    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
// SPDX-License-Identifier: MIT
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

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

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
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
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

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
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
// SPDX-License-Identifier: MIT
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

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