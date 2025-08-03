// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

/// @dev Interface of the ERC20 standard as defined in the EIP.
/// @dev This includes the optional name, symbol, and decimals metadata.
interface IERC20 {
    /// @dev Emitted when `value` tokens are moved from one account (`from`) to another (`to`).
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @dev Emitted when the allowance of a `spender` for an `owner` is set, where `value`
    /// is the new allowance.
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @notice Returns the amount of tokens in existence.
    function totalSupply() external view returns (uint256);

    /// @notice Returns the amount of tokens owned by `account`.
    function balanceOf(address account) external view returns (uint256);

    /// @notice Moves `amount` tokens from the caller's account to `to`.
    function transfer(address to, uint256 amount) external returns (bool);

    /// @notice Returns the remaining number of tokens that `spender` is allowed
    /// to spend on behalf of `owner`
    function allowance(address owner, address spender) external view returns (uint256);

    /// @notice Sets `amount` as the allowance of `spender` over the caller's tokens.
    /// @dev Be aware of front-running risks: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    function approve(address spender, uint256 amount) external returns (bool);

    /// @notice Moves `amount` tokens from `from` to `to` using the allowance mechanism.
    /// `amount` is then deducted from the caller's allowance.
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    /// @notice Returns the name of the token.
    function name() external view returns (string memory);

    /// @notice Returns the symbol of the token.
    function symbol() external view returns (string memory);

    /// @notice Returns the decimals places of the token.
    function decimals() external view returns (uint8);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

import "./IERC20.sol";

/// @dev Interface of the ERC4626 "Tokenized Vault Standard", as defined in
/// https://eips.ethereum.org/EIPS/eip-4626
interface IERC4626 is IERC20 {
    event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares);

    event Withdraw(
        address indexed sender, address indexed receiver, address indexed owner, uint256 assets, uint256 shares
    );

    /// @notice Returns the address of the underlying token used for the Vault for accounting, depositing, and withdrawing.
    /// @dev
    /// - MUST be an ERC-20 token contract.
    /// - MUST NOT revert.
    function asset() external view returns (address assetTokenAddress);

    /// @notice Returns the total amount of the underlying asset that is “managed” by Vault.
    /// @dev
    /// - SHOULD include any compounding that occurs from yield.
    /// - MUST be inclusive of any fees that are charged against assets in the Vault.
    /// - MUST NOT revert.
    function totalAssets() external view returns (uint256 totalManagedAssets);

    /// @notice Returns the amount of shares that the Vault would exchange for the amount of assets provided, in an ideal
    /// scenario where all the conditions are met.
    /// @dev
    /// - MUST NOT be inclusive of any fees that are charged against assets in the Vault.
    /// - MUST NOT show any variations depending on the caller.
    /// - MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
    /// - MUST NOT revert.
    ///
    /// NOTE: This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
    /// “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and
    /// from.
    function convertToShares(uint256 assets) external view returns (uint256 shares);

    /// @notice Returns the amount of assets that the Vault would exchange for the amount of shares provided, in an ideal
    /// scenario where all the conditions are met.
    /// @dev
    /// - MUST NOT be inclusive of any fees that are charged against assets in the Vault.
    /// - MUST NOT show any variations depending on the caller.
    /// - MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
    /// - MUST NOT revert.
    ///
    /// NOTE: This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
    /// “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and
    /// from.
    function convertToAssets(uint256 shares) external view returns (uint256 assets);

    /// @notice Returns the maximum amount of the underlying asset that can be deposited into the Vault for the receiver,
    /// through a deposit call.
    /// @dev
    /// - MUST return a limited value if receiver is subject to some deposit limit.
    /// - MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of assets that may be deposited.
    /// - MUST NOT revert.
    function maxDeposit(address receiver) external view returns (uint256 maxAssets);

    /// @notice Allows an on-chain or off-chain user to simulate the effects of their deposit at the current block, given
    /// current on-chain conditions.
    /// @dev
    /// - MUST return as close to and no more than the exact amount of Vault shares that would be minted in a deposit
    ///   call in the same transaction. I.e. deposit should return the same or more shares as previewDeposit if called
    ///   in the same transaction.
    /// - MUST NOT account for deposit limits like those returned from maxDeposit and should always act as though the
    ///   deposit would be accepted, regardless if the user has enough tokens approved, etc.
    /// - MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
    /// - MUST NOT revert.
    ///
    /// NOTE: any unfavorable discrepancy between convertToShares and previewDeposit SHOULD be considered slippage in
    /// share price or some other type of condition, meaning the depositor will lose assets by depositing.
    function previewDeposit(uint256 assets) external view returns (uint256 shares);

    /// @notice Mints shares Vault shares to receiver by depositing exactly amount of underlying tokens.
    /// @dev
    /// - MUST emit the Deposit event.
    /// - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
    ///   deposit execution, and are accounted for during deposit.
    /// - MUST revert if all of assets cannot be deposited (due to deposit limit being reached, slippage, the user not
    ///   approving enough underlying tokens to the Vault contract, etc).
    ///
    /// NOTE: most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    /// @notice Returns the maximum amount of the Vault shares that can be minted for the receiver, through a mint call.
    /// @dev
    /// - MUST return a limited value if receiver is subject to some mint limit.
    /// - MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of shares that may be minted.
    /// - MUST NOT revert.
    function maxMint(address receiver) external view returns (uint256 maxShares);

    /// @notice Allows an on-chain or off-chain user to simulate the effects of their mint at the current block, given
    /// current on-chain conditions.
    /// @dev
    /// - MUST return as close to and no fewer than the exact amount of assets that would be deposited in a mint call
    ///   in the same transaction. I.e. mint should return the same or fewer assets as previewMint if called in the
    ///   same transaction.
    /// - MUST NOT account for mint limits like those returned from maxMint and should always act as though the mint
    ///   would be accepted, regardless if the user has enough tokens approved, etc.
    /// - MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
    /// - MUST NOT revert.
    ///
    /// NOTE: any unfavorable discrepancy between convertToAssets and previewMint SHOULD be considered slippage in
    /// share price or some other type of condition, meaning the depositor will lose assets by minting.
    function previewMint(uint256 shares) external view returns (uint256 assets);

    /// @notice Mints exactly shares Vault shares to receiver by depositing amount of underlying tokens.
    /// @dev
    /// - MUST emit the Deposit event.
    /// - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the mint
    ///   execution, and are accounted for during mint.
    /// - MUST revert if all of shares cannot be minted (due to deposit limit being reached, slippage, the user not
    ///   approving enough underlying tokens to the Vault contract, etc).
    ///
    /// NOTE: most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
    function mint(uint256 shares, address receiver) external returns (uint256 assets);

    /// @notice Returns the maximum amount of the underlying asset that can be withdrawn from the owner balance in the
    /// Vault, through a withdraw call.
    /// @dev
    /// - MUST return a limited value if owner is subject to some withdrawal limit or timelock.
    /// - MUST NOT revert.
    function maxWithdraw(address owner) external view returns (uint256 maxAssets);

    /// @notice Allows an on-chain or off-chain user to simulate the effects of their withdrawal at the current block,
    /// given current on-chain conditions.
    /// @dev
    /// - MUST return as close to and no fewer than the exact amount of Vault shares that would be burned in a withdraw
    ///   call in the same transaction. I.e. withdraw should return the same or fewer shares as previewWithdraw if
    ///   called
    ///   in the same transaction.
    /// - MUST NOT account for withdrawal limits like those returned from maxWithdraw and should always act as though
    ///   the withdrawal would be accepted, regardless if the user has enough shares, etc.
    /// - MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
    /// - MUST NOT revert.
    ///
    /// NOTE: any unfavorable discrepancy between convertToShares and previewWithdraw SHOULD be considered slippage in
    /// share price or some other type of condition, meaning the depositor will lose assets by depositing.
    function previewWithdraw(uint256 assets) external view returns (uint256 shares);

    /// @notice Burns shares from owner and sends exactly assets of underlying tokens to receiver.
    /// @dev
    /// - MUST emit the Withdraw event.
    /// - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
    ///   withdraw execution, and are accounted for during withdraw.
    /// - MUST revert if all of assets cannot be withdrawn (due to withdrawal limit being reached, slippage, the owner
    ///   not having enough shares, etc).
    ///
    /// Note that some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
    /// Those methods should be performed separately.
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);

    /// @notice Returns the maximum amount of Vault shares that can be redeemed from the owner balance in the Vault,
    /// through a redeem call.
    /// @dev
    /// - MUST return a limited value if owner is subject to some withdrawal limit or timelock.
    /// - MUST return balanceOf(owner) if owner is not subject to any withdrawal limit or timelock.
    /// - MUST NOT revert.
    function maxRedeem(address owner) external view returns (uint256 maxShares);

    /// @notice Allows an on-chain or off-chain user to simulate the effects of their redeemption at the current block,
    /// given current on-chain conditions.
    /// @dev
    /// - MUST return as close to and no more than the exact amount of assets that would be withdrawn in a redeem call
    ///   in the same transaction. I.e. redeem should return the same or more assets as previewRedeem if called in the
    ///   same transaction.
    /// - MUST NOT account for redemption limits like those returned from maxRedeem and should always act as though the
    ///   redemption would be accepted, regardless if the user has enough shares, etc.
    /// - MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
    /// - MUST NOT revert.
    ///
    /// NOTE: any unfavorable discrepancy between convertToAssets and previewRedeem SHOULD be considered slippage in
    /// share price or some other type of condition, meaning the depositor will lose assets by redeeming.
    function previewRedeem(uint256 shares) external view returns (uint256 assets);

    /// @notice Burns exactly shares from owner and sends assets of underlying tokens to receiver.
    /// @dev
    /// - MUST emit the Withdraw event.
    /// - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
    ///   redeem execution, and are accounted for during redeem.
    /// - MUST revert if all of shares cannot be redeemed (due to withdrawal limit being reached, slippage, the owner
    ///   not having enough shares, etc).
    ///
    /// NOTE: some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
    /// Those methods should be performed separately.
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);
}
// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.25;

import { IERC20 }   from "lib/forge-std/src/interfaces/IERC20.sol";
import { IERC4626 } from "lib/forge-std/src/interfaces/IERC4626.sol";

interface JoinLike {
    function vat() external view returns (VatLike);
    function join(address, uint256) external;
    function exit(address, uint256) external;
}

interface VatLike {
    function hope(address) external;
}

/**
 * @notice Actions for migrating from DAI/sDAI to USDS/sUSDS.
 * @dev    Also contains 1 downgrade path from USDS to DAI for convenience.
 */
contract MigrationActions {

    IERC20   public immutable dai;
    IERC20   public immutable usds;
    IERC4626 public immutable sdai;
    IERC4626 public immutable susds;

    VatLike  public immutable vat;
    JoinLike public immutable daiJoin;
    JoinLike public immutable usdsJoin;

    constructor(
        address _sdai,
        address _susds,
        address _daiJoin,
        address _usdsJoin
    ) {
        sdai  = IERC4626(_sdai);
        susds = IERC4626(_susds);

        dai  = IERC20(sdai.asset());
        usds = IERC20(susds.asset());

        daiJoin  = JoinLike(_daiJoin);
        usdsJoin = JoinLike(_usdsJoin);
        vat      = daiJoin.vat();

        // Infinite approvals
        dai.approve(_daiJoin,   type(uint256).max);
        usds.approve(_usdsJoin, type(uint256).max);
        usds.approve(_susds,    type(uint256).max);

        // Vat permissioning
        vat.hope(_daiJoin);
        vat.hope(_usdsJoin);
    }

    /**
     * @notice Migrate `assetsIn` of `dai` to `usds`.
     * @param  receiver The receiver of `usds`.
     * @param  assetsIn The amount of `dai` to migrate.
     */
    function migrateDAIToUSDS(address receiver, uint256 assetsIn) public {
        dai.transferFrom(msg.sender, address(this), assetsIn);
        _migrateDAIToUSDS(receiver, assetsIn);
    }

    /**
     * @notice Migrate `assetsIn` of `dai` to `susds`.
     * @param  receiver  The receiver of `susds`.
     * @param  assetsIn  The amount of `dai` to migrate.
     * @return sharesOut The amount of `susds` shares received.
     */
    function migrateDAIToSUSDS(address receiver, uint256 assetsIn) external returns (uint256 sharesOut) {
        migrateDAIToUSDS(address(this), assetsIn);
        sharesOut = susds.deposit(assetsIn, receiver);
    }

    /**
     * @notice Migrate `assetsIn` of `sdai` to `usds`.
     * @param  receiver The receiver of `usds`.
     * @param  assetsIn The amount of `sdai` to migrate in assets.
     */
    function migrateSDAIAssetsToUSDS(address receiver, uint256 assetsIn) public {
        sdai.withdraw(assetsIn, address(this), msg.sender);
        _migrateDAIToUSDS(receiver, assetsIn);
    }

    /**
     * @notice Migrate `sharesIn` of `sdai` to `usds`.
     * @param  receiver  The receiver of `usds`.
     * @param  sharesIn  The amount of `sdai` to migrate in shares.
     * @return assetsOut The amount of `usds` assets received.
     */
    function migrateSDAISharesToUSDS(address receiver, uint256 sharesIn) public returns (uint256 assetsOut) {
        assetsOut = sdai.redeem(sharesIn, address(this), msg.sender);
        _migrateDAIToUSDS(receiver, assetsOut);
    }

    /**
     * @notice Migrate `assetsIn` of `sdai` (denominated in `dai`) to `susds`.
     * @param  receiver  The receiver of `susds`.
     * @param  assetsIn  The amount of `sdai` to migrate (denominated in `dai`).
     * @return sharesOut The amount of `susds` shares received.
     */
    function migrateSDAIAssetsToSUSDS(address receiver, uint256 assetsIn) external returns (uint256 sharesOut) {
        migrateSDAIAssetsToUSDS(address(this), assetsIn);
        sharesOut = susds.deposit(assetsIn, receiver);
    }

    /**
     * @notice Migrate `sharesIn` of `sdai` to `susds`.
     * @param  receiver  The receiver of `susds`.
     * @param  sharesIn  The amount of `sdai` to migrate in shares.
     * @return sharesOut The amount of `susds` shares received.
     */
    function migrateSDAISharesToSUSDS(address receiver, uint256 sharesIn) external returns (uint256 sharesOut) {
        uint256 assets = migrateSDAISharesToUSDS(address(this), sharesIn);
        sharesOut = susds.deposit(assets, receiver);
    }

    /**
     * @notice Downgrade `assetsIn` of `usds` to `dai`.
     * @param  receiver The receiver of `dai`.
     * @param  assetsIn The amount of `usds` to downgrade.
     */
    function downgradeUSDSToDAI(address receiver, uint256 assetsIn) external {
        usds.transferFrom(msg.sender, address(this), assetsIn);
        usdsJoin.join(address(this), assetsIn);
        daiJoin.exit(receiver,       assetsIn);
    }

    /**********************************************************************************************/
    /*** Internal helper functions                                                              ***/
    /**********************************************************************************************/

    function _migrateDAIToUSDS(address receiver, uint256 amount) internal {
        daiJoin.join(address(this), amount);
        usdsJoin.exit(receiver,     amount);
    }

}