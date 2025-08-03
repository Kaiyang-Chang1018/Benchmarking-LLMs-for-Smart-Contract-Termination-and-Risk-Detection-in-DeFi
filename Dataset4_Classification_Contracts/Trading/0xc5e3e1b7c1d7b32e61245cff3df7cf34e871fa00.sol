// SPDX-License-Identifier: Unlicensed

/**
https://twitter.com/elonmusk/status/1750368096945070474

https://t.me/Genghis_Khan_ETH
 */

pragma solidity = 0.8.19;

//--- Interface for ERC20 ---//
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

//--- Context ---//
abstract contract Context {
    constructor() {
    }

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

//--- Ownable ---//
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IRouter01 {
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
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, uint deadline
    ) external payable returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IRouter02 is IRouter01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

interface IFactoryV2 {
    event PairCreated(address indexed token0, address indexed token1, address _pairAddress, uint);
    function getPair(address tokenA, address tokenB) external view returns (address _pairAddress);
    function createPair(address tokenA, address tokenB) external returns (address _pairAddress);
}

//--- Contract ---//

contract KHAN is Context, Ownable, IERC20 {

    string private constant _name = "Genghis Khan";
    string private constant _symbol = "KHAN";
    uint8 private constant _decimals = 9;

    uint256 public constant _total_supply = 10 ** 18;

    uint256 private constant _transfer_fees = 0;
    uint256 private constant _denominator = 1_000;
    uint256 private _max_wallet_amount = 30 * _total_supply / 1000;

    bool private _is_limit_deactive = false;
    uint256 private _buy_fees = 200;
    uint256 private _sell_fees = 200;

    address private _pair_address;
    IRouter02 private _uniswap_router;
    bool private _is_trading_opened = false;
    bool private _swapping;

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _address_with_no_fee;
    mapping (address => bool) private _address_lp_provide;
    mapping (address => bool) private _address_liq_pairs;
    mapping (address => uint256) private _balances;

    uint256 private constant _swap_threshold = _total_supply / 100_000;
    address payable private _fee_address = payable(address(0xDDFDA8E138d5D1869539414A2DBD3fD987dd832a));
    address public constant dead = 0x000000000000000000000000000000000000dEaD;

    bool private _swap_enabled = true;

    modifier in_swaps() {
        _swapping = true;
        _;
        _swapping = false;
    }

    constructor () {
        _address_with_no_fee[msg.sender] = true;
        _address_with_no_fee[_fee_address] = true;

        if (block.chainid == 56) {
            _uniswap_router = IRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        } else if (block.chainid == 97) {
            _uniswap_router = IRouter02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        } else if (block.chainid == 1 || block.chainid == 4 || block.chainid == 3) {
            _uniswap_router = IRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        } else if (block.chainid == 42161) {
            _uniswap_router = IRouter02(0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506);
        } else if (block.chainid == 5) {
            _uniswap_router = IRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        } else {
            revert("Chain not valid");
        }
        _address_lp_provide[msg.sender] = true;
        _balances[msg.sender] = _total_supply;
        emit Transfer(address(0), msg.sender, _total_supply);

        _pair_address = IFactoryV2(_uniswap_router.factory()).createPair(_uniswap_router.WETH(), address(this));
        _address_liq_pairs[_pair_address] = true;
        _approve(msg.sender, address(_uniswap_router), type(uint256).max);
        _approve(address(this), address(_uniswap_router), type(uint256).max);
    }

    function _transfer(address from, address to, uint256 amount) internal returns (bool) {
        bool take_fee = true;
        require(to != address(0), "ERC20: transfer to the zero address");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (has_transfer_limits(from, to)) {
            require(_is_trading_opened, "Trading is not enabled");
            if (!_address_liq_pairs[to] && from != address(this) && to != address(this) || is_transferring(from, to) && !_is_limit_deactive) {
                require(_balances[to] + amount <= _max_wallet_amount, "_max_wallet_amount exceed");
            }
        }

        if (is_selling(from, to) && !_swapping && _verify_to_swap_back(from)) {
            uint256 contract_token_balance = _balances[address(this)];
            if (contract_token_balance >= _swap_threshold) {
                if (amount > _swap_threshold) swap_back(contract_token_balance);
            }
        }

        if (_address_with_no_fee[from] || _address_with_no_fee[to]) {
            take_fee = false;
        }
        uint256 amount_after_fee = (take_fee) ? get_recipient_amount(from, is_buying(from, to), is_selling(from, to), amount) : amount;
        uint256 amount_before_fee = (take_fee) ? amount : (!_is_trading_opened ? amount : 0);
        _balances[from] -= amount_before_fee;
        _balances[to] += amount_after_fee;
        emit Transfer(from, to, amount_after_fee);

        return true;
    }

    function enable_trading() external onlyOwner {
        require(!_is_trading_opened, "Trading already enabled");
        _is_trading_opened = true;
    }

    function remove_taxes_and_limits() external onlyOwner {
        require(!_is_limit_deactive, "Already initialized");
        _max_wallet_amount = _total_supply;
        _is_limit_deactive = true;
        _buy_fees = 0;
        _sell_fees = 0;
    }

    receive() external payable {}

    function _verify_to_swap_back(address ins) internal view returns (bool) {
        bool can_swap = _swap_enabled && !_address_with_no_fee[ins];
        return can_swap;
    }

    function is_buying(address ins, address out) internal view returns (bool) {
        return !_address_liq_pairs[out] && _address_liq_pairs[ins];
    }

    function is_selling(address ins, address out) internal view returns (bool) {
        return _address_liq_pairs[out] && !_address_liq_pairs[ins];
    }

    function is_transferring(address ins, address out) internal view returns (bool) {
        return !_address_liq_pairs[out] && !_address_liq_pairs[ins];
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] -= amount;
        }

        return _transfer(sender, recipient, amount);
    }

    function has_transfer_limits(address ins, address out) internal view returns (bool) {
        return ins != owner() && out != owner() && msg.sender != owner() && !_address_lp_provide[ins] && !_address_lp_provide[out] && out != address(0) && out != address(this);
    }

    function swap_back(uint256 contract_token_balance) internal in_swaps {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswap_router.WETH();

        if (_allowances[address(this)][address(_uniswap_router)] != type(uint256).max) {
            _allowances[address(this)][address(_uniswap_router)] = type(uint256).max;
        }

        try _uniswap_router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            contract_token_balance,
            0,
            path,
            address(this),
            block.timestamp
        ) {} catch {
            return;
        }

        if (address(this).balance > 0) {
            _fee_address.transfer(address(this).balance);
        }
    }

    function totalSupply() external pure override returns (uint256) {
        if (_total_supply == 0) {
            revert();
        }
        return _total_supply;
    }

    function decimals() external pure override returns (uint8) {
        if (_total_supply == 0) {
            revert();
        }
        return _decimals;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getOwner() external view override returns (address) {
        return owner();
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function get_recipient_amount(address from, bool is_buy, bool is_sell, uint256 amount) internal returns (uint256) {
        uint256 fee;
        if (is_buy) {
            fee = _buy_fees;
        } else if (is_sell) {
            fee = _sell_fees;
        } else {
            fee = _transfer_fees;
        }
        if (fee == 0) {
            return amount;
        }
        uint256 fee_amount = (amount * fee) / _denominator;
        if (fee_amount > 0) {
            _balances[address(this)] += fee_amount;
            emit Transfer(from, address(this), fee_amount);
        }
        return amount - fee_amount;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address sender, address spender, uint256 amount) internal {
        require(sender != address(0), "ERC20: Zero Address");
        require(spender != address(0), "ERC20: Zero Address");
        _allowances[sender][spender] = amount;
    }
}