pragma solidity ^0.8.0;

interface ITokenGiver {
    function GetFreeTokens() external;
}

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract MyContract {
    address private constant TARGET_CONTRACT = 0x93715112138dD0265a3888eb7458BB7BF3fF7C3e;

    function go(uint times) public {
        for(uint i = 0; i < times; i++) {
            ITokenGiver(TARGET_CONTRACT).GetFreeTokens();
            uint256 balance = IERC20(TARGET_CONTRACT).balanceOf(address(this));
            require(IERC20(TARGET_CONTRACT).transfer(msg.sender, balance), "Transfer failed");
        }
    }
}