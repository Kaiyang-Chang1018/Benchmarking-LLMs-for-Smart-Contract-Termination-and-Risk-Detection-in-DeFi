/*
Overview of Excryon
Excryon is an innovative cryptocurrency trading simulation application designed to provide users with a 
realistic and engaging trading experience without the risk of financial loss. By simulating the dynamics 
of the cryptocurrency market, Excryon enables users to practice trading strategies, manage virtual portfolios, 
and track their progress as they advance through various levels of trading proficiency.
Excryon is structured around a unique leveling system where users start as an Anchovy and can advance through 
ten distinct levels, ultimately aiming to become a Whale. Each level unlocks exclusive visual elements and 
provides a sense of progression and achievement. The platform features detailed asset management tools, including 
portfolio tracking, average cost price calculations, and profit/loss assessments. Users can also engage in buying 
and selling cryptocurrencies within the simulation, honing their trading skills and strategies.
Purpose and Vision
The purpose of Excryon is to create an immersive and educational environment for individuals interested in 
cryptocurrency trading. By providing a risk-free platform, Excryon allows users to experiment with different 
trading strategies, learn from their mistakes, and build confidence in their trading abilities. The vision behind 
Excryon is to democratize access to cryptocurrency trading education, making it accessible to everyone regardless 
of their financial background or experience level.
Excryon aims to foster a community of informed and skilled traders who can apply their knowledge in real-world 
scenarios. By gamifying the learning process and introducing a competitive element through ranking and progression 
systems, Excryon strives to make the journey of learning cryptocurrency trading enjoyable and motivating.
Disclaimer
It is important to note that Excryon is a simulation application, and all trading activities, balances, and 
profit/loss values within the platform are entirely fictional. There is no real money involved, and the outcomes 
of simulated trades have no real-world financial implications. Excryon is intended solely for educational and 
entertainment purposes. Users should not interpret the performance of their virtual trades as indicative of real-world 
trading success.
Token Economics
Introduction to $EXCRYON
Excryon features its own native token, $EXCRYON, designed to enhance the user experience and provide additional 
layers of engagement and utility within the platform. $EXCRYON tokens are integral to the ecosystem, offering users 
various ways to interact with the platform, make in-game purchases, and participate in exclusive features.
Token Utility
$EXCRYON tokens serve multiple purposes within the Excryon simulation environment. 
- In-Game Purchases: Users can use $EXCRYON tokens to purchase virtual assets, upgrade their trading tools, and unlock 
premium features that enhance their trading experience. This includes access to advanced analytics, exclusive trading 
signals, and custom visual elements.
- Rewards and Incentives: Active participation and successful trading within Excryon are rewarded with $EXCRYON tokens. 
Users can earn tokens through various achievements, such as reaching new fish levels, completing trading challenges, 
and participating in community events. These tokens can be reinvested within the platform to further enhance the user’s 
capabilities and status.
Token Distribution and Governance
The distribution of $EXCRYON tokens is designed to ensure a fair and sustainable ecosystem. Initial token distribution 
includes allocations for platform development, user rewards, community engagement, and future growth initiatives. 
Additionally, Excryon plans to introduce governance mechanisms that allow token holders to participate in decision-making 
processes related to platform updates and new feature implementations.
Security and Privacy
 Data Protection Measures
Excryon places a high priority on the security and privacy of its users. The platform employs state-of-the-art data 
protection measures to ensure that all user information is kept safe and secure. This includes the use of encryption 
protocols, secure servers, and regular security audits to prevent unauthorized access and data breaches. User data, 
including personal information and trading activity, is encrypted both in transit and at rest, safeguarding it from 
potential threats.
User Privacy
Excryon is committed to protecting the privacy of its users. The platform adheres to strict privacy policies that comply 
with relevant data protection regulations. Users can be confident that their personal information will not be shared with 
third parties without their explicit consent. Additionally, Excryon offers privacy controls that allow users to manage 
their data preferences and control the visibility of their profile and trading activity within the community.
Security Protocols
The platform's security protocols are designed to provide robust protection against various types of cyber threats. Excryon 
uses multi-factor authentication (MFA) to enhance account security, requiring users to verify their identity through multiple 
methods before accessing their accounts. Regular security updates and patches are applied to the platform to address 
vulnerabilities and ensure a secure trading environment. By maintaining a strong focus on security, Excryon aims to provide 
a safe and trustworthy experience for all users.
Roadmap and Future Developments
Short-term Goals
Excryon's development team is dedicated to continuously improving the platform and introducing new features to enhance the 
user experience. In the short term, the focus will be on refining existing features, improving user interface and experience, 
and expanding the range of available cryptocurrencies. Planned short-term developments include:
- Enhanced portfolio tracking tools
- Improved analytics and reporting features
- Introduction of community-driven trading competitions
- Launch of the leveraged transactions simulation
Long-term Vision
Excryon's long-term vision is to become the leading platform for cryptocurrency trading education and simulation. The team 
aims to build a comprehensive ecosystem that supports users at all levels of their trading journey, from beginners to advanced 
traders. Long-term goals include:
- Integration of advanced trading algorithms and AI-driven insights
- Expansion into additional markets and asset classes
- Development of a mobile application to complement the desktop platform
- Establishment of partnerships with educational institutions and industry leaders to promote cryptocurrency trading education
Planned Features and Enhancements
To keep the platform at the forefront of innovation, Excryon has a roadmap of planned features and enhancements. These include:
- Social Trading Features: Allowing users to follow and learn from top traders, share strategies, and collaborate on trading 
ideas.
- Enhanced Customization Options: Offering more personalization for user dashboards and trading tools.
- Educational Modules: Interactive courses and certifications on various aspects of cryptocurrency trading, including technical 
analysis, market psychology, and risk management.
- Virtual Reality (VR) Integration: Exploring the potential of VR to create immersive trading experiences and simulations.
By pursuing these developments, Excryon aims to provide a continually evolving and enriching platform for its users.

*/
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;
library Address {
    function isContract(address account) internal view returns (bool) {

        return account.code.length > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(
        address target, 
        bytes memory data) 
        internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }
    function functionCall(address target, bytes memory data, string memory errorMessage) 
    internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target, 
        bytes memory data, 
        uint256 value
        ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value, 
        string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(
            target, 
            success, 
            returndata, 
            errorMessage);
    }
    function functionStaticCall(
        address target, 
        bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(
            target, 
            data, 
            "Address: low-level static Excryon call failed");
    }
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) 
    internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function functionDelegateCall(
        address target, 
        bytes memory data) 
        internal returns (bytes memory) {
        return functionDelegateCall(
            target, 
            data, 
            "Address: low-level delegate call failed");
    }
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) 
    internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function verifyCallResultFromTarget(address target,bool success, bytes memory returndata,string memory errorMessage) 
    internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }
    function _revert(bytes memory returndata, string memory errorMessage) private pure {
       
        if (returndata.length > 0) {
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
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
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
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
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// pragma solidity ^0.8.0;

library SafeMath {
    
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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


interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

pragma solidity >=0.6.2;

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
    function nonces(address owner) external view returns (uint);

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


interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}
interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract ExcryonToken is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public uniswapV2Pair;

    address public marketingWallet;
    address public developmentWallet;
    address public liquidityWallet;
    address public constant deadAddress = address(0xdead);

    bool public tradingEnabled;
    bool public swapEnabled;
    bool private _swapping;

    uint256 public swapTokensAtAmount;

    uint256 public buyTotalFees;
    uint256 private _buyMarketingFee;
    uint256 private _buyDevelopmentFee;
    uint256 private _buyLiquidityFee;

    uint256 public sellTotalFees;
    uint256 private _sellMarketingFee;
    uint256 private _sellDevelopmentFee;
    uint256 private _sellLiquidityFee;

    uint256 private _tokensForMarketing;
    uint256 private _tokensForDevelopment;
    uint256 private _tokensForLiquidity;  

    mapping (address => bool) private _isExcludedFromFees;

    mapping(address => bool) private _automatedMarketMakerPairs;

    event ExcludeFromLimits(address indexed account, bool isExcluded);

    event ExcludeFromFees(address indexed account, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event marketingWalletUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );

    event developmentWalletUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );

    event liquidityWalletUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );
    event TokensAirdropped(uint256 totalWallets, uint256 totalTokens);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    );


    constructor() ERC20("Excryon Token", "EXCRYON") {

        uint256 totalSupply = 1000000000 * (10 ** 18);

        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), type(uint256).max);

        _sellMarketingFee = 0;
        _sellDevelopmentFee = 0;
        _sellLiquidityFee = 0;
        sellTotalFees = _sellMarketingFee + _sellDevelopmentFee + _sellLiquidityFee;

        _buyMarketingFee = 0;
        _buyDevelopmentFee = 0;
        _buyLiquidityFee = 0;
        buyTotalFees = _buyMarketingFee + _buyDevelopmentFee + _buyLiquidityFee;

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[deadAddress] = true;

        _mint(owner(), totalSupply); 
    }

    receive() external payable {}

    function openTrader() public onlyOwner {
        require(!tradingEnabled, "Trading already active.");
        tradingEnabled = true;
        swapEnabled = true;
    }
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function setAutomatedMarketMakerPair(address pair, bool value)
    public
    onlyOwner
    {
        require(pair != uniswapV2Pair, "The pair cannot be removed from automatedMarketMakerPairs");
        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        _automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the Tr zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(tradingEnabled || _isExcludedFromFees[from] || _isExcludedFromFees[to], "Trading not yet enabled!");
        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }


        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (
            canSwap &&
            swapEnabled &&_automatedMarketMakerPairs[from]&&!_swapping&&
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to]
        ) {
            _swapping = true;

            _swapBack();

            _swapping = false;
        }

        bool takeFee = !_swapping;

        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        uint256 fees = 0;

        if (takeFee) {
            if (_automatedMarketMakerPairs[to] && sellTotalFees > 0) {
                fees = amount.mul(sellTotalFees).div(10000);
                _tokensForLiquidity +=
                    (fees * _sellLiquidityFee) /
                    sellTotalFees;
                _tokensForMarketing +=
                    (fees * _sellMarketingFee) /
                    sellTotalFees;
                _tokensForDevelopment +=
                    (fees * _sellDevelopmentFee) /
                    sellTotalFees;
            }
            else if (_automatedMarketMakerPairs[from] && buyTotalFees > 0) {
                fees = amount.mul(buyTotalFees).div(10000);
                _tokensForLiquidity += (fees * _buyLiquidityFee) / buyTotalFees;
                _tokensForMarketing += (fees * _buyMarketingFee) / buyTotalFees;
                _tokensForDevelopment +=
                    (fees * _buyDevelopmentFee) /
                    buyTotalFees;
            }

            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }

            amount -= fees;
        }

        super._transfer(from, to, amount);
    }

    function _swapTokensForETH(uint256 tokenAmount) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal {
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            liquidityWallet,
            block.timestamp
        );
    }

    function _swapBack() internal {
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = _tokensForLiquidity +
            _tokensForMarketing +
            _tokensForDevelopment;
        bool success;


        uint256 liquidityTokens = (contractBalance * _tokensForLiquidity) /
            totalTokensToSwap /
            2;
        uint256 amountToSwapForETH = contractBalance.sub(liquidityTokens);

        uint256 initialETHBalance = address(this).balance;

        _swapTokensForETH(amountToSwapForETH);

        uint256 ethBalance = address(this).balance.sub(initialETHBalance);

        uint256 ethForMarketing = ethBalance.mul(_tokensForMarketing).div(
            totalTokensToSwap
        );

        uint256 ethForDevelopment = ethBalance.mul(_tokensForDevelopment).div(
            totalTokensToSwap
        );

        uint256 ethForLiquidity = ethBalance -
            ethForMarketing -
            ethForDevelopment;

        _tokensForLiquidity = 0;
        _tokensForMarketing = 0;
        _tokensForDevelopment = 0;

        if (liquidityTokens > 0 && ethForLiquidity > 0) {
            _addLiquidity(liquidityTokens, ethForLiquidity);
            emit SwapAndLiquify(
                amountToSwapForETH,
                ethForLiquidity,
                _tokensForLiquidity
            );
        }

        (success, ) = address(developmentWallet).call{value: ethForDevelopment}("");

        (success, ) = address(marketingWallet).call{
            value: address(this).balance
        }("");
    }

}