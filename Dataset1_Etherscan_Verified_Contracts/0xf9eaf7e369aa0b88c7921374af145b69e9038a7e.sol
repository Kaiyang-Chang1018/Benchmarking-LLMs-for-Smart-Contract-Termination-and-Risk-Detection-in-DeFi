// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/*                                              
  Website :    https://doglife-catlife.com/
  Twitter :    https://x.com/DOGLIFE_NETWORK
  Telegram :   https://t.me/DOGLIFE_NETWORK
*/

/**
 * @title ERC20
 * @dev Implementation of the basic standard token.
 */
contract ERC20 {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function transfer(address to, uint256 value) public returns (bool success) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool success) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        require(value <= balanceOf[from], "Insufficient balance");
        require(value <= allowance[from][msg.sender], "Allowance exceeded");
        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "Mint to the zero address");
        totalSupply += amount;
        balanceOf[account] += amount;
        emit Transfer(address(0), account, amount);
    }
}

/**
 * @title Token
 * @dev ERC20 Token with customizable name, symbol, and initial supply.
 * 
 * The contract allows for the creation of an ERC20 token with the following features:
 * - Customizable token name and symbol, specified at deployment.
 * - Initial supply of tokens, distributed to a specified liquidity address.
 * - Ownership of the contract can be renounced, rendering some functions inaccessible.
 */
contract Token is ERC20 {
    address public owner;
    
    event OwnershipRenounced(address indexed previousOwner);
    event TokensDistributed(address indexed to, uint256 amount);

    /*
     * @dev Sets the values for {name}, {symbol}, {initialSupply}, and {Liquidity}.
     * 
     * @param name The name of the token.
     * @param symbol The symbol of the token.
     * @param initialSupply The initial supply of the token.
     */

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        address Liquidity
    ) ERC20(name, symbol) {
        _mint(Liquidity, initialSupply);
        owner = msg.sender;
        emit TokensDistributed(Liquidity, initialSupply);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * This operation cannot be undone.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }

}