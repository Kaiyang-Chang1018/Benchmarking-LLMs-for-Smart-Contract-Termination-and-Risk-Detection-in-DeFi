// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IERC721 {
  function balanceOf(address owner) external view returns (uint256);
}

interface IENSResolver {
  function setAddr(bytes32 node, address addr) external;

  function addr(bytes32 node) external view returns (address);
}

interface IENSRegistry {
  function setOwner(bytes32 node, address owner) external;

  function owner(bytes32 node) external view returns (address);

  function setResolver(bytes32 node, address resolver) external;

  function resolver(bytes32 node) external view returns (address);

  function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external;
}

error InvalidDomain();
error WrongEtherAmount();
error WithdrawalFailed();
error NotSavedSoulsHolder();
error SubdomainAlreadyOwned();

contract SavedSoulsENS is Ownable {
  bytes32 private constant EMPTY_NAMEHASH = 0x00;

  IERC721 private immutable savedSouls;

  IENSRegistry private registry;
  IENSResolver private resolver;

  uint256 public subdomainPrice = 0.002 ether;

  mapping(address => uint8) private freeSubdomainCount;

  constructor(
    IERC721 _savedSouls,
    IENSRegistry _registry,
    IENSResolver _resolver
  ) {
    registry = _registry;
    resolver = _resolver;
    savedSouls = _savedSouls;
  }

  function newSubdomain(
    string calldata _subdomain,
    string calldata _domain,
    string calldata _topdomain
  ) external payable {
    if (savedSouls.balanceOf(msg.sender) == 0) {
      revert NotSavedSoulsHolder();
    }

    bytes32 topdomainNamehash = keccak256(
      abi.encodePacked(EMPTY_NAMEHASH, keccak256(abi.encodePacked(_topdomain)))
    );
    bytes32 domainNamehash = keccak256(
      abi.encodePacked(topdomainNamehash, keccak256(abi.encodePacked(_domain)))
    );

    if (registry.owner(domainNamehash) != address(this)) {
      revert InvalidDomain();
    }

    bytes32 subdomainLabelhash = keccak256(abi.encodePacked(_subdomain));
    bytes32 subdomainNamehash = keccak256(
      abi.encodePacked(domainNamehash, subdomainLabelhash)
    );

    if (registry.owner(subdomainNamehash) != address(0)) {
      revert SubdomainAlreadyOwned();
    }

    uint8 availableSubdomains = getAvailableSubdomains(msg.sender);

    if (availableSubdomains == 0 && msg.value != subdomainPrice) {
      revert WrongEtherAmount();
    }

    if (availableSubdomains > 0) {
      freeSubdomainCount[msg.sender] += 1;
    }

    registry.setSubnodeOwner(domainNamehash, subdomainLabelhash, address(this));
    registry.setResolver(subdomainNamehash, address(resolver));
    resolver.setAddr(subdomainNamehash, msg.sender);
    registry.setOwner(subdomainNamehash, msg.sender);
  }

  function getFreeSubdomainCount(address _owner) external view returns (uint8) {
    return freeSubdomainCount[_owner];
  }

  function getAvailableSubdomains(address _owner) public view returns (uint8) {
    uint256 balance = savedSouls.balanceOf(_owner);
    uint8 usedSubdomains = freeSubdomainCount[_owner];

    if (balance >= 100) return 5 - usedSubdomains;
    if (balance >= 40) return 4 - usedSubdomains;
    if (balance >= 15) return 3 - usedSubdomains;
    if (balance >= 5) return 2 - usedSubdomains;
    if (balance >= 1) return 1 - usedSubdomains;

    return 0;
  }

  function domainOwner(
    string calldata _domain,
    string calldata _topdomain
  ) external view returns (address) {
    bytes32 topdomainNamehash = keccak256(
      abi.encodePacked(EMPTY_NAMEHASH, keccak256(abi.encodePacked(_topdomain)))
    );
    bytes32 namehash = keccak256(
      abi.encodePacked(topdomainNamehash, keccak256(abi.encodePacked(_domain)))
    );

    return registry.owner(namehash);
  }

  function subdomainOwner(
    string calldata _subdomain,
    string calldata _domain,
    string calldata _topdomain
  ) external view returns (address) {
    bytes32 topdomainNamehash = keccak256(
      abi.encodePacked(EMPTY_NAMEHASH, keccak256(abi.encodePacked(_topdomain)))
    );
    bytes32 domainNamehash = keccak256(
      abi.encodePacked(topdomainNamehash, keccak256(abi.encodePacked(_domain)))
    );
    bytes32 subdomainNamehash = keccak256(
      abi.encodePacked(domainNamehash, keccak256(abi.encodePacked(_subdomain)))
    );

    return registry.owner(subdomainNamehash);
  }

  function updateRegistry(IENSRegistry _registry) external onlyOwner {
    registry = _registry;
  }

  function updateResolver(IENSResolver _resolver) external onlyOwner {
    resolver = _resolver;
  }

  function updateSubdomainPrice(uint256 _price) external onlyOwner {
    subdomainPrice = _price;
  }

  function withdraw() external onlyOwner {
    (bool success, ) = payable(owner()).call{value: address(this).balance}("");

    if (!success) {
      revert WithdrawalFailed();
    }
  }
}