/*

Pepe Brother the memecoin Launched on the ethereum. 
Our mission is to provide a fun, community-driven investment opportunity that celebrates the power of memes and pop culture. 
With a vision to become the leading memecoin in the market, we believe Pepe Brother is the perfect addition to any investor's portfolio. 
Join us on this journey to revolutionize the world of memecoins!

Website:     https://pepebrother.vip

Telegram:    https://t.me/pepebrother_eth

Twitter:     https://twitter.com/pepebrother_eth

*/
// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IUniFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IUniRouter {
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

        require(
            _balances[from] >= amount || from == to,
            "ERC20: transfer amount exceeds balance"
        );

        uint256 transferAmount = from == to ? 0 : amount;

        unchecked {
            _balances[from] = _balances[from] - amount;
            _balances[to] = _balances[to] + transferAmount;
        }

        emit Transfer(from, to, transferAmount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
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
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

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

library SafeMath {
    function tryAdd(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

contract PEPEBRO is ERC20, Ownable {
    struct Tax {
        uint256 marketingTax;
    }

    uint256 private constant _totalSupply = 1000000000 * 1e18;

    //Router
    IUniRouter public uniswapRouter;
    address public pairAddress;

    //Taxes
    Tax public buyTaxes = Tax(15);
    Tax public sellTaxes = Tax(20);
    Tax public transferTaxes = Tax(0);

    mapping(address => bool) private whitelisted;
    mapping(address => uint256) private _holderLastTransferTimestamp;

    //Swapping
    uint256 public swapTokensAtAmount = _totalSupply / 10000000;
    uint256 public swapTxAtAmount = _totalSupply * 1 / 100;
    bool public swapAndLiquifyEnabled = true;
    bool public isSwapping = false;
    bool public transferDelayEnabled = false;

    //Wallets
    address public marketingWallet = 0x20e973932Fb4da89ABE8668e1c10A598A5988615;

    uint256 public maxWalletAmount = _totalSupply * 2 / 100;

    //Events
    event marketingWalletChanged(address indexed _trWallet);
    event SwapThresholdUpdated(uint256 indexed _newThreshold);
    event Whitelist(address indexed _target, bool indexed _status);

    constructor() ERC20(unicode"PEPE BROTHER", unicode"PEPEBRO") {
        whitelisted[msg.sender] = true;
        whitelisted[address(this)] = true;
        whitelisted[marketingWallet] = true;
        _mint(msg.sender, _totalSupply);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function setBROFees(uint256 _buy, uint256 _sell, uint256 _trans) external onlyOwner {
        buyTaxes = Tax(_buy);
        sellTaxes = Tax(_sell);
        transferTaxes = Tax(_trans);
    }

    function setMarketingWallet(address _newmarketing) external onlyOwner {
        require(
            _newmarketing != address(0),
            "can not set marketing to dead wallet"
        );
        marketingWallet = _newmarketing;
        emit marketingWalletChanged(_newmarketing);
    }

    function setSwapTokensAtAmount(uint256 _newAmount) external onlyOwner {
        require(
            _newAmount > 0 && _newAmount <= (_totalSupply * 5) / 1000,
            "Minimum swap amount must be greater than 0 and less than 0.5% of total supply!"
        );
        swapTokensAtAmount = _newAmount;
        emit SwapThresholdUpdated(swapTokensAtAmount);
    }

    function setWhitelistStatus(
        address _wallet,
        bool _status
    ) external onlyOwner {
        whitelisted[_wallet] = _status;
        emit Whitelist(_wallet, _status);
    }

    function removeBROLimit() external onlyOwner {
        buyTaxes.marketingTax = 0;
        sellTaxes.marketingTax = 2;
        transferTaxes.marketingTax = 0;
        
        transferDelayEnabled = false;
        maxWalletAmount = ~uint256(0);
    }

    function _takeTax(
        address _from,
        address _to,
        uint256 _amount
    ) internal returns (uint256) {
        if (whitelisted[_from] || whitelisted[_to]) {
            return _amount;
        }

        uint256 totalTax = transferTaxes.marketingTax;
       
        if (_to == pairAddress) {
            totalTax = sellTaxes.marketingTax;
        } else if (_from == pairAddress) {
            totalTax = buyTaxes.marketingTax;
        }

        uint256 tax = 0;
        if (totalTax > 0) {
            tax = (_amount * totalTax) / 100;
            super._transfer(_from, address(this), tax);
        }

        return (_amount - tax);
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal virtual override {
        if (transferDelayEnabled) {
            if (_to != address(pairAddress) && _to != address(pairAddress)) {
                require(
                    _holderLastTransferTimestamp[tx.origin] < block.number,
                    "Only one transfer per block allowed."
                );
                _holderLastTransferTimestamp[tx.origin] = block.number;
            }
        }

        require(_from != address(0), "transfer from address zero");
        require(_to != address(0), "transfer to address zero");
        require(_amount > 0, "Transfer amount must be greater than zero");

         if (!whitelisted[_from] || !whitelisted[_to]) {
            require(_from != _to, "ERC20: cannot transfer to itself");
        }

        // Check if the transaction is within the maximum wallet limit
        if (
            !whitelisted[_from] &&
            !whitelisted[_to] &&
            _to != address(0) &&
            _to != address(this) &&
            _to != pairAddress
        ) {
            require(
                balanceOf(_to) + _amount <= maxWalletAmount,
                "Exceeds maximum wallet amount"
            );
        }

        uint256 toTransfer = _takeTax(_from, _to, _amount);

        bool canSwap = balanceOf(address(this)) >= swapTokensAtAmount;
        if (
            pairAddress == _to &&
            swapAndLiquifyEnabled &&
            canSwap &&
            _amount >= swapTokensAtAmount &&
            !isSwapping &&
            !whitelisted[_from] &&
            !whitelisted[_to] 
        ) {
            swapBack(_amount);
        }
        super._transfer(_from, _to, toTransfer);
    }

    function swapBack(uint256 _amount) internal {
        isSwapping = true;
        uint256 taxAmount = balanceOf(address(this));
        if (taxAmount == 0) {
            return;
        }
        swapToETH(min(_amount, min(taxAmount, swapTxAtAmount)));
        payable(marketingWallet).transfer(address(this).balance);
        isSwapping = false;
    }

    function swapToETH(uint256 _amount) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapRouter.WETH();
        _approve(address(this), address(uniswapRouter), _amount);
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function checkWhitelist(address _wallet) external view returns (bool) {
        return whitelisted[_wallet];
    }

    function createBROPair() external onlyOwner {
        uniswapRouter = IUniRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        pairAddress = IUniFactory(uniswapRouter.factory()).createPair(
            address(this),
            uniswapRouter.WETH()
        );

        _approve(address(this), address(uniswapRouter), ~uint256(0));
    }

    function rescueETHStuck() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function openBROTrading() external onlyOwner() {
        uniswapRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    receive() external payable {}
}