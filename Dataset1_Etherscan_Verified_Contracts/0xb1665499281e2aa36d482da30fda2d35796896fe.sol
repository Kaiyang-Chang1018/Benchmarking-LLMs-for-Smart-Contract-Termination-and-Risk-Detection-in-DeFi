// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV3Router {
    function swapExactTokensForETH(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external returns (uint[] memory amounts);
    
    function getWETH() external pure returns (address);
}

contract PupWithCap {
    string public constant name = "PupWithCap";
    string public constant symbol = "PUPWITHCAP";
    uint8 public constant decimals = 18;
    uint256 public constant totalSupply = 1_000_000 * (10 ** uint256(decimals));
    uint256 public constant maxWalletHold = totalSupply / 100; // 1% of total supply
    uint256 private constant buyTaxRate = 1; // 1% buy tax
    uint256 private constant sellTaxRate = 4; // 4% sell tax
    uint256 private constant initialTaxRate = 50; // 50% initial tax rate
    uint256 private constant initialTaxPeriod = 8 minutes; // Initial tax period
    address private immutable _taxRecipient = 0x493C0D9dc09cD5Ed50d55c99C604EBf71fd90558; // Tax recipient address
    address private immutable _uniswapV3Router = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45; // Uniswap v3 router address
    address private _owner;
    uint256 private immutable _startTime;
    
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    constructor() {
        _owner = msg.sender;
        _balances[msg.sender] = totalSupply;
        _startTime = block.timestamp;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);
        return true;
    }
    
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(amount <= _maxTxAmount(), "Transfer amount exceeds the maxTxAmount.");

        uint256 transferAmount = _applyTax(sender == _uniswapV3Router, sender == _uniswapV3Router, amount);

        _balances[sender] -= amount;
        _balances[recipient] += transferAmount;
        
        emit Transfer(sender, recipient, transferAmount);
    }
    
    function _maxTxAmount() private pure returns (uint256) {
        return maxWalletHold;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function _applyTax(bool isBuying, bool isSelling, uint256 amount) private returns (uint256) {
        if (block.timestamp <= _startTime + initialTaxPeriod) {
            uint256 initialTaxAmount = amount * initialTaxRate / 100;
            _transferToTaxRecipient(initialTaxAmount);
            amount -= initialTaxAmount;
        }
        
        if (isBuying) {
            uint256 taxAmount = amount * buyTaxRate / 100;
            _transferToTaxRecipient(taxAmount);
            return amount - taxAmount;
        } else if (isSelling) {
            uint256 taxAmount = amount * sellTaxRate / 100;
            _transferToTaxRecipient(taxAmount);
            return amount - taxAmount;
        }
        return amount;
    }
    
    function _transferToTaxRecipient(uint256 amount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = IUniswapV3Router(_uniswapV3Router).getWETH(); // Updated to use getWETH() instead of WETH()

        _approve(address(this), _uniswapV3Router, amount);
        IUniswapV3Router(_uniswapV3Router).swapExactTokensForETH(
            amount, 
            0, 
            path, 
            _taxRecipient, 
            block.timestamp + 3600
        );
    }

    // Renounce ownership
    function renounceOwnership() external {
        require(msg.sender == _owner, "Only the owner can call this function");
        _owner = address(0);
    }
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}