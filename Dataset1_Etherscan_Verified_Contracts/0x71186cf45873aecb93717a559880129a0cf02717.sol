// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {IAuth} from "./IAuth.sol";

/**
 * @title Auth Module
 *
 * @dev The `Auth` contract module provides a basic access control mechanism,
 *      where a set of addresses are granted access to protected functions.
 *      These addresses are said to be _auth'ed_.
 *
 *      Initially, the address given as constructor argument is the only address
 *      auth'ed. Through the `rely(address)` and `deny(address)` functions,
 *      auth'ed callers are able to grant/renounce auth to/from addresses.
 *
 *      This module is used through inheritance. It will make available the
 *      modifier `auth`, which can be applied to functions to restrict their
 *      use to only auth'ed callers.
 */
abstract contract Auth is IAuth {
    /// @dev Mapping storing whether address is auth'ed.
    /// @custom:invariant Image of mapping is {0, 1}.
    ///                     ∀x ∊ Address: _wards[x] ∊ {0, 1}
    /// @custom:invariant Only address given as constructor argument is authenticated after deployment.
    ///                     deploy(initialAuthed) → (∀x ∊ Address: _wards[x] == 1 → x == initialAuthed)
    /// @custom:invariant Only functions `rely` and `deny` may mutate the mapping's state.
    ///                     ∀x ∊ Address: preTx(_wards[x]) != postTx(_wards[x])
    ///                                     → (msg.sig == "rely" ∨ msg.sig == "deny")
    /// @custom:invariant Mapping's state may only be mutated by authenticated caller.
    ///                     ∀x ∊ Address: preTx(_wards[x]) != postTx(_wards[x]) → _wards[msg.sender] = 1
    mapping(address => uint) private _wards;

    /// @dev List of addresses possibly being auth'ed.
    /// @dev May contain duplicates.
    /// @dev May contain addresses not being auth'ed anymore.
    /// @custom:invariant Every address being auth'ed once is element of the list.
    ///                     ∀x ∊ Address: authed(x) -> x ∊ _wardsTouched
    address[] private _wardsTouched;

    /// @dev Ensures caller is auth'ed.
    modifier auth() {
        assembly ("memory-safe") {
            // Compute slot of _wards[msg.sender].
            mstore(0x00, caller())
            mstore(0x20, _wards.slot)
            let slot := keccak256(0x00, 0x40)

            // Revert if caller not auth'ed.
            let isAuthed := sload(slot)
            if iszero(isAuthed) {
                // Store selector of `NotAuthorized(address)`.
                mstore(0x00, 0x4a0bfec1)
                // Store msg.sender.
                mstore(0x20, caller())
                // Revert with (offset, size).
                revert(0x1c, 0x24)
            }
        }
        _;
    }

    constructor(address initialAuthed) {
        _wards[initialAuthed] = 1;
        _wardsTouched.push(initialAuthed);

        // Note to use address(0) as caller to indicate address was auth'ed
        // during deployment.
        emit AuthGranted(address(0), initialAuthed);
    }

    /// @inheritdoc IAuth
    function rely(address who) external auth {
        if (_wards[who] == 1) return;

        _wards[who] = 1;
        _wardsTouched.push(who);
        emit AuthGranted(msg.sender, who);
    }

    /// @inheritdoc IAuth
    function deny(address who) external auth {
        if (_wards[who] == 0) return;

        _wards[who] = 0;
        emit AuthRenounced(msg.sender, who);
    }

    /// @inheritdoc IAuth
    function authed(address who) public view returns (bool) {
        return _wards[who] == 1;
    }

    /// @inheritdoc IAuth
    /// @custom:invariant Only contains auth'ed addresses.
    ///                     ∀x ∊ authed(): _wards[x] == 1
    /// @custom:invariant Contains all auth'ed addresses.
    ///                     ∀x ∊ Address: _wards[x] == 1 → x ∊ authed()
    function authed() public view returns (address[] memory) {
        // Initiate array with upper limit length.
        address[] memory wardsList = new address[](_wardsTouched.length);

        // Iterate through all possible auth'ed addresses.
        uint ctr;
        for (uint i; i < wardsList.length; i++) {
            // Add address only if still auth'ed.
            if (_wards[_wardsTouched[i]] == 1) {
                wardsList[ctr++] = _wardsTouched[i];
            }
        }

        // Set length of array to number of auth'ed addresses actually included.
        assembly ("memory-safe") {
            mstore(wardsList, ctr)
        }

        return wardsList;
    }

    /// @inheritdoc IAuth
    function wards(address who) public view returns (uint) {
        return _wards[who];
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IAuth {
    /// @notice Thrown by protected function if caller not auth'ed.
    /// @param caller The caller's address.
    error NotAuthorized(address caller);

    /// @notice Emitted when auth granted to address.
    /// @param caller The caller's address.
    /// @param who The address auth got granted to.
    event AuthGranted(address indexed caller, address indexed who);

    /// @notice Emitted when auth renounced from address.
    /// @param caller The caller's address.
    /// @param who The address auth got renounced from.
    event AuthRenounced(address indexed caller, address indexed who);

    /// @notice Grants address `who` auth.
    /// @dev Only callable by auth'ed address.
    /// @param who The address to grant auth.
    function rely(address who) external;

    /// @notice Renounces address `who`'s auth.
    /// @dev Only callable by auth'ed address.
    /// @param who The address to renounce auth.
    function deny(address who) external;

    /// @notice Returns whether address `who` is auth'ed.
    /// @param who The address to check.
    /// @return True if `who` is auth'ed, false otherwise.
    function authed(address who) external view returns (bool);

    /// @notice Returns full list of addresses granted auth.
    /// @dev May contain duplicates.
    /// @return List of addresses granted auth.
    function authed() external view returns (address[] memory);

    /// @notice Returns whether address `who` is auth'ed.
    /// @custom:deprecated Use `authed(address)(bool)` instead.
    /// @param who The address to check.
    /// @return 1 if `who` is auth'ed, 0 otherwise.
    function wards(address who) external view returns (uint);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IToll {
    /// @notice Thrown by protected function if caller not tolled.
    /// @param caller The caller's address.
    error NotTolled(address caller);

    /// @notice Emitted when toll granted to address.
    /// @param caller The caller's address.
    /// @param who The address toll got granted to.
    event TollGranted(address indexed caller, address indexed who);

    /// @notice Emitted when toll renounced from address.
    /// @param caller The caller's address.
    /// @param who The address toll got renounced from.
    event TollRenounced(address indexed caller, address indexed who);

    /// @notice Grants address `who` toll.
    /// @dev Only callable by auth'ed address.
    /// @param who The address to grant toll.
    function kiss(address who) external;

    /// @notice Renounces address `who`'s toll.
    /// @dev Only callable by auth'ed address.
    /// @param who The address to renounce toll.
    function diss(address who) external;

    /// @notice Returns whether address `who` is tolled.
    /// @param who The address to check.
    /// @return True if `who` is tolled, false otherwise.
    function tolled(address who) external view returns (bool);

    /// @notice Returns full list of addresses tolled.
    /// @dev May contain duplicates.
    /// @return List of addresses tolled.
    function tolled() external view returns (address[] memory);

    /// @notice Returns whether address `who` is tolled.
    /// @custom:deprecated Use `tolled(address)(bool)` instead.
    /// @param who The address to check.
    /// @return 1 if `who` is tolled, 0 otherwise.
    function bud(address who) external view returns (uint);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {IToll} from "./IToll.sol";

/**
 * @title Toll Module
 *
 * @notice "Toll paid, we kiss - but dissension looms, maybe diss?"
 *
 * @dev The `Toll` contract module provides a basic access control mechanism,
 *      where a set of addresses are granted access to protected functions.
 *      These addresses are said the be _tolled_.
 *
 *      Initially, no address is tolled. Through the `kiss(address)` and
 *      `diss(address)` functions, auth'ed callers are able to toll/de-toll
 *      addresses. Authentication for these functions is defined via the
 *      downstream implemented `toll_auth()` function.
 *
 *      This module is used through inheritance. It will make available the
 *      modifier `toll`, which can be applied to functions to restrict their
 *      use to only tolled callers.
 */
abstract contract Toll is IToll {
    /// @dev Mapping storing whether address is tolled.
    /// @custom:invariant Image of mapping is {0, 1}.
    ///                     ∀x ∊ Address: _buds[x] ∊ {0, 1}
    /// @custom:invariant Only functions `kiss` and `diss` may mutate the mapping's state.
    ///                     ∀x ∊ Address: preTx(_buds[x]) != postTx(_buds[x])
    ///                                     → (msg.sig == "kiss" ∨ msg.sig == "diss")
    /// @custom:invariant Mapping's state may only be mutated by authenticated caller.
    ///                     ∀x ∊ Address: preTx(_buds[x]) != postTx(_buds[x])
    ///                                     → toll_auth()
    mapping(address => uint) private _buds;

    /// @dev List of addresses possibly being tolled.
    /// @dev May contain duplicates.
    /// @dev May contain addresses not being tolled anymore.
    /// @custom:invariant Every address being tolled once is element of the list.
    ///                     ∀x ∊ Address: tolled(x) → x ∊ _budsTouched
    address[] private _budsTouched;

    /// @dev Ensures caller is tolled.
    modifier toll() {
        assembly ("memory-safe") {
            // Compute slot of _buds[msg.sender].
            mstore(0x00, caller())
            mstore(0x20, _buds.slot)
            let slot := keccak256(0x00, 0x40)

            // Revert if caller not tolled.
            let isTolled := sload(slot)
            if iszero(isTolled) {
                // Store selector of `NotTolled(address)`.
                mstore(0x00, 0xd957b595)
                // Store msg.sender.
                mstore(0x20, caller())
                // Revert with (offset, size).
                revert(0x1c, 0x24)
            }
        }
        _;
    }

    /// @dev Reverts if caller not allowed to access protected function.
    /// @dev Must be implemented in downstream contract.
    function toll_auth() internal virtual;

    /// @inheritdoc IToll
    function kiss(address who) external {
        toll_auth();

        if (_buds[who] == 1) return;

        _buds[who] = 1;
        _budsTouched.push(who);
        emit TollGranted(msg.sender, who);
    }

    /// @inheritdoc IToll
    function diss(address who) external {
        toll_auth();

        if (_buds[who] == 0) return;

        _buds[who] = 0;
        emit TollRenounced(msg.sender, who);
    }

    /// @inheritdoc IToll
    function tolled(address who) public view returns (bool) {
        return _buds[who] == 1;
    }

    /// @inheritdoc IToll
    /// @custom:invariant Only contains tolled addresses.
    ///                     ∀x ∊ tolled(): _tolled[x]
    /// @custom:invariant Contains all tolled addresses.
    ///                     ∀x ∊ Address: _tolled[x] == 1 → x ∊ tolled()
    function tolled() public view returns (address[] memory) {
        // Initiate array with upper limit length.
        address[] memory budsList = new address[](_budsTouched.length);

        // Iterate through all possible tolled addresses.
        uint ctr;
        for (uint i; i < budsList.length; i++) {
            // Add address only if still tolled.
            if (_buds[_budsTouched[i]] == 1) {
                budsList[ctr++] = _budsTouched[i];
            }
        }

        // Set length of array to number of tolled addresses actually included.
        assembly ("memory-safe") {
            mstore(budsList, ctr)
        }

        return budsList;
    }

    /// @inheritdoc IToll
    function bud(address who) public view returns (uint) {
        return _buds[who];
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IVerifier {
    /// @notice Thrown if message verification requested by a different address
    ///         than the entrypoint.
    error NotEntrypoint();

    /// @notice Thrown if wat message's version does not match verifier's
    ///         version.
    error VersionMismatch();

    /// @notice Thrown if wat message's scheme does not match verifier's scheme.
    error SchemeMismatch();

    /// @notice Thrown if wat message's bar is zero.
    error BarIsZero();

    /// @notice Thrown if wat message's wat is zero.
    error WatIsZero();

    /// @notice Tries to verify wat message `watMessage`.
    ///
    /// @dev Only callable by entrypoint!
    ///
    /// @param watMessage The wat message to verify.
    /// @return err The error occured during verification, if any.
    /// @return wat The wat message's wat identifier.
    /// @return val The wat message's verified value.
    /// @return age The wat message's value's age.
    function tryVerify(bytes calldata watMessage)
        external
        view
        returns (bytes4 err, bytes32 wat, uint val, uint age);

    /// @notice The low-latency message version the verifier supports.
    /// @return version_ The verifier's low-latency message version supported.
    function version() external view returns (uint8 version_);

    /// @notice The low-latency message verification scheme the verifier
    ///         supports.
    /// @return scheme_ The verifier's low-latency verification scheme.
    function scheme() external view returns (uint8 scheme_);

    /// @notice The low-latency entrypoint contract from which the verifier
    ///         accepts verify requests.
    /// @return entrypoint_ The verifier's low-latency entrypoint.
    function entrypoint() external view returns (address entrypoint_);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

//------------------------------------------------------------------------------
// Errors

/// @dev Bytes4 instance used to indicate an absence of errors.
bytes4 constant NO_ERR = bytes4(0);

//------------------------------------------------------------------------------
// PokeData

/// @dev Type PokeData encapsulates a value and its corresponding timestamp.
struct PokeData {
    uint128 val;
    uint32 age;
}

/// @dev The size of a PokeData instance in bytes.
uint constant POKE_DATA_BYTE_SIZE = 32;

//------------------------------------------------------------------------------
// ValidatorMessage

/// @dev Type ValidatorMessageECDSA encapsulates a PokeData with its
///      corresponding ECDSA signature.
struct ValidatorMessageECDSA {
    PokeData pokeData;
    uint8 v;
    bytes32 r;
    bytes32 s;
}

/// @dev The size of an ValidatorMessageECDSA instance in bytes.
uint constant VALIDATOR_MESSAGE_ECDSA_SIZE = 96;

/// @dev Type ValidatorMessageSchnorr encapsulates a PokeData with its
///      corresponding Schnorr muli-signature.
struct ValidatorMessageSchnorr {
    PokeData pokeData;
    bytes32 signature;
    address commitment;
    bytes validatorIds;
}

//------------------------------------------------------------------------------
// WatMessage

/// @dev Type WatMessageHeader defines the header of a wat message.
///
///      The header contains the wat message's version and cryptographic scheme,
///      as well as the wat's bar configuration and wat identifier.
struct WatMessageHeader {
    uint8 version;
    uint8 scheme;
    uint8 bar;
    bytes32 wat;
}

/// @dev The size of a WatMessageHeader instance in bytes.
uint constant WAT_MESSAGE_HEADER_BYTE_SIZE = 64;

/// @dev Type WatMessageECDSA defines a wat message using the ECDSA scheme.
struct WatMessageECDSA {
    WatMessageHeader header;
    ValidatorMessageECDSA[] messages;
}

/// @dev Type WatMessageECDSA defines a wat message using the Schnorr scheme.
struct WatMessageSchnorr {
    WatMessageHeader header;
    ValidatorMessageSchnorr message;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IVerifier} from "../IVerifier.sol";

interface IVerifierECDSA is IVerifier {
    //--------------------------------------------------------------------------
    // Errors

    /// @notice Thrown if any validator message stale.
    error StaleMessage();

    /// @notice Thrown if any validator message from the future.
    error FutureMessage();

    /// @notice Thrown if at least two validator messages from the same
    ///         validator.
    error DoubleSigningAttempted();

    /// @notice Thrown if any validator message signed by non-validator address.
    error NotAValidator();

    /// @notice Thrown if validator messages not in ascending order based on
    ///         their value.
    error MessagesNotSorted();

    /// @notice Thrown if any validator message signed by the zero address.
    error SignerIsZeroAddress();

    /// @notice Thrown if wat message's config invalid.
    error ConfigInvalid();

    /// @notice Thrown if wat message's bar is zero.
    error ZeroBar();

    /// @notice Thrown if wat message's wat not supported.
    error WatNotSupported();

    //--------------------------------------------------------------------------
    // Events

    /// @notice Emitted when a wat's config updated.
    /// @param caller The caller's address.
    /// @param wat The wat identifier.
    /// @param oldBar The wat's old bar configuration.
    /// @param oldBloom The wat's old bloom configuration.
    /// @param newBar The wat's new bar configuration.
    /// @param newBloom The wat's new bloom configuration.
    event ConfigUpdated(
        address indexed caller,
        bytes32 indexed wat,
        uint8 oldBar,
        uint oldBloom,
        uint8 newBar,
        uint newBloom
    );

    /// @notice Emitted when validator lifted.
    /// @param caller The caller's address.
    /// @param validator The validator's address.
    event ValidatorLifted(address indexed caller, address indexed validator);

    /// @notice Emitted when validator dropped.
    /// @param caller The caller's address.
    /// @param validator The validator's address.
    event ValidatorDropped(address indexed caller, address indexed validator);

    /// @notice Emitted when staleness threshold updated.
    /// @param caller The caller's address.
    /// @param oldStalenessThreshold The old staleness threshold.
    /// @param newStalenessThreshold The new staleness threshold.
    event StalenessThresholdUpdated(
        address indexed caller,
        uint16 oldStalenessThreshold,
        uint16 newStalenessThreshold
    );

    /// @notice Emitted when grace period updated.
    /// @param caller The caller's address.
    /// @param oldGracePeriod The old grace period.
    /// @param newGracePeriod The new grace period.
    event GracePeriodUpdated(
        address indexed caller, uint16 oldGracePeriod, uint16 newGracePeriod
    );

    //--------------------------------------------------------------------------
    // Public View Functions

    /// @notice Returns whether wat `wat` is supported.
    ///
    /// @dev Note that a wat is supported if the config update to unsupport the
    ///      wat is still in the grace period.
    ///
    /// @dev Reverts if:
    ///      - `wat` is zero
    ///
    /// @param wat The wat to check support for.
    /// @return supported Whether wat `wat` is supported.
    function wats(bytes32 wat) external view returns (bool supported);

    /// @notice Returns wat `wat`'s current config.
    ///
    /// @dev A wat's config is composed of its bar security parameter and set of
    ///      lifted validators encoded as bloom.
    ///
    /// @dev Reverts if:
    ///      - `wat` is zero
    ///      - `wat` not supported
    ///
    /// @param wat The wat to return its config.
    /// @return bar The wat's bar security parameter.
    /// @return bloom The wat's set of lifted validators encoded as bloom.
    function config(bytes32 wat) external view returns (uint bar, uint bloom);

    /// @notice Returns the global set of Chronicle Protocol validators lifted
    ///         for low-latency oracles.
    ///
    /// @dev Note that every wat's validator set is a subset of the global
    ///      validator set.
    ///
    /// @return validators_ The global set of Chronicle Protocol validators
    ///                     lifted for low-latency oracles.
    function validators()
        external
        view
        returns (address[] memory validators_);

    /// @notice Returns whether validator `validator_` is part of Chronicle
    ///         Protocol's global set of validators lifted for low-latency
    ///         oracles.
    ///
    /// @param validator The validator to check.
    /// @return lifted Whether validator `validator` is lifted for the global
    ///                set of Chronicle Protocol's low-latency oracles.
    function validators(address validator)
        external
        view
        returns (bool lifted);

    /// @notice Returns the set of lifted validators for wat `wat`.
    ///
    /// @dev Reverts if:
    ///      - `wat` is zero
    ///      - `wat` not supported
    ///
    /// @param wat The wat to return its set of lifted validators.
    /// @return validators_ The set of lifted validators for wat `wat`.
    function validators(bytes32 wat)
        external
        view
        returns (address[] memory validators_);

    /// @notice Returns whether validator `validator` is lifted for wat `wat`.
    ///
    /// @dev Reverts if:
    ///      - `wat` is zero
    ///      - `wat` not supported
    ///
    /// @param wat The wat to return for whether validator `validator` is lifted.
    /// @param validator The validator to check whether they are lifted for wat
    ///                  `wat`.
    /// @return lifted Whether validator `validator` is lifted for wat `wat`.
    function validators(bytes32 wat, address validator)
        external
        view
        returns (bool lifted);

    /// @notice Returns the grace period in seconds.
    ///
    /// @dev The grace period is the time period after a wat's config update
    ///      during which both, the new and previous, wat's configs are valid.
    ///
    ///      This period is necessary to give ample time for non-finalized txs
    ///      and Chronicle Protocol low-latency API providers to update to the
    ///      new config.
    ///
    /// @dev Note that offboarded wats do not have a grace period!
    ///
    /// @return gracePeriod_ The grace period is seconds.
    function gracePeriod() external view returns (uint16 gracePeriod_);

    /// @notice Returns the staleness threshold in seconds.
    ///
    /// @dev The staleness threshold is the time after which a validator
    ///      message's age will be deemed invalid.
    ///
    /// @return stalenessThreshold_ The staleness threshold in seconds.
    function stalenessThreshold()
        external
        view
        returns (uint16 stalenessThreshold_);

    //--------------------------------------------------------------------------
    // Auth'ed Functionality

    /// @notice Updates the grace period to `gracePeriod_`.
    ///
    /// @dev Only callable by auth'ed address.
    ///
    /// @dev Reverts if:
    ///      - `gracePeriod_` is zero
    ///
    /// @param gracePeriod_ The grace period in seconds to update to.
    function setGracePeriod(uint16 gracePeriod_) external;

    /// @notice Updates the staleness threshold to `stalenessThreshold_`.
    ///
    /// @dev Only callable by auth'ed address.
    ///
    /// @dev Reverts if:
    ///      - `stalenessThreshold_` is zero
    ///
    /// @param stalenessThreshold_ The staleness threshold in seconds to update
    ///                            to.
    function setStalenessThreshold(uint16 stalenessThreshold_) external;

    /// @notice Updates wat `wat`'s config.
    ///
    /// @dev A wat's config is composed of its bar security parameter and set of
    ///      lifted validators encoded as bloom.
    ///
    /// @dev Note that this function is used to add initial support for a new
    ///      wat, updating a wat's config, and removing support for a wat.
    ///
    ///      A wat's support is removed via setting its bar and bloom parameters
    ///      to zero.
    ///
    /// @dev Only callable by auth'ed address.
    ///
    /// @dev Reverts if:
    ///      - exclusively `bar` or `bloom` zero
    ///
    /// @param wat The wat to update its config.
    /// @param bar The bar to update wat `wat`'s config to.
    /// @param bloom The set of lifted validators encoded as bloom to update
    ///              wat `wat`'s config to.
    function setConfig(bytes32 wat, uint8 bar, uint bloom) external;

    /// @notice Lifts validator `validator` to Chronicle Protocol's global
    ///         low-latency validator set.
    ///
    /// @dev Only callable by auth'ed address.
    ///
    /// @dev Reverts if:
    ///      - `validator` is zero address
    ///
    /// @param validator The validator to lift.
    function lift(address validator) external;

    /// @notice Lifts list of validators `validators` to Chronicle Protocol's
    ///         global low-latency validator set.
    ///
    /// @dev Only callable by auth'ed address.
    ///
    /// @dev Reverts if:
    ///      - any validator in `validators` is zero address
    ///
    /// @param validators The validators to lift.
    function lift(address[] memory validators) external;

    /// @notice Drops validator with id `validatorId` from Chronicle Protocol's
    ///         global low-latency validator set.
    ///
    /// @dev Only callable by auth'ed address.
    ///
    /// @param validatorId The id of the validator to drop.
    function drop(uint8 validatorId) external;

    /// @notice Drops list of validators with ids `validatorIds` from Chronicle
    ///         Protocol's global low-latency validator set.
    ///
    /// @dev Only callable by auth'ed address.
    ///
    /// @param validatorIds The ids of the validators to drop.
    function drop(uint8[] memory validatorIds) external;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import {Auth} from "chronicle-std/auth/Auth.sol";
import {Toll} from "chronicle-std/toll/Toll.sol";

import {IVerifier} from "../IVerifier.sol";

import {IVerifierECDSA} from "./IVerifierECDSA.sol";

import {
    NO_ERR,
    WatMessageHeader,
    WAT_MESSAGE_HEADER_BYTE_SIZE,
    ValidatorMessageECDSA,
    VALIDATOR_MESSAGE_ECDSA_SIZE,
    PokeData
} from "../libs/Types.sol";

/**
 * @title VerifierECDSA
 * @custom:version 1.0.0
 *
 * @notice Chronicle Protocol low-latency verifier for ECDSA median-proof based
 *         v1 messages.
 *
 * @dev This IVerifier implementation is able to verify ECDSA median-prood based
 *      v1 wat messages.
 *
 * @custom:references
 *      - [EIP-2098]: https://eips.ethereum.org/EIPS/eip-2098
 *      - [Median]: https://github.com/makerdao/median/blob/0316acd5a97fbd6c3d23b159b3d329f99ead3405/src/median.sol
 *
 * @author Chronicle Labs, Inc
 * @custom:security-contact security@chroniclelabs.org
 */
contract VerifierECDSA is IVerifierECDSA, Auth {
    /// @dev WatConfig defines the security configuration for a wat.
    struct WatConfig {
        /// @dev The bloom of validators lifted.
        uint bloom;
        /// @dev The bar security parameter.
        uint8 bar;
        /// @dev The timestamp the config got activated.
        uint32 born;
    }

    /// @dev Tuple of a wat's current and previous config.
    ///
    /// @dev The previous config MAY be used during the grace period after a
    ///      config update.
    struct WatConfigTuple {
        /// @dev The current valid config.
        WatConfig cur;
        /// @dev The last config, valid only during the grace period after a
        ///      config update.
        WatConfig last;
    }

    //--------------------------------------------------------------------------
    // Constants and Immutables

    /// @dev Mask to receive an ECDSA's s value from an [EIP-2098] compact
    ///      signature representation.
    ///
    ///      Equals `(1 << 255) - 1`.
    bytes32 internal constant _EIP2098_MASK =
        0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    /// @dev The low-latency message version the verifier supports.
    uint8 internal constant _VERSION = 1;

    /// @dev The low-latency verification scheme the verifier supports.
    uint8 internal constant _SCHEME = 1;

    /// @dev The entrypoint from which the verifier accepts verify requests.
    ///
    /// @custom:invariant Only entrypoint can call verify functions
    ///     msg.sig == "tryVerify" → msg.sender == _ENTRYPOINT
    address internal immutable _ENTRYPOINT;

    //--------------------------------------------------------------------------
    // Storage

    /// @dev Stores the configs for each wat.
    ///
    /// @dev Additionally to the current wat's config its last config is stored
    ///      to allow for a grace period after a config update. For more info,
    ///      see `_gracePeriod`.
    ///
    /// @custom:invariant Empty wat has no config
    ///     _cfgs[bytes32("")].cur.born == 0
    ///   ∧ _cfgs[bytes32("")].last.born == 0
    ///
    /// @custom:invariant Current config is never born earlier than last config
    ///   ∀ cfg ∊ _cfgs: cfg.cur.born >= cfg.last.born
    ///
    /// @custom:invariant Bar and bloom must both be zero or both be non-zero
    ///   ∀ cfg ∊ _cfgs:   (cfg.cur.bar  == 0) ↔ (cfg.cur.bloom  == 0)
    ///                  ∧ (cfg.last.bar == 0) ↔ (cfg.last.bloom == 0)
    ///
    /// @custom:invariant Config can only be updated via `setConfig`
    ///   ∀ cfg ∊ _cfgs: preTx(cfg.cur.born) != postTx(cfg.cur.born)
    ///                    → msg.sig == "setConfig"
    ///
    /// @custom:invariant Last config can only be set to current config
    ///   ∀ cfg ∊ _cfgs: preTx(cfg.last) != postTx(cfg.last)
    ///                    → postTx(cfg.last) = preTx(cfg.cur)
    mapping(bytes32 => WatConfigTuple) _cfgs;

    /// @dev The set of global validators indexed via their 1-byte identifier.
    ///
    /// @custom:invariant Validators are indexed via their 1-byte identifier
    ///   ∀ id ∊ Uint8: _validators[id] != 0 → validators[id] >> 152 == id
    address[256] internal _validators;

    /// @dev The bloom of the global set of validators.
    ///
    /// @custom:invariant Bloom encodes _validators.
    ///     ∀ id ∊ Uint8: _validators[id] != 0 ↔ _bloom & (1 << id) != 0
    uint internal _bloom;

    /// @dev The grace period during which both wat configs, the current and
    ///      last one, are valid.
    ///
    /// @dev The grace period allows to successfully verify wat messages already
    ///      in transit during a config update and thereby weakens the
    ///      offchain's config update requirements from hard real-time to soft
    ///      soft real-time.
    ///
    /// @dev Note that offboarded wats do not have a grace period!
    uint16 internal _gracePeriod;

    /// @dev The staleness threshold defining after which age a validator
    ///      message is deemed invalid.
    ///
    /// @dev Note that if a single validator message included in a wat message,
    ///      ie a single ECDSA signed poke data included in a median proof, is
    ///      stale the whole message is considered invalid.
    uint16 internal _stalenessThreshold;

    //--------------------------------------------------------------------------
    // Constructor

    constructor(address initialAuthed, address entrypoint_)
        payable
        Auth(initialAuthed)
    {
        _ENTRYPOINT = entrypoint_;
    }

    //--------------------------------------------------------------------------
    // IVerifier Verify Functionality

    /// @inheritdoc IVerifier
    ///
    /// @custom:invariant Reverts iff out of gas.
    function tryVerify(bytes calldata watMessage)
        external
        view
        returns (bytes4, bytes32, uint, uint)
    {
        bytes4 err;

        // Fail if caller not entrypoint.
        if (msg.sender != _ENTRYPOINT) {
            return (NotEntrypoint.selector, bytes32(""), 0, 0);
        }

        // Decode header from wat message.
        WatMessageHeader memory header;
        (err, header) = _tryDecodeHeader(watMessage);
        if (err != NO_ERR) {
            return (err, bytes32(""), 0, 0);
        }
        // assert(header.wat != bytes32(""));
        // assert(header.bar != 0);

        // Initialize loop variables.
        //
        // Let bloom encode the processed set of validators.
        uint bloom;
        // Let oldest be the oldest processed validator message's age.
        uint oldest = type(uint).max;

        // Create additional scope to counteract stack-to-deep during non
        // --via-ir compilation.
        {
            // Let valMessage be the current validator message.
            ValidatorMessageECDSA memory valMessage;
            // Let last be the last processed validator message's val.
            uint last;

            // First prove coherence of wat message.
            //
            // Note that verification of wat message's conformity to its respective
            // config is performed afterwards.
            for (uint i; i < header.bar; i++) {
                // Cast i to uint8 without performing overflow check.
                //
                // Note that loop is bounded by header's bar field which is of type
                // uint8.
                uint8 index;
                assembly ("memory-safe") {
                    index := i
                }

                // Decode i'th validator message from wat message.
                valMessage = _decodeValidatorMessage(watMessage, index);

                // Fail if validator message from the future.
                if (valMessage.pokeData.age > block.timestamp) {
                    return (FutureMessage.selector, bytes32(""), 0, 0);
                }

                // Fail if validator message stale.
                //
                // Unchecked because the only protected operation performed is a
                // substraction from block.timestamp with the validator message's
                // age which is guaranteed to be less than or equal to
                // block.timestamp.
                unchecked {
                    uint staleness = block.timestamp - valMessage.pokeData.age;
                    if (staleness > _stalenessThreshold) {
                        return (StaleMessage.selector, bytes32(""), 0, 0);
                    }
                }

                // Recover signer and compute respective id.
                address signer = _recover(header.wat, valMessage);
                uint8 signerId = uint8(uint160(signer) >> 152);

                // Fail if signer not a validator.
                //
                // Note that this check succeeds if signer is the zero address
                // and _validators[0] == address(0), ie the 0x00 validator not
                // being lifted.
                if (_validators[signerId] != signer) {
                    return (NotAValidator.selector, bytes32(""), 0, 0);
                }

                // Fail if double signing attempted.
                if (bloom & (1 << signerId) != 0) {
                    return (DoubleSigningAttempted.selector, bytes32(""), 0, 0);
                }

                // Fail if validator messages not in ascending order based on val.
                if (valMessage.pokeData.val < last) {
                    return (MessagesNotSorted.selector, bytes32(""), 0, 0);
                }

                // Update loop variables.
                bloom |= 1 << signerId;
                last = valMessage.pokeData.val;
                oldest = oldest < valMessage.pokeData.age
                    ? oldest
                    : valMessage.pokeData.age;
            }
        }
        // assert(bloom != 0);

        // Fail if zero address used as signer.
        //
        // Note that the zero address signer check is performed outside the
        // loop to reduce the check's cost from O(n) to O(1).
        if (bloom & 1 == 1 && _validators[0] == address(0)) {
            return (SignerIsZeroAddress.selector, bytes32(""), 0, 0);
        }

        // Verify wat message conforms to its respective config.
        //
        // Note that this check is performed after the loop to efficiently
        // verify wat message's validators set is a subset of the wat config's
        // validator set. Note that this check can only be performed in O(1)
        // once the wat message's bloom is constructed.
        if (!_verifyConfig(header.wat, header.bar, bloom)) {
            return (ConfigInvalid.selector, bytes32(""), 0, 0);
        }

        // Let wat message's val be the val of the median's validator message.
        uint val = _median(watMessage, header.bar);

        // Let val's age be the age of the oldest validator message.
        uint age = oldest;

        return (NO_ERR, header.wat, val, age);
    }

    /// @dev Returns whether bar `bar` and bloom `bloom` is an acceptable config
    ///      for wat `wat`.
    ///
    /// @dev Whether a config is acceptable is defined as:
    ///
    ///         !offboarded && (matchesCur || (inGracePeriod && matchesLast)
    ///
    ///      where:
    ///         offboarded    : Whether wat's current config is zero
    ///         matchesCur    : Whether bar equals current config's bar and
    ///                         bloom is a subset of current config's bloom
    ///         inGracePeriod : Whether current config is in grace period
    ///         matchesLast   : Whether bar equals last config's bar and bloom
    ///                         is a subset of last config's bloom
    ///
    /// @custom:invariant Reverts iff out of gas.
    function _verifyConfig(bytes32 wat, uint8 bar, uint bloom)
        internal
        view
        returns (bool)
    {
        // assert(wat != bytes32(""));
        // assert(bar != 0);
        // assert(bloom != 0);

        // Load current config from storage.
        WatConfig memory cur = _cfgs[wat].cur;

        // Succeed if wat's current config matches given bar and bloom.
        //
        // Note that explicitly checking whether cur config exists is performed
        // after this check to optimize the happy path. Note that this is
        // possible due to the guarantee that bar is non-zero.
        if ((bloom | cur.bloom) == cur.bloom && bar == cur.bar) {
            return true;
        }

        // Fail if current config is zero, ie wat not supported.
        //
        // Note that there is no grace period when a wat is offboarded.
        if (cur.bar == 0) {
            return false;
        }

        // Fail if current config not in grace period, ie only current config
        // deemed valid.
        //
        // Unchecked because the only protected operation performed is a
        // substraction from block.timestamp with cur.born which is guaranteed
        // to be less than or equal to block.timestamp.
        unchecked {
            bool inGracePeriod = (block.timestamp - cur.born) <= _gracePeriod;
            if (!inGracePeriod) {
                return false;
            }
        }

        // If current config in grace period the last config may also be valid.
        //
        // Note that explicitly checking whether last config exists can be
        // abdicated due to the guarantee that bar is non-zero.
        WatConfig memory last = _cfgs[wat].last;
        if ((bloom | last.bloom) == last.bloom && bar == last.bar) {
            return true;
        }

        // Otherwise config is invalid.
        return false;
    }

    /// @custom:invariant Reverts iff out of gas.
    function _tryDecodeHeader(bytes calldata watMessage)
        internal
        pure
        returns (bytes4, WatMessageHeader memory)
    {
        WatMessageHeader memory header;

        // Note that checking whether wat message's length is sufficient to hold
        // at least the header is abdicated. This check MUST have been performed
        // by the entrypoint already in oder to _correctly_ forward messages.
        //
        // Nevertheless, note that reading non-existing calldata does not revert
        // but rather returns zero.
        //
        // require(
        //     watMessage.length < WAT_MESSAGE_HEADER_BYTE_SIZE,
        //     "internal error: entrypoint did not verify wat message's header"
        // );

        // Load both words from calldata.
        uint word0;
        uint word1;
        assembly ("memory-safe") {
            word0 := calldataload(watMessage.offset)
            word1 := calldataload(add(watMessage.offset, 0x20))
        }

        // Extract fields.
        //
        // Note that masking is not necessary due to casting.
        header.version = uint8(word0 >> 248);
        header.scheme = uint8(word0 >> 240);
        header.bar = uint8(word0 >> 232);
        header.wat = bytes32(word1);

        // Fail if version or scheme mismatch.
        if (header.version != _VERSION) {
            return (VersionMismatch.selector, header);
        }
        if (header.scheme != _SCHEME) {
            return (SchemeMismatch.selector, header);
        }

        // Fail if bar or wat zero.
        if (header.bar == 0) {
            return (BarIsZero.selector, header);
        }
        if (header.wat == 0) {
            return (WatIsZero.selector, header);
        }

        return (NO_ERR, header);
    }

    /// @custom:invariant Reverts iff out of gas.
    function _decodeValidatorMessage(bytes calldata watMessage, uint8 index)
        internal
        pure
        returns (ValidatorMessageECDSA memory)
    {
        uint offset = _computeValidatorMessageOffset(watMessage, index);

        // Read validator message's (val, age) tuple.
        uint valAndAge;
        assembly ("memory-safe") {
            valAndAge := calldataload(offset)
        }

        // Note that masking is not necessary due to casting.
        uint128 val = uint128(valAndAge >> 128);
        uint32 age = uint32(valAndAge >> 96);

        // Read and decompress validator message's EIP-2098 compressed ECDSA
        // signature.
        uint8 v;
        bytes32 r;
        bytes32 s;
        assembly ("memory-safe") {
            r := calldataload(add(0x20, offset))
            let yParityAndS := calldataload(add(offset, 0x40))

            // Receive s via masking yParityAndS with EIP-2098 mask.
            s := and(yParityAndS, _EIP2098_MASK)

            // Receive v via reading yParity, encoded in the last bit, and
            // adding 27.
            //
            // Note that yParity ∊ {0, 1} which cannot overflow by adding 27.
            v := add(shr(255, yParityAndS), 27)
        }

        return ValidatorMessageECDSA(PokeData(val, age), v, r, s);
    }

    /// @custom:invariant Reverts iff out of gas.
    function _median(bytes calldata watMessage, uint8 bar)
        internal
        pure
        returns (uint)
    {
        // assert(bar != 0);

        uint8 mid = bar >> 1;
        uint offset = _computeValidatorMessageOffset(watMessage, mid);

        // Read validator message's (val, age) tuple.
        uint valAndAge;
        assembly ("memory-safe") {
            valAndAge := calldataload(offset)
        }

        // Return only validator message's val.
        //
        // Note that masking is not necessary due to casting.
        return uint128(valAndAge >> 128);
    }

    /// @custom:invariant Reverts iff out of gas.
    function _computeValidatorMessageOffset(
        bytes calldata watMessage,
        uint8 index
    ) internal pure returns (uint) {
        // Note that index is the index'th validator message in given wat
        // message. Therefore, the offset to the index'th validator message MUST
        // be less than the total calldatasize, allowing computing the offset
        // via unchecked arithmetic.
        uint offset;
        unchecked {
            // Let initial offset be the offset to the first validator message.
            uint initialOffset;
            assembly ("memory-safe") {
                // forgefmt: disable-next-item
                initialOffset := add(
                    watMessage.offset,
                    WAT_MESSAGE_HEADER_BYTE_SIZE
                )
            }

            // Let dynamic offset be the offset from the first validator message
            // to the index'th validator message.
            uint dynamicOffset = uint(index) * VALIDATOR_MESSAGE_ECDSA_SIZE;
            // Note that type(uint8).max * VALIDATOR_MESSAGE_ECDSA_SIZE = 24,480.
            // assert(dynamicOffset <= 24_480);

            offset = initialOffset + dynamicOffset;
        }

        // uint calldatasize_;
        // assembly ("memory-safe") {
        //     calldatasize_ := calldatasize()
        // }
        // assert(offset < calldatasize_);

        return offset;
    }

    /// @dev Note that a ValidatorMessageECDSA signature scheme equals
    ///      Chronicle's legacy [Median] oracle scheme developed for MakerDAO.
    ///
    ///      This ensures validators don't have to sign the same data multiple
    ///      times.
    ///
    /// @custom:invariant Reverts iff out of gas.
    function _recover(bytes32 wat, ValidatorMessageECDSA memory valMessage)
        internal
        pure
        returns (address)
    {
        return ecrecover(
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    keccak256(
                        abi.encodePacked(
                            uint(valMessage.pokeData.val),
                            uint(valMessage.pokeData.age),
                            wat
                        )
                    )
                )
            ),
            valMessage.v,
            valMessage.r,
            valMessage.s
        );
    }

    //--------------------------------------------------------------------------
    // IVerifier Public View Functions

    /// @inheritdoc IVerifier
    function version() external pure returns (uint8) {
        return _VERSION;
    }

    /// @inheritdoc IVerifier
    function scheme() external pure returns (uint8) {
        return _SCHEME;
    }

    /// @inheritdoc IVerifier
    function entrypoint() external view returns (address) {
        return _ENTRYPOINT;
    }

    //--------------------------------------------------------------------------
    // Public View Functions

    /// @inheritdoc IVerifierECDSA
    function wats(bytes32 wat) public view returns (bool) {
        if (wat == bytes32("")) {
            revert WatIsZero();
        }

        return _cfgs[wat].cur.bar != 0;
    }

    /// @inheritdoc IVerifierECDSA
    function config(bytes32 wat) external view returns (uint, uint) {
        if (!wats(wat)) {
            revert WatNotSupported();
        }

        WatConfig memory cur = _cfgs[wat].cur;

        return (cur.bar, cur.bloom);
    }

    /// @inheritdoc IVerifierECDSA
    function validators() external view returns (address[] memory) {
        address[] memory validators_ = new address[](256);

        uint bloom = _bloom;
        uint ctr;
        for (uint i; i < 256; i++) {
            if (bloom & (1 << i) == 0) {
                continue;
            }

            address validator = _validators[i];
            // assert(validator != address(0));
            // assert(uint(validator) >> 152 == i);

            validators_[ctr++] = validator;
        }

        assembly ("memory-safe") {
            mstore(validators_, ctr)
        }

        return validators_;
    }

    /// @inheritdoc IVerifierECDSA
    function validators(address validator) external view returns (bool) {
        uint8 validatorId = uint8(uint160(validator) >> 152);

        return _validators[validatorId] == validator;
    }

    /// @inheritdoc IVerifierECDSA
    function validators(bytes32 wat) external view returns (address[] memory) {
        if (!wats(wat)) {
            revert WatNotSupported();
        }

        address[] memory validators_ = new address[](256);

        uint bloom = _cfgs[wat].cur.bloom;
        uint ctr;
        for (uint i; i < 256; i++) {
            if (bloom & (1 << i) == 0) {
                continue;
            }

            address validator = _validators[i];

            // Note that the following invariants are NOT enforced onchain.
            // For more info, see `drop()`.
            //
            // assert(validator != address(0));
            // assert(uint(validator) >> 152 == i);

            validators_[ctr++] = validator;
        }

        assembly ("memory-safe") {
            mstore(validators_, ctr)
        }

        return validators_;
    }

    /// @inheritdoc IVerifierECDSA
    function validators(bytes32 wat, address validator)
        external
        view
        returns (bool)
    {
        if (!wats(wat)) {
            revert WatNotSupported();
        }

        uint8 validatorId = uint8(uint160(validator) >> 152);

        // Note to not only verify validator is part of wat's bloom but also
        // part of the global bloom. This is necessary because `drop()` does
        // not verify whether a validator is lifted on a wat before dropping.
        return _validators[validatorId] == validator
            && _cfgs[wat].cur.bloom & (1 << validatorId) != 0;
    }

    /// @inheritdoc IVerifierECDSA
    function gracePeriod() external view returns (uint16) {
        return _gracePeriod;
    }

    /// @inheritdoc IVerifierECDSA
    function stalenessThreshold() external view returns (uint16) {
        return _stalenessThreshold;
    }

    //--------------------------------------------------------------------------
    // Auth'ed Functionality

    /// @inheritdoc IVerifierECDSA
    function setGracePeriod(uint16 gracePeriod_) external auth {
        require(gracePeriod_ != 0);

        if (_gracePeriod != gracePeriod_) {
            emit GracePeriodUpdated(msg.sender, _gracePeriod, gracePeriod_);
            _gracePeriod = gracePeriod_;
        }
    }

    /// @inheritdoc IVerifierECDSA
    function setStalenessThreshold(uint16 stalenessThreshold_) external auth {
        require(stalenessThreshold_ != 0);

        if (_stalenessThreshold != stalenessThreshold_) {
            emit StalenessThresholdUpdated(
                msg.sender, _stalenessThreshold, stalenessThreshold_
            );
            _stalenessThreshold = stalenessThreshold_;
        }
    }

    /// @inheritdoc IVerifierECDSA
    function setConfig(bytes32 wat, uint8 bar, uint bloom) external auth {
        require(wat != bytes32(""));

        // Fail if exclusively bar or bloom zero.
        require((bar == 0) == (bloom == 0));

        // Fail if config's validator set not a subset of global validator set.
        require(_bloom | bloom == _bloom);

        // Cache old config.
        WatConfig memory oldCfg = _cfgs[wat].cur;

        // Update configs.
        _cfgs[wat].cur = WatConfig(bloom, bar, uint32(block.timestamp));
        _cfgs[wat].last = oldCfg;

        emit ConfigUpdated(
            msg.sender, wat, oldCfg.bar, oldCfg.bloom, bar, bloom
        );
    }

    /// @inheritdoc IVerifierECDSA
    function lift(address validator) external auth {
        _lift(validator);
    }

    /// @inheritdoc IVerifierECDSA
    function lift(address[] memory validators_) external auth {
        for (uint i; i < validators_.length; i++) {
            _lift(validators_[i]);
        }
    }

    function _lift(address validator) internal {
        require(validator != address(0));

        uint8 validatorId = uint8(uint160(validator) >> 152);
        if (_validators[validatorId] == address(0)) {
            // assert(_bloom & (1 << validatorId) == 0);

            _validators[validatorId] = validator;
            _bloom |= 1 << validatorId;

            emit ValidatorLifted(msg.sender, validator);
        } else {
            // Note to be idempotent. However, disallow updating an id's validator
            // via lifting without dropping the previous validator.
            require(_validators[validatorId] == validator);
        }
    }

    /// @inheritdoc IVerifierECDSA
    function drop(uint8 validatorId) external auth {
        _drop(validatorId);
    }

    /// @inheritdoc IVerifierECDSA
    function drop(uint8[] memory validatorIds) external auth {
        for (uint i; i < validatorIds.length; i++) {
            _drop(validatorIds[i]);
        }
    }

    /// @dev Note that it is possible to drop a validator that is lifted for a
    ///      wat, ie part of a wat's bloom config. However, note that any ECDSA
    ///      signature verification for a dropped validator fails.
    function _drop(uint8 validatorId) internal {
        if (_validators[validatorId] != address(0)) {
            // assert(_bloom & (1 << validator) != 0);

            emit ValidatorDropped(msg.sender, _validators[validatorId]);

            _validators[validatorId] = address(0);
            _bloom &= ~(1 << validatorId);
        }
    }
}

/**
 * @dev Contract overwrite to deploy contract instances with specific naming.
 *
 *      For more info, see docs/Deployment.md.
 */
contract VerifierECDSA_1 is VerifierECDSA {
    constructor(address initialAuthed, address entrypoint_)
        VerifierECDSA(initialAuthed, entrypoint_)
    {}
}