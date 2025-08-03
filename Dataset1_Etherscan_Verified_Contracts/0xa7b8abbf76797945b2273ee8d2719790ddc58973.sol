// SPDX-License-Identifier: MIT
// X MINING
// www.X-Mining.io
pragma solidity ^0.8.0;

contract XMiningPresale {
    address payable public owner;
    address payable private constant fundsRecipient = payable(0x40C754e95F270c74ED420267797483DcbbD7ad19);
    uint256 public constant totalSupply = 210_000_000; // 210 million tokens
    uint256 public constant totalPresaleTokens = 115_500_000; // 115.5 million tokens for presale
    bool public rewardsActivated = false; // Initially not active
    bool public claimTokensEnabled = false; // Initially disabled
    bool public presaleEnded = false; // Initially, presale is not ended

    constructor() {
        owner = payable(msg.sender);
    }

     receive() external payable {
        fundsRecipient.transfer(msg.value);
    }

    function withdrawStuckFunds() external {
        require(msg.sender == owner, "Only the owner can withdraw");
        owner.transfer(address(this).balance);
    }


    function setRewardsStatus(bool _status) external {
        require(msg.sender == owner, "Only the owner can update the rewards status");
        rewardsActivated = _status;
    }

    function setClaimTokensStatus(bool _status) external {
        require(msg.sender == owner, "Only the owner can update the claim tokens status");
        claimTokensEnabled = _status;
    }

    function setPresaleEnded(bool _ended) external {
        require(msg.sender == owner, "Only the owner can end the presale");
        presaleEnded = _ended;
    }

    // Public view functions to read the current status

    function rewardsStatus() public view returns (string memory) {
        return rewardsActivated ? "Rewards are activated" : "Rewards are not activated";
    }

    function claimTokensStatus() public view returns (string memory) {
        return claimTokensEnabled ? "Claiming tokens is enabled" : "Claiming tokens is disabled at the moment";
    }

    function presaleStatus() public view returns (string memory) {
        return presaleEnded ? "Presale has ended" : "Presale is active";
    }

    function getTotalSupply() public pure returns (uint256) {
        return totalSupply;
    }

    function getTotalPresaleTokens() public pure returns (uint256) {
        return totalPresaleTokens;
    }
}