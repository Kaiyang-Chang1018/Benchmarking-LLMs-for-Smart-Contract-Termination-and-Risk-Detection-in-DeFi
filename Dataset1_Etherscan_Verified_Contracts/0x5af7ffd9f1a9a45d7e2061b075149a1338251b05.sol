pragma solidity ^0.8.20;

interface IEERC515 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event AddLiquidity(uint32 _blockToUnlockLiquidity, uint256 value);
    event RemoveLiquidity(uint256 value);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out
    );
}

abstract contract ERC515 is IEERC515{
    mapping(address account => uint256) private _balances;

    uint256 private _totalSupply;
    uint256 public _maxWallet;
    uint32 public blockToUnlockLiquidity;

    string private _name;
    string private _symbol;

    address public owner;
    address public liquidityProvider;

    bool public tradingEnable;
    bool public liquidityAdded;
    bool public maxWalletEnable;

    mapping(address account => uint32) private lastTransaction;
    
    uint256 public mintedTokens;
    uint256 public tokenPrice; 
    uint256 public mintingLimit;

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyLiquidityProvider() {
        require(msg.sender == liquidityProvider, "You are not the liquidity provider");
        _;
    }

    uint256 public launchBlock;

    uint256 public buyFee;
    uint256 public saleFee;
    address public feeAddress;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_,
        uint256 tokenPrice_,
        uint256 mintingLimit_,
        uint256 buyFee_,
        uint256 saleFee_
    ) {
        _name = name_;
        _symbol = symbol_;
        _totalSupply = totalSupply_;
        _maxWallet = totalSupply_ / 40;
        tokenPrice = tokenPrice_;
        mintingLimit = mintingLimit_;
        owner = msg.sender;
        tradingEnable = false;
        maxWalletEnable = true;
        liquidityAdded = false;
        _balances[address(this)] = totalSupply_;

        launchBlock = block.number;

        buyFee = buyFee_;
        saleFee = saleFee_;
        feeAddress = msg.sender;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) public virtual returns (bool) {
        // sell or transfer
        if (to == address(this)) {
            sell(value);
        }
        else{
            _transfer(msg.sender, to, value);
        }
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal virtual {
        if(from != address(this)){
            require(lastTransaction[msg.sender] != block.number, "You can't make two transactions in the same block");
            lastTransaction[msg.sender] = uint32(block.number);
        }
        require (_balances[from] >= value, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = _balances[from] - value;
        }
        if (to == address(0)) {
            unchecked {
                _totalSupply -= value;
            }
        } else {
            unchecked {
                _balances[to] += value;
            }
        }
        emit Transfer(from, to, value);
    }

    function getReserves() public view returns (uint256, uint256) {
        return (address(this).balance, _balances[address(this)]);
    }

    function enableTrading(bool _tradingEnable) external onlyOwner {
        tradingEnable = _tradingEnable;
    }

    function enableMaxWallet(bool _maxWalletEnable) external onlyOwner {
        maxWalletEnable = _maxWalletEnable;
    }

    function setMaxWallet(uint256 _maxWallet_) external onlyOwner {
        _maxWallet = _maxWallet_;
    }

    function renounceOwnership() external onlyOwner {
        owner = address(0);
    }

    function addLiquidity(uint32 _blockToUnlockLiquidity) internal  {
        require(liquidityAdded == false, "Liquidity already added");
        liquidityAdded = true;
        uint256 etherAmount = address(this).balance;
        require(etherAmount > 0, "No ETH balance");
        blockToUnlockLiquidity = _blockToUnlockLiquidity;
        tradingEnable = true;
        liquidityProvider = owner;
        
        emit AddLiquidity(_blockToUnlockLiquidity, etherAmount);
    }

    function removeLiquidity() public onlyLiquidityProvider {
        require(block.number > blockToUnlockLiquidity, "Liquidity locked");
        tradingEnable = false;
        payable(msg.sender).transfer(address(this).balance);
        emit RemoveLiquidity(address(this).balance);
    }

    function extendLiquidityLock(uint32 _blockToUnlockLiquidity) public onlyLiquidityProvider {
        blockToUnlockLiquidity = _blockToUnlockLiquidity;
    }

    function getAmountOut(uint256 value, bool _buy) public view returns(uint256) {
        if (!tradingEnable) {
            return tokenPrice * value / 1 ether;
        }else{
            (uint256 reserveETH, uint256 reserveToken) = getReserves();

            if (_buy) {
                return (value * reserveToken) / (reserveETH + value);
            } else {
                return (value * reserveETH) / (reserveToken + value);
            }
        }
    }

    function buy(uint256 _minAmount) public payable {
        require(msg.value > 0, "No ETH sent");
        if (!tradingEnable) {
            uint256 tokensToMint = (tokenPrice * msg.value)  / 1 ether;
            require(tokensToMint > 0, "Not enough ETH sent");
            if (maxWalletEnable) {
                require(tokensToMint + _balances[msg.sender] <= _maxWallet, "Max wallet exceeded");
            }
            mintedTokens += tokensToMint;
            _transfer(address(this), msg.sender, tokensToMint);
            if (mintedTokens >= mintingLimit) {
                _addLiquidityAndEnableTrading();
            }
        } else {
            uint256 token_amount = (msg.value * _balances[address(this)]) / (address(this).balance + msg.value);
            if (maxWalletEnable) {
                require(token_amount + _balances[msg.sender] <= _maxWallet, "Max wallet exceeded");
            }
            if (buyFee > 0) {
                uint256 fee = (token_amount * buyFee) / 100;
                token_amount -= fee;
                _transfer(address(this), address(0), fee);
            }
            require(token_amount >= _minAmount, "Slippage too high");
            _transfer(address(this), msg.sender, token_amount);
            emit Swap(msg.sender, msg.value,0,0,token_amount);
        }
    }

    function _addLiquidityAndEnableTrading() internal {
        uint32 blockToUnlock = uint32(block.number + 200000);
        addLiquidity(blockToUnlock);
    }

    function sell(uint256 sell_amount) internal {
        if (block.number >= launchBlock + 200000 && !tradingEnable) {
            uint256 ethAmount = sell_amount /  tokenPrice;
            require(address(this).balance >= ethAmount, "Insufficient ETH in reserves");
            _transfer(msg.sender, address(this), sell_amount);
            payable(msg.sender).transfer(ethAmount);
            emit Swap(msg.sender, 0, sell_amount, ethAmount, 0);
        } else {
            require(tradingEnable, "Trading not enable");
            uint256 ethAmount = getAmountOut(sell_amount, false);
            require(ethAmount > 0, "Sell amount too low");
            require(address(this).balance >= ethAmount, "Insufficient ETH in reserves");
            if(saleFee > 0){
                uint256 feeEth = (ethAmount * saleFee) / 100;
                ethAmount -= feeEth;
                uint256 feeAddressPortion = (feeEth * 20) / 100;
                payable(feeAddress).transfer(feeAddressPortion);
            }
            _transfer(msg.sender, address(this), sell_amount);
            payable(msg.sender).transfer(ethAmount);
            emit Swap(msg.sender, 0, sell_amount, ethAmount, 0);
        }
    }

    receive() external payable {
        buy(0);
    }
}


contract Elegant is ERC515 {
    uint256 private _totalSupply = 10000000 * 10 ** 18;
    uint256 private tokenPrice_ = 250000 * 10 ** 18;
    uint256 private mintingLimit_ = 5000000 * 10 ** 18;
    constructor() ERC515("Elegant", "ELE", _totalSupply,tokenPrice_,mintingLimit_,1,1) {}
}