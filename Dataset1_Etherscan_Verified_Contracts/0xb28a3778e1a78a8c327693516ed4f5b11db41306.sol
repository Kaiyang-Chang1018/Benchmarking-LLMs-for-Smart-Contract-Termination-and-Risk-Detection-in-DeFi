// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
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
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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
     _    _ _    ____ _____ ____  _
    / \  | | |_ / ___|_   _|  _ \| |
   / _ \ | | __| |     | | | |_) | |
  / ___ \| | |_| |___  | | |  _ <| |___
 /_/   \_\_|\__|\____| |_| |_| \_\_____|

 Website: https://altctrl.com/
 Telegram: https://t.me/OffcialAltCTRL/
 X: https://x.com/OfficialAltCTRL/
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    event Transfer(address indexed sender, address indexed recipient, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract AltCTRL is IERC20, Ownable {
    /* ========== EVENTS ========== */
    event SwapSettingsUpdated(uint256 newThreshold, uint256 newMaxAmount);
    event TaxCollectorUpdated(address newCollector);
    event ExemptFromTaxes(address account, bool enabled);

    /* ========== STATE VARIABLES ========== */
    string private constant _name = "AltCTRL";
    string private constant _symbol = "CTRL";
    uint8 private constant _decimals = 9;
    uint256 private constant _totalSupply = 42_000_000 * 10 ** _decimals;

    uint256 private _swapLocked = 1;
    uint256 private _swapThreshold = (_totalSupply * 5) / 10_000;
    uint256 private _maxSwapAmount = (_totalSupply * 5) / 1_000;

    IUniswapV2Router02 private immutable _dexRouter;
    address private immutable _liquidityPool;

    uint256 private constant _buyTax = 300;
    uint256 private constant _sellTax = 500;
    address payable public taxCollector;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _taxExempt;

    /* ========== ERRORS ========== */
    error Reentrancy();

    /* ========== CONSTRUCTOR ========== */
    constructor(address payable _taxCollector, address routerAddress) Ownable(msg.sender) {
        require(_taxCollector != address(0), "Invalid address");
        taxCollector = _taxCollector;

        _taxExempt[0x000000000000000000000000000000000000dEaD] = true;
        _taxExempt[address(this)] = true;
        _taxExempt[msg.sender] = true;
        _taxExempt[_taxCollector] = true;

        _dexRouter = IUniswapV2Router02(routerAddress);
        _liquidityPool = IUniswapV2Factory(_dexRouter.factory()).createPair(address(this), _dexRouter.WETH());

        _balances[msg.sender] = _totalSupply;
        _allowances[address(this)][address(_dexRouter)] = type(uint256).max;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    /* ========== MODIFIERS ========== */
    modifier lockTheSwap() virtual {
        if (_swapLocked == 2) revert Reentrancy();

        _swapLocked = 2;
        _;
        _swapLocked = 1;
    }

    /* ========== VIEW FUNCTIONS ========== */
    function name() external pure override returns (string memory) {
        return _name;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external pure override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function isTaxExempt(address account) external view returns(bool) {
        return _taxExempt[account];
    }

    function getPoolAddress() external view returns (address) {
        return _liquidityPool;
    }

    /* ========== PRIVATE FUNCTIONS ========== */
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: Approve from zero address");
        require(spender != address(0), "ERC20: Approve to zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "Transfer from zero address");
        require(recipient != address(0), "Transfer to zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "Insufficient balance");

        bool isExcluded = _taxExempt[sender] || _taxExempt[recipient];
        bool isLiquidityPool = sender == _liquidityPool || recipient == _liquidityPool;
        uint256 transferAmount = amount;

        if (!isExcluded && isLiquidityPool) {
            uint256 transactionTax = _buyTax;
            if (recipient == _liquidityPool) {
                transactionTax = _sellTax;
            }

            uint256 taxAmount = (amount * transactionTax) / 10_000;
            if (taxAmount > 0) {
                _balances[address(this)] += taxAmount;
                emit Transfer(sender, address(this), taxAmount);

                transferAmount -= taxAmount;
            }
        }

        _balances[sender] -= amount;
        _balances[recipient] += transferAmount;
        emit Transfer(sender, recipient, transferAmount);
    }

    function _swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _dexRouter.WETH();

        _dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            taxCollector,
            block.timestamp
        );
    }

    /* ========== EXTERNAL FUNCTIONS ========== */
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        }

        _transfer(sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    receive() external payable {}

    /* ========== OWNER FUNCTIONS ========== */
    function setSwapSettings(uint256 threshold, uint256 maxAmount) external onlyOwner {
        require(threshold > 0, "Invalid threshold");
        require(maxAmount > 0, "Invalid max amount");

        _swapThreshold = (_totalSupply * threshold) / 10_000;
        _maxSwapAmount = (_totalSupply * maxAmount) / 1_000;

        emit SwapSettingsUpdated(_swapThreshold, _maxSwapAmount);
    }

    function setTaxCollector(address payable _taxCollector) external onlyOwner {
        require(_taxCollector != address(0), "Invalid address");

        taxCollector = _taxCollector;
        emit TaxCollectorUpdated(_taxCollector);
    }

    function setTaxExempt(address account, bool enabled) external onlyOwner {
        require(account != address(0), "Invalid address");

        _taxExempt[account] = enabled;
        emit ExemptFromTaxes(account, enabled);
    }

    function triggerSwap() external onlyOwner {
        uint256 contractBalance = _balances[address(this)];
        if (contractBalance >= _swapThreshold) {
            if (contractBalance > _maxSwapAmount) {
                contractBalance = _maxSwapAmount;
            }

            _swapTokensForEth(contractBalance);
        }
    }
}