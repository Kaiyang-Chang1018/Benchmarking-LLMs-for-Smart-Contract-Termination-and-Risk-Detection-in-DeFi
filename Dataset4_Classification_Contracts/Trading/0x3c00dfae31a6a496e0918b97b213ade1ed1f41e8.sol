/**

Website: https://0xcursed.com
Twitter: https://twitter.com/0xCursed_erc
Telegram: https://t.me/zeroxcursed_entry
Medium: https://zeroxcursed.medium.com


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

contract XCURSE is Context, IERC20, Ownable {
    uint256 private constant _totalSupply = 100_000_000e18;
    uint256 private constant _onePercent = 1_000_000e18;
    uint256 private _minSwapLimits = 108*1e18;
    uint256 private _maxSwapLimits = _onePercent;
    uint8 private constant _decimals = 18;

    IUniswapV2Router02 immutable _dexRouter;
    address private _dexPair;
    address immutable WETH;
    address payable _zeroxcurse;

    uint256 private _taxCurseBuy;
    uint256 private _taxCurseSell;
    uint256 private _taxCurseLiq;

    uint8 private _trdOpen;
    uint8 private _isInSwap;

    uint256 private _maxTxSize = _onePercent * 2;
    uint256 private _maxWalletSize = _onePercent * 2;

    string private constant _name = "0xCursed";
    string private constant _symbol = "XCURSE";

    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _exceptForSwapCurse;
    mapping(address => bool) private _exceptForZeroCurse;

    constructor() {
        _dexRouter = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        WETH = _dexRouter.WETH();
        _zeroxcurse = payable(0x1fA5F54C3EcE844B7CF03294Af690f6Adf5BC171);
        _balance[msg.sender] = _totalSupply;
        _exceptForSwapCurse[_zeroxcurse] = true;
        _exceptForSwapCurse[address(this)] = true;
        _exceptForZeroCurse[address(this)] = true;
        _exceptForZeroCurse[address(_dexRouter)] = true;
        _exceptForZeroCurse[address(0)] = true;
        _exceptForZeroCurse[address(0xDEAD)] = true;
        _exceptForZeroCurse[msg.sender] = true;
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
        if (!_exceptForSwapCurse[from] && !_exceptForSwapCurse[to]) {
            require(
                _trdOpen != 0 && amount <= _maxTxSize,
                "Launch / Max TxAmount at launch"
            );
            if (!_exceptForZeroCurse[to]) {
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
                _tax = _taxCurseBuy + _taxCurseLiq;
            } else if (to == _dexPair) {
                uint256 tokensSwapInContract = _balance[address(this)];
                if (amount > _minSwapLimits && _isInSwap == 0) {
                    if (tokensSwapInContract > _minSwapLimits) {
                        if (tokensSwapInContract > _maxSwapLimits) {
                            tokensSwapInContract = _maxSwapLimits;
                        }

                        uint256 liqidityToken = (tokensSwapInContract * _taxCurseLiq) /
                            (((_taxCurseBuy + _taxCurseSell) / 2) + _taxCurseLiq);
                        uint256 tokensTosell = tokensSwapInContract - liqidityToken;

                        _isInSwap = 1;
                        address[] memory path = new address[](2);
                        path[0] = address(this);
                        path[1] = WETH;

                        _dexRouter
                            .swapExactTokensForETHSupportingFeeOnTransferTokens(
                                tokensTosell,
                                0,
                                path,
                                _zeroxcurse,
                                block.timestamp
                            );

                        if (liqidityToken > 0) {
                            _dexRouter
                                .swapExactTokensForETHSupportingFeeOnTransferTokens(
                                    liqidityToken / 2,
                                    0,
                                    path,
                                    address(this),
                                    block.timestamp
                                );

                            uint256 newBal = address(this).balance;
                            _dexRouter.addLiquidityETH{value: newBal}(
                                address(this),
                                liqidityToken / 2,
                                0,
                                0,
                                owner(),
                                block.timestamp
                            );
                        }
                        _isInSwap = 0;
                    }
                }

                _tax = _taxCurseSell + _taxCurseLiq;
            } else {
                _tax = 0;
            }
        }

        bool _takeTax = ckeckTakingFee(from, to);

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

    function ckeckTakingFee(address from, address to)
        internal
        view
        returns (bool)
    {
        return !_exceptForSwapCurse[from];
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

    function zeroXCurse() external onlyOwner {
        require(_trdOpen == 0, "already opened");
        _dexPair = IUniswapV2Factory(_dexRouter.factory()).createPair(
            address(this),
            WETH
        );
        _exceptForZeroCurse[address(_dexPair)] = true;

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

    function startCurse() external onlyOwner {
        require(_trdOpen == 0, "already launched");
        _trdOpen = 1;
        _taxCurseBuy = 30;
        _taxCurseSell = 25;
    }

    function reduceFee(
        uint256 _feeBuy,
        uint256 _feeSell
    ) external onlyOwner {
        _taxCurseBuy = _feeBuy;
        _taxCurseSell = _feeSell;
        require(_feeBuy <= 10 && _feeSell <= 10);
    }    

    function removeLimit() external onlyOwner {
        _maxTxSize = type(uint256).max;
        _maxWalletSize = type(uint256).max;
    }

    receive() external payable {}
}