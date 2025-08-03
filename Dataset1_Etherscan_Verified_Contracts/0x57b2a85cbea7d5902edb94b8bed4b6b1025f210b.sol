// File: @chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol


pragma solidity ^0.8.4;

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness. It ensures 2 things:
 * @dev 1. The fulfillment came from the VRFCoordinator
 * @dev 2. The consumer contract implements fulfillRandomWords.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash). Create subscription, fund it
 * @dev and your consumer contract as a consumer of it (see VRFCoordinatorInterface
 * @dev subscription management functions).
 * @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,
 * @dev callbackGasLimit, numWords),
 * @dev see (VRFCoordinatorInterface for a description of the arguments).
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomWords method.
 *
 * @dev The randomness argument to fulfillRandomWords is a set of random words
 * @dev generated from your requestId and the blockHash of the request.
 *
 * @dev If your contract could have concurrent requests open, you can use the
 * @dev requestId returned from requestRandomWords to track which response is associated
 * @dev with which randomness request.
 * @dev See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ.
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request. It is for this reason that
 * @dev that you can signal to an oracle you'd like them to wait longer before
 * @dev responding to the request (however this is not enforced in the contract
 * @dev and so remains effective only in the case of unmodified oracle software).
 */
abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   */
  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBaseV2 expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomWords the VRF output expanded to the requested number of words
   */
  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}

// File: @chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol


pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {
  /**
   * @notice Get configuration relevant for making requests
   * @return minimumRequestConfirmations global min for request confirmations
   * @return maxGasLimit global max for request gas limit
   * @return s_provingKeyHashes list of registered key hashes
   */
  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );

  /**
   * @notice Request a set of random words.
   * @param keyHash - Corresponds to a particular oracle job which uses
   * that key for generating the VRF proof. Different keyHash's have different gas price
   * ceilings, so you can select a specific one to bound your maximum per request cost.
   * @param subId  - The ID of the VRF subscription. Must be funded
   * with the minimum subscription balance required for the selected keyHash.
   * @param minimumRequestConfirmations - How many blocks you'd like the
   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
   * for why you may want to request more. The acceptable range is
   * [minimumRequestBlockConfirmations, 200].
   * @param callbackGasLimit - How much gas you'd like to receive in your
   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
   * may be slightly less than this amount because of gas used calling the function
   * (argument decoding etc.), so you may need to request slightly more than you expect
   * to have inside fulfillRandomWords. The acceptable range is
   * [0, maxGasLimit]
   * @param numWords - The number of uint256 random values you'd like to receive
   * in your fulfillRandomWords callback. Note these numbers are expanded in a
   * secure way by the VRFCoordinator from a single random value supplied by the oracle.
   * @return requestId - A unique identifier of the request. Can be used to match
   * a request to a response in fulfillRandomWords.
   */
  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  /**
   * @notice Create a VRF subscription.
   * @return subId - A unique subscription id.
   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
   * @dev Note to fund the subscription, use transferAndCall. For example
   * @dev  LINKTOKEN.transferAndCall(
   * @dev    address(COORDINATOR),
   * @dev    amount,
   * @dev    abi.encode(subId));
   */
  function createSubscription() external returns (uint64 subId);

  /**
   * @notice Get a VRF subscription.
   * @param subId - ID of the subscription
   * @return balance - LINK balance of the subscription in juels.
   * @return reqCount - number of requests for this subscription, determines fee tier.
   * @return owner - owner of the subscription.
   * @return consumers - list of consumer address which are able to use this subscription.
   */
  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @param newOwner - proposed new owner of the subscription
   */
  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @dev will revert if original owner of subId has
   * not requested that msg.sender become the new owner.
   */
  function acceptSubscriptionOwnerTransfer(uint64 subId) external;

  /**
   * @notice Add a consumer to a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - New consumer which can use the subscription
   */
  function addConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Remove a consumer from a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - Consumer to remove from the subscription
   */
  function removeConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Cancel a subscription
   * @param subId - ID of the subscription
   * @param to - Where to send the remaining LINK to
   */
  function cancelSubscription(uint64 subId, address to) external;

  /*
   * @notice Check to see if there exists a request commitment consumers
   * for all consumers and keyhashes for a given sub.
   * @param subId - ID of the subscription
   * @return true if there exists at least one unfulfilled request for the subscription, false
   * otherwise.
   */
  function pendingRequestExists(uint64 subId) external view returns (bool);
}

// File: WeaponToBlood.sol


pragma solidity ^0.8.18;



interface ILoot {
    function controlledBurn(address _from, uint256 _id, uint256 _amount) external;

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts) external;
}

contract WeaponToBlood is VRFConsumerBaseV2 {
    address lootContract;
    mapping(uint256 => uint256[]) weaponToRarityChances;
    struct ChainlinkRequest {
        address sender;
        uint256[] weaponIds;
    }
    mapping(uint256 => ChainlinkRequest) requests;
    address owner;
    uint256 price = 0;
    event RandomBloodMinted(address user, uint256[] bloodIds);

    // Chainlink
    VRFCoordinatorV2Interface COORDINATOR;
    uint64 subscriptionId;
    address vrfCoordinator = 0x271682DEB8C4E0901D1a1550aD2e64D568E69909;
    bytes32 keyHash = 0x9fe0eebf5e446e3c998ec9bb19951541aee00bb90ea201ae456421a2ded86805;
    uint32 callbackGasLimit = 300000;
    uint16 requestConfirmations = 3;

    constructor(uint64 _subscriptionId, address _lootContract) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        owner = msg.sender;
        subscriptionId = _subscriptionId;
        lootContract = _lootContract;
        weaponToRarityChances[0] = [0, 530, 975, 1000]; // Raygun: 0, 530, 445, 25
        weaponToRarityChances[8] = [360, 910, 1000, 1000]; // Katana: 360, 550, 90, 0
        weaponToRarityChances[1] = [510, 950, 1000, 1000]; // Scroll: 510, 440, 50, 0
        weaponToRarityChances[2] = [660, 970, 1000, 1000]; // AR15: 660, 310, 30, 0
        weaponToRarityChances[9] = [660, 970, 1000, 1000]; // Moon Staff: 660, 310, 30, 0
        weaponToRarityChances[3] = [770, 990, 1000, 1000]; // Claws: 770, 220, 10, 0
    }

    function setLootContract(address _lootContract) public onlyOwner {
        lootContract = _lootContract;
    }

    function setSubscriptionId(uint64 _subscriptionId) public onlyOwner {
        subscriptionId = _subscriptionId;
    }

    function setCallbackGasLimit(uint32 _callbackGasLimit) public onlyOwner {
        callbackGasLimit = _callbackGasLimit;
    }

    function setRequestConfirmations(uint16 _requestConfirmations) public onlyOwner {
        requestConfirmations = _requestConfirmations;
    }

    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    function checkIsWeapon(uint256 weaponId) private pure {
        require(
            weaponId == 3 || weaponId == 2 || weaponId == 9 || weaponId == 8 || weaponId == 1 || weaponId == 0,
            "Item is not a Weapon!"
        );
    }

    function burnWeaponsForRandomBlood(
        uint256[] memory _weaponIds
    ) public payable {
        require(msg.value >= price, "Not enough ETH sent!");
        for (uint256 i = 0; i < _weaponIds.length; i++) {
            uint256 weaponId = _weaponIds[i];
            checkIsWeapon(weaponId);
            ILoot(lootContract).controlledBurn(msg.sender, weaponId, 1);
        }
        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            1
        );
        requests[requestId].weaponIds = _weaponIds;
        requests[requestId].sender = msg.sender;
    }

    function getBloodRarity(uint256 weaponId, uint256 randomNum) private view returns (uint256) {
        uint256[] memory rarities = weaponToRarityChances[weaponId];
        for (uint256 i = 0; i < rarities.length; i++) {
            if (randomNum < rarities[i]) {
                if (i == 0) {
                    return 7; // common blood (Almanazar)
                } else if (i == 1) {
                    return 6; // rare blood (Balthazar)
                } else if (i == 2) {
                    return 5; // epic blood (Nebuchadnezzar)
                } else if (i == 3) {
                    return 4; // legendary blood (Melchizedek)
                }
            }
        }
        return 7; // common blood (Almanazar)
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        uint256[] memory weaponIds = requests[requestId].weaponIds;
        uint256 randomNum = randomWords[0];
        uint256[] memory bloodIds = new uint256[](weaponIds.length);
        uint256[] memory amounts = new uint256[](weaponIds.length);
        for (uint256 i = 0; i < weaponIds.length; i++) {
            uint256 randomRarityChance = (randomNum % (1000 ** (i+1))) / (1000 ** i);
            uint256 bloodId = getBloodRarity(weaponIds[i], randomRarityChance);
            bloodIds[i] = bloodId;
            amounts[i] = 1;
        }
        ILoot(lootContract).mintBatch(requests[requestId].sender, bloodIds, amounts);
        emit RandomBloodMinted(requests[requestId].sender, bloodIds);
    }

    function burnWeaponsForBlood(uint256[] memory _weaponIds) public {
        uint256[] memory bloodIds = new uint256[](_weaponIds.length);
        uint256[] memory amounts = new uint256[](_weaponIds.length);
        for (uint256 i = 0; i < _weaponIds.length; i++) {
            uint256 weaponId = _weaponIds[i];
            checkIsWeapon(weaponId);
            ILoot(lootContract).controlledBurn(msg.sender, _weaponIds[i], 1);
            if (weaponId == 3 || weaponId == 2 || weaponId == 9) { // claw or AR15 or Moon Staff
                bloodIds[i] = 7; // small blood
            } else if (weaponId == 8 || weaponId == 1) { // Katana or Scroll
                bloodIds[i] = 6; // medium blood
            } else if (weaponId == 0) { // Raygun
                bloodIds[i] = 5; // large blood
            }
            amounts[i] = 1;
        }
        ILoot(lootContract).mintBatch(msg.sender, bloodIds, amounts);
    }

    function setOwner(address _owner) public onlyOwner {
        owner = _owner;
    }

    function withdrawEth() public onlyOwner {
        (bool sent,) = payable(owner).call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}