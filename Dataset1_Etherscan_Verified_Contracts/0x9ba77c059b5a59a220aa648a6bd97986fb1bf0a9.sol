/*
Website: https://www.agentsys.io/
Twitter: https://x.com/agentsysdotio
Telegram: https://t.me/agentsys
DApps: https://t.me/agentsysbot
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

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
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
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
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);
}
interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

contract AGENTSYS_AI is ERC20, Ownable {
    uint256 private buyTax = 20;
    uint256 private sellTax = 20;

    IUniswapV2Router02 private uniswapV2Router;
    address public uniswapV2Pair;
    mapping(address => bool) public isExempt;

    address private immutable marketingAddress;
    address private immutable taxAddress;

    uint256 public maxTransactionAmount;
    uint256 public maxTxLaunch;
    bool private launch = false;
    bool private slowLaunch = true;
    uint256 private blockLaunch;
    uint256 private lastSellBlock;
    uint256 private sellCount;
    uint256 private minSwap;
    uint256 private maxSwap;
    uint256 private _buyCount = 0;
    bool private inSwap;
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(
        address _taxAddress,
        address _marketingAddress

    ) ERC20("AGENTSYS AI", "AGSYS") Ownable() {
        uint256 totalSupply = 100000000 * 10 ** 18; // 100M

        marketingAddress = _marketingAddress;
        taxAddress = _taxAddress;

        isExempt[msg.sender] = true;
        isExempt[address(this)] = true;
        isExempt[marketingAddress] = true;
        isExempt[taxAddress] = true;


        _mint(marketingAddress, (totalSupply * 8) / 100);
        _mint(address(this), (totalSupply * 84) / 100);
        _mint(msg.sender, (totalSupply * 8) / 100);


        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );


        // maxTransactionAmount = (2 * 100000000 * 10 ** 18) / 100;
        maxTransactionAmount = (100000000 * 10 ** 18) * 5 / 1000; // 5% of total supply
        // maxTxLaunch = ( 15 * 100000000 * 10 ** 18) / 1000;
        maxTxLaunch = ( 100000000 * 10 ** 18) * 5 / 1000; // 0.5% of total supply
        maxSwap = 500000 * 10 ** 18;
        minSwap = 100000 * 10 ** 18;
    }

    function unclog() external {
        require(msg.sender == marketingAddress);
        uint256 amount = balanceOf(address(this));
        uint256 toUnclog = amount / 2;
        transfer(marketingAddress, toUnclog);
    }

    function generatePair() external onlyOwner {
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
    }

    function openTrading() external onlyOwner {
        // 20% clogged
        uint256 tokenToLP = ((100000000 * 10 ** 18) * 68) / 100;

        _approve(
            address(this),
            address(uniswapV2Router),
            balanceOf(address(this))
        );

        // uniswapV2Pair = address(
        //     IUniswapV2Factory(uniswapV2Router.factory()).createPair(
        //         address(this),
        //         uniswapV2Router.WETH()
        //     )
        // );        

        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            tokenToLP,
            0,
            0,
            owner(),
            block.timestamp
        );

        launch = true;
        blockLaunch = block.number;
    }

    function getMinCASwap() public view returns (uint256) {
        return minSwap / 10 ** decimals();
    }

    function initialize(
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external onlyOwner {
        require(recipients.length == amounts.length);
        for (uint256 i = 0; i < recipients.length; i++) {
            _transfer(msg.sender, recipients[i], amounts[i]);
        }
    }

    function setMaxCASwap(uint256 _maxSwap) external onlyOwner {
        require(_maxSwap <= ((100000000 * 10 ** 18) * 5 / 1000));
        require(_maxSwap >= ((100000000 * 10 ** 18) * 5 / 10000));
        maxSwap = _maxSwap * 10 ** decimals();
    }

    function setMinSwap(uint256 _minSwap) external onlyOwner {
        require(_minSwap <= ((100000000 * 10 ** 18) * 5 / 1000));
        require(_minSwap >= ((100000000 * 10 ** 18) * 5 / 10000));
        minSwap = _minSwap * 10 ** decimals();
    }

    function switchCaSell() external onlyOwner {
        if (inSwap) {
            inSwap = false;
        } else {
            inSwap = true;
        }
    }

    function deactivateSlowLaunch(uint256 inPercent) external onlyOwner {
        slowLaunch = false;
        uint256 amount = balanceOf(marketingAddress);
        uint256 _inPercent = (amount * inPercent) / 100;
        transferFrom(marketingAddress, address(this), _inPercent);
    }

    function getMaxCASwap() public view returns (uint256) {
        return maxSwap / 10 ** decimals();
    }

    function swapTokensEth(uint256 tokenAmount) internal lockTheSwap {
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            taxAddress,
            block.timestamp
        );
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        if (!isExempt[from] && !isExempt[to]) {
            require(launch);
            uint256 tax = 0;

            if (slowLaunch && blockLaunch != block.number) {
                require(value <= maxTxLaunch, "MAX TX LIMIT");
            } else {
                require(value <= maxTransactionAmount, "MAX TX LIMIT");
            }

            if (to == uniswapV2Pair) {
                tax = sellTax;
                uint256 tokensSwap = balanceOf(address(this));
                if (tokensSwap > minSwap && !inSwap) {
                    if (block.number > lastSellBlock) {
                        sellCount = 0;
                    }
                    if (sellCount < 3) {
                        sellCount++;
                        lastSellBlock = block.number;
                        swapTokensEth(min(maxSwap, min(value, tokensSwap)));
                    }
                }
            } else if (from == uniswapV2Pair) {
                tax = buyTax;
                if (block.number == blockLaunch) {
                    _buyCount++;
                    tax = 20;
                    require(
                        _buyCount <= 15,
                        "Exceeds buys on the first block."
                    );
                }
            }

            uint256 taxAmount = (value * tax) / 100;
            uint256 amountAfterTax = value - taxAmount;

            if (taxAmount > 0) {
                super._transfer(from, address(this), taxAmount);
            }
            super._transfer(from, to, amountAfterTax);
            return;
        }
        super._transfer(from, to, value);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function setTax(uint256 newBuyTax, uint256 newSellTax) external onlyOwner {
        require(newBuyTax < 20 && newSellTax < 20);
        sellTax = newSellTax;
        buyTax = newBuyTax;
    }

    function setMaxTx(uint256 newMaxTx) external onlyOwner {
        maxTransactionAmount = newMaxTx * 10 ** decimals();
    }

    function removeAllLimits() external onlyOwner {
        maxTransactionAmount = totalSupply();
    }

    function exportETH() external {
        payable(marketingAddress).transfer(address(this).balance);
    }

    function setExcludedWallet(
        address wAddress,
        bool isExcle
    ) external onlyOwner {
        isExempt[wAddress] = isExcle;
    }

    receive() external payable {}
}