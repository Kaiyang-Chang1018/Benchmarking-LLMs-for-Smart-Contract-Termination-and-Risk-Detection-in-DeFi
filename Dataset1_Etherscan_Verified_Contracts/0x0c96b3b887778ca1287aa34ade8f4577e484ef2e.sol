/*           
            @@@@@@@@@@@@@@@@@           @@@@@@@@@@@      @@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@      
         @@@@@@@@@@@@@@@@@@@@@@@        @@@@@@@@@@@@     @@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@      
        @@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@@@@@@@@@    @@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@      
       @@@@@@@@@@@@@@@@@@@@@@@@@@@@     @@@@@@@@@@@@@@   @@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@      
      @@@@@@@@@@@@@@ @@@@@@@@@@@@@@@    @@@@@@@@@@@@@@   @@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@      
      @@@@@@@@@@@@@   @@@@@@@@@@@@@@    @@@@@@@@@@@@@@@  @@@@@@@@@@@@@    @@@@@@@@@@@@@               
      @@@@@@@@@@@@@   @@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@ @@@@@@@@@@@@@    @@@@@@@@@@@@@               
      @@@@@@@@@@@@@   @@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    @@@@@@@@@@@@@               
      @@@@@@@@@@@@@   @@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    @@@@@@@@@@@@@               
      @@@@@@@@@@@@@   @@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@       
      @@@@@@@@@@@@@   @@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@       
      @@@@@@@@@@@@@   @@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@       
      @@@@@@@@@@@@@   @@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@       
      @@@@@@@@@@@@@   @@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@       
      @@@@@@@@@@@@@   @@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    @@@@@@@@@@@@@@              
      @@@@@@@@@@@@@   @@@@@@@@@@@@@@    @@@@@@@@@@@ @@@@@@@@@@@@@@@@@@    @@@@@@@@@@@@@               
      @@@@@@@@@@@@@   @@@@@@@@@@@@@@    @@@@@@@@@@@ @@@@@@@@@@@@@@@@@@    @@@@@@@@@@@@@               
      @@@@@@@@@@@@@   @@@@@@@@@@@@@@    @@@@@@@@@@@  @@@@@@@@@@@@@@@@@    @@@@@@@@@@@@@               
      @@@@@@@@@@@@@   @@@@@@@@@@@@@@    @@@@@@@@@@@  @@@@@@@@@@@@@@@@@    @@@@@@@@@@@@@               
      @@@@@@@@@@@@@   @@@@@@@@@@@@@@    @@@@+---#@@   @@@@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@      
      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@     @@@+-----%@    @@@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@      
       @@@@@@@@@@@@@@@@@@@@@@@@@@@      @@%------@@    @@@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@      
        @@@@@@@@@@@@@@@@@@@@@@@@@       @@=-----+@@     @@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@      
           @@@@@@@@@@@@@@@@@@@          @#------%@@     @@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@      
               @@@@@@@@@@@              ==-----==                                                     
                                        =------=                                                      
                              =-----   ==-----==                                                      
                             ++------= =------=                                                       
                              +=-----=+=------==-=                                                    
                              ++=----==------------=                                                  
                               +=----==-----------------=                                             
                               +=----=----------------------                                          
                               ==---=-----------------------==                                        
                               ==----------------------------=                                        
                               +=---------------------------==                                        
                               ++=-------------------------==                                         
                                ++=-----------------------==+                                         
                                 *++=--------------------=++                                          
                                   *++==---------------==++                                           
                                    **+=-------------==++*                                            
                                   ***+==-----------==+**                                             
                                  ***+===----------===+*                                              
Web:https://one1.fun/

Twitter:https://x.com/one1dio

Telegram:https://t.me/one1dio

SPDX-License-Identifier: MIT

*/                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       

pragma solidity ^0.8.0;

contract ONE {
    using SafeMath for uint256;

    string public constant name = "ONE";
    string public constant symbol = "ONE";
    uint8 public constant decimals = 18;
    uint256 public constant totalSupply = 10000000000 * 10**18;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    address public owner;

    modifier onlyOwner() {
        require(owner == msg.sender, "Caller is not the owner");
        _;
    }

    constructor() {
        _balances[msg.sender] = totalSupply;
        owner = msg.sender;
        emit Transfer(address(0), msg.sender, totalSupply);
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        // Using SafeMath for secure arithmetic operations
        _balances[sender] = senderBalance.sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address tokenOwner, address spender, uint256 amount) internal {
        require(tokenOwner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        // Using SafeMath for secure arithmetic operations
        _allowances[tokenOwner][spender] = amount;
        emit Approval(tokenOwner, spender, amount);
    }

    function allowance(address tokenOwner, address spender) external view returns (uint256) {
        return _allowances[tokenOwner][spender];
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");

        _transfer(sender, recipient, amount);

        // Using SafeMath for secure arithmetic operations
        _approve(sender, msg.sender, currentAllowance.sub(amount));

        return true;
    }

    // Ownership transfer functions
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
}

// SafeMath library for safe arithmetic operations (although Solidity 0.8.0+ includes overflow checks by default)
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }
}