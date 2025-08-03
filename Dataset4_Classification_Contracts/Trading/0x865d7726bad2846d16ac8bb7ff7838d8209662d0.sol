// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// lib/openzeppelin-contracts/contracts/utils/Context.sol

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

// lib/openzeppelin-contracts/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

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

// src/PunterMarketRegistry.sol

// Import ownable

contract PunterMarketRegistry is Ownable {
    // Order accounts for byte packing to save gas
    struct Market {
        uint256 id;
        uint256 winningOptionIndex;
        uint256 endTimestamp;
        bool isActive;
        address creator;
        string metadata;
        string[] options;
        uint256[] votes;
    }

    struct Vote {
        uint256 marketId;
        uint256 voteId;
        uint256 optionIndex;
        uint256 voteAmount;
        address voter;
    }

    struct VoterProfile {
        address voter;
        uint256 totalVotes;
        uint256 totalEarnings;
    }

    Market[] public markets;
    Vote[] public votes;

    // Keep tracking of the voters and their earnings
    address[] public voters;
    mapping(address => uint256) public voterEarnings;
    mapping(address => uint256) public voterTotalEarnings;
    mapping(address => uint256) public voterTotalVotes;

    // Keep track of the unclaimed ETH for each user
    mapping(address => uint256) public unclaimedEth;

    // Keep track of earning referrals for each user
    mapping(address => uint256) public unclaimedReferralEarnings;
    mapping(address => uint256) public referralEarnings;

    // Keep track of referrals for each user
    mapping(address => address) public referredBy;

    // Keep track of referred users for each referrer
    mapping(address => address[]) public referredUsers;

    // Keep track of the earnings for each user
    mapping(address => uint256) public earnings;

    // Keep track of platform operators
    mapping(address => bool) public isOperator;

    // Keeep track of hasVoted per market
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    // Referral fee percentage
    uint256 public referrerFeePercentage = 1; // 5%
    uint256 public referrerFeeBase = 100;

    uint256 public platformFeePercentage = 3; // 3%
    uint256 public platformFeeBase = 100;

    address public platformFeeCollector = 0xd2291d26d8Dc1264DA75Aa3Ab7D29A6827348cA5;

    // Allow this contract to receive ETH
    receive() external payable {}

    constructor() {
        isOperator[msg.sender] = true;
        isOperator[0xd2291d26d8Dc1264DA75Aa3Ab7D29A6827348cA5] = true;
    }

    // Events
    event MarketCreated(uint256 marketId, address creator, string metadata, string[] options);
    event VoteCast(uint256 marketId, uint256 voteId, address voter, uint256 optionIndex, uint256 voteAmount);
    event MarketEnded(uint256 marketId, uint256 winningOptionIndex);
    event EthClaimed(address claimer, uint256 amount);
    event ReferrerFeeChanged(uint256 newReferrerFeePercentage);
    event ReferrerSet(address user, address referrer);
    event WinningsDistributed(address user, uint256 amount);
    event VoterProfileCreated(address voter, uint256 totalVotes, uint256 totalEarnings);
    event VoterProfileUpdated(address voter, uint256 totalVotes, uint256 totalEarnings);
    event ReferralDistributed(address referrer, uint256 amount);

    /**
     * Getter functions
     */
    function getMarkets() public view returns (Market[] memory) {
        return markets;
    }

    function getReferredUsers(address referrer) public view returns (address[] memory) {
        return referredUsers[referrer];
    }

    function getVoters() public view returns (VoterProfile[] memory) {
        VoterProfile[] memory voterProfiles = new VoterProfile[](voters.length);

        for (uint256 i = 0; i < voters.length; i++) {
            address voter = voters[i];
            voterProfiles[i] = VoterProfile({
                voter: voter,
                totalVotes: voterTotalVotes[voter],
                totalEarnings: voterTotalEarnings[voter]
            });
        }

        return voterProfiles;
    }

    function getVoter(address _voter) public view returns (VoterProfile memory) {
        // Build a VoterProfile object
        VoterProfile memory voterProfile = VoterProfile({
            voter: _voter,
            totalVotes: voterTotalVotes[_voter],
            totalEarnings: voterTotalEarnings[_voter]
        });

        return voterProfile;
    }

    function getVotesForMarket(uint256 marketId) public view returns (Vote[] memory) {
        Market storage market = markets[marketId];
        // Loop through all votes and return the ones that belong to this market
        Vote[] memory marketVotes = new Vote[](market.votes.length);

        for (uint256 i = 0; i < market.votes.length; i++) {
            marketVotes[i] = votes[market.votes[i]];
        }

        return marketVotes;
    }

    function _appendVoterProfileIfNotExists(address voter) private {
        bool exists = false;
        for (uint256 i = 0; i < voters.length; i++) {
            if (voters[i] == voter) {
                exists = true;
                break;
            }
        }

        if (!exists) {
            voters.push(voter);
            emit VoterProfileCreated(voter, 0, 0);
        }
    }

    function _increaseVoterEarnings(address voter, uint256 amount) private {
        _appendVoterProfileIfNotExists(voter);

        voterEarnings[voter] += amount;
        voterTotalEarnings[voter] += amount;

        emit VoterProfileUpdated(voter, voterTotalVotes[voter], voterTotalEarnings[voter]);
    }

    function _increaseVoterVotes(address voter, uint256 amount) private {
        _appendVoterProfileIfNotExists(voter);

        voterTotalVotes[voter] += amount;

        emit VoterProfileUpdated(voter, voterTotalVotes[voter], voterTotalEarnings[voter]);
    }

    function _handlePlatformFeeDistribution(address voter, uint256 amount)
        private
        returns (uint256 _remainingVoteAmount)
    {
        uint256 voteAmount = amount;

        // Calculate the platform fee from the amount
        uint256 platformFee = (voteAmount * platformFeePercentage) / platformFeeBase;
        uint256 referralFee = 0;

        address isReferredBy = referredBy[voter];
        if (isReferredBy != address(0)) {
            referralFee = (voteAmount * referrerFeePercentage) / referrerFeeBase;
        }

        // If referralFee is positive, rdeduct it from the platform fee
        if (referralFee > 0) {
            platformFee -= referralFee;
            unclaimedReferralEarnings[isReferredBy] += referralFee;
            emit ReferralDistributed(isReferredBy, referralFee);
        }

        // Distribute the platform fee to the platform using .call
        (bool success,) = platformFeeCollector.call{value: platformFee}("");
        require(success, "Platform fee transfer");

        // Calculate the remaining vote amount after deducting the platform fee
        _remainingVoteAmount = voteAmount - platformFee - referralFee;

        return _remainingVoteAmount;
    }

    /**
     * Referrals
     */
    function setReferredBy(address referrer) public {
        // Only allow once
        require(referredBy[msg.sender] == address(0), "Referrer already set");
        referredBy[msg.sender] = referrer;
        referredUsers[referrer].push(msg.sender);

        // Emit event
        emit ReferrerSet(msg.sender, referrer);
    }

    function changeReferrerFeePercentage(uint256 newReferrerFeePercentage) public onlyOwner {
        referrerFeePercentage = newReferrerFeePercentage;

        // Emit event
        emit ReferrerFeeChanged(newReferrerFeePercentage);
    }

    function changeOperator(address operator, bool status) public onlyOwner {
        isOperator[operator] = status;
    }

    function setPlatformFeeCollector(address _platformFeeCollector) public onlyOwner {
        platformFeeCollector = _platformFeeCollector;
    }

    /**
     * Market functions
     */
    function createMarket(string memory metadata, string[] memory options, uint256 endTimestamp) public {
        uint256 _newMarketId = markets.length;

        Market memory market = Market({
            id: _newMarketId,
            creator: msg.sender,
            endTimestamp: endTimestamp,
            metadata: metadata,
            options: options,
            votes: new uint256[](0),
            winningOptionIndex: 0,
            isActive: true
        });

        markets.push(market);

        // Emit event
        emit MarketCreated(_newMarketId, msg.sender, metadata, options);
    }

    function voteInMarket(uint256 marketId, uint256 optionIndex, address referree) public payable {
        Market storage market = markets[marketId];

        if (referree != address(0) && referredBy[msg.sender] == address(0)) {
            setReferredBy(referree);
        }

        _increaseVoterVotes(msg.sender, 1);

        require(market.isActive, "Market is not active");
        require(optionIndex < market.options.length, "Invalid option index");

        // Check if market has not expired
        require(block.timestamp < market.endTimestamp, "Market has expired");

        // Check if the user has voted before in this market or not
        require(!hasVoted[marketId][msg.sender], "User has already voted");
        hasVoted[marketId][msg.sender] = true;

        // Transfer the ETH to the contract using call
        (bool success,) = address(this).call{value: msg.value}("");
        require(success, "Transfer failed");

        uint256 _newVoteId = votes.length;
        uint256 voteAmount = msg.value;

        voteAmount = _handlePlatformFeeDistribution(msg.sender, voteAmount);

        Vote memory vote = Vote({
            voteId: _newVoteId,
            marketId: marketId,
            optionIndex: optionIndex,
            voter: msg.sender,
            voteAmount: voteAmount
        });

        votes.push(vote);
        market.votes.push(_newVoteId);

        // Emit event
        emit VoteCast(marketId, _newVoteId, msg.sender, optionIndex, msg.value);
    }

    function endMarket(uint256 marketId, uint256 winningOptionIndex) public onlyOwner {
        Market storage market = markets[marketId];

        require(market.isActive, "Market is not active");

        market.isActive = false;
        market.winningOptionIndex = winningOptionIndex;

        // Ensure there are votes in the market
        require(market.votes.length > 0, "No votes in the market");

        // Calculate the total amount to distribute to the winners by summing up all the votes of the losing options
        uint256 totalLosingVotesAmount = 0;
        uint256 totalWinningVotesAmount = 0;

        for (uint256 i = 0; i < market.votes.length; i++) {
            Vote memory vote = votes[market.votes[i]];

            if (vote.optionIndex != winningOptionIndex) {
                // Vote is on the losing option
                totalLosingVotesAmount += vote.voteAmount;
            } else {
                // Vote is on the winning option
                totalWinningVotesAmount += vote.voteAmount;

                // Refund the original vote amount to the user
                unclaimedEth[vote.voter] += vote.voteAmount;
            }
        }

        if (totalWinningVotesAmount == 0) {
            // No winning votes
            emit MarketEnded(marketId, winningOptionIndex);

            // Send all the losing votes to the platform fee using call
            (bool success,) = platformFeeCollector.call{value: totalLosingVotesAmount}("");
            require(success, "Transfer failed");

            return;
        } else {
            // Need to run for loop again to correctly distribute winnings
            for (uint256 i = 0; i < market.votes.length; i++) {
                Vote memory vote = votes[market.votes[i]];

                if (vote.optionIndex == winningOptionIndex) {
                    // Winner Vote - Calculate the proportional amount to distribute to this winner
                    uint256 amountToDistribute = (vote.voteAmount * totalLosingVotesAmount) / totalWinningVotesAmount;

                    unclaimedEth[vote.voter] += amountToDistribute;

                    // Update the voter profile
                    _increaseVoterEarnings(vote.voter, amountToDistribute);

                    // Emit event
                    emit WinningsDistributed(vote.voter, amountToDistribute);
                }
            }

            // Emit event
            emit MarketEnded(marketId, winningOptionIndex);
        }
    }

    function claimEth() public {
        uint256 amount = unclaimedEth[msg.sender];
        unclaimedEth[msg.sender] = 0;

        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        // Emit event
        emit EthClaimed(msg.sender, amount);
    }

    function claimReferralEarnings() public {
        uint256 amount = unclaimedReferralEarnings[msg.sender];
        unclaimedReferralEarnings[msg.sender] = 0;
        referralEarnings[msg.sender] += amount;

        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        // Emit event
        emit EthClaimed(msg.sender, amount);
    }
}