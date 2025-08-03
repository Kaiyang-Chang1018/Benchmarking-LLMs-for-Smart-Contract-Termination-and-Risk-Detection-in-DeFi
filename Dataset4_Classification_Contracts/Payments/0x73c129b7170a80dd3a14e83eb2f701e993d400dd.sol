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
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import "./interfaces/ITokiErrors.sol";
import "./interfaces/IBridgeRouter.sol";
import "./interfaces/IETHBridge.sol";
import "./interfaces/IETHVault.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ETHBridge is ITokiErrors, IETHBridge {
    address public immutable ETH_VAULT;
    IBridgeStandardRouter public immutable BRIDGE;
    uint256 public immutable ETH_POOL_ID;

    constructor(address ethVault, address bridge, uint256 ethPoolId) {
        if (ethVault == address(0)) {
            revert TokiZeroAddress("ethVault");
        }
        if (bridge == address(0)) {
            revert TokiZeroAddress("bridge");
        }

        ETH_VAULT = ethVault;
        BRIDGE = IBridgeStandardRouter(bridge);
        ETH_POOL_ID = ethPoolId;
    }

    function depositETH() external payable {
        if (msg.value == 0) {
            revert TokiZeroAmount("msg.value");
        }

        IETHVault(ETH_VAULT).deposit{value: msg.value}();
        // ERC20Upgradeable's approve function returns true or revert.
        // solhint-disable-next-line no-unused-vars
        bool _approved = IERC20(ETH_VAULT).approve(address(BRIDGE), msg.value);

        BRIDGE.deposit(ETH_POOL_ID, msg.value, msg.sender);
    }

    function transferETH(
        string calldata srcChannel,
        uint256 amountLD,
        uint256 minAmountLD,
        bytes calldata to,
        uint256 refuelAmount,
        IBCUtils.ExternalInfo calldata externalInfo,
        address payable refundTo
    ) external payable {
        if (msg.value < amountLD) {
            revert TokiInsufficientAmount("msg.value", msg.value, amountLD);
        }

        // Note about slither-disable:
        //   ETH_VAULT can only be set in constructor which called by authorized deployer.
        // slither-disable-next-line arbitrary-send-eth
        IETHVault(ETH_VAULT).deposit{value: amountLD}();
        // ERC20Upgradeable's approve function returns true or revert.
        // solhint-disable-next-line no-unused-vars
        bool _approved = IERC20(ETH_VAULT).approve(address(BRIDGE), amountLD);

        BRIDGE.transferPool{value: msg.value - amountLD}(
            srcChannel,
            ETH_POOL_ID,
            ETH_POOL_ID,
            amountLD,
            minAmountLD,
            to,
            refuelAmount,
            externalInfo,
            refundTo
        );
    }
}
// SPDX-License-Identifier: BUSL-1.1
// solhint-disable-next-line one-contract-per-file
pragma solidity 0.8.28;

import "../library/IBCUtils.sol";

/**
 * @title IBridgeStandardRouter
 * @dev Interface that contains the standard functions of the Bridge service.
 */
interface IBridgeStandardRouter {
    /**
     * @dev Deposits tokens into the specified pool to provide liquidity.
     * In exchange for depositing asset tokens, LP tokens are obtained.
     * @param poolId The ID of the pool to deposit into.
     * @param amountLD The amount of tokens to deposit in LD units.
     * @param to The address to receive the deposited tokens.
     */
    function deposit(uint256 poolId, uint256 amountLD, address to) external;

    /**
     * @dev Transfers tokens from the source pool to the destination pool and makes a remittance request on the destination side.
     * Initiates cross-chain transactions. For a detailed flow, refer to IPool.
     * @param srcChannel The channel for identifying the destination chain.
     * @param srcPoolId The ID of the source pool.
     * @param dstPoolId The ID of the destination pool.
     * @param amountLD The amount of tokens to transfer in LD units.
     * @param minAmountLD The minimum amount of tokens to transfer in LD units.
     * @param to The address to receive the transferred tokens.
     * @param refuelAmount The amount of the destination chain's native asset.
     * The equivalent value of native asset is consumed on the source.
     * @param externalInfo The payload to call the outer service on the destination chain.
     * @param refundTo The address to refund the remaining native asset.
     */
    function transferPool(
        string calldata srcChannel,
        uint256 srcPoolId,
        uint256 dstPoolId,
        uint256 amountLD,
        uint256 minAmountLD,
        bytes calldata to,
        uint256 refuelAmount,
        IBCUtils.ExternalInfo calldata externalInfo,
        address payable refundTo
    ) external payable;

    /**
     * @dev Transfers the token escrow from the source chain to the destination chain.
     * Initiates cross-chain transactions. For a detailed flow, refer to IPool.
     * @param srcChannel The channel for identifying the destination chain.
     * @param denom The denomination of tokens.
     * @param amountLD The amount of tokens to transfer in LD units.
     * @param to The address to receive the transferred tokens.
     * @param refuelAmount The amount of the destination chain's native asset.
     * The equivalent value of native asset is consumed on the source.
     * @param externalInfo The payload to call the outer service on the destination chain.
     * @param refundTo The address to refund the remaining native asset.
     */
    function transferToken(
        string calldata srcChannel,
        string calldata denom,
        uint256 amountLD,
        bytes calldata to,
        uint256 refuelAmount,
        IBCUtils.ExternalInfo calldata externalInfo,
        address payable refundTo
    ) external payable;

    /**
     * @dev Withdraws tokens from the source pool to the destination pool, and in exchange, burn LP tokens locally.
     * Initiates cross-chain transactions. For a detailed flow, refer to IPool.
     * @param srcChannel The channel for identifying the destination chain.
     * @param srcPoolId The ID of the source pool.
     * @param dstPoolId The ID of the destination pool.
     * @param amountLP The amount of LP tokens to burn.
     * @param minAmountLD The minimum amount of tokens to withdraw in LD units.
     * @param to The address to receive the withdrawn tokens.
     * @param refundTo The address to refund the remaining native asset.
     */
    function withdrawRemote(
        string calldata srcChannel,
        uint256 srcPoolId,
        uint256 dstPoolId,
        uint256 amountLP,
        uint256 minAmountLD,
        bytes calldata to,
        address payable refundTo
    ) external payable;

    /**
     * @dev Withdraws tokens from the destination pool to the source pool.
     * withdrawLocal burns local LP tokens and uses the balance that the destination pool can send to the source pool to withdraw tokens in the source pool.
     * Initiates cross-chain transactions. For a detailed flow, refer to IPool.
     * @param srcChannel The channel for identifying the destination chain.
     * @param srcPoolId The ID of the source pool.
     * @param dstPoolId The ID of the destination pool.
     * @param amountLP The amount of LP tokens to burn.
     * @param to The address to receive the withdrawn tokens.
     * @param refundTo The address to refund the remaining native asset.
     */
    function withdrawLocal(
        string calldata srcChannel,
        uint256 srcPoolId,
        uint256 dstPoolId,
        uint256 amountLP,
        bytes calldata to,
        address payable refundTo
    ) external payable;

    /** In Ledger **/

    /**
     * @dev Transfers tokens from the source pool to the destination pool and makes a remittance request on the destination side.
     * If it has the suffix 'InLedger', it is a single transaction rather than a cross-chain transaction.
     * @param srcPoolId The ID of the source pool.
     * @param dstPoolId The ID of the destination pool.
     * @param amountLD_ The amount of tokens to transfer in LD units.
     * @param minAmountLD The minimum amount of tokens to transfer in LD units.
     * @param to The address to receive the transferred tokens.
     * @param externalInfo The payload to call the outer service on the source chain.
     */
    function transferPoolInLedger(
        uint256 srcPoolId,
        uint256 dstPoolId,
        uint256 amountLD_,
        uint256 minAmountLD,
        address to,
        IBCUtils.ExternalInfo calldata externalInfo
    ) external;

    /**
     * @dev Withdraws tokens instantly.
     * @param srcPoolId The address from which the tokens are withdrawn.
     * @param amountLP The amount of LP tokens to withdraw in GD units.
     * @param to The address to receive the tokens.
     * @return amountGD The amount of tokens withdrawn in GD units.
     */
    function withdrawInstant(
        uint256 srcPoolId,
        uint256 amountLP,
        address to
    ) external returns (uint256 amountGD);

    /**
     * @dev Withdraws tokens from the destination pool to the source pool.
     * If it has the suffix 'InLedger', it is a single transaction rather than a cross-chain transaction.
     * @param srcPoolId The ID of the source pool.
     * @param dstPoolId The ID of the destination pool.
     * @param amountLP The amount of LP tokens to burn.
     * @param to The address to receive the withdrawn tokens.
     */
    function withdrawLocalInLedger(
        uint256 srcPoolId,
        uint256 dstPoolId,
        uint256 amountLP,
        address to
    ) external;

    /**
     * @dev Withdraws tokens from the source pool to the destination pool, and in exchange, burn LP tokens locally.
     * If it has the suffix 'InLedger', it is a single transaction rather than a cross-chain transaction.
     * @param srcPoolId The ID of the source pool.
     * @param dstPoolId The ID of the destination pool.
     * @param amountLP The amount of LP tokens to burn.
     * @param minAmountLD The minimum amount of tokens to withdraw in LD units.
     * @param to The address to receive the withdrawn tokens.
     */
    function withdrawRemoteInLedger(
        uint256 srcPoolId,
        uint256 dstPoolId,
        uint256 amountLP,
        uint256 minAmountLD,
        address to
    ) external;
}

/**
 * @title IBridgeEnhancedRouter
 * @dev Interface that contains the enhanced functions of the Bridge service.
 */
interface IBridgeEnhancedRouter is IBridgeStandardRouter {
    /**
     * @dev Sends credit to the destination pool from the source pool.
     * Initiates cross-chain transactions. For a detailed flow, refer to IPool.
     * @param srcChannel The channel for identifying the destination chain.
     * @param srcPoolId The ID of the source pool.
     * @param dstPoolId The ID of the destination pool.
     * @param refundTo The address to refund the remaining native asset.
     */
    function sendCredit(
        string calldata srcChannel,
        uint256 srcPoolId,
        uint256 dstPoolId,
        address payable refundTo
    ) external payable;

    /**
     * @dev Sends credit to the destination pool from the source pool.
     * If it has the suffix 'InLedger', it is a single transaction rather than a cross-chain transaction.
     * @param srcPoolId The ID of the source pool.
     * @param dstPoolId The ID of the destination pool.
     */
    function sendCreditInLedger(uint256 srcPoolId, uint256 dstPoolId) external;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * @title IDecimalConvertible
 * @dev Interface for converting decimals between global and local.
 * For more details on globalDecimals and localDecimals, refer to IPool.
 */
interface IDecimalConvertible {
    /**
     * @dev Returns the global decimals, which is the smallest decimal value among connected pools.
     * @return The global decimals.
     */
    function globalDecimals() external returns (uint8);

    /**
     * @dev Returns the local decimals for the token
     * @return The local decimals for the token.
     */
    function localDecimals() external returns (uint8);

    /**
     * @dev Returns the conversion rate for the token
     * @return The conversion rate for the token.
     */
    function convertRate() external returns (uint256);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import "../library/IBCUtils.sol";

/**
 * @title IETHBridge
 * @dev Interface for ETHBridge that supports the cross-chain bridge of native ETH.
 */
interface IETHBridge {
    /**
     * @dev Deposits ETH into the ETH pool. The native ETH is minted as wrapped ETH and deposited into the pool.
     */
    function depositETH() external payable;

    /**
     * @dev Transfers ETH from the source chain to the destination chain.
     * The caller must send native ETH as msg.value along with the function call.
     * @param srcChannel The channel for identifying the destination chain.
     * @param amountLD The amount of native ETH in LD units to transfer.
     * LD stands for Local Decimals. For more details, please refer to IPool.
     * @param minAmountLD The minimum amount of native ETH in LD units to receive.
     * @param to The destination chain address to receive the wrapped ETH.
     * @param refuelAmount The amount of the destination chain's native asset.
     * The equivalent value of native ETH is consumed on the source.
     * @param externalInfo The payload to call the outer service on the destination chain.
     * @param refundTo The address to refund the remaining native ETH.
     */
    function transferETH(
        string calldata srcChannel,
        uint256 amountLD,
        uint256 minAmountLD,
        bytes calldata to,
        uint256 refuelAmount,
        IBCUtils.ExternalInfo calldata externalInfo,
        address payable refundTo
    ) external payable;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * @title IETHVault
 * @dev Interface for ETHVault that supports the deposit and withdrawal of native ETH tokens.
 */
interface IETHVault {
    /**
     * @dev Emitted when the caller deposits ETH into the vault.
     * @param from The address that deposited the ETH.
     * @param amount The amount of ETH deposited.
     */
    event Deposit(address from, uint256 amount);

    /**
     * @dev Emitted when the caller withdraws ETH from the vault.
     * @param to The address that withdrew the ETH.
     * @param amount The amount of ETH withdrawn.
     */
    event Withdraw(address to, uint256 amount);

    /**
     * @dev Emitted when the caller transfers native ETH instead of wrapped ETH.
     * @param from The address that sent the ETH.
     * @param to The address that received the ETH.
     * @param amount The amount of ETH transferred.
     */
    event TransferNative(address from, address to, uint256 amount);

    /**
     * @dev Deposits native ETH into the vault. The caller must send ETH as msg.value along with the function call.
     * The native ETH is minted as wrapped ETH.
     */
    function deposit() external payable;

    /**
     * @dev Withdraws native ETH from the vault.
     * The caller receives native ETH and the equivalent amount of wrapped ETH are burned.
     * @param amount The amount of ETH to withdraw.
     */
    function withdraw(uint256 amount) external;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import "./ITransferPoolFeeCalculator.sol";
import "./IDecimalConvertible.sol";
import "./IStaticFlowRateLimiter.sol";

/**
 * @title IPool
 * @dev Interface for the Pool contract. Represents the liquidity pool, implemented using a mechanism called the Delta Algorithm.
 * The Delta Algorithm allows for efficient cross-chain transactions and liquidity management.
 * When a function that could unbalance pools is called, such as minting liquidity, transferring tokens, and withdrawing liquidity,
 * delta calculation can be triggered. It can also be forcefully triggered using callDelta.
 * Refer to the white paper for more details on the Delta Algorithm: https://www.dropbox.com/s/gf3606jedromp61/Delta-Solving.The.Bridging-Trilemma.pdf?dl=0
 *
 * IPool serves as an liquidity pool contract which mints and burns ERC20 LP tokens when liquidity is added and removed from the pool.
 * A pool ID is assigned to each pool contract, which is shared between chains.
 * Majority of the cross-chain and liquidity related functions will be called by the Bridge.
 *
 *
 * Some functions in the Pool execute cross-chain transactions.
 * In cross-chain transactions, it's important to understand the context in which the function is executed and the perspective from which it is viewed.
 * The following terms are related to cross-chain transactions:
 * - Local pool: The pool where the function is being executed.
 * - Peer pool: The pool that is connected to the local pool.
 * - Initiator: The pool that initiates the cross-chain transaction.
 * - Counterparty: The pool that receives the cross-chain transaction.
 * Local pool and Peer pool represent a first-person view, whereas Initiator and Counterparty represent an objective view.
 *
 * The Pool uses two types of units:
 * - GD (Global Decimals): Lowest common decimals units used across the unified liquidity pool. GD can not be greater than LD.
 * - LD (Local Decimals): Decimal units specific to a particular asset token.
 *
 * The Pool uses two types of tokens:
 * - Liquidity provider token (LP token): This token represents the share of liquidity provided by users and is in GD units.
 * - Asset token: This token represents the actual token associated with the Pool, such as USDC or USDT.
 *   When simply referred to as 'token' it means the asset token.
 *
 */
interface IPool is IDecimalConvertible, IStaticFlowRateLimiter {
    /**
     * @dev Struct for the peer pool.
     * In the Delta Algorithm, there is a pool for each token, and these are referred to as a unified liquidity pool.
     * Within the unified liquidity pool, each pool is connected to multiple peer pools. Each pool refers to other connected pools as peer pools.
     * For example, the USDC on ETH pool may connect to peer pools like the USDT on ETH pool or the USDC on BSC pool, among others.
     * @param chainId The chain ID of the peer pool.
     * @param id The ID of the peer pool that is unique within the chain.
     * @param weight The weight that determines the allocation amount of liquidity.
     * The larger the weight, the more balance is allocated.
     * @param balance The balance available for transfer to the peer pool in GD units.
     * @param targetBalance The target balance, representing the ideal balance in GD units.
     * If the balance is less than the targetBalance, an additional eqFee will be charged.
     * @param lastKnownBalance The last known balance of the peer pool in GD units.
     * Unlike balance, it represents the amount that can be transferred from the peer pool to this pool.
     * @param credits The amount of tokens in GD units that can be transferred to the peer pool next time,
     * reducing the cost of cross-chain transactions.
     * @param ready Indicates if the peer pool is ready for transfer.
     */
    struct PeerPoolInfo {
        uint256 chainId;
        uint256 id;
        uint256 weight;
        uint256 balance;
        uint256 targetBalance;
        uint256 lastKnownBalance;
        uint256 credits;
        bool ready;
    }

    /**
     * @dev Struct for the credit information.
     * @param credits The amount of tokens in GD units that can be transferred to the peer pool next time.
     * @param targetBalance The target balance in GD units.
     */
    struct CreditInfo {
        uint256 credits;
        uint256 targetBalance;
    }

    /**
     * @dev Emitted by transfer.
     * @param peerChainId The chain ID of the peer pool.
     * @param peerPoolId The ID of the peer pool.
     * @param from The address from which the tokens are transferred.
     * @param amountGD The amount of tokens transferred in GD units.
     * @param eqReward The equilibrium reward for the transfer.
     * @param eqFee The equilibrium fee for the transfer.
     * @param protocolFee The protocol fee for the transfer.
     * @param lpFee The liquidity provider fee for the transfer.
     */
    event Transfer(
        uint256 peerChainId,
        uint256 peerPoolId,
        address from,
        uint256 amountGD,
        uint256 eqReward,
        uint256 eqFee,
        uint256 protocolFee,
        uint256 lpFee
    );

    /**
     * @dev Emitted when tokens are received.
     * @param to The address that receives the tokens.
     * @param amountGD The amount of tokens received in GD units.
     * @param protocolFee The protocol fee for the transfer.
     * @param eqFee The equilibrium fee for the transfer.
     */
    event Recv(
        address to,
        uint256 amountGD,
        uint256 protocolFee,
        uint256 eqFee
    );

    /**
     * @dev Emitted by withdrawRemote.
     * @param peerChainId The chain ID of the peer pool.
     * @param peerPoolId The ID of the peer pool.
     * @param from The address from which the tokens are withdrawn.
     * @param amountLP The amount of LP tokens withdrawn in GD units.
     * @param amountLD The amount of asset tokens withdrawn in LD units.
     */
    event WithdrawRemote(
        uint256 peerChainId,
        uint256 peerPoolId,
        address from,
        uint256 amountLP,
        uint256 amountLD
    );

    /**
     * @dev Emitted by withdrawLocal.
     *
     * @param peerChainId The chain ID of the peer pool.
     * @param peerPoolId The ID of the peer pool.
     * @param from The address from which the tokens are withdrawn.
     * @param amountLP The amount of LP tokens withdrawn in GD units.
     * @param amountGD The amount of asset tokens withdrawn in GD units.
     * @param to The address that receives the tokens.
     */
    event WithdrawLocal(
        uint256 peerChainId,
        uint256 peerPoolId,
        address from,
        uint256 amountLP,
        uint256 amountGD,
        bytes to
    );

    /**
     * @dev Emitted by withdrawCheck.
     * @param peerChainId The chain ID of the peer pool.
     * @param peerPoolId The ID of the peer pool.
     * @param amountLP The amount of LP tokens withdrawn in GD units.
     * @param amountGD The amount of asset tokens withdrawn in GD units.
     */
    event WithdrawCheck(
        uint256 peerChainId,
        uint256 peerPoolId,
        uint256 amountLP,
        uint256 amountGD
    );

    /**
     * @dev Emitted by withdrawConfirm.
     * @param peerChainId The chain ID of the peer pool.
     * @param peerPoolId The ID of the peer pool.
     * @param to The address that receives the tokens.
     * @param amountGD The amount of tokens withdrawn in GD units.
     * @param amountMintGD The amount of tokens minted in GD units.
     */
    event WithdrawConfirm(
        uint256 peerChainId,
        uint256 peerPoolId,
        address to,
        uint256 amountGD,
        uint256 amountMintGD
    );

    /**
     * @dev Emitted by sendCredit.
     * @param peerPoolId The ID of the peer pool.
     * @param credits The amount of tokens in GD units that can be transferred to the peer pool next time.
     * @param targetBalance The target balance in GD units.
     */
    event SendCredit(
        uint256 peerPoolId,
        uint256 credits,
        uint256 targetBalance
    );

    /**
     * @dev Emitted by updateCredit.
     * @param peerChainId The chain ID of the peer pool.
     * @param peerPoolId The ID of the peer pool.
     * @param credits The amount of tokens in GD units that can be transferred to the peer pool next time.
     * @param targetBalance The target balance in GD units.
     */
    event UpdateCredit(
        uint256 peerChainId,
        uint256 peerPoolId,
        uint256 credits,
        uint256 targetBalance
    );

    /**
     * @dev Emitted by withdrawInstant.
     * @param from The address from which the tokens are withdrawn.
     * @param amountLP The amount of LP tokens withdrawn in GD units.
     * @param amountGD The amount of asset tokens withdrawn in GD units.
     * @param to The address that receives the tokens.
     */
    event WithdrawInstant(
        address from,
        uint256 amountLP,
        uint256 amountGD,
        address to
    );

    /**
     * @dev Emitted when LP tokens are minted.
     * @param to The address to which the tokens are minted.
     * @param amountLP The amount of LP tokens minted in GD units.
     * @param amountGD The amount of asset tokens minted in GD units.
     */
    event Mint(address to, uint256 amountLP, uint256 amountGD);

    /**
     * @dev Emitted when LP tokens are burned.
     * @param from The address from which the tokens are burned.
     * @param amountLP The amount of LP tokens burned in GD units.
     * @param amountGD The amount of asset tokens burned in GD units.
     */
    event Burn(address from, uint256 amountLP, uint256 amountGD);

    // ============= for admin functions =================

    /**
     * @dev Emitted by setTransferStop.
     * @param stopTransfer The stop transfer status.
     */
    event UpdateStopTransfer(bool stopTransfer);

    /**
     * @dev Emitted when a peer pool is updated.
     * @param peerChainId The chain ID of the peer pool.
     * @param peerPoolId The ID of the peer pool.
     * @param weight The weight that determines the allocation amount of liquidity.
     */
    event PeerPoolInfoUpdate(
        uint256 peerChainId,
        uint256 peerPoolId,
        uint256 weight
    );

    /**
     * @dev Emitted by setDeltaParam.
     * @param batched Indicates if the delta updates are batched. If true, the updates are processed in batch mode.
     * @param swapDeltaBP The basis points for the swap delta.
     * @param lpDeltaBP The basis points for the liquidity provider delta.
     * @param defaultSwapMode The default mode for swaps.
     * @param defaultLPMode The default mode for LP tokens.
     */
    event UpdateDeltaParam(
        bool batched,
        uint256 swapDeltaBP,
        uint256 lpDeltaBP,
        bool defaultSwapMode,
        bool defaultLPMode
    );

    /**
     * @dev Emitted by drawFee.
     * @param to The address to which the fee is transferred.
     * @param amountLD The amount of the fee drawn in LD units.
     */
    event DrawFee(address to, uint256 amountLD);

    /**
     * @dev Emitted when the maximum total deposits are set.
     * @param maxTotalDepositsLD The maximum total deposits allowed in LD units.
     */
    event SetMaxTotalDeposits(uint256 maxTotalDepositsLD);

    /**
     * @dev Mints LP tokens in exchange for depositing assert tokens.
     * Note that asset tokens are transferred by the Bridge contract, not by the Pool contract.
     * @param to The address to which the tokens are minted.
     * @param amountLD The amount of asset tokens to mint in LD units.
     * @return amountGD The amount of asset tokens minted in GD units.
     */
    function mint(
        address to,
        uint256 amountLD
    ) external returns (uint256 amountGD);

    /**
     * @dev Transfers tokens to a peer pool.
     * Note that the Bridge contract performs the transfer token. The Pool only performs delta calculations and updates its internal state.
     *
     * [Flow of a cross-chain transaction]
     * 1. transfer on the initiator <- this function
     * 2. recv on the counterparty
     *
     * @param peerChainId The chain ID of the peer pool.
     * @param peerPoolId The ID of the peer pool.
     * @param from The address from which the  tokens are transferred.
     * @param amountLD The amount of  tokens to transfer in LD units.
     * @param minAmountLD The minimum amount of  tokens to transfer in LD units.
     * Slippage check is done to ensure that the amount after adding the reward and
     * subtracting the fee is greater than or equal to the minimum amount in GD units.
     * @param newLiquidity Indicates if the transfer is new liquidity.
     * @return feeInfo The fee information for the transfer.
     */
    function transfer(
        uint256 peerChainId,
        uint256 peerPoolId,
        address from,
        uint256 amountLD,
        uint256 minAmountLD,
        bool newLiquidity
    ) external returns (ITransferPoolFeeCalculator.FeeInfo memory);

    /**
     * @dev Receives tokens from the peer pool.
     * The delta calculation is performed, and the peer pool info of the local pool is updated.
     *
     * [Flow of a cross-chain transaction]
     * 1. transfer on the initiator
     * 2. recv on the counterparty <- this function
     *
     * 1. withdrawRemote on the initiator
     * 2. recv on the counterparty <- this function
     *
     * @param peerChainId The chain id of the peer pool
     * @param peerPoolId The pool id of the peer pool
     * @param to The address to receive the tokens
     * @param feeInfo The fee information
     * @param updateDelta Whether to update the delta like totalLiquidity
     * @return amountLD The amount of tokens received, including rewards
     * @return isTransferred Whether the tokens are transferred
     */
    function recv(
        uint256 peerChainId,
        uint256 peerPoolId,
        address to,
        ITransferPoolFeeCalculator.FeeInfo memory feeInfo,
        bool updateDelta
    ) external returns (uint256 amountLD, bool isTransferred);

    /**
     * @dev Withdraws asset tokens from the peer pool, and in exchange, burn LP tokens locally.
     *
     * [Flow of a cross-chain transaction]
     * 1. withdrawRemote on the initiator <- this function
     * 2. recv on the counterparty
     *
     * @param peerChainId The chain ID of the peer pool.
     * @param peerPoolId The ID of the peer pool.
     * @param from The address from which the tokens are withdrawn.
     * @param amount The amount of LP tokens.
     */
    function withdrawRemote(
        uint256 peerChainId,
        uint256 peerPoolId,
        address from,
        uint256 amount
    ) external;

    /**
     * @dev Withdraws tokens from a peer pool locally.
     * withdrawLocal burns local LP tokens and uses the balance that the peer pool can send to the local pool to withdraw tokens in the local pool.
     *
     * [Flow of a cross-chain transaction]
     * 1. withdrawLocal on the initiator <- this function
     * 2. withdrawCheck on the counterparty
     * 3. withdrawConfirm on the initiator
     *
     * @param peerChainId The chain ID of the peer pool.
     * @param peerPoolId The ID of the peer pool.
     * @param from The address from which the tokens are withdrawn.
     * @param amount The amount of LP tokens.
     * @param to The address to receive the tokens.
     * @return amountGD The amount of asset tokens withdrawn in GD units.
     */
    function withdrawLocal(
        uint256 peerChainId,
        uint256 peerPoolId,
        address from,
        uint256 amount,
        bytes calldata to
    ) external returns (uint256 amountGD);

    /**
     * @dev This is the second step in withdrawLocal which executed on the peer pool for withdrawLocal.
     * It checks the balance, and if the balance is insufficient, it transfers tokens up to the balance.
     *
     * [Flow of a cross-chain transaction]
     * 1. withdrawLocal on the initiator
     * 2. withdrawCheck on the counterparty <- this function
     * 3. withdrawConfirm on the initiator
     *
     * @param peerChainId The chain ID of the peer pool (the initiator pool).
     * @param peerPoolId The ID of the peer pool (the initiator pool).
     * @param amountGD The amount of tokens to withdraw in GD units.
     */
    function withdrawCheck(
        uint256 peerChainId,
        uint256 peerPoolId,
        uint256 amountGD
    ) external returns (uint256 amountSwap, uint256 amountMint);

    /**
     * @dev This is the final step in withdrawLocal which executed on the local pool for withdrawLocal.
     * If the full amount cannot be withdrawn, mint LP tokens to refund the excess burned tokens.
     *
     * [Flow of a cross-chain transaction]
     * 1. withdrawLocal on the initiator
     * 2. withdrawCheck on the counterparty
     * 3. withdrawConfirm on the initiator <- this function
     *
     * @param peerChainId The chain ID of the peer pool (the counterparty pool).
     * @param peerPoolId The ID of the peer pool (the counterparty pool).
     * @param to The address to receive the tokens
     * @param amountGD The amount of tokens to withdraw, capped by `peerPoolInfo.balance`.
     * @param amountToMintGD The amount of tokens to mint when `peerPoolInfo.balance` is insufficient
     * @param updateDelta Whether to update the delta like `totalLiquidity`
     * @return isTransferred Whether the tokens are transferred
     */
    function withdrawConfirm(
        uint256 peerChainId,
        uint256 peerPoolId,
        address to,
        uint256 amountGD,
        uint256 amountToMintGD,
        bool updateDelta
    ) external returns (bool isTransferred);

    /**
     * @dev Sends credit to a peer pool.
     * Credits aims to reduce the processing costs of cross-chain transactions. It can be transferred to the peer pool next time.
     * Updates the local Peer pool info and generates a IBC packet.
     *
     * [Flow of a cross-chain transaction]
     * 1. sendCredit on the initiator <- this function
     * 2. updateCredit on the counterparty
     *
     * @param peerChainId The chain ID of the peer pool.
     * @param peerPoolId The ID of the peer pool.
     * @return creditInfo The credit information.
     */
    function sendCredit(
        uint256 peerChainId,
        uint256 peerPoolId
    ) external returns (CreditInfo memory);

    /**
     * @dev This is the 2nd step in sendCredit which executed on the peer pool for sendCredit.
     * Updates the peer pool info of the local pool (the counterparty pool) based on the received credit.
     *
     * [Flow of a cross-chain transaction]
     * 1. sendCredit on the initiator
     * 2. updateCredit on the counterparty <- this function
     *
     * @param peerChainId The chain ID of the peer pool (the initiator pool).
     * @param peerPoolId The ID of the peer pool (the initiator pool).
     * @param creditInfo The credit information.
     */
    function updateCredit(
        uint256 peerChainId,
        uint256 peerPoolId,
        CreditInfo memory creditInfo
    ) external;

    /**
     * @dev Withdraws tokens instantly.
     * Instead of using a cross-chain transaction, withdraw instantly from deltaCredit.
     * If deltaCredit is insufficient, withdraw up to deltaCredit.
     * @param from The address from which the tokens are withdrawn.
     * @param amountLP The amount of LP tokens to withdraw in GD units.
     * @param to The address to receive the tokens.
     * @return amountGD The amount of tokens withdrawn in GD units.
     */
    function withdrawInstant(
        address from,
        uint256 amountLP,
        address to
    ) external returns (uint256 amountGD);

    /**
     * @dev Handles failure of recv
     */
    function handleRecvFailure(
        uint256 peerChainId,
        uint256 peerPoolId,
        address to,
        ITransferPoolFeeCalculator.FeeInfo memory feeInfo
    ) external;

    /**
     * @dev Handles failure of withdrawConfirm
     */
    function handleWithdrawConfirmFailure(
        uint256 peerChainId,
        uint256 peerPoolId,
        address to,
        uint256 amountGD,
        uint256 amountToMintGD
    ) external;

    /**
     * @dev Calculates the delta.
     * @param fullMode Indicates if the full mode should be used.
     * If true, even if each pool has an ideal balance, all deltaCredit will be consumed and proportionally distributed to each pool.
     */
    function callDelta(bool fullMode) external;

    /**
     * @dev Sets the transfer stop status.
     * @param transferStop If true, transfer operations are restricted. However, withdrawals are not restricted.
     */
    function setTransferStop(bool transferStop) external;

    /**
     * @dev Registers a peer pool.
     * @param peerChainId The chain ID of the peer pool.
     * @param peerPoolId The ID of the peer pool.
     * @param weight The weight of the peer pool.
     */
    function registerPeerPool(
        uint256 peerChainId,
        uint256 peerPoolId,
        uint256 weight
    ) external;

    /**
     * @dev Activates a peer pool.
     * @param peerChainId The chain ID of the peer pool.
     * @param peerPoolId The ID of the peer pool.
     */
    function activatePeerPool(uint256 peerChainId, uint256 peerPoolId) external;

    /**
     * @dev Sets the weight of a peer pool.
     * When the peer pool is activated, it becomes available for transfer.
     * @param peerChainId The chain ID of the peer pool.
     * @param peerPoolId The ID of the peer pool.
     * @param weight The weight of the peer pool.
     */
    function setPeerPoolWeight(
        uint256 peerChainId,
        uint256 peerPoolId,
        uint256 weight
    ) external;

    /**
     * @dev Sets the delta parameters.
     * @param batched Indicates if the delta updates are batched.
     * @param swapDeltaBP The basis points for the swap delta.
     * @param lpDeltaBP The basis points for the liquidity provider delta.
     * @param defaultSwapMode The default mode for swaps.
     * @param defaultLPMode The default mode for LP tokens.
     */
    function setDeltaParam(
        bool batched,
        uint256 swapDeltaBP,
        uint256 lpDeltaBP,
        bool defaultSwapMode,
        bool defaultLPMode
    ) external;

    /**
     * @dev Draws a fee from the pool.
     * @param to The address to receive the fee.
     */
    function drawFee(address to) external;

    // ============== for helper ===================

    /**
     * @dev Returns the total liquidity.
     * @return The total liquidity in GD units.
     */
    function totalLiquidity() external view returns (uint256);

    /**
     * @dev Returns the asset token address.
     * @return The asset token address.
     */
    function token() external view returns (address);

    /**
     * @dev Returns the equilibrium fee pool.
     * @return The equilibrium fee pool in GD units.
     */
    function eqFeePool() external view returns (uint256);

    /**
     * @dev Returns the peer pool information.
     * @param peerChainId The chain ID of the peer pool.
     * @param peerPoolId The ID of the peer pool.
     * @return The peer pool information.
     */
    function getPeerPoolInfo(
        uint256 peerChainId,
        uint256 peerPoolId
    ) external view returns (PeerPoolInfo memory);

    /**
     * @dev Calculates the fee for a transfer.
     * @param peerChainId The chain ID of the peer pool.
     * @param peerPoolId The ID of the peer pool.
     * @param from The address from which the tokens are transferred.
     * @param amountLD The amount of tokens to transfer in LD units.
     * @return feeInfo The fee information.
     */
    function calcFee(
        uint256 peerChainId,
        uint256 peerPoolId,
        address from,
        uint256 amountLD
    ) external view returns (ITransferPoolFeeCalculator.FeeInfo memory);

    /**
     * @dev Converts LP tokens in GD units to asset tokens in LD units.
     * @param amountLP The amount of LP tokens in GD units.
     * @return The amount of asset tokens in LD units.
     */
    // solhint-disable-next-line func-name-mixedcase
    function LPToLD(uint256 amountLP) external view returns (uint256);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * @dev StaticFlowRateLimiter limits the flow within a certain period.
 * For example, it can be used to limit the amount of ERC20 token transfers.
 */
interface IStaticFlowRateLimiter {
    /**
     * @dev Resets the flow rate limit with a privilege.
     */
    function resetFlowRateLimit() external;

    /**
     * @dev Returns the end of the current period.
     * @return The block number when the current period ends.
     */
    function currentPeriodEnd() external view returns (uint256);

    /**
     * @dev Returns the amount accumulated in the current period.
     * @return The amount accumulated in the current period.
     */
    function currentPeriodAmount() external view returns (uint256);

    /**
     * @dev Returns whether the lock period is applied.
     * @return `true` if the lock period is applied, `false` otherwise.
     */
    function appliedLockPeriod() external view returns (bool);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

interface ITokiErrors {
    error TokiZeroAddress(string message);
    error TokiZeroAmount(string message);
    error TokiZeroValue(string message);

    // user error
    error TokiInsufficientAmount(string name, uint256 value, uint256 needed);
    // pool does not have enough liquidity
    error TokiInsufficientPoolLiquidity(uint256 value, uint256 needed);
    error TokiExceed(string name, uint256 value, uint256 limit);
    error TokiExceedAdd(
        string name,
        uint256 current,
        uint256 add,
        uint256 limit
    );

    // only used in PseudoToken, which is just for Testnet
    error TokiContractNotAllowed(string name, address addr);

    error TokiCannotCloseChannel();
    error TokiCannotTimeoutPacket();

    error TokiRequireOrderedChannel();
    error TokiDstOuterGasShouldBeZero();

    error TokiInvalidPacketType(uint8);
    error TokiInvalidRetryType(uint8);
    error TokiInvalidRecipientBytes();
    error TokiNoRevertReceive();
    error TokiRetryExpired(uint256 expiryBlock);
    error TokiInvalidAppVersion(uint256 expected, uint256 actual);
    error TokiNotEnoughNativeFee(uint256 value, uint256 limit);
    error TokiFailToRefund();

    error TokiNoFee();
    error TokiInvalidBalanceDeficitFeeZone();
    error TokiInvalidSafeZoneRange(uint256 min, uint256 max);
    error TokiDepeg(uint256 poolId);
    error TokiUnregisteredChainId(string channel);
    error TokiUnregisteredPoolId(uint256 poolId);

    error TokiSamePool(uint256 poolId, address pool);
    error TokiNoPool(uint256 poolId);
    error TokiPoolRecvIsFailed(uint256 poolId);
    error TokiPoolWithdrawConfirmIsFailed(uint256 poolId);
    error TokiPriceIsNotPositive(int256 value);
    error TokiPriceIsExpired(uint256 updatedAt);

    error TokiDstChainIdNotAccepted(uint256 dstChainId);

    error TokiTransferIsStop();
    error TokiTransferIsFailed(address token, address to, uint256 value);
    error TokiNativeTransferIsFailed(address to, uint256 value);
    error TokiPeerPoolIsNotReady(uint256 peerChainId, uint256 peerPoolId);
    error TokiSlippageTooHigh(
        uint256 amountGD,
        uint256 eqReward,
        uint256 eqFee,
        uint256 minAmountGD
    );
    error TokiPeerPoolIsRegistered(uint256 chainId, uint256 poolId);
    error TokiPeerPoolIsAlreadyActive(uint256 chainId, uint256 poolId);
    error TokiNoPeerPoolInfo();
    error TokiPeerPoolInfoNotFound(uint256 chainId, uint256 poolId);

    error TokiFlowRateLimitExceed(uint256 current, uint256 add, uint256 limit);

    error TokiFallbackUnauthorized(address caller);

    // used in mocks
    error TokiMock(string message);

    // channel upgrade
    error TokiInvalidProposedVersion(string version);
    error TokiChannelNotFound(string portId, string channelId);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import "../interfaces/IPool.sol";

/**
 * @title ITransferPoolFeeCalculator
 * @dev Interface for calculating fees for transferring between pools.
 */
interface ITransferPoolFeeCalculator {
    /**
     * @dev Struct for the source pool.
     * @param addr The address of the source pool.
     * @param id The ID of the source pool.
     * @param globalDecimals The global decimals used by the source pool.
     * @param balance The current balance of the source pool in GD (global decimals) units.
     * @param totalLiquidity The total liquidity of the source pool in GD units.
     * @param eqFeePool The equilibrium fee pool of the source pool in GD units.
     */
    struct SrcPoolInfo {
        address addr;
        uint256 id;
        uint8 globalDecimals;
        uint256 balance;
        uint256 totalLiquidity;
        uint256 eqFeePool;
    }

    /**
     * @dev Struct for the calculated fees.
     * @param amountGD The transferring token amount converted to global decimals, from which eqFee and protocolFee are subtracted.
     * @param protocolFee The protocol fee.
     * @param lpFee The liquidity provider fee.
     * @param eqFee The equilibrium fee.
     * @param eqReward The equilibrium reward.
     * @param balanceDecrease Balance reduction in source pool that will update destination pool's last known balance
     */
    struct FeeInfo {
        uint256 amountGD;
        uint256 protocolFee;
        uint256 lpFee;
        uint256 eqFee;
        uint256 eqReward;
        uint256 balanceDecrease;
    }

    /**
     * @dev Calculates the fees for transferring between pools.
     * @param srcPoolInfo The struct of source pool.
     * @param dstPoolInfo The struct of destination pool.
     * @param from The address that transfers the token.
     * @param amountGD The amount of the token in GD units.
     * GD stands for Global Decimals. For more details, please refer to IPool.
     * @return FeeInfo The calculated fees.
     */
    function calcFee(
        SrcPoolInfo calldata srcPoolInfo,
        IPool.PeerPoolInfo calldata dstPoolInfo,
        address from,
        uint256 amountGD
    ) external view returns (FeeInfo memory);

    /**
     * @dev Returns the version of the fee calculator.
     * @return The version string.
     */
    function version() external pure returns (string memory);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import "../interfaces/ITokiErrors.sol";
import "../interfaces/ITransferPoolFeeCalculator.sol";
import "../interfaces/IPool.sol";
import "./MessageType.sol";

library IBCUtils {
    struct ExternalInfo {
        bytes payload;
        uint256 dstOuterGas; // in gas
    }

    struct SendCreditPayload {
        uint8 ftype;
        uint256 srcPoolId;
        uint256 dstPoolId;
        IPool.CreditInfo creditInfo;
    }

    struct TransferPoolPayload {
        uint8 ftype;
        uint256 srcPoolId;
        uint256 dstPoolId;
        ITransferPoolFeeCalculator.FeeInfo feeInfo;
        IPool.CreditInfo creditInfo;
        bytes to;
        uint256 refuelAmount;
        ExternalInfo externalInfo;
    }

    struct TransferTokenPayload {
        uint8 ftype;
        string denom;
        uint256 amount;
        bytes to;
        uint256 refuelAmount;
        ExternalInfo externalInfo;
    }

    struct WithdrawCheckPayload {
        uint8 ftype;
        uint256 withdrawLocalPoolId;
        uint256 withdrawCheckPoolId;
        uint256 transferAmountGD;
        uint256 mintAmountGD;
        IPool.CreditInfo creditInfo;
        bytes to;
    }

    struct WithdrawPayload {
        uint8 ftype;
        uint256 withdrawLocalPoolId;
        uint256 withdrawCheckPoolId;
        uint256 amountGD;
        IPool.CreditInfo creditInfo;
        bytes to;
    }

    struct RetryReceivePoolPayload {
        uint8 ftype;
        uint256 appVersion;
        uint256 lastValidHeight;
        uint256 srcPoolId;
        uint256 dstPoolId;
        address to;
        ITransferPoolFeeCalculator.FeeInfo feeInfo;
        uint256 refuelAmount;
        ExternalInfo externalInfo;
    }

    struct RetryReceiveTokenPayload {
        uint8 ftype;
        uint256 appVersion;
        uint256 lastValidHeight;
        string denom;
        uint256 amount;
        address to;
        uint256 refuelAmount;
        ExternalInfo externalInfo;
    }

    struct RetryExternalCallPayload {
        uint8 ftype;
        uint256 appVersion;
        uint256 lastValidHeight;
        address token;
        uint256 amount;
        address to;
        ExternalInfo externalInfo;
    }

    struct RetryRefuelCallPayload {
        uint8 ftype;
        uint256 appVersion;
        uint256 lastValidHeight;
        address to;
        uint256 refuelAmount;
    }

    struct RetryRefuelAndExternalCallPayload {
        uint8 ftype;
        uint256 appVersion;
        uint256 lastValidHeight;
        address token;
        uint256 amount;
        address to;
        uint256 refuelAmount;
        ExternalInfo externalInfo;
    }

    struct RetryWithdrawConfirmPayload {
        uint8 ftype;
        uint256 appVersion;
        uint256 lastValidHeight;
        uint256 withdrawLocalPoolId;
        uint256 withdrawCheckPoolId;
        address to;
        uint256 transferAmountGD;
        uint256 mintAmountGD;
    }

    uint8 internal constant _TYPE_RETRY_RECEIVE_POOL = 1;
    uint8 internal constant _TYPE_RETRY_WITHDRAW_CONFIRM = 2;
    uint8 internal constant _TYPE_RETRY_RECEIVE_TOKEN = 5;
    uint8 internal constant _TYPE_RETRY_EXTERNAL_CALL = 10;
    uint8 internal constant _TYPE_RETRY_REFUEL_CALL = 11;
    uint8 internal constant _TYPE_RETRY_REFUEL_AND_EXTERNAL_CALL = 12;

    error SafeTransferFromFailed(bool success, bytes data);

    /**
     * internal helper function(with external call)
     */
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        if (!success || (data.length > 0 && !abi.decode(data, (bool)))) {
            revert SafeTransferFromFailed(success, data);
        }
    }

    function parseType(
        bytes memory payload
    ) internal pure returns (uint8 ftype) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            ftype := mload(add(payload, 32))
        }
    }

    function encodeTransferPool(
        uint256 srcPoolId,
        uint256 dstPoolId,
        ITransferPoolFeeCalculator.FeeInfo memory feeInfo,
        IPool.CreditInfo memory creditInfo,
        bytes memory to,
        uint256 refuelAmount,
        ExternalInfo memory externalInfo
    ) internal pure returns (bytes memory) {
        return
            abi.encode(
                MessageType._TYPE_TRANSFER_POOL,
                srcPoolId,
                dstPoolId,
                feeInfo,
                creditInfo,
                to,
                refuelAmount,
                externalInfo
            );
    }

    function decodeTransferPool(
        bytes memory payload
    ) internal pure returns (TransferPoolPayload memory) {
        (
            uint8 ftype,
            uint256 srcPoolId,
            uint256 dstPoolId,
            ITransferPoolFeeCalculator.FeeInfo memory feeInfo,
            IPool.CreditInfo memory creditInfo,
            bytes memory to,
            uint256 refuelAmount,
            ExternalInfo memory externalInfo
        ) = abi.decode(
                payload,
                (
                    uint8,
                    uint256,
                    uint256,
                    ITransferPoolFeeCalculator.FeeInfo,
                    IPool.CreditInfo,
                    bytes,
                    uint256,
                    ExternalInfo
                )
            );
        TransferPoolPayload memory p = TransferPoolPayload(
            ftype,
            srcPoolId,
            dstPoolId,
            feeInfo,
            creditInfo,
            to,
            refuelAmount,
            externalInfo
        );
        return p;
    }

    function encodeCredit(
        uint256 srcPoolId,
        uint256 dstPoolId,
        IPool.CreditInfo memory creditInfo
    ) internal pure returns (bytes memory) {
        return
            abi.encode(
                MessageType._TYPE_CREDIT,
                srcPoolId,
                dstPoolId,
                creditInfo
            );
    }

    function decodeCredit(
        bytes memory payload
    ) internal pure returns (SendCreditPayload memory) {
        (
            uint8 ftype,
            uint256 srcPoolId,
            uint256 dstPoolId,
            IPool.CreditInfo memory creditInfo
        ) = abi.decode(payload, (uint8, uint256, uint256, IPool.CreditInfo));
        SendCreditPayload memory p = SendCreditPayload(
            ftype,
            srcPoolId,
            dstPoolId,
            creditInfo
        );
        return p;
    }

    function encodeWithdraw(
        uint256 withdrawLocalPoolId,
        uint256 withdrawCheckPoolId,
        uint256 amountGD,
        IPool.CreditInfo memory creditInfo,
        bytes memory to
    ) internal pure returns (bytes memory) {
        return
            abi.encode(
                MessageType._TYPE_WITHDRAW,
                withdrawLocalPoolId,
                withdrawCheckPoolId,
                amountGD,
                creditInfo,
                to
            );
    }

    function decodeWithdraw(
        bytes memory payload
    ) internal pure returns (WithdrawPayload memory) {
        (
            uint8 ftype,
            uint256 withdrawLocalPoolId,
            uint256 withdrawCheckPoolId,
            uint256 amountGD,
            IPool.CreditInfo memory creditInfo,
            bytes memory to
        ) = abi.decode(
                payload,
                (uint8, uint256, uint256, uint256, IPool.CreditInfo, bytes)
            );
        WithdrawPayload memory p = WithdrawPayload(
            ftype,
            withdrawLocalPoolId,
            withdrawCheckPoolId,
            amountGD,
            creditInfo,
            to
        );
        return p;
    }

    function encodeWithdrawCheck(
        uint256 withdrawLocalPoolId,
        uint256 withdrawCheckPoolId,
        uint256 transferAmount,
        uint256 mintAmount,
        IPool.CreditInfo memory creditInfo,
        bytes memory to
    ) internal pure returns (bytes memory) {
        return
            abi.encode(
                MessageType._TYPE_WITHDRAW_CHECK,
                withdrawLocalPoolId,
                withdrawCheckPoolId,
                transferAmount,
                mintAmount,
                creditInfo,
                to
            );
    }

    function decodeWithdrawCheck(
        bytes memory payload
    ) internal pure returns (WithdrawCheckPayload memory) {
        (
            uint8 ftype,
            uint256 withdrawLocalPoolId,
            uint256 withdrawCheckPoolId,
            uint256 transferAmount,
            uint256 mintAmount,
            IPool.CreditInfo memory creditInfo,
            bytes memory to
        ) = abi.decode(
                payload,
                (
                    uint8,
                    uint256,
                    uint256,
                    uint256,
                    uint256,
                    IPool.CreditInfo,
                    bytes
                )
            );
        WithdrawCheckPayload memory p = WithdrawCheckPayload(
            ftype,
            withdrawLocalPoolId,
            withdrawCheckPoolId,
            transferAmount,
            mintAmount,
            creditInfo,
            to
        );
        return p;
    }

    function encodeTransferToken(
        string memory denom,
        uint256 amount,
        bytes memory to,
        uint256 refuelAmount,
        ExternalInfo memory externalInfo
    ) internal pure returns (bytes memory) {
        return
            abi.encode(
                MessageType._TYPE_TRANSFER_TOKEN,
                denom,
                amount,
                to,
                refuelAmount,
                externalInfo
            );
    }

    function decodeTransferToken(
        bytes memory payload
    ) internal pure returns (TransferTokenPayload memory) {
        (
            uint8 ftype,
            string memory denom,
            uint256 amount,
            bytes memory to,
            uint256 refuelAmount,
            ExternalInfo memory externalInfo
        ) = abi.decode(
                payload,
                (uint8, string, uint256, bytes, uint256, ExternalInfo)
            );
        TransferTokenPayload memory p = TransferTokenPayload(
            ftype,
            denom,
            amount,
            to,
            refuelAmount,
            externalInfo
        );
        return p;
    }

    function encodeRetryReceivePool(
        uint256 appVersion,
        uint256 lastValidHeight,
        uint256 srcPoolId,
        uint256 dstPoolId,
        address to,
        ITransferPoolFeeCalculator.FeeInfo memory feeInfo,
        uint256 refuelAmount,
        IBCUtils.ExternalInfo memory externalInfo
    ) internal pure returns (bytes memory) {
        return
            abi.encode(
                _TYPE_RETRY_RECEIVE_POOL,
                appVersion,
                lastValidHeight,
                srcPoolId,
                dstPoolId,
                to,
                feeInfo,
                refuelAmount,
                externalInfo
            );
    }

    function decodeRetryReceivePool(
        bytes memory payload
    ) internal pure returns (RetryReceivePoolPayload memory) {
        (
            uint8 ftype,
            uint256 appVersion,
            uint256 lastValidHeight,
            uint256 srcPoolId,
            uint256 dstPoolId,
            address to,
            ITransferPoolFeeCalculator.FeeInfo memory feeInfo,
            uint256 refuelAmount,
            IBCUtils.ExternalInfo memory externalInfo
        ) = abi.decode(
                payload,
                (
                    uint8,
                    uint256, // appVersion
                    uint256, // lastValidHeight
                    uint256, // srcPoolId
                    uint256, // dstPoolId
                    address, // to
                    ITransferPoolFeeCalculator.FeeInfo, // feeInfo
                    uint256, // refuelAmount
                    IBCUtils.ExternalInfo // externalInfo
                )
            );
        RetryReceivePoolPayload memory p = RetryReceivePoolPayload(
            ftype,
            appVersion,
            lastValidHeight,
            srcPoolId,
            dstPoolId,
            to,
            feeInfo,
            refuelAmount,
            externalInfo
        );
        return p;
    }

    function encodeRetryReceiveToken(
        uint256 appVersion,
        uint256 lastValidHeight,
        string memory denom,
        uint256 amount,
        address to,
        uint256 refuelAmount,
        IBCUtils.ExternalInfo memory externalInfo
    ) internal pure returns (bytes memory) {
        return
            abi.encode(
                _TYPE_RETRY_RECEIVE_TOKEN,
                appVersion,
                lastValidHeight,
                denom,
                amount,
                to,
                refuelAmount,
                externalInfo
            );
    }

    function decodeRetryReceiveToken(
        bytes memory payload
    ) internal pure returns (RetryReceiveTokenPayload memory) {
        (
            uint8 ftype,
            uint256 appVersion,
            uint256 lastValidHeight,
            string memory denom,
            uint256 amount,
            address to,
            uint256 refuelAmount,
            IBCUtils.ExternalInfo memory externalInfo
        ) = abi.decode(
                payload,
                (
                    uint8,
                    uint256,
                    uint256,
                    string,
                    uint256,
                    address,
                    uint256,
                    IBCUtils.ExternalInfo
                )
            );
        RetryReceiveTokenPayload memory p = RetryReceiveTokenPayload(
            ftype,
            appVersion,
            lastValidHeight,
            denom,
            amount,
            to,
            refuelAmount,
            externalInfo
        );
        return p;
    }

    function encodeRetryWithdrawConfirm(
        uint256 appVersion,
        uint256 lastValidHeight,
        uint256 srcPoolId,
        uint256 dstPoolId,
        address to,
        uint256 transferAmount,
        uint256 mintAmount
    ) internal pure returns (bytes memory) {
        return
            abi.encode(
                _TYPE_RETRY_WITHDRAW_CONFIRM,
                appVersion,
                lastValidHeight,
                srcPoolId,
                dstPoolId,
                to,
                transferAmount,
                mintAmount
            );
    }

    function decodeRetryWithdrawConfirm(
        bytes memory payload
    ) internal pure returns (RetryWithdrawConfirmPayload memory) {
        (
            uint8 ftype,
            uint256 appVersion,
            uint256 lastValidHeight,
            uint256 srcPoolId,
            uint256 dstPoolId,
            address to,
            uint256 transferAmount,
            uint256 mintAmount
        ) = abi.decode(
                payload,
                (
                    uint8,
                    uint256,
                    uint256,
                    uint256,
                    uint256,
                    address,
                    uint256,
                    uint256
                )
            );
        RetryWithdrawConfirmPayload memory p = RetryWithdrawConfirmPayload(
            ftype,
            appVersion,
            lastValidHeight,
            srcPoolId,
            dstPoolId,
            to,
            transferAmount,
            mintAmount
        );
        return p;
    }

    function encodeRetryExternalCall(
        uint256 appVersion,
        uint256 lastValidHeight,
        address token,
        uint256 amount,
        address to,
        IBCUtils.ExternalInfo memory externalInfo
    ) internal pure returns (bytes memory) {
        return
            abi.encode(
                _TYPE_RETRY_EXTERNAL_CALL,
                appVersion,
                lastValidHeight,
                token,
                amount,
                to,
                externalInfo
            );
    }

    function decodeRetryExternalCall(
        bytes memory payload
    ) internal pure returns (RetryExternalCallPayload memory) {
        (
            uint8 ftype,
            uint256 appVersion,
            uint256 lastValidHeight,
            address token,
            uint256 amount,
            address to,
            IBCUtils.ExternalInfo memory externalInfo
        ) = abi.decode(
                payload,
                (
                    uint8,
                    uint256,
                    uint256,
                    address,
                    uint256,
                    address,
                    IBCUtils.ExternalInfo
                )
            );
        RetryExternalCallPayload memory p = RetryExternalCallPayload(
            ftype,
            appVersion,
            lastValidHeight,
            token,
            amount,
            to,
            externalInfo
        );
        return p;
    }

    function encodeRetryRefuelCall(
        uint256 appVersion,
        uint256 lastValidHeight,
        address to,
        uint256 refuelAmount
    ) internal pure returns (bytes memory) {
        return
            abi.encode(
                _TYPE_RETRY_REFUEL_CALL,
                appVersion,
                lastValidHeight,
                to,
                refuelAmount
            );
    }

    function decodeRetryRefuelCall(
        bytes memory payload
    ) internal pure returns (RetryRefuelCallPayload memory) {
        (
            uint8 ftype,
            uint256 appVersion,
            uint256 lastValidHeight,
            address to,
            uint256 refuelAmount
        ) = abi.decode(payload, (uint8, uint256, uint256, address, uint256));
        RetryRefuelCallPayload memory p = RetryRefuelCallPayload(
            ftype,
            appVersion,
            lastValidHeight,
            to,
            refuelAmount
        );
        return p;
    }

    function encodeRetryRefuelAndExternalCall(
        uint256 appVersion,
        uint256 lastValidHeight,
        address token,
        uint256 amount,
        address to,
        uint256 refuelAmount,
        IBCUtils.ExternalInfo memory externalInfo
    ) internal pure returns (bytes memory) {
        return
            abi.encode(
                _TYPE_RETRY_REFUEL_AND_EXTERNAL_CALL,
                appVersion,
                lastValidHeight,
                token,
                amount,
                to,
                refuelAmount,
                externalInfo
            );
    }

    function decodeRetryRefuelAndExternalCall(
        bytes memory payload
    ) internal pure returns (RetryRefuelAndExternalCallPayload memory) {
        (
            uint8 ftype,
            uint256 appVersion,
            uint256 lastValidHeight,
            address token,
            uint256 amount,
            address to,
            uint256 refuelAmount,
            IBCUtils.ExternalInfo memory externalInfo
        ) = abi.decode(
                payload,
                (
                    uint8,
                    uint256,
                    uint256,
                    address,
                    uint256,
                    address,
                    uint256,
                    IBCUtils.ExternalInfo
                )
            );
        RetryRefuelAndExternalCallPayload
            memory p = RetryRefuelAndExternalCallPayload(
                ftype,
                appVersion,
                lastValidHeight,
                token,
                amount,
                to,
                refuelAmount,
                externalInfo
            );
        return p;
    }

    function decodeAddress(
        bytes memory data
    ) internal pure returns (address addr, bool success) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            success := eq(mload(data), 20)
            addr := mload(add(data, 20))
        }
    }

    function encodeAddress(address addr) internal pure returns (bytes memory) {
        return abi.encodePacked(addr);
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import "../interfaces/ITransferPoolFeeCalculator.sol";
import "../interfaces/IPool.sol";

library MessageType {
    // use onReceive or RelayerFee
    uint8 internal constant _TYPE_TRANSFER_POOL = 1;
    uint8 internal constant _TYPE_CREDIT = 2;
    uint8 internal constant _TYPE_WITHDRAW = 3;
    uint8 internal constant _TYPE_WITHDRAW_CHECK = 4;
    uint8 internal constant _TYPE_TRANSFER_TOKEN = 5;
}