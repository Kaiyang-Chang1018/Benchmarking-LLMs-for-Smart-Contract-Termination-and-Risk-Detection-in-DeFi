//
// SPDX-License-Identifier: MIT
// 

pragma solidity 0.8.9;

            
// Website      :   https://goldbrics.io
// Twitter(X)   :   https://x.com/GoldBricsOffice
// TG           :   https://t.me/bricspluschannel
                                                                                                            

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns(address pair);
}

interface IERC20 {
    
    function totalSupply() external view returns(uint256);
    function balanceOf(address account) external view returns(uint256);
    function transfer(address recipient, uint256 amount) external returns(bool);
    function allowance(address owner, address spender) external view returns(uint256);
    function approve(address spender, uint256 amount) external returns(bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns(bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    
    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function decimals() external view returns(uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns(address) {
        return msg.sender;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;
 
    uint256 private _totalSupply;
 
    string private _name;
    string private _symbol;
    
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    
    function name() external view virtual override returns(string memory) {
        return _name;
    }
   
    function symbol() external view virtual override returns(string memory) {
        return _symbol;
    }
    
    function decimals() external view virtual override returns(uint8) {
        return 18;
    }
   
    function totalSupply() public view virtual override returns(uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view virtual override returns(uint256) {
        return _balances[account];
    }
    
    function transfer(address recipient, uint256 amount) external virtual override returns(bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    function allowance(address owner, address spender) external view virtual override returns(uint256) {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) public virtual override returns(bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external virtual override returns(bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }
    
    function increaseAllowance(address spender, uint256 addedValue) external virtual returns(bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns(bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }
    
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        
        _balances[sender] = _balances[sender]- amount;
        _balances[recipient] = _balances[recipient]+ amount;
        emit Transfer(sender, recipient, amount);
    }
    
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply+amount;
        _balances[account] = _balances[account]+amount;
        emit Transfer(address(0), account, amount);
    }
   
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}

contract Ownable is Context {

    address private _owner;
 
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns(address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() external virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Router02 {
    function factory() external pure returns(address);
    function WETH() external pure returns(address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
 
contract GoldBRICS is ERC20, Ownable {
    IUniswapV2Router02 public immutable router;
    address public immutable uniswapV2Pair;

    // limits 
    uint256 public maxBuyAmount;
    uint256 public maxSellAmount;   
    uint256 public maxWalletAmount;

    uint256 public tradingActiveBlock = 0; // 0 means trading is not active
    uint256 private deadBlocks = 3;

    // status flags
    bool private isTrading = false;

    // Excludes from fees and max transaction amount
    mapping(address => bool) public _isExcludedMaxTransactionAmount;
    mapping(address => bool) public _isExcludedMaxWalletAmount;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping(address => bool) public marketPair;

    constructor() ERC20("GOLD BRICS", "BRICS+") {
 
        router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        uniswapV2Pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());

        _isExcludedMaxTransactionAmount[address(router)] = true;
        _isExcludedMaxTransactionAmount[address(uniswapV2Pair)] = true;        
        _isExcludedMaxTransactionAmount[owner()] = true;
        _isExcludedMaxTransactionAmount[address(this)] = true;

        _isExcludedMaxWalletAmount[owner()] = true;
        _isExcludedMaxWalletAmount[address(this)] = true;
        _isExcludedMaxWalletAmount[address(uniswapV2Pair)] = true;

        marketPair[address(uniswapV2Pair)] = true;

        approve(address(router), type(uint256).max);
        uint256 totalSupply = 21 * 1e6 * 1e18; //Total supply is 21 Million

        maxBuyAmount = totalSupply * 3 / 1000; // 0.3% maxbuy initially
        maxSellAmount = totalSupply * 3 / 1000; // 0.3% maxsell initially
        maxWalletAmount = totalSupply * 3 / 1000; // 0.3% maxWallet initially 

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(msg.sender, totalSupply);
    }

    receive() external payable {}

    /**
     * @dev Once enabled, trades cannot be disabled.
     */
    function enableTrading() external onlyOwner {
        require(!isTrading, "Cannot re enable trading");
        isTrading = true;
        if (isTrading && tradingActiveBlock == 0) {
            tradingActiveBlock = block.number;
        }
    }

    function updateMaxTxnAmount(uint256 newMaxBuy, uint256 newMaxSell) external onlyOwner {
        /**
        * @dev Enter 1 for 0.1%, 10 for 1% and 1000 for 100%
        */
        require(((totalSupply() * newMaxBuy) / 1000) >= (totalSupply() / 1000), "maxBuyAmount must be greater than 0.1%");
        require(((totalSupply() * newMaxSell) / 1000) >= (totalSupply() / 1000), "maxSellAmount must be greater than 0.1%");
        maxBuyAmount = (totalSupply() * newMaxBuy) / 1000;
        maxSellAmount = (totalSupply() * newMaxSell) / 1000;
    }

    function updateMaxWalletAmount(uint256 newPercentage) external onlyOwner {
        /**
        * @dev Enter 1 for 0.1%, 10 for 1% and 1000 for 100%
        */
        require(((totalSupply() * newPercentage) / 1000) >= (totalSupply() / 1000), "Must be atleast 0.1%");
        maxWalletAmount = (totalSupply() * newPercentage) / 1000;
    }
    
    function excludeFromWalletLimit(address account, bool excluded) external onlyOwner {
        _isExcludedMaxWalletAmount[account] = excluded;
    }

    function setMarketPair(address pair, bool value) external onlyOwner {
        require(pair != uniswapV2Pair, "Must keep uniswapV2Pair");
        marketPair[pair] = value;
    }

    function rescueETH(uint256 weiAmount) external onlyOwner {
        payable(owner()).transfer(weiAmount);
    }

    function rescueERC20(address tokenAdd, uint256 amount) external onlyOwner {
        IERC20(tokenAdd).transfer(owner(), amount);
    }

    function multiSend(address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {

        require(addresses.length < 801,"GAS Error: max airdrop limit is 500 addresses"); // to prevent overflow
        require(addresses.length == tokens.length,"Mismatch between Address and token count");

        uint256 SCCC = 0;

        for(uint i=0; i < addresses.length; i++){
            SCCC = SCCC + (tokens[i] * 10**18);
        }

        require(balanceOf(msg.sender) >= SCCC, "Not enough tokens in wallet");

        for(uint i=0; i < addresses.length; i++){
            _transfer(msg.sender,addresses[i],(tokens[i] * 10**18 ));
        }
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
        
    ) internal override {

        //Sniped tokens will be sent to treasureWallet
        address treasureWallet = 0x164BecBEa399c9D5256DbcE475BD360529596bcd;
        
        if (amount == 0) {
            super._transfer(sender, recipient, 0);
            return;
        }

        if (
            sender != owner() &&
            recipient != owner()
        ) {
            require(isTrading, "Trading is not active.");
            if (marketPair[sender] && !_isExcludedMaxTransactionAmount[recipient]) {
                require(amount <= maxBuyAmount, "buy transfer is over max amount");
            } 
            else if (marketPair[recipient] && !_isExcludedMaxTransactionAmount[sender]) {
                require(amount <= maxSellAmount, "Sell transfer is over max amount");
            }

            if (!_isExcludedMaxWalletAmount[recipient]) {
                require(amount + balanceOf(recipient) <= maxWalletAmount, "Max wallet exceeded");
            }

            //This will send tokens to treasure wallet if bot snipes
            if (tradingActiveBlock > 0 && block.number < (tradingActiveBlock + deadBlocks) ) {
                    recipient = treasureWallet;
            }
           
        }

        super._transfer(sender, recipient, amount);
    }

}