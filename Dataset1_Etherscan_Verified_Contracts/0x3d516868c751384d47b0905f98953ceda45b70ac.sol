// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Uniswap Interfaces
interface IUniswapV2Router02 {
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function WETH() external pure returns (address);

    function factory() external pure returns (address);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

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

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract MattFurryToken is Context, IERC20, Ownable {
    string private _name = "Matt Furry";
    string private _symbol = "$Furry";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 1000000 * 10**uint(_decimals);
    uint256 private _taxFee = 10; // 10% initial tax fee
    uint256 private _previousTaxFee = _taxFee;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;

    constructor(address routerAddress) {
        _balances[_msgSender()] = _totalSupply;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        uniswapV2Router = IUniswapV2Router02(routerAddress);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function setTaxFeePercent(uint256 taxFee) external onlyOwner {
        require(taxFee <= 10, "Tax fee must be less than or equal to 10%");
        _taxFee = taxFee;
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function LaunchEvent(
        uint256 tokenAmount,
        uint256 ethAmountForLiquidity,
        address[] calldata recipients,
        uint256 ethAmountPerRecipient
    ) external onlyOwner payable {
        require(recipients.length * ethAmountPerRecipient == msg.value - ethAmountForLiquidity, "Incorrect ETH amount sent");

        // Add liquidity
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmountForLiquidity}(
            address(this),
            tokenAmount,
            0,
            0,
            owner(),
            block.timestamp
        );

        // Buy tokens for each recipient
        for (uint256 i = 0; i < recipients.length; i++) {
            address[] memory path = new address[](2);
            path[0] = uniswapV2Router.WETH();
            path[1] = address(this);

            uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethAmountPerRecipient}(
                0,
                path,
                recipients[i],
                block.timestamp
            );
        }
    }

    function EventComplete(uint256 liquidity) external onlyOwner {
        IERC20 liquidityToken = IERC20(uniswapV2Pair);
        liquidityToken.approve(address(uniswapV2Router), liquidity);

        uniswapV2Router.removeLiquidityETH(
            address(this),
            liquidity,
            0, // minimum amount of tokens to receive
            0, // minimum amount of ETH to receive
            owner(),
            block.timestamp
        );
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount <= _balances[sender], "ERC20: transfer amount exceeds balance");

        uint256 fee = 0;
        if (!_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient]) {
            fee = amount * _taxFee / 100;
        }

        uint256 transferAmount = amount - fee;
        _balances[sender] -= amount;
        _balances[recipient] += transferAmount;
        if (fee > 0) {
            _balances[address(this)] += fee;
            emit Transfer(sender, address(this), fee);
        }
        emit Transfer(sender, recipient, transferAmount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}