// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract AngelBoost is Ownable {
    event Launch(uint256 indexed id, address indexed creator, uint256 goal, uint256 startAt, uint256 endAt);
    event Pledge(uint256 indexed id, address indexed caller, uint256 amount);
    event Claim(uint256 indexed id);
    event Refund(uint256 indexed id, address indexed caller, uint256 amount);
    event TransferCampaign(uint256 indexed id, address indexed caller, address indexed newCreator);

    struct Campaign {
        // Creator of campaign
        address creator;
        // Amount of tokens to raise
        uint256 goal;
        // Total amount pledged
        uint256 pledged;
        // Total amount refunded
        uint256 refunded;
        // Timestamp of start of campaign
        uint256 startAt;
        // Timestamp of end of campaign
        uint256 endAt;
        // True if goal was reached and creator has claimed the tokens.
        bool claimed;
    }

    // Total count of campaigns created. It is also used to generate id for new campaigns.
    uint256 public count;
    // Total money raised
    uint256 public globalMoneyCount;
    // Total number of contributions
    uint256 public globalContributionCount;
    // Mapping from id to Campaign
    mapping(uint256 => Campaign) public campaigns;
    // Mapping from campaign id => pledger => amount pledged
    mapping(uint256 => mapping(address => uint256)) public pledgedAmount;
    // Campaign max duration
    uint256 public campaignMaxDuration = 365 days;
    // Campaign claim fee & max fee
    uint256 public claimFee = 500; // 5.00 %
    uint256 public maxFee = 1000; // 10.00 %
    // Campaign claim limit
    uint256 public claimLimit = 90 days;
    // Campaign launch fee
    uint256 public launchFee = 0.003 ether;

    constructor() {}

    modifier onlyCreator(uint256 _id) {
        Campaign memory campaign = campaigns[_id];
        require(
            campaign.creator == _msgSender(),
            "Can't perform this action, sender is not the owner of the Campaign."
        );
        _;
    }

    function launch(uint256 _goal,uint256 _startAt,uint256 _endAt) external payable {
        if (_startAt < block.timestamp) _startAt = block.timestamp;

        require(
            _endAt >= _startAt,
            "Error: end date needs to be grater than start date."
        );
        require(
            _endAt - _startAt <= campaignMaxDuration,
            "Error: campaign can't last more than 1 year"
        );

        if (_msgSender() != owner()) {
            require(
                msg.value >= launchFee,
                "Error: Lauch fee not payed. Send more ETH"
            );
        }

        count += 1;
        campaigns[count] = Campaign({
            creator: _msgSender(),
            goal: _goal,
            pledged: 0,
            refunded: 0,
            startAt: _startAt,
            endAt: _endAt,
            claimed: false
        });

        sendValue(payable(owner()), msg.value);

        emit Launch(count, _msgSender(), _goal, _startAt, _endAt);
    }

    function transferCampaign(uint256 _id, address _newCreator) external onlyCreator(_id) {
        Campaign memory campaign = campaigns[_id];
        campaign.creator = _newCreator;

        emit TransferCampaign(_id, _msgSender(), _newCreator);
    }

    function pledge(uint256 _id) external payable {
        uint256 _amount = msg.value;
        Campaign storage campaign = campaigns[_id];
        require(
            block.timestamp >= campaign.startAt,
            "Error: campaign is not started yet."
        );
        require(
            block.timestamp <= campaign.endAt,
            "Error: campaign is already ended."
        );

        campaign.pledged += _amount;
        pledgedAmount[_id][_msgSender()] += _amount;

        globalContributionCount += 1;

        emit Pledge(_id, _msgSender(), _amount);
    }

    function claim(uint256 _id) external onlyCreator(_id) {
        Campaign storage campaign = campaigns[_id];
        require(
            block.timestamp > campaign.endAt,
            "Error: campaign is not ended yet."
        );
        require(
            campaign.pledged >= campaign.goal,
            "Error: pledged amout didn't reach the campaign goal."
        );
        require(!campaign.claimed, "Error: already claimed.");

        campaign.claimed = true;

        uint256 campaignFee = (campaign.pledged * claimFee) / 10000;
        uint256 creatorAmount = campaign.pledged - campaignFee;

        sendValue(payable(owner()), campaignFee);
        sendValue(payable(campaign.creator), creatorAmount);

        globalMoneyCount += campaign.pledged;

        emit Claim(_id);
    }

    function refund(uint256 _id) external {
        Campaign memory campaign = campaigns[_id];
        require(
            block.timestamp > campaign.endAt,
            "Error: campaing didn't end yet."
        );
        require(
            campaign.pledged < campaign.goal,
            "Error: campaign reached the goal."
        );
        require(!campaign.claimed, "Error: campaign already claimed.");

        uint256 bal = pledgedAmount[_id][_msgSender()];
        pledgedAmount[_id][_msgSender()] = 0;

        campaign.refunded += bal;

        sendValue(payable(_msgSender()), bal);

        emit Refund(_id, _msgSender(), bal);
    }

    function adminClaim(uint256 _id) external onlyOwner {
        Campaign storage campaign = campaigns[_id];
        require(
            block.timestamp > campaign.endAt + claimLimit,
            "Error: claim limit is not reached yet."
        );
        require(!campaign.claimed, "Error: already claimed.");

        campaign.claimed = true;

        sendValue(
            payable(owner()),
            campaign.pledged - campaign.refunded
        );
    }

    function setFee(uint256 _fee, uint256 _launchFee) external onlyOwner {
        require(_fee <= maxFee, "Error: fee can't go over the fee limit.");

        claimFee = _fee;
        launchFee = _launchFee;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}
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