/**
* Telegram: https://t.me/Feedtokenerc
*/

// SPDX-License-Identifier: NOLICENSE


pragma solidity ^0.8.10;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IFactory{
        function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IRouter {
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;
}

contract $FEED is Context, IERC20, Ownable {

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    mapping (address => bool) private _isBot;

    address[] private _excluded;

    bool public swapEnabled = true;
    bool private swapping;

    IRouter public router;
    address public pair;

    uint8 private constant _decimals = 18;
    uint256 private constant MAX = ~uint256(0);

    uint256 private _tTotal = 10000000 * 10**_decimals;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));

    
    uint256 public swapTokensAtAmount = 20000 * 10**_decimals;
    
    uint256 public maxSellAmount = 100000 * 10**_decimals;
    uint256 public maxBuyAmount = 100000 * 10**_decimals;
    uint256 public maxWalletBalance = 100000 * 10**_decimals;

    address public sponsorAddress = 0x6EB3AE4DC94C23353017BECA71dFf7877d23C719;
    address public marketingAddress = 0xa42b4A0cB0E69ffDE733035D76bfBB3cD3540646;
    address public wsdappsAddress = 0x3D191EBe224907cb7f4b8eb6F1dE9ba9F0E98925;

    string private constant _name = "Cereal";
    string private constant _symbol = "$FEED";


    struct Taxes {
      uint256 rfi;
      uint256 marketing;
      uint256 sponsor;
      uint256 liquidity;
      uint256 wsdapps;
    }

    Taxes public taxes = Taxes(10,5,20,10,5);
    Taxes public sellTaxes = Taxes(10,105,20,10,5);

    struct TotFeesPaidStruct{
        uint256 rfi;
        uint256 sponsor;
        uint256 marketing;
        uint256 liquidity;
        uint256 wsdapps;
    }
    TotFeesPaidStruct public totFeesPaid;

    struct valuesFromGetValues{
      uint256 rAmount;
      uint256 rTransferAmount;
      uint256 rRfi;
      uint256 rsponsor;
      uint256 rmarketing;
      uint256 rLiquidity;
      uint256 rwsdapps;
      uint256 tTransferAmount;
      uint256 tRfi;
      uint256 tsponsor;
      uint256 tmarketing;
      uint256 tLiquidity;
      uint256 twsdapps;
    }

    event FeesChanged();

    modifier lockTheSwap {
        swapping = true;
        _;
        swapping = false;
    }

    constructor () {
        IRouter _router = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address _pair = IFactory(_router.factory())
            .createPair(address(this), _router.WETH());

        router = _router;
        pair = _pair;
        
        excludeFromReward(pair);

        _rOwned[owner()] = _rTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[sponsorAddress]=true;
        _isExcludedFromFee[marketingAddress] = true;
        _isExcludedFromFee[wsdappsAddress] = true;

        emit Transfer(address(0), owner(), _tTotal);
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

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferRfi, bool isSell) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferRfi) {
            valuesFromGetValues memory s = _getValues(tAmount, false, isSell);
            return s.rAmount;
        } else {
            valuesFromGetValues memory s = _getValues(tAmount, true, isSell);
            return s.rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount/currentRate;
    }

    function excludeFromReward(address account) public onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function excludeFromFee(address account, bool isExcluded) public onlyOwner {
        _isExcludedFromFee[account] = isExcluded;
    }


    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
    
    function setSellTaxes() public onlyOwner {
        sellTaxes.rfi = 10;
        sellTaxes.sponsor = 20;
        sellTaxes.marketing = 5;
        sellTaxes.liquidity = 10;
        sellTaxes.wsdapps = 5;
    }

    function _reflectRfi(uint256 rRfi, uint256 tRfi) private {
        _rTotal -=rRfi;
        totFeesPaid.rfi +=tRfi;
    }

    function _takeLiquidity(uint256 rLiquidity, uint256 tLiquidity) private {
        totFeesPaid.liquidity +=tLiquidity;

        if(_isExcluded[address(this)])
        {
            _tOwned[address(this)]+=tLiquidity;
        }
        _rOwned[address(this)] +=rLiquidity;
    }

    function _takesponsor(uint256 rsponsor, uint256 tsponsor) private {
        totFeesPaid.sponsor +=tsponsor;

        if(_isExcluded[address(this)])
        {
            _tOwned[address(this)]+=tsponsor;
        }
        _rOwned[address(this)] +=rsponsor;
    }
    
    function _takemarketing(uint256 rmarketing, uint256 tmarketing) private {
        totFeesPaid.marketing += tmarketing;

        if(_isExcluded[address(this)])
        {
            _tOwned[address(this)]+= tmarketing;
        }
        _rOwned[address(this)] += rmarketing;
    }

    function _takewsdapps(uint256 rwsdapps, uint256 twsdapps) private {
        totFeesPaid.marketing += twsdapps;

        if(_isExcluded[address(this)])
        {
            _tOwned[address(this)]+= twsdapps;
        }
        _rOwned[address(this)] += rwsdapps;
    }

    function _getValues(uint256 tAmount, bool takeFee, bool isSell) private view returns (valuesFromGetValues memory to_return) {
        to_return = _getTValues(tAmount, takeFee, isSell);
        (to_return.rAmount, to_return.rTransferAmount, to_return.rRfi, to_return.rsponsor, to_return.rmarketing, to_return.rLiquidity, to_return.rwsdapps) = _getRValues(to_return, tAmount, takeFee, _getRate());
        return to_return;
    }

    function _getTValues(uint256 tAmount, bool takeFee, bool isSell) private view returns (valuesFromGetValues memory s) {

        if(!takeFee) {
          s.tTransferAmount = tAmount;
          return s;
        }
        Taxes memory temp;
        if(isSell) temp = sellTaxes;
        else temp = taxes;
        
        s.tRfi = tAmount*temp.rfi/1000;
        s.tsponsor = tAmount*temp.sponsor/1000;
        s.tLiquidity = tAmount*temp.liquidity/1000;
        s.tmarketing = tAmount*temp.marketing/1000;
        s.twsdapps = tAmount*temp.wsdapps/1000;
        s.tTransferAmount = tAmount-s.tRfi-s.tsponsor-s.tmarketing-s.twsdapps-s.tLiquidity;
        return s;
    }

    function _getRValues(valuesFromGetValues memory s, uint256 tAmount, bool takeFee, uint256 currentRate) private pure returns (uint256 rAmount, uint256 rTransferAmount, uint256 rRfi,uint256 rsponsor, uint256 rmarketing, uint256 rwsdapps, uint256 rLiquidity) {
        rAmount = tAmount*currentRate;

        if(!takeFee) {
          return(rAmount, rAmount, 0,0,0,0,0);
        }

        rRfi = s.tRfi*currentRate;
        rsponsor = s.tsponsor*currentRate;
        rmarketing = s.tmarketing*currentRate;
        rwsdapps = s.twsdapps*currentRate;
        rLiquidity = s.tLiquidity*currentRate;
        rTransferAmount =  rAmount-rRfi-rsponsor-rmarketing-rwsdapps-rLiquidity;
        return (rAmount, rTransferAmount, rRfi,rsponsor,rmarketing,rwsdapps,rLiquidity);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply/tSupply;
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply-_rOwned[_excluded[i]];
            tSupply = tSupply-_tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal/_tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
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
        require(amount <= balanceOf(from),"You are trying to transfer more than your balance");
        require(!_isBot[from] && !_isBot[to], "You are a bot");

        if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to] && !swapping){
            if(from == pair){
                require(amount <= maxBuyAmount, "You are exceeding maxBuyAmount");
            }
            if(to == pair){
                require(amount <= maxSellAmount, "You are exceeding maxSellAmount");
            }
            if(to != pair){
                require(balanceOf(to) + amount <= maxWalletBalance, "You are exceeding maxWalletBalance");
            }
        }
        
        bool canSwap = balanceOf(address(this)) >= swapTokensAtAmount;
        if(!swapping && swapEnabled && canSwap && from != pair && !_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
            swapAndLiquify(swapTokensAtAmount);
        }

        _tokenTransfer(from, to, amount, !(_isExcludedFromFee[from] || _isExcludedFromFee[to]), to == pair);
    }


    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool takeFee, bool isSell) private {
        valuesFromGetValues memory s = _getValues(tAmount, takeFee, isSell);

        if (_isExcluded[sender] ) {  //from excluded
                _tOwned[sender] = _tOwned[sender]-tAmount;
        }
        if (_isExcluded[recipient]) { //to excluded
                _tOwned[recipient] = _tOwned[recipient]+s.tTransferAmount;
        }

        _rOwned[sender] -= s.rAmount;
        _rOwned[recipient] += s.rTransferAmount;

        if (s.rRfi > 0 || s.tRfi > 0) _reflectRfi(s.rRfi, s.tRfi);
        if (s.rLiquidity > 0 || s.tLiquidity > 0) {
            _takeLiquidity(s.rLiquidity, s.tLiquidity);
        }
        if (s.rsponsor > 0 || s.tsponsor > 0) {
            _takesponsor(s.rsponsor, s.tsponsor);
        }
        if (s.rmarketing > 0 || s.tmarketing > 0) {
            _takemarketing(s.rmarketing, s.tmarketing);
        }
        if (s.rwsdapps > 0 || s.twsdapps > 0) {
            _takemarketing(s.rwsdapps, s.twsdapps);
        }

        emit Transfer(sender, recipient, isSell || takeFee ? s.tTransferAmount : tAmount); // Emit the correct transfer amount
        emit Transfer(sender, address(this), s.tLiquidity + s.tmarketing + s.tsponsor + s.twsdapps);
    }

    function swapAndLiquify(uint256 tokens) private lockTheSwap{
       // Split the contract balance into halves
        uint256 denominator = (sellTaxes.liquidity + sellTaxes.sponsor + sellTaxes.marketing + sellTaxes.wsdapps) * 2;
        uint256 tokensToAddLiquidityWith = tokens * sellTaxes.liquidity / denominator;
        uint256 toSwap = tokens - tokensToAddLiquidityWith;

        uint256 initialBalance = address(this).balance;

        swapTokensForETH(toSwap);

        uint256 deltaBalance = address(this).balance - initialBalance;
        uint256 unitBalance= deltaBalance / (denominator - sellTaxes.liquidity);
        uint256 ETHToAddLiquidityWith = unitBalance * sellTaxes.liquidity;

        if(ETHToAddLiquidityWith > 0){
            // Add liquidity to pancake
            addLiquidity(tokensToAddLiquidityWith, ETHToAddLiquidityWith);
        }

        uint256 sponsorAmt = unitBalance * 2 * sellTaxes.sponsor;
        if(sponsorAmt > 0){
            payable(sponsorAddress).transfer(sponsorAmt);
        }
        
        uint256 marketingAmt = unitBalance * 2 * sellTaxes.marketing;
        if(marketingAmt > 0){
            payable(marketingAddress).transfer(marketingAmt);
        }
        uint256 wsdappsAmt = unitBalance * 2 * sellTaxes.wsdapps;
        if(wsdappsAmt > 0){
            payable(wsdappsAddress).transfer(wsdappsAmt);
        }        
    }

    function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(router), tokenAmount);

        // add the liquidity
        router.addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0x6F1182C6E8BC5F36dB6B1B999590489fc63cE854),
            block.timestamp
        );
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);

        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function updatesponsorWallet(address newWallet) external onlyOwner{
        sponsorAddress = newWallet;
    }
    
    function updatemarketingWallet(address newmarketingWallet) external onlyOwner{
        marketingAddress = newmarketingWallet;
    }
    
    function increaseMaxes() external onlyOwner{
        maxWalletBalance = _tTotal * 2 / 100;
        maxBuyAmount = _tTotal * 2 / 100;
        maxSellAmount = _tTotal * 2 /100;
    }

    function removeLimits() external onlyOwner{
        maxWalletBalance = _tTotal;
        maxBuyAmount = _tTotal;
        maxSellAmount = _tTotal;
    }
    
    function updateSwapTokensAtAmount(uint256 amount) external onlyOwner{
        swapTokensAtAmount = amount * 10**_decimals;
    }

    function updateSwapEnabled(bool _enabled) external onlyOwner{
        swapEnabled = _enabled;
    }
    
    function updateRouterAndPair(address newRouter, address newPair) external onlyOwner{
        router = IRouter(newRouter);
        pair = newPair;
    }    

    //Use this in case ETH are sent to the contract
    function rescueETH(uint256 weiAmount) external onlyOwner{
        require(address(this).balance >= weiAmount, "insufficient ETH balance");
        payable(msg.sender).transfer(weiAmount);
    }
    
    // Function to allow admin to claim ERC20 tokens sent to this contract
    // Owner cannot transfer out $BART from this smart contract
    function rescueAnyERC20Tokens(address _tokenAddr, address _to, uint _amount) public onlyOwner {
        require(_tokenAddr != address(this), "Cannot transfer out $BART!");
        IERC20(_tokenAddr).transfer(_to, _amount);
    }

    receive() external payable{
    }
}