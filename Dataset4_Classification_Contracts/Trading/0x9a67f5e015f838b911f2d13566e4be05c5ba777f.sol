// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/*    
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│       _______         ______                      _                     │
│      |__   __|       |  ____|                    (_)                    │
│         | | __ ___  _| |__ __ _ _ __ _ __ ___     _ _ __   __ _         │
│         | |/ _` \ \/ /  __/ _` | '__| '_ ` _ \   | | '_ \ / _` |        │
│         | | (_| |>  <| | | (_| | |  | | | | | |  | | | | | (_| |        │
│         |_|\__,_/_/\_\_|  \__,_|_|  |_| |_| |_|(_)_|_| |_|\__, |        │
│                                                            __/ |        │
│                                                           |___/         │
│                                                                         │
│                               taxfarm.ing                               │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
*/

import {ITokenLogic, TokenLogic} from "./TokenLogic.sol";

// utils 
import {IERC20} from "./utils/IERC20.sol";
import {IUniswapV2Router02} from "./utils/IUniswapV2Router02.sol";
import {IUniswapV2Factory} from "./utils/IUniswapV2Factory.sol";
import {Ownable} from "./utils/Ownable.sol";

interface ITokenFactory {
    function externalTryBurn(address token) external;
}

// factory contract for deploying and managing child tokens
contract TokenFactory is Ownable {

    bytes public constant TOKEN_PROXY_BYTECODE = hex"60a060405234801561000f575f80fd5b506040516102dc3803806102dc833981810160405281019061003191906100c9565b8073ffffffffffffffffffffffffffffffffffffffff1660808173ffffffffffffffffffffffffffffffffffffffff1681525050506100f4565b5f80fd5b5f73ffffffffffffffffffffffffffffffffffffffff82169050919050565b5f6100988261006f565b9050919050565b6100a88161008e565b81146100b2575f80fd5b50565b5f815190506100c38161009f565b92915050565b5f602082840312156100de576100dd61006b565b5b5f6100eb848285016100b5565b91505092915050565b6080516101cb6101115f395f81816030015260ea01526101cb5ff3fe60806040526004361061002c575f3560e01c8063629c52a914610070578063d77177501461009a5761002d565b5b5f7f00000000000000000000000000000000000000000000000000000000000000009050365f80375f80365f845af43d5f803e805f811461006c573d5ff35b3d5ffd5b34801561007b575f80fd5b506100846100c4565b6040516100919190610124565b60405180910390f35b3480156100a5575f80fd5b506100ae6100e8565b6040516100bb919061017c565b60405180910390f35b7f10eeeeffffffffffffffffffffffffffffffffffffffffffffffffffffffffff81565b7f000000000000000000000000000000000000000000000000000000000000000081565b5f819050919050565b61011e8161010c565b82525050565b5f6020820190506101375f830184610115565b92915050565b5f73ffffffffffffffffffffffffffffffffffffffff82169050919050565b5f6101668261013d565b9050919050565b6101768161015c565b82525050565b5f60208201905061018f5f83018461016d565b9291505056fea26469706673582212208caaf51ee3f849b605f6e63e26072b5c076726d07d40423546787cda62f1dc5b64736f6c63430008140033";
    bytes public TOKEN_PROXY_DEPLOY_BYTECODE; // deployment bytecode got from TOKEN_PROXY_BYTECODE and constructor argument (token logic)
    uint public uniqueId = 0x1000100000000000000000000000000000000000000000000000000000000000; // first child token unique id (used to keep track of token bytecode uniqueness)

    address payable public protocolFeesRecipient;
    address public immutable tokenLogic; // token logic passed to the newly created tokens

    IUniswapV2Router02 constant uniswapRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Factory immutable uniswapFactory;

    uint8 public stakingFees = 0; // percentage of protocol fees forwarded to staking (initialized at 0 to avoid forwarding to zero address)
    address payable public stakingContract;

    enum LaunchStatus {
        LAUNCH_ACTIVE,
        LIQUIDITY_BURNED,
        LIQUIDITY_REFUNDED
    }   

    struct TokenInfo {
        bool isChildToken;
        uint uniqueId;

        LaunchStatus launchStatus;
        uint feesReceived; // eth amount received so far from the token
    }

    mapping (address => TokenInfo) public childTokens;
    mapping (address => address[]) public tokensDeployed;
    mapping (address => bool) public withdrawalAddresses;

    event TokenCreated(address indexed token, address indexed deployer, string name, string symbol);
    event LiquidityBurned(address indexed token);
    event LiquidityRefunded(address indexed token);

    constructor(address _protocolFeesRecipient) Ownable(msg.sender) {
        protocolFeesRecipient = payable(_protocolFeesRecipient);

        tokenLogic = address(new TokenLogic(address(this)));
        // concatenate base creation bytecode of token proxy with token logic (token proxy constructor parameter)
        TOKEN_PROXY_DEPLOY_BYTECODE = abi.encodePacked(
            TOKEN_PROXY_BYTECODE, 
            abi.encode(tokenLogic)
            );

        uniswapFactory = IUniswapV2Factory(uniswapRouter.factory());
    }

    modifier onlyEoa() {
        require(tx.origin == msg.sender, "Not EOA");
        _;
    }

    function setStaking(address _stakingContract, uint8 _stakingFees) external onlyOwner {
        require(_stakingFees <= 100, "Invalid fees");
        stakingFees = _stakingFees;
        stakingContract = payable(_stakingContract);
    }

    // set addresses able to call withdraw on behalf of deployers (could be used to build automatic bots ...)
    function setWithdrawalAddresses(address account, bool isWithdrawalAddr) external onlyOwner {
        withdrawalAddresses[account] = isWithdrawalAddr;
    }

    function setProtocolFeesRecipient(address payable _protocolFeesRecipient) external {
        require(msg.sender == protocolFeesRecipient);
        protocolFeesRecipient = _protocolFeesRecipient;
    }

    // deploy a child token with its name and symbol and return its address
    function deployToken(string memory _name, string memory _symbol) onlyEoa external payable returns (address) {
        address deployer = msg.sender;
        address token = deployNewBytecode();

        (bool success, ) = token.call{
            value: msg.value
        }(abi.encodeWithSelector(0x90657147, deployer, _name, _symbol));
        require(success, "Error initializing token");
    
        childTokens[token].isChildToken = true;
        childTokens[token].uniqueId = uniqueId - 1;
        tokensDeployed[deployer].push(token);

        emit TokenCreated(token, deployer, _name, _symbol);

        return token;
    }
    
    // deploy a new token proxy bytecode with the current uniqueId
    function deployNewBytecode() private returns (address token) {
        bytes memory bytecode = TOKEN_PROXY_DEPLOY_BYTECODE;
        bytes32 _id = bytes32(uniqueId);

        assembly {
            mstore(add(bytecode, 503), _id) // dynamically replace the current unique id in the bytecode to deploy

            token := create(0, add(bytecode, 0x20), mload(bytecode))

            if iszero(extcodesize(token)) {
                revert(0, 0)
            }
        }
        uniqueId++;
    }

    // receive function, used by the child tokens to forward fees from tokens swaps
    receive() external payable {
        address token = msg.sender;
        if (token == address(uniswapRouter)) return;

        require(childTokens[token].isChildToken, "Unknown token");

        childTokens[token].feesReceived += msg.value;

        bool result = _tryBurn(token);

        // stop acumulating fees and distribute if launch is active
        if (!result && childTokens[token].launchStatus != LaunchStatus.LAUNCH_ACTIVE) {
            uint protocolFees = msg.value / 5;
            _distributeFees(token, msg.value - protocolFees, protocolFees);
        }
    }

    // allow to externally withdraw liquidity (in case there is no tx for a while)
    function withdrawLiquidity(address token) external {
        require(childTokens[token].isChildToken == true, "Unknown token");
        require(msg.sender == ITokenLogic(token).deployer() || withdrawalAddresses[msg.sender], "Unauthorized");

        // if liquidity is already burned or refunded, then checking for burn is useless
        if (childTokens[token].launchStatus != LaunchStatus.LAUNCH_ACTIVE) return;

        // if we could burn lp, just return
        if (_tryBurn(token)) return;

        require(block.timestamp - ITokenLogic(token).launchTimestamp() > 24 hours, "Token not ready to refund");
        
        childTokens[token].launchStatus = LaunchStatus.LIQUIDITY_REFUNDED;

        // remove liquidity
        IERC20 lpToken = IERC20(uniswapFactory.getPair(token, uniswapRouter.WETH()));
        uint amount = lpToken.balanceOf(address(this));

        lpToken.approve(address(uniswapRouter), amount);
        (uint amountToken, uint amountETH) = uniswapRouter.removeLiquidityETH(token, amount, 0, 0, address(this), block.timestamp);
        IERC20(token).burn(amountToken);

        // refund eth from liquidity back to deployer up to 1 ether and tip the protocol with the remainder
        uint deployerRefund = min(amountETH, 1 ether);
        uint protocolTip = amountETH > 1 ether ? amountETH - 1 ether : 0;
        (uint deployerFees, uint protocolFees) = getTokenFees(token);

        _distributeFees(token, deployerRefund + deployerFees, protocolTip + protocolFees);
            
        emit LiquidityRefunded(token);
    }

    function externalTryBurn(address token) external {
        require(childTokens[token].isChildToken == true, "Unknown token");

        _tryBurn(token);
    }
    
    function _tryBurn(address token) private returns (bool) {
        // if liquidity is already burned or refunded, then checking for burn is useless
        if (childTokens[token].launchStatus != LaunchStatus.LAUNCH_ACTIVE) return false;

        (uint deployerFees, uint protocolFees) = getTokenFees(token);
        // check if we can burn the liquidity
        if (deployerFees >= 1 ether) {
            childTokens[token].launchStatus = LaunchStatus.LIQUIDITY_BURNED;

            IERC20 lpToken = IERC20(uniswapFactory.getPair(token, uniswapRouter.WETH()));

            // burn lp token
            lpToken.transfer(address(0), lpToken.balanceOf(address(this)));

            _distributeFees(token, deployerFees, protocolFees);

            emit LiquidityBurned(token);
            return true;
        }
        return false;
    }

    function getTokenFees(address token) public view returns (uint deployerFees, uint protocolFees) {
        uint totalFees = childTokens[token].feesReceived;
        protocolFees = totalFees / 5;
        deployerFees = totalFees - protocolFees;
    }

    // distribute fees to token deployer and protocol fees recipient
    function _distributeFees(address token, uint deployerFees, uint protocolFees) private {
        // refund deployer
        if (deployerFees != 0) {
            (bool result, ) = ITokenLogic(token).deployer().call{value: deployerFees}("");
            require(result, "Failed to refund deployer");
        }
        // distribute protocol fees
        if (protocolFees != 0) {
            uint feesToStaking = (stakingFees * protocolFees) / 100;
            uint feesToDev = protocolFees - feesToStaking;
            if (feesToDev != 0) {
                (bool result, ) = protocolFeesRecipient.call{value: feesToDev}("");
                require(result, "Failed to forward");
            }
            if (feesToStaking != 0) {
                (bool result, ) = stakingContract.call{value: feesToStaking}("");
                require(result, "Failed to forward");
            }
        }
    }

    // return token unique id in bytes32
    function getTokenUniqueId(address token) external view returns (bytes32) {
        return bytes32(childTokens[token].uniqueId);
    }
    
    function getTokensDeployed(address deployer) external view returns (address[] memory) {
        return tokensDeployed[deployer];
    }

    function min(uint a, uint b) private pure returns (uint) {
        return a < b ? a : b;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*    
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│       _______         ______                      _                     │
│      |__   __|       |  ____|                    (_)                    │
│         | | __ ___  _| |__ __ _ _ __ _ __ ___     _ _ __   __ _         │
│         | |/ _` \ \/ /  __/ _` | '__| '_ ` _ \   | | '_ \ / _` |        │
│         | | (_| |>  <| | | (_| | |  | | | | | |  | | | | | (_| |        │
│         |_|\__,_/_/\_\_|  \__,_|_|  |_| |_| |_|(_)_|_| |_|\__, |        │
│                                                            __/ |        │
│                                                           |___/         │
│                                                                         │
│                               taxfarm.ing                               │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
*/

// utils
import {ERC20Logic} from "./utils/ERC20Logic.sol";
import {IUniswapV2Router02} from "./utils/IUniswapV2Router02.sol";
import {IUniswapV2Factory} from "./utils/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "./utils/IUniswapV2Pair.sol";
import {IWETH} from "./utils/IWETH.sol";

interface ITokenLogic {
    function initialize(address _deployer, string memory _name, string memory _symbol) external payable;
    function launchTimestamp() external view returns(uint);
    function deployer() external view returns(address payable);
}

// token logic (code used by token proxies contracts)
contract TokenLogic is ERC20Logic, ITokenLogic {
    enum FeesTier {
        HIGH_FEES, // 20/20 fees the first 5 minutes
        MEDIUM_FEES, // 5/5 fees until contract has less than 1% of the supply to sell
        LOW_FEES // 1/1 then
    }

    // - token logic constants (not colliding proxies storages)

    uint private constant HIGH_FEES_DURATION = 300; // duration of the high fees stage (20% during 5 minutes)
    uint private constant LIMITS_DURATION = 300; // duration of max tx and max wallet limits in seconds
    uint private constant BASE_TOTAL_SUPPLY = 1_000_000_000 * 10**18;
    uint public constant MAX_TX_AMOUNT = (1 * BASE_TOTAL_SUPPLY) / 100; // max tx 10M (1%)
    uint public constant MAX_WALLET_AMOUNT = (3 * BASE_TOTAL_SUPPLY) / 100; // max wallet 30M (3%)
    uint private constant LIQUIDITY_AMOUNT = (80 * BASE_TOTAL_SUPPLY) / 100; // uniswap liquidity (80%)

    address public immutable tokenFactory;
    address public immutable WETH;

    IUniswapV2Factory public immutable uniswapFactory;
    IUniswapV2Router02 constant uniswapRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    // - instance token storage (stored in each token proxies)

    bool _swapping;

    uint public launchTimestamp; // token launch timestamp

    address payable public deployer;
    address public uniswapPair;

    FeesTier public feesTier; // current token fees tier (could be outdated and updated during the transaction)

    constructor (address _tokenFactory) {
        tokenFactory = _tokenFactory;

        uniswapFactory = IUniswapV2Factory(uniswapRouter.factory());
        WETH = uniswapRouter.WETH();
    }

    modifier lockSwap {
        _swapping = true;
        _;
        _swapping = false;
    }

    // initialize new token datas (called from the factory to the token proxy delegating the call here)
    function initialize(address _deployer, string memory _name, string memory _symbol) external payable {
        require(msg.sender == tokenFactory, "Unauthorized"); // initialized only on the same deployment transaction from token factory
        require(msg.value == 1 ether, "Wrong initial liquidity");

        name = _name;
        symbol = _symbol;
        deployer = payable(_deployer);

        launchTimestamp = block.timestamp;

        _mint(address(this), BASE_TOTAL_SUPPLY - LIQUIDITY_AMOUNT); // mint clogged amount to the contract

        uniswapPair = uniswapFactory.createPair(address(this), WETH);
        _mint(uniswapPair, LIQUIDITY_AMOUNT); // mint liquidity amount to the pair

        IWETH(WETH).deposit{value: 1 ether}();
        assert(IWETH(WETH).transfer(uniswapPair, 1 ether)); // transfer weth to the pair
        IUniswapV2Pair(uniswapPair).mint(tokenFactory); // call low level mint function on pair
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        if (_swapping) return super._transfer(sender, recipient, amount);

        uint fees = _takeFees(sender, recipient, amount);
        if (fees != 0) {
            super._transfer(sender, address(this), fees);
            amount -= fees;
        }

        if (recipient == uniswapPair) _swapFees(amount);

        super._transfer(sender, recipient, amount);

        _forwardFees();
    }

    // return fees amount taken from the transfer (and check for tx and wallet limits)
    function _takeFees(address sender, address recipient, uint amount) private returns (uint) {
        if ((sender != uniswapPair && recipient != uniswapPair) || recipient == tokenFactory || sender == address(this) || recipient == address(uniswapRouter)) return 0;

        // ensure max tx and max wallet
        if (limitsActive() && sender == uniswapPair) {
            require(amount <= MAX_TX_AMOUNT, "Max tx amount reached");
            require(balanceOf(recipient) + amount <= MAX_WALLET_AMOUNT, "Max wallet amount reached");
        }

        // if token has low fees tier, fees are immutable at 1% 
        if (feesTier == FeesTier.LOW_FEES) return amount / 100; // 1% fees

        // else, if token has medium fees, check if we can change tier and return correct fees
        else if (feesTier == FeesTier.MEDIUM_FEES) {
            if (balanceOf(address(this)) <= totalSupply / 100) {
                feesTier = FeesTier.LOW_FEES;
                return amount / 100; // 1% fees
            }
            return amount / 20; // 5% fees
        }

        // else, token is at high fees tier and we check if we can change tier and return correct fees
        else {
            if (block.timestamp - launchTimestamp > HIGH_FEES_DURATION) {
                feesTier = FeesTier.MEDIUM_FEES;
                return amount / 20; // 5% fees
            }
            return amount / 5; // 20% fees
        }
    }

    // swap some fees tokens to eth
    function _swapFees(uint maxAmount) private lockSwap {
        uint tokenAmount = min(min(maxAmount, balanceOf(address(this))), totalSupply / 100);
        if (tokenAmount < 1e18) return; // prevent too small swaps

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;

        _approve(address(this), address(uniswapRouter), tokenAmount);
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }   

    // return true if max wallet and max tx limitations are still active
    function limitsActive() public view returns (bool) {
        return block.timestamp - launchTimestamp <= LIMITS_DURATION;
    }
    
    // forward contract fees to token factory (also try to burn liquidity)
    function _forwardFees() private {
        uint balance = address(this).balance;

        if (balance == 0) return;

        (bool result, ) = tokenFactory.call{value: balance}("");
        require(result, "Failed to forward fees");
    }

    function min(uint a, uint b) private pure returns (uint) {
        return a < b ? a : b;
    }

    receive() external payable {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "./IERC20.sol";
import {Context} from "./Context.sol";

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

// contract implementing the logic of ERC20 standard (thus usable from proxies)
contract ERC20Logic is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 public totalSupply;

    string public name;
    string public symbol;

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
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
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function burn(uint256 value) public virtual {
        _burn(_msgSender(), value);
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
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
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        totalSupply -= amount;

        emit Transfer(account, address(0), amount);
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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function burn(uint256 value) external;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IUniswapV2Pair {
    function mint(address to) external returns (uint liquidity);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
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
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Context} from "./Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}