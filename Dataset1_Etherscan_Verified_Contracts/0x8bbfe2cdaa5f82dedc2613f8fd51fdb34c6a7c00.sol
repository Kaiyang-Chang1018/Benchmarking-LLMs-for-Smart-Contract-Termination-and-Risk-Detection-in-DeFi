/***

    ABOUT ACHMEDINO

    Straight out of an action, yet strangely romantic blockbuster, now making an entrance into your hearts and charts – It’s me, Achmedino! 

    Picture this: the most unexpected love story of the year, featuring my (in)famous father Achmed – The Dead Terrorist and my mother Achmedina – one of his 72 virgins. 
    
    Ain’t that a plot to twist your brains? But hey, here I am! A bundle of joyful humor and endless potential.

    I might just bring the best of both worlds into the crypto space – my mother’s heart of gold and my dad’s explosive wit. 
    
    And guess what? I’ve got a strong will to carry out my father’s mission and legacy. 
    
    Above all else, I am here to prove that even in the afterlife, his legacy lives on and his humor continues to fill everyone’s hearts. 
    
    So, get ready for some bone-shaking laughter as I take the stage and steal the spotlight!

    ---

    BABY STEPS, BABY MISSION

    Stepping into your father's shoes is hard…especially because he lost them on his first and final bombing attempt. 
    
    My dad might be the “Dead Terrorist” to many, but to me, he is my hero.

    He teaches me to play with bombs instead of strapping them to myself and always tells me “Achmedino, fireworks should fire up inside your heart, not outside near civilians”. 
    
    I believe he’s the coolest. I want to be just like him when I grow up and help many people…I looove to help!

    But first, support me on my mission to perpetuate my father's legacy. Together, we can celebrate his achievements and ensure that the essence of his mission lives on.
    
    Let’s be an inspiration for many generations to come!


    Website: https://www.ikeelyou.vip/achmedino
    Telegram: https://t.me/iKeelYouERC20
    X: https://twitter.com/iKeelYouERC20

***/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


contract ACHMEDINO is Context, IERC20, Ownable {
    using SafeMath for uint256;

    address public immutable ACHMED = address(0xD7F721e05546a961386eE5C32192EA40b86c0120); // ACHMED
    address public immutable deadWallet = 0x000000000000000000000000000000000000dEaD;
    
    string private constant _name = "Baby Boy Of Achmed";
    string private constant _symbol = "ACHMEDINO";
    uint256 private constant _totalSupply = 7272 * 10**18;
    
    uint256 public MinTaxSwapLimit = 7272100000000000000; // 0.1% of the total Supply
    uint256 public maxTxAmount = 72721000000000000000; // 1% maxTxAmount
    uint256 public maxWalletlimit = 72721000000000000000; // 1% Maxwalletlimit
    uint8 private constant _decimals = 18;

    IUniswapV2Router02 immutable uniswapV2Router;
    address public  uniswapV2Pair;
    address immutable WETH;
    address payable public marketingWallet;
    address payable public ownerWallet;

    uint256 private marketingBuyTax = 3;
    uint256 private marketingSellTax = 3;

    uint256 private achmedBuybackBuyTax = 2;
    uint256 private achmedBuybackSellTax = 2;

    uint256 public buyTax = marketingBuyTax.add(achmedBuybackBuyTax);
    uint256 public sellTax = marketingSellTax.add(achmedBuybackSellTax);
    uint8 private inSwapAndLiquify;

    uint256 countMarketingTax;
    uint256 countBuybackTax;

    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFees;
    
    bool public isOpen = false;
    bool private inSwap;
    mapping(address => bool) private _whiteList;

    modifier inSwapFlag {
        inSwap = true;
        _;
        inSwap = false;
    }
    modifier open(address from, address to) {
        require(isOpen || _whiteList[from] || _whiteList[to], "Not Open");
        _;
    }

    constructor() {
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        WETH = uniswapV2Router.WETH();
        
        
        marketingWallet = payable(0x37Dce6E73EF0bd098d93797FaAcEE9Ef3bB1132b);
        ownerWallet = payable (0x3f6F125665441b83c272599a5F0B1248deAA8BEF);
        
        _balance[ownerWallet] = _totalSupply;

        _whiteList[msg.sender] = true;
        _whiteList[address(this)] = true;
        _whiteList[ownerWallet] = true;

        _isExcludedFromFees[marketingWallet] = true;
        _isExcludedFromFees[ownerWallet] = true;
        _isExcludedFromFees[msg.sender] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[address(uniswapV2Router)] = true;

        _allowances[address(this)][address(uniswapV2Router)] = type(uint256).max;
        _allowances[ownerWallet][address(uniswapV2Router)] = type(uint256).max;
        _allowances[marketingWallet][address(uniswapV2Router)] = type(uint256).max;
        

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function createPair() external  onlyOwner {

        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            WETH
        );

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
        return _balance[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
        );
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function updateBuyTaxes(uint256 marketing, uint256 buyback) external onlyOwner {
        require(marketing.add(buyback) <= 25);
        marketingBuyTax = marketing;
        achmedBuybackBuyTax = buyback;
        buyTax = marketingBuyTax.add(achmedBuybackBuyTax);
    }    

    function updateSellTaxes(uint256 marketing, uint256 buyback) external onlyOwner {
        require(marketing.add(buyback) <= 25);
        marketingSellTax = marketing;
        achmedBuybackSellTax = buyback;
        sellTax = marketingSellTax.add(achmedBuybackSellTax);
    }    

    function ExcludeFromFees(address holder, bool exempt) external onlyOwner {
        _isExcludedFromFees[holder] = exempt;
    }
    
    function ChangeMinTaxSwapLimit(uint256 NewMinTaxSwapLimitAmount) external onlyOwner {
        MinTaxSwapLimit = NewMinTaxSwapLimitAmount;
    }

    function ChangeMaxTxAmountLimit(uint256 NewMaxTxAmountLimit) external onlyOwner {
        maxTxAmount = NewMaxTxAmountLimit;
    }

    function ChangeMaxWalletLimit(uint256 NewMaxWallettLimit) external onlyOwner {
        maxWalletlimit = NewMaxWallettLimit;
    }

    function DisableWalletLimit() external onlyOwner {
        maxWalletlimit = _totalSupply;
    }
    
    function ChangeMarketingWalletAddress(address newAddress) external onlyOwner() {
        marketingWallet = payable(newAddress);
    }

    function EnableTrade() external onlyOwner {
        isOpen = true;
    }

    function includeToWhiteList(address[] memory _users) external onlyOwner {
        for(uint8 i = 0; i < _users.length; i++) {
            _whiteList[_users[i]] = true;
        }
    }

    // Contract Coded by @butiyam on Fiverr and Telegram

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(isOpen || _whiteList[from] || _whiteList[to], "Not Open");

        uint256 _tax;
        bool isBuying = false;
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            _tax = 0;
        } else {

            if (inSwapAndLiquify == 1) {
                //No tax transfer
                _balance[from] -= amount;
                _balance[to] += amount;

                emit Transfer(from, to, amount);
                return;
            }

            if (from == uniswapV2Pair) {
                isBuying = true;
                _tax = buyTax;
                require(amount <= maxTxAmount);
                uint256 contractBalanceRecipient = balanceOf(to);
                require(contractBalanceRecipient + amount <= maxWalletlimit,"ACHMEDINO: maximum token per wallet amount exceed");
            } else if (to == uniswapV2Pair) {
                require(from != address(this) && amount <= maxTxAmount);
                uint256 tokensToSwap = _balance[address(this)];
                if (tokensToSwap > MinTaxSwapLimit && inSwapAndLiquify == 0) {
                    inSwapAndLiquify = 1;
                    SwapAndBuyBack(countBuybackTax);
                    internalSwap(countMarketingTax);

                    inSwapAndLiquify = 0;
                }
                isBuying = false;
                _tax = sellTax;
            } else {
                _tax = 0;
            }
        }
        
    // Contract Coded by @butiyam on Fiverr and Telegram

        //Is there tax for sender|receiver?
        if (_tax != 0) {
            if(isBuying){
                countMarketingTax += (amount * marketingBuyTax) / 100;
                countBuybackTax += (amount * achmedBuybackBuyTax) / 100; 
            }else {
                countMarketingTax += (amount * marketingSellTax) / 100;
                countBuybackTax += (amount * achmedBuybackSellTax) / 100; 
            }
            //Tax transfer
            uint256 taxTokens = (amount * _tax) / 100;
            uint256 transferAmount = amount - taxTokens;

            _balance[from] -= amount;
            _balance[to] += transferAmount;
            _balance[address(this)] += taxTokens;
            emit Transfer(from, address(this), taxTokens);
            emit Transfer(from, to, transferAmount);
        } else {
            //No tax transfer
            _balance[from] -= amount;
            _balance[to] += amount;

            emit Transfer(from, to, amount);
        }
    }

     function SwapAndBuyBack(uint256 tokenAmount) internal inSwapFlag {
        

        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = WETH;
        path[2] = ACHMED;


        uint[] memory amounts = uniswapV2Router.getAmountsOut(tokenAmount, path);

        if(amounts[2] > 70000000000000000000){
            tokenAmount = tokenAmount / 2;
        }

        if (_allowances[address(this)][address(uniswapV2Router)] != type(uint256).max) {
            _allowances[address(this)][address(uniswapV2Router)] = type(uint256).max;
        }

        try uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
           deadWallet,
            block.timestamp
        ) {} catch {
            return;
        }

        countBuybackTax -= tokenAmount;

    }

     function internalSwap(uint256 tokenAmount) internal inSwapFlag {
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;

        if (_allowances[address(this)][address(uniswapV2Router)] != type(uint256).max) {
            _allowances[address(this)][address(uniswapV2Router)] = type(uint256).max;
        }

        try uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
           marketingWallet,
            block.timestamp
        ) {} catch {
            return;
        }

        countMarketingTax = 0;

    }

    receive() external payable {}
}