// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Simple single owner authorization mixin.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)
abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./GenericERC20Token.sol";
import "solmate/auth/Owned.sol";
import "./IWETH.sol";
import "./IEsEMBR.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Pair.sol";

contract EmberVault is Owned {
    struct Package {
        uint8 Enabled;
        uint80 Price;
        uint80 BorrowedLiquidity;
        uint16 Duration; // IN WEEKS!
        uint16 DebtGrowthPerWeek; // for 40% apy its 65. 0.65% per week = ~40% apy
    } // total size 1 slot

    struct SetupParams {
        string TokenName;
        string TokenSymbol;
        uint8 TokenDecimals;
        uint256 TotalSupply;
        uint256 TransferTax;
    }

    struct TokenInfo {
        uint40 CreationTime;
        uint16 PackageId;
        uint24 Reserved; // reserved
        uint16 LastPaidWeek; // 0 = no payments, 1 = paid off first week, etc
        uint80 Pending;
        uint80 RemainingDebt; // uint80 is fine here because the debt will never be more than 1.2 million ethers.

        uint256 TotalPaid;
    } // total size 2 slots

    struct ClaimInfo {
        uint256 EthAmount;
        uint256 TokenAmount;
    } // total size 2 slots

    mapping(address => address) public tokenDeployers; // mapping(Token => Deployer)
    mapping(address => address) public liquidityPools; // mapping(Token => UniV2Pool)
    mapping(uint256 => Package) public packages; // mapping(PackageId => Package)
    mapping(address => TokenInfo) public tokens; // mapping(Token => TokenInfo)
    mapping(address => ClaimInfo) public claims; // mapping(CookedToken => ClaimInfo)

    mapping(address => bool) allowed_factories; // mapping(UniV2Factory => bool)
    mapping(address => bool) allowed_routers; // mapping(Router => bool)
    mapping(address => address) router_factory; // mapping(Router => Factory)

    IWETH public WETH;
    address payable public esEmbr;

    uint256 nextPackageId;

    uint256 public pullingMaxHoursReward = 100;
    uint256 public pullingRewardPerHour;
    uint256 public pullingBaseReward;

    uint256 private rentrancy_lock = 1;

    event TokenDeployed(
        address indexed deployer,
        address token_address,
        GenericERC20Token.ConstructorCalldata params,
        uint256 package_id,
        uint256 initialLiq
    );

    constructor(address _router, address _factory) Owned(msg.sender) {
        require(_router != address(0), "Router address cannot be 0");
        require(_factory != address(0), "Factory address cannot be 0");

        allowed_routers[_router] = true;
        allowed_factories[_factory] = true;
        router_factory[_router] = _factory;

        WETH = IWETH(payable(IUniswapV2Router02(_router).WETH()));
        WETH.approve(_router, type(uint256).max);
    }

    modifier onlyEsEMBR() {
        require(msg.sender == esEmbr, "Vault: Only esEMBR contract can call this function");
        _;
    }

    modifier nonReentrant() {
        require(rentrancy_lock == 1);

        rentrancy_lock = 2;
        _;
        rentrancy_lock = 1;
    }

    function create(
        GenericERC20Token.ConstructorCalldata calldata params,
        uint16 package_id
    ) external payable returns (address) {
        Package memory package = packages[package_id];

        require(package.BorrowedLiquidity != 0, "Vault: Invalid package provided");
        require(msg.value == package.Price, "Vault: Invalid package cost provided");

        require(package.Enabled == 1, "Vault: Package is disabled");

        require(address(this).balance >= package.BorrowedLiquidity, "Vault: Not enough funds available to lend");
        require(allowed_routers[params.UniV2SwapRouter], "Vault: Unsupported Swap Router provided");
        require(router_factory[params.UniV2SwapRouter] == params.UniV2Factory, "Vault: Invalid UniswapV2 factory provided");

        // Check if we can verify contract-deployed tokens on etherscan
        address token = address(new GenericERC20Token(params, address(WETH)));
        address pool = GenericERC20Token(payable(token)).addLiquidity{value: package.BorrowedLiquidity}(params.TotalSupply);

        tokenDeployers[token] = msg.sender;
        liquidityPools[token] = pool;
        tokens[token] = TokenInfo({
           CreationTime: uint40(block.timestamp),
           PackageId: package_id,
           Reserved: 0,
           LastPaidWeek: 0,
           Pending: 0,
           RemainingDebt: uint80(package.BorrowedLiquidity),

           TotalPaid: 0
        });

        emit TokenDeployed(
            msg.sender,
            token,
            params,
            package_id,
            package.BorrowedLiquidity
        );

        // Send package cost to esEMBR so it can be distributed
        (bool success, ) = esEmbr.call{value: msg.value}("");
        require(success, "Vault: Failed to send ether to esEMBR");

        return token;
    }

    // Transfers all tokens from the token contract to this vault and sells them
    // @returns the amount of eth received from selling
    function liquidateToken(GenericERC20Token token, address swap_router, uint256 minTokenOut) internal {
        uint256 contract_token_balance = token.withdrawTokens();
        if (contract_token_balance == 0) {
            return;
        }

        address[] memory path = new address[](2);
        path[0] = address(token);
        path[1] = address(WETH);

        // Wrap in a try catch to prevent losing access to the borrowed ETH if the token or dex revert for whatever reason.
        try IUniswapV2Router01(swap_router).swapExactTokensForETHSupportingFeeOnTransferTokens(
            contract_token_balance,
            minTokenOut,
            path,
            address(this),
            type(uint256).max
        ) { } catch {
			// Ignore
        }
    }

    function removeLiquidityETH(IUniswapV2Pair pair, uint256 amount) internal returns(uint256, uint256) {
        pair.transfer(address(pair), amount); // Must send liquidity to pair first before pulling (burning)
        (uint256 amount0, uint256 amount1) = pair.burn(address(this));
        (uint256 amountToken, uint256 amountEth) = address(WETH) == pair.token0() ? (amount1, amount0) : (amount0, amount1);

        WETH.withdraw(amountEth);

        return (amountToken, amountEth);
    }

	event TokenDefaulted(address token, address liquidator, uint256 eth_amount, uint256 token_amount);
    function tryPullLiq(GenericERC20Token token, uint256 minTokenOut) external {
        TokenInfo memory tokenInfo = tokens[address(token)];
        require(tokenInfo.RemainingDebt != 0, "Vault: Invalid token provided or debt is already paid off");

        // first we check if token actually missed their payments
        uint16 currentWeek = uint16((block.timestamp - tokenInfo.CreationTime) / 604800) + 1;
        require(currentWeek > tokenInfo.LastPaidWeek + 1, "Vault: Only unhealthy tokens can be liquidated");

        Package memory package = packages[tokenInfo.PackageId];

        address swap_router = token.swapRouter();

        // Sell whatever tax tokens are left in the token's contract
        liquidateToken(token, swap_router, minTokenOut);

        IUniswapV2Pair pair = IUniswapV2Pair(token.initial_liquidity_pool());

        (uint256 amntTokenPulled, uint256 amntEthPulled) = removeLiquidityETH(pair, pair.balanceOf(address(this)));

        uint256 _borrowedLiquidity = package.BorrowedLiquidity;
        uint256 _tokenTotalSupply = token.totalSupply();

        // Uniswap burns a very small amount of tokens, so if you add 1eth to LP then instantly pull you will get 0.999..99 eth back. 
        // Make sure we don't underflow when that happens
        uint256 ethAmount = amntEthPulled < _borrowedLiquidity ? 0 : amntEthPulled - _borrowedLiquidity;
        uint256 tokenAmount = amntTokenPulled > _tokenTotalSupply ? 0 : _tokenTotalSupply - amntTokenPulled; 

        // Make ppl claim it turbo
        claims[address(token)] = ClaimInfo({
            EthAmount: ethAmount, // Total eth amount available for users to claim
            TokenAmount: tokenAmount // The tokens circulating outside the LP
        });

        // stop transfers
        token.disableTransfers();

        delete tokens[address(token)];

        // Reward the user esEMBR for pulling liq

        // Clamp reward by `pullingMaxHoursReward`
        uint256 hoursSinceWeekStarted = (block.timestamp - (tokenInfo.CreationTime + tokenInfo.LastPaidWeek * 604800)) / 3600;
        if (hoursSinceWeekStarted > pullingMaxHoursReward) hoursSinceWeekStarted = pullingMaxHoursReward;

        IEsEMBR(esEmbr).reward(msg.sender, hoursSinceWeekStarted * pullingRewardPerHour + pullingBaseReward);

		emit TokenDefaulted(address(token), msg.sender, ethAmount, tokenAmount);
    }

    // When a failed project's liquidity is pulled, users can exchange their tokens to the ETH the vault pulled from LP, proportional to their share
    function redeemToken(GenericERC20Token token, uint256 amount) nonReentrant external returns (uint) {
        require(tokenDeployers[address(token)] != address(0) && token.emberStatus() == GenericERC20Token.EmberDebtStatus.DEFAULTED, "Vault: Unable to claim eth from a token that hasn't defaulted");

        // Tokens will be sent to this contract where they will basically count as burned
        token.transferFrom(msg.sender, address(this), amount);

        ClaimInfo memory claimInfo = claims[address(token)];
        uint256 refund = amount * claimInfo.EthAmount / claimInfo.TokenAmount;

        (bool success,) = msg.sender.call{value: refund}("");
        require(success, "Vault: Failed to send ether");

        return refund;
    }

    // Users can also exchange LP tokens for their share of the pulled LP
    function redeemLPToken(GenericERC20Token token, uint256 amount) nonReentrant external returns (uint) {
        require(tokenDeployers[address(token)] != address(0) && token.emberStatus() == GenericERC20Token.EmberDebtStatus.DEFAULTED, "Vault: Unable to claim eth from a token that hasn't defaulted");
        IUniswapV2Pair lp_token = IUniswapV2Pair(token.initial_liquidity_pool());

        // We could directly transfer the LP token to the LP and burn it to save gas
        lp_token.transferFrom(msg.sender, address(this), amount);

        // Using lp_token.burn saves gas fosho but gotta rewrite some code, will do later
        // both the tokens and the eth will be sent to the vault contract
        (uint256 amntTokenPulled, uint256 amntEthPulled) = removeLiquidityETH(lp_token, amount);

        ClaimInfo memory claimInfo = claims[address(token)];
        uint256 refund = amntTokenPulled * claimInfo.EthAmount / claimInfo.TokenAmount;

        (bool success,) = msg.sender.call{value: refund + amntEthPulled}("");
        require(success, "Vault: Failed to send ether");

        return refund + amntEthPulled;
    }

    // interest_paid: the amount of interest the protocol made from interest
    function onDebtPaidOff(GenericERC20Token token, uint256 interest_paid) internal {
        address deployer = tokenDeployers[address(token)];

        // Free up space
        delete tokens[address(token)];
        delete tokenDeployers[address(token)];

        token.transferOwnershipToRealOwner(deployer);

		IERC20 lp_token = IERC20(liquidityPools[address(token)]);
		lp_token.transfer(deployer, lp_token.balanceOf(address(this)));

        // Send the eth made from interest to esEMBR so its revshared
        (bool success, ) = esEmbr.call{value: interest_paid}("");
        require(success, "Vault: Failed to send ether to esEMBR");
    }

    receive() external payable {
		// Vault can receive ETH
    }

    // This function can be called to collect fees and pay off debt but also by sending in eth to help pay off debt faster
    event DebtDecrease(address token, uint256 new_debt);
    event DebtPaidOff(address token);
    function payup(GenericERC20Token token) nonReentrant payable external returns(uint80, uint80, uint80, uint) {
        require(msg.sender == tokenDeployers[address(token)], "Vault: Only token deployer can claim fees");

        TokenInfo memory tokenInfo = tokens[address(token)];

        Package memory package = packages[tokenInfo.PackageId];

        uint80 collectedEth = uint80(token.withdrawEth()) + uint80(msg.value) + tokenInfo.Pending;

        // from now on, this function wont revert. It will simply try to pay off as much as it can and update the info.
        uint16 currentWeek = uint16((block.timestamp - tokenInfo.CreationTime) / 604800) + 1;
        if (currentWeek > package.Duration) {
            currentWeek = package.Duration;
        }

        (uint16 paidForWeeks, uint80 newDebt, uint80 newPending) = payOffWeeks(tokenInfo.RemainingDebt, collectedEth, currentWeek - tokenInfo.LastPaidWeek, package.Duration - tokenInfo.LastPaidWeek, package.DebtGrowthPerWeek);
        tokenInfo.LastPaidWeek += paidForWeeks;
        tokenInfo.RemainingDebt = newDebt;
        tokenInfo.Pending = newPending;
        tokenInfo.TotalPaid += collectedEth;

        tokens[address(token)] = tokenInfo;

        // Check if deployer just paid off all debt
        if (newDebt == 0) {
            // Send any leftover ETH to the owner
            if (newPending != 0) {
                (bool success, ) = msg.sender.call{value: newPending}("");
                require(success, "Vault: payup: Failed to send ether");
            }

            onDebtPaidOff(token, tokenInfo.TotalPaid - package.BorrowedLiquidity);

            emit DebtPaidOff(address(token));
            return (collectedEth, 0, 0, tokenInfo.TotalPaid);
        }

        emit DebtDecrease(address(token), newDebt);

        return (collectedEth, newDebt, newPending, tokenInfo.TotalPaid);
    }

    function payOffWeeks(uint80 debt, uint80 balance, uint16 shouldPayOffWeeks, uint16 weeksRemaining, uint16 growthPerWeek) public pure returns (uint16, uint80, uint80) {
        // Increate debt according to apy
        uint80 nextWeeksDebt;
        uint16 paidForWeeks;
        uint80 newDebt = debt;
        uint80 newPending = balance;

        // Is it possible to run out of gas here?
        for (uint256 i = 0; i < shouldPayOffWeeks; i++) {
            uint80 newDebt2 = newDebt + newDebt * growthPerWeek / 10000;
            nextWeeksDebt = newDebt2 / weeksRemaining;
            if (newPending >= nextWeeksDebt) {
                // can pay off a week
                newDebt = newDebt2;
                newDebt -= nextWeeksDebt;
                newPending -= nextWeeksDebt;
                paidForWeeks++;
                weeksRemaining--;
            } else {
                // no paid offs turbo
                return (paidForWeeks, newDebt, newPending);
            }
        }

        // if theres anything LEFT after paying off the current weeks, we put it towards paying off the real debt
        if (newDebt >= newPending) {
            newDebt -= newPending;
            newPending = 0;
        } else {
            newPending -= newDebt;
            newDebt = 0;
        }

        return (paidForWeeks, newDebt, newPending);
    }

    // ============================== OWNER-ONLY FUNCTIONS ==============================
    function setRewardSettings(uint256 _base, uint256 _max, uint256 _rate) onlyOwner external {
        pullingBaseReward = _base;
        pullingMaxHoursReward = _max;
        pullingRewardPerHour = _rate;
    }

    function setEsEMBR(address payable _esEmbr) onlyOwner external {
        require(address(esEmbr) == address(0), "Vault: Cannot set esEMBR again");
        esEmbr = _esEmbr;
    }

    // Owner can add new packages
    function addPackage(Package calldata _package) external onlyOwner {
        require(_package.BorrowedLiquidity > 0, "Vault: Liquidity cannot be 0");

        packages[nextPackageId++] = _package;
    }

    // Packages can be enabled & disabled, but never removed
    function setPackageEnabled(uint256 package_id, uint8 _status) external onlyOwner {
        require(packages[package_id].BorrowedLiquidity != 0, "Vault: Invalid package provided");

        packages[package_id].Enabled = _status;
    }

    // Manage DEX routers and factories
    function setRouterStatus(address _router, address _factory, bool status) external onlyOwner {
        require(_router != address(0), "Router address cannot be 0");
        require(_factory != address(0), "Factory address cannot be 0");

        allowed_routers[_router] = status;
        allowed_factories[_factory] = status;

        router_factory[_router] = _factory;
    }

    // ============================== FUNCTIONS CALLED BY ESEMBR ==============================

    // Called by esEMBR when a user wants to unstake their eth, note that the user will have to wait if the amount they're trying to unstake is currently utilized
    function unstakeEth(uint256 amount, address unstaker) onlyEsEMBR external {
        (bool success, ) = unstaker.call{value: amount}("");
        require(success, "Vault: unstakeEth: Failed to send ether");
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./EsEMBRRewardsDistributor.sol";
import "./EmberVault.sol";
import "./IVester.sol";
import "./IEMBR.sol";
import "solmate/tokens/ERC20.sol";
import "solmate/auth/Owned.sol";

contract EsEMBR is ERC20, Owned, IEsEMBR {
    IEMBRToken public embr;
    address public distributor;
    EmberVault public vault;

    uint256 private totalEthStaked;
    uint256 private totalEmbrStaked;
    uint256 private totalRewardPerEth;
    uint256 private totalRewardPerEmbr;
    uint256 private totalEthPerEsembr;

    uint256 public rewardsLeft = 15_000_000 * 1e18;

    mapping(address => uint256) public stakedEth;
    mapping(address => uint256) public stakedEmbr;
    mapping(address => uint256) entriesEth;
    mapping(address => uint256) entriesEmbr;
    mapping(address => uint256) claimableRewards;

    uint256 public constant PRECISION = 1e30; // thanks gmx

    mapping(address => uint256) public entries;
    mapping(address => uint256) public claimableEth;
    mapping(address => bool) public revShareSources;

    mapping(uint256 => IVester) vesters; // mapping(Timeframe => IVester)
    mapping(uint256 => bool) enabled_vesters; // mapping(Timeframe => bool)

    event Claimed(address indexed user, uint256 amount);

    constructor(address payable _embr, address _distributor, address payable _vault) ERC20("Escrowed EMBR", "esEMBR", 18) Owned(msg.sender) {
        vault = EmberVault(_vault);
        embr = IEMBRToken(_embr);
        distributor = _distributor;

        revShareSources[_vault] = true; // The vault will send the package costs right after token is created
        revShareSources[msg.sender] = true; // Owner will periodically send tax revshare
    }

    modifier onlyDistributor() {
        require(msg.sender == distributor, "esEMBR: Only the distributor can access this function");
        _;
    }

    receive() external payable {
        require(revShareSources[msg.sender], "esEMBR: Only whitelisted addresses can send ETH to esEMBR");

        _updateRevShareForAll(msg.value);
    }

    // =============================== SOUL BOUND OVERRIDES ===============================
    // Transfers should only be allowed to be done by the distributor
    function _transfer(address from, address to, uint256 amount) internal {
        uint256 from_balance = balanceOf[from];
        require(from_balance >= amount, "esEMBR: Amount exceeds balance"); /// I think not needed, the instruction below should revert since we are using SafeMath

        balanceOf[from] = from_balance - amount;
        balanceOf[to] += amount;

        emit Transfer(from, to, amount);
    }

    function transfer(address to, uint256 amount) onlyDistributor public override returns (bool) {
        _transfer(msg.sender, to, amount);

        return true;
    }

    function _mintRewards(address to, uint256 amount) internal {
        rewardsLeft -= amount;

        _mint(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) onlyDistributor public override returns (bool) {
        _transfer(from, to, amount);

        return true;
    }

    function approve(address, uint256) public pure override returns (bool) {
        revert("esEMBR: Approvals are not allowed");
    }

    function permit(address, address, uint256, uint256, uint8, bytes32, bytes32) public pure override {
        revert("esEMBR: Permits are not allowed");
    }

    // =============================== ETH STAKING/UNSTAKING ===============================
    event StakedEth(address user, uint256 amount);
    function stakeEth() external payable {
        require(msg.value != 0, "esEMBR: Staked amount cannot be 0");

        _updateRewardsEthForUser(msg.sender);

        stakedEth[msg.sender] += msg.value;
        totalEthStaked += msg.value;

        // send eth to vault
        (bool success, ) = payable(address(vault)).call{value: msg.value}("");
        require(success, "esEMBR: Error forwarding the ETH to the Vault");
    }

    event UnstakedEth(address user, uint256 amount);
    function unstakeEth(uint256 amount) external {
        require(amount != 0, "esEMBR: Unstaked amount cannot be 0");

        _updateRewardsEthForUser(msg.sender);

        uint256 staked = stakedEth[msg.sender];
        require(staked >= amount, "esEMBR: Requested amount exceeds staked amount");

        stakedEth[msg.sender] = staked - amount;
        totalEthStaked -= amount;

        // pull eth from vault
        vault.unstakeEth(amount, msg.sender);

        emit UnstakedEth(msg.sender, amount);
    }

    // =============================== EMBR STAKING/UNSTAKING ===============================
    event StakedEmbr(address user, uint256 amount);
    function stakeEmbr(uint256 amount) external {
        require(amount != 0, "esEMBR: Staked amount cannot be 0");

        _updateRewardsEmbrForUser(msg.sender);

        IEMBRToken(embr).transferFrom(msg.sender, address(this), amount);

        stakedEmbr[msg.sender] += amount;
        totalEmbrStaked += amount;

        emit StakedEmbr(msg.sender, amount);
    }

    event UnstakedEmbr(address user, uint256 amount);
    function unstakeEmbr(uint256 amount) external {
        require(amount != 0, "esEMBR: Unstaked amount cannot be 0");
    
        _updateRewardsEmbrForUser(msg.sender);

        uint256 staked = stakedEmbr[msg.sender];
        require(staked >= amount, "esEMBR: Requested amount exceeds staked amount");

        stakedEmbr[msg.sender] = staked - amount;
        totalEmbrStaked -= amount;

        IEMBRToken(embr).transfer(msg.sender, amount);

		emit UnstakedEmbr(msg.sender, amount);
    }
    
    // ======================== VAULT-ONLY FUNCTIONS =====================
    // This is called by the vault to reward users that pull liquidity of failed tokens
    function reward(address recipient, uint256 amount) external {
        require(msg.sender == address(vault), "esEMBR: Only the vault can reward");

        uint256 _rewardsLeft = rewardsLeft;
        if (amount > _rewardsLeft) amount = _rewardsLeft;

        _updateRevShareForUser(0, recipient);
        _mintRewards(recipient, amount);
    }

    // =============================== CLAIMING ===============================
    // EMBR and ETH stakers can call this function to receive their esEMBR
    function claim() external returns (uint256) {
        _updateRewardsEthForUser(msg.sender);
        _updateRewardsEmbrForUser(msg.sender);
        _updateRevShareForUser(0, msg.sender);

        uint256 to_claim = claimableRewards[msg.sender];
        if (to_claim == 0) return 0;

        claimableRewards[msg.sender] = 0;

        _mintRewards(msg.sender, to_claim);

        return to_claim;
    }

    // This pays out the ETH made from rev share to the esEMBR holder
    function claimRevShare() public returns (uint256) {
        _updateRevShareForUser(0, msg.sender);

        uint256 to_claim = claimableEth[msg.sender];
        if (to_claim == 0) return 0;

        claimableEth[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value: to_claim}("");
        require(success, "esEMBR: claimRevShare: failed to send ether");

        return to_claim;
    }
    
    // =============================== ETH REWARDS UPDATER ===============================
    // This function should be called by distributor when the rate changes
    function updateRewardsEthForAll() public {
        uint256 reward_amount = EsEMBRRewardsDistributor(distributor).distributeForEth();
        uint256 _totalEthStaked = totalEthStaked;

        if (reward_amount != 0 && _totalEthStaked != 0) {
            totalRewardPerEth += reward_amount * PRECISION / _totalEthStaked;
        }
    }

    function _updateRewardsEthForUser(address _user) internal {
        updateRewardsEthForAll();

        uint256 staked = stakedEth[_user];
        uint256 userReward = (staked * (totalRewardPerEth - entriesEth[_user])) / PRECISION;

        claimableRewards[_user] += userReward;
        entriesEth[_user] = totalRewardPerEth;
    }

    // =============================== EMBR REWARDS UPDATER ===============================
    function updateRewardsEmbrForAll() public {
        uint256 reward_amount = EsEMBRRewardsDistributor(distributor).distributeForEmbr();
        uint256 supply = totalEmbrStaked;

        if (reward_amount != 0 && supply != 0) {
            totalRewardPerEmbr += reward_amount * PRECISION / supply;
        }
    }

    function _updateRewardsEmbrForUser(address receiver) private {
        updateRewardsEmbrForAll();

        uint256 staked = stakedEmbr[receiver];
        uint256 userReward = (staked * (totalRewardPerEmbr - entriesEmbr[receiver])) / PRECISION;

        claimableRewards[receiver] += userReward;
        entriesEmbr[receiver] = totalRewardPerEmbr;
    }

    // =============================== REV SHARE UPDATER ===============================
    function _updateRevShareForAll(uint256 added) internal {
        uint256 _totalSupply = totalSupply;

        if (added != 0 && _totalSupply != 0) {
            totalEthPerEsembr += added * PRECISION / _totalSupply;
        }
    }

    function _updateRevShareForUser(uint256 added, address receiver) internal {
        _updateRevShareForAll(added);

        uint256 staked = balanceOf[receiver];
        uint256 userReward = (totalEthPerEsembr - entries[receiver]) * staked / PRECISION;

        claimableEth[receiver] += userReward;
        entries[receiver] = totalEthPerEsembr;
    }

    function vest(uint256 timeframe, uint256 amount) external {
        require(balanceOf[msg.sender] >= amount, "esEMBR: Amount exceeds your balance");

        IVester _vester = vesters[timeframe];
        require(address(_vester) != address(0), "esEMBR: Invalid vesting timeframe");
        require(enabled_vesters[timeframe], "esEMBR: This vesting timeframe is currently disabled");

        // Update revshare state so the user doesn't keep collecting revshare for the old balance
        _updateRevShareForUser(0, msg.sender);

        // Burn the tokens
        _burn(msg.sender, amount);

        // Claim whatever EMBR rewards the user had pending in this timeframe before vesting the new amount
        _collect(msg.sender, timeframe);

        _vester.vest(msg.sender, amount);
    }

    // Useful for batching multiple different claims into one call
    function batchCollectVested(uint[] calldata timeframes) external returns (uint) {
        uint256 totalClaimed = 0;

        for (uint256 i = 0; i < timeframes.length; i++) {
            totalClaimed += _collect(msg.sender, timeframes[i]);
        }

        return totalClaimed;
    }

    // Collect the vested EMBR, if any
    function collectVested(uint256 timeframe) external returns (uint) {
        return _collect(msg.sender, timeframe);
    }

    // Checks with the vester if there is any EMBR to claim, and if yes, transfer the EMBR and emit event
    // Returns the claimed amount
    function _collect(address addy, uint256 timeframe) internal returns(uint) {
        uint256 claimable_amount = vesters[timeframe].claim(addy);
        if (claimable_amount != 0) {
            embr.transfer(addy, claimable_amount);

            emit Claimed(msg.sender, claimable_amount);
        }

        return claimable_amount;
    }

    // ====================== VIEW FUNCTIONS ========================
    // Returns the amount of esEMBR tokens that are available to be claimed by _address, both for embr staking and eth staking
    function claimable(address _address) public view returns (uint256) {
        uint256 stakedAmountEth = stakedEth[_address];
        uint256 stakedAmountEmbr = stakedEmbr[_address];
        if (stakedAmountEth == 0 && stakedAmountEmbr == 0) {
            return claimableRewards[_address];
        }

        uint256 _totalEthStaked = totalEthStaked;
        uint256 userRewardForEth;
        if (_totalEthStaked != 0) {
            uint256 pendingRewardsEth = EsEMBRRewardsDistributor(distributor).pendingForEth() * PRECISION;
            uint256 currentTotalRewardPerEth = totalRewardPerEth + (pendingRewardsEth / _totalEthStaked);

            userRewardForEth = stakedAmountEth * (currentTotalRewardPerEth - entriesEth[_address]) / PRECISION;
        }

        uint256 _totalEmbrStaked = totalEmbrStaked;
        uint256 userRewardForEmbr;
        if (_totalEmbrStaked != 0) {
            uint256 pendingRewardsEmbr = EsEMBRRewardsDistributor(distributor).pendingForEmbr() * PRECISION;
            uint256 currentTotalRewardPerEmbr = totalRewardPerEmbr + (pendingRewardsEmbr / _totalEmbrStaked);

            userRewardForEmbr = stakedAmountEmbr * (currentTotalRewardPerEmbr - entriesEmbr[_address]) / PRECISION;
        }

        return claimableRewards[_address] + userRewardForEth + userRewardForEmbr;
    }

    // Accounts for the pending rewards as well
    function claimableRevShare(address _address) public view returns (uint256) {
        uint256 esembr_balance = balanceOf[_address];
        if (esembr_balance == 0) {
            return claimableEth[_address];
        }

        return claimableEth[_address] + ((totalEthPerEsembr - entries[_address]) * esembr_balance / PRECISION);
    }

    // Returns the amount of EMBR tokens that can be claimed by esEMBR vesters
    function claimableEMBR(address addy, uint256[] calldata timeframes) public view returns (uint256) {
        uint256 total = 0;

        for (uint256 i = 0; i < timeframes.length; i++) {
            ( uint256 claimableAmount, ) = vesters[timeframes[i]].claimable(addy);

            total += claimableAmount;
        }

        return total;
    }

    function getVestedEsEMBR(address addy, uint256[] calldata timeframes) public view returns (uint256[] memory) {
        uint256[] memory vestedAmounts = new uint256[](timeframes.length);

        for (uint256 i = 0; i < timeframes.length; i++) {
            vestedAmounts[i] = vesters[timeframes[i]].vestingAmount(addy);
        }

        return vestedAmounts;
    }

    // ====================== ADMIN FUNCTIONS =========================
    // Add new vester contracts
    function addVester(uint256 timeframe, IVester vester) onlyOwner external {
        require(vester.vestingTime() == timeframe, "esEMBR: The timeframe provided does not match the vester's timeframe");
        require(address(vesters[timeframe]) == address(0), "esEMBR: The timeframe provided already exists");

        vesters[timeframe] = vester;
        enabled_vesters[timeframe] = true;
    }

    // Allow owner to disable specific vesting timeframes, this will stop new users from vesting but existing vesters will be able to claim their tokens without an issue.
    function setVesterStatus(uint256 timeframe, bool status) onlyOwner external {
        require(address(vesters[timeframe]) != address(0), "esEMBR: Timeframe does not exist");

        enabled_vesters[timeframe] = status;
    }

    function setRevShareSource(address _source, bool _enabled) onlyOwner external {
        revShareSources[_source] = _enabled;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./IEsEMBR.sol";
import "solmate/auth/Owned.sol";

contract EsEMBRRewardsDistributor is Owned {
    IEsEMBR public esEmbr;

    uint256 public emissionPerSecondEth; // Max esEMBR emissions per second for ETH stakers
    uint256 public emissionPerSecondEmbr; // Max esEMBR emissions per second for EMBR stakers

    uint256 private lastEmissionTimeEth;
    uint256 private lastEmissionTimeEmbr;

    constructor() Owned(msg.sender) { }

    modifier onlyEsEMBR() {
        require(msg.sender == address(esEmbr), "EsEMBRRewardsDistributor: Only esEMBR contract can call this function");
        _;
    }

    function setEsEMBR(address payable _esEmbr) external onlyOwner {
        esEmbr = IEsEMBR(_esEmbr);
    }

    function setEmissionPerSecondEth(uint256 amount) external onlyOwner {
        esEmbr.updateRewardsEthForAll();

        emissionPerSecondEth = amount;
        lastEmissionTimeEth = block.timestamp;
    }

    function setEmissionPerSecondEmbr(uint256 amount) external onlyOwner {
        esEmbr.updateRewardsEmbrForAll();

        emissionPerSecondEmbr = amount;
        lastEmissionTimeEmbr = block.timestamp;
    }

    function _clamp(uint256 value, uint256 max) internal pure returns(uint256) {
        return value > max ? max : value;
    }

    function distributeForEth() onlyEsEMBR external returns (uint256) {
        uint256 tokens_to_emit = pendingForEth();
        if (tokens_to_emit == 0) return 0;

        lastEmissionTimeEth = block.timestamp;

        return _clamp(tokens_to_emit, esEmbr.rewardsLeft());
    }

    function distributeForEmbr() onlyEsEMBR external returns (uint256) {
        uint256 tokens_to_emit = pendingForEmbr();
        if (tokens_to_emit == 0) return 0;

        lastEmissionTimeEmbr = block.timestamp;

        return _clamp(tokens_to_emit, esEmbr.rewardsLeft());
    }

    function pendingForEth() public view returns (uint256) {
        if (lastEmissionTimeEth == block.timestamp) return 0;

        return (block.timestamp - lastEmissionTimeEth) * emissionPerSecondEth;
    }

    function pendingForEmbr() public view returns (uint256) {
        if (lastEmissionTimeEmbr == block.timestamp) return 0;

        return (block.timestamp - lastEmissionTimeEmbr) * emissionPerSecondEmbr;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "solmate/tokens/ERC20.sol";
import "solmate/auth/Owned.sol";
import "./IWETH.sol";
import "./IUniswapV2Router01.sol";
import "./IUniswapV2Factory.sol";

contract GenericERC20Token is ERC20, Owned {
    TokenStorage public packedStorage;

    uint256 constant TRANSFER_LOCK_DURATION = 1 minutes; // 1 min

    uint256 public maxSupply;
    uint256 public sell_threshold;

    uint256 public max_transfer_size_per_tx;
    uint256 public max_holding_amount;

    address public WETH;
    address public tax_receiver;
    address public uni_factory;
    address public initial_liquidity_pool;

    mapping(address => bool) public routers;
    mapping(address => bool) public LPs;
    mapping(address => bool) public exclude_from_fees; // no fees if these addresses are transferred from
    mapping(address => bool) public exclude_from_limits; // excluded from max tx side and max holding

    enum EmberDebtStatus { IN_DEBT, DEFAULTED, PAID_OFF }
    struct TokenStorage {
        uint8 BuyTax; // measured in 0.1%.
        uint8 SellTax; // measured in 0.1%.
        uint8 BurnTax; // measured in 0.1%.
        uint40 DeployDate; // This should be good for the next 32000 years.
        bool InSwap;
        address SwapRouter; // Used to periodically sell tokens
        EmberDebtStatus EmberStatus; // 0 we are paying off debt, 1 we are cooked, 2 we are free
    }

    struct ConstructorCalldata {
        string Name;
        string Symbol;
        uint8 Decimals;

        uint256 TotalSupply;
        uint256 MaxSupply;

        uint8 BuyTax;
        uint8 SellTax;
        uint256 SellThreshold;
        uint8 TransferBurnTax;

        address UniV2Factory;
        address UniV2SwapRouter;

        uint256 MaxSizePerTx;
        uint256 MaxHoldingAmount;
    }

    constructor(ConstructorCalldata memory params, address _weth) ERC20(params.Name, params.Symbol, params.Decimals) Owned(msg.sender) {
        sell_threshold = params.SellThreshold;
        tax_receiver = address(this);

        require(params.MaxSupply >= params.TotalSupply, "Max supply must be higher than total supply.");
        maxSupply = params.MaxSupply;

        max_holding_amount = params.MaxHoldingAmount;
        max_transfer_size_per_tx = params.MaxSizePerTx;
        WETH = _weth;
        uni_factory = params.UniV2Factory;

        require(params.BuyTax <= 252 && params.SellTax <= 252, "Buy/sell tax cannot be higher than 25.2%");

        packedStorage = TokenStorage(params.BuyTax, params.SellTax, params.TransferBurnTax, uint40(block.timestamp), false, params.UniV2SwapRouter, EmberDebtStatus.IN_DEBT);

        routers[params.UniV2SwapRouter] = true;

        exclude_from_fees[msg.sender] = true;
		exclude_from_fees[address(0xDEAD)] = true;

        exclude_from_limits[msg.sender] = true;
		exclude_from_limits[address(0xDEAD)] = true;
        exclude_from_limits[params.UniV2SwapRouter] = true;

        allowance[msg.sender][params.UniV2SwapRouter] = type(uint).max; // Allow univ2 router access to all of the vault's tokens as they will be sold when claiming fees
        allowance[address(this)][params.UniV2SwapRouter] = type(uint).max; // Allow univ2 router access to all of this contract's tokens as they will be used when adding liq and tax swaps

        _mint(address(this), params.TotalSupply);
    }

    function addLiquidity(uint256 token_amount) external payable onlyOwner returns(address) {
        require(initial_liquidity_pool == address(0), "Liquidity already added");

        IUniswapV2Router01(packedStorage.SwapRouter).addLiquidityETH{value: msg.value}(
            address(this),
            token_amount,
            token_amount,
            msg.value,
            msg.sender,

            type(uint).max
        );

        address _initial_liquidity_pool = calculateUniV2Pair();
        initial_liquidity_pool = _initial_liquidity_pool;
        LPs[_initial_liquidity_pool] = true;

        return _initial_liquidity_pool;
    }

    function mint(address receiver, uint256 amount) public onlyOwner {
        require(maxSupply >= totalSupply + amount, "Total supply cannot exceed max supply");

        // Bypasses max_holding_amount and max_transfer_size_per_tx and all other checks
        _mint(receiver, amount);
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        if (packedStorage.EmberStatus == EmberDebtStatus.DEFAULTED && msg.sender == initial_liquidity_pool && to == owner) {
            // Tokens are being transfered from LP to the Vault = LP burn.

            balanceOf[msg.sender] = balanceOf[msg.sender] - amount;
            balanceOf[to] = balanceOf[to] + amount;

            emit Transfer(msg.sender, to, amount);

            return true;
        }

        _transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        if (packedStorage.EmberStatus == EmberDebtStatus.DEFAULTED && msg.sender == owner) {
            // The vault contract is trying to burn the user's tokens to refund them eth.
            // The owner in this case is the ember vault for sure since packedStorage.EmberStatus can only be changed to EmberDebtStatus.DEFAULTED by the vault
            // And it can't be changed back after that.

            balanceOf[from] = balanceOf[from]- amount;
            balanceOf[to] = balanceOf[to] + amount;

            emit Transfer(from, to, amount);

            return true;
        }

        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.
        if (allowed != type(uint256).max) {
            allowance[from][msg.sender] = allowed - amount; // Will revert if allowance is not enough if solidity version is >=0.8.0
        }

        _transfer(from, to, amount);

        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        TokenStorage memory info = packedStorage;

        require(info.EmberStatus != EmberDebtStatus.DEFAULTED, "Token failed to pay off Ember debt. Transfers have been stopped, but claiming ETH is possible through the vault contract");

        // This branch will only ever be entered once, which is when the vault creates the token and adds LP, after that initial_liquidity_pool will be set to the actual LP addy
        if (initial_liquidity_pool == address(0)) {
            balanceOf[from] = balanceOf[from] - amount;
            balanceOf[to] = balanceOf[to] + amount;

            emit Transfer(from, to, amount);

            return;
        }

        // Disable transfers if 1 minute hasn't passed yet since deployment.
        if ((info.DeployDate + TRANSFER_LOCK_DURATION > block.timestamp) && from != owner && to != owner) {
            revert("You must wait 1 minute after deployment to be able to trade this token");
        }

        require(from != address(0), "Transfer from the zero address");
        require(to != address(0), "Transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        require(max_transfer_size_per_tx >= amount || exclude_from_limits[from], "Max size per tx exceeded");

        uint256 taxFee = 0;
        if (!exclude_from_fees[from] && !exclude_from_fees[to]) {
            if (LPs[from]) {
                if (info.BuyTax != 0) {
                    if (info.EmberStatus == EmberDebtStatus.PAID_OFF) {
                        taxFee = (amount * info.BuyTax) / 1000;
                    } else {
                        taxFee = (amount * (info.BuyTax + 3)) / 1000; // add 0.3% for protocol
                    }

                    balanceOf[address(this)] = balanceOf[address(this)] + taxFee;
                    emit Transfer(from, address(this), taxFee);
                }
            } else if (LPs[to]) {
                if (info.SellTax != 0) {
                    if (info.EmberStatus == EmberDebtStatus.PAID_OFF) {
                        taxFee = (amount * info.SellTax) / 1000;
                    } else {
                        taxFee = (amount * (info.SellTax + 3)) / 1000; // add 0.3% for protocol
                    }

                    balanceOf[address(this)] = balanceOf[address(this)] + taxFee;
                    emit Transfer(from, address(this), taxFee);
                }

                // If the owner completely removes tax, there will probably still be some tokens left in the contract that will have to be withdrawn and sold manually.
                if (info.BuyTax != 0 || info.SellTax != 0) {
                    uint256 balance = balanceOf[address(this)];
                    if (!info.InSwap && balance > sell_threshold) {
                        packedStorage.InSwap = true;

                        address[] memory path = new address[](2);
                        path[0] = address(this);
                        path[1] = WETH;

                        // Wrap in a try catch to prevent owner from rugging by setting invalid router
                        try IUniswapV2Router01(info.SwapRouter).swapExactTokensForETHSupportingFeeOnTransferTokens(
                            taxFee,
                            0,
                            path,
                            tax_receiver,
                            type(uint).max
                        ) { } catch {
                            // Ignore, to prevent trades from failing if owner sets an invalid router
                        }

                        packedStorage.InSwap = false;
                    }
                }
            } else if (info.BurnTax != 0) {
                // Only apply burn tax if buy/sell tax wasnt applied.
                taxFee = (amount * info.BurnTax) / 1000;

                balanceOf[address(0)] = balanceOf[address(0)] + taxFee;
                emit Transfer(from, address(0), taxFee);
            }
        }

        // Apply balance changes
        balanceOf[from] = balanceOf[from] - amount;
        balanceOf[to] = balanceOf[to] + (amount - taxFee);
        emit Transfer(from, to, amount - taxFee);

        require(balanceOf[to] <= max_holding_amount || exclude_from_limits[to], "Max holding per wallet exceeded");
    }

    // Withdraws token to owner's addy
    function withdrawTokens() onlyOwner external returns(uint) {
        uint256 balance = balanceOf[address(this)];
        if (balance == 0) return 0;

        balanceOf[msg.sender] = balanceOf[msg.sender] + balance;
        balanceOf[address(this)] = balanceOf[address(this)] - balance;

        emit Transfer(address(this), msg.sender, balance);

        return balance;
    }

    // Withdraws ETH to owner
    function withdrawEth() external onlyOwner returns (uint) {
        // native_balance should now include the previously unwrapped weth
        uint256 native_balance = address(this).balance;
        if (native_balance != 0) {
            (bool sent, ) = owner.call{value: native_balance}("");
            require(sent, "Failed to send Ether");
        }

        return native_balance;
    }

    // ============================== [START] Functions that are supposed to be called by the vault only ==============================
    // Called right after we pull liq and enable claims
    function disableTransfers() external onlyOwner {
        require(packedStorage.EmberStatus == EmberDebtStatus.IN_DEBT, "Can only disable transfers on a token that's currently in debt");
        packedStorage.EmberStatus = EmberDebtStatus.DEFAULTED;
    }

    // Called right after the Ember debt gets fully paid off
    function transferOwnershipToRealOwner(address _real_owner) external onlyOwner {
        require(packedStorage.EmberStatus == EmberDebtStatus.IN_DEBT, "EmberStatus is supposed to be IN_DEBT");

        // Change tax receiver to new owner
        tax_receiver = _real_owner;

        // Disables the 0.3% protocol fee and disable future liquidations
        packedStorage.EmberStatus = EmberDebtStatus.PAID_OFF; // we free

        transferOwnership(_real_owner);
    }

    // ============================== [END] Functions that are supposed to be called by the vault only ==============================

    function setInitialLiquidityPool(address _addy) public onlyOwner {
        initial_liquidity_pool = _addy;
    }

    function disableMinting() public onlyOwner {
        maxSupply = totalSupply;
    }

    receive() external payable {
        // Enable receiving eth for tax
    }

    function setLP(address _lp, bool _bool) onlyOwner external {
        require(_lp != address(0), "LP address cannot be 0");

        LPs[_lp] = _bool;
    }

    function setExcludedFromFees(address _address, bool _bool) onlyOwner external {
        exclude_from_fees[_address] = _bool;
    }

    function setExcludedFromLimits(address _address, bool _bool) onlyOwner external {
        exclude_from_limits[_address] = _bool;
    }

    function setTaxReceiver(address _tax_receiver) onlyOwner external {
        require(_tax_receiver != address(0), "Tax receiver address cannot be 0");

        tax_receiver = _tax_receiver;
    }

    function setRouter(address _router, address _factory) onlyOwner external {
        require(_router != address(0), "Router address cannot be 0");

        packedStorage.SwapRouter = _router;
        uni_factory = _factory;
    }

    function setTaxes(uint8 _buyTax, uint8 _sellTax) onlyOwner external {
        require(_buyTax <= 252, "buy tax cant be higher than 25.2%");
        require(_sellTax <= 252, "sell tax cant be higher than 25.2%");

        TokenStorage memory info = packedStorage;
        info.BuyTax = _buyTax;
        info.SellTax = _sellTax;
        packedStorage = info;
    }

	function setLimits(
        uint _max_holding,
        uint _max_transfer
    ) external onlyOwner {
        require(
            _max_holding >= totalSupply / 100,
            "Max Holding Limit cannot be less than 1% of total supply"
        );
        require(
            _max_transfer >= totalSupply / 100,
            "Max Transfer Limit cannot be less than 1% of total supply"
        );

        max_holding_amount = _max_holding;
        max_transfer_size_per_tx = _max_transfer;
    }

    // ================== packedStorage viewers =======================
    function buyTax() view public returns (uint) {
        return packedStorage.BuyTax;
    }

    function sellTax() view public returns (uint) {
        return packedStorage.SellTax;
    }

    function burnTax() view public returns (uint) {
        return packedStorage.BurnTax;
    }

    function deployDate() view public returns (uint) {
        return packedStorage.DeployDate;
    }

    function swapRouter() view public returns (address) {
        return packedStorage.SwapRouter;
    }

    function emberStatus() view public returns (EmberDebtStatus) {
        return packedStorage.EmberStatus;
    }

    function calculateUniV2Pair() public view returns (address) {
        return IUniswapV2Factory(uni_factory).getPair(address(this), WETH);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./IERC20.sol";

interface IEMBRToken is IERC20 {

}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.19;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./IVester.sol";
import "./IERC20.sol";

interface IEsEMBR {
    function updateRewardsEthForAll() external;
    function updateRewardsEmbrForAll() external;
    function addVester(uint timeframe, IVester vester) external;
    function reward(address recipient, uint amount) external;

    function claimable(address _address) external view returns (uint256);
    function claim() external returns (uint256);

    function claimableRevShare(address _address) external view returns (uint256);
    function claimRevShare() external returns (uint256);
    function claimableEMBR(address addy, uint256[] calldata timeframes) external view returns (uint256);

    function batchCollectVested(uint[] calldata timeframes) external returns (uint);
    function collectVested(uint timeframe) external returns (uint);

    function rewardsLeft() external returns (uint);
}
pragma solidity ^0.8.0;

interface IUniswapV2Factory {
    function allPairs(uint256) external view returns (address);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address, address) external view returns (address);

    function setFeeTo(address _feeTo) external;

    function setFeeToSetter(address _feeToSetter) external;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

// https://github.com/Uniswap/v2-core/blob/master/contracts/interfaces/IUniswapV2Pair.sol

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

// https://uniswap.org/docs/v2/smart-contracts/router01/
// https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/UniswapV2Router01.sol implementation
// UniswapV2Router01 is deployed at 0xf164fC0Ec4E93095b804a4795bBe1e041497b92a on the Ethereum mainnet, and the Ropsten, Rinkeby, Görli, and Kovan testnets

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) external pure returns (uint amountB);

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountOut);

    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountIn);

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

    function getAmountsIn(
        uint amountOut,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

import "./IUniswapV2Router01.sol";

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

interface IVester {
    function vest(address user, uint256 amount) external; // called by esembr contract only. This is where esembr contract will transfer the vested embr amount to the vester.
    function claimable(address user) external view returns (uint256 /* claimable amount */, uint256 /* entry time */);
    function claim(address user) external returns (uint256); // called by esembr contract only
    function vestingTime() external view returns (uint256);
    function vestingAmount(address) external view returns (uint256);
}
pragma solidity >=0.8.20;

interface IWETH {
    function deposit() external payable;
    function name() external view returns (string memory);

    function approve(address guy, uint256 wad) external returns (bool);

    function totalSupply() external view returns (uint256);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);

    function withdraw(uint256 wad) external;

    function decimals() external view returns (uint8);

    function balanceOf(address) external view returns (uint256);

    function symbol() external view returns (string memory);

    function transfer(address dst, uint256 wad) external returns (bool);
    function allowance(address, address) external view returns (uint256);

    fallback() external payable;
}