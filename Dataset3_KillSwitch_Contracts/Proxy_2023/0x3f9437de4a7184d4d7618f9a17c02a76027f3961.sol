// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
  _   _      _           _       ____  _        _     _      
 | \ | | ___| |__  _   _| | __ _/ ___|| |_ _ __(_) __| | ___ 
 |  \| |/ _ \ '_ \| | | | |/ _` \___ \| __| '__| |/ _` |/ _ \
 | |\  |  __/ |_) | |_| | | (_| |___) | |_| |  | | (_| |  __/
 |_| \_|\___|_.__/ \__,_|_|\__,_|____/ \__|_|  |_|\__,_|\___|
                                                             
*/


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
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    bool private _paused;

    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    /**
     * @dev The operation failed because the contract is paused.
     */
    error EnforcedPause();

    /**
     * @dev The operation failed because the contract is not paused.
     */
    error ExpectedPause();

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        if (paused()) {
            revert EnforcedPause();
        }
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        if (!paused()) {
            revert ExpectedPause();
        }
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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
 * @dev Collection of common custom errors used in multiple contracts
 *
 * IMPORTANT: Backwards compatibility is not guaranteed in future versions of the library.
 * It is recommended to avoid relying on the error API for critical functionality.
 *
 * _Available since v5.1._
 */
library Errors {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error InsufficientBalance(uint256 balance, uint256 needed);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedCall();

    /**
     * @dev The deployment failed.
     */
    error FailedDeployment();

    /**
     * @dev A necessary precompile is missing.
     */
    error MissingPrecompile(address);
}

library Address {
    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

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
            revert Errors.InsufficientBalance(address(this).balance, amount);
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert Errors.FailedCall();
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
     * {Errors.FailedCall} error.
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
            revert Errors.InsufficientBalance(address(this).balance, value);
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
     * was not a contract or bubbling up the revert reason (falling back to {Errors.FailedCall}) in case
     * of an unsuccessful call.
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
     * revert reason or with a default {Errors.FailedCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {Errors.FailedCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            assembly ("memory-safe") {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert Errors.FailedCall();
        }
    }
}

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
 * TIP: If EIP-1153 (transient storage) is available on the chain you're deploying at,
 * consider using {ReentrancyGuardTransient} instead.
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
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}


interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(
    uint80 _roundId
  ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

  function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}


/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function decimals() external returns (uint8);
}


/**
 * @dev Interface of the USDT mainnet because its transferFrom doesnt return bool
 */
interface ERC20USDT {
    function totalSupply()  external  returns (uint);
    function balanceOf(address who) external  returns (uint);
    function transfer(address to, uint value) external;
    event Transfer(address indexed from, address indexed to, uint value);
    function allowance(address owner, address spender) external  returns (uint);
    function transferFrom(address from, address to, uint value) external;
    function approve(address spender, uint value) external;
    event Approval(address indexed owner, address indexed spender, uint value);
    function decimals() external returns (uint256);

}

interface IProxy {
    function masterCopy() external view returns (address);
}


contract PresaleContract is Pausable, Ownable, ReentrancyGuard {
    
    AggregatorV3Interface internal price_feed;
    IERC20 internal nst_token;
    ERC20USDT internal usdt_token;

    uint256 private sold_amount = 0;
    uint256 private current_round = 0;
    uint256 private end_round = 24;
    uint256 private current_round_amount = 0;
    uint256 private current_price = 0;
    uint256 private usdt_decimals = 0;
    uint256 private nst_decimals = 0;
    uint256 private all_sold_amount = 0;
    bool public presale_ended = false;
    address public nst_token_address = address(0);
    address public potential_owner = address(0);

    
    uint256 private constant initial_round_amount = 20833333 * 10 ** 18;
    uint256 private constant start_price = 20000;
    uint256 private constant round_step = 5000;
    address public constant payout_address = 0xa796029F1887b28545dc61F30A67d4661Ec18cDb; 
    address public constant usdt_token_address = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public constant price_feed_address = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    address public constant initial_multisig_admin = 0x453F55b3aC1C4377a8BaD6Bb7EFe55bAe982124f;



    uint256 public constant timelock_period = 48*60*60;
    

    uint256 public allow_transfer_ownership_at = 0;
    uint256 public allow_renounce_ownership_at = 0;
    uint256 public allow_extract_at = 0;
    address public scheduled_new_owner = address(0);


    constructor() Ownable(initial_multisig_admin) {
        price_feed = AggregatorV3Interface(price_feed_address);
        usdt_token = ERC20USDT(usdt_token_address);
        usdt_decimals = usdt_token.decimals();
        current_round_amount = initial_round_amount;
        current_round = 1; 
        current_price = start_price;
    }


    function acceptOwnership() public {
        require(msg.sender == potential_owner, "You must be nominated as potential owner before you can accept ownership");
        require(owner() != address(0), "Ownership renounced");
        _transferOwnership(potential_owner);
        potential_owner = address(0); 
    }

    event OwnerNominated(address newOwner);


    event AcquiredForOrder(
        address indexed buyer_address,
        uint256 usdt_amount,
        uint256 nst_price,
        uint256 payment_token_amount,
        uint256 payment_token_exchange_rate,
        uint256 round,
        uint256 nst_amount
    );

    event PresaleInitialized(
        address nst_address
    );

    event PresaleEnded(
        bool ended
    );

    event IncreaseRound(
        uint256 round
    );

    event CurrentRoundAmount(
        uint256 amount
    );

    event ScheduleTransferOwnership(
        address new_owner_candidate,
        uint256 allow_execute_at,
        bool canceled,
        bool executed
    );

    event ScheduleRenounceOwnership(
        uint256 allow_execute_at,
        bool canceled,
        bool executed
    );

    event ScheduleExtractNST(
        uint256 allow_execute_at,
        bool canceled,
        bool executed
    );


    /*
    * @dev Initialize NST presale contract by setting NST token address.
    */
    function setNstAddress(address nst_address_) public onlyOwner {
        require(nst_token_address == address(0), "NebulaStride::Presale::AlreadyInitialized");
        require(nst_address_ != address(0), "NebulaStride::Presale::ZeroAddress");
        nst_token_address = nst_address_;
        nst_token = IERC20(nst_token_address);
        nst_decimals = nst_token.decimals();
        emit PresaleInitialized(nst_address_);
    }

    /**
    * @dev This function get current exchange rate from chainlink and cast
    * decimal places to usdt-like (which is 6 decimals)
    */
    function getEthPrice() public view returns (uint256) {
        (
        ,
        int256 price,
        ,
        uint256 updatedAt,
        ) = price_feed.latestRoundData();
        require(price > 0, "NebulaStride::PriceOracle::OracleFetchPriceFailed");
        require(block.timestamp - updatedAt <= 3600, "NebulaStride::PriceOracle::OraclePriceOld");
        return uint256(price)/100;
    }

    /**
    * @dev This function uses to convert base asset amount to quote asset amount.
    */
    function calcQuoteAmountFromBase(uint256 eth_amount, uint256 price, uint256 input_decimals_count) public pure returns (uint256) {
        uint256 usdt_amount = (eth_amount * price)/10**input_decimals_count;
        return usdt_amount;
    }

    /**
    * @dev This function uses to convert quote asset amount to base asset amount.
    */
    function calcBaseAmountFromQuote(uint256 usdt_amount, uint256 price, uint256 output_decimals_count) public pure returns (uint256) {
        uint256 eth_amount = (usdt_amount*10**output_decimals_count)/ price;
        return eth_amount;
    }

    /*
    * @dev This function uses to calculate buy amount based on base and quote assets.
    */
    function calcBuyPrice(uint256 base_amount, uint256 quote_amount, uint256 decimal_amount ) public pure returns (uint256) {
        uint256 price = (quote_amount * 10 ** decimal_amount)/ base_amount;
        return price;
    }


    /*
    * @notice Get price on current round
    * @dev This function uses to calculate buy amount based on base and quote assets.
    */
    function currentPrice() public view  returns (uint256) { 
        return current_price;
    }

    /* @dev 
    * This function is a presale engine. It performs estimation of the following parameters.
    *  1. How much NST the user will get
    *  2. How many will remain in the round
    *  3. Round number
    *  4. Average purchase price of NST in usdt
    *  5. Whether the presale will end after this order
    *  6. Order parts 2d array (this is required for publishing AcquiredForOrder events). Each row contains metadata for part order for each round.
    *  
    *  Also this function will return revert if we don't have enough NST to cover his order.
    */
    function quoteFromUSDTtoNST(uint256 payment_amount) public view returns (uint256, uint256, uint256, uint256, bool, uint256[4][] memory){
    require(nst_token_address != address(0), "NebulaStride::Presale::NotInitialized");
    require(payment_amount > 0, "NebulaStride::Quoter::InitialPaymentIsNull");
    uint256 payment_amount_ = payment_amount;
    uint256 remaining_payment_amount = payment_amount;
    uint256 remaining_round_amount = current_round_amount;
    uint256 remaining_round = current_round;
    uint256 remaining_nst_amount = 0;
    bool remaining_presale_ended = false;
    uint256[4][] memory parts = new uint256[4][](end_round - current_round + 1);
    uint256 part_idx = 0;
    for (uint256 round_=current_round; round_ <= end_round; round_++){
        uint256 round_price = start_price + (round_step * (round_ - 1));
        uint256 nst_amount = calcBaseAmountFromQuote(remaining_payment_amount, round_price, 18);
        if (nst_amount >= remaining_round_amount){
            uint256 usdt_amount = calcQuoteAmountFromBase(remaining_round_amount, round_price, 18);
            remaining_round += 1;
            if (nst_amount == remaining_round_amount){
                remaining_round_amount = initial_round_amount;
                remaining_nst_amount += nst_amount;
                remaining_payment_amount -= remaining_payment_amount;
                parts[part_idx] = [nst_amount, usdt_amount, round_price, round_];
                part_idx++;
                break;
            }
            else {
                remaining_nst_amount += remaining_round_amount;
                parts[part_idx] = [remaining_round_amount, usdt_amount, round_price, round_]; 
                part_idx++;
                remaining_round_amount = initial_round_amount;
                remaining_payment_amount -= usdt_amount;
            }

        }
        else{
            uint256 usdt_amount = remaining_payment_amount;
            parts[part_idx] = [nst_amount, usdt_amount, round_price, round_]; 
            part_idx++;
            remaining_round_amount -= nst_amount;
            remaining_nst_amount += nst_amount;
            remaining_payment_amount -= usdt_amount;
            break;
        }
    }
    require(remaining_payment_amount == 0, "NebulaStride::Quoter::TooManyPayment");


    if (remaining_round > end_round) {
        remaining_round = end_round;
        remaining_round_amount = 0;
        remaining_presale_ended = true;
    }

    uint256 avg_buy_price = calcBuyPrice(remaining_nst_amount, payment_amount_, nst_decimals);
    return (remaining_nst_amount, remaining_round_amount, remaining_round, avg_buy_price, remaining_presale_ended, parts);
    }

    /* 
    * @dev This function is only for estimate how much usdt user pay for some NST amount
    */
    function quoteFromNSTtoUSDT(uint256 nst_amount) public view returns (uint256, uint256){
        require(nst_token_address != address(0), "NebulaStride::Presale::NotInitialized");
        require(nst_amount > 0, "NebulaStride::Quoter::InitialPaymentIsNull");
        uint256 wants_nst_amount_ = nst_amount;
        uint256 remaining_nst_amount = nst_amount;
        uint256 remaining_round_amount = current_round_amount;
        uint256 remaining_usdt_amount = 0;
        uint256 nst_total = initial_round_amount * end_round - all_sold_amount;
        require(remaining_nst_amount <= nst_total, "NebulaStride::Quoter::NotEnoughNST");
        for (uint256 round_ = current_round; round_ <= end_round; round_++){
            uint256 round_price = start_price + (round_step * (round_ - 1));
            if  (remaining_nst_amount > remaining_round_amount){
                remaining_usdt_amount += calcQuoteAmountFromBase(remaining_round_amount, round_price, 18);
                remaining_nst_amount -= remaining_round_amount;
                remaining_round_amount = initial_round_amount;
            }
            else {
                remaining_usdt_amount += calcQuoteAmountFromBase(remaining_nst_amount, round_price, 18);
                remaining_nst_amount -= remaining_nst_amount;
                break;
            }
        }
        require(remaining_nst_amount ==0, "NebulaStride::Quoter::ErrorWhileQuoting");

        uint256 avg_buy_price = calcBuyPrice(wants_nst_amount_, remaining_usdt_amount, 18);
        
        return (remaining_usdt_amount, avg_buy_price);
    }


    /* 
    * @dev Quote how many user received NST for certain USDT or ETH amount
    */
    function quote(bool is_usdt, uint256 initial_payment_amount) whenNotPaused public view returns (uint256, uint256) {
        require(nst_token_address != address(0), "NebulaStride::Presale::NotInitialized");
        require(initial_payment_amount > 0, "NebulaStride::Quoter::InitialPaymentIsNull");
        require(presale_ended == false, "NebulaStride::Quoter::PresaleEnded");
        if (is_usdt == true) {
            uint256 payment_amount_ = initial_payment_amount;
            (uint256 nst_amount,,, uint256 avg_buy_price,,  ) = quoteFromUSDTtoNST(payment_amount_);
            return (nst_amount, avg_buy_price);
        }
        else {
            uint256 price = getEthPrice();
            uint256 payment_amount_ = calcQuoteAmountFromBase(initial_payment_amount, price, 18);
            require(payment_amount_ > 0, "NebulaStride::Quoter::EthAmountTooSmall");
            (uint256 nst_amount,,, uint256 avg_buy_price,,) = quoteFromUSDTtoNST(payment_amount_);
            uint256 avg_buy_price_eth = calcBaseAmountFromQuote(avg_buy_price, price, 18);
            return (nst_amount, avg_buy_price_eth);
        }
    }

    /* 
    * @dev Quote how many user paid USDT or ETH amount for certain NST
    */
    function quoteFromNST(bool to_usdt, uint nst_amount) public view returns (uint256, uint256) {
        require(nst_token_address != address(0), "NebulaStride::Presale::NotInitialized");
        require(nst_amount > 0, "NebulaStride::Quoter::InitialPaymentIsNull");
        require(presale_ended == false, "NebulaStride::Quoter::PresaleEnded");
        (uint256 usdt_amount, uint256 avg_buy_price) = quoteFromNSTtoUSDT(nst_amount);
        if (to_usdt) {

            return (usdt_amount, avg_buy_price);
        }
        else {
            uint256 price = getEthPrice();
            uint256 eth_amount = calcBaseAmountFromQuote(usdt_amount, price, 18);
            uint256 eth_buy_price = calcBaseAmountFromQuote(avg_buy_price, price, 18);
            return (eth_amount, eth_buy_price);
        }
    }

    /* 
    * @title Total amount for presale
    */
    function allForPresale() public view  returns (uint256) { 
        uint256 all_for_presale = initial_round_amount * end_round;
         return all_for_presale;
    }

    /*
    * @title Get remaining token amount for current round
    */
    function remainingForRound() public view  returns (uint256) { return current_round_amount; }

    /*
    * @title Get sold tokens amount
    */
    function allSoldTokens() public view  returns (uint256) { return all_sold_amount; }

    /*
    * @title Get current round.
    */
    function currentRound() public view  returns (uint256) { return current_round; }

    /*
    * @title Buy NST for ETH.
    * @notify All calculations are in USD. As exchange rate source used chainlink price feed
    */
    function buyForETH(uint256 eth_amount, uint256 nst_amount_with_slippage, uint256 valid_until) nonReentrant whenNotPaused public payable returns  (uint256)  { 
        require(nst_token_address != address(0), "NebulaStride::Presale::NotInitialized");
        require(!presale_ended, "NebulaStride::OrderProcessor::PresaleEnded");
        require(valid_until >= block.timestamp, "NebulaStride::OrderProcessor::TransactionTimeout");
        require(eth_amount > 0, "NebulaStride::OrderProcessor::ZeroBuy");
        require(msg.value == eth_amount, "NebulaStride::OrderProcessor::ValueMissmatch");
        uint256 price = getEthPrice();
        uint256 usdt_amount = calcQuoteAmountFromBase(eth_amount, price, 18);
        require(usdt_amount > 0, "NebulaStride::OrderProcessor::EthAmountTooSmall");
        (uint256 remaining_nst_amount, uint256 remaining_round_amount, uint256 remaining_round, , bool remaining_presale_ended, uint256[4][] memory parts) = quoteFromUSDTtoNST(usdt_amount);
        require(remaining_nst_amount >= nst_amount_with_slippage, "NebulaStride::OrderProcessor::SlippageTriggered");
        require(nst_token.balanceOf(address(this)) >= remaining_nst_amount, "NebulaStride::OrderProcessor::NotEnoughNstOnContract");

        
        for (uint256 part_idx = 0; part_idx < parts.length; part_idx ++) 
        {
            if (parts[part_idx][3] == 0) {
                break;
            }
            uint256 eth_equivalent = calcBaseAmountFromQuote(parts[part_idx][2], price, 18);
            emit AcquiredForOrder(
                msg.sender,
                parts[part_idx][1],
                parts[part_idx][2],
                eth_equivalent,
                price,
                parts[part_idx][3],
                parts[part_idx][0]
            );
        }

        current_round_amount = remaining_round_amount;
        emit CurrentRoundAmount(current_round_amount);
        if (remaining_round > current_round) {
            current_price = start_price + (round_step * (remaining_round - 1));
            current_round = remaining_round;
            emit IncreaseRound(remaining_round);
        }

        if (remaining_presale_ended == true) {
            presale_ended = remaining_presale_ended;
            emit PresaleEnded(true);
        }
        Address.sendValue(payable(payout_address), msg.value);
        nst_token.transfer(msg.sender, remaining_nst_amount);
        all_sold_amount += remaining_nst_amount;
        return remaining_nst_amount;
    }
    

    /*
    * @title Extract NST
    * @notice Extract NST to payout address. Its usable when presale ends and it has unspent tokens.
    */
    function _extractNST() private {
        nst_token.transfer(payout_address, nst_token.balanceOf(address(this)));
    }

    /*
    * @title Buy NST for USDT. 
    */
    function buyForUSDT(uint256 usdt_amount, uint256 nst_amount_with_slippage, uint256 valid_until) nonReentrant whenNotPaused public returns (uint256)  {
        require(nst_token_address != address(0), "NebulaStride::Presale::NotInitialized");
        require(!presale_ended, "NebulaStride::OrderProcessor::PresaleEnded");
        require(valid_until >= block.timestamp, "NebulaStride::OrderProcessor::TransactionTimeout");
        require(usdt_amount > 0, "NebulaStride::OrderProcessor::ZeroBuy");
        require(usdt_token.allowance(msg.sender, address(this)) >= usdt_amount, "NebulaStride::OrderProcessor::NotEnoughAllowance");
        require(usdt_token.balanceOf(msg.sender)>=usdt_amount, "NebulaStride::OrderProcessor::NotEnoughTokens");
        (uint256 remaining_nst_amount, uint256 remaining_round_amount, uint256 remaining_round, , bool remaining_presale_ended, uint256[4][] memory parts) = quoteFromUSDTtoNST(usdt_amount);
        require(remaining_nst_amount >= nst_amount_with_slippage, "NebulaStride::OrderProcessor::SlippageTriggered");
        require(nst_token.balanceOf(address(this)) >= remaining_nst_amount, "NebulaStride::OrderProcessor::NotEnoughNstOnContract");


        for (uint256 part_idx = 0; part_idx < parts.length; part_idx ++) 
        {
            if (parts[part_idx][3] == 0) {
                break;
            }
            emit AcquiredForOrder(
                msg.sender,
                parts[part_idx][1],
                parts[part_idx][2],
                parts[part_idx][1],
                1,
                parts[part_idx][3],
                parts[part_idx][0]
            );
        }

        current_round_amount = remaining_round_amount;
        emit CurrentRoundAmount(current_round_amount);
        if (remaining_round > current_round) {
            current_price = start_price + (round_step * (remaining_round - 1));
            current_round = remaining_round;
            emit IncreaseRound(remaining_round);
        }

        if (remaining_presale_ended == true) {
            presale_ended = remaining_presale_ended;
            emit PresaleEnded(true);
        }

        

        usdt_token.transferFrom(msg.sender, payout_address, usdt_amount);
        nst_token.transfer(msg.sender, remaining_nst_amount);
        all_sold_amount += remaining_nst_amount;
        return remaining_nst_amount;
    }


    /*
    * @title Schedule transfer ownership with timelock model
    * @dev This function “plans” the execution of the transfer of ownership mechanism.
    * User can only plan TransferOwnership OR RenounceOwnership at same time.
    */
    function scheduleTransferOwnership(address newOwner) public onlyOwner {
        require(allow_transfer_ownership_at == 0, "TransferOwnership already planned");
        require(newOwner != address(0), "potential owner can not be the zero address.");
        require(allow_renounce_ownership_at == 0, "RenounceOwnership already planned");
        require(IProxy(newOwner).masterCopy() != address(0), "New owner must be safe wallet");
        allow_transfer_ownership_at = block.timestamp + timelock_period;
        scheduled_new_owner = newOwner;
        emit ScheduleTransferOwnership(
            scheduled_new_owner,
            allow_transfer_ownership_at,
            false,
            false
        );
    }

    /*
    * @title Cancel schedule transfer ownership with timelock model
    * @dev This function cancels a scheduled task for ownership transfer 
    */
    function cancelTransferOwnership() public onlyOwner {
        require(allow_transfer_ownership_at > 0, "TransferOwnership not planned");
        emit ScheduleTransferOwnership(
            scheduled_new_owner,
            allow_transfer_ownership_at,
            true,
            false
        );
        allow_transfer_ownership_at=0;
        scheduled_new_owner = address(0);
    }

    /*
    * @title Execute schedule transfer ownership with timelock model
    * @dev This function execute a scheduled task for ownership transfer 
    */
    function executeTransferOwnership() public onlyOwner {
        require(allow_transfer_ownership_at > 0, "TransferOwnership not planned");
        require(allow_transfer_ownership_at <= block.timestamp, "TransferOwnership not unlocked");
        potential_owner = scheduled_new_owner;
        emit OwnerNominated(potential_owner);
        emit ScheduleTransferOwnership(
            scheduled_new_owner,
            allow_transfer_ownership_at,
            false,
            true
        );
        allow_transfer_ownership_at=0;
        scheduled_new_owner=address(0);
    }

    /*
    * @title Schedule renounce ownership with timelock model
    * @dev This function “plans” the execution of the renounce of ownership mechanism. 
    * User can only plan TransferOwnership OR RenounceOwnership at same time.
    */
    function scheduleRenounceOwnership() public onlyOwner {
        require(allow_renounce_ownership_at == 0, "RenounceOwnership already planned");
        require(allow_transfer_ownership_at == 0, "TransferOwnership already planned");

        allow_renounce_ownership_at = block.timestamp + timelock_period;
        emit ScheduleRenounceOwnership(
            allow_renounce_ownership_at,
            false,
            false
        );
    }


    /*
    * @title Cancel schedule renounce ownership with timelock model
    * @dev This function cancels a scheduled task for ownership renounce 
    */
    function cancelRenounceOwnership() public onlyOwner {
        require(allow_renounce_ownership_at > 0, "RenounceOwnership not planned");
        emit ScheduleRenounceOwnership(
            allow_renounce_ownership_at,
            true,
            false
        );
        allow_renounce_ownership_at=0;
    }

    /*
    * @title Execute schedule renounce ownership with timelock model
    * @dev This function execute a scheduled task for ownership renounce 
    */
    function executeRenounceOwnership() public onlyOwner {
        require(allow_renounce_ownership_at > 0, "RenounceOwnership not planned");
        require(allow_renounce_ownership_at <= block.timestamp, "RenounceOwnership not unlocked");
        _transferOwnership(address(0));
        emit ScheduleRenounceOwnership(
            allow_renounce_ownership_at,
            false,
            true
        );
        allow_renounce_ownership_at = 0;
        allow_transfer_ownership_at = 0;
        potential_owner = address(0);
        scheduled_new_owner = address(0);
    }

    /*
    * @title Pause contract
    */
    function pause() public onlyOwner {
        _pause();
    }

    /*
    * @title Un-pause contract
    */
    function unPause() public onlyOwner {
        _unpause();
    }

    /*
    * @title Schedule contract extractNST with timelock model
    * @dev This function “plans” the execution of the renounce of ownership mechanism 
    */
    function scheduleExtractNst() public onlyOwner {
        require(allow_extract_at == 0, "ExtractNst already planned");
        allow_extract_at = block.timestamp + timelock_period;
        emit ScheduleExtractNST(
            allow_extract_at,
            false,
            false
        );
    }


    /*
    * @title Cancel schedule contract un-pause with timelock model
    * @dev This function cancels a scheduled task for pause contract
    */
    function cancelExtractNst() public onlyOwner {
        require(allow_extract_at > 0, "ExtractNst not planned");
        emit ScheduleExtractNST(
            allow_extract_at,
            true,
            false
        );
        allow_extract_at=0;
    }

    /*
    * @title Execute schedule contract un-pause with timelock model
    * @dev This function execute a scheduled task for pause contract
    */
    function executeExtractNst() public onlyOwner {
        require(allow_extract_at > 0, "ExtractNst not planned");
        require(allow_extract_at <= block.timestamp, "ExtractNst not unlocked");
        _extractNST();
        emit ScheduleExtractNST(
            allow_extract_at,
            false,
            true
        );
        allow_extract_at = 0;
    }

    function getTimestamp() public view returns (uint256) {
        return block.timestamp;
    }

    function renounceOwnership() public override view onlyOwner{
        revert("RenounceOwnership only via timelock mechanism");
    }

    function transferOwnership(address newOwner) public override view onlyOwner {
        revert("TransferOwnership only via timelock mechanism");
    }

}