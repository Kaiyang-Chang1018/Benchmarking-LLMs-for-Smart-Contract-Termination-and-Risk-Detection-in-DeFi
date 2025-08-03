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
// OpenZeppelin Contracts (last updated v4.9.0) (interfaces/IERC2612.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/extensions/IERC20Permit.sol";

interface IERC2612 is IERC20Permit {}
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
// OpenZeppelin Contracts (last updated v4.9.4) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
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
     *
     * CAUTION: See Security Considerations above.
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
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

/**
 * @title Guardable
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (a guardian) that can be granted exclusive access to
 * specific functions.
 *
 * This module is essentially a renamed version of the OpenZeppelin Ownable contract.
 * The main difference is in terminology:
 * - 'owner' is renamed to 'guardian'
 * - 'ownership' concepts are renamed to 'watch' or 'guard'
 *
 * By default, the guardian account will be the one that deploys the contract. This
 * can later be changed with {transferWatch}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyGuardian`, which can be applied to your functions to restrict their use to
 * the guardian.
 */
abstract contract Guardable {
    address private _guardian;

    event WatchTransferred(address indexed previousGuardian, address indexed newGuardian);

    /**
     * @dev Initializes the contract setting the deployer as the initial guardian.
     */
    constructor() {
        _transferWatch(msg.sender);
    }

    /**
     * @dev Throws if called by any account other than the guardian.
     */
    modifier onlyGuardian() {
        _checkGuardian();
        _;
    }

    /**
     * @dev Returns the address of the current guardian.
     */
    function guardian() public view virtual returns (address) {
        return _guardian;
    }

    /**
     * @dev Throws if the sender is not the guardian.
     */
    function _checkGuardian() internal view virtual {
        require(guardian() == msg.sender, "Guardable: caller is not the guardian");
    }

    /**
     * @dev Leaves the contract without guardian. It will not be possible to call
     * `onlyGuardian` functions anymore. Can only be called by the current guardian.
     *
     * NOTE: Renouncing guardianship will leave the contract without a guardian,
     * thereby removing any functionality that is only available to the guardian.
     */
    function releaseGuard() public virtual onlyGuardian {
        _transferWatch(address(0));
    }

    /**
     * @dev Transfers guardianship of the contract to a new account (`newGuardian`).
     * Can only be called by the current guardian.
     */
    function transferWatch(address newGuardian) public virtual onlyGuardian {
        require(newGuardian != address(0), "Guardable: new guardian is the zero address");
        _transferWatch(newGuardian);
    }

    /**
     * @dev Transfers guardianship of the contract to a new account (`newGuardian`).
     * Internal function without access restriction.
     */
    function _transferWatch(address newGuardian) internal virtual {
        address oldGuardian = _guardian;
        _guardian = newGuardian;
        emit WatchTransferred(oldGuardian, newGuardian);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import "./BaseMath.sol";

/* Contains global system constants and common functions. */
contract Base is BaseMath {
    uint constant internal SECONDS_IN_ONE_MINUTE = 60;

    /*
     * Half-life of 12h. 12h = 720 min
     * (1/2) = d^720 => d = (1/2)^(1/720)
     */
    uint constant internal MINUTE_DECAY_FACTOR = 999037758833783000;

    /*
    * BETA: 18 digit decimal. Parameter by which to divide the redeemed fraction, in order to calc the new base rate from a redemption.
    * Corresponds to (1 / ALPHA) in the white paper.
    */
    uint constant internal BETA = 2;

    uint constant public _100pct = 1000000000000000000; // 1e18 == 100%

    // Min net debt remains a system global due to its rationale for keeping SortedPositions relatively small
    uint constant public MIN_NET_DEBT = 1800e18;

    uint constant internal PERCENT_DIVISOR = 200; // dividing by 200 yields 0.5%

    // Gas compensation is not configurable per collateral type, as this is
    // more-so a chain specific consideration rather than collateral specific
    uint constant public GAS_COMPENSATION = 200e18;

    // A dynamic fee, which kicks in and acts as a floor if the custom min fee % attached to a collateral instance is too low.
    uint constant public DYNAMIC_BORROWING_FEE_FLOOR = DECIMAL_PRECISION / 1000 * 5; // 0.5%
    uint constant public DYNAMIC_REDEMPTION_FEE_FLOOR = DECIMAL_PRECISION / 1000 * 5; // 0.5%

    address internal positionControllerAddress;
    address internal gasPoolAddress;

    // Return the amount of Collateral to be drawn from a position's collateral and sent as gas compensation.
    function _getCollGasCompensation(uint _entireColl) internal pure returns (uint) {
        return _entireColl / PERCENT_DIVISOR;
    }

    function _requireUserAcceptsFee(uint _fee, uint _amount, uint _maxFeePercentage) internal pure {
        uint feePercentage = (_fee * DECIMAL_PRECISION) / _amount;
        require(feePercentage <= _maxFeePercentage, "Fee exceeded");
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

contract BaseMath {
    uint constant public DECIMAL_PRECISION = 1e18;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

library StableMath {
    uint internal constant DECIMAL_PRECISION = 1e18;

    /* Precision for Nominal ICR (independent of price). Rationale for the value:
     *
     * - Making it “too high” could lead to overflows.
     * - Making it “too low” could lead to an ICR equal to zero, due to truncation from Solidity floor division. 
     *
     * This value of 1e20 is chosen for safety: the NICR will only overflow for numerator > ~1e39 ETH,
     * and will only truncate to 0 if the denominator is at least 1e20 times greater than the numerator.
     *
     */
    uint internal constant NICR_PRECISION = 1e20;

    function _min(uint _a, uint _b) internal pure returns (uint) {
        return (_a < _b) ? _a : _b;
    }

    function _max(uint _a, uint _b) internal pure returns (uint) {
        return (_a >= _b) ? _a : _b;
    }

    /* 
    * Multiply two decimal numbers and use normal rounding rules:
    * -round product up if 19'th mantissa digit >= 5
    * -round product down if 19'th mantissa digit < 5
    *
    * Used only inside the exponentiation, _decPow().
    */
    function decMul(uint x, uint y) internal pure returns (uint decProd) {
        uint prod_xy = x * y;
        decProd = (prod_xy + (DECIMAL_PRECISION / 2)) / DECIMAL_PRECISION;
    }

    /* 
    * _decPow: Exponentiation function for 18-digit decimal base, and integer exponent n.
    * 
    * Uses the efficient "exponentiation by squaring" algorithm. O(log(n)) complexity. 
    * 
    * Called by PositionManager._calcDecayedBaseRate
    *
    * The exponent is capped to avoid reverting due to overflow. The cap 525600000 equals
    * "minutes in 1000 years": 60 * 24 * 365 * 1000
    * 
    * If a period of > 1000 years is ever used as an exponent in either of the above functions, the result will be
    * negligibly different from just passing the cap, since: 
    *
    * In function 1), the decayed base rate will be 0 for 1000 years or > 1000 years
    * In function 2), the difference in tokens issued at 1000 years and any time > 1000 years, will be negligible
    */
    function _decPow(uint _base, uint _minutes) internal pure returns (uint) {
       
        if (_minutes > 525600000) {_minutes = 525600000;}  // cap to avoid overflow
    
        if (_minutes == 0) {return DECIMAL_PRECISION;}

        uint y = DECIMAL_PRECISION;
        uint x = _base;
        uint n = _minutes;

        // Exponentiation-by-squaring
        while (n > 1) {
            if (n % 2 == 0) {
                x = decMul(x, x);
                n = n / 2;
            } else { // if (n % 2 != 0)
                y = decMul(x, y);
                x = decMul(x, x);
                n = (n - 1) / 2;
            }
        }

        return decMul(x, y);
  }

    function _getAbsoluteDifference(uint _a, uint _b) internal pure returns (uint) {
        return (_a >= _b) ? _a - _b : _b - _a;
    }

    function _adjustDecimals(uint _val, uint8 _collDecimals) internal pure returns (uint) {
        if (_collDecimals < 18) {
            return _val * (10 ** (18 - _collDecimals));
        } else if (_collDecimals > 18) {
            // Assuming _collDecimals won't exceed 25, this should be safe from overflow.
            return _val / (10 ** (_collDecimals - 18));
        } else {
            return _val;
        }
    }

    function _computeNominalCR(uint _coll, uint _debt, uint8 _collDecimals) internal pure returns (uint) {
        if (_debt > 0) {
            _coll = _adjustDecimals(_coll, _collDecimals);
            return (_coll * NICR_PRECISION) / _debt;
        }
        // Return the maximal value for uint256 if the Position has a debt of 0. Represents "infinite" CR.
        else { // if (_debt == 0)
            return type(uint256).max;
        }
    }

    function _computeCR(uint _coll, uint _debt, uint _price, uint8 _collDecimals) internal pure returns (uint) {
        // Check for zero debt to avoid division by zero
        if (_debt == 0) {
            return type(uint256).max; // Infinite CR since there's no debt.
        }

        _coll = _adjustDecimals(_coll, _collDecimals);
        uint newCollRatio = (_coll * _price) / _debt;
        return newCollRatio;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../Guardable.sol";
import "../interfaces/IFeeToken.sol";
import "../interfaces/IFeeTokenMinter.sol";
import "../common/BaseMath.sol";
import "../common/StableMath.sol";

interface IBackstopPoolIncentives {
    event TotalFeeTokensIssuedUpdated(uint _totalFeeTokensIssued);

    function setAddresses(address _feeTokenAddress, address _backstopPoolAddress, address _feeTokenMinterAddress) external;
    function issueFeeTokens() external returns (uint);
    function sendFeeTokens(address _account, uint _feeTokenAmount) external;
}

/**
 * @title BackstopPoolIncentives
 * @dev Contract for managing the issuance and distribution of FeeTokens as incentives for the Backstop Pool.
 *
 * Key features:
 *      1. Token Issuance: Implements a decay curve for FeeToken issuance over time - 50% each year.
 *      2. Activation Mechanism: Allows for the activation of backstop rewards by the guardian, initially they are OFF.
 *      3. Re-staking Requirement: Requires users to restake after reward activation, so that rewards from previous deposits are not rewarded.
 *      4. Immutable Supply Schedule: Guaranteed reduction in supply over time, even if rewards are not activated. If rewards are not needed, they should converge to zero.
 */
contract BackstopPoolIncentives is IBackstopPoolIncentives, Ownable, BaseMath, Guardable {
    //==================================================================//
    //-------------------------- CONSTANTS -----------------------------//
    //==================================================================//

    /// @dev Number of seconds in one minute
    uint constant public SECONDS_IN_ONE_MINUTE = 60;

    /**
     * @dev The issuance factor F determines the curvature of the issuance curve.
     *
     * For 50% of remaining tokens issued each year, with minutes as time units, we have:
     * F ** 525600 = 0.5
     *
     * Re-arranging:
     * 525600 * ln(F) = ln(0.5)
     * F = 0.5 ** (1/525600)
     * F = 0.999998681227695000
     */
    uint constant public ISSUANCE_FACTOR = 999998681227695000;

    /// @dev Maximum tokens allocated for reward (200 million)
    uint constant public incentivesSupplyCap = 200_000_000e18;

    //==================================================================//
    //-------------------------- INTERFACES ----------------------------//
    //==================================================================//

    IFeeToken public feeToken;
    IFeeTokenMinter public feeTokenMinter;

    //==================================================================//
    //----------------------- STATE VARIABLES --------------------------//
    //==================================================================//

    /// @dev Address of the Backstop Pool contract
    address public backstopPoolAddress;

    /// @dev Total amount of FeeTokens issued as incentives up to this point
    uint public totalFeeTokensIssued;

    /// @dev Timestamp of contract deployment
    uint public immutable deploymentTime;

    /// @dev Flag indicating if backstop rewards are active
    bool public backstopRewardsActive;

    /// @dev Mapping to track if an account has restaked since reward activation
    mapping(address => bool) public restakedSinceActivation;

    //==================================================================//
    //------------------------- CONSTRUCTOR ----------------------------//
    //==================================================================//

    /**
     * @dev Constructor just sets the deployment time
     */
    constructor() {
        deploymentTime = block.timestamp;
    }

    //==================================================================//
    //----------------------- SETUP FUNCTIONS --------------------------//
    //==================================================================//

    /**
     * @dev Sets the addresses for the contract dependencies, and renounces ownership
     * @param _feeTokenAddress Address of the FeeToken contract
     * @param _backstopPoolAddress Address of the BackstopPool contract
     * @param _feeTokenMinterAddress Address of the FeeTokenMinter contract
     */
    function setAddresses(
        address _feeTokenAddress,
        address _backstopPoolAddress,
        address _feeTokenMinterAddress
    ) external onlyOwner override {
        require(_feeTokenAddress != address(0), "_feeTokenAddress is the null address");
        require(_backstopPoolAddress != address(0), "_backstopPoolAddress is the null address");
        require(_feeTokenMinterAddress != address(0), "_feeTokenMinterAddress is the null address");

        feeToken = IFeeToken(_feeTokenAddress);
        backstopPoolAddress = _backstopPoolAddress;
        feeTokenMinter = IFeeTokenMinter(_feeTokenMinterAddress);
        renounceOwnership();
    }

    /**
     * @dev Activates the backstop rewards.  Can only be called by the guardian.
     */
    function activateBackstopIncentives() external onlyGuardian {
        require(!backstopRewardsActive, "Backstop rewards are already being dispersed");
        backstopRewardsActive = true;
    }

    //==================================================================//
    //----------------- EXTERNAL MUTATIVE FUNCTIONS --------------------//
    //==================================================================//

    /**
     * @dev Issues FeeTokens based on the current issuance curve
     * @return The amount of FeeTokens issued
     */
    function issueFeeTokens() external override returns (uint) {
        _requireCallerIsBackstopPool();
        uint latestTotalFeeTokensIssued = (incentivesSupplyCap * _getCumulativeIssuanceFraction()) / DECIMAL_PRECISION;
        uint issuance = latestTotalFeeTokensIssued - totalFeeTokensIssued;
        totalFeeTokensIssued = latestTotalFeeTokensIssued;
        emit TotalFeeTokensIssuedUpdated(latestTotalFeeTokensIssued);
        return issuance;
    }

    /**
     * @dev Initiates a FeeToken vest for an account, if backstop rewards were activated, and the user restaked
     * @param _account The address of the account to receive FeeTokens
     * @param _feeTokenAmount The amount of FeeTokens to vest
     */
    function sendFeeTokens(address _account, uint _feeTokenAmount) external override {
        _requireCallerIsBackstopPool();
        if (backstopRewardsActive) {
            // Require the user to restake following reward activation,
            // otherwise historic rewards will be paid out instead of being orphaned as intended.
            if(restakedSinceActivation[_account]) {
                // They retouched their stake, and as a result orphaned their old rewards.
                // It's now safe to credit their rewards
                if(_feeTokenAmount > 0) {
                    feeTokenMinter.appendVestingEntry(_account, _feeTokenAmount);
                }
            } else {
                restakedSinceActivation[_account] = true;
            }
        }
    }

    //==================================================================//
    //---------------------- INTERNAL FUNCTIONS ------------------------//
    //==================================================================//

    /**
     * @dev Calculates the cumulative issuance fraction (1-f^t)
     * @return The cumulative issuance fraction
     */
    function _getCumulativeIssuanceFraction() internal view returns (uint) {
        // Get the time passed since deployment
        uint timePassedInMinutes = (block.timestamp - deploymentTime) / SECONDS_IN_ONE_MINUTE;

        // f^t
        uint power = StableMath._decPow(ISSUANCE_FACTOR, timePassedInMinutes);

        //  (1 - f^t)
        uint cumulativeIssuanceFraction = uint(DECIMAL_PRECISION) - power;
        assert(cumulativeIssuanceFraction <= DECIMAL_PRECISION); // must be in range [0,1]
        return cumulativeIssuanceFraction;
    }

    /**
     * @dev Ensures that the caller is the BackstopPool contract
     */
    function _requireCallerIsBackstopPool() internal view {
        require(msg.sender == backstopPoolAddress, "IncentivesIssuance: caller is not BP");
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import "./IPool.sol";
import "./ICanReceiveCollateral.sol";

/// @title IActivePool Interface
/// @notice Interface for the ActivePool contract which manages the main collateral pool
interface IActivePool is IPool, ICanReceiveCollateral {
    /// @notice Emitted when the stable debt in the ActivePool is updated
    /// @param _STABLEDebt The new total stable debt amount
    event ActivePoolStableDebtUpdated(uint _STABLEDebt);

    /// @notice Emitted when the collateral balance in the ActivePool is updated
    /// @param _Collateral The new total collateral amount
    event ActivePoolCollateralBalanceUpdated(uint _Collateral);

    /// @notice Sends collateral from the ActivePool to a specified account
    /// @param _account The address of the account to receive the collateral
    /// @param _amount The amount of collateral to send
    function sendCollateral(address _account, uint _amount) external;

    /// @notice Sets the addresses of connected contracts and components
    /// @param _positionControllerAddress Address of the PositionController contract
    /// @param _positionManagerAddress Address of the PositionManager contract
    /// @param _backstopPoolAddress Address of the BackstopPool contract
    /// @param _defaultPoolAddress Address of the DefaultPool contract
    /// @param _collateralAssetAddress Address of the collateral asset token
    function setAddresses(
        address _positionControllerAddress,
        address _positionManagerAddress,
        address _backstopPoolAddress,
        address _defaultPoolAddress,
        address _collateralAssetAddress
    ) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

/// @title IBackstopPool Interface
/// @notice Interface for the BackstopPool contract which manages deposits and collateral gains
interface IBackstopPool {
    /// @notice Struct to represent collateral gains for a specific asset
    struct CollateralGain {
        address asset;
        uint gains;
    }

    /// @notice Emitted when the collateral balance of the BackstopPool is updated
    /// @param asset The address of the collateral asset
    /// @param _newBalance The new balance of the collateral
    event BackstopPoolCollateralBalanceUpdated(address asset, uint _newBalance);

    /// @notice Emitted when the stable token balance of the BackstopPool is updated
    /// @param _newBalance The new balance of stable tokens
    event BackstopPoolStableBalanceUpdated(uint _newBalance);

    /// @notice Emitted when the product P is updated
    /// @param _P The new value of P
    event P_Updated(uint _P);

    /// @notice Emitted when the sum S is updated for a specific collateral asset
    /// @param collateralAsset The address of the collateral asset
    /// @param _S The new value of S
    /// @param _epoch The current epoch
    /// @param _scale The current scale
    event S_Updated(address collateralAsset, uint _S, uint128 _epoch, uint128 _scale);

    /// @notice Emitted when the sum G is updated
    /// @param _G The new value of G
    /// @param _epoch The current epoch
    /// @param _scale The current scale
    event G_Updated(uint _G, uint128 _epoch, uint128 _scale);

    /// @notice Emitted when the current epoch is updated
    /// @param _currentEpoch The new current epoch
    event EpochUpdated(uint128 _currentEpoch);

    /// @notice Emitted when the current scale is updated
    /// @param _currentScale The new current scale
    event ScaleUpdated(uint128 _currentScale);

    /// @notice Emitted when a depositor's snapshot is updated
    /// @param _depositor The address of the depositor
    /// @param _asset The address of the asset
    /// @param _P The current value of P
    /// @param _S The current value of S
    /// @param _G The current value of G
    event DepositSnapshotUpdated(address indexed _depositor, address indexed _asset, uint _P, uint _S, uint _G);

    /// @notice Emitted when a user's deposit amount changes
    /// @param _depositor The address of the depositor
    /// @param _newDeposit The new deposit amount
    event UserDepositChanged(address indexed _depositor, uint _newDeposit);

    /// @notice Emitted when collateral gains are withdrawn
    /// @param _depositor The address of the depositor
    /// @param gains An array of CollateralGain structs representing the gains
    /// @param _stableLoss The amount of stable tokens lost
    event CollateralGainsWithdrawn(address indexed _depositor, IBackstopPool.CollateralGain[] gains, uint _stableLoss);

    /// @notice Emitted when collateral is sent to an address
    /// @param asset The address of the collateral asset
    /// @param _to The recipient address
    /// @param _amount The amount of collateral sent
    event CollateralSent(address indexed asset, address indexed _to, uint _amount);

    /// @notice Emitted when fee tokens are paid to a depositor
    /// @param _depositor The address of the depositor
    /// @param _feeToken The amount of fee tokens paid
    event FeeTokenPaidToDepositor(address indexed _depositor, uint _feeToken);

    /// @notice Sets the addresses of connected contracts
    /// @param _collateralController The address of the CollateralController contract
    /// @param _stableTokenAddress The address of the StableToken contract
    /// @param _positionController The address of the PositionController contract
    /// @param _incentivesIssuance The address of the IncentivesIssuance contract
    function setAddresses(address _collateralController, address _stableTokenAddress, address _positionController, address _incentivesIssuance) external;

    /// @notice Allows a user to provide stable tokens to the BackstopPool
    /// @param _amount The amount of stable tokens to provide
    function provideToBP(uint _amount) external;

    /// @notice Allows a user to withdraw stable tokens from the BackstopPool
    /// @param _amount The amount of stable tokens to withdraw
    function withdrawFromBP(uint _amount) external;

    /// @notice Allows a user to withdraw collateral gains to their position
    /// @param asset The address of the collateral asset
    /// @param version The version of the collateral
    /// @param _upperHint The upper hint for position insertion
    /// @param _lowerHint The lower hint for position insertion
    function withdrawCollateralGainToPosition(address asset, uint8 version, address _upperHint, address _lowerHint) external;

    /// @notice Offsets debt with collateral
    /// @param collateralAsset The address of the collateral asset
    /// @param version The version of the collateral
    /// @param _debt The amount of debt to offset
    /// @param _coll The amount of collateral to add
    function offset(address collateralAsset, uint8 version, uint _debt, uint _coll) external;

    /// @notice Gets the total amount of a specific collateral in the BackstopPool
    /// @param asset The address of the collateral asset
    /// @return The amount of collateral
    function getCollateral(address asset) external view returns (uint);

    /// @notice Gets the total amount of stable token deposits in the BackstopPool
    /// @return The total amount of stable token deposits
    function getTotalStableDeposits() external view returns (uint);

    /// @notice Gets the collateral gains for a depositor
    /// @param _depositor The address of the depositor
    /// @return An array of CollateralGain structs representing the gains
    function getDepositorCollateralGains(address _depositor) external view returns (IBackstopPool.CollateralGain[] memory);

    /// @notice Gets the collateral gain for a specific asset and depositor
    /// @param asset The address of the collateral asset
    /// @param _depositor The address of the depositor
    /// @return The amount of collateral gain
    function getDepositorCollateralGain(address asset, address _depositor) external view returns (uint);

    /// @notice Gets the compounded stable deposit for a depositor
    /// @param _depositor The address of the depositor
    /// @return The compounded stable deposit amount
    function getCompoundedStableDeposit(address _depositor) external view returns (uint);

    /// @notice Gets the sum S for a specific asset, epoch, and scale
    /// @param asset The address of the collateral asset
    /// @param epoch The epoch number
    /// @param scale The scale number
    /// @return The sum S
    function getEpochToScaleToSum(address asset, uint128 epoch, uint128 scale) external view returns(uint);

    /// @notice Gets the fee token gain for a depositor
    /// @param _depositor The address of the depositor
    /// @return The amount of fee token gain
    function getDepositorFeeTokenGain(address _depositor) external view returns (uint);

    /// @notice Gets the sum S from the deposit snapshot for a specific user and asset
    /// @param user The address of the user
    /// @param asset The address of the asset
    /// @return The sum S from the deposit snapshot
    function getDepositSnapshotToAssetToSum(address user, address asset) external view returns(uint);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

// Common interface for the contracts which need internal collateral counters to be updated.
interface ICanReceiveCollateral {
    function receiveCollateral(address asset, uint amount) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "./IActivePool.sol";
import "./ICollateralSurplusPool.sol";
import "./IDefaultPool.sol";
import "./IPriceFeed.sol";
import "./ISortedPositions.sol";
import "./IPositionManager.sol";

/// @title ICollateralController Interface
/// @notice Interface for the CollateralController contract which manages multiple collateral types and their settings
interface ICollateralController {
    /// @notice Emitted when the redemption cooldown requirement is changed
    /// @param newRedemptionCooldownRequirement The new cooldown period for redemptions
    event RedemptionCooldownRequirementChanged(uint newRedemptionCooldownRequirement);

    /// @notice Gets the address of the guardian
    /// @return The address of the guardian
    function getGuardian() external view returns (address);

    /// @notice Structure to hold redemption settings for a collateral type
    struct RedemptionSettings {
        uint256 redemptionCooldownPeriod;
        uint256 redemptionGracePeriod;
        uint256 maxRedemptionPoints;
        uint256 availableRedemptionPoints;
        uint256 redemptionRegenerationRate;
        uint256 lastRedemptionRegenerationTimestamp;
    }

    /// @notice Structure to hold loan settings for a collateral type
    struct LoanSettings {
        uint256 loanCooldownPeriod;
        uint256 loanGracePeriod;
        uint256 maxLoanPoints;
        uint256 availableLoanPoints;
        uint256 loanRegenerationRate;
        uint256 lastLoanRegenerationTimestamp;
    }

    /// @notice Enum to represent the base rate type
    enum BaseRateType {
        Global,
        Local
    }

    /// @notice Structure to hold fee settings for a collateral type
    struct FeeSettings {
        uint256 redemptionsTimeoutFeePct;
        uint256 maxRedemptionsFeePct;
        uint256 minRedemptionsFeePct;
        uint256 minBorrowingFeePct;
        uint256 maxBorrowingFeePct;
        BaseRateType baseRateType;
    }

    /// @notice Structure to hold all settings for a collateral type
    struct Settings {
        uint256 debtCap;
        uint256 decommissionedOn;
        uint256 MCR;
        uint256 CCR;
        RedemptionSettings redemptionSettings;
        LoanSettings loanSettings;
        FeeSettings feeSettings;
    }

    /// @notice Structure to represent a collateral type and its associated contracts
    struct Collateral {
        uint8 version;
        IActivePool activePool;
        ICollateralSurplusPool collateralSurplusPool;
        IDefaultPool defaultPool;
        IERC20Metadata asset;
        IPriceFeed priceFeed;
        ISortedPositions sortedPositions;
        IPositionManager positionManager;
        bool sunset;
    }

    /// @notice Structure to represent a collateral type with its settings and associated contracts
    struct CollateralWithSettings {
        string name;
        string symbol;
        uint8 decimals;
        uint8 version;
        Settings settings;
        IActivePool activePool;
        ICollateralSurplusPool collateralSurplusPool;
        IDefaultPool defaultPool;
        IERC20Metadata asset;
        IPriceFeed priceFeed;
        ISortedPositions sortedPositions;
        IPositionManager positionManager;
        bool sunset;
        uint256 availableRedemptionPoints;
        uint256 availableLoanPoints;
    }

    /// @notice Adds support for a new collateral type
    /// @param collateralAddress Address of the collateral token
    /// @param positionManagerAddress Address of the PositionManager contract
    /// @param sortedPositionsAddress Address of the SortedPositions contract
    /// @param activePoolAddress Address of the ActivePool contract
    /// @param priceFeedAddress Address of the PriceFeed contract
    /// @param defaultPoolAddress Address of the DefaultPool contract
    /// @param collateralSurplusPoolAddress Address of the CollateralSurplusPool contract
    function supportCollateral(
        address collateralAddress,
        address positionManagerAddress,
        address sortedPositionsAddress,
        address activePoolAddress,
        address priceFeedAddress,
        address defaultPoolAddress,
        address collateralSurplusPoolAddress
    ) external;

    /// @notice Gets all active collateral types
    /// @return An array of Collateral structs representing active collateral types
    function getActiveCollaterals() external view returns (Collateral[] memory);

    /// @notice Gets the unique addresses of all active collateral tokens
    /// @return An array of addresses representing active collateral token addresses
    function getUniqueActiveCollateralAddresses() external view returns (address[] memory);

    /// @notice Gets the debt cap for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return debtCap The debt cap for the specified collateral type
    function getDebtCap(address asset, uint8 version) external view returns (uint debtCap);

    /// @notice Gets the Critical Collateral Ratio (CCR) for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return The CCR for the specified collateral type
    function getCCR(address asset, uint8 version) external view returns (uint);

    /// @notice Gets the Minimum Collateral Ratio (MCR) for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return The MCR for the specified collateral type
    function getMCR(address asset, uint8 version) external view returns (uint);

    /// @notice Gets the minimum borrowing fee percentage for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return The minimum borrowing fee percentage for the specified collateral type
    function getMinBorrowingFeePct(address asset, uint8 version) external view returns (uint);

    /// @notice Gets the maximum borrowing fee percentage for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return The maximum borrowing fee percentage for the specified collateral type
    function getMaxBorrowingFeePct(address asset, uint8 version) external view returns (uint);

    /// @notice Gets the minimum redemption fee percentage for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return The minimum redemption fee percentage for the specified collateral type
    function getMinRedemptionsFeePct(address asset, uint8 version) external view returns (uint);

    /// @notice Requires that the commissioning period has passed for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    function requireAfterCommissioningPeriod(address asset, uint8 version) external view;

    /// @notice Requires that a specific collateral type is active
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    function requireIsActive(address asset, uint8 version) external view;

    /// @notice Gets the Collateral struct for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return A Collateral struct representing the specified collateral type
    function getCollateralInstance(address asset, uint8 version) external view returns (ICollateralController.Collateral memory);

    /// @notice Gets the Settings struct for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return A Settings struct representing the settings for the specified collateral type
    function getSettings(address asset, uint8 version) external view returns (ICollateralController.Settings memory);

    /// @notice Gets the total collateral amount for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return assetColl The total collateral amount for the specified collateral type
    function getAssetColl(address asset, uint8 version) external view returns (uint assetColl);

    /// @notice Gets the total debt amount for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return assetDebt The total debt amount for the specified collateral type
    function getAssetDebt(address asset, uint8 version) external view returns (uint assetDebt);

    /// @notice Gets the version of a specific PositionManager
    /// @param positionManager Address of the PositionManager contract
    /// @return version The version of the specified PositionManager
    function getVersion(address positionManager) external view returns (uint8 version);

    /// @notice Checks if a specific collateral type is in Recovery Mode
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @param price Current price of the collateral
    /// @return A boolean indicating whether the collateral type is in Recovery Mode
    function checkRecoveryMode(address asset, uint8 version, uint price) external returns (bool);

    /// @notice Requires that there are no undercollateralized positions across all collateral types
    function requireNoUnderCollateralizedPositions() external;

    /// @notice Checks if a given address is a valid PositionManager
    /// @param positionManager Address to check
    /// @return A boolean indicating whether the address is a valid PositionManager
    function validPositionManager(address positionManager) external view returns (bool);

    /// @notice Checks if a specific collateral type is decommissioned
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return A boolean indicating whether the collateral type is decommissioned
    function isDecommissioned(address asset, uint8 version) external view returns (bool);

    /// @notice Checks if a specific PositionManager is decommissioned and its sunset period has elapsed
    /// @param pm Address of the PositionManager
    /// @param collateral Address of the collateral token
    /// @return A boolean indicating whether the PositionManager is decommissioned and its sunset period has elapsed
    function decommissionedAndSunsetPositionManager(address pm, address collateral) external view returns (bool);

    /// @notice Gets the base rate type (Global or Local)
    /// @return The base rate type
    function getBaseRateType() external view returns (BaseRateType);

    /// @notice Gets the timestamp of the last fee operation
    /// @return The timestamp of the last fee operation
    function getLastFeeOperationTime() external view returns (uint);

    /// @notice Gets the current base rate
    /// @return The current base rate
    function getBaseRate() external view returns (uint);

    /// @notice Decays the base rate from borrowing
    function decayBaseRateFromBorrowing() external;

    /// @notice Updates the timestamp of the last fee operation
    function updateLastFeeOpTime() external;

    /// @notice Calculates the number of minutes passed since the last fee operation
    /// @return The number of minutes passed since the last fee operation
    function minutesPassedSinceLastFeeOp() external view returns (uint);

    /// @notice Calculates the decayed base rate
    /// @return The decayed base rate
    function calcDecayedBaseRate() external view returns (uint);

    /// @notice Updates the base rate from redemption
    /// @param _CollateralDrawn Amount of collateral drawn
    /// @param _price Current price of the collateral
    /// @param _totalStableSupply Total supply of stable tokens
    /// @return The updated base rate
    function updateBaseRateFromRedemption(uint _CollateralDrawn, uint _price, uint _totalStableSupply) external returns (uint);

    /// @notice Regenerates and consumes redemption points
    /// @param amount Amount of redemption points to consume
    /// @return utilizationPCT The utilization percentage after consumption
    /// @return loadIncrease The increase in load after consumption
    function regenerateAndConsumeRedemptionPoints(uint amount) external returns (uint utilizationPCT, uint loadIncrease);

    /// @notice Gets the redemption cooldown requirement for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return escrowDuration The duration of the escrow period
    /// @return gracePeriod The grace period for redemptions
    /// @return redemptionsTimeoutFeePct The fee percentage for redemption timeouts
    function getRedemptionCooldownRequirement(address asset, uint8 version) external returns (uint escrowDuration,uint gracePeriod,uint redemptionsTimeoutFeePct);

    /// @notice Calculates the redemption points at a specific timestamp for a collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @param targetTimestamp The timestamp to calculate the redemption points for
    /// @return workingRedemptionPoints The redemption points at the specified timestamp
    function redemptionPointsAt(address asset, uint8 version, uint targetTimestamp) external view returns (uint workingRedemptionPoints);

    /// @notice Regenerates and consumes loan points
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @param amount Amount of loan points to consume
    /// @return utilizationPCT The utilization percentage after consumption
    /// @return loadIncrease The increase in load after consumption
    function regenerateAndConsumeLoanPoints(address asset, uint8 version, uint amount) external returns (uint utilizationPCT, uint loadIncrease);

    /// @notice Gets the loan cooldown requirement for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return escrowDuration The duration of the escrow period
    /// @return gracePeriod The grace period for loans
    function getLoanCooldownRequirement(address asset, uint8 version) external view returns (uint escrowDuration, uint gracePeriod);

    /// @notice Calculates the loan points at a specific timestamp for a collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @param targetTimestamp The timestamp to calculate the loan points for
    /// @return workingLoanPoints The loan points at the specified timestamp
    function loanPointsAt(address asset, uint8 version, uint targetTimestamp) external view returns (uint workingLoanPoints);

    /// @notice Calculates the borrowing rate for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param baseRate The base rate to use in the calculation
    /// @param suggestedAdditiveFeePCT The suggested additive fee percentage
    /// @return The calculated borrowing rate
    function calcBorrowingRate(address asset, uint baseRate, uint suggestedAdditiveFeePCT) external view returns (uint);

    /// @notice Calculates the redemption rate for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param baseRate The base rate to use in the calculation
    /// @param suggestedAdditiveFeePCT The suggested additive fee percentage
    /// @return The calculated redemption rate
    function calcRedemptionRate(address asset, uint baseRate, uint suggestedAdditiveFeePCT) external view returns (uint);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import "./ICanReceiveCollateral.sol";

/// @title ICollateralSurplusPool Interface
/// @notice Interface for the CollateralSurplusPool contract which manages surplus collateral
interface ICollateralSurplusPool is ICanReceiveCollateral {
    /// @notice Emitted when a user's collateral balance is updated
    /// @param _account The address of the account
    /// @param _newBalance The new balance of the account
    event CollBalanceUpdated(address indexed _account, uint _newBalance);

    /// @notice Emitted when collateral is sent to an account
    /// @param _to The address receiving the collateral
    /// @param _amount The amount of collateral sent
    event CollateralSent(address _to, uint _amount);

    /// @notice Sets the addresses of connected contracts
    /// @param _positionControllerAddress Address of the PositionController contract
    /// @param _positionManagerAddress Address of the PositionManager contract
    /// @param _activePoolAddress Address of the ActivePool contract
    /// @param _collateralAssetAddress Address of the collateral asset token
    function setAddresses(address _positionControllerAddress, address _positionManagerAddress, address _activePoolAddress, address _collateralAssetAddress) external;

    /// @notice Gets the total amount of collateral in the pool
    /// @return The total amount of collateral
    function getCollateral() external view returns (uint);

    /// @notice Gets the amount of claimable collateral for a specific account
    /// @param _account The address of the account
    /// @return The amount of claimable collateral for the account
    function getUserCollateral(address _account) external view returns (uint);

    /// @notice Accounts for surplus collateral for a specific account
    /// @param _account The address of the account
    /// @param _amount The amount of surplus collateral to account for
    function accountSurplus(address _account, uint _amount) external;

    /// @notice Allows an account to claim their surplus collateral
    /// @param _account The address of the account claiming the collateral
    function claimColl(address _account) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import "./IPool.sol";
import "./ICanReceiveCollateral.sol";

/// @title IDefaultPool Interface
/// @notice Interface for the DefaultPool contract which manages defaulted debt and collateral
interface IDefaultPool is IPool, ICanReceiveCollateral {
    /// @notice Emitted when the STABLE debt in the DefaultPool is updated
    /// @param _STABLEDebt The new total STABLE debt amount
    event DefaultPoolSTABLEDebtUpdated(uint _STABLEDebt);

    /// @notice Emitted when the collateral balance in the DefaultPool is updated
    /// @param _Collateral The new total collateral amount
    event DefaultPoolCollateralBalanceUpdated(uint _Collateral);

    /// @notice Sends collateral from the DefaultPool to the ActivePool
    /// @param _amount The amount of collateral to send
    function sendCollateralToActivePool(uint _amount) external;

    /// @notice Sets the addresses of connected contracts
    /// @param _positionManagerAddress Address of the PositionManager contract
    /// @param _activePoolAddress Address of the ActivePool contract
    /// @param _collateralAssetAddress Address of the collateral asset token
    function setAddresses(address _positionManagerAddress, address _activePoolAddress, address _collateralAssetAddress) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC2612.sol";

interface IFeeToken is IERC20 {
    /**
     * @dev Sends tokens directly to the Fee Staking contract
     * @param _sender The address of the token sender
     * @param _amount The amount of tokens to send
     */
    function sendToFeeStaking(address _sender, uint _amount) external;

    /**
     * @dev Mints new tokens
     * @param account The address that will receive the minted tokens
     * @param amount The amount of tokens to mint
     */
    function mint(address account, uint amount) external;

    /**
     * @dev Burns tokens
     * @param amount The amount of tokens to burn
     */
    function burn(uint amount) external;

    /**
     * @dev Returns the supply of the token which is mintable via the Minter
     * @return The base supply amount
     */
    function minterSupply() external view returns (uint);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

/**
 * @title IFeeTokenMinter
 * @dev Interface for the FeeTokenMinter contract, responsible for managing vesting entries on behalf of other system components
 */
interface IFeeTokenMinter {
    /**
     * @dev Appends a new vesting entry for an account
     * @param account The address of the account to receive the vested tokens
     * @param quantity The amount of tokens to be vested
     */
    function appendVestingEntry(address account, uint256 quantity) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

/// @title IPool Interface
/// @notice Interface for Pool contracts that manage collateral and stable debt
interface IPool {
    /// @notice Emitted when collateral is sent from the pool
    /// @param _to The address receiving the collateral
    /// @param _amount The amount of collateral sent
    event CollateralSent(address _to, uint _amount);

    /// @notice Gets the total amount of collateral in the pool
    /// @return The total amount of collateral
    function getCollateral() external view returns (uint);

    /// @notice Gets the total amount of stable debt in the pool
    /// @return The total amount of stable debt
    function getStableDebt() external view returns (uint);

    /// @notice Increases the stable debt in the pool
    /// @param _amount The amount to increase the debt by
    function increaseStableDebt(uint _amount) external;

    /// @notice Decreases the stable debt in the pool
    /// @param _amount The amount to decrease the debt by
    function decreaseStableDebt(uint _amount) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

/// @title IPositionController Interface
/// @notice Interface for the PositionController contract which manages user positions
interface IPositionController {
    /// @notice Emitted when a new position is created
    /// @param asset The address of the collateral asset
    /// @param version The version of the collateral
    /// @param _borrower The address of the position owner
    /// @param arrayIndex The index of the position in the positions array
    event PositionCreated(address indexed asset, uint8 indexed version, address indexed _borrower, uint arrayIndex);

    /// @notice Emitted when a position is updated
    /// @param asset The address of the collateral asset
    /// @param version The version of the collateral
    /// @param _borrower The address of the position owner
    /// @param _debt The new debt amount of the position
    /// @param _coll The new collateral amount of the position
    /// @param stake The new stake amount of the position
    /// @param operation The type of operation performed (e.g., open, close, adjust)
    event PositionUpdated(address indexed asset, uint8 indexed version, address indexed _borrower, uint _debt, uint _coll, uint stake, uint8 operation);

    /// @notice Emitted when a borrowing fee is paid
    /// @param asset The address of the collateral asset
    /// @param version The version of the collateral
    /// @param _borrower The address of the position owner
    /// @param _stableFee The amount of fee paid in stable tokens
    event StableBorrowingFeePaid(address indexed asset, uint8 indexed version, address indexed _borrower, uint _stableFee);

    /// @notice Sets the addresses of connected contracts
    /// @param _collateralController Address of the CollateralController contract
    /// @param _backstopPoolAddress Address of the BackstopPool contract
    /// @param _gasPoolAddress Address of the GasPool contract
    /// @param _stableTokenAddress Address of the StableToken contract
    /// @param _feeTokenStakingAddress Address of the FeeTokenStaking contract
    function setAddresses(
        address _collateralController,
        address _backstopPoolAddress,
        address _gasPoolAddress,
        address _stableTokenAddress,
        address _feeTokenStakingAddress
    ) external;

    /// @notice Opens a new position
    /// @param asset The address of the collateral asset
    /// @param version The version of the collateral
    /// @param suppliedCollateral The amount of collateral supplied
    /// @param _maxFee The maximum fee percentage the user is willing to pay
    /// @param _stableAmount The amount of stable tokens to borrow
    /// @param _upperHint The address hint for position insertion (upper bound)
    /// @param _lowerHint The address hint for position insertion (lower bound)
    function openPosition(address asset, uint8 version, uint suppliedCollateral, uint _maxFee, uint _stableAmount,
        address _upperHint, address _lowerHint) external;

    /// @notice Adds collateral to an existing position
    /// @param asset The address of the collateral asset
    /// @param version The version of the collateral
    /// @param _collAddition The amount of collateral to add
    /// @param _upperHint The address hint for position insertion (upper bound)
    /// @param _lowerHint The address hint for position insertion (lower bound)
    function addColl(address asset, uint8 version, uint _collAddition, address _upperHint, address _lowerHint) external;

    /// @notice Moves collateral gain to a position (called by BackstopPool)
    /// @param asset The address of the collateral asset
    /// @param version The version of the collateral
    /// @param _collAddition The amount of collateral to add
    /// @param _user The address of the position owner
    /// @param _upperHint The address hint for position insertion (upper bound)
    /// @param _lowerHint The address hint for position insertion (lower bound)
    function moveCollateralGainToPosition(address asset, uint8 version, uint _collAddition, address _user,
        address _upperHint, address _lowerHint) external;

    /// @notice Withdraws collateral from a position
    /// @param asset The address of the collateral asset
    /// @param version The version of the collateral
    /// @param _amount The amount of collateral to withdraw
    /// @param _upperHint The address hint for position insertion (upper bound)
    /// @param _lowerHint The address hint for position insertion (lower bound)
    function withdrawColl(address asset, uint8 version, uint _amount, address _upperHint, address _lowerHint) external;

    /// @notice Withdraws stable tokens from a position
    /// @param asset The address of the collateral asset
    /// @param version The version of the collateral
    /// @param _maxFee The maximum fee percentage the user is willing to pay
    /// @param _amount The amount of stable tokens to withdraw
    /// @param _upperHint The address hint for position insertion (upper bound)
    /// @param _lowerHint The address hint for position insertion (lower bound)
    function withdrawStable(address asset, uint8 version, uint _maxFee, uint _amount,
        address _upperHint, address _lowerHint) external;

    /// @notice Repays stable tokens to a position
    /// @param asset The address of the collateral asset
    /// @param version The version of the collateral
    /// @param _amount The amount of stable tokens to repay
    /// @param _upperHint The address hint for position insertion (upper bound)
    /// @param _lowerHint The address hint for position insertion (lower bound)
    function repayStable(address asset, uint8 version, uint _amount, address _upperHint, address _lowerHint) external;

    /// @notice Closes a position
    /// @param asset The address of the collateral asset
    /// @param version The version of the collateral
    function closePosition(address asset, uint8 version) external;

    /// @notice Adjusts a position's collateral and debt
    /// @param asset The address of the collateral asset
    /// @param version The version of the collateral
    /// @param _collAddition The amount of collateral to add
    /// @param _maxFee The maximum fee percentage the user is willing to pay
    /// @param _collWithdrawal The amount of collateral to withdraw
    /// @param _debtChange The amount of debt to change
    /// @param isDebtIncrease True if the debt is increasing, false if decreasing
    /// @param _upperHint The address hint for position insertion (upper bound)
    /// @param _lowerHint The address hint for position insertion (lower bound)
    function adjustPosition(address asset, uint8 version, uint _collAddition, uint _maxFee,
        uint _collWithdrawal, uint _debtChange, bool isDebtIncrease, address _upperHint, address _lowerHint) external;

    /// @notice Claims any remaining collateral after position closure
    /// @param asset The address of the collateral asset
    /// @param version The version of the collateral
    function claimCollateral(address asset, uint8 version) external;

    /// @notice Calculates the composite debt (debt + gas compensation)
    /// @param _debt The base debt amount
    /// @return The composite debt amount
    function getCompositeDebt(uint _debt) external view returns (uint);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

/// @title IPositionManager Interface
/// @notice Interface for the PositionManager contract which manages individual positions
interface IPositionManager {
    /// @notice Emitted when a redemption occurs
    /// @param _attemptedStableAmount The amount of stable tokens attempted to redeem
    /// @param _actualStableAmount The actual amount of stable tokens redeemed
    /// @param _CollateralSent The amount of collateral sent to the redeemer
    /// @param _CollateralFee The fee paid in collateral for the redemption
    event Redemption(uint _attemptedStableAmount, uint _actualStableAmount, uint _CollateralSent, uint _CollateralFee);

    /// @notice Emitted when total stakes are updated
    /// @param _newTotalStakes The new total stakes value
    event TotalStakesUpdated(uint _newTotalStakes);

    /// @notice Emitted when system snapshots are updated
    /// @param _totalStakesSnapshot The new total stakes snapshot
    /// @param _totalCollateralSnapshot The new total collateral snapshot
    event SystemSnapshotsUpdated(uint _totalStakesSnapshot, uint _totalCollateralSnapshot);

    /// @notice Emitted when L terms are updated
    /// @param _L_Collateral The new L_Collateral value
    /// @param _L_STABLE The new L_STABLE value
    event LTermsUpdated(uint _L_Collateral, uint _L_STABLE);

    /// @notice Emitted when position snapshots are updated
    /// @param _L_Collateral The new L_Collateral value for the position
    /// @param _L_STABLEDebt The new L_STABLEDebt value for the position
    event PositionSnapshotsUpdated(uint _L_Collateral, uint _L_STABLEDebt);

    /// @notice Emitted when a position's index is updated
    /// @param _borrower The address of the position owner
    /// @param _newIndex The new index value
    event PositionIndexUpdated(address _borrower, uint _newIndex);

    /// @notice Get the total count of position owners
    /// @return The number of position owners
    function getPositionOwnersCount() external view returns (uint);

    /// @notice Get a position owner's address by index
    /// @param _index The index in the position owners array
    /// @return The address of the position owner
    function getPositionFromPositionOwnersArray(uint _index) external view returns (address);

    /// @notice Get the nominal ICR (Individual Collateral Ratio) of a position
    /// @param _borrower The address of the position owner
    /// @return The nominal ICR of the position
    function getNominalICR(address _borrower) external view returns (uint);

    /// @notice Get the current ICR of a position
    /// @param _borrower The address of the position owner
    /// @param _price The current price of the collateral
    /// @return The current ICR of the position
    function getCurrentICR(address _borrower, uint _price) external view returns (uint);

    /// @notice Liquidate a single position
    /// @param _borrower The address of the position owner to liquidate
    function liquidate(address _borrower) external;

    /// @notice Liquidate multiple positions
    /// @param _n The number of positions to attempt to liquidate
    function liquidatePositions(uint _n) external;

    /// @notice Batch liquidate a specific set of positions
    /// @param _positionArray An array of position owner addresses to liquidate
    function batchLiquidatePositions(address[] calldata _positionArray) external;

    /// @notice Queue a redemption request
    /// @param _stableAmount The amount of stable tokens to queue for redemption
    function queueRedemption(uint _stableAmount) external;

    /// @notice Redeem collateral for stable tokens
    /// @param _stableAmount The amount of stable tokens to redeem
    /// @param _firstRedemptionHint The address of the first position to consider for redemption
    /// @param _upperPartialRedemptionHint The address of the position just above the partial redemption
    /// @param _lowerPartialRedemptionHint The address of the position just below the partial redemption
    /// @param _partialRedemptionHintNICR The nominal ICR of the partial redemption hint
    /// @param _maxIterations The maximum number of iterations to perform in the redemption algorithm
    /// @param _maxFee The maximum acceptable fee percentage for the redemption
    function redeemCollateral(
        uint _stableAmount,
        address _firstRedemptionHint,
        address _upperPartialRedemptionHint,
        address _lowerPartialRedemptionHint,
        uint _partialRedemptionHintNICR,
        uint _maxIterations,
        uint _maxFee
    ) external;

    /// @notice Update the stake and total stakes for a position
    /// @param _borrower The address of the position owner
    /// @return The new stake value
    function updateStakeAndTotalStakes(address _borrower) external returns (uint);

    /// @notice Update the reward snapshots for a position
    /// @param _borrower The address of the position owner
    function updatePositionRewardSnapshots(address _borrower) external;

    /// @notice Add a position owner to the array of position owners
    /// @param _borrower The address of the position owner
    /// @return index The index of the new position owner in the array
    function addPositionOwnerToArray(address _borrower) external returns (uint index);

    /// @notice Apply pending rewards to a position
    /// @param _borrower The address of the position owner
    function applyPendingRewards(address _borrower) external;

    /// @notice Get the pending collateral reward for a position
    /// @param _borrower The address of the position owner
    /// @return The amount of pending collateral reward
    function getPendingCollateralReward(address _borrower) external view returns (uint);

    /// @notice Get the pending stable debt reward for a position
    /// @param _borrower The address of the position owner
    /// @return The amount of pending stable debt reward
    function getPendingStableDebtReward(address _borrower) external view returns (uint);

    /// @notice Check if a position has pending rewards
    /// @param _borrower The address of the position owner
    /// @return True if the position has pending rewards, false otherwise
    function hasPendingRewards(address _borrower) external view returns (bool);

    /// @notice Get the entire debt and collateral for a position, including pending rewards
    /// @param _borrower The address of the position owner
    /// @return debt The total debt of the position
    /// @return coll The total collateral of the position
    /// @return pendingStableDebtReward The pending stable debt reward
    /// @return pendingCollateralReward The pending collateral reward
    function getEntireDebtAndColl(address _borrower)
    external view returns (uint debt, uint coll, uint pendingStableDebtReward, uint pendingCollateralReward);

    /// @notice Close a position
    /// @param _borrower The address of the position owner
    function closePosition(address _borrower) external;

    /// @notice Remove the stake for a position
    /// @param _borrower The address of the position owner
    function removeStake(address _borrower) external;

    /// @notice Get the current redemption rate
    /// @param suggestedAdditiveFeePCT The suggested additive fee percentage
    /// @return The current redemption rate
    function getRedemptionRate(uint suggestedAdditiveFeePCT) external view returns (uint);

    /// @notice Get the redemption rate with decay
    /// @param suggestedAdditiveFeePCT The suggested additive fee percentage
    /// @return The redemption rate with decay applied
    function getRedemptionRateWithDecay(uint suggestedAdditiveFeePCT) external view returns (uint);

    /// @notice Get the redemption fee with decay
    /// @param _CollateralDrawn The amount of collateral drawn
    /// @param suggestedAdditiveFeePCT The suggested additive fee percentage
    /// @return The redemption fee with decay applied
    function getRedemptionFeeWithDecay(uint _CollateralDrawn, uint suggestedAdditiveFeePCT) external view returns (uint);

    /// @notice Get the current borrowing rate
    /// @param suggestedAdditiveFeePCT The suggested additive fee percentage
    /// @return The current borrowing rate
    function getBorrowingRate(uint suggestedAdditiveFeePCT) external view returns (uint);

    /// @notice Get the borrowing rate with decay
    /// @param suggestedAdditiveFeePCT The suggested additive fee percentage
    /// @return The borrowing rate with decay applied
    function getBorrowingRateWithDecay(uint suggestedAdditiveFeePCT) external view returns (uint);

    /// @notice Get the borrowing fee
    /// @param stableDebt The amount of stable debt
    /// @param suggestedAdditiveFeePCT The suggested additive fee percentage
    /// @return The borrowing fee
    function getBorrowingFee(uint stableDebt, uint suggestedAdditiveFeePCT) external view returns (uint);

    /// @notice Get the borrowing fee with decay
    /// @param _stableDebt The amount of stable debt
    /// @param suggestedAdditiveFeePCT The suggested additive fee percentage
    /// @return The borrowing fee with decay applied
    function getBorrowingFeeWithDecay(uint _stableDebt, uint suggestedAdditiveFeePCT) external view returns (uint);

    /// @notice Decay the base rate from borrowing
    function decayBaseRateFromBorrowing() external;

    /// @notice Get the status of a position
    /// @param _borrower The address of the position owner
    /// @return The status of the position
    function getPositionStatus(address _borrower) external view returns (uint);

    /// @notice Get the stake of a position
    /// @param _borrower The address of the position owner
    /// @return The stake of the position
    function getPositionStake(address _borrower) external view returns (uint);

    /// @notice Get the debt of a position
    /// @param _borrower The address of the position owner
    /// @return The debt of the position
    function getPositionDebt(address _borrower) external view returns (uint);

    /// @notice Get the collateral of a position
    /// @param _borrower The address of the position owner
    /// @return The collateral of the position
    function getPositionColl(address _borrower) external view returns (uint);

    /// @notice Set the status of a position
    /// @param _borrower The address of the position owner
    /// @param num The new status value
    function setPositionStatus(address _borrower, uint num) external;

    /// @notice Increase the collateral of a position
    /// @param _borrower The address of the position owner
    /// @param _collIncrease The amount of collateral to increase
    /// @return The new collateral amount
    function increasePositionColl(address _borrower, uint _collIncrease) external returns (uint);

    /// @notice Decrease the collateral of a position
    /// @param _borrower The address of the position owner
    /// @param _collDecrease The amount of collateral to decrease
    /// @return The new collateral amount
    function decreasePositionColl(address _borrower, uint _collDecrease) external returns (uint);

    /// @notice Increase the debt of a position
    /// @param _borrower The address of the position owner
    /// @param _debtIncrease The amount of debt to increase
    /// @return The new debt amount
    function increasePositionDebt(address _borrower, uint _debtIncrease) external returns (uint);

    /// @notice Decrease the debt of a position
    /// @param _borrower The address of the position owner
    /// @param _debtDecrease The amount of debt to decrease
    /// @return The new debt amount
    function decreasePositionDebt(address _borrower, uint _debtDecrease) external returns (uint);

    /// @notice Get the entire debt of the system
    /// @return total The total debt in the system
    function getEntireDebt() external view returns (uint total);

    /// @notice Get the entire collateral in the system
    /// @return total The total collateral in the system
    function getEntireCollateral() external view returns (uint total);

    /// @notice Get the Total Collateral Ratio (TCR) of the system
    /// @param _price The current price of the collateral
    /// @return TCR The Total Collateral Ratio
    function getTCR(uint _price) external view returns(uint TCR);

    /// @notice Check if the system is in Recovery Mode
    /// @param _price The current price of the collateral
    /// @return True if the system is in Recovery Mode, false otherwise
    function checkRecoveryMode(uint _price) external returns(bool);

    /// @notice Check if the position manager is in sunset mode
    /// @return True if the position manager is in sunset mode, false otherwise
    function isSunset() external returns(bool);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

/// @title IPriceFeed Interface
/// @notice Interface for price feed contracts that provide various price-related functionalities
interface IPriceFeed {
    /// @notice Enum to represent the current operational mode of the oracle
    enum OracleMode {AUTOMATED, FALLBACK}

    /// @notice Struct to hold detailed price information
    struct PriceDetails {
        uint lowestPrice;
        uint highestPrice;
        uint weightedAveragePrice;
        uint spotPrice;
        uint shortTwapPrice;
        uint longTwapPrice;
        uint suggestedAdditiveFeePCT;
        OracleMode currentMode;
    }

    /// @notice Fetches the current price details
    /// @param utilizationPCT The current utilization percentage
    /// @return A PriceDetails struct containing various price metrics
    function fetchPrice(uint utilizationPCT) external view returns (PriceDetails memory);

    /// @notice Fetches the weighted average price, used during liquidations
    /// @param testLiquidity Whether to test for liquidity
    /// @param testDeviation Whether to test for price deviation
    /// @return price The weighted average price
    function fetchWeightedAveragePrice(bool testLiquidity, bool testDeviation) external returns (uint price);

    /// @notice Fetches the lowest price, used when exiting escrow or testing for under-collateralized positions
    /// @param testLiquidity Whether to test for liquidity
    /// @param testDeviation Whether to test for price deviation
    /// @return price The lowest price
    function fetchLowestPrice(bool testLiquidity, bool testDeviation) external returns (uint price);

    /// @notice Fetches the lowest price with a fee suggestion, used when issuing new debt
    /// @param loadIncrease The increase in load
    /// @param originationOrRedemptionLoadPCT The origination or redemption load percentage
    /// @param testLiquidity Whether to test for liquidity
    /// @param testDeviation Whether to test for price deviation
    /// @return price The lowest price
    /// @return suggestedAdditiveFeePCT The suggested additive fee percentage
    function fetchLowestPriceWithFeeSuggestion(
        uint loadIncrease,
        uint originationOrRedemptionLoadPCT,
        bool testLiquidity,
        bool testDeviation
    ) external returns (uint price, uint suggestedAdditiveFeePCT);

    /// @notice Fetches the highest price with a fee suggestion, used during redemptions
    /// @param loadIncrease The increase in load
    /// @param originationOrRedemptionLoadPCT The origination or redemption load percentage
    /// @param testLiquidity Whether to test for liquidity
    /// @param testDeviation Whether to test for price deviation
    /// @return price The highest price
    /// @return suggestedAdditiveFeePCT The suggested additive fee percentage
    function fetchHighestPriceWithFeeSuggestion(
        uint loadIncrease,
        uint originationOrRedemptionLoadPCT,
        bool testLiquidity,
        bool testDeviation
    ) external returns (uint price, uint suggestedAdditiveFeePCT);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

/// @title IRecoverable Interface
/// @notice Interface for contracts that can recover orphaned tokens
interface IRecoverable {
    /// @notice Extracts orphaned tokens from the contract
    /// @dev This function should only be callable by authorized roles (e.g., guardian)
    /// @param asset The address of the token to be extracted
    /// @param version The version of the token (if applicable)
    function extractOrphanedTokens(address asset, uint8 version) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

/// @title ISortedPositions Interface
/// @notice Interface for a sorted list of positions, ordered by their Individual Collateral Ratio (ICR)
interface ISortedPositions {
    /// @notice Emitted when the PositionManager address is changed
    /// @param _positionManagerAddress The new address of the PositionManager
    event PositionManagerAddressChanged(address _positionManagerAddress);

    /// @notice Emitted when the PositionController address is changed
    /// @param _positionControllerAddress The new address of the PositionController
    event PositionControllerAddressChanged(address _positionControllerAddress);

    /// @notice Emitted when a new node (position) is added to the list
    /// @param _id The address of the new position
    /// @param _NICR The Nominal Individual Collateral Ratio of the new position
    event NodeAdded(address _id, uint _NICR);

    /// @notice Emitted when a node (position) is removed from the list
    /// @param _id The address of the removed position
    event NodeRemoved(address _id);

    /// @notice Sets the parameters for the sorted list
    /// @param _size The maximum size of the list
    /// @param _positionManagerAddress The address of the PositionManager contract
    /// @param _positionControllerAddress The address of the PositionController contract
    function setParams(uint256 _size, address _positionManagerAddress, address _positionControllerAddress) external;

    /// @notice Inserts a new node (position) into the list
    /// @param _id The address of the new position
    /// @param _ICR The Individual Collateral Ratio of the new position
    /// @param _prevId The address of the previous node in the insertion position
    /// @param _nextId The address of the next node in the insertion position
    function insert(address _id, uint256 _ICR, address _prevId, address _nextId) external;

    /// @notice Removes a node (position) from the list
    /// @param _id The address of the position to remove
    function remove(address _id) external;

    /// @notice Re-inserts a node (position) into the list with a new ICR
    /// @param _id The address of the position to re-insert
    /// @param _newICR The new Individual Collateral Ratio of the position
    /// @param _prevId The address of the previous node in the new insertion position
    /// @param _nextId The address of the next node in the new insertion position
    function reInsert(address _id, uint256 _newICR, address _prevId, address _nextId) external;

    /// @notice Checks if a position is in the list
    /// @param _id The address of the position to check
    /// @return bool True if the position is in the list, false otherwise
    function contains(address _id) external view returns (bool);

    /// @notice Checks if the list is full
    /// @return bool True if the list is full, false otherwise
    function isFull() external view returns (bool);

    /// @notice Checks if the list is empty
    /// @return bool True if the list is empty, false otherwise
    function isEmpty() external view returns (bool);

    /// @notice Gets the current size of the list
    /// @return uint256 The current number of positions in the list
    function getSize() external view returns (uint256);

    /// @notice Gets the maximum size of the list
    /// @return uint256 The maximum number of positions the list can hold
    function getMaxSize() external view returns (uint256);

    /// @notice Gets the first position in the list (highest ICR)
    /// @return address The address of the first position
    function getFirst() external view returns (address);

    /// @notice Gets the last position in the list (lowest ICR)
    /// @return address The address of the last position
    function getLast() external view returns (address);

    /// @notice Gets the next position in the list after a given position
    /// @param _id The address of the current position
    /// @return address The address of the next position
    function getNext(address _id) external view returns (address);

    /// @notice Gets the previous position in the list before a given position
    /// @param _id The address of the current position
    /// @return address The address of the previous position
    function getPrev(address _id) external view returns (address);

    /// @notice Checks if a given insertion position is valid for a new ICR
    /// @param _ICR The ICR of the position to insert
    /// @param _prevId The address of the proposed previous node
    /// @param _nextId The address of the proposed next node
    /// @return bool True if the insertion position is valid, false otherwise
    function validInsertPosition(uint256 _ICR, address _prevId, address _nextId) external view returns (bool);

    /// @notice Finds the correct insertion position for a given ICR
    /// @param _ICR The ICR of the position to insert
    /// @param _prevId A hint for the previous node
    /// @param _nextId A hint for the next node
    /// @return address The address of the previous node for insertion
    /// @return address The address of the next node for insertion
    function findInsertPosition(uint256 _ICR, address _prevId, address _nextId) external view returns (address, address);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC2612.sol";

/// @title IStable Interface
/// @notice Interface for the Stable token contract, extending ERC20 and ERC2612 functionality
interface IStable is IERC20, IERC2612 {
    /// @notice Mints new tokens to a specified account
    /// @param _account The address to receive the minted tokens
    /// @param _amount The amount of tokens to mint
    function mint(address _account, uint256 _amount) external;

    /// @notice Burns tokens from a specified account
    /// @param _account The address from which to burn tokens
    /// @param _amount The amount of tokens to burn
    function burn(address _account, uint256 _amount) external;

    /// @notice Transfers tokens from a sender to a pool
    /// @param _sender The address sending the tokens
    /// @param poolAddress The address of the pool receiving the tokens
    /// @param _amount The amount of tokens to transfer
    function sendToPool(address _sender, address poolAddress, uint256 _amount) external;

    /// @notice Transfers tokens for redemption escrow
    /// @param from The address sending the tokens
    /// @param to The address receiving the tokens (likely a position manager)
    /// @param amount The amount of tokens to transfer
    function transferForRedemptionEscrow(address from, address to, uint amount) external;

    /// @notice Returns tokens from a pool to a user
    /// @param poolAddress The address of the pool sending the tokens
    /// @param user The address of the user receiving the tokens
    /// @param _amount The amount of tokens to return
    function returnFromPool(address poolAddress, address user, uint256 _amount) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../common/Base.sol";
import "../common/StableMath.sol";
import "../Guardable.sol";
import "../interfaces/IBackstopPool.sol";
import "../interfaces/IRecoverable.sol";
import "../interfaces/ICollateralController.sol";
import "../interfaces/IPositionController.sol";
import "../incentives/BackstopPoolIncentives.sol";
import "../interfaces/IStable.sol";

/**
 * @title BackstopPool
 * @dev Contract for managing a backstop pool in a DeFi system.
 *
 * Key features:
 *   1. Deposit Management: Handles deposits of stable tokens into the backstop pool.
 *   2. Collateral Tracking: Tracks multiple types of collateral assets.
 *   3. Incentive Distribution: Manages the distribution of fee tokens as incentives.
 *   4. Position Offsetting: Allows for offsetting of positions with collateral and debt.
 *   5. Compound Interest: Implements a compound interest mechanism for deposits.
 *   6. Snapshots: Maintains snapshots of user deposits and global state for accurate reward calculations.
 */
contract BackstopPool is Base, Ownable, Guardable, IBackstopPool, IRecoverable {
    string constant public NAME = "BackstopPool";

    // External contract interfaces
    ICollateralController public collateralController;
    IPositionController public positionController;
    IStable public stableToken;
    IBackstopPoolIncentives public incentivesIssuance;

    // Total deposits in the pool
    uint256 internal totalStableDeposits;

    /**
     * @dev Struct to hold collateral totals and related data
     */
    struct CollateralTotals {
        uint256 total;
        mapping(uint128 => mapping(uint128 => uint)) epochToScaleToSum;
        uint lastCollateralError_Offset;
    }

    // Mappings for tracking rewards and collateral
    mapping(uint128 => mapping(uint128 => uint)) public epochToScaleToG;
    mapping(address => CollateralTotals) public collateralToTotals;

    /**
     * @dev Struct to represent a user's deposit
     */
    struct Deposit {
        uint initialValue;
    }

    /**
     * @dev Struct to hold snapshot data for deposits
     */
    struct Snapshots {
        mapping(address => uint) S;
        uint P;
        uint G;
        uint128 scale;
        uint128 epoch;
    }

    // Mappings for user deposits and snapshots
    mapping(address => Deposit) public deposits;
    mapping(address => Snapshots) public depositSnapshots;

    // Global state variables
    uint public P = DECIMAL_PRECISION;
    uint public constant SCALE_FACTOR = 1e9;
    uint128 public currentScale;
    uint128 public currentEpoch;

    // Error tracking for fee token and stable loss
    uint public lastFeeTokenError;
    uint public lastStableLossError_Offset;

    /**
     * @dev Sets the addresses for various components of the system
     * @param _collateralController Address of the collateral controller
     * @param _stableTokenAddress Address of the stable token
     * @param _positionController Address of the position controller
     * @param _incentivesIssuance Address of the incentives issuance contract
     */
    function setAddresses(
        address _collateralController,
        address _stableTokenAddress,
        address _positionController,
        address _incentivesIssuance
    ) external onlyOwner {
        collateralController = ICollateralController(_collateralController);
        incentivesIssuance = IBackstopPoolIncentives(_incentivesIssuance);
        stableToken = IStable(_stableTokenAddress);
        positionController = IPositionController(_positionController);
        renounceOwnership();
    }

    /**
     * @dev Gets the total amount of a specific collateral in the pool
     * @param collateral Address of the collateral token
     * @return The total amount of the specified collateral
     */
    function getCollateral(address collateral) external view override returns (uint) {
        return collateralToTotals[collateral].total;
    }

    /**
     * @dev Gets the total amount of stable token deposits in the pool
     * @return The total amount of stable token deposits
     */
    function getTotalStableDeposits() external view override returns (uint) {
        return totalStableDeposits;
    }

    /**
     * @dev Allows a user to provide funds to the backstop pool
     * @param _amount The amount of stable tokens to deposit
     */
    function provideToBP(uint _amount) external override {
        _requireNonZeroAmount(_amount);
        uint initialDeposit = deposits[msg.sender].initialValue;

        IBackstopPoolIncentives incentiveIssuanceCached = incentivesIssuance;
        _triggerFeeTokenIssuance(incentiveIssuanceCached);

        uint compoundedStableDeposit = getCompoundedStableDeposit(msg.sender);
        uint StableLoss = initialDeposit - compoundedStableDeposit;

        _payOutFeeTokenGains(incentiveIssuanceCached, msg.sender);
        _sendStableToBackstopPool(msg.sender, _amount);

        uint newDeposit = compoundedStableDeposit + _amount;
        CollateralGain[] memory depositorCollateralGains =
                        _calculateGainsAndUpdateSnapshots(msg.sender, newDeposit, false, address(0), 0, address(0), address(0));

        emit UserDepositChanged(msg.sender, newDeposit);
        emit CollateralGainsWithdrawn(msg.sender, depositorCollateralGains, StableLoss);
    }

    /**
     * @dev Allows a user to withdraw funds from the backstop pool
     * @param _amount The amount of stable tokens to withdraw
     */
    function withdrawFromBP(uint _amount) external override {
        if (_amount != 0) {
            _requireNoUnderCollateralizedPositions();
        }

        uint initialDeposit = deposits[msg.sender].initialValue;
        _requireUserHasDeposit(initialDeposit);

        IBackstopPoolIncentives incentiveIssuanceCached = incentivesIssuance;
        _triggerFeeTokenIssuance(incentiveIssuanceCached);

        uint compoundedStableDeposit = getCompoundedStableDeposit(msg.sender);
        uint StabletoWithdraw = StableMath._min(_amount, compoundedStableDeposit);
        uint StableLoss = initialDeposit - compoundedStableDeposit;

        _payOutFeeTokenGains(incentiveIssuanceCached, msg.sender);
        _sendStableToDepositor(msg.sender, StabletoWithdraw);

        uint newDeposit = compoundedStableDeposit - StabletoWithdraw;

        CollateralGain[] memory depositorCollateralGains =
                        _calculateGainsAndUpdateSnapshots(msg.sender, newDeposit, false, address(0), 0, address(0), address(0));

        emit UserDepositChanged(msg.sender, newDeposit);
        emit CollateralGainsWithdrawn(msg.sender, depositorCollateralGains, StableLoss);
    }

    /**
     * @dev Internal function to calculate gains and update snapshots
     * @param depositor Address of the depositor
     * @param newDeposit New deposit amount
     * @param withdrawingToPosition Flag indicating if withdrawing to a position
     * @param asset Address of the asset
     * @param version Version of the asset
     * @param _upperHint Upper hint for position
     * @param _lowerHint Lower hint for position
     * @return depositorCollateralGains Array of collateral gains
     */
    function _calculateGainsAndUpdateSnapshots(
        address depositor, uint newDeposit,
        bool withdrawingToPosition,
        address asset, uint8 version, address _upperHint, address _lowerHint
    ) private returns (CollateralGain[] memory depositorCollateralGains) {
        depositorCollateralGains = getDepositorCollateralGains(depositor);
        _updateDepositAndSnapshots(depositor, newDeposit);

        for (uint idx = 0; idx < depositorCollateralGains.length; idx++) {
            CollateralGain memory gain = depositorCollateralGains[idx];

            if (gain.gains == 0) {
                if (withdrawingToPosition && depositorCollateralGains[idx].asset == asset) {
                    revert("BackstopPool: caller must have non-zero Collateral Gain");
                }
                continue;
            }

            collateralToTotals[gain.asset].total -= gain.gains;
            emit BackstopPoolCollateralBalanceUpdated(gain.asset, collateralToTotals[gain.asset].total);
            emit CollateralSent(gain.asset, depositor, gain.gains);

            if (withdrawingToPosition && depositorCollateralGains[idx].asset == asset) {
                IERC20(asset).approve(address(positionController), gain.gains);
                positionController.moveCollateralGainToPosition(asset, version, gain.gains, depositor, _upperHint, _lowerHint);
            } else {
                require(IERC20(gain.asset).transfer(depositor, gain.gains), "BackstopPool: sending Collateral failed");
            }
        }
    }

    /**
     * @dev Allows a user to withdraw collateral gain to a position
     * @param asset Address of the collateral asset
     * @param version Version of the collateral
     * @param _upperHint Upper hint for position
     * @param _lowerHint Lower hint for position
     */
    function withdrawCollateralGainToPosition(address asset, uint8 version, address _upperHint, address _lowerHint) external override {
        uint initialDeposit = deposits[msg.sender].initialValue;
        _requireUserHasDeposit(initialDeposit);
        _requireUserHasPosition(asset, version, msg.sender);

        IBackstopPoolIncentives incentiveIssuanceCached = incentivesIssuance;
        _triggerFeeTokenIssuance(incentiveIssuanceCached);

        uint compoundedStableDeposit = getCompoundedStableDeposit(msg.sender);
        uint StableLoss = initialDeposit - compoundedStableDeposit;

        _payOutFeeTokenGains(incentiveIssuanceCached, msg.sender);

        CollateralGain[] memory depositorCollateralGains =
                        _calculateGainsAndUpdateSnapshots(msg.sender, compoundedStableDeposit, true, asset, version, _upperHint, _lowerHint);

        emit UserDepositChanged(msg.sender, compoundedStableDeposit);
        emit CollateralGainsWithdrawn(msg.sender, depositorCollateralGains, StableLoss);
    }

    /**
     * @dev Offsets a position with collateral and debt
     * @param collateralAsset Address of the collateral asset
     * @param version Version of the collateral
     * @param _debtToOffset Amount of debt to offset
     * @param _collToAdd Amount of collateral to add
     */
    function offset(address collateralAsset, uint8 version, uint _debtToOffset, uint _collToAdd) external override {
        _requireCallerIsPositionManager(collateralAsset, version);
        uint totalStable = totalStableDeposits;
        if (totalStable == 0 || _debtToOffset == 0) {
            return;
        }

        _triggerFeeTokenIssuance(incentivesIssuance);

        (uint CollateralGainPerUnitStaked, uint StableLossPerUnitStaked) =
                        _computeRewardsPerUnitStaked(collateralAsset, _collToAdd, _debtToOffset, totalStable);

        _updateRewardSumAndProduct(collateralAsset, CollateralGainPerUnitStaked, StableLossPerUnitStaked);
        _moveOffsetCollAndDebt(collateralController.getCollateralInstance(collateralAsset, version), _collToAdd, _debtToOffset);
    }

    /**
     * @dev Computes rewards per unit staked
     * @param collateralAsset Address of the collateral asset
     * @param _collToAdd Amount of collateral to add
     * @param _debtToOffset Amount of debt to offset
     * @param _totalStableDeposits Total stable deposits
     * @return CollateralGainPerUnitStaked Collateral gain per unit staked
     * @return stableLossPerUnitStaked Stable loss per unit staked
     */
    function _computeRewardsPerUnitStaked(
        address collateralAsset,
        uint _collToAdd,
        uint _debtToOffset,
        uint _totalStableDeposits
    ) internal returns (uint CollateralGainPerUnitStaked, uint stableLossPerUnitStaked) {
        uint CollateralNumerator = (_collToAdd * DECIMAL_PRECISION) + collateralToTotals[collateralAsset].lastCollateralError_Offset;
        assert(_debtToOffset <= _totalStableDeposits);

        if (_debtToOffset == _totalStableDeposits) {
            stableLossPerUnitStaked = DECIMAL_PRECISION;
            lastStableLossError_Offset = 0;
        } else {
            uint stableLossNumerator = (_debtToOffset * DECIMAL_PRECISION) - lastStableLossError_Offset;
            stableLossPerUnitStaked = (stableLossNumerator / _totalStableDeposits) + 1;
            lastStableLossError_Offset = (stableLossPerUnitStaked * _totalStableDeposits) - stableLossNumerator;
        }

        CollateralGainPerUnitStaked = CollateralNumerator / _totalStableDeposits;
        collateralToTotals[collateralAsset].lastCollateralError_Offset = CollateralNumerator - (CollateralGainPerUnitStaked * _totalStableDeposits);

        return (CollateralGainPerUnitStaked, stableLossPerUnitStaked);
    }

    /**
     * @dev Updates reward sum and product
     * @param collateralAsset Address of the collateral asset
     * @param _CollateralGainPerUnitStaked Collateral gain per unit staked
     * @param _stableLossPerUnitStaked Stable loss per unit staked
     */
    function _updateRewardSumAndProduct(address collateralAsset, uint _CollateralGainPerUnitStaked, uint _stableLossPerUnitStaked) internal {
        uint currentP = P;
        uint newP;

        assert(_stableLossPerUnitStaked <= DECIMAL_PRECISION);
        uint newProductFactor = uint(DECIMAL_PRECISION) - _stableLossPerUnitStaked;

        uint128 currentScaleCached = currentScale;
        uint128 currentEpochCached = currentEpoch;

        uint currentS = collateralToTotals[collateralAsset].epochToScaleToSum[currentEpochCached][currentScaleCached];
        uint marginalCollateralGain = _CollateralGainPerUnitStaked * currentP;
        uint newS = currentS + marginalCollateralGain;
        collateralToTotals[collateralAsset].epochToScaleToSum[currentEpochCached][currentScaleCached] = newS;
        emit S_Updated(collateralAsset, newS, currentEpochCached, currentScaleCached);

        if (newProductFactor == 0) {
            currentEpoch = currentEpochCached + 1;
            emit EpochUpdated(currentEpoch);
            currentScale = 0;
            emit ScaleUpdated(currentScale);
            newP = DECIMAL_PRECISION;
        } else if (((currentP * newProductFactor) / DECIMAL_PRECISION) < SCALE_FACTOR) {
            newP = ((currentP * newProductFactor) * SCALE_FACTOR) / DECIMAL_PRECISION;
            currentScale = currentScaleCached + 1;
            emit ScaleUpdated(currentScale);
        } else {
            newP = (currentP * newProductFactor) / DECIMAL_PRECISION;
        }

        assert(newP > 0);
        P = newP;

        emit P_Updated(newP);
    }

    /**
     * @dev Extracts orphaned tokens from the contract
     * @param asset Address of the token to extract
     * @param version Version of the token
     */
    function extractOrphanedTokens(address asset, uint8 version) external override onlyGuardian {
        require(asset != address(stableToken), "Naughty...");

        address[] memory collaterals = collateralController.getUniqueActiveCollateralAddresses();
        for (uint idx; idx < collaterals.length; idx++) {
            // Should not be able to extract tokens in the contract which are under normal operation.
            // Only tokens which are not claimed by users before sunset can be extracted,
            // or tokens which are accidentally sent to the contract.
            require(collaterals[idx] != asset, "Guardian can only extract non-active tokens");
        }

        IERC20 orphan = IERC20(asset);
        orphan.transfer(guardian(), orphan.balanceOf(address(this)));
    }

    /**
     * @dev Moves offset collateral and debt
     * @param collateral Collateral instance
     * @param _collToAdd Amount of collateral to add
     * @param _debtToOffset Amount of debt to offset
     */
    function _moveOffsetCollAndDebt(ICollateralController.Collateral memory collateral, uint _collToAdd, uint _debtToOffset) internal {
        IActivePool activePoolCached = collateral.activePool;
        activePoolCached.decreaseStableDebt(_debtToOffset);
        _decreaseStable(_debtToOffset);
        stableToken.burn(address(this), _debtToOffset);
        activePoolCached.sendCollateral(address(this), _collToAdd);
        collateralToTotals[address(collateral.asset)].total += _collToAdd;
        emit BackstopPoolCollateralBalanceUpdated(address(collateral.asset), collateralToTotals[address(collateral.asset)].total);
    }

    /**
     * @dev Decreases the total stable deposits
     * @param _amount Amount to decrease
     */
    function _decreaseStable(uint _amount) internal {
        uint newTotalStableDeposits = totalStableDeposits - _amount;
        totalStableDeposits = newTotalStableDeposits;
        emit BackstopPoolStableBalanceUpdated(newTotalStableDeposits);
    }

    /**
     * @dev Gets the collateral gains for a depositor
     * @param _depositor Address of the depositor
     * @return An array of CollateralGain structs
     */
    function getDepositorCollateralGains(address _depositor) public view override returns (IBackstopPool.CollateralGain[] memory) {
        uint P_Snapshot = depositSnapshots[_depositor].P;
        uint128 epochSnapshot = depositSnapshots[_depositor].epoch;
        uint128 scaleSnapshot = depositSnapshots[_depositor].scale;

        uint initialDeposit = deposits[_depositor].initialValue;
        if (initialDeposit == 0) {return new IBackstopPool.CollateralGain[](0);}

        address[] memory collaterals = collateralController.getUniqueActiveCollateralAddresses();
        IBackstopPool.CollateralGain[] memory gains = new IBackstopPool.CollateralGain[](collaterals.length);

        for (uint idx; idx < collaterals.length; idx++) {
            CollateralTotals storage c = collateralToTotals[collaterals[idx]];

            uint S_Snapshot = depositSnapshots[_depositor].S[collaterals[idx]];
            uint firstPortion = c.epochToScaleToSum[epochSnapshot][scaleSnapshot] - S_Snapshot;
            uint secondPortion = c.epochToScaleToSum[epochSnapshot][scaleSnapshot + 1] / SCALE_FACTOR;
            uint gain = ((initialDeposit * (firstPortion + secondPortion)) / P_Snapshot) / DECIMAL_PRECISION;

            gains[idx] = CollateralGain(collaterals[idx], gain);
        }

        return gains;
    }

    /**
     * @dev Gets the collateral gain for a specific depositor and asset
     * @param asset Address of the collateral asset
     * @param _depositor Address of the depositor
     * @return The amount of collateral gain
     */
    function getDepositorCollateralGain(address asset, address _depositor) external view returns (uint) {
        IBackstopPool.CollateralGain[] memory gains = getDepositorCollateralGains(_depositor);
        for (uint idx; idx < gains.length; idx++) {
            if (gains[idx].asset == asset) {
                return gains[idx].gains;
            }
        }
        return 0;
    }

    /**
     * @dev Gets the sum for a specific epoch and scale
     * @param asset Address of the collateral asset
     * @param epoch Epoch number
     * @param scale Scale number
     * @return The sum for the given epoch and scale
     */
    function getEpochToScaleToSum(address asset, uint128 epoch, uint128 scale) external override view returns (uint) {
        return collateralToTotals[asset].epochToScaleToSum[epoch][scale];
    }

    /**
     * @dev Gets the sum from the deposit snapshot for a specific user and asset
     * @param user Address of the user
     * @param asset Address of the collateral asset
     * @return The sum from the deposit snapshot
     */
    function getDepositSnapshotToAssetToSum(address user, address asset) external view returns (uint) {
        return depositSnapshots[user].S[asset];
    }

    /**
     * @dev Calculates the compounded stable deposit for a depositor
     * @param _depositor Address of the depositor
     * @return The compounded stable deposit amount
     */
    function getCompoundedStableDeposit(address _depositor) public view override returns (uint) {
        uint initialDeposit = deposits[_depositor].initialValue;
        if (initialDeposit == 0) {return 0;}

        uint snapshot_P = depositSnapshots[_depositor].P;
        uint128 scaleSnapshot = depositSnapshots[_depositor].scale;
        uint128 epochSnapshot = depositSnapshots[_depositor].epoch;

        if (epochSnapshot < currentEpoch) {return 0;}

        uint compoundedStake;
        uint128 scaleDiff = currentScale - scaleSnapshot;

        if (scaleDiff == 0) {
            compoundedStake = (initialDeposit * P) / snapshot_P;
        } else if (scaleDiff == 1) {
            compoundedStake = ((initialDeposit * P) / (snapshot_P)) / SCALE_FACTOR;
        } else {
            compoundedStake = 0;
        }

        return (compoundedStake < (initialDeposit / 1e9)) ? 0 : compoundedStake;
    }

    /**
     * @dev Sends stable tokens to the backstop pool
     * @param _address Address to send from
     * @param _amount Amount to send
     */
    function _sendStableToBackstopPool(address _address, uint _amount) internal {
        stableToken.sendToPool(_address, address(this), _amount);
        uint newTotalStableDeposits = totalStableDeposits + _amount;
        totalStableDeposits = newTotalStableDeposits;
        emit BackstopPoolStableBalanceUpdated(newTotalStableDeposits);
    }

    /**
     * @dev Sends stable tokens to a depositor
     * @param _depositor Address of the depositor
     * @param stableWithdrawal Amount to withdraw
     */
    function _sendStableToDepositor(address _depositor, uint stableWithdrawal) internal {
        if (stableWithdrawal == 0) {
            return;
        }
        stableToken.returnFromPool(address(this), _depositor, stableWithdrawal);
        _decreaseStable(stableWithdrawal);
    }

    /**
     * @dev Updates deposit and snapshots for a user
     * @param _depositor Address of the depositor
     * @param _newValue New deposit value
     */
    function _updateDepositAndSnapshots(address _depositor, uint _newValue) internal {
        deposits[_depositor].initialValue = _newValue;
        address[] memory collaterals = collateralController.getUniqueActiveCollateralAddresses();

        if (_newValue == 0) {
            delete depositSnapshots[_depositor];
            for (uint idx; idx < collaterals.length; idx++) {
                depositSnapshots[_depositor].S[collaterals[idx]] = 0;
            }
            emit DepositSnapshotUpdated(_depositor, address(0), 0, 0, 0);
            return;
        }

        uint128 currentScaleCached = currentScale;
        uint128 currentEpochCached = currentEpoch;
        uint currentG = epochToScaleToG[currentEpochCached][currentScaleCached];
        uint currentP = P;

        for (uint idx; idx < collaterals.length; idx++) {
            CollateralTotals storage c = collateralToTotals[collaterals[idx]];
            uint currentS = c.epochToScaleToSum[currentEpochCached][currentScaleCached];
            depositSnapshots[_depositor].S[collaterals[idx]] = currentS;
            emit DepositSnapshotUpdated(_depositor, collaterals[idx], currentP, currentS, currentG);
        }

        depositSnapshots[_depositor].P = currentP;
        depositSnapshots[_depositor].G = currentG;
        depositSnapshots[_depositor].scale = currentScaleCached;
        depositSnapshots[_depositor].epoch = currentEpochCached;
    }

    /**
     * @dev Triggers fee token issuance
     * @param _incentivesIssuance Address of the incentives issuance contract
     */
    function _triggerFeeTokenIssuance(IBackstopPoolIncentives _incentivesIssuance) internal {
        uint feeTokenIssuance = _incentivesIssuance.issueFeeTokens();
        _updateG(feeTokenIssuance);
    }

    /**
     * @dev Updates the G value
     * @param _feeTokenIssuance Amount of fee tokens issued
     */
    function _updateG(uint _feeTokenIssuance) internal {
        uint totalStable = totalStableDeposits; // cached to save an SLOAD
        /*
        * When total deposits is 0, G is not updated. In this case, the feeToken issued can not be obtained by later
        * depositors - it is missed out on, and remains in the balanceOf the IncentivesIssuance contract.
        */
        if (totalStable == 0 || _feeTokenIssuance == 0) {return;}

        uint feeTokenPerUnitStaked = _computeFeeTokenPerUnitStaked(_feeTokenIssuance, totalStable);
        uint marginalFeeTokenGain = feeTokenPerUnitStaked * P;
        epochToScaleToG[currentEpoch][currentScale] = epochToScaleToG[currentEpoch][currentScale] + marginalFeeTokenGain;

        emit G_Updated(epochToScaleToG[currentEpoch][currentScale], currentEpoch, currentScale);
    }

    /**
     * @dev Computes fee token per unit staked
     * @param _feeTokenIssuance Amount of fee tokens issued
     * @param _totalStableDeposits Total stable deposits
     * @return The computed fee token per unit staked
     */
    function _computeFeeTokenPerUnitStaked(uint _feeTokenIssuance, uint _totalStableDeposits) internal returns (uint) {
        /*
        * Calculate the feeToken-per-unit staked.  Division uses a "feedback" error correction, to keep the
        * cumulative error low in the running total G:
        *
        * 1) Form a numerator which compensates for the floor division error that occurred the last time this
        * function was called.
        * 2) Calculate "per-unit-staked" ratio.
        * 3) Multiply the ratio back by its denominator, to reveal the current floor division error.
        * 4) Store this error for use in the next correction when this function is called.
        * 5) Note: static analysis tools complain about this "division before multiplication", however, it is intended.
        */
        uint feeTokenNumerator = (_feeTokenIssuance * DECIMAL_PRECISION) + lastFeeTokenError;

        uint feeTokenPerUnitStaked = feeTokenNumerator / _totalStableDeposits;
        lastFeeTokenError = feeTokenNumerator - (feeTokenPerUnitStaked * _totalStableDeposits);

        return feeTokenPerUnitStaked;
    }

    /**
     * @dev Calculates the fee token gain for a depositor
     * @param _depositor Address of the depositor
     * @return The calculated fee token gain
     */
    function getDepositorFeeTokenGain(address _depositor) public view override returns (uint) {
        uint initialDeposit = deposits[_depositor].initialValue;
        if (initialDeposit == 0) {return 0;}
        Snapshots storage snapshots = depositSnapshots[_depositor];
        return (DECIMAL_PRECISION * (_getFeeTokenGainFromSnapshots(initialDeposit, snapshots))) / DECIMAL_PRECISION;
    }

    /**
     * @dev Gets the fee token gain from snapshots
     * @param initialStake Initial stake amount
     * @param snapshots Snapshots struct
     * @return The calculated fee token gain
     */
    function _getFeeTokenGainFromSnapshots(uint initialStake, Snapshots storage snapshots) internal view returns (uint) {
        /*
         * Grab the sum 'G' from the epoch at which the stake was made. The feeToken gain may span up to one scale change.
         * If it does, the second portion of the feeToken gain is scaled by 1e9.
         * If the gain spans no scale change, the second portion will be 0.
         */
        uint128 epochSnapshot = snapshots.epoch;
        uint128 scaleSnapshot = snapshots.scale;
        uint G_Snapshot = snapshots.G;
        uint P_Snapshot = snapshots.P;

        uint firstPortion = epochToScaleToG[epochSnapshot][scaleSnapshot] - G_Snapshot;
        uint secondPortion = epochToScaleToG[epochSnapshot][scaleSnapshot + 1] / SCALE_FACTOR;

        return ((initialStake * (firstPortion + secondPortion)) / P_Snapshot) / DECIMAL_PRECISION;
    }

    /**
     * @dev Pays out fee token gains to a depositor
     * @param _incentivesIssuance Incentives issuance contract
     * @param _depositor Address of the depositor
     */
    function _payOutFeeTokenGains(IBackstopPoolIncentives _incentivesIssuance, address _depositor) internal {
        uint depositorFeeTokenGain = getDepositorFeeTokenGain(_depositor);
        _incentivesIssuance.sendFeeTokens(_depositor, depositorFeeTokenGain);
        emit FeeTokenPaidToDepositor(_depositor, depositorFeeTokenGain);
    }

    /**
     * @dev Checks if the caller is the position manager for the given collateral and version
     * @param collateralAsset Address of the collateral asset
     * @param version Version of the collateral
     */
    function _requireCallerIsPositionManager(address collateralAsset, uint8 version) internal view {
        require(
            msg.sender == address(collateralController.getCollateralInstance(collateralAsset, version).positionManager),
            "BackstopPool: Caller is not a PositionManager"
        );
    }

    /**
     * @dev Checks if there are no under-collateralized positions
     */
    function _requireNoUnderCollateralizedPositions() internal {
        collateralController.requireNoUnderCollateralizedPositions();
    }

    /**
     * @dev Checks if a user has a deposit
     * @param _initialDeposit Initial deposit amount
     */
    function _requireUserHasDeposit(uint _initialDeposit) internal pure {
        require(_initialDeposit > 0, 'BackstopPool: User must have a non-zero deposit');
    }

    /**
     * @dev Checks if the amount is non-zero
     * @param _amount Amount to check
     */
    function _requireNonZeroAmount(uint _amount) internal pure {
        require(_amount > 0, 'BackstopPool: Amount must be non-zero');
    }

    /**
     * @dev Checks if a user has an active position for the given asset and version
     * @param asset Address of the collateral asset
     * @param version Version of the collateral
     * @param _depositor Address of the depositor
     */
    function _requireUserHasPosition(address asset, uint8 version, address _depositor) internal view {
        require(
            collateralController.getCollateralInstance(asset, version).positionManager.getPositionStatus(_depositor) == 1,
            "BackstopPool: caller must have an active position to withdraw CollateralGain to"
        );
    }
}