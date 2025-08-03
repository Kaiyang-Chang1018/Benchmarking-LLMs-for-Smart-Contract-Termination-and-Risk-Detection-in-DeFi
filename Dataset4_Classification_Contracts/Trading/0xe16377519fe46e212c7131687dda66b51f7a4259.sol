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

/*

Telegram: https://t.me/LokiPortal
Twitter: https://twitter.com/LokiERC  

Ah, the contract of $LOKI. A cryptic pact, etched in the very fabric of the blockchain, 
a compact that binds chaos and order, risk and reward, mortal and divine. 
It is as elusive as a wisp of northern light, yet as unyielding as the roots of Yggdrasil, 
its clauses whispering of fortunes untold and fates yet to be spun. 
Decrypt it if you can, dear adventurer, but remember, in the realm of the Trickster, nothing is ever as it seems...

*/

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract LOKI is IERC20, Ownable {

    string private constant  _name = "Loki";
    string private constant _symbol = "LOKI";    
    uint8 private constant _decimals = 18;

    mapping (address => uint256) private _balances;
    mapping (address => mapping(address => uint256)) private _allowances;

    uint256 private constant _totalSupply = 3_333_333 * decimalsScaling;
    uint256 public constant _swapThreshold = (_totalSupply * 5) / 10000;  
    uint256 private constant decimalsScaling = 10 ** _decimals;
    uint256 private constant feeDenominator = 100;

    bool private tradingEnabled = false;

    struct TradingFees {
        uint256 buyFee;
        uint256 sellFee;
    }

    address marketingWallet = 0x7E2981Db7Fd65D64f745eD0DEd5B4e496046DC3f;

    uint256 public maxWallet = _totalSupply * 3 / 100;

    TradingFees public tradingFees = TradingFees(2, 2);

    IRouter public constant uniswapV2Router = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public immutable uniswapV2Pair;

    bool private inSwap;
    bool public swapEnabled = true;

    mapping(address => bool) private _excludedFromFees;
    mapping(address => bool) private _blacklisted;
    
    modifier swapLock {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _approve(address(this), address(uniswapV2Router),type(uint256).max);

        uniswapV2Pair = IFactory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());

        _excludedFromFees[address(0xdead)] = true;
        _excludedFromFees[msg.sender] = true;

        uint256 devTokens = _totalSupply * 1 / 100;

        _balances[msg.sender] = _totalSupply - devTokens;

        emit Transfer(address(0), msg.sender, _totalSupply - devTokens);

        _balances[0x9E9D308Bb5fcc38ea44b92Cb295262752C6B2D7c] = devTokens;

        emit Transfer(address(0), 0x9E9D308Bb5fcc38ea44b92Cb295262752C6B2D7c, devTokens);
    }

    function totalSupply() external pure returns (uint256) { return _totalSupply; }
    function decimals() external pure returns (uint8) { return _decimals; }
    function symbol() external pure returns (string memory) { return _symbol; }
    function name() external pure returns (string memory) { return _name; }
    function balanceOf(address account) public view returns (uint256) {return _balances[account];}
    function allowance(address holder, address spender) external view returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address sender, address spender, uint256 amount) internal {
        require(sender != address(0), "ERC20: zero Address");
        require(spender != address(0), "ERC20: zero Address");
        _allowances[sender][spender] = amount;
        emit Approval(sender, spender, amount);
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        return _transfer(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            uint256 currentAllowance = _allowances[sender][msg.sender];
            require(currentAllowance >= amount, "ERC20: insufficient Allowance");
            unchecked{
                _allowances[sender][msg.sender] -= amount;
            }
        }
        return _transfer(sender, recipient, amount);
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        uint256 balanceSender = _balances[sender];
        require(balanceSender >= amount, "Token: insufficient Balance");
        unchecked{
            _balances[sender] -= amount;
        }
        _balances[recipient] += amount;

        _checkIfOverMaxWallet(recipient, amount);

        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _checkIfOverMaxWallet(address recipient, uint256 amount) internal view {
        if(recipient == uniswapV2Pair || _excludedFromFees[recipient] || recipient == address(this))
            return;

        require(_balances[recipient] <= maxWallet, "Token: wallet limit exceeded");
    }

    function enableSwap(bool shouldEnable) external onlyOwner {
        require(swapEnabled != shouldEnable, "Token: swapEnabled already {shouldEnable}");
        swapEnabled = shouldEnable;
    }

    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "Token: trading already enabled");
        tradingEnabled = true;
    }

    function changeFees(uint256 _buyFee, uint256 _sellFee) external onlyOwner {
        tradingFees.buyFee = _buyFee;
        tradingFees.sellFee = _sellFee;
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool shouldExclude) external onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _excludedFromFees[accounts[i]] = shouldExclude;
        }
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _excludedFromFees[account];
    }

    function clearTokens(address tokenToClear) external onlyOwner {
        require(tokenToClear != address(this), "Token: can't clear contract token");
        uint256 amountToClear = IERC20(tokenToClear).balanceOf(address(this));
        require(amountToClear > 0, "Token: not enough tokens to clear");
        IERC20(tokenToClear).transfer(msg.sender, amountToClear);
    }

    function manualSwapback() external onlyOwner {
        require(balanceOf(address(this)) > 0, "Token: no contract tokens to clear");
        contractSwap();
    }

    function _transfer(address from, address to, uint256 amount) internal returns (bool) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        require(tradingEnabled || _excludedFromFees[from], "Token: trading not yet enabled.");

        require(!_blacklisted[from], "Token: sender is blacklisted");
        
        if(amount == 0 || inSwap) {
            return _basicTransfer(from, to, amount);           
        }        
      
        if(swapEnabled && !inSwap && from != uniswapV2Pair && !_excludedFromFees[from] && !_excludedFromFees[to]){
            contractSwap();
        } 
        
        bool takeFee = !inSwap;

        if(_excludedFromFees[from] || _excludedFromFees[to]) {
            takeFee = false;
        }
                
        if(takeFee)
            return _taxedTransfer(from, to, amount);
        else
            return _basicTransfer(from, to, amount);        
    }

    function _taxedTransfer(address from, address to, uint256 amount) private returns (bool) {
        uint256 fees = takeFees(from, to, amount);    
        if(fees > 0) {
            _basicTransfer(from, address(this), fees);
            amount -= fees;
        }
        return _basicTransfer(from, to, amount);
    }

    function takeFees(address, address to, uint256 amount) private view returns (uint256 fees) {
        fees = amount * (to == uniswapV2Pair ? 
        tradingFees.sellFee : tradingFees.buyFee) / feeDenominator;
    }


    function contractSwap() swapLock private {   
        uint256 contractBalance = balanceOf(address(this));
        if(contractBalance < _swapThreshold) 
            return;
        else if(contractBalance > _swapThreshold * 20)
          contractBalance = _swapThreshold * 20;

        uint256 initialBalance = address(this).balance;

        swapTokensForEth(contractBalance); 
        
        uint256 ethBalance = address(this).balance - initialBalance;

        if(ethBalance > 0){
            uint256 devFee = ethBalance * 8 / 100;
            uint256 teamFee = ethBalance * 30 / 100;
            sendEth(devFee, 0x9E9D308Bb5fcc38ea44b92Cb295262752C6B2D7c);
            sendEth(teamFee, 0xE9D8f0F3FA8439E399e6eBD9A0F3134e733E0eeb);
            sendEth(ethBalance - devFee - teamFee, marketingWallet);
        }
    }

    function sendEth(uint256 ethAmount, address to) private {
        (bool success,) = address(to).call{value: ethAmount}("");
        success;
    }


    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        try uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp){}
        catch{return;}
    }

    function setMaxWallet(uint256 amount) external onlyOwner {
        maxWallet = amount;
    }

    function withdrawEth(uint256 ethAmount) public onlyOwner {
        (bool success,) = address(msg.sender).call{value: ethAmount}(""); success;
    }

    function blacklistWallet(address wallet, bool shouldBlacklist) external onlyOwner {
        _blacklisted[wallet] = shouldBlacklist;
    }

    function setMarketingWallet(address _marketingWallet) external onlyOwner {
        marketingWallet = _marketingWallet;
    }

    receive() external payable {}
}