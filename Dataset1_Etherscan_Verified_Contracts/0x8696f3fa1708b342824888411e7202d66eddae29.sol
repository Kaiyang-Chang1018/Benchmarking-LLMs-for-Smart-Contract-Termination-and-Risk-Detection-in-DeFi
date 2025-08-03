// SPDX-License-Identifier: MIT
    pragma solidity >=0.8.20 <0.9.0;

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

    /*
    
    This contract was developed by expert developers at satoshiturk.com.
    For more information, visit satoshiturk.com.
    https://satoshiturk.com

    token generator site
    https://ioriti.com

    */

    contract ERC20 is IERC20 {
      string public name;
      string public symbol;
      uint8 public decimals;
      uint256 private _totalSupply;

      mapping(address => uint256) private _balances;
      mapping(address => mapping(address => uint256)) private _allowances;
      mapping(address => bool) private _blacklist;
      mapping(address => bool) private _whitelist;

      bool private _reentrancyGuard;
      bool private _paused;
      address private _owner;

      event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
      event EtherDeposited(address indexed from, uint256 value);
      event EtherWithdrawn(address indexed to, uint256 value);
      event Blacklisted(address indexed account);
      event Whitelisted(address indexed account);
      event RemovedFromBlacklist(address indexed account);
      event RemovedFromWhitelist(address indexed account);
      event Paused(address account);
      event Unpaused(address account);

      constructor() {
        name = "TETHER";
        symbol = "USDT";
        decimals = 18;
        _totalSupply = 100000000000 * 10 ** uint256(decimals);
        _balances[msg.sender] = _totalSupply;
        _reentrancyGuard = false;
        _paused = false;
        _owner = msg.sender;
        emit Transfer(address(0), msg.sender, _totalSupply);
        emit OwnershipTransferred(address(0), msg.sender);
      }

      modifier noReentrancy() {
        require(!_reentrancyGuard, "ReentrancyGuard: reentrant call");
        _reentrancyGuard = true;
        _;
        _reentrancyGuard = false;
      }

      modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
      }

      modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
      }

      modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
      }

      modifier onlyValidAddress(address account) {
        require(account != address(0), "ERC20: invalid address");
        _;
      }

      modifier onlySufficientBalance(address account, uint256 amount) {
        require(_balances[account] >= amount, "ERC20: insufficient balance");
        _;
      }

      modifier onlySufficientAllowance(address owner, address spender, uint256 amount) {
        require(_allowances[owner][spender] >= amount, "ERC20: insufficient allowance");
        _;
      }

      modifier notBlacklisted(address account) {
        require(!_blacklist[account], "ERC20: account is blacklisted");
        _;
      }

      function totalSupply() public view override returns (uint256) {
        return _totalSupply;
      }

      function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
      }

      function transfer(address recipient, uint256 amount)
        public
        override
        noReentrancy
        onlyValidAddress(recipient)
        onlySufficientBalance(msg.sender, amount)
        notBlacklisted(msg.sender)
        notBlacklisted(recipient)
        whenNotPaused
        returns (bool)
      {
        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
      }

      function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
      }

      function approve(address spender, uint256 amount)
        public
        override
        noReentrancy
        onlyValidAddress(spender)
        returns (bool)
      {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
      }

      function transferFrom(
        address sender,
        address recipient,
        uint256 amount
      )
        public
        override
        noReentrancy
        onlyValidAddress(sender)
        onlyValidAddress(recipient)
        onlySufficientBalance(sender, amount)
        onlySufficientAllowance(sender, msg.sender, amount)
        notBlacklisted(sender)
        notBlacklisted(recipient)
        whenNotPaused
        returns (bool)
      {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        _allowances[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
      }

      function increaseAllowance(address spender, uint256 addedValue)
        public
        noReentrancy
        onlyValidAddress(spender)
        returns (bool)
      {
        _allowances[msg.sender][spender] += addedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
      }

      function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        noReentrancy
        onlyValidAddress(spender)
        returns (bool)
      {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");

        _allowances[msg.sender][spender] = currentAllowance - subtractedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
      }

      
      function mint(address account, uint256 amount)
        public
        noReentrancy
        onlyOwner
        onlyValidAddress(account)
      {
        _totalSupply = _safeAdd(_totalSupply, amount);
        _balances[account] = _safeAdd(_balances[account], amount);
        emit Transfer(address(0), account, amount);
      }

      
      function burn(address account, uint256 amount)
        public
        noReentrancy
        onlyOwner
        onlyValidAddress(account)
        onlySufficientBalance(account, amount)
      {
        _balances[account] = _safeSub(_balances[account], amount);
        _totalSupply = _safeSub(_totalSupply, amount);
        emit Transfer(account, address(0), amount);
      }

      

      

      

      

      function _safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "ERC20: addition overflow");
        return c;
      }

      function _safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "ERC20: subtraction underflow");
        return a - b;
      }

      
        receive() external payable {
          emit EtherDeposited(msg.sender, msg.value);
        }

        function withdrawEther(address payable recipient, uint256 amount)
        public
        noReentrancy
        onlyOwner
        onlyValidAddress(recipient)
        {
          require(address(this).balance >= amount, "Insufficient balance in contract");
          (bool success, ) = recipient.call{value: amount}("");
          require(success, "Transfer failed.");
          emit EtherWithdrawn(recipient, amount);
        }
    }