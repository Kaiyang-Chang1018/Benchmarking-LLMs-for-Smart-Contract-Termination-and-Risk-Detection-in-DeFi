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
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Context.sol";

interface IERC20Mintable_ITO {
    /// @notice Mints ERC20 token(s) for the provided account, increases totalSupply().
    /// @param  account The address to mint tokens for.
    /// @param  amount  The amount of tokens to mint.
    function mint(address account, uint256 amount) external;
}

interface IZivoeGlobals_ITO {
    /// @notice Returns the address of the ZivoeDAO contract.
    function DAO() external view returns (address);

    /// @notice Returns the address of the ZivoeRewardsVesting ($ZVE) vesting contract.
    function vestZVE() external view returns (address);

    /// @notice Returns the address of the ZivoeYDL contract.
    function YDL() external view returns (address);

    /// @notice Returns the address of the ZivoeTrancheToken ($zJTT) contract.
    function zJTT() external view returns (address);

    /// @notice Returns the address of the ZivoeTrancheToken ($zSTT) contract.
    function zSTT() external view returns (address);

    /// @notice Returns the address of the ZivoeToken contract.
    function ZVE() external view returns (address);

    /// @notice Returns the Zivoe Laboratory address.
    function ZVL() external view returns (address);

    /// @notice Returns the address of the ZivoeTranches contract.
    function ZVT() external view returns (address);

    /// @notice Returns total circulating supply of zSTT and zJTT, accounting for defaults via markdowns.
    /// @return zSTTSupply zSTT.totalSupply() adjusted for defaults.
    /// @return zJTTSupply zJTT.totalSupply() adjusted for defaults.
    function adjustedSupplies() external view returns (uint256 zSTTSupply, uint256 zJTTSupply);

    /// @notice Handles WEI standardization of a given asset amount (i.e. 6 decimal precision => 18 decimal precision).
    /// @param  amount              The amount of a given "asset" to be standardized.
    /// @param  asset               The asset (ERC-20) from which to standardize the amount to WEI.
    /// @return standardizedAmount  The input amount, standardized to 18 decimals.
    function standardize(uint256 amount, address asset) external view returns (uint256 standardizedAmount);
}

interface ITO_IZivoeRewardsVesting {
    /// @notice Determines if account has vesting schedule set or not.
    function vestingScheduleSet(address) external view returns(bool);

    /// @notice Sets the vestingSchedule for an account.
    /// @param  account         The account vesting $ZVE.
    /// @param  daysToCliff     The number of days before vesting is claimable (a.k.a. cliff period).
    /// @param  daysToVest      The number of days for the entire vesting period, from beginning to end.
    /// @param  amountToVest    The amount of tokens being vested.
    /// @param  revokable       If the vested amount can be revoked.
    function createVestingSchedule(
        address account, 
        uint256 daysToCliff, 
        uint256 daysToVest, 
        uint256 amountToVest, 
        bool revokable
    ) external;
}

interface ITO_IZivoeTranches {
    /// @notice Unlocks the ZivoeTranches contract for distributions, sets initial variables.
    function unlock() external;
}

interface ITO_IZivoeYDL {
    /// @notice Unlocks the ZivoeYDL contract for distributions, initializes values.
    function unlock() external;
}



/// @notice This contract will facilitate the Zivoe ITO ("Initial Tranche Offering").
///         This contract has the following responsibilities:
///          - Permissioned by $zJTT and $zSTT to call mint() when an account deposits.
///          - Escrow $zJTT and $zSTT until the ITO concludes.
///          - Facilitate claiming of $zJTT and $zSTT when the ITO concludes.
///          - Vest $ZVE simulatenously during claiming (based on $pZVE credits).
///          - Migrate deposits to ZivoeDAO after the ITO concludes.
contract ZivoeITO is Context {

    using SafeERC20 for IERC20;
    
    // ---------------------
    //    State Variables
    // ---------------------

    address public immutable GBL;   /// @dev The ZivoeGlobals contract.
    
    address[] public stables;       /// @dev Stablecoin(s) allowed for juniorDeposit() or seniorDeposit().

    uint256 public end;             /// @dev The unix when the ITO ends (airdrop is claimable).
    uint256 public snapshotSTT;     /// @dev Snapshot of senior tranche token supply after migrateDeposits().
    uint256 public snapshotJTT;     /// @dev Snapshot of junior tranche token supply after migrateDeposits().

    bool public migrated;           /// @dev Triggers (true) when ITO concludes and assets migrate to ZivoeDAO.

    mapping(address => bool) public airdropClaimed;         /// @dev Tracks if an account has claimed their airdrop.

    mapping(address => uint256) public juniorCredits;       /// @dev Tracks $pZVE (credits) from juniorDeposit().
    mapping(address => uint256) public seniorCredits;       /// @dev Tracks $pZVE (credits) from seniorDeposit().

    uint256 private constant BIPS = 10000;



    // -----------------
    //    Constructor
    // -----------------

    /// @notice Initializes the ZivoeITO contract.
    /// @param  _GBL     The ZivoeGlobals contract.
    /// @param  _stables Array of stablecoins representing initial stablecoin inputs.
    constructor (address _GBL, address[] memory _stables) {
        GBL = _GBL;
        stables = _stables;
    }



    // ------------
    //    Events
    // ------------

    /// @notice Emitted during claimAirdrop().
    /// @param  account     The account claiming their airdrop.
    /// @param  zSTTClaimed The amount of Zivoe Senior Tranche ($zSTT) tokens received.
    /// @param  zJTTClaimed The amount of Zivoe Junior Tranche ($zJTT) tokens received.
    /// @param  ZVEVested  The amount of Zivoe ($ZVE) tokens received.
    event AirdropClaimed(address indexed account, uint256 zSTTClaimed, uint256 zJTTClaimed, uint256 ZVEVested);

    /// @notice Emitted during migrateDeposits().
    /// @param  DAI     Total amount of DAI migrated from the ITO to ZivoeDAO and ZVL.
    /// @param  FRAX    Total amount of FRAX migrated from the ITO to ZivoeDAO and ZVL.
    /// @param  USDC    Total amount of USDC migrated from the ITO to ZivoeDAO and ZVL.
    /// @param  USDT    Total amount of USDT migrated from the ITO to ZivoeDAO and ZVL.
    event DepositsMigrated(uint256 DAI, uint256 FRAX, uint256 USDC, uint256 USDT);

    /// @notice Emitted during commence().
    /// @param  start   The unix when the ITO starts.
    /// @param  end     The unix when the ITO ends (airdrop is claimable).
    event ITOCommenced(uint256 start, uint256 end);

    /// @notice Emitted during depositJunior().
    /// @param  account         The account depositing stablecoins to junior tranche.
    /// @param  asset           The stablecoin deposited.
    /// @param  amount          The amount of stablecoins deposited.
    /// @param  credits         The amount of credits earned.
    /// @param  trancheTokens   The amount of Zivoe Junior Tranche ($zJTT) tokens minted.
    event JuniorDeposit(
        address indexed account, 
        address indexed asset, 
        uint256 amount, 
        uint256 credits, 
        uint256 trancheTokens
    );

    /// @notice Emitted during depositSenior().
    /// @param  account         The account depositing stablecoins to senior tranche.
    /// @param  asset           The stablecoin deposited.
    /// @param  amount          The amount of stablecoins deposited.
    /// @param  credits         The amount of credits earned.
    /// @param  trancheTokens   The amount of Zivoe Senior Tranche ($zSTT) tokens minted.
    event SeniorDeposit(
        address indexed account, 
        address indexed asset, 
        uint256 amount, 
        uint256 credits, 
        uint256 trancheTokens
    );
    


    // ---------------
    //    Functions
    // ---------------

    /// @notice Checks if stablecoin deposits into the Junior Tranche are open.
    /// @param  amount The amount to deposit.
    /// @param  asset The asset (stablecoin) to deposit.
    /// @return open Will return "true" if the deposits into the Junior Tranche are open.
    function isJuniorOpen(uint256 amount, address asset) public view returns (bool open) {
        uint256 convertedAmount = IZivoeGlobals_ITO(GBL).standardize(amount, asset);
        (uint256 seniorSupp, uint256 juniorSupp) = IZivoeGlobals_ITO(GBL).adjustedSupplies();
        return convertedAmount + juniorSupp <= seniorSupp * 2000 / BIPS;
    }

    /// @notice Claim $zSTT, $zJTT, and begin a vesting schedule for $ZVE.
    /// @dev    This function MUST only be callable after the ITO concludes.
    /// @param  depositor   The address to claim for, generally _msgSender().
    /// @return zSTTClaimed Amount of $zSTT airdropped.
    /// @return zJTTClaimed Amount of $zJTT airdropped.
    /// @return ZVEVested   Amount of $ZVE vested.
    function claimAirdrop(address depositor) external returns (
        uint256 zSTTClaimed, uint256 zJTTClaimed, uint256 ZVEVested
    ) {
        require(end != 0, "ZivoeITO::claimAirdrop() end == 0");
        require(migrated, "ZivoeITO::claimAirdrop() !migrated");
        require(!airdropClaimed[depositor], "ZivoeITO::claimAirdrop() airdropClaimed[depositor]");
        require(
            seniorCredits[depositor] > 0 || juniorCredits[depositor] > 0, 
            "ZivoeITO::claimAirdrop() seniorCredits[depositor] == 0 && juniorCredits[depositor] == 0"
        );

        airdropClaimed[depositor] = true;

        // Temporarily store credit values, decrease them to 0 immediately after.
        uint256 seniorCreditsOwned = seniorCredits[depositor];
        uint256 juniorCreditsOwned = juniorCredits[depositor];

        seniorCredits[depositor] = 0;
        juniorCredits[depositor] = 0;

        // Calculate proportion of $ZVE awarded based on $pZVE credits.
        uint256 upper = seniorCreditsOwned + juniorCreditsOwned;
        uint256 middle = IERC20(IZivoeGlobals_ITO(GBL).ZVE()).totalSupply() / 20;
        uint256 lower = snapshotSTT * 3 + snapshotJTT;

        emit AirdropClaimed(depositor, seniorCreditsOwned / 3, juniorCreditsOwned, upper * middle / lower);

        IERC20(IZivoeGlobals_ITO(GBL).zJTT()).safeTransfer(depositor, juniorCreditsOwned);
        IERC20(IZivoeGlobals_ITO(GBL).zSTT()).safeTransfer(depositor, seniorCreditsOwned / 3);

        if (upper * middle / lower > 0) {
            ITO_IZivoeRewardsVesting(IZivoeGlobals_ITO(GBL).vestZVE()).createVestingSchedule(
                depositor, 0, 360, upper * middle / lower, false
            );
        }
        
        return (seniorCreditsOwned / 3, juniorCreditsOwned, upper * middle / lower);
    }

    /// @notice Deposit stablecoins, mint Zivoe Junior Tranche ($zJTT) tokens and increase airdrop credits.
    /// @dev    This function MUST only be callable during the ITO, and with accepted stablecoins.
    /// @param  amount The amount to deposit.
    /// @param  asset The asset to deposit.
    function depositJunior(uint256 amount, address asset) public {
        require(block.timestamp < end, "ZivoeITO::depositJunior() block.timestamp >= end");
        require(!migrated, "ZivoeITO::depositJunior() migrated");
        require(
            asset == stables[0] || asset == stables[1] || asset == stables[2] || asset == stables[3],
            "ZivoeITO::depositJunior() asset != stables[0-3]"
        );
        require(
            !ITO_IZivoeRewardsVesting(IZivoeGlobals_ITO(GBL).vestZVE()).vestingScheduleSet(_msgSender()),
            "ZivoeITO::depositJunior() ITO_IZivoeRewardsVesting(vestZVE).vestingScheduleSet(_msgSender())"
        );

        require(isJuniorOpen(amount, asset), "ZivoeITO::depositJunior() !isJuniorOpen(amount, asset)");

        address caller = _msgSender();
        uint256 standardizedAmount = IZivoeGlobals_ITO(GBL).standardize(amount, asset);

        juniorCredits[caller] += standardizedAmount;

        emit JuniorDeposit(caller, asset, amount, standardizedAmount, standardizedAmount);

        IERC20(asset).safeTransferFrom(caller, address(this), amount);
        IERC20Mintable_ITO(IZivoeGlobals_ITO(GBL).zJTT()).mint(address(this), standardizedAmount);
    }

    /// @notice Deposit stablecoins, mint Zivoe Senior Tranche ($zSTT) tokens and increase airdrop credits.
    /// @dev    This function MUST only be callable during the ITO, and with accepted stablecoins.
    /// @param  amount The amount to deposit.
    /// @param  asset The asset to deposit.
    function depositSenior(uint256 amount, address asset) public {
        require(block.timestamp < end, "ZivoeITO::depositSenior() block.timestamp >= end");
        require(!migrated, "ZivoeITO::depositSenior() migrated");
        require(
            asset == stables[0] || asset == stables[1] || asset == stables[2] || asset == stables[3],
            "ZivoeITO::depositSenior() asset != stables[0-3]"
        );
        require(
            !ITO_IZivoeRewardsVesting(IZivoeGlobals_ITO(GBL).vestZVE()).vestingScheduleSet(_msgSender()),
            "ZivoeITO::depositSenior() ITO_IZivoeRewardsVesting(vestZVE).vestingScheduleSet(_msgSender())"
        );

        address caller = _msgSender();
        uint256 standardizedAmount = IZivoeGlobals_ITO(GBL).standardize(amount, asset);

        seniorCredits[caller] += standardizedAmount * 3;

        emit SeniorDeposit(caller, asset, amount, standardizedAmount * 3, standardizedAmount);

        IERC20(asset).safeTransferFrom(caller, address(this), amount);
        IERC20Mintable_ITO(IZivoeGlobals_ITO(GBL).zSTT()).mint(address(this), standardizedAmount);
    }

    /// @notice Deposit stablecoins to both tranches simultaneously
    /// @param amountSenior The amount to deposit to senior tranche
    /// @param assetSenior The asset to deposit to senior tranche
    /// @param amountJunior The amount to deposit to senior tranche
    /// @param assetJunior The asset to deposit to senior tranche
    function depositBoth(uint256 amountSenior, address assetSenior, uint256 amountJunior, address assetJunior) external {
        depositSenior(amountSenior, assetSenior);
        depositJunior(amountJunior, assetJunior);
    }

    /// @notice Migrate tokens to ZivoeDAO.
    /// @dev    This function MUST only be callable after the ITO concludes (or earlier at ZVL discretion).
    function migrateDeposits() external {
        require(end != 0, "ZivoeITO::migrateDeposits() end == 0");
        if (_msgSender() != IZivoeGlobals_ITO(GBL).ZVL()) {
            require(block.timestamp > end, "ZivoeITO::migrateDeposits() block.timestamp <= end");
        }
        require(!migrated, "ZivoeITO::migrateDeposits() migrated");
        
        migrated = true;
        snapshotSTT = IERC20(IZivoeGlobals_ITO(GBL).zSTT()).totalSupply();
        snapshotJTT = IERC20(IZivoeGlobals_ITO(GBL).zJTT()).totalSupply();

        emit DepositsMigrated(
            IERC20(stables[0]).balanceOf(address(this)), 
            IERC20(stables[1]).balanceOf(address(this)), 
            IERC20(stables[2]).balanceOf(address(this)), 
            IERC20(stables[3]).balanceOf(address(this))
        );

        for (uint256 i = 0; i < stables.length; i++) {
            IERC20(stables[i]).safeTransfer(IZivoeGlobals_ITO(GBL).DAO(), IERC20(stables[i]).balanceOf(address(this)));
        }

        ITO_IZivoeYDL(IZivoeGlobals_ITO(GBL).YDL()).unlock();
        ITO_IZivoeTranches(IZivoeGlobals_ITO(GBL).ZVT()).unlock();
    }

    /// @notice Starts the ITO.
    /// @dev    Only callable by ZVL.
    function commence() external {
        require(end == 0, "ZivoeITO::commence() end !== 0");
        require(
            _msgSender() == IZivoeGlobals_ITO(GBL).ZVL(), 
            "ZivoeITO::commence() _msgSender() != IZivoeGlobals_ITO(GBL).ZVL()"
        );
        emit ITOCommenced(block.timestamp, block.timestamp + 30 days);
        end = block.timestamp + 30 days;
    }

}