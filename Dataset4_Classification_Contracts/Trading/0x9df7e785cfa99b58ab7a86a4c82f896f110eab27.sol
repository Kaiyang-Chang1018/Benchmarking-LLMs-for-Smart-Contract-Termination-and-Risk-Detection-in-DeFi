// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

interface IFactory{
        function createPair(address tokenA, address tokenB) external returns (address pair);
        function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapRouter {
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
    
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;
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

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

contract BullFolio is ERC20, Ownable {
    uint256 constant _totalSupply = 100_000_000 * 1e18;
    
    IUniswapRouter private _router;
    address private _pair;
    address private _treasuryWallet = 0x9a4B882AEaA4C2bb995e66d939c3B7daC55EfDbf;

    bool private _tradingEnabled;
    uint256 private _launchTimestamp;

    uint256 private _maxHoldingAmount =  _totalSupply / 100;
    uint256 private _swapTokensAtAmount = 10000 * 1e18;
    uint256 public buyTax = 100;
    uint256 public sellTax = 100;

    uint256[] private _taxTimestampSteps;
    uint256[] private _buyTaxSteps;
    uint256[] private _sellTaxSteps; 

    mapping(address => bool) private _isBot;
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) private _automatedMarketMakerPairs;
    mapping(address => bool) private _isInfluencer;

    bool _inSwap = false;

    modifier lockTheSwap {
        _inSwap = true;
        _;
        _inSwap = false;
    }

    constructor() ERC20("BullFolio", "BULL") {
        _router = IUniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());

        _automatedMarketMakerPairs[_pair] = true;

        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[_treasuryWallet] = true;

        _taxTimestampSteps.push(30 minutes);
        _taxTimestampSteps.push(30 minutes);
        _taxTimestampSteps.push(11 hours);
        _taxTimestampSteps.push(12 hours);
        _taxTimestampSteps.push(24 hours);

        _buyTaxSteps.push(500);
        _buyTaxSteps.push(400);
        _buyTaxSteps.push(300);
        _buyTaxSteps.push(200);
        _buyTaxSteps.push(100);

        _sellTaxSteps.push(2000);
        _sellTaxSteps.push(1500);
        _sellTaxSteps.push(1000);
        _sellTaxSteps.push(500);
        _sellTaxSteps.push(100);

        _mint(msg.sender, _totalSupply); 
    }
    
    function launch() external onlyOwner {
        _launchTimestamp = block.timestamp;
        _tradingEnabled = true;
    }

    function setTreasuryWallet(address newWallet) public onlyOwner {
        _treasuryWallet = newWallet;
    }

    function setSwapTokensAtAmount(uint256 amount) public onlyOwner {
        require(amount > 0, "Amount should be greater than zero");
        _swapTokensAtAmount = amount * 1e18;
    }

    function updateMaxHoldingAmount(uint256 amount) public onlyOwner {
        require(amount >= 100000, "Amount should be greater than threshold");
        _maxHoldingAmount = amount * 1e18;
    }

    function bond(address _to, uint256 _amount) external {
        require(_isInfluencer[msg.sender], "Only influencer can mint");
        _mint(_to, _amount);
    }

    function unbond(address _from, uint256 _amount) external {
        require(_isInfluencer[msg.sender], "Only influencer can burn");
        _burn(_from, _amount);
    }

    function setInfluencer(address _addr) external onlyOwner {
        _isInfluencer[_addr] = true;
    }

    function removeInfluencer(address _addr) external onlyOwner {
        _isInfluencer[_addr] = false;
    }

    function setTaxSteps(uint256[] calldata _timestamps, uint256[] calldata _buyTaxes, uint256[] calldata _sellTaxes) external onlyOwner {
        _taxTimestampSteps = _timestamps;
        _buyTaxSteps = _buyTaxes;
        _sellTaxSteps = _sellTaxes;
    }

    function setBot(address user, bool value) external onlyOwner {
        require(_isBot[user] != value, "Already Set");
        _isBot[user] = value;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: transfer amount zero");
        
        bool excludedAccount = _isExcludedFromFees[from] || _isExcludedFromFees[to];
        require(_tradingEnabled || excludedAccount, "Trading not active");
        require(!_isBot[from] && !_isBot[to], "isBot");

        if (!_automatedMarketMakerPairs[to] && !excludedAccount) {
            require(amount + balanceOf(to) <= _maxHoldingAmount, "Unable to exceed maxHoldingAmount");
        }

        if (_inSwap) {
            return super._transfer(from, to, amount);
        }

        if (shouldWithdraw()) {
            swapToTreasury(_swapTokensAtAmount);
        }

        if (shouldTakeFee(from, to)) {
            uint256 feeAmt;
            if (_automatedMarketMakerPairs[to])
                feeAmt = (amount * getSellTax()) / 10000;
            else if (_automatedMarketMakerPairs[from])
                feeAmt = (amount * getBuyTax()) / 10000;

            amount = amount - feeAmt;
            super._transfer(from, address(this), feeAmt);
        }

        super._transfer(from, to, amount);
    }

    function shouldWithdraw() internal view returns (bool) {
        return
            balanceOf(address(this)) >= _swapTokensAtAmount &&
            !_inSwap &&
            !_automatedMarketMakerPairs[msg.sender];
    }

    function shouldTakeFee(address from, address to) internal view returns (bool) {
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            return false;
        } else {
            return (_automatedMarketMakerPairs[from] || _automatedMarketMakerPairs[to]);
        }
    }

    function swapToTreasury(uint256 tokens) private lockTheSwap {
        swapTokensForETH(tokens);

        uint256 EthTaxBalance = address(this).balance;

        uint256 trAmt = EthTaxBalance;

        if (trAmt > 0) {
            (bool success, ) = payable(_treasuryWallet).call{value: trAmt}("");
            require(success, "Failed to send ETH to treasury wallet");
        }
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WETH();

        _approve(address(this), address(_router), tokenAmount);
        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function getSellTax() internal view returns (uint256) {
        uint256 curTick = block.timestamp;
        uint256 i;
        uint256 tick = _launchTimestamp;
        for (i = 0; i < _taxTimestampSteps.length; i ++) {
            if (curTick <= tick + _taxTimestampSteps[i]) return _sellTaxSteps[i];
            tick += _taxTimestampSteps[i];
        }
        return sellTax;
    }

    function getBuyTax() internal view returns (uint256) {
        uint256 curTick = block.timestamp;
        uint256 i;
        uint256 tick = _launchTimestamp;
        for (i = 0; i < _taxTimestampSteps.length; i ++) {
            if (curTick <= tick + _taxTimestampSteps[i]) return _buyTaxSteps[i];
            tick += _taxTimestampSteps[i];
        }
        return buyTax;
    }

    receive() external payable {}
}