/*

Welcome to Wanted. The most addictive bot for underground crypto trading

Taxes 3/3 => 2% marketing, 1% lp

Website: https://www.wantedeth.com/
Telegram: https://t.me/wanted_eth
Twitter: https://twitter.com/WantedETH_com

*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ERC20 {
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender)
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
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
  address internal owner;

  constructor(address _owner) {
    owner = _owner;
  }

  modifier onlyOwner() {
    require(isOwner(msg.sender), "!OWNER");
    _;
  }

  function isOwner(address account) public view returns (bool) {
    return account == owner;
  }

  function renounceOwnership() public onlyOwner {
    owner = address(0);
    emit OwnershipTransferred(address(0));
  }

  event OwnershipTransferred(address owner);
}

interface IDEXFactory {
  function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
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
    returns (
      uint256 amountToken,
      uint256 amountETH,
      uint256 liquidity
    );

  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable;

  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;
}

contract Wanted is ERC20, Ownable {
  address routerAdress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
  address DEAD = 0x000000000000000000000000000000000000dEaD;

  string constant _name = "Wanted";
  string constant _symbol = "WTD";
  uint8 constant _decimals = 18;

  uint256 public constant _totalSupply = 10_000_000 * (10**_decimals);

  uint256 public constant MIN_TOKENS_ALLOW_BOT = 10_000 * (10**_decimals);

  mapping(address => uint256) _balances;
  mapping(address => mapping(address => uint256)) _allowances;

  mapping(address => bool) isFeeExempt;
  mapping(address => bool) isTxLimitExempt;

  uint256 public constant liquidityFee = 1; // 1% of every transaction is added to liquidity
  uint256 public constant marketingFee = 2; // 2% of every transaction is sent to marketing wallet
  uint256 public constant totalFee = liquidityFee + marketingFee;
  uint256 public constant feeDenominator = 100;

  address public marketingFeeReceiver;
  address public deployer;

  bool tradingEnabled = false;

  IDEXRouter public router;
  address public pair;

  bool public swapEnabled = true;
  uint256 public swapThreshold = 1; // 0.1% of total supply
  bool inSwap;
  modifier swapping() {
    inSwap = true;
    _;
    inSwap = false;
  }

  constructor() Ownable(msg.sender) {
    router = IDEXRouter(routerAdress);
    pair = IDEXFactory(router.factory()).createPair(
      router.WETH(),
      address(this)
    );
    _allowances[address(this)][address(router)] = type(uint256).max;

    address _owner = owner;
    isFeeExempt[msg.sender] = true;
    isTxLimitExempt[address(router)] = true;
    isTxLimitExempt[_owner] = true;
    isTxLimitExempt[msg.sender] = true;
    isTxLimitExempt[DEAD] = true;

    marketingFeeReceiver = msg.sender;
    deployer = msg.sender;
    _balances[msg.sender] = _totalSupply;
    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  receive() external payable {}

  function totalSupply() external pure override returns (uint256) {
    return _totalSupply;
  }

  function decimals() external pure override returns (uint8) {
    return _decimals;
  }

  function symbol() external pure override returns (string memory) {
    return _symbol;
  }

  function name() external pure override returns (string memory) {
    return _name;
  }

  function getOwner() external view override returns (address) {
    return owner;
  }

  function balanceOf(address account) public view override returns (uint256) {
    return _balances[account];
  }

  function allowance(address holder, address spender)
    external
    view
    override
    returns (uint256)
  {
    return _allowances[holder][spender];
  }

  function approve(address spender, uint256 amount)
    public
    override
    returns (bool)
  {
    _allowances[msg.sender][spender] = amount;
    emit Approval(msg.sender, spender, amount);
    return true;
  }

  function approveMax(address spender) external returns (bool) {
    return approve(spender, type(uint256).max);
  }

  function transfer(address recipient, uint256 amount)
    external
    override
    returns (bool)
  {
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
  ) internal returns (bool) {
    if (inSwap) {
      return _basicTransfer(sender, recipient, amount);
    }

    if (sender == deployer || recipient == deployer) {
      return _basicTransfer(sender, recipient, amount);
    } else {
      require(tradingEnabled, "Trading is not enabled yet.");
    }

    if (shouldSwapBack() && !isTxLimitExempt[recipient]) {
      swapBack();
    }

    _balances[sender] = _balances[sender] - amount;

    uint256 amountReceived = shouldTakeFee(sender)
      ? takeFee(sender, amount)
      : amount;
    _balances[recipient] = _balances[recipient] + amountReceived;

    emit Transfer(sender, recipient, amountReceived);
    return true;
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

  function shouldTakeFee(address sender) internal view returns (bool) {
    return !isFeeExempt[sender];
  }

  function takeFee(address sender, uint256 amount) internal returns (uint256) {
    uint256 feeAmount = (amount * totalFee) / feeDenominator;
    _balances[address(this)] = _balances[address(this)] + feeAmount;
    emit Transfer(sender, address(this), feeAmount);
    return amount - feeAmount;
  }

  function shouldSwapBack() internal view returns (bool) {
    return
      msg.sender != pair &&
      !inSwap &&
      swapEnabled &&
      _balances[address(this)] >= (swapThreshold * _totalSupply) / 10000;
  }

  function swapBack() internal swapping {
    uint256 contractTokenBalance = (swapThreshold * _totalSupply) / 10000;
    uint256 amountToLiquify = (contractTokenBalance * liquidityFee) /
      totalFee /
      2;
    uint256 amountToSwap = contractTokenBalance - amountToLiquify;

    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = router.WETH();

    uint256 balanceBefore = address(this).balance;

    router.swapExactTokensForETHSupportingFeeOnTransferTokens(
      amountToSwap,
      0,
      path,
      address(this),
      block.timestamp
    );
    uint256 amountETH = address(this).balance - balanceBefore;
    uint256 totalETHFee = totalFee - (liquidityFee / 2);
    uint256 amountETHLiquidity = (amountETH * liquidityFee) / totalETHFee / 2;
    uint256 amountETHMarketing = (amountETH * marketingFee) / totalETHFee;

    (
      bool MarketingSuccess, /* bytes memory data */

    ) = payable(marketingFeeReceiver).call{
        value: amountETHMarketing,
        gas: 30000
      }("");
    require(MarketingSuccess, "receiver rejected ETH transfer");

    if (amountToLiquify > 0) {
      router.addLiquidityETH{value: amountETHLiquidity}(
        address(this),
        amountToLiquify,
        0,
        0,
        marketingFeeReceiver,
        block.timestamp
      );
    }
  }

  function setMarketingFeeReceiver(address _marketingFeeReceiver) external {
    require(
      msg.sender == deployer,
      "Only deployer can set marketingFeeReceiver"
    );
    marketingFeeReceiver = _marketingFeeReceiver;
  }

  function clearStuckBalance() external {
    require(msg.sender == deployer, "Only deployer can clear stuck balance");
    payable(deployer).transfer(address(this).balance);
  }

  function enableTrading() external onlyOwner {
    tradingEnabled = true;
  }
}