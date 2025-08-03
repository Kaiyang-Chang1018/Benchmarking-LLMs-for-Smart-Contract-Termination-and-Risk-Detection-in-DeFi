// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Ownable 
{
    address private _owner;   
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    constructor(address __owner) 
    {
        _owner = __owner;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) 
    {
        return _owner;
    }   
    
    modifier onlyOwner() 
    {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner 
    {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner 
    {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



contract LockToken is Ownable {

    bool public isOpen = false;
    
    mapping(address => bool) private _whiteList;
    modifier open(address from, address to) {
        require(isOpen || _whiteList[from] || _whiteList[to], "Not Open");
        _;
    }

    constructor(address __owner) Ownable(__owner) {
        _whiteList[__owner] = true;
        _whiteList[address(this)] = true;
    }

    function openTrade() external onlyOwner {
        isOpen = true;
    }


    function includeToWhiteList(address[] memory _users) external onlyOwner {
        for(uint8 i = 0; i < _users.length; i++) {
            _whiteList[_users[i]] = true;
        }
    }
}



contract TSION is LockToken 
{
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    address public marketingWallet = 0xaa23eEAD59ED2756Cb068DEDb744b78C9F7605b2;

    uint256 public marketingFee = 2;

    mapping (address => bool) private _isExcludedFromWhale;
    uint256 public _walletHoldingMaxLimit;

    constructor(address __owner) LockToken(__owner)
    { 
      _name = "TSION";
      _symbol = "Tsion";
      _decimals = 18;
      _init(owner(), 1_000_000_000 * 10**18);
      _isExcludedFromFee[owner()] = true;
      _isExcludedFromFee[marketingWallet] = true;
      _isExcludedFromFee[address(this)] = true;
      _isExcludedFromWhale[owner()]=true;
      _isExcludedFromWhale[address(this)]=true;
      _isExcludedFromWhale[address(0)]=true;
      _isExcludedFromWhale[marketingWallet]=true;
      _walletHoldingMaxLimit = 10_000_000 * 10**18;
    }


    function name() public view virtual returns (string memory) 
    {
        return _name;
    }


    function symbol() public view virtual returns (string memory) 
    {
        return _symbol;
    }


    function decimals() public view virtual returns (uint8) 
    {
        return _decimals;
    }

 
    function totalSupply() public view  returns (uint256) 
    {
        return _totalSupply;
    }


    function balanceOf(address account) public view  returns (uint256) 
    {
        return _balances[account];
    }

    
    function transfer(address recipient, uint256 amount) public  returns (bool) 
    {
         _transferTokens(_msgSender(), recipient, amount);
        return true;
    }



    function allowance(address owner, address spender) public view  returns (uint256) 
    {
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 amount) public returns (bool) 
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }


    function transferFrom(address sender, address recipient, uint256 amount) public  returns (bool) 
    {
        _transferTokens(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()]-amount);
        return true;
    }



    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) 
    {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender]+addedValue);
        return true;
    }


    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) 
    {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender]-subtractedValue);
        return true;
    }
    

    function _transferTokens(address sender, address recipient, uint256 amount) internal virtual 
    {
        uint256 marketingTokens = 0;

        if(!_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient]) 
        { 
            marketingTokens = (amount*marketingFee)/100;
            amount = amount-marketingTokens;
        }


        if(marketingTokens>0) 
        {
            _transfer(sender, marketingWallet, marketingTokens);
        }  

        _transfer(sender, recipient, amount);

    }



    function _transfer(address sender, address recipient, uint256 amount) internal open(sender, recipient) 
    {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[sender] >= amount, "ERC20: Cannot send more available balance");
        _balances[sender] = _balances[sender]-amount;
        _balances[recipient] = _balances[recipient]+amount;
        emit Transfer(sender, recipient, amount);
    }

    // this is an internal function for one time call at deployment 
    function _init(address account, uint256 amount) internal virtual 
    {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply = _totalSupply+amount;
        _balances[account] = _balances[account]+amount;
        emit Transfer(address(0), account, amount);
    }


    function _approve(address owner, address spender, uint256 amount) internal virtual 
    {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }



    function checkForWhale(address from, address to, uint256 amount) private view
    {
        uint256 newBalance = balanceOf(to)+amount;
        if(!_isExcludedFromWhale[from] && !_isExcludedFromWhale[to]) 
        { 
            require(newBalance <= _walletHoldingMaxLimit, "Exceeding max tokens limit in the wallet"); 
        } 
    }

    function setExcludedFromWhale(address account, bool _enabled) public onlyOwner 
    {
        _isExcludedFromWhale[account] = _enabled;
    } 


}