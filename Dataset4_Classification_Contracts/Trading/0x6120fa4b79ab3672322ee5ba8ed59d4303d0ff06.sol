// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

/*

                                                                                                    
                    &&&&&& &&&&&                                        &%                          
                     &&&&&&&&&&&&&&&                               && &&&&&&&&&&%                   
                     &&&&&&&      &&&&&                          #&&&&&&&&&&&&&                     
                     &&&&&  &&&&&&&   &&                      &&&&    &%  &&&&&&&                   
                        &&. &&&&&&&&&&                        &  %&&&&&&&  &&&&                     
                        &&&&  *&&&&&&&&&                       &&&&&&&&&  &&&&                      
                           .&&&   &&&&&&&&                   &&&&&&&&   &&&                         
                                    .&&&&&&&               &&&&&&&   &&&%                           
                                       &&&&&&             &&&&&&                                    
                                         &&&&&          /&&&&.                                      
                                           &&&&  %&&&  #&&&,                                        
                                   &&&&(     &&&&&&&&&&&&&                                          
                               &&&&&&&&&&&&&&&&&&&&&&&&&&&&   &&&&&&&&&&                            
                             &&&%        &&&&&&&&&&&&&&&&&&&&&&&&&     &&&                          
                            &&&    &&&*    &&&&&&&&&&&&&&&&&&&&&         &&*                        
                           &&&   .&&&&&&   &&&&&&&&&&&&&&&&&&&&   &&&&&   &&                        
                           &&&   #&&&&&&   &&&&&&&&&&&&&&&&&&&&&  &&&&&   &&                        
                            &&&    &&&&    &&&&&&&&&&&&&&&&&&&&&&  #&&   &&&                        
                             &&&         &&&&&&&&&&&&&&&&&&&&&&&&,     *&&&                         
                              (&&&&&&&&&&&&&&&&&&&&          &&&&&&&&&&&%                           
                                  &&&&&&&&&&&&&&&&&          &&&&&                                  
                                    &&&&&&&&&&&&&&&&&&    %&&&&&&&                                  
                                    &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&#                                 
                                      &&&&&&&&&&&&&&&&&&&&&&&&&&&&                                  
                                           &&&&&&&&&&&&&&&&&&&&                                     

*/
/*
 * ERC20AntiBot contract
 * This contract is used to control bad actors using bots on trades
 */
/// @title ERC20AntiBot
/// @author Smithii

import {IERC20AntiBot} from "./interfaces/services/IERC20AntiBot.sol";
import {Indexable} from "./utils/Indexable.sol";
import {Payable} from "./utils/Payable.sol";

contract ERC20AntiBot is IERC20AntiBot, Payable, Indexable {
    constructor(
        address _indexer,
        address _payments,
        string memory _serviceId
    ) Indexable(_indexer) Payable(_payments, _serviceId) {}

    /// mappings
    mapping(address => mapping(address => uint256)) private buyBlock;
    mapping(address => Options) private canUseAntiBot;
    mapping(address => mapping(address => bool)) public exempts;

    /// @inheritdoc IERC20AntiBot
    function isBotDetected(address _from) public view returns (bool) {
        if (isExempt(msg.sender, _from)) return false;

        if (isActive(msg.sender)) {
            return (buyBlock[msg.sender][_from] == block.number);
        }
        return false;
    }
    /// @inheritdoc IERC20AntiBot
    function registerBlock(address _to) external {
        if (isActive(msg.sender)) {
            buyBlock[msg.sender][_to] = block.number;
        }
    }
    /// set a token address to be registered in the AntiBot
    /// @param _tokenAddress the address to check
    /// @param _options the options for anti bot
    function _setCanUseAntiBot(
        address _tokenAddress,
        Options memory _options
    ) internal {
        canUseAntiBot[_tokenAddress] = _options;
    }
    /// @inheritdoc IERC20AntiBot
    function setCanUseAntiBot(
        bytes32 projectId,
        address _tokenAddress
    ) external payable onlyProjectOwner(_tokenAddress) {
        if (canUseAntiBot[_tokenAddress].active)
            revert TokenAlreadyActiveOnAntiBot();
        Options memory _options = Options(true, true);
        _setCanUseAntiBot(_tokenAddress, _options);
        payService(projectId, _tokenAddress, 1);
    }
    /// @inheritdoc IERC20AntiBot
    function setActive(
        address _tokenAddress,
        bool _active
    ) external onlyProjectOwner(_tokenAddress) {
        if (!canUseAntiBot[_tokenAddress].active)
            revert TokenNotActiveOnAntiBot();
        canUseAntiBot[_tokenAddress].applied = _active;
    }
    /// @inheritdoc IERC20AntiBot
    function setExempt(
        address _tokenAddress,
        address _traderAddress,
        bool _exempt
    ) external onlyProjectOwner(_tokenAddress) {
        if (!canUseAntiBot[_tokenAddress].active)
            revert TokenNotActiveOnAntiBot();
        exempts[_tokenAddress][_traderAddress] = _exempt;
    }
    /// @inheritdoc IERC20AntiBot
    function isExempt(
        address _tokenAddress,
        address _traderAddress
    ) public view returns (bool) {
        return exempts[_tokenAddress][_traderAddress];
    }
    /// @inheritdoc IERC20AntiBot
    function isActive(address _tokenAddress) public view returns (bool) {
        if (!canUseAntiBot[_tokenAddress].active) return false;
        return canUseAntiBot[_tokenAddress].applied;
    }
    /// @inheritdoc IERC20AntiBot
    function canUse(address _tokenAddress) public view returns (bool) {
        return canUseAntiBot[_tokenAddress].active;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
/*
 * IIndexer Inteface
 */
/// @title IIndexer
/// @author Smithii

interface IIndexer {
    /// Structs
    struct Contract {
        address contractAddress;
        string contracType;
        string name;
        string symbol;
    }
    struct Project {
        address owner;
        Contract[] contracts;
    }

    /// Errors
    error ProjectContractAlreadyRegistered();
    error ProjectIndexAlreadyRegistered();

    /// Events
    event ProjectRegistered(
        bytes32 projectId,
        address owner,
        address contractAddress,
        string contractType
    );

    /// Register a project in the Indexer
    /// @param _projectId bytes32 projectId
    /// @param _owner the owner of the project
    /// @param _contract the contract address
    function registerProject(
        bytes32 _projectId,
        address _owner,
        address _contract,
        string memory _contractType,
        string memory _name,
        string memory _symbol
    ) external;
    /// Check if the ProjectIndex is registered
    /// @param _projectId bytes32 projectId
    /// @return bool if the proyect is aleady registered
    function isProjectIndexRegistered(
        bytes32 _projectId
    ) external returns (bool);
    /// Check if a contract is registered in the project
    /// @param _contract the contract address
    /// @return bool if the proyect is aleady registered`
    function isContractRegistered(address _contract) external returns (bool);
    /// @param _projectId the project Index
    function getProjectOwner(bytes32 _projectId) external returns (address);
    ///
    /// @param _projectAddress address of the project
    function getProjectAddressOwner(
        address _projectAddress
    ) external returns (address);
    ///
    /// @param _projectAddress address of the project
    /// @return address the owner of the project
    /// @return address[] the contracts of the project
    function getProjectInfoByProjectAddress(
        address _projectAddress
    ) external returns (address, Contract[] memory);
    ///
    /// @param _projectId bytes32 projectId
    /// @return address the owner of the project
    /// @return address[] the contracts of the project
    function getProjectInfoByIndex(
        bytes32 _projectId
    ) external returns (address, Contract[] memory);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

/*
 * IPayments interface
 */
/// @title Payments
/// @author Smithii

interface IPayments {
    struct Service {
        bytes32 serviceId;
        uint256 pricePerItem;
        bool active;
    }

    struct Invoice {
        address user;
        Service service;
        uint256 qty;
        uint256 total;
        uint256 timestamp;
    }

    /// Events
    event ServiceAdded(bytes32 serviceId, string name, uint256 price);
    event ServiceSet(bytes32 serviceId, bool active);
    event ServicePaid(
        bytes32 projectId,
        address contractAddress,
        bytes32 serviceId,
        address user,
        uint256 amount,
        uint256 timestamp
    );
    event ServiceWithdraw(
        bytes32 projectId,
        address contractAddress,
        bytes32 serviceId,
        uint256 amount
    );

    /// Errors
    error ServiceNotActive(bytes32 serviceId);
    error InvalidTotalAmount();
    error ServiceAlreadyPaid(
        bytes32 projectId,
        address contractAddress,
        bytes32 serviceId
    );

    /// Add a service to the payment program
    /// @param _serviceId the service id
    /// @param _pricePerItem the price per item
    function addService(bytes32 _serviceId, uint256 _pricePerItem) external;
    /// Set the service active status
    /// @param _serviceId the service id
    /// @param _active the active status
    function setService(bytes32 _serviceId, bool _active) external;
    /// function payService by projectId and contract address
    /// @param _projectId bytes32 projectId
    /// @param _contract the contract address
    /// @param _serviceId the service id
    /// @param _qty the qty of items to pay
    function payService(
        bytes32 _projectId,
        address _contract,
        bytes32 _serviceId,
        uint256 _qty
    ) external payable;
    /// Withdraw per invoice
    /// @param _projectId the project id
    /// @param _contract the contract address
    /// @param _serviceId the service id
    /// @param _to the address to withdraw the balance
    function withdraw(
        bytes32 _projectId,
        address _contract,
        bytes32 _serviceId,
        address payable _to
    ) external;
    /// Withdraw the contract balance
    /// @param _to the address to withdraw the balance
    function withdrawAll(address payable _to) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
/*
 * IERC20AntiBot interface
 */
/// @title ERC20AntiBot
/// @author Smithii

interface IERC20AntiBot {
    struct Options {
        bool applied;
        bool active;
    }
    /// errors
    error TokenNotActiveOnAntiBot();
    error TokenAlreadyActiveOnAntiBot();
    ///
    /// @param _from the address to check
    function isBotDetected(address _from) external returns (bool);
    /// Registers the block number of the receiver
    /// @param _to the address to register
    function registerBlock(address _to) external;
    /// Registers and pay for a token address to use the Antibot
    /// @param projectId the project id
    /// @param _tokenAddress the address to register
    function setCanUseAntiBot(
        bytes32 projectId,
        address _tokenAddress
    ) external payable;
    /// Set the exempt status of a trader
    /// @param _tokenAddress the token address
    /// @param _traderAddress the trader address
    /// @param _exempt the exempt status
    function setExempt(
        address _tokenAddress,
        address _traderAddress,
        bool _exempt
    ) external;
    /// helper function to check if the trader is exempt
    /// @param _tokenAddress the token address
    /// @param _traderAddress the trader address
    function isExempt(
        address _tokenAddress,
        address _traderAddress
    ) external returns (bool);
    ///
    /// @param _tokenAddress the token address
    /// @param _active the active oft he options to be applied
    function setActive(address _tokenAddress, bool _active) external;
    /// Check if the token address is active to use the Antibot
    /// @param _tokenAddress the address to check
    function isActive(address _tokenAddress) external returns (bool);
    /// Get if the token address can use the Antibot
    /// @param _tokenAddress the address to check
    function canUse(address _tokenAddress) external returns (bool);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

/// @title Indexable
/// @author Smithii

import {IIndexer} from "../interfaces/marketplace/IIndexer.sol";

abstract contract Indexable {
    address public indexer = address(0);
    bytes32 public projectId;
    /// errors
    error NotPtojectOwner();
    constructor(address _indexer) {
        indexer = _indexer;
    }
    modifier onlyProjectOwner(address _address) {
        if (getProjectAddressOwner(_address) != msg.sender)
            revert NotPtojectOwner();
        _;
    }
    /// Registers the project in the Indexer
    /// @param _projectId the project id
    /// @param _owner the owner of the project
    /// @param _contract the contract address
    /// @param _contractType the contract type eg. ERC20, ERC721
    function registerProject(
        bytes32 _projectId,
        address _owner,
        address _contract,
        string memory _contractType,
        string memory _name,
        string memory _symbol
    ) public {
        IIndexer(indexer).registerProject(
            _projectId,
            _owner,
            _contract,
            _contractType,
            _name,
            _symbol
        );
    }
    ///
    /// @param _projectAddress the project address
    function isContractRegistered(
        address _projectAddress
    ) public returns (bool) {
        return IIndexer(indexer).isContractRegistered(_projectAddress);
    }
    ///
    /// @param _projectId the project id
    function getProjectOwner(bytes32 _projectId) public returns (address) {
        return IIndexer(indexer).getProjectOwner(_projectId);
    }
    function getProjectAddressOwner(
        address _projectAddress
    ) public returns (address) {
        return IIndexer(indexer).getProjectAddressOwner(_projectAddress);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

/// @title Payable
/// @author Smithii

import {IPayments} from "../interfaces/marketplace/IPayments.sol";

abstract contract Payable {
    address public payments = address(0);
    bytes32 public serviceId;

    constructor(address _payments, string memory _serviceId) {
        payments = _payments;
        serviceId = keccak256(abi.encodePacked(_serviceId));
    }
    ///
    /// @param _projectId the project id
    /// @param _token the token address
    /// @param qty the qty of items to pay
    function payService(
        bytes32 _projectId,
        address _token,
        uint256 qty
    ) public payable {
        IPayments(payments).payService{value: msg.value}(
            _projectId,
            _token,
            serviceId,
            qty
        );
    }
    receive() external payable {}
}