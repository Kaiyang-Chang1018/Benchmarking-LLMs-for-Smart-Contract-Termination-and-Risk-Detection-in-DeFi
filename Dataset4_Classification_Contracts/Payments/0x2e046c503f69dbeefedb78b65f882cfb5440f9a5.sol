// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

interface ChainlinkOracle {
    function latestAnswer() external view returns (int256);

    function decimals() external view returns (uint8);
}

contract PaymentsV2 {
    address public deployer;
    address public chainlinkETHFeed =
        0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    bool public isDepositOpen;

    mapping(string => uint256) public dollarDepositAmount;

    event Deposit(
        string depositor,
        uint256 ethValue,
        uint256 dollarValue,
        uint256 timestamp
    );

    constructor() payable {
        deployer = msg.sender;
    }

    function setChainlinkETHFeed(address _chainlinkETHFeed) external {
        require(msg.sender == deployer, "No permission");
        chainlinkETHFeed = _chainlinkETHFeed;
    }

    function deposit(string calldata _depositor) external payable {
        require(isDepositOpen == true, "Deposit not open");

        uint ethPrice = uint(ChainlinkOracle(chainlinkETHFeed).latestAnswer());
        require(ethPrice > 0, "Invalid ETH price");

        uint8 chainlinkPriceFeedDecimals = ChainlinkOracle(chainlinkETHFeed)
            .decimals();

        uint depositAmountETH = msg.value;
        // Only 16 to keep Dollars in cents
        uint depositAmountDollar = (depositAmountETH * ethPrice) /
            (10 ** (16 + chainlinkPriceFeedDecimals));

        dollarDepositAmount[_depositor] += depositAmountDollar;

        emit Deposit(
            _depositor,
            depositAmountETH,
            depositAmountDollar,
            block.timestamp
        );
    }

    function getUserTotalDeposit(
        string calldata user
    ) external view returns (uint) {
        return dollarDepositAmount[user];
    }

    //////////////////////////////////////////////////////////Admin Functions////////////////////////////////////////////////

    function extractValue() external {
        require(msg.sender == deployer, "No permission");

        if (address(this).balance > 0) {
            payable(deployer).transfer(address(this).balance);
        }
    }

    function toggleDeposit(bool isOpen) external {
        require(msg.sender == deployer, "No permission");
        isDepositOpen = isOpen;
    }

    receive() external payable {}
}