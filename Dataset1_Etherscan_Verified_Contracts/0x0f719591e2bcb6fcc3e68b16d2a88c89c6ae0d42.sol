// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/**
 * @dev Collection of functions related to the address type,
 * adapted from OpenZeppelin's Address library under the MIT license.
 */
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance for send");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token contract returns false).
 * Supports non-compliant tokens that do not return a boolean.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: operation did not succeed");
        }
    }
}

interface IUniswapV2Router02 {
    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function getAmountsOut(
        uint256 amountIn, 
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
}

/**
 * @dev Provides information about the current execution context.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @title Ownable2Step
 * @dev A modified two-step ownership model where a new owner must accept the ownership transfer.
 */
abstract contract Ownable2Step is Context {
    address private _owner;
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed currentOwner, address indexed pendingOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable2Step: caller is not the owner");
        _;
    }

    /**
     * @dev Initiates a transfer of ownership to a new account (`newOwner`), but the newOwner must accept the transfer.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable2Step: new owner is zero address");
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(_owner, newOwner);
    }

    /**
     * @dev The new pending owner calls this function to accept the ownership transfer.
     */
    function acceptOwnership() public virtual {
        require(_msgSender() == _pendingOwner, "Ownable2Step: caller is not the pending owner");
        _transferOwnership(_pendingOwner);
        _pendingOwner = address(0);
    }

    /**
     * @dev Transfers ownership to `newOwner`.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner_, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

/**
 * @title ERC20 Implementation
 * @dev Standard ERC20 token mechanics
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeERC20 for IERC20; // Not strictly required here, but available if needed

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner_ = _msgSender();
        _transfer(owner_, to, amount);
        return true;
    }

    function allowance(address owner_, address spender) public view virtual override returns (uint256) {
        return _allowances[owner_][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner_ = _msgSender();
        _approve(owner_, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner_ = _msgSender();
        _approve(owner_, spender, allowance(owner_, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner_ = _msgSender();
        uint256 currentAllowance = allowance(owner_, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner_, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from zero address");
        require(to != address(0), "ERC20: transfer to zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to zero address");

        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner_, address spender, uint256 amount) internal virtual {
        require(owner_ != address(0), "ERC20: approve from zero address");
        require(spender != address(0), "ERC20: approve to zero address");

        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }

    function _spendAllowance(address owner_, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner_, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner_, spender, currentAllowance - amount);
            }
        }
    }
}

/**
 * @title EVOLVE
 * @dev ERC20 token with fee and manual swap logic, plus two-step ownership and safe ETH transfer.
 */
contract EVOLVE is ERC20, Ownable2Step {
    using SafeERC20 for IERC20;

    uint256 public constant initialTotalSupply = 42 * 1e9 * 1e18;
    IUniswapV2Router02 public constant _uniswapV2Router =
        IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    address public taxWallet;
    uint256 public swapTokensAtAmount;  // Reference only, not used in automatic swaps
    uint256 public sellFee = 45;

    // Fee exclusions and AMM pairs
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) private automatedMarketMakerPairs;

    // Slippage tolerance for manual swaps
    uint256 public slippageTolerance = 5;

    /**
     * @dev Events for transparency in critical state changes
     */
    event AutomatedMarketMakerPairUpdated(address indexed pair, bool indexed value);
    event ExcludedFromFees(address indexed account, bool indexed isExcluded);
    event SwapTokensAtAmountUpdated(uint256 newAmount);
    event SellFeeUpdated(uint256 newFee);
    event TaxWalletUpdated(address indexed newTaxWallet);
    event SlippageToleranceUpdated(uint256 newSlippageTolerance);

    constructor() ERC20("Evolve Network", "EVOLVE") {
        // Pre-approve an unlimited amount of tokens for the router
        _approve(address(this), address(_uniswapV2Router), type(uint256).max);

        // Exclude this contract from fees
        _isExcludedFromFees[address(this)] = true;

        // Set the default tax wallet
        _setTaxWallet(0x4049F1A5881E39994b6b27Fbb6F0bEb86fA067FA);

        // Mint total supply to the owner (the deployer)
        _mint(owner(), initialTotalSupply);
    }

    /**
     * @notice Transfers tokens with fee logic if it's a sell to an AMM.
     */
    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from zero address");
        require(to != address(0), "ERC20: transfer to zero address");

        // If not excluded from fees and selling to an AMM, take the fee
        if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            if (automatedMarketMakerPairs[to]) {
                // Sell scenario
                uint256 fees = (amount * sellFee) / 100;
                if (fees > 0) {
                    super._transfer(from, address(this), fees);
                    amount -= fees;
                }
            }
        }

        // Final transfer after fees
        super._transfer(from, to, amount);
    }

    /**
     * @notice Allows the owner to lower (but never increase) the sell fee.
     */
    function lowerFees(uint256 _sellFee) external onlyOwner {
        require(_sellFee <= sellFee, "Can only lower fees!");
        sellFee = _sellFee;
        emit SellFeeUpdated(_sellFee);
    }

    /**
     * @notice Enables the owner to retrieve any ETH in the contract using .call().
     */
    function retrieveStuckEth() external onlyOwner {
        uint256 contractBalance = address(this).balance;
        (bool success, ) = payable(taxWallet).call{value: contractBalance}("");
        require(success, "Payment failed");
    }

    /**
     * @notice Enables the owner to retrieve ERC20 tokens, even non-standard ones like USDT.
     * Uses SafeERC20 to ensure compatibility.
     */
    function retrieveStuckToken(address tokenAddress) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        token.safeTransfer(taxWallet, balance);
    }

    /**
     * @notice Allows the owner to designate or revoke an address as an AMM pair.
     */
    function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
        automatedMarketMakerPairs[pair] = value;
        emit AutomatedMarketMakerPairUpdated(pair, value);
    }

    /**
     * @notice Excludes or includes an account in fee deductions.
     */
    function excludeFromFees(address account, bool excluded) external onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludedFromFees(account, excluded);
    }

    /**
     * @notice Sets an arbitrary token threshold (no longer used for auto-swaps).
     */
    function setSwapTokensAtAmount(uint256 _amount) external onlyOwner {
        swapTokensAtAmount = _amount;
        emit SwapTokensAtAmountUpdated(_amount);
    }

    /**
     * @notice Allows the owner to change the tax wallet, ensuring it's not the zero address.
     */
    function setTaxWallet(address _taxWallet) external onlyOwner {
        require(_taxWallet != address(0), "Tax wallet cannot be zero address");
        _setTaxWallet(_taxWallet);
        emit TaxWalletUpdated(_taxWallet);
    }

    /**
     * @notice Owner-only function to swap a specified amount of the contract’s token balance for ETH.
     * @param tokenAmount The amount of tokens to swap.
     */
    function swapContractTokensForETH(uint256 tokenAmount) external onlyOwner {
        require(tokenAmount > 0, "Cannot swap zero amount");
        uint256 contractTokenBalance = balanceOf(address(this));
        require(contractTokenBalance >= tokenAmount, "Not enough tokens in the contract");

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapV2Router.WETH();

        // Fetch the expected output using Uniswap's getAmountsOut
        uint256[] memory amountsOut = _uniswapV2Router.getAmountsOut(tokenAmount, path);
        uint256 expectedETH = amountsOut[1];

        // Calculate the minimum ETH amount after applying slippage tolerance
        uint256 minAmountOut = expectedETH - ((expectedETH * slippageTolerance) / 100);

        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            minAmountOut,
            path,
            taxWallet,
            block.timestamp
        );
    }

    /**
     * @notice Allows the owner to update the slippage tolerance used in swaps.
     * @param _slippageTolerance The new slippage tolerance as a percentage (0-100).
     */
    function setSlippageTolerance(uint256 _slippageTolerance) external onlyOwner {
        require(_slippageTolerance <= 100, "Slippage cannot exceed 100%");
        slippageTolerance = _slippageTolerance;
        emit SlippageToleranceUpdated(_slippageTolerance);
    }

    /**
     * @notice Internal function to set the tax wallet and exclude it from fees.
     */
    function _setTaxWallet(address _taxWallet) private {
        taxWallet = _taxWallet;
        _isExcludedFromFees[taxWallet] = true;
    }

    receive() external payable {}
}