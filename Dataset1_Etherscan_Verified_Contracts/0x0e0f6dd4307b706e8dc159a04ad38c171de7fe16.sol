// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
}

contract RewardDistributor {
    address public owner;
    IERC20 public token;
    uint8 public tokenDecimals;
    uint256 public scalingFactor;

    struct Distribution {
        address recipient;
        uint32 amount;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event TokensDistributed(address indexed recipient, uint32 amount);

    constructor(address _tokenAddress, address _ownerAddress) {
        require(_ownerAddress != address(0), "Token address cannot be zero address");
        require(_tokenAddress != address(0), "Token address cannot be zero address");
        owner = _ownerAddress;
        token = IERC20(_tokenAddress);
        tokenDecimals = token.decimals();
        scalingFactor = 10 ** uint256(tokenDecimals);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    /// @notice Transfers the ownership of the contract to a new owner
    /// @param newOwner The address of the new owner
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner cannot be the zero address");
         owner = newOwner;
    }

    /// @notice Distributes tokens to a list of recipients
    /// @param distributions An array of Distribution structs containing recipient addresses and amounts
    function distributeTokens(Distribution[] calldata distributions) external onlyOwner {
        for (uint256 i = 0; i < distributions.length; i++) {
            address recipient = distributions[i].recipient;
            uint32 amount = distributions[i].amount;

            require(recipient != address(0), "Recipient cannot be zero address");
            require(amount > 0, "Amount must be greater than zero");

            uint256 amountInBaseUnits = uint256(amount) * scalingFactor;

            // Check-Effects-Interactions pattern
            bool success = token.transferFrom(msg.sender, recipient, amountInBaseUnits);
            require(success, "Transfer failed");
        }
    }
}