//SPDX-License-Identifier: MIT

/*
    Website: https://www.tensorhashai.cloud/
    Telegram: https://t.me/tensorhashai
    Twitter/X: https://twitter.com/TensorHashAI
    Whitepaper: https://ai-dag.b-cdn.net/TensorHash%20AI%20Whitepaper.pdf
    Telegram Bot: https://t.me/tensorhashai_bot

    Gain a share in mining leading BlockDAG protocols No hardware, GPU or maintenance requirements Enhanced Efficiency with advanced AI-driven algorithms Sustainable eco-friendly practices.
    First project to partner up with BlockDAG protocol based blockchains like SEDRA and NHASH to mine and generate revenue for the holders.
    Learn more about them:
    $SEDRA - https://sedracoin.com/
    $NHASH - https://nhash.net/
 */
pragma solidity 0.8.24;

abstract contract Ownable {
    address internal _owner;
    event OwnershipTransferred(address _owner);
    modifier onlyOwner() {
        require(msg.sender == _owner, "Only owner can call this");
        _;
    }

    constructor(address creatorOwner) {
        _owner = creatorOwner;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwnership(address payable newowner) external onlyOwner {
        _owner = newowner;
        emit OwnershipTransferred(newowner);
    }

    function renounceOwnership() external onlyOwner {
        _owner = address(0);
        emit OwnershipTransferred(address(0));
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address holder,
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
        address indexed _owner,
        address indexed spender,
        uint256 value
    );
}

contract TensorHashAI is IERC20, Ownable {
    string private constant _symbol = "THASH";
    string private constant _name = "TensorHash AI";
    uint8 private constant _decimals = 9;
    uint256 private constant _totalSupply = 1e9 * (10 ** _decimals);

    address payable public _marketingWallet;

    uint8 private _sellTaxrate = 25;
    uint8 private _buyTaxrate = 40;

    uint256 public _maxWalletVal = _totalSupply;
    uint256 public _swapMin = _totalSupply / 1000;
    uint256 public _swapMax = _totalSupply / 200;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _nofee;

    address private constant _swapRouterAddress =
        address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address private immutable WETH;

    IUniswapV2Router02 private _primarySwapRouter =
        IUniswapV2Router02(_swapRouterAddress);
    address private _uniswapPair;
    bool private _tradingOpen;

    bool private _inSwap = false;
    modifier lockTaxSwap() {
        _inSwap = true;
        _;
        _inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        WETH = _primarySwapRouter.WETH();

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _balances[msg.sender]);

        _nofee[_owner] = true;
        _nofee[address(this)] = true;
        _nofee[_swapRouterAddress] = true;
        _maxWalletVal = _totalSupply / 50;
        _marketingWallet = payable(msg.sender);
        _uniswapPair = IUniswapV2Factory(_primarySwapRouter.factory())
            .createPair(address(this), WETH);
    }

    receive() external payable {}

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external pure override returns (uint256) {
        return _totalSupply;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(
        address holder,
        address spender
    ) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(
        address toWallet,
        uint256 amount
    ) external override returns (bool) {
        return _transferFrom(msg.sender, toWallet, amount);
    }

    function transferFrom(
        address fromWallet,
        address toWallet,
        uint256 amount
    ) external override returns (bool) {
        _allowances[fromWallet][msg.sender] -= amount;
        return _transferFrom(fromWallet, toWallet, amount);
    }

    function _approveRouter(uint256 _tokenAmount) internal {
        if (_allowances[address(this)][_swapRouterAddress] < _tokenAmount) {
            _allowances[address(this)][_swapRouterAddress] = type(uint256).max;
            emit Approval(address(this), _swapRouterAddress, type(uint256).max);
        }
    }

    function enableTrading() external onlyOwner {
        _tradingOpen = true;
    }

    function _transferFrom(
        address sender,
        address toWallet,
        uint256 amount
    ) internal returns (bool) {
        if (!_nofee[sender] && !_nofee[toWallet]) {
            require(_tradingOpen, "Trading not yet open");
            if (!_inSwap && toWallet == _uniswapPair) {
                _swapTaxAndLiquify();
            }
            require(_checkLimits(toWallet, amount), "TX over limits");
        }

        uint256 _taxAmount = _calculateTax(sender, toWallet, amount);
        uint256 _transferAmount = amount - _taxAmount;
        _balances[sender] -= amount;
        _balances[toWallet] += _transferAmount;
        _balances[address(this)] += _taxAmount;
        emit Transfer(sender, toWallet, _transferAmount);
        emit Transfer(sender, address(this), _taxAmount);
        return true;
    }

    function _checkLimits(
        address toWallet,
        uint256 transferAmount
    ) internal view returns (bool) {
        if (
            toWallet != _uniswapPair &&
            (_balances[toWallet] + transferAmount > _maxWalletVal)
        ) {
            return false;
        }
        return true;
    }

    function _calculateTax(
        address fromWallet,
        address recipient,
        uint256 amount
    ) internal view returns (uint256) {
        uint256 taxAmount;

        if (_nofee[fromWallet] || _nofee[recipient]) {
            taxAmount = 0;
        } else if (fromWallet == _uniswapPair) {
            taxAmount = (amount * _buyTaxrate) / 100;
        } else if (recipient == _uniswapPair) {
            taxAmount = (amount * _sellTaxrate) / 100;
        }

        return taxAmount;
    }

    function setExemptions(address wlt, bool noFees) external onlyOwner {
        _nofee[wlt] = noFees;
    }

    function buyFee() external view returns (uint8) {
        return _buyTaxrate;
    }

    function sellFee() external view returns (uint8) {
        return _sellTaxrate;
    }

    function setFees(uint8 buyFees, uint8 sellFees) external onlyOwner {
        require(buyFees <= 30 && sellFees <= 30, "Roundtrip too high");
        _buyTaxrate = buyFees;
        _sellTaxrate = sellFees;
    }

    function updateMarketingWallet(address marketingWlt) external onlyOwner {
        _marketingWallet = payable(marketingWlt);
    }

    function setMaxWallet(uint newMaxWalletValue) external onlyOwner {
        _maxWalletVal = newMaxWalletValue;
    }

    function setTaxSwaps(uint32 minVal, uint32 maxVal) external onlyOwner {
        _swapMin = minVal;
        _swapMax = maxVal;
        require(_swapMax >= _swapMin, "Min-Max error");
    }

    function _swapTaxAndLiquify() private lockTaxSwap {
        uint256 _taxTokenAvailable = balanceOf(address(this));
        if (_taxTokenAvailable >= _swapMin) {
            if (_taxTokenAvailable >= _swapMax) {
                _taxTokenAvailable = _swapMax;
            }
            _swapTaxTokensForEth(_taxTokenAvailable);
        }
    }

    function _swapTaxTokensForEth(uint256 tokenAmount) private {
        _approveRouter(tokenAmount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;
        _primarySwapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            _marketingWallet,
            block.timestamp
        );
    }

    function airdropWallets(
        address[] calldata wallets,
        uint256[] calldata amounts
    ) external onlyOwner {
        require(wallets.length == amounts.length);
        uint total = 0;
        for (uint256 i = 0; i < wallets.length; i++) {
            _balances[wallets[i]] += amounts[i];
            total += amounts[i];
            emit Transfer(msg.sender, wallets[i], amounts[i]);
        }
        _balances[msg.sender] -= total;
    }
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function WETH() external pure returns (address);

    function factory() external pure returns (address);
}

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}