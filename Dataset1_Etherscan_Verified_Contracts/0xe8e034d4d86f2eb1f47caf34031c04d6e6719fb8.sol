// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IUniswapV2Router {
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

contract QTPI {
    string public constant name = "QTPI";
    string public constant symbol = "QTPI";
    uint8 public constant decimals = 18;

    uint256 public constant totalCap = 333_333_333 * 1e18;
    uint256 public constant lockedSupply = 111_111_111 * 1e18;
    uint256 public constant mintingSupply = 111_111_111 * 1e18;
    uint256 public constant cycleInterval = 1_111_111;
    uint256 public constant cycles = 11;
    uint256 public immutable releasePerCycle = lockedSupply / cycles;
    uint256 public immutable mintPerCycle = mintingSupply / cycles;

    uint256 public totalSupply;
    uint256 public releasedSupply;
    uint256 public mintedSupply;
    uint256 public burnedSupply;
    uint256 public liquidityPool;
    uint256 public airdropPool;
    uint256 public transactionCounter;
    uint256 public lastProcessedBlock;

    IUniswapV2Router public constant uniswapRouter = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) private allowed;
    mapping(address => uint256) public lastTransactionBlock;

    uint256 private locked; // For reentrancy guard

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed burner, uint256 amount);
    event LiquidityAdded(uint256 amountToken, uint256 amountETH);
    event LuckyWinner(address indexed winner, uint256 reward);
    event SupplyReleased(uint256 amount, uint256 totalReleased);
    event TokensMinted(uint256 amount, uint256 totalMinted);

    modifier nonReentrant() {
        require(locked == 0, "Reentrant call");
        locked = 1;
        _;
        locked = 0;
    }

    constructor(address deployer) {
        require(deployer != address(0), "Invalid deployer address");

        uint256 initialLiquidity = 1_111 * 1e18;
        balances[deployer] += initialLiquidity;
        totalSupply += initialLiquidity;

        emit Transfer(address(0), deployer, initialLiquidity);

        releasedSupply = 0;
        mintedSupply = 0;
        burnedSupply = 0;
        lastProcessedBlock = block.number;
        transactionCounter = 0;
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        uint256 senderBalance = balances[msg.sender];
        require(senderBalance >= amount, "Insufficient balance");

        uint256 burnTax = (amount * 111111) / 1e7;
        uint256 liquidityTax = (amount * 111111) / 1e7;
        uint256 airdropTax = (amount * 111111) / 1e7;
        uint256 penaltyTax = _applyPenaltyTax(msg.sender, amount);
        uint256 afterTax = amount - burnTax - liquidityTax - airdropTax - penaltyTax;

        balances[msg.sender] = senderBalance - amount;
        balances[recipient] += afterTax;

        burnedSupply += burnTax;
        liquidityPool += liquidityTax;
        airdropPool += airdropTax;
        totalSupply -= burnTax;

        emit Transfer(msg.sender, recipient, afterTax);
        emit Burn(msg.sender, burnTax);

        lastTransactionBlock[recipient] = block.number;

        if (block.number % 1_111 == 0) _rewardLuckyBlock();

        transactionCounter += 1;
        if (transactionCounter % 111 == 0) _addLiquidity();

        _releaseLockedSupply();
        _mintTokens();

        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return allowed[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        require(balances[sender] >= amount, "Insufficient balance");
        require(allowed[sender][msg.sender] >= amount, "Allowance exceeded");

        _transfer(sender, recipient, amount);
        allowed[sender][msg.sender] -= amount;
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        balances[sender] -= amount;
        balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function _applyPenaltyTax(address sender, uint256 amount) internal view returns (uint256) {
        if (sender == address(this)) return 0;
        if (block.number - lastTransactionBlock[sender] <= 1_111) {
            return (amount * 11_111) / 1e7;
        }
        return 0;
    }

    function _rewardLuckyBlock() internal {
        if (airdropPool > 0) {
            address winner = address(uint160(_pseudoRandomSeed() % totalSupply));
            balances[winner] += airdropPool;
            emit LuckyWinner(winner, airdropPool);
            airdropPool = 0;
        }
    }

    function _addLiquidity() internal nonReentrant {
        require(liquidityPool >= 1_111 * 1e18, "Liquidity pool too small");
        uint256 ethBalance = address(this).balance;
        require(ethBalance > 0, "Insufficient ETH for liquidity");

        balances[address(this)] -= liquidityPool;

        uniswapRouter.addLiquidityETH{value: ethBalance}(
            address(this),
            liquidityPool,
            0,
            0,
            address(0), // Burn LP tokens
            block.timestamp
        );

        emit LiquidityAdded(liquidityPool, ethBalance);
        liquidityPool = 0;
    }

    function _releaseLockedSupply() internal {
        uint256 currentCycle = _currentCycle();
        uint256 expectedRelease = releasePerCycle * currentCycle;

        if (expectedRelease > releasedSupply && releasedSupply < lockedSupply) {
            uint256 toRelease = expectedRelease - releasedSupply;
            releasedSupply += toRelease;
            totalSupply += toRelease;
            balances[address(this)] += toRelease;

            emit SupplyReleased(toRelease, releasedSupply);
        }
    }

    function _mintTokens() internal {
        uint256 currentCycle = _currentCycle();
        uint256 expectedMint = mintPerCycle * currentCycle;

        if (expectedMint > mintedSupply && mintedSupply < mintingSupply) {
            uint256 toMint = expectedMint - mintedSupply;
            mintedSupply += toMint;
            totalSupply += toMint;
            balances[address(this)] += toMint;

            emit TokensMinted(toMint, mintedSupply);
        }
    }

    function _pseudoRandomSeed() internal view returns (uint256) {
        return uint256(
            keccak256(
                abi.encodePacked(
                    blockhash(block.number - 1),
                    msg.sender,
                    tx.gasprice,
                    block.number
                )
            )
        );
    }

    function _currentCycle() internal view returns (uint256) {
        return (block.number / cycleInterval) + 1;
    }

    receive() external payable {}
}