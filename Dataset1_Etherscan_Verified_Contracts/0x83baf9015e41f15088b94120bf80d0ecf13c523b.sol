// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function WETH() external pure returns (address);
    
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
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
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
}

contract PuppyBCD is IERC20 {
    using SafeMath for uint256;

    string private _name = "PuppyBCD";
    string private _symbol = "PBCD";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 1000000000 * 10 ** uint256(_decimals);
    
    address public owner;
    bool public whitelistEnabled = true; // 手动控制白名单启用或禁用
    uint256 public maxPurchaseLimitInETH = 0.1 ether; // 白名单用户购买限制为0.1 ETH

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isWhitelisted;
    mapping(address => bool) private _isBlacklisted;  // 黑名单
    mapping(address => uint256) private _whitelistPurchases; // 记录每个白名单用户的购买金额

    uint256 public buyTax = 1; // 1%
    uint256 public sellTax = 1; // 1%
    address public buyTaxWallet = 0xe89219A5EE1E68a0f0C395f562d22c011Bc33333;
    address public sellTaxWallet = 0x818336045F385dd00448E269477Bd1Dc4F777777;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(owner == msg.sender, "Caller is not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);

        // Initialize Uniswap router and create a pair
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); // Uniswap V2 router address
        uniswapV2Pair = uniswapV2Router.WETH();

        // Set whitelist addresses
        _isWhitelisted[0xd0e2b35Ca687d75D394F3bAd343C880F4Bea7FD3] = true;
        _isWhitelisted[0x42D2165326777f25cf1E65BfC2F6088E5e8AdF68] = true;
        _isWhitelisted[0x87Af63e3D75d0C42e47bbe989BECB85cDd293353] = true;
        _isWhitelisted[0x44DE27DB303110a27A79A85E5337769413b1cb5a] = true;
        _isWhitelisted[0x54c003ADc2Ba1A149A2C333f8AAc75f460983Cfb] = true; 
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

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view override returns (uint256) {
        return _allowances[tokenOwner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function _approve(address tokenOwner, address spender, uint256 amount) internal {
        require(tokenOwner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[tokenOwner][spender] = amount;
        emit Approval(tokenOwner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(!_isBlacklisted[sender] && !_isBlacklisted[recipient], "ERC20: sender or recipient is blacklisted");

        if (whitelistEnabled) {
            require(_isWhitelisted[sender] && _isWhitelisted[recipient], "ERC20: sender or recipient is not whitelisted");
            if (sender == uniswapV2Pair) {
                uint256 ethAmount = getETHAmountFromTokens(amount);
                require(_whitelistPurchases[recipient].add(ethAmount) <= maxPurchaseLimitInETH, "Exceeds whitelist purchase limit of 0.1 ETH");
                _whitelistPurchases[recipient] = _whitelistPurchases[recipient].add(ethAmount);
            }
        }

        uint256 taxAmount = 0;

        if (recipient == uniswapV2Pair) {
            taxAmount = amount.mul(sellTax).div(100);
            _balances[sellTaxWallet] = _balances[sellTaxWallet].add(taxAmount);
        } else if (sender == uniswapV2Pair) {
            taxAmount = amount.mul(buyTax).div(100);
            _balances[buyTaxWallet] = _balances[buyTaxWallet].add(taxAmount);
        }

        uint256 transferAmount = amount.sub(taxAmount);
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(transferAmount);
        
        emit Transfer(sender, recipient, transferAmount);
        if (taxAmount > 0) {
            emit Transfer(sender, address(this), taxAmount);
            swapTokensForEth(taxAmount, recipient == uniswapV2Pair ? sellTaxWallet : buyTaxWallet);
        }
    }

    function swapTokensForEth(uint256 tokenAmount, address to) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            to,
            block.timestamp
        );
    }

    function getETHAmountFromTokens(uint256 tokenAmount) private view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        uint[] memory amounts = uniswapV2Router.getAmountsOut(tokenAmount, path);
        return amounts[1];
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    // 手动禁用白名单功能
    function disableWhitelist() external onlyOwner {
        whitelistEnabled = false;
    }

    // 手动启用白名单功能
    function enableWhitelist() external onlyOwner {
        whitelistEnabled = true;
    }

    // 新增白名单功能
    function addToWhitelist(address account) external onlyOwner {
        _isWhitelisted[account] = true;
    }

    function removeFromWhitelist(address account) external onlyOwner {
        _isWhitelisted[account] = false;
    }

    function isWhitelisted(address account) external view returns (bool) {
        return _isWhitelisted[account];
    }

    // 新增黑名单功能
    function addToBlacklist(address account) external onlyOwner {
        _isBlacklisted[account] = true;
    }

    function removeFromBlacklist(address account) external onlyOwner {
        _isBlacklisted[account] = false;
    }

    function isBlacklisted(address account) external view returns (bool) {
        return _isBlacklisted[account];
    }
}