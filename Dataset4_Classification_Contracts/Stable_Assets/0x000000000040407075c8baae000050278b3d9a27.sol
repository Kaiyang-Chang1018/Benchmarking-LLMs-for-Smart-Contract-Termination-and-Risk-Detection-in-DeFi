// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IMintableToken} from "./apps/interfaces/IMintableToken.sol";
import {ICortexMigrator} from "./interfaces/ICortexMigrator.sol";
import {ICortexMigratorLookup} from "./interfaces/ICortexMigratorLookup.sol";

/// @notice CortexMigrator is a contract that enables the migration of SYN tokens to CX tokens and vice versa.
/// Users interacting with this contract can migrate by burning one token and having the other one minted to them.
/// The migration ratio is set at 5.5 CX per 1 SYN.
contract CortexMigrator is ICortexMigrator {
    /// @notice Ratio of the CX tokens to the SYN tokens for the migration process (5.5 CX per 1 SYN).
    uint256 public constant MIGRATION_RATIO = 5.5 * 10 ** 18;
    /// @dev Precision of the `MIGRATION_RATIO`.
    uint256 internal constant WAD = 10 ** 18;

    /// @notice Address of the SYN token, set at construction.
    address public immutable SYN;
    /// @notice Address of the CX token, set at construction.
    address public immutable CX;

    /// @notice Initializes the migrator with token addresses from a lookup contract.
    /// @param lookup The lookup contract that provides the SYN and CX token addresses.
    /// @dev This pattern allows the contract to be deployed deterministically across different chains.
    constructor(ICortexMigratorLookup lookup) {
        (SYN, CX) = lookup.lookupAddresses();
        // Make sure the addresses are not zero.
        if (SYN == address(0) || CX == address(0)) revert CortexMigrator__ZeroAddress();
    }

    /// @notice Migrates SYN tokens to CX tokens by burning SYN and minting CX.
    /// @dev Burns `amountSYN` of SYN from msg.sender and mints `amountSYN * 5.5` of CX to recipient.
    /// The caller must approve this contract to spend their SYN tokens.
    /// @param amountSYN    The amount of SYN tokens to burn from msg.sender.
    /// @param recipient    The address to receive the minted CX tokens (5.5 CX per 1 SYN).
    function synToCX(uint256 amountSYN, address recipient) external {
        // Make sure the recipient is not a zero address.
        if (recipient == address(0)) revert CortexMigrator__ZeroAddress();
        uint256 amountCX = amountSYN * MIGRATION_RATIO / WAD;
        IMintableToken(SYN).burnFrom(msg.sender, amountSYN);
        IMintableToken(CX).mint(recipient, amountCX);
    }

    /// @notice Migrates CX tokens back to SYN tokens by burning CX and minting SYN.
    /// @dev Burns `amountCX` of CX from msg.sender and mints `amountCX / 5.5` of SYN to recipient.
    /// The caller must approve this contract to spend their CX tokens.
    /// @param amountCX     The amount of CX tokens to burn from msg.sender.
    /// @param recipient    The address to receive the minted SYN tokens (1 SYN per 5.5 CX).
    function cxToSYN(uint256 amountCX, address recipient) external {
        // Make sure the recipient is not a zero address.
        if (recipient == address(0)) revert CortexMigrator__ZeroAddress();
        uint256 amountSYN = amountCX * WAD / MIGRATION_RATIO;
        IMintableToken(CX).burnFrom(msg.sender, amountCX);
        IMintableToken(SYN).mint(recipient, amountSYN);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMintableToken {
    function mint(address to, uint256 amount) external;

    function burnFrom(address from, uint256 amount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICortexMigrator {
    error CortexMigrator__ZeroAddress();

    function synToCX(uint256 amountSYN, address recipient) external;
    function cxToSYN(uint256 amountCX, address recipient) external;

    // solhint-disable-next-line func-name-mixedcase
    function MIGRATION_RATIO() external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICortexMigratorLookup {
    error CortexMigratorLookup__ZeroAddress();

    function lookupAddresses() external view returns (address syn, address cx);
}