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

    uint256 private _totalSupply;

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
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

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
        _totalSupply += amount;

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
            _totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    function balanceOf(address owner) external view returns (uint);
    function sync() external;
}
pragma solidity >=0.6.2;

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
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
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
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
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
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
   function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;    
}
pragma solidity 0.8.19;

    /*
    $$\      $$\                                   $$$$$$$$\ $$\ 
    $$$\    $$$ |                                  $$  _____|\__|
    $$$$\  $$$$ | $$$$$$\  $$$$$$\$$$$\   $$$$$$\  $$ |      $$\ 
    $$\$$\$$ $$ |$$  __$$\ $$  _$$  _$$\ $$  __$$\ $$$$$\    $$ |
    $$ \$$$  $$ |$$$$$$$$ |$$ / $$ / $$ |$$$$$$$$ |$$  __|   $$ |
    $$ |\$  /$$ |$$   ____|$$ | $$ | $$ |$$   ____|$$ |      $$ |
    $$ | \_/ $$ |\$$$$$$$\ $$ | $$ | $$ |\$$$$$$$\ $$ |      $$ |
    \__|     \__| \_______|\__| \__| \__| \_______|\__|      \__|
                                                              */
                                                              /*
    This contract was never owned, and never will be.
    The liquidity is entirely owned by the community.
    The liquidity lock is entirely maintained by the community.
    There is community. You are the community. 
    We, together, are MemeFi.

    https://memefi.wtf
    https://twitter.com/MemeFi__

    There are three stages to this contract.

        1. Liquidity Generation Event
        2. Trading
        3. Unlocking

    It is up to us to determine the best way to transition between these stages.
    It is up to us to determine the duration of the liquidity generation event.
    MemeFi your life. MemeFi your world. MemeFi your future.

    We start with a liquidity generation event. It accepts all ETH above 0.03.
    If the amount is 0.1 ETH or grater, it increases the duration of the LGE by 300 blocks. 
    If it stalls for 300 blocks, we can list it.
    At that point the LGE is over and we begin trading.
    
        * 100% of the circulating supply and 100% of the ETH raised in the LGE will be added to a Uniswap V2 Listing.
        * Selling the token incurs a 1% transaction fee that's given to LP providers to help combat IL.
        * During trading, liquidity can be locked in a rolling ~30 day period (198250 blocks).
        * Once LP Tokens are unlocked, providers are able to remove/sell freely.
        * At any point during the unlock period the 30 day rolling lock is able to be reactivated.

    During trading, the way to lock liquidity is to send an amount of MEFI greater than or equal to the reset amount.
    The first payment to lock liquidity will be 13374.20697 MEFI.

        * 80% of the payment is burned.
        * 20% is sent to the governor.

    If/when the liquidity unlocks, you simply send 0 ETH to the contract to receive your proportional LP Tokens.
    Governor can be renounced at any time to a community controlled contract or even the dEaD address.
                                                  \*/

import "lib/solmate/src/tokens/ERC20.sol";
import "lib/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "lib/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "lib/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

error ContributionTooLow();
error ListingDelayNotElapsed();
error UnlockDelayNotElapsed();
error CanOnlyUnlock();
error LGEEnded();
error NotGovernor();
error ZeroContribution();
error NotZeroAddress();
error LGEHasNotBegun();
error NotDuringLGE();

contract MemeFi is ERC20 {
    address public uniswapV2Pair;
    address payable public governor;

    bool public lgeActive = true;

    uint256 public totalContributions;
    uint256 public listingLPBalance;
    uint256 public lastLockContribution;

    mapping(address => uint256) public contributions;

    uint256 public immutable unlockBlockDelay = 198250;
    uint256 public immutable fee_divisor = 100;
    uint256 public immutable MAXIMUM_CIRCULATING_SUPPLY = 1_337_420_697 ether;
    uint256 public immutable BURN_PERCENTAGE = 80;
    uint256 public immutable blockListingDelay = 300;

    event Contribution(address indexed sender, uint256 amount);
    event Listing(
        address lister,
        uint256 totalContributions,
        uint256 listingLPBalance
    );
    event Unlock(address indexed sender, uint256 amount);
    event LiquidityLockReset(
        address indexed sender,
        uint new_amount,
        uint old_amount,
        uint treasury
    );

    receive() external payable {
        if (!lgeActive) {
            if (contributions[msg.sender] == 0) revert ZeroContribution();
            if (block.number < lastLockContribution + unlockBlockDelay)
                revert UnlockDelayNotElapsed();

            uint256 amount = (listingLPBalance * contributions[msg.sender]) /
                totalContributions;

            contributions[msg.sender] = 0;
            ERC20(uniswapV2Pair).transfer(msg.sender, amount);

            emit Unlock(msg.sender, amount);
        } else {
            if (msg.value < 0.03 ether) revert ContributionTooLow();
            if (msg.value >= 0.1 ether) lastLockContribution = block.number;
            contributions[msg.sender] += msg.value;
            emit Contribution(msg.sender, msg.value);
        }
    }

    constructor() ERC20("MemeFi", "MEFI", 18) {
        lastLockContribution = block.number;
        uniswapV2Pair = IUniswapV2Factory(
            0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
        ).createPair(address(this), 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

        _mint(address(this), MAXIMUM_CIRCULATING_SUPPLY);
        governor = payable(msg.sender);
    }

    function list() external {
        if (lastLockContribution == 0) revert LGEHasNotBegun();
        if (block.number < lastLockContribution + blockListingDelay)
            revert ListingDelayNotElapsed();
        totalContributions = address(this).balance;
        ERC20(address(this)).approve(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D,
            MAXIMUM_CIRCULATING_SUPPLY
        );
        IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D)
            .addLiquidityETH{value: address(this).balance}(
            address(this),
            MAXIMUM_CIRCULATING_SUPPLY,
            0,
            0,
            address(this),
            block.timestamp
        );
        listingLPBalance = IUniswapV2Pair(uniswapV2Pair).balanceOf(
            address(this)
        );
        lgeActive = false;
        emit Listing(msg.sender, totalContributions, listingLPBalance);
    }

    function recover(address token) external {
        if (lgeActive) revert NotDuringLGE();
        if (token == uniswapV2Pair) revert CanOnlyUnlock();
        if (token == address(0)) {
            governor.transfer(address(this).balance);
        } else {
            ERC20(token).transfer(
                governor,
                ERC20(token).balanceOf(address(this))
            );
        }
    }

    function renounce(address _new_governor) external {
        if (msg.sender != governor) revert NotGovernor();
        if (_new_governor == address(0)) revert NotZeroAddress();
        governor = payable(_new_governor);
    }

    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        if (to == address(this) && amount >= requiredResetAmount()) {
            uint256 treasury = (amount * (100 - BURN_PERCENTAGE)) / 100;
            lastLockContribution = block.number;
            _burn(msg.sender, amount - treasury);
            emit LiquidityLockReset(
                msg.sender,
                requiredResetAmount(),
                amount,
                treasury
            );
            return super.transfer(governor, treasury);
        }
        return super.transfer(to, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 fee = 0;
        if (to == uniswapV2Pair && !lgeActive) {
            fee = amount / fee_divisor;
            super.transferFrom(from, uniswapV2Pair, fee);
            IUniswapV2Pair(uniswapV2Pair).sync();
        }
        super.transferFrom(from, to, amount - fee);
        return true;
    }

    function requiredResetAmount() public view returns (uint256) {
        return totalSupply() / 10 ** 5;
    }
}