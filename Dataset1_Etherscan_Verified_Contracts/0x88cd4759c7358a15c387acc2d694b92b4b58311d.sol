//SPDX-License-Identifier: MIT

/*

    Xenon AGI, a visionary project at the forefront of Artificial General Intelligence (AGI) and innovative GPU technologies, combines reliability with innovation to enhance GPU-digital interactions through cutting-edge protocols. Our goal is to elevate user experiences by offering unparalleled efficiency, scalability, and security through Xenon's revolutionary protocol, transforming GPU performance in rendering, mining, and deep learning applications.

    telegram: https://t.me/XenonAGI
    twitter: https://x.com/XenonAGI
    website: https://xenon-agi.tech

    Try DAPP: https://app.xenon-agi.tech/
    Read more in our whitepaper: https://docs.xenon-agi.tech/
    Github: https://github.com/XenonAGI
        
    ██╗░░██╗░█████╗░░██████╗░██╗
    ╚██╗██╔╝██╔══██╗██╔════╝░██║
    ░╚███╔╝░███████║██║░░██╗░██║
    ░██╔██╗░██╔══██║██║░░╚██╗██║
    ██╔╝╚██╗██║░░██║╚██████╔╝██║
    ╚═╝░░╚═╝╚═╝░░╚═╝░╚═════╝░╚═╝
    
*/
pragma solidity 0.8.27;

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

contract XAGI is Context, IERC20, Ownable {
    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 1_000_000_000 * 10 ** _decimals;
    string private constant _name = unicode"Xenon AGI";
    string private constant _symbol = unicode"XAGI";
    uint256 public _buyFees = 20;
    uint256 public _sellFees = 20;
    mapping (address => bool) private _excludedFromFee;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;
    uint256 private _swapTokensAtAmount = _tTotal / 1000;
    uint256 private _maxTaxSwap = _tTotal / 100;
    bool private inSwap;
    IUniswapV2Router02 uniswapV2Router;
    address uniswapV2Pair;
    uint256 public _maxWallet = _tTotal * 20 / 1000;
    address payable public _taxWallet;
    bool public tradingOpen;
    bool private swapEnabled = true;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor() {
        _taxWallet = payable(msg.sender);
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _excludedFromFee[address(uniswapV2Router)] = true;
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _excludedFromFee[address(this)] = true;
        _excludedFromFee[owner()] = true;
        _balances[owner()] = _tTotal;
        emit Transfer(address(0), msg.sender, _tTotal);
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - (amount));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(to != address(0));
        uint256 taxAmount=0;
        if (_excludedFromFee[from] == false && !_excludedFromFee[to]) {
            require(tradingOpen == true, "XAGI: Trade isn't open!");

            taxAmount = amount * _buyFees / 100;

            if (to != uniswapV2Pair) {
                require(balanceOf(to) + amount <= _maxWallet, "XAGI: Max wallet!");
            }

            if(to == uniswapV2Pair){
                taxAmount = amount * _sellFees / 100;
                require(_maxWallet < _tTotal);
            }

            if (from == uniswapV2Pair) {
                require(balanceOf(to) + amount <= _maxWallet);
            }

            uint256 contractBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled && contractBalance>_swapTokensAtAmount) {
                swapTokensForEth(min(amount,min(contractBalance,_maxTaxSwap)));
            }
        }

        if(taxAmount > 0){
          _balances[address(this)] += (taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from] -= amount;
        _balances[to] += amount - taxAmount;
        emit Transfer(from, to, amount - (taxAmount));
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
            _taxWallet,
            block.timestamp
        );
    }

    function updateMaxWalletSize(uint amount) external onlyOwner {
        require(amount >= _tTotal / 500);
        _maxWallet = amount;
    }

    function openTrading() external onlyOwner {
        tradingOpen = true;
    }

    function excludeFromFees(address account, bool status) external onlyOwner {
        _excludedFromFee[account] = status;
    }

    function setNormalFees() external onlyOwner {
        _buyFees = 5;
        _sellFees = 5;
    }

    function setFees(uint newBuyFee, uint newSellFee) external onlyOwner {
        _buyFees = newBuyFee;
        _sellFees  = newSellFee;
        require(newBuyFee <= 25, "Too high!");
        require(newSellFee <= 25, "Too high!");
    }

    receive() external payable {}
}