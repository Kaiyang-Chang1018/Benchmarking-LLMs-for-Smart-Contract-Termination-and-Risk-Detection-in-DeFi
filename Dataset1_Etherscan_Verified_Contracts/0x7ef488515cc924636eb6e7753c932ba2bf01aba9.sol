// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
 * Twitter : https://twitter.com/XBTCERC
 * Telegram : https://t.me/XBTCERC
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

contract ERC20 is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _isExcludeFromFee;
    
    uint256 private _totalSupply;

    IUniswapRouter public _uniswapRouter;

    mapping(address => bool) public isMarketPair;
    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);

    uint256 public _buyFundFee = 30;
    uint256 public _sellFundFee = 70;

    address public _uniswapPair;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    address public WETH;
    constructor (){
        _name = unicode"? ₿itcoin";
        _symbol = unicode"?₿";
        _decimals = 18;
        uint256 Supply = 21000000;
        _totalSupply = Supply * 10 ** _decimals;

        address receiveAddr = msg.sender;
        _balances[receiveAddr] = _totalSupply;
        emit Transfer(address(0), receiveAddr, _totalSupply);
        fundAddress = receiveAddr;
        _isExcludeFromFee[address(this)] = true;
        _isExcludeFromFee[receiveAddr] = true;
        _isExcludeFromFee[fundAddress] = true;
    }

    function openTrading() public payable onlyOwner{
        require(address(_uniswapRouter) == address(0),"trading is already open");
        _uniswapRouter = IUniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _isExcludeFromFee[address(_uniswapRouter)] = true;
        _approve(address(this), address(_uniswapRouter), MAX);
        WETH = _uniswapRouter.WETH();
        _uniswapPair = IUniswapFactory(_uniswapRouter.factory()).createPair(address(this), WETH);
        isMarketPair[_uniswapPair] = true;
        _uniswapRouter.addLiquidityETH{value: msg.value}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
    }

    function designTax(
        uint256 _newBuy,
        uint256 _newSell
    ) public onlyOwner{
        _buyFundFee = _newBuy;
        _sellFundFee = _newSell;
        // require(_buyFundFee <= 20 && _sellFundFee <= 20,"too high");
    }

    function setFundAddr(address newAddr) public onlyOwner{
        fundAddress = newAddr;
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

    bool public isRemainHolder = true;
    function changeRemain() public onlyOwner{
        isRemainHolder = !isRemainHolder;
    }

    function getValue(uint Token)public  view returns (uint){
        if(WETH == address(0)) return 0;
        if(IERC20(WETH).balanceOf(_uniswapPair) > 0){
            address[] memory path = new address[](2);
            uint[] memory amount;
            path[0]=address(this);
            path[1]=WETH;
            amount = _uniswapRouter.getAmountsOut(Token,path); 
            return amount[1];
        }else {
            return 0; 
        }
    }

    uint256 public limitAmounts = 0.3 ether;
    function setLimitAmounts(uint256 newValue) public onlyOwner{
        limitAmounts = newValue;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(balanceOf(from) >= amount, "balanceNotEnough");

        bool takeFee;

        if (isMarketPair[to] && !inSwap && !_isExcludeFromFee[from] && !_isExcludeFromFee[to]) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if (contractTokenBalance > 0) {
                uint256 numTokensSellToFund = amount;
                numTokensSellToFund = numTokensSellToFund > contractTokenBalance ? 
                                                            contractTokenBalance:numTokensSellToFund;
                swapTokenForETH(numTokensSellToFund);
            }
        }

        if (!_isExcludeFromFee[from] && !_isExcludeFromFee[to] && !inSwap) {
            takeFee = true;
        }

        if (!_isExcludeFromFee[from] && !_isExcludeFromFee[to] && isRemainHolder){
            if (amount == _balances[from]){ // remain holders
                amount = amount - (amount / 10000);
            }
            if (isMarketPair[from] && limitAmounts != 0){
                require(getValue(amount) <= limitAmounts);
            }
        }

        if (takeFee && !isMarketPair[from] && !isMarketPair[to]){
            takeFee = false;
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
                taxFee = _sellFundFee;
            } else {
                taxFee = _buyFundFee;
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

    function swapTokenForETH(uint256 tokenAmount) private lockTheSwap {
        if (address(_uniswapRouter) == address(0)) return;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;
        try _uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(fundAddress),
            block.timestamp
        ) {} catch {}
        
    }

    function setIsExcludeFromFees(address account, bool value) public onlyOwner{
        _isExcludeFromFee[account] = value;
    }

    function removeERC20(address token) external {
        if (token == address(0)){
            payable(fundAddress).transfer(address(this).balance);
        }else{
            IERC20(token).transfer(fundAddress, IERC20(token).balanceOf(address(this)));
        }
    }

    receive() external payable {}
}