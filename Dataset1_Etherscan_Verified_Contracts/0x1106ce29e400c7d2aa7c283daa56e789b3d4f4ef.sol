// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TollBooth {
    address constant tollOperator = 0xc932b3a342658A2d3dF79E4661f29DfF6D7e93Ce;
    uint256 public tollAmount = 0.003 ether;
    mapping(address => uint64) public accessPass;

    function payToll(address payable tollGate) external payable {
        require(msg.value >= tollAmount, "Incorrect toll amount");
        tollGate.transfer(msg.value);
        accessPass[msg.sender] = uint64(block.timestamp + 1 hours);
    }

    function hasAccess(address traveler) external view returns (bool) {
        return block.timestamp <= accessPass[traveler];
    }

    function adjustToll(uint256 newAmount) external {
        require(msg.sender == tollOperator, "Not the toll operator");
        tollAmount = newAmount;
    }
}