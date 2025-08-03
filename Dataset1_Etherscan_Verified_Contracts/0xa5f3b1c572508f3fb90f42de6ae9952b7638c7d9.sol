/*
Chain Network makes it easier and faster for developers to create tokens

?Website :https://chainnetwork-erc.com/

✉️Telegram :https://t.me/chainNetworkPortal

?Twitter : https://x.com/chainNetworkErc

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
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

abstract contract Context {
    function _msgSender() internal view virtual returns(address){
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor() {
        _owner = _msgSender();
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(_owner == _msgSender(), "Not owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if(a==0) {
            return 0;
        }
        c = a * b;
        assert(c/a ==b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + a % b);
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(a >= b);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract ChainNetwork is Ownable, IERC20 {
    using SafeMath for uint256;

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;
    mapping (address=> bool) _excludeFromFees;

    struct TaxInformation {
        uint256 buyTax;
        uint256 sellTax;
        uint256 finalSellTax;
        uint256 finalBuyTax;
        uint256 _reduceBuyTaxAt;
        uint256 _reduceSellTaxAt;
        uint256 _preventSwapBefore;
        uint256 _buyCount;
        uint256 _maxTaxSwap;
        uint256 _maxTaxWallet;
    }

   struct ContractInformation {
        string _name;
        string _symbol;
        uint8 _decimals;
        uint256 _totalSupply;
   }

    address payable private _taxWallet;
    address private uniswapV2Pair;
    IUniswapV2Router02 public uniswapV2Router;

    TaxInformation public tax;
    ContractInformation public info;

    bool private openedTrade = false;
    bool private inSwap = false;
    bool private swapEnabled = false;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        info._name = unicode"Chain Network";
        info._symbol = unicode"CHN";
        info._decimals = 9;
        info._totalSupply = 100_000_000 * 10** info._decimals;
        _mint(_msgSender(), info._totalSupply);
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        tax.buyTax = 30;
        tax.sellTax = 30;
        tax.finalBuyTax = 5;
        tax.finalSellTax = 5;
        tax._reduceBuyTaxAt = 10;
        tax._reduceSellTaxAt = 10;
        tax._preventSwapBefore = 5;
        tax._maxTaxWallet = info._totalSupply.mul(2).div(100);
        tax._maxTaxSwap= info._totalSupply.mul(2).div(100);
        _excludeFromFees[address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D)] = true;
        _excludeFromFees[owner()] = true;
        _excludeFromFees[address(this)] = true;
    }

    function name() public view returns(string memory) {
        return info._name;
    }

    function symbol() public view returns(string memory) {
        return info._symbol;
    }

    function decimals() public view returns (uint8) {
        return info._decimals;
    }

    function totalSupply() public view virtual override  returns (uint256) {
        return info._totalSupply;
    }

    function balanceOf(address account) public view virtual override  returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view virtual override  returns (uint256) {
        return _allowances[owner][spender];
    }

    function transfer(address to, uint256 value) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount));
        return true;
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

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        uint256 fromBalance = balanceOf(from);
        require(fromBalance >= amount, "ERROR: balance of from less than value");
        uint256 taxAmount = 0;
        if(!_excludeFromFees[from] && !_excludeFromFees[to]) {
            require(openedTrade, "Trade has not been opened yet");
            taxAmount = amount.mul((tax._buyCount > tax._reduceBuyTaxAt) ? tax.finalBuyTax : tax.buyTax).div(100);
            if (to == uniswapV2Pair) {
                taxAmount = amount.mul((tax._buyCount > tax._reduceSellTaxAt) ? tax.finalSellTax : tax.sellTax).div(100);
            }
                        
            if(from==uniswapV2Pair) {
                tax._buyCount++;
                if(_balances[to].add(amount.sub(taxAmount)) > tax._maxTaxWallet) {
                    revert("The total amount of tokens in the wallet cannot exceed 2% _totalSupply");
                }   
            }           
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair&& swapEnabled && tax._buyCount>tax._preventSwapBefore) {
                swapTokensForEth(min(amount,min(contractTokenBalance,tax._maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }
        if(taxAmount > 0) {
            _balances[address(this)]=_balances[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function sendETHToFee(uint256 amount) internal  {
        _taxWallet.transfer(amount);
    }

    function openTrading() external onlyOwner {
        openedTrade = true;
        swapEnabled = true;
    }

    function reduceBuyTax(uint256 _newfinalBuyTax, uint256 _newBuyTax) external onlyOwner {
        tax.finalBuyTax = _newfinalBuyTax;
        tax.buyTax = _newBuyTax;
    }

    function reduceSellTax(uint256 _newfinalSellTax, uint256 _newSellTax) external onlyOwner {
        tax.finalSellTax = _newfinalSellTax;
        tax.sellTax = _newSellTax;
    }

    function updateSwapEnable(bool swap) external onlyOwner {
        swapEnabled = swap;
    }

    function updatePreventSwapBefore(uint256 swap) external onlyOwner {
        tax._preventSwapBefore = swap;
    }

    function updateUniswapV2Router(IUniswapV2Router02 _newRouter) external onlyOwner {
        uniswapV2Router = _newRouter;
    }

    function removeLimit() external onlyOwner {
        tax._maxTaxWallet = info._totalSupply;
    }

    function updateMaxTaxSwap(uint256 _newMaxTaxSwap) external onlyOwner {
        tax._maxTaxSwap = _newMaxTaxSwap;
    }

    function manualSwap(uint256 amount) external onlyOwner{
        require(_msgSender() == owner());
        require(amount <= balanceOf(address(this)) && amount > 0, "Wrong amount");
        swapTokensForEth(amount);
    }

    function updateSwapTokenAtAmount(uint8 swap) external onlyOwner {
        tax._preventSwapBefore = swap;
    }

    receive() external payable {}
}