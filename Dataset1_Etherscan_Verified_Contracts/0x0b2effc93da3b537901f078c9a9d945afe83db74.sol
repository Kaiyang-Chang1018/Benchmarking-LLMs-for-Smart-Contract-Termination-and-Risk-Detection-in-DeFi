// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;

contract HowMuchYouLoveBlockchain {

    event HowMuchYouLoveBlockChain(uint8 ANumberFrom_0_to_255);

    function howMuchYouLoveBlockChain(uint8 _ANumberFrom_0_to_255) public {
        emit HowMuchYouLoveBlockChain(_ANumberFrom_0_to_255);
    }

}