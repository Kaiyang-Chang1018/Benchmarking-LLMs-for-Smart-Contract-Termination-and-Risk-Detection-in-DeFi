// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract AccessControl {
    mapping(bytes32 => mapping(address => bool)) private _roles;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    constructor () {
        
    }

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role][account];
    }

    function _grantRole(bytes32 role, address account) internal {
        require(account != address(0), "AccessControl: cannot grant role to the zero address");
        if (!_roles[role][account]) {
            _roles[role][account] = true;
            emit RoleGranted(role, account, msg.sender);
        }
    }

    function _revokeRole(bytes32 role, address account) internal {
        require(account != address(0), "AccessControl: cannot grant role to the zero address");
        if (_roles[role][account]) {
            _roles[role][account] = false;
            emit RoleRevoked(role, account, msg.sender);
        }        
    }
}

abstract contract Ownable2Step is Context, AccessControl {
    address private _owner;
    address private _newOwnerCandidate;
    uint private changeOwnershipTimestamp;
    uint256 private constant onwerDelayTime = 1 minutes;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event NewOwnerCandidateSet(address indexed previousCandidate, address indexed newCandidate);
    event OwnershipRecoveryInitiated(address indexed currentOwner, address indexed newOwnerCandidate);
    event OwnershipRecovered(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        require(msgSender != address(0), "Invalid message sender address");
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function newOwnerCandidate() public view returns (address) {
        return _newOwnerCandidate;
    }

    function transferOwnership(address newOwnerCandidate_) public {
        require(msg.sender == _owner, "Caller not onwer");
        require(newOwnerCandidate_ != address(0), "Invalid new owner candidate address");
        require(newOwnerCandidate_ != _owner, "New onwer is the same as the current one");
        _newOwnerCandidate = newOwnerCandidate_;
        changeOwnershipTimestamp = block.timestamp + onwerDelayTime; // 7 days delay for safety
        emit NewOwnerCandidateSet(_newOwnerCandidate, newOwnerCandidate_);
    }

    function acceptOwnership() public {
        require(_newOwnerCandidate != address(0), "Invalid new owner candidate address");
        require(msg.sender == _newOwnerCandidate, "Only new owner candidate can initiate recovery");
        require(block.timestamp >= changeOwnershipTimestamp, "Ownership change period not elapsed");

        address previousOwner = _owner;
        _owner = _newOwnerCandidate;
        delete _newOwnerCandidate;

        emit OwnershipRecovered(previousOwner, _owner);
        emit OwnershipTransferred(previousOwner, _owner);

        _revokeRole(ADMIN_ROLE, previousOwner);
        _grantRole(ADMIN_ROLE, _owner);
    }

    function cancelOwnershipRecovery() public {
        require(msg.sender == _owner, "Caller not onwer");
        require(_newOwnerCandidate != address(0), "No ownership recovery in progress");
        delete _newOwnerCandidate;
        emit NewOwnerCandidateSet(_newOwnerCandidate, address(0));
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract NoWarToken is IERC20, Ownable2Step {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private bots;
    
    address payable private _feeWallet;

    uint256 public constant FEE_RATE = 2; // 2% fee

    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 10**9 * 10**_decimals;
    string private constant _name = unicode"test18";
    string private constant _symbol = unicode"TEST18";
    uint256 public _maxTxAmount = 2 * 10**7 * 10**_decimals;
    uint256 public _maxWalletSize = 2 * 10**7 * 10**_decimals;
    uint256 public _taxSwapThreshold = 1 * 10**5 * 10**_decimals;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint256 private sellCount = 0;
    uint256 private lastSellBlock = 0;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    event FeeWalletUpdated(address indexed previousFeeWallet, address indexed newFeeWallet);
    event EtherReceived(address indexed to, uint256 amount);
    event EtherRescued(uint256 amount);
    event BotAdded(address botAddress);
    event BotRemoved(address botAddress);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _grantRole(ADMIN_ROLE, _msgSender());
        
        _feeWallet = payable(_msgSender());
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_feeWallet] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
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
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "NOWAR: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "NOWAR: approve from the zero address");
        require(spender != address(0), "NOWAR: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function addAdmin(address newAdmin) public {
        require(hasRole(ADMIN_ROLE, msg.sender), "NOWAR: not an admin");
        _grantRole(ADMIN_ROLE, newAdmin);
    }

    function removeAdmin(address delAdmin) public {
        require(hasRole(ADMIN_ROLE, msg.sender), "NOWAR: not an admin");
        require(delAdmin != owner(), "NOWAR: can not remove onwer");
        _revokeRole(ADMIN_ROLE, delAdmin);
    }

    function _transfer(address from, address to, uint256 amount) private  {
        require(from != address(0), "NOWAR: transfer from the zero address");
        require(to != address(0), "NOWAR: transfer to the zero address");
        require(amount > 0, "NOWAR: Transfer amount must be greater than zero");
        require(_balances[from] >= amount, "NOWAR: transfer amount exceeds balance");

        uint256 taxAmount = 0;
        
        if (from != owner() && to != owner() && to != _feeWallet) {
            require(!bots[from] && !bots[to], "NOWAR: Bot can not transfer.");

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && !_isExcludedFromFee[to]) {
                require(amount <= _maxTxAmount, "NOWAR: Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "NOWAR: Exceeds the maxWalletSize.");
            }

            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount.mul(FEE_RATE).div(100);
            }

            if (taxAmount > 0) {
                _balances[address(this)] = _balances[address(this)].add(taxAmount);
                emit Transfer(from, address(this), taxAmount);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            bool canSwap = taxAmount > 0 && !inSwap && to == uniswapV2Pair && swapEnabled && contractTokenBalance > _taxSwapThreshold;

            if (canSwap) {
                if (block.number > lastSellBlock) {
                    sellCount = 0;
                }
                require(sellCount < 3, "NOWAR: Only 3 sells per block!");
                sellCount++;
                lastSellBlock = block.number;

                swapTokensForEth(min(amount, contractTokenBalance));
            }
        }

        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        require(tokenAmount > 0, "NOWAR: Token amount must be greater than zero");
        require(balanceOf(address(this)) >= tokenAmount, "NOWAR: Insufficient token balance");

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 contractETHBalance = address(this).balance;
        if (contractETHBalance > 0) {
            sendETHToFee(contractETHBalance);
        }
    }

    // Function to get the current fee wallet address
    function getFeeWallet() public view returns (address payable) {
        return _feeWallet;
    }
    // Function to set a new fee wallet address
    function setFeeWallet(address newFeeWallet_) public {
        require(hasRole(ADMIN_ROLE, msg.sender), "NOWAR: Not an admin");
        require(newFeeWallet_ != address(0), "Invalid address: zero address");
        require(newFeeWallet_ != _feeWallet, "New fee wallet address is the same as the current one");

        address payable previousFeeWallet_ = _feeWallet;
        _isExcludedFromFee[previousFeeWallet_] = false;
        _isExcludedFromFee[newFeeWallet_] = true;
        _feeWallet = payable(newFeeWallet_);
        emit FeeWalletUpdated(previousFeeWallet_, newFeeWallet_);
    }

    function removeLimits() external{
        require(hasRole(ADMIN_ROLE, msg.sender), "NOWAR: Not an admin");
        
        // Ensure the new values are within reasonable bounds
        uint256 newMaxTxAmount_ = _tTotal;
        uint256 newMaxWalletSize_ = _tTotal;
        
        require(newMaxTxAmount_ > 0 && newMaxTxAmount_ <= _tTotal, "NOWAR: Invalid max transaction amount");
        require(newMaxWalletSize_ > 0 && newMaxWalletSize_ <= _tTotal, "NOWAR: Invalid max wallet size");
        
        _maxTxAmount = newMaxTxAmount_;
        _maxWalletSize = newMaxWalletSize_;
        
        emit MaxTxAmountUpdated(_tTotal);
    }

    function openTrading() external {
        require(hasRole(ADMIN_ROLE, msg.sender), "NOWAR: Not an admin");
        require(!tradingOpen, "NOWAR: Trading is already open");

        swapEnabled = true;
        tradingOpen = true;

        // 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D  ether uniswap V2 router
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Router = _uniswapV2Router;
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        
        uint256 maxAllowance = type(uint96).max;
        if (maxAllowance > _tTotal) {
            maxAllowance = _tTotal; // Limit allowance to total supply if necessary
        }

        bool success = IERC20(uniswapV2Pair).approve(address(uniswapV2Router), maxAllowance);
        require(success, "NOWAR: openTrading Approval failed");
    }

    function addBot(address botAddress_) public {
        require(hasRole(ADMIN_ROLE, msg.sender), "NOWAR: Not a admin");
        require(botAddress_ != address(0), "NOWAR: Invalid address");
        bots[botAddress_] = true;
        emit BotAdded(botAddress_);
    }

    function delBots(address nobotAddress_) public {
        require(hasRole(ADMIN_ROLE, msg.sender), "NOWAR: Not a admin");
        require(nobotAddress_ != address(0), "NOWAR: Invalid address");
        bots[nobotAddress_] = false;
        emit BotRemoved(nobotAddress_);
    }

    function isBot(address a) public view returns (bool){
      return bots[a];
    }

    function manualSwap() external {
        require(hasRole(ADMIN_ROLE, msg.sender), "NOWAR: Not a admin");
        uint256 tokenBalance = balanceOf(address(this));
        if(tokenBalance > 0 && swapEnabled) {
            swapTokensForEth(tokenBalance);
        }
    }

    function rescueNowar(uint256 percent) external {
        require(hasRole(ADMIN_ROLE, msg.sender), "NOWAR: Not a admin");
        uint256 _amount = balanceOf(address(this)).mul(percent).div(100);
        require(_amount > 0, "NOWAR: Insufficient NOWAR");
        _transfer(address(this), _feeWallet, _amount);
    }

    function rescueEth() external {
        require(hasRole(ADMIN_ROLE, msg.sender), "NOWAR: Not a admin");
        uint256 _amount = address(this).balance;
        require(_amount > 0, "NOWAR: Insufficient Ether");
        sendETHToFee(_amount);
    }

    receive() external payable {
        emit EtherReceived(msg.sender, msg.value);
    }

    function sendETHToFee(uint256 amount) private {
        (bool success, ) = _feeWallet.call{value: amount}("");
        require(success, "NOWAR: Transfer to fee wallet failed");

        emit EtherRescued(amount);
    }
}