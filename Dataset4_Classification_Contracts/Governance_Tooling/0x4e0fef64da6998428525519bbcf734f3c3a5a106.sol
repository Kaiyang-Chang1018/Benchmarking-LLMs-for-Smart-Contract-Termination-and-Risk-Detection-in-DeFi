//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;


/**
 * @title Owner
 * @dev Set & change owner
 */
contract Ownable {

    address private owner;
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier onlyOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public onlyOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}

interface IGenerator {
    function create(
        address nft_,
        address rewardToken_,
        uint256 lockTime_,
        uint256 rewardsPerSecond_,
        string calldata name_,
        string calldata symbol_,
        address lockTimeSetter_
    ) external returns (address);
}

/**
    Have a toggle for NFT baggage claim Contracts to hide from the front end
 */
contract PartnerApplication is Ownable {

    // application fee
    uint256 public applicationFee;

    // Partner Data Struct
    struct PartnerData {
        string socialLink;
        string description;
        uint256 fee;
        address requester;
        bool isAccepted;
        bool isInApplicationPhase;
    }

    // Partner Struct
    struct Partner {        
        address nft;
        string nftName;
        string nftSymbol;
        address rewardToken;
        uint256 lockTime;
        uint256 rewardsPerSecond;
        address nftOwner;
    }

    // Maps a partnerNonce to a Partner Struct
    mapping ( uint256 => Partner ) public partners;

    // Maps a partnerNonce to a Partner Struct
    mapping ( uint256 => PartnerData ) public partnerData;

    // Partner Nonce
    uint256 public partnerNonce;

    // NFT Generator
    address public generator;

    constructor(
        address generator_
    ) {
        generator = generator_;
    }

    function accept(uint256 partnerId) external onlyOwner returns(address newBaggageClaim) {
        require(
            partnerId < partnerNonce,
            'Invalid ID'
        );
        require(
            partnerData[partnerId].isInApplicationPhase == true &&
            partnerData[partnerId].isAccepted == false,
            'Parnter Already Accepted'
        );

        // delete application phase
        delete partnerData[partnerId].isInApplicationPhase;

        // set to be accepted
        partnerData[partnerId].isAccepted = true;

        // send value to owner
        _send(this.getOwner(), partnerData[partnerId].fee);

        // create nft baggage claim contract
        newBaggageClaim = IGenerator(generator).create(
            partners[partnerId].nft,
            partners[partnerId].rewardToken,
            partners[partnerId].lockTime,
            partners[partnerId].rewardsPerSecond,
            partners[partnerId].nftName,
            partners[partnerId].nftSymbol,
            partners[partnerId].nftOwner
        );
    }

    function reject(uint256 partnerId) external onlyOwner {
        require(
            partnerId < partnerNonce,
            'Invalid ID'
        );
        require(
            partnerData[partnerId].isInApplicationPhase == true,
            'Parnter Already Rejected'
        );

        // delete application phase
        delete partnerData[partnerId].isInApplicationPhase;

        // send value to initial requester
        _send(partnerData[partnerId].requester, partnerData[partnerId].fee);
    }

    function setGenerator(address generator_) external onlyOwner {
        generator = generator_;
    }

    function setApplicationFee(uint256 newFee) external onlyOwner {
        applicationFee = newFee;
    }

    /**
        strings = [nftName, nftSymbol, socialLink, description]
    */
    function Apply(
        string[] calldata strings,
        address rewardToken_,
        address nft_,
        uint256 lockTime,
        uint256 rewardsPerDay_,
        address ownerOfBaggageClaimPool
    ) external payable {
        require(
            msg.value >= applicationFee,
            'Insufficient Value Sent'
        );
        require(
            nft_ != address(0), 'Zero Address'
        );
        require(
            rewardsPerDay_ >= 1 days,
            'Unit Too Small'
        );

        partners[partnerNonce] = Partner({
            nft: nft_,
            nftName: strings[0],
            nftSymbol: strings[1],
            rewardToken: rewardToken_,
            lockTime: lockTime,
            rewardsPerSecond: rewardsPerDay_ / 1 days,
            nftOwner: ownerOfBaggageClaimPool
        });

        partnerData[partnerNonce] = PartnerData({
            socialLink: strings[2],
            description: strings[3],
            fee: msg.value,
            requester: msg.sender,
            isAccepted: false,
            isInApplicationPhase: true
        });

        unchecked {
            ++partnerNonce;
        }
    }

    function _send(address to, uint256 fee) internal {
        if (fee > address(this).balance) {
            fee = address(this).balance;
        }
        if (fee == 0) {
            return;
        }
        (bool s,) = payable(to).call{value: fee}("");
        require(s, 'Failure To Send Fee');
    }
}