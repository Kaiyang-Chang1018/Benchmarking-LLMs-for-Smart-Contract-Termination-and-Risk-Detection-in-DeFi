// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Create2.sol)

pragma solidity ^0.8.20;

/**
 * @dev Helper to make usage of the `CREATE2` EVM opcode easier and safer.
 * `CREATE2` can be used to compute in advance the address where a smart
 * contract will be deployed, which allows for interesting new mechanisms known
 * as 'counterfactual interactions'.
 *
 * See the https://eips.ethereum.org/EIPS/eip-1014#motivation[EIP] for more
 * information.
 */
library Create2 {
    /**
     * @dev Not enough balance for performing a CREATE2 deploy.
     */
    error Create2InsufficientBalance(uint256 balance, uint256 needed);

    /**
     * @dev There's no code to deploy.
     */
    error Create2EmptyBytecode();

    /**
     * @dev The deployment failed.
     */
    error Create2FailedDeployment();

    /**
     * @dev Deploys a contract using `CREATE2`. The address where the contract
     * will be deployed can be known in advance via {computeAddress}.
     *
     * The bytecode for a contract can be obtained from Solidity with
     * `type(contractName).creationCode`.
     *
     * Requirements:
     *
     * - `bytecode` must not be empty.
     * - `salt` must have not been used for `bytecode` already.
     * - the factory must have a balance of at least `amount`.
     * - if `amount` is non-zero, `bytecode` must have a `payable` constructor.
     */
    function deploy(uint256 amount, bytes32 salt, bytes memory bytecode) internal returns (address addr) {
        if (address(this).balance < amount) {
            revert Create2InsufficientBalance(address(this).balance, amount);
        }
        if (bytecode.length == 0) {
            revert Create2EmptyBytecode();
        }
        /// @solidity memory-safe-assembly
        assembly {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
        }
        if (addr == address(0)) {
            revert Create2FailedDeployment();
        }
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy}. Any change in the
     * `bytecodeHash` or `salt` will result in a new destination address.
     */
    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {
        return computeAddress(salt, bytecodeHash, address(this));
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy} from a contract located at
     * `deployer`. If `deployer` is this contract's address, returns the same value as {computeAddress}.
     */
    function computeAddress(bytes32 salt, bytes32 bytecodeHash, address deployer) internal pure returns (address addr) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40) // Get free memory pointer

            // |                   | ↓ ptr ...  ↓ ptr + 0x0B (start) ...  ↓ ptr + 0x20 ...  ↓ ptr + 0x40 ...   |
            // |-------------------|---------------------------------------------------------------------------|
            // | bytecodeHash      |                                                        CCCCCCCCCCCCC...CC |
            // | salt              |                                      BBBBBBBBBBBBB...BB                   |
            // | deployer          | 000000...0000AAAAAAAAAAAAAAAAAAA...AA                                     |
            // | 0xFF              |            FF                                                             |
            // |-------------------|---------------------------------------------------------------------------|
            // | memory            | 000000...00FFAAAAAAAAAAAAAAAAAAA...AABBBBBBBBBBBBB...BBCCCCCCCCCCCCC...CC |
            // | keccak(start, 85) |            ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑ |

            mstore(add(ptr, 0x40), bytecodeHash)
            mstore(add(ptr, 0x20), salt)
            mstore(ptr, deployer) // Right-aligned with 12 preceding garbage bytes
            let start := add(ptr, 0x0b) // The hashed data starts at the final garbage byte which we will set to 0xff
            mstore8(start, 0xff)
            addr := keccak256(start, 85)
        }
    }
}
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
 * Factory contract
 * This contract is used to deploy smart contracts and register them in the Indexer contract
 */
/// @title ERC20TokenFactory
/// @author Smithii

import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";
import {Indexable} from "./utils/Indexable.sol";
import {Payable} from "./utils/Payable.sol";

contract ERC20TokenFactory is Payable, Indexable {
    constructor(
        address _indexer,
        address _payments,
        string memory _serviceId
    ) Payable(_payments, _serviceId) Indexable(_indexer) {}

    /// Deploys a contract and pays the service creating fee
    /// @param _projectId bytes32 projectId
    /// @param _byteCode the contract bytecode
    /// @param _type the contract type
    function deployContract(
        bytes32 _projectId,
        bytes calldata _byteCode,
        string memory _type,
        string memory _name,
        string memory _symbol
    ) external payable {
        address resultedAddress = Create2.computeAddress(
            _projectId,
            keccak256(_byteCode)
        );
        registerProject(_projectId, msg.sender, resultedAddress, _type, _name, _symbol);
        address _contract = Create2.deploy(0, _projectId, _byteCode);
        require(_contract == resultedAddress, "Contract address mismatch");
        /// @notice Pay the total of 1 token creation fee
        payService(_projectId, _contract, 1);
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