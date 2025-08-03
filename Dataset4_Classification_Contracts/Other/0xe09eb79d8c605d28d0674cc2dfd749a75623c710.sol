// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;

contract SpeakMyWord {

    event MyWord(string word);

    function myWord(string memory _word) public {
        emit MyWord(_word);
    }

}