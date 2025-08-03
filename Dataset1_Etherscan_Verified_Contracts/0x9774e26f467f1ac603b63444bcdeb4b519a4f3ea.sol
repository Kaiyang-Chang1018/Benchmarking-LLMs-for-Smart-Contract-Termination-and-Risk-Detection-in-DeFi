// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {
    IUniswapV3Pool,
    IUniswapV3PoolState,
    IUniswapV3PoolImmutables
} from "contracts/interfaces/external/uniswap/IUniswapV3Pool.sol";
import { INonfungiblePositionManager } from
    "contracts/interfaces/external/uniswap/INonfungiblePositionManager.sol";

import { Sickle } from "contracts/Sickle.sol";
import { INftSettingsRegistry } from
    "contracts/interfaces/INftSettingsRegistry.sol";
import {
    RewardBehavior,
    RewardConfig
} from "contracts/structs/PositionSettingsStructs.sol";
import {
    NftKey,
    NftSettings,
    ExitConfig,
    RebalanceConfig
} from "contracts/structs/NftSettingsStructs.sol";
import { SickleFactory } from "contracts/SickleFactory.sol";

interface IPreviousAutomation {
    function rewardAutomation(
        address user
    ) external returns (RewardBehavior);
    function harvestTokensOut(
        address user
    ) external returns (address);
}

interface IPreviousNftSettingsRegistry {
    struct PreviousRebalanceConfig {
        int24 bufferTicksBelow;
        int24 bufferTicksAbove;
        uint256 slippageBP;
        int24 cutoffTickLow;
        int24 cutoffTickHigh;
        uint8 delayMin;
    }

    struct PreviousNftSettings {
        bool autoRebalance;
        RewardBehavior rewardBehavior;
        address harvestTokenOut;
        PreviousRebalanceConfig rebalanceConfig;
    }

    function getNftSettings(
        NftKey memory key
    ) external returns (PreviousNftSettings memory);
}

contract NftSettingsRegistry is INftSettingsRegistry {
    error AutoHarvestNotSet();
    error AutoCompoundNotSet();
    error AutoRebalanceNotSet();
    error AutoExitNotSet();
    error CompoundOrHarvestNotSet();
    error CompoundAndHarvestBothSet();
    error ExitTriggersNotSet();
    error InvalidTokenOut();
    error InvalidMinMaxTickRange();
    error InvalidSlippageBP();
    error InvalidPriceImpactBP();
    error InvalidDustBP();
    error InvalidMinTickLow();
    error InvalidMaxTickHigh();
    error OnlySickle();
    error RebalanceConfigNotSet();
    error TickWithinRange();
    error TickOutsideStopLossRange();
    error SickleNotDeployed();
    error InvalidWidth(uint24 actual, uint24 expected);

    event NftSettingsSet(NftKey key, NftSettings settings);
    event NftSettingsUnset(NftKey key);

    uint256 constant MAX_SLIPPAGE_BP = 500;
    uint256 constant MAX_PRICE_IMPACT_BP = 5000;
    uint256 constant MAX_DUST_BP = 5000;
    int24 constant MAX_TICK = 887_272;
    int24 constant MIN_TICK = -MAX_TICK;

    SickleFactory public immutable factory;

    constructor(
        SickleFactory _factory
    ) {
        factory = _factory;
    }

    mapping(bytes32 => NftSettings) settingsMap;

    /* Public functions */

    function getNftSettings(
        NftKey memory key
    ) public view returns (NftSettings memory) {
        return settingsMap[keccak256(abi.encode(key))];
    }

    function validateHarvestFor(
        NftKey memory key
    ) public view {
        NftSettings memory settings = getNftSettings(key);
        if (
            !settings.automateRewards
                || settings.rewardConfig.rewardBehavior != RewardBehavior.Harvest
        ) {
            revert AutoHarvestNotSet();
        }
    }

    function validateCompoundFor(
        NftKey memory key
    ) public view {
        NftSettings memory settings = getNftSettings(key);
        if (
            !settings.automateRewards
                || settings.rewardConfig.rewardBehavior != RewardBehavior.Compound
        ) {
            revert AutoCompoundNotSet();
        }
    }

    // Validate that a rebalanceFor meets the user requirements
    function validateRebalanceFor(
        NftKey memory key
    ) public {
        NftSettings memory settings = getNftSettings(key);
        RebalanceConfig memory config = settings.rebalanceConfig;

        if (!settings.autoRebalance) {
            revert AutoRebalanceNotSet();
        }
        if (config.cutoffTickLow == 0) {
            revert RebalanceConfigNotSet();
        }

        (,,,,, int24 tickLower, int24 tickUpper,,,,,) =
            key.nftManager.positions(key.tokenId);

        int24 tick = _get_current_tick(settings.pool);

        if (
            tick >= tickLower - int24(config.bufferTicksBelow)
                && tick < tickUpper + int24(config.bufferTicksAbove)
        ) {
            revert TickWithinRange();
        }
        if (tick <= config.cutoffTickLow || tick >= config.cutoffTickHigh) {
            revert TickOutsideStopLossRange();
        }
    }

    function validateExitFor(
        NftKey memory key
    ) public {
        NftSettings memory settings = getNftSettings(key);
        ExitConfig memory config = settings.exitConfig;

        if (!settings.autoExit) {
            revert AutoExitNotSet();
        }

        int24 tick = _get_current_tick(settings.pool);

        if (tick >= config.triggerTickLow && tick < config.triggerTickHigh) {
            revert TickWithinRange();
        }
    }

    /* Sickle Owner functions */

    function setNftSettings(
        INonfungiblePositionManager nftManager,
        uint256 tokenId,
        NftSettings calldata settings
    ) external {
        Sickle sickle = _get_sickle_by_owner(msg.sender);
        NftKey memory key = NftKey(sickle, nftManager, tokenId);
        _set_nft_settings(key, settings);
    }

    function unsetNftSettings(
        INonfungiblePositionManager nftManager,
        uint256 tokenId
    ) external {
        Sickle sickle = _get_sickle_by_owner(msg.sender);
        NftKey memory key = NftKey(sickle, nftManager, tokenId);
        _unset_nft_settings(key);
    }

    /* Sickle (delegatecall) functions */

    function setNftSettings(
        NftKey calldata key,
        NftSettings calldata settings
    ) external {
        Sickle sickle = Sickle(payable(msg.sender));

        if (key.sickle != sickle) {
            revert OnlySickle();
        }

        _set_nft_settings(key, settings);
    }

    function resetNftSettings(
        NftKey calldata oldKey,
        NftKey calldata newKey,
        NftSettings calldata settings
    ) external {
        Sickle sickle = Sickle(payable(msg.sender));

        if (oldKey.sickle != sickle || newKey.sickle != sickle) {
            revert OnlySickle();
        }

        _unset_nft_settings(oldKey);

        _set_nft_settings(newKey, settings);
    }

    function migrateNftSettings(
        IPreviousAutomation automation,
        IPreviousNftSettingsRegistry previousNftSettingsRegistry,
        INonfungiblePositionManager nftManager,
        IUniswapV3Pool[] memory pools,
        uint256[] memory tokenIds
    ) external {
        Sickle sickle = _get_sickle_by_owner(msg.sender);

        uint256 tokenLength = tokenIds.length;
        for (uint256 i; i < tokenLength; i++) {
            NftKey memory key = NftKey(sickle, nftManager, tokenIds[i]);
            RebalanceConfig memory newConfig = _get_new_rebalance_config(
                previousNftSettingsRegistry, key, pools[i]
            );
            NftSettings memory settings =
                _get_new_nft_settings(automation, sickle, pools[i], newConfig);
            _set_nft_settings(key, settings);
        }
    }

    /* Modifiers */

    modifier checkConfigValues(NftKey memory key, NftSettings memory settings) {
        if (settings.autoRebalance) {
            _check_rebalance_config(settings.rebalanceConfig);
            _check_tick_width(key, settings);
        } else {
            if (
                settings.rebalanceConfig.cutoffTickLow != 0
                    || settings.rebalanceConfig.cutoffTickHigh != 0
            ) {
                revert AutoRebalanceNotSet();
            }
        }
        if (
            settings.rewardConfig.rewardBehavior != RewardBehavior.Harvest
                && settings.rewardConfig.harvestTokenOut != address(0)
        ) {
            revert InvalidTokenOut();
        }
        if (!settings.autoExit) {
            if (
                settings.exitConfig.triggerTickLow != 0
                    || settings.exitConfig.triggerTickHigh != 0
                    || settings.exitConfig.exitTokenOutLow != address(0)
                    || settings.exitConfig.exitTokenOutHigh != address(0)
                    || settings.exitConfig.slippageBP != 0
                    || settings.exitConfig.priceImpactBP != 0
            ) {
                revert AutoExitNotSet();
            }
        } else {
            if (
                settings.exitConfig.triggerTickLow == 0
                    && settings.exitConfig.triggerTickHigh == 0
            ) {
                revert ExitTriggersNotSet();
            }
            if (settings.exitConfig.slippageBP > MAX_SLIPPAGE_BP) {
                revert InvalidSlippageBP();
            }
            if (
                settings.exitConfig.priceImpactBP > MAX_PRICE_IMPACT_BP
                    || settings.exitConfig.priceImpactBP == 0
            ) {
                revert InvalidPriceImpactBP();
            }
        }
        _;
    }

    /* Internal */

    function _get_sickle_by_owner(
        address owner
    ) internal view returns (Sickle) {
        Sickle sickle = Sickle(payable(factory.sickles(owner)));
        if (address(sickle) == address(0)) {
            revert SickleNotDeployed();
        }
        return sickle;
    }

    function _set_nft_settings(
        NftKey memory key,
        NftSettings memory settings
    ) internal checkConfigValues(key, settings) {
        settingsMap[keccak256(abi.encode(key))] = settings;
        emit NftSettingsSet(key, settings);
    }

    function _unset_nft_settings(
        NftKey memory key
    ) internal {
        delete settingsMap[keccak256(abi.encode(key))];
        emit NftSettingsUnset(key);
    }

    // Tick is the 2nd field in slot0, the rest can vary
    function _get_current_tick(
        IUniswapV3Pool pool
    ) internal returns (int24) {
        (, bytes memory result) =
            address(pool).call(abi.encodeCall(IUniswapV3PoolState.slot0, ()));

        int24 tick;

        assembly {
            tick := mload(add(result, 64))
        }

        return tick;
    }

    // Check configuratgion parameters for errors
    function _check_rebalance_config(
        RebalanceConfig memory config
    ) internal pure {
        if (config.cutoffTickLow < MIN_TICK) {
            revert InvalidMinTickLow();
        }
        if (config.cutoffTickLow >= config.cutoffTickHigh) {
            revert InvalidMinMaxTickRange();
        }
        if (config.cutoffTickHigh > MAX_TICK) {
            revert InvalidMaxTickHigh();
        }
        if (config.slippageBP > MAX_SLIPPAGE_BP) {
            revert InvalidSlippageBP();
        }
        if (
            config.priceImpactBP > MAX_PRICE_IMPACT_BP
                || config.priceImpactBP == 0
        ) {
            revert InvalidPriceImpactBP();
        }
        if (config.dustBP > MAX_DUST_BP || config.dustBP == 0) {
            revert InvalidDustBP();
        }
        if (
            config.rewardConfig.rewardBehavior != RewardBehavior.Harvest
                && config.rewardConfig.harvestTokenOut != address(0)
        ) {
            revert InvalidTokenOut();
        }
    }

    function _check_tick_width(
        NftKey memory key,
        NftSettings memory settings
    ) internal view {
        (,,,,, int24 tickLower, int24 tickUpper,,,,,) =
            key.nftManager.positions(key.tokenId);
        int24 tickSpacing = settings.pool.tickSpacing();

        uint24 actualWidth = uint24(tickUpper - tickLower) / uint24(tickSpacing);
        uint24 expectedWidth = settings.rebalanceConfig.tickSpacesBelow
            + settings.rebalanceConfig.tickSpacesAbove + 1;

        if (actualWidth != expectedWidth) {
            revert InvalidWidth(actualWidth, expectedWidth);
        }
    }

    /* Migration internals */

    function _get_position_tick_spaces_each_side(
        NftKey memory key,
        IUniswapV3Pool pool
    ) private view returns (uint24 below, uint24 above) {
        (,,,,, int24 tickLower, int24 tickUpper,,,,,) =
            key.nftManager.positions(key.tokenId);
        int24 tickSpacing = pool.tickSpacing();
        uint24 totalSpaces = uint24((tickUpper - tickLower) / tickSpacing - 1);
        below = totalSpaces / 2;
        above = totalSpaces / 2 + totalSpaces % 2;
    }

    function _get_new_nft_settings(
        IPreviousAutomation automation,
        Sickle sickle,
        IUniswapV3Pool pool,
        RebalanceConfig memory newConfig
    ) internal returns (NftSettings memory) {
        address sickleOwner = sickle.owner();
        RewardBehavior rewardBehavior = automation.rewardAutomation(sickleOwner);

        return NftSettings({
            pool: pool,
            autoRebalance: true,
            rebalanceConfig: newConfig,
            automateRewards: rewardBehavior != RewardBehavior.None,
            rewardConfig: RewardConfig(
                rewardBehavior, automation.harvestTokensOut(sickleOwner)
            ),
            autoExit: false,
            exitConfig: ExitConfig(0, 0, address(0), address(0), 0, 0)
        });
    }

    function _get_new_rebalance_config(
        IPreviousNftSettingsRegistry previousNftSettingsRegistry,
        NftKey memory key,
        IUniswapV3Pool pool
    ) internal returns (RebalanceConfig memory) {
        IPreviousNftSettingsRegistry.PreviousNftSettings memory previousSettings =
            previousNftSettingsRegistry.getNftSettings(key);
        IPreviousNftSettingsRegistry.PreviousRebalanceConfig memory oldConfig =
            previousSettings.rebalanceConfig;
        (uint24 spacesBelow, uint24 spacesAbove) =
            _get_position_tick_spaces_each_side(key, pool);
        return RebalanceConfig(
            spacesBelow,
            spacesAbove,
            int24(oldConfig.bufferTicksBelow),
            int24(oldConfig.bufferTicksAbove),
            oldConfig.slippageBP,
            oldConfig.slippageBP,
            oldConfig.slippageBP,
            oldConfig.cutoffTickLow,
            oldConfig.cutoffTickHigh,
            oldConfig.delayMin,
            RewardConfig(
                previousSettings.rewardBehavior,
                previousSettings.harvestTokenOut
            )
        );
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { SickleStorage } from "contracts/base/SickleStorage.sol";
import { Multicall } from "contracts/base/Multicall.sol";
import { SickleRegistry } from "contracts/SickleRegistry.sol";

/// @title Sickle contract
/// @author vfat.tools
/// @notice Sickle facilitates farming and interactions with Masterchef
/// contracts
/// @dev Base contract inheriting from all the other "manager" contracts
contract Sickle is SickleStorage, Multicall {
    /// @notice Function to receive ETH
    receive() external payable { }

    /// @param sickleRegistry_ Address of the SickleRegistry contract
    constructor(
        SickleRegistry sickleRegistry_
    ) initializer Multicall(sickleRegistry_) {
        _Sickle_initialize(address(0), address(0));
    }

    /// @param sickleOwner_ Address of the Sickle owner
    function initialize(
        address sickleOwner_,
        address approved_
    ) external initializer {
        _Sickle_initialize(sickleOwner_, approved_);
    }

    /// INTERNALS ///

    function _Sickle_initialize(
        address sickleOwner_,
        address approved_
    ) internal {
        SickleStorage._SickleStorage_initialize(sickleOwner_, approved_);
    }

    function onERC721Received(
        address, // operator
        address, // from
        uint256, // tokenId
        bytes calldata // data
    ) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function onERC1155Received(
        address, // operator
        address, // from
        uint256, // id
        uint256, // value
        bytes calldata // data
    ) external pure returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address, // operator
        address, // from
        uint256[] calldata, // ids
        uint256[] calldata, // values
        bytes calldata // data
    ) external pure returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";
import { SickleRegistry } from "contracts/SickleRegistry.sol";
import { Sickle } from "contracts/Sickle.sol";
import { Admin } from "contracts/base/Admin.sol";

/// @title SickleFactory contract
/// @author vfat.tools
/// @notice Factory deploying new Sickle contracts
contract SickleFactory is Admin {
    /// EVENTS ///

    /// @notice Emitted when a new Sickle contract is deployed
    /// @param admin Address receiving the admin rights of the Sickle contract
    /// @param sickle Address of the newly deployed Sickle contract
    event Deploy(address indexed admin, address sickle);

    /// @notice Thrown when the caller is not whitelisted
    /// @param caller Address of the non-whitelisted caller
    error CallerNotWhitelisted(address caller); // 0x252c8273

    /// @notice Thrown when the factory is not active and a deploy is attempted
    error NotActive(); // 0x80cb55e2

    /// @notice Thrown when a Sickle contract is already deployed for a user
    error SickleAlreadyDeployed(); //0xf6782ef1

    /// STORAGE ///

    mapping(address => address) private _sickles;
    mapping(address => address) private _admins;
    mapping(address => bytes32) public _referralCodes;

    /// @notice Address of the SickleRegistry contract
    SickleRegistry public immutable registry;

    /// @notice Address of the Sickle implementation contract
    address public immutable implementation;

    /// @notice Address of the previous SickleFactory contract (if applicable)
    SickleFactory public immutable previousFactory;

    /// @notice Whether the factory is active (can deploy new Sickle contracts)
    bool public isActive = true;

    /// WRITE FUNCTIONS ///

    /// @param admin_ Address of the admin
    /// @param sickleRegistry_ Address of the SickleRegistry contract
    /// @param sickleImplementation_ Address of the Sickle implementation
    /// contract
    /// @param previousFactory_ Address of the previous SickleFactory contract
    /// if applicable
    constructor(
        address admin_,
        address sickleRegistry_,
        address sickleImplementation_,
        address previousFactory_
    ) Admin(admin_) {
        registry = SickleRegistry(sickleRegistry_);
        implementation = sickleImplementation_;
        previousFactory = SickleFactory(previousFactory_);
    }

    /// @notice Update the isActive flag.
    /// @dev Effectively pauses and unpauses new Sickle deployments.
    /// @custom:access Restricted to protocol admin.
    function setActive(bool active) external onlyAdmin {
        isActive = active;
    }

    function _deploy(
        address admin,
        address approved,
        bytes32 referralCode
    ) internal returns (address sickle) {
        sickle = Clones.cloneDeterministic(
            implementation, keccak256(abi.encode(admin))
        );
        Sickle(payable(sickle)).initialize(admin, approved);
        _sickles[admin] = sickle;
        _admins[sickle] = admin;
        if (referralCode != bytes32(0)) {
            _referralCodes[sickle] = referralCode;
        }
        emit Deploy(admin, sickle);
    }

    function _getSickle(address admin) internal returns (address sickle) {
        sickle = _sickles[admin];
        if (sickle != address(0)) {
            return sickle;
        }
        if (address(previousFactory) != address(0)) {
            sickle = previousFactory.sickles(admin);
            if (sickle != address(0)) {
                _sickles[admin] = sickle;
                _admins[sickle] = admin;
                _referralCodes[sickle] = previousFactory.referralCodes(sickle);
                return sickle;
            }
        }
    }

    /// @notice Predict the address of a Sickle contract for a specific user
    /// @param admin Address receiving the admin rights of the Sickle contract
    /// @return sickle Address of the predicted Sickle contract
    function predict(address admin) external view returns (address) {
        bytes32 salt = keccak256(abi.encode(admin));
        return Clones.predictDeterministicAddress(implementation, salt);
    }

    /// @notice Returns the Sickle contract for a specific user
    /// @param admin Address that owns the Sickle contract
    /// @return sickle Address of the Sickle contract
    function sickles(address admin) external view returns (address sickle) {
        sickle = _sickles[admin];
        if (sickle == address(0) && address(previousFactory) != address(0)) {
            sickle = previousFactory.sickles(admin);
        }
    }

    /// @notice Returns the admin for a specific Sickle contract
    /// @param sickle Address of the Sickle contract
    /// @return admin Address that owns the Sickle contract
    function admins(address sickle) external view returns (address admin) {
        admin = _admins[sickle];
        if (admin == address(0) && address(previousFactory) != address(0)) {
            admin = previousFactory.admins(sickle);
        }
    }

    /// @notice Returns the referral code for a specific Sickle contract
    /// @param sickle Address of the Sickle contract
    /// @return referralCode Referral code for the user
    function referralCodes(address sickle)
        external
        view
        returns (bytes32 referralCode)
    {
        referralCode = _referralCodes[sickle];
        if (
            referralCode == bytes32(0) && address(previousFactory) != address(0)
        ) {
            referralCode = previousFactory.referralCodes(sickle);
        }
    }

    /// @notice Deploys a new Sickle contract for a specific user, or returns
    /// the existing one if it exists
    /// @param admin Address receiving the admin rights of the Sickle contract
    /// @param referralCode Referral code for the user
    /// @return sickle Address of the deployed Sickle contract
    function getOrDeploy(
        address admin,
        address approved,
        bytes32 referralCode
    ) external returns (address sickle) {
        if (!isActive) {
            revert NotActive();
        }
        if (!registry.isWhitelistedCaller(msg.sender)) {
            revert CallerNotWhitelisted(msg.sender);
        }
        if ((sickle = _getSickle(admin)) != address(0)) {
            return sickle;
        }
        return _deploy(admin, approved, referralCode);
    }

    /// @notice Deploys a new Sickle contract for a specific user
    /// @dev Sickle contracts are deployed with create2, the address of the
    /// admin is used as a salt, so all the Sickle addresses can be pre-computed
    /// and only 1 Sickle will exist per address
    /// @param referralCode Referral code for the user
    /// @return sickle Address of the deployed Sickle contract
    function deploy(
        address approved,
        bytes32 referralCode
    ) external returns (address sickle) {
        if (!isActive) {
            revert NotActive();
        }
        if (_getSickle(msg.sender) != address(0)) {
            revert SickleAlreadyDeployed();
        }
        return _deploy(msg.sender, approved, referralCode);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { Admin } from "contracts/base/Admin.sol";

library SickleRegistryEvents {
    event CollectorChanged(address newCollector);
    event FeesUpdated(bytes32[] feeHashes, uint256[] feesInBP);
    event ReferralCodeCreated(bytes32 indexed code, address indexed referrer);

    // Multicall caller and target whitelist status changes
    event CallerStatusChanged(address caller, bool isWhitelisted);
    event TargetStatusChanged(address target, bool isWhitelisted);
}

/// @title SickleRegistry contract
/// @author vfat.tools
/// @notice Manages the whitelisted contracts and the collector address
contract SickleRegistry is Admin {
    /// ERRORS ///

    error ArrayLengthMismatch(); // 0xa24a13a6
    error FeeAboveMaxLimit(); // 0xd6cf7b5e
    error InvalidReferralCode(); // 0xe55b4629

    /// STORAGE ///

    /// @notice Address of the fee collector
    address public collector;

    /// @notice Tracks the contracts that can be called through Sickle multicall
    /// @return True if the contract is a whitelisted target
    mapping(address => bool) public isWhitelistedTarget;

    /// @notice Tracks the contracts that can call Sickle multicall
    /// @return True if the contract is a whitelisted caller
    mapping(address => bool) public isWhitelistedCaller;

    /// @notice Keeps track of the referrers and their associated code
    mapping(bytes32 => address) public referralCodes;

    /// @notice Mapping for fee hashes (hash of the strategy contract addresses
    /// and the function selectors) and their associated fees
    /// @return The fee in basis points to apply to the transaction amount
    mapping(bytes32 => uint256) public feeRegistry;

    /// WRITE FUNCTIONS ///

    /// @param admin_ Address of the admin
    /// @param collector_ Address of the collector
    constructor(address admin_, address collector_) Admin(admin_) {
        collector = collector_;
    }

    /// @notice Updates the whitelist status for multiple multicall targets
    /// @param targets Addresses of the contracts to update
    /// @param isApproved New status for the contracts
    /// @custom:access Restricted to protocol admin.
    function setWhitelistedTargets(
        address[] calldata targets,
        bool isApproved
    ) external onlyAdmin {
        for (uint256 i; i < targets.length;) {
            isWhitelistedTarget[targets[i]] = isApproved;
            emit SickleRegistryEvents.TargetStatusChanged(
                targets[i], isApproved
            );

            unchecked {
                ++i;
            }
        }
    }

    /// @notice Updates the fee collector address
    /// @param newCollector Address of the new fee collector
    /// @custom:access Restricted to protocol admin.
    function updateCollector(address newCollector) external onlyAdmin {
        collector = newCollector;
        emit SickleRegistryEvents.CollectorChanged(newCollector);
    }

    /// @notice Update the whitelist status for multiple multicall callers
    /// @param callers Addresses of the callers
    /// @param isApproved New status for the caller
    /// @custom:access Restricted to protocol admin.
    function setWhitelistedCallers(
        address[] calldata callers,
        bool isApproved
    ) external onlyAdmin {
        for (uint256 i; i < callers.length;) {
            isWhitelistedCaller[callers[i]] = isApproved;
            emit SickleRegistryEvents.CallerStatusChanged(
                callers[i], isApproved
            );

            unchecked {
                ++i;
            }
        }
    }

    /// @notice Associates a referral code to the address of the caller
    function setReferralCode(bytes32 referralCode) external {
        if (referralCodes[referralCode] != address(0)) {
            revert InvalidReferralCode();
        }

        referralCodes[referralCode] = msg.sender;
        emit SickleRegistryEvents.ReferralCodeCreated(referralCode, msg.sender);
    }

    /// @notice Update the fees for multiple strategy functions
    /// @param feeHashes Array of fee hashes
    /// @param feesArray Array of fees to apply (in basis points)
    /// @custom:access Restricted to protocol admin.
    function setFees(
        bytes32[] calldata feeHashes,
        uint256[] calldata feesArray
    ) external onlyAdmin {
        if (feeHashes.length != feesArray.length) {
            revert ArrayLengthMismatch();
        }

        for (uint256 i = 0; i < feeHashes.length;) {
            if (feesArray[i] <= 500) {
                // maximum fee of 5%
                feeRegistry[feeHashes[i]] = feesArray[i];
            } else {
                revert FeeAboveMaxLimit();
            }
            unchecked {
                ++i;
            }
        }

        emit SickleRegistryEvents.FeesUpdated(feeHashes, feesArray);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/// @title Admin contract
/// @author vfat.tools
/// @notice Provides an administration mechanism allowing restricted functions
abstract contract Admin {
    /// ERRORS ///

    /// @notice Thrown when the caller is not the admin
    error NotAdminError(); //0xb5c42b3b

    /// EVENTS ///

    /// @notice Emitted when a new admin is set
    /// @param oldAdmin Address of the old admin
    /// @param newAdmin Address of the new admin
    event AdminSet(address oldAdmin, address newAdmin);

    /// STORAGE ///

    /// @notice Address of the current admin
    address public admin;

    /// MODIFIERS ///

    /// @dev Restricts a function to the admin
    modifier onlyAdmin() {
        if (msg.sender != admin) revert NotAdminError();
        _;
    }

    /// WRITE FUNCTIONS ///

    /// @param admin_ Address of the admin
    constructor(address admin_) {
        emit AdminSet(admin, admin_);
        admin = admin_;
    }

    /// @notice Sets a new admin
    /// @param newAdmin Address of the new admin
    /// @custom:access Restricted to protocol admin.
    function setAdmin(address newAdmin) external onlyAdmin {
        emit AdminSet(admin, newAdmin);
        admin = newAdmin;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { SickleStorage } from "contracts/base/SickleStorage.sol";
import { SickleRegistry } from "contracts/SickleRegistry.sol";

/// @title Multicall contract
/// @author vfat.tools
/// @notice Enables calling multiple methods in a single call to the contract
abstract contract Multicall is SickleStorage {
    /// ERRORS ///

    error MulticallParamsMismatchError(); // 0xc1e637c9

    /// @notice Thrown when the target contract is not whitelisted
    /// @param target Address of the non-whitelisted target
    error TargetNotWhitelisted(address target); // 0x47ccabe7

    /// @notice Thrown when the caller is not whitelisted
    /// @param caller Address of the non-whitelisted caller
    error CallerNotWhitelisted(address caller); // 0x252c8273

    /// STORAGE ///

    /// @notice Address of the SickleRegistry contract
    /// @dev Needs to be immutable so that it's accessible for Sickle proxies
    SickleRegistry public immutable registry;

    /// INITIALIZATION ///

    /// @param registry_ Address of the SickleRegistry contract
    constructor(SickleRegistry registry_) initializer {
        registry = registry_;
    }

    /// WRITE FUNCTIONS ///

    /// @notice Batch multiple calls together (calls or delegatecalls)
    /// @param targets Array of targets to call
    /// @param data Array of data to pass with the calls
    function multicall(
        address[] calldata targets,
        bytes[] calldata data
    ) external payable {
        if (targets.length != data.length) {
            revert MulticallParamsMismatchError();
        }

        if (!registry.isWhitelistedCaller(msg.sender)) {
            revert CallerNotWhitelisted(msg.sender);
        }

        for (uint256 i = 0; i != data.length;) {
            if (targets[i] == address(0)) {
                unchecked {
                    ++i;
                }
                continue; // No-op
            }

            if (targets[i] != address(this)) {
                if (!registry.isWhitelistedTarget(targets[i])) {
                    revert TargetNotWhitelisted(targets[i]);
                }
            }

            (bool success, bytes memory result) =
                targets[i].delegatecall(data[i]);

            if (!success) {
                if (result.length == 0) revert();
                assembly {
                    revert(add(32, result), mload(result))
                }
            }
            unchecked {
                ++i;
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { Initializable } from
    "@openzeppelin/contracts/proxy/utils/Initializable.sol";

library SickleStorageEvents {
    event ApprovedAddressChanged(address newApproved);
}

/// @title SickleStorage contract
/// @author vfat.tools
/// @notice Base storage of the Sickle contract
/// @dev This contract needs to be inherited by stub contracts meant to be used
/// with `delegatecall`
abstract contract SickleStorage is Initializable {
    /// ERRORS ///

    /// @notice Thrown when the caller is not the owner of the Sickle contract
    error NotOwnerError(); // 0x74a21527

    /// @notice Thrown when the caller is not a strategy contract or the
    /// Flashloan Stub
    error NotStrategyError(); // 0x4581ba62

    /// STORAGE ///

    /// @notice Address of the owner
    address public owner;

    /// @notice An address that can be set by the owner of the Sickle contract
    /// in order to trigger specific functions.
    address public approved;

    /// MODIFIERS ///

    /// @dev Restricts a function call to the owner, however if the admin was
    /// not set yet,
    /// the modifier will not restrict the call, this allows the SickleFactory
    /// to perform
    /// some calls on the user's behalf before passing the admin rights to them
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwnerError();
        _;
    }

    /// INITIALIZATION ///

    /// @param owner_ Address of the owner of this Sickle contract
    function _SickleStorage_initialize(
        address owner_,
        address approved_
    ) internal onlyInitializing {
        owner = owner_;
        approved = approved_;
    }

    /// WRITE FUNCTIONS ///

    /// @notice Sets the approved address of this Sickle
    /// @param newApproved Address meant to be approved by the owner
    function setApproved(address newApproved) external onlyOwner {
        approved = newApproved;
        emit SickleStorageEvents.ApprovedAddressChanged(newApproved);
    }

    /// @notice Checks if `caller` is either the owner of the Sickle contract
    /// or was approved by them
    /// @param caller Address to check
    /// @return True if `caller` is either the owner of the Sickle contract
    function isOwnerOrApproved(address caller) public view returns (bool) {
        return caller == owner || caller == approved;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { NftKey, NftSettings } from "contracts/structs/NftSettingsStructs.sol";

interface INftSettingsRegistry {
    function getNftSettings(
        NftKey calldata key
    ) external view returns (NftSettings memory);

    function setNftSettings(
        NftKey calldata key,
        NftSettings calldata settings
    ) external;

    function resetNftSettings(
        NftKey calldata oldKey,
        NftKey calldata newKey,
        NftSettings calldata settings
    ) external;

    function validateRebalanceFor(
        NftKey memory key
    ) external;

    function validateExitFor(
        NftKey memory key
    ) external;

    function validateHarvestFor(
        NftKey memory key
    ) external;

    function validateCompoundFor(
        NftKey memory key
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPool {
    error DepositsNotEqual();
    error BelowMinimumK();
    error FactoryAlreadySet();
    error InsufficientLiquidity();
    error InsufficientLiquidityMinted();
    error InsufficientLiquidityBurned();
    error InsufficientOutputAmount();
    error InsufficientInputAmount();
    error IsPaused();
    error InvalidTo();
    error K();
    error NotEmergencyCouncil();

    event Fees(address indexed sender, uint256 amount0, uint256 amount1);
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, address indexed to, uint256 amount0, uint256 amount1);
    event Swap(
        address indexed sender,
        address indexed to,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out
    );
    event Sync(uint256 reserve0, uint256 reserve1);
    event Claim(address indexed sender, address indexed recipient, uint256 amount0, uint256 amount1);

    // Struct to capture time period obervations every 30 minutes, used for local oracles
    struct Observation {
        uint256 timestamp;
        uint256 reserve0Cumulative;
        uint256 reserve1Cumulative;
    }

    /// @notice Returns the decimal (dec), reserves (r), stable (st), and tokens (t) of token0 and token1
    function metadata()
        external
        view
        returns (uint256 dec0, uint256 dec1, uint256 r0, uint256 r1, bool st, address t0, address t1);

    /// @notice Claim accumulated but unclaimed fees (claimable0 and claimable1)
    function claimFees() external returns (uint256, uint256);

    /// @notice Returns [token0, token1]
    function tokens() external view returns (address, address);

    /// @notice Address of token in the pool with the lower address value
    function token0() external view returns (address);

    /// @notice Address of token in the poool with the higher address value
    function token1() external view returns (address);

    /// @notice Address of linked PoolFees.sol
    function poolFees() external view returns (address);

    /// @notice Address of PoolFactory that created this contract
    function factory() external view returns (address);

    /// @notice Capture oracle reading every 30 minutes (1800 seconds)
    function periodSize() external view returns (uint256);

    /// @notice Amount of token0 in pool
    function reserve0() external view returns (uint256);

    /// @notice Amount of token1 in pool
    function reserve1() external view returns (uint256);

    /// @notice Timestamp of last update to pool
    function blockTimestampLast() external view returns (uint256);

    /// @notice Cumulative of reserve0 factoring in time elapsed
    function reserve0CumulativeLast() external view returns (uint256);

    /// @notice Cumulative of reserve1 factoring in time elapsed
    function reserve1CumulativeLast() external view returns (uint256);

    /// @notice Accumulated fees of token0 (global)
    function index0() external view returns (uint256);

    /// @notice Accumulated fees of token1 (global)
    function index1() external view returns (uint256);

    /// @notice Get an LP's relative index0 to index0
    function supplyIndex0(address) external view returns (uint256);

    /// @notice Get an LP's relative index1 to index1
    function supplyIndex1(address) external view returns (uint256);

    /// @notice Amount of unclaimed, but claimable tokens from fees of token0 for an LP
    function claimable0(address) external view returns (uint256);

    /// @notice Amount of unclaimed, but claimable tokens from fees of token1 for an LP
    function claimable1(address) external view returns (uint256);

    /// @notice Returns the value of K in the Pool, based on its reserves.
    function getK() external returns (uint256);

    /// @notice Set pool name
    ///         Only callable by Voter.emergencyCouncil()
    /// @param __name String of new name
    function setName(string calldata __name) external;

    /// @notice Set pool symbol
    ///         Only callable by Voter.emergencyCouncil()
    /// @param __symbol String of new symbol
    function setSymbol(string calldata __symbol) external;

    /// @notice Get the number of observations recorded
    function observationLength() external view returns (uint256);

    /// @notice Get the value of the most recent observation
    function lastObservation() external view returns (Observation memory);

    /// @notice True if pool is stable, false if volatile
    function stable() external view returns (bool);

    /// @notice Produces the cumulative price using counterfactuals to save gas and avoid a call to sync.
    function currentCumulativePrices()
        external
        view
        returns (uint256 reserve0Cumulative, uint256 reserve1Cumulative, uint256 blockTimestamp);

    /// @notice Provides twap price with user configured granularity, up to the full window size
    /// @param tokenIn .
    /// @param amountIn .
    /// @param granularity .
    /// @return amountOut .
    function quote(address tokenIn, uint256 amountIn, uint256 granularity) external view returns (uint256 amountOut);

    /// @notice Returns a memory set of TWAP prices
    ///         Same as calling sample(tokenIn, amountIn, points, 1)
    /// @param tokenIn .
    /// @param amountIn .
    /// @param points Number of points to return
    /// @return Array of TWAP prices
    function prices(address tokenIn, uint256 amountIn, uint256 points) external view returns (uint256[] memory);

    /// @notice Same as prices with with an additional window argument.
    ///         Window = 2 means 2 * 30min (or 1 hr) between observations
    /// @param tokenIn .
    /// @param amountIn .
    /// @param points .
    /// @param window .
    /// @return Array of TWAP prices
    function sample(
        address tokenIn,
        uint256 amountIn,
        uint256 points,
        uint256 window
    ) external view returns (uint256[] memory);

    /// @notice This low-level function should be called from a contract which performs important safety checks
    /// @param amount0Out   Amount of token0 to send to `to`
    /// @param amount1Out   Amount of token1 to send to `to`
    /// @param to           Address to recieve the swapped output
    /// @param data         Additional calldata for flashloans
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;

    /// @notice This low-level function should be called from a contract which performs important safety checks
    ///         standard uniswap v2 implementation
    /// @param to Address to receive token0 and token1 from burning the pool token
    /// @return amount0 Amount of token0 returned
    /// @return amount1 Amount of token1 returned
    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    /// @notice This low-level function should be called by addLiquidity functions in Router.sol, which performs important safety checks
    ///         standard uniswap v2 implementation
    /// @param to           Address to receive the minted LP token
    /// @return liquidity   Amount of LP token minted
    function mint(address to) external returns (uint256 liquidity);

    /// @notice Update reserves and, on the first call per block, price accumulators
    /// @return _reserve0 .
    /// @return _reserve1 .
    /// @return _blockTimestampLast .
    function getReserves() external view returns (uint256 _reserve0, uint256 _reserve1, uint256 _blockTimestampLast);

    /// @notice Get the amount of tokenOut given the amount of tokenIn
    /// @param amountIn Amount of token in
    /// @param tokenIn  Address of token
    /// @return Amount out
    function getAmountOut(uint256 amountIn, address tokenIn) external view returns (uint256);

    /// @notice Force balances to match reserves
    /// @param to Address to receive any skimmed rewards
    function skim(address to) external;

    /// @notice Force reserves to match balances
    function sync() external;

    /// @notice Called on pool creation by PoolFactory
    /// @param _token0 Address of token0
    /// @param _token1 Address of token1
    /// @param _stable True if stable, false if volatile
    function initialize(address _token0, address _token1, bool _stable) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC721Enumerable } from
    "openzeppelin-contracts/contracts/interfaces/IERC721Enumerable.sol";

interface INonfungiblePositionManager is IERC721Enumerable {
    struct IncreaseLiquidityParams {
        uint256 tokenId;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }

    struct DecreaseLiquidityParams {
        uint256 tokenId;
        uint128 liquidity;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    struct CollectParams {
        uint256 tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }

    function increaseLiquidity(IncreaseLiquidityParams memory params)
        external
        payable
        returns (uint256 amount0, uint256 amount1, uint256 liquidity);

    function decreaseLiquidity(DecreaseLiquidityParams calldata params)
        external
        payable
        returns (uint256 amount0, uint256 amount1);

    function mint(MintParams memory params)
        external
        payable
        returns (uint256 tokenId, uint256 amount0, uint256 amount1);

    function collect(CollectParams calldata params)
        external
        payable
        returns (uint256 amount0, uint256 amount1);

    function burn(uint256 tokenId) external payable;

    function positions(uint256 tokenId)
        external
        view
        returns (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Pool state that never changes
/// @notice These parameters are fixed for a pool forever, i.e., the methods
/// will always return the same values
interface IUniswapV3PoolImmutables {
    /// @notice The contract that deployed the pool, which must adhere to the
    /// IUniswapV3Factory interface
    /// @return The contract address
    function factory() external view returns (address);

    /// @notice The first of the two tokens of the pool, sorted by address
    /// @return The token contract address
    function token0() external view returns (address);

    /// @notice The second of the two tokens of the pool, sorted by address
    /// @return The token contract address
    function token1() external view returns (address);

    /// @notice The pool's fee in hundredths of a bip, i.e. 1e-6
    /// @return The fee
    function fee() external view returns (uint24);

    /// @notice The pool tick spacing
    /// @dev Ticks can only be used at multiples of this value, minimum of 1 and
    /// always positive
    /// e.g.: a tickSpacing of 3 means ticks can be initialized every 3rd tick,
    /// i.e., ..., -6, -3, 0, 3, 6, ...
    /// This value is an int24 to avoid casting even though it is always
    /// positive.
    /// @return The tick spacing
    function tickSpacing() external view returns (int24);

    /// @notice The maximum amount of position liquidity that can use any tick
    /// in the range
    /// @dev This parameter is enforced per tick to prevent liquidity from
    /// overflowing a uint128 at any point, and
    /// also prevents out-of-range liquidity from being used to prevent adding
    /// in-range liquidity to a pool
    /// @return The max amount of liquidity per tick
    function maxLiquidityPerTick() external view returns (uint128);
}

/// @title Pool state that can change
/// @notice These methods compose the pool's state, and can change with any
/// frequency including multiple times
/// per transaction
interface IUniswapV3PoolState {
    /// @notice The 0th storage slot in the pool stores many values, and is
    /// exposed as a single method to save gas
    /// when accessed externally.
    /// @return sqrtPriceX96 The current price of the pool as a
    /// sqrt(token1/token0) Q64.96 value
    /// @return tick The current tick of the pool, i.e. according to the last
    /// tick transition that was run.
    /// This value may not always be equal to
    /// SqrtTickMath.getTickAtSqrtRatio(sqrtPriceX96) if the price is on a tick
    /// boundary.
    /// @return observationIndex The index of the last oracle observation that
    /// was written,
    /// @return observationCardinality The current maximum number of
    /// observations stored in the pool,
    /// @return observationCardinalityNext The next maximum number of
    /// observations, to be updated when the observation.
    /// @return feeProtocol The protocol fee for both tokens of the pool.
    /// Encoded as two 4 bit values, where the protocol fee of token1 is shifted
    /// 4 bits and the protocol fee of token0
    /// is the lower 4 bits. Used as the denominator of a fraction of the swap
    /// fee, e.g. 4 means 1/4th of the swap fee.
    /// unlocked Whether the pool is currently locked to reentrancy
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );

    /// @notice The fee growth as a Q128.128 fees of token0 collected per unit
    /// of liquidity for the entire life of the pool
    /// @dev This value can overflow the uint256
    function feeGrowthGlobal0X128() external view returns (uint256);

    /// @notice The fee growth as a Q128.128 fees of token1 collected per unit
    /// of liquidity for the entire life of the pool
    /// @dev This value can overflow the uint256
    function feeGrowthGlobal1X128() external view returns (uint256);

    /// @notice The amounts of token0 and token1 that are owed to the protocol
    /// @dev Protocol fees will never exceed uint128 max in either token
    function protocolFees()
        external
        view
        returns (uint128 token0, uint128 token1);

    /// @notice The currently in range liquidity available to the pool
    /// @dev This value has no relationship to the total liquidity across all
    /// ticks
    /// @return The liquidity at the current price of the pool
    function liquidity() external view returns (uint128);

    /// @notice Look up information about a specific tick in the pool
    /// @param tick The tick to look up
    /// @return liquidityGross the total amount of position liquidity that uses
    /// the pool either as tick lower or
    /// tick upper
    /// @return liquidityNet how much liquidity changes when the pool price
    /// crosses the tick,
    /// @return feeGrowthOutside0X128 the fee growth on the other side of the
    /// tick from the current tick in token0,
    /// @return feeGrowthOutside1X128 the fee growth on the other side of the
    /// tick from the current tick in token1,
    /// @return tickCumulativeOutside the cumulative tick value on the other
    /// side of the tick from the current tick
    /// @return secondsPerLiquidityOutsideX128 the seconds spent per liquidity
    /// on the other side of the tick from the current tick,
    /// @return secondsOutside the seconds spent on the other side of the tick
    /// from the current tick,
    /// @return initialized Set to true if the tick is initialized, i.e.
    /// liquidityGross is greater than 0, otherwise equal to false.
    /// Outside values can only be used if the tick is initialized, i.e. if
    /// liquidityGross is greater than 0.
    /// In addition, these values are only relative and must be used only in
    /// comparison to previous snapshots for
    /// a specific position.
    function ticks(int24 tick)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );

    /// @notice Returns 256 packed tick initialized boolean values. See
    /// TickBitmap for more information
    function tickBitmap(int16 wordPosition) external view returns (uint256);

    /// @notice Returns the information about a position by the position's key
    /// @param key The position's key is a hash of a preimage composed by the
    /// owner, tickLower and tickUpper
    /// @return liquidity The amount of liquidity in the position,
    /// @return feeGrowthInside0LastX128 fee growth of token0 inside the tick
    /// range as of the last mint/burn/poke,
    /// @return feeGrowthInside1LastX128 fee growth of token1 inside the tick
    /// range as of the last mint/burn/poke,
    /// @return tokensOwed0 the computed amount of token0 owed to the position
    /// as of the last mint/burn/poke,
    /// @return tokensOwed1 the computed amount of token1 owed to the position
    /// as of the last mint/burn/poke
    function positions(bytes32 key)
        external
        view
        returns (
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    /// @notice Returns data about a specific observation index
    /// @param index The element of the observations array to fetch
    /// @dev You most likely want to use #observe() instead of this method to
    /// get an observation as of some amount of time
    /// ago, rather than at a specific index in the array.
    /// @return blockTimestamp The timestamp of the observation,
    /// @return tickCumulative the tick multiplied by seconds elapsed for the
    /// life of the pool as of the observation timestamp,
    /// @return secondsPerLiquidityCumulativeX128 the seconds per in range
    /// liquidity for the life of the pool as of the observation timestamp,
    /// @return initialized whether the observation has been initialized and the
    /// values are safe to use
    function observations(uint256 index)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );
}

interface IUniswapV3Pool is IUniswapV3PoolImmutables, IUniswapV3PoolState {
    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { INonfungiblePositionManager } from
    "contracts/interfaces/external/uniswap/INonfungiblePositionManager.sol";
import { IUniswapV3Pool } from
    "contracts/interfaces/external/uniswap/IUniswapV3Pool.sol";

import { Sickle } from "contracts/Sickle.sol";
import {
    RewardConfig,
    RewardBehavior
} from "contracts/structs/PositionSettingsStructs.sol";

struct NftKey {
    Sickle sickle;
    INonfungiblePositionManager nftManager;
    uint256 tokenId;
}

struct ExitConfig {
    int24 triggerTickLow;
    int24 triggerTickHigh;
    address exitTokenOutLow;
    address exitTokenOutHigh;
    uint256 priceImpactBP;
    uint256 slippageBP;
}

/**
 * @notice Settings for automatic rebalancing
 * @param tickSpacesBelow: Position width measured in tick spaces below
 * Default: 0 (Position doesn't include any tick spaces below current)
 * @param tickSpacesAbove: Position width measured in tick spaces above
 * Default: 0 (Position doesn't include any tick spaces above current)
 * @param bufferTicksBelow: Difference from position tickLower to
 * rebalance below. Can be negative (rebalance before position goes under
 * range)
 * Default: 0 (always rebalance if tick < tickLower)
 * @param bufferTicksAbove: Difference from position tickUpper to
 * rebalance above. Can be negative (rebalance before position goes above range)
 * Default: 0 (always rebalance if tick >= tickUpper)
 * @param dustBP: Dust allowance in basis points
 * @param priceImpactBP: Price impact allowance in basis points
 * @param slippageBP: Slippage allowance in basis points
 * @param cutoffTickLow: Stop rebalancing below this tick
 * default: MIN_TICK (no stop loss)
 * @param cutoffTickHigh: Stop rebalancing above this tick
 * default: MAX_TICK (no stop loss)
 * @param delayMin: Delay in minutes before rebalancing
 * @param rewardConfig: Configuration for handling rewards when rebalancing
 */
struct RebalanceConfig {
    uint24 tickSpacesBelow;
    uint24 tickSpacesAbove;
    int24 bufferTicksBelow;
    int24 bufferTicksAbove;
    uint256 dustBP;
    uint256 priceImpactBP;
    uint256 slippageBP;
    int24 cutoffTickLow;
    int24 cutoffTickHigh;
    uint8 delayMin;
    RewardConfig rewardConfig;
}

/**
 * Settings for automating an NFT position
 * @param autoRebalance: Whether to rebalance automatically when position goes
 * out of range
 * @param rebalanceConfig: Configuration for the above
 * @param automateRewards: Whether to automatically harvest or compound rewards
 * for this position, regardless of rebalance settings.
 * @param rewardConfig: Configuration for reward automation
 * Harvest as-is, harvest and convert to a different token, or compound into the
 * position.
 */
struct NftSettings {
    IUniswapV3Pool pool;
    bool autoRebalance;
    RebalanceConfig rebalanceConfig;
    bool automateRewards;
    RewardConfig rewardConfig;
    bool autoExit;
    ExitConfig exitConfig;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { IPool } from "contracts/interfaces/external/aerodrome/IPool.sol";

import { Sickle } from "contracts/Sickle.sol";

struct PositionKey {
    Sickle sickle;
    address stakingContract;
    uint256 poolIndex;
}

enum RewardBehavior {
    None,
    Harvest,
    Compound
}

struct RewardConfig {
    RewardBehavior rewardBehavior;
    address harvestTokenOut;
}

struct ExitConfig {
    uint256 triggerPriceHigh;
    uint256 triggerPriceLow;
    uint256 triggerReserves0;
    uint256 triggerReserves1;
    address exitTokenOutLow;
    address exitTokenOutHigh;
    uint256 priceImpactBP;
    uint256 slippageBP;
}

/**
 * Settings for automating an ERC20 position
 * @param pool: Uniswap or Aerodrome vAMM/sAMM pair for the position (requires
 * token0/token1/getReserves functions)
 * @param router: Router for the pair (requires connector registration)
 * @param automateRewards: Whether to automatically harvest or compound rewards
 * for this position, regardless of rebalance settings.
 * @param rewardConfig: Configuration for reward automation
 * Harvest as-is, harvest and convert to a different token, or compound into the
 * position.
 * @param autoExit: Whether to automatically exit the position when it goes out
 * of
 * range
 * @param exitConfig: Configuration for the above
 */
struct PositionSettings {
    IPool pair;
    address router;
    bool automateRewards;
    RewardConfig rewardConfig;
    bool autoExit;
    ExitConfig exitConfig;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/extensions/IERC721Enumerable.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create(0, 0x09, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create2(0, 0x09, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(add(ptr, 0x38), deployer)
            mstore(add(ptr, 0x24), 0x5af43d82803e903d91602b57fd5bf3ff)
            mstore(add(ptr, 0x14), implementation)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73)
            mstore(add(ptr, 0x58), salt)
            mstore(add(ptr, 0x78), keccak256(add(ptr, 0x0c), 0x37))
            predicted := keccak256(add(ptr, 0x43), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.1) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!Address.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}