// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
  @title A library for deploying contracts EIP-3171 style.
*/
library Create3 {
    error ErrorCreatingProxy();
    error ErrorCreatingContract();
    error TargetAlreadyExists();

    /**
    @notice The bytecode for a contract that proxies the creation of another contract
    @dev If this code is deployed using CREATE2 it can be used to decouple `creationCode` from the child contract address

  0x67363d3d37363d34f03d5260086018f3:
      0x00  0x67  0x67XXXXXXXXXXXXXXXX  PUSH8 bytecode  0x363d3d37363d34f0
      0x01  0x3d  0x3d                  RETURNDATASIZE  0 0x363d3d37363d34f0
      0x02  0x52  0x52                  MSTORE
      0x03  0x60  0x6008                PUSH1 08        8
      0x04  0x60  0x6018                PUSH1 18        24 8
      0x05  0xf3  0xf3                  RETURN

  0x363d3d37363d34f0:
      0x00  0x36  0x36                  CALLDATASIZE    cds
      0x01  0x3d  0x3d                  RETURNDATASIZE  0 cds
      0x02  0x3d  0x3d                  RETURNDATASIZE  0 0 cds
      0x03  0x37  0x37                  CALLDATACOPY
      0x04  0x36  0x36                  CALLDATASIZE    cds
      0x05  0x3d  0x3d                  RETURNDATASIZE  0 cds
      0x06  0x34  0x34                  CALLVALUE       val 0 cds
      0x07  0xf0  0xf0                  CREATE          addr
  */

    bytes internal constant PROXY_CHILD_BYTECODE =
        hex"67_36_3d_3d_37_36_3d_34_f0_3d_52_60_08_60_18_f3";

    //                        KECCAK256_PROXY_CHILD_BYTECODE = keccak256(PROXY_CHILD_BYTECODE);
    bytes32 internal constant KECCAK256_PROXY_CHILD_BYTECODE =
        0x21c35dbe1b344a2488cf3321d6ce542f8e9f305544ff09e4993a62319a497c1f;

    /**
    @notice Returns the size of the code on a given address
    @param _addr Address that may or may not contain code
    @return size of the code on the given `_addr`
  */
    function codeSize(address _addr) internal view returns (uint256 size) {
        assembly {
            size := extcodesize(_addr)
        }
    }

    /**
    @notice Creates a new contract with given `_creationCode` and `_salt`
    @param _salt Salt of the contract creation, resulting address will be derivated from this value only
    @param _creationCode Creation code (constructor) of the contract to be deployed, this value doesn't affect the resulting address
    @return addr of the deployed contract, reverts on error
  */
    function create3(bytes32 _salt, bytes memory _creationCode)
        internal
        returns (address addr)
    {
        return create3(_salt, _creationCode, 0);
    }

    /**
    @notice Creates a new contract with given `_creationCode` and `_salt`
    @param _salt Salt of the contract creation, resulting address will be derivated from this value only
    @param _creationCode Creation code (constructor) of the contract to be deployed, this value doesn't affect the resulting address
    @param _value In WEI of ETH to be forwarded to child contract
    @return addr of the deployed contract, reverts on error
  */
    function create3(
        bytes32 _salt,
        bytes memory _creationCode,
        uint256 _value
    ) internal returns (address addr) {
        // Creation code
        bytes memory creationCode = PROXY_CHILD_BYTECODE;

        // Get target final address
        addr = addressOf(_salt);
        if (codeSize(addr) != 0) revert TargetAlreadyExists();

        // Create CREATE2 proxy
        address proxy;
        assembly {
            proxy := create2(
                0,
                add(creationCode, 32),
                mload(creationCode),
                _salt
            )
        }
        if (proxy == address(0)) revert ErrorCreatingProxy();

        // Call proxy with final init code
        (bool success, ) = proxy.call{value: _value}(_creationCode);
        if (!success || codeSize(addr) == 0) revert ErrorCreatingContract();
    }

    /**
    @notice Computes the resulting address of a contract deployed using address(this) and the given `_salt`
    @param _salt Salt of the contract creation, resulting address will be derivated from this value only
    @return addr of the deployed contract, reverts on error

    @dev The address creation formula is: keccak256(rlp([keccak256(0xff ++ address(this) ++ _salt ++ keccak256(childBytecode))[12:], 0x01]))
  */
    function addressOf(bytes32 _salt) internal view returns (address) {
        address proxy = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            address(this),
                            _salt,
                            KECCAK256_PROXY_CHILD_BYTECODE
                        )
                    )
                )
            )
        );

        return
            address(
                uint160(
                    uint256(
                        keccak256(abi.encodePacked(hex"d6_94", proxy, hex"01"))
                    )
                )
            );
    }
}

/**
 * @title UniversalDeployer for GlueX Protocol
 * @author
 * @dev A simple contract that deploys other contracts via Create3.
 *      If the UniversalDeployer is at the same address on multiple chains,
 *      it can produce the same child contract address on each chain
 *      by using the same salt.
 */
contract UniversalDeployer {
    event Deployed(address indexed contract_address, bytes32 indexed salt);

    error OnlyGluexDeployer();

    address public immutable gluexDeployer;

    constructor(address _gluexDeployer) {
        gluexDeployer = _gluexDeployer;
    }

    /**
     * @dev Modifier to restrict access to deployer-only functions.
     */
    modifier onlyDeployer() {
        checkDeployer();
        _;
    }

    /**
     * @notice Verifies the caller is the Gluex deployer.
     * @dev Reverts with `OnlyGluexDeployer` if the caller is not the deployer.
     */
    function checkDeployer() internal view {
        if (msg.sender != gluexDeployer) revert OnlyGluexDeployer();
    }

    /**
     * @dev Deploys a contract using Create3 with the given salt.
     * @param _bytecode The creation bytecode of the contract to deploy (without constructor arguments).
     * @param _args Constructor arguments of the contract to deploy.
     * @param _salt A 32-byte salt used to create a deterministic address.
     * @return contractAddress The address of the deployed contract.
     *
     * Requirements:
     * - The code cannot be empty.
     * - The deployed address must not already contain code (i.e. same salt can only be used once).
     */
    function deploy(
        bytes memory _bytecode,
        bytes memory _args,
        string memory _salt
    ) external onlyDeployer returns (address contractAddress) {
        bytes memory code = abi.encodePacked(_bytecode, _args);

        require(code.length != 0, "UniversalDeployer: bytecode is empty");

        bytes32 salt = keccak256(bytes(_salt));

        contractAddress = Create3.create3(salt, code);

        emit Deployed(contractAddress, salt);
    }

    /**
     * @dev Computes the address of a contract deployed via Create3.
     * @param _salt The salt used for deployment.
     * @return predicted The address of the deployed contract.
     */
    function getDeployedAddress(string memory _salt)
        external
        view
        returns (address predicted)
    {
        bytes32 salt = keccak256(bytes(_salt));
        return Create3.addressOf(salt);
    }
}