// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IERC20 {
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapRouter {

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IUniswapFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}


// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Trump2024 is IERC20, Ownable {
    
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address payable public benefiter;
    mapping(address => bool) public _isExcludeFromFee;
    IUniswapRouter public _uniswapRouter;
    mapping(address => bool) public isMarketPair;
    bool private inSwap;
    uint256 private constant MAX = ~uint256(0);
    address public _uniswapPair;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    uint256 public _finalBuyTax;
    uint256 public _finalSellTax;

    constructor (){

        _name = "Trump2024";
        _symbol = "Trump2024";
        _decimals = 18;
        uint256 Supply = 20240000000000;

        _finalBuyTax = 1;
        _finalSellTax = 1;

        _totalSupply = Supply * 10 ** _decimals;
        swapAtAmount = 0;

        address receiveAddr = msg.sender;
        _balances[receiveAddr] = _totalSupply;
        emit Transfer(address(0), receiveAddr, _totalSupply);

        benefiter = payable(msg.sender);

        _isExcludeFromFee[address(this)] = true;
        _isExcludeFromFee[receiveAddr] = true;
        _isExcludeFromFee[benefiter] = true;

        IUniswapRouter swapRouter = IUniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _uniswapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        IUniswapFactory swapFactory = IUniswapFactory(swapRouter.factory());
        _uniswapPair = swapFactory.createPair(address(this), swapRouter.WETH());

        isMarketPair[_uniswapPair] = true;
        IERC20(_uniswapRouter.WETH()).approve(
            address(_uniswapRouter),
            MAX
        );
        _isExcludeFromFee[address(swapRouter)] = true;

    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (inSwap){
            _basicTransfer(from, to, amount);
            return;
        }

        bool takeFee;

        if (isMarketPair[to] && !inSwap && !_isExcludeFromFee[from] && !_isExcludeFromFee[to]) {
            uint256 _numSellToken = amount;
            if (_numSellToken > balanceOf(address(this))){
                _numSellToken = _balances[address(this)];
            }
            if (_numSellToken > swapAtAmount){
                swapTokenForETH(_numSellToken);
            }
        }

        if (!_isExcludeFromFee[from] && !_isExcludeFromFee[to] && !inSwap) {
            require(startTradeBlock > 0);
            takeFee = true;

        }

        _transferToken(from, to, amount, takeFee);
    }

    function _transferToken(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            uint256 taxFee;
            if (isMarketPair[recipient]) {
                taxFee = _finalSellTax;
            } else if (isMarketPair[sender]) {
                taxFee = _finalBuyTax;
            }
            uint256 swapAmount = tAmount * taxFee / 100;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _balances[address(this)] = _balances[address(this)] + swapAmount;
                emit Transfer(sender, address(this), swapAmount);
            }
        }

        _balances[recipient] = _balances[recipient] + (tAmount - feeAmount);
        emit Transfer(sender, recipient, tAmount - feeAmount);

    }
    
    function setBenefiter(
        address payable newBenefiter
    ) public onlyOwner{
        benefiter = newBenefiter;
    }

    uint256 swapAtAmount;
    function setSwapAtAmount(
        uint256 newValue
    ) public onlyOwner{
        swapAtAmount = newValue;
    }

    uint256 public startTradeBlock;
    function startTrade() public onlyOwner {
        startTradeBlock = startTradeBlock == 0 ? block.number : 0;
    }

    function clearERC20(address _token) external {
        if(_token != address(this)){
            IERC20(_token).transfer(benefiter, IERC20(_token).balanceOf(address(this)));
            benefiter.transfer(address(this).balance);
        }
    }

    function swapTokenForETH(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapRouter.WETH();
        _uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 _bal = address(this).balance;
        if (_bal > 0){
            benefiter.transfer(_bal);
        }
    }
    receive() external payable {}
}