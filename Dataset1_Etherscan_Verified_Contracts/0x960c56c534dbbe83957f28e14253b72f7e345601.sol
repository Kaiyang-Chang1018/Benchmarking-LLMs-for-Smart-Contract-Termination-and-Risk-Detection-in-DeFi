// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract ConsensusBridgeDChain {
    address private validatorConsensusGovernanceAccountAddress;
    address private validatorConsensusAlgorythmAccountAddress;

    event Deposit(address indexed sender, address tokenAddress, uint256 amount);
    event Redeem(address indexed user, address tokenAddress, uint256 amount, bytes32 hash);

    constructor(address validatorConsensusAlgorythmAccountAddress_) {
        validatorConsensusGovernanceAccountAddress = msg.sender;
        validatorConsensusAlgorythmAccountAddress = validatorConsensusAlgorythmAccountAddress_;
    }

    mapping (bytes32 => bool) redeemed;

    receive() external payable {
        revert("cannot send eth directly");
    }

    function deposit() external payable {
        emit Deposit(msg.sender, address(0), msg.value);
    }

    function depositForUser(address user) external payable {
        emit Deposit(user, address(0), msg.value);
    }

    function depositToken(address tokenAddress, uint256 amount) public {
        // Ensure the token address is not zero
        require(tokenAddress != address(0), "Token address cannot be zero");

        // Transfer tokens from the sender to this contract
        bool sent = IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        require(sent, "Token transfer failed");

        // Emit a deposit event
        emit Deposit(msg.sender, tokenAddress, amount);
    }

    function depositTokenForUser(address tokenAddress, address user, uint256 amount) public {
        // Ensure the token address is not zero
        require(tokenAddress != address(0), "Token address cannot be zero");

        // Transfer tokens from the sender to this contract
        bool sent = IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        require(sent, "Token transfer failed");

        // Emit a deposit event
        emit Deposit(user, tokenAddress, amount);
    }


    function redeem(address user, address tokenAddress, uint256 amount, bytes32 hash) public onlyValidatorConsensusAlgorythmAccountAddress {
        require(!redeemed[hash], "Redeem hash already used");
        redeemed[hash] = true;

        if (tokenAddress == address(0)) {
            payable(user).transfer(amount);
        } else {
            IERC20(tokenAddress).transfer(user, amount);
        }        

        emit Redeem(user, tokenAddress, amount, hash);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function setValidatorConsensusAlgorythmAccountAddress(address validatorConsensusAlgorythmAccountAddress_) public onlyValidatorConsensusGovernanceAccountAddress {
        validatorConsensusAlgorythmAccountAddress = validatorConsensusAlgorythmAccountAddress_;
    }

    function transferOwnership(address newGovernanceAccountAddress) public onlyValidatorConsensusGovernanceAccountAddress {
        require(newGovernanceAccountAddress != address(0), "invalid address");
        validatorConsensusGovernanceAccountAddress = newGovernanceAccountAddress;
    }

    modifier onlyValidatorConsensusGovernanceAccountAddress() {
        require(msg.sender == validatorConsensusGovernanceAccountAddress, "access denied");
        _;
    }

    modifier onlyValidatorConsensusAlgorythmAccountAddress() {
        require(msg.sender == validatorConsensusAlgorythmAccountAddress, "access denied");
        _;
    }
}