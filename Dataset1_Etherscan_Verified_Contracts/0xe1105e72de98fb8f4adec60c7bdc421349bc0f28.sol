/// SPDX-License-Identifier: MIT
pragma solidity 0.8.26; 
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

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {FailedInnerCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {FailedInnerCall}) in case of an
     * unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {FailedInnerCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {FailedInnerCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}






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

    /**
     * @dev An operation with an ERC20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
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

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}



/**
 * @title MoonVesting
 * @dev A token vesting contract that handles both linear and cycle-based vesting schedules.
 */
contract MoonVesting is Ownable {
    using SafeERC20 for IERC20;
    IERC20 public token;

    struct VestingSchedule {
        uint256 amount;
        uint256 start;
        uint256 duration;
        bool revokable;
        bool revoked;
        uint256 cycles;
        uint256 cycleDuration;
        uint256 released;
    }

    mapping(address => mapping(uint256 => VestingSchedule))
        public vestingSchedules;
    mapping(address => uint256[]) public userVestingIds;

    bool private _entered;

    event VestingCreated(
        address indexed beneficiary,
        uint256 indexed vestingId,
        uint256 amount,
        uint256 start,
        uint256 cliff,
        uint256 duration,
        bool revokable,
        uint256 cycles,
        uint256 cycleDuration
    );
    event TokensReleased(
        address indexed beneficiary,
        uint256 indexed vestingId,
        uint256 amount
    );
    event VestingRevoked(
        address indexed beneficiary,
        uint256 indexed vestingId
    );


    error ZeroAddress();
    error ZeroAmount();
    error CliffPeriodIsNotPassedYet();
    error NoTokensToClaim();
    error AlreadyClaimed();
    error ArrayLengthMismatch();
    error ZeroDuration();
    error MinimumTwoCycles();
    error VestingIsNotRevokable();
    error AlreadyRevoked();
    error NoVestingFound();
    error CannotClaimNativeToken();
    /**
     * @dev Constructor function
     * @param _token Address of the token to be vested
     */
    constructor(IERC20 _token) Ownable(msg.sender) {
        token = _token;
    }

    modifier nonReentrant() {
        require(!_entered, "Reentrant call");
        _entered = true;
        _;
        _entered = false;
    }

    function claimOtherERC20(address _token, address to, uint256 amount) external onlyOwner{
      if(_token == address(token)){
        revert CannotClaimNativeToken();
      }
      // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = _token.call(
            abi.encodeWithSelector(0xa9059cbb, to, amount)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "ERC20: TOKEN_CLAIM_FAILED"
        );
    }

    /// @dev set linear vesting
    /// see docs:{_setLinearVesting}
    /// example - user '0x123' has been alloted with 100 tokens, cliff is 1, duration is 30
    /// then user tokens are vested over 30 days linearly.
    /// user can start claiming unlocked tokens anytime after cliff of 1 day has been passed.
    function setLinearVesting(
        address beneficiary,
        uint256 amount,
        uint256 cliff,
        uint256 duration,
        bool revokable
    ) external onlyOwner {
        if (amount > 0) {
            token.safeTransferFrom(msg.sender, address(this), amount);
        }
        _setLinearVesting(
            beneficiary,
            amount,
            cliff,
            duration,
            revokable
        );
    }

   

    /// @dev set linear vesting for multiple users with custom amounts, duration
    /// see docs:{_setLinearVesting}
    function setLinearVestingMulti(
        address[] calldata users,
        uint256[] calldata amounts,
        uint256[] calldata cliff,
        uint256[] calldata duration,
        bool revokable
    ) external onlyOwner {
        uint256 userLength = users.length;
        uint256 amountLength = amounts.length;
        if(
            userLength != amountLength &&
                userLength != cliff.length &&
                userLength != duration.length){revert ArrayLengthMismatch();}
           
        uint256 totalTokens;
        for (uint256 j = 0; j < amountLength; j++) {
            totalTokens = totalTokens + amounts[j];
        }
        token.safeTransferFrom(msg.sender, address(this), totalTokens);
        for (uint256 i = 0; i < userLength; i++) {
            _setLinearVesting(
                users[i],
                amounts[i],
                cliff[i],
                duration[i],
                revokable
            );
        }
    }

    /// @dev set cycleBased vesting
    /// see docs:{_setCycleBasedrVesting}
    /// example - user '0x123' is assigned with 100 as amount. With cliff 1, cycles 5 and cycle duration 10
    /// so per cycle claimable amount will be (100/5 = 20),
    /// when 1 day passed, user can get 20 tokens, then every 10 days he can claim 20 tokens untill full
    /// amount is claimed
    function setCycleBasedVesting(
        address beneficiary,
        uint256 amount,
        uint256 cliff,
        uint256 cycles,
        uint256 cycleduration,
        bool revokable
    ) external onlyOwner {
        if (amount > 0) {
            token.safeTransferFrom(msg.sender, address(this), amount);
        }
        _setCycleBasedVesting(
            beneficiary,
            amount,
            cliff,
            cycles,
            cycleduration,
            revokable
        );
    }

    
    /// @dev set cycleBased vesting for multiple users with custom amounts, cycles
    /// see docs:{_setCycleBasedrVesting}
    function setCycleBasedVestingMultiWithCustomParams(
        address[] calldata users,
        uint256[] calldata amounts,
        uint256[] calldata cliff,
        uint256[] calldata cycles,
        uint256[] calldata cycleduration,
        bool revokable
    ) external onlyOwner {
        uint256 userLength = users.length;
        uint256 amountLength = amounts.length;
        if(
            userLength != amountLength &&
                userLength != cliff.length &&
                userLength != cycles.length){revert ArrayLengthMismatch();}
        uint256 totalTokens;
        
        for (uint256 j = 0; j < amountLength; ++j) {
            totalTokens = totalTokens + amounts[j];
        }
        
        token.safeTransferFrom(msg.sender, address(this), totalTokens);

        for (uint256 i = 0; i < userLength; ++i) {
            _setCycleBasedVesting(
                users[i],
                amounts[i],
                cliff[i],
                cycles[i],
                cycleduration[i],
                revokable
            );
        }
        
    }

    /**
     * @notice Sets a linear vesting schedule for a beneficiary
     * @param beneficiary Address of the beneficiary
     * @param amount Total amount of tokens to be vested
     * @param cliff Duration in days before vesting starts
     * @param duration Total duration in days for vesting
     * @param revokable Boolean indicating whether the vesting is revokable by the owner
     */
    function _setLinearVesting(
        address beneficiary,
        uint256 amount,
        uint256 cliff,
        uint256 duration,
        bool revokable
    ) internal {
        if(
            beneficiary == address(0)){revert ZeroAddress();}
           
        if(amount == 0){revert ZeroAmount();}
        if(duration == 0){revert ZeroDuration();}

         cliff = cliff * 1 days;
         duration = duration * 1 days;
        uint256 start = block.timestamp + cliff;

        uint256 vestingId = userVestingIds[beneficiary].length;
        vestingSchedules[beneficiary][vestingId] = VestingSchedule({
            amount: amount,
            start: start,
            duration: duration,
            revokable: revokable,
            revoked: false,
            cycles: 0,
            cycleDuration: 0,
            released: 0
        });

        userVestingIds[beneficiary].push(vestingId);

        emit VestingCreated(
            beneficiary,
            vestingId,
            amount,
            start,
            cliff,
            duration,
            revokable,
            0,
            0
        );
    }

    /**
     * @notice Sets a cycle-based vesting schedule for a beneficiary
     * @param beneficiary Address of the beneficiary
     * @param amount Total amount of tokens to be vested
     * @param cliff Duration in days before vesting starts
     * @param cycles Number of cycles for the vesting
     * @param cycleduration Duration in days of each cycle
     * @param revokable Boolean indicating whether the vesting is revokable by the owner
     */
    function _setCycleBasedVesting(
        address beneficiary,
        uint256 amount,
        uint256 cliff,
        uint256 cycles,
        uint256 cycleduration,
        bool revokable
    ) internal {
        if(
            beneficiary == address(0)){revert ZeroAddress();}
           
        if(amount == 0){revert ZeroAmount();}
        if(cycleduration == 0){revert ZeroDuration();}
        if(cycles == 0){revert MinimumTwoCycles();}

        cliff = cliff * 1 days;
        cycleduration = cycleduration * 1 days;
        uint256 start = block.timestamp + cliff;
        uint256 duration = cycles * cycleduration;
        uint256 vestingId = userVestingIds[beneficiary].length;
        vestingSchedules[beneficiary][vestingId] = VestingSchedule({
            amount: amount,
            start: start,
            duration: duration,
            revokable: revokable,
            revoked: false,
            cycles: cycles,
            cycleDuration: cycleduration,
            released: 0
        });

        userVestingIds[beneficiary].push(vestingId);

        emit VestingCreated(
            beneficiary,
            vestingId,
            amount,
            start,
            cliff,
            duration,
            revokable,
            cycles,
            cycleduration
        );
    }

    /**
     * @notice Returns the IDs of all vesting schedules for a user
     * @param beneficiary Address of the beneficiary
     * @return Array of vesting schedule IDs
     */
    function getUserVestingIds(address beneficiary)
        external
        view
        returns (uint256[] memory)
    {
        return userVestingIds[beneficiary];
    }

    

    /**
     * @notice Allows a beneficiary to claim tokens from a specific vesting schedule
     * @param vestingId ID of the vesting schedule
     */
    function claimTokens(uint256 vestingId) external nonReentrant{
        _release(msg.sender, vestingId);
    }

    /**
     * @notice Allows a beneficiary to claim tokens from multiple vesting schedules
     * @param vestingIds Array of vesting schedule IDs
     */
    function claimMultipleTokens(uint256[] memory vestingIds) external nonReentrant{
        for (uint256 i = 0; i < vestingIds.length; i++) {
            _release(msg.sender, vestingIds[i]);
        }
    }

    /**
     * @notice Revokes a vesting schedule
     * @param beneficiary Address of the beneficiary
     * @param vestingId ID of the vesting schedule
     * send unlocked tokens to beneficiary and rest to the owner
     * userful if setting vesting for employees
     */
    function revoke(address beneficiary, uint256 vestingId) external onlyOwner {
        VestingSchedule storage schedule = vestingSchedules[beneficiary][
            vestingId
        ];
        if(!schedule.revokable){revert VestingIsNotRevokable();}
        if(schedule.revoked){revert AlreadyRevoked();}

        uint256 vestedAmount = _tokensVested(beneficiary, vestingId);
        uint256 unreleased = vestedAmount - schedule.released;
        uint256 refund = schedule.amount - vestedAmount;

        schedule.revoked = true;

        if (unreleased > 0) {
            token.safeTransfer(beneficiary, unreleased);
        }

        token.safeTransfer(owner(), refund);

        emit VestingRevoked(beneficiary, vestingId);
    }

    /**
 * @notice Returns the IDs of all vesting schedules for a user that have tokens available
 * @param beneficiary Address of the beneficiary
 * @return Array of vesting schedule IDs with tokens available
 */
function getUserVestingIdsWithTokens(address beneficiary) external view returns (uint256[] memory) {
    uint256[] memory allIds = userVestingIds[beneficiary];
    uint256[] memory tempIdsWithTokens = new uint256[](allIds.length);
    uint256 count = 0;

    for (uint256 i = 0; i < allIds.length; i++) {
        uint256 vestingId = allIds[i];
        if (getIdWithTokens(beneficiary, vestingId) > 0) {
            tempIdsWithTokens[count] = vestingId;
            count++;
        }
    }

    // Create the final array with the exact count
    uint256[] memory idsWithTokens = new uint256[](count);
    for (uint256 i = 0; i < count; i++) {
        idsWithTokens[i] = tempIdsWithTokens[i];
    }

    return idsWithTokens;
}

    /**
     * @dev Internal function to release tokens for a specific vesting schedule
     * @param beneficiary Address of the beneficiary
     * @param vestingId ID of the vesting schedule
     */
    function _release(address beneficiary, uint256 vestingId) internal {
        VestingSchedule storage schedule = vestingSchedules[beneficiary][
            vestingId
        ];
        if(schedule.amount == 0){revert NoVestingFound();}
        if(block.timestamp < schedule.start){revert CliffPeriodIsNotPassedYet();}
        if(schedule.revoked){revert AlreadyRevoked();}

        uint256 vestedAmount = _tokensVested(beneficiary, vestingId);
        uint256 unreleased = vestedAmount - schedule.released;

        if(unreleased == 0) {revert AlreadyClaimed();}

        schedule.released += unreleased;
        token.safeTransfer(beneficiary, unreleased);

        emit TokensReleased(beneficiary, vestingId, unreleased);
    }
    
    /**
     * @dev returns if particular vesting has tokens to claim
     * @param user user address
     * @param vesting  vesting id
     */

    function getIdWithTokens (address user, uint256 vesting) public view returns (uint256){
        VestingSchedule storage schedule = vestingSchedules[user][
            vesting
        ];
        uint256 amount = schedule.amount - schedule.released;
        return amount;
    }
    

    /**
     * @notice returns current claimable tokens for particular user
     * @param user user address
     * @param vesting vesting id
     */
    function getUnlockedTokens(address user, uint256 vesting) public view returns (uint256) {
        VestingSchedule storage schedule = vestingSchedules[user][
            vesting
        ];
        if(schedule.start >  block.timestamp){return 0;}
        uint256 totalAmount = _tokensVested(user, vesting);
         uint256 unlockedTokens = totalAmount - schedule.released;
         return unlockedTokens;
    }

    /**
     * @dev Internal function to calculate the amount of tokens vested for a specific vesting schedule
     * @param beneficiary Address of the beneficiary
     * @param vestingId ID of the vesting schedule
     * @return Amount of vested tokens
     */
    function _tokensVested(address beneficiary, uint256 vestingId)
        private
        view
        returns (uint256)
    {
        VestingSchedule storage schedule = vestingSchedules[beneficiary][
            vestingId
        ];

        if (block.timestamp < schedule.start) {
            return 0;
        }

        if (schedule.revoked) {
            return schedule.released;
        }

        uint256 elapsedTime = block.timestamp - schedule.start;
        uint256 vestedAmount;

        if (schedule.cycles == 0) {
            // Linear vesting
            vestedAmount = (schedule.amount * elapsedTime) / schedule.duration;
        } else {
            // Cycle-based vesting
            uint256 currentCycle = elapsedTime / schedule.cycleDuration;
            vestedAmount =
                (schedule.amount * (currentCycle + 1)) /
                schedule.cycles;
        }

        if (vestedAmount > schedule.amount) {
            vestedAmount = schedule.amount;
        }

        return vestedAmount;
    }
}