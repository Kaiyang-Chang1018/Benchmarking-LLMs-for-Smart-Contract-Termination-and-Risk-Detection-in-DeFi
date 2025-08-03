// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract CoinFlip {
    address public deployer;
    IERC20 public token;
    uint256 public betAmount;
    address public constant burnAddress = 0x000000000000000000000000000000000000dEaD;

    address[2] private players;
    uint256 private index = 0;
    uint256 private blockNumber;
    uint256 private numberOfBlocks = 3;  // Number of future blocks to consider

    event GameStarted(address player1, address player2);
    event GameResult(address participant, bool isWinner);
    event ParticipantJoined(address participant);
    event WaitingForParticipant();

    constructor(address _tokenAddress, uint256 _betAmount) {
        deployer = msg.sender;
        token = IERC20(_tokenAddress);
        betAmount = _betAmount;
    }

    function setBetAmount(uint256 _newBetAmount) public {
        require(msg.sender == deployer, "Only deployer can set the bet amount");
        betAmount = _newBetAmount;
    }

    function joinGame() public {
        require(index < 2, "Game is already full");
        require(token.balanceOf(msg.sender) >= betAmount, "Insufficient token balance");
        require(token.transferFrom(msg.sender, address(this), betAmount), "Transfer failed");
        
        players[index] = msg.sender;
        if (index == 0) blockNumber = block.number + numberOfBlocks; // Store future block number when first player joins
        index++;

        if (index == 2) {
            emit GameStarted(players[0], players[1]);
            // Check that enough blocks have passed
            require(block.number > blockNumber, "Not enough blocks have passed to ensure randomness");
            executeGame();
            index = 0; // Reset for the next game
        } else {
            emit WaitingForParticipant();
            emit ParticipantJoined(msg.sender);
        }
    }

    function executeGame() private {
        uint256 combinedBlockHash = uint256(keccak256(abi.encodePacked(
            blockhash(blockNumber-1),
            blockhash(blockNumber-2),
            blockhash(blockNumber-3)
        )));
        address winner = (combinedBlockHash % 2 == 0) ? players[0] : players[1];

        uint256 rewardAmount = betAmount * 18 / 10;
        uint256 deployerFee = betAmount / 10;
        uint256 burnFee = betAmount / 10;

        // Transfer rewards and fees
        token.transfer(winner, rewardAmount);
        token.transfer(deployer, deployerFee);
        token.transfer(burnAddress, burnFee);

        // Emit GameResult event for both participants
        emit GameResult(players[0], players[0] == winner);
        emit GameResult(players[1], players[1] == winner);
    }
}