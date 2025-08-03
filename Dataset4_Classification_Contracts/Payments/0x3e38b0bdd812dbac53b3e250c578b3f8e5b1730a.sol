// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Airdrop {
    address public owner;
    IERC20 public token;
    mapping(address => uint256) public airdrops;

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor(address _token) {
        owner = msg.sender;
        token = IERC20(_token);
    }

    function setAirdrops(address[] calldata _recipients, uint256[] calldata _amounts) external onlyOwner {
        require(_recipients.length == _amounts.length, "Arrays must be of equal length");
        for (uint256 i = 0; i < _recipients.length; i++) {
            airdrops[_recipients[i]] = _amounts[i];
        }
    }

    function claim() external {
        uint256 amount = airdrops[msg.sender];
        require(amount > 0, "No airdrop amount set for caller");
        airdrops[msg.sender] = 0;
        require(token.transfer(msg.sender, amount), "Token transfer failed");
    }

    function recoverERC20(address _tokenContract) external onlyOwner {
        IERC20 tokenContract = IERC20(_tokenContract);
        uint256 balance = tokenContract.balanceOf(address(this));
        require(tokenContract.transfer(owner, balance), "Recover token failed");
    }

    // New function to view a wallet's airdrop amount
    function viewAirdropAmount(address _wallet) external view returns (uint256) {
        return airdrops[_wallet];
    }
}