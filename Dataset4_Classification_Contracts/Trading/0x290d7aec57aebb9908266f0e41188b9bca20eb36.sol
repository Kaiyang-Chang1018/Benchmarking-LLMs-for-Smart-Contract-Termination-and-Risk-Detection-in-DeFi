// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import "./CF_Common.sol";
import "./CF_ERC20.sol";

abstract contract CF_Burnable is CF_Common, CF_ERC20 {
  /// @notice Total amount of tokens burned so far
  function totalBurned() external view returns (uint256) {
    return _totalBurned;
  }

  function burn(uint256 amount) external {
    _burn(msg.sender, amount);
  }

  function burnFrom(address account, uint256 amount) external {
    _spendAllowance(account, msg.sender, amount);
    _burn(account, amount);
  }

  function _burn(address account, uint256 amount) internal virtual {
    require(_balance[account] >= amount, "Exceeds balance");

    unchecked {
      _balance[account] -= amount;
      _totalSupply -= amount;
      _totalBurned += amount;
    }

    emit Transfer(account, address(0xdEaD), amount);
  }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import "./IDEXV2.sol";
import "./IERC20.sol";

abstract contract CF_Common {
  string internal constant _version = "1.0.3";

  mapping(address => uint256) internal _balance;
  mapping(address => mapping(address => uint256)) internal _allowance;
  mapping(address => bool) internal _whitelisted;
  mapping(address => holderAccount) internal _holder;
  mapping(uint8 => taxBeneficiary) internal _taxBeneficiary;
  mapping(address => uint256) internal _tokensForTaxDistribution;

  address[] internal _holders;

  bool internal _autoSwapEnabled;
  bool internal _swapping;
  bool internal _suspendTaxes;
  bool internal _distributing;
  bool internal immutable _initialized;

  uint8 internal immutable _decimals;
  uint8 internal _cooldownTriggerCount;
  uint24 internal constant _denominator = 1000;
  uint24 internal _maxTxPercent;
  uint24 internal _maxBalancePercent;
  uint24 internal _totalTxTax;
  uint24 internal _totalBuyTax;
  uint24 internal _totalSellTax;
  uint24 internal _totalPenaltyTxTax;
  uint24 internal _totalPenaltyBuyTax;
  uint24 internal _totalPenaltySellTax;
  uint24 internal _minAutoSwapPercent;
  uint24 internal _maxAutoSwapPercent;
  uint24 internal _minAutoAddLiquidityPercent;
  uint24 internal _maxAutoAddLiquidityPercent;
  uint32 internal _lastTaxDistribution;
  uint32 internal _tradingEnabled;
  uint32 internal _lastSwap;
  uint32 internal _earlyPenaltyTime;
  uint32 internal _cooldownTriggerTime;
  uint32 internal _cooldownPeriod;
  uint256 internal _totalSupply;
  uint256 internal _totalBurned;
  uint256 internal _maxTxAmount;
  uint256 internal _maxBalanceAmount;
  uint256 internal _minAutoSwapAmount;
  uint256 internal _maxAutoSwapAmount;
  uint256 internal _minAutoAddLiquidityAmount;
  uint256 internal _maxAutoAddLiquidityAmount;
  uint256 internal _amountForLiquidity;
  uint256 internal _ethForLiquidity;
  uint256 internal _totalTaxCollected;
  uint256 internal _totalTaxUnclaimed;
  uint256 internal _amountForTaxDistribution;
  uint256 internal _amountSwappedForTaxDistribution;
  uint256 internal _ethForTaxDistribution;

  struct Renounced {
    bool Whitelist;
    bool Cooldown;
    bool MaxTx;
    bool MaxBalance;
    bool Taxable;
    bool DEXRouterV2;
  }

  struct holderAccount {
    bool exists;
    bool penalty;
    uint32 count;
    uint32 start;
    uint32 cooldown;
  }

  struct taxBeneficiary {
    bool exists;
    address account;
    uint24[3] percent; // 0: tx, 1: buy, 2: sell
    uint24[3] penalty;
    uint256 unclaimed;
  }

  struct DEXRouterV2 {
    address router;
    address pair;
    address token0;
    address WETH;
    address receiver;
  }

  Renounced internal _renounced;
  IERC20 internal _taxToken;
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

abstract contract CF_Cooldown is CF_Common, CF_Ownable {
  event SetCooldown(uint8 count, uint32 time, uint32 period);
  event RenouncedCooldown();

  /// @notice Permanently renounce and prevent the owner from being able to update cooldown features
  /// @dev Existing settings will continue to be effective
  function renounceCooldown() external onlyOwner {
    _renounced.Cooldown = true;

    emit RenouncedCooldown();
  }

  /// @notice Returns current cooldown settings
  /// @return count Number of transfers
  /// @return time Seconds during which the number of transfers will be taken into account
  /// @return period Seconds during which the wallet will be in cooldown (0 means disabled)
  function getCooldownSettings() external view returns (uint8 count, uint32 time, uint32 period) {
    return (_cooldownTriggerCount, _cooldownTriggerTime, _cooldownPeriod);
  }

  /// @notice Set cooldown settings
  /// @param count Number of transfers
  /// @param time Seconds during which the number of transfers will be taken into account
  /// @param period Seconds during which the wallet will be in cooldown (less or equal to 1 week, 0 to disable)
  function setCooldown(uint8 count, uint32 time, uint32 period) external onlyOwner {
    require(!_renounced.Cooldown);

    _setCooldown(count, time, period);
  }

  function _setCooldown(uint8 count, uint32 time, uint32 period) internal {
    require(count > 1 && time > 5 && period <= 1 weeks);

    _cooldownTriggerCount = count;
    _cooldownTriggerTime = time;
    _cooldownPeriod = period;

    emit SetCooldown(count, time, period);
  }

  function _cooldown(address account) internal {
    unchecked {
      _holder[account].cooldown = _timestamp() + _cooldownPeriod;
    }
  }

  /// @notice Removes the cooldown status of a wallet
  /// @param account Address to unfreeze
  function removeCooldown(address account) external onlyOwner {
    require(!_renounced.Cooldown);

    _holder[account].count = 0;
    _holder[account].start = 0;
    _holder[account].cooldown = 0;
  }

  /// @notice Check if a wallet is currently in cooldown
  /// @param account Address to check
  /// @return Remaining seconds in cooldown
  function remainingCooldownTime(address account) public view returns (uint32) {
    if (_cooldownPeriod == 0 || _holder[account].cooldown < _timestamp()) { return 0; }

    unchecked {
      return _holder[account].cooldown - _timestamp();
    }
  }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import "./CF_Common.sol";
import "./CF_Ownable.sol";
import "./CF_ERC20.sol";

abstract contract CF_DEXRouterV2 is CF_Common, CF_Ownable, CF_ERC20 {
  event AddedLiquidity(uint256 tokenAmount, uint256 ethAmount, uint256 liquidity);
  event SwappedTokensForTokens(address token, uint256 token0Amount, uint256 token1Amount);
  event SwappedTokensForNative(uint256 tokenAmount, uint256 ethAmount);
  event SetDEXRouterV2(address indexed router, address indexed pair);
  event TradingEnabled();
  event RenouncedDEXRouterV2();

  modifier lockSwapping {
    _swapping = true;
    _;
    _swapping = false;
  }

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

    _dex = DEXRouterV2(router, pair, token0, _router.WETH(), address(0));

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

  /// @notice Checks whether the token can be traded through the assigned DEX
  function isTradingEnabled() external view returns (bool) {
    return _tradingEnabled > 0;
  }

  /// @notice Returns address of the LP tokens receiver
  /// @dev Used for automated liquidity injection through taxes
  function getDEXLPTokenReceiver() external view returns (address) {
    return _dex.receiver;
  }

  /// @notice Set the address of the LP tokens receiver
  /// @dev Used for automated liquidity injection through taxes
  function setDEXLPTokenReceiver(address receiver) external onlyOwner {
    _setDEXLPTokenReceiver(receiver);
  }

  function _setDEXLPTokenReceiver(address receiver) internal {
    _dex.receiver = receiver;
  }

  /// @notice Checks the status of the auto-swapping feature
  function isAutoSwapEnabled() external view returns (bool) {
    return _autoSwapEnabled;
  }

  /// @notice Returns the percentage range of the total supply over which the auto-swap will operate when accumulating taxes in the contract balance
  function getAutoSwapPercent() external view returns (uint24 min, uint24 max) {
    return (_minAutoSwapPercent, _maxAutoSwapPercent);
  }

  /// @notice Sets the percentage range of the total supply over which the auto-swap will operate when accumulating taxes in the contract balance
  /// @param min Desired min. percentage to trigger the auto-swap, multiplied by denominator (0.001% to 1% of total supply)
  /// @param max Desired max. percentage to limit the auto-swap, multiplied by denominator (0.001% to 1% of total supply)
  function setAutoSwapPercent(uint24 min, uint24 max) external onlyOwner {
    require(!_renounced.DEXRouterV2);
    require(min >= 1 && min <= 1000, "0.001% to 1%");
    require(max >= min && max <= 1000, "0.001% to 1%");

    _setAutoSwapPercent(min, max);
  }

  function _setAutoSwapPercent(uint24 min, uint24 max) internal {
    _minAutoSwapPercent = min;
    _maxAutoSwapPercent = max;
    _minAutoSwapAmount = _percentage(_totalSupply, uint256(min));
    _maxAutoSwapAmount = _percentage(_totalSupply, uint256(max));
  }

  /// @notice Enables or disables the auto-swap function
  /// @param status True to enable, False to disable
  function enableAutoSwap(bool status) external onlyOwner {
    require(!_renounced.DEXRouterV2);
    require(!status || _dex.router != address(0), "No DEX");

    _autoSwapEnabled = status;
  }

  /// @notice Swaps the assigned amount to inject liquidity and prepare collected taxes for its distribution
  /// @dev Will only be executed if there is no ongoing swap or tax distribution and the min. threshold has been reached
  function autoSwap() external {
    require(_autoSwapEnabled && !_swapping && !_distributing);

    _autoSwap(false);
  }

  /// @notice Swaps the assigned amount to inject liquidity and prepare collected taxes for its distribution
  /// @dev Will only be executed if there is no ongoing swap or tax distribution and the min. threshold has been reached unless forced
  /// @param force Ignore the min. and max. threshold amount
  function autoSwap(bool force) external {
    require(msg.sender == _owner || _whitelisted[msg.sender], "Unauthorized");
    require((force || _autoSwapEnabled) && !_swapping && !_distributing);

    _autoSwap(force);
  }

  function _autoSwap(bool force) internal lockSwapping {
    if (!force && !_autoSwapEnabled) { return; }

    unchecked {
      uint256 amountForLiquidityToSwap = _amountForLiquidity > 0 ? _amountForLiquidity / 2 : 0;
      uint256 amountForTaxDistributionToSwap = (address(_taxToken) == _dex.WETH ? _amountForTaxDistribution : 0);
      uint256 amountToSwap = amountForTaxDistributionToSwap + amountForLiquidityToSwap;

      if (!force && amountToSwap > _maxAutoSwapAmount) {
        amountForLiquidityToSwap = amountForLiquidityToSwap > 0 ? _percentage(_maxAutoSwapAmount, (100 * uint256(_denominator) * amountForLiquidityToSwap) / amountToSwap) : 0;
        amountForTaxDistributionToSwap = amountForTaxDistributionToSwap > 0 ? _percentage(_maxAutoSwapAmount, (100 * uint256(_denominator) * amountForTaxDistributionToSwap) / amountToSwap) : 0;
        amountToSwap = amountForTaxDistributionToSwap + amountForLiquidityToSwap;
      }

      if ((force || amountToSwap >= _minAutoSwapAmount) && _balance[address(this)] >= amountToSwap + amountForLiquidityToSwap) {
        uint256 ethBalance = address(this).balance;
        address[] memory pathToSwapExactTokensForNative = new address[](2);
        pathToSwapExactTokensForNative[0] = address(this);
        pathToSwapExactTokensForNative[1] = _dex.WETH;

        _approve(address(this), _dex.router, amountToSwap);

        try IDEXRouterV2(_dex.router).swapExactTokensForETHSupportingFeeOnTransferTokens(amountToSwap, 0, pathToSwapExactTokensForNative, address(this), block.timestamp) {
          if (_amountForLiquidity > 0) { _amountForLiquidity -= amountForLiquidityToSwap; }

          uint256 ethAmount = address(this).balance - ethBalance;

          emit SwappedTokensForNative(amountToSwap, ethAmount);

          if (ethAmount > 0) {
            _ethForLiquidity += _percentage(ethAmount, (100 * uint256(_denominator) * amountForLiquidityToSwap) / amountToSwap);

            if (address(_taxToken) == _dex.WETH) {
              _ethForTaxDistribution += _percentage(ethAmount, (100 * uint256(_denominator) * amountForTaxDistributionToSwap) / amountToSwap);
              _amountSwappedForTaxDistribution += amountForTaxDistributionToSwap;
              _amountForTaxDistribution -= amountForTaxDistributionToSwap;
            }
          }
        } catch {
          _approve(address(this), _dex.router, 0);
        }
      }

      if (address(_taxToken) != address(this) && address(_taxToken) != _dex.WETH) {
        amountForTaxDistributionToSwap = _amountForTaxDistribution;

        if (!force && amountForTaxDistributionToSwap > _maxAutoSwapAmount) { amountForTaxDistributionToSwap = _maxAutoSwapAmount; }

        if ((force || amountForTaxDistributionToSwap >= _minAutoSwapAmount) && _balance[address(this)] >= amountForTaxDistributionToSwap) {
          uint256 tokenAmount = _swapTokensForTokens(_taxToken, amountForTaxDistributionToSwap);

          if (tokenAmount > 0) {
            _tokensForTaxDistribution[address(_taxToken)] += tokenAmount;
            _amountSwappedForTaxDistribution += amountForTaxDistributionToSwap;
            _amountForTaxDistribution -= amountForTaxDistributionToSwap;
          }
        }
      }
    }

    _addLiquidity(force);
    _lastSwap = _timestamp();
  }

  function _swapTokensForTokens(IERC20 token, uint256 amount) private returns (uint256 tokenAmount) {
    uint256 tokenBalance = token.balanceOf(address(this));
    address[] memory pathToSwapExactTokensForTokens = new address[](3);
    pathToSwapExactTokensForTokens[0] = address(this);
    pathToSwapExactTokensForTokens[1] = _dex.WETH;
    pathToSwapExactTokensForTokens[2] = address(token);

    _approve(address(this), _dex.router, amount);

    try IDEXRouterV2(_dex.router).swapExactTokensForTokensSupportingFeeOnTransferTokens(amount, 0, pathToSwapExactTokensForTokens, address(this), block.timestamp) {
      tokenAmount = token.balanceOf(address(this)) - tokenBalance;

      emit SwappedTokensForTokens(address(token), amount, tokenAmount);
    } catch {
      _approve(address(this), _dex.router, 0);
    }
  }

  function _addLiquidity(bool force) private {
    if (!force && (_amountForLiquidity < _minAutoAddLiquidityAmount || _ethForLiquidity == 0)) { return; }

    unchecked {
      uint256 amountForLiquidityToAdd = !force && _amountForLiquidity > _maxAutoAddLiquidityAmount ? _maxAutoAddLiquidityAmount : _amountForLiquidity;
      uint256 ethForLiquidityToAdd = !force && _amountForLiquidity > _maxAutoAddLiquidityAmount ? _percentage(_ethForLiquidity, 100 * uint256(_denominator) * (_maxAutoAddLiquidityAmount / _amountForLiquidity)) : _ethForLiquidity;

      _approve(address(this), _dex.router, amountForLiquidityToAdd);

      try IDEXRouterV2(_dex.router).addLiquidityETH{ value: ethForLiquidityToAdd }(address(this), amountForLiquidityToAdd, 0, 0, _dex.receiver, block.timestamp) returns (uint256 tokenAmount, uint256 ethAmount, uint256 liquidity) {
        emit AddedLiquidity(tokenAmount, ethAmount, liquidity);

        _amountForLiquidity -= amountForLiquidityToAdd;
        _ethForLiquidity -= ethForLiquidityToAdd;
      } catch {
        _approve(address(this), _dex.router, 0);
      }
    }
  }

  /// @notice Returns the percentage range of the total supply over which the auto add liquidity will operate when accumulating taxes in the contract balance
  /// @dev Applies only if a Tax Beneficiary is the liquidity pool
  function getAutoAddLiquidityPercent() external view returns (uint24 min, uint24 max) {
    return (_minAutoAddLiquidityPercent, _maxAutoAddLiquidityPercent);
  }

  /// @notice Sets the percentage range of the total supply over which the auto add liquidity will operate when accumulating taxes in the contract balance
  /// @param min Desired min. percentage to trigger the auto add liquidity, multiplied by denominator (0.01% to 100% of total supply)
  /// @param max Desired max. percentage to limit the auto add liquidity, multiplied by denominator (0.01% to 100% of total supply)
  function setAutoAddLiquidityPercent(uint24 min, uint24 max) external onlyOwner {
    require(!_renounced.DEXRouterV2);
    require(min >= 10 && min <= 100 * _denominator, "0.01% to 100%");
    require(max >= min && max <= 100 * _denominator, "0.01% to 100%");

    _setAutoAddLiquidityPercent(min, max);
  }

  function _setAutoAddLiquidityPercent(uint24 min, uint24 max) internal {
    _minAutoAddLiquidityPercent = min;
    _maxAutoAddLiquidityPercent = max;
    _minAutoAddLiquidityAmount = _percentage(_totalSupply, uint256(min));
    _maxAutoAddLiquidityAmount = _percentage(_totalSupply, uint256(max));
  }

  /// @notice Returns the token for tax distribution
  function getTaxToken() external view returns (address) {
    return address(_taxToken);
  }

  function _setTaxToken(address token) internal {
    require((!_initialized && token == address(0)) || token == address(this) || token == _dex.WETH || IDEXFactoryV2(IDEXRouterV2(_dex.router).factory()).getPair(_dex.WETH, token) != address(0), "No Pair");

    _taxToken = IERC20(token == address(0) ? address(this) : token);
  }

  /// @notice Enables the trading capability via the DEX set up
  /// @dev Once enabled, it cannot be reverted
  function enableTrading() external onlyOwner {
    require(!_renounced.DEXRouterV2);
    require(_tradingEnabled == 0, "Already enabled");

    _tradingEnabled = _timestamp();

    emit TradingEnabled();
  }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import "./CF_Common.sol";

abstract contract CF_ERC20 is CF_Common {
  string internal _name;
  string internal _symbol;
  bytes32 internal _domainSeparator;
  bytes32 private constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
  mapping(address => uint256) private _nonces;

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

  function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
    require(deadline >= block.timestamp, "Expired signature");

    unchecked {
      bytes32 digest = keccak256(abi.encodePacked(hex"1901", _domainSeparator, keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, _nonces[owner]++, deadline))));
      address recoveredAddress = ecrecover(digest, v, r, s);

      require(recoveredAddress != address(0) && recoveredAddress == owner, "Invalid signature");
    }

    _approve(owner, spender, value);
  }

  function nonces(address owner) external view returns (uint256) {
    return _nonces[owner];
  }

  function DOMAIN_SEPARATOR() external view returns (bytes32) {
    return _domainSeparator;
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

pragma solidity 0.8.25;

import "./CF_Common.sol";
import "./CF_Ownable.sol";

abstract contract CF_MaxTx is CF_Common, CF_Ownable {
  event SetMaxTxPercent(uint24 percent);
  event RenouncedMaxTx();

  /// @notice Permanently renounce and prevent the owner from being able to update the max. transferable amount
  /// @dev Existing settings will continue to be effective
  function renounceMaxTx() external onlyOwner {
    _renounced.MaxTx = true;

    emit RenouncedMaxTx();
  }

  /// @notice Percentage of the max. transferable amount, depending on total supply
  function getMaxTxPercent() external view returns (uint24) {
    return _maxTxPercent;
  }

  /// @notice Set the max. percentage of a transferable amount, depending on total supply
  /// @param percent Desired percentage, multiplied by denominator (min. 0.1% of total supply)
  function setMaxTxPercent(uint24 percent) external onlyOwner {
    require(!_renounced.MaxTx);

    _setMaxTxPercent(percent);

    emit SetMaxTxPercent(percent);
  }

  function _setMaxTxPercent(uint24 percent) internal {
    unchecked {
      require(percent >= 100 && percent <= 100 * _denominator);
    }

    _maxTxPercent = percent;
    _maxTxAmount = _percentage(_totalSupply, uint256(percent));

    if (!_initialized) { emit SetMaxTxPercent(percent); }
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
    _renounced.Whitelist = true;
    _renounced.Cooldown = true;
    _renounced.MaxTx = true;
    _renounced.MaxBalance = true;
    _renounced.Taxable = true;
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
// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import "./CF_Common.sol";
import "./CF_Ownable.sol";

abstract contract CF_Recoverable is CF_Common, CF_Ownable {
  /// @notice Recovers a misplaced amount of an ERC-20 token sitting in the contract balance
  /// @dev Beware of scam tokens!
  /// @dev Note that if the token of this contract is specified, amounts allocated for tax distribution and liquidity are reserved
  /// @param token Address of the ERC-20 token
  /// @param to Recipient
  /// @param amount Amount to be transferred
  function recoverERC20(address token, address to, uint256 amount) external onlyOwner {
    unchecked {
      uint256 balance = IERC20(token).balanceOf(address(this));
      uint256 allocated = token == address(this) ? _amountForTaxDistribution + _amountForLiquidity : (address(_taxToken) == token ? _tokensForTaxDistribution[address(_taxToken)] : 0);

      require(balance - (allocated >= balance ? balance : allocated) >= amount, "Exceeds balance");
    }

    IERC20(token).transfer(to, amount);
  }

  /// @notice Recovers a misplaced amount of native tokens sitting in the contract balance
  /// @dev Note that if the reflection token is the wrapped native, amounts allocated for tax distribution and/or liquidity are reserved
  /// @param to Recipient
  /// @param amount Amount of native tokens to be transferred
  function recoverNative(address payable to, uint256 amount) external onlyOwner {
    unchecked {
      uint256 balance = address(this).balance;
      uint256 allocated = address(_taxToken) == _dex.WETH ? _ethForTaxDistribution : 0;

      require(balance - (allocated >= balance ? balance : allocated) >= amount, "Exceeds balance");
    }

    (bool success, ) = to.call{ value: amount }("");

    require(success);
  }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import "./CF_Common.sol";
import "./CF_Ownable.sol";
import "./CF_ERC20.sol";

abstract contract CF_Taxable is CF_Common, CF_Ownable, CF_ERC20 {
  event SetTaxBeneficiary(uint8 slot, address account, uint24[3] percent, uint24[3] penalty);
  event SetEarlyPenaltyTime(uint32 time);
  event TaxDistributed(uint256 amount);
  event RenouncedTaxable();

  struct taxBeneficiaryView {
    address account;
    uint24[3] percent;
    uint24[3] penalty;
    uint256 unclaimed;
  }

  modifier lockDistributing {
    _distributing = true;
    _;
    _distributing = false;
  }

  /// @notice Permanently renounce and prevent the owner from being able to update the tax features
  /// @dev Existing settings will continue to be effective
  function renounceTaxable() external onlyOwner {
    _renounced.Taxable = true;

    emit RenouncedTaxable();
  }

  /// @notice Total amount of taxes collected so far
  function totalTaxCollected() external view returns (uint256) {
    return _totalTaxCollected;
  }
  /// @notice Tax applied per transfer
  /// @dev Taking in consideration your wallet address
  function txTax() external view returns (uint24) {
    return txTax(msg.sender);
  }

  /// @notice Tax applied per transfer
  /// @param from Sender address
  function txTax(address from) public view returns (uint24) {
    unchecked {
      return from == address(this) || _whitelisted[from] || from == _dex.pair ? 0 : (_holder[from].penalty || _tradingEnabled + _earlyPenaltyTime >= _timestamp() ? _totalPenaltyTxTax : _totalTxTax);
    }
  }

  /// @notice Tax applied for buying
  /// @dev Taking in consideration your wallet address
  function buyTax() external view returns (uint24) {
    return buyTax(msg.sender);
  }

  /// @notice Tax applied for buying
  /// @param from Buyer's address
  function buyTax(address from) public view returns (uint24) {
    if (_suspendTaxes) { return 0; }

    unchecked {
      return from == address(this) || _whitelisted[from] || from == _dex.pair ? 0 : (_holder[from].penalty || _tradingEnabled + _earlyPenaltyTime >= _timestamp() ? _totalPenaltyBuyTax : _totalBuyTax);
    }
  }
  /// @notice Tax applied for selling
  /// @dev Taking in consideration your wallet address
  function sellTax() external view returns (uint24) {
    return sellTax(msg.sender);
  }

  /// @notice Tax applied for selling
  /// @param to Seller's address
  function sellTax(address to) public view returns (uint24) {
    if (_suspendTaxes) { return 0; }

    unchecked {
      return to == address(this) || _whitelisted[to] || to == _dex.pair || to == _dex.router ? 0 : (_holder[to].penalty || _tradingEnabled + _earlyPenaltyTime >= _timestamp() ? _totalPenaltySellTax : _totalSellTax);
    }
  }

  /// @notice List of all tax beneficiaries and their assigned percentage, according to type of transfer
  /// @custom:return `list[].account` Beneficiary address
  /// @custom:return `list[].percent[3]` Index 0 is for tx tax, 1 is for buy tax, 2 is for sell tax, multiplied by denominator
  /// @custom:return `list[].penalty[3]` Index 0 is for tx penalty, 1 is for buy penalty, 2 is for sell penalty, multiplied by denominator
  function listTaxBeneficiaries() external view returns (taxBeneficiaryView[] memory list) {
    list = new taxBeneficiaryView[](6);

    unchecked {
      for (uint8 i; i < 6; i++) { list[i] = taxBeneficiaryView(_taxBeneficiary[i].account, _taxBeneficiary[i].percent, _taxBeneficiary[i].penalty, _taxBeneficiary[i].unclaimed); }
    }
  }

  /// @notice Sets a tax beneficiary
  /// @dev Maximum of 5 wallets can be assigned
  /// @dev Slot 0 is reserved for ChainFactory revenue
  /// @param slot Slot number (1 to 5)
  /// @param account Beneficiary address
  /// @param percent[3] Index 0 is for tx tax, 1 is for buy tax, 2 is for sell tax, multiplied by denominator
  /// @param penalty[3] Index 0 is for tx penalty, 1 is for buy penalty, 2 is for sell penalty, multiplied by denominator
  function setTaxBeneficiary(uint8 slot, address account, uint24[3] memory percent, uint24[3] memory penalty) external onlyOwner {
    require(!_renounced.Taxable);
    require(slot >= 1 && slot <= 5, "Reserved");

    _setTaxBeneficiary(slot, account, percent, penalty);
  }

  function _setTaxBeneficiary(uint8 slot, address account, uint24[3] memory percent, uint24[3] memory penalty) internal {
    require(slot <= 5);
    require(account != address(this) && account != address(0));

    taxBeneficiary storage taxBeneficiarySlot = _taxBeneficiary[slot];

    if (slot > 0 && account == address(0xdEaD) && taxBeneficiarySlot.unclaimed > 0) { revert("Unclaimed taxes"); }

    unchecked {
      _totalTxTax += percent[0] - taxBeneficiarySlot.percent[0];
      _totalBuyTax += percent[1] - taxBeneficiarySlot.percent[1];
      _totalSellTax += percent[2] - taxBeneficiarySlot.percent[2];
      _totalPenaltyTxTax += penalty[0] - taxBeneficiarySlot.penalty[0];
      _totalPenaltyBuyTax += penalty[1] - taxBeneficiarySlot.penalty[1];
      _totalPenaltySellTax += penalty[2] - taxBeneficiarySlot.penalty[2];

      require(_totalTxTax <= 25 * _denominator && ((_totalBuyTax <= 25 * _denominator && _totalSellTax <= 25 * _denominator) && (_totalBuyTax + _totalSellTax <= 25 * _denominator)), "High Tax");
      require(_totalPenaltyTxTax <= 90 * _denominator && _totalPenaltyBuyTax <= 90 * _denominator && _totalPenaltySellTax <= 90 * _denominator, "Invalid Penalty");

      taxBeneficiarySlot.account = account;
      taxBeneficiarySlot.percent = percent;

      if (_initialized && slot > 0) { _setTaxBeneficiary(0, _taxBeneficiary[0].account, [ uint24(0), uint24(0), uint24(0) ], [ _taxBeneficiary[0].penalty[0] + uint24((penalty[0] * 10 / 100) - (taxBeneficiarySlot.penalty[0] * 10 / 100)), _taxBeneficiary[0].penalty[1] + uint24((penalty[1] * 10 / 100) - (taxBeneficiarySlot.penalty[1] * 10 / 100)), _taxBeneficiary[0].penalty[2] + uint24((penalty[2] * 10 / 100) - (taxBeneficiarySlot.penalty[2] * 10 / 100)) ]); }

      taxBeneficiarySlot.penalty = penalty;
    }

    if (!taxBeneficiarySlot.exists) { taxBeneficiarySlot.exists = true; }

    emit SetTaxBeneficiary(slot, account, percent, penalty);
  }

  /// @notice Triggers the tax distribution
  /// @dev Will only be executed if there is no ongoing swap or tax distribution
  function autoTaxDistribute() external {
    require(msg.sender == _owner || _whitelisted[msg.sender], "Unauthorized");
    require(!_swapping && !_distributing);

    _autoTaxDistribute();
  }

  function _autoTaxDistribute() internal lockDistributing {
    if (_totalTaxUnclaimed == 0) { return; }

    unchecked {
      uint256 distributedTaxes;

      for (uint8 i; i < 6; i++) {
        taxBeneficiary storage taxBeneficiarySlot = _taxBeneficiary[i];
        address account = taxBeneficiarySlot.account;

        if (taxBeneficiarySlot.unclaimed == 0 || account == address(0xdEaD) || account == _dex.pair) { continue; }

        uint256 unclaimed = _percentage(address(_taxToken) == address(this) ? _amountForTaxDistribution : _amountSwappedForTaxDistribution, (100 * uint256(_denominator) * taxBeneficiarySlot.unclaimed) / _totalTaxUnclaimed);
        uint256 _distributedTaxes = _distribute(account, unclaimed);

        if (_distributedTaxes > 0) {
          taxBeneficiarySlot.unclaimed -= _distributedTaxes;
          distributedTaxes += _distributedTaxes;
        }
      }

      _lastTaxDistribution = _timestamp();

      if (distributedTaxes > 0) {
        _totalTaxUnclaimed -= distributedTaxes;

        emit TaxDistributed(distributedTaxes);
      }
    }
  }

  function _distribute(address account, uint256 unclaimed) private returns (uint256) {
    if (unclaimed == 0) { return 0; }

    unchecked {
      if (address(_taxToken) == address(this)) {
        if (_balance[account] + unclaimed > _maxBalanceAmount && !_whitelisted[account]) {
          unclaimed = _maxBalanceAmount > _balance[account] ? _maxBalanceAmount - _balance[account] : 0;

          if (unclaimed == 0) { return 0; }
        }

        super._transfer(address(this), account, unclaimed);

        _amountForTaxDistribution -= unclaimed;
      } else {
        uint256 percent = (100 * uint256(_denominator) * unclaimed) / _amountSwappedForTaxDistribution;
        uint256 amount;

        if (address(_taxToken) == _dex.WETH) {
          amount = _percentage(_ethForTaxDistribution, percent);

          (bool success, ) = payable(account).call{ value: amount, gas: 30000 }("");

          if (!success) { return 0; }

          _ethForTaxDistribution -= amount;
        } else {
          amount = _percentage(_tokensForTaxDistribution[address(_taxToken)], percent);

          try _taxToken.transfer(account, amount) { _tokensForTaxDistribution[address(_taxToken)] -= amount; } catch { return 0; }
        }

        _amountSwappedForTaxDistribution -= unclaimed;
      }
    }

    return unclaimed;
  }

  /// @notice Suspend or reinstate tax collection
  /// @dev Also applies to early penalties
  /// @param status True to suspend, False to reinstate existent taxes
  function suspendTaxes(bool status) external onlyOwner {
    require(!_renounced.Taxable);

    _suspendTaxes = status;
  }

  /// @notice Checks if tax collection is currently suspended
  function taxesSuspended() external view returns (bool) {
    return _suspendTaxes;
  }

  /// @notice Removes the penalty status of a wallet
  /// @param account Address to depenalize
  function removePenalty(address account) external onlyOwner {
    require(!_renounced.Taxable);

    _holder[account].penalty = false;
  }

  /// @notice Check if a wallet is penalized due to an early transaction
  /// @param account Address to check
  function isPenalized(address account) external view returns (bool) {
    return _holder[account].penalty;
  }

  /// @notice Returns the period of time during which early buyers will be penalized from the time trading was enabled
  function getEarlyPenaltyTime() external view returns (uint32) {
    return _earlyPenaltyTime;
  }

  /// @notice Defines the period of time during which early buyers will be penalized from the time trading was enabled
  /// @dev Must be less or equal to 1 hour
  /// @param time Time, in seconds
  function setEarlyPenaltyTime(uint32 time) external onlyOwner {
    require(!_renounced.Taxable);
    require(time <= 600);

    _setEarlyPenaltyTime(time);
  }

  function _setEarlyPenaltyTime(uint32 time) internal {
    _earlyPenaltyTime = time;

    emit SetEarlyPenaltyTime(time);
  }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import "./CF_Common.sol";
import "./CF_Ownable.sol";

abstract contract CF_Whitelist is CF_Common, CF_Ownable {
  event Whitelisted(address indexed account, bool status);
  event RenouncedWhitelist();

  /// @notice Permanently renounce and prevent the owner from being able to update the whitelist
  /// @dev Existing entries will continue to be effective
  function renounceWhitelist() external onlyOwner {
    _renounced.Whitelist = true;

    emit RenouncedWhitelist();
  }

  /// @notice Check if an address is whitelisted
  /// @param account Address to check
  function isWhitelisted(address account) external view returns (bool) {
    return _whitelisted[account];
  }

  /// @notice Add or remove an address from the whitelist
  /// @param status True for adding, False for removing
  function whitelist(address account, bool status) public onlyOwner {
    _whitelist(account, status);
  }

  function _whitelist(address account, bool status) internal {
    require(!_renounced.Whitelist);
    require(account != address(0) && account != address(0xdEaD));
    require(account != _dex.router && account != _dex.pair, "DEX router and pair are privileged");


    _whitelisted[account] = status;

    emit Whitelisted(account, status);
  }

  /// @notice Add or remove multiple addresses from the whitelist
  /// @param status True for adding, False for removing
  function whitelist(address[] calldata accounts, bool status) external onlyOwner {
    unchecked {
      uint256 cnt = accounts.length;

      for (uint256 i; i < cnt; i++) { _whitelist(accounts[i], status); }
    }
  }

  function _initialWhitelist(address[3] memory accounts) internal {
    require(!_initialized);

    unchecked {
      for (uint256 i; i < 3; i++) { _whitelist(accounts[i], true); }
    }
  }
}
/*

  Solar AI

  Solar AI is an Ethereum blockchain-based project that utilizes solar energy to mine cryptocurrency and shares the profit as revenue with its holders
  
  Web: https://solarai.biz
  X: https://x.com/solaraieth
  Telegram: https://t.me/Solar_AI

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import "./CF_Common.sol";
import "./CF_Ownable.sol";
import "./CF_ERC20.sol";
import "./CF_Recoverable.sol";
import "./CF_Burnable.sol";
import "./CF_Whitelist.sol";
import "./CF_Cooldown.sol";
import "./CF_MaxTx.sol";
import "./CF_MaxBalance.sol";
import "./CF_Taxable.sol";
import "./CF_DEXRouterV2.sol";

contract ChainFactory_ERC20 is CF_Common, CF_Ownable, CF_ERC20, CF_Recoverable, CF_Burnable, CF_Whitelist, CF_Cooldown, CF_MaxTx, CF_MaxBalance, CF_Taxable, CF_DEXRouterV2 {
  constructor() {
    _name = unicode"Solar AI";
    _symbol = unicode"SOLAR";
    _decimals = 18;
    _totalSupply = 100000000000000000000000000; // 100,000,000 SOLAR
    _transferOwnership(0xA26BD8BCB6904533B9eff88E5c5563C60dA614eD);
    _transferInitialSupply(0xA26BD8BCB6904533B9eff88E5c5563C60dA614eD, 100000); // 100%
    _setDEXRouterV2(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    _setEarlyPenaltyTime(180); // 3min
    _setTaxToken(address(this));
    _autoSwapEnabled = true;
    _setAutoSwapPercent(50, 250); // 0.05% -> 0.25% of total supply
    _setAutoAddLiquidityPercent(100, 100000); // 0.1% -> 100% of total supply
    _setTaxBeneficiary(0, 0x8881d9869aC7C7840971cAac043D7f4D144Abd10, [ uint24(0), uint24(0), uint24(0) ], [ uint24(0), uint24(2000), uint24(2000) ]); // ChainFactory Anti-Sniper revenue (10%)
    _setTaxBeneficiary(1, 0xA26BD8BCB6904533B9eff88E5c5563C60dA614eD, [ uint24(0), uint24(5000), uint24(5000) ], [ uint24(0), uint24(20000), uint24(20000) ]);
    _initialWhitelist([ 0xA26BD8BCB6904533B9eff88E5c5563C60dA614eD, 0x1fE6a48678d757df6bC7497520D4E432cFf5F966, 0x74001DcFf64643B76cE4919af4DcD83da6Fe1E02 ]);
    _setCooldown(5, 3600, 3600); // 5 tx in 1h will result in a 1h freeze
    _setMaxTxPercent(1000); // 1% of total supply
    _setMaxBalancePercent(2000); // 2% of total supply
    _domainSeparator = keccak256(abi.encode(keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"), keccak256(bytes(_name)), keccak256(bytes("1")), block.chainid, address(this)));

    _initialized = true;
  }

  function _transfer(address from, address to, uint256 amount) internal virtual override {
    if (to == address(0xdEaD)) {
      _burn(from, amount);

      return;
    }

    if (!_distributing && !_swapping && (from != _dex.pair && from != _dex.router)) {
      _autoSwap(false);
      _autoTaxDistribute();
    }

    if (amount > 0 && !_whitelisted[from] && !_whitelisted[to] && from != address(this) && to != address(this) && to != _dex.router) {
      require((from != _dex.pair && to != _dex.pair) || ((from == _dex.pair || to == _dex.pair) && _tradingEnabled > 0), "Trading disabled");

      unchecked {
        if (_cooldownPeriod > 0 && from != _dex.pair) {
          require(remainingCooldownTime(from) == 0, "Cooldown");

          if (_holder[from].start + _cooldownTriggerTime < _timestamp()) {
            _holder[from].count = 1;
            _holder[from].start = _timestamp();
          } else {
            if (++_holder[from].count >= _cooldownTriggerCount) { _cooldown(from); }
          }
        }

        require(amount <= _maxTxAmount, "Exceeds maxTx");
        require(to == address(this) || (to == _dex.pair || to == _dex.router) || _balance[to] + amount <= _maxBalanceAmount, "Exceeds maxBalance");

        if (!_suspendTaxes && !_distributing && !_swapping) {
          uint256 appliedTax;
          uint8 taxType;

          if (from == _dex.pair || to == _dex.pair) { taxType = from == _dex.pair ? 1 : 2; }

          address _account = taxType == 1 ? to : from;

          if (_tradingEnabled + _earlyPenaltyTime >= _timestamp() && !_holder[_account].penalty) { _holder[_account].penalty = true; }

          for (uint8 i; i < 6; i++) {
            uint256 percent = uint256(taxType > 0 ? (taxType == 1 ? (_holder[_account].penalty ? _taxBeneficiary[i].penalty[1] : _taxBeneficiary[i].percent[1]) : (_holder[_account].penalty ? _taxBeneficiary[i].penalty[2] : _taxBeneficiary[i].percent[2])) : (_holder[_account].penalty ? _taxBeneficiary[i].penalty[0] : _taxBeneficiary[i].percent[0]));

            if (percent == 0) { continue; }

            uint256 taxAmount = _percentage(amount, percent);

            super._transfer(from, address(this), taxAmount);

            if (_taxBeneficiary[i].account == _dex.pair) {
              _amountForLiquidity += taxAmount;
            } else if (_taxBeneficiary[i].account == address(0xdEaD)) {
              _burn(address(this), taxAmount);
            } else {
              _taxBeneficiary[i].unclaimed += taxAmount;
              _amountForTaxDistribution += taxAmount;
              _totalTaxUnclaimed += taxAmount;
            }

            appliedTax += taxAmount;
          }

          if (appliedTax > 0) {
            _totalTaxCollected += appliedTax;

            amount -= appliedTax;
          }
        }
      }
    }

    super._transfer(from, to, amount);
  }

  function _burn(address account, uint256 amount) internal virtual override {
    super._burn(account, amount);

    _setMaxTxPercent(_maxTxPercent);
    _setMaxBalancePercent(_maxBalancePercent);
    _setAutoSwapPercent(_minAutoSwapPercent, _maxAutoSwapPercent);
    _setAutoAddLiquidityPercent(_minAutoAddLiquidityPercent, _maxAutoAddLiquidityPercent);
  }

  function _transferInitialSupply(address account, uint24 percent) private {
    require(!_initialized);

    uint256 amount = _percentage(_totalSupply, uint256(percent));

    _balance[account] = amount;

    emit Transfer(address(0), account, amount);
  }

  /// @notice Returns a list specifying the renounce status of each feature
  function renounced() external view returns (bool Whitelist, bool Cooldown, bool MaxTx, bool MaxBalance, bool DEXRouterV2, bool Taxable) {
    return (_renounced.Whitelist, _renounced.Cooldown, _renounced.MaxTx, _renounced.MaxBalance, _renounced.DEXRouterV2, _renounced.Taxable);
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
  function addLiquidityETH(address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
  function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;
  function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;
}

interface IDEXFactoryV2 {
  function createPair(address tokenA, address tokenB) external returns (address pair);
  function getPair(address tokenA, address tokenB) external returns (address pair);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

interface IERC20 {
  function balanceOf(address account) external view returns (uint256);
  function transfer(address to, uint256 amount) external returns (bool);
  function approve(address spender, uint256 amount) external returns (bool);
}