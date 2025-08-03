// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.20 ^0.8.0 ^0.8.7;

// contracts/interfaces/IMplUserActions.sol

interface IMplUserActions {

    /**************************************************************************************************************************************/
    /*** Events                                                                                                                         ***/
    /**************************************************************************************************************************************/

    event MigratedAndStaked(
        address indexed sender,
        address assetSent,
        uint256 amountSent,
        address indexed receiver,
        address assetReceived,
        uint256 amountReceived
    );

    event RedeemedAndMigrated(
        address indexed sender,
        address assetSent,
        uint256 amountSent,
        address indexed receiver,
        address assetReceived,
        uint256 amountReceived
    );

    event RedeemedAndMigratedAndStaked(
        address indexed sender,
        address assetSent,
        uint256 amountSent,
        address indexed receiver,
        address assetReceived,
        uint256 amountReceived
    );

    /**************************************************************************************************************************************/
    /*** State Variables                                                                                                                ***/
    /**************************************************************************************************************************************/

    /**
     *  @dev    Returns the address of the MPL migrator contract.
     *  @return migrator Address of the migrator contract.
     */
    function migrator() external returns (address migrator);

    /**
     *  @dev    Returns the address of the MPL contract.
     *  @return mpl Address of the MPL contract.
     */
    function mpl() external returns (address mpl);

    /**
     *  @dev    Returns the address of the stSYRUP contract.
     *  @return stsyrup Address of the stSYRUP contract.
     */
    function stsyrup() external returns (address stsyrup);

    /**
     *  @dev    Returns the address of the SYRUP contract.
     *  @return syrup Address of the SYRUP contract.
     */
    function syrup() external returns (address syrup);

    /**
     *  @dev    Returns the address of the xMPL contract.
     *  @return xmpl Address of the xMPL contract.
     */
    function xmpl() external returns (address xmpl);

    /**************************************************************************************************************************************/
    /*** User Actions                                                                                                                   ***/
    /**************************************************************************************************************************************/

    /**
     *  @dev    Migrates MPL to SYRUP and then stakes it.
     *  @param  receiver   Address that will receive stSYRUP.
     *  @param  mplIn      Amount of MPL to migrate.
     *  @return stsyrupOut Amount of stSYRUP received.
     */
    function migrateAndStake(address receiver, uint256 mplIn) external returns (uint256 stsyrupOut);

    /**
     *  @dev    Migrates MPL to SYRUP and then stakes it.
     *          Approves the transfer of MPL with the use of a permit signature.
     *  @param  receiver   Address that will receive stSYRUP.
     *  @param  mplIn      Amount of MPL to migrate.
     *  @param  deadline   The deadline of the permit.
     *  @param  v          The v value of the permit signature.
     *  @param  r          The r value of the permit signature.
     *  @param  s          The s value of the permit signature.
     *  @return stsyrupOut Amount of stSYRUP received.
     */
    function migrateAndStakeWithPermit(
        address receiver,
        uint256 mplIn,
        uint256 deadline,
        uint8   v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 stsyrupOut);

    /**
     *  @dev    Redeems xMPL into MPL and then migrates it to SYRUP.
     *  @param  receiver Address that will receive SYRUP.
     *  @param  xmplIn   Amount of xMPL to redeem.
     *  @return syrupOut Amount of SYRUP received.
     */
    function redeemAndMigrate(address receiver, uint256 xmplIn) external returns (uint256 syrupOut);

    /**
     *  @dev    Redeems xMPL into MPL and then migrates it to SYRUP.
     *          Approves the transfer of xMPL with the use of a permit signature.
     *  @param  receiver Address that will receive SYRUP.
     *  @param  xmplIn   Amount of xMPL to redeem.
     *  @param  deadline The deadline of the permit.
     *  @param  v        The v value of the permit signature.
     *  @param  r        The r value of the permit signature.
     *  @param  s        The s value of the permit signature.
     *  @return syrupOut Amount of SYRUP received.
     */
    function redeemAndMigrateWithPermit(
        address receiver,
        uint256 xmplIn,
        uint256 deadline,
        uint8   v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 syrupOut);

    /**
     *  @dev    Redeems xMPL into MPL, migrates it to SYRUP, and then stakes it.
     *  @param  receiver   Address that will receive stSYRUP.
     *  @param  xmplIn     Amount of xMPL to redeem.
     *  @return stsyrupOut Amount of stSYRUP received.
     */
    function redeemAndMigrateAndStake(address receiver, uint256 xmplIn) external returns (uint256 stsyrupOut);

    /**
     *  @dev    Redeems xMPL into MPL, migrates it to SYRUP, and then stakes it.
     *          Approves the transfer of xMPL with the use of a permit signature.
     *  @param  receiver   sAddress that will receive stSYRUP.
     *  @param  xmplIn     Amount of xMPL to redeem.
     *  @param  deadline   The deadline of the permit.
     *  @param  v          The v value of the permit signature.
     *  @param  r          The r value of the permit signature.
     *  @param  s          The s value of the permit signature.
     *  @return stsyrupOut Amount of stSYRUP received.
     */
    function redeemAndMigrateAndStakeWithPermit(
        address receiver,
        uint256 xmplIn,
        uint256 deadline,
        uint8   v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 stsyrupOut);

}

// contracts/interfaces/Interfaces.sol

interface IBalancerVaultLike {

    enum SwapKind { GIVEN_IN, GIVEN_OUT }

    struct FundManagement {
        address sender;
        bool fromInternalBalance;
        address recipient;
        bool toInternalBalance;
    }

    struct SingleSwap {
        bytes32 poolId;
        SwapKind kind;
        address assetIn;
        address assetOut;
        uint256 amount;
        bytes userData;
    }

    function swap(
        SingleSwap calldata singleSwap,
        FundManagement calldata funds,
        uint256 limit,
        uint256 deadline
    ) external returns (uint256 assetDelta);

}

interface IERC20Like_0 {

    function allowance(address owner, address spender) external view returns (uint256 allowance);

    function balanceOf(address account) external view returns (uint256 balance);

    function DOMAIN_SEPARATOR() external view returns (bytes32 domainSeparator);

    function PERMIT_TYPEHASH() external view returns (bytes32 permitTypehash);

    function approve(address spender, uint256 amount) external returns (bool success);

    function permit(address owner, address spender, uint amount, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    function transfer(address recipient, uint256 amount) external returns (bool success);

    function transferFrom(address owner, address recipient, uint256 amount) external returns (bool success);

}

interface IGlobalsLike {

    function governor() external view returns (address governor);

    function operationalAdmin() external view returns (address operationalAdmin);

}

interface IMigratorLike {

    function migrate(address receiver, uint256 mplAmount) external returns (uint256 syrupAmount);

}

interface IPoolLike is IERC20Like_0 {

    function asset() external view returns (address asset);

    function convertToExitAssets(uint256 shares) external view returns (uint256);

    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    function manager() external view returns (address manager);

}

interface IPoolManagerLike {

    function poolPermissionManager() external view returns (address poolPermissionManager);

}

interface IPoolPermissionManagerLike {

    function hasPermission(address poolManager, address lender, bytes32 functionId) external view returns (bool hasPermission);

    function permissionAdmins(address account) external view returns (bool isAdmin);

    function setLenderBitmaps(address[] calldata lenders, uint256[] calldata bitmaps) external;

}

interface IPSMLike {

    function buyGem(address account, uint256 daiAmount) external;

    function tout() external view returns (uint256 tout);  // This is the fee charged for conversion

}

interface ISDaiLike {

    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);

}

interface IRDTLike {

    function asset() external view returns (address asset);

    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);

}

interface IStakedSyrupLike {

    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

}

// modules/erc20-helper/src/interfaces/IERC20Like.sol

/// @title Interface of the ERC20 standard as needed by ERC20Helper.
interface IERC20Like_1 {

    function approve(address spender_, uint256 amount_) external returns (bool success_);

    function transfer(address recipient_, uint256 amount_) external returns (bool success_);

    function transferFrom(address owner_, address recipient_, uint256 amount_) external returns (bool success_);

}

// modules/erc20-helper/src/ERC20Helper.sol

/**
 * @title Small Library to standardize erc20 token interactions.
 */
library ERC20Helper {

    /**************************************************************************************************************************************/
    /*** Internal Functions                                                                                                             ***/
    /**************************************************************************************************************************************/

    function transfer(address token_, address to_, uint256 amount_) internal returns (bool success_) {
        return _call(token_, abi.encodeWithSelector(IERC20Like_1.transfer.selector, to_, amount_));
    }

    function transferFrom(address token_, address from_, address to_, uint256 amount_) internal returns (bool success_) {
        return _call(token_, abi.encodeWithSelector(IERC20Like_1.transferFrom.selector, from_, to_, amount_));
    }

    function approve(address token_, address spender_, uint256 amount_) internal returns (bool success_) {
        // If setting approval to zero fails, return false.
        if (!_call(token_, abi.encodeWithSelector(IERC20Like_1.approve.selector, spender_, uint256(0)))) return false;

        // If `amount_` is zero, return true as the previous step already did this.
        if (amount_ == uint256(0)) return true;

        // Return the result of setting the approval to `amount_`.
        return _call(token_, abi.encodeWithSelector(IERC20Like_1.approve.selector, spender_, amount_));
    }

    function _call(address token_, bytes memory data_) private returns (bool success_) {
        if (token_.code.length == uint256(0)) return false;

        bytes memory returnData;
        ( success_, returnData ) = token_.call(data_);

        return success_ && (returnData.length == uint256(0) || abi.decode(returnData, (bool)));
    }

}

// contracts/MplUserActions.sol

contract MplUserActions is IMplUserActions {

    /**************************************************************************************************************************************/
    /*** State Variables                                                                                                                ***/
    /**************************************************************************************************************************************/

    address public immutable override migrator;
    address public immutable override mpl;
    address public immutable override stsyrup;
    address public immutable override syrup;
    address public immutable override xmpl;

    /**************************************************************************************************************************************/
    /*** Constructor                                                                                                                    ***/
    /**************************************************************************************************************************************/

    constructor(address migrator_, address xmpl_, address stsyrup_) {
        address mpl_   = IRDTLike(xmpl_).asset();
        address syrup_ = IRDTLike(stsyrup_).asset();

        migrator = migrator_;
        mpl      = mpl_;
        syrup    = syrup_;
        xmpl     = xmpl_;
        stsyrup  = stsyrup_;

        require(ERC20Helper.approve(mpl_,   migrator_, type(uint256).max), "MUA:C:MPL_APPROVE");
        require(ERC20Helper.approve(syrup_, stsyrup_,  type(uint256).max), "MUA:C:SYRUP_APPROVE");
    }

    /**************************************************************************************************************************************/
    /*** User Actions                                                                                                                   ***/
    /**************************************************************************************************************************************/

    // MPL -> SYRUP -> stSYRUP
    function migrateAndStake(address receiver_, uint256 mplIn_) external override returns (uint256 stsyrupOut_) {
        stsyrupOut_ = _migrateAndStake(receiver_, mplIn_);
    }

    // MPL -> SYRUP -> stSYRUP
    function migrateAndStakeWithPermit(
        address receiver_,
        uint256 mplIn_,
        uint256 deadline_,
        uint8   v_,
        bytes32 r_,
        bytes32 s_
    )
        external override returns (uint256 stsyrupOut_)
    {
        _permit(mpl, deadline_, mplIn_, v_, r_, s_);

        stsyrupOut_ = _migrateAndStake(receiver_, mplIn_);
    }

    // xMPL -> MPL -> SYRUP
    function redeemAndMigrate(address receiver_, uint256 xmplIn_) external override returns (uint256 syrupOut_) {
        syrupOut_ = _redeemAndMigrate(receiver_, xmplIn_);
    }

    // xMPL -> MPL -> SYRUP
    function redeemAndMigrateWithPermit(
        address receiver_,
        uint256 xmplIn_,
        uint256 deadline_,
        uint8   v_,
        bytes32 r_,
        bytes32 s_
    )
        external override returns (uint256 syrupOut_)
    {
        _permit(xmpl, deadline_, xmplIn_, v_, r_, s_);

        syrupOut_ = _redeemAndMigrate(receiver_, xmplIn_);
    }

    // xMPL -> MPL -> SYRUP -> stSYRUP
    function redeemAndMigrateAndStake(address receiver_, uint256 xmplIn_) external override returns (uint256 stsyrupOut_) {
        stsyrupOut_ = _redeemAndMigrateAndStake(receiver_, xmplIn_);
    }

    // xMPL -> MPL -> SYRUP -> stSYRUP
    function redeemAndMigrateAndStakeWithPermit(
        address receiver_,
        uint256 xmplIn_,
        uint256 deadline_,
        uint8   v_,
        bytes32 r_,
        bytes32 s_
    )
        external override returns (uint256 stsyrupOut_)
    {
        _permit(xmpl, deadline_, xmplIn_, v_, r_, s_);

        stsyrupOut_ = _redeemAndMigrateAndStake(receiver_, xmplIn_);
    }

    /**************************************************************************************************************************************/
    /*** Internal Functions                                                                                                             ***/
    /**************************************************************************************************************************************/

    // MPL -> SYRUP -> stSYRUP
    function _migrateAndStake(address receiver_, uint256 mplIn_) internal returns (uint256 stsyrupOut_) {
        require(mplIn_ > 0,                                                       "MUA:MAS:ZERO_AMOUNT");
        require(ERC20Helper.transferFrom(mpl, msg.sender, address(this), mplIn_), "MUA:MAS:TRANSFER_FAIL");

        uint256 syrupAmount_ = _migrate(address(this), mplIn_);
        stsyrupOut_          = _stake(receiver_, syrupAmount_);

        emit MigratedAndStaked(msg.sender, mpl, mplIn_, receiver_, stsyrup, stsyrupOut_);
    }

    // MPL -> SYRUP
    function _migrate(address receiver_, uint256 mplIn_) internal returns (uint256 syrupOut_) {
        syrupOut_ = IMigratorLike(migrator).migrate(receiver_, mplIn_);
    }

    function _permit(address asset_, uint256 deadline_, uint256 amount_, uint8 v_, bytes32 r_, bytes32 s_) internal {
        uint256 allowance_ = IERC20Like_0(asset_).allowance(msg.sender, address(this));

        if (allowance_ < amount_) {
            IERC20Like_0(asset_).permit(msg.sender, address(this), amount_, deadline_, v_, r_, s_);
        }
    }

    // xMPL -> MPL
    function _redeem(address receiver_, uint256 xmplIn_) internal returns (uint256 mplOut_) {
        mplOut_ = IRDTLike(xmpl).redeem(xmplIn_, receiver_, address(this));
    }

    // xMPL -> MPL -> SYRUP
    function _redeemAndMigrate(address receiver_, uint256 xmplIn_) internal returns (uint256 syrupOut_) {
        require(xmplIn_ > 0,                                                        "MUA:RAM:ZERO_AMOUNT");
        require(ERC20Helper.transferFrom(xmpl, msg.sender, address(this), xmplIn_), "MUA:RAM:TRANSFER_FAIL");

        uint256 mplAmount_ = _redeem(address(this), xmplIn_);
        syrupOut_          = _migrate(receiver_, mplAmount_);

        emit RedeemedAndMigrated(msg.sender, xmpl, xmplIn_, receiver_, syrup, syrupOut_);
    }

    // xMPL -> MPL -> SYRUP -> stSYRUP
    function _redeemAndMigrateAndStake(address receiver_, uint256 xmplIn_) internal returns (uint256 stsyrupOut_) {
        require(xmplIn_ > 0,                                                        "MUA:RAMAS:ZERO_AMOUNT");
        require(ERC20Helper.transferFrom(xmpl, msg.sender, address(this), xmplIn_), "MUA:RAMAS:TRANSFER_FAIL");

        uint256 mplAmount_   = _redeem(address(this), xmplIn_);
        uint256 syrupAmount_ = _migrate(address(this), mplAmount_);
        stsyrupOut_          = _stake(receiver_, syrupAmount_);

        emit RedeemedAndMigratedAndStaked(msg.sender, xmpl, xmplIn_, receiver_, stsyrup, stsyrupOut_);
    }

    // SYRUP -> stSYRUP
    function _stake(address receiver_, uint256 syrupIn_) internal returns (uint256 stsyrupOut_) {
        stsyrupOut_ = IRDTLike(stsyrup).deposit(syrupIn_, receiver_);
    }

}