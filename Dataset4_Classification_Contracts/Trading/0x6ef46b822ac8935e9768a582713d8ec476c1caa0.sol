// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "whitelist/interfaces/IWhitelist.sol";
import "./libs/AttoDecimal.sol";
import "solowei/TwoStageOwnable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import "openzeppelin-contracts/contracts/utils/math/Math.sol";

contract FixedSwap is ReentrancyGuard, TwoStageOwnable {
    using SafeERC20 for IERC20;
    using AttoDecimal for AttoDecimal.Instance;

    IWhitelist public whitelist;

    enum Type {
        SIMPLE,
        INTERVAL,
        LINEAR
    }

    struct Props {
        uint256 issuanceLimit;
        uint256 startsAt;
        uint256 endsAt;
        IERC20 paymentToken;
        IERC20 issuanceToken;
        AttoDecimal.Instance fee;
        AttoDecimal.Instance rate;
    }

    struct AccountState {
        uint256 paymentSum;
    }

    struct ComplexAccountState {
        uint256 issuanceAmount;
        uint256 withdrawnIssuanceAmount;
    }

    struct Account {
        AccountState state;
        ComplexAccountState complex;
        uint256 immediatelyUnlockedAmount; // linear
        uint256 unlockedIntervalsCount; // interval
    }

    struct State {
        uint256 available;
        uint256 issuance;
        uint256 lockedPayments;
        uint256 unlockedPayments;
        uint256 paymentLimit;
        address nominatedOwner;
        address owner;
    }

    struct Interval {
        uint256 startsAt;
        AttoDecimal.Instance unlockingPart;
    }

    struct LinearProps {
        uint256 endsAt;
        uint256 duration;
    }

    struct Pool {
        Type type_;
        uint256 index;
        AttoDecimal.Instance immediatelyUnlockingPart;
        Props props;
        LinearProps linear;
        State state;
        Interval[] intervals;
        mapping(address => Account) accounts;
    }

    Pool[] private _pools;
    mapping(IERC20 => uint256) private _collectedFees;

    function getTimestamp() internal view virtual returns (uint256) {
        return block.timestamp;
    }

    function poolsCount() public view returns (uint256) {
        return _pools.length;
    }

    function poolProps(uint256 poolIndex) public view returns (Type type_, Props memory props) {
        Pool storage pool = _getPool(poolIndex);
        return (pool.type_, pool.props);
    }

    function intervalPoolProps(uint256 poolIndex)
        public
        view
        returns (Props memory props, AttoDecimal.Instance memory immediatelyUnlockingPart, Interval[] memory intervals)
    {
        Pool storage pool = _getPool(poolIndex);
        _assertPoolIsInterval(pool);
        return (pool.props, pool.immediatelyUnlockingPart, pool.intervals);
    }

    function linearPoolProps(uint256 poolIndex)
        public
        view
        returns (Props memory props, AttoDecimal.Instance memory immediatelyUnlockingPart, LinearProps memory linear)
    {
        Pool storage pool = _getPool(poolIndex);
        _assertPoolIsLinear(pool);
        return (pool.props, pool.immediatelyUnlockingPart, pool.linear);
    }

    function poolState(uint256 poolIndex) public view returns (State memory state) {
        return _getPool(poolIndex).state;
    }

    function poolAccount(
        uint256 poolIndex,
        address address_
    )
        public
        view
        returns (Type type_, AccountState memory state)
    {
        Pool storage pool = _getPool(poolIndex);
        return (pool.type_, pool.accounts[address_].state);
    }

    function intervalPoolAccount(
        uint256 poolIndex,
        address address_
    )
        public
        view
        returns (AccountState memory state, ComplexAccountState memory complex, uint256 unlockedIntervalsCount)
    {
        Pool storage pool = _getPool(poolIndex);
        _assertPoolIsInterval(pool);
        Account storage account = pool.accounts[address_];
        return (account.state, account.complex, account.unlockedIntervalsCount);
    }

    function linearPoolAccount(
        uint256 poolIndex,
        address address_
    )
        public
        view
        returns (AccountState memory state, ComplexAccountState memory complex, uint256 immediatelyUnlockedAmount)
    {
        Pool storage pool = _getPool(poolIndex);
        _assertPoolIsLinear(pool);
        Account storage account = pool.accounts[address_];
        return (account.state, account.complex, account.immediatelyUnlockedAmount);
    }

    function collectedFees(IERC20 token) public view returns (uint256) {
        return _collectedFees[token];
    }

    event AccountLimitChanged(uint256 indexed poolIndex, address indexed address_, uint256 indexed limitIndex);
    event FeeWithdrawn(address indexed token, uint256 amount);
    event ImmediatelyUnlockingPartUpdated(uint256 indexed poolIndex, uint256 mantissa);
    event IntervalCreated(uint256 indexed poolIndex, uint256 startsAt, uint256 unlockingPart);
    event IssuanceIncreased(uint256 indexed poolIndex, uint256 amount);
    event LinearUnlockingEndingTimestampUpdated(uint256 indexed poolIndex, uint256 timestamp);
    event LinearPoolUnlocking(uint256 indexed poolIndex, address indexed account, uint256 amount);
    event PaymentLimitCreated(uint256 indexed poolIndex, uint256 indexed limitIndex, uint256 limit);
    event PaymentLimitChanged(uint256 indexed poolIndex, uint256 indexed limitIndex, uint256 newLimit);
    event PaymentUnlocked(uint256 indexed poolIndex, uint256 unlockedAmount, uint256 collectedFee);
    event PaymentsWithdrawn(uint256 indexed poolIndex, uint256 amount);
    event PoolOwnerChanged(uint256 indexed poolIndex, address indexed newOwner);
    event PoolOwnerNominated(uint256 indexed poolIndex, address indexed nominatedOwner);
    event UnsoldWithdrawn(uint256 indexed poolIndex, uint256 amount);
    event WhitelistContractChanged(address oldAddress, address newAddress);

    event PoolCreated(
        Type type_,
        IERC20 indexed paymentToken,
        IERC20 indexed issuanceToken,
        uint256 poolIndex,
        uint256 issuanceLimit,
        uint256 startsAt,
        uint256 endsAt,
        uint256 fee,
        uint256 rate,
        uint256 paymentLimit
    );

    event Swap(
        uint256 indexed poolIndex,
        address indexed caller,
        uint256 requestedPaymentAmount,
        uint256 paymentAmount,
        uint256 issuanceAmount
    );

    constructor(address owner_, address whitelistContract_) public TwoStageOwnable(owner_) {
        whitelist = IWhitelist(whitelistContract_);
    }

    function createSimplePool(
        Props memory props,
        uint256 paymentLimit,
        address owner_
    )
        external
        onlyOwner
        returns (bool success, uint256 poolIndex)
    {
        return (true, _createSimplePool(props, paymentLimit, owner_, Type.SIMPLE).index);
    }

    /**
     * @dev Creates an interval pool with the provided properties, payment limit, owner, and immediately unlocking part.
     * This function can only be called by the contract owner.
     *
     * @param props The properties of the pool to be created. It is a struct of type Props which includes:
     * - issuanceLimit: The maximum amount of tokens that can be issued.
     * - startsAt: The timestamp when the pool starts.
     * - endsAt: The timestamp when the pool ends.
     * - paymentToken: The ERC20 token to be used for payments.
     * - issuanceToken: The ERC20 token to be issued.
     * - fee: The fee for the pool.
     * - rate: The rate of the pool.
     * @param paymentLimit The maximum amount of payment that can be made in the pool.
     * @param owner_ The owner of the pool.
     * @param immediatelyUnlockingPart The part of the issuance tokens that can be unlocked immediately.
     * @param intervals The intervals of the pool. Each interval is a struct of type Interval which includes:
     * - startsAt: The timestamp when the interval starts.
     * - unlockingPart: The part of the issuance tokens that can be unlocked in the interval.
     *
     * @return success True if the pool was created successfully, otherwise False.
     * @return poolIndex The index of the pool in the _pools array.
     */
    function createIntervalPool(
        Props memory props,
        uint256 paymentLimit,
        address owner_,
        AttoDecimal.Instance memory immediatelyUnlockingPart,
        Interval[] memory intervals
    )
        external
        onlyOwner
        returns (bool success, uint256 poolIndex)
    {
        Pool storage pool = _createSimplePool(props, paymentLimit, owner_, Type.INTERVAL);
        _setImmediatelyUnlockingPart(pool, immediatelyUnlockingPart);
        uint256 intervalsCount = intervals.length;
        AttoDecimal.Instance memory lastUnlockingPart = immediatelyUnlockingPart;
        uint256 lastIntervalStartingTimestamp = props.endsAt - 1;
        for (uint256 i = 0; i < intervalsCount; i++) {
            Interval memory interval = intervals[i];
            require(interval.unlockingPart.gt(lastUnlockingPart), "Invalid interval unlocking part");
            lastUnlockingPart = interval.unlockingPart;
            uint256 startingTimestamp = interval.startsAt;
            require(startingTimestamp > lastIntervalStartingTimestamp, "Invalid interval starting timestamp");
            lastIntervalStartingTimestamp = startingTimestamp;
            pool.intervals.push(interval);
            emit IntervalCreated(poolIndex, interval.startsAt, interval.unlockingPart.mantissa);
        }
        require(
            lastUnlockingPart.eq(1, ERC20(address(props.paymentToken)).decimals()), "Unlocking part not equal to one"
        );
        return (true, pool.index);
    }

    /**
     * @dev Creates a linear pool with the provided properties, payment limit, owner, immediately unlocking part,
     * and linear unlocking end timestamp. This function can only be called by the contract owner.
     *
     * @param props The properties of the pool to be created. It is a struct of type Props which includes:
     * - issuanceLimit: The maximum amount of tokens that can be issued.
     * - startsAt: The timestamp when the pool starts.
     * - endsAt: The timestamp when the pool ends.
     * - paymentToken: The ERC20 token to be used for payments.
     * - issuanceToken: The ERC20 token to be issued.
     * - fee: The fee for the pool.
     * - rate: The rate of the pool.
     * @param paymentLimit The maximum amount of payment that can be made in the pool.
     * @param owner_ The owner of the pool.
     * @param immediatelyUnlockingPart The part of the issuance tokens that can be unlocked immediately.
     * @param linearUnlockingEndsAt The timestamp when the linear unlocking ends.
     *
     * @return success True if the pool was created successfully, otherwise False.
     * @return poolIndex The index of the pool in the _pools array.
     */
    function createLinearPool(
        Props memory props,
        uint256 paymentLimit,
        address owner_,
        AttoDecimal.Instance memory immediatelyUnlockingPart,
        uint256 linearUnlockingEndsAt
    )
        external
        onlyOwner
        returns (bool success, uint256 poolIndex)
    {
        require(linearUnlockingEndsAt > props.endsAt, "Linear unlocking less than or equal to pool ending timestamp");
        Pool storage pool = _createSimplePool(props, paymentLimit, owner_, Type.LINEAR);
        _setImmediatelyUnlockingPart(pool, immediatelyUnlockingPart);
        pool.linear.endsAt = linearUnlockingEndsAt;
        pool.linear.duration = linearUnlockingEndsAt - props.endsAt;
        emit LinearUnlockingEndingTimestampUpdated(pool.index, linearUnlockingEndsAt);
        return (true, pool.index);
    }

    function increaseIssuance(uint256 poolIndex, uint256 amount) external returns (bool success) {
        require(amount > 0, "Amount is zero");
        Pool storage pool = _getPool(poolIndex);
        require(getTimestamp() < pool.props.endsAt, "Pool ended");
        address caller = msg.sender;
        _assertPoolOwnership(pool, caller);
        pool.state.issuance = pool.state.issuance + amount;
        require(pool.state.issuance <= pool.props.issuanceLimit, "Issuance limit exceeded");
        pool.state.available = pool.state.available + amount;
        emit IssuanceIncreased(poolIndex, amount);
        pool.props.issuanceToken.safeTransferFrom(caller, address(this), amount);
        return true;
    }

    /**
     * @dev Swaps the payment token for the issuance token in the pool.
     * This function can only be called by the whitelisted addresses.
     *
     * @param poolIndex The index of the pool in the _pools array.
     * @param requestedPaymentAmount The amount of payment tokens to be swapped for issuance tokens.
     *
     * @return paymentAmount The amount of payment tokens that were swapped.
     * @return issuanceAmount The amount of issuance tokens that were issued.
     */
    function swap(
        uint256 poolIndex,
        uint256 requestedPaymentAmount
    )
        external
        nonReentrant
        returns (uint256 paymentAmount, uint256 issuanceAmount)
    {
        require(requestedPaymentAmount > 0, "Requested payment amount is zero");
        address caller = msg.sender;
        require(whitelist.isWhitelisted(caller), "FixedSwap::Caller Not Whitelisted");
        Pool storage pool = _getPool(poolIndex);
        uint256 timestamp = getTimestamp();
        require(timestamp >= pool.props.startsAt, "Pool not started");
        require(timestamp < pool.props.endsAt, "Pool ended");
        require(pool.state.available > 0, "No available issuance");
        (paymentAmount, issuanceAmount) = _calculateSwapAmounts(pool, requestedPaymentAmount, caller);
        Account storage account = pool.accounts[caller];
        if (paymentAmount > 0) {
            pool.state.lockedPayments = pool.state.lockedPayments + paymentAmount;
            account.state.paymentSum = account.state.paymentSum + paymentAmount;
            uint256 contractBalanceBefore = pool.props.paymentToken.balanceOf(address(this));
            pool.props.paymentToken.safeTransferFrom(caller, address(this), paymentAmount);
            uint256 contractBalanceAfter = pool.props.paymentToken.balanceOf(address(this));

            require(
                contractBalanceBefore + paymentAmount == contractBalanceAfter,
                "Failed to transfer correct amount"
            );
        }
        if (issuanceAmount > 0) {
            if (pool.type_ == Type.SIMPLE) {
                pool.props.issuanceToken.safeTransfer(caller, issuanceAmount);
            } else {
                uint256 totalIssuanceAmount = account.complex.issuanceAmount + issuanceAmount;
                account.complex.issuanceAmount = totalIssuanceAmount;
                uint256 newWithdrawnIssuanceAmount = pool.immediatelyUnlockingPart.mul(totalIssuanceAmount).floor(
                    ERC20(address(pool.props.paymentToken)).decimals()
                );
                uint256 issuanceToWithdraw = newWithdrawnIssuanceAmount - account.complex.withdrawnIssuanceAmount;
                account.complex.withdrawnIssuanceAmount = newWithdrawnIssuanceAmount;
                if (pool.type_ == Type.LINEAR) {
                    account.immediatelyUnlockedAmount = newWithdrawnIssuanceAmount;
                }
                if (issuanceToWithdraw > 0) {
                    pool.props.issuanceToken.safeTransfer(caller, issuanceToWithdraw);
                }
            }
            pool.state.available = pool.state.available - issuanceAmount;
        }
        emit Swap(poolIndex, caller, requestedPaymentAmount, paymentAmount, issuanceAmount);
    }

    function unlockInterval(
        uint256 poolIndex,
        uint256 intervalIndex
    )
        external
        returns (uint256 withdrawnIssuanceAmount)
    {
        address caller = msg.sender;
        Pool storage pool = _getPool(poolIndex);
        _assertPoolIsInterval(pool);
        require(intervalIndex < pool.intervals.length, "Invalid interval index");
        Interval storage interval = pool.intervals[intervalIndex];
        require(interval.startsAt <= getTimestamp(), "Interval not started");
        Account storage account = pool.accounts[caller];
        require(intervalIndex >= account.unlockedIntervalsCount, "Already unlocked");
        uint256 newWithdrawnIssuanceAmount = interval.unlockingPart.mul(account.complex.issuanceAmount).floor(
            ERC20(address(pool.props.paymentToken)).decimals()
        );
        uint256 issuanceToWithdraw = newWithdrawnIssuanceAmount - account.complex.withdrawnIssuanceAmount;
        account.complex.withdrawnIssuanceAmount = newWithdrawnIssuanceAmount;
        if (issuanceToWithdraw > 0) {
            pool.props.issuanceToken.safeTransfer(caller, issuanceToWithdraw);
        }
        account.unlockedIntervalsCount = intervalIndex + 1;
        return issuanceToWithdraw;
    }

    /**
     * @dev Unlocks the linear pool for the caller.
     * This function can only be called by the pool participant.
     *
     * @param poolIndex The index of the pool in the _pools array.
     *
     * @return withdrawalAmount The amount of tokens that the caller can withdraw from the pool.
     * This amount is calculated based on the time passed since the pool ended and the amount of tokens
     * the caller has in the pool. If the pool has not ended yet or all funds are already unlocked,
     * the function will revert.
     */
    function unlockLinear(uint256 poolIndex) external returns (uint256 withdrawalAmount) {
        address caller = msg.sender;
        uint256 timestamp = getTimestamp();
        Pool storage pool = _getPool(poolIndex);
        _assertPoolIsLinear(pool);
        require(pool.props.endsAt < timestamp, "Pool not ended");
        Account storage account = pool.accounts[caller];
        uint256 issuanceAmount = account.complex.issuanceAmount;
        require(account.complex.withdrawnIssuanceAmount < issuanceAmount, "All funds already unlocked");
        uint256 passedTime = timestamp - pool.props.endsAt;
        uint256 freezedAmount = issuanceAmount - account.immediatelyUnlockedAmount;
        uint256 unfreezedAmount = (passedTime * freezedAmount) / pool.linear.duration;
        uint256 newWithdrawnIssuanceAmount = timestamp >= pool.linear.endsAt
            ? issuanceAmount
            : Math.min(account.immediatelyUnlockedAmount + unfreezedAmount, issuanceAmount);
        withdrawalAmount = newWithdrawnIssuanceAmount - account.complex.withdrawnIssuanceAmount;
        if (withdrawalAmount > 0) {
            account.complex.withdrawnIssuanceAmount = newWithdrawnIssuanceAmount;
            emit LinearPoolUnlocking(pool.index, caller, withdrawalAmount);
            pool.props.issuanceToken.safeTransfer(caller, withdrawalAmount);
        }
    }

    function withdrawPayments(uint256 poolIndex) external returns (bool success) {
        Pool storage pool = _getPool(poolIndex);
        address caller = msg.sender;
        _assertPoolOwnership(pool, caller);
        _unlockPayments(pool);
        uint256 collectedPayments = pool.state.unlockedPayments;
        require(collectedPayments > 0, "No collected payments");
        pool.state.unlockedPayments = 0;
        emit PaymentsWithdrawn(poolIndex, collectedPayments);
        pool.props.paymentToken.safeTransfer(caller, collectedPayments);
        return true;
    }

    function withdrawUnsold(uint256 poolIndex) external returns (bool success) {
        Pool storage pool = _getPool(poolIndex);
        address caller = msg.sender;
        _assertPoolOwnership(pool, caller);
        require(getTimestamp() >= pool.props.endsAt, "Not ended");
        uint256 amount = pool.state.available;
        require(amount > 0, "No unsold");
        pool.state.available = 0;
        emit UnsoldWithdrawn(poolIndex, amount);
        pool.props.issuanceToken.safeTransfer(caller, amount);
        return true;
    }

    function collectFee(uint256 poolIndex) external onlyOwner returns (bool success) {
        _unlockPayments(_getPool(poolIndex));
        return true;
    }

    /**
     * @dev Withdraws the collected fees for the specified token.
     * This function can only be called by the contract owner.
     *
     * @param token The ERC20 token for which the fees will be withdrawn.
     *
     * @return success True if the fees were withdrawn successfully, otherwise False.
     */
    function withdrawFee(IERC20 token) external onlyOwner returns (bool success) {
        uint256 collectedFee = _collectedFees[token];
        require(collectedFee > 0, "No collected fees");
        _collectedFees[token] = 0;
        emit FeeWithdrawn(address(token), collectedFee);
        token.safeTransfer(owner(), collectedFee);
        return true;
    }

    function nominateNewPoolOwner(uint256 poolIndex, address nominatedOwner_) external returns (bool success) {
        Pool storage pool = _getPool(poolIndex);
        _assertPoolOwnership(pool, msg.sender);
        require(nominatedOwner_ != pool.state.owner, "Already owner");
        if (pool.state.nominatedOwner == nominatedOwner_) return true;
        pool.state.nominatedOwner = nominatedOwner_;
        emit PoolOwnerNominated(poolIndex, nominatedOwner_);
        return true;
    }

    function acceptPoolOwnership(uint256 poolIndex) external returns (bool success) {
        Pool storage pool = _getPool(poolIndex);
        address caller = msg.sender;
        require(pool.state.nominatedOwner == caller, "Not nominated to pool ownership");
        pool.state.owner = caller;
        pool.state.nominatedOwner = address(0);
        emit PoolOwnerChanged(poolIndex, caller);
        return true;
    }

    function _assertPoolIsInterval(Pool storage pool) private view {
        require(pool.type_ == Type.INTERVAL, "Not interval pool");
    }

    function _assertPoolIsLinear(Pool storage pool) private view {
        require(pool.type_ == Type.LINEAR, "Not linear pool");
    }

    function _assertPoolOwnership(Pool storage pool, address account) private view {
        require(account == pool.state.owner, "Permission denied");
    }

    /**
     * @dev Calculates the payment and issuance amounts for the swap.
     *
     * @param pool The pool in which the swap is made.
     * @param requestedPaymentAmount The amount of payment tokens requested for the swap.
     * @param account The address of the account that is making the swap.
     *
     * @return paymentAmount The amount of payment tokens that will be swapped.
     * @return issuanceAmount The amount of issuance tokens that will be issued.
     */
    function _calculateSwapAmounts(
        Pool storage pool,
        uint256 requestedPaymentAmount,
        address account
    )
        private
        view
        returns (uint256 paymentAmount, uint256 issuanceAmount)
    {
        paymentAmount = requestedPaymentAmount;
        Account storage poolAccount_ = pool.accounts[account];
        uint256 paymentLimit = pool.state.paymentLimit;
        require(poolAccount_.state.paymentSum < paymentLimit, "Account payment limit exceeded");
        if (poolAccount_.state.paymentSum + paymentAmount > paymentLimit) {
            paymentAmount = paymentLimit - poolAccount_.state.paymentSum;
        }
        issuanceAmount = pool.props.rate.mul(paymentAmount).floor(ERC20(address(pool.props.paymentToken)).decimals());
        if (issuanceAmount > pool.state.available) {
            issuanceAmount = pool.state.available;
            paymentAmount = AttoDecimal.div(
                issuanceAmount, pool.props.rate, ERC20(address(pool.props.paymentToken)).decimals()
            ).ceil(ERC20(address(pool.props.paymentToken)).decimals());
        }
    }

    function _getPool(uint256 index) private view returns (Pool storage) {
        require(index < _pools.length, "Pool not found");
        return _pools[index];
    }

    /**
     * @dev Creates a simple pool with the provided properties, payment limit, and owner.
     * This function can only be called by the contract owner.
     *
     * @param props The properties of the pool to be created. It is a struct of type Props which includes:
     * - issuanceLimit: The maximum amount of tokens that can be issued.
     * - startsAt: The timestamp when the pool starts.
     * - endsAt: The timestamp when the pool ends.
     * - paymentToken: The ERC20 token to be used for payments.
     * - issuanceToken: The ERC20 token to be issued.
     * - fee: The fee for the pool.
     * - rate: The rate of the pool.
     * @param paymentLimit The maximum amount of payment that can be made in the pool.
     * @param owner_ The owner of the pool.
     * @param type_ The type of the pool. It can be SIMPLE, INTERVAL, or LINEAR.
     *
     * @return pool The created pool. It is a struct of type Pool which includes:
     * - index: The index of the pool in the _pools array.
     * - type_: The type of the pool.
     * - props: The properties of the pool.
     * - state: The state of the pool which includes the payment limit and the owner.
     */
    function _createSimplePool(
        Props memory props,
        uint256 paymentLimit,
        address owner_,
        Type type_
    )
        private
        returns (Pool storage)
    {
        {
            uint256 timestamp = getTimestamp();
            uint8 decimals = ERC20(address(props.paymentToken)).decimals();
            if (props.startsAt < timestamp) props.startsAt = timestamp;
            require(decimals > 0, "PaymentTokenDecimals is 0");
            require(props.fee.lt(1, decimals), "Fee gte 100%");
            require(props.startsAt < props.endsAt, "Invalid ending timestamp");
        }
        uint256 poolIndex = _pools.length;
        _pools.push();
        Pool storage pool = _pools[poolIndex];
        pool.index = poolIndex;
        pool.type_ = type_;
        pool.props = props;
        pool.state.paymentLimit = paymentLimit;
        pool.state.owner = owner_;
        emit PoolCreated(
            type_,
            props.paymentToken,
            props.issuanceToken,
            poolIndex,
            props.issuanceLimit,
            props.startsAt,
            props.endsAt,
            props.fee.mantissa,
            props.rate.mantissa,
            paymentLimit
        );
        emit PoolOwnerChanged(poolIndex, owner_);
        return pool;
    }

    /**
     * @dev Sets the immediately unlocking part for the pool.
     *
     * @param pool The pool in which the immediately unlocking part is set.
     * @param immediatelyUnlockingPart The part of the issuance tokens that can be unlocked immediately.
     */
    function _setImmediatelyUnlockingPart(
        Pool storage pool,
        AttoDecimal.Instance memory immediatelyUnlockingPart
    )
        private
    {
        uint8 decimals = ERC20(address(pool.props.paymentToken)).decimals();
        require(immediatelyUnlockingPart.lt(1, decimals), "Invalid immediately unlocking part value");
        pool.immediatelyUnlockingPart = immediatelyUnlockingPart;
        emit ImmediatelyUnlockingPartUpdated(pool.index, immediatelyUnlockingPart.mantissa);
    }

    /**
     * @dev Unlocks the payments in the pool.
     *
     * @param pool The pool in which the payments are unlocked.
     */
    function _unlockPayments(Pool storage pool) private {
        if (pool.state.lockedPayments == 0) return;
        uint256 fee =
            pool.props.fee.mul(pool.state.lockedPayments).ceil(ERC20(address(pool.props.paymentToken)).decimals());
        _collectedFees[pool.props.paymentToken] = _collectedFees[pool.props.paymentToken] + fee;
        uint256 unlockedAmount = pool.state.lockedPayments - fee;
        pool.state.unlockedPayments = pool.state.unlockedPayments + unlockedAmount;
        pool.state.lockedPayments = 0;
        emit PaymentUnlocked(pool.index, unlockedAmount, fee);
    }

    function changeWhitelistAddress(address _newWhitelistAddress) external onlyOwner {
        require(_newWhitelistAddress != address(0), "FixedSwap: ZeroAddress");
        emit WhitelistContractChanged(address(whitelist), _newWhitelistAddress);
        whitelist = IWhitelist(_newWhitelistAddress);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

library AttoDecimal {
    struct Instance {
        uint256 mantissa;
    }

    uint256 constant BASE = 10;

    function ONE_MANTISSA(uint8 decimals) internal pure returns (uint256) {
        return BASE ** decimals;
    }

    function SQUARED_ONE_MANTISSA(
        uint8 decimals
    ) internal pure returns (uint256) {
        return ONE_MANTISSA(decimals) * ONE_MANTISSA(decimals);
    }

    function MAX_INTEGER(uint8 decimals) internal pure returns (uint256) {
        return type(uint256).max / ONE_MANTISSA(decimals);
    }

    function mul(
        Instance memory a,
        uint256 b
    ) internal pure returns (Instance memory) {
        return Instance({mantissa: a.mantissa * b});
    }

    function div(
        Instance memory a,
        uint256 b
    ) internal pure returns (Instance memory) {
        return Instance({mantissa: a.mantissa / b});
    }

    function div(
        uint256 a,
        Instance memory b,
        uint8 decimals
    ) internal pure returns (Instance memory) {
        return
            Instance({
                mantissa: (a * SQUARED_ONE_MANTISSA(decimals)) / b.mantissa
            });
    }

    function floor(
        Instance memory a,
        uint8 decimals
    ) internal pure returns (uint256) {
        return a.mantissa / ONE_MANTISSA(decimals);
    }

    function ceil(
        Instance memory a,
        uint8 decimals
    ) internal pure returns (uint256) {
        return
            (a.mantissa / ONE_MANTISSA(decimals)) +
            (a.mantissa % ONE_MANTISSA(decimals) > 0 ? 1 : 0);
    }

    function eq(
        Instance memory a,
        uint256 b,
        uint8 decimals
    ) internal pure returns (bool) {
        if (b > MAX_INTEGER(decimals)) return false;
        return a.mantissa == b * ONE_MANTISSA(decimals);
    }

    function gt(
        Instance memory a,
        Instance memory b
    ) internal pure returns (bool) {
        return a.mantissa > b.mantissa;
    }

    function lt(
        Instance memory a,
        uint256 b,
        uint8 decimals
    ) internal pure returns (bool) {
        if (b > MAX_INTEGER(decimals)) return true;
        return a.mantissa < (b * (ONE_MANTISSA(decimals)));
    }

    function lt(
        Instance memory a,
        Instance memory b
    ) internal pure returns (bool) {
        return a.mantissa < b.mantissa;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IWhitelist {
    function addWallets(address[] calldata wallets) external;

    function removeWallets(address[] calldata wallets) external;

    function isWhitelisted(address wallet) external view returns (bool);

    event AddressesWhitelisted(address caller);
    event AddressesBlacklisted(address caller);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

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
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
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
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
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
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
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
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
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
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
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
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

abstract contract TwoStageOwnable {
    address private _nominatedOwner;
    address private _owner;

    function nominatedOwner() public view returns (address) {
        return _nominatedOwner;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    event OwnerChanged(address indexed newOwner);
    event OwnerNominated(address indexed nominatedOwner);

    constructor(address owner_) {
        require(owner_ != address(0), "Owner is zero");
        _setOwner(owner_);
    }

    function acceptOwnership() external returns (bool success) {
        require(msg.sender == _nominatedOwner, "Not nominated to ownership");
        _setOwner(_nominatedOwner);
        return true;
    }

    function nominateNewOwner(address owner_) external onlyOwner returns (bool success) {
        _nominateNewOwner(owner_);
        return true;
    }

    modifier onlyOwner {
        require(msg.sender == _owner, "Not owner");
        _;
    }

    function _nominateNewOwner(address owner_) internal {
        if (_nominatedOwner == owner_) return;
        require(_owner != owner_, "Already owner");
        _nominatedOwner = owner_;
        emit OwnerNominated(owner_);
    }

    function _setOwner(address newOwner) internal {
        if (_owner == newOwner) return;
        _owner = newOwner;
        _nominatedOwner = address(0);
        emit OwnerChanged(newOwner);
    }
}