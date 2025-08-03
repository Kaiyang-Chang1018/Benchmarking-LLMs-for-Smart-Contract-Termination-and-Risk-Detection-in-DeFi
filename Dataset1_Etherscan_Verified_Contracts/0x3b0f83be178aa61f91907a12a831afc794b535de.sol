// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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

interface IUniswapRouter {
    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

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
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IUniswapFactory {
    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "you are not owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ERC20 is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private fundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _isExcludeFromFee;

    uint256 private _totalSupply;

    IUniswapRouter public _uniswapRouter;

    mapping(address => bool) public isMarketPair;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);

    address public _uniswapPair;
    uint256 public startTradeTimeStamp;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _name = "XMUSIC";
        _symbol = "XMUSIC";
        _decimals = 9;
        uint256 Supply = 460000000000;
        _totalSupply = Supply * 10 ** _decimals;

        address receiveAddr = 0x3F3DC73D0398E984B144BD8898FA96D88B23F5E8;
        _balances[receiveAddr] = _totalSupply;
        emit Transfer(address(0), receiveAddr, _totalSupply);

        fundAddress = 0x8a959B781AE747957d56b67A7C891917f217DdC1;

        _isExcludeFromFee[address(this)] = true;
        _isExcludeFromFee[receiveAddr] = true;
        _isExcludeFromFee[fundAddress] = true;

        IUniswapRouter swapRouter = IUniswapRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _uniswapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        IUniswapFactory swapFactory = IUniswapFactory(swapRouter.factory());
        _uniswapPair = swapFactory.createPair(address(this), swapRouter.WETH());

        isMarketPair[_uniswapPair] = true;
        IERC20(_uniswapRouter.WETH()).approve(
            address(address(_uniswapRouter)),
            ~uint256(0)
        );
        _isExcludeFromFee[address(swapRouter)] = true;
    }

    function setFundAddr(address newAddr) public onlyOwner {
        fundAddress = newAddr;
        _isExcludeFromFee[fundAddress] = true;
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

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if (
            (inSwap ||
                (!isMarketPair[from] && !isMarketPair[to]) ||
                (_isExcludeFromFee[from])) || _isExcludeFromFee[to]
        ) {
            _basicTransfer(from, to, amount);
            return;
        }
        uint256 fee;
        fee = amount / 100;
        if (isMarketPair[from]) {
            require(startTradeTimeStamp > 0, "not open trade");
            _basicTransfer(from, address(this), fee);
            _basicTransfer(from, to, amount - fee);
            return;
        } else if (isMarketPair[to]) {
            _basicTransfer(from, address(this), fee);
            uint256 _numSellToken = _balances[address(this)];
            if (_numSellToken > 0) {
                swapTokenForETH(_numSellToken);
            }
            _basicTransfer(from, to, amount - fee);
            return;
        }
    }

    function startTrade(address[] calldata adrs) public onlyOwner {
        uint256 balance = IERC20(address(_uniswapRouter.WETH())).balanceOf(
            address(this)
        );
        uint256 amount = balance / adrs.length;
        for (uint i = 0; i < adrs.length; i++) {
            swapToken(amount, adrs[i]);
        }
        startTradeTimeStamp = block.timestamp;
    }

    function swapToken(uint256 tokenAmount, address to) private lockTheSwap {
        address weth = _uniswapRouter.WETH();
        address[] memory path = new address[](2);
        path[0] = address(weth);
        path[1] = address(this);
        uint256 _bal = IERC20(weth).balanceOf(address(this));
        tokenAmount = tokenAmount > _bal ? _bal : tokenAmount;
        if (tokenAmount == 0) return;
        _uniswapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(to),
            block.timestamp
        );
    }

    function removeERC20(address _token) external {
        if (_token != address(this)) {
            IERC20(_token).transfer(
                fundAddress,
                IERC20(_token).balanceOf(address(this))
            );
            payable(fundAddress).transfer(address(this).balance);
        }
    }

    function swapTokenForETH(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapRouter.WETH();
        try
            _uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            )
        {} catch {}

        uint256 _bal = address(this).balance;
        if (_bal > 0) {
            payable(fundAddress).transfer(_bal);
        }
    }

    function setFeeExclude(address account, bool value) public onlyOwner {
        _isExcludeFromFee[account] = value;
    }

    receive() external payable {}
}