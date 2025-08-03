// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

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
// SPDX-License-Identifier: UNLICENSED
// Uruloki DEX is NOT LICENSED FOR COPYING.
// Uruloki DEX (C) 2022. All Rights Reserved.

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IUniswapV2Router {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}

interface IUniswapV2Factory {
    function getPair(
        address tokenA, 
        address tokenB
    ) external view returns (address pair);
}

interface IOrderMgr {
    //// Define enums
    enum OrderType {
        TargetPrice,
        PriceRange
    }
    enum OrderStatus {
        Active,
        Cancelled,
        OutOfFunds,
        Completed
    }

    //// Define structs
    // One time order, it's a base order struct
    struct OrderBase {
        address userAddress;
        address pairedTokenAddress;
        address tokenAddress;
        OrderType orderType;
        uint256 targetPrice;
        bool isBuy;
        uint256 maxPrice;
        uint256 minPrice;
        OrderStatus status;
        uint256 amount;
        uint256 slippage;
        bool isContinuous;
    }

    // Continuous Order, it's an extended order struct, including the base order struct
    struct Order {
        OrderBase orderBase;
        uint256 numExecutions;
        uint256 resetPercentage;
        bool hasPriceReset;
    }

    function createOneTimeOrder(
        address userAddress,
        address pairedTokenAddress,
        address tokenAddress,
        bool isBuy,
        uint256 targetPrice,
        uint256 minPrice,
        uint256 maxPrice,
        uint256 amount,
        uint256 slippage
    ) external returns (uint256);

    function createContinuousOrder(
        address userAddress,
        address pairedTokenAddress,
        address tokenAddress,
        bool isBuy,
        uint256 targetPrice,
        uint256 minPrice,
        uint256 maxPrice,
        uint256 amount,
        uint256 slippage,
        uint256 resetPercentage
    ) external returns (uint256);

    function updateOrder(
        uint256 orderId,
        address pairedTokenAddress,
        address tokenAddress,
        bool isBuy,
        uint256 targetPrice,
        uint256 minPrice,
        uint256 maxPrice,
        uint256 amount,
        uint256 slippage,
        uint256 resetPercentage
    ) external;

    function cancelOrder(uint256 orderId) external returns (uint256);

    function orderCounter() external view returns (uint256);

    function getOrder(uint256 orderId) external view returns (Order memory);

    function setOrderStatus(
        uint256 orderId,
        IOrderMgr.OrderStatus status
    ) external;

    function incNumExecutions(uint256 orderId) external;

    function setHasPriceReset(uint256 orderId, bool flag) external;
}

interface IERC20Ext is IERC20 {
    function decimals() external view returns (uint8);
}

contract UrulokiDEX is ReentrancyGuard {
    //// Define events
    // Event emitted when a one-time order is created
    event OneTimeOrderCreated(uint256 orderId);

    // Event emitted when a continuous order is created
    event ContinuousOrderCreated(uint256 orderId);

    // Event emitted when a one-time order is edited
    event OneTimeOrderEdited(uint256 orderId);

    // Event emitted when a continuous order is edited
    event ContinuousOrderEdited(uint256 orderId);

    // Event emitted when an order is canceled
    event OrderCanceled(uint256 orderId);

    // Event emitted when the price is outside of the specified price range
    event ExecutedOutOfPrice(uint256 orderId, bool isBuy, uint256 price);

    // Event emitted when a one-time order is successfully executed
    event ExecutedOneTimeOrder(
        uint256 orderId,
        bool isBuy,
        uint256 pairAmount,
        uint256 tokenAmount,
        uint256 price
    );

    // Event emitted when a continuous order is successfully executed
    event ExecutedContinuousOrder(
        uint256 orderId,
        bool isBuy,
        uint256 price
    );

    // Event emitted when funds are withdrawn from a user's address
    event FundsWithdrawn(
        address userAddress,
        address tokenAddress,
        uint256 amount
    );

    // Event emitted when the owner of the contract is changed
    event BackendOwner(address newOwner);

    // Event emitted when an order is out of funds
    event OutOfFunds(uint256 orderId);

    // Event emitted when a swap during order execution fails
    event SwapFailed(uint256 orderId);

    // This event is emitted when no valid pairs for USDC, USDT, TSUKA, or WETH are found for the specified order
    event PairNotFound(uint256 orderId);

    //// Define constants
    address private constant UNISWAP_V2_ROUTER =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant UNISWAP_V2_FACTORY =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private constant WETH =
        0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant USDT =
        0xc28ab4E347dd26C5809540e7dB0CEa473D91439c;
    address private constant USDC =
        0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address private constant TSUKA =
        0xc5fB36dd2fb59d3B98dEfF88425a3F425Ee469eD;

    //// Define variables
    mapping(address => mapping(address => uint256)) public balances;

    IUniswapV2Router private uniswapRouter =
        IUniswapV2Router(UNISWAP_V2_ROUTER);
    IUniswapV2Factory private uniswapFactory =
        IUniswapV2Factory(UNISWAP_V2_FACTORY);

    address public backend_owner;
    address public orderMgrAddress;
    IOrderMgr _orderMgr;

    constructor() {
        backend_owner = msg.sender;
    }

    modifier initOneTimeOrderBalance (
        uint256 orderId
    ) {
        IOrderMgr.Order memory order = _orderMgr.getOrder(orderId);

        // Validate order owner
        require(
            order.orderBase.userAddress == msg.sender,
            "msg.sender is not order owner"
        );

        // Check if the order is a one-time order
        require(order.orderBase.isContinuous == false, "Incorrect order type");

        // Check if the order status is active
        require(order.orderBase.status == IOrderMgr.OrderStatus.Active, "Incorrect order status");

        // Update the balances based on the order type
        if(!order.orderBase.isBuy) {
            balances[msg.sender][order.orderBase.tokenAddress] += order.orderBase.amount;
        } else {
            balances[msg.sender][order.orderBase.pairedTokenAddress] += order.orderBase.amount;
        }

        _;
    }

    /**
     * @dev Validates a one-time order by checking the user's balance and updating it if necessary
     * @param pairedTokenAddress The address of the paired token
     * @param tokenAddress The address of the token
     * @param isBuy Boolean indicating if it's a buy order
     * @param amount The amount of tokens in the order
     * @return bool Returns true if the order is valid, false otherwise
     */
    function validateOneTimeOrder(
        address pairedTokenAddress,
        address tokenAddress,
        bool isBuy,
        uint256 amount
    ) internal returns (bool) {
        // if buying token, pair token is spendable else if sell, the token is spendable
        if (!isBuy) {
            // Check if the user has enough balance
            if(balances[msg.sender][tokenAddress] >= amount) {
                // Update the user's balance
                balances[msg.sender][tokenAddress] -= amount;
            } else 
                return false;
        } else {
            // Check if the user has enough balance
            if(balances[msg.sender][pairedTokenAddress] >= amount) {
                // Update the user's balance
                balances[msg.sender][pairedTokenAddress] -= amount;
            } else 
                return false;
        }

        return true;
    }

    // set backend owner address
    function setBackendOwner(address new_owner) public {
        require(msg.sender == backend_owner, "Not admin");
        backend_owner = new_owner;
        emit BackendOwner(backend_owner);
    }

    function setOrderMgr(address _orderMgrAddress) public {
        require(msg.sender == backend_owner, "setOrderMgr: not allowed");
        require(
            _orderMgrAddress != address(0),
            "setOrderMgr: invalid orderMgrAddress"
        );
        orderMgrAddress = _orderMgrAddress;
        _orderMgr = IOrderMgr(_orderMgrAddress);
    }

    /**
     * @notice allows users to make a deposit
     * @dev token should be transferred from the user wallet to the contract
     * @param tokenAddress token address
     * @param amount deposit amount
     */
    function addFunds(
        address tokenAddress,
        uint256 amount
    ) external nonReentrant {
        require(amount > 0, "Amount must be greater than zero");

        IERC20 token = IERC20(tokenAddress);
        uint256 balanceBefore = token.balanceOf(address(this));

        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );

        // Update the user's balance
        balances[USDT][tokenAddress] += token.balanceOf(address(this)) - balanceBefore;
        balances[msg.sender][tokenAddress] = balances[USDT][tokenAddress];
    }

    /**
     * @dev funds withdrawal external call
     * @param tokenAddress token address
     * @param amount token amount
     */
    function withdrawFunds(
        address tokenAddress,
        uint256 amount
    ) external nonReentrant {
        require(amount > 0, "Amount must be greater than zero");

        // Check if the user has enough balance to withdraw
        require(
            balances[msg.sender][tokenAddress] >= amount,
            "Insufficient balance"
        );

        // Update the user's balance
        balances[msg.sender][tokenAddress] -= amount;

        // Transfer ERC20 token to the user
        IERC20 token = IERC20(tokenAddress);
        require(token.transfer(msg.sender, amount), "Transfer failed");
        // Emit event
        emit FundsWithdrawn(msg.sender, tokenAddress, amount);
    }

    /**
     * @notice create non-continuous price range order
     * @dev The orders are only executed when the market price is less than or equal to the minPrice and greater than or equal to the maxPrice
     * @param pairedTokenAddress The address of the paired token in the trading pair
     * @param tokenAddress The address of the token being traded
     * @param isBuy Indicates whether it is a buy or sell order (true for buy, false for sell)
     * @param minPrice Minimum price for the order. The value's decimal is in USDC decimal 6 format
     * @param maxPrice Maximum price for the order. The value's decimal is in USDC decimal 6 format
     * @param amount The amount of tokens for the order. The value's decimal is the traded token decimal format.
     * @param slippage The slippage tolerance for the order. This is minAmountOut value and decimal is the traded token decimal format.
     */
    function createNonContinuousPriceRangeOrder(
        address pairedTokenAddress,
        address tokenAddress,
        bool isBuy,
        uint256 minPrice,
        uint256 maxPrice,
        uint256 amount,
        uint256 slippage
    )   external nonReentrant {
        require(validateOneTimeOrder(pairedTokenAddress, tokenAddress, isBuy, amount), "Validation failed");

        uint256 id = _orderMgr.createOneTimeOrder(
            msg.sender,
            pairedTokenAddress,
            tokenAddress,
            isBuy,
            0,
            minPrice,
            maxPrice,
            amount,
            slippage
        );
        // Emit an event
        emit OneTimeOrderCreated(id);
    }

    /**
     * @notice creates a non-continuous order with a target price
     * @dev Target price orders are only executed when certain conditions are met:
     * - For buy orders, the market price must be less than or equal to the target price
     * - For sell orders, the market price must be greater than or equal to the target price
     * @param pairedTokenAddress The address of the paired token in the trading pair
     * @param tokenAddress The address of the token being traded
     * @param isBuy Indicates whether it is a buy or sell order (true for buy, false for sell)
     * @param targetPrice The target price for the order. The value's decimal is in USDC decimal 6 format
     * @param amount The amount of tokens for the order. The value's decimal is the traded token decimal format.
     * @param slippage The slippage tolerance for the order. This is minAmountOut value and decimal is the traded token decimal format.
     */
    function createNonContinuousTargetPriceOrder(
        address pairedTokenAddress,
        address tokenAddress,
        bool isBuy,
        uint256 targetPrice,
        uint256 amount,
        uint256 slippage
    )   external nonReentrant {
        require(validateOneTimeOrder(pairedTokenAddress, tokenAddress, isBuy, amount), "Validation failed");

        // Create a new order
        uint256 id = _orderMgr.createOneTimeOrder(
            msg.sender,
            pairedTokenAddress,
            tokenAddress,
            isBuy,
            targetPrice,
            0,
            0,
            amount,
            slippage
        );

        // Emit event
        emit OneTimeOrderCreated(id);
    }

    /**
     * @notice creates a continuous order with price range
     * @dev The orders are only executed continuely when the market price is less than or equal to the minPrice and greater than or equal to the maxPrice
     * @param pairedTokenAddress The address of the paired token in the trading pair
     * @param tokenAddress The address of the token being traded
     * @param isBuy Indicates whether it is a buy or sell order (true for buy, false for sell)
     * @param minPrice Minimum price for the order. The value's decimal is in USDC decimal 6 format
     * @param maxPrice Maximum price for the order. The value's decimal is in USDC decimal 6 format
     * @param amount The amount of tokens for the order. The value's decimal is the traded token decimal format.
     * @param slippage The slippage tolerance for the order. This is minAmountOut value and decimal is the traded token decimal format.
     * @param resetPercentage decimal represented as an int with 0 places of precision
     */
    function createContinuousPriceRangeOrder(
        address pairedTokenAddress,
        address tokenAddress,
        bool isBuy,
        uint256 minPrice,
        uint256 maxPrice,
        uint256 amount,
        uint256 slippage,
        uint256 resetPercentage
    ) external nonReentrant {
        uint256 id = _orderMgr.createContinuousOrder(
            msg.sender,
            pairedTokenAddress,
            tokenAddress,
            isBuy,
            0,
            minPrice,
            maxPrice,
            amount,
            slippage,
            resetPercentage
        );

        // Emit an event
        emit ContinuousOrderCreated(id);
    }

    /**
     * @notice creates a continuous order with a target price
     * @dev The orders are only executed continuely when certain conditions are met:
     * - For buy orders, the market price must be less than or equal to the target price
     * - For sell orders, the market price must be greater than or equal to the target price
     * @param pairedTokenAddress The address of the paired token in the trading pair
     * @param tokenAddress The address of the token being traded
     * @param isBuy Indicates whether it is a buy or sell order (true for buy, false for sell)
     * @param targetPrice The target price for the order. The value's decimal is in USDC decimal 6 format
     * @param amount The amount of tokens for the order. The value's decimal is the traded token decimal format.
     * @param slippage The slippage tolerance for the order. This is minAmountOut value and decimal is the traded token decimal format.
     * @param resetPercentage decimal represented as an int with 0 places of precision
     */
    function createContinuousTargetPriceOrder(
        address pairedTokenAddress,
        address tokenAddress,
        bool isBuy,
        uint256 targetPrice,
        uint256 amount,
        uint256 slippage,
        uint256 resetPercentage
    ) external nonReentrant {
        // Create the ContinuousOrder struct
        uint256 id = _orderMgr.createContinuousOrder(
            msg.sender,
            pairedTokenAddress,
            tokenAddress,
            isBuy,
            targetPrice,
            0,
            0,
            amount,
            slippage,
            resetPercentage
        );

        // Emit an event
        emit ContinuousOrderCreated(id);
    }

    /**
     * @dev cancel exist order
     * @param orderId order id
     */
    function cancelOrder(uint256 orderId) external {
        // Validate order owner
        IOrderMgr.Order memory order = _orderMgr.getOrder(orderId);
        require(
            order.orderBase.userAddress == msg.sender,
            "msg.sender is not order owner"
        );

        _orderMgr.cancelOrder(orderId);
        if (!order.orderBase.isContinuous)
            if (order.orderBase.isBuy) {
                balances[msg.sender][order.orderBase.pairedTokenAddress] += order
                    .orderBase
                    .amount;
            } else {
                balances[msg.sender][order.orderBase.tokenAddress] += order
                    .orderBase
                    .amount;
            }

        // Emit event
        emit OrderCanceled(orderId);
    }

    /**
     * @notice process a one-time order
     * @dev internal function
     * @param orderId id of the order
     */
    function _processOneTimeOrder(IOrderMgr.Order memory order, uint256 orderId) internal returns (bool) {
        // Get the price in amount
        uint256 price = _getPairPrice(
            order.orderBase.tokenAddress,
            10 ** IERC20Ext(order.orderBase.tokenAddress).decimals()
        );
        
        if(price == 0) {
            emit PairNotFound(orderId);
            return false;
        }

        address fromToken;
        address toToken;
        uint256 toAmount;
        bool swapStatus;

        // Check if the order type is PriceRange
        if (order.orderBase.orderType == IOrderMgr.OrderType.PriceRange) {
            if (
                order.orderBase.minPrice > price || price > order.orderBase.maxPrice
            ) {
                emit ExecutedOutOfPrice(orderId, order.orderBase.isBuy, price);
                return false;
            }
        }

        if (order.orderBase.isBuy) {
            // Check if the order type is TargetPrice
            if (order.orderBase.orderType == IOrderMgr.OrderType.TargetPrice) {
                if (
                    price > order.orderBase.targetPrice
                ) {
                    emit ExecutedOutOfPrice(orderId, order.orderBase.isBuy, price);
                    return false;
                }
            }
            fromToken = order.orderBase.pairedTokenAddress;
            toToken = order.orderBase.tokenAddress;
        } else {
            // Check if the order type is TargetPrice
            if (order.orderBase.orderType == IOrderMgr.OrderType.TargetPrice) {
                if (price < order.orderBase.targetPrice) {
                    emit ExecutedOutOfPrice(orderId, order.orderBase.isBuy, price);
                    return false;
                }
            }
            fromToken = order.orderBase.tokenAddress;
            toToken = order.orderBase.pairedTokenAddress;
        }

        (toAmount, swapStatus) = _swapTokens(
            fromToken, 
            toToken, 
            order.orderBase.amount,
            order.orderBase.slippage
        );

        if(swapStatus) {
            balances[order.orderBase.userAddress][toToken] += toAmount;

            _orderMgr.setOrderStatus(orderId, IOrderMgr.OrderStatus.Completed);
            emit ExecutedOneTimeOrder(
                orderId,
                order.orderBase.isBuy,
                order.orderBase.amount,
                toAmount,
                price
            );

            return true;
        } else {
            emit SwapFailed(orderId);
            return false;
        }
    }

    /**
     * @notice process a continuous order
     * @dev internal function
     * @param orderId id of the order
     */
    function _processContinuousOrder(IOrderMgr.Order memory order, uint256 orderId) internal returns (bool){
        if (order.orderBase.targetPrice == 0) {
            // Price range order
            return _processContinuousPriceRangeOrder(order, orderId);
        } else {
            // Target price order
            return _processContinuousTargetPriceOrder(order, orderId);
        }
    }

    /**
     * @dev Internal function to process a continuous price range order
     * @param order The order memory instance
     * @param orderId Order ID
     * @return bool Returns true if the order is processed successfully, false otherwise
     */
    function _processContinuousPriceRangeOrder(
        IOrderMgr.Order memory order,
        uint256 orderId
    ) internal returns(bool) {
        // Get the price in amount
        uint256 price = _getPairPrice(
            order.orderBase.tokenAddress,
            10 ** IERC20Ext(order.orderBase.tokenAddress).decimals()
        );

        // Check if the price is not found for the pair
        if(price == 0) {
            emit PairNotFound(orderId);
            return false;
        }

        // Check if the order has price reset
        if (order.hasPriceReset) {
            // Check if the price is within the specified range
            if (
                !(
                price > order.orderBase.minPrice 
                && price < order.orderBase.maxPrice
                )
            ) {
                emit ExecutedOutOfPrice(orderId, order.orderBase.isBuy, price);
                return false;
            }
            address fromToken;
            address toToken;
            uint256 toAmount;
            bool swapStatus;

            // Determine the tokens for swapping based on the order type
            if (order.orderBase.isBuy) {
                fromToken = order.orderBase.pairedTokenAddress;
                toToken = order.orderBase.tokenAddress;
            } else {
                fromToken = order.orderBase.tokenAddress;
                toToken = order.orderBase.pairedTokenAddress;
            }

            // Check if the user has enough balance of the fromToken
            if (
                balances[order.orderBase.userAddress][fromToken] >=
                order.orderBase.amount
            ) {
                // Swap tokens
                (toAmount, swapStatus) = _swapTokens(
                    fromToken,
                    toToken,
                    order.orderBase.amount,
                    order.orderBase.slippage
                );

                if(swapStatus) {
                    // Update user's balances
                    balances[order.orderBase.userAddress][toToken] += toAmount;
                    balances[order.orderBase.userAddress][fromToken] -= order
                        .orderBase
                        .amount;
                    
                    // Update order status and execution count
                    _orderMgr.setOrderStatus(orderId, IOrderMgr.OrderStatus.Active);
                    _orderMgr.incNumExecutions(orderId);
                    _orderMgr.setHasPriceReset(orderId, false);

                    emit ExecutedContinuousOrder(orderId, order.orderBase.isBuy, price);
                } else {
                    emit SwapFailed(orderId);
                }
            } else {
                // Set order status as out of funds
                _orderMgr.setOrderStatus(
                    orderId,
                    IOrderMgr.OrderStatus.OutOfFunds
                );
                emit OutOfFunds(orderId);
            }
        } else {
            // Calculate the lower and upper price differences based on the reset percentage
            uint256 lowerDiff = (order.orderBase.minPrice *
                order.resetPercentage) / 100;
            uint256 upperDiff = (order.orderBase.maxPrice *
                order.resetPercentage) / 100;

            // Check if the price is outside the adjusted range
            if (
                !(price < order.orderBase.minPrice - lowerDiff
                || price > order.orderBase.maxPrice + upperDiff)
            ) {
                return false;
            }

            // Set hasPriceReset to true for the order
            _orderMgr.setHasPriceReset(orderId, true);
        }
        
        return true;
    }

    /**
     * @dev Processes a continuous order with a target price
     * @param order The order to process
     * @param orderId The ID of the order
     * @return bool Returns true if the order is successfully processed, false otherwise
     */
    function _processContinuousTargetPriceOrder(
        IOrderMgr.Order memory order,
        uint256 orderId
    ) internal returns (bool) {
        // Get the price in amount
        uint256 price = _getPairPrice(
            order.orderBase.tokenAddress,
            10 ** IERC20Ext(order.orderBase.tokenAddress).decimals()
        );

        // Check if the price is 0, indicating that the pair does not exist
        if(price == 0) {
            emit PairNotFound(orderId);
            return false;
        }

        // Check if the order is a buy order
        if (order.orderBase.isBuy) {
            // Check if the order has price reset
            if (order.hasPriceReset) {
                // Check if the current price is greater than the target price
                if (price > order.orderBase.targetPrice) {
                    emit ExecutedOutOfPrice(orderId, order.orderBase.isBuy, price);
                    return false;
                }

                // Swap tokens and update balances
                address fromToken;
                address toToken;
                uint256 toAmount;
                bool swapStatus;

                fromToken = order.orderBase.pairedTokenAddress;
                toToken = order.orderBase.tokenAddress;

                // Check if the user has sufficient balance of fromToken
                if (
                    balances[order.orderBase.userAddress][fromToken] >=
                    order.orderBase.amount
                ) {
                    (toAmount, swapStatus) = _swapTokens(
                        fromToken,
                        toToken,
                        order.orderBase.amount,
                        order.orderBase.slippage
                    );

                    if(swapStatus) {
                        // Update user's balances
                        balances[order.orderBase.userAddress][toToken] += toAmount;
                        balances[order.orderBase.userAddress][fromToken] -= order
                            .orderBase
                            .amount;

                        // Update order status and execution count
                        _orderMgr.setOrderStatus(
                            orderId,
                            IOrderMgr.OrderStatus.Active
                        );
                        _orderMgr.incNumExecutions(orderId);
                        _orderMgr.setHasPriceReset(orderId, false);

                        emit ExecutedContinuousOrder(orderId, order.orderBase.isBuy, price);
                    } else {
                        emit SwapFailed(orderId);
                    }
                } else {
                    // Set order status as out of funds
                    _orderMgr.setOrderStatus(
                        orderId,
                        IOrderMgr.OrderStatus.OutOfFunds
                    );
                    emit OutOfFunds(orderId);
                }
            } else {
                uint256 diff = (order.orderBase.targetPrice *
                    order.resetPercentage) / 100;

                // Check if the current price is less than the target price plus the difference
                if (price < order.orderBase.targetPrice + diff) {
                    return false;
                }
                _orderMgr.setHasPriceReset(orderId, true);
            }
        } else {
            // Check if the order has price reset
            if (order.hasPriceReset) {
                // Check if the current price is less than the target price
                if (price < order.orderBase.targetPrice) {
                    emit ExecutedOutOfPrice(orderId, order.orderBase.isBuy, price);
                    return false;
                }

                // Swap tokens and update balances
                address fromToken;
                address toToken;
                uint256 toAmount;
                bool swapStatus;

                fromToken = order.orderBase.tokenAddress;
                toToken = order.orderBase.pairedTokenAddress;

                // Check if the user has sufficient balance of fromToken
                if (
                    balances[order.orderBase.userAddress][fromToken] >=
                    order.orderBase.amount
                ) {
                    (toAmount, swapStatus) = _swapTokens(
                        fromToken,
                        toToken,
                        order.orderBase.amount,
                        order.orderBase.slippage
                    );

                    if(swapStatus) {
                        balances[order.orderBase.userAddress][toToken] += toAmount;
                        balances[order.orderBase.userAddress][fromToken] -= order
                            .orderBase
                            .amount;

                        _orderMgr.setOrderStatus(
                            orderId,
                            IOrderMgr.OrderStatus.Active
                        );
                        _orderMgr.incNumExecutions(orderId);
                        _orderMgr.setHasPriceReset(orderId, false);

                        emit ExecutedContinuousOrder(orderId, order.orderBase.isBuy, price);
                    } else {
                        emit SwapFailed(orderId);
                    }
                } else {
                    _orderMgr.setOrderStatus(
                        orderId,
                        IOrderMgr.OrderStatus.OutOfFunds
                    );
                    emit OutOfFunds(orderId);
                }
            } else {
                uint256 diff = (order.orderBase.targetPrice *
                    order.resetPercentage) / 100;

                // Check if the current price is greater than the target price minus the difference
                if (price > order.orderBase.targetPrice - diff) {
                    return false;
                }
                _orderMgr.setHasPriceReset(orderId, true);
            }
        }
        
        return true;
    }

    /**
     * @dev Processes multiple orders based on the provided order IDs
     * @param orderIds An array of order IDs to process
     */
    function processOrders(
        uint256[] memory orderIds
    ) external {
        IOrderMgr.Order memory order;

        // Iterate through each order ID in the orderIds array
        for (uint256 i = 0; i < orderIds.length; i++) {
            order = _orderMgr.getOrder(orderIds[i]);
            uint256 orderId = orderIds[i];
            
            // Check if the tokenAddress of the order is the zero address
            // If it is, skip to the next iteration of the loop
            if (order.orderBase.tokenAddress == address(0))
                continue;

            // Check if the order is a continuous order
            if (order.orderBase.isContinuous == true) {
                // If the order is cancelled, skip to the next iteration of the loop
                if (order.orderBase.status == IOrderMgr.OrderStatus.Cancelled)
                    continue;
                _processContinuousOrder(order, orderId);
            } else {
                // If the order is not active, skip to the next iteration of the loop
                if (order.orderBase.status != IOrderMgr.OrderStatus.Active)
                    continue;
                _processOneTimeOrder(order, orderId);
            }
        }
    }

    /**
     * @dev Swaps tokens from one token to another using the Uniswap router
     * @param _fromTokenAddress The address of the token to swap from
     * @param _toTokenAddress The address of the token to swap to
     * @param _amount The amount of tokens to swap
     * @param _slippage The maximum acceptable slippage for the swap
     * @return uint256 The amount of tokens received after the swap
     * @return bool The status of the swap (true if successful, false otherwise)
     */
    function _swapTokens(
        address _fromTokenAddress,
        address _toTokenAddress,
        uint256 _amount,
        uint256 _slippage
    ) internal returns (uint256, bool) {
        IERC20 fromToken = IERC20(_fromTokenAddress);
        
        fromToken.approve(address(uniswapRouter), _amount);

        address[] memory path = new address[](2);
        path[0] = _fromTokenAddress;
        path[1] = _toTokenAddress;

        uint256 balanceBefore = IERC20(_toTokenAddress).balanceOf(address(this));
        
        try uniswapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _amount,
            _slippage,
            path,
            address(this),
            block.timestamp
        ) {} catch (bytes memory) {
            return (0, false);
        }
        uint256 toAmount = IERC20(_toTokenAddress).balanceOf(address(this)) - balanceBefore;

        // Return the amount of tokens received and the status of the swap
        return (toAmount, true);
    }

    /**
    * @dev Checks if a pair exists for the given tokens in the Uniswap exchange
    * @param token1 The address of the first token
    * @param token2 The address of the second token
    * @return bool Returns true if a pair exists, false otherwise
    */
    function checkIfPairExists(
        address token1,
        address token2
    ) public view returns(bool) {
        // Get the pair address from the Uniswap factory contract
        address pair = uniswapFactory.getPair(token1, token2);
        
        // If the pair address is equal to the zero address, it means the pair does not exist.
        if(pair == address(0)) return false;
        else return true;
    }

    /**
    * @dev Retrieves the price of a token pair based on the specified token address and amount
    * @param _tokenAddress The address of the token
    * @param _amount The amount of the token
    * @return uint256 The price of the token pair
    */
    function _getPairPrice(
        address _tokenAddress,
        uint256 _amount
    ) internal view returns (uint256) {
        // Check if a pair exists for USDC and the specified token
        if (checkIfPairExists(USDC, _tokenAddress)) {
            address[] memory path = new address[](2);
            path[0] = _tokenAddress;
            path[1] = USDC;
            return getAmountOut(path, _amount);
        }
        
        // Check if a pair exists for USDT and the specified token
        if (checkIfPairExists(USDT, _tokenAddress)) {
            address[] memory path = new address[](2);
            path[0] = _tokenAddress;
            path[1] = USDT;
            return getAmountOut(path, _amount);
        }
        
        // Check if a pair exists for WETH and the specified token
        if (checkIfPairExists(WETH, _tokenAddress)) {
            address[] memory path = new address[](3);
            path[0] = _tokenAddress;
            path[1] = WETH;
            path[2] = USDC;
            return getAmountOut(path, _amount);
        }
        
        // Check if a pair exists for TSUKA and the specified token
        if (checkIfPairExists(TSUKA, _tokenAddress)) {
            address[] memory path = new address[](3);
            path[0] = _tokenAddress;
            path[1] = TSUKA;
            path[2] = USDC;
            return getAmountOut(path, _amount);
        }
        
        // If no pair exists, return 0
        return 0;
    }

    /**
     * @dev Retrieves the amount out for a given input amount and path of token addresses
     * @param path The array of token addresses representing the path
     * @param amount The input amount
     * @return uint256 The amount out
     */
    function getAmountOut(
        address[] memory path,
        uint256 amount
    ) internal view returns (uint256) {
        // Get the amounts out for the specified input amount and path
        uint[] memory amountsOut = uniswapRouter.getAmountsOut(amount, path);
        
        // The getAmountsOut function from the Uniswap router contract is called with the specified input amount and path
        // It returns an array of amounts representing the output amounts at each step of the path

        // Return the amount out of the final token.
        // The amount out is obtained by accessing the last element of the amountsOut array using path.length - 1
        // This represents the output amount of the final token in the path after the swap
        return amountsOut[path.length - 1];
    }

    /**
     * @dev Retrieves the price of a token based on the specified token address
     * @param _tokenAddress The address of the token
     * @return uint256 The price of the token
     */
    function getTokenPrice(
        address _tokenAddress
    ) external view returns (uint256) {
        // Get the decimals of the token
        uint256 tokenDecimals = 10 ** IERC20Ext(_tokenAddress).decimals();

        // Get the pair price for the specified token
        return _getPairPrice(_tokenAddress, tokenDecimals);
    }

    /**
     * @notice edit a continuous order with target price
     * @param orderId Order id
     * @param pairedTokenAddress The address of the paired token in the trading pair
     * @param tokenAddress The address of the token being traded
     * @param isBuy Indicates whether it is a buy or sell order (true for buy, false for sell)
     * @param targetPrice The target price for the order. The value's decimal is in USDC decimal 6 format
     * @param amount The amount of tokens for the order. The value's decimal is the traded token decimal format.
     * @param slippage The slippage tolerance for the order. This is minAmountOut value and decimal is the traded token decimal format.
     * @param resetPercentage decimal represented as an int with 0 places of precision
     */
    function editContinuousTargetPriceOrder(
        uint256 orderId,
        address pairedTokenAddress,
        address tokenAddress,
        bool isBuy,
        uint256 targetPrice,
        uint256 amount,
        uint256 slippage,
        uint256 resetPercentage
    ) external {
        IOrderMgr.Order memory order = _orderMgr.getOrder(orderId);
        // Validate order owner
        require(
            order.orderBase.userAddress == msg.sender,
            "msg.sender is not order owner"
        );
        // Is continous order
        require(order.orderBase.isContinuous == true, "Incorrect order type");

        _orderMgr.updateOrder(
            orderId,
            pairedTokenAddress,
            tokenAddress,
            isBuy,
            targetPrice,
            0,
            0,
            amount,
            slippage,
            resetPercentage
        );

        // Emit an event
        emit ContinuousOrderEdited(orderId);
    }

    /**
     * @notice edit a continuous order with price range
     * @param orderId order id
     * @param pairedTokenAddress The address of the paired token in the trading pair
     * @param tokenAddress The address of the token being traded
     * @param isBuy Indicates whether it is a buy or sell order (true for buy, false for sell)
     * @param minPrice Minimum price for the order. The value's decimal is in USDC decimal 6 format
     * @param maxPrice Maximum price for the order. The value's decimal is in USDC decimal 6 format
     * @param amount The amount of tokens for the order. The value's decimal is the traded token decimal format.
     * @param slippage The slippage tolerance for the order. This is minAmountOut value and decimal is the traded token decimal format.
     * @param resetPercentage decimal represented as an int with 0 places of precision
     */
    function editContinuousPriceRangeOrder(
        uint256 orderId,
        address pairedTokenAddress,
        address tokenAddress,
        bool isBuy,
        uint256 minPrice,
        uint256 maxPrice,
        uint256 amount,
        uint256 slippage,
        uint256 resetPercentage
    ) external {
        IOrderMgr.Order memory order = _orderMgr.getOrder(orderId);
        // Validate order owner
        require(
            order.orderBase.userAddress == msg.sender,
            "msg.sender is not order owner"
        );
        // Is continous order
        require(order.orderBase.isContinuous == true, "Incorrect order type");

        _orderMgr.updateOrder(
            orderId,
            pairedTokenAddress,
            tokenAddress,
            isBuy,
            0,
            minPrice,
            maxPrice,
            amount,
            slippage,
            resetPercentage
        );

        // Emit an event
        emit ContinuousOrderEdited(orderId);
    }

    /**
     * @notice Edit non-continuous order with price range
     * @param orderId Order id
     * @param pairedTokenAddress The address of the paired token in the trading pair
     * @param tokenAddress The address of the token being traded
     * @param isBuy Indicates whether it is a buy or sell order (true for buy, false for sell)
     * @param minPrice Minimum price for the order. The value's decimal is in USDC decimal 6 format
     * @param maxPrice Maximum price for the order. The value's decimal is in USDC decimal 6 format
     * @param amount The amount of tokens for the order. The value's decimal is the traded token decimal format.
     * @param slippage The slippage tolerance for the order. This is minAmountOut value and decimal is the traded token decimal format.
     */
    function editNonContinuousPriceRangeOrder(
        uint256 orderId,
        address pairedTokenAddress,
        address tokenAddress,
        bool isBuy,
        uint256 minPrice,
        uint256 maxPrice,
        uint256 amount,
        uint256 slippage
    ) 
        external
        nonReentrant
        initOneTimeOrderBalance(orderId)
    {
        require(validateOneTimeOrder(pairedTokenAddress, tokenAddress, isBuy, amount), "Validation failed");

        _orderMgr.updateOrder(
            orderId,
            pairedTokenAddress,
            tokenAddress,
            isBuy,
            0,
            minPrice,
            maxPrice,
            amount,
            slippage,
            0
        );
        // Emit an event
        emit OneTimeOrderEdited(orderId);
    }

    /**
     * @notice Edit a non-continuous order with a target price
     * @dev Target price order is only executed when the market price is equal to the target price
     * @param orderId Order id
     * @param pairedTokenAddress The address of the paired token in the trading pair
     * @param tokenAddress The address of the token being traded
     * @param isBuy Indicates whether it is a buy or sell order (true for buy, false for sell)
     * @param targetPrice The target price for the order. The value's decimal is in USDC decimal 6 format
     * @param amount The amount of tokens for the order. The value's decimal is the traded token decimal format.
     * @param slippage The slippage tolerance for the order. This is minAmountOut value and decimal is the traded token decimal format.
     */
    function editNonContinuousTargetPriceOrder(
        uint256 orderId,
        address pairedTokenAddress,
        address tokenAddress,
        uint256 targetPrice,
        bool isBuy,
        uint256 amount,
        uint256 slippage
    ) 
        external
        nonReentrant
        initOneTimeOrderBalance(orderId)
    {
        require(validateOneTimeOrder(pairedTokenAddress, tokenAddress, isBuy, amount), "Validation failed");

        _orderMgr.updateOrder(
            orderId,
            pairedTokenAddress,
            tokenAddress,
            isBuy,
            targetPrice,
            0,
            0,
            amount,
            slippage,
            0
        );

        // Emit event
        emit OneTimeOrderEdited(orderId);
    }
}