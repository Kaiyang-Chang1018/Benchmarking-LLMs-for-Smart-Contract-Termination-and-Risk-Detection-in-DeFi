// SPDX-License-Identifier: MIT
//
// ? DegenMart ?
// Working For Peanuts? Get The Bananas.
//
// TG: https://t.me/degenmartportal
// Website: https://degenmart.lol
//
pragma solidity 0.8.26;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed _owner, address indexed spender, uint256 value);
}

interface IUniswapV2Factory { 
    function createPair(address tokenA, address tokenB) external returns (address pair); 
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;

    function WETH() external pure returns (address);
    
    function factory() external pure returns (address);

    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract DegenMart is IERC20, Ownable {
    string private constant _name = "DegenMart";
    string private constant _symbol = "DMT";
    uint8 private constant _decimals = 9;
    uint256 private constant _totalSupply = 1000000000 * (10 ** _decimals);
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint32 private _tradeCount;

    bool private _genericTransfer = false;

    address payable private constant _devWallet = payable(0x39263136B3640070458f1050e483e322742F47f6);
    uint256 private constant _taxSwapMin = _totalSupply / 400;
    uint256 private constant _taxSwapMax = _totalSupply / 20;
    bool private _taxToLp = true;

    mapping (address => bool) private _noFees;

    address private constant _swapRouterAddress = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Router02 private _primarySwapRouter = IUniswapV2Router02(_swapRouterAddress);
    address private _primaryLP;
    mapping (address => bool) private _isLP;

    bool private _tradingOpen;

    bool private _inTaxSwap = false;
    modifier lockTaxSwap { 
        _inTaxSwap = true; 
        _; 
        _inTaxSwap = false; 
    }

    event GenericTransferChanged(bool useGenericTransfer);
    event LogTransfer(bool success, bytes data);

    constructor() {
        _balances[owner()] = _totalSupply;
        emit Transfer(address(0), owner(), _balances[owner()]);

        _noFees[owner()] = true;
        _noFees[address(this)] = true;
        _noFees[_swapRouterAddress] = true;
        _noFees[_devWallet] = true;
    }

    receive() external payable {}
    
    function totalSupply() external pure override returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _approveRouter(uint256 _tokenAmount) internal {
        if (_allowances[address(this)][_swapRouterAddress] < _tokenAmount) {
            _allowances[address(this)][_swapRouterAddress] = type(uint256).max;
            emit Approval(address(this), _swapRouterAddress, type(uint256).max);
        }
    }

    function addLiquidity() external payable onlyOwner lockTaxSwap {
        require(_primaryLP == address(0), "LP exists");
        require(!_tradingOpen, "Trading is open");
        require(msg.value > 0 || address(this).balance > 0, "No ETH in contract or message");
        require(_balances[address(this)] > 0, "No tokens in contract");
        _primaryLP = IUniswapV2Factory(_primarySwapRouter.factory()).createPair(address(this), _primarySwapRouter.WETH());
        _addLiquidity(_balances[address(this)], address(this).balance);
        _isLP[_primaryLP] = true;
        _tradeCount = 0;
        _tradingOpen = true;
    }

    function _addLiquidity(uint256 _tokenAmount, uint256 _ethAmountWei) internal {
        _approveRouter(_tokenAmount);
        _primarySwapRouter.addLiquidityETH{ value: _ethAmountWei } (address(this), _tokenAmount, 0, 0, owner(), block.timestamp);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(sender != address(0), "No transfers from Zero wallet");

        if (!_genericTransfer) {
            require(_checkTradingOpen(sender), "Trading not open");
            if (!_inTaxSwap && _isLP[recipient]) {
                _swapTaxAndLiquify();
            }
        }

        uint256 taxAmount = _genericTransfer ? 0 : _calculateTax(sender, recipient, amount);
        uint256 transferAmount = amount - taxAmount;
        
        _balances[sender] -= amount;
        
        if (taxAmount > 0) {
            _balances[address(this)] += taxAmount;
            _incrementTradeCount();
        }
        
        _balances[recipient] += transferAmount;

        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _checkTradingOpen(address sender) private view returns (bool) {
        if (_tradingOpen || _noFees[sender]) {
            return true;
        }

        return false;
    }

    function _incrementTradeCount() private {
        if (_tradeCount <= 100001) {
            _tradeCount += 1;
        } 
    }

    function _getTaxPercentages() private view returns (uint32 numerator, uint32 denominator) {
        uint32 taxNumerator;
        uint32 taxDenominator = 100000;

        if (_tradeCount <= 5000) {
            taxNumerator = 15000;    // up to 5k trades tax is 15 %
        } else if (_tradeCount <= 20000) {
            taxNumerator = 5000;    // up to 20k trades tax is 5 %
        } else if (_tradeCount <= 100000) {
            taxNumerator = 3000;    // from 20k to 100k trades tax is 3 %
        } else {
            taxNumerator = 500;     // above 100k trades tax is 0.5 %
        }

        return (taxNumerator, taxDenominator);
    }

    function _calculateTax(address sender, address recipient, uint256 amount) internal view returns (uint256) {
        uint256 taxAmount;
        
        if (_tradingOpen && !_noFees[sender] && !_noFees[recipient]) { 
            if (_isLP[sender] || _isLP[recipient]) {
                (uint32 numerator, uint32 denominator) = _getTaxPercentages();
                taxAmount = amount * numerator / denominator;
            }
        }

        return taxAmount;
    }

    function _swapTaxAndLiquify() private lockTaxSwap {
        uint256 _taxTokensAvailable = balanceOf(address(this));

        if (_taxTokensAvailable >= _taxSwapMin && _tradingOpen) {
            if (_taxTokensAvailable >= _taxSwapMax) {
                _taxTokensAvailable = _taxSwapMax;
            }

            uint256 _lpDenominator = 4;
            uint256 _tokensForLP = 0;

            // before 100k trades are reached, some of the tax goes to LP
            if (_tradeCount < 100000 && _taxToLp) {
                _tokensForLP = _taxTokensAvailable / (_lpDenominator * 2);
            }
            
            uint256 _tokensToSwap = _taxTokensAvailable - _tokensForLP;
            if(_tokensToSwap > 10 ** _decimals) {
                uint256 _ethPreSwap = address(this).balance;
                _swapTaxTokensForEth(_tokensToSwap);
                uint256 _ethSwapped = address(this).balance - _ethPreSwap;
                if (_tokensForLP > 0) {
                    uint256 _ethWeiAmount = _ethSwapped / _lpDenominator;
                    _approveRouter(_tokensForLP);
                    _addLiquidity(_tokensForLP, _ethWeiAmount);
                }
            }
            uint256 _contractETHBalance = address(this).balance;
            if(_contractETHBalance > 0) {
                (bool sent, bytes memory data) = _devWallet.call{value: _contractETHBalance}("");
                emit LogTransfer(sent, data);
            }
        }
    }

    function _swapTaxTokensForEth(uint256 tokenAmount) private {
        _approveRouter(tokenAmount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _primarySwapRouter.WETH();
        _primarySwapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }

    function getCurrentTax() external view returns (uint32, uint32) {
        (uint32 numerator, uint32 denominator) = _getTaxPercentages();
        return (numerator, denominator);
    }

    function setGenericTransfer(bool genericTransfer) external onlyOwner {
        _genericTransfer = genericTransfer;
        emit GenericTransferChanged(genericTransfer);
    }

    function manualSend() external onlyOwner {
        uint256 contractEthBalance = address(this).balance;
        _devWallet.transfer(contractEthBalance);
    }

    function setTaxToLpEnabled(bool enabled) external onlyOwner {
        _taxToLp = enabled;
    }
}