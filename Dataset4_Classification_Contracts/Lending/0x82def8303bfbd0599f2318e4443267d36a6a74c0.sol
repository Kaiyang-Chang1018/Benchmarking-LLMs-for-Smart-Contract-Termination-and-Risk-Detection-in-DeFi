// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract AbiQuota {
    address public admin;
    IERC20 public token;
    mapping(address => uint256) public withdrawableAmounts;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can execute this");
        _;
    }

    constructor(address _tokenAddress) {
        admin = msg.sender;
        token = IERC20(_tokenAddress);
    }


    function depositTokens(uint256 amount) external onlyAdmin {
        require(token.transferFrom(msg.sender, address(this), amount), "Token transfer failed");

    }


    function allocateTokens(address member, uint256 amount) external onlyAdmin {

        withdrawableAmounts[member] = amount;

    }


    function viewWithdrawableAmount() external view returns (uint256) {
        return withdrawableAmounts[msg.sender];
    }


    function viewMemberWithdrawableAmount(address member) external view onlyAdmin returns (uint256) {
        return withdrawableAmounts[member];
    }


    function withdrawTokens(uint256 amount) external {
        require(withdrawableAmounts[msg.sender] >= amount, "Not enough withdrawable amount");
        require(token.transfer(msg.sender, amount), "Token transfer failed");
        withdrawableAmounts[msg.sender] -= amount;
    }


    function changeAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "New admin cannot be zero address");
        admin = newAdmin;
    }


    function updateTokenAddress(address _tokenAddress) external onlyAdmin {
        token = IERC20(_tokenAddress);
    }

    function rescueTokens(address tokenAddress, uint256 amount) external onlyAdmin {
        IERC20(tokenAddress).transfer(admin, amount);
    }
}