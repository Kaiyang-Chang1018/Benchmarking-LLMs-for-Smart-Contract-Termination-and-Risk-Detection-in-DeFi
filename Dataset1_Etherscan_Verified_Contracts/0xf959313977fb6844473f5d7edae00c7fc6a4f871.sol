// SPDX-License-Identifier: MIT

/**
    
                   W O L F P A C K   A I
                   
        ++                        ++         
        ++++                     +++         
        ++++++                 +++++            
        +++  ++++          ++++  +++         
        +++    +++        +++    +++         
        +++    +++        +++    +++         
        +++  ++++    ++    ++++  +++         
        +++++++    ++++++    +++++++                
        ++++    ++++    ++++    +++++        
     +++++++++    ++++ ++++   ++++ ++++      
    ++++    +++     +++++    +++    ++++     
      ++++   ++++   ++++   ++++   ++++            
          ++++ +++   ++   +++ +++++          
           +++++++   ++   +++++++            
             +++++   ++   ++++               
               ++++  ++  ++++                
                 ++++++++++                  
                   ++++++                    
                     ++                      

    🌐 Official Links
    ----------------
    Website:    https://www.wolfpackai.app/landing
    Terminal:   https://www.wolfpackai.app/
    Litepaper:  https://docs.wolfpackai.app
    Telegram:   https://t.me/wolfpackaitg
    Twitter:    https://x.com/wolfpackaix

    📊 WolfPack AI Overview
    ---------------------
    An autonomous AI research agent aggregating real-time data from:
    - Social media sentiment
    - Community engagement
    - Influencer analysis
    - Technical documentation

    🔍 Key Features
    -------------
    - Real-time Telegram analytics
    - Cross-platform data aggregation
    - Sentiment analysis
    - Project risk evaluation
    - Admin/Mod activity monitoring
    - Scam detection
    - KOL tracking
    - Price impact analysis
    - Custom alert systems

*/
pragma solidity ^0.8.19;

abstract contract Ownable {
    // Custom errors for gas optimization
    error Unauthorized();
    error InvalidAddress();

    address private _owner;
    address private immutable _originalDeployer;
    uint256 private immutable _deploymentTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _originalDeployer = msg.sender;
        _deploymentTime = block.timestamp;
        _transferOwnership(msg.sender);
    }

    modifier onlyOwner() {
        if (owner() != msg.sender) revert Unauthorized();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function deploymentDetails() public view returns (address deployer, uint256 timestamp) {
        return (_originalDeployer, _deploymentTime);
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) revert InvalidAddress();
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract WOLFPACKAI is IERC20, Ownable {
    // Custom errors
    error ZeroAddress();
    error InsufficientBalance();
    error InsufficientAllowance();
    error AllowanceBelowZero();

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFees; // Added for future use
    
    string private constant TOKEN_NAME = "WOLFPACK AI";
    string private constant TOKEN_SYMBOL = "WOLFAI";
    uint8 private constant DECIMALS = 18;
    uint256 private immutable _totalSupply;
    uint8 private constant CONTRACT_VERSION = 1;

    // Added events for tracking
    event ExcludeFromFees(address indexed account, bool excluded);
    event ContractDeployed(uint8 version, uint256 totalSupply);

    constructor() {
        _totalSupply = 10000000 * (10 ** DECIMALS);
        _balances[msg.sender] = _totalSupply;
        
        // Exclude deployer from potential future fees
        _isExcludedFromFees[msg.sender] = true;
        
        emit Transfer(address(0), msg.sender, _totalSupply);
        emit ContractDeployed(CONTRACT_VERSION, _totalSupply);
    }

    // Added view functions
    function name() public pure returns (string memory) {
        return TOKEN_NAME;
    }

    function symbol() public pure returns (string memory) {
        return TOKEN_SYMBOL;
    }

    function decimals() public pure returns (uint8) {
        return DECIMALS;
    }

    function version() public pure returns (uint8) {
        return CONTRACT_VERSION;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        _spendAllowance(from, msg.sender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, allowance(msg.sender, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = allowance(msg.sender, spender);
        if (currentAllowance < subtractedValue) revert AllowanceBelowZero();
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        if (from == address(0) || to == address(0)) revert ZeroAddress();
        if (_balances[from] < amount) revert InsufficientBalance();
        
        unchecked {
            _balances[from] -= amount;
            _balances[to] += amount;
        }
        
        emit Transfer(from, to, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        if (owner == address(0) || spender == address(0)) revert ZeroAddress();

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < amount) revert InsufficientAllowance();
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}