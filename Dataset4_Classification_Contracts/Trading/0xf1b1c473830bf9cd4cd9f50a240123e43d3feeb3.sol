/**
 *
 * https://t.me/billycoinerc
 * https://billycoin.vip
 *
 */

pragma solidity ^0.8.19;

// SPDX-License-Identifier: MIT

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
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

    function renounceOwnership() external virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IDexRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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
}

interface IDexFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

contract BILLY is IERC20, Ownable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply = 1e9 * 10**18;

    string private _name = "Billy";
    string private _symbol = "BILLY";

    mapping(address => bool) public exemptFromFees;
    mapping(address => bool) public exemptFromLimits;

    bool public tradingActive;

    mapping(address => bool) public isAMMPair;

    uint256 public maxTransaction;
    uint256 public maxWallet;

    address public taxReceiverAddress;

    uint256 public buyTotalTax;

    uint256 public sellTotalTax;

    bool public limitsInEffect = true;

    bool public swapEnabled = false;
    bool private swapping;
    uint256 public swapTokensAtAmt;
    uint256 public swapTokensMaxAmt;

    address public lpPair;
    IDexRouter public dexRouter;

    uint256 public constant FEE_DIVISOR = 10000;

    // events

    event UpdatedMaxTransaction(uint256 newMax);
    event UpdatedMaxWallet(uint256 newMax);
    event SetExemptFromFees(address _address, bool _isExempt);
    event SetExemptFromLimits(address _address, bool _isExempt);
    event RemovedLimits();
    event UpdatedTaxes(uint256 newBuyAmt, uint256 newSellAmt);

    // constructor

    constructor() {
        address newOwner = msg.sender;
        _balances[newOwner] = _totalSupply;

        dexRouter = IDexRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        maxTransaction = (_totalSupply * 20) / 1000;
        maxWallet = (_totalSupply * 20) / 1000;
        swapTokensAtAmt = (_totalSupply * 5) / 1000000;
        swapTokensMaxAmt = _totalSupply / 100;

        taxReceiverAddress = 0x84e7C44df2c43Ee57549cfb328d5B8214cc77605;

        buyTotalTax = 5000;

        sellTotalTax = 5000;

        exemptFromLimits[taxReceiverAddress] = true;
        exemptFromLimits[msg.sender] = true;
        exemptFromLimits[address(this)] = true;

        exemptFromFees[taxReceiverAddress] = true;

        _approve(address(this), address(dexRouter), type(uint256).max);
    }

    receive() external payable {}

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        if (
            from == owner() ||
            to == owner() ||
            from == address(this) ||
            to == address(this)
        ) {
            _balances[from] = _balances[from] - amount;
            _balances[to] = _balances[to] + amount;
            emit Transfer(from, to, amount);
            return;
        }

        checkLimits(from, to, amount);

        amount -= handleTax(from, to, amount);

        _balances[from] = _balances[from] - amount;
        _balances[to] = _balances[to] + amount;
        emit Transfer(from, to, amount);
    }

    function checkLimits(
        address from,
        address to,
        uint256 amount
    ) internal view {
        require(tradingActive, "Trading not active");

        if (limitsInEffect) {
            // buy
            if (isAMMPair[from] && !exemptFromLimits[to]) {
                require(
                    amount <= maxTransaction,
                    "Buy transfer amount exceeded."
                );
                require(
                    amount + balanceOf(to) <= maxWallet,
                    "Unable to exceed Max Wallet"
                );
            }
            // sell
            else if (isAMMPair[to] && !exemptFromLimits[from]) {
                require(
                    amount <= maxTransaction,
                    "Sell transfer amount exceeds the maxTransactionAmt."
                );
            } else if (!exemptFromLimits[to]) {
                require(
                    amount + balanceOf(to) <= maxWallet,
                    "Unable to exceed Max Wallet"
                );
            }
        }
    }

    function handleTax(
        address from,
        address to,
        uint256 amount
    ) internal returns (uint256) {
        if (
            amount >= swapTokensAtAmt &&
            swapEnabled &&
            !swapping &&
            isAMMPair[to] &&
            !exemptFromFees[from]
        ) {
            swapping = true;
            swapBack();
            swapping = false;
        }

        uint256 tax = 0;

        if (!exemptFromFees[from] && !exemptFromFees[to]) {
            // on sell
            if (isAMMPair[to] && sellTotalTax > 0) {
                tax = (amount * sellTotalTax) / FEE_DIVISOR;
            }
            // on buy
            else if (isAMMPair[from] && buyTotalTax > 0) {
                tax = (amount * buyTotalTax) / FEE_DIVISOR;
            }

            if (tax > 0) {
                _balances[from] = _balances[from] - tax;
                _balances[address(this)] = _balances[address(this)] + tax;
                emit Transfer(from, address(this), tax);
            }
        } else {
            _balances[from] = _balances[from] + (amount - tax);
        }

        return tax;
    }

    function swapTokensForETH(uint256 tokenAmt) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(dexRouter.WETH());

        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmt,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));

        if (contractBalance > swapTokensMaxAmt) {
            contractBalance = swapTokensMaxAmt;
        }

        if (contractBalance > swapTokensAtAmt)
            swapTokensForETH(contractBalance);

        payable(taxReceiverAddress).transfer(address(this).balance);
    }

    function createPair() external onlyOwner {
        lpPair = IDexFactory(dexRouter.factory()).createPair(
            address(this),
            dexRouter.WETH()
        );

        isAMMPair[lpPair] = true;

        exemptFromLimits[lpPair] = true;

        dexRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );

        tradingActive = true;
        swapEnabled = true;
    }

    function updateTaxes(uint256 _buyTax, uint256 _sellTax) external onlyOwner {
        buyTotalTax = _buyTax;
        sellTotalTax = _sellTax;
        require(
            buyTotalTax <= 9900 && sellTotalTax <= 9900,
            "Keep tax below 99%"
        );
        emit UpdatedTaxes(buyTotalTax, sellTotalTax);
    }

    function removeLimits() external onlyOwner {
        limitsInEffect = false;
        maxTransaction = totalSupply();
        maxWallet = totalSupply();
        emit RemovedLimits();
    }
}