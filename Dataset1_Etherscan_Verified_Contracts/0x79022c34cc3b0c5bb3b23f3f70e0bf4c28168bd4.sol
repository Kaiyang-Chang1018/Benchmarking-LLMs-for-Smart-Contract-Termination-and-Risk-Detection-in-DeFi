/**
 __       __                                     __        ________  __                            __                               
/  \     /  |                                   /  |      /        |/  |                          /  |                              
$$  \   /$$ | __    __   ______   ______    ____$$ |      $$$$$$$$/ $$ |  ______   _______    ____$$ |  ______    ______    _______ 
$$$  \ /$$$ |/  |  /  | /      \ /      \  /    $$ |      $$ |__    $$ | /      \ /       \  /    $$ | /      \  /      \  /       |
$$$$  /$$$$ |$$ |  $$ |/$$$$$$  |$$$$$$  |/$$$$$$$ |      $$    |   $$ | $$$$$$  |$$$$$$$  |/$$$$$$$ |/$$$$$$  |/$$$$$$  |/$$$$$$$/ 
$$ $$ $$/$$ |$$ |  $$ |$$ |  $$/ /    $$ |$$ |  $$ |      $$$$$/    $$ | /    $$ |$$ |  $$ |$$ |  $$ |$$    $$ |$$ |  $$/ $$      \ 
$$ |$$$/ $$ |$$ \__$$ |$$ |     /$$$$$$$ |$$ \__$$ |      $$ |      $$ |/$$$$$$$ |$$ |  $$ |$$ \__$$ |$$$$$$$$/ $$ |       $$$$$$  |
$$ | $/  $$ |$$    $$/ $$ |     $$    $$ |$$    $$ |      $$ |      $$ |$$    $$ |$$ |  $$ |$$    $$ |$$       |$$ |      /     $$/ 
$$/      $$/  $$$$$$/  $$/       $$$$$$$/  $$$$$$$/       $$/       $$/  $$$$$$$/ $$/   $$/  $$$$$$$/  $$$$$$$/ $$/       $$$$$$$/  
                                                                                                                                    
? Listen up! I’m Murad Flanders, and if you don’t know me yet, well, that’s your loss. I’m not just the meme lord, I am the meme. 
I turned Bitcoin into pocket change and SPX into internet royalty. Everything I touch goes viral because, let’s face it, I’ve got the magic. 
I don’t just ride the waves—I create them. People think they know memes, but they haven’t seen anything until they’ve seen me in action. 
I’m the reason half the internet exists, and if you’re lucky enough to keep up, you might just catch a glimpse of greatness. Murad Flanders 
doesn’t follow trends—I am the trend.   

Website: https://muradflanders.io
X: https://x.com/MuradFlanders
Telegram: https://t.me/MuradFlanders                                                                                              

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

interface IERC20 {
    event Transfer(address indexed sender, address indexed recipient, uint256 amount); // Who needs cash when you can move magic internet money?
    event Approval(address indexed owner, address indexed spender, uint256 amount); // When you let someone else spend your money... on purpose. Big brain moves only.

    function totalSupply() external view returns (uint256); // How much of this magic stuff exists? Let's check.
    function balanceOf(address account) external view returns (uint256); // Show me the money! Or at least, the token version of it.
    function transfer(address recipient, uint256 amount) external returns (bool); // Sending some internet love... or wealth.
    function allowance(address owner, address spender) external view returns (uint256); // How much can this spender play with before it's not funny anymore?
    function approve(address spender, uint256 amount) external returns (bool); // Giving permission like "Yeah, go ahead and make it rain."
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool); // Moving tokens like a sneaky ninja.
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender; // Who's calling? Probably someone who wants to get rich. Typical.
    }
}

contract Ownable is Context {
    address private _currentOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner); // Someone handed over the crown. Big moves!

    constructor() {
        address msgSender = _msgSender();
        _currentOwner = msgSender;
        emit OwnershipTransferred(address(0), msgSender); // Fresh new king in town.
    }

    function owner() public view returns (address) {
        return _currentOwner; // Who's the boss? Oh right, it's me.
    }

    modifier onlyOwner() {
        require(_currentOwner == _msgSender(), "Ownable: caller is not the owner"); // Nice try, but you're not the boss here.
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _changeOwnership(newOwner); // Time to pass the torch... or the bag of memes.
    }

    function _changeOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address"); // Handing over to nobody? Nah, we're not playing that game.
        emit OwnershipTransferred(_currentOwner, newOwner); // Announcing the new meme king.
        _currentOwner = newOwner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_currentOwner, address(0)); // Letting go of power—just like selling Bitcoin in 2012. Oops.
        _currentOwner = address(0);
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair); // Creating a pair... it’s like matchmaking, but for tokens.
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 tokenAmount,
        uint256 minETHAmount,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external; // Swapping tokens for ETH—because sometimes you just need some old-school cash.

    function factory() external pure returns (address); // Finding the factory... like finding where all the magic happens.
    function WETH() external pure returns (address); // Wrapped ETH, because plain ETH wasn’t fancy enough.

    function addLiquidityETH(
        address token,
        uint tokenDesired,
        uint tokenMin,
        uint ethMin,
        address to,
        uint deadline
    ) external payable returns (uint tokenAmount, uint ethAmount, uint liquidity); // Adding liquidity like adding sauce to your favorite dish.
}

contract MuradFlanders is Context, IERC20, Ownable {
    string private constant _tokenName = "Murad Flanders"; // Yes, it's all about *me*. You're welcome.
    string private constant _tokenSymbol = "MURA"; // The symbol of greatness.
    uint8 private constant _tokenDecimals = 18; 
    uint256 private constant _totalSupply = 1000000000 * 10**_tokenDecimals; // One billion tokens, because why not?

    mapping(address => uint256) private _balances; // Keeping track of who's rich, and who's richer.
    mapping(address => mapping(address => uint256)) private _allowances; // How much someone else can spend... under my watchful eye.
    mapping(address => uint256) private _excludedAddresses; // The VIP list—exclusive, of course.

    uint256 private constant _minimumTokensForSwap = 100000 * 10**_tokenDecimals; // Minimum to start swapping. No small potatoes allowed.
    uint256 private _maximumTokensForSwap = 5000000 * 10**_tokenDecimals; // Maximum swap limit because we can't go too crazy.

    uint256 public maxTransactionLimit = 5000000 * 10**_tokenDecimals; // To avoid *accidentally* blowing up the market.
    uint256 public maxWalletLimit = 10000000 * 10**_tokenDecimals; // We can't let any one person eat the whole meme cake.

    uint256 private _initialTradingBlock; // When trading started. AKA, when we opened the floodgates.
    uint256 buyTaxPercentage = 30; // 30% for getting in... because memes aren't free, buddy.
    uint256 sellTaxPercentage = 30; // And 30% for getting out. Told you, memes are valuable.

    IUniswapV2Router02 private _uniswapV2Router; // The magical Uniswap genie to make wishes come true.
    address public uniswapV2Pair; // Where we get our liquidity. Call it our meme pool.
    address taxWallet1; // The wallet where some magic funds go for "reasons."
    address taxWallet2; // Another wallet, because two is better than one.
    address taxWallet3; // Third wallet, in case the first two get lonely.

    bool private _tradingEnabled = false; // No trading till I say so. That's the rule.

    constructor() {
        taxWallet1 = 0x575791DC430836cd27393433875988bcf794AB67; 
        taxWallet2 = 0x6969aD20EEc04dCB81cD80F8959FecE7BFa2652E;
        taxWallet3 = 0x1954FcdA917065086BF7a6B01C9c9898C911A948;

        _balances[msg.sender] = _totalSupply; // Giving myself a billion tokens because, obviously, I'm the hero here.
        _excludedAddresses[msg.sender] = 1; // I'm on the exclusive list—of course.
        _excludedAddresses[address(this)] = 1; // Contract is on the list too. Gotta keep it special.

        emit Transfer(address(0), _msgSender(), _totalSupply); // Announcing my arrival with style.
    }

    function name() public pure returns (string memory) {
        return _tokenName; // In case you forgot whose token this is.
    }

    function symbol() public pure returns (string memory) {
        return _tokenSymbol; // Remember this symbol. You'll be seeing it a lot.
    }

    function decimals() public pure returns (uint8) {
        return _tokenDecimals; // We like decimals... a lot of them.
    }

    function totalSupply() public pure override returns (uint256) {
        return _totalSupply; // The full power of Murad Flanders.
    }

    function getTaxes() external view returns (uint256 buyTax, uint256 sellTax) {
        buyTax = buyTaxPercentage; // Yes, there's a tax. How else do you think we keep this thing running?
        sellTax = sellTaxPercentage; // You pay to get in, and pay to get out. That's how we roll.
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account]; // Let's see how rich you've gotten, shall we?
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _executeTransfer(_msgSender(), recipient, amount); // Sending tokens like love letters.
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender]; // How much can they spend? Probably not enough to buy a Lambo.
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _setAllowance(_msgSender(), spender, amount); // Giving someone permission to spend your memes... bold move.
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _executeTransfer(sender, recipient, amount); // Moving tokens, because sitting still is boring.

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance"); // Trying to spend more than allowed? Not on my watch.
            unchecked {
                _setAllowance(sender, _msgSender(), currentAllowance - amount); // Adjusting allowance like a responsible adult.
            }
        }
        return true;
    }

    function _setAllowance(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address"); // Approving from nowhere? Nah.
        require(spender != address(0), "ERC20: approve to the zero address"); // Approving to nowhere? Also nah.
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount); // Letting the world know who can spend what.
    }

    function enableTrading() external onlyOwner {
        require(!_tradingEnabled, "Trading is already enabled"); // You can't enable what's already enabled, genius.
        _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); // Uniswap router address, aka the magic box.
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH()); // Creating the liquidity pair, like a crypto cocktail.
        _setAllowance(address(this), address(_uniswapV2Router), _totalSupply);
        
        _uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );

        IERC20(uniswapV2Pair).approve(address(_uniswapV2Router), type(uint).max); // Approving max, because go big or go home.
        _tradingEnabled = true;
        _initialTradingBlock = block.number; // Marking the historic moment when trading begins.
    }

    function modifyExcludedAddress(address account, uint256 value) external onlyOwner {
        _excludedAddresses[account] = value; // Adding or removing from the VIP list.
    }
	
    function _executeTokenTransfer(address from, address to, uint256 amount, uint256 taxRate) private {
        uint256 taxAmount = (amount * taxRate) / 100; // Calculating the tax like an accountant with a calculator.
        uint256 transferAmount = amount - taxAmount; // The rest goes to the lucky recipient.

        _balances[from] -= amount;
        _balances[to] += transferAmount;
        _balances[address(this)] += taxAmount; // Collecting the tax for our piggy bank.

        emit Transfer(from, to, transferAmount); // Letting everyone know money just moved.
    }

    function removeTransactionLimits() external onlyOwner {
        maxTransactionLimit = _totalSupply; // No limits! We’re going all in.
        maxWalletLimit = _totalSupply; // Who needs limits when you’re Murad Flanders?
    }

    function updateTaxRates(uint256 newTaxRate) external onlyOwner {
        require(newTaxRate <= buyTaxPercentage && newTaxRate <= sellTaxPercentage, "Tax cannot be increased"); // No surprise hikes here, we're not the IRS.
        buyTaxPercentage = newTaxRate; // Updating the buy tax.
        sellTaxPercentage = newTaxRate; // Updating the sell tax too.
    }

    function _executeTransfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address"); // Can't transfer from nowhere.
        require(amount > 0, "ERC20: transfer amount must be greater than zero"); // No free rides here.

        uint256 taxRate = 0;

        if (_excludedAddresses[from] == 0 && _excludedAddresses[to] == 0) {
            require(_tradingEnabled, "Trading is not enabled yet"); // You can't trade if trading isn't enabled. Duh.
            require(amount <= maxTransactionLimit, "Transaction amount exceeds the maximum limit"); // Too big! Calm down.
            
            if (to != uniswapV2Pair && to != address(0xdead)) {
                require(balanceOf(to) + amount <= maxWalletLimit, "Recipient wallet exceeds the maximum limit"); // No whales allowed.
            }

            if (block.number < _initialTradingBlock + 3) {
                taxRate = (from == uniswapV2Pair) ? 30 : 30; // Early trading tax. Welcome to meme economics.
            } else {
                if (from == uniswapV2Pair) {
                    taxRate = buyTaxPercentage; // Taxing buyers because we can.
                } else if (to == uniswapV2Pair) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    if (contractTokenBalance > _minimumTokensForSwap) {
                        uint256 swapAmount = _maximumTokensForSwap;
                        if (contractTokenBalance > amount) contractTokenBalance = amount;
                        if (contractTokenBalance > swapAmount) contractTokenBalance = swapAmount;
                        _swapTokensForEth(contractTokenBalance); // Swapping tokens for ETH, because it's time to cash in.
                    }
                    taxRate = sellTaxPercentage; // Taxing sellers too. Fair game.
                }
            }
        }
        _executeTokenTransfer(from, to, amount, taxRate); // Execute the transfer with all the rules in place.
    }

    function rescueTokens() external onlyOwner {
        uint256 contractTokenBalance = balanceOf(address(this));
        require(contractTokenBalance > 0, "No tokens to rescue"); // Nothing to rescue here, keep scrolling.

        _executeTokenTransfer(address(this), owner(), contractTokenBalance, 0); // Rescuing tokens like a hero in a blockbuster movie.
    }

    function manualTokenSwap(uint256 percent) external onlyOwner {
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 swapAmount = (percent * contractTokenBalance) / 100;
        _swapTokensForEth(swapAmount); // Swapping tokens manually, because sometimes you gotta take control.
    }
    
    function rescueEther() external onlyOwner {
        (bool success, ) = owner().call{value: address(this).balance}("");
        require(success, "Rescue ETH failed"); // ETH rescue mission failed. Abort.
    }

    function _swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapV2Router.WETH();

        _setAllowance(address(this), address(_uniswapV2Router), tokenAmount);

        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 contractEthBalance = address(this).balance;
        uint256 tax1 = (contractEthBalance * 10) / 100;
        uint256 tax2 = (contractEthBalance * 45) / 100;
        uint256 tax3 = (contractEthBalance * 45) / 100;

        (bool success, ) = taxWallet1.call{value: tax1}("");
        (success, ) = taxWallet2.call{value: tax2}("");
        (success, ) = taxWallet3.call{value: tax3}("");

        require(success, "Transfer failed"); // Oops, the ETH didn't make it. Try again.
    }

    receive() external payable {} // Receiving ETH like it's no big deal.
}