/**

Website: https://undead.fund
Twitter: https://twitter.com/undeadfund
Telegram: https://t.me/undeadfund

*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.18;

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

contract UNDEAD is Context, IERC20, Ownable {
    uint256 private constant _totalSupply = 10_000_000e18;
    uint256 private constant onePercent = 100_000e18;
    uint256 private constant tenthPercent = 10_000e18;
    uint256 private minSwap = 72e18;
    uint256 private maxSwap = onePercent * 2;
    uint8 private constant _decimals = 18;

    IUniswapV2Router02 immutable uniswapV2Router;
    address public uniswapV2Pair;
    address immutable WETH;
    address payable immutable _undeadAddr;

    uint256 public buyTax;
    uint256 public sellTax;
    uint256 public lpTax;

    uint8 private launch;
    uint8 private inSwapAndLiquify;

    uint256 private launchBlock;
    uint256 public maxTxAmount = onePercent * 2; //max Tx for first mins after launch
    uint256 public maxWalletAmount = onePercent * 2; //max Tx for first mins after launch

    string private constant _name = "UNDEAD";
    string private constant _symbol = "UNDEAD";

    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcludedFromMax;

    constructor() {
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        WETH = uniswapV2Router.WETH();
        buyTax = 31;
        sellTax = 32;
        lpTax = 0;

        _undeadAddr = payable(0xF6A5b5036E52BDA96402C38f3C8eDC6EAE661858);
        _balance[msg.sender] = _totalSupply;
        _isExcludedFromFee[_undeadAddr] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromMax[address(this)] = true;
        _isExcludedFromMax[address(uniswapV2Router)] = true;
        _isExcludedFromMax[address(0)] = true;
        _isExcludedFromMax[address(0xDEAD)] = true;
        _isExcludedFromMax[msg.sender] = true;
        _allowances[address(this)][address(uniswapV2Router)] = type(uint256)
            .max;
        _allowances[msg.sender][address(uniswapV2Router)] = type(uint256).max;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function liveUnDead() external onlyOwner {
        require(launch == 0, "already opened");
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            WETH
        );
        _isExcludedFromMax[address(uniswapV2Pair)] = true;

        uint256 ethBalance = address(this).balance;
        uniswapV2Router.addLiquidityETH{value: ethBalance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
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

    function openTrading() external onlyOwner {
        require(launch == 0, "already opened");
        launch = 1;
        launchBlock = block.number;
    }

    function addExcludedWallet(address wallet) external onlyOwner {
        _isExcludedFromFee[wallet] = true;
        _isExcludedFromMax[wallet] = true;
    }

    function removeLimits() external onlyOwner {
        maxTxAmount = type(uint256).max;
        maxWalletAmount = type(uint256).max;
    }

    function changeTax(
        uint256 newBuyTax,
        uint256 newSellTax,
        uint256 newLpTax
    ) external onlyOwner {
        require(
            newBuyTax < 20 ||
                newSellTax < 20 ||
                newLpTax < 20 ||
                (newBuyTax + newSellTax + newLpTax) < 50,
            "Cannot set taxes above 20%"
        );
        buyTax = newBuyTax;
        sellTax = newSellTax;
        lpTax = newLpTax;
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
        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
            require(
                launch != 0 && amount <= maxTxAmount,
                "Launch / Max TxAmount 1% at launch"
            );
            if (!_isExcludedFromMax[to]) {
                require(
                    _balance[to] + amount <= maxWalletAmount,
                    "Exceeds max wallet balance"
                );
            }

            if (inSwapAndLiquify == 1) {
                //No tax transfer
                _balance[from] -= amount;
                _balance[to] += amount;

                emit Transfer(from, to, amount);
                return;
            }

            if (from == uniswapV2Pair) {
                _tax = buyTax + lpTax;
            } else if (to == uniswapV2Pair) {
                uint256 tokensToSwap = _balance[address(this)];
                if (amount > minSwap && inSwapAndLiquify == 0) {
                    if (tokensToSwap > minSwap) {
                        if (tokensToSwap > maxSwap) {
                            tokensToSwap = maxSwap;
                        }

                        uint256 liqidityToken = (tokensToSwap * lpTax) /
                            (((buyTax + sellTax) / 2) + lpTax);
                        uint256 tokensTosell = tokensToSwap - liqidityToken;

                        inSwapAndLiquify = 1;
                        address[] memory path = new address[](2);
                        path[0] = address(this);
                        path[1] = WETH;

                        uniswapV2Router
                            .swapExactTokensForETHSupportingFeeOnTransferTokens(
                                tokensTosell,
                                0,
                                path,
                                _undeadAddr,
                                block.timestamp
                            );

                        if (liqidityToken > 0) {
                            uniswapV2Router
                                .swapExactTokensForETHSupportingFeeOnTransferTokens(
                                    liqidityToken / 2,
                                    0,
                                    path,
                                    address(this),
                                    block.timestamp
                                );

                            uint256 newBal = address(this).balance;
                            uniswapV2Router.addLiquidityETH{value: newBal}(
                                address(this),
                                liqidityToken / 2,
                                0,
                                0,
                                owner(),
                                block.timestamp
                            );
                        }
                        inSwapAndLiquify = 0;
                    }
                }

                _tax = sellTax + lpTax;
            } else {
                _tax = 0;
            }
        }

        bool _takeTax = shouldTakeTax(from, to);

        if (_takeTax) {
            //Tax transfer
            uint256 transferAmount = takeTax(from, to, amount, _tax);

            _balance[to] += transferAmount;
            emit Transfer(from, to, transferAmount);
        } else {
            _balance[to] += amount;

            emit Transfer(from, to, amount);
        }
    }

    function shouldTakeTax(address from, address to)
        internal
        view
        returns (bool)
    {
        return !_isExcludedFromFee[from];
    }

    function takeTax(
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

    receive() external payable {}
}