// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.17;

import {EnumerableSet} from "./dependencies/EnumerableSet.sol";
import {Authority} from "solmate/auth/Auth.sol";
import {RolesAuthority} from "./RolesAuthority.sol";

/// @notice Role based Authority that supports up to 256 roles.
/// @notice We have taken the tradeoff of additional storage usage for easier readabiliy without using off-chain / indexing services.
/// @author BadgerDAO Expanded from Solmate RolesAuthority
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/authorities/RolesAuthority.sol)
/// @author Modified from Dappsys (https://github.com/dapphub/ds-roles/blob/master/src/roles.sol)
contract Governor is RolesAuthority {
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 NO_ROLES = bytes32(0);

    struct Role {
        uint8 roleId;
        string roleName;
    }

    struct Capability {
        address target;
        bytes4 functionSig;
        uint8[] roles;
    }

    mapping(uint8 => string) internal roleNames;

    event RoleNameSet(uint8 indexed role, string indexed name);

    /// @notice The contract constructor initializes RolesAuthority with the given owner.
    /// @param _owner The address of the owner, who gains all permissions by default.
    constructor(address _owner) RolesAuthority(_owner, Authority(address(this))) {}

    /// @notice Returns a list of users that are assigned a specific role.
    /// @dev This function searches all users and checks if they are assigned the given role.
    /// @dev Intended for off-chain utility only due to inefficiency.
    /// @param role The role ID to find users for.
    /// @return usersWithRole An array of addresses that are assigned the given role.
    function getUsersByRole(uint8 role) external view returns (address[] memory usersWithRole) {
        // Search over all users: O(n) * 2
        uint256 count;
        for (uint256 i = 0; i < users.length(); i++) {
            address user = users.at(i);
            bool _canCall = doesUserHaveRole(user, role);
            if (_canCall) {
                count += 1;
            }
        }
        if (count > 0) {
            uint256 j = 0;
            usersWithRole = new address[](count);
            address[] memory _usrs = users.values();
            for (uint256 i = 0; i < _usrs.length; i++) {
                address user = _usrs[i];
                bool _canCall = doesUserHaveRole(user, role);
                if (_canCall) {
                    usersWithRole[j] = user;
                    j++;
                }
            }
        }
    }

    /// @notice Returns a list of roles that an address has.
    /// @dev This function searches all roles and checks if they are assigned to the given user.
    /// @dev Intended for off-chain utility only due to inefficiency.
    /// @param user The address of the user.
    /// @return rolesForUser An array of role IDs that the user has.
    function getRolesForUser(address user) external view returns (uint8[] memory rolesForUser) {
        // Enumerate over all possible roles and check if enabled
        uint256 count;
        for (uint8 i = 0; i <= type(uint8).max;) {
            if (doesUserHaveRole(user, i)) {
                count += 1;
            }
            if (i < type(uint8).max) {
                i = i + 1;
            } else {
                break;
            }
        }
        if (count > 0) {
            uint256 j = 0;
            rolesForUser = new uint8[](count);
            for (uint8 i = 0; i <= type(uint8).max;) {
                if (doesUserHaveRole(user, i)) {
                    rolesForUser[j] = i;
                    j++;
                }
                if (i < type(uint8).max) {
                    i = i + 1;
                } else {
                    break;
                }
            }
        }
    }

    /// @notice Converts a byte map representation to an array of role IDs.
    /// @param byteMap The bytes32 value encoding the roles.
    /// @return roleIds An array of role IDs extracted from the byte map.
    function getRolesFromByteMap(bytes32 byteMap) public pure returns (uint8[] memory roleIds) {
        uint256 count;
        for (uint8 i = 0; i <= type(uint8).max;) {
            bool roleEnabled = (uint256(byteMap >> i) & 1) != 0;
            if (roleEnabled) {
                count += 1;
            }
            if (i < type(uint8).max) {
                i = i + 1;
            } else {
                break;
            }
        }
        if (count > 0) {
            uint256 j = 0;
            roleIds = new uint8[](count);
            for (uint8 i = 0; i <= type(uint8).max;) {
                bool roleEnabled = (uint256(byteMap >> i) & 1) != 0;
                if (roleEnabled) {
                    roleIds[j] = i;
                    j++;
                }
                if (i < type(uint8).max) {
                    i = i + 1;
                } else {
                    break;
                }
            }
        }
    }

    /// @notice Converts an array of role IDs to a byte map representation.
    /// @param roleIds An array of role IDs.
    /// @return A bytes32 value encoding the roles.
    function getByteMapFromRoles(uint8[] memory roleIds) public pure returns (bytes32) {
        bytes32 _data;
        for (uint256 i = 0; i < roleIds.length; i++) {
            _data |= bytes32(1 << uint256(roleIds[i]));
        }
        return _data;
    }

    /// @notice Retrieves all function signatures enabled for a target address.
    /// @param _target The target contract address.
    /// @return _funcs An array of function signatures enabled for the target.
    function getEnabledFunctionsInTarget(address _target) public view returns (bytes4[] memory _funcs) {
        bytes32[] memory _sigs = enabledFunctionSigsByTarget[_target].values();
        if (_sigs.length > 0) {
            _funcs = new bytes4[](_sigs.length);
            for (uint256 i = 0; i < _sigs.length; ++i) {
                _funcs[i] = bytes4(_sigs[i]);
            }
        }
    }

    /// @notice Retrieves the name associated with a role ID.
    /// @param role The role ID.
    /// @return roleName The name of the role.
    function getRoleName(uint8 role) external view returns (string memory roleName) {
        return roleNames[role];
    }

    /// @notice Sets the name for a specific role ID for improved readability.
    /// @dev This function requires authorization.
    /// @param role The role ID.
    /// @param roleName The name to assign to the role.
    function setRoleName(uint8 role, string memory roleName) external requiresAuth {
        roleNames[role] = roleName;

        emit RoleNameSet(role, roleName);
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.17;

import {Auth, Authority} from "solmate/auth/Auth.sol";
import {EnumerableSet} from "./dependencies/EnumerableSet.sol";
import {IRolesAuthority} from "./interfaces/IRolesAuthority.sol";

/// @notice Role based Authority that supports up to 256 roles.
/// @author BadgerDAO expanded with capability burning and enumeration of role holders and targets
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/authorities/RolesAuthority.sol)
/// @author Modified from Dappsys (https://github.com/dapphub/ds-roles/blob/master/src/roles.sol)
contract RolesAuthority is IRolesAuthority, Auth, Authority {
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner, Authority _authority) Auth(_owner, _authority) {}

    /*//////////////////////////////////////////////////////////////
                            ROLE/USER STORAGE
    //////////////////////////////////////////////////////////////*/

    EnumerableSet.AddressSet internal users;
    EnumerableSet.AddressSet internal targets;
    mapping(address => EnumerableSet.Bytes32Set) internal enabledFunctionSigsByTarget;

    EnumerableSet.Bytes32Set internal enabledFunctionSigsPublic;

    mapping(address => bytes32) public getUserRoles;

    mapping(address => mapping(bytes4 => CapabilityFlag)) public capabilityFlag;

    mapping(address => mapping(bytes4 => bytes32)) public getRolesWithCapability;

    /// @notice Checks if a user has a specific role.
    /// @param user The address of the user to check.
    /// @param role The role to check for.
    /// @return bool True if the user has the role, false otherwise.
    function doesUserHaveRole(address user, uint8 role) public view virtual returns (bool) {
        return (uint256(getUserRoles[user]) >> role) & 1 != 0;
    }

    /// @notice Checks if a role has the capability to call a specific function on a target contract.
    /// @param role The role to check the capability for.
    /// @param target The address of the target contract.
    /// @param functionSig The function signature to check the capability for.
    /// @return bool True if the role has the capability, false otherwise.
    function doesRoleHaveCapability(uint8 role, address target, bytes4 functionSig)
        public
        view
        virtual
        returns (bool)
    {
        return (uint256(getRolesWithCapability[target][functionSig]) >> role) & 1 != 0;
    }

    /// @notice Checks if a function on a target contract is publicly accessible.
    /// @param target The address of the target contract.
    /// @param functionSig The function signature to check.
    /// @return bool True if the function is public, false otherwise.
    function isPublicCapability(address target, bytes4 functionSig) public view returns (bool) {
        return capabilityFlag[target][functionSig] == CapabilityFlag.Public;
    }

    /*//////////////////////////////////////////////////////////////
                           AUTHORIZATION LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Checks if a user has the authorization to call a specific function on a target contract.
    /// @notice Authorization is granted if the function's capability is set to public, or if the user possesses a role with the required capability, provided the capability has not been burned.
    /// @param user The address of the user attempting to call the function.
    /// @param target The address of the contract containing the function.
    /// @param functionSig The function signature being called.
    /// @return bool Returns true if the user is authorized to call the function, false otherwise.
    function canCall(address user, address target, bytes4 functionSig) public view virtual override returns (bool) {
        CapabilityFlag flag = capabilityFlag[target][functionSig];

        if (flag == CapabilityFlag.Burned) {
            return false;
        } else if (flag == CapabilityFlag.Public) {
            return true;
        } else {
            return bytes32(0) != getUserRoles[user] & getRolesWithCapability[target][functionSig];
        }
    }

    /*//////////////////////////////////////////////////////////////
                   ROLE CAPABILITY CONFIGURATION LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Enables or disables public access to a specific function signature on a target contract.
    /// @dev Checks to ensure the capability has not been previously burned before allowing modification.
    /// @param target The contract address whose function signature's capability is being modified.
    /// @param functionSig The function signature whose capability flag is being set.
    /// @param enabled A boolean indicating whether to enable (true) or disable (false) public access.
    function setPublicCapability(address target, bytes4 functionSig, bool enabled) public virtual requiresAuth {
        require(capabilityFlag[target][functionSig] != CapabilityFlag.Burned, "RolesAuthority: Capability Burned");

        if (enabled) {
            capabilityFlag[target][functionSig] = CapabilityFlag.Public;
        } else {
            capabilityFlag[target][functionSig] = CapabilityFlag.None;
        }

        emit PublicCapabilityUpdated(target, functionSig, enabled);
    }

    /// @notice Grants or revokes a specified role's ability to call a function on a target.
    /// @notice If the capability is already public or has been burned, this function will have no effect.
    /// @param role The role ID to update the capability for.
    /// @param target The address of the contract where the function signature resides.
    /// @param functionSig The function signature to update the capability for.
    /// @param enabled True to grant the capability, false to revoke it.
    function setRoleCapability(uint8 role, address target, bytes4 functionSig, bool enabled)
        public
        virtual
        requiresAuth
    {
        if (enabled) {
            // Grant the role the capability to call the function signature on the target.
            getRolesWithCapability[target][functionSig] |= bytes32(1 << role);
            enabledFunctionSigsByTarget[target].add(bytes32(functionSig));

            if (!targets.contains(target)) {
                targets.add(target);
            }
        } else {
            // Revoke the role's capability to call the function signature on the target.
            getRolesWithCapability[target][functionSig] &= ~bytes32(1 << role);

            // If no roles are left with the capability to call the function signature, remove it from the list of enabled function signatures for the target.
            if (getRolesWithCapability[target][functionSig] == bytes32(0)) {
                enabledFunctionSigsByTarget[target].remove(bytes32(functionSig));
            }

            // If no function signatures are left enabled for the target, remove the target.
            if (enabledFunctionSigsByTarget[target].length() == 0) {
                targets.remove(target);
            }
        }

        emit RoleCapabilityUpdated(role, target, functionSig, enabled);
    }

    /// @notice Permanently burns a capability for a target, preventing it from being called in the future.
    /// @dev Intended for use to renounce a capability of a governance entity.
    /// @param target The address of the contract where the capability is being burned.
    /// @param functionSig The function signature of the capability being burned.
    function burnCapability(address target, bytes4 functionSig) public virtual requiresAuth {
        require(capabilityFlag[target][functionSig] != CapabilityFlag.Burned, "RolesAuthority: Capability Burned");
        capabilityFlag[target][functionSig] = CapabilityFlag.Burned;

        emit CapabilityBurned(target, functionSig);
    }

    /*//////////////////////////////////////////////////////////////
                       USER ROLE ASSIGNMENT LOGIC
    //////////////////////////////////////////////////////////////*/
    /// @notice Assigns or removes a role for an address.
    /// @param user The address of the user to assign/remove the role to/from.
    /// @param role The role ID to assign/remove.
    /// @param enabled True to assign the role, false to remove it.
    function setUserRole(address user, uint8 role, bool enabled) public virtual requiresAuth {
        if (enabled) {
            getUserRoles[user] |= bytes32(1 << role);

            if (!users.contains(user)) {
                users.add(user);
            }
        } else {
            getUserRoles[user] &= ~bytes32(1 << role);

            // Remove user if no more roles
            if (getUserRoles[user] == bytes32(0)) {
                users.remove(user);
            }
        }

        emit UserRoleUpdated(user, role, enabled);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.17;

import {EnumerableSet} from "../dependencies/EnumerableSet.sol";

/// @notice Role based Authority that supports up to 256 roles.
/// @author BadgerDAO
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/authorities/RolesAuthority.sol)
/// @author Modified from Dappsys (https://github.com/dapphub/ds-roles/blob/master/src/roles.sol)
interface IRolesAuthority {
    event UserRoleUpdated(address indexed user, uint8 indexed role, bool enabled);

    event PublicCapabilityUpdated(address indexed target, bytes4 indexed functionSig, bool enabled);
    event CapabilityBurned(address indexed target, bytes4 indexed functionSig);

    event RoleCapabilityUpdated(uint8 indexed role, address indexed target, bytes4 indexed functionSig, bool enabled);

    enum CapabilityFlag {
        None,
        Public,
        Burned
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Provides a flexible and updatable auth pattern which is completely separate from application logic.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Auth.sol)
/// @author Modified from Dappsys (https://github.com/dapphub/ds-auth/blob/master/src/auth.sol)
abstract contract Auth {
    event OwnershipTransferred(address indexed user, address indexed newOwner);

    event AuthorityUpdated(address indexed user, Authority indexed newAuthority);

    address public owner;

    Authority public authority;

    constructor(address _owner, Authority _authority) {
        owner = _owner;
        authority = _authority;

        emit OwnershipTransferred(msg.sender, _owner);
        emit AuthorityUpdated(msg.sender, _authority);
    }

    modifier requiresAuth() virtual {
        require(isAuthorized(msg.sender, msg.sig), "UNAUTHORIZED");

        _;
    }

    function isAuthorized(address user, bytes4 functionSig) internal view virtual returns (bool) {
        Authority auth = authority; // Memoizing authority saves us a warm SLOAD, around 100 gas.

        // Checking if the caller is the owner only after calling the authority saves gas in most cases, but be
        // aware that this makes protected functions uncallable even to the owner if the authority is out of order.
        return (address(auth) != address(0) && auth.canCall(user, address(this), functionSig)) || user == owner;
    }

    function setAuthority(Authority newAuthority) public virtual {
        // We check if the caller is the owner first because we want to ensure they can
        // always swap out the authority even if it's reverting or using up a lot of gas.
        require(msg.sender == owner || authority.canCall(msg.sender, address(this), msg.sig));

        authority = newAuthority;

        emit AuthorityUpdated(msg.sender, newAuthority);
    }

    function transferOwnership(address newOwner) public virtual requiresAuth {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}

/// @notice A generic interface for a contract which provides authorization data to an Auth instance.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Auth.sol)
/// @author Modified from Dappsys (https://github.com/dapphub/ds-auth/blob/master/src/auth.sol)
interface Authority {
    function canCall(
        address user,
        address target,
        bytes4 functionSig
    ) external view returns (bool);
}