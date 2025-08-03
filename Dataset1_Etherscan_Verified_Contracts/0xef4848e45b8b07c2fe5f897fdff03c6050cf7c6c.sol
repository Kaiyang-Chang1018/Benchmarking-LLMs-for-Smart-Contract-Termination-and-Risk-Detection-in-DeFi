//SPDX-License-Identifier: MIT


 
interface IERC20 {
 
    function totalSupply() external view returns (uint256);
 
    function balanceOf(address account) external view returns (uint256);
 
    function transfer(address recipient, uint256 amount) external returns (bool);
 
    function allowance(address owner, address spender) external view returns (uint256);
 
    function approve(address spender, uint256 amount) external returns (bool);
 
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
 
    event Transfer(address indexed from, address indexed to, uint256 value);
 
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        (bool success, ) = address(token).call(abi.encodeWithSignature('transfer(address,uint256)',  to, value));
        require(success, 'Token payment failed');
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        (bool success, ) = address(token).call(abi.encodeWithSignature('transferFrom(address,address,uint256)', from, to, value));
        require(success, 'Token payment failed');
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require(token.approve(spender, value), "SafeERC20: approve failed");
    }
}


pragma solidity 0.8.9;


/**
 * @dev Collection of functions related to the address type
 */

contract FPSStrikeContract {
    
    using SafeERC20 for IERC20;

    address public TokenAdr = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public ceoAddress = 0xfc7306F82B701bE09Cf7fe547D05301bEB624e12;
    address public smartContractAddress;

    mapping(address => uint256) public playerToken;
    
    modifier onlyCeo() {
        require(msg.sender == ceoAddress, "Error: Caller Must be Ownable!!");
        _;
    }
 
    constructor() {
        smartContractAddress = address(this); 
    }
   
    function depositToken(uint256 amount) public  {   
        IERC20(TokenAdr).safeTransferFrom(msg.sender, smartContractAddress, amount);
    }

    function withdrawToken(uint256 amount) public {
        require(
            playerToken[msg.sender] >= amount,
            "Cannot Withdraw more then your Balance!"
        );

        address account = msg.sender;

        IERC20(TokenAdr).safeTransfer(account, amount);

        playerToken[msg.sender] = 0;
    }

    function setToken(address _adr, uint256 amount) public onlyCeo() {
        playerToken[_adr] = amount;
    }

    function changeSmartContract(address smartContract) public onlyCeo() {
        smartContractAddress = smartContract;
    }

    function changeCeo(address _adr) public onlyCeo() {
        ceoAddress = _adr;
    }

  function emergencyWithdrawToken(address _adr) public onlyCeo() {
        uint256 bal = IERC20(_adr).balanceOf(address(this));
        IERC20(_adr).safeTransfer(msg.sender, bal);
    }

    function emergencyWithdrawETH() public onlyCeo() {
        (bool os, ) = payable(msg.sender).call{value: address(this).balance}('');
        require(os);
    }

    
}