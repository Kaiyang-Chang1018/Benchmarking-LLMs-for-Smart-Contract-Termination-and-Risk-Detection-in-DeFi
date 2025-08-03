pragma solidity ^0.8.13;

// src/DigitalTwinPaymentMetadata.sol

contract DigitalTwinPaymentMetadata {
    address public treasury1;
    uint256 public treasury1Perc;
    address public treasury2;
    uint256 public treasury2Perc;

    address public operator;

    event TransferIn(address indexed user, uint256 amount, string metadata);

    constructor(
        address treasury1_,
        uint256 treasury1Perc_,
        address treasury2_,
        uint256 treasury2Perc_
    ) {
        treasury1 = payable(treasury1_);
        treasury1Perc = treasury1Perc_;
        treasury2 = payable(treasury2_);
        treasury2Perc = treasury2Perc_;
        operator = msg.sender;
    }

    modifier isOperator() {
        require(msg.sender == operator, "Only operator");
        _;
    }

    function setOperator(address operator_) public isOperator {
        operator = operator_;
    }

    function setAddress(
        address treasury1_,
        address treasury2_
    ) public isOperator {
        treasury1 = payable(treasury1_);
        treasury2 = payable(treasury2_);
    }

    function setFees(
        uint256 treasury1Perc_,
        uint256 treasury2Perc_
    ) public isOperator {
        require(
            treasury1Perc_ + treasury2Perc_ == 100,
            "Total percent must be 100%"
        );
        treasury1Perc = treasury1Perc_;
        treasury2Perc = treasury2Perc_;
    }

    function pay(string memory metadata) public payable {
        uint256 amount = msg.value;
        uint256 treasury1Amount = (amount * treasury1Perc) / 100;
        uint256 treasury2Amount = amount - treasury1Amount;

        if (treasury1Amount > 0) {
            (bool successTreasury1, ) = treasury1.call{value: treasury1Amount}(
                ""
            );
            require(successTreasury1, "Treasury 1 fee transfer failed");
        }
        if (treasury2Perc > 0) {
            (bool successTreasury2, ) = treasury2.call{value: treasury2Amount}(
                ""
            );
            require(successTreasury2, "Treasury 2 fee transfer failed");
        }

        emit TransferIn(msg.sender, amount, metadata);
    }
    fallback() external payable {
        revert("no fallback");
    }
    receive() external payable {
        revert("no receive");
    }
}