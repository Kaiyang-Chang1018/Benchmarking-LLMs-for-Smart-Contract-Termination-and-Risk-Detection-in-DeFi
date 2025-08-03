// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

interface IETHC {
    function revealSelectedMiner(uint256 targetBlock) external;
    function blockNumber() external view returns (uint256);
}


contract ETHCHelper {

    IETHC public ETHC;

    constructor(address token_address) {
        ETHC = IETHC(token_address);
    }

    function bulkRevealSelectedMiner(uint256[] memory blockNumbers) external {
        uint256 currentBlockNumber = ETHC.blockNumber();
        for (uint256 i=0; i<blockNumbers.length; i++) {
            if (blockNumbers[i] == currentBlockNumber) {
                continue;
            }

            ETHC.revealSelectedMiner(blockNumbers[i]);
        }
    }

    function bulkRevealSelectedMinerSince(uint256 startingBlockNumber) external {
        uint256 currentBlockNumber = ETHC.blockNumber();
        for (uint256 blockNumber=startingBlockNumber; blockNumber<currentBlockNumber; blockNumber++) {
            ETHC.revealSelectedMiner(blockNumber);
        }
    }
}