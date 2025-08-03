// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

library LibsErrorTypes {
    /***********************************|
    |         LiquidityCalcs            | 
    |__________________________________*/

    /// @notice thrown when supply or borrow exchange price is zero at calc token data (token not configured yet)
    uint256 internal constant LiquidityCalcs__ExchangePriceZero = 70001;

    /// @notice thrown when rate data is set to a version that is not implemented
    uint256 internal constant LiquidityCalcs__UnsupportedRateVersion = 70002;

    /// @notice thrown when the calculated borrow rate turns negative. This should never happen.
    uint256 internal constant LiquidityCalcs__BorrowRateNegative = 70003;

    /***********************************|
    |           SafeTransfer            | 
    |__________________________________*/

    /// @notice thrown when safe transfer from for an ERC20 fails
    uint256 internal constant SafeTransfer__TransferFromFailed = 71001;

    /// @notice thrown when safe transfer for an ERC20 fails
    uint256 internal constant SafeTransfer__TransferFailed = 71002;

    /***********************************|
    |           SafeApprove             | 
    |__________________________________*/

    /// @notice thrown when safe approve from for an ERC20 fails
    uint256 internal constant SafeApprove__ApproveFailed = 81001;
}
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity 0.8.21;

import { LibsErrorTypes as ErrorTypes } from "./errorTypes.sol";

/// @notice provides minimalistic methods for safe transfers, e.g. ERC20 safeTransferFrom
library SafeTransfer {
    uint256 internal constant MAX_NATIVE_TRANSFER_GAS = 20000; // pass max. 20k gas for native transfers

    error FluidSafeTransferError(uint256 errorId_);

    /// @dev Transfer `amount_` of `token_` from `from_` to `to_`, spending the approval given by `from_` to the
    /// calling contract. If `token_` returns no value, non-reverting calls are assumed to be successful.
    /// Minimally modified from Solmate SafeTransferLib (address as input param for token, Custom Error):
    /// https://github.com/transmissions11/solmate/blob/50e15bb566f98b7174da9b0066126a4c3e75e0fd/src/utils/SafeTransferLib.sol#L31-L63
    function safeTransferFrom(address token_, address from_, address to_, uint256 amount_) internal {
        bool success_;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(from_, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "from_" argument.
            mstore(add(freeMemoryPointer, 36), and(to_, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to_" argument.
            mstore(add(freeMemoryPointer, 68), amount_) // Append the "amount_" argument. Masking not required as it's a full 32 byte type.

            success_ := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token_, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        if (!success_) {
            revert FluidSafeTransferError(ErrorTypes.SafeTransfer__TransferFromFailed);
        }
    }

    /// @dev Transfer `amount_` of `token_` to `to_`.
    /// If `token_` returns no value, non-reverting calls are assumed to be successful.
    /// Minimally modified from Solmate SafeTransferLib (address as input param for token, Custom Error):
    /// https://github.com/transmissions11/solmate/blob/50e15bb566f98b7174da9b0066126a4c3e75e0fd/src/utils/SafeTransferLib.sol#L65-L95
    function safeTransfer(address token_, address to_, uint256 amount_) internal {
        bool success_;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to_, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to_" argument.
            mstore(add(freeMemoryPointer, 36), amount_) // Append the "amount_" argument. Masking not required as it's a full 32 byte type.

            success_ := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token_, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        if (!success_) {
            revert FluidSafeTransferError(ErrorTypes.SafeTransfer__TransferFailed);
        }
    }

    /// @dev Transfer `amount_` of ` native token to `to_`.
    /// Minimally modified from Solmate SafeTransferLib (Custom Error):
    /// https://github.com/transmissions11/solmate/blob/50e15bb566f98b7174da9b0066126a4c3e75e0fd/src/utils/SafeTransferLib.sol#L15-L25
    function safeTransferNative(address to_, uint256 amount_) internal {
        bool success_;

        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and store if it succeeded or not. Pass limited gas
            success_ := call(MAX_NATIVE_TRANSFER_GAS, to_, amount_, 0, 0, 0, 0)
        }

        if (!success_) {
            revert FluidSafeTransferError(ErrorTypes.SafeTransfer__TransferFailed);
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

import { Owned } from "solmate/src/auth/Owned.sol";

import { SafeTransfer } from "../../libraries/safeTransfer.sol";

contract VaultLiquidator is Owned {
    address constant public ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address constant public DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    // @notice temporary implementation address set for fallback
    address private _implementation;

    // @notice whitelisted rebalancers
    mapping (address => bool) public rebalancer; 
    // @notice whitelisted implementations
    mapping (address => bool) public implementation;
    
    error FluidVaultT1Liquidator__InvalidOperation();
    error FluidVaultT1Liquidator__InvalidImplementation();
    error FluidVaultT1Liquidator__InvalidFallback();

    event ToggleRebalancer(
        address indexed rebalancer,
        bool indexed status
    );

    event ToggleImplementation(
        address indexed implementation,
        bool indexed status
    );

    event Withdraw(
        address indexed to,
        address indexed token,
        uint256 amount
    );

    constructor (
        address owner_,
        address[] memory rebalancers_,
        address[] memory implementations_
    ) Owned(owner_) {
        require(owner_ != address(0), "Owner cannot be the zero address");

        for (uint256 i = 0; i < rebalancers_.length; i++) {
            rebalancer[rebalancers_[i]] = true;
            emit ToggleRebalancer(rebalancers_[i], true);
        }

        for (uint256 i = 0; i < implementations_.length; i++) {
            implementation[implementations_[i]] = true;
            emit ToggleImplementation(implementations_[i], true);
        }

        _implementation = DEAD_ADDRESS;
    }

    modifier isRebalancer() {
        if (!rebalancer[msg.sender] && msg.sender != owner) {
            revert FluidVaultT1Liquidator__InvalidOperation();
        }
        _;
    }

    modifier isImplementation(address implementation_) {
        if (!implementation[implementation_] || _implementation != DEAD_ADDRESS) {
            revert FluidVaultT1Liquidator__InvalidImplementation();
        }
        _implementation = implementation_;
        _;
        _implementation = address(DEAD_ADDRESS);
    }

    function _spell(address target_, bytes memory data_) internal returns (bytes memory response_) {
        assembly {
            let succeeded := delegatecall(gas(), target_, add(data_, 0x20), mload(data_), 0, 0)
            let size := returndatasize()

            response_ := mload(0x40)
            mstore(0x40, add(response_, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            mstore(response_, size)
            returndatacopy(add(response_, 0x20), 0, size)

            if iszero(succeeded) {
                // throw if delegatecall failed
                returndatacopy(0x00, 0x00, size)
                revert(0x00, size)
            }
        }
    }

    function toggleRebalancer(address rebalancer_, bool status_) public onlyOwner {
        rebalancer[rebalancer_] = status_;
        emit ToggleRebalancer(rebalancer_, status_);
    }

    function toggleImplementation(address implementation_, bool status_) public onlyOwner {
        implementation[implementation_] = status_;
        emit ToggleImplementation(implementation_, status_);
    }

    function spell(address[] memory targets_, bytes[] memory calldatas_) public onlyOwner {
        for (uint256 i = 0; i < targets_.length; i++) {
            _spell(targets_[i], calldatas_[i]);
        }
    }

    function withdraw(address to_, address[] memory tokens_, uint256[] memory amounts_) public onlyOwner {
        for (uint i = 0; i < tokens_.length; i++) {
            if (tokens_[i] == ETH_ADDRESS) {
                SafeTransfer.safeTransferNative(payable(to_), amounts_[i]);
            } else {
                SafeTransfer.safeTransfer(tokens_[i], to_, amounts_[i]);
            }
            emit Withdraw(to_, tokens_[i], amounts_[i]);
        }
    }

    receive() payable external {}

    function execute(address implementation_, bytes memory data_) public isRebalancer() isImplementation(implementation_) {
        _spell(implementation_, data_);
    }

    fallback() external payable {
        if (_implementation != DEAD_ADDRESS) {
            bytes memory response_ = _spell(_implementation, msg.data);
            assembly {
                return(add(response_, 32), mload(response_))
            }
        } else {
            revert FluidVaultT1Liquidator__InvalidFallback();
        }
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Simple single owner authorization mixin.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)
abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}