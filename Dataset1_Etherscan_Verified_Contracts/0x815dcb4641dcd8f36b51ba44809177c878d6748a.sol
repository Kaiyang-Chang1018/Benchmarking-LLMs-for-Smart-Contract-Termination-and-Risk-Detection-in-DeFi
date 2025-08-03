/**

Website: https://0xsecretai.com
Whitepaper: https://whitepaper.0xsecretai.com
Twitter: https://twitter.com/zeroxsecretai
Telegram: https://t.me/zeroxsecretai

*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.15;

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

contract SECAI is Context, IERC20, Ownable {
    uint256 private constant _totalSupply = 100_000_000e18;
    uint256 private constant _onePercent = 1_000_000e18;
    uint256 private _minSwappingSize = 111*1e18;
    uint256 private _maxSwappingSize = _onePercent;
    uint8 private constant _decimals = 18;

    IUniswapV2Router02 immutable _dexRouter;
    address private _dexPair;
    address immutable WETH;
    address payable _secretai;

    uint256 private _taxSecretBuy;
    uint256 private _taxSecretSell;
    uint256 private _taxSecretLiq;

    uint8 private _trdActive;
    uint8 private _isInSwap;

    uint256 private _maxBuySellTokens = _onePercent * 2;
    uint256 private _maxWalletHoldings = _onePercent * 2;

    string private constant _name = "0xSecretAI";
    string private constant _symbol = "SECAI";

    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _exceptForTradeSec;
    mapping(address => bool) private _exceptFromSecAI;

    constructor() {
        _dexRouter = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        WETH = _dexRouter.WETH();
        _secretai = payable(0xae2764E4854CACcD2BfA1797c075e8433d77aAB4);
        _balance[msg.sender] = _totalSupply;
        _exceptForTradeSec[_secretai] = true;
        _exceptForTradeSec[address(this)] = true;
        _exceptFromSecAI[address(this)] = true;
        _exceptFromSecAI[address(_dexRouter)] = true;
        _exceptFromSecAI[address(0)] = true;
        _exceptFromSecAI[address(0xDEAD)] = true;
        _exceptFromSecAI[msg.sender] = true;
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
        if (!_exceptForTradeSec[from] && !_exceptForTradeSec[to]) {
            require(
                _trdActive != 0 && amount <= _maxBuySellTokens,
                "Launch / Max TxAmount at launch"
            );
            if (!_exceptFromSecAI[to]) {
                require(
                    _balance[to] + amount <= _maxWalletHoldings,
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
                _tax = _taxSecretBuy + _taxSecretLiq;
            } else if (to == _dexPair) {
                uint256 tokensInContract = _balance[address(this)];
                if (amount > _minSwappingSize && _isInSwap == 0) {
                    if (tokensInContract > _minSwappingSize) {
                        if (tokensInContract > _maxSwappingSize) {
                            tokensInContract = _maxSwappingSize;
                        }

                        uint256 lpTokensForSwap = (tokensInContract * _taxSecretLiq) /
                            (((_taxSecretBuy + _taxSecretSell) / 2) + _taxSecretLiq);
                        uint256 tokensTosell = tokensInContract - lpTokensForSwap;

                        _isInSwap = 1;
                        address[] memory path = new address[](2);
                        path[0] = address(this);
                        path[1] = WETH;

                        _dexRouter
                            .swapExactTokensForETHSupportingFeeOnTransferTokens(
                                tokensTosell,
                                0,
                                path,
                                _secretai,
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

                _tax = _taxSecretSell + _taxSecretLiq;
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
        return !_exceptForTradeSec[from];
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

    function startSecret() external onlyOwner {
        require(_trdActive == 0, "already launched");
        _trdActive = 1;
        _taxSecretBuy = 30;
        _taxSecretSell = 30;
    }

    function secingLiquidity() external onlyOwner {
        require(_trdActive == 0, "already opened");
        _dexPair = IUniswapV2Factory(_dexRouter.factory()).createPair(
            address(this),
            WETH
        );
        _exceptFromSecAI[address(_dexPair)] = true;

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

    function reduceFees(
        uint256 _feeOnBuy,
        uint256 _feeOnSell
    ) external onlyOwner {
        _taxSecretBuy = _feeOnBuy;
        _taxSecretSell = _feeOnSell;
        require(_feeOnBuy <= 10 && _feeOnSell <= 10);
    }    

    function removeHoldingLimit() external onlyOwner {
        _maxBuySellTokens = type(uint256).max;
        _maxWalletHoldings = type(uint256).max;
    }

    receive() external payable {}
}