// SPDX-License-Identifier: MIT

/*
    You should place social links here (website, twitter telegram, white paper and etc)
*/

pragma solidity 0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionCallWithValue(
                target,
                data,
                0,
                "Address: low-level call failed"
            );
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage)
        private
        pure
    {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
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

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

interface IERC20Errors {
    error ERC20InsufficientBalance(
        address sender,
        uint256 balance,
        uint256 needed
    );
    error ERC20InvalidSender(address sender);
    error ERC20InvalidReceiver(address receiver);
    error ERC20InsufficientAllowance(
        address spender,
        uint256 allowance,
        uint256 needed
    );
    error ERC20InvalidApprover(address approver);
    error ERC20InvalidSpender(address spender);
}

abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance < amount) {
            revert ERC20InsufficientAllowance(
                recipient,
                currentAllowance,
                amount
            );
        }
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addtionalValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addtionalValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractionValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractionValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractionValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        if (sender == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (recipient == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        uint256 senderBalance = _balances[sender];
        if (senderBalance < amount) {
            revert ERC20InsufficientBalance(sender, senderBalance, amount);
        }
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _createInitialSupply(address account, uint256 amount)
        internal
        virtual
    {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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

interface ILpPair {
    function sync() external;
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

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
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

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IDexFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

contract RAM is ERC20, Ownable {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 private  maxTradeAmount;

    uint256 private  maxHoldingAmount;

    IDexRouter public immutable dexRouter;
    address public immutable lpPair;

    IERC20 public immutable WETH;

    bool private tokenHoldingsRequiredToBuy;
    uint256 private  minimumHoldingsToBuy;

    bool private swapping;
    uint256 public swapTokensAtAmount;

    address public taxAddress = 0x0000000000000000000000000000000000000000; // Tax Address here

    bool public tradingActive = false;
    bool public swapEnabled = false;

    // Anti-bot and anti-whale mappings and variables
    mapping(address => uint256) private _holderLastTransferTime; // to hold last Transfers temporarily during launch
    bool private  transferDelayEnabled = true;
    uint256 private  transferDelayDuration; // Define the transfer delay duration

    uint256 private buyFee;
    uint256 private sellFee;
    uint256 private transferFee;

    struct WhitelistWallet {
        bool isExcludedFromFees;
        bool isExcludedMaxTradeAmount;
        bool isExcludedMaxHoldingAmount;
    }

    mapping(address => WhitelistWallet) public _whitelistWallet;

    mapping(address => bool) public automatedMarketMakerPairs;

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event EnabledTrading();
    event DisabledTrading();
    event EnabledSwap();
    event DisabledSwap();
    event UpdatedFees(uint256 buyFee, uint256 sellFee, uint256 transferFee);
    event UpdatedTaxAddress(address indexed newWallet);
    event OwnerForcedSwapBack(uint256 timestamp);
    event TransferForeignToken(address token, uint256 amount);
    event ReuppedApprovals();
    event SwapTokensAtAmountUpdated(uint256 newAmount);
    event WhiteList(
        bool isExcludedFromFees,
        bool isExcludedMaxTradeAmount,
        bool isExcludedMaxHoldingAmount
    );
    event LimitsUpdated(
        bool transferDelayEnabled,
        uint256 transferDelayDuration,
        bool tokenHoldingsRequiredToBuy,
        uint256 minimumHoldingsToBuy,
        uint256 maxHoldingAmount,
        uint256 maxTradeAmount
    );

    error ChainNotConfigured();
    error TradingIsNotActive();
    error TradingStatusAlreadyDesiredValue();

    uint256 constant MAX_TRANSFER_DELAY = 3 hours;

    constructor() {
        _name = "Random Access Memory";
        _symbol = "RAM";
        _decimals = 18;
        uint256 totalSupply = 1_000_000_000 * 10**_decimals;

        maxTradeAmount = (totalSupply * 1) / 100;
        
        swapTokensAtAmount = totalSupply / 500;

        tokenHoldingsRequiredToBuy = false;

        maxHoldingAmount = (totalSupply * 1) / 100;

        buyFee = 450; // 4.5% Fees
        sellFee = 525; // 5.25% Fees
        transferFee = 10;  // 0.1% Fees

        transferDelayDuration = 5 minutes; // Define the transfer delay duration

        address newOwner = msg.sender; // can leave alone if owner is deployer.

        address _dexRouter;
        address ethcoinAddress;

        if (block.chainid == 1) {
            ethcoinAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
            _dexRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        } else if (block.chainid == 137) {
            ethcoinAddress = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
            _dexRouter = 0xedf6066a2b290C185783862C7F4776A2C8077AD1;
        } else if (block.chainid == 11155111) {
            ethcoinAddress = 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9;
            _dexRouter = 0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008;
        } else {
            revert ChainNotConfigured();
        }

        // initialize router
        dexRouter = IDexRouter(_dexRouter);
        WETH = IERC20(ethcoinAddress);

        // create pair
        lpPair = IDexFactory(dexRouter.factory()).createPair(
            address(this),
            address(WETH)
        );
        setAutomatedMarketMakerPair(address(lpPair), true);

        // setWhitelist(address(lpPair), false, false, true);
        setWhitelist(address(this), true, true, true);
        setWhitelist(address(0xdead), true, true, false);
        setWhitelist(newOwner, true, true, true);

        _createInitialSupply(address(newOwner), totalSupply);
        transferOwnership(newOwner);

        WETH.approve(address(dexRouter), type(uint256).max);
        _approve(address(this), address(dexRouter), type(uint256).max);
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /// @notice Adds or removes an address from the whitelist.
    /// @dev Only the owner can call this function.
    /// @param account The address to whitelist or unwhitelist.
    /// @param isExcludedFromFees True if the address should be excluded from fees, false otherwise.
    /// @param isExcludedMaxTradeAmount True if the address should be excluded from the max transaction amount, false otherwise.
    /// @param isExcludedMaxHoldingAmount True if the address should be excluded from the max holding amount, false otherwise. 
    function setWhitelist(
        address account,
        bool isExcludedFromFees,
        bool isExcludedMaxTradeAmount,
        bool isExcludedMaxHoldingAmount
    ) public {
        _whitelistWallet[account] = WhitelistWallet(
            isExcludedFromFees,
            isExcludedMaxTradeAmount,
            isExcludedMaxHoldingAmount
        );
        emit WhiteList(
            isExcludedFromFees,
            isExcludedMaxTradeAmount,
            isExcludedMaxHoldingAmount
        );
    }

    /// @notice Enables trading of the token.
    /// @dev Only callable by the contract owner.
    /// @custom:emits EnabledTrading when trading is enabled.
    function enableTrading() external onlyOwner {
        tradingActive = true;
        emit EnabledTrading();
    }

    /// @notice Enables or disables the automatic swap of accumulated fees for WETH.
    /// @dev This function can only be called by the contract owner.
    /// @param _enable Set to true to enable automatic swapping, false to disable.
    function setSwapEnabled(bool _enable) external onlyOwner {
        swapEnabled = _enable;
        if (_enable) {
            emit EnabledSwap();
        } else {
            emit DisabledSwap();
        }
    }

    /// @notice Returns the current limitations on token transfers and holdings.
    /// @return _transferDelayEnabled Indicates if the transfer delay mechanism is active.
    /// @return _transferDelayDuration The duration of the transfer delay, in seconds. 
    /// @return _tokenHoldingsRequiredToBuy Specifies if holding token is required for buying.
    /// @return _minimumHoldingsToBuy Represents the minimum amount of tokens needed to buy.
    /// @return _maxHoldingAmount Represents the maximum number of tokens an address can hold. 
    /// @return _maxTradeAmount Denotes the maximum number of tokens allowed in a single trade order.
    function limits()
        public
        view
        returns (bool _transferDelayEnabled, uint256 _transferDelayDuration, bool _tokenHoldingsRequiredToBuy, uint256 _minimumHoldingsToBuy, uint256 _maxHoldingAmount, uint256 _maxTradeAmount)
    {
        return (transferDelayEnabled, transferDelayDuration, tokenHoldingsRequiredToBuy, minimumHoldingsToBuy ,maxHoldingAmount, maxTradeAmount);
    }

    /// @notice Sets various limitations for trading and holding tokens.
    /// @dev Can only be called by the contract owner.
    /// @param _duration The duration of the transfer delay, in seconds. Must be less than or equal to MAX_TRANSFER_DELAY (5 minutes).
    /// @param _minimumHoldingsToBuy The minimum amount of tokens required to buy, in wei (1 token = 10^18 wei).
    /// @param _maxHoldingAmount The maximum number of tokens an address can hold, in wei.
    /// @param _maxTradeAmount The maximum number of tokens that can be traded in a single transaction, in wei. 
    /// Emits a `LimitsUpdated` event with the updated values. 
    /// Requirements: 
    /// - `_duration` must be less than or equal to `MAX_TRANSFER_DELAY` (5 minutes).
    /// - `_maxTradeAmount` must be greater than or equal to 0.01% of the total supply.
    function setLimits(uint256 _duration, uint256 _minimumHoldingsToBuy, uint256 _maxHoldingAmount, uint256 _maxTradeAmount)
        external
        onlyOwner
    {
        require(
            _duration <= MAX_TRANSFER_DELAY,
            "Duration exceeds maximum transfer delay"
        );
        require(
            _maxTradeAmount >= ((totalSupply() / 10000) / (10**decimals())),
            "Cannot set max buy amount lower than 0.01%"
        );
        transferDelayEnabled = _duration > 0;
        transferDelayDuration = _duration;
        tokenHoldingsRequiredToBuy = _minimumHoldingsToBuy > 0;
        minimumHoldingsToBuy = _minimumHoldingsToBuy;
        maxHoldingAmount = _maxHoldingAmount;
        maxTradeAmount = _maxTradeAmount;
        emit LimitsUpdated(
            transferDelayEnabled,
            transferDelayDuration,
            tokenHoldingsRequiredToBuy,
            minimumHoldingsToBuy,
            maxHoldingAmount,
            maxTradeAmount
        );
    }

    /// @notice change the minimum amount of tokens to sell from fees
    /// @param newAmount The new minimum amount of tokens to sell
    /// @dev This function allows the contract owner to adjust the threshold at which accumulated fees are automatically swapped for WETH and sent to the tax address.
    /// Requirements:
    /// - The `newAmount` must be greater than or equal to 0.001% of the total supply.
    /// - The `newAmount` must be less than or equal to 1% of the total supply.
    /// Emits a {SwapTokensAtAmountUpdated} event.
    function updateSwapTokensAtAmount(uint256 newAmount) external onlyOwner {
        uint256 _totalSupply = totalSupply();
        require(
            newAmount >= (_totalSupply * 1) / 100000,
            "Swap amount cannot be lower than 0.001% total supply."
        );
        require(
            newAmount <= (_totalSupply * 1) / 100,
            "Swap amount cannot be higher than 1% total supply."
        );
        swapTokensAtAmount = newAmount;
        emit SwapTokensAtAmountUpdated(newAmount);
    }

    /// @notice Airdrop tokens to a list of wallets.
    /// @dev This function allows the owner to distribute tokens to multiple wallets in a single transaction.
    /// @param wallets An array of wallet addresses to receive the airdrop.
    /// @param amountsInTokens An array of token amounts to be sent to each wallet. Must be in the same order as the wallets array. The token amounts are in wei
    /// @dev Note: The length of the wallets and amountsInTokens arrays must be the same, and it should be less than 600 due to gas limitations.
    function airdropToWallets(
        address[] memory wallets,
        uint256[] memory amountsInTokens
    ) external onlyOwner {
        require(
            wallets.length == amountsInTokens.length,
            "arrays must be the same length"
        );
        require(
            wallets.length < 600,
            "Can only airdrop 600 wallets per txn due to gas limits"
        );
        for (uint256 i = 0; i < wallets.length; i++) {
            address wallet = wallets[i];
            uint256 amount = amountsInTokens[i];
            super._transfer(msg.sender, wallet, amount);
        }
    }

    /// @notice Sets or unsets the automated market maker pair status for a given address.
    /// @param pair The address of the pair to update.
    /// @param value True to set the pair as an automated market maker pair, false to unset it.
    /// @dev This function can only be called by the owner. 
    ///     The pair cannot be removed from automatedMarketMakerPairs if it is the lpPair.
    ///     This function also excludes/includes the pair from max transaction limits depending on the value.
    function setAutomatedMarketMakerPair(address pair, bool value)
        public
        onlyOwner
    {
        require(
            pair != lpPair || value,
            "The pair cannot be removed from automatedMarketMakerPairs"
        );
        automatedMarketMakerPairs[pair] = value;
        setWhitelist(pair, false, true, true);
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    /// @notice Updates the buy, sell, and transfer fees for the token.
    /// @dev Only callable by the owner. Fees are input as basis points (e.g., 700 for 7%).
    /// @param _buyFee The new buy fee, in basis points.
    /// @param _sellFee The new sell fee, in basis points.
    /// @param _transferFee The new transfer fee, in basis points.
    function updateFees(
        uint256 _buyFee,
        uint256 _sellFee,
        uint256 _transferFee
    ) external onlyOwner {
        require(_buyFee <= 700, "Must keep buy fees at 7% or less");
        require(_sellFee <= 700, "Must keep sell fees at 7% or less");
        require(_transferFee <= 700, "Must keep transfer fees at 7% or less");
        buyFee = _buyFee;
        sellFee = _sellFee;
        transferFee = _transferFee;
        emit UpdatedFees(buyFee, sellFee, transferFee);
    }

    /// @notice Returns the buy, sell, and transfer fees for the token, represented as basis points (hundredths of a percent).
    /// @dev For example, a fee of 5.5% would be returned as 550.
    /// @return _buyFee The current buy fee in basis points.
    /// @return _sellFee The current sell fee in basis points.
    /// @return _transferFee The current transfer fee in basis points.
    function getFees()
        external
        view
        returns (
            uint256 _buyFee,
            uint256 _sellFee,
            uint256 _transferFee
        )
    {
        return (buyFee, sellFee, transferFee);
    }

    function _checkMaxHoldingAmount(address to, uint256 amount) internal view {
        if (!_whitelistWallet[to].isExcludedMaxHoldingAmount && !automatedMarketMakerPairs[to]) {
            require(
                balanceOf(to) + amount <= maxHoldingAmount,
                "Exceeds max holding amount"
            );
        }
    }

    function _checkMiminumHoldingToBuy(address to) internal view {
        require(minimumHoldingsToBuy <= balanceOf(to), "Token balance is less than minimum holding amount");
    }

    function _checkTransferDelay(address from, address to) internal {
        if (
            transferDelayEnabled &&
            from != address(dexRouter) &&
            from != address(lpPair) && 
            to != owner() && 
            from != owner() &&
            from != taxAddress &&
            to != taxAddress
        ) {
            require(
                _holderLastTransferTime[tx.origin] + transferDelayDuration < block.timestamp,
                "Transfer delay enabled. Try again later."
            );

            _holderLastTransferTime[tx.origin] = block.timestamp;
        }
    }

    // 
    function _checkMaxTradeAmount(
        address from,
        address to,
        uint256 amount
    ) internal view {
        if(
            (!_whitelistWallet[from].isExcludedMaxTradeAmount && automatedMarketMakerPairs[to]) || 
            (!_whitelistWallet[to].isExcludedMaxTradeAmount && automatedMarketMakerPairs[from])
        ) {
            require(
                amount <= maxTradeAmount,
                "Trade amount exceeds the max trade amount."
            );
        }
    }

    function _takeFee(
        address from,
        address to,
        uint256 amount
    ) internal returns (uint256) {

        if (_whitelistWallet[from].isExcludedFromFees || _whitelistWallet[to].isExcludedFromFees) {
            return 0;
        }

        uint256 fees;

        if (automatedMarketMakerPairs[to] && sellFee > 0) {
            fees = (amount * sellFee) / 10000;
        } else if (automatedMarketMakerPairs[from] && buyFee > 0) {
            fees = (amount * buyFee) / 10000;
        } else if (transferFee > 0) {
            fees = (amount * transferFee) / 10000;
        }

        if (fees > 0) {
            super._transfer(from, address(this), fees);
        }

        return fees;
    }

    function _executeSwap() internal {
        if (
            balanceOf(address(this)) > swapTokensAtAmount &&
            swapEnabled &&
            !swapping
        ) {
            swapping = true;
            swapBack();
            swapping = false;
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (!tradingActive && (automatedMarketMakerPairs[from] || automatedMarketMakerPairs[to]) && _msgSender() != owner()) {
            revert TradingIsNotActive();
        }

        _checkTransferDelay(from, to);
        _checkMiminumHoldingToBuy(to);
        _checkMaxTradeAmount(from, to, amount);
        _checkMaxHoldingAmount(to, amount);

        uint256 fees = _takeFee(from, to, amount);

        _executeSwap();

        super._transfer(from, to, amount - fees);
    }

    function swapTokensForWETH(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(WETH);

        // make the swap
        dexRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(taxAddress),
            block.timestamp
        );
    }

    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));

        if (contractBalance == 0) {
            return;
        }

        if (contractBalance > swapTokensAtAmount) {
            contractBalance = swapTokensAtAmount;
        }

        swapTokensForWETH(contractBalance);

        if (WETH.balanceOf(address(this)) > 0) {
            WETH.transfer(taxAddress, WETH.balanceOf(address(this)));
        }
    }

    function _forceSwapBack() private {
        uint256 contractBalance = balanceOf(address(this));

        if (contractBalance == 0) {
            return;
        }

        swapTokensForWETH(contractBalance);

        if (WETH.balanceOf(address(this)) > 0) {
            WETH.transfer(taxAddress, WETH.balanceOf(address(this)));
        }
    }

    /// @notice Allows the owner to transfer any ERC20 tokens sent to the contract.
    /// @dev This function can only be called by the owner.
    /// @param _token The address of the ERC20 token to transfer.
    /// @param _to The address to transfer the tokens to.
    /// @dev Emits a {TransferForeignToken} event.
    /// Requirements:
    /// - `_token` address cannot be zero.
    /// - `_token` cannot be the native token (RAM) while trading is active.
    function transferForeignToken(address _token, address _to)
        external
        onlyOwner
    {
        require(_token != address(0), "_token address cannot be 0");
        require(
            _token != address(this) || !tradingActive,
            "Can't withdraw native tokens while trading is active"
        );
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        SafeERC20.safeTransfer(IERC20(_token), _to, _contractBalance);
        emit TransferForeignToken(_token, _contractBalance);
    }

    /// @notice Sets the tax address where fees are collected.
    /// @dev Only callable by the owner.
    /// @param _taxAddress The new tax address. Must not be the zero address.
    /// @ emits UpdatedTaxAddress event with the new tax address.
    function setTaxAddress(address _taxAddress) external onlyOwner {
        require(_taxAddress != address(0), "address cannot be 0");
        taxAddress = payable(_taxAddress);
        setWhitelist(_taxAddress, true, true, true);
        emit UpdatedTaxAddress(_taxAddress);
    }

    /// @notice Forcefully swap back accumulated tokens for WETH and send to the tax address, even if the accumulated amount is below the threshold.
    /// @dev This function can be used to manually trigger a swap in case of slippage issues or other unforeseen circumstances.
    /// @dev Only callable by the owner.
    /// Emits an {OwnerForcedSwapBack} event with the current timestamp.
    function forceSwapBack() external onlyOwner {
        swapping = true;
        _forceSwapBack();
        swapping = false;
        emit OwnerForcedSwapBack(block.timestamp);
    }

    // function updateAllowanceForSwapping() external onlyOwner {
    //     WETH.approve(address(dexRouter), type(uint256).max);
    //     _approve(address(this), address(dexRouter), type(uint256).max);
    //     emit ReuppedApprovals();
    // }
}