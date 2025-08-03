// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// -------------------
// Compatibility
// TC Router V4
// -------------------

import {Owners} from "../../lib/Owners.sol";
import {Executors} from "../../lib/Executors.sol";
import {SafeTransferLib} from "../../lib/SafeTransferLib.sol";
import {IERC20} from "../../interfaces/IERC20.sol";
import {IThorchainRouterV4} from "../../interfaces/IThorchainRouterV4.sol";
import {IOracleV1} from "../../interfaces/IOracleV1.sol";

contract TSFeeDistributor_V2 is Owners, Executors {
    using SafeTransferLib for address;

    IOracleV1 public oracle;
    IThorchainRouterV4 public tcRouter;

    IERC20 public feeAsset;
    uint256 public minFeeAmount;
    uint256 private _communityDistribution;

    uint32 public treasuryBps;
    uint32 public communityBps;
    uint32 public treasuryIndex;
    uint32 public communityIndex;

    bool public publicMode;
    bool public transferTreasury;
    address public treasuryWallet;

    mapping(uint32 => string) public memoTreasury;
    mapping(uint32 => string) public memoCommunity;

    event TreasuryDistribution(uint256 amount, string memo);
    event CommunityDistribution(uint256 amount, string memo);

    constructor(
        address _oracleAddress,
        address _tcRouterAddress,
        address _feeAsset,
        address _treasuryWallet
    ) {
        treasuryBps = 2500;
        communityBps = 7500;
        _communityDistribution = 0;

        oracle = IOracleV1(_oracleAddress);
        tcRouter = IThorchainRouterV4(_tcRouterAddress);
        feeAsset = IERC20(_feeAsset);
        minFeeAmount = 0;

        _feeAsset.safeApprove(_tcRouterAddress, 0);
        _feeAsset.safeApprove(_tcRouterAddress, type(uint256).max);

        publicMode = false;
        transferTreasury = true;
        treasuryWallet = _treasuryWallet;

        _setOwner(msg.sender, true);
    }

    function setMinFeeAmount(uint256 amount) external isOwner {
        minFeeAmount = amount;
    }

    function setTCRouter(address _tcRouterAddress) public isOwner {
        tcRouter = IThorchainRouterV4(_tcRouterAddress);
        feeAsset.approve(_tcRouterAddress, 0);
        feeAsset.approve(_tcRouterAddress, type(uint256).max);
    }

    function setShares(uint32 treasury, uint32 community) external isOwner {
        require(treasury + community == 10000, "Shares must add up to 10000");
        treasuryBps = treasury;
        communityBps = community;
    }

    function getMemoTreasury(uint32 id) external view returns (string memory) {
        return memoTreasury[id];
    }

    function setMemoTreasury(uint32 id, string memory memo) external isOwner {
        memoTreasury[id] = memo;
    }

    function setTreasuryIndex(uint32 index) external isOwner {
        treasuryIndex = index;
    }

    function setTreasuryTransfer(bool _transferTreasury) external isOwner {
        transferTreasury = _transferTreasury;
    }

    function getMemoCommunity(uint32 id) external view returns (string memory) {
        return memoCommunity[id];
    }

    function setMemoCommunity(uint32 id, string memory memo) external isOwner {
        memoCommunity[id] = memo;
    }

    function setCommunityIndex(uint32 index) external isOwner {
        communityIndex = index;
    }

    function setTreasuryWallet(address _treasuryWallet) external isOwner {
        treasuryWallet = _treasuryWallet;
    }

    // Protected version in case the oracle is down
    function distributeTreasuryExecutor(
        address inboundAddress
    ) external isExecutor {
        require(!publicMode, "Must call distributeTreasury instead.");
        _distributeTreasury(inboundAddress);
    }

    function distributeTreasury() external {
        require(publicMode, "Must call distributeTreasuryExecutor instead.");
        (, address inboundAddress) = oracle.getInboundAddress("ETH");

        _distributeTreasury(inboundAddress);
    }

    function _distributeTreasury(address inboundAddress) internal {
        require(
            _communityDistribution == 0,
            "It's the community's turn to receive distribution"
        );
        uint256 balance = feeAsset.balanceOf(address(this));
        require(balance >= minFeeAmount, "Balance is below minimum fee amount");

        uint256 treasuryAmount = (balance * treasuryBps) / 10000;
        _communityDistribution = balance - treasuryAmount;

        if (transferTreasury) {
            feeAsset.transfer(treasuryWallet, treasuryAmount);
        } else {
            tcRouter.depositWithExpiry{value: 0}(
                payable(inboundAddress),
                address(feeAsset),
                treasuryAmount,
                memoTreasury[treasuryIndex],
                type(uint256).max
            );
        }

        emit TreasuryDistribution(treasuryAmount, memoTreasury[treasuryIndex]);
    }

    function distributeCommunityExecutor(
        address inboundAddress
    ) external isExecutor {
        require(!publicMode, "Must call distributeCommunity instead.");
        _distributeCommunity(inboundAddress);
    }

    function distributeCommunity() external {
        require(publicMode, "Must call distributeCommunityExecutor instead.");
        (, address inboundAddress) = oracle.getInboundAddress("ETH");

        _distributeCommunity(inboundAddress);
    }

    function _distributeCommunity(address inboundAddress) internal {
        require(
            _communityDistribution > 0,
            "It's the treasury's turn to receive distribution"
        );
        require(
            _communityDistribution <= feeAsset.balanceOf(address(this)),
            "Community distribution exceeds balance"
        );

        tcRouter.depositWithExpiry{value: 0}(
            payable(inboundAddress),
            address(feeAsset),
            _communityDistribution,
            memoCommunity[communityIndex],
            type(uint256).max
        );

        emit CommunityDistribution(
            _communityDistribution,
            memoCommunity[communityIndex]
        );

        _communityDistribution = 0;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IOracleV1 {
    function getRouterAddress() external view returns (address);

    function getPoolsAPY(string memory chain) external view returns (uint64);

    function getSaversAPY(string memory chain) external view returns (uint64);

    // Updated to match the new return type of getInboundAddress in the TSOracle_V1 contract
    function getInboundAddress(
        string memory chain
    ) external view returns (bytes memory, address);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IThorchainRouterV4 {
    function depositWithExpiry(
        address payable vault,
        address asset,
        uint amount,
        string memory memo,
        uint expiration
    ) external payable;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Owners} from "./Owners.sol";

abstract contract Executors is Owners {
    event ExecutorSet(address indexed executor, bool active);

    mapping(address => bool) public executors;

    modifier isExecutor() {
        require(executors[msg.sender], "Unauthorized");
        _;
    }

    function _setExecutor(address executor, bool active) internal virtual {
        executors[executor] = active;
        emit ExecutorSet(executor, active);
    }

    function setExecutor(address owner, bool active) external virtual isOwner {
        _setExecutor(owner, active);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

abstract contract Owners {
    event OwnerSet(address indexed owner, bool active);

    mapping(address => bool) public owners;

    modifier isOwner() {
        require(owners[msg.sender], "Unauthorized");
        _;
    }

    function _setOwner(address owner, bool active) internal virtual {
        owners[owner] = active;
        emit OwnerSet(owner, active);
    }

    function setOwner(address owner, bool active) external virtual isOwner {
        _setOwner(owner, active);
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @author Modified from Gnosis (https://github.com/gnosis/gp-v2-contracts/blob/main/src/contracts/libraries/GPv2SafeERC20.sol)
/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.
library SafeTransferLib {
    /*///////////////////////////////////////////////////////////////
                            ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool callStatus;

        assembly {
            // Transfer the ETH and store if it succeeded or not.
            callStatus := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(callStatus, "ETH_TRANSFER_FAILED");
    }

    /*///////////////////////////////////////////////////////////////
                           ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool callStatus;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata to memory piece by piece:
            mstore(
                freeMemoryPointer,
                0x23b872dd00000000000000000000000000000000000000000000000000000000
            ) // Begin with the function selector.
            mstore(
                add(freeMemoryPointer, 4),
                and(from, 0xffffffffffffffffffffffffffffffffffffffff)
            ) // Mask and append the "from" argument.
            mstore(
                add(freeMemoryPointer, 36),
                and(to, 0xffffffffffffffffffffffffffffffffffffffff)
            ) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            // Call the token and store if it succeeded or not.
            // We use 100 because the calldata length is 4 + 32 * 3.
            callStatus := call(gas(), token, 0, freeMemoryPointer, 100, 0, 0)
        }

        require(
            didLastOptionalReturnCallSucceed(callStatus),
            "TRANSFER_FROM_FAILED"
        );
    }

    function safeTransfer(address token, address to, uint256 amount) internal {
        bool callStatus;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata to memory piece by piece:
            mstore(
                freeMemoryPointer,
                0xa9059cbb00000000000000000000000000000000000000000000000000000000
            ) // Begin with the function selector.
            mstore(
                add(freeMemoryPointer, 4),
                and(to, 0xffffffffffffffffffffffffffffffffffffffff)
            ) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            // Call the token and store if it succeeded or not.
            // We use 68 because the calldata length is 4 + 32 * 2.
            callStatus := call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)
        }

        require(
            didLastOptionalReturnCallSucceed(callStatus),
            "TRANSFER_FAILED"
        );
    }

    function safeApprove(address token, address to, uint256 amount) internal {
        bool callStatus;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata to memory piece by piece:
            mstore(
                freeMemoryPointer,
                0x095ea7b300000000000000000000000000000000000000000000000000000000
            ) // Begin with the function selector.
            mstore(
                add(freeMemoryPointer, 4),
                and(to, 0xffffffffffffffffffffffffffffffffffffffff)
            ) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            // Call the token and store if it succeeded or not.
            // We use 68 because the calldata length is 4 + 32 * 2.
            callStatus := call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)
        }

        require(didLastOptionalReturnCallSucceed(callStatus), "APPROVE_FAILED");
    }

    /*///////////////////////////////////////////////////////////////
                         INTERNAL HELPER LOGIC
    //////////////////////////////////////////////////////////////*/

    function didLastOptionalReturnCallSucceed(
        bool callStatus
    ) private pure returns (bool success) {
        assembly {
            // Get how many bytes the call returned.
            let returnDataSize := returndatasize()

            // If the call reverted:
            if iszero(callStatus) {
                // Copy the revert message into memory.
                returndatacopy(0, 0, returnDataSize)

                // Revert with the same message.
                revert(0, returnDataSize)
            }

            switch returnDataSize
            case 32 {
                // Copy the return data into memory.
                returndatacopy(0, 0, returnDataSize)

                // Set success to whether it returned true.
                success := iszero(iszero(mload(0)))
            }
            case 0 {
                // There was no return data.
                success := 1
            }
            default {
                // It returned some malformed input.
                success := 0
            }
        }
    }
}