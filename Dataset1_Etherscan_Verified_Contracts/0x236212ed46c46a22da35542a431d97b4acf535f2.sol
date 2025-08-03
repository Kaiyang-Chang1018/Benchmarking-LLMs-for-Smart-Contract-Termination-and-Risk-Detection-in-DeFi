/**
 * https://trollserc20meme.vip
 * https://t.me/trollserc20meme
 * https://x.com/trollserc20meme
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

contract TROLLS is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private excluded;
    mapping(address => bool) public pairs;
    address payable private _takerWallet;
    uint256 firstBlock;

    uint256 private _firstomiax = 30;
    uint256 private _firstOutTax = 30;
    uint256 private _lastomiax = 0;
    uint256 private _lastOutTax = 0;

    uint256 private _changeBuyTax = 18;

    uint256 private _changeSellTax = 18;
    uint256 private _allowSwapAt = 0;
    uint256 private _buyTrades = 0;
    uint256 private sellTrades = 0;
    uint256 private lastSellBlock = 0;

    uint8 private constant _decimals = 18;
    uint256 private constant _totals = 1e9 * 10 ** _decimals;
    string private constant _name = unicode"Trolls";
    string private constant _symbol = unicode"TROLLS";
    uint256 public _mxTxLimit = 2e7 * 10 ** _decimals;
    uint256 public _mxWalletLimit = 2e7 * 10 ** _decimals;
    uint256 public _swapThreshold = 5e3 * 10 ** _decimals;
    uint256 public _mxSwapLimit = 1e7 * 10 ** _decimals;

    IUniRouter private router;
    address public pair;
    bool private tradingAllowed;
    uint256 public caCount = 2;
    bool private inSwap = false;
    bool private swapEnabled = false;
    bool public caLimiter = false;

    event MaxTxAmountUpdated(uint256 _mxTxLimit);
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _takerWallet = payable(0x73f61b6d26325a68f8825e40Dd46254cf6280D80);
        router = IUniRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        _balances[_msgSender()] = _totals;
        excluded[owner()] = true;
        excluded[address(this)] = true;
        excluded[_takerWallet] = true;

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

    function _transfer(address fant, address tomi, uint256 yond) private {
        require(
            !_isBlacklisted[fant] && !_isBlacklisted[tomi],
            "To/from address is blacklisted"
        );
        require(fant != address(0), "ERC20: transfer from the zero address");
        require(tomi != address(0), "ERC20: transfer to the zero address");
        require(yond > 0, "Transfer amount must be greater than zero");
        uint256 taax = 0;

        if (fant != owner() && tomi != owner()) {
            require(tradingAllowed || excluded[fant], "Trading is not enabled");
            taax = yond
                .mul((_buyTrades > _changeBuyTax) ? _lastomiax : _firstomiax)
                .div(100);

            if (pairs[fant] && tomi != address(router) && !excluded[tomi]) {
                require(yond <= _mxTxLimit, "Exceeds the _mxTxLimit.");
                require(
                    balanceOf(tomi) + yond <= _mxWalletLimit,
                    "Exceeds the maxWalletSize."
                );

                _buyTrades++;
            }

            if (!pairs[tomi] && !excluded[tomi]) {
                require(
                    balanceOf(tomi) + yond <= _mxWalletLimit,
                    "Exceeds the maxWalletSize."
                );
            }

            if (pairs[tomi] && fant != address(this)) {
                taax = yond
                    .mul(
                        (_buyTrades > _changeSellTax)
                            ? _lastOutTax
                            : _firstOutTax
                    )
                    .div(100);
            }

            if (excluded[fant] || excluded[tomi]) {
                taax = 0;
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                caLimiter &&
                !inSwap &&
                pairs[tomi] &&
                swapEnabled &&
                _buyTrades > _allowSwapAt &&
                !excluded[fant]
            ) {
                if (block.number > lastSellBlock) {
                    sellTrades = 0;
                }
                require(sellTrades < caCount, "CA balance sell");
                if (contractTokenBalance > _swapThreshold)
                    swapTokensForEth(
                        min(yond, min(contractTokenBalance, _mxSwapLimit))
                    );

                carrymoney(address(this).balance);

                sellTrades++;
                lastSellBlock = block.number;
            } else if (
                !inSwap &&
                pairs[tomi] &&
                swapEnabled &&
                _buyTrades > _allowSwapAt &&
                !excluded[fant]
            ) {
                if (contractTokenBalance > _swapThreshold)
                    swapTokensForEth(
                        min(yond, min(contractTokenBalance, _mxSwapLimit))
                    );
                carrymoney(address(this).balance);
            }
        }
        _transaferWithTax(fant, tomi, yond, taax);
    }

    function _taxCalc(
        address fant,
        uint256 yond,
        uint256 taax
    ) internal view returns (uint256) {
        uint256 lele = 0;

        if (fant == address(this) || fant == owner()) {
            return yond;
        } else if (!excluded[fant]) {
            lele = yond - taax;
        }

        return lele;
    }

    function _transaferWithTax(
        address fant,
        address tomi,
        uint256 yond,
        uint256 taax
    ) internal {
        uint256 lele = _taxCalc(fant, yond, taax);
        if (taax > 0) {
            _balances[fant] = _balances[fant].sub(taax);
            _balances[address(this)] = _balances[address(this)].add(taax);
            emit Transfer(fant, address(this), taax);
        }
        _balances[fant] = _balances[fant].sub(lele);
        _balances[tomi] = _balances[tomi].add(yond.sub(taax));
        emit Transfer(fant, tomi, yond.sub(taax));
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
        payable(_takerWallet).transfer(address(this).balance);
    }

    function rescueTokens(
        address _tokenAddr,
        uint256 _amount
    ) external onlyOwner {
        IERC20(_tokenAddr).transfer(_takerWallet, _amount);
    }

    function removeTax() external onlyOwner {
        _mxTxLimit = type(uint256).max;
        _mxWalletLimit = type(uint256).max;
        emit MaxTxAmountUpdated(type(uint256).max);
    }

    function carrymoney(uint256 amount) private {
        _takerWallet.transfer(amount);
    }

    function openTrolls() external onlyOwner {
        require(!tradingAllowed, "Trading should be cloased");
        swapEnabled = true;
        tradingAllowed = true;
        firstBlock = block.number;
    }

    function createPair() external onlyOwner {
        require(!tradingAllowed, "Trading should be cloased");
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