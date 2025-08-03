// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

/*
website: https://pepesumo.com
tg: https://t.me/pepesumotoken
x: https://x.com/pepesumotoken
*/


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
    function deposit() external payable;
}

contract PepeSUMO is IERC20 {
    mapping (address => uint256) private _balances;
    mapping (address => uint256) public lastFaucetClaim;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public swap;
    address private _taxWallet;
    address public donateLocation;
    address private univ2;
    uint256 public faucet;
    uint256 public faucetTotalOut;
    uint256 public _initialBuyTax = 10;
    uint256 public _initialSellTax = 10;
    uint256 public _finalBuyTax = 0;
    uint256 public _finalSellTax = 1;
    uint256 private _reduceBuyTaxAt = 30;
    uint256 private _reduceSellTaxAt = 30;
    uint256 private _delayTaxSwapBefore = 15;
    uint256 public _buyCount = 0;
    uint256 public _sellCount = 0;
    uint256 public donationShare = 3;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000000 * 10**_decimals;  
    string private constant _name = 'PepeSumo';
    string private constant _symbol = 'PSUMO';
    uint256 private _taxSwapThreshold = 10000000  * 10**_decimals;
    address public _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool public tradingOpen;
    bool private swapCreated;
    bool private inSwap;
    bool public taxOn;
    bool public faucetOn;
    uint256 private taxSellCount = 0;
    uint256 public lastSellBlock = 0;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    receive() external payable {}

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
        _taxWallet = msg.sender;
        faucetOn = true;
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);  
        donateLocation = 0xB803C271b6c94D71A759173ed580a23De939db20;
        _balances[msg.sender] = _tTotal;
        emit Transfer(address(0), msg.sender, _tTotal);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner_, address spender) public view override returns (uint256) {
        return _allowances[owner_][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        require(_allowances[sender][msg.sender] >= amount, "under allowance");
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function _approve(address owner_, address spender, uint256 amount) private {
        require(owner_ != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }

    function maxTaxSwap() public view returns(uint256 max) {
        max = balanceOf(uniswapV2Pair) * 1 / 1000;
    }

    function isSwap(address addy) public view returns(bool isswap) {
        isswap = swap[addy];
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(to != from, "!Same address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;
        if(!tradingOpen) {
        require(from == _owner || to == _owner, "trading not open");
        }
        
        if(tradingOpen) {
        if(isSwap(from)) {
        if(_buyCount >= _reduceBuyTaxAt) {
            taxAmount = amount * _finalBuyTax / 100;
        }
        if(_buyCount < _reduceBuyTaxAt) {
            taxAmount = amount * _initialBuyTax / 100;
        }
            _buyCount += 1;
        }

        if(isSwap(to) && from != address(this)) {
        if(_sellCount >= _reduceSellTaxAt) {
            bool t = to == uniswapV2Pair || to == univ2 ? true : false;
            taxAmount = t ? amount * _finalSellTax / 100 : 0;
        }
        if(_sellCount < _reduceSellTaxAt) {
            taxAmount = amount * _initialSellTax / 100;
        }
            _sellCount += 1;
        }

        if(taxOn) {
        uint256 contractTokenBalance = balanceOf(address(this)) - faucet;
        if(!inSwap && isSwap(to) && swapCreated && contractTokenBalance > _taxSwapThreshold && _sellCount >= _delayTaxSwapBefore) {
            taxConversion(amount, contractTokenBalance);
        }
        }
        }

        if(taxAmount > 0) {
            if(faucetOn) {
            faucet += taxAmount * 3 / 1000;
            }
            _balances[address(this)] += taxAmount;
            emit Transfer(from, address(this), taxAmount);            
        }

        _balances[from] -= amount;
        uint256 aft = amount - taxAmount;
        _balances[to] += aft;
        emit Transfer(from, to, aft);
    }

    function taxConversion(uint256 amount, uint256 contractTokenBalance) private {
        if(block.number > lastSellBlock) {
            taxSellCount = 0;
        }
        if(taxSellCount < 3) { // 2 max per block
            uint256 tot = min(amount, min(contractTokenBalance, maxTaxSwap()));
            uint256 out = amount == tot ? amount / 4 : tot;
            swapTokensForEth(out);
            uint256 contractETHBalance = address(this).balance;
        if(contractETHBalance > 2e15) {
            sendETHToFee(address(this).balance);
        }
            taxSellCount += 1;
            lastSellBlock = block.number;
        }
    }

    function claimFaucet() external returns(uint256 amount) {
        require(balanceOf(address(this)) >= faucet, "bal<faucet");
        require(block.timestamp > lastFaucetClaim[msg.sender] + 7 days, "1 per 7 days");
        require(faucetOn, "!faucetOn");
        amount = faucet;
        faucet = 0;
        faucetTotalOut += amount;
        _balances[address(this)] -= amount;
        _balances[msg.sender] += amount;
        lastFaucetClaim[msg.sender] = block.timestamp;
        emit Transfer(address(this), msg.sender, amount);
    }

    function addSwap(address addy) external {
        require(msg.sender == _taxWallet, "!_taxWallet");
        swap[addy] = true;
    }

    function addUniV2(address addy) external onlyOwner {
        require(univ2 == address(0), "already set");
        univ2 = addy;
        swap[addy] = true;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a > b) ? b : a;
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
        if(donationShare > 0) {
        uint256 donateShare = amount * donationShare / 100;
        address weth = uniswapV2Router.WETH();
        IUniswapV2Router02(weth).deposit{value:donateShare}();
        IERC20(weth).transfer(donateLocation, donateShare);
        }
        (bool success,) = _taxWallet.call{value : address(this).balance}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }

    function adduniv2pair(address addy) external onlyOwner {
        require(!swapCreated,"trading is already open");
        uniswapV2Pair = addy;
        swapCreated = true;
        swap[uniswapV2Pair] = true;
    }

    function setDonationShare(uint256 amount) external {
        require(msg.sender == _taxWallet, "!_taxWallet");
        require(amount <= 10, "<10");
        donationShare = amount;
    }

    function setFaucetOn(bool _bool) external {
        require(msg.sender == _taxWallet, "!_taxWallet");
        faucetOn = _bool;
    }

    function openDex() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        tradingOpen = true;
        taxOn = true;
    }

    function SumoSwap() external {
        require(msg.sender == _taxWallet, "!_taxWallet");
        uint256 bal = balanceOf(address(this)) - faucet;
        uint256 mts = maxTaxSwap();
        uint256 tokenBalance = bal > mts ? mts : bal;
        if(tokenBalance > 0 && tradingOpen){
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0){
            sendETHToFee(ethBalance);
        }
    }

    function setWallet(address addy) external {
        require(msg.sender == _taxWallet, "!_taxWallet");
        require(addy != address(0), "zero address");
        _taxWallet = addy;
    }

    function setTaxOn(bool _bool) external {
        require(msg.sender == _taxWallet, "!_taxWallet");
        taxOn = _bool;
    }

    function saveETH() external {
        require(msg.sender == _taxWallet, "!_taxWallet");
        (bool success,) = _taxWallet.call{value : address(this).balance}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }

    function setDonateLocation(address addy) external {
        require(msg.sender == _taxWallet, "!_taxWallet");
        require(addy != address(0), "zero address");
        donateLocation = addy;
    }
}