// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// @author thirdweb

import "./interface/IPermissions.sol";
import "../lib/TWStrings.sol";

/**
 *  @title   Permissions
 *  @dev     This contracts provides extending-contracts with role-based access control mechanisms
 */
contract Permissions is IPermissions {
    /// @dev Map from keccak256 hash of a role => a map from address => whether address has role.
    mapping(bytes32 => mapping(address => bool)) private _hasRole;

    /// @dev Map from keccak256 hash of a role to role admin. See {getRoleAdmin}.
    mapping(bytes32 => bytes32) private _getRoleAdmin;

    /// @dev Default admin role for all roles. Only accounts with this role can grant/revoke other roles.
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /// @dev Modifier that checks if an account has the specified role; reverts otherwise.
    modifier onlyRole(bytes32 role) {
        _checkRole(role, msg.sender);
        _;
    }

    /**
     *  @notice         Checks whether an account has a particular role.
     *  @dev            Returns `true` if `account` has been granted `role`.
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     *  @param account  Address of the account for which the role is being checked.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _hasRole[role][account];
    }

    /**
     *  @notice         Checks whether an account has a particular role;
     *                  role restrictions can be swtiched on and off.
     *
     *  @dev            Returns `true` if `account` has been granted `role`.
     *                  Role restrictions can be swtiched on and off:
     *                      - If address(0) has ROLE, then the ROLE restrictions
     *                        don't apply.
     *                      - If address(0) does not have ROLE, then the ROLE
     *                        restrictions will apply.
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     *  @param account  Address of the account for which the role is being checked.
     */
    function hasRoleWithSwitch(bytes32 role, address account) public view returns (bool) {
        if (!_hasRole[role][address(0)]) {
            return _hasRole[role][account];
        }

        return true;
    }

    /**
     *  @notice         Returns the admin role that controls the specified role.
     *  @dev            See {grantRole} and {revokeRole}.
     *                  To change a role's admin, use {_setRoleAdmin}.
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     */
    function getRoleAdmin(bytes32 role) external view override returns (bytes32) {
        return _getRoleAdmin[role];
    }

    /**
     *  @notice         Grants a role to an account, if not previously granted.
     *  @dev            Caller must have admin role for the `role`.
     *                  Emits {RoleGranted Event}.
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     *  @param account  Address of the account to which the role is being granted.
     */
    function grantRole(bytes32 role, address account) public virtual override {
        _checkRole(_getRoleAdmin[role], msg.sender);
        if (_hasRole[role][account]) {
            revert("Can only grant to non holders");
        }
        _setupRole(role, account);
    }

    /**
     *  @notice         Revokes role from an account.
     *  @dev            Caller must have admin role for the `role`.
     *                  Emits {RoleRevoked Event}.
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     *  @param account  Address of the account from which the role is being revoked.
     */
    function revokeRole(bytes32 role, address account) public virtual override {
        _checkRole(_getRoleAdmin[role], msg.sender);
        _revokeRole(role, account);
    }

    /**
     *  @notice         Revokes role from the account.
     *  @dev            Caller must have the `role`, with caller being the same as `account`.
     *                  Emits {RoleRevoked Event}.
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     *  @param account  Address of the account from which the role is being revoked.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        if (msg.sender != account) {
            revert("Can only renounce for self");
        }
        _revokeRole(role, account);
    }

    /// @dev Sets `adminRole` as `role`'s admin role.
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = _getRoleAdmin[role];
        _getRoleAdmin[role] = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /// @dev Sets up `role` for `account`
    function _setupRole(bytes32 role, address account) internal virtual {
        _hasRole[role][account] = true;
        emit RoleGranted(role, account, msg.sender);
    }

    /// @dev Revokes `role` from `account`
    function _revokeRole(bytes32 role, address account) internal virtual {
        _checkRole(role, account);
        delete _hasRole[role][account];
        emit RoleRevoked(role, account, msg.sender);
    }

    /// @dev Checks `role` for `account`. Reverts with a message including the required role.
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!_hasRole[role][account]) {
            revert(
                string(
                    abi.encodePacked(
                        "Permissions: account ",
                        TWStrings.toHexString(uint160(account), 20),
                        " is missing role ",
                        TWStrings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /// @dev Checks `role` for `account`. Reverts with a message including the required role.
    function _checkRoleWithSwitch(bytes32 role, address account) internal view virtual {
        if (!hasRoleWithSwitch(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "Permissions: account ",
                        TWStrings.toHexString(uint160(account), 20),
                        " is missing role ",
                        TWStrings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// @author thirdweb

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IPermissions {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}
// SPDX-License-Identifier: Apache 2.0
pragma solidity ^0.8.0;

/// @author thirdweb

/**
 * @dev String operations.
 */
library TWStrings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @author Syky - Nathan Rempel

import "./interface/IGroupRegistry.sol";

import "@thirdweb-dev/contracts/extension/Permissions.sol";

contract GroupRegistry is IGroupRegistry, Permissions {
    /*//////////////////////////////////////////////////////////////
                            Constants
    //////////////////////////////////////////////////////////////*/

    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    /*//////////////////////////////////////////////////////////////
                            Mappings
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => ItemSet) private _groups;
    mapping(uint256 => ItemSet) private _subgroups;

    /*//////////////////////////////////////////////////////////////
                            Constructor
    //////////////////////////////////////////////////////////////*/

    constructor(address defaultAdmin_) {
        _setupRole(DEFAULT_ADMIN_ROLE, defaultAdmin_);
        _setRoleAdmin(MANAGER_ROLE, DEFAULT_ADMIN_ROLE);
    }

    /*//////////////////////////////////////////////////////////////
                        Admin functions
    //////////////////////////////////////////////////////////////*/

    function assignMembers(
        uint256 _subgroupId,
        address[] calldata _members
    ) external onlyValidId(_subgroupId) onlyManager {
        ItemSet storage _itemSet = _subgroups[_subgroupId];
        uint256 memberLength = _members.length;
        uint256[] memory members = new uint256[](memberLength);
        for (uint256 i; i < memberLength; ) {
            members[i] = uint160(_members[i]);
            unchecked {
                ++i;
            }
        }
        _insertItems(_itemSet, members);
        emit MembersAssigned(_subgroupId, _members);
    }

    function removeMembers(
        uint256 _subgroupId,
        address[] calldata _members
    ) external onlyValidId(_subgroupId) onlyManager {
        ItemSet storage _itemSet = _subgroups[_subgroupId];
        uint256 memberLength = _members.length;
        uint256[] memory members = new uint256[](memberLength);
        for (uint256 i; i < memberLength; ) {
            members[i] = uint160(_members[i]);
            unchecked {
                ++i;
            }
        }
        _removeItems(_itemSet, members);
        emit MembersAssigned(_subgroupId, _members);
    }

    function assignSubgroups(
        uint256 _groupId,
        uint256[] calldata _subgroupIds
    ) external onlyValidId(_groupId) onlyManager {
        ItemSet storage _itemSet = _groups[_groupId];
        _insertItems(_itemSet, _subgroupIds);
        emit SubgroupsAssigned(_groupId, _subgroupIds);
    }

    function removeSubgroups(
        uint256 _groupId,
        uint256[] calldata _subgroupIds
    ) external onlyValidId(_groupId) onlyManager {
        ItemSet storage _itemSet = _groups[_groupId];
        _removeItems(_itemSet, _subgroupIds);
        emit SubgroupsRemoved(_groupId, _subgroupIds);
    }

    /*//////////////////////////////////////////////////////////////
                        Public getters
    //////////////////////////////////////////////////////////////*/

    function isGroupMember(
        uint256 _groupId,
        address _member
    ) external view returns (bool) {
        return _isGroupMember(_groupId, _member);
    }

    function isSubgroupMember(
        uint256 _subgroupId,
        address _member
    ) external view returns (bool) {
        return _isSubgroupMember(_subgroupId, _member);
    }

    function groupMembers(
        uint256 _groupId
    ) external view returns (GroupMembersQuery memory) {
        return
            GroupMembersQuery({groupId: _groupId, subgroups: _getGroupMembers(_groupId)});
    }

    function groupSubgroups(uint256 _groupId) external view returns (uint256[] memory) {
        return _getSubgroups(_groupId);
    }

    function subgroupMembers(
        uint256 _subgroupId
    ) external view returns (SubgroupMembersQuery memory) {
        return
            SubgroupMembersQuery({
                subgroupId: _subgroupId,
                members: _getSubgroupMembers(_subgroupId)
            });
    }

    /*//////////////////////////////////////////////////////////////
                            Modifiers
    //////////////////////////////////////////////////////////////*/

    /// @dev Modifier that checks if an account has admin or manager role; reverts otherwise.
    modifier onlyManager() {
        _checkManagerAdmin();
        _;
    }

    modifier onlyValidId(uint256 _id) {
        if (_id == 0) revert NonZeroIdRequired();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                        Internal functions
    //////////////////////////////////////////////////////////////*/

    /// @dev Function that checks if an account has admin or manager role; reverts otherwise.
    function _checkManagerAdmin() internal view {
        if (
            !hasRole(DEFAULT_ADMIN_ROLE, msg.sender) && !hasRole(MANAGER_ROLE, msg.sender)
        ) {
            revert ManagerRoleRequired();
        }
    }

    function _insertItems(
        ItemSet storage _itemSet,
        uint256[] memory _items
    ) internal virtual {
        uint256 assignCount = _items.length;
        if (assignCount == 0) revert NonEmptyArrayRequired();

        uint256 currentIdx = _itemSet.index;
        for (uint256 i; i < assignCount; ) {
            //don't add zero group
            if (_items[i] == 0) continue;

            //don't add existing subgroup
            uint256 existingIdx = _itemSet.indexOf[_items[i]];
            if (_itemSet.items[existingIdx] == _items[i]) continue;

            //add subgroup to current index
            _itemSet.items[currentIdx] = _items[i];

            unchecked {
                //add the index reference, increment the current index
                _itemSet.indexOf[_items[i]] = currentIdx++;
                ++i;
            }
        }
        //revert if no changes to save gas
        if (_itemSet.index == currentIdx) revert AlreadyAssigned();

        //save the new index
        _itemSet.index = currentIdx;
    }

    function _removeItems(
        ItemSet storage _itemSet,
        uint256[] memory _items
    ) internal virtual {
        uint256 removeCount = _items.length;
        if (removeCount == 0) revert NonEmptyArrayRequired();

        bool unchanged = true;

        for (uint256 i; i < removeCount; ) {
            //don't add zero addresses
            if (_items[i] == 0) continue;

            //confirm the member exists
            uint256 existingIdx = _itemSet.indexOf[_items[i]];
            if (_itemSet.items[existingIdx] == _items[i]) {
                delete _itemSet.items[existingIdx];
                delete _itemSet.indexOf[_items[i]];
                unchanged = false;
            }

            unchecked {
                ++i;
            }
        }

        //revert if no changes to save gas
        if (unchanged) revert AlreadyRemoved();
    }

    function _selectItems(
        ItemSet storage _itemSet
    ) internal view returns (uint256[] memory) {
        uint256 itemLength = _itemSet.index;

        uint256[] memory allItems = new uint256[](itemLength);
        uint256 actualLength = 0;

        unchecked {
            for (uint256 i; i < itemLength; ) {
                allItems[i] = _itemSet.items[i];
                if (allItems[i] != 0) {
                    ++actualLength;
                }
                ++i;
            }
        }

        uint256[] memory actualItems = new uint256[](actualLength);

        uint256 idx;

        unchecked {
            for (uint256 i; i < itemLength; ) {
                if (allItems[i] != 0) {
                    actualItems[idx] = allItems[i];
                    ++idx;
                }
                ++i;
            }
        }

        return actualItems;
    }

    function _isGroupMember(
        uint256 _groupId,
        address _member
    ) internal view returns (bool) {
        uint256 subgroupCount = _groups[_groupId].index;
        for (uint256 i; i < subgroupCount; ) {
            uint256 subgroupId = _groups[_groupId].items[i];
            if (subgroupId == 0) continue;
            if (_isSubgroupMember(subgroupId, _member)) return true;
            unchecked {
                ++i;
            }
        }
        return false;
    }

    function _isSubgroupMember(
        uint256 _subgroupId,
        address _member
    ) internal view returns (bool) {
        uint256 memberIdx = _subgroups[_subgroupId].indexOf[uint160(_member)];
        return _subgroups[_subgroupId].items[memberIdx] == uint160(_member);
    }

    function _getSubgroups(uint256 _groupId) internal view returns (uint256[] memory) {
        ItemSet storage group = _groups[_groupId];
        return _selectItems(group);
    }

    function _getSubgroupMembers(
        uint256 _subgroupId
    ) internal view returns (address[] memory) {
        ItemSet storage subgroup = _subgroups[_subgroupId];
        uint256[] memory items = _selectItems(subgroup);
        uint256 itemsLength = items.length;

        address[] memory members = new address[](itemsLength);
        for (uint256 i; i < itemsLength; ) {
            members[i] = address(uint160(items[i]));
            unchecked {
                ++i;
            }
        }
        return members;
    }

    function _getGroupMembers(
        uint256 _groupId
    ) internal view returns (SubgroupMembersQuery[] memory) {
        uint256[] memory subgroupIds = _getSubgroups(_groupId);

        uint256 subgroupsLength = subgroupIds.length;
        SubgroupMembersQuery[] memory subgroups = new SubgroupMembersQuery[](
            subgroupsLength
        );

        for (uint256 i; i < subgroupsLength; ) {
            subgroups[i] = SubgroupMembersQuery({
                subgroupId: subgroupIds[i],
                members: _getSubgroupMembers(subgroupIds[i])
            });
            unchecked {
                ++i;
            }
        }

        return subgroups;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @author Syky - Nathan Rempel

interface IGroupRegistry {
    struct ItemSet {
        uint256 index;
        mapping(uint256 => uint256) items;
        mapping(uint256 => uint256) indexOf;
    }

    struct GroupMembersQuery {
        uint256 groupId;
        SubgroupMembersQuery[] subgroups;
    }

    struct SubgroupMembersQuery {
        uint256 subgroupId;
        address[] members;
    }

    function isGroupMember(
        uint256 _groupId,
        address _member
    ) external view returns (bool);

    function isSubgroupMember(
        uint256 _subgroupId,
        address _member
    ) external view returns (bool);

    function groupMembers(
        uint256 _groupId
    ) external view returns (GroupMembersQuery memory);

    function groupSubgroups(uint256 _groupId) external view returns (uint256[] memory);

    function subgroupMembers(
        uint256 _subgroupId
    ) external view returns (SubgroupMembersQuery memory);

    function assignMembers(uint256 _subgroupId, address[] calldata _members) external;

    function removeMembers(uint256 _subgroupId, address[] calldata _members) external;

    function assignSubgroups(uint256 _groupId, uint256[] calldata _subgroupIds) external;

    function removeSubgroups(uint256 _groupId, uint256[] calldata _subgroupIds) external;

    event MembersAssigned(uint256 indexed subgroupId, address[] members);
    event MembersRemoved(uint256 indexed subgroupId, address[] members);
    event SubgroupsAssigned(uint256 indexed groupId, uint256[] subgroupIds);
    event SubgroupsRemoved(uint256 indexed groupId, uint256[] subgroupIds);

    error ManagerRoleRequired();
    error NonZeroIdRequired();
    error NonEmptyArrayRequired();
    error AlreadyAssigned();
    error AlreadyRemoved();
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @author Syky - Nathan Rempel

/*
           @@@   @@@@@   @@@@@@@         @@@@    @@@@@@@      @@@@@     @@@@@@@        @@@@
         @@@@      @@@     @@@@@@        @@       @@@@@@       @@        @@@@@@        @@
         @@@@@      @@      @@@@@       @@        @@@@@       @            @@@@@      @@
         @@@@@@      @@      @@@@@     @@         @@@@@     @               @@@@     @@
          @@@@@@      @       @@@@@   @@          @@@@@    @                @@@@@    @
           @@@@@@@             @@@@@ @@           @@@@@  @@@                 @@@@@  @
             @@@@@@             @@@@@@            @@@@@@@@@@@                 @@@@@@
               @@@@@@           @@@@@             @@@@@  @@@@@                 @@@@@
                @@@@@@@         @@@@@             @@@@@   @@@@@                @@@@@
         @        @@@@@@        @@@@@             @@@@@    @@@@@               @@@@@
         @@        @@@@@        @@@@@             @@@@@     @@@@@              @@@@@
         @@@@      @@@@@        @@@@@             @@@@@@     @@@@@@           @@@@@@
         @@@@@@   @@@@         @@@@@@@           @@@@@@@     @@@@@@@          @@@@@@@
*/

import "../base/GroupRegistry.sol";

contract SykyGroups is GroupRegistry {
    /*//////////////////////////////////////////////////////////////
                            Version Info
    //////////////////////////////////////////////////////////////*/

    string public constant ENV = "GOERLI";
    string public constant VER = "1.0.0";

    /*//////////////////////////////////////////////////////////////
                            Constructor
    //////////////////////////////////////////////////////////////*/

    constructor(address defaultAdmin_) GroupRegistry(defaultAdmin_) {}
}