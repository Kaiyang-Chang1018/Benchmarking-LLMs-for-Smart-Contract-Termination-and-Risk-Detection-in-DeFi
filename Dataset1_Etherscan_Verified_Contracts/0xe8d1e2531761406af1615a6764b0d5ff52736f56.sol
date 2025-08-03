# pragma version ~=0.4.0
"""
@title Multi-Role-Based Access Control Functions
@custom:contract-name access_control
@license GNU Affero General Public License v3.0 only
@author pcaversaccio
@notice These functions can be used to implement role-based access
        control mechanisms. Roles are referred to by their `bytes32`
        identifier. These should be exposed in the external API and
        be unique. The best way to achieve this is by using `public`
        `constant` hash digests:
        ```vy
        MY_ROLE: public(constant(bytes32)) = keccak256("MY_ROLE");
        ```

        Roles can be used to represent a set of permissions. To restrict
        access to a function call, use the `external` function `hasRole`
        or the `internal` function `_check_role` (to avoid any NatSpec
        parsing error, no `@` character is added to the visibility decorator
        `@external` in the following examples; please add them accordingly):
        ```vy
        from ethereum.ercs import IERC165
        implements: IERC165

        from snekmate.auth.interfaces import IAccessControl
        implements: IAccessControl

        from snekmate.auth import access_control
        initializes: access_control

        exports: access_control.__interface__

        ...

        external
        def foo():
            assert access_control.hasRole[MY_ROLE][msg.sender], "access_control: account is missing role"
            ...

        OR

        external
        def foo():
            access_control._check_role(MY_ROLE, msg.sender)
            ...
        ```

        Roles can be granted and revoked dynamically via the `grantRole`
        and `revokeRole` functions. Each role has an associated admin role,
        and only accounts that have a role's admin role can call `grantRole`
        and `revokeRole`. Also, by default, the admin role for all roles is
        `DEFAULT_ADMIN_ROLE`, which means that only accounts with this role
        will be able to grant or revoke other roles. More complex role
        relationships can be created by using `set_role_admin`.

        WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin! It has
        permission to grant and revoke this role. Extra precautions should be
        taken to secure accounts that have been granted it.

        The implementation is inspired by OpenZeppelin's implementation here:
        https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControl.sol.
"""


# @dev We import and implement the `IERC165` interface,
# which is a built-in interface of the Vyper compiler.
from ethereum.ercs import IERC165
implements: IERC165


# @dev We import and implement the `IAccessControl`
# interface, which is written using standard Vyper
# syntax.
import interfaces.IAccessControl as IAccessControl
implements: IAccessControl


# @dev The default 32-byte admin role.
# @notice If you declare a variable as `public`,
# Vyper automatically generates an `external`
# getter function for the variable.
DEFAULT_ADMIN_ROLE: public(constant(bytes32)) = empty(bytes32)


# @dev Stores the ERC-165 interface identifier for each
# imported interface. The ERC-165 interface identifier
# is defined as the XOR of all function selectors in the
# interface.
_SUPPORTED_INTERFACES: constant(bytes4[2]) = [
    0x01FFC9A7, # The ERC-165 identifier for ERC-165.
    0x7965DB0B, # The ERC-165 identifier for `IAccessControl`.
]


# @dev Returns `True` if `account` has been granted `role`.
hasRole: public(HashMap[bytes32, HashMap[address, bool]])


# @dev Returns the admin role that controls `role`.
getRoleAdmin: public(HashMap[bytes32, bytes32])


@deploy
@payable
def __init__():
    """
    @dev To omit the opcodes for checking the `msg.value`
         in the creation-time EVM bytecode, the constructor
         is declared as `payable`.
    @notice The `DEFAULT_ADMIN_ROLE` role will be assigned
            to the `msg.sender`.
    """
    self._grant_role(DEFAULT_ADMIN_ROLE, msg.sender)


@external
@view
def supportsInterface(interface_id: bytes4) -> bool:
    """
    @dev Returns `True` if this contract implements the
         interface defined by `interface_id`.
    @param interface_id The 4-byte interface identifier.
    @return bool The verification whether the contract
            implements the interface or not.
    """
    return interface_id in _SUPPORTED_INTERFACES


@external
def grantRole(role: bytes32, account: address):
    """
    @dev Grants `role` to `account`.
    @notice If `account` had not been already
            granted `role`, emits a `RoleGranted`
            event. Note that the caller must have
            `role`'s admin role.
    @param role The 32-byte role definition.
    @param account The 20-byte address of the account.
    """
    self._check_role(self.getRoleAdmin[role], msg.sender)
    self._grant_role(role, account)


@external
def revokeRole(role: bytes32, account: address):
    """
    @dev Revokes `role` from `account`.
    @notice If `account` had been granted `role`,
            emits a `RoleRevoked` event. Note that
            the caller must have `role`'s admin role.
    @param role The 32-byte role definition.
    @param account The 20-byte address of the account.
    """
    self._check_role(self.getRoleAdmin[role], msg.sender)
    self._revoke_role(role, account)


@external
def renounceRole(role: bytes32, account: address):
    """
    @dev Revokes `role` from the calling account.
    @notice Roles are often managed via `grantRole`
            and `revokeRole`. This function's purpose
            is to provide a mechanism for accounts to
            lose their privileges if they are compromised
            (such as when a trusted device is misplaced).
            If the calling account had been granted `role`,
            emits a `RoleRevoked` event. Note that the
            caller must be `account`.
    @param role The 32-byte role definition.
    @param account The 20-byte address of the account.
    """
    assert account == msg.sender, "access_control: can only renounce roles for itself"
    self._revoke_role(role, account)


@external
def set_role_admin(role: bytes32, admin_role: bytes32):
    """
    @dev Sets `admin_role` as `role`'s admin role.
    @notice Note that the caller must have `role`'s
            admin role.
    @param role The 32-byte role definition.
    @param admin_role The new 32-byte admin role definition.
    """
    self._check_role(self.getRoleAdmin[role], msg.sender)
    self._set_role_admin(role, admin_role)


@internal
@view
def _check_role(role: bytes32, account: address):
    """
    @dev Reverts with a standard message if `account`
         is missing `role`.
    @param role The 32-byte role definition.
    @param account The 20-byte address of the account.
    """
    assert self.hasRole[role][account], "access_control: account is missing role"


@internal
def _set_role_admin(role: bytes32, admin_role: bytes32):
    """
    @dev Sets `admin_role` as `role`'s admin role.
    @notice This is an `internal` function without
            access restriction.
    @param role The 32-byte role definition.
    @param admin_role The new 32-byte admin role definition.
    """
    previous_admin_role: bytes32 = self.getRoleAdmin[role]
    self.getRoleAdmin[role] = admin_role
    log IAccessControl.RoleAdminChanged(role, previous_admin_role, admin_role)


@internal
def _grant_role(role: bytes32, account: address):
    """
    @dev Grants `role` to `account`.
    @notice This is an `internal` function without
            access restriction.
    @param role The 32-byte role definition.
    @param account The 20-byte address of the account.
    """
    if (not(self.hasRole[role][account])):
        self.hasRole[role][account] = True
        log IAccessControl.RoleGranted(role, account, msg.sender)


@internal
def _revoke_role(role: bytes32, account: address):
    """
    @dev Revokes `role` from `account`.
    @notice This is an `internal` function without
            access restriction.
    @param role The 32-byte role definition.
    @param account The 20-byte address of the account.
    """
    if (self.hasRole[role][account]):
        self.hasRole[role][account] = False
        log IAccessControl.RoleRevoked(role, account, msg.sender)
# pragma version ~=0.4.0
"""
@title `access_control` Interface Definition
@custom:contract-name IAccessControl
@license GNU Affero General Public License v3.0 only
@author pcaversaccio
@notice The interface definition of `access_control`
        to support the ERC-165 detection. In order
        to ensure consistency and interoperability,
        we follow OpenZeppelin's definition here:
        https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/IAccessControl.sol.

        On how to use interfaces in Vyper, please visit:
        https://vyper.readthedocs.io/en/latest/interfaces.html#interfaces.
"""


# @dev Emitted when `newAdminRole` is set as
# `role`'s admin role, replacing `previousAdminRole`.
# Note that `DEFAULT_ADMIN_ROLE` is the starting
# admin for all roles, despite `RoleAdminChanged`
# not being emitted signaling this.
event RoleAdminChanged:
    role: indexed(bytes32)
    previousAdminRole: indexed(bytes32)
    newAdminRole: indexed(bytes32)


# @dev Emitted when `account` is granted `role`.
# Note that `sender` is the account (an admin
# role bearer) that originated the contract call.
event RoleGranted:
    role: indexed(bytes32)
    account: indexed(address)
    sender: indexed(address)


# @dev Emitted when `account` is revoked `role`.
# Note that `sender` is the account that originated
# the contract call:
#   - if using `revokeRole`, it is the admin role
#     bearer,
#   - if using `renounceRole`, it is the role bearer
#     (i.e. `account`).
event RoleRevoked:
    role: indexed(bytes32)
    account: indexed(address)
    sender: indexed(address)


@external
@view
def hasRole(role: bytes32, account: address) -> bool:
    """
    @dev Returns `True` if `account` has been
         granted `role`.
    @param role The 32-byte role definition.
    @param account The 20-byte address of the account.
    @return bool The verification whether the role
            `role` has been granted to `account` or not.
    """
    return ...


@external
@view
def getRoleAdmin(role: bytes32) -> bytes32:
    """
    @dev Returns the admin role that controls
         `role`.
    @notice See `grantRole` and `revokeRole`.
            To change a role's admin, use
            {access_control-set_role_admin}.
    @param role The 32-byte role definition.
    @return bytes32 The 32-byte admin role
            that controls `role`.
    """
    return ...


@external
def grantRole(role: bytes32, account: address):
    """
    @dev Grants `role` to `account`.
    @notice If `account` had not been already
            granted `role`, emits a `RoleGranted`
            event. Note that the caller must have
            `role`'s admin role.
    @param role The 32-byte role definition.
    @param account The 20-byte address of the account.
    """
    ...


@external
def revokeRole(role: bytes32, account: address):
    """
    @dev Revokes `role` from `account`.
    @notice If `account` had been granted `role`,
            emits a `RoleRevoked` event. Note that
            the caller must have `role`'s admin role.
    @param role The 32-byte role definition.
    @param account The 20-byte address of the account.
    """
    ...


@external
def renounceRole(role: bytes32, account: address):
    """
    @dev Revokes `role` from the calling account.
    @notice Roles are often managed via `grantRole`
            and `revokeRole`. This function's purpose
            is to provide a mechanism for accounts to
            lose their privileges if they are compromised
            (such as when a trusted device is misplaced).
            If the calling account had been granted `role`,
            emits a `RoleRevoked` event. Note that the
            caller must be `account`.
    @param role The 32-byte role definition.
    @param account The 20-byte address of the account.
    """
    ...
# pragma version ~=0.4

"""
@title Rewards Handler

@notice A contract that helps distributing rewards for scrvUSD, an ERC4626 vault
for crvUSD (yearn's vault v3 multi-vault implementaiton is used). Any crvUSD
token sent to this contract is considered donated as rewards for depositors and
will not be recoverable. This contract can receive funds to be distributed from
the FeeSplitter (crvUSD borrow rates revenues) and potentially other sources as
well. The amount of funds that this contract should receive from the fee
splitter is determined by computing the time-weighted average of the vault
balance over crvUSD circulating supply ratio. The contract handles the rewards
in a permissionless manner, anyone can take snapshots of the TVL and distribute
rewards. In case of manipulation of the time-weighted average, the contract
allows trusted contracts given the role of `RATE_MANGER` to correct the
distribution rate of the rewards.

@license Copyright (c) Curve.Fi, 2020-2024 - all rights reserved

@author curve.fi

@custom:security security@curve.fi
"""


################################################################
#                           INTERFACES                         #
################################################################


from ethereum.ercs import IERC20
from ethereum.ercs import IERC165

implements: IERC165

from contracts.interfaces import IDynamicWeight

implements: IDynamicWeight

from contracts.interfaces import IStablecoinLens

# yearn vault's interface
from interfaces import IVault


################################################################
#                            MODULES                           #
################################################################


# we use access control because we want to have multiple addresses being able
# to adjust the rate while only the dao (which has the `DEFAULT_ADMIN_ROLE`)
# can appoint `RATE_MANAGER`s
from snekmate.auth import access_control

initializes: access_control
exports: (
    # we don't expose `supportsInterface` from access control
    access_control.grantRole,
    access_control.revokeRole,
    access_control.renounceRole,
    access_control.set_role_admin,
    access_control.DEFAULT_ADMIN_ROLE,
    access_control.hasRole,
    access_control.getRoleAdmin,
)

# import custom modules that contain helper functions.
import TWA as twa
initializes: twa
exports: (
    twa.compute_twa,
    twa.snapshots,
    twa.get_len_snapshots,
    twa.twa_window,
    twa.min_snapshot_dt_seconds,
    twa.last_snapshot_timestamp,
)


################################################################
#                            EVENTS                            #
################################################################


event MinimumWeightUpdated:
    new_minimum_weight: uint256


event ScalingFactorUpdated:
    new_scaling_factor: uint256


event StablecoinLensUpdated:
    new_stablecoin_lens: IStablecoinLens


################################################################
#                           CONSTANTS                          #
################################################################


RATE_MANAGER: public(constant(bytes32)) = keccak256("RATE_MANAGER")
RECOVERY_MANAGER: public(constant(bytes32)) = keccak256("RECOVERY_MANAGER")
LENS_MANAGER: public(constant(bytes32)) = keccak256("LENS_MANAGER")
WEEK: constant(uint256) = 86_400 * 7  # 7 days
MAX_BPS: constant(uint256) = 10**4  # 100%

_SUPPORTED_INTERFACES: constant(bytes4[1]) = [
    0xA1AAB33F,  # The ERC-165 identifier for the dynamic weight interface.
]


################################################################
#                            STORAGE                           #
################################################################


stablecoin: immutable(IERC20)
vault: public(immutable(IVault))
stablecoin_lens: public(IStablecoinLens)

# scaling factor for the deposited token / circulating supply ratio.
scaling_factor: public(uint256)

# the minimum amount of rewards requested to the FeeSplitter.
minimum_weight: public(uint256)


################################################################
#                          CONSTRUCTOR                         #
################################################################


@deploy
def __init__(
    _stablecoin: IERC20,
    _vault: IVault,
    _lens: IStablecoinLens,
    minimum_weight: uint256,
    scaling_factor: uint256,
    admin: address,
):
    # initialize access control
    access_control.__init__()
    # admin (most likely the dao) controls who can be a rate manager
    access_control._grant_role(access_control.DEFAULT_ADMIN_ROLE, admin)
    # admin itself is a RATE_MANAGER and RECOVERY_MANAGER
    access_control._grant_role(RATE_MANAGER, admin)
    access_control._grant_role(RECOVERY_MANAGER, admin)
    access_control._grant_role(LENS_MANAGER, admin)

    # deployer does not control this contract
    access_control._revoke_role(access_control.DEFAULT_ADMIN_ROLE, msg.sender)

    twa.__init__(
        WEEK,  # twa_window = 1 week
        3_600,  #  min_snapshot_dt_seconds = 1 hour (3600 sec)
    )

    self._set_minimum_weight(minimum_weight)
    self._set_scaling_factor(scaling_factor)

    self._set_stablecoin_lens(_lens)
    stablecoin = _stablecoin
    vault = _vault


################################################################
#                   PERMISSIONLESS FUNCTIONS                   #
################################################################


@external
def take_snapshot():
    """
    @notice Function that anyone can call to take a snapshot of the current
    deposited supply ratio in the vault. This is used to compute the time-weighted
    average of the TVL to decide on the amount of rewards to ask for (weight).

    @dev There's no point in MEVing this snapshot as the rewards distribution rate
    can always be reduced (if a malicious actor inflates the value of the snapshot)
    or the minimum amount of rewards can always be increased (if a malicious actor
    deflates the value of the snapshot).
    """
    self._take_snapshot()


@internal
def _take_snapshot():
    """
    @notice Internal function to take a snapshot of the current deposited supply
    ratio in the vault.
    """
    # get the circulating supply from a helper contract.
    # supply in circulation = controllers' debt + peg keppers' debt
    circulating_supply: uint256 = staticcall self.stablecoin_lens.circulating_supply()

    # obtain the supply of crvUSD contained in the vault by checking its totalAssets.
    # This will not take into account rewards that are not yet distributed.
    supply_in_vault: uint256 = staticcall vault.totalAssets()

    # here we intentionally reduce the precision of the ratio because the
    # dynamic weight interface expects a percentage in BPS.
    supply_ratio: uint256 = supply_in_vault * MAX_BPS // circulating_supply

    twa._take_snapshot(supply_ratio)


@external
def process_rewards(take_snapshot: bool = False):
    """
    @notice Permissionless function that let anyone distribute rewards (if any) to
    the crvUSD vault.
    """
    # optional (advised) snapshot before distributing the rewards
    if take_snapshot:
        self._take_snapshot()

    # prevent the rewards from being distributed untill the distribution rate
    # has been set
    assert (staticcall vault.profitMaxUnlockTime() != 0), "rewards should be distributed over time"

    # any crvUSD sent to this contract (usually through the fee splitter, but
    # could also come from other sources) will be used as a reward for scrvUSD
    # vault depositors.
    available_balance: uint256 = staticcall stablecoin.balanceOf(self)

    assert available_balance > 0, "no rewards to distribute"

    # we distribute funds in 2 steps:
    # 1. transfer the actual funds
    extcall stablecoin.transfer(vault.address, available_balance)
    # 2. start streaming the rewards to users
    extcall vault.process_report(vault.address)


################################################################
#                         VIEW FUNCTIONS                       #
################################################################


@external
@view
def supportsInterface(interface_id: bytes4) -> bool:
    """
    @dev Returns `True` if this contract implements the interface defined by
    `interface_id`.
    @param interface_id The 4-byte interface identifier.
    @return bool The verification whether the contract implements the interface or
    not.
    """
    return (
        interface_id in access_control._SUPPORTED_INTERFACES
        or interface_id in _SUPPORTED_INTERFACES
    )


@external
@view
def weight() -> uint256:
    """
    @notice this function is part of the dynamic weight interface expected by the
    FeeSplitter to know what percentage of funds should be sent for rewards
    distribution to scrvUSD vault depositors.
    @dev `minimum_weight` acts as a lower bound for the percentage of rewards that
    should be distributed to depositors. This is useful to bootstrapping TVL by asking
    for more at the beginning and can also be increased in the future if someone
    tries to manipulate the time-weighted average of the tvl ratio.
    """
    raw_weight: uint256 = twa._compute() * self.scaling_factor // MAX_BPS
    return max(raw_weight, self.minimum_weight)


################################################################
#                         ADMIN FUNCTIONS                      #
################################################################


@external
def set_twa_snapshot_dt(_min_snapshot_dt_seconds: uint256):
    """
    @notice Setter for the time-weighted average minimal frequency.
    @param _min_snapshot_dt_seconds The minimum amount of time that should pass
    between two snapshots.
    """
    access_control._check_role(RATE_MANAGER, msg.sender)
    twa._set_snapshot_dt(_min_snapshot_dt_seconds)


@external
def set_twa_window(_twa_window: uint256):
    """
    @notice Setter for the time-weighted average window
    @param _twa_window The time window used to compute the TWA value of the
    balance/supply ratio.
    """
    access_control._check_role(RATE_MANAGER, msg.sender)
    twa._set_twa_window(_twa_window)


@external
def set_distribution_time(new_distribution_time: uint256):
    """
    @notice Admin function to correct the distribution rate of the rewards. Making
    this value lower will reduce the time it takes to stream the rewards, making it
    longer will do the opposite. Setting it to 0 will immediately distribute all the
    rewards.

    @dev This function can be used to prevent the rewards distribution from being
    manipulated (i.e. MEV twa snapshots to obtain higher APR for the vault). Setting
    this value to zero can be used to pause `process_rewards`.
    """
    access_control._check_role(RATE_MANAGER, msg.sender)

    # change the distribution time of the rewards in the vault
    extcall vault.setProfitMaxUnlockTime(new_distribution_time)

    # enact the changes
    extcall vault.process_report(vault.address)


@view
@external
def distribution_time() -> uint256:
    """
    @notice Getter for the distribution time of the rewards.
    @return uint256 The time over which vault rewards will be distributed.
    """
    return staticcall vault.profitMaxUnlockTime()


@external
def set_minimum_weight(new_minimum_weight: uint256):
    """
    @notice Update the minimum weight that the the vault will ask for.

    @dev This function can be used to prevent the rewards requested from being
    manipulated (i.e. MEV twa snapshots to obtain lower APR for the vault). Setting
    this value to zero makes the amount of rewards requested fully determined by the
    twa of the deposited supply ratio.
    """
    access_control._check_role(RATE_MANAGER, msg.sender)
    self._set_minimum_weight(new_minimum_weight)


@internal
def _set_minimum_weight(new_minimum_weight: uint256):
    assert new_minimum_weight <= MAX_BPS, "minimum weight should be <= 100%"
    self.minimum_weight = new_minimum_weight

    log MinimumWeightUpdated(new_minimum_weight)


@external
def set_scaling_factor(new_scaling_factor: uint256):
    """
    @notice Update the scaling factor that is used in the weight calculation.
    This factor can be used to adjust the rewards distribution rate.
    """
    access_control._check_role(RATE_MANAGER, msg.sender)
    self._set_scaling_factor(new_scaling_factor)


@internal
def _set_scaling_factor(new_scaling_factor: uint256):
    self.scaling_factor = new_scaling_factor

    log ScalingFactorUpdated(new_scaling_factor)


@external
def set_stablecoin_lens(_lens: address):
    """
    @notice Setter for the stablecoin lens that determines stablecoin circulating supply.
    @param _lens The address of the new stablecoin lens.
    """
    access_control._check_role(LENS_MANAGER, msg.sender)
    self._set_stablecoin_lens(IStablecoinLens(_lens))


@internal
def _set_stablecoin_lens(_lens: IStablecoinLens):
    assert _lens.address != empty(address), "no lens"
    self.stablecoin_lens = _lens

    log StablecoinLensUpdated(_lens)


@external
def recover_erc20(token: IERC20, receiver: address):
    """
    @notice This is a helper function to let an admin rescue funds sent by mistake
    to this contract. crvUSD cannot be recovered as it's part of the core logic of
    this contract.
    """
    access_control._check_role(RECOVERY_MANAGER, msg.sender)

    # if crvUSD was sent by accident to the contract the funds are lost and will
    # be distributed as rewards on the next `process_rewards` call.
    assert token != stablecoin, "can't recover crvusd"

    # when funds are recovered the whole balanced is sent to a trusted address.
    balance_to_recover: uint256 = staticcall token.balanceOf(self)

    assert extcall token.transfer(receiver, balance_to_recover, default_return_value=True)
# pragma version ~=0.4

"""
@title Time Weighted Average (TWA) Calculator

@notice Stores value snapshots and computes the Time Weighted Average (TWA) over
a specified time window.

@dev
- Stores value snapshots with timestamps in an array, only adding if the minimum
  time interval (`min_snapshot_dt_seconds`) has passed.
- Uses the trapezoidal rule to calculate the TWA over the `twa_window`.
- Functions:
  - `_take_snapshot`: Internal, adds a snapshot if the minimum interval passed.
    Wrapper required in importing contract.
  - `compute_twa`: Calculates and returns the TWA based on stored snapshots.
  - `get_len_snapshots`: Returns the number of stored snapshots.

@license Copyright (c) Curve.Fi, 2020-2024 - all rights reserved
@author curve.fi
@custom:security security@curve.fi
"""


################################################################
#                            EVENTS                            #
################################################################


event SnapshotTaken:
    value: uint256
    timestamp: uint256

event TWAWindowUpdated:
    new_window: uint256

event SnapshotIntervalUpdated:
    new_dt_seconds: uint256


################################################################
#                           CONSTANTS                          #
################################################################


MAX_SNAPSHOTS: constant(uint256) = 10**18  # 31.7 billion years if snapshot every second


################################################################
#                            STORAGE                           #
################################################################


min_snapshot_dt_seconds: public(uint256)  # Minimum time between snapshots in seconds
twa_window: public(uint256)  # Time window in seconds for TWA calculation
last_snapshot_timestamp: public(uint256)  # Timestamp of the last snapshot
snapshots: public(DynArray[Snapshot, MAX_SNAPSHOTS])


struct Snapshot:
    tracked_value: uint256
    timestamp: uint256


################################################################
#                          CONSTRUCTOR                         #
################################################################


@deploy
def __init__(_twa_window: uint256, _min_snapshot_dt_seconds: uint256):
    self._set_twa_window(_twa_window)
    self._set_snapshot_dt(max(1, _min_snapshot_dt_seconds))


################################################################
#                         VIEW FUNCTIONS                       #
################################################################


@external
@view
def get_len_snapshots() -> uint256:
    """
    @notice Returns the number of snapshots stored.
    """
    return len(self.snapshots)


@external
@view
def compute_twa() -> uint256:
    """
    @notice External endpoint for _compute() function.
    """
    return self._compute()


################################################################
#                       INTERNAL FUNCTIONS                     #
################################################################


@internal
def _take_snapshot(_value: uint256):
    """
    @notice Stores a snapshot of the tracked value.
    @param _value The value to store.
    """
    if  (  # First snapshot
        self.last_snapshot_timestamp + self.min_snapshot_dt_seconds <= block.timestamp # after dt
    ) or (len(self.snapshots) == 0):
        self.last_snapshot_timestamp = block.timestamp
        self.snapshots.append(
            Snapshot(tracked_value=_value, timestamp=block.timestamp)
        )  # store the snapshot into the DynArray
        log SnapshotTaken(_value, block.timestamp)


@internal
def _set_twa_window(_new_window: uint256):
    """
    @notice Adjusts the TWA window.
    @param _new_window The new TWA window in seconds.
    @dev Only callable by the importing contract.
    """
    self.twa_window = _new_window
    log TWAWindowUpdated(_new_window)


@internal
def _set_snapshot_dt(_new_dt_seconds: uint256):
    """
    @notice Adjusts the minimum snapshot time interval.
    @param _new_dt_seconds The new minimum snapshot time interval in seconds.
    @dev Only callable by the importing contract.
    """
    self.min_snapshot_dt_seconds = _new_dt_seconds
    log SnapshotIntervalUpdated(_new_dt_seconds)


@internal
@view
def _compute() -> uint256:
    """
    @notice Computes the TWA over the specified time window by iterating backwards over the snapshots.
    @return The TWA for tracked value over the self.twa_window.
    """
    num_snapshots: uint256 = len(self.snapshots)
    if num_snapshots == 0:
        return 0

    time_window_start: uint256 = block.timestamp - self.twa_window

    total_weighted_tracked_value: uint256 = 0
    total_time: uint256 = 0

    # Iterate backwards over all snapshots
    index_array_end: uint256 = num_snapshots - 1
    for i: uint256 in range(0, num_snapshots, bound=MAX_SNAPSHOTS):  # i from 0 to (num_snapshots-1)
        i_backwards: uint256 = index_array_end - i
        current_snapshot: Snapshot = self.snapshots[i_backwards]
        next_snapshot: Snapshot = current_snapshot
        if i != 0:  # If not the first iteration (last snapshot), get the next snapshot
            next_snapshot = self.snapshots[i_backwards + 1]

        # Time Axis (Increasing to the Right) --->
        #                                        SNAPSHOT
        # |---------|---------|---------|------------------------|---------|---------|
        # t0   time_window_start      interval_start        interval_end      block.timestamp (Now)

        interval_start: uint256 = current_snapshot.timestamp
        # Adjust interval start if it is before the time window start
        if interval_start < time_window_start:
            interval_start = time_window_start

        interval_end: uint256 = interval_start
        if i == 0:  # First iteration - we are on the last snapshot (i_backwards = num_snapshots - 1)
            # For the last snapshot, interval end is block.timestamp
            interval_end = block.timestamp
        else:
            # For other snapshots, interval end is the timestamp of the next snapshot
            interval_end = next_snapshot.timestamp

        if interval_end <= time_window_start:
            break

        time_delta: uint256 = interval_end - interval_start

        # Interpolation using the trapezoidal rule
        averaged_tracked_value: uint256 = (current_snapshot.tracked_value + next_snapshot.tracked_value) // 2

        # Accumulate weighted rate and time
        total_weighted_tracked_value += averaged_tracked_value * time_delta
        total_time += time_delta

    if total_time == 0 and num_snapshots == 1:
        # case when only snapshot is taken in the block where computation is called
        return self.snapshots[0].tracked_value

    assert total_time > 0, "Zero total time!"
    twa: uint256 = total_weighted_tracked_value // total_time
    return twa
@view
@external
def weight() -> uint256:
    ...


# eip165 hash of this inteface is: 0xA1AAB33F
@view
@external
def circulating_supply() -> uint256:
    ...
# pragma version ~=0.4


@external
def setProfitMaxUnlockTime(new_profit_max_unlock_time: uint256):
    ...


@external
def process_report(strategy: address) -> (uint256, uint256):
    ...


@view
@external
def totalAssets() -> uint256:
    ...


@view
@external
def profitMaxUnlockTime() -> uint256:
    ...