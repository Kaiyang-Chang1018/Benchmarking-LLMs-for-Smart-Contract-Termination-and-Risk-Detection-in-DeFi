// File: @openzeppelin/contracts@4.9.5/utils/Context.sol


// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts@4.9.5/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
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

// File: 1.sol



pragma solidity >=0.8.11 <0.9.0;


contract Snowdare is Ownable {

  struct Asset {
    uint256 id;
    uint256 versionsCount;
    address owner;
    string title;
  }
  struct Version {
    uint256 assetType;
    uint256 chunkIdsCount;
    string name;
    uint256 size;
    string fileType;
    uint256 commentIdsCount;
    address author;
    uint256 timestamp;
    bytes cipherData;
  }
  struct Profile {
    uint256 assetIdsCount;
    uint256 commentIdsCount;
    string name;
    uint256 lastActivity;
    uint256 earnings;
    bool commentsBlocked;
    address referrer;
  }

  uint256 public assetCount;
  uint256 public chunksCount;
  uint256 public commentsCount;
  uint256 public profilesCount;

  uint256 public appNewestVersion;
  uint256 public mainNetworkId;

  mapping (uint256 => Asset) public assets;
  mapping (bytes32 => Asset) public externalAssets;
  mapping (uint256 => mapping(uint256 => Version)) public versions;
  mapping (uint256 => mapping(uint256 => mapping(uint256 => uint256))) public chunkIds;
  mapping (uint256 => bytes) public chunks;
  mapping (uint256 => address) public chunkOwners;
  mapping (uint256 => Version) public comments;
  mapping (uint256 => mapping(uint256 => uint256)) public chunkIdsInComments;
  mapping (uint256 => mapping(uint256 => mapping(uint256 => uint256))) public commentIds;
  mapping (string => address) public addressesFromNames;
  mapping (address => Profile) public profilesFromAddresses;
  mapping (address => mapping(uint256 => uint256)) public assetIdsInProfiles;
  mapping (address => mapping(uint256 => uint256)) public commentIdsInProfiles;
  mapping (bytes32 => uint256) public commentIdsCountInExternalAssets;
  mapping (bytes32 => mapping(uint256 => uint256)) public commentIdsInExternalAssets;
  mapping (address => Version) public aboutProfilesFromAddresses;
  mapping (address => mapping(uint256 => uint256)) public chunkIdsInAboutProfiles;

  event AssetIndex(address indexed _address, uint256 _assetIndex);
  event ChunkIndex(address indexed _address, uint256 _chunkIndex);

  function addAsset(bytes memory _bytes, string memory _title, uint256[] memory _additionalChunkIds, uint256 _assetType, string memory _name, uint256 _size, string memory _fileType, address _hostAddress, address _referralAddress, bytes memory _cipherData) public payable {
    addChunk(_bytes, _hostAddress, _referralAddress, 9007199254740991, 0x0000000000000000000000000000000000000000000000000000000000000000);
    uint i = 0;
    while (i < _additionalChunkIds.length) {
      require(chunkOwners[_additionalChunkIds[i]] == msg.sender);
      chunkIds[assetCount][0][i] = _additionalChunkIds[i];
      i++;
    }
    require(bytes(_title).length <= 64 && bytes(_title).length > 0 && bytes(_name).length <= 512);
    chunkIds[assetCount][0][i] = chunksCount - 1;
    versions[assetCount][0] = Version(_assetType, i + 1, _name, _size, _fileType, 0, msg.sender, block.timestamp, _cipherData);
    assets[assetCount] = Asset(assetCount, 1, msg.sender, _title);
    assetIdsInProfiles[msg.sender][profilesFromAddresses[msg.sender].assetIdsCount] = assetCount;
    assetCount++;
    profilesFromAddresses[msg.sender].assetIdsCount++;
    emit AssetIndex(msg.sender, assetCount - 1);
  }

  function addExternalAsset(string memory _name, address _hostAddress, address _referralAddress) public payable {
    uint256 minimum = tx.gasprice * (bytes(_name).length * 12 + ((bytes(_name).length / 32) * 20000) + 395314) * 95 / 100;
    require(msg.value >= minimum);
    uint256 bonus = msg.value / 10;
    processPayments(bonus, _hostAddress, _referralAddress);
    (bool os, ) = payable(owner()).call{value: (msg.value - (5 * bonus))}('');
    require(os);
    bytes32 hash = keccak256(bytes(_name));
    require(keccak256(abi.encodePacked(externalAssets[hash].title)) == keccak256(abi.encodePacked("")));
    externalAssets[hash] = Asset(0, 0, msg.sender, _name);
  }

  function updateAsset(bytes memory _bytes, uint256[] memory _additionalChunkIds, uint256 _id, uint256 _assetType, string memory _name, uint256 _size, string memory _fileType, address _hostAddress, address _referralAddress, bytes memory _cipherData) public payable {
    addChunk(_bytes, _hostAddress, _referralAddress, 9007199254740991, 0x0000000000000000000000000000000000000000000000000000000000000000);
    require(assetCount > _id && bytes(_name).length <= 64 && msg.sender == assets[_id].owner);
    uint i = 0;
    while (i < _additionalChunkIds.length) {
      require(chunkOwners[_additionalChunkIds[i]] == msg.sender);
      chunkIds[_id][assets[_id].versionsCount][i] = _additionalChunkIds[i];
      i++;
    }
    require(bytes(_cipherData).length == 0 || bytes(_cipherData).length == 48);
    chunkIds[_id][assets[_id].versionsCount][i] = chunksCount - 1;
    versions[_id][assets[_id].versionsCount] = Version(_assetType, i + 1, _name, _size, _fileType, 0, msg.sender, block.timestamp, _cipherData);
    assets[_id].versionsCount++;
  }

  function addComment(bytes memory _bytes, uint256[] memory _additionalChunkIds, uint256 _id, uint256 _versionId, uint256 _assetType, string memory _name, uint256 _size, string memory _fileType, address _hostAddress, address _referralAddress, bytes memory _cipherData) public payable {
    addChunk(_bytes, _hostAddress, _referralAddress, _id, 0x0000000000000000000000000000000000000000000000000000000000000000);
    require(assetCount > _id && bytes(_name).length <= 64 && assets[_id].versionsCount > _versionId, "Error!");
    commentsCount++;
    commentIds[_id][_versionId][versions[_id][_versionId].commentIdsCount] = commentsCount;
    uint i = 0;
    while (i < _additionalChunkIds.length) {
      require(chunkOwners[_additionalChunkIds[i]] == msg.sender, "Error!");
      chunkIdsInComments[commentsCount][i] = _additionalChunkIds[i];
      i++;
    }
    require(bytes(_cipherData).length == 0 || bytes(_cipherData).length == 48, "Error!");
    chunkIdsInComments[commentsCount][i] = chunksCount - 1;
    comments[commentsCount] = Version(_assetType, i + 1, _name, _size, _fileType, 0, msg.sender, block.timestamp, _cipherData);
    versions[_id][_versionId].commentIdsCount++;
  }

  function addCommentExternal(bytes memory _bytes, uint256[] memory _additionalChunkIds, bytes32 _assetHash, uint256 _assetType, string memory _name, uint256 _size, string memory _fileType, address _hostAddress, address _referralAddress, bytes memory _cipherData) public payable {
    addChunk(_bytes, _hostAddress, _referralAddress, 9007199254740991, _assetHash);
    commentsCount++;
    commentIdsInExternalAssets[_assetHash][commentIdsCountInExternalAssets[bytes32(_assetHash)]] = commentsCount;
    require(bytes(_name).length <= 64);
    uint i = 0;
    while (i < _additionalChunkIds.length) {
      require(chunkOwners[_additionalChunkIds[i]] == msg.sender);
      chunkIdsInComments[commentsCount][i] = _additionalChunkIds[i];
      i++;
    }
    require(bytes(_cipherData).length == 0 || bytes(_cipherData).length == 48);
    chunkIdsInComments[commentsCount][i] = chunksCount - 1;
    comments[commentsCount] = Version(_assetType, i + 1, _name, _size, _fileType, 0, msg.sender, block.timestamp, _cipherData);
    commentIdsCountInExternalAssets[_assetHash]++;
  }

  function addCommentInProfile(bytes memory _bytes, uint256[] memory _additionalChunkIds, address _profileId, uint256 _assetType, string memory _name, uint256 _size, string memory _fileType, address _hostAddress, address _referralAddress) public payable {
    addChunk(_bytes, _hostAddress, _referralAddress, 9007199254740991, 0x0000000000000000000000000000000000000000000000000000000000000000);
    commentsCount++;
    commentIdsInProfiles[_profileId][profilesFromAddresses[_profileId].commentIdsCount] = commentsCount;
    require(bytes(_name).length <= 64);
    uint i = 0;
    while (i < _additionalChunkIds.length) {
      require(chunkOwners[_additionalChunkIds[i]] == msg.sender);
      chunkIdsInComments[commentsCount][i] = _additionalChunkIds[i];
      i++;
    }
    chunkIdsInComments[commentsCount][i] = chunksCount - 1;
    comments[commentsCount] = Version(_assetType, i + 1, _name, _size, _fileType, 0, msg.sender, block.timestamp, "");
    profilesFromAddresses[_profileId].commentIdsCount++;
  }

  function addAboutInProfile(bytes memory _bytes, uint256[] memory _additionalChunkIds, uint256 _assetType, string memory _name, uint256 _size, string memory _fileType, address _hostAddress, address _referralAddress) public payable {
    addChunk(_bytes, _hostAddress, _referralAddress, 9007199254740991, 0x0000000000000000000000000000000000000000000000000000000000000000);
    require(bytes(_name).length <= 64);
    uint i = 0;
    while (i < _additionalChunkIds.length) {
      require(chunkOwners[_additionalChunkIds[i]] == msg.sender);
      chunkIdsInAboutProfiles[msg.sender][i] = _additionalChunkIds[i];
      i++;
    }
    chunkIdsInAboutProfiles[msg.sender][i] = chunksCount - 1;
    aboutProfilesFromAddresses[msg.sender] = Version(_assetType, i + 1, _name, _size, _fileType, 0, msg.sender, block.timestamp, "");
  }

  function addChunk(bytes memory _bytes, address _hostAddress, address _referralAddress, uint256 _assetId, bytes32 _externalAssetId) public payable {
    uint256 minimum = tx.gasprice * (bytes(_bytes).length * 12 + ((bytes(_bytes).length / 32) * 20000) + 395314) * 95 / 100;
    require(msg.value >= minimum);
    uint256 bonus = msg.value / 10;
    processPayments(bonus, _hostAddress, _referralAddress);
    address assetOwnerAddress;
    if (_externalAssetId != 0x0000000000000000000000000000000000000000000000000000000000000000) {
      if (profilesFromAddresses[externalAssets[bytes32(_externalAssetId)].owner].lastActivity + 2592000 < block.timestamp) {
        assetOwnerAddress = owner();
      } else {
        assetOwnerAddress = externalAssets[bytes32(_externalAssetId)].owner;
      }
    } else {
      if (_assetId == 9007199254740991 || profilesFromAddresses[assets[_assetId].owner].lastActivity + 2592000 < block.timestamp) {
        assetOwnerAddress = owner();
      } else {
        assetOwnerAddress = assets[_assetId].owner;
      }
    }
    (bool ass, ) = payable(assetOwnerAddress).call{value: (4 * bonus)}('');
    profilesFromAddresses[assetOwnerAddress].earnings = profilesFromAddresses[assetOwnerAddress].earnings + (4 * bonus);
    require(ass);
    (bool os, ) = payable(owner()).call{value: (msg.value - (9 * bonus))}('');
    require(os);
    chunks[chunksCount] = _bytes;
    chunkOwners[chunksCount] = msg.sender;
    chunksCount++;
    emit ChunkIndex(msg.sender, chunksCount - 1);
  }

  function setName(string memory _newName) public {
    require(bytes(_newName).length > 2 && bytes(_newName).length < 33 && addressesFromNames[_newName] == 0x0000000000000000000000000000000000000000 && bytes(profilesFromAddresses[msg.sender].name).length == 0);
    uint i = 0;
    while (i < bytes(_newName).length) {
      require((bytes(_newName)[i] >= 0x2D && bytes(_newName)[i] <= 0x39) || (bytes(_newName)[i] >= 0x61 && bytes(_newName)[i] <= 0x7A));
      i++;
    }
    profilesFromAddresses[msg.sender].name = _newName;
    addressesFromNames[_newName] = msg.sender;
  }

  function setCommentsBlock(bool blockComments) public {
    profilesFromAddresses[msg.sender].commentsBlocked = blockComments;
  }

  function updateExternalAssetOwner(address _newOwner, bytes32 _hash) public {
    require(msg.sender == externalAssets[_hash].owner);
    externalAssets[_hash].owner = _newOwner;
  }

  function withdraw() public onlyOwner {
    (bool os, ) = payable(owner()).call{value: address(this).balance}('');
    require(os);
  }

  function setAppNewestVersion(uint256 version) public onlyOwner {
    appNewestVersion = version;
  }
  
  function setMainNetworkId(uint256 networkId) public onlyOwner {
    mainNetworkId = networkId;
  }

  function processPayments(uint256 bonus, address _hostAddress, address _referralAddress) private {
    address hostAddress;
    if (_hostAddress == 0x0000000000000000000000000000000000000000 || _hostAddress == msg.sender || profilesFromAddresses[_hostAddress].lastActivity + 2592000 < block.timestamp) {
      hostAddress = owner();
    } else {
      hostAddress = _hostAddress;
    }
    address referralAddress;
    if (profilesFromAddresses[msg.sender].referrer == 0x0000000000000000000000000000000000000000) {
      if (_referralAddress != msg.sender) {
        profilesFromAddresses[msg.sender].referrer = _referralAddress;
      } else {
      profilesFromAddresses[msg.sender].referrer = owner();
      } 
    }
    if (profilesFromAddresses[profilesFromAddresses[msg.sender].referrer].lastActivity + 2592000 < block.timestamp) {
      referralAddress = owner();
    } else {
      referralAddress = profilesFromAddresses[msg.sender].referrer;
    }
    address referralAddress2;
    if (profilesFromAddresses[profilesFromAddresses[msg.sender].referrer].referrer == 0x0000000000000000000000000000000000000000 || msg.sender == profilesFromAddresses[profilesFromAddresses[msg.sender].referrer].referrer || profilesFromAddresses[profilesFromAddresses[msg.sender].referrer].lastActivity + 2592000 < block.timestamp) {
      referralAddress2 = owner();
    } else {
      referralAddress2 = profilesFromAddresses[profilesFromAddresses[msg.sender].referrer].referrer;
    }
    (bool hs, ) = payable(hostAddress).call{value: (2 * bonus)}('');
    profilesFromAddresses[hostAddress].earnings = profilesFromAddresses[hostAddress].earnings + (2 * bonus);
    require(hs);
    (bool rs, ) = payable(referralAddress).call{value: (2 * bonus)}('');
    profilesFromAddresses[referralAddress].earnings = profilesFromAddresses[referralAddress].earnings + (2 * bonus);
    require(rs);
    (bool rs2, ) = payable(referralAddress2).call{value: bonus}('');
    profilesFromAddresses[referralAddress2].earnings = profilesFromAddresses[referralAddress2].earnings + bonus;
    require(rs2);
    profilesFromAddresses[msg.sender].lastActivity = block.timestamp;
  }
}