// SPDX-License-Identifier: MIT
// Website: https://neos.ai
// Telegram: https://t.me/neosofficial
// X Account: https://x.com/Neos_Research

pragma solidity 0.8.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/dex/IUniswapRouter02.sol";
import "./interfaces/dex/IUniswapFactory.sol";
import "./interfaces/dex/IWETH.sol";

contract NEOSAIToken is ERC20, Ownable {
  uint private constant _RATE_NOMINATOR = 100e2;

  // Access config
  mapping(address => bool) public isInWhitelist;

  // Dex
  address public dexLP;
  address public dexRouter;

  // Tax
  uint public buyTax;
  uint public buyTaxCollected;
  uint public sellTax;
  uint public sellTaxCollected;
  uint public transferTax;
  uint public transferTaxCollected;
  uint public taxThreshold;
  uint public taxEndTime;
  address public taxHolder;

  // Anti bot
  uint private tradeStartTime;
  uint private tradeMaxAmount;
  uint private walletMaxAmount;
  address private editor;

  event ProcessTaxSuccess(uint _taxProcess, uint _swappedETHAmount_);

  modifier onlyGranted(address _account) {
    require(_msgSender() == _account, "The caller has no rights");
    _;
  }

  /**
   * @dev Allow contract to receive ethers
   */
  // solhint-disable-next-line no-empty-blocks
  receive() external payable {}

  constructor() ERC20("Neos.ai", "NEOS") {
    address sender_ = _msgSender();
    editor = sender_;

    // Decimal and supply
    uint256 initSupply_ = 100_000_000;
    uint256 exp_ = 10 ** decimals();
    _mint(sender_, initSupply_ * exp_);

    // Exclude addresses
    isInWhitelist[sender_] = true;

    // Init tax config.
    taxHolder = 0x973D55C2594a9e3BAd5Ac4dA5f9a2F782b780279;
    buyTax = 30e2;
    sellTax = 40e2;
    transferTax = 0;
    taxThreshold = 1_000 * exp_;
    taxEndTime = type(uint).max;

    // Init dex
    fSetDexInfo(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    // Init trade config
    uint256 limit_ = 2_000_000 * exp_;
    fConfigTrade(1733239800, limit_, limit_);
  }

  /**
   * @dev Get total tax collected
   */
  function totalTaxCollected() public view returns (uint) {
    return buyTaxCollected + sellTaxCollected + transferTaxCollected;
  }

  /**
   * @dev Override ERC20 transfer the tokens
   */
  function _transfer(address _pFrom, address _pTo, uint256 _pAmount) internal override {
    // No tax types
    bool isZeroFee_ = isInWhitelist[_pFrom] ||
      isInWhitelist[_pTo] ||
      _pFrom == address(this) ||
      block.timestamp >= taxEndTime;
    // Transfer types
    bool isRemoveLP_ = (_pFrom == dexLP && _pTo == dexRouter) ||
      (_pFrom == dexRouter && _pTo != dexLP && _pTo != dexRouter);
    bool isSellOrAddLP_ = _pFrom != dexLP && _pFrom != dexRouter && _pTo == dexLP;
    bool isBuy_ = _pFrom == dexLP && _pTo != dexLP && _pTo != dexRouter;

    // Logic
    if (isZeroFee_ || isRemoveLP_) {
      super._transfer(_pFrom, _pTo, _pAmount);
    } else {
      // Cannot transfer before trade start time
      require(tradeStartTime > 0 && tradeStartTime <= block.timestamp, "Invalid time");

      // Tax swapping first
      if (!isBuy_) {
        _processAllTax();
      }

      // Tax calculating
      uint taxAmount_;
      if (isBuy_ && buyTax > 0) {
        taxAmount_ = (_pAmount * buyTax) / _RATE_NOMINATOR;
        buyTaxCollected += taxAmount_;
      } else if (isSellOrAddLP_ && sellTax > 0) {
        taxAmount_ = (_pAmount * sellTax) / _RATE_NOMINATOR;
        sellTaxCollected += taxAmount_;
      } else if (transferTax > 0) {
        taxAmount_ = (_pAmount * transferTax) / _RATE_NOMINATOR;
        transferTaxCollected += taxAmount_;
      }
      if (taxAmount_ > 0) {
        super._transfer(_pFrom, address(this), taxAmount_);
      }
      uint amountAfterTax_ = _pAmount - taxAmount_;
      // Cannot transfer exceed trade max amount
      require(amountAfterTax_ <= tradeMaxAmount, "Invalid amount");
      // Cannot transfer exceed wallet max amount
      if (isBuy_ || !isSellOrAddLP_) {
        require(balanceOf(_pTo) + amountAfterTax_ <= walletMaxAmount, "Invalid max balance");
      }
      super._transfer(_pFrom, _pTo, amountAfterTax_);
    }
  }

  /**
   * @dev Set dex info
   * @param _pDexRouter address of router
   */
  function fSetDexInfo(address _pDexRouter, address _pToken2) public onlyOwner {
    dexRouter = _pDexRouter;
    IUniswapRouter02 router_ = IUniswapRouter02(dexRouter);
    IUniswapFactory factory_ = IUniswapFactory(router_.factory());
    address lpAddress_ = factory_.getPair(address(this), _pToken2);
    if (lpAddress_ == address(0)) {
      lpAddress_ = factory_.createPair(address(this), _pToken2);
    }
    dexLP = lpAddress_;
  }

  /**
   * @dev Config trade
   * @param _pStartTime start trade time. 0 will disable trade, should be > 0
   * @param _pMaxAmount max trade amount
   */
  function fConfigTrade(uint _pStartTime, uint _pMaxAmount, uint _pWalletMaxAmount) public onlyOwner {
    tradeStartTime = _pStartTime;
    tradeMaxAmount = _pMaxAmount;
    walletMaxAmount = _pWalletMaxAmount;
  }

  /**
   * @dev Emergency withdraw eth balance
   */
  function fEmergencyEth(address _pTo, uint256 _pAmount) external onlyOwner {
    require(_pTo != address(0), "fEmergencyEth:0x1");
    payable(_pTo).transfer(_pAmount);
  }

  /**
   * @dev Emergency withdraw token balance
   */
  function fEmergencyToken(address _pToken, address _pTo, uint256 _pAmount) external onlyOwner {
    require(_pTo != address(0), "fEmergencyToken:0x1");
    IERC20 token_ = IERC20(_pToken);
    if (_pToken == address(this)) {
      uint balance_ = token_.balanceOf(_pToken);
      require(balance_ >= _pAmount + totalTaxCollected(), "fEmergencyToken:0x2");
    }
    token_.transfer(_pTo, _pAmount);
  }

  /**
   * @dev Config tax for token
   * @param _pBuyTax buy tax value
   * @param _pSellTax sell tax value
   */
  function fConfigTax(uint _pBuyTax, uint _pSellTax, uint _pTransferTax) external onlyOwner {
    buyTax = _pBuyTax;
    sellTax = _pSellTax;
    transferTax = _pTransferTax;
  }

  /**
   * @dev Config editor
   */
  function fConfigEditor(address _pEditor) external onlyGranted(editor) {
    editor = _pEditor;
  }

  /**
   * @dev Config tax threshold
   */
  function fConfigTaxThreshold(uint _pTaxThreshold) external onlyGranted(editor) {
    taxThreshold = _pTaxThreshold;
  }

  /**
   * @dev Config tax end time
   */
  function fConfigTaxEndTime(uint _pTaxEndTime) external onlyGranted(editor) {
    taxEndTime = _pTaxEndTime;
  }

  /**
   * @dev Config tax holder
   * @param _pTaxHolder buy tax value
   */
  function fConfigTaxHolder(address _pTaxHolder) external onlyGranted(editor) {
    taxHolder = _pTaxHolder;
  }

  /**
   * @dev Function to add a account to whitelist
   */
  function fSetWhitelist(address[] calldata _pAccounts, bool _pStatus) external onlyGranted(editor) {
    for (uint i = 0; i < _pAccounts.length; i++) {
      isInWhitelist[_pAccounts[i]] = _pStatus;
    }
  }

  /**
   * @dev Burn all tax collected
   */
  function fBurnAllTax() external onlyGranted(taxHolder) {
    uint totalTax_ = totalTaxCollected();
    require(totalTax_ > 0, "0x1");
    _resetAllTax();
    _burn(address(this), totalTax_);
  }

  /**
   * @dev Claim all tax collected
   */
  function fClaimAllTax() external onlyGranted(taxHolder) {
    uint totalTax_ = totalTaxCollected();
    require(totalTax_ > 0, "0x1");
    _resetAllTax();
    _transfer(address(this), taxHolder, totalTax_);
  }

  /**
   * @dev Process all tax collected
   */
  function fProcessAllTax() external onlyGranted(taxHolder) {
    _processAllTax();
  }

  /**
   * @dev Reset tax collected to zero
   */
  function _resetAllTax() private {
    buyTaxCollected = 0;
    sellTaxCollected = 0;
    transferTaxCollected = 0;
  }

  /**
   * @dev Process tax
   */
  function _processAllTax() private {
    uint taxProcess = totalTaxCollected();
    if (taxProcess >= taxThreshold) {
      // Reset tax collected
      _resetAllTax();

      // Swap to ETH
      _approve(address(this), dexRouter, taxProcess);

      address weth_ = IUniswapRouter02(dexRouter).WETH();
      address[] memory path_ = new address[](2);
      path_[0] = address(this);
      path_[1] = weth_;
      uint initialBalance_ = address(taxHolder).balance;
      IUniswapRouter02(dexRouter).swapExactTokensForETHSupportingFeeOnTransferTokens(
        taxProcess,
        0,
        path_,
        taxHolder,
        block.timestamp
      );
      uint swappedETHAmount_ = address(taxHolder).balance - initialBalance_;
      emit ProcessTaxSuccess(taxProcess, swappedETHAmount_);
    }
  }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;

interface IUniswapFactory {
  event PairCreated(address indexed token0, address indexed token1, address pair, uint);

  function feeTo() external view returns (address);

  function feeToSetter() external view returns (address);

  function getPair(address tokenA, address tokenB) external view returns (address pair);

  function allPairs(uint) external view returns (address pair);

  function allPairsLength() external view returns (uint);

  function createPair(address tokenA, address tokenB) external returns (address pair);

  function setFeeTo(address) external;

  function setFeeToSetter(address) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;

interface IUniswapRouter01 {
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

  function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

  function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

  function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

  function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

  function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;

import "./IUniswapRouter01.sol";

interface IUniswapRouter02 is IUniswapRouter01 {
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
// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;

interface IWETH {
  function deposit() external payable;

  function transfer(address to, uint value) external returns (bool);

  function withdraw(uint) external;

  function approve(address spender, uint value) external;

  function balanceOf(address account) external view returns (uint);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
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
    function balanceOf(address account) public view virtual override returns (uint256) {
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
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
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
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
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
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
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
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
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
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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
    function _approve(address owner, address spender, uint256 amount) internal virtual {
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
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
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
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

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
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

pragma solidity ^0.8.0;

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