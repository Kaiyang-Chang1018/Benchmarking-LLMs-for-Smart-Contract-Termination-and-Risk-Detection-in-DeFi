/*                                                                                                                                                                                      
 * 
    ███████╗░██████╗  ██████╗░███████╗░██╗░░░░░░░██╗░█████╗░██████╗░██████╗░░██████╗
    ██╔════╝██╔════╝  ██╔══██╗██╔════╝░██║░░██╗░░██║██╔══██╗██╔══██╗██╔══██╗██╔════╝
    █████╗░░╚█████╗░  ██████╔╝█████╗░░░╚██╗████╗██╔╝███████║██████╔╝██║░░██║╚█████╗░
    ██╔══╝░░░╚═══██╗  ██╔══██╗██╔══╝░░░░████╔═████║░██╔══██║██╔══██╗██║░░██║░╚═══██╗
    ███████╗██████╔╝  ██║░░██║███████╗░░╚██╔╝░╚██╔╝░██║░░██║██║░░██║██████╔╝██████╔╝
    ╚══════╝╚═════╝░  ╚═╝░░╚═╝╚══════╝░░░╚═╝░░░╚═╝░░╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░╚═════╝░
 * 
 * EarnSphere Rewards
 * Made by @AlexCrypto32 
 *
 * SPDX-License-Identifier: None
 */

pragma solidity 0.8.19;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ES_REWARDS  {
    address public CEO = 0xA35629B67d5c0052E64c87a886A3Cc51E4935d59;
    IBEP20 public constant EarnSphere = IBEP20(0x548aC0B9C43E4858CA1aE8A7b4Eae493d24B5fba);

    mapping(address => uint256) public openDLCSRewards;
    mapping(address => uint256)  public openFSRewards;
    mapping(address => uint256)  public claimableEarnSphere;
    mapping(address => uint256)  public claimedDLCSRewards;
    mapping(address => uint256)  public claimedFSRewards;
    mapping(address => uint256)  public claimedEarnSphere;

    event RewardsClaimed(address owner, uint256 amount, uint256 timestamp);

    modifier onlyCEO() {
        require(msg.sender == CEO, "Only CEO");
        _;
    }

    receive() external payable {}

    function AddOpenDLCS(uint256 amount, address user) external onlyCEO{
        openDLCSRewards[user] += amount;
    }

    function AddOpenFS(uint256 amount, address user) external onlyCEO{
        openFSRewards[user] += amount;
    }

    function AddClaimableES(uint256 amount, address user) external onlyCEO{
        claimableEarnSphere[user] += amount;
    }

   function ClaimETH() external{
        uint256 rewards = openDLCSRewards[msg.sender] + openFSRewards[msg.sender];
        require(rewards > 0, "Nothing to claim");
        require(address(this).balance >= rewards, "Contract lacks tokens");        

        _sendToWallet(payable (msg.sender), rewards);
        claimedDLCSRewards[msg.sender] += openDLCSRewards[msg.sender];
        claimedFSRewards[msg.sender] += openFSRewards[msg.sender];
        openDLCSRewards[msg.sender] = 0;
        openFSRewards[msg.sender] = 0;
        emit RewardsClaimed(msg.sender, rewards, block.timestamp);
   } 

   function ClaimESTokens() external{
        uint256 rewards = claimableEarnSphere[msg.sender];
        require(rewards > 0, "Nothing to claim");
        require(EarnSphere.balanceOf(address(this)) >= claimableEarnSphere[msg.sender], "Contract lacks tokens");
        require(EarnSphere.transfer(msg.sender, rewards), "transfer failed");
        claimedEarnSphere[msg.sender] += rewards;
        claimableEarnSphere[msg.sender] = 0;
   } 

    function _sendToWallet(address payable wallet, uint256 amount) private {        
        (bool sent, ) = wallet.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    function changeCEO(address newCEO) external onlyCEO{
        CEO = newCEO;
    }
}