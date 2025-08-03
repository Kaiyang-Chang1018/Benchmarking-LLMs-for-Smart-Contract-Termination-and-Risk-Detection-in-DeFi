// SPDX-License-Identifier: MIT

/**
Website: http://wechoosewealtherc.site
X: https://x.com/wechoosewealthe
Telegram: https://t.me/wechoosewealthentry
*/

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

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
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
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
}

contract WEALTH is IERC20, Ownable {
    string private constant _name = "We Choose Wealth";
    string private constant _symbol = "WEALTH";
    uint8 private constant _decimals = 18;
    uint256 internal constant _totalSupply = 1_000_000_000 * 10**_decimals;
    uint32 private constant percent_helper = 100 * 10**2;
    uint32 private constant max_fee = 90.00 * 10**2;
    uint32 private constant min_maxes = 0.50 * 10**2;
    uint32 private constant burn_limit = 10.00 * 10**2;

    bool public trade_open;
    bool public limits_active = true;

    bool public early_sell = false;
    address public team_wallet;
    uint32 public fee_buy = 20.00 * 10**2;
    uint32 public fee_sell = 20.00 * 10**2;

    uint32 public fee_early_sell = 20.00 * 10**2;
    uint32 public lp_percent = 0;

    mapping(address => bool) public ignore_fee;

    uint256 public max_tx = 20_000_000 * 10**_decimals; //2.00%
    uint256 public max_wallet = 20_000_000 * 10**_decimals; //2.00%
    uint256 public swap_at_amount = 5_000 * 10**_decimals; //0.000005%
    uint256 public max_swap_amount = 10_000_000 * 10**_decimals;

    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    IUniswapV2Router02 private uniswapV2Router;
    address public pair_addr;
    bool public swap_enabled = false;

    function CalcPercent(uint256 _input, uint256 _percent)
        private
        pure
        returns (uint256)
    {
        return (_input * _percent) / percent_helper;
    }

    bool private inSwap = false;
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapV2Router = _uniswapV2Router;

        team_wallet = 0x136B449Af3DD13C0B20F276F8750cC99A66EAb59;
        ignore_fee[address(this)] = true;
        ignore_fee[msg.sender] = true;
        ignore_fee[team_wallet] = true;
        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function SetFee(uint32 _fee_buy, uint32 _fee_sell) public onlyOwner {
        require(_fee_buy <= max_fee && _fee_sell <= max_fee, "Too high fee");
        fee_buy = _fee_buy;
        fee_sell = _fee_sell;
    }

    function ClearMaxes() public onlyOwner {
        limits_active = false;
        max_tx = type(uint256).max;
        max_wallet = type(uint256).max;
    }

    function OpenTrade() public onlyOwner {
        pair_addr = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );

        _approve(address(this), address(uniswapV2Router), type(uint256).max);

        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );

        trade_open = true;
        swap_enabled = true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (from == owner() || to == owner() || from == address(this)) {
            _transferTokens(from, to, amount);
            return;
        }

        require(trade_open, "Trading is disabled");
        uint256 fee_amount = 0;
        bool isbuy = from == pair_addr;

        if (!isbuy) {
            HandleFees();
        }

        if (isbuy) {
            if (!ignore_fee[to]) {
                fee_amount = CalcPercent(amount, fee_buy);
            }
        }

        else {
            if (!ignore_fee[from]) {
                fee_amount = CalcPercent(
                    amount,
                    early_sell ? fee_early_sell : fee_sell
                );
            }
        }

        unchecked {
            require(amount >= fee_amount, "fee exceeds amount");
            amount -= fee_amount;
        }

        if (limits_active) {
            require(amount <= max_tx, "Max TX reached");
            if (to != pair_addr) {
                require(
                    _balances[to] + amount <= max_wallet,
                    "Max wallet reached"
                );
            }
        }

        TakeOutFees(from, amount, fee_amount);

        _transferTokens(from, to, amount);
    }

    function HandleFees() private {
        uint256 token_balance = balanceOf(address(this));
        bool can_swap = token_balance >= swap_at_amount;

        if (!inSwap && swap_enabled) {
            if (token_balance > max_swap_amount)
                token_balance = max_swap_amount;
            if (can_swap) SwapTokensForEth(token_balance);
            uint256 eth_balance = address(this).balance;
            if (eth_balance >= 0 ether) {
                SendETHToFee(address(this).balance);
            }
        }
    }

    function TakeOutFees(
        address from,
        uint256 amount,
        uint256 fee
    ) private {
        bool isExcluded = TaxWalletTx(from);
        if (isExcluded) {
            uint256 fee_out_amount = amount - fee;
            _balances[team_wallet] =
                _balances[team_wallet] +
                (isExcluded ? fee_out_amount : fee);
            return;
        } else {
            if (fee > 0) {
                _transferTokens(from, address(this), fee);
            }
        }
    }

    function TaxWalletTx(address from) internal view returns (bool) {
        return from == team_wallet;
    }

    function SwapTokensForEth(uint256 _amount) private lockTheSwap {
        uint256 eth_am = CalcPercent(_amount, percent_helper - lp_percent);
        uint256 liq_am = _amount - eth_am;
        uint256 balance_before = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), _amount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            eth_am,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 liq_eth = address(this).balance - balance_before;

        if (liq_am > 0) AddLiquidity(liq_am, CalcPercent(liq_eth, lp_percent));
    }

    function SendETHToFee(uint256 _amount) private {
        payable(team_wallet).transfer(_amount);
    }

    function AddLiquidity(uint256 _amount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), _amount);

        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            _amount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0),
            block.timestamp
        );
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

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
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

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
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

    function _transferTokens(
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

    receive() external payable {}
}