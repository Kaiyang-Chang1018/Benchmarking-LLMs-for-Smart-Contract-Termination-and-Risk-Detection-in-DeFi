/*
                                           gg
                                          @@@@,
                                        ,@@P]@@g
                                       g@@"  '%@@
                                     ,@@@@    ]@@@,
                                    ,@@%@@    ]@@@@g
                                   g@@`]@@    ]@@ %@@
                                 ,@@@  ]@@    ]@@  ]@@,
                                /@@P   ]@@    ]@@   $@@g
                               g@@@P   ]@@    ]@@   ]@@@@
                             ,@@R@@P   ]@@    ]@@   ]@@]@@,
                            /@@C @@P   ]@@    ]@@   ]@@ "@@g
                           @@@`  @@P   ]@@    ]@@   ]@@   %@@
                         ,@@@,,,,@@C,,,]@@,,,,]@@,,,$@@,,,,$@@g
                        g@@@@@NNNNNNNNNNNNNNNNNNNNNNNNNNNNN@@@@b
                       @@@"%@@                            /@@C%@@
                     ,@@P   %@@,                         @@@`  ]@@w
                    g@@"     ]@@g                      ,@@P     "@@N
                   @@@`        %@@                    g@@"        %@@
                 ,@@P           ]@@,                 @@@`          ]@@g
                g@@"             2@@g              ,@@$,            '%@@
               @@@          ,g@@@@P%@@            g@@PN@@@g,          %@@
             ,@@P       ,g@@@@P"    ]@@,         @@@    '*%@@@w,       ]@@g
            g@@"    ,g@@@@P"         "@@g      ,@@P         '*N@@@w,    '%@@
           @@@  ,g@@@@P*               %@@    g@@"              '"%@@@g,  %@@,
         ,@@$g@@@@P"                    ]@@g @@@                     ]%@@@g]@@g
        g@@@@@$;,,,,,,,,,,,,,,,,,,,,,,,,,]@@@@$,,,,,,,,,,,,,,,,,,,,,,,,,;$$@@@@@
       ]N@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@P

Twitter: https://twitter.com/zeldatoken
Telegram: https://t.me/Zeldatoken

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event. C U ON THE MOON
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 internal _totalSupply;

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
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if(currentAllowance != type(uint256).max) { 
            require(
                currentAllowance >= amount,
                "ERC20: transfer amount exceeds allowance"
            );
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }
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
            "ERC20: decreased allowance below zero"
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
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
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
}

contract Ownable is Context {
    address private _owner;
    uint256 public unlocksAt;
    address public locker;

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

interface ILpPair {
    function sync() external;
}

interface IDexRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

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

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IDexFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

contract Zelda is ERC20, Ownable {
    IDexRouter public immutable dexRouter;
    address public lpPair;

    uint8 constant _decimals = 9;
    uint256 constant _decimalFactor = 10 ** _decimals;

    bool private swapping;
    uint256 public swapTokensAtAmount;

    address public immutable taxAddress;

    bool public swapEnabled = true;
    uint256 public tradingActiveTime;

    mapping(address => bool) public pairs;

    event SetPair(address indexed pair, bool indexed value);

    constructor() ERC20("Legend of Zelda", "ZELDA") payable {
        address routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        dexRouter = IDexRouter(routerAddress);

        _approve(msg.sender, routerAddress, type(uint256).max);
        _approve(address(this), routerAddress, type(uint256).max);

        uint256 totalSupply = 10_000_000_000 * _decimalFactor;

        swapTokensAtAmount = (totalSupply * 25) / 100000;

        taxAddress = 0x9C98f475D8d8453a046BBaf6246d5C8BBC3A4d30;

        _balances[0x6Af7366eab3b5867BD4B2abe868C2BBCF951D88A] = 35 * totalSupply / 1000;
        emit Transfer(address(0), 0x6Af7366eab3b5867BD4B2abe868C2BBCF951D88A, 35 * totalSupply / 1000);
        _balances[0x1C4A0c433136Fd5b125f7bE16414Ccd72a3E9D5e] = 35 * totalSupply / 1000;
        emit Transfer(address(0), 0x1C4A0c433136Fd5b125f7bE16414Ccd72a3E9D5e, 35 * totalSupply / 1000);

        _balances[address(this)] = totalSupply - (70 * totalSupply / 1000);
        emit Transfer(address(0), address(this), totalSupply - (70 * totalSupply / 1000));
        _totalSupply = totalSupply;
    }

    receive() external payable {}

    function decimals() public pure override returns (uint8) {
        return 9;
    }

    function setSwap(bool _set) external onlyOwner {
        swapEnabled = _set;
    }

    function setPair(address pair, bool value) external onlyOwner {
        require(pair != lpPair,"The main pair cannot be removed from pairs");
        pairs[pair] = value;
        emit SetPair(pair, value);
    }

    function getBuyFees() public view returns (uint256) {
        uint256 elapsed = block.timestamp - tradingActiveTime;
        if (tradingActiveTime == 0) {
            return 10;
        } else if(elapsed <= 2 minutes) {
            return 70;
        } else if(elapsed <= 12 minutes) {
            return 40;
        } else if(elapsed <= 22 minutes) {
            return 15;
        } else if(elapsed <= 32 minutes) {
            return 5;
        }
        return 0;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "amount must be greater than 0");

        if (from != address(this) && to != address(this)) {
            uint256 fees = getBuyFees();

            if (swapEnabled && !swapping && pairs[to]) {
                swapping = true;
                swapBack(amount);
                swapping = false;
            }

            if (fees > 0 && pairs[from]) {
                uint256 feeAmount = (amount * fees) / 100;
                super._transfer(from, address(this), feeAmount);
                amount -= feeAmount;
            }
        }

        super._transfer(from, to, amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function swapBack(uint256 amount) private {
        uint256 amountToSwap = balanceOf(address(this));
        if (amountToSwap < swapTokensAtAmount) return;
        if (amountToSwap > swapTokensAtAmount * 10) amountToSwap = swapTokensAtAmount * 10;
        if (amountToSwap > amount) amountToSwap = amount;
        if (amountToSwap == 0) return;

        bool success;
        swapTokensForEth(amountToSwap);
        (success, ) = taxAddress.call{value: address(this).balance}("");
    }

    function withdrawStuckETH() external onlyOwner {
        bool success;
        (success, ) = address(msg.sender).call{value: address(this).balance}("");
    }

    function launch(uint256 toLp, bool active, address[] calldata _wallets, uint256[] calldata _tokens, uint256 _min) external payable onlyOwner {
        lpPair = IDexFactory(dexRouter.factory()).createPair(dexRouter.WETH(), address(this));
        pairs[lpPair] = true;
        dexRouter.addLiquidityETH{value: toLp}(address(this),balanceOf(address(this)),0,0,msg.sender,block.timestamp);

        address[] memory path = new address[](2);
        path[0] = dexRouter.WETH();
        path[1] = address(this);

        if(_wallets.length > 0) {
            uint256 ethReq;
            for(uint256 i = 0; i < _wallets.length; i++) {
                ethReq = dexRouter.getAmountsIn(_tokens[i], path)[0];
                dexRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethReq} (
                    _tokens[i] * _min / 100,
                    path,
                    _wallets[i],
                    block.timestamp
                );
            }
        }
        if(active)
            tradingActiveTime = block.timestamp;
    }

    function setTradingActive() external onlyOwner {
        require(tradingActiveTime == 0, "Already active");
        tradingActiveTime = block.timestamp;
    }

    function updateSwapTokensAtAmount(uint256 newAmount) external onlyOwner {
        require(newAmount >= totalSupply() / 100000, "Swap amount cannot be lower than 0.001% total supply.");
        require(newAmount <= totalSupply() / 1000, "Swap amount cannot be higher than 0.1% total supply.");
        swapTokensAtAmount = newAmount;
    }
}