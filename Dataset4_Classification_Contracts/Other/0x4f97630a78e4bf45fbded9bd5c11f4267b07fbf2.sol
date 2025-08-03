pragma solidity ^0.5.10;

contract THBN {

    function hellowolrd() external pure returns(string memory) {
        return "hellowolrd";
    }

    function release() external {
        selfdestruct((msg.sender));
    } 
    
}