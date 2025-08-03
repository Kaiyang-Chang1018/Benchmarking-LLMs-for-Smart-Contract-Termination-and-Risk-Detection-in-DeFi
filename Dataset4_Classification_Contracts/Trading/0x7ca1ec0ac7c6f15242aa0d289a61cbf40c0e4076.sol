// SPDX-License-Identifier: MIT
/*********************************************************************************************\
* Deployyyyer: https://deployyyyer.io
* Twitter: https://x.com/deployyyyer
* Telegram: https://t.me/Deployyyyer
/*********************************************************************************************/
pragma solidity ^0.8.23;

import { LibDiamond } from "../libraries/LibDiamond.sol";
import { IDiamondCut } from "../interfaces/IDiamondCut.sol";

//import "../libraries/LibDiamond.sol";
import "../interfaces/IDiamondLoupe.sol";
import "../interfaces/IDiamondCut.sol";
import "../interfaces/IERC173.sol";
import "../interfaces/IERC165.sol";
import "../interfaces/IERC20.sol";
import {AppStorage} from "../libraries/LibAppStorage.sol";
import { INewToken, IUniswapV2Router02 } from "../interfaces/INewToken.sol";
//import { NewTokenFacet } from "./NewTokenFacet.sol";
//import "hardhat/console.sol";

/// @title TokenDiamond 
/// @notice Diamond Proxy for a launched token
/// @dev 
contract TokenDiamond { 
    AppStorage internal s;
    event Transfer(address indexed from, address indexed to, uint256 value);
    //event Approval(address indexed owner, address indexed spender, uint256 value);
    event IncreasedLimits(uint256 maxWallet, uint256 maxTx);

    /// @notice Constructor of Diamond Proxy for a launched token
    constructor(IDiamondCut.FacetCut[] memory _diamondCut, INewToken.InitParams memory params) {
        require(params.owner != address(0));
        LibDiamond.diamondCut(_diamondCut, address(0), new bytes(0));
        LibDiamond.setContractOwner(params.owner);

        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        // adding ERC165 data
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        //ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;
        ds.supportedInterfaces[type(IERC20).interfaceId] = true;

        //init appStorage   
        //s.deployyyyer = msg.sender;
        //deployerWallet is always deployyyyer launcher
        s.deployyyyerCa = payable(msg.sender);
        s.isParent = false; 
        s.tokenFacet = address(bytes20(ds.facets[IERC20.name.selector]));

        s.stakingFacet = params.stakingFacet;
        s.minLiq = params.minLiq;
        s.taxBuy = params.maxBuyTax; //20%
        s.maxBuyTax = params.maxBuyTax;
        s.minBuyTax = params.minBuyTax;
        s.lpTax = params.lpTax;
        s.taxSell = params.maxSellTax; //20%
        s.maxSellTax = params.maxSellTax;
        s.minSellTax = params.minSellTax;
        
        s.initTaxType = params.initTaxType;
        s.initInterval = params.initInterval;
        s.countInterval = params.countInterval;

        // Reduction Rules
        s.buyCount = 0; 
    

        // Token Information
        s.decimals = 18;

        s.isFreeTier = params.isFreeTier;
        s.taxWallet = payable(params.taxWallet);
        
        s.name = params.name;
        s.symbol = params.symbol;
        s.tTotal = params.supply*10**18;

        // Contract Swap Rules            
        s.taxSwapThreshold = params.taxSwapThreshold*10**18; //0.1%
        s.maxTaxSwap = params.maxSwap*10**18; //1%
        s.walletLimited = true;
        
        
        s.maxWallet = s.tTotal * params.maxWallet / 100;  //1% (allow 1 - 100)
        s.maxTx = s.tTotal * params.maxTx / 100;
        if (params.maxWallet == 100 && params.maxTx == 100) {
            s.walletLimited = false;
        }
        emit IncreasedLimits(params.maxWallet, params.maxTx);
        s.balances[address(this)] = s.tTotal;
        emit Transfer(address(0), address(this), s.tTotal);

        s.preventSwap = params.preventSwap;

        //s.uniswapV2Router = IUniswapV2Router02(params.v2router);
        //s.allowances[address(this)][address(s.uniswapV2Router)] = s.tTotal;
        //emit Approval(address(this), address(s.uniswapV2Router), s.tTotal);

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
        //require(facet != address(0), "T1");
        require(facet != address(0), "T1");
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
    
    /// @notice receive eth
    receive() external payable {}
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

interface IERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceId The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

/// @title ERC-173 Contract Ownership Standard
///  Note: the ERC-165 identifier for this interface is 0x7f5828d0
/* is ERC165 */
interface IERC173 {
    /// @dev This emits when ownership of a contract changes.
    //event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @notice Get the address of the owner
    /// @return owner_ The address of the owner.
    function owner() external view returns (address owner_);

    /// @notice Set the address of the new owner of the contract
    /// @dev Set _newOwner to address(0) to renounce any ownership.
    /// @param _newOwner The address of the new owner of the contract
    function transferOwnership(address _newOwner) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;


interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function transfer(address _to, uint256 _value) external returns (bool success);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;
import { IPresale} from "./IPresale.sol";

interface INewToken {
    struct InitParams {
        address owner;
        address taxWallet;
        address stakingFacet;
        address v2router;
        bool isFreeTier;
        uint256 minLiq; 
        uint256 supply;
        uint256 initTaxType; //0-time,1-buyCount,2-hybrid
        uint256 initInterval; //seconds 0-1 hour(if 1m: 1m, 3m, 6m, 10m)
        uint256 countInterval; //0-100 
        uint256  maxBuyTax; //40%
        uint256  minBuyTax; //0
        uint256  maxSellTax; //40%
        uint256  minSellTax; //0
        uint256  lpTax; //0-90 of buy or sell tax
        uint256 maxWallet;
        uint256 maxTx;
        uint256 preventSwap;
        uint256 maxSwap;
        uint256 taxSwapThreshold;
        string  name;
        string  symbol;
    }
    
    struct TeamParams {
        address team1;
        uint256 team1p; 
        uint256 cliffPeriod; 
        uint256 vestingPeriod;
        bool isAdd;
    }

	function rescueERC20(address _address) external;
	function increaseLimits(uint256 maxwallet, uint256 maxtx) external;
	function startTrading(uint256 lockPeriod, bool shouldBurn, address router) external;
    //require trading and presale not started
    function addPresale(address presale, uint256 percent, IPresale.PresaleParams memory newdetails) external;
    //require caller to be presale address
    function finPresale() external;
    function refPresale() external;
    //requires presale not started and trading not started
    function addTeam(TeamParams memory params) external;
    //what if we remove team out from init?
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);

}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

interface IPresale {
    struct PresaleParams {
            address owner;
            address token;
            uint256 softcap;
            uint256 hardcap;
            uint256 startTs;
            uint256 finishTs;
            uint256 duration;
            uint256 liqPercent;
            uint256 cliffPeriod;
            uint256 vestingPeriod;
            uint256 status;
            uint256 sold;
            uint256 maxEth;
            uint256 maxBag;
            uint256 fee;
    }

    function transferOwnership(address _newOwner) external;
    function owner() external view returns (address);
    function rescueERC20(address _address) external;
    function setupPresale(PresaleParams memory params) external;
    function buyTokens(uint256 _amount) external payable;
    //should we offer or force token vesting??
    function claimTokens() external;
    function getRefund() external;
    function getPresaleDetails() external view returns(PresaleParams memory); 
    function finishPresale() external; 
    function claimEth() external;
    function getClaimableTokens(address user) external view returns(uint256,uint256,uint256,uint256);
    function refundPresale() external;
}
// SPDX-License-Identifier: MIT
/*********************************************************************************************\
* Deployyyyer: https://deployyyyer.io
* Twitter: https://x.com/deployyyyer
* Telegram: https://t.me/Deployyyyer
/*********************************************************************************************/
pragma solidity ^0.8.23;
import {LibDiamond} from "./LibDiamond.sol";
//import {LibMeta} from "./LibMeta.sol";
import {IUniswapV2Factory, IUniswapV2Router02} from "../interfaces/INewToken.sol";



struct AppStorage {
    mapping(address => bool) validRouters; //parentOnly
    mapping(address => bool) allowedTokens; //parentOnly
    //this should be bool too
    mapping(address => address) launchedTokens; //parentOnly
    mapping(address => address) launchedPresale; //parentOnly
    //cost of launch, cost of promo, cost of setting socials is 2xpromoCostEth
    uint256 ethCost; //parentOnly
    uint256 deployyyyerCost; //parentOnly
    uint256 promoCostEth; //parentOnly
    uint256 promoCostDeployyyyer; //parentOnly
    address bridge; //parentOnly

    //mapping of user address to score
    mapping(address => uint256) myScore; //parentOnly

    //+1 for launch, +5 for liquidity add, +50 for lp burn, -100 for lp retrieve
    uint256 cScore; //cScore is transferred with ownership, cScore is deducted on lp retrieve

    
    //address deployyyyer;
    bool isParent;
    uint256 minLiq;
    //this can be a map with share and clain in a structure
    mapping(address => uint256) teamShare;
    mapping(address => uint256) teamClaim;
    
    uint256 teamBalance;

    uint256 cliffPeriod; //min 30days
    uint256 vestingPeriod;//min 1day max 10000 days avg 30days.


    mapping(address => bool)  isExTxLimit; //is excluded from transaction limit
    mapping(address => bool)  isExWaLimit; //is excluded from wallet limit
    mapping (address => uint256)  balances; //ERC20 balance
    mapping (address => mapping (address => uint256))  allowances; //ERC20 balance

    address payable taxWallet; //tax wallet for the token
    address payable deployyyyerCa; //deployyyyer contract address
    address payable stakingContract; //address of staking contract for the token
    address stakingFacet; //facet address, used to launch a staking pool
    address presaleFacet; //facet address, used to launch a presale
    address tokenFacet; //facet address, used to launch a ERC20 token
    uint256 stakingShare; //share of tax sent to its staking pool
    
    
    // Reduction Rules
    uint256  buyCount; 

    uint256 initTaxType; //0-time,1-buyCount,2-hybrid,3-none
    //interval*1, lastIntEnd+(interval*2), lastIntEnd+(interval*3)
    uint256 initInterval; //seconds 0-1 hour(if 1m: 1m, 3m, 6m, 10m)
    uint256 countInterval; //0-100 

    //current taxes
    uint256  taxBuy; 
    uint256  maxBuyTax; //40%
    uint256  minBuyTax; //0

    uint256  taxSell; 
    uint256  maxSellTax; //40%
    uint256  minSellTax; //0
    
    


    uint256  tradingOpened;

    // Token Information
    uint8   decimals;
    uint256   tTotal;
    string   name;
    string   symbol;

    // Contract Swap Rules 
    uint256 preventSwap; //50            
    uint256  taxSwapThreshold; //0.1%
    uint256  maxTaxSwap; //1%
    uint256  maxWallet; //1%
    uint256  maxTx;

    IUniswapV2Router02  uniswapV2Router;
    address  uniswapV2Pair;
    
    bool  tradingOpen; //true if liquidity pool is created
    bool  inSwap;
    bool  walletLimited;
    bool isFreeTier;
    bool isBurnt;
    bool isRetrieved;
    uint256 lockPeriod;
    
    //buy back tax calculations
    uint256 lpTax; //0-50 percent of tax amount 
    uint256 halfLp;
    uint256 lastSwap;

    uint256 presaleTs;
    uint256 presaleSt;
    address presale;

}

/*
library LibAppStorage {
    function diamondStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }

    function abs(int256 x) internal pure returns (uint256) {
        return uint256(x >= 0 ? x : -x);
    }
}
*/


contract Modifiers {
    AppStorage internal s;

    modifier onlyOwner() {
        LibDiamond.enforceIsContractOwner();
        _;
    }  
    
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