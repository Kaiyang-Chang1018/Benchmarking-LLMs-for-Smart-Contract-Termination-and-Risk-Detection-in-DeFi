// SPDX-License-Identifier: MIT
/*********************************************************************************************\
* Deployyyyer: https://deployyyyer.io
* Twitter: https://x.com/deployyyyer
* Telegram: https://t.me/Deployyyyer
/*********************************************************************************************/
pragma solidity ^0.8.23;

import { LibDiamond } from "../libraries/LibDiamond.sol";
import { IDiamondCut } from "../interfaces/IDiamondCut.sol";

import "../interfaces/IDiamondLoupe.sol";
import "../interfaces/IDiamondCut.sol";
//import "../interfaces/IERC173.sol";
//import "../interfaces/IERC165.sol";
import {AppStorageStaking} from "../libraries/LibAppStorageStaking.sol";
import { IStaking } from "../interfaces/IStaking.sol";
//import "hardhat/console.sol";

/// @title StakingDiamond 
/// @notice Diamond Proxy for a staking pool
/// @dev 
contract StakingDiamond { 
    AppStorageStaking internal s;
    event RewardsReceived(address indexed sender, uint256 amount, uint256 accRewardsPerShare);
    /// @notice Constructor of Diamond Proxy for a staking pool
    constructor(IDiamondCut.FacetCut[] memory _diamondCut, IStaking.StakingParams memory params) {
        require(params.owner != address(0));
        LibDiamond.diamondCut(_diamondCut, address(0), new bytes(0));
        LibDiamond.setContractOwner(params.owner);

        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        // adding ERC165 data
        //ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        //ds.supportedInterfaces[type(IERC173).interfaceId] = true;

        //init appStorage 
        s.accRewardsPrecision = 1e18;  
        s.token = msg.sender;
        s.withdrawTimeout = params.withdrawTimeout;

    }  

    /// @notice fallback
    // Find facet for function that is called and execute the
    // function if a facet is found and return any value.
    fallback() external payable {
        LibDiamond.DiamondStorage storage ds;
        bytes32 position = LibDiamond.DIAMOND_STORAGE_POSITION;
        // get diamond storage
        assembly {
            ds.slot := position
        }
        // get facet from function selector
        address facet = address(bytes20(ds.facets[msg.sig]));
        //require(facet != address(0), "sd1");
        require(facet != address(0), "sd1");
        // Execute external function from facet using delegatecall and return any value.
        assembly {
            // copy function selector and any arguments
            calldatacopy(0, 0, calldatasize())
            // execute function call using the facet
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            // get any return value
            returndatacopy(0, 0, returndatasize())
            // return any return value or error back to the caller
            switch result
                case 0 {
                    revert(0, returndatasize())
                }
                default {
                    return(0, returndatasize())
                }
        }
    }
    /// @notice receive
    /// @dev staing rewards in eth, sets accRewardsPerShare
    receive() external payable {
        uint256 amount = msg.value;
        require(amount > 0, "sd2");
        s.totalRewards[msg.sender] += amount;
        s.totalETHCollected += amount;
        if (s.totalStakedAmount == 0) {
            s.unallocatedETH += amount;
        } else {
            s.accRewardsPerShare += ((amount+s.unallocatedETH) * s.accRewardsPrecision) / s.totalStakedAmount;  
            s.unallocatedETH = 0;         
        }
        emit RewardsReceived(msg.sender, amount, s.accRewardsPerShare);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
/******************************************************************************/

interface IDiamondCut {
    enum FacetCutAction {Add, Replace, Remove}
    // Add=0, Replace=1, Remove=2

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    /// @notice Add/replace/remove any number of functions and optionally execute
    ///         a function with delegatecall
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments
    ///                  _calldata is executed with delegatecall on _init
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external;

    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
/******************************************************************************/

// A loupe is a small magnifying glass used to look at diamonds.
// These functions look at diamonds
interface IDiamondLoupe {
    /// These functions are expected to be called frequently
    /// by tools.

    struct Facet {
        address facetAddress;
        bytes4[] functionSelectors;
    }

    /// @notice Gets all facet addresses and their four byte function selectors.
    /// @return facets_ Facet
    function facets() external view returns (Facet[] memory facets_);

    /// @notice Gets all the function selectors supported by a specific facet.
    /// @param _facet The facet address.
    /// @return facetFunctionSelectors_
    function facetFunctionSelectors(address _facet) external view returns (bytes4[] memory facetFunctionSelectors_);

    /// @notice Get all the facet addresses used by a diamond.
    /// @return facetAddresses_
    function facetAddresses() external view returns (address[] memory facetAddresses_);

    /// @notice Gets the facet that supports the given selector.
    /// @dev If facet is not found return address(0).
    /// @param _functionSelector The function selector.
    /// @return facetAddress_ The facet address.
    function facetAddress(bytes4 _functionSelector) external view returns (address facetAddress_);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

interface IStaking {
    struct StakingParams {
            address owner;
            uint256 withdrawTimeout;
        }
    struct StakingDetails {
        uint256 claimable;
        uint256 withdrawable;
        uint256 unstakedAmount;
        uint256 totalRewards;
        uint256 timeToWithdraw;
        uint256 stakedAmount;
    }
    function transferOwnership(address _newOwner) external;
    function owner() external view returns (address);
    function rescueERC20(address _address) external;
    function stake(uint256 _amount) external;
    function unstake(uint256 _amount) external;
    function restake() external;
    function withdraw() external;
    function claimRewards() external;
    //function refreshPool() external;
    function getUserDetails(address) external view returns (StakingDetails memory);
}
// SPDX-License-Identifier: MIT
/*********************************************************************************************\
* Deployyyyer: https://deployyyyer.io
* Twitter: https://x.com/deployyyyer
* Telegram: https://t.me/Deployyyyer
/*********************************************************************************************/
pragma solidity ^0.8.23;
import {LibDiamond} from "./LibDiamond.sol";


struct AppStorageStaking {
    address token;
    uint256 accRewardsPrecision;
    uint256 totalStakedAmount;
    uint256 withdrawTimeout;
    uint256 unallocatedETH;
    uint256 accRewardsPerShare;
    uint256 totalETHCollected;
    mapping(address => uint256) totalRewards;
    mapping(address => uint256) rewardDebt;
    mapping(address => uint256) stakedAmount;
    mapping(address => uint256) claimedAmount;
    mapping(address => uint256) claimableRewards;
    mapping(address => uint256) lastUnstakeTime;
    mapping(address => uint256) unstakedAmount;

}



contract Modifiers {
    AppStorageStaking internal s;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

/*********************************************************************************************\
* Authors: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen), 
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
/*********************************************************************************************/
import { IDiamondCut } from "../interfaces/IDiamondCut.sol";

library LibDiamond {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    struct DiamondStorage {
        // maps function selectors to the facets that execute the functions.
        // and maps the selectors to their position in the selectorSlots array.
        // func selector => address facet, selector position
        mapping(bytes4 => bytes32) facets;
        // array of slots of function selectors.
        // each slot holds 8 function selectors.
        mapping(uint256 => bytes32) selectorSlots;
        // The number of function selectors in selectorSlots
        uint16 selectorCount;
        // Used to query if a contract implements an interface.
        // Used to implement ERC-165.
        mapping(bytes4 => bool) supportedInterfaces;
        // owner of the contract
        address contractOwner;
    }

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function setContractOwner(address _newOwner) internal {
        DiamondStorage storage ds = diamondStorage();
        address previousOwner = ds.contractOwner;
        ds.contractOwner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function contractOwner() internal view returns (address contractOwner_) {
        contractOwner_ = diamondStorage().contractOwner;
    }

    function enforceIsContractOwner() internal view {
        require(msg.sender == diamondStorage().contractOwner, "l0");
    }

    //event DiamondCut(IDiamondCut.FacetCut[] _diamondCut, address _init, bytes _calldata);

    //bytes32 constant CLEAR_ADDRESS_MASK = bytes32(uint256(0xffffffffffffffffffffffff));
    bytes32 constant CLEAR_SELECTOR_MASK = bytes32(uint256(0xffffffff << 224));

    // Internal function version of diamondCut
    // This code is almost the same as the external diamondCut,
    // except it is using 'Facet[] memory _diamondCut' instead of
    // 'Facet[] calldata _diamondCut'.
    // The code is duplicated to prevent copying calldata to memory which
    // causes an error for a two dimensional array.
    // also removed action on _calldata and _init is always address(0)
    // maintained same old signature
    function diamondCut(
        IDiamondCut.FacetCut[] memory _diamondCut,
        address _init,
        bytes memory _calldata
    ) internal {
        DiamondStorage storage ds = diamondStorage();
        uint256 originalSelectorCount = ds.selectorCount;
        uint256 selectorCount = originalSelectorCount;
        bytes32 selectorSlot;
        // Check if last selector slot is not full
        // "selectorCount & 7" is a gas efficient modulo by eight "selectorCount % 8" 
        if (selectorCount & 7 > 0) {
            // get last selectorSlot
            // "selectorSlot >> 3" is a gas efficient division by 8 "selectorSlot / 8"
            selectorSlot = ds.selectorSlots[selectorCount >> 3];
        }
        // loop through diamond cut
        for (uint256 facetIndex; facetIndex < _diamondCut.length; facetIndex++) {
            (selectorCount, selectorSlot) = addReplaceRemoveFacetSelectors(
                selectorCount,
                selectorSlot,
                _diamondCut[facetIndex].facetAddress,
                _diamondCut[facetIndex].action,
                _diamondCut[facetIndex].functionSelectors
            );
        }
        if (selectorCount != originalSelectorCount) {
            ds.selectorCount = uint16(selectorCount);
        }
        // If last selector slot is not full
        // "selectorCount & 7" is a gas efficient modulo by eight "selectorCount % 8" 
        if (selectorCount & 7 > 0) {
            // "selectorSlot >> 3" is a gas efficient division by 8 "selectorSlot / 8"
            ds.selectorSlots[selectorCount >> 3] = selectorSlot;
        }
        //emit DiamondCut(_diamondCut, _init, _calldata);
        //initializeDiamondCut(_init, _calldata);
        require(_init == address(0), "l1");
        require(_calldata.length == 0, "l2");
    }

    //supports only add, maintaining lib fn name
    function addReplaceRemoveFacetSelectors(
        uint256 _selectorCount,
        bytes32 _selectorSlot,
        address _newFacetAddress,
        IDiamondCut.FacetCutAction _action,
        bytes4[] memory _selectors
    ) internal returns (uint256, bytes32) {
        DiamondStorage storage ds = diamondStorage();
        require(_selectors.length > 0, "l3");
        if (_action == IDiamondCut.FacetCutAction.Add) {
            enforceHasContractCode(_newFacetAddress, "l4");
            for (uint256 selectorIndex; selectorIndex < _selectors.length; selectorIndex++) {
                bytes4 selector = _selectors[selectorIndex];
                bytes32 oldFacet = ds.facets[selector];
                require(address(bytes20(oldFacet)) == address(0), "l5");
                // add facet for selector
                ds.facets[selector] = bytes20(_newFacetAddress) | bytes32(_selectorCount);
                // "_selectorCount & 7" is a gas efficient modulo by eight "_selectorCount % 8" 
                uint256 selectorInSlotPosition = (_selectorCount & 7) << 5;
                // clear selector position in slot and add selector
                _selectorSlot = (_selectorSlot & ~(CLEAR_SELECTOR_MASK >> selectorInSlotPosition)) | (bytes32(selector) >> selectorInSlotPosition);
                // if slot is full then write it to storage
                if (selectorInSlotPosition == 224) {
                    // "_selectorSlot >> 3" is a gas efficient division by 8 "_selectorSlot / 8"
                    ds.selectorSlots[_selectorCount >> 3] = _selectorSlot;
                    _selectorSlot = 0;
                }
                _selectorCount++;
            }
        } 
        else {
            revert("l6");
        }
        return (_selectorCount, _selectorSlot);
    }

    function enforceHasContractCode(address _contract, string memory _errorMessage) internal view {
        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_contract)
        }
        require(contractSize > 0, _errorMessage);
    }
}