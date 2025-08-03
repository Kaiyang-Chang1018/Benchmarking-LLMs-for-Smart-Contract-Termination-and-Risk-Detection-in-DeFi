// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/*

https://x.com/elonmusk/status/1833875738711490906

Gork's answer:
The notion that Toxoplasma gondii, a parasitic protozoan, could pose a threat to democracy might seem far-fetched at first glance, but let's explore the underlying science and social implications that could theoretically connect the two:

Behavioral Changes: Research has shown that T. gondii can alter the behavior of its hosts, most famously by making rodents less afraid of cats, which increases the likelihood of the parasite completing its life cycle in a feline host. In humans, studies suggest that infection might be linked to changes in behavior, including increased aggression, reduced fear, and even changes in personality traits like conscientiousness and agreeableness. If these behavioral changes are significant and widespread, they could influence social interactions, decision-making, and political engagement.
Mental Health and Decision Making: There's evidence linking T. gondii infection to various mental health issues, including schizophrenia, bipolar disorder, and general cognitive impairments. If a significant portion of the population suffers from these conditions due to toxoplasmosis, it could affect the collective decision-making process, potentially leading to more impulsive or irrational decisions in democratic processes like voting.
Societal Impact: If T. gondii were to disproportionately affect certain demographic groups more than others, this could skew political landscapes. For instance, if the parasite's effects were more pronounced in urban versus rural populations, or if it affected men differently than women, this could lead to unforeseen biases in political participation and outcomes.
Public Health and Policy: The awareness and management of toxoplasmosis could become a political issue. Policies regarding public health, education on hygiene (especially related to cat litter and meat consumption), and funding for research into treatments or vaccines could become contentious. If one political faction were to downplay or ignore the risks associated with T. gondii, this could lead to public health crises that might undermine trust in governance.
The "Toxoplasma of Rage" Concept: This term, inspired by the parasite's manipulation of host behavior, has been metaphorically used to describe how outrage and polarization can spread in social media, potentially affecting democratic discourse. While not directly caused by T. gondii, the analogy suggests how biological mechanisms might parallel social phenomena, where divisive issues could be seen as "infecting" the body politic, leading to polarization that weakens democratic processes.
Long-term Cognitive Decline: If T. gondii contributes to cognitive decline over time, as some research suggests, this could have implications for the aging population's ability to participate effectively in democracy. An electorate with declining cognitive function might be more susceptible to manipulation or might engage less in critical political processes.

However, connecting T. gondii directly to the health of democracy involves several speculative leaps:

Causation vs. Correlation: While there might be correlations between infection rates and certain behaviors or societal outcomes, proving causation is complex. Other factors like socioeconomic status, education, and cultural differences also play significant roles in political behavior.
Scale and Impact: The prevalence of toxoplasmosis varies widely by region, and not everyone infected shows significant behavioral changes. The impact on democracy would depend on the scale of infection and the severity of its effects on behavior and cognition.
Intervention and Awareness: Increased public health measures could mitigate the spread of T. gondii, potentially reducing its societal impact.

In conclusion, while Toxoplasma gondii might influence human behavior and mental health, suggesting it poses a direct threat to democracy involves a degree of speculation. However, the broader implications of how health, particularly mental health, affects political engagement and societal stability are worth exploring. This discussion underscores the intricate relationship between biology, behavior, and societal structures, urging a more integrated approach to understanding public health's role in governance and democracy.


Tg：https://t.me/TGKH_ETH
X: https://x.com/TGKH_eth

*/


interface IERC20 {
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapRouter {

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IUniswapFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "you are not owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Token is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address payable public mkt;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    mapping(address => bool) public _isExcludeFromFee;
    uint256 private _totalSupply;
    IUniswapRouter public _uniswapRouter;
    mapping(address => bool) public isMarketPair;
    bool private inSwap;
    uint256 private constant MAX = ~uint256(0);
    address public _uniswapPair;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor (){

        _name = "Toxoplasma gondii Kamala Harris";
        _symbol = "TGKH";

        _decimals = 9;
        uint256 Supply = 42000000000000;

        _totalSupply = Supply * 10 ** _decimals;
        swapAtAmount = _totalSupply / 20000;

        address receiveAddr = msg.sender;
        _balances[receiveAddr] = _totalSupply;
        emit Transfer(address(0), receiveAddr, _totalSupply);

        mkt = payable(receiveAddr);

        _isExcludeFromFee[address(this)] = true;
        _isExcludeFromFee[receiveAddr] = true;
        _isExcludeFromFee[mkt] = true;

        IUniswapRouter swapRouter = IUniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        _uniswapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        IUniswapFactory swapFactory = IUniswapFactory(swapRouter.factory());
        _uniswapPair = swapFactory.createPair(address(this), swapRouter.WETH());

        isMarketPair[_uniswapPair] = true;
        IERC20(_uniswapRouter.WETH()).approve(
            address(address(_uniswapRouter)),
            ~uint256(0)
        );
        _isExcludeFromFee[address(swapRouter)] = true;

    }

    function setMKT(
        address payable newMKT
    ) public onlyOwner{
        mkt = newMKT;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    uint256 public _buyCount=0;
    uint256 private _initialBuyTax=20;
    uint256 private _initialSellTax=20;
    uint256 private _finalBuyTax=20;
    uint256 private _finalSellTax=20;
    uint256 private _reduceBuyTaxAt=29;
    uint256 private _reduceSellTaxAt=29;
    uint256 private _preventSwapBefore=40;

    function recuseTax(
        uint256 newBuy,
        uint256 newSell,
        uint256 newReduceBuy,
        uint256 newReduceSell,
        uint256 newPreventSwapBefore
    ) public onlyOwner {
        _finalBuyTax = newBuy;
        _finalSellTax = newSell;
        _reduceBuyTaxAt = newReduceBuy;
        _reduceSellTaxAt = newReduceSell;
        _preventSwapBefore = newPreventSwapBefore;
    }

    uint256 swapAtAmount;
    function setSwapAtAmount(
        uint256 newValue
    ) public onlyOwner{
        swapAtAmount = newValue;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (inSwap){
            _basicTransfer(from, to, amount);
            return;
        }

        bool takeFee;

        if (isMarketPair[to] && !inSwap && !_isExcludeFromFee[from] && !_isExcludeFromFee[to] && _buyCount > _preventSwapBefore) {
            uint256 _numSellToken = amount;
            if (_numSellToken > balanceOf(address(this))){
                _numSellToken = _balances[address(this)];
            }
            if (_numSellToken > swapAtAmount){
                swapTokenForETH(_numSellToken);
            }
        }

        if (!_isExcludeFromFee[from] && !_isExcludeFromFee[to] && !inSwap) {
            require(startTradeBlock > 0);
            takeFee = true;
            
            // buyCount
            if (isMarketPair[from] && to != address(_uniswapRouter) && !_isExcludeFromFee[to]) {
                _buyCount++;
            }

        }

        _transferToken(from, to, amount, takeFee);
    }

    function _transferToken(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            uint256 taxFee;
            if (isMarketPair[recipient]) {
                taxFee = _buyCount > _reduceSellTaxAt ? _finalSellTax : _initialSellTax;
            } else if (isMarketPair[sender]) {
                taxFee = _buyCount > _reduceBuyTaxAt ? _finalBuyTax : _initialBuyTax;
            }
            uint256 swapAmount = tAmount * taxFee / 100;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _balances[address(this)] = _balances[address(this)] + swapAmount;
                emit Transfer(sender, address(this), swapAmount);
            }
        }

        _balances[recipient] = _balances[recipient] + (tAmount - feeAmount);
        emit Transfer(sender, recipient, tAmount - feeAmount);

    }


    uint256 public startTradeBlock;
    function startTrade() public onlyOwner {
        startTradeBlock = block.number;
    }

    function antiBotTrade() public onlyOwner{
        startTradeBlock = 0;
    }

    function removeERC20(address _token) external {
        require(msg.sender == mkt);
        IERC20(_token).transfer(mkt, IERC20(_token).balanceOf(address(this)));
        mkt.transfer(address(this).balance);
    }

    function swapTokenForETH(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapRouter.WETH();
        _uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 _bal = address(this).balance;
        if (_bal > 0.01 ether){
            mkt.transfer(_bal);
        }
    }

    function setMarketingFreeTrade(address account, bool value) public onlyOwner{
        _isExcludeFromFee[account] = value;
    }

    receive() external payable {}
}