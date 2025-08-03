// File: github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.2/contracts/token/ERC20/IERC20.sol



pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}

// File: github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.2/contracts/utils/Context.sol



pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.2/contracts/access/Ownable.sol



pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/burn_wrapper.sol



pragma solidity 0.7.6;



// Interface for Circle's CCTP Token Messenger
interface ITokenMessenger {
    function depositForBurn(
        uint256 amount,
        uint32 destinationDomain,
        bytes32 mintRecipient,
        address burnToken
    ) external returns (uint64 _nonce);

    function depositForBurnWithCaller(
        uint256 amount,
        uint32 destinationDomain,
        bytes32 mintRecipient,
        address burnToken,
        bytes32 destinationCaller
    ) external returns (uint64 nonce);

    function replaceDepositForBurn(
        bytes calldata originalMessage,
        bytes calldata originalAttestation,
        bytes32 newDestinationCaller,
        bytes32 newMintRecipient
    ) external;
}

// Interface for tokens that support mint and burn functions (like USDC)
interface IMintBurnToken is IERC20 {
    function mint(address to, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
    function burn(uint256 amount) external;
    function approve(address spender, uint256 value) external override returns (bool);
    function transfer(address to, uint256 value) external override returns (bool);
    function transferFrom(address from, address to, uint256 value) external override returns (bool);
}

// Interface for calculating fees related to swaps and gas usage
interface IFeeCalculatorContract {
    function calculateFee(uint256 amount, uint256 gasLimit) external view returns (uint256);
    function convertNativeToUSD(uint256 nativeAmount) external view returns (uint256);
}

// CCTP Contract Wrapper for handling cross-chain USDC transfers, fee calculations, and token burns
contract CCTPContractWrapper is Ownable {
    address private _feeCalculatorAddress;
    address private _feeDestinationAddress;
    address private _burnContractAddress;

    // Constructor to initialize fee calculator, fee destination, and burn contract addresses
    // @param feeCalculatorAddress: The address of fee calculator contract
    // @param feeDestinationAddress: The address of fee destination
    // @param burnContractAddress: The address of burn contract
    constructor(
        address feeCalculatorAddress,
        address feeDestinationAddress,
        address burnContractAddress
    ) Ownable() {
        _feeCalculatorAddress = feeCalculatorAddress;
        _feeDestinationAddress = feeDestinationAddress;
        _burnContractAddress = burnContractAddress;
    }

    // Transfer a specific amount of tokens to a destination address
    // @param amount: The amount to send domain
    // @param recipient: The recepient address
    // @param tokenContractAddress: The token contract address
    function transferToken(
        uint256 amount,
        address recipient,
        address tokenContractAddress
    ) external onlyOwner {
        IMintBurnToken tokenContract = IMintBurnToken(tokenContractAddress);
        require(tokenContract.transfer(recipient, amount), "Token transfer failed");
    }

    // Send native value (ETH) to a recipient
    // @param recipient: The recepient address
    // @param amount: The amount to send domain
    function sendValue(address payable recipient, uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Failed to send value");
    }

    // Initiate the CCTP process: Transfer tokens from the user, subtract the fee, and burn tokens using Circle's CCTP
    // @param swapAmount: The amount being swapped
    // @param destinationDomain: The destination domain
    // @param mintRecipient: The destination address
    // @param senderAddress: The address shich should receive token as CCTP swap result
    // @param burnTokenAddress: The token contract address
    // @return _nonce unique nonce reserved by message
    function callDepositForBurn(
        uint256 swapAmount,
        uint32 destinationDomain,
        bytes32 mintRecipient,
        address senderAddress,
        address burnTokenAddress
    ) external onlyOwner returns (uint64 _nonce) {
        uint256 gasLimit = gasleft();

        // Retrieve contracts for fee calculation and burn functionality
        IFeeCalculatorContract feeCalculator = IFeeCalculatorContract(_feeCalculatorAddress);
        IMintBurnToken burnToken = IMintBurnToken(burnTokenAddress);
        
        // Calculate fee based on gas and transfer amount
        uint256 feeAmount = feeCalculator.calculateFee(swapAmount, gasLimit * tx.gasprice);
        require(feeAmount < swapAmount, "Fee exceeds transfer amount");

        // Transfer tokens from sender to this contract
        require(burnToken.transferFrom(senderAddress, getContractAddress(), swapAmount), "Token transfer failed");

        // Transfer fee to fee destination
        require(burnToken.transfer(getFeeDestinationAddress(), feeAmount), "Fee transfer failed");

        // Approve burn contract for remaining tokens
        require(burnToken.approve(_burnContractAddress, swapAmount - feeAmount), "Approval failed");

        // Initiate burn process via Circle CCTP's depositForBurn method
        ITokenMessenger burnContract = ITokenMessenger(_burnContractAddress);
        return burnContract.depositForBurn(
            swapAmount - feeAmount,
            destinationDomain,
            mintRecipient,
            burnTokenAddress
        );
    }

    // Update the fee calculator contract address (only callable by the owner)
    // @param newContract: The new address of fee calculator contract
    function updateFeeCalculatorAddress(address newContract) public onlyOwner virtual {
        _feeCalculatorAddress = newContract;
    }

    // Get the current fee calculator contract address
    // @return address of fee calculator contract
    function getFeeCalculatorAddress() public view returns (address) {
        return _feeCalculatorAddress;
    }

    // Update the fee destination address (only callable by the owner)
    // @param newAddress: The new address of fee destination
    function updateFeeDestinationAddress(address newAddress) public onlyOwner virtual {
        _feeDestinationAddress = newAddress;
    }

    // Get the current fee destination address
    // @return address of fee destination
    function getFeeDestinationAddress() public view returns (address) {
        return _feeDestinationAddress;
    }

    // Update the burn contract address (only callable by the owner)
    // @param newAddress: The new address of burn contract
    function updateBurnContractAddress(address newAddress) public onlyOwner virtual {
        _burnContractAddress = newAddress;
    }

    // Get the current burn contract address
    // @return address of burn contract
    function getBurnContractAddress() public view returns (address) {
        return _burnContractAddress;
    }

    // Get the current contract address
    // @return address of current contract
    function getContractAddress() public view returns (address) {
        return address(this); // Returns the address of the current contract
    }
}