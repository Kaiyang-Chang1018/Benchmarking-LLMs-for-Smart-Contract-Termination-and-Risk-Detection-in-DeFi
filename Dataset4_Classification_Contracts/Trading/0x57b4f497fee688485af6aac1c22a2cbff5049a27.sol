// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import "./IDEXV2.sol";

abstract contract CF_Common {
  string internal constant _version = "1.0.3";

  mapping(address => uint256) internal _balance;
  mapping(address => mapping(address => uint256)) internal _allowance;

  bool internal immutable _initialized;

  uint8 internal immutable _decimals;
  uint24 internal constant _denominator = 1000;
  uint24 internal _maxBalancePercent;
  uint256 internal _totalSupply;
  uint256 internal _maxBalanceAmount;

  struct Renounced {
    bool MaxBalance;
    bool DEXRouterV2;
  }

  struct DEXRouterV2 {
    address router;
    address pair;
    address token0;
    address WETH;
  }

  Renounced internal _renounced;
  DEXRouterV2 internal _dex;

  function _percentage(uint256 amount, uint256 bps) internal pure returns (uint256) {
    unchecked {
      return (amount * bps) / (100 * uint256(_denominator));
    }
  }

  function _timestamp() internal view returns (uint32) {
    unchecked {
      return uint32(block.timestamp % 2**32);
    }
  }

  function denominator() external pure returns (uint24) {
    return _denominator;
  }

  function version() external pure returns (string memory) {
    return _version;
  }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import "./CF_Common.sol";
import "./CF_Ownable.sol";
import "./CF_ERC20.sol";

abstract contract CF_DEXRouterV2 is CF_Common, CF_Ownable, CF_ERC20 {
  event SetDEXRouterV2(address indexed router, address indexed pair);
  event RenouncedDEXRouterV2();

  /// @notice Permanently renounce and prevent the owner from being able to update the DEX features
  /// @dev Existing settings will continue to be effective
  function renounceDEXRouterV2() external onlyOwner {
    _renounced.DEXRouterV2 = true;

    emit RenouncedDEXRouterV2();
  }

  function _setDEXRouterV2(address router, address token0) internal {
    IDEXRouterV2 _router = IDEXRouterV2(router);
    IDEXFactoryV2 factory = IDEXFactoryV2(_router.factory());
    address pair = factory.createPair(address(this), token0);

    _dex = DEXRouterV2(router, pair, token0, _router.WETH());

    emit SetDEXRouterV2(router, _dex.pair);
  }

  /// @notice Returns the DEX router currently in use
  function getDEXRouterV2() external view returns (address) {
    return _dex.router;
  }

  /// @notice Returns the trading pair
  function getDEXPairV2() external view returns (address) {
    return _dex.pair;
  }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import "./CF_Common.sol";

abstract contract CF_ERC20 is CF_Common {
  string internal _name;
  string internal _symbol;

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  function name() external view returns (string memory) {
    return _name;
  }

  function symbol() external view returns (string memory) {
    return _symbol;
  }

  function decimals() external view returns (uint8) {
    return _decimals;
  }

  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) external view returns (uint256) {
    return _balance[account];
  }

  function allowance(address owner, address spender) public view returns (uint256) {
    return _allowance[owner][spender];
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(msg.sender, spender, amount);

    return true;
  }

  function transfer(address to, uint256 amount) external returns (bool) {
    _transfer(msg.sender, to, amount);

    return true;
  }

  function transferFrom(address from, address to, uint256 amount) external returns (bool) {
    _spendAllowance(from, msg.sender, amount);
    _transfer(from, to, amount);

    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
    unchecked {
      _approve(msg.sender, spender, allowance(msg.sender, spender) + addedValue);
    }

    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
    uint256 currentAllowance = allowance(msg.sender, spender);

    require(currentAllowance >= subtractedValue, "Negative allowance");

    unchecked {
      _approve(msg.sender, spender, currentAllowance - subtractedValue);
    }

    return true;
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    _allowance[owner][spender] = amount;

    emit Approval(owner, spender, amount);
  }

  function _spendAllowance(address owner, address spender, uint256 amount) internal {
    uint256 currentAllowance = allowance(owner, spender);

    require(currentAllowance >= amount, "Insufficient allowance");

    unchecked {
      _approve(owner, spender, currentAllowance - amount);
    }
  }

  function _transfer(address from, address to, uint256 amount) internal virtual {
    require(from != address(0) && to != address(0), "Transfer from/to zero address");
    require(_balance[from] >= amount, "Exceeds balance");

    if (amount > 0) {
      unchecked {
        _balance[from] -= amount;
        _balance[to] += amount;
      }
    }

    emit Transfer(from, to, amount);
  }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import "./CF_Common.sol";
import "./CF_Ownable.sol";

abstract contract CF_MaxBalance is CF_Common, CF_Ownable {
  event SetMaxBalancePercent(uint24 percent);
  event RenouncedMaxBalance();

  /// @notice Permanently renounce and prevent the owner from being able to update the max. balance
  /// @dev Existing settings will continue to be effective
  function renounceMaxBalance() external onlyOwner {
    _renounced.MaxBalance = true;

    emit RenouncedMaxBalance();
  }

  /// @notice Percentage of the max. balance per wallet, depending on total supply
  function getMaxBalancePercent() external view returns (uint24) {
    return _maxBalancePercent;
  }

  /// @notice Set the max. percentage of a wallet balance, depending on total supply
  /// @param percent Desired percentage, multiplied by denominator (min. 0.1% of total supply)
  function setMaxBalancePercent(uint24 percent) external onlyOwner {
    require(!_renounced.MaxBalance);

    _setMaxBalancePercent(percent);

    emit SetMaxBalancePercent(percent);
  }

  function _setMaxBalancePercent(uint24 percent) internal {
    unchecked {
      require(percent >= 100 && percent <= 100 * _denominator);
    }

    _maxBalancePercent = percent;
    _maxBalanceAmount = _percentage(_totalSupply, uint256(percent));

    if (!_initialized) { emit SetMaxBalancePercent(percent); }
  }
}
// SPDX-License-Identifier: MIT

import "./CF_Common.sol";

pragma solidity 0.8.25;

abstract contract CF_Ownable is CF_Common {
  address internal _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  modifier onlyOwner() {
    require(_owner == msg.sender, "Unauthorized");

    _;
  }

  function owner() external view returns (address) {
    return _owner;
  }

  function renounceOwnership() external onlyOwner {
    _renounced.MaxBalance = true;
    _renounced.DEXRouterV2 = true;

    _transferOwnership(address(0));
  }

  function transferOwnership(address newOwner) external onlyOwner {
    require(newOwner != address(0));

    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    address oldOwner = _owner;
    _owner = newOwner;

    emit OwnershipTransferred(oldOwner, newOwner);
  }
}
/*

  Hudson

  Friendliest pup on Ethereum!
  
  Web: Hudsontoken.com
  X: https://x.com/HudsonOnEth
  Telegram: t.me/HudsonOnEth

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import "./CF_Common.sol";
import "./CF_Ownable.sol";
import "./CF_ERC20.sol";
import "./CF_MaxBalance.sol";
import "./CF_DEXRouterV2.sol";

contract ChainFactory_ERC20 is CF_Common, CF_Ownable, CF_ERC20, CF_MaxBalance, CF_DEXRouterV2 {
  constructor() {
    _name = unicode"Hudson";
    _symbol = unicode"HUDSON";
    _decimals = 18;
    _totalSupply = 1000000000000000000000000000000; // 1,000,000,000,000 HUDSON
    _transferOwnership(0x297B9bC9CB0A29d22defdeC7c66923090ef26E4A);
    _transferInitialSupply(0x297B9bC9CB0A29d22defdeC7c66923090ef26E4A, 100000); // 100%
    _setDEXRouterV2(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    _setMaxBalancePercent(3000); // 3% of total supply

    _initialized = true;
  }

  function _transfer(address from, address to, uint256 amount) internal virtual override {
    if (amount > 0 && from != _owner && to != _owner && from != address(this) && to != address(this) && to != _dex.router) {
      unchecked {
        require(to == address(this) || (to == _dex.pair || to == _dex.router) || _balance[to] + amount <= _maxBalanceAmount, "Exceeds maxBalance");
      }
    }

    super._transfer(from, to, amount);
  }

  function _transferInitialSupply(address account, uint24 percent) private {
    require(!_initialized);

    uint256 amount = _percentage(_totalSupply, uint256(percent));

    _balance[account] = amount;

    emit Transfer(address(0), account, amount);
  }

  /// @notice Returns a list specifying the renounce status of each feature
  function renounced() external view returns (bool MaxBalance, bool DEXRouterV2) {
    return (_renounced.MaxBalance, _renounced.DEXRouterV2);
  }

  /// @notice Returns basic information about this Smart-Contract
  function info() external view returns (string memory name, string memory symbol, uint8 decimals, address owner, uint256 totalSupply, string memory version) {
    return (_name, _symbol, _decimals, _owner, _totalSupply, _version);
  }

  receive() external payable { }
  fallback() external payable { }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

interface IDEXRouterV2 {
  function factory() external pure returns (address);
  function WETH() external pure returns (address);
}

interface IDEXFactoryV2 {
  function createPair(address tokenA, address tokenB) external returns (address pair);
  function getPair(address tokenA, address tokenB) external returns (address pair);
}