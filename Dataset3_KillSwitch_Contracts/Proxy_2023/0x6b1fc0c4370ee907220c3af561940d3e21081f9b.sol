// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (interfaces/IERC4626.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";
import "../token/ERC20/extensions/IERC20Metadata.sol";

/**
 * @dev Interface of the ERC4626 "Tokenized Vault Standard", as defined in
 * https://eips.ethereum.org/EIPS/eip-4626[ERC-4626].
 *
 * _Available since v4.7._
 */
interface IERC4626 is IERC20, IERC20Metadata {
    event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares);

    event Withdraw(
        address indexed sender,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    /**
     * @dev Returns the address of the underlying token used for the Vault for accounting, depositing, and withdrawing.
     *
     * - MUST be an ERC-20 token contract.
     * - MUST NOT revert.
     */
    function asset() external view returns (address assetTokenAddress);

    /**
     * @dev Returns the total amount of the underlying asset that is “managed” by Vault.
     *
     * - SHOULD include any compounding that occurs from yield.
     * - MUST be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT revert.
     */
    function totalAssets() external view returns (uint256 totalManagedAssets);

    /**
     * @dev Returns the amount of shares that the Vault would exchange for the amount of assets provided, in an ideal
     * scenario where all the conditions are met.
     *
     * - MUST NOT be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT show any variations depending on the caller.
     * - MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
     * - MUST NOT revert.
     *
     * NOTE: This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
     * “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and
     * from.
     */
    function convertToShares(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Returns the amount of assets that the Vault would exchange for the amount of shares provided, in an ideal
     * scenario where all the conditions are met.
     *
     * - MUST NOT be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT show any variations depending on the caller.
     * - MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
     * - MUST NOT revert.
     *
     * NOTE: This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
     * “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and
     * from.
     */
    function convertToAssets(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Returns the maximum amount of the underlying asset that can be deposited into the Vault for the receiver,
     * through a deposit call.
     *
     * - MUST return a limited value if receiver is subject to some deposit limit.
     * - MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of assets that may be deposited.
     * - MUST NOT revert.
     */
    function maxDeposit(address receiver) external view returns (uint256 maxAssets);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their deposit at the current block, given
     * current on-chain conditions.
     *
     * - MUST return as close to and no more than the exact amount of Vault shares that would be minted in a deposit
     *   call in the same transaction. I.e. deposit should return the same or more shares as previewDeposit if called
     *   in the same transaction.
     * - MUST NOT account for deposit limits like those returned from maxDeposit and should always act as though the
     *   deposit would be accepted, regardless if the user has enough tokens approved, etc.
     * - MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToShares and previewDeposit SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by depositing.
     */
    function previewDeposit(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Mints shares Vault shares to receiver by depositing exactly amount of underlying tokens.
     *
     * - MUST emit the Deposit event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   deposit execution, and are accounted for during deposit.
     * - MUST revert if all of assets cannot be deposited (due to deposit limit being reached, slippage, the user not
     *   approving enough underlying tokens to the Vault contract, etc).
     *
     * NOTE: most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
     */
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    /**
     * @dev Returns the maximum amount of the Vault shares that can be minted for the receiver, through a mint call.
     * - MUST return a limited value if receiver is subject to some mint limit.
     * - MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of shares that may be minted.
     * - MUST NOT revert.
     */
    function maxMint(address receiver) external view returns (uint256 maxShares);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their mint at the current block, given
     * current on-chain conditions.
     *
     * - MUST return as close to and no fewer than the exact amount of assets that would be deposited in a mint call
     *   in the same transaction. I.e. mint should return the same or fewer assets as previewMint if called in the
     *   same transaction.
     * - MUST NOT account for mint limits like those returned from maxMint and should always act as though the mint
     *   would be accepted, regardless if the user has enough tokens approved, etc.
     * - MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToAssets and previewMint SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by minting.
     */
    function previewMint(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Mints exactly shares Vault shares to receiver by depositing amount of underlying tokens.
     *
     * - MUST emit the Deposit event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the mint
     *   execution, and are accounted for during mint.
     * - MUST revert if all of shares cannot be minted (due to deposit limit being reached, slippage, the user not
     *   approving enough underlying tokens to the Vault contract, etc).
     *
     * NOTE: most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
     */
    function mint(uint256 shares, address receiver) external returns (uint256 assets);

    /**
     * @dev Returns the maximum amount of the underlying asset that can be withdrawn from the owner balance in the
     * Vault, through a withdraw call.
     *
     * - MUST return a limited value if owner is subject to some withdrawal limit or timelock.
     * - MUST NOT revert.
     */
    function maxWithdraw(address owner) external view returns (uint256 maxAssets);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their withdrawal at the current block,
     * given current on-chain conditions.
     *
     * - MUST return as close to and no fewer than the exact amount of Vault shares that would be burned in a withdraw
     *   call in the same transaction. I.e. withdraw should return the same or fewer shares as previewWithdraw if
     *   called
     *   in the same transaction.
     * - MUST NOT account for withdrawal limits like those returned from maxWithdraw and should always act as though
     *   the withdrawal would be accepted, regardless if the user has enough shares, etc.
     * - MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToShares and previewWithdraw SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by depositing.
     */
    function previewWithdraw(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Burns shares from owner and sends exactly assets of underlying tokens to receiver.
     *
     * - MUST emit the Withdraw event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   withdraw execution, and are accounted for during withdraw.
     * - MUST revert if all of assets cannot be withdrawn (due to withdrawal limit being reached, slippage, the owner
     *   not having enough shares, etc).
     *
     * Note that some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
     * Those methods should be performed separately.
     */
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);

    /**
     * @dev Returns the maximum amount of Vault shares that can be redeemed from the owner balance in the Vault,
     * through a redeem call.
     *
     * - MUST return a limited value if owner is subject to some withdrawal limit or timelock.
     * - MUST return balanceOf(owner) if owner is not subject to any withdrawal limit or timelock.
     * - MUST NOT revert.
     */
    function maxRedeem(address owner) external view returns (uint256 maxShares);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their redeemption at the current block,
     * given current on-chain conditions.
     *
     * - MUST return as close to and no more than the exact amount of assets that would be withdrawn in a redeem call
     *   in the same transaction. I.e. redeem should return the same or more assets as previewRedeem if called in the
     *   same transaction.
     * - MUST NOT account for redemption limits like those returned from maxRedeem and should always act as though the
     *   redemption would be accepted, regardless if the user has enough shares, etc.
     * - MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToAssets and previewRedeem SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by redeeming.
     */
    function previewRedeem(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Burns exactly shares from owner and sends assets of underlying tokens to receiver.
     *
     * - MUST emit the Withdraw event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   redeem execution, and are accounted for during redeem.
     * - MUST revert if all of shares cannot be redeemed (due to withdrawal limit being reached, slippage, the owner
     *   not having enough shares, etc).
     *
     * NOTE: some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
     * Those methods should be performed separately.
     */
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);
}
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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

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
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
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
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
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
// OpenZeppelin Contracts (last updated v4.9.5) (utils/Multicall.sol)

pragma solidity ^0.8.0;

import "./Address.sol";
import "./Context.sol";

/**
 * @dev Provides a function to batch together multiple calls in a single external call.
 *
 * Consider any assumption about calldata validation performed by the sender may be violated if it's not especially
 * careful about sending transactions invoking {multicall}. For example, a relay address that filters function
 * selectors won't filter calls nested within a {multicall} operation.
 *
 * NOTE: Since 5.0.1 and 4.9.4, this contract identifies non-canonical contexts (i.e. `msg.sender` is not {_msgSender}).
 * If a non-canonical context is identified, the following self `delegatecall` appends the last bytes of `msg.data`
 * to the subcall. This makes it safe to use with {ERC2771Context}. Contexts that don't affect the resolution of
 * {_msgSender} are not propagated to subcalls.
 *
 * _Available since v4.1._
 */
abstract contract Multicall is Context {
    /**
     * @dev Receives and executes a batch of function calls on this contract.
     * @custom:oz-upgrades-unsafe-allow-reachable delegatecall
     */
    function multicall(bytes[] calldata data) external virtual returns (bytes[] memory results) {
        bytes memory context = msg.sender == _msgSender()
            ? new bytes(0)
            : msg.data[msg.data.length - _contextSuffixLength():];

        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            results[i] = Address.functionDelegateCall(address(this), bytes.concat(data[i], context));
        }
        return results;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

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
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
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
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1, "Math: mulDiv overflow");

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
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
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
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
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
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
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
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.18;

contract Governance {
    /// @notice Emitted when the governance address is updated.
    event GovernanceTransferred(
        address indexed previousGovernance,
        address indexed newGovernance
    );

    modifier onlyGovernance() {
        _checkGovernance();
        _;
    }

    /// @notice Checks if the msg sender is the governance.
    function _checkGovernance() internal view virtual {
        require(governance == msg.sender, "!governance");
    }

    /// @notice Address that can set the default base fee and provider
    address public governance;

    constructor(address _governance) {
        governance = _governance;

        emit GovernanceTransferred(address(0), _governance);
    }

    /**
     * @notice Sets a new address as the governance of the contract.
     * @dev Throws if the caller is not current governance.
     * @param _newGovernance The new governance address.
     */
    function transferGovernance(
        address _newGovernance
    ) external virtual onlyGovernance {
        require(_newGovernance != address(0), "ZERO ADDRESS");
        address oldGovernance = governance;
        governance = _newGovernance;

        emit GovernanceTransferred(oldGovernance, _newGovernance);
    }
}
// SPDX-License-Identifier: GNU AGPLv3
pragma solidity >=0.8.18;

import {IVault} from "@yearn-vaults/interfaces/IVault.sol";
import {Governance} from "@periphery/utils/Governance.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

interface IBaseFee {
    function basefee_global() external view returns (uint256);
}

/**
 * @title YearnV3  Debt Allocator
 * @author yearn.finance
 * @notice
 *  This Debt Allocator is meant to be used alongside
 *  Yearn V3 vaults to provide the needed triggers for a keeper
 *  to perform automated debt updates for the vaults strategies.
 *
 * @dev
 *  Each vault that should be managed by this allocator will
 *  need to be added by first setting a `minimumChange` for the
 *  vault, which will act as the minimum amount of funds to move that will
 *  trigger a debt update. Then adding each strategy by setting a
 *  `targetRatio` and optionally a `maxRatio`.
 *
 *  The allocator aims to allocate debt between the strategies
 *  based on their set target ratios. Which are denominated in basis
 *  points and represent the percent of total assets that specific
 *  strategy should hold (i.e 1_000 == 10% of the vaults `totalAssets`).
 *
 *  The trigger will attempt to allocate up to the `maxRatio` when
 *  the strategy has `minimumChange` amount less than the `targetRatio`.
 *  And will pull funds to the `targetRatio` when it has `minimumChange`
 *  more than its `maxRatio`.
 */
contract DebtAllocator is Governance {
    /// @notice An event emitted when the base fee provider is set.
    event UpdatedBaseFeeProvider(address baseFeeProvider);

    /// @notice An event emitted when a keeper is added or removed.
    event UpdateKeeper(address indexed keeper, bool allowed);

    /// @notice An event emitted when the max base fee is updated.
    event UpdateMaxAcceptableBaseFee(uint256 newMaxAcceptableBaseFee);

    /// @notice An event emitted when a strategies debt ratios are Updated.
    event UpdateStrategyDebtRatio(
        address indexed vault,
        address indexed strategy,
        uint256 newTargetRatio,
        uint256 newMaxRatio,
        uint256 newTotalDebtRatio
    );

    /// @notice An event emitted when a strategy is added or removed.
    event StrategyChanged(
        address indexed vault,
        address indexed strategy,
        Status status
    );

    /// @notice An event emitted when the minimum change is updated.
    event UpdateMinimumChange(address indexed vault, uint256 newMinimumChange);

    /// @notice An even emitted when the paused status is updated.
    event UpdatePaused(address indexed vault, bool indexed status);

    /// @notice An event emitted when the minimum time to wait is updated.
    event UpdateMinimumWait(uint256 newMinimumWait);

    /// @notice An event emitted when a keeper is added or removed.
    event UpdateManager(address indexed manager, bool allowed);

    /// @notice An event emitted when the max debt update loss is updated.
    event UpdateMaxDebtUpdateLoss(uint256 newMaxDebtUpdateLoss);

    /// @notice Status when a strategy is added or removed from the allocator.
    enum Status {
        NULL,
        ADDED,
        REMOVED
    }

    /// @notice Struct for each strategies info.
    struct StrategyConfig {
        // Flag to set when a strategy is added.
        bool added;
        // The ideal percent in Basis Points the strategy should have.
        uint16 targetRatio;
        // The max percent of assets the strategy should hold.
        uint16 maxRatio;
        // Timestamp of the last time debt was updated.
        // The debt updates must be done through this allocator
        // for this to be used.
        uint96 lastUpdate;
        // We have an extra 120 bits in the slot.
        // So we declare the variable in the struct so it can be
        // used if this contract is inherited.
        uint120 open;
    }

    /// @notice Struct to hold the vault's info.
    struct VaultConfig {
        // Optional flag to stop the triggers.
        bool paused;
        // The minimum amount denominated in asset that will
        // need to be moved to trigger a debt update.
        uint128 minimumChange;
        // Total debt ratio currently allocated in basis points.
        // Can't be more than 10_000.
        uint16 totalDebtRatio;
    }

    /// @notice Used during the `shouldUpdateDebt` to hold the data.
    struct StrategyDebtInfo {
        VaultConfig vaultConfig;
        StrategyConfig strategyConfig;
        uint256 vaultAssets;
        uint256 targetDebt;
        uint256 maxDebt;
        uint256 currentIdle;
        uint256 minIdle;
        uint256 toChange;
    }

    /// @notice Make sure the caller is governance or a manager.
    modifier onlyManagers() {
        _isManager();
        _;
    }

    /// @notice Make sure the caller is a keeper
    modifier onlyKeepers() {
        _isKeeper();
        _;
    }

    /// @notice Check is either factories governance or local manager.
    function _isManager() internal view virtual {
        require(managers[msg.sender] || msg.sender == governance, "!manager");
    }

    /// @notice Check is one of the allowed keepers.
    function _isKeeper() internal view virtual {
        require(keepers[msg.sender], "!keeper");
    }

    uint256 internal constant MAX_BPS = 10_000;

    /// @notice Time to wait between debt updates in seconds.
    uint256 public minimumWait;

    /// @notice Provider to read current block's base fee.
    address public baseFeeProvider;

    /// @notice Max loss to accept on debt updates in basis points.
    uint256 public maxDebtUpdateLoss;

    /// @notice Max the chains base fee can be during debt update.
    // Will default to max uint256 and need to be set to be used.
    uint256 public maxAcceptableBaseFee;

    /// @notice Mapping of addresses that are allowed to update debt.
    mapping(address => bool) public keepers;

    /// @notice Mapping of addresses that are allowed to update debt ratios.
    mapping(address => bool) public managers;

    mapping(address => VaultConfig) internal _vaultConfigs;

    /// @notice Mapping of vault => strategy => its config.
    mapping(address => mapping(address => StrategyConfig))
        internal _strategyConfigs;

    constructor() Governance(msg.sender) {}

    /**
     * @notice Initialize the contract after being cloned.
     * @dev Sets default values for the global variables.
     */
    function initialize(address _governance) external {
        require(governance == address(0), "initialized");
        require(_governance != address(0), "ZERO ADDRESS");

        governance = _governance;
        emit GovernanceTransferred(address(0), _governance);

        // Default max base fee to uint max.
        maxAcceptableBaseFee = type(uint256).max;

        // Default to allow 1 BP loss.
        maxDebtUpdateLoss = 1;

        // Default minimum wait to 6 hours
        minimumWait = 60 * 60 * 6;

        // Default to allow governance to be a keeper.
        keepers[_governance] = true;
        emit UpdateKeeper(_governance, true);
    }

    /**
     * @notice Debt update wrapper for the vault.
     * @dev This contract must have the DEBT_MANAGER role assigned to them.
     *
     *   This will also uses the `maxUpdateDebtLoss` during debt
     *   updates to assure decreases did not realize profits outside
     *   of the allowed range.
     */
    function update_debt(
        address _vault,
        address _strategy,
        uint256 _targetDebt
    ) public virtual onlyKeepers {
        // If going to 0 record full balance first.
        if (_targetDebt == 0) {
            IVault(_vault).process_report(_strategy);
        }

        // Update debt with the default max loss.
        IVault(_vault).update_debt(_strategy, _targetDebt, maxDebtUpdateLoss);

        // Update the last time the strategies debt was updated.
        _strategyConfigs[_vault][_strategy].lastUpdate = uint96(
            block.timestamp
        );
    }

    /**
     * @notice Check if a strategy's debt should be updated.
     * @dev This should be called by a keeper to decide if a strategies
     * debt should be updated and if so by how much.
     *
     * @param _vault Address of the vault to update.
     * @param _strategy Address of the strategy to check.
     * @return . Bool representing if the debt should be updated.
     * @return . Calldata if `true` or reason if `false`.
     */
    function shouldUpdateDebt(
        address _vault,
        address _strategy
    ) public view virtual returns (bool, bytes memory) {
        // Store all local variables in a struct to avoid stack to deep
        StrategyDebtInfo memory strategyDebtInfo;

        strategyDebtInfo.vaultConfig = getVaultConfig(_vault);

        // Don't do anything if paused.
        if (strategyDebtInfo.vaultConfig.paused) {
            return (false, bytes("Paused"));
        }

        // Check the base fee isn't too high.
        if (!isCurrentBaseFeeAcceptable()) return (false, bytes("Base Fee"));

        // Get the strategy specific debt config.
        strategyDebtInfo.strategyConfig = getStrategyConfig(_vault, _strategy);

        // Make sure the strategy has been added to the allocator.
        if (!strategyDebtInfo.strategyConfig.added) {
            return (false, bytes("!added"));
        }

        if (
            block.timestamp - strategyDebtInfo.strategyConfig.lastUpdate <=
            minimumWait
        ) {
            return (false, bytes("min wait"));
        }

        // Retrieve the strategy specific parameters.
        IVault.StrategyParams memory params = IVault(_vault).strategies(
            _strategy
        );
        // Make sure its an active strategy.
        require(params.activation != 0, "!active");

        strategyDebtInfo.vaultAssets = IVault(_vault).totalAssets();

        // Get the target debt for the strategy based on vault assets.
        strategyDebtInfo.targetDebt = Math.min(
            (strategyDebtInfo.vaultAssets *
                strategyDebtInfo.strategyConfig.targetRatio) / MAX_BPS,
            // Make sure it is not more than the max allowed.
            params.max_debt
        );

        // Get the max debt we would want the strategy to have.
        strategyDebtInfo.maxDebt = Math.min(
            (strategyDebtInfo.vaultAssets *
                strategyDebtInfo.strategyConfig.maxRatio) / MAX_BPS,
            // Make sure it is not more than the max allowed.
            params.max_debt
        );

        // If we need to add more.
        if (strategyDebtInfo.targetDebt > params.current_debt) {
            strategyDebtInfo.currentIdle = IVault(_vault).totalIdle();
            strategyDebtInfo.minIdle = IVault(_vault).minimum_total_idle();

            // We can't add more than the available idle.
            if (strategyDebtInfo.minIdle >= strategyDebtInfo.currentIdle) {
                return (false, bytes("No Idle"));
            }

            // Add up to the max if possible
            strategyDebtInfo.toChange = Math.min(
                strategyDebtInfo.maxDebt - params.current_debt,
                // Can't take more than is available.
                Math.min(
                    strategyDebtInfo.currentIdle - strategyDebtInfo.minIdle,
                    IVault(_strategy).maxDeposit(_vault)
                )
            );

            // If the amount to add is over our threshold.
            if (
                strategyDebtInfo.toChange >
                strategyDebtInfo.vaultConfig.minimumChange
            ) {
                // Return true and the calldata.
                return (
                    true,
                    abi.encodeCall(
                        this.update_debt,
                        (
                            _vault,
                            _strategy,
                            params.current_debt + strategyDebtInfo.toChange
                        )
                    )
                );
            }
            // If current debt is greater than our max.
        } else if (strategyDebtInfo.maxDebt < params.current_debt) {
            strategyDebtInfo.toChange =
                params.current_debt -
                strategyDebtInfo.targetDebt;

            strategyDebtInfo.currentIdle = IVault(_vault).totalIdle();
            strategyDebtInfo.minIdle = IVault(_vault).minimum_total_idle();

            if (strategyDebtInfo.minIdle > strategyDebtInfo.currentIdle) {
                // Pull at least the amount needed for minIdle.
                strategyDebtInfo.toChange = Math.max(
                    strategyDebtInfo.toChange,
                    strategyDebtInfo.minIdle - strategyDebtInfo.currentIdle
                );
            }

            // Find out by how much. Aim for the target.
            strategyDebtInfo.toChange = Math.min(
                strategyDebtInfo.toChange,
                // Account for the current liquidity constraints.
                // Use max redeem to match vault logic.
                IVault(_strategy).convertToAssets(
                    IVault(_strategy).maxRedeem(_vault)
                )
            );

            // Check if it's over the threshold.
            if (
                strategyDebtInfo.toChange >
                strategyDebtInfo.vaultConfig.minimumChange
            ) {
                // Can't lower debt if there are unrealised losses.
                if (
                    IVault(_vault).assess_share_of_unrealised_losses(
                        _strategy,
                        params.current_debt
                    ) != 0
                ) {
                    return (false, bytes("unrealised loss"));
                }

                // If so return true and the calldata.
                return (
                    true,
                    abi.encodeCall(
                        this.update_debt,
                        (
                            _vault,
                            _strategy,
                            params.current_debt - strategyDebtInfo.toChange
                        )
                    )
                );
            }
        }

        // Either no change or below our minimumChange.
        return (false, bytes("Below Min"));
    }

    /*//////////////////////////////////////////////////////////////
                        STRATEGY MANAGEMENT
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Increase a strategies target debt ratio.
     * @dev `setStrategyDebtRatio` functions will do all needed checks.
     * @param _strategy The address of the strategy to increase the debt ratio for.
     * @param _increase The amount in Basis Points to increase it.
     */
    function increaseStrategyDebtRatio(
        address _vault,
        address _strategy,
        uint256 _increase
    ) external virtual {
        setStrategyDebtRatio(
            _vault,
            _strategy,
            getStrategyTargetRatio(_vault, _strategy) + _increase
        );
    }

    /**
     * @notice Decrease a strategies target debt ratio.
     * @param _strategy The address of the strategy to decrease the debt ratio for.
     * @param _decrease The amount in Basis Points to decrease it.
     */
    function decreaseStrategyDebtRatio(
        address _vault,
        address _strategy,
        uint256 _decrease
    ) external virtual {
        setStrategyDebtRatio(
            _vault,
            _strategy,
            getStrategyTargetRatio(_vault, _strategy) - _decrease
        );
    }

    /**
     * @notice Sets a new target debt ratio for a strategy.
     * @dev This will default to a 20% increase for max debt.
     *
     * @param _strategy Address of the strategy to set.
     * @param _targetRatio Amount in Basis points to allocate.
     */
    function setStrategyDebtRatio(
        address _vault,
        address _strategy,
        uint256 _targetRatio
    ) public virtual {
        uint256 maxRatio = Math.min((_targetRatio * 12_000) / MAX_BPS, MAX_BPS);
        setStrategyDebtRatio(_vault, _strategy, _targetRatio, maxRatio);
    }

    /**
     * @notice Sets a new target debt ratio for a strategy.
     * @dev A `minimumChange` for that strategy must be set first.
     * This is to prevent debt from being updated too frequently.
     *
     * @param _vault Address of the vault
     * @param _strategy Address of the strategy to set.
     * @param _targetRatio Amount in Basis points to allocate.
     * @param _maxRatio Max ratio to give on debt increases.
     */
    function setStrategyDebtRatio(
        address _vault,
        address _strategy,
        uint256 _targetRatio,
        uint256 _maxRatio
    ) public virtual onlyManagers {
        VaultConfig memory vaultConfig = getVaultConfig(_vault);
        // Make sure a minimumChange has been set.
        require(vaultConfig.minimumChange != 0, "!minimum");
        // Cannot be more than 100%.
        require(_maxRatio <= MAX_BPS, "max too high");
        // Max cannot be lower than the target.
        require(_maxRatio >= _targetRatio, "max ratio");

        // Get the current config.
        StrategyConfig memory strategyConfig = getStrategyConfig(
            _vault,
            _strategy
        );

        // Set added flag if not set yet.
        if (!strategyConfig.added) {
            strategyConfig.added = true;
            emit StrategyChanged(_vault, _strategy, Status.ADDED);
        }

        // Get what will be the new total debt ratio.
        uint256 newTotalDebtRatio = vaultConfig.totalDebtRatio -
            strategyConfig.targetRatio +
            _targetRatio;

        // Make sure it is under 100% allocated
        require(newTotalDebtRatio <= MAX_BPS, "ratio too high");

        // Update local config.
        strategyConfig.targetRatio = uint16(_targetRatio);
        strategyConfig.maxRatio = uint16(_maxRatio);

        // Write to storage.
        _strategyConfigs[_vault][_strategy] = strategyConfig;
        _vaultConfigs[_vault].totalDebtRatio = uint16(newTotalDebtRatio);

        emit UpdateStrategyDebtRatio(
            _vault,
            _strategy,
            _targetRatio,
            _maxRatio,
            newTotalDebtRatio
        );
    }

    /**
     * @notice Remove a strategy from this debt allocator.
     * @dev Will delete the full config for the strategy
     * @param _vault Address of the vault
     * @param _strategy Address of the address ro remove.
     */
    function removeStrategy(
        address _vault,
        address _strategy
    ) external virtual onlyManagers {
        StrategyConfig memory strategyConfig = getStrategyConfig(
            _vault,
            _strategy
        );
        require(strategyConfig.added, "!added");

        uint256 target = strategyConfig.targetRatio;

        // Remove any debt ratio the strategy holds.
        if (target != 0) {
            uint256 newRatio = _vaultConfigs[_vault].totalDebtRatio - target;
            _vaultConfigs[_vault].totalDebtRatio = uint16(newRatio);
            emit UpdateStrategyDebtRatio(_vault, _strategy, 0, 0, newRatio);
        }

        // Remove the full config including the `added` flag.
        delete _strategyConfigs[_vault][_strategy];

        // Emit Event.
        emit StrategyChanged(_vault, _strategy, Status.REMOVED);
    }

    /*//////////////////////////////////////////////////////////////
                        VAULT MANAGEMENT
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Set the minimum change variable for a strategy.
     * @dev This is the minimum amount of debt to be
     * added or pulled for it to trigger an update.
     *
     * @param _vault Address of the vault
     * @param _minimumChange The new minimum to set for the strategy.
     */
    function setMinimumChange(
        address _vault,
        uint256 _minimumChange
    ) external virtual onlyGovernance {
        require(_minimumChange > 0, "zero change");
        // Make sure it fits in the slot size.
        require(_minimumChange < type(uint128).max, "too high");

        // Set the new minimum.
        _vaultConfigs[_vault].minimumChange = uint128(_minimumChange);

        emit UpdateMinimumChange(_vault, _minimumChange);
    }

    /**
     * @notice Allows governance to pause the triggers.
     * @param _vault Address of the vault
     * @param _status Status to set the `paused` bool to.
     */
    function setPaused(
        address _vault,
        bool _status
    ) external virtual onlyGovernance {
        require(_status != _vaultConfigs[_vault].paused, "already set");
        _vaultConfigs[_vault].paused = _status;

        emit UpdatePaused(_vault, _status);
    }

    /*//////////////////////////////////////////////////////////////
                        ALLOCATOR MANAGEMENT
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Set the minimum time to wait before re-updating a strategies debt.
     * @dev This is only enforced per strategy.
     * @param _minimumWait The minimum time in seconds to wait.
     */
    function setMinimumWait(
        uint256 _minimumWait
    ) external virtual onlyGovernance {
        minimumWait = _minimumWait;

        emit UpdateMinimumWait(_minimumWait);
    }

    /**
     * @notice Set if a manager can update ratios.
     * @param _address The address to set mapping for.
     * @param _allowed If the address can call {update_debt}.
     */
    function setManager(
        address _address,
        bool _allowed
    ) external virtual onlyGovernance {
        managers[_address] = _allowed;

        emit UpdateManager(_address, _allowed);
    }

    /**
     * @notice Set the max loss in Basis points to allow on debt updates.
     * @dev Withdrawing during debt updates use {redeem} which allows for 100% loss.
     *      This can be used to assure a loss is not realized on redeem outside the tolerance.
     * @param _maxDebtUpdateLoss The max loss to accept on debt updates.
     */
    function setMaxDebtUpdateLoss(
        uint256 _maxDebtUpdateLoss
    ) external virtual onlyGovernance {
        require(_maxDebtUpdateLoss <= MAX_BPS, "higher than max");
        maxDebtUpdateLoss = _maxDebtUpdateLoss;

        emit UpdateMaxDebtUpdateLoss(_maxDebtUpdateLoss);
    }

    /**
     * @notice
     *  Used to set our baseFeeProvider, which checks the network's current base
     *  fee price to determine whether it is an optimal time to harvest or tend.
     *
     *  This may only be called by governance.
     * @param _baseFeeProvider Address of our baseFeeProvider
     */
    function setBaseFeeProvider(
        address _baseFeeProvider
    ) external virtual onlyGovernance {
        baseFeeProvider = _baseFeeProvider;

        emit UpdatedBaseFeeProvider(_baseFeeProvider);
    }

    /**
     * @notice Set the max acceptable base fee.
     * @dev This defaults to max uint256 and will need to
     * be set for it to be used.
     *
     * Is denominated in gwei. So 50gwei would be set as 50e9.
     *
     * @param _maxAcceptableBaseFee The new max base fee.
     */
    function setMaxAcceptableBaseFee(
        uint256 _maxAcceptableBaseFee
    ) external virtual onlyGovernance {
        maxAcceptableBaseFee = _maxAcceptableBaseFee;

        emit UpdateMaxAcceptableBaseFee(_maxAcceptableBaseFee);
    }

    /**
     * @notice Set if a keeper can update debt.
     * @param _address The address to set mapping for.
     * @param _allowed If the address can call {update_debt}.
     */
    function setKeeper(
        address _address,
        bool _allowed
    ) external virtual onlyGovernance {
        keepers[_address] = _allowed;

        emit UpdateKeeper(_address, _allowed);
    }

    /**
     * @notice Get a strategies full config.
     * @dev Used for customizations by inheriting the contract.
     * @param _vault Address of the vault
     * @param _strategy Address of the strategy.
     * @return The strategies current Config.
     */
    function getStrategyConfig(
        address _vault,
        address _strategy
    ) public view virtual returns (StrategyConfig memory) {
        return _strategyConfigs[_vault][_strategy];
    }

    /**
     * @notice Get a vaults full config.
     * @dev Used for customizations by inheriting the contract.
     * @param _vault Address of the vault.
     * @return The vaults current Config.
     */
    function getVaultConfig(
        address _vault
    ) public view virtual returns (VaultConfig memory) {
        return _vaultConfigs[_vault];
    }

    /**
     * @notice Get a vaults current total debt.
     * @param _vault Address of the vault
     */
    function totalDebtRatio(
        address _vault
    ) external view virtual returns (uint256) {
        return getVaultConfig(_vault).totalDebtRatio;
    }

    /**
     * @notice Get a vaults minimum change required.
     * @param _vault Address of the vault
     */
    function minimumChange(
        address _vault
    ) external view virtual returns (uint256) {
        return getVaultConfig(_vault).minimumChange;
    }

    /**
     * @notice Get the paused status of a vault
     * @param _vault Address of the vault
     */
    function isPaused(address _vault) public view virtual returns (bool) {
        return getVaultConfig(_vault).paused;
    }

    /**
     * @notice Get a strategies target debt ratio.
     * @param _vault Address of the vault
     * @param _strategy Address of the strategy.
     * @return The strategies current targetRatio.
     */
    function getStrategyTargetRatio(
        address _vault,
        address _strategy
    ) public view virtual returns (uint256) {
        return getStrategyConfig(_vault, _strategy).targetRatio;
    }

    /**
     * @notice Get a strategies max debt ratio.
     * @param _vault Address of the vault
     * @param _strategy Address of the strategy.
     * @return The strategies current maxRatio.
     */
    function getStrategyMaxRatio(
        address _vault,
        address _strategy
    ) public view virtual returns (uint256) {
        return getStrategyConfig(_vault, _strategy).maxRatio;
    }

    /**
     * @notice Returns wether or not the current base fee is acceptable
     *   based on the `maxAcceptableBaseFee`.
     * @return . If the current base fee is acceptable.
     */
    function isCurrentBaseFeeAcceptable() public view virtual returns (bool) {
        address _baseFeeProvider = baseFeeProvider;
        if (_baseFeeProvider == address(0)) return true;
        return
            maxAcceptableBaseFee >= IBaseFee(_baseFeeProvider).basefee_global();
    }
}
// SPDX-License-Identifier: GNU AGPLv3
pragma solidity >=0.8.18;

import {DebtAllocator} from "./DebtAllocator.sol";
import {Multicall} from "@openzeppelin/contracts/utils/Multicall.sol";

contract DebtOptimizerApplicator is Multicall {
    /// @notice An event emitted when a keeper is added or removed.
    event UpdateManager(address indexed manager, bool allowed);

    /// @notice struct for debt ratio changes
    struct StrategyDebtRatio {
        address strategy;
        uint256 targetRatio;
        uint256 maxRatio;
    }

    /// @notice Make sure the caller is governance.
    modifier onlyGovernance() {
        _isGovernance();
        _;
    }

    /// @notice Make sure the caller is governance or a manager.
    modifier onlyManagers() {
        _isManager();
        _;
    }

    /// @notice Check the Factories governance address.
    function _isGovernance() internal view virtual {
        require(
            msg.sender == DebtAllocator(debtAllocator).governance(),
            "!governance"
        );
    }

    /// @notice Check is either factories governance or local manager.
    function _isManager() internal view virtual {
        require(
            managers[msg.sender] ||
                msg.sender == DebtAllocator(debtAllocator).governance(),
            "!manager"
        );
    }

    /// @notice The address of the debt allocator.
    address public immutable debtAllocator;

    /// @notice Mapping of addresses that are allowed to update debt ratios.
    mapping(address => bool) public managers;

    constructor(address _debtAllocator) {
        debtAllocator = _debtAllocator;
    }

    /**
     * @notice Set if a manager can update ratios.
     * @param _address The address to set mapping for.
     * @param _allowed If the address can call {update_debt}.
     */
    function setManager(
        address _address,
        bool _allowed
    ) external virtual onlyGovernance {
        managers[_address] = _allowed;

        emit UpdateManager(_address, _allowed);
    }

    function setStrategyDebtRatios(
        address _vault,
        StrategyDebtRatio[] calldata _strategyDebtRatios
    ) public onlyManagers {
        for (uint8 i; i < _strategyDebtRatios.length; ++i) {
            if (_strategyDebtRatios[i].maxRatio == 0) {
                DebtAllocator(debtAllocator).setStrategyDebtRatio(
                    _vault,
                    _strategyDebtRatios[i].strategy,
                    _strategyDebtRatios[i].targetRatio
                );
            } else {
                DebtAllocator(debtAllocator).setStrategyDebtRatio(
                    _vault,
                    _strategyDebtRatios[i].strategy,
                    _strategyDebtRatios[i].targetRatio,
                    _strategyDebtRatios[i].maxRatio
                );
            }
        }
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.18;

import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";

interface IVault is IERC4626 {
    // STRATEGY EVENTS
    event StrategyChanged(address indexed strategy, uint256 change_type);
    event StrategyReported(
        address indexed strategy,
        uint256 gain,
        uint256 loss,
        uint256 current_debt,
        uint256 protocol_fees,
        uint256 total_fees,
        uint256 total_refunds
    );
    // DEBT MANAGEMENT EVENTS
    event DebtUpdated(
        address indexed strategy,
        uint256 current_debt,
        uint256 new_debt
    );
    // ROLE UPDATES
    event RoleSet(address indexed account, uint256 role);
    event UpdateRoleManager(address indexed role_manager);

    event UpdateAccountant(address indexed accountant);
    event UpdateDefaultQueue(address[] new_default_queue);
    event UpdateUseDefaultQueue(bool use_default_queue);
    event UpdatedMaxDebtForStrategy(
        address indexed sender,
        address indexed strategy,
        uint256 new_debt
    );
    event UpdateAutoAllocate(bool auto_allocate);
    event UpdateDepositLimit(uint256 deposit_limit);
    event UpdateMinimumTotalIdle(uint256 minimum_total_idle);
    event UpdateProfitMaxUnlockTime(uint256 profit_max_unlock_time);
    event DebtPurchased(address indexed strategy, uint256 amount);
    event Shutdown();

    struct StrategyParams {
        uint256 activation;
        uint256 last_report;
        uint256 current_debt;
        uint256 max_debt;
    }

    function FACTORY() external view returns (uint256);

    function strategies(address) external view returns (StrategyParams memory);

    function default_queue(uint256) external view returns (address);

    function use_default_queue() external view returns (bool);

    function auto_allocate() external view returns (bool);

    function minimum_total_idle() external view returns (uint256);

    function deposit_limit() external view returns (uint256);

    function deposit_limit_module() external view returns (address);

    function withdraw_limit_module() external view returns (address);

    function accountant() external view returns (address);

    function roles(address) external view returns (uint256);

    function role_manager() external view returns (address);

    function future_role_manager() external view returns (address);

    function isShutdown() external view returns (bool);

    function nonces(address) external view returns (uint256);

    function initialize(
        address,
        string memory,
        string memory,
        address,
        uint256
    ) external;

    function setName(string memory) external;

    function setSymbol(string memory) external;

    function set_accountant(address new_accountant) external;

    function set_default_queue(address[] memory new_default_queue) external;

    function set_use_default_queue(bool) external;

    function set_auto_allocate(bool) external;

    function set_deposit_limit(uint256 deposit_limit) external;

    function set_deposit_limit(
        uint256 deposit_limit,
        bool should_override
    ) external;

    function set_deposit_limit_module(
        address new_deposit_limit_module
    ) external;

    function set_deposit_limit_module(
        address new_deposit_limit_module,
        bool should_override
    ) external;

    function set_withdraw_limit_module(
        address new_withdraw_limit_module
    ) external;

    function set_minimum_total_idle(uint256 minimum_total_idle) external;

    function setProfitMaxUnlockTime(
        uint256 new_profit_max_unlock_time
    ) external;

    function set_role(address account, uint256 role) external;

    function add_role(address account, uint256 role) external;

    function remove_role(address account, uint256 role) external;

    function transfer_role_manager(address role_manager) external;

    function accept_role_manager() external;

    function unlockedShares() external view returns (uint256);

    function pricePerShare() external view returns (uint256);

    function get_default_queue() external view returns (address[] memory);

    function process_report(
        address strategy
    ) external returns (uint256, uint256);

    function buy_debt(address strategy, uint256 amount) external;

    function add_strategy(address new_strategy) external;

    function revoke_strategy(address strategy) external;

    function force_revoke_strategy(address strategy) external;

    function update_max_debt_for_strategy(
        address strategy,
        uint256 new_max_debt
    ) external;

    function update_debt(
        address strategy,
        uint256 target_debt
    ) external returns (uint256);

    function update_debt(
        address strategy,
        uint256 target_debt,
        uint256 max_loss
    ) external returns (uint256);

    function shutdown_vault() external;

    function totalIdle() external view returns (uint256);

    function totalDebt() external view returns (uint256);

    function apiVersion() external view returns (string memory);

    function assess_share_of_unrealised_losses(
        address strategy,
        uint256 assets_needed
    ) external view returns (uint256);

    function profitMaxUnlockTime() external view returns (uint256);

    function fullProfitUnlockDate() external view returns (uint256);

    function profitUnlockingRate() external view returns (uint256);

    function lastProfitUpdate() external view returns (uint256);

    //// NON-STANDARD ERC-4626 FUNCTIONS \\\\

    function withdraw(
        uint256 assets,
        address receiver,
        address owner,
        uint256 max_loss
    ) external returns (uint256);

    function withdraw(
        uint256 assets,
        address receiver,
        address owner,
        uint256 max_loss,
        address[] memory strategies
    ) external returns (uint256);

    function redeem(
        uint256 shares,
        address receiver,
        address owner,
        uint256 max_loss
    ) external returns (uint256);

    function redeem(
        uint256 shares,
        address receiver,
        address owner,
        uint256 max_loss,
        address[] memory strategies
    ) external returns (uint256);

    function maxWithdraw(
        address owner,
        uint256 max_loss
    ) external view returns (uint256);

    function maxWithdraw(
        address owner,
        uint256 max_loss,
        address[] memory strategies
    ) external view returns (uint256);

    function maxRedeem(
        address owner,
        uint256 max_loss
    ) external view returns (uint256);

    function maxRedeem(
        address owner,
        uint256 max_loss,
        address[] memory strategies
    ) external view returns (uint256);

    //// NON-STANDARD ERC-20 FUNCTIONS \\\\

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (bool);
}