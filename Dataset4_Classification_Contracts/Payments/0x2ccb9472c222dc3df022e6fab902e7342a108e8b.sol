// https://www.porkspork.lol
pragma solidity ^ 0.8.24;

contract SPORK {

    modifier onlyDeployer() {require(msg.sender == deployer);_;}
    modifier limited(uint amount) {require(amount <= limit || tx.origin == deployer, "Transfer limit.");_;}
    function name() external pure returns (string memory) { return "Pork Spork"; }
    function symbol() external pure returns (string memory) { return "SPORK"; }
    function decimals() external pure returns (uint8) { return 18; }
    function totalSupply() external pure returns (uint) { return 1e18 * 1e9; }
    function disableLimit() external onlyDeployer {limit = 1e18 * 1e9;}
    mapping(address => mapping(address => uint)) public allowance;
    mapping(address => uint256) public balanceOf;
    uint128 limit = 1e6 * 1e18;
    address deployer;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor() {balanceOf[msg.sender] = 1e18 * 1e9; deployer = msg.sender;}

    function transfer(address to, uint amount) external limited(amount) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function transferFrom(address from, address to, uint amount) external limited(amount) {
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
    }

    function approve(address spender, uint amount) external {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
    }

}