pragma solidity ^0.4.24;

//Safe Math Interface

contract Safe_Math {

    function safe_Add(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function safe_Sub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function safe_Mul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function safe_Div(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


//ERC Token Standard #20 Interface

contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


//Contract function to receive approval and execute function in one call

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}

//Actual token contract

contract AEDToken is ERC20Interface, Safe_Math {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    constructor() public {
        symbol = "AED";
        name = "AED";
        decimals = 18;
        _totalSupply = 1000000001000000000000000000;
        balances[0x43673733e2b5413e6cBb2c7A65de797dDA630384] = _totalSupply;
        emit Transfer(address(0), 0x43673733e2b5413e6cBb2c7A65de797dDA630384, _totalSupply);
    }

    function totalSupply() public constant returns (uint) {
        return _totalSupply  - balances[address(0)];
    }

    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safe_Sub(balances[msg.sender], tokens);
        balances[to] = safe_Add(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safe_Sub(balances[from], tokens);
        allowed[from][msg.sender] = safe_Sub(allowed[from][msg.sender], tokens);
        balances[to] = safe_Add(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }

    function () public payable {
        revert();
    }
}