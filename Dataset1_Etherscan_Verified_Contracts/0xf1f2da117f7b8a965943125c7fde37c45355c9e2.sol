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
// OpenZeppelin Contracts (last updated v5.1.0) (access/Ownable2Step.sol)

pragma solidity ^0.8.20;

import {Ownable} from "./Ownable.sol";

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This extension of the {Ownable} contract includes a two-step mechanism to transfer
 * ownership, where the new owner must call {acceptOwnership} in order to replace the
 * old one. This can help prevent common mistakes, such as transfers of ownership to
 * incorrect accounts, or to contracts that are unable to interact with the
 * permission system.
 *
 * The initial owner is specified at deployment time in the constructor for `Ownable`. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2Step is Ownable {
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     *
     * Setting `newOwner` to the zero address is allowed; this can be used to cancel an initiated ownership transfer.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() public virtual {
        address sender = _msgSender();
        if (pendingOwner() != sender) {
            revert OwnableUnauthorizedAccount(sender);
        }
        _transferOwnership(sender);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
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
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC-20 standard.
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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {ISwapRouter, IV3SwapRouter} from "./interfaces/ISwapRouter.sol";
import {TransferHelper} from "./uniswap/TransferHelper.sol";
import {RevertContext, RevertOptions} from "./zetachain/Revert.sol";
import {IGatewayEVM} from "./interfaces/IGatewayEVM.sol";
import "./interfaces/IPermit2.sol";

// Interface for a wrapped native token to allow deposits and withdrawals
interface IWTOKEN is IERC20 {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
    receive() external payable;
}

/**
 * @title EvmDustTokens
 * This contract helps users to convert all their ERC20 tokens
 * from one supported chain to another.
 */
contract EvmDustTokens is Ownable2Step {
    using TransferHelper for *;

    IGatewayEVM public immutable gateway;
    ISwapRouter public immutable swapRouter; // Uniswap router
    IPermit2 public immutable permit2;
    address public immutable universalDApp;
    address payable public immutable wNativeToken;
    uint256 public protocolFee = 200; // Our fee: 200 == 2%
    uint256 public collectedFees;
    uint256 public refunds;

    // Allowed tokens to receive
    mapping(address => bool) public isWhitelisted;
    address[] tokenList;

    // @dev for V3 path = bytes.concat(
    //                      bytes20(tokenIn),
    //                      bytes3(swapFee1),
    //                      bytes20(tokenOut1),
    //                      bytes3(swapFee2),
    //                      bytes20(tokenOut2),
    //                      ... etc
    //                  );
    // for V2 path = abi.encode(array);
    // address[] array = [tokenIn, tokenOut1, tokenOut2, ...]
    struct SwapInput {
        bool isV3;
        bytes path;
        uint256 amount;
        uint256 minAmountOut;
    }

    struct SwapOutput {
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 amountOut;
    }

    event FeesWithdrawn(uint256 amount);
    event ProtocolFeeUpdated(uint256 newFee);
    event TokenFeesWithdrawn(address token, uint256 amount);
    event TokenAdded(address indexed token);
    event TokenRemoved(address indexed token);
    event Swapped(address indexed executor, SwapOutput[] swaps, uint256 totalTokensReceived);
    event SwappedAndDeposited(address indexed executor, SwapOutput[] swaps, uint256 totalTokensReceived);
    event Withdrawn(address indexed recipient, address outputToken, uint256 totalTokensReceived);
    event WithdrawFailed(address indexed recipient, uint256 totalTokensReceived);
    event RefundsSent(address indexed receiver, uint256 amount);
    event Reverted(address indexed recipient, address asset, uint256 amount);

    error FeeWithdrawalFailed();
    error InvalidAddress();
    error InsufficientAllowance(address token);
    error InsufficientBalance(address token);
    error InvalidMsgValue();
    error InvalidPath(uint256 swapIndex);
    error InvalidToken(address token);
    error NotGateway();
    error NoSwaps();
    error SwapFailed(bytes path, bytes revertData);
    error TransferFailed();
    error TokenIsNotWhitelisted(address token);
    error TokenIsWhitelisted(address token);
    error WrongIndex();

    constructor(
        IGatewayEVM _gateway,
        ISwapRouter _swapRouter,
        address _universalDApp,
        address payable _wNativeToken,
        address _initialOwner,
        IPermit2 _permit2,
        address[] memory _tokenList
    ) payable Ownable(_initialOwner) {
        if (
            address(_gateway) == address(0) || address(_swapRouter) == address(0) || _universalDApp == address(0)
                || _wNativeToken == address(0) || address(_permit2) == address(0)
        ) revert InvalidAddress();
        gateway = _gateway;
        swapRouter = _swapRouter;
        universalDApp = _universalDApp;
        permit2 = _permit2;
        wNativeToken = _wNativeToken;
        isWhitelisted[_wNativeToken] = true;
        tokenList.push(_wNativeToken);
        emit TokenAdded(_wNativeToken);

        uint256 tokenCount = _tokenList.length;
        address token;
        for (uint256 i; i < tokenCount; ++i) {
            token = _tokenList[i];
            if (token == address(0)) revert InvalidToken(token);
            isWhitelisted[token] = true;
            tokenList.push(token);
            emit TokenAdded(token);
        }
    }

    /**
     * Called by users to convert all their ERC20 tokens from one supported chain to another
     * @param swaps - Swaps to perform
     * @param message - Message to send to the Universal DApp
     * @param nonce - Permit2 nonce
     * @param deadline - Permit2 deadline
     * @param signature - Permit2 signature
     * @dev The message has to be abi.encode(UniversalDApp.Params)
     */
    function SwapAndBridgeTokens(
        SwapInput[] calldata swaps,
        bytes calldata message,
        uint256 nonce,
        uint256 deadline,
        bytes calldata signature
    ) external {
        if (swaps.length == 0) revert NoSwaps();
        // The output token has to be the wrapped native token
        address outputToken = _getOutputToken(swaps[0].path);
        if (outputToken != wNativeToken) revert InvalidPath(0);

        // Batch transfer all input tokens using Permit2
        _signatureBatchTransfer(swaps, nonce, deadline, signature);

        // Perform the swaps
        (SwapOutput[] memory performedSwaps, uint256 totalTokensReceived) = _performSwaps(swaps, outputToken);

        // Unwrap the native token and subtract the protocol fee
        IWTOKEN(wNativeToken).withdraw(totalTokensReceived);
        uint256 feeAmount = totalTokensReceived * protocolFee / 10000;
        totalTokensReceived -= feeAmount;
        collectedFees = collectedFees + feeAmount;

        // Prepare the revert options
        RevertOptions memory revertOptions = RevertOptions({
            revertAddress: address(this),
            callOnRevert: true,
            abortAddress: address(0),
            revertMessage: abi.encode(msg.sender),
            onRevertGasLimit: 0
        });
        gateway.depositAndCall{value: totalTokensReceived}(universalDApp, message, revertOptions);

        emit SwappedAndDeposited(msg.sender, performedSwaps, totalTokensReceived);
    }

    /**
     * Called by users to convert all their ERC20 tokens on the same chain
     * @param swaps - Swaps to perform
     * @param isNativeOutput - Whether the output token is native
     * @param nonce - Permit2 nonce
     * @param deadline - Permit2 deadline
     * @param signature - Permit2 signature
     */
    function SwapTokens(
        SwapInput[] calldata swaps,
        bool isNativeOutput,
        uint256 nonce,
        uint256 deadline,
        bytes calldata signature
    ) external {
        if (swaps.length == 0) revert NoSwaps();
        address outputToken = _getOutputToken(swaps[0].path);
        if (isNativeOutput && outputToken != wNativeToken) revert InvalidPath(0);

        // Batch transfer all input tokens using Permit2
        _signatureBatchTransfer(swaps, nonce, deadline, signature);

        // Perform the swaps
        (SwapOutput[] memory performedSwaps, uint256 totalTokensReceived) = _performSwaps(swaps, outputToken);

        uint256 feeAmount = totalTokensReceived * protocolFee / 10000;
        if (isNativeOutput) {
            // Unwrap the native token, subtract the protocol fee, and send the tokens to the msg.sender
            IWTOKEN(wNativeToken).withdraw(totalTokensReceived);
            totalTokensReceived -= feeAmount;
            collectedFees = collectedFees + feeAmount;

            (bool s,) = msg.sender.call{value: totalTokensReceived}("");
            if (!s) revert TransferFailed();
        } else {
            // Subtract the protocol fee and send the tokens to the msg.sender
            totalTokensReceived -= feeAmount;
            outputToken.safeTransfer(msg.sender, totalTokensReceived);
        }

        emit Swapped(msg.sender, performedSwaps, totalTokensReceived);
    }

    /**
     * Called by the Universal DApp to withdraw tokens on the destination chain
     * @param outputToken - The address of the output token
     * @param recipient - The address of the recipient
     * @param minAmount - The minimum amount of tokens to receive from the swap
     * @dev To receive native tokens, set outputToken to address(0)
     */
    function ReceiveTokens(address outputToken, address recipient, uint256 minAmount) external payable {
        // Early exit
        if (msg.value == 0) return;
        // Check if the output token is native or whitelisted
        if (outputToken != address(0) && !isWhitelisted[outputToken]) {
            refunds = refunds + msg.value;

            emit WithdrawFailed(recipient, msg.value);
        } else if (outputToken == address(0)) {
            // If outputToken is 0x, send msg.value to the recipient
            (bool s,) = recipient.call{value: msg.value}("");
            if (s) {
                emit Withdrawn(recipient, outputToken, msg.value);
            } else {
                refunds = refunds + msg.value;

                emit WithdrawFailed(recipient, msg.value);
            }
        } else if (outputToken == wNativeToken) {
            // Wrap native token to the wrapped native token (i.e: WETH, WPOL, etc)
            IWTOKEN(wNativeToken).deposit{value: msg.value}();
            wNativeToken.safeTransfer(recipient, msg.value);

            emit Withdrawn(recipient, wNativeToken, msg.value);
        } else {
            // Swap wrapped native token to the output token
            IWTOKEN(wNativeToken).deposit{value: msg.value}();
            wNativeToken.safeApprove(address(swapRouter), msg.value);

            ISwapRouter.ExactInputSingleParams memory params = IV3SwapRouter.ExactInputSingleParams({
                tokenIn: wNativeToken,
                tokenOut: outputToken,
                fee: 3000,
                recipient: recipient,
                amountIn: msg.value,
                amountOutMinimum: minAmount,
                sqrtPriceLimitX96: 0
            });

            uint256 amountOut = swapRouter.exactInputSingle(params);

            emit Withdrawn(recipient, outputToken, amountOut);
        }
    }

    /**
     * Add tokens to whitelist
     * @param tokens - The addresses of the ERC20 tokens
     */
    function addTokens(address[] calldata tokens) external onlyOwner {
        uint256 tokenCount = tokens.length;
        address token;
        for (uint256 i; i < tokenCount; ++i) {
            token = tokens[i];
            if (token == address(0)) revert InvalidAddress();
            if (isWhitelisted[token]) revert TokenIsWhitelisted(token);
            isWhitelisted[token] = true;
            tokenList.push(token);
            emit TokenAdded(token);
        }
    }

    /**
     * Remove token from whitelist
     * @param token - The address of the ERC20 token
     * @param index - The index of the token in tokenList
     */
    function removeToken(address token, uint256 index) external onlyOwner {
        if (token == address(0)) revert InvalidAddress();
        if (!isWhitelisted[token]) revert TokenIsNotWhitelisted(token);
        delete isWhitelisted[token];

        if (tokenList[index] != token) revert WrongIndex();
        uint256 len = tokenList.length - 1;
        tokenList[index] = tokenList[len];
        assembly {
            sstore(tokenList.slot, len)
        }
        emit TokenRemoved(token);
    }

    /**
     * Withdraw all collected fees
     */
    function withdrawFees() external onlyOwner {
        uint256 fees = collectedFees;
        delete collectedFees;
        (bool s,) = msg.sender.call{value: fees}("");
        if (!s) revert FeeWithdrawalFailed();
        emit FeesWithdrawn(fees);
    }

    /**
     * Withdraw token fees
     * @param tokens - The addresses of the ERC20 tokens
     */
    function withdrawTokenFees(address[] calldata tokens) external onlyOwner {
        uint256 len = tokens.length;
        uint256 amount;
        address token;
        for (uint256 i; i < len; ++i) {
            token = tokens[i];
            amount = IERC20(token).balanceOf(address(this));
            token.safeTransfer(msg.sender, amount);
            emit TokenFeesWithdrawn(token, amount);
        }
    }

    /**
     * Send refunds to the original sender
     * @param receiver - The address of the original sender
     * @param amount - The amount of refunds
     */
    function sendRefunds(address receiver, uint256 amount) external onlyOwner {
        // Reverts if the amount is greater than the refunds
        refunds = refunds - amount;
        (bool s,) = receiver.call{value: amount}("");
        if (!s) revert TransferFailed();
        emit RefundsSent(receiver, amount);
    }

    /**
     * Update the protocol fee
     * @param _newFee - The new protocol fee
     */
    function updateProtocolFee(uint256 _newFee) external onlyOwner {
        protocolFee = _newFee;
        emit ProtocolFeeUpdated(_newFee);
    }

    /**
     * Called by the gateway if the transaction reverts.
     * Returns the reverted tokens back to the original sender
     * @param revertContext - Revert context to pass to onRevert
     * @dev The gateway sends tokens to the contract and then calls onRevert
     */
    function onRevert(RevertContext calldata revertContext) external payable {
        if (msg.sender != address(gateway)) revert NotGateway();

        // Decode the revert message to get the original sender's address
        address originalSender = abi.decode(revertContext.revertMessage, (address));

        // Transfer the reverted tokens back to the original sender
        if (revertContext.asset == address(0)) {
            (bool s,) = originalSender.call{value: revertContext.amount}("");
            if (!s) revert TransferFailed();
        } else {
            revertContext.asset.safeTransfer(originalSender, revertContext.amount);
        }

        emit Reverted(originalSender, revertContext.asset, revertContext.amount);
    }

    /**
     * Get the list of whitelisted tokens
     */
    function getTokenList() external view returns (address[] memory) {
        return tokenList;
    }

    /**
     * Get the metadata of whitelisted tokens
     * @param user - The address of the user
     * @return addresses - The addresses of the whitelisted tokens
     * @return names - The names of the whitelisted tokens
     * @return symbols - The symbols of the whitelisted tokens
     * @return decimals - The decimals of the whitelisted tokens
     * @return balances - The balances of the whitelisted tokens
     */
    function getTokensMetadata(address user)
        external
        view
        returns (
            address[] memory addresses,
            string[] memory names,
            string[] memory symbols,
            uint8[] memory decimals,
            uint256[] memory balances
        )
    {
        uint256 tokenCount = tokenList.length;

        addresses = new address[](tokenCount);
        names = new string[](tokenCount);
        symbols = new string[](tokenCount);
        decimals = new uint8[](tokenCount);
        balances = new uint256[](tokenCount);
        IERC20Metadata token;
        for (uint256 i; i < tokenCount; ++i) {
            token = IERC20Metadata(tokenList[i]);
            addresses[i] = address(token);
            names[i] = token.name();
            symbols[i] = token.symbol();
            decimals[i] = token.decimals();
            balances[i] = token.balanceOf(user);
        }
    }

    /**
     * Batch SignatureTransfer to transfer tokens from msg.sender to this contract
     * @param swaps - Swaps to perform
     * @param nonce - Permit2 nonce
     * @param deadline - Permit2 deadline
     * @param signature - Permit2 signature
     */
    function _signatureBatchTransfer(
        SwapInput[] calldata swaps,
        uint256 nonce,
        uint256 deadline,
        bytes calldata signature
    ) internal {
        uint256 swapsAmount = swaps.length;

        // Create arrays for TokenPermissions and SignatureTransferDetails
        ISignatureTransfer.TokenPermissions[] memory permitted = new ISignatureTransfer.TokenPermissions[](swapsAmount);
        ISignatureTransfer.SignatureTransferDetails[] memory transferDetails =
            new ISignatureTransfer.SignatureTransferDetails[](swapsAmount);
        address token;
        uint256 amount;
        for (uint256 i; i < swapsAmount; ++i) {
            SwapInput calldata swap = swaps[i];
            token = _getInputToken(swap.isV3, swap.path);
            amount = swap.amount;

            // Check allowance and balance
            if (IERC20(token).allowance(msg.sender, address(permit2)) < amount) revert InsufficientAllowance(token);
            if (IERC20(token).balanceOf(msg.sender) < amount) revert InsufficientBalance(token);

            permitted[i] = ISignatureTransfer.TokenPermissions({token: token, amount: amount});

            transferDetails[i] =
                ISignatureTransfer.SignatureTransferDetails({to: address(this), requestedAmount: amount});
        }

        // Create the PermitBatchTransferFrom struct
        ISignatureTransfer.PermitBatchTransferFrom memory permit =
            ISignatureTransfer.PermitBatchTransferFrom({permitted: permitted, nonce: nonce, deadline: deadline});

        // Execute the batched permit transfer
        permit2.permitTransferFrom(permit, transferDetails, msg.sender, signature);
    }

    /**
     * Perform the swaps via Uniswap
     * @param swaps - Swaps to perform
     * @param outputToken - The output token
     * @return performedSwaps - The performed swaps
     * @return totalTokensReceived - The total amount of the output token received
     */
    function _performSwaps(SwapInput[] calldata swaps, address outputToken)
        internal
        returns (SwapOutput[] memory performedSwaps, uint256 totalTokensReceived)
    {
        if (!isWhitelisted[outputToken]) revert TokenIsNotWhitelisted(outputToken);

        uint256 swapsAmount = swaps.length;
        performedSwaps = new SwapOutput[](swapsAmount);
        // Loop through each swap provided
        for (uint256 i; i < swapsAmount; ++i) {
            SwapInput calldata swap = swaps[i];
            // All swaps must have the same output token
            if (outputToken != _getOutputToken(swap.path)) revert InvalidPath(i);
            address inputToken = _getInputToken(swap.isV3, swap.path);
            uint256 amount = swap.amount;
            // Approve the swap router to spend the token
            inputToken.safeApprove(address(swapRouter), amount);

            uint256 amountOut = swap.isV3 ? _performV3(swap) : _performV2(swap);
            totalTokensReceived += amountOut;

            // Store performed swap details
            performedSwaps[i] =
                SwapOutput({tokenIn: inputToken, tokenOut: outputToken, amountIn: amount, amountOut: amountOut});
        }
    }

    /**
     * Get the input token from the path
     * @param isV3 - Whether the swap is V3
     * @param path - The path of the swap
     * @return token - The input token
     */
    function _getInputToken(bool isV3, bytes calldata path) internal pure returns (address token) {
        return isV3 ? address(bytes20(path[0:20])) : abi.decode(path, (address[]))[0];
    }

    /**
     * Get the output token from the path
     * @param path - The path of the swap
     * @return token - The output token
     */
    function _getOutputToken(bytes calldata path) internal pure returns (address token) {
        uint256 len = path.length;
        return address(bytes20(path[len - 20:len]));
    }

    /**
     * Perform a V3 swap
     * @param swap - The swap to perform
     * @return amountOut - The amount of the output token
     */
    function _performV3(SwapInput calldata swap) internal returns (uint256 amountOut) {
        // Build Uniswap Swap to convert the input token to the output token
        ISwapRouter.ExactInputParams memory params = IV3SwapRouter.ExactInputParams({
            path: swap.path,
            recipient: address(this),
            amountIn: swap.amount,
            amountOutMinimum: swap.minAmountOut
        });

        // Try to perform the swap
        try swapRouter.exactInput(params) returns (uint256 amount) {
            return amount;
        } catch (bytes memory revertData) {
            revert SwapFailed(swap.path, revertData);
        }
    }

    /**
     * Perform a V2 swap
     * @param swap - The swap to perform
     * @return amountOut - The amount of the output token
     */
    function _performV2(SwapInput calldata swap) internal returns (uint256 amountOut) {
        // Try to perform the swap
        try swapRouter.swapExactTokensForTokens(
            swap.amount, swap.minAmountOut, abi.decode(swap.path, (address[])), address(this)
        ) returns (uint256 amount) {
            return amount;
        } catch (bytes memory revertData) {
            revert SwapFailed(swap.path, revertData);
        }
    }

    receive() external payable {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IEIP712} from "./IEIP712.sol";

/// @title AllowanceTransfer
/// @notice Handles ERC20 token permissions through signature based allowance setting and ERC20 token transfers by checking allowed amounts
/// @dev Requires user's token approval on the Permit2 contract
interface IAllowanceTransfer is IEIP712 {
    /// @notice Thrown when an allowance on a token has expired.
    /// @param deadline The timestamp at which the allowed amount is no longer valid
    error AllowanceExpired(uint256 deadline);

    /// @notice Thrown when an allowance on a token has been depleted.
    /// @param amount The maximum amount allowed
    error InsufficientAllowance(uint256 amount);

    /// @notice Thrown when too many nonces are invalidated.
    error ExcessiveInvalidation();

    /// @notice Emits an event when the owner successfully invalidates an ordered nonce.
    event NonceInvalidation(
        address indexed owner, address indexed token, address indexed spender, uint48 newNonce, uint48 oldNonce
    );

    /// @notice Emits an event when the owner successfully sets permissions on a token for the spender.
    event Approval(
        address indexed owner, address indexed token, address indexed spender, uint160 amount, uint48 expiration
    );

    /// @notice Emits an event when the owner successfully sets permissions using a permit signature on a token for the spender.
    event Permit(
        address indexed owner,
        address indexed token,
        address indexed spender,
        uint160 amount,
        uint48 expiration,
        uint48 nonce
    );

    /// @notice Emits an event when the owner sets the allowance back to 0 with the lockdown function.
    event Lockdown(address indexed owner, address token, address spender);

    /// @notice The permit data for a token
    struct PermitDetails {
        // ERC20 token address
        address token;
        // the maximum amount allowed to spend
        uint160 amount;
        // timestamp at which a spender's token allowances become invalid
        uint48 expiration;
        // an incrementing value indexed per owner,token,and spender for each signature
        uint48 nonce;
    }

    /// @notice The permit message signed for a single token allowance
    struct PermitSingle {
        // the permit data for a single token alownce
        PermitDetails details;
        // address permissioned on the allowed tokens
        address spender;
        // deadline on the permit signature
        uint256 sigDeadline;
    }

    /// @notice The permit message signed for multiple token allowances
    struct PermitBatch {
        // the permit data for multiple token allowances
        PermitDetails[] details;
        // address permissioned on the allowed tokens
        address spender;
        // deadline on the permit signature
        uint256 sigDeadline;
    }

    /// @notice The saved permissions
    /// @dev This info is saved per owner, per token, per spender and all signed over in the permit message
    /// @dev Setting amount to type(uint160).max sets an unlimited approval
    struct PackedAllowance {
        // amount allowed
        uint160 amount;
        // permission expiry
        uint48 expiration;
        // an incrementing value indexed per owner,token,and spender for each signature
        uint48 nonce;
    }

    /// @notice A token spender pair.
    struct TokenSpenderPair {
        // the token the spender is approved
        address token;
        // the spender address
        address spender;
    }

    /// @notice Details for a token transfer.
    struct AllowanceTransferDetails {
        // the owner of the token
        address from;
        // the recipient of the token
        address to;
        // the amount of the token
        uint160 amount;
        // the token to be transferred
        address token;
    }

    /// @notice A mapping from owner address to token address to spender address to PackedAllowance struct, which contains details and conditions of the approval.
    /// @notice The mapping is indexed in the above order see: allowance[ownerAddress][tokenAddress][spenderAddress]
    /// @dev The packed slot holds the allowed amount, expiration at which the allowed amount is no longer valid, and current nonce thats updated on any signature based approvals.
    function allowance(address user, address token, address spender)
        external
        view
        returns (uint160 amount, uint48 expiration, uint48 nonce);

    /// @notice Approves the spender to use up to amount of the specified token up until the expiration
    /// @param token The token to approve
    /// @param spender The spender address to approve
    /// @param amount The approved amount of the token
    /// @param expiration The timestamp at which the approval is no longer valid
    /// @dev The packed allowance also holds a nonce, which will stay unchanged in approve
    /// @dev Setting amount to type(uint160).max sets an unlimited approval
    function approve(address token, address spender, uint160 amount, uint48 expiration) external;

    /// @notice Permit a spender to a given amount of the owners token via the owner's EIP-712 signature
    /// @dev May fail if the owner's nonce was invalidated in-flight by invalidateNonce
    /// @param owner The owner of the tokens being approved
    /// @param permitSingle Data signed over by the owner specifying the terms of approval
    /// @param signature The owner's signature over the permit data
    function permit(address owner, PermitSingle memory permitSingle, bytes calldata signature) external;

    /// @notice Permit a spender to the signed amounts of the owners tokens via the owner's EIP-712 signature
    /// @dev May fail if the owner's nonce was invalidated in-flight by invalidateNonce
    /// @param owner The owner of the tokens being approved
    /// @param permitBatch Data signed over by the owner specifying the terms of approval
    /// @param signature The owner's signature over the permit data
    function permit(address owner, PermitBatch memory permitBatch, bytes calldata signature) external;

    /// @notice Transfer approved tokens from one address to another
    /// @param from The address to transfer from
    /// @param to The address of the recipient
    /// @param amount The amount of the token to transfer
    /// @param token The token address to transfer
    /// @dev Requires the from address to have approved at least the desired amount
    /// of tokens to msg.sender.
    function transferFrom(address from, address to, uint160 amount, address token) external;

    /// @notice Transfer approved tokens in a batch
    /// @param transferDetails Array of owners, recipients, amounts, and tokens for the transfers
    /// @dev Requires the from addresses to have approved at least the desired amount
    /// of tokens to msg.sender.
    function transferFrom(AllowanceTransferDetails[] calldata transferDetails) external;

    /// @notice Enables performing a "lockdown" of the sender's Permit2 identity
    /// by batch revoking approvals
    /// @param approvals Array of approvals to revoke.
    function lockdown(TokenSpenderPair[] calldata approvals) external;

    /// @notice Invalidate nonces for a given (token, spender) pair
    /// @param token The token to invalidate nonces for
    /// @param spender The spender to invalidate nonces for
    /// @param newNonce The new nonce to set. Invalidates all nonces less than it.
    /// @dev Can't invalidate more than 2**16 nonces per transaction.
    function invalidateNonces(address token, address spender, uint48 newNonce) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IEIP712 {
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../zetachain/Revert.sol";

/// @title IGatewayEVMEvents
/// @notice Interface for the events emitted by the GatewayEVM contract.
interface IGatewayEVMEvents {
    /// @notice Emitted when a contract call is executed.
    /// @param destination The address of the contract called.
    /// @param value The amount of ETH sent with the call.
    /// @param data The calldata passed to the contract call.
    event Executed(address indexed destination, uint256 value, bytes data);

    /// @notice Emitted when a contract call is reverted.
    /// @param to The address of the contract called.
    /// @param token The address of the ERC20 token, empty if gas token
    /// @param amount The amount of ETH sent with the call.
    /// @param data The calldata passed to the contract call.
    /// @param revertContext Revert context to pass to onRevert.
    event Reverted(
        address indexed to,
        address indexed token,
        uint256 amount,
        bytes data,
        RevertContext revertContext
    );

    /// @notice Emitted when a contract call with ERC20 tokens is executed.
    /// @param token The address of the ERC20 token.
    /// @param to The address of the contract called.
    /// @param amount The amount of tokens transferred.
    /// @param data The calldata passed to the contract call.
    event ExecutedWithERC20(
        address indexed token,
        address indexed to,
        uint256 amount,
        bytes data
    );

    /// @notice Emitted when a deposit is made.
    /// @param sender The address of the sender.
    /// @param receiver The address of the receiver.
    /// @param amount The amount of ETH or tokens deposited.
    /// @param asset The address of the ERC20 token (zero address if ETH).
    /// @param payload The calldata passed with the deposit. No longer used. Kept to maintain compatibility.
    /// @param revertOptions Revert options.
    event Deposited(
        address indexed sender,
        address indexed receiver,
        uint256 amount,
        address asset,
        bytes payload,
        RevertOptions revertOptions
    );

    /// @notice Emitted when a deposit and call is made.
    /// @param sender The address of the sender.
    /// @param receiver The address of the receiver.
    /// @param amount The amount of ETH or tokens deposited.
    /// @param asset The address of the ERC20 token (zero address if ETH).
    /// @param payload The calldata passed with the deposit.
    /// @param revertOptions Revert options.
    event DepositedAndCalled(
        address indexed sender,
        address indexed receiver,
        uint256 amount,
        address asset,
        bytes payload,
        RevertOptions revertOptions
    );

    /// @notice Emitted when an omnichain smart contract call is made without asset transfer.
    /// @param sender The address of the sender.
    /// @param receiver The address of the receiver.
    /// @param payload The calldata passed to the call.
    /// @param revertOptions Revert options.
    event Called(
        address indexed sender,
        address indexed receiver,
        bytes payload,
        RevertOptions revertOptions
    );

    /// @notice Emitted when tss address is updated
    /// @param oldTSSAddress old tss address
    /// @param newTSSAddress new tss address
    event UpdatedGatewayTSSAddress(
        address oldTSSAddress,
        address newTSSAddress
    );
}

/// @title IGatewayEVMErrors
/// @notice Interface for the errors used in the GatewayEVM contract.
interface IGatewayEVMErrors {
    /// @notice Error for failed execution.
    error ExecutionFailed();

    /// @notice Error for failed deposit.
    error DepositFailed();

    /// @notice Error for insufficient ETH amount.
    error InsufficientETHAmount();

    /// @notice Error for insufficient ERC20 token amount.
    error InsufficientERC20Amount();

    /// @notice Error for zero address input.
    error ZeroAddress();

    /// @notice Error for failed token approval.
    error ApprovalFailed();

    /// @notice Error for already initialized custody.
    error CustodyInitialized();

    /// @notice Error for already initialized connector.
    error ConnectorInitialized();

    /// @notice Error when trying to transfer not whitelisted token to custody.
    error NotWhitelistedInCustody();

    /// @notice Error when trying to call onCall method using arbitrary call.
    error NotAllowedToCallOnCall();

    /// @notice Error when trying to call onRevert method using arbitrary call.
    error NotAllowedToCallOnRevert();

    /// @notice Error indicating payload size exceeded in external functions.
    error PayloadSizeExceeded();
}

/// @title IGatewayEVM
/// @notice Interface for the GatewayEVM contract.
interface IGatewayEVM is IGatewayEVMErrors, IGatewayEVMEvents {
    /// @notice Executes a call to a contract using ERC20 tokens.
    /// @param messageContext Message context containing sender and arbitrary call flag.
    /// @param token The address of the ERC20 token.
    /// @param to The address of the contract to call.
    /// @param amount The amount of tokens to transfer.
    /// @param data The calldata to pass to the contract call.
    function executeWithERC20(
        MessageContext calldata messageContext,
        address token,
        address to,
        uint256 amount,
        bytes calldata data
    ) external;

    /// @notice Transfers msg.value to destination contract and executes it's onRevert function.
    /// @dev This function can only be called by the TSS address and it is payable.
    /// @param destination Address to call.
    /// @param data Calldata to pass to the call.
    /// @param revertContext Revert context to pass to onRevert.
    function executeRevert(
        address destination,
        bytes calldata data,
        RevertContext calldata revertContext
    ) external payable;

    /// @notice Executes a call to a destination address without ERC20 tokens.
    /// @dev This function can only be called by the TSS address and it is payable.
    /// @param messageContext Message context containing sender and arbitrary call flag.
    /// @param destination Address to call.
    /// @param data Calldata to pass to the call.
    /// @return The result of the call.
    function execute(
        MessageContext calldata messageContext,
        address destination,
        bytes calldata data
    ) external payable returns (bytes memory);

    /// @notice Executes a revertable call to a contract using ERC20 tokens.
    /// @param token The address of the ERC20 token.
    /// @param to The address of the contract to call.
    /// @param amount The amount of tokens to transfer.
    /// @param data The calldata to pass to the contract call.
    /// @param revertContext Revert context to pass to onRevert.
    function revertWithERC20(
        address token,
        address to,
        uint256 amount,
        bytes calldata data,
        RevertContext calldata revertContext
    ) external;

    /// @notice Deposits ETH to the TSS address.
    /// @param receiver Address of the receiver.
    /// @param revertOptions Revert options.
    function deposit(
        address receiver,
        RevertOptions calldata revertOptions
    ) external payable;

    /// @notice Deposits ERC20 tokens to the custody or connector contract.
    /// @param receiver Address of the receiver.
    /// @param amount Amount of tokens to deposit.
    /// @param asset Address of the ERC20 token.
    /// @param revertOptions Revert options.
    function deposit(
        address receiver,
        uint256 amount,
        address asset,
        RevertOptions calldata revertOptions
    ) external;

    /// @notice Deposits ETH to the TSS address and calls an omnichain smart contract.
    /// @param receiver Address of the receiver.
    /// @param payload Calldata to pass to the call.
    /// @param revertOptions Revert options.
    function depositAndCall(
        address receiver,
        bytes calldata payload,
        RevertOptions calldata revertOptions
    ) external payable;

    /// @notice Deposits ERC20 tokens to the custody or connector contract and calls an omnichain smart contract.
    /// @param receiver Address of the receiver.
    /// @param amount Amount of tokens to deposit.
    /// @param asset Address of the ERC20 token.
    /// @param payload Calldata to pass to the call.
    /// @param revertOptions Revert options.
    function depositAndCall(
        address receiver,
        uint256 amount,
        address asset,
        bytes calldata payload,
        RevertOptions calldata revertOptions
    ) external;

    /// @notice Calls an omnichain smart contract without asset transfer.
    /// @param receiver Address of the receiver.
    /// @param payload Calldata to pass to the call.
    /// @param revertOptions Revert options.
    function call(
        address receiver,
        bytes calldata payload,
        RevertOptions calldata revertOptions
    ) external;
}

/// @notice Message context passed to execute function.
/// @param sender Sender from omnichain contract.
struct MessageContext {
    address sender;
}

/// @notice Interface implemented by contracts receiving authenticated calls.
interface Callable {
    function onCall(
        MessageContext calldata context,
        bytes calldata message
    ) external payable returns (bytes memory);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ISignatureTransfer} from "./ISignatureTransfer.sol";
import {IAllowanceTransfer} from "./IAllowanceTransfer.sol";

/// @notice Permit2 handles signature-based transfers in SignatureTransfer and allowance-based transfers in AllowanceTransfer.
/// @dev Users must approve Permit2 before calling any of the transfer functions.
interface IPermit2 is ISignatureTransfer, IAllowanceTransfer {
    // IPermit2 unifies the two interfaces so users have maximal flexibility with their approval.
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IEIP712} from "./IEIP712.sol";

/// @title SignatureTransfer
/// @notice Handles ERC20 token transfers through signature based actions
/// @dev Requires user's token approval on the Permit2 contract
interface ISignatureTransfer is IEIP712 {
    /// @notice Thrown when the requested amount for a transfer is larger than the permissioned amount
    /// @param maxAmount The maximum amount a spender can request to transfer
    error InvalidAmount(uint256 maxAmount);

    /// @notice Thrown when the number of tokens permissioned to a spender does not match the number of tokens being transferred
    /// @dev If the spender does not need to transfer the number of tokens permitted, the spender can request amount 0 to be transferred
    error LengthMismatch();

    /// @notice Emits an event when the owner successfully invalidates an unordered nonce.
    event UnorderedNonceInvalidation(address indexed owner, uint256 word, uint256 mask);

    /// @notice The token and amount details for a transfer signed in the permit transfer signature
    struct TokenPermissions {
        // ERC20 token address
        address token;
        // the maximum amount that can be spent
        uint256 amount;
    }

    /// @notice The signed permit message for a single token transfer
    struct PermitTransferFrom {
        TokenPermissions permitted;
        // a unique value for every token owner's signature to prevent signature replays
        uint256 nonce;
        // deadline on the permit signature
        uint256 deadline;
    }

    /// @notice Specifies the recipient address and amount for batched transfers.
    /// @dev Recipients and amounts correspond to the index of the signed token permissions array.
    /// @dev Reverts if the requested amount is greater than the permitted signed amount.
    struct SignatureTransferDetails {
        // recipient address
        address to;
        // spender requested amount
        uint256 requestedAmount;
    }

    /// @notice Used to reconstruct the signed permit message for multiple token transfers
    /// @dev Do not need to pass in spender address as it is required that it is msg.sender
    /// @dev Note that a user still signs over a spender address
    struct PermitBatchTransferFrom {
        // the tokens and corresponding amounts permitted for a transfer
        TokenPermissions[] permitted;
        // a unique value for every token owner's signature to prevent signature replays
        uint256 nonce;
        // deadline on the permit signature
        uint256 deadline;
    }

    /// @notice A map from token owner address and a caller specified word index to a bitmap. Used to set bits in the bitmap to prevent against signature replay protection
    /// @dev Uses unordered nonces so that permit messages do not need to be spent in a certain order
    /// @dev The mapping is indexed first by the token owner, then by an index specified in the nonce
    /// @dev It returns a uint256 bitmap
    /// @dev The index, or wordPosition is capped at type(uint248).max
    function nonceBitmap(address, uint256) external view returns (uint256);

    /// @notice Transfers a token using a signed permit message
    /// @dev Reverts if the requested amount is greater than the permitted signed amount
    /// @param permit The permit data signed over by the owner
    /// @param owner The owner of the tokens to transfer
    /// @param transferDetails The spender's requested transfer details for the permitted token
    /// @param signature The signature to verify
    function permitTransferFrom(
        PermitTransferFrom memory permit,
        SignatureTransferDetails calldata transferDetails,
        address owner,
        bytes calldata signature
    ) external;

    /// @notice Transfers a token using a signed permit message
    /// @notice Includes extra data provided by the caller to verify signature over
    /// @dev The witness type string must follow EIP712 ordering of nested structs and must include the TokenPermissions type definition
    /// @dev Reverts if the requested amount is greater than the permitted signed amount
    /// @param permit The permit data signed over by the owner
    /// @param owner The owner of the tokens to transfer
    /// @param transferDetails The spender's requested transfer details for the permitted token
    /// @param witness Extra data to include when checking the user signature
    /// @param witnessTypeString The EIP-712 type definition for remaining string stub of the typehash
    /// @param signature The signature to verify
    function permitWitnessTransferFrom(
        PermitTransferFrom memory permit,
        SignatureTransferDetails calldata transferDetails,
        address owner,
        bytes32 witness,
        string calldata witnessTypeString,
        bytes calldata signature
    ) external;

    /// @notice Transfers multiple tokens using a signed permit message
    /// @param permit The permit data signed over by the owner
    /// @param owner The owner of the tokens to transfer
    /// @param transferDetails Specifies the recipient and requested amount for the token transfer
    /// @param signature The signature to verify
    function permitTransferFrom(
        PermitBatchTransferFrom memory permit,
        SignatureTransferDetails[] calldata transferDetails,
        address owner,
        bytes calldata signature
    ) external;

    /// @notice Transfers multiple tokens using a signed permit message
    /// @dev The witness type string must follow EIP712 ordering of nested structs and must include the TokenPermissions type definition
    /// @notice Includes extra data provided by the caller to verify signature over
    /// @param permit The permit data signed over by the owner
    /// @param owner The owner of the tokens to transfer
    /// @param transferDetails Specifies the recipient and requested amount for the token transfer
    /// @param witness Extra data to include when checking the user signature
    /// @param witnessTypeString The EIP-712 type definition for remaining string stub of the typehash
    /// @param signature The signature to verify
    function permitWitnessTransferFrom(
        PermitBatchTransferFrom memory permit,
        SignatureTransferDetails[] calldata transferDetails,
        address owner,
        bytes32 witness,
        string calldata witnessTypeString,
        bytes calldata signature
    ) external;

    /// @notice Invalidates the bits specified in mask for the bitmap at the word position
    /// @dev The wordPos is maxed at type(uint248).max
    /// @param wordPos A number to index the nonceBitmap at
    /// @param mask A bitmap masked against msg.sender's current bitmap at the word position
    function invalidateUnorderedNonces(uint256 wordPos, uint256 mask) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

import "./IV2SwapRouter.sol";
import {IV3SwapRouter} from"./IV3SwapRouter.sol";

/// @title Router token swapping functionality
/// @notice Functions for swapping tokens via Uniswap V2 and V3
interface ISwapRouter is IV2SwapRouter, IV3SwapRouter {}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Callback for IUniswapV3PoolActions#swap
/// @notice Any contract that calls IUniswapV3PoolActions#swap must implement this interface
interface IUniswapV3SwapCallback {
    /// @notice Called to `msg.sender` after executing a swap via IUniswapV3Pool#swap.
    /// @dev In the implementation you must pay the pool tokens owed for the swap.
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
    /// @param amount0Delta The amount of token0 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
    /// @param amount1Delta The amount of token1 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
    /// @param data Any data passed through by the caller via the IUniswapV3PoolActions#swap call
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

/// @title Router token swapping functionality
/// @notice Functions for swapping tokens via Uniswap V2
interface IV2SwapRouter {
    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @dev Setting `amountIn` to 0 will cause the contract to look up its own balance,
    /// and swap the entire amount, enabling contracts to send tokens before calling this function.
    /// @param amountIn The amount of token to swap
    /// @param amountOutMin The minimum amount of output that must be received
    /// @param path The ordered list of tokens to swap through
    /// @param to The recipient address
    /// @return amountOut The amount of the received token
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to
    ) external payable returns (uint256 amountOut);

    /// @notice Swaps as little as possible of one token for an exact amount of another token
    /// @param amountOut The amount of token to swap for
    /// @param amountInMax The maximum amount of input that the caller will pay
    /// @param path The ordered list of tokens to swap through
    /// @param to The recipient address
    /// @return amountIn The amount of token to pay
    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to
    ) external payable returns (uint256 amountIn);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

import "./IUniswapV3SwapCallback.sol";

/// @title Router token swapping functionality
/// @notice Functions for swapping tokens via Uniswap V3
interface IV3SwapRouter is IUniswapV3SwapCallback {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInput(
        ExactInputParams calldata params
    ) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutputSingle(
        ExactOutputSingleParams calldata params
    ) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another along the specified path (reversed)
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactOutputParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutput(
        ExactOutputParams calldata params
    ) external payable returns (uint256 amountIn);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.6.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library TransferHelper {
    /// @notice Transfers tokens from the targeted address to the given destination
    /// @notice Errors with 'STF' if transfer fails
    /// @param token The contract address of the token to be transferred
    /// @param from The originating address from which the tokens will be transferred
    /// @param to The destination address of the transfer
    /// @param value The amount to be transferred
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(
                IERC20.transferFrom.selector,
                from,
                to,
                value
            )
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "STF"
        );
    }

    /// @notice Transfers tokens from msg.sender to a recipient
    /// @dev Errors with ST if transfer fails
    /// @param token The contract address of the token which will be transferred
    /// @param to The recipient of the transfer
    /// @param value The value of the transfer
    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20.transfer.selector, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "ST"
        );
    }

    /// @notice Approves the stipulated contract to spend the given allowance in the given token
    /// @dev Errors with 'SA' if transfer fails
    /// @param token The contract address of the token to be approved
    /// @param to The target of the approval
    /// @param value The amount of the given token the target will be allowed to spend
    function safeApprove(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20.approve.selector, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "SA"
        );
    }

    /// @notice Transfers ETH to the recipient address
    /// @dev Fails with `STE`
    /// @param to The destination of the transfer
    /// @param value The value to be transferred
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "STE");
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/// @notice Struct containing revert options
/// @param revertAddress Address to receive revert.
/// @param callOnRevert Flag if onRevert hook should be called.
/// @param abortAddress Address to receive funds if aborted.
/// @param revertMessage Arbitrary data sent back in onRevert.
/// @param onRevertGasLimit Gas limit for revert tx, unused on GatewayZEVM methods
struct RevertOptions {
    address revertAddress;
    bool callOnRevert;
    address abortAddress;
    bytes revertMessage;
    uint256 onRevertGasLimit;
}

/// @notice Struct containing revert context passed to onRevert.
/// @param sender Address of account that initiated smart contract call.
/// @param asset Address of asset, empty if it's gas token.
/// @param amount Amount specified with the transaction.
/// @param revertMessage Arbitrary data sent back in onRevert.
struct RevertContext {
    address sender;
    address asset;
    uint256 amount;
    bytes revertMessage;
}

/// @title Revertable
/// @notice Interface for contracts that support revertable calls.
interface Revertable {
    /// @notice Called when a revertable call is made.
    /// @param revertContext Revert context to pass to onRevert.
    function onRevert(RevertContext calldata revertContext) external;
}