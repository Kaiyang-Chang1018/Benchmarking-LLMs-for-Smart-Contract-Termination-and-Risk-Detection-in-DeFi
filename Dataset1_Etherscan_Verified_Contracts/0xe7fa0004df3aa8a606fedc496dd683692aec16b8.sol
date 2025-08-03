// SPDX-License-Identifier: MIT
                                                                                                    
/**
   ###                   ###                                                                        
    #####             ######    ##    #    ##                                      ###              
    #######################    ####  ###  ####                                    #####             
    #######################    #### ##### #### #### #########  #########         ######    ####     
      ######%#####%######       ######### #### #### ####%%#### #########         #######   ####     
      ######%%%%#%%#######      #############  #### ####       ####             ########   ####     
     ### ####%%#%%#### ###      #############  #### #########  ########         #### ###   ####     
     ### ############# ###      ###### ######  ####    ####### ########         #########  ####     
      ####    ###    #####      ###### ######  ####       #### ####            ##########  ####     
     ######## ### ########      #####   ####   #### ########## #########       ####   #### ####     
     #####################       ####   ####   ####  ########  #########      ####    #### ####     
    ###                  ##                                                                         
 *
 *    ~~~~~~~~~~~ WISE AI -      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 *    Official Links
 *    ----------------
 *    Website:    https://www.wiseai.my/welcome  
 *    Twitter:    https://x.com/wiseaix
 *    Telegram:   https://t.me/wiseai_portal
 *    Docs:       https://docs.wiseai.my/
 *
 *
 *    Contract Details
 *    ----------------
 *    - Max Wallet: 5% (500,000 tokens)
 *    - Total Supply: 10,000,000 tokens
 *    - Trading opens 1 block after deployment
 *    - TAX B2% S2% - Used for marketing and development
 *    - Renounced ownership after launch
 *    - LP locked at launch
 */                                                                                              
                                                                                                    

pragma solidity ^0.8.19;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(msg.sender);
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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

contract WISEAI is IERC20, Ownable {
    string private constant _name = "WISE AI";
    string private constant _symbol = "WISEAI";
    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 10000000 * (10 ** 18); // 10M total supply
    uint256 private constant _maxWalletLimit = (_totalSupply * 5) / 100; // 5% max wallet

    uint256 public immutable tradingOpenBlock;
    address public immutable feeReceiver;
    address public immutable pair;
    address public immutable routerAddress;
    
    uint256 public immutable buyFee;
    uint256 public immutable sellFee;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public isExemptFromLimit;

    event ExemptFromLimitUpdated(address indexed account, bool exempt);

    constructor(
        address _feeReceiver,
        uint256 _buyFee,
        uint256 _sellFee,
        address _routerAddress
    ) {
        require(_feeReceiver != address(0), "Invalid fee receiver");
        require(_routerAddress != address(0), "Invalid router address");
        require(_buyFee <= 10 && _sellFee <= 10, "Fees cannot exceed 10%");
        
        feeReceiver = _feeReceiver;
        buyFee = _buyFee;
        sellFee = _sellFee;
        routerAddress = _routerAddress;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_routerAddress);
        
        address _pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        pair = _pair;

        tradingOpenBlock = block.number + 1;
        
        // Exempt critical addresses from limits
        isExemptFromLimit[msg.sender] = true;
        isExemptFromLimit[address(this)] = true;
        isExemptFromLimit[_pair] = true;
        isExemptFromLimit[_feeReceiver] = true;
        
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function setLimitExempt(address account, bool exempt) external onlyOwner {
        require(account != address(0), "Invalid address");
        isExemptFromLimit[account] = exempt;
        emit ExemptFromLimitUpdated(account, exempt);
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

    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0) && to != address(0), "Invalid address");
        require(_balances[from] >= amount, "Insufficient balance");

        // Check trading is open for pair transactions
        if (to == pair || from == pair) {
            require(block.number >= tradingOpenBlock, "Trading not open");
        }

        // Check max wallet limit
        if (!isExemptFromLimit[to]) {
            require(_balances[to] + amount <= _maxWalletLimit, "Exceeds max wallet limit");
        }

        uint256 feeAmount;
        
        // Calculate fees only after trading is open
        if (block.number >= tradingOpenBlock) {
            if (from == pair) { // Buy
                feeAmount = (amount * buyFee) / 100;
            } else if (to == pair) { // Sell
                feeAmount = (amount * sellFee) / 100;
            }
        }

        uint256 finalAmount = amount - feeAmount;

        _balances[from] -= amount;
        _balances[to] += finalAmount;

        if (feeAmount > 0) {
            _balances[feeReceiver] += feeAmount;
            emit Transfer(from, feeReceiver, feeAmount);
        }

        emit Transfer(from, to, finalAmount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0) && spender != address(0), "Invalid address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal {
        uint256 currentAllowance = _allowances[owner][spender];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "Insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}