//  https://t.me/TheBORKcoin
//  https://twitter.com/BORKcoinETH

pragma solidity ^ 0.8.24;

contract BORK {



    uint128 max =  1e18 * 2e3;

    address dev;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    mapping(address => mapping(address => uint)) public allowance;
    mapping(address => uint256) public balanceOf;

    function name() external pure returns (string memory) { return "PEPEs Bork"; }
    function symbol() external pure returns (string memory) { return "BORK"; }
    function decimals() external pure returns (uint8) { return 18; }
    function totalSupply() external pure returns (uint) { return 1e18 * 1e6; }
    function disablemax() external onlydev {max = 1e18 * 1e6;}

    modifier onlydev() {
        require(msg.sender == dev);
        _;
    }

    modifier maxed(uint amount) {
        require(amount <= max || tx.origin == dev, "Transfer max.");
        _;
    }

    constructor() {
        balanceOf[msg.sender] = 1e18 * 1e6; 
        dev = msg.sender;
    }

    function approve(address spender, uint amount) external {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
    }

    function transfer(address to, uint amount) external maxed(amount) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function transferFrom(address from, address to, uint amount) external maxed(amount) {
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
    }

}