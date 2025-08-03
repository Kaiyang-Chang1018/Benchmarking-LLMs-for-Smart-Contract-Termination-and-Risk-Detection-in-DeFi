// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

contract HugeONE is IERC20 {
    string public name = "Huge ONE";
    string public symbol = "HUGE1";
    uint256 public totalSupply = 1 * 10**18; // 1 token with 18 decimals
    uint8 public decimals = 18;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
    
    address public taxDestination;
    mapping(address => bool) public exemptFromTax;

    address public contractOwner;

    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Only contract owner can call this function");
        _;
    }

    constructor(address _taxDestination) {
        balances[msg.sender] = totalSupply;
        taxDestination = _taxDestination;
        exemptFromTax[msg.sender] = true; // Deploying wallet is exempt from tax
        contractOwner = msg.sender;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return balances[account];
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        uint256 currentAllowance = allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        
        _transfer(sender, recipient, amount);
        
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }

        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return allowances[owner][spender];
    }

    function whitelist(address wallet) external onlyOwner {
        exemptFromTax[wallet] = true;
    }

    function removeWhitelist(address wallet) external onlyOwner {
        exemptFromTax[wallet] = false;
    }

    function setTaxDestination(address _taxDestination) external onlyOwner {
        taxDestination = _taxDestination;
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(balances[sender] >= amount, "ERC20: transfer amount exceeds balance");

        uint256 taxAmount = 0;
        uint256 amountAfterTax = amount;

        if (!exemptFromTax[sender] && !exemptFromTax[recipient]) {
            // Apply tax if neither sender nor recipient is exempt
            taxAmount = (amount * 2) / 100; // 2% tax
            amountAfterTax = amount - taxAmount;
        }

        balances[sender] -= amount;
        balances[recipient] += amountAfterTax;
        balances[taxDestination] += taxAmount;

        emit Transfer(sender, recipient, amountAfterTax);
        emit Transfer(sender, taxDestination, taxAmount);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}