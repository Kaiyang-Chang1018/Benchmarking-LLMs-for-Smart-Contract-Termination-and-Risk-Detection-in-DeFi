// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

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
pragma solidity 0.8.21;

import "./ERC20.sol"; 
import "@openzeppelin/contracts/access/Ownable.sol";

// Website - https://buytruth.cc
// Telegram - https://t.me/buytruth_chat
// X (Previously Twitter) - http://x.com/BuyTruthSellNot

contract BuyTruth is ERC20("BuyTruth", "TRUTH"), Ownable {

    /**
        "Buy the truth, and sell it not; also wisdom, and instruction, and understanding" - Proverbs 23:23 KJV

        This token is designed to encourage users to buy and hold the TRUTH token.
        Once TRUTH is purchased, if sending/selling before 90 days has elapsed a penalty will be applied to the transfer.
        The penalty is calculated on a gradient, with a maximum of 50% for holders of less than one day, and no penalty for holders of 90 days or more.
        The 90 day holding counter is reset every time a purchase of TRUTH tokens is made.
         
        Penalties - All penalties are distributed in the following way: 
            1) 45% of the penalty amount is placed into a rewards pool held by this contract
            2) 30% of the penalty amount is burned (removed from circulation)
            3) 15% of the penalty amount is transfered to a charity address, to be used to fund Kingdom works
            4) 10% of the penalty amount is transfered to a dev fund address, to be used per dev discretion

        Rewards - TRUTH holders are encouraged to claim rewards from the rewards pool using the dApp
            1) Holders can claim based on their allocation of recently purchased TRUTH (until they claim rewards)
            2) Buy more TRUTH increase the percentage of the reward pool that is claimable
            3) Claiming rewards resets purchases that are eligible for making claims
                a) If you would like to claim more, you have to purchase more TRUTH
            4) Claiming rewards also resets the 90 day holding counter
     */
    
    uint public launchBlock; // Block number required to permit transfers (to support a fair launch)

    uint public antiWhaleBlockDelay; // Number of post-launch blocks required to be mined in order to purchase more than 1% of total supply

    uint constant private MULTIPLIER = 100; // used to increase accuracy in calculations

    uint256 constant private _totalSupply = 8100000000 * 10**18; // 8.1 billion tokens with 18 decimal places (one for every soul on the Earth)

    address immutable private _lpMaintainer; // Address that maintains the list of Automated Market Marker Routers and liquity pools
        
    address immutable private _devFundAddress; // For the Scripture says, “You must not muzzle an ox to keep it from eating as it treads out the grain.” And in another place, “Those who work deserve their pay!” - 1 Timothy 5:18 NLT

    address immutable private _charityAddress; // "Whoever is generous to the poor lends to the Lord, and he will repay him for his deed." - Proverbs 19:17 ESV
    
    uint256 private _totalBurned; // Tracks the total amount of penalties burned

    uint256 private _tokenSupplyEligibleForRewards; // Tracks the total amount of tokens bought and have not been sold or had rewards claimed

    mapping(address => bool) public isLiquidityPool; // Map of liquidity pools that sell TRUTH tokens (to avoid penalties being applied to the LP)

    mapping(address => uint) private _balanceUpdateTime; // Stores the last time TRUTH tokens were purchased for each address

    mapping(address => uint256) private _purchasesSinceLastClaim; // Stores total purchases since holders claimed their last reward
    
    constructor(address devFundAddress, address charityFundAddress) {
        _mint(msg.sender, _totalSupply);
        
        launchBlock = block.number + 67835; // 9.5 days worth of blocks
        antiWhaleBlockDelay = 21421; // 72 hours worth of blocks

        _devFundAddress = devFundAddress;
        _charityAddress = charityFundAddress;
        _lpMaintainer = msg.sender;

        isLiquidityPool[0xC36442b4a4522E871399CD717aBDD847Ab11FE88] = true; // Uniswap V3 NFT Manager
    }

    // Hopefully not needed, can be used to accelerate/delay launch prior to any purchases being made
    function updateLaunchBlocks(uint _launchBlockDelay, uint _antiWhaleBlockDelay) external onlyOwner {

        require(_tokenSupplyEligibleForRewards == 0, "Purchases have already been made, cannot update");

        launchBlock = block.number + _launchBlockDelay;
        antiWhaleBlockDelay = _antiWhaleBlockDelay;
    }

    // Invoked when token holder sends token
    // Penalty amount (if applicable) is added to the amount requested to be transferred
    function transfer(address to, uint256 transferAmount) public override returns (bool) {

        // Allow Uniswap to provide a quote the block prior to launch (required to allow transactions on launch block)
        // Exception for contract owner so that liquidity pool can be created. Ownership will be revoked prior to launch.
        require(msg.sender == owner() || block.number >= launchBlock - 1, "Purchases are not allowed yet."); 
        
        // Checks if tokens are being bought
        if (isLiquidityPool[msg.sender]) {

            //Anti-whale - No buys for more than 1% of supply for the first ~72 hours (based on 12 seconds per block)
            if(transferAmount > (_totalSupply / 100)){
                require(block.number >= (launchBlock + antiWhaleBlockDelay), "Cannot buy more than 1% of total supply at a time yet");    
            }
                        
            // Transfer the original amount minus any penalty amount (if applicable) to the recipient
            _transfer(msg.sender, to, transferAmount);

            // Exempt addresses do not pay penalties, or contribute to total eligible supply
            if(!_isExempt(to)){
                _balanceUpdateTime[to] = block.timestamp; // resets 90 day countdown
                _purchasesSinceLastClaim[to] += transferAmount; // adds to token purchases since last rewards claim
                _tokenSupplyEligibleForRewards += transferAmount; // adds to total token purchases that have not been claimed against
            }
        }
        // Holder is selling or sending tokens
        else {

            // Penalty only applies when sender has not held the token for at least 90 days
            uint penaltyPercent = calculatePenaltyPercentWithMultiplier(msg.sender); // Needs to be divided by MULTIPLIER to get actual percentage
            uint256 penaltyAmount = (((transferAmount * MULTIPLIER * MULTIPLIER) / ((MULTIPLIER * MULTIPLIER) - penaltyPercent)) * penaltyPercent) / MULTIPLIER / MULTIPLIER; // Use of MULTIPLIER for decimal precision for divisor
            uint256 totalAmount = transferAmount + penaltyAmount;

            // Account for rounding errors by reducing penalty by 1 if needed
            if(penaltyAmount > 0 && _balances[msg.sender] < totalAmount){
                penaltyAmount--;
                totalAmount--;
            }

            require(_balances[msg.sender] >= totalAmount, "Insufficient balance, possibly due to penalties");
        
            // Ensure penaltyAmount is never greater than the transfer amount to prevent underflow
            require(penaltyAmount <= transferAmount, "Penalty amount exceeds transfer amount");

            // Transfer the original amount minus any penalty amount (if applicable) to the recipient
            _transfer(msg.sender, to, transferAmount);

            // Exempt addresses do not pay penalties, or contribute to total eligible supply    
            if(!_isExempt(msg.sender)){

                // Apply the penalty, if any
                if (penaltyAmount > 0) {
                    _applyPenalty(msg.sender, penaltyAmount);
                }

                // Selling
                if(isLiquidityPool[to]){
                    // If sending more (incl penalties) than the purchases since their last claim (indicates prior balance), reduce _tokenSupplyEligibleForRewards by the recent purchases only
                    uint256 amountToReduce = totalAmount > _purchasesSinceLastClaim[msg.sender] ? _purchasesSinceLastClaim[msg.sender] : totalAmount;
                    _tokenSupplyEligibleForRewards = _tokenSupplyEligibleForRewards >= amountToReduce ? _tokenSupplyEligibleForRewards - amountToReduce : 0;
                } 
                // Sending to another wallet
                else {
                    _tokenSupplyEligibleForRewards = _tokenSupplyEligibleForRewards - penaltyAmount;
                    _purchasesSinceLastClaim[to] = _purchasesSinceLastClaim[to] + transferAmount;
                }
                
                // Reduce qualifying token purchases when sending tokens
                _purchasesSinceLastClaim[msg.sender] = _purchasesSinceLastClaim[msg.sender] >= totalAmount ? _purchasesSinceLastClaim[msg.sender] - totalAmount : 0;

                // Reset unclaimed rewards if user empties their wallet
                if(_balances[msg.sender] == 0){
                    _purchasesSinceLastClaim[msg.sender] = 0;
                    _balanceUpdateTime[msg.sender] = 0;
                }
            }
        }
        
        return true;
    }

    // Invoked from UniSwap contract after approval to spend token
    // Penalty amount (if applicable) is added to the amount requested to be transferred
    function transferFrom(address from, address to, uint256 transferAmount) public override returns (bool) {

        // Allow Uniswap to provide a quote the block prior to launch (required to allow transactions on launch block)
        // Exception for contract owner so that liquidity pool can be created. Ownership will be revoked prior to launch.
        require(from == owner() || block.number >= launchBlock - 1, "Purchases are not allowed yet.");
        
        // Checks if tokens are being bought
        if (isLiquidityPool[from]) {

            //Anti-whale - No buys for more than 1% of supply for the first ~72 hours (based on 12 seconds per block)
            if(transferAmount > (_totalSupply / 100)){
                require(block.number >= (launchBlock + antiWhaleBlockDelay), "Cannot buy more than 1% of total supply at a time yet");    
            }
            
            // Ensure the sender (DEX like UniSwap) has enough allowance to send the transferAmount
            require(allowance(from, msg.sender) >= transferAmount, "Allowance too low");
                        
            // Transfer the original amount minus any penalty amount (if applicable) to the recipient
            _transfer(from, to, transferAmount);
            
            // Exempt addresses do not pay penalties, or contribute to total eligible supply
            if(!_isExempt(to)){
                _balanceUpdateTime[to] = block.timestamp; // resets 90 day countdown
                _purchasesSinceLastClaim[to] += transferAmount; // adds to token purchases since last rewards claim
                _tokenSupplyEligibleForRewards += transferAmount; // adds to total token purchases that have not been claimed against
            }
                        
            // Adjust the allowance
            uint256 currentAllowance = allowance(from, msg.sender);
            require(currentAllowance >= transferAmount, "Allowance decreased during transfer");
            _approve(from, msg.sender, currentAllowance - transferAmount);
        }
        // Holder (or holder's agent) is selling or sending tokens
        else {

            // Penalty only applies when sender has not held the token for at least 90 days
            uint256 penaltyPercent = calculatePenaltyPercentWithMultiplier(from);
            uint256 penaltyAmount = (((transferAmount * MULTIPLIER * MULTIPLIER) / ((MULTIPLIER * MULTIPLIER) - penaltyPercent)) * penaltyPercent) / MULTIPLIER / MULTIPLIER; // Use of MULTIPLIER for decimal precision for divisor
            uint256 totalAmount = transferAmount + penaltyAmount;

            // Account for rounding errors by reducing penalty by 1 if needed
            if(penaltyAmount > 0 && _balances[from] < totalAmount){
                penaltyAmount--;
                totalAmount--;
            }

            require(_balances[from] >= totalAmount, "Insufficient balance, possibly due to penalties");

            // Ensure the sender has enough allowance to send the totalAmount
            require(allowance(from, msg.sender) >= totalAmount, "Allowance too low");
        
            // Ensure penaltyAmount is never greater than the transfer amount to prevent underflow
            require(penaltyAmount <= transferAmount, "Penalty amount exceeds transfer amount");

            // Transfer the original amount minus any penalty amount (if applicable) to the recipient
            _transfer(from, to, transferAmount);

            // Exempt addresses do not pay penalties, or contribute to total eligible supply    
            if(!_isExempt(from)){

                // Apply the penalty, if any
                if (penaltyAmount > 0) {
                    _applyPenalty(from, penaltyAmount);
                }

                // Selling
                if(isLiquidityPool[to]){
                    // If sending more (incl penalties) than the purchases since their last claim (indicates prior balance), reduce _tokenSupplyEligibleForRewards by the recent purchases only
                    uint256 amountToReduce = totalAmount > _purchasesSinceLastClaim[from] ? _purchasesSinceLastClaim[from] : totalAmount;
                    _tokenSupplyEligibleForRewards = _tokenSupplyEligibleForRewards >= amountToReduce ? _tokenSupplyEligibleForRewards - amountToReduce : 0;
                } 
                // Sending to another wallet
                else {
                    _tokenSupplyEligibleForRewards = _tokenSupplyEligibleForRewards - penaltyAmount;
                    _purchasesSinceLastClaim[to] = _purchasesSinceLastClaim[to] + transferAmount;
                }

                // Reduce qualifying token purchases when sending tokens
                _purchasesSinceLastClaim[from] = _purchasesSinceLastClaim[from] >= totalAmount ? _purchasesSinceLastClaim[from] - totalAmount : 0;

                // Reset unclaimed rewards if user empties their wallet
                if(_balances[from] == 0){
                    _purchasesSinceLastClaim[from] = 0;
                    _balanceUpdateTime[from] = 0;
                }
            }

            // Adjust the allowance
            uint256 currentAllowance = allowance(from, msg.sender);
            require(currentAllowance >= totalAmount, "Allowance decreased during transfer");
            _approve(from, msg.sender, currentAllowance - totalAmount);

        }

        return true;
    }

    // Determine max sendable amount
    function balanceOf(address account) public view virtual override returns (uint256) {
        uint256 totalBalance = _balances[account];
        return totalBalance - ((totalBalance * calculatePenaltyPercentWithMultiplier(account)) / 100 / MULTIPLIER);
    }

    // Determine total balance amount
    function balanceTotalOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    // Calculate the number of days held - gets reset every buy or reward claim
    function numDaysHeld(address account) public view returns (uint256) {
        // If _balanceUpdateTime never set, default to uint245.max
        if(_balanceUpdateTime[account] == 0){
            return type(uint256).max; 
        }

        return (block.timestamp - _balanceUpdateTime[account]) / 86400; // 86400 seconds in a day
    }

    // For increased accuracy there is a multiplier of 100. 
    // IMPORTANT: The return value needs to be divided by MULTIPLIER after any calculations
    function calculatePenaltyPercentWithMultiplier(address account) public view returns (uint) {
        if (_isExempt(account)) {
            return 0; // No penalties for excempt addresses to send tokens
        }
        
        uint256 daysHeld = numDaysHeld(account);

        // Calculate penalty percent based on a gradient
        if (daysHeld < 90) {
            return ((90 - daysHeld) * 50 * MULTIPLIER) / (90); // Max 50% penalty for 0 days of holding
        } else {
            return 0; // No penalty for 90 or more days of holding
        }
    }

    // Internal function that distributes 10% of the burn amount to the devFund address, destroys the remainder
    function _applyPenalty(address fromAccount, uint256 totalPenaltyAmount) internal {
        uint256 rewardsAmount = (totalPenaltyAmount * 45) / 100; // 45% 
        uint256 burnAmount = (totalPenaltyAmount * 30) / 100; // 30% 
        uint256 charityAmount = (totalPenaltyAmount * 15) / 100; // 15% 
        uint256 devFundAmount = totalPenaltyAmount - (rewardsAmount + burnAmount + charityAmount); // Remaining 10% to devFund address
        
        // Remove 30% of penalty amount from circulating supply
        _burn(fromAccount, burnAmount);
        _totalBurned += burnAmount;

        // Contract hold 45% of penalty amount for token holders to claim as rewards
        _transfer(fromAccount, address(this), rewardsAmount);

        // charity address gets 15% of penalty amount
        _transfer(fromAccount, _charityAddress, charityAmount);

        // devFund address gets 10% of penalty amount
        _transfer(fromAccount, _devFundAddress, devFundAmount);
    }

    function availableRewards(address account) public view returns (uint256) {

        require(!_isExempt(account), "Exempt addresses cannot claim rewards");

        return _tokenSupplyEligibleForRewards == 0 ? 0 : (_purchasesSinceLastClaim[account] * _balances[address(this)] ) / _tokenSupplyEligibleForRewards;
    }

    // Transfers rewards from the contract's pool to the token holder
    function claimRewards() external {

        uint256 claimableRewards = availableRewards(msg.sender);
        require(claimableRewards > 0, "No rewards available for this address");

        // This contract transfers rewards to caller, and resets their 90 day countdown
        _transfer(address(this), msg.sender, claimableRewards); 

        // Reset 90 day countdown
        _balanceUpdateTime[msg.sender] = block.timestamp;

        // Reduce the count of tokens that have not been claimed against
        _tokenSupplyEligibleForRewards -= _purchasesSinceLastClaim[msg.sender];
        
        // Reset the count of tokens that make one eligible to claim rewards
        _purchasesSinceLastClaim[msg.sender] = 0;
    }

    // LP owner, charity, dev fund, and liquidity pool accounts are exempt from penalties, but cannot claim rewards
    function _isExempt(address account) internal view returns (bool) {
        return account == _lpMaintainer || account == _devFundAddress || account == _charityAddress || isLiquidityPool[account];
    }

    function devAddress() external view returns (address) {
        return _devFundAddress; 
    }

    function charityAddress() external view returns (address) {
        return _charityAddress; 
    }

    function totalBurned() external view returns (uint256) {
        return _totalBurned;
    }

    function rewardsPoolBalance() external view returns (uint256) {
        return _balances[address(this)];
    }

    function balanceEligibleForRewards(address account) external view returns (uint256) {
        return _purchasesSinceLastClaim[account]; 
    }

    function supplyEligibleForRewards() external view returns (uint256) {
        return _tokenSupplyEligibleForRewards; 
    }

    function blocksTillLaunch() external view returns (uint) {
        return launchBlock < block.number ? 0 : (launchBlock - block.number); 
    }

    modifier lpMaintainer() {
        require(msg.sender == _lpMaintainer, "Not authorized");
        _;
    }

    function addLiquidityPool(address lpAddress) external lpMaintainer {
        require(!isLiquidityPool[lpAddress], "Address is already added as LP");
        isLiquidityPool[lpAddress] = true;
    }

    function removeLiquidityPool(address lpAddress) external lpMaintainer {
        require(isLiquidityPool[lpAddress], "Address is not an LP");
        isLiquidityPool[lpAddress] = false;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)

pragma solidity 0.8.21;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}