/**
 * ██████  ███████ ██    ██  ██████  ██      ██    ██ ███████ ██  ██████  ███    ██
 * ██   ██ ██      ██    ██ ██    ██ ██      ██    ██     ██  ██ ██    ██ ████   ██
 * ██████  █████   ██    ██ ██    ██ ██      ██    ██   ██    ██ ██    ██ ██ ██  ██
 * ██   ██ ██       ██  ██  ██    ██ ██      ██    ██  ██     ██ ██    ██ ██  ██ ██
 * ██   ██ ███████   ████    ██████  ███████  ██████  ███████ ██  ██████  ██   ████
 * 
 * @title Platty Ai
 * 
 * @notice This is a smart contract developed by Revoluzion for Platty Ai.
 * 
 * @dev This smart contract was developed based on the general
 * OpenZeppelin Contracts guidelines where functions revert instead of
 * returning `false` on failure. 
 * 
 * @author Revoluzion Ecosystem
 * @custom:email support@revoluzion.io
 * @custom:telegram https://t.me/RevoluzionEcosystem
 * @custom:website https://revoluzion.io
 * @custom:dapp https://revoluzion.app
 */


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/********************************************************************************************
  INTERFACE
********************************************************************************************/

/**
 * @title Router Interface
 * 
 * @notice Interface of the Router contract, providing functions to interact with
 * Router contract that is derived from Uniswap V2 Router.
 * 
 * @dev See https://docs.uniswap.org/contracts/v2/reference/smart-contracts/router-02
 */
interface IRouter {

    // FUNCTION

    /**
     * @notice Get the address of the Wrapped Ether (WETH) token.
     * 
     * @return The address of the WETH token.
     */
    function WETH() external pure returns (address);
            
    /**
     * @notice Get the address of the linked Factory contract.
     * 
     * @return The address of the Factory contract.
     */
    function factory() external pure returns (address);

    /**
     * @notice Swaps an exact amount of tokens for ETH, supporting
     * tokens that implement fee-on-transfer mechanisms.
     * 
     * @param amountIn The exact amount of input tokens for the swap.
     * @param amountOutMin The minimum acceptable amount of ETH to receive in the swap.
     * @param path An array of token addresses representing the token swap path.
     * @param to The recipient address that will receive the swapped ETH.
     * @param deadline The timestamp by which the transaction must be executed to be
     * considered valid.
     * 
     * @dev This function swaps a specific amount of tokens for ETH on a specified path, 
     * ensuring a minimum amount of output ETH.
     */
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;

    /**
     * @notice Swaps a precise amount of ETH for tokens, supporting tokens with fee-on-transfer mechanisms.
     * 
     * @param amountOutMin The minimum acceptable amount of output tokens expected from the swap.
     * @param path An array of token addresses representing the token swap path.
     * @param to The recipient address that will receive the swapped tokens.
     * @param deadline The timestamp by which the transaction must be executed to be considered valid.
     * 
     * @dev This function performs a direct swap of a specified amount of ETH for tokens based on the provided
     * path and minimum acceptable output token amount.
     */
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external payable;

    /**
     * @notice Add liquidity to the pool with ether.
     * 
     * @param token The address of the ERC20 token.
     * @param amountTokenDesired The desired amount of token to add to the pool.
     * @param amountTokenMin The minimum amount of token acceptable to add to the pool.
     * @param amountETHMin The minimum amount of ETH acceptable to add to the pool.
     * @param to The address where the liquidity tokens will be sent.
     * @param deadline The deadline by which the liquidity must be added.
     * 
     * @return amountToken The actual amount of token added to the pool
     * @return amountETH The actual amount of ETH added to the pool
     * @return liquidity The total amount of liquidity tokens minted
     * 
     * @dev Add liquidity to the pool with ether by providing an ERC20 token and ether in
     * exchange for liquidity tokens.
     */
    function addLiquidityETH(address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

/**
 * @title Factory Interface
 * 
 * @notice Interface of the Factory contract, providing functions to interact with
 * Factory contract that is derived from Uniswap V2 Factory.
 * 
 * @dev See https://docs.uniswap.org/contracts/v2/reference/smart-contracts/factory
 */
interface IFactory {

    // FUNCTION

    /**
     * @notice Create a new token pair for two given tokens on Uniswap V2-based factory.
     * 
     * @param tokenA The address of the first token.
     * @param tokenB The address of the second token.
     * 
     * @return pair The address of the created pair for the given tokens.
     */
    function createPair(address tokenA, address tokenB) external returns (address pair);

    /**
     * @notice Get the address of the pair for two tokens on the decentralized exchange.
     * 
     * @param tokenA The address of the first token.
     * @param tokenB The address of the second token.
     * 
     * @return pair The address of the pair corresponding to the provided tokens.
     */
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

/**
 * @title Pair Interface
 * 
 * @notice Interface of the Pair contract in a decentralized exchange based on the
 * Pair contract that is derived from Uniswap V2 Pair.
 * 
 * @dev See https://docs.uniswap.org/contracts/v2/reference/smart-contracts/pair
 */
interface IPair {

    // FUNCTION

    /**
     * @notice Get the address of the first token in the pair.
     * 
     * @return The address of the first token.
     */
    function token0() external view returns (address);

    /**
     * @notice Get the address of the second token in the pair.
     * 
     * @return The address of the second token.
     */
    function token1() external view returns (address);
}

/**
 * @title ERC20 Token Standard Interface
 * 
 * @notice Interface of the ERC-20 standard token as defined in the ERC.
 * 
 * @dev See https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20 {
    
    // EVENT
    
    /**
     * @notice Emitted when `value` tokens are transferred from
     * one account (`from`) to another (`to`).
     * 
     * @param from The address tokens are transferred from.
     * @param to The address tokens are transferred to.
     * @param value The amount of tokens transferred.
     * 
     * @dev The `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @notice Emitted when the allowance of a `spender` for an `owner`
     * is set by a call to {approve}.
     * 
     * @param owner The address allowing `spender` to spend on their behalf.
     * @param spender The address allowed to spend tokens on behalf of `owner`.
     * @param value The allowance amount set for `spender`.
     * 
     * @dev The `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // FUNCTION

    /**
     * @notice Returns the value of tokens in existence.
     * 
     * @return The value of the total supply of tokens.
     * 
     * @dev This should get the total token supply.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @notice Returns the value of tokens owned by `account`.
     * 
     * @param account The address to query the balance for.
     * 
     * @return The token balance of `account`.
     * 
     * @dev This should get the token balance of a specific account.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @notice Moves a `value` amount of tokens from the caller's account to `to`.
     * 
     * @param to The address to transfer tokens to.
     * @param value The amount of tokens to be transferred.
     * 
     * @return A boolean indicating whether the transfer was successful or not.
     * 
     * @dev This should transfer tokens to a specified address and emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @notice Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}.
     * 
     * @param owner The address allowing `spender` to spend on their behalf.
     * @param spender The address allowed to spend tokens on behalf of `owner`.
     * 
     * @return The allowance amount for `spender`.
     * 
     * @dev The return value should be zero by default and
     * changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @notice Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     * 
     * @param spender The address allowed to spend tokens on behalf of the sender.
     * @param value The allowance amount for `spender`.
     * 
     * @return A boolean indicating whether the approval was successful or not.
     * 
     * @dev This should approve `spender` to spend a specified amount of tokens
     * on behalf of the sender and emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @notice Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's allowance.
     * 
     * @param from The address to transfer tokens from.
     * @param to The address to transfer tokens to.
     * @param value The amount of tokens to be transferred.
     * 
     * @return A boolean indicating whether the transfer was successful or not.
     * 
     * @dev This should transfer tokens from one address to another after
     * spending caller's allowance and emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

/**
 * @title ERC20 Token Metadata Interface
 * 
 * @notice Interface for the optional metadata functions of the ERC-20 standard as defined in the ERC.
 * 
 * @dev It extends the IERC20 interface. See https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20Metadata is IERC20 {

    // FUNCTION
    
    /**
     * @notice Returns the name of the token.
     * 
     * @return The name of the token as a string.
     */
    function name() external view returns (string memory);

    /**
     * @notice Returns the symbol of the token.
     * 
     * @return The symbol of the token as a string.
     */
    function symbol() external view returns (string memory);

    /**
     * @notice Returns the number of decimals used to display the token.
     * 
     * @return The number of decimals as a uint8.
     */
    function decimals() external view returns (uint8);
}

/**
 * @title ERC20 Token Standard Error Interface
 * 
 * @notice Interface of the ERC-6093 custom errors that defined common errors
 * related to the ERC-20 standard token functionalities.
 * 
 * @dev See https://eips.ethereum.org/EIPS/eip-6093
 */
interface IERC20Errors {
    
    // ERROR

    /**
     * @notice Error indicating that the `sender` has inssufficient `balance` for the operation.
     * 
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     *
     * @dev The `needed` value is required to inform user on the needed amount.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @notice Error indicating that the `sender` is invalid for the operation.
     * 
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);
    
    /**
     * @notice Error indicating that the `receiver` is invalid for the operation.
     * 
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);
    
    /**
     * @notice Error indicating that the `spender` does not have enough `allowance` for the operation.
     * 
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     * 
     * @dev The `needed` value is required to inform user on the needed amount.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    
    /**
     * @notice Error indicating that the `approver` is invalid for the approval operation.
     * 
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @notice Error indicating that the `spender` is invalid for the allowance operation.
     * 
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @title Common Error Interface
 * 
 * @notice Interface of the common errors not specific to ERC-20 functionalities.
 */
interface ICommonError {

    // ERROR

    /**
     * @notice Error indicating that the `current` address cannot be used in this context.
     * 
     * @param current Address used in the context.
     */
    error CannotUseCurrentAddress(address current);

    /**
     * @notice Error indicating that the `current` value cannot be used in this context.
     * 
     * @param current Value used in the context.
     */
    error CannotUseCurrentValue(uint256 current);

    /**
     * @notice Error indicating that the `current` state cannot be used in this context.
     * 
     * @param current Boolean state used in the context.
     */
    error CannotUseCurrentState(bool current);

    /**
     * @notice Error indicating that all the `current` value cannot be used in this context.
     */
    error CannotUseAllCurrentValue();

    /**
     * @notice Error indicating that all the `current` state cannot be used in this context.
     */
    error CannotUseAllCurrentState();

    /**
     * @notice Error indicating that all the `current` address cannot be used in this context.
     */
    error CannotUseAllCurrentAddress();

    /**
     * @notice Error indicating that the `invalid` address provided is not a valid address for this context.
     * 
     * @param invalid Address used in the context.
     */
    error InvalidAddress(address invalid);

    /**
     * @notice Error indicating that the `invalid` value provided is not a valid value for this context.
     * 
     * @param invalid Value used in the context.
     */
    error InvalidValue(uint256 invalid);
}

/********************************************************************************************
  ACCESS
********************************************************************************************/

/**
 * @title Ownable Contract
 * 
 * @notice Abstract contract module implementing ownership functionality through
 * inheritance as a basic access control mechanism, where there is an owner account
 * that can be granted exclusive access to specific functions.
 * 
 * @dev The initial owner is set to the address provided by the deployer and can
 * later be changed with {transferOwnership}.
 */
abstract contract Ownable {

    // DATA

    address private _owner;

    // MODIFIER

    /**
     * @notice Modifier that allows access only to the contract owner.
     *
     * @dev Should throw if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    // ERROR

    /**
     * @notice Error indicating that the `account` is not authorized to perform an operation.
     * 
     * @param account Address used to perform the operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @notice Error indicating that the provided `owner` address is invalid.
     * 
     * @param owner Address used to perform the operation.
     * 
     * @dev Should throw if called by an invalid owner account such as address(0) as an example.
     */
    error OwnableInvalidOwner(address owner);

    // CONSTRUCTOR

    /**
     * @notice Initializes the contract setting the `initialOwner` address provided by
     * the deployer as the initial owner.
     * 
     * @param initialOwner The address to set as the initial owner.
     *
     * @dev Should throw an error if called with address(0) as the `initialOwner`.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }
    
    // EVENT
    
    /**
     * @notice Emitted when ownership of the contract is transferred.
     * 
     * @param previousOwner The address of the previous owner.
     * @param newOwner The address of the new owner.
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // FUNCTION

    /**
     * @notice Get the address of the smart contract owner.
     * 
     * @return The address of the current owner.
     *
     * @dev Should return the address of the current smart contract owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }
    
    /**
     * @notice Checks if the caller is the owner and reverts if not.
     * 
     * @dev Should throw if the sender is not the current owner of the smart contract.
     */
    function _checkOwner() internal view virtual {
        if (owner() != msg.sender) {
            revert OwnableUnauthorizedAccount(msg.sender);
        }
    }
    
    /**
     * @notice Allows the current owner to renounce ownership and make the
     * smart contract ownerless.
     * 
     * @dev This function can only be called by the current owner and will
     * render all `onlyOwner` functions inoperable.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    
    /**
     * @notice Allows the current owner to transfer ownership of the smart contract
     * to `newOwner` address.
     * 
     * @param newOwner The address to transfer ownership to.
     *
     * @dev This function can only be called by the current owner and will render
     * all `onlyOwner` functions inoperable to him/her. Should throw if called with
     * address(0) as the `newOwner`.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }
    
    /**
     * @notice Internal function to transfer ownership of the smart contract
     * to `newOwner` address.
     * 
     * @param newOwner The address to transfer ownership to.
     *
     * @dev This function replace current owner address stored as _owner with 
     * the address of the `newOwner`.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/********************************************************************************************
  TOKEN
********************************************************************************************/

/**
 * @title Platty Ai Token Contract
 *
 * @notice Platty Ai is an extended version of ERC-20 standard token that
 * includes additional functionalities for ownership control, trading enabling,
 * and exemption management.
 * 
 * @dev Implements ERC20Metadata, ERC20Errors, and CommonError interfaces, and
 * extends Ownable contract.
 */
contract PlattyAi is Ownable, IERC20Metadata, IERC20Errors, ICommonError {

    // DATA

    struct Fee {
        uint256 marketing;
        uint256 liquidity;
        uint256 donations;
        uint256 team;
    }

    Fee public buyFee = Fee(2_000, 1_500, 1_000, 500);
    Fee public sellFee = Fee(2_000, 1_500, 1_000, 500);
    Fee public transferFee = Fee(2_000, 1_500, 1_000, 500);
    Fee public collectedFee = Fee(0, 0, 0, 0);
    Fee public redeemedFee = Fee(0, 0, 0, 0);

    IRouter public router = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    string private constant NAME = "Platty Ai";
    string private constant SYMBOL = "Platty";

    uint8 private constant DECIMALS = 18;

    uint256 public constant FEEDENOMINATOR = 100_000;

    uint256 private _totalSupply;

    uint256 public tradeStartTime = 0;
    uint256 public tradeStartBlock = 0;
    uint256 public totalTriggerZeusBuyback = 0;
    uint256 public lastTriggerZeusTimestamp = 0;
    uint256 public totalFeeCollected = 0;
    uint256 public totalFeeRedeemed = 0;
    uint256 public limitWallet = 2_000;
    uint256 public limitTxn = 2_000;
    uint256 public minSwap = 100_000 ether;

    address public projectOwner = 0xD4B21E9f95aE99240151603dC53105C85a6B4b58;
    address public marketingReceiver = 0xE9d1FddABd3588050CC689F3A1306f555ea028da;
    address public liquidityReceiver = 0x341dea926d55F52B1b93e38e77DFE43E2Ca1f692;
    address public donationsReceiver = 0x1D17F59977d60d9F49e17C6f0B8cA3dC35b165D5;
    address public teamReceiver = 0xb43df1066e0af7257958dd7302A8d58929262A1a;
    
    address public pair;
    
    bool public tradeEnabled = false;
    bool public isFeeActive = false;
    bool public isWalletLimitActive = false;
    bool public isTxnLimitActive = false;
    bool public isSwapEnabled = false;
    bool public inSwap = false;

    // MAPPING

    mapping(address account => uint256) private _balances;
    mapping(address account => mapping(address spender => uint256)) private _allowances;
    
    mapping(address pair => bool) public isPairLP;
    mapping(address account => bool) public isExemptFee;
    mapping(address account => bool) public isExemptWalletLimit;
    mapping(address account => bool) public isExemptTxnLimit;
    mapping(address account => bool) public isWhitelist;

    // MODIFIER
    
    /**
     * @notice Modifier to mark the start and end of a swapping operation.
     */
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    /**
     * @notice Modifier that allows access only to the contract owner and project owner.
     *
     * @dev Should throw if called by any account other than the owner.
     */
    modifier onlyOwnerAndProjectOwner() {
        if (owner() != msg.sender && projectOwner != msg.sender) {
            revert OwnableUnauthorizedAccount(msg.sender);
        }
        _;
    }

    // ERROR

    /**
     * @notice Error indicating that the native token cannot be withdrawn from the smart contract.
     */
    error CannotWithdrawNativeToken();

    /**
     * @notice Error indicating that the receiver cannot initiate transfer of Ether.
     * 
     * @dev Should throw if called by the receiver address.
     */
    error ReceiverCannotInitiateTransferEther();
    
    /**
     * @notice Error indicating that only a wallet address is allowed to perform the action.
     * 
     * @dev Should throw if called to use an address that is not believed to be a wallet.
     */
    error OnlyWalletAddressAllowed();

    /**
     * @notice Error indicating that trading has not been enabled yet.
     */
    error TradeNotYetEnabled();

    /**
     * @notice Error indicating that the transaction is prevented due to gas wastage action.
     */
    error GasWastage();

    /**
     * @notice Error indicating that no balancing needed.
     */
    error NoNeedBalancing();

    /**
     * @notice Error indicating that anti sniper is active and any transaction involving
     * two address that is not whitelisted will be prevented for five block.
     */
    error AntiSniperCannotTransactFiveBlock();

    /**
     * @notice Error indicating an invalid total fee compared to the maximum allowed.
     * 
     * @param current The current total fee.
     * @param max The maximum allowed total fee.
     *
     * @dev The `max` is required to inform user of the maximum value allowed.
     */
    error InvalidTotalFee(uint256 current, uint256 max);

    /**
     * @notice Error indicating that trading has already been enabled at a specific `timestamp`.
     * 
     * @param currentState The current state of trading.
     * @param timestamp The timestamp when trading was enabled.
     *
     * @dev The `currentState` is required to inform user of the current state of trading.
     */
    error TradeAlreadyEnabled(bool currentState, uint256 timestamp);

    /**
     * @notice Error indicating that the type of limit exceed the amount.
     * 
     * @param limitType The type of limit exceeded.
     * @param limit The amount after current limit imposed.
     *
     * @dev The `currentState` is required to inform user of the current state of trading.
     */
    error LimitExceed(string limitType, uint256 limit);

    // CONSTRUCTOR

    /**
     * @notice Constructs the Platty Ai contract and initializes both owner and
     * project owner addresses. Deployer will receive 1,000,000,000,000 tokens after
     * the smart contract was deployed.
     * 
     * @dev If deployer is not the project owner, then deployer will be exempted
     * from fees along with the project owner and router.
     */
    constructor() Ownable (msg.sender) {
        isExemptFee[projectOwner] = true;
        isExemptFee[address(this)] = true;
        isExemptFee[address(router)] = true;

        isExemptWalletLimit[projectOwner] = true;
        isExemptWalletLimit[address(this)] = true;
        isExemptWalletLimit[address(router)] = true;

        isExemptTxnLimit[projectOwner] = true;
        isExemptTxnLimit[address(this)] = true;
        isExemptTxnLimit[address(router)] = true;

        isWhitelist[projectOwner] = true;
        isWhitelist[address(this)] = true;
        isWhitelist[address(router)] = true;

        if (projectOwner != msg.sender) {
            isExemptFee[msg.sender] = true;
            isExemptWalletLimit[msg.sender] = true;
            isExemptTxnLimit[msg.sender] = true;
            isWhitelist[msg.sender] = true;
        }
        
        _mint(msg.sender, 1_000_000_000_000 * 10**DECIMALS);

        pair = IFactory(router.factory()).createPair(address(this), router.WETH());
        isPairLP[pair] = true;
        isExemptWalletLimit[pair] = true;
        isExemptTxnLimit[pair] = true;
        isWhitelist[pair] = true;
    }

    // EVENT

    /**
     * @notice Emitted when trading is enabled for the contract.
     * 
     * @param caller The address that triggered the trading enablement.
     * @param timestamp The timestamp when trading was enabled.
     */
    event TradeEnabled(address caller, uint256 timestamp);

    /**
     * @notice Emits when an automatic or manual redemption occurs, distributing fees
     * and redeeming a specific amount.
     * 
     * @param feeDistribution The amount distributed for respective fees.
     * @param amountToRedeem The total amount being redeemed.
     * @param caller The address that triggered the redemption.
     * @param timestamp The timestamp at which the redemption event occurred.
     */
    event AutoRedeem(uint256[4] feeDistribution, uint256 amountToRedeem, address caller, uint256 timestamp);

    /**
     * @notice Emitted when the router address is updated.
     * 
     * @param oldRouter The address of the old router.
     * @param newRouter The address of the new router.
     * @param caller The address that triggered the router update.
     * @param timestamp The timestamp when the update occurred.
     */
    event UpdateRouter(address oldRouter, address newRouter, address caller, uint256 timestamp);

    /**
     * @notice Emitted upon setting the status of a specific address type.
     * 
     * @param addressType The type of address status being modified.
     * @param account The address of the account whose status is being updated.
     * @param oldStatus The previous exemption status.
     * @param newStatus The new exemption status.
     * @param caller The address that triggered the status update.
     * @param timestamp The timestamp when the update occurred.
     */
    event SetAddressState(string addressType, address account, bool oldStatus, bool newStatus, address caller, uint256 timestamp); 
    
    /**
     * @notice Emitted when the state of a feature is updated.
     * 
     * @param stateType The type of state being updated.
     * @param oldStatus The previous status before the update.
     * @param newStatus The new status after the update.
     * @param caller The address of the caller who updated the state.
     * @param timestamp The timestamp when the update occurred.
     */
    event UpdateSpecialState(string stateType, bool[3] oldStatus, bool[3] newStatus, address caller, uint256 timestamp);

    /**
     * @notice Emitted when the state of a feature is updated.
     * 
     * @param stateType The type of state being updated.
     * @param oldStatus The previous status before the update.
     * @param newStatus The new status after the update.
     * @param caller The address of the caller who updated the state.
     * @param timestamp The timestamp when the update occurred.
     */
    event UpdateState(string stateType, bool oldStatus, bool newStatus, address caller, uint256 timestamp);

    /**
     * @notice Emitted upon updating a receiver address.
     * 
     * @param receiverType The type of receiver being updated.
     * @param oldReceiver The previous receiver address before the update.
     * @param newReceiver The new receiver address after the update.
     * @param caller The address of the caller who updated the receiver address.
     * @param timestamp The timestamp when the receiver address was updated.
     */
    event UpdateReceiver(string receiverType, address oldReceiver, address newReceiver, address caller, uint256 timestamp);

    /**
     * @notice Emitted when the state of a feature is updated.
     * 
     * @param feeType The type of fee being updated.
     * @param oldFee The previous fee value before the update.
     * @param newFee The new fee value after the update.
     * @param caller The address of the caller who updated the fee.
     * @param timestamp The timestamp when the fee update occurred.
     */
    event UpdateFee(string feeType, uint256[4] oldFee, uint256[4] newFee, address caller, uint256 timestamp);

    /**
     * @notice Emitted when the value is updated.
     * 
     * @param valueType The type of value being updated.
     * @param oldValue The old value before the update.
     * @param newValue The new value after the update.
     * @param caller The address of the caller who updated the value.
     * @param timestamp The timestamp when the update occurred.
     */
    event UpdateValue(string valueType, uint256 oldValue, uint256 newValue, address caller, uint256 timestamp);
    
    /**
     * @notice Emitted when the minimum swap value is updated.
     * 
     * @param diff The amount differences that was balanced.
     * @param caller The address of the caller who initiate the balancing.
     * @param timestamp The timestamp when the balancing occurred.
     */
    event InitiateBalancing(uint256 diff, address caller, uint256 timestamp);

    // FUNCTION

    /* General */
    
    /**
     * @notice Allows the contract to receive Ether.
     * 
     * @dev This is a required feature to have in order to allow the smart contract
     * to be able to receive ether from the swap.
     */
    receive() external payable {}

    /**
     * @notice Withdraws tokens or Ether from the contract to a specified address.
     * 
     * @param tokenAddress The address of the token to withdraw.
     * @param amount The amount of tokens or Ether to withdraw.
     * 
     * @dev You need to use address(0) as `tokenAddress` to withdraw Ether and
     * use 0 as `amount` to withdraw the whole balance amount in the smart contract.
     * Anyone can trigger this function to send the fund to the `marketingReceiver`.
     * Only `marketingReceiver` address will not be able to trigger this function to
     * withdraw Ether from the smart contract by himself/herself. Should throw if try
     * to withdraw any amount of native token from the smart contract. Distribution
     * of native token can only be done through autoRedeem function.
     */
    function wTokens(address tokenAddress, uint256 amount) external {
        uint256 allocated = totalFeeCollected > totalFeeRedeemed ? totalFeeCollected - totalFeeRedeemed : 0;
        uint256 toTransfer = amount;
        address receiver = marketingReceiver;
        
        if (tokenAddress == address(this)) {
            if (allocated >= balanceOf(address(this))) {
                revert CannotWithdrawNativeToken();
            }
            if (amount > balanceOf(address(this)) - allocated) {
                revert ERC20InsufficientBalance(address(this), balanceOf(address(this)) - allocated, amount);
            }
            if (amount == 0) {
                toTransfer = balanceOf(address(this)) - allocated;
            }
            _update(address(this), receiver, toTransfer);
        } else if (tokenAddress == address(0)) {
            if (amount == 0) {
                toTransfer = address(this).balance;
            }
            if (msg.sender == receiver) {
                revert ReceiverCannotInitiateTransferEther();
            }
            payable(receiver).transfer(toTransfer);
        } else {
            if (amount == 0) {
                toTransfer = IERC20(tokenAddress).balanceOf(address(this));
            }
            IERC20(tokenAddress).transfer(receiver, toTransfer);
        }
    }

    /**
     * @notice Balance back the difference between collected and redeemed fee amount if redeemed amount
     * is more that collected amount.
     */
    function balancing() external {
        if(totalFeeCollected >= totalFeeRedeemed) {
            revert NoNeedBalancing();
        }
        collectedFee.marketing = redeemedFee.marketing;
        collectedFee.liquidity = redeemedFee.liquidity;
        collectedFee.donations = redeemedFee.donations;
        collectedFee.team = redeemedFee.team;
        totalFeeCollected = totalFeeRedeemed;
        emit InitiateBalancing(totalFeeCollected - totalFeeRedeemed, msg.sender, block.timestamp);
    }

    /**
     * @notice Enables trading functionality for the token contract.
     * 
     * @dev Only the smart contract owner can trigger this function and should throw if
     * trading already enabled. Can only be triggered once and emits a TradeEnabled event
     * upon successful transaction. This function also set necessary states and emitting
     * an event upon success.
     */
    function enableTrading() external onlyOwner {
        if (tradeEnabled) {
            revert TradeAlreadyEnabled(tradeEnabled, tradeStartTime);
        }
        if (!isFeeActive) {
            isFeeActive = true;
        }
        if (!isWalletLimitActive) {
            isWalletLimitActive = true;
        }
        if (!isTxnLimitActive) {
            isTxnLimitActive = true;
        }
        if (!isSwapEnabled) {
            isSwapEnabled = true;
        }
        tradeEnabled = true;
        tradeStartTime = block.timestamp;
        tradeStartBlock = block.number;

        emit TradeEnabled(msg.sender, block.timestamp);
    }

    /**
     * @notice Calculates the circulating supply of the token.
     * 
     * @return The circulating supply of the token.
     * 
     * @dev This should only return the token supply that is in circulation,
     * which excluded the potential balance that could be in both address(0)
     * and address(0xdead) that are already known to not be out of circulation.
     */
    function circulatingSupply() public view returns (uint256) {
        return totalSupply() - balanceOf(address(0xdead)) - balanceOf(address(0));
    }

    /* Redeem */

    /**
     * @notice Initiates a manual redemption process by distributing a specific
     * amount of tokens for fee purposes, swapping a portion for ETH.
     * 
     * @param amountToRedeem The amount of tokens to be redeemed and distributed
     * for fee.
     * 
     * @dev This function calculates the distribution of tokens for fee redeems
     * the specified amount, and triggers a swap for ETH. This function can only
     * be used to manual redeem specified amount by the owner.
     */
    function manualRedeem(uint256 amountToRedeem) external swapping {
        autoRedeem(amountToRedeem);
    }

    /**
     * @notice Initiates an automatic redemption process by distributing a specific
     * amount of tokens for marketing purposes, swapping a portion for ETH.
     * 
     * @param amountToRedeem The amount of tokens to be redeemed and distributed
     * for marketing.
     * 
     * @dev This function calculates the distribution of tokens for marketing
     * redeems the specified amount, and triggers a swap for ETH. This function 
     * can be used for both auto and manual redeem of the specified amount.
     */
    function autoRedeem(uint256 amountToRedeem) internal swapping {
        uint256 totalToRedeem = totalFeeCollected > totalFeeRedeemed ? totalFeeCollected - totalFeeRedeemed : 0;
        
        if (amountToRedeem > totalToRedeem) {
            return;
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        uint256 marketingToRedeem = collectedFee.marketing - redeemedFee.marketing;
        uint256 liquidityToRedeem = collectedFee.liquidity - redeemedFee.liquidity;
        uint256 donationsToRedeem = collectedFee.donations - redeemedFee.donations;
        
        uint256 marketingFeeDistribution = amountToRedeem * marketingToRedeem / totalToRedeem;
        uint256 liquidityFeeDistribution = amountToRedeem * liquidityToRedeem / totalToRedeem;
        uint256 donationsFeeDistribution = amountToRedeem * donationsToRedeem / totalToRedeem;
        uint256 teamFeeDistribution = amountToRedeem - marketingFeeDistribution - liquidityFeeDistribution - donationsFeeDistribution;

        totalFeeRedeemed += amountToRedeem;

        uint256 initialBalance = address(this).balance;
        uint256 firstLiquidityHalf = liquidityFeeDistribution / 2;
        uint256 secondLiquidityHalf = liquidityFeeDistribution - firstLiquidityHalf;

        _approve(address(this), address(router), amountToRedeem);
    
        emit AutoRedeem([marketingFeeDistribution, liquidityFeeDistribution, donationsFeeDistribution, teamFeeDistribution], amountToRedeem, msg.sender, block.timestamp);

        if (marketingFeeDistribution > 0) {
            redeemedFee.marketing += marketingFeeDistribution;
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                marketingFeeDistribution,
                0,
                path,
                marketingReceiver,
                block.timestamp
            );
        }

        if (liquidityFeeDistribution > 0) {
            redeemedFee.liquidity += liquidityFeeDistribution;
            
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                firstLiquidityHalf,
                0,
                path,
                address(this),
                block.timestamp
            );
            
            router.addLiquidityETH{
                value: address(this).balance - initialBalance
            }(
                address(this),
                secondLiquidityHalf,
                0,
                0,
                liquidityReceiver,
                block.timestamp + 1_200
            );
        }

        if (donationsFeeDistribution > 0) {
            redeemedFee.donations += donationsFeeDistribution;
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                donationsFeeDistribution,
                0,
                path,
                donationsReceiver,
                block.timestamp
            );
        }

        if (teamFeeDistribution > 0) {
            redeemedFee.team += teamFeeDistribution;
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                teamFeeDistribution,
                0,
                path,
                teamReceiver,
                block.timestamp
            );
        }
    }

    /* Update */

    /**
     * @notice Updates the status of fee activation, wallet limit activation, and/or 
     * txn limit activation activation allowing toggling the mechanism.
     * 
     * @param newFeeStatus The new status for fee activation.
     * @param newWalletLimitStatus The new status for wallet limit activation.
     * @param newTxnLimitStatus The new status for txn limit activation.
     * 
     * @dev This function will emits the UpdateSpecialState event.
     */
    function updateActiveState(bool newFeeStatus, bool newWalletLimitStatus, bool newTxnLimitStatus) external onlyOwner {
        if (isFeeActive == newFeeStatus && isWalletLimitActive == newWalletLimitStatus && isTxnLimitActive == newTxnLimitStatus) {
            revert CannotUseAllCurrentState();
        }
        bool oldFeeStatus = isFeeActive;
        bool oldWalletLimitStatus = isWalletLimitActive;
        bool oldTxnLimitStatus = isTxnLimitActive;
        if (isFeeActive != newFeeStatus) {
            isFeeActive = newFeeStatus;
        }
        if (isWalletLimitActive != newWalletLimitStatus) {
            isWalletLimitActive = newWalletLimitStatus;
        }
        if (isTxnLimitActive != newTxnLimitStatus) {
            isTxnLimitActive = newTxnLimitStatus;
        }
        emit UpdateSpecialState("activeState", [oldFeeStatus, oldWalletLimitStatus, oldTxnLimitStatus], [newFeeStatus, newWalletLimitStatus, newTxnLimitStatus], msg.sender, block.timestamp);
    }
    
    /**
     * @notice Updates the minimum swap value, ensuring it doesn't exceed
     * a certain threshold.
     * 
     * @param newMinSwap The new minimum swap value to be set.
     * 
     * @dev This function will emits the UpdateValue event.
     */
    function updateMinSwap(uint256 newMinSwap) external onlyOwner {
        if (newMinSwap > circulatingSupply() * 1_000 / FEEDENOMINATOR) {
            revert InvalidValue(newMinSwap);
        }
        if (minSwap == newMinSwap) {
            revert CannotUseCurrentValue(newMinSwap);
        }
        uint256 oldMinSwap = minSwap;
        minSwap = newMinSwap;
        emit UpdateValue("minSwap", oldMinSwap, newMinSwap, msg.sender, block.timestamp);
    }
    
    /**
     * @notice Updates the wallet limit value, ensuring it doesn't exceed
     * a certain threshold.
     * 
     * @param newWalletLimit The new wallet limit value to be set.
     * 
     * @dev This function will emits the UpdateValue event.
     */
    function updateWalletLimit(uint256 newWalletLimit) external onlyOwner {
        if (newWalletLimit < 2_000) {
            revert InvalidValue(newWalletLimit);
        }
        if (limitWallet == newWalletLimit) {
            revert CannotUseCurrentValue(newWalletLimit);
        }
        uint256 oldWalletLimit = limitWallet;
        limitWallet = newWalletLimit;
        emit UpdateValue("walletLimit", oldWalletLimit, newWalletLimit, msg.sender, block.timestamp);
    }
    
    /**
     * @notice Updates the txn limit value, ensuring it doesn't exceed
     * a certain threshold.
     * 
     * @param newTxnLimit The new txn limit value to be set.
     * 
     * @dev This function will emits the UpdateValue event.
     */
    function updateTxnLimit(uint256 newTxnLimit) external onlyOwner {
        if (newTxnLimit < 2_000) {
            revert InvalidValue(newTxnLimit);
        }
        if (limitTxn == newTxnLimit) {
            revert CannotUseCurrentValue(newTxnLimit);
        }
        uint256 oldTxnLimit = limitTxn;
        limitTxn = newTxnLimit;
        emit UpdateValue("walletLimit", oldTxnLimit, newTxnLimit, msg.sender, block.timestamp);
    }

    /**
     * @notice Updates the status of swap enabling, allowing toggling the swap mechanism.
     * 
     * @param newStatus The new status for swap enabling.
     * 
     * @dev This function will emits the UpdateState event.
     */
    function updateSwapEnabled(bool newStatus) external onlyOwner {
        if (isSwapEnabled == newStatus) {
            revert CannotUseCurrentState(newStatus);
        }
        bool oldStatus = isSwapEnabled;
        isSwapEnabled = newStatus;
        emit UpdateState("isSwapEnabled", oldStatus, newStatus, msg.sender, block.timestamp);
    }
    
    /**
     * @notice Allow the owner to modify marketing fee for buy transactions.
     * 
     * @param newMarketingFee The new marketing fee percentage for buy transactions.
     * @param newLiquidityFee The new liquidity fee percentage for buy transactions.
     * @param newDonationsFee The new donations fee percentage for buy transactions.
     * @param newTeamFee The new team fee percentage for buy transactions.
     * 
     * @dev This function will emits the UpdateFee event and should throw if triggered
     * with the current value or if the fee was locked.
     */
    function updateBuyFee(uint256 newMarketingFee, uint256 newLiquidityFee, uint256 newDonationsFee, uint256 newTeamFee) external onlyOwner {
        if (newMarketingFee + newLiquidityFee + newDonationsFee +newTeamFee > 10_000) {
            revert InvalidTotalFee(newMarketingFee + newLiquidityFee + newDonationsFee +newTeamFee, 10_000);
        }
        if (newMarketingFee == buyFee.marketing && newLiquidityFee == buyFee.liquidity && newDonationsFee == buyFee.donations && newTeamFee == buyFee.team) {
            revert CannotUseAllCurrentValue();
        }
        uint256 oldMarketingFee = buyFee.marketing;
        uint256 oldLiquidityFee = buyFee.liquidity;
        uint256 oldDonationsFee = buyFee.donations;
        uint256 oldTeamFee = buyFee.team;
        buyFee.marketing = newMarketingFee;
        buyFee.liquidity = newLiquidityFee;
        buyFee.donations = newDonationsFee;
        buyFee.team = newTeamFee;
        emit UpdateFee("buyFee", [oldMarketingFee, oldLiquidityFee, oldDonationsFee, oldTeamFee], [newMarketingFee, newLiquidityFee, newDonationsFee, newTeamFee], msg.sender, block.timestamp);
    }
    
    /**
     * @notice Allow the owner to modify marketing fee for sell transactions.
     * 
     * @param newMarketingFee The new marketing fee percentage for sell transactions.
     * @param newLiquidityFee The new liquidity fee percentage for sell transactions.
     * @param newDonationsFee The new donations fee percentage for sell transactions.
     * @param newTeamFee The new team fee percentage for sell transactions.
     * 
     * @dev This function will emits the UpdateFee event and should throw if triggered
     * with the current value or if the fee was locked.
     */
    function updateSellFee(uint256 newMarketingFee, uint256 newLiquidityFee, uint256 newDonationsFee, uint256 newTeamFee) external onlyOwner {
        if (newMarketingFee + newLiquidityFee + newDonationsFee +newTeamFee > 10_000) {
            revert InvalidTotalFee(newMarketingFee + newLiquidityFee + newDonationsFee +newTeamFee, 10_000);
        }
        if (newMarketingFee == sellFee.marketing && newLiquidityFee == sellFee.liquidity && newDonationsFee == sellFee.donations && newTeamFee == sellFee.team) {
            revert CannotUseAllCurrentValue();
        }
        uint256 oldMarketingFee = sellFee.marketing;
        uint256 oldLiquidityFee = sellFee.liquidity;
        uint256 oldDonationsFee = sellFee.donations;
        uint256 oldTeamFee = sellFee.team;
        sellFee.marketing = newMarketingFee;
        sellFee.liquidity = newLiquidityFee;
        sellFee.donations = newDonationsFee;
        sellFee.team = newTeamFee;
        emit UpdateFee("sellFee", [oldMarketingFee, oldLiquidityFee, oldDonationsFee, oldTeamFee], [newMarketingFee, newLiquidityFee, newDonationsFee, newTeamFee], msg.sender, block.timestamp);
    }
    
    /**
     * @notice Allow the owner to modify marketing fee for transfer transactions.
     * 
     * @param newMarketingFee The new marketing fee percentage for transfer transactions.
     * @param newLiquidityFee The new liquidity fee percentage for transfer transactions.
     * @param newDonationsFee The new donations fee percentage for transfer transactions.
     * @param newTeamFee The new team fee percentage for transfer transactions.
     * 
     * @dev This function will emits the UpdateFee event and should throw if triggered
     * with the current value or if the fee was locked.
     */
    function updateTransferFee(uint256 newMarketingFee, uint256 newLiquidityFee, uint256 newDonationsFee, uint256 newTeamFee) external onlyOwner {
        if (newMarketingFee + newLiquidityFee + newDonationsFee +newTeamFee > 10_000) {
            revert InvalidTotalFee(newMarketingFee + newLiquidityFee + newDonationsFee +newTeamFee, 10_000);
        }
        if (newMarketingFee == transferFee.marketing && newLiquidityFee == transferFee.liquidity && newDonationsFee == transferFee.donations && newTeamFee == transferFee.team) {
            revert CannotUseAllCurrentValue();
        }
        uint256 oldMarketingFee = transferFee.marketing;
        uint256 oldLiquidityFee = transferFee.liquidity;
        uint256 oldDonationsFee = transferFee.donations;
        uint256 oldTeamFee = transferFee.team;
        transferFee.marketing = newMarketingFee;
        transferFee.liquidity = newLiquidityFee;
        transferFee.donations = newDonationsFee;
        transferFee.team = newTeamFee;
        emit UpdateFee("transferFee", [oldMarketingFee, oldLiquidityFee, oldDonationsFee, oldTeamFee], [newMarketingFee, newLiquidityFee, newDonationsFee, newTeamFee], msg.sender, block.timestamp);
    }

    /**
     * @notice Allow the owner to change the address receiving marketing fees.
     * 
     * @param newMarketingReceiver The new address to receive marketing fees.
     * 
     * @dev This function will emits the UpdateReceiver event and should throw
     * if triggered with the current address or if the receiver was locked.
     */
    function updateReceiver(address newMarketingReceiver, address newLiquidityReceiver, address newDonationsReceiver, address newTeamReceiver) external onlyOwner {
        if (newMarketingReceiver == address(0)) {
            revert InvalidAddress(address(0));
        }
        if (marketingReceiver == newMarketingReceiver && liquidityReceiver == newLiquidityReceiver && donationsReceiver == newDonationsReceiver && teamReceiver == newTeamReceiver) {
            revert CannotUseAllCurrentAddress();
        }
        address oldMarketingReceiver = marketingReceiver;
        address oldLiquidityReceiver = liquidityReceiver;
        address oldDonationsReceiver = donationsReceiver;
        address oldTeamReceiver = teamReceiver;
        if (marketingReceiver != newMarketingReceiver) {
            marketingReceiver = newMarketingReceiver;
            emit UpdateReceiver("marketingReceiver", oldMarketingReceiver, newMarketingReceiver, msg.sender, block.timestamp);
        }
        if (liquidityReceiver != newLiquidityReceiver) {
            liquidityReceiver = newLiquidityReceiver;
            emit UpdateReceiver("liquidityReceiver", oldLiquidityReceiver, newLiquidityReceiver, msg.sender, block.timestamp);
        }
        if (donationsReceiver != newDonationsReceiver) {
            donationsReceiver = newDonationsReceiver;
            emit UpdateReceiver("donationsReceiver", oldDonationsReceiver, newDonationsReceiver, msg.sender, block.timestamp);
        }
        if (teamReceiver != newTeamReceiver) {
            teamReceiver = newTeamReceiver;
            emit UpdateReceiver("teamReceiver", oldTeamReceiver, newTeamReceiver, msg.sender, block.timestamp);
        }
    }

    /**
     * @notice Allow the owner to set the status of a specified LP pair.
     * 
     * @param lpPair The LP pair address.
     * @param newStatus The new status of the LP pair.
     * 
     * @dev This function will emits the SetAddressState event and should throw
     * if triggered with the current state for the address or if the lpPair
     * address is not a valid pair address.
     */
    function setPairLP(address lpPair, bool newStatus) external onlyOwner {
        if (isPairLP[lpPair] == newStatus) {
            revert CannotUseCurrentState(newStatus);
        }
        if (IPair(lpPair).token0() != address(this) && IPair(lpPair).token1() != address(this)) {
            revert InvalidAddress(lpPair);
        }
        bool oldStatus = isPairLP[lpPair];
        isPairLP[lpPair] = newStatus;
        emit SetAddressState("isPairLP", lpPair, oldStatus, newStatus, msg.sender, block.timestamp);
    }

    /**
     * @notice Updates the router address used for token swaps.
     * 
     * @param newRouter The address of the new router contract.
     * 
     * @dev This should also generate the pair address using the factory of the `newRouter` if
     * the address of the pair on the new router's factory is address(0).If the new pair address's
     * isPairLP status is not yet set to true, this function will automatically set it to true.
     */
    function updateRouter(address newRouter) external onlyOwner {
        if (newRouter == address(router)) {
            revert CannotUseCurrentAddress(newRouter);
        }

        address oldRouter = address(router);
        router = IRouter(newRouter);
        isExemptFee[newRouter] = true;
        isExemptWalletLimit[newRouter] = true;
        isExemptTxnLimit[newRouter] = true;
        if (tradeStartTime > 0 && block.number <= tradeStartBlock + 5) {
            isWhitelist[newRouter] = true;
        }

        emit UpdateRouter(oldRouter, newRouter, msg.sender, block.timestamp);

        if (address(IFactory(router.factory()).getPair(address(this), router.WETH())) == address(0)) {
            pair = IFactory(router.factory()).createPair(address(this), router.WETH());
            if (!isPairLP[pair]) {
                isPairLP[pair] = true;
            }
        }
    }

    /**
     * @notice Updates the exemption status for fee on a specific account.
     * 
     * @param user The address of the account.
     * @param newFeeStatus The new fee exemption status.
     * @param newWalletLimitStatus The new wallet limit exemption status.
     * @param newTxnLimitStatus The new txn limit exemption status.
     * @param newWhitelistStatus The new whitelist exemption status.
     * 
     * @dev Should throw if the `newStatus` is the exact same state as the current state
     * for the `user` address.
     */
    function updateExemption(address user, bool newFeeStatus, bool newWalletLimitStatus, bool newTxnLimitStatus, bool newWhitelistStatus) external onlyOwner {
        if (tradeStartTime > 0 && block.number <= tradeStartBlock + 5) {
            if (isExemptFee[user] == newFeeStatus && isExemptWalletLimit[user] == newWalletLimitStatus && isExemptTxnLimit[user] == newTxnLimitStatus && isWhitelist[user] == newWhitelistStatus) {
                revert CannotUseAllCurrentState();
            }
        } else {
            if (isExemptFee[user] == newFeeStatus && isExemptWalletLimit[user] == newWalletLimitStatus && isExemptTxnLimit[user] == newTxnLimitStatus) {
                revert CannotUseAllCurrentState();
            }
        }

        bool oldFeeStatus = isExemptFee[user];
        bool oldWalletLimitStatus = isExemptWalletLimit[user];
        bool oldTxnLimitStatus = isExemptTxnLimit[user];
        bool oldWhitelistStatus = isWhitelist[user];
        if (isExemptFee[user] != newFeeStatus) {
            isExemptFee[user] = newFeeStatus;
            emit SetAddressState("isExemptFee", user, oldFeeStatus, newFeeStatus, msg.sender, block.timestamp);
        }
        if (isExemptWalletLimit[user] != newWalletLimitStatus) {
            isExemptWalletLimit[user] = newWalletLimitStatus;
            emit SetAddressState("isExemptWalletLimit", user, oldWalletLimitStatus, newWalletLimitStatus, msg.sender, block.timestamp);
        }
        if (isExemptTxnLimit[user] != newTxnLimitStatus) {
            isExemptTxnLimit[user] = newTxnLimitStatus;
            emit SetAddressState("isExemptTxnLimit", user, oldTxnLimitStatus, newTxnLimitStatus, msg.sender, block.timestamp);
        }
        if (isWhitelist[user] != newWhitelistStatus && tradeStartTime > 0 && block.number <= tradeStartBlock + 5) {
            isWhitelist[user] = newWhitelistStatus;
            emit SetAddressState("isWhitelist", user, oldWhitelistStatus, newWhitelistStatus, msg.sender, block.timestamp);
        }
    }

    /* Fee */

    /**
     * @notice Takes the transfer fee from the specified address and amount, and distribute
     * the fees accordingly.
     * 
     * @param feeType The type of fee being taken.
     * @param from The address from which the fee is taken.
     * @param amount The amount from which the fee is taken.
     * 
     * @return The new amount after deducting the fee.
     */
    function takeFee(Fee memory feeType, address from, uint256 amount) internal swapping returns (uint256) {
        uint256 feeTotal = feeType.marketing + feeType.liquidity + feeType.donations + feeType.team;
        uint256 feeAmount = amount * feeTotal / FEEDENOMINATOR;
        uint256 newAmount = amount - feeAmount;
        if (feeAmount > 0) {
            tallyFee(feeType, from, feeAmount, feeTotal);
        }
        return newAmount;
    }
    
    /**
     * @notice Tally the collected fee for a given fee type and address,
     * based on the amount and fee provided.
     * 
     * @param feeType The type of fee being tallied.
     * @param from The address from which the fee is collected.
     * @param amount The total amount being collected as a fee.
     * @param fee The total fee being collected.
     */
    function tallyFee(Fee memory feeType, address from, uint256 amount, uint256 fee) internal swapping {
        uint256 collectMarketing = amount * feeType.marketing / fee;
        uint256 collectLiquidity = amount * feeType.liquidity / fee;
        uint256 collectDonations = amount * feeType.donations / fee;
        uint256 collectTeam = amount - collectMarketing - collectLiquidity - collectDonations;
        tallyCollection(collectMarketing, collectLiquidity, collectDonations, collectTeam, amount);
        
        _update(from, address(this), amount);
    }

    /**
     * @notice Tally the collected fee for marketing based on
     * provided amounts.
     * 
     * @param collectMarketing The amount collected for marketing fees.
     * @param collectLiquidity The amount collected for liquidity fees.
     * @param collectDonations The amount collected for donations fees.
     * @param collectTeam The amount collected for team fees.
     * @param amount The total amount collected as a fee.
     */
    function tallyCollection(uint256 collectMarketing, uint256 collectLiquidity, uint256 collectDonations, uint256 collectTeam, uint256 amount) internal swapping {
        collectedFee.marketing += collectMarketing;
        collectedFee.liquidity += collectLiquidity;
        collectedFee.donations += collectDonations;
        collectedFee.team += collectTeam;
        totalFeeCollected += amount;
    }

    /* Buyback */

    /**
     * @notice Triggers a buyback with a specified amount,
     * limited to 5 ether per transaction.
     * 
     * @param amount The amount of ETH to be used for the buyback.
     * 
     * @dev This can only be triggered by the smart contract owner.
     */
    function triggerZeusBuyback(uint256 amount) external onlyOwner {
        if (amount > 5 ether) {
            revert InvalidValue(5 ether);
        }
        totalTriggerZeusBuyback += amount;
        lastTriggerZeusTimestamp = block.timestamp;
        buyTokens(amount, address(0xdead));
    }

    /**
     * @notice Initiates a buyback by swapping ETH for tokens.
     * 
     * @param amount The amount of ETH to be used for the buyback.
     * @param to The address to which the bought tokens will be sent.
     */
    function buyTokens(uint256 amount, address to) internal swapping {
        if (msg.sender == address(0xdead)) { revert InvalidAddress(address(0xdead)); }
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(this);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        } (0, path, to, block.timestamp);
    }

    /* Override */
    
    /**
     * @notice Overrides the {transferOwnership} function to update project owner.
     * 
     * @param newOwner The address of the new owner.
     * 
     * @dev Should throw if the `newOwner` is set to the current owner address or address(0xdead).
     * This overrides function is just an extended version of the original {transferOwnership}
     * function. See {Ownable-transferOwnership} for more information.
     */
    function transferOwnership(address newOwner) public override onlyOwner {
        if (newOwner == owner()) {
            revert CannotUseCurrentAddress(newOwner);
        }
        if (newOwner == address(0xdead)) {
            revert InvalidAddress(newOwner);
        }
        projectOwner = newOwner;
        super.transferOwnership(newOwner);
    }

    /* ERC20 Standard */

    /**
     * @notice Returns the name of the token.
     * 
     * @return The name of the token.
     * 
     * @dev This is usually a longer version of the name.
     */
    function name() public view virtual returns (string memory) {
        return NAME;
    }

    /**
     * @notice Returns the symbol of the token.
     * 
     * @return The symbol of the token.
     * 
     * @dev This is usually a shorter version of the name.
     */
    function symbol() public view virtual returns (string memory) {
        return SYMBOL;
    }

    /**
     * @notice Returns the number of decimals used for token display purposes.
     * 
     * @return The number of decimals.
     * 
     * @dev This is purely used for user representation of the amount and does not
     * affect any of the arithmetic of the smart contract including, but not limited
     * to {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return DECIMALS;
    }

    /**
     * @notice Returns the total supply of tokens.
     * 
     * @return The total supply of tokens.
     * 
     * @dev See {IERC20-totalSupply} for more information.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @notice Returns the balance of tokens for a given account.
     * 
     * @param account The address of the account to check.
     * 
     * @return The token balance of the account.
     * 
     * @dev See {IERC20-balanceOf} for more information.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @notice Transfers tokens from the sender to a specified recipient.
     * 
     * @param to The address of the recipient.
     * @param value The amount of tokens to transfer.
     * 
     * @return A boolean indicating whether the transfer was successful or not.
     * 
     * @dev See {IERC20-transfer} for more information.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address provider = msg.sender;
        _transfer(provider, to, value);
        return true;
    }

    /**
     * @notice Returns the allowance amount that a spender is allowed to spend on behalf of a provider.
     * 
     * @param provider The address allowing spending.
     * @param spender The address allowed to spend tokens.
     * 
     * @return The allowance amount for the spender.
     * 
     * @dev See {IERC20-allowance} for more information.
     */
    function allowance(address provider, address spender) public view virtual returns (uint256) {
        return _allowances[provider][spender];
    }
    
    /**
     * @notice Approves a spender to spend a certain amount of tokens on behalf of the sender.
     * 
     * @param spender The address allowed to spend tokens.
     * @param value The allowance amount for the spender.
     * 
     * @return A boolean indicating whether the approval was successful or not.
     * 
     * @dev See {IERC20-approve} for more information.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address provider = msg.sender;
        _approve(provider, spender, value);
        return true;
    }

    /**
     * @notice Transfers tokens from one address to another on behalf of a spender.
     * 
     * @param from The address to transfer tokens from.
     * @param to The address to transfer tokens to.
     * @param value The amount of tokens to transfer.
     * 
     * @return A boolean indicating whether the transfer was successful or not.
     * 
     * @dev See {IERC20-transferFrom} for more information.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @notice Internal function to handle token transfers with additional checks.
     * 
     * @param from The address tokens are transferred from.
     * @param to The address tokens are transferred to.
     * @param value The amount of tokens to transfer.
     * 
     * @dev This internal function is equivalent to {transfer}, and thus can be used for other functions
     * such as implementing automatic token fees, slashing mechanisms, etc. Since this function is not
     * virtual, {_update} should be overridden instead. This function can only be called if the address
     * for `from` and `to` are not address(0) and the sender should at least have a balance of `value`.
     * It also enforces various conditions including validations for trade status, fees, exemptions,
     * and redemption.
     * 
     * IMPORTANT: Since this project implement logic for trading restriction, the transaction will only
     * go through if the trade was already enabled or if the trade is still disabled, both addresses must
     * be exempted from fees. Please note that this feature could significantly impact the audit score as
     * since it possesses the potential for malicious exploitation, which might affect the received score.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        if (!tradeEnabled) {
            if (!isExemptFee[from] && !isExemptFee[to]) {
                revert TradeNotYetEnabled();
            }
        }

        if (tradeStartBlock > 0 && block.number <= tradeStartBlock + 5 && !isWhitelist[from] && !isWhitelist[to]) {
            revert AntiSniperCannotTransactFiveBlock();
        }

        if (isTxnLimitActive && !isExemptTxnLimit[from] && value > circulatingSupply() * limitTxn / FEEDENOMINATOR) {
            revert LimitExceed("Txn Limit Exceed", circulatingSupply() * limitTxn / FEEDENOMINATOR);
        }

        if (inSwap || isExemptFee[from] || isExemptFee[to]) {
            return _update(from, to, value);
        }
        uint256 toRedeem = totalFeeCollected > totalFeeRedeemed ? totalFeeCollected - totalFeeRedeemed : 0;
        if (from != pair && isSwapEnabled && toRedeem >= minSwap && balanceOf(address(this)) >= minSwap) {
            autoRedeem(toRedeem);
        }

        uint256 newValue = value;

        if (isFeeActive && !isExemptFee[from] && !isExemptFee[to]) {
            newValue = _beforeTokenTransfer(from, to, value);
        }

        if (isWalletLimitActive && !isExemptWalletLimit[to] && balanceOf(to) + newValue > circulatingSupply() * limitWallet / FEEDENOMINATOR) {
            revert LimitExceed("Wallet Limit Exceed", circulatingSupply() * limitWallet / FEEDENOMINATOR);
        }

        _update(from, to, newValue);
    }

    /**
     * @notice Internal function called before token transfer, applying fee mechanisms
     * based on transaction specifics.
     * 
     * @param from The address from which tokens are being transferred.
     * @param to The address to which tokens are being transferred.
     * @param amount The amount of tokens being transferred.
     * 
     * @return The modified amount after applying potential fees.
     * 
     * @dev This function calculates and applies fees before executing token transfers
     * based on the transaction details and address types.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal swapping virtual returns (uint256) {
        if (isPairLP[from] && (buyFee.marketing + buyFee.liquidity + buyFee.donations + buyFee.team > 0)) {
            return takeFee(buyFee, from, amount);
        }
        if (isPairLP[to] && (sellFee.marketing + sellFee.liquidity + sellFee.donations + sellFee.team > 0)) {
            return takeFee(sellFee, from, amount);
        }
        if (!isPairLP[from] && !isPairLP[to] && (transferFee.marketing + transferFee.liquidity + transferFee.donations + transferFee.team > 0)) {
            return takeFee(transferFee, from, amount);
        }
        return amount;
    }

    /**
     * @notice Internal function to update token balances during transfers.
     * 
     * @param from The address tokens are transferred from.
     * @param to The address tokens are transferred to.
     * @param value The amount of tokens to transfer.
     * 
     * @dev This function is used internally to transfer a `value` amount of token from
     * `from` address to `to` address. This function is also used for mints if `from`
     * is the zero address and for burns if `to` is the zero address.
     * 
     * IMPORTANT: All customizations that are required for transfers, mints, and burns
     * should be done by overriding this function.

     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                _totalSupply -= value;
            }
        } else {
            unchecked {
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }
 
    /**
     * @notice Internal function to mint tokens and update the total supply.
     * 
     * @param account The address to mint tokens to.
     * @param value The amount of tokens to mint.
     * 
     * @dev The `account` address cannot be address(0) because it does not make any sense to mint to it.
     * Since this function is not virtual, {_update} should be overridden instead for customization.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }
 
    /**
     * @notice Internal function to set an allowance for a `spender` to spend a specific `value` of tokens
     * on behalf of a `provider`.
     * 
     * @param provider The address allowing spending.
     * @param spender The address allowed to spend tokens.
     * @param value The allowance amount for the spender.
     * 
     * @dev This internal function is equivalent to {approve}, and thus can be used for other functions
     * such as setting automatic allowances for certain subsystems, etc. 
     * 
     * IMPORTANT: This function internally calls {_approve} with the emitEvent parameter set to `true`.
     */
    function _approve(address provider, address spender, uint256 value) internal {
        _approve(provider, spender, value, true);
    }

    /**
     * @notice Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     * 
     * @param provider The address allowing spending.
     * @param spender The address allowed to spend tokens.
     * @param value The allowance amount for the spender.
     * @param emitEvent A boolean indicating whether to emit the Approval event.
     * 
     * @dev This internal function is equivalent to {approve}, and thus can be used for other functions
     * such as setting automatic allowances for certain subsystems, etc. This function can only be called
     * if the address for `provider` and `spender` are not address(0). If `emitEvent` is set to `true`,
     * this function will emits the Approval event.
     */
    function _approve(address provider, address spender, uint256 value, bool emitEvent) internal virtual {
        if (provider == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[provider][spender] = value;
        if (emitEvent) {
            emit Approval(provider, spender, value);
        }
    }

    /**
     * @notice Internal function to decrease allowance when tokens are spent.
     * 
     * @param provider The address allowing spending.
     * @param spender The address allowed to spend tokens.
     * @param value The amount of tokens spent.
     * 
     * @dev If the allowance value for the `spender` is infinite/the max value of uint256,
     * this function will notupdate the allowance value. Should throw if not enough allowance
     * is available. On all occasion, this function will not emit an Approval event.
     */
    function _spendAllowance(address provider, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(provider, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(provider, spender, currentAllowance - value, false);
            }
        }
    }

    /* ERC20 Extended */

    /**
     * @notice Increases the allowance granted by the message sender to the spender.
     * 
     * @param spender The address to whom the allowance is being increased.
     * @param value The additional amount by which the allowance is increased.
     * 
     * @return A boolean indicating whether the operation was successful or not.
     * 
     * @dev Allow a spender to spend more tokens on behalf of the message sender and
     * update the allowance accordingly.
     */
    function increaseAllowance(address spender, uint256 value) external virtual returns (bool) {
        address provider = msg.sender;
        uint256 currentAllowance = allowance(provider, spender);
        _approve(provider, spender, currentAllowance + value, true);
        return true;
    }
    
    /**
     * @notice Decreases the allowance granted by the message sender to the spender.
     * 
     * @param spender The address whose allowance is being decreased.
     * @param value The amount by which the allowance is decreased.
     * 
     * @return A boolean indicating whether the operation was successful or not.
     * 
     * @dev Reduce the spender's allowance by a specified amount. Should throw if the
     * current allowance is insufficient.
     */
    function decreaseAllowance(address spender, uint256 value) external virtual returns (bool) {
        address provider = msg.sender;
        uint256 currentAllowance = allowance(provider, spender);
        if (currentAllowance < value) {
            revert ERC20InsufficientAllowance(spender, currentAllowance, value);
        }
        unchecked {
            _approve(provider, spender, currentAllowance - value, true);
        }
        return true;
    }
}