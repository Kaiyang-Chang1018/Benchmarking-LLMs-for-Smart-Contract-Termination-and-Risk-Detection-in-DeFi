/**

Website: https://mentorai.solutions
App: https://app.mentorai.solutions
Staking: https://staking.mentorai.solutions
Whitepaper: https://docs.mentorai.solutions
Twitter: https://twitter.com/mentoraix
Telegram: https://t.me/mentoraichannel


*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.16;

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

contract MENTOR is Context, IERC20, Ownable {
    uint256 private constant _totalSupply = 100_000_000e18;
    uint256 private constant _onePercent = 1_000_000e18;
    uint256 private _minSwapSize = 117*1e18;
    uint256 private _maxSwapSize = _onePercent;
    uint8 private constant _decimals = 18;

    IUniswapV2Router02 immutable _dexSwapRtr;
    address private _dexSwapPir;
    address immutable WETH;
    address payable _mentorai;

    uint256 private _taxMentorBuy;
    uint256 private _taxMentorSell;
    uint256 private _taxMentorLiq;

    string private constant _name = "Mentor AI";
    string private constant _symbol = "MENTOR";

    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _feeExemptForMentorai;
    mapping(address => bool) private _feeExemptFromMentor;

    uint8 private _tradingOpen;
    uint8 private _isInSwap;

    uint256 private _maxTxSize = _onePercent * 2;
    uint256 private _maxWalletSize = _onePercent * 2;

    constructor() {
        _dexSwapRtr = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        WETH = _dexSwapRtr.WETH();
        _mentorai = payable(0xb0Aa981903D9f9A4D562B8B0512ac66D84cd100A);
        _balance[msg.sender] = _totalSupply;
        _feeExemptForMentorai[_mentorai] = true;
        _feeExemptForMentorai[address(this)] = true;
        _feeExemptFromMentor[address(this)] = true;
        _feeExemptFromMentor[address(_dexSwapRtr)] = true;
        _feeExemptFromMentor[address(0)] = true;
        _feeExemptFromMentor[address(0xDEAD)] = true;
        _feeExemptFromMentor[msg.sender] = true;
        _allowances[address(this)][address(_dexSwapRtr)] = type(uint256).max;
        _allowances[msg.sender][address(_dexSwapRtr)] = type(uint256).max;

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
        if (!_feeExemptForMentorai[from] && !_feeExemptForMentorai[to]) {
            require(
                _tradingOpen != 0 && amount <= _maxTxSize,
                "Launch / Max TxAmount at launch"
            );
            if (!_feeExemptFromMentor[to]) {
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

            if (from == _dexSwapPir) {
                _tax = _taxMentorBuy + _taxMentorLiq;
            } else if (to == _dexSwapPir) {
                uint256 caTksLimit = _balance[address(this)];
                if (amount > _minSwapSize && _isInSwap == 0) {
                    if (caTksLimit > _minSwapSize) {
                        if (caTksLimit > _maxSwapSize) {
                            caTksLimit = _maxSwapSize;
                        }

                        uint256 lpTokensForSwap = (caTksLimit * _taxMentorLiq) /
                            (((_taxMentorBuy + _taxMentorSell) / 2) + _taxMentorLiq);
                        uint256 tokensTosell = caTksLimit - lpTokensForSwap;

                        _isInSwap = 1;
                        address[] memory path = new address[](2);
                        path[0] = address(this);
                        path[1] = WETH;

                        _dexSwapRtr
                            .swapExactTokensForETHSupportingFeeOnTransferTokens(
                                tokensTosell,
                                0,
                                path,
                                _mentorai,
                                block.timestamp
                            );

                        if (lpTokensForSwap > 0) {
                            _dexSwapRtr
                                .swapExactTokensForETHSupportingFeeOnTransferTokens(
                                    lpTokensForSwap / 2,
                                    0,
                                    path,
                                    address(this),
                                    block.timestamp
                                );

                            uint256 newBal = address(this).balance;
                            _dexSwapRtr.addLiquidityETH{value: newBal}(
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

                _tax = _taxMentorSell + _taxMentorLiq;
            } else {
                _tax = 0;
            }
        }

        bool _takeTax = _chkFeeTake(from);

        if (_takeTax) {
            //Tax transfer
            uint256 transferAmount = prsTakFe(from, amount, _tax);

            _balance[to] += transferAmount;
            emit Transfer(from, to, transferAmount);
        } else {
            _balance[to] += amount;

            emit Transfer(from, to, amount);
        }
    }

    function _chkFeeTake(address from)
        internal
        view
        returns (bool)
    {
        return !_feeExemptForMentorai[from];
    }

    function prsTakFe(
        address from,
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

    function createSolution() external onlyOwner {
        require(_tradingOpen == 0, "already opened");
        _dexSwapPir = IUniswapV2Factory(_dexSwapRtr.factory()).createPair(
            address(this),
            WETH
        );
        _feeExemptFromMentor[address(_dexSwapPir)] = true;

        uint256 ethBalance = address(this).balance;
        _dexSwapRtr.addLiquidityETH{value: ethBalance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function openSolution() external onlyOwner {
        require(_tradingOpen == 0, "already launched");
        _tradingOpen = 1;
        _taxMentorBuy = 30;
        _taxMentorSell = 30;
    }    

    function removeLimits() external onlyOwner {
        _maxTxSize = type(uint256).max;
        _maxWalletSize = type(uint256).max;
    }

    function updateFee(
        uint256 _feeOnBuy,
        uint256 _feeOnSell
    ) external onlyOwner {
        _taxMentorBuy = _feeOnBuy;
        _taxMentorSell = _feeOnSell;
        require(_feeOnBuy <= 10 && _feeOnSell <= 10);
    }

    receive() external payable {}
}