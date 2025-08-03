/**
Let's PetBambi together!

Website: https://petbambi.com/

Whitepaper: https://petbambi.com/PetBambi_(PETB)_Whitepaper.pdf

Twitter: https://x.com/petbambi_petb

Discord: https://discord.me/petbambi
**/


// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28.0;





// Begin IERC20.sol
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// End IERC20.sol





// Begin IERC20Metadata.sol
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
// End IERC20.sol





// Begin Context.sol
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
// End Context.sol





// Begin Ownable.sol
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

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
// End Ownable.sol





// Begin Pausable.sol
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}
// End Pausable.sol





// Begin ReentrancyGuard.sol
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}
// End ReentrancyGuard.sol





/// @dev Implementation of the ERC20 token standard with additional custom features.
contract PetBambiERC20 is IERC20, IERC20Metadata, Ownable, Pausable, ReentrancyGuard {
    string private constant TOKEN_NAME = "PetBambi";
    string private constant TOKEN_SYMBOL = "PETB";
    uint8 private constant DECIMALS = 18;

    uint256 private _totalSupply;

    bool public tradingEnabled = false;

    struct Limits {
        uint256 maxTxAmount;
        uint256 maxWalletBalance;
    }

    struct Wallets {
        address liquidityPoolWallet;
        address airdropWallet;
        address founderWallet;
        address marketingWallet;
    }

    Limits public limits;
    Wallets public wallets;

    mapping(address => bool) public isBlacklisted;
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
    mapping(address => bool) private tradingExempt;
    mapping(address => uint256) public claimedRewards;
    mapping(address => uint256) public lastClaimedTimestamp;
    mapping(address => uint256) public lastActionTimestamp;
    mapping(address => bool) private bridges;

    uint256 public totalRewardsPool;
    uint256 public rewardPerToken;
    uint256 public vestingStartTimestamp;
    uint256 public constant VESTING_CLIFF = 30 days;
    uint256 public constant VESTING_RATE = 10;

    event RewardsSupplied(uint256 amount);
    event RewardsClaimed(address indexed recipient, uint256 amount);
    event TradingEnabled(uint256 timestamp);

    constructor(uint256 initialMaxTxAmount, uint256 initialMaxWalletBalance) {
        require(initialMaxTxAmount > 0, "MaxTx > 0");
        require(initialMaxWalletBalance > 0, "MaxBal > 0");

        limits = Limits({
            maxTxAmount: initialMaxTxAmount,
            maxWalletBalance: initialMaxWalletBalance
        });

        wallets = Wallets({
            liquidityPoolWallet: 0xcB21796a652143B270a3471063F6984852C54003,
            airdropWallet: 0x0ECd821424D4B8473C55b92cA2ADC7c264F808D7,
            founderWallet: 0x16538c4e516eBBb692a74E2bc611f5669210D04B,
            marketingWallet: 0xcba3c632C4f469Fa03d9F1bE1a11DD50DA30c91D
        });

        uint256 initialTotalSupply = 33_777_777_777 * 10 ** uint256(DECIMALS);
        _totalSupply = initialTotalSupply;

        uint256 liquidityTokens = (initialTotalSupply * 19) / 100;
        uint256 airdropTokens = (initialTotalSupply * 13) / 100;
        uint256 founderTokens = (initialTotalSupply * 13) / 100;
        uint256 marketingTokens = (initialTotalSupply * 2) / 100;
        uint256 circulatingTokens = initialTotalSupply - (liquidityTokens + airdropTokens + founderTokens + marketingTokens);

        balances[wallets.liquidityPoolWallet] = liquidityTokens;
        balances[wallets.airdropWallet] = airdropTokens;
        balances[wallets.founderWallet] = founderTokens;
        balances[wallets.marketingWallet] = marketingTokens;
        balances[msg.sender] = circulatingTokens;

        tradingExempt[wallets.founderWallet] = true;
        tradingExempt[wallets.liquidityPoolWallet] = true;
        tradingExempt[wallets.marketingWallet] = true;
        tradingExempt[wallets.airdropWallet] = true;
        tradingExempt[msg.sender] = true;

        vestingStartTimestamp = block.timestamp;
    }

    function name() public pure override returns (string memory) {
        return TOKEN_NAME;
    }

    function symbol() public pure override returns (string memory) {
        return TOKEN_SYMBOL;
    }

    function decimals() public pure override returns (uint8) {
        return DECIMALS;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

/// @dev Returns the circulating supply of the token, excluding balances held in specific wallets (liquidity, airdrop, marketing),
/// and unreleased founder tokens based on the vesting schedule.
/// @return The circulating supply of the token.
    function circulatingSupply() public view returns (uint256) {
        unchecked {
            uint256 circulating = _totalSupply;
            circulating -= balances[wallets.liquidityPoolWallet];
            circulating -= balances[wallets.airdropWallet];
            circulating -= balances[wallets.marketingWallet];

            uint256 totalFounderTokens = (_totalSupply * 13) / 100;
            uint256 unreleasedFounderTokens = totalFounderTokens - getReleasedFounderTokens();
            circulating -= unreleasedFounderTokens;

            return circulating;
        }
    }

/// @dev Returns the balance of a specific account.
/// @param account The address of the account to query.
/// @return The balance of the account as an unsigned integer.
    function balanceOf(address account) public view override returns (uint256) {
        return balances[account];
    }

/// @dev Updates the maximum transaction amount limit. Only callable by the owner.
/// @param newMaxTxAmount The new maximum transaction amount.
    function updateMaxTxAmount(uint256 newMaxTxAmount) external onlyOwner {
        require(newMaxTxAmount > 0, "Must be greater than 0");
        limits.maxTxAmount = newMaxTxAmount;
    }

/// @dev Updates the maximum wallet balance limit. Only callable by the owner.
/// @param newMaxWalletBalance The new maximum wallet balance.
    function updateMaxWalletBalance(uint256 newMaxWalletBalance) external onlyOwner {
        require(newMaxWalletBalance > 0, "Must be greater than 0");
        limits.maxWalletBalance = newMaxWalletBalance;
    }

/// @dev Enables token trading. Can only be called by the owner.
/// Emits the `TradingEnabled` event.
/// @notice Once enabled, trading cannot be disabled.
    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "Trading is already enabled");
        tradingEnabled = true;
        emit TradingEnabled(block.timestamp);
    }

/// @dev Supplies rewards to the rewards pool for token holders to claim.
/// Updates the reward per token using 1e9 precision and adjusts the total rewards pool.
/// Requires the owner to have sufficient balance and ensures a non-zero circulating supply.
/// Emits a `RewardsSupplied` event.
/// @param amount The amount of tokens to supply to the rewards pool.
        function supplyRewards(uint256 amount) external onlyOwner whenNotPaused {
        require(amount > 0, "Amount must be greater than 0");
        require(balances[msg.sender] >= amount, "Insufficient balance for rewards");

        balances[msg.sender] -= amount;
        totalRewardsPool += amount;

        uint256 circulatingSupplyAmount = circulatingSupply();
        require(circulatingSupplyAmount > 0, "No circulating supply");

        rewardPerToken += (amount * 1e9) / circulatingSupplyAmount;

        emit RewardsSupplied(amount);
    }

/// @dev Allows a token holder to claim their share of rewards from the rewards pool.
/// Requires a minimum holding of 1 EUR (1 million tokens) to be eligible for rewards.
/// Rewards are based on the holder's balance and the accumulated rewards per token using 1e9 precision.
/// Rewards claimed do not count toward the max wallet balance limit, ensuring users
/// can claim rewards even if their wallet is at the cap.
/// The function ensures rewards can only be claimed once per month (30 days).
/// Emits a `RewardsClaimed` event.
    function claimRewards() external nonReentrant whenNotPaused {
        uint256 userBalance = balances[msg.sender];

        require(userBalance >= 1_000_000, "Minimum 1M tokens required");

        require(
            block.timestamp >= lastClaimedTimestamp[msg.sender] + 30 days,
            "Claim allowed once per month"
            );

        uint256 totalEntitledReward = (userBalance * rewardPerToken) / 1e9;

        uint256 unclaimedReward = totalEntitledReward - claimedRewards[msg.sender];
        require(unclaimedReward > 0, "No rewards available to claim");

        claimedRewards[msg.sender] += unclaimedReward;
        totalRewardsPool -= unclaimedReward;

        balances[msg.sender] += unclaimedReward;

        lastClaimedTimestamp[msg.sender] = block.timestamp;

        emit RewardsClaimed(msg.sender, unclaimedReward);
    }

/// @dev Allows the caller to transfer tokens to multiple recipients in a single transaction.
/// Includes checks for sufficient balance for the total transfer amount.
/// Emits a `Transfer` event for each recipient.
/// @param recipients Array of recipient addresses.
/// @param amounts Array of amounts corresponding to each recipient.
    function batchTransfer(address[] calldata recipients, uint256[] calldata amounts) external whenNotPaused {
        uint256 totalAmount;
        unchecked {
            for (uint256 i = 0; i < recipients.length; i++) {
                totalAmount += amounts[i];
            }
        }
        require(balances[msg.sender] >= totalAmount, "Insufficient balance");

        for (uint256 j = 0; j < recipients.length; j++) {
            address recipientAddress = recipients[j];
            uint256 transferAmount = amounts[j];

            require(recipientAddress != address(0), "Invalid recipient");
            require(transferAmount > 0, "Invalid transfer amount");

            balances[msg.sender] -= transferAmount;
            balances[recipientAddress] += transferAmount;

            emit Transfer(msg.sender, recipientAddress, transferAmount);
        }
    }

/// @dev Transfers tokens from the caller's address to a recipient.
/// Includes checks for trading status, transaction limits, and wallet balance limits.
/// Emits a `Transfer` event.
/// @param recipient The address of the recipient.
/// @param amount The amount of tokens to transfer.
/// @return A boolean value indicating whether the operation was successful.
    function transfer(address recipient, uint256 amount) public override whenNotPaused returns (bool) {
        require(tradingEnabled || tradingExempt[msg.sender], "Trading is not yet enabled");
        _validateTrading(msg.sender, amount);
        require(balances[msg.sender] >= amount, "Insufficient balance");

        if (!tradingExempt[recipient]) {
            uint256 newBalance = balances[recipient] + amount;
            require(newBalance <= limits.maxWalletBalance, "Exceeds max wallet balance");
        }

        balances[msg.sender] -= amount;
        balances[recipient] += amount;

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

/// @dev Transfers tokens from one address to another, using the allowance mechanism.
/// Deducts the specified amount from the caller's allowance.
/// Emits a `Transfer` event.
/// @param sender The address of the token sender.
/// @param recipient The address of the token recipient.
/// @param amount The amount of tokens to transfer.
/// @return A boolean value indicating whether the operation was successful.
    function transferFrom(address sender, address recipient, uint256 amount) public override whenNotPaused returns (bool) {
        require(tradingEnabled || tradingExempt[sender], "Trading is not yet enabled");
        require(recipient != address(0), "Cannot transfer to zero address");
        require(balances[sender] >= amount, "Insufficient balance");
        require(allowances[sender][msg.sender] >= amount, "Allowance exceeded");

        _validateTrading(sender, amount);

        balances[sender] -= amount;
        balances[recipient] += amount;
        allowances[sender][msg.sender] -= amount;

        emit Transfer(sender, recipient, amount);
        return true;
    }

/// @dev Internal function to validate trading conditions, including transaction limits.
/// @param sender The address initiating the transaction.
/// @param amount The amount of tokens to be transferred.
    function _validateTrading(address sender, uint256 amount) internal view {
        require(tradingEnabled || tradingExempt[sender], "Trading disabled");
        require(amount <= limits.maxTxAmount, "Exceeds max transaction size");
    }

/// @dev Increases the allowance of a spender by the specified value.
/// Emits an `Approval` event.
/// @param spender The address of the spender.
/// @param addedValue The additional amount to add to the spender's allowance.
/// @return A boolean value indicating whether the operation was successful.
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, allowances[msg.sender][spender] + addedValue);
        return true;
    }

/// @dev Decreases the allowance of a spender by the specified value.
/// Emits an `Approval` event. Reverts if the requested decrease is greater than the current allowance.
/// @param spender The address of the spender.
/// @param subtractedValue The amount to subtract from the spender's allowance.
/// @return A boolean value indicating whether the operation was successful.
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "Decreased allowance below zero");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }

/// @dev Approves a spender to withdraw tokens from the caller's account, up to the specified amount.
/// Emits an `Approval` event.
/// @param spender The address allowed to spend the tokens.
/// @param amount The maximum amount of tokens the spender is approved to withdraw.
/// @return A boolean value indicating whether the operation was successful.
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

/// @dev Internal function to set the allowance for a spender on a given owner's account.
/// Emits an `Approval` event.
/// @param owner The address of the token owner.
/// @param spender The address allowed to spend the tokens.
/// @param amount The maximum amount of tokens the spender is approved to withdraw.
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0) && spender != address(0), "Zero address");
        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

/// @dev Returns the remaining number of tokens a spender is allowed to spend on behalf of an owner.
/// @param owner The address of the token owner.
/// @param spender The address of the approved spender.
/// @return The remaining allowance as an unsigned integer.
    function allowance(address owner, address spender) public view override returns (uint256) {
        return allowances[owner][spender];
    }

/// @dev Calculates and returns the number of founder tokens that have been released based on the vesting schedule.
/// The release rate is determined by `VESTING_RATE` and the elapsed time since `vestingStartTimestamp`.
/// @return The total number of founder tokens released to date.
    function getReleasedFounderTokens() public view returns (uint256) {
        uint256 totalFounderTokens = (_totalSupply * 13) / 100;
        uint256 elapsedMonths = (block.timestamp - vestingStartTimestamp) / 30 days;

        uint256 releasedTokens = (totalFounderTokens * elapsedMonths * VESTING_RATE) / 100;
        return releasedTokens > totalFounderTokens ? totalFounderTokens : releasedTokens;
    }

/// @dev Burns a specified amount of tokens from the caller's account, reducing the total supply.
/// Emits a `Transfer` event to indicate the burn action.
/// @param amount The amount of tokens to burn.
    function burn(uint256 amount) external {
        require(amount > 0, "Burn must be greater than zero");
        require(balances[msg.sender] >= amount, "Insufficient balance to burn");

        balances[msg.sender] -= amount;
        _totalSupply -= amount;

        emit Transfer(msg.sender, address(0), amount);
    }

/// @dev Mints a specified amount of tokens to a recipient's address, increasing the total supply.
/// Restricted to authorized bridge contracts.
/// Emits a `Transfer` event to indicate the mint action.
/// @param to The address of the recipient.
/// @param amount The amount of tokens to mint.
    function mint(address to, uint256 amount) external onlyBridge {
        require(to != address(0), "Cannot mint to the zero address");
        require(amount > 0, "Mint must be greater than zero");

        balances[to] += amount;
        _totalSupply += amount;

        emit Transfer(address(0), to, amount);
    }

/// @dev Adds a bridge contract to the whitelist.
/// Restricted to the owner of the contract.
/// @param bridge The address of the bridge contract to whitelist.
    function addBridge(address bridge) external onlyOwner {
        require(bridge != address(0), "NO Zero address");
        bridges[bridge] = true;

        emit BridgeAdded(bridge);
    }

/// @dev Removes a bridge contract from the whitelist.
/// Restricted to the owner of the contract.
/// @param bridge The address of the bridge contract to remove.
    function removeBridge(address bridge) external onlyOwner {
        require(bridges[bridge], "Bridge not found in whitelist");
        bridges[bridge] = false;

        emit BridgeRemoved(bridge);
    }

/// @dev Modifier to restrict access to whitelisted bridge contracts.
        modifier onlyBridge() {
        require(bridges[msg.sender], "Caller is not authorized bridge");
        _;
    }

/// @dev Checks if an address is an authorized bridge.
/// @param bridge The address to check.
/// @return True if the address is an authorized bridge, false otherwise.
    function isBridge(address bridge) public view returns (bool) {
        return bridges[bridge];
    }

        event BridgeAdded(address indexed bridge);
        event BridgeRemoved(address indexed bridge);

}