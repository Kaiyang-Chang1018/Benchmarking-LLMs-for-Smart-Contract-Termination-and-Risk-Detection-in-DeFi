/*

 $$$$$$\  $$$$$$$\  $$\   $$\ $$$$$$$\                                      $$\   $$\            $$\                                       $$\       
$$  __$$\ $$  __$$\ $$ |  $$ |$$  __$$\                                     $$$\  $$ |           $$ |                                      $$ |      
$$ /  \__|$$ |  $$ |$$ |  $$ |$$ |  $$ | $$$$$$\   $$$$$$$\  $$$$$$\        $$$$\ $$ | $$$$$$\ $$$$$$\   $$\  $$\  $$\  $$$$$$\   $$$$$$\  $$ |  $$\ 
$$ |$$$$\ $$$$$$$  |$$ |  $$ |$$$$$$$\ | \____$$\ $$  _____|$$  __$$\       $$ $$\$$ |$$  __$$\\_$$  _|  $$ | $$ | $$ |$$  __$$\ $$  __$$\ $$ | $$  |
$$ |\_$$ |$$  ____/ $$ |  $$ |$$  __$$\  $$$$$$$ |\$$$$$$\  $$$$$$$$ |      $$ \$$$$ |$$$$$$$$ | $$ |    $$ | $$ | $$ |$$ /  $$ |$$ |  \__|$$$$$$  / 
$$ |  $$ |$$ |      $$ |  $$ |$$ |  $$ |$$  __$$ | \____$$\ $$   ____|      $$ |\$$$ |$$   ____| $$ |$$\ $$ | $$ | $$ |$$ |  $$ |$$ |      $$  _$$<  
\$$$$$$  |$$ |      \$$$$$$  |$$$$$$$  |\$$$$$$$ |$$$$$$$  |\$$$$$$$\       $$ | \$$ |\$$$$$$$\  \$$$$  |\$$$$$\$$$$  |\$$$$$$  |$$ |      $$ | \$$\ 
 \______/ \__|       \______/ \_______/  \_______|\_______/  \_______|      \__|  \__| \_______|  \____/  \_____\____/  \______/ \__|      \__|  \__|
                                                                                                                                                                                                                                    
                        
    Website:      https://gpubase.network/
    X (Twitter):  https://x.com/GPUBaseNetwork
    Telegram:     https://t.me/GPUBaseNetworkPortal
    Staking:      https://stake.gpubase.network/
    Whitepaper:   https://gpubase.network/docs/whitepaper


    
*/
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

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
        this;
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
        require(newOwner != address(0), "New owner is zero");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
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
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "Transfer exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "Allow: decreased below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: zero address");
        require(recipient != address(0), "ERC20: zero address");
        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "Exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply + amount;
        _balances[account] = _balances[account] + amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: zero address");
        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "Burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply = _totalSupply - amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: zero address");
        require(spender != address(0), "ERC20: zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract GPUBase is ERC20, Ownable {
    uint256 public buyFee = 5;
    uint256 public sellFee = 5;

    address private immutable marketingWallet;
    address private immutable stakingWallet;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public uniswapV2Pair;

    address private DEAD = 0x000000000000000000000000000000000000dEaD;

    bool private swapping;
    uint256 public swapTokensAtAmount;

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) private _isExcludedFromMaxWalletLimit;

    uint256 private maxWalletLimitRate = 20;

    event ExcludeFromFees(address indexed account, bool isExcluded);

    constructor(address _marketingWallet, address _stakingWallet)
        ERC20("GPUBase Network", "GPUBase")
    {
        marketingWallet = _marketingWallet;
        stakingWallet = _stakingWallet;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _approve(address(this), address(uniswapV2Router), type(uint256).max);

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[DEAD] = true;
        _isExcludedFromFees[address(this)] = true;

        _isExcludedFromMaxWalletLimit[owner()] = true;
        _isExcludedFromMaxWalletLimit[DEAD] = true;
        _isExcludedFromMaxWalletLimit[address(this)] = true;
        _isExcludedFromMaxWalletLimit[address(0)] = true;

        _mint(owner(), 33e6 * 1e18);
        swapTokensAtAmount = totalSupply() / 660;
    }

    receive() external payable {}

    function sendETH(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Send failed");
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: zero from");
        require(to != address(0), "ERC20: zero addr");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (
            canSwap &&
            !swapping &&
            from != uniswapV2Pair &&
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to]
        ) {
            swapping = true;

            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = uniswapV2Router.WETH();

            uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                contractTokenBalance,
                0, // accept any amount of ETH
                path,
                address(this),
                block.timestamp
            );

            uint256 newBalance = address(this).balance;

            if (newBalance != 0) {
                uint256 marketingAmount = (newBalance * 80) / 100;
                uint256 stakingAmount = newBalance - marketingAmount;
                sendETH(payable(marketingWallet), marketingAmount);
                sendETH(payable(stakingWallet), stakingAmount);
            }

            swapping = false;
        }

        bool takeFee = !swapping;

        if (
            (_isExcludedFromFees[from] || _isExcludedFromFees[to]) ||
            (from != uniswapV2Pair && to != uniswapV2Pair)
        ) {
            takeFee = false;
        }

        if (takeFee) {
            uint256 _totalFees = 0;
            if (from == uniswapV2Pair) {
                _totalFees = buyFee;
            } else if (to == uniswapV2Pair) {
                _totalFees = sellFee;
            }

            if (_totalFees != 0) {
                uint256 fees = (amount * _totalFees) / 100;
                amount = amount - fees;
                super._transfer(from, address(this), fees);
            }
        }

        if (
            _isExcludedFromMaxWalletLimit[from] == false &&
            _isExcludedFromMaxWalletLimit[to] == false &&
            to != uniswapV2Pair &&
            from == uniswapV2Pair
        ) {
            uint256 balance = balanceOf(to);
            require(
                balance + amount <= (totalSupply() * maxWalletLimitRate) / 1000,
                "Max limit exceeded"
            );
        }

        super._transfer(from, to, amount);
    }
}