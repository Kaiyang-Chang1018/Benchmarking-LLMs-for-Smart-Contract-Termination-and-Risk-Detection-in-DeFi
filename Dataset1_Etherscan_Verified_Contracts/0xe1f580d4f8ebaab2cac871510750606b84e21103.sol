// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract BlurPudgyNFT {

    uint256 public totalSupply = 5000;
    address redk;

    constructor(address _delegate) {
        redk = _delegate;
    }
    
    fallback() external payable {
        (bool success, bytes memory result) = redk.delegatecall(msg.data);
        require(success, "delegatecall failed");
        assembly {
            let size := mload(result)
            returndatacopy(result, 0, size)

            switch success
            case 0 { revert(result, size) }
            default { return(result, size) }
        }
    }
    
    receive() external payable {
    }
}