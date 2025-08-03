// SPDX-License-Identifier: MIT

/*
    4096 Website: https://4096.cash
    4096 App: https://app.4096.cash
    Telegram: https://t.me/ERC4096
    Twitter: https://twitter.com/4096ERC
*/

pragma solidity ^0.8.18;

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

interface IWETH is IERC20 {
    function deposit() external payable;
}

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

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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

interface IERC4096 is IERC20 {
    function sellCounter() external view returns(uint256);
    function sellAmountCounter() external view returns(uint256);
    function lastLpBurnTime() external view returns(uint256);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
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
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
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

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

contract Teleport {
    IERC4096 public originalToken = IERC4096(0x4096Fc7119040175589387656F7C6073265f4096);
    IUniswapV2Pair public originalTokenPair = IUniswapV2Pair(0x7C3f018376C7B97CB811cd17aA094052DBeE6dBc);
    IWETH WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    address owner;

    constructor() {
        owner = msg.sender;
    }

    struct Args {
        uint256 res4096;
        uint256 resWETH;
        uint256 timestamp;
        uint256 sellAmountCounter;
        uint256 lastLpBurnTime;
        uint256 needToSell;
        uint256 cycleSell;
        uint256 sellCycles;
    }

    function getData() external view returns(uint256, uint256) {
        return (originalToken.sellCounter(), originalToken.balanceOf(address(originalTokenPair)));
    }

    function teleport(uint256 maxSpend) external payable {
        uint256 lastLpBurnTime = originalToken.lastLpBurnTime();
        uint256 sellAmountCounter = originalToken.sellAmountCounter();

        (uint256 res4096, uint256 resWETH,) = originalTokenPair.getReserves();

        {
            uint256 contractBalance = originalToken.balanceOf(address(originalToken));
            if (contractBalance > 1) {
                uint256 amountOut = (contractBalance * 997 * resWETH) / (res4096 * 1000 + contractBalance * 997);

                res4096 += contractBalance;
                resWETH -= amountOut;
            }
        }

        uint256 needToSell;
        unchecked {
            uint256 currentCounter = originalToken.sellCounter();

            uint256 target = 15;
            if (res4096 > 512) {
                if (res4096 > 1024) {
                    target = 3;
                }
                else {
                    target = 7;
                }
            }

            require(target > currentCounter, "Nowhere to teleport");
            needToSell = target - currentCounter;
        }

        uint256 cycleSell = needToSell;
        unchecked {
            if (res4096 <= 512 && 512 - res4096 < needToSell) {
                cycleSell = 512 - res4096;
                require(cycleSell > 0, "Nowhere to teleport: edge case");
            }
            else if (res4096 <= 1024 && 1024 - res4096 < needToSell) {
                cycleSell = 1024 - res4096;
                require(cycleSell > 0, "Nowhere to teleport: edge case");
            }
        }

        unchecked {
            uint256 timestamp = block.timestamp - 8 hours;

            if (needToSell == cycleSell) {
                uint256 amountReceived;
                uint256[] memory amountsOut = new uint256[](needToSell);

                {
                    uint256 nukedWithCounter;
                    uint256 nukedWithTimeout;

                    for (uint256 i = 0; i < needToSell; ++i) {
                        if (res4096 > 256) {
                            if (sellAmountCounter > 1023 && nukedWithCounter == 0 ) {
                                --res4096;
                                nukedWithCounter = 1;
                            }
                            else if (lastLpBurnTime <= timestamp && nukedWithTimeout == 0) {
                                --res4096;
                                nukedWithTimeout = 1;
                            }
                        }

                        ++sellAmountCounter;

                        uint256 amountOut = (997 * resWETH) / (res4096 * 1000 + 997);

                        amountsOut[i] = amountOut;

                        ++res4096;
                        resWETH -= amountOut;

                        amountReceived += amountOut;
                    }
                }

                uint256 amountIn = resWETH * needToSell * 1000 / (res4096 - needToSell) / 997 + 1;

                {
                    uint256 additionalSpend = amountIn - amountReceived;
                    require(additionalSpend < maxSpend, "Additional WETH spend is higher than your max spend");
                    if (msg.value == 0) {
                        WETH.transferFrom(msg.sender, address(this), additionalSpend);
                    }
                    else {
                        WETH.deposit{value: additionalSpend}();
                        (bool success,) = msg.sender.call{value: msg.value - additionalSpend}('');
                        require(success, "Failed to return excess ETH");
                    }

                    for (uint256 i = 0; i < needToSell; ++i) {
                        originalToken.transfer(address(originalTokenPair), 1);
                        originalTokenPair.swap(0, amountsOut[i], address(this), '');
                    }
                }

                WETH.transfer(address(originalTokenPair), amountIn);
                originalTokenPair.swap(needToSell, 0, address(this), '');
            }
            else {
                uint256 sellCycles = needToSell / cycleSell;
                (uint256[] memory amountsInAndOut, uint256 additionalSpend, uint256 remainingSellsCount) = getAmountsInAndOut(Args(res4096, resWETH, timestamp, sellAmountCounter, lastLpBurnTime, needToSell, cycleSell, sellCycles));

                require(additionalSpend < maxSpend, "Additional WETH spend is higher than your max spend");
                if (msg.value == 0) {
                    WETH.transferFrom(msg.sender, address(this), additionalSpend);
                }
                else {
                    WETH.deposit{value: additionalSpend}();
                    (bool success,) = msg.sender.call{value: msg.value - additionalSpend}('');
                    require(success, "Failed to return excess ETH");
                }

                uint256 amountsIndex = 0;
                for (uint256 i = 0; i < sellCycles; ++i) {
                    for (uint256 j = 0; j < cycleSell; ++j) {
                        originalToken.transfer(address(originalTokenPair), 1);
                        originalTokenPair.swap(0, amountsInAndOut[amountsIndex], address(this), '');

                        ++amountsIndex;
                    }

                    WETH.transfer(address(originalTokenPair), amountsInAndOut[amountsIndex]);
                    originalTokenPair.swap(cycleSell, 0, address(this), '');
                    ++amountsIndex;
                }

                if (remainingSellsCount > 0) {
                    for (uint256 i = 0; i < remainingSellsCount; ++i) {
                        originalToken.transfer(address(originalTokenPair), 1);
                        originalTokenPair.swap(0, amountsInAndOut[amountsIndex], address(this), '');

                        ++amountsIndex;
                    }

                    WETH.transfer(address(originalTokenPair), amountsInAndOut[amountsIndex]);
                    originalTokenPair.swap(remainingSellsCount, 0, address(this), '');
                }
            }
        }
    }

    function getAmountsInAndOut(Args memory args) private pure returns(uint256[] memory, uint256, uint256) {
        uint256[] memory amountsInAndOut;
        {
            uint256 length = args.needToSell + args.sellCycles + 1;
            if (args.needToSell == args.sellCycles) {
                --length;
            }
            amountsInAndOut = new uint256[](length);
        }

        uint256 amountReceived;
        uint256 additionalSpend;

        uint256 amountsIndex;
        uint256 remainingSellsCount;

        {
            uint256 nukedWithCounter;
            uint256 nukedWithTimeout;

            for (uint256 i = 0; i < args.sellCycles; ++i) {
                for (uint256 j = 0; j < args.cycleSell; ++j) {
                    if (args.res4096 > 256) {
                        if (args.sellAmountCounter > 1023 && nukedWithCounter == 0 ) {
                            --args.res4096;
                            nukedWithCounter = 1;
                        }
                        else if (args.lastLpBurnTime <= args.timestamp && nukedWithTimeout == 0) {
                            --args.res4096;
                            nukedWithTimeout = 1;
                        }
                    }

                    ++args.sellAmountCounter;
                    
                    uint256 amountOut = (997 * args.resWETH) / (args.res4096 * 1000 + 997);

                    amountsInAndOut[amountsIndex] = amountOut;
                    ++amountsIndex;

                    ++args.res4096;
                    args.resWETH -= amountOut;

                    amountReceived += amountOut;
                }

                uint256 amountIn = args.resWETH * args.cycleSell * 1000 / (args.res4096 - args.cycleSell) / 997 + 1;

                args.res4096 -= args.cycleSell;
                args.resWETH += amountIn;

                amountsInAndOut[amountsIndex] = amountIn;
                ++amountsIndex;

                additionalSpend += amountIn - amountReceived;
                amountReceived = 0;
            }

            if (args.needToSell != args.sellCycles) {
                remainingSellsCount = args.needToSell - args.sellCycles * args.cycleSell;

                for (uint256 i = 0; i < remainingSellsCount; ++i) {
                    if (args.res4096 > 256) {
                        if (args.sellAmountCounter > 1023 && nukedWithCounter == 0 ) {
                            --args.res4096;
                            nukedWithCounter = 1;
                        }
                        else if (args.lastLpBurnTime <= args.timestamp && nukedWithTimeout == 0) {
                            --args.res4096;
                            nukedWithTimeout = 1;
                        }
                    }

                    ++args.sellAmountCounter;

                    uint256 amountOut = (997 * args.resWETH) / (args.res4096 * 1000 + 997);

                    amountsInAndOut[amountsIndex] = amountOut;
                    ++amountsIndex;

                    ++args.res4096;
                    args.resWETH -= amountOut;

                    amountReceived += amountOut;
                }

                uint256 remainingAmountIn = args.resWETH * args.cycleSell * 1000 / (args.res4096 - args.cycleSell) / 997 + 1;

                amountsInAndOut[amountsIndex] = remainingAmountIn;

                additionalSpend += remainingAmountIn - amountReceived;
            }
        }

        return (amountsInAndOut, additionalSpend, remainingSellsCount);
    }

    function retrieveTokens(address tokenContract) external {
        require(msg.sender == owner);
        IERC20(tokenContract).transfer(owner, IERC20(tokenContract).balanceOf(address(this)));
    }

    function retrieveETH() external {
        require(msg.sender == owner);
        (bool success,) = owner.call{value: address(this).balance}('');
        require(success);
    }
}