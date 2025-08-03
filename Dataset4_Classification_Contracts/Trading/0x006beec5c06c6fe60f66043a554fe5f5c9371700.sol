// SPDX-License-Identifier: MIT
/**
 * https://t.me/projectorioneth
 * https://x.com/ProjectOrionETH
 * https://www.projectorion.online/
 */
pragma solidity 0.8.19;

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface INodeManager {
    struct NodeEntity {
        string name;
        uint256 creationTime;
        uint256 lastClaimTime;
        uint256 amount;
        uint256 tier;
        uint256 totalClaimed;
    }

    function getNodePrice(uint256 _tierIndex) external view returns (uint256);

    function createNode(
        address account,
        string memory nodeName,
        uint256 tier
    ) external;

    function getNodeReward(
        address account,
        uint256 _creationTime
    ) external view returns (uint256);

    function getAllNodesRewards(
        address account
    ) external view returns (uint256[2] memory);

    function cashoutNodeReward(address account, uint256 _creationTime) external;

    function cashoutAllNodesRewards(address account) external;

    function getAllNodes(
        address account
    ) external view returns (NodeEntity[] memory);

    function getNodeFee(
        address account,
        uint256 _creationTime,
        uint256 _rewardAmount
    ) external returns (uint256);

    function getAllNodesFee(
        address account,
        uint256 _rewardAmount
    ) external returns (uint256);

    function borrowRewards(
        address account,
        uint256 blocktime,
        uint256 amount
    ) external;

    function getNodeTier(
        address account,
        uint256 blocktime
    ) external view returns (uint256);

    function upgradeNode(
        address account,
        uint256 blocktime
    ) external;

    function getNodeNumberOf(address account) external view returns (uint256);

    function isNodeOwner(address account) external view returns (bool);

    function updateTiersRewards(uint256[] memory newVal) external;

    function getNodesNames(
        address account
    ) external view returns (string memory);

    function getNodesCreationTime(
        address account
    ) external view returns (string memory);

    function getNodesRewards(
        address account
    ) external view returns (string memory);

    function getNodesLastClaimTime(
        address account
    ) external view returns (string memory);

    function totalStaked() external view returns (uint256);

    function totalNodesCreated() external view returns (uint256);
}

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
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
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

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(
        address target,
        bytes memory data
    ) internal view returns (bytes memory) {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
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
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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

library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
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
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
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

        _beforeTokenTransfer(sender, recipient, amount);

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

        _afterTokenTransfer(sender, recipient, amount);
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

interface IAliens {
    function mint(uint256 numberOfToken) external payable;

    function setPriceForSale(
        uint256 _tokenId,
        uint256 _newPrice,
        bool isForSale
    ) external;

    function buyToken(uint256 _tokenId) external payable;

    function tokenOfOwnerByIndex(
        address nodeOwner,
        uint256 index
    ) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function setAlienKind(
        uint256[] memory _tokens,
        uint256[] memory _kinds
    ) external;

    function getAllSaleTokens() external view returns (uint256[] memory);

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function changeUrl(string memory url) external;

    function getAlienLevel(uint256 _tokenId) external view returns (uint256);

    function getAlienKind(uint256 _tokenId) external view returns (uint256);

    function growAlien(uint256 _tokenId) external;

}

contract ORN is ERC20, Ownable {
    using SafeMath for uint256;

    INodeManager public nodeManager;
    IAliens public aliens;

    IUniswapV2Router02 public uniswapV2Router;

    address public uniswapV2Pair;
    address public marketingWallet;
    address public distributionPool;
    address public devPool;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;

    uint256 public rewardsFee;
    uint256 public liquidityPoolFee;
    uint256 public futurFee;

    uint256 public buyTax = 35;
    uint256 public sellTax = 55;

    uint256 private devShare = 25;
    bool private swapping = false;
    bool private swapLiquify = true;
    uint256 public swapTokensAmount;
    uint256 public growMultiplier = 10e18;

    bool private tradingOpen = false;
    uint256 private maxTx = 375;

    mapping(address => bool) public automatedMarketMakerPairs;

    event UpdateUniswapV2Router(
        address indexed newAddress,
        address indexed oldAddress
    );

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event LiquidityWalletUpdated(
        address indexed newLiquidityWallet,
        address indexed oldLiquidityWallet
    );

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    constructor() ERC20("Project Orion", "ORN")  {
        marketingWallet = 0x2AF5DFf2Ff0b71816E9E552a4e8EBE807016C2C0;
        distributionPool = 0x5A45348CBDde5D073Dab1A2D30f695f21FAadfFC;
        devPool = msg.sender;

        address uniV2Router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

        require(uniV2Router != address(0), "ROUTER CANNOT BE ZERO");
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(uniV2Router);

        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        
        uniswapV2Pair = _uniswapV2Pair;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        futurFee = 89;
        rewardsFee = 1;
        liquidityPoolFee = 10;


        _mint(_msgSender(), 300000e18);

        require(
            totalSupply() == 300000e18,
            "CONSTR: totalSupply must equal 300,000"
        );
        swapTokensAmount = 100 * (10 ** 18);
    }

    receive() external payable virtual {}

    function setNodeManagement(address nodeManagement) external onlyOwner {
        nodeManager = INodeManager(nodeManagement);
    }

    function setAliens(address aliensAddress) external onlyOwner {
        aliens = IAliens(aliensAddress);
    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(
            newAddress != address(uniswapV2Router),
            "ELEMENTS: The router already has that address"
        );
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Pair = _uniswapV2Pair;
    }

    function updateSwapTokensAmount(uint256 newVal) external onlyOwner {
        swapTokensAmount = newVal;
    }

    function updateFuturWall(address payable wall) external onlyOwner {
        marketingWallet = wall;
    }

    function updateDevWall(address payable wall) external onlyOwner {
        devPool = wall;
    }

    function updateRewardsWall(address payable wall) external onlyOwner {
        distributionPool = wall;
    }

    function updateFeeSplit(uint256 _rewardsFee, uint256 _liquidityPoolFee, uint256 _futurFee) external onlyOwner {
        require(_rewardsFee.add(_liquidityPoolFee).add(_futurFee) == 100, "Fees must add up to 100");
        rewardsFee = _rewardsFee;
        liquidityPoolFee = _liquidityPoolFee;
        futurFee = _futurFee;
    }
    
    function updateSellTax(uint256 value) external onlyOwner {
        require(value <= 6, "TAX: sell tax cannot exceed 6%");
        sellTax = value;
    }

    function updateBuyTax(uint256 value) external onlyOwner {
        require(value <= 6, "TAX: buy tax cannot exceed 6%");
        buyTax = value;
    }

    function lowerFeesOnLaunch(uint256 newBuy, uint256 newSell) external onlyOwner {
        require (newBuy <= buyTax, "Taxes only go down");
        require (newSell <= sellTax, "Taxes only go down");
        buyTax = newBuy;
        sellTax = newSell;
    }

    function setAutomatedMarketMakerPair(
        address pair,
        bool value
    ) public onlyOwner {
        require(
            pair != uniswapV2Pair,
            "ELEMENTS: The DEX pair cannot be removed from automatedMarketMakerPairs"
        );

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(
            automatedMarketMakerPairs[pair] != value,
            "ELEMENTS: Automated market maker pair is already set to that value"
        );
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if (
            automatedMarketMakerPairs[to] &&
            (from != address(this) && from != owner())
        ) {
            uint256 sellTaxAmount = amount.mul(sellTax).div(100);
            super._transfer(from, address(this), sellTaxAmount);
            amount = amount.sub(sellTaxAmount);
        } else if (
            automatedMarketMakerPairs[from] &&
            (to != address(this) && to != owner())
        ) {
            uint256 buyTaxAmount = amount.mul(buyTax).div(100);
            super._transfer(from, address(this), buyTaxAmount);
            amount = amount.sub(buyTaxAmount);
        }
        uint256 amount2 = amount;
        uint256 contractTokenBalance = balanceOf(address(this));
        bool swapAmountOk = contractTokenBalance >= swapTokensAmount;

        if (
            swapAmountOk &&
            swapLiquify &&
            !swapping &&
            from != owner() &&
            !automatedMarketMakerPairs[from]
        ) {
            swapContractTokens();
        }

        if (
            from != owner() &&
            to != uniswapV2Pair &&
            to != address(uniswapV2Router) &&
            to != address(this) &&
            from != address(this)
        ) {
            require(tradingOpen, "Trading not yet enabled.");

            if (
                to != marketingWallet &&
                to != distributionPool &&
                to != devPool &&
                from != marketingWallet &&
                from != distributionPool &&
                from != devPool
            ) {
                uint256 walletBalance = balanceOf(address(to));
                require(
                    amount2.add(walletBalance) <= maxTx.mul(1e18),
                    "wallet limit."
                );
            }
        }
        super._transfer(from, to, amount2);
    }

    function swapAndLiquify(uint256 tokens) private {
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        uint256 initialBalance = address(this).balance;

        swapTokensForEth(half);

        uint256 newBalance = address(this).balance.sub(initialBalance);

        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            distributionPool,
            block.timestamp
        );
    }

    function swapContractTokens() private {
        swapping = true;
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 fdTokens = contractTokenBalance.mul(futurFee).div(100);
        uint256 devTokens = fdTokens.mul(devShare).div(100);
        uint256 mktTokens = fdTokens.sub(devTokens);

        uint256 rewardsPoolTokens = contractTokenBalance.mul(rewardsFee).div(
            100
        );

        super._transfer(
            address(this),
            distributionPool,
            rewardsPoolTokens
        );

        uint256 swapTokens = contractTokenBalance.mul(liquidityPoolFee).div(
            100
        );

        swapAndLiquify(swapTokens);

        swapTokensForEth(balanceOf(address(this)));
        uint256 totalTaxTokens = devTokens
            .add(mktTokens);

        uint256 ETHBalance = address(this).balance;

        bool success;

        (success, ) =  devPool.call{value: ETHBalance.mul(devTokens).div(totalTaxTokens)}("");
        
        (success, ) =  marketingWallet.call{value: (address(this)).balance}("");


        swapping = false;
    }

    function createNodeWithTokens(string memory _name, uint256 tier) public {
        require(
            bytes(_name).length > 3 && bytes(_name).length < 32,
            "NODE CREATION: NAME SIZE INVALID"
        );
        address sender = _msgSender();
        require(
            sender != address(0),
            "NODE CREATION:  creation from the zero address"
        );
        require(
            sender != distributionPool,
            "NODE CREATION: futur, dev and rewardsPool cannot create node"
        );

        uint256 nodePrice = nodeManager.getNodePrice(tier);
        require(
            balanceOf(sender) >= nodePrice.mul(1e18),
            "NODE CREATION: Balance too low for creation. Try lower tier."
        );

        super._transfer(sender, distributionPool, nodePrice.mul(1e18));
        nodeManager.createNode(sender, _name, tier);
    }

    function createNodeWithRewards(
        uint256 blocktime,
        string memory _name,
        uint256 tier
    ) public {
        require(
            bytes(_name).length > 3 && bytes(_name).length < 32,
            "NODE CREATION: NAME SIZE INVALID"
        );
        address sender = _msgSender();
        require(
            sender != address(0),
            "NODE CREATION:  creation from the zero address"
        );
        require(
            sender != distributionPool,
            "NODE CREATION: rewardsPool cannot create node"
        );
        uint256 nodePrice = nodeManager.getNodePrice(tier);
        uint256 rewardOf = nodeManager.getNodeReward(sender, blocktime);
        require(
            rewardOf >= nodePrice.mul(1e18),
            "NODE CREATION: Reward Balance too low for creation."
        );
        nodeManager.borrowRewards(
            sender,
            blocktime,
            nodeManager.getNodePrice(tier).mul(1e18)
        );
        nodeManager.createNode(sender, _name, tier);
    }

    function upgradeNode(uint256 blocktime) public {
        address sender = _msgSender();
        require(sender != address(0), "Zero address not permitted");
        require(sender != distributionPool, "Cannot upgrade nodes");
        uint256 currentTier = nodeManager.getNodeTier(sender, blocktime);
        require(currentTier < 4, "Your Node is already at max level");
        uint256 nextTier = currentTier.add(1);
        uint256 currentPrice = nodeManager.getNodePrice(currentTier);
        uint256 newPrice = nodeManager.getNodePrice(nextTier);
        uint256 priceDiff = (newPrice.sub(currentPrice)).mul(1e18);
        uint256 rewardOf = nodeManager.getNodeReward(sender, blocktime);
        if (rewardOf > priceDiff) {
            upgradeNodeCashout(sender, blocktime, rewardOf.sub(priceDiff));
            nodeManager.cashoutNodeReward(sender, blocktime);
        } else if (rewardOf < priceDiff) {
            upgradeNodeAddOn(sender, blocktime, priceDiff.sub(rewardOf));
            nodeManager.cashoutNodeReward(sender, blocktime);
        }
    }

    function upgradeNodeCashout(
        address account,
        uint256 blocktime,
        uint256 cashOutAmount
    ) internal {
        uint256 taxAmount = nodeManager.getNodeFee(
            account,
            blocktime,
            cashOutAmount
        );
        super._transfer(
            distributionPool,
            account,
            cashOutAmount.sub(taxAmount)
        );
        nodeManager.upgradeNode(account, blocktime);
    }

    function upgradeNodeAddOn(
        address account,
        uint256 blocktime,
        uint256 AddAmount
    ) internal {
        super._transfer(account, distributionPool, AddAmount);
        nodeManager.upgradeNode(account, blocktime);
    }

    function setGrowMultiplier(uint256 newVal) external onlyOwner {
        growMultiplier = newVal;
    }

    function growAlien(uint256 _tokenId) external {
        address sender = _msgSender();
        uint256 artifLevel = aliens.getAlienLevel(_tokenId);
        uint256 growPrice = artifLevel.mul(growMultiplier);
        require(
            balanceOf(sender) > growPrice,
            "Not enough ELEMENTS to grow your Alien"
        );
        super._transfer(sender, distributionPool, growPrice);
        aliens.growAlien(_tokenId);
    }

    function cashoutReward(uint256 blocktime) public {
        address sender = _msgSender();
        require(sender != address(0), "CSHT:  can't from the zero address");
        require(
            sender != marketingWallet && sender != distributionPool,
            "CSHT: futur and rewardsPool cannot cashout rewards"
        );
        uint256 rewardAmount = nodeManager.getNodeReward(sender, blocktime);
        require(
            rewardAmount > 0,
            "CSHT: You don't have enough reward to cash out"
        );

        uint256 taxAmount = nodeManager.getNodeFee(
            sender,
            blocktime,
            rewardAmount
        );
        super._transfer(distributionPool, sender, rewardAmount.sub(taxAmount));
        nodeManager.cashoutNodeReward(sender, blocktime);
    }

    function cashoutAll() public {
        address sender = _msgSender();
        require(sender != address(0), "ELEMENTS:  creation from the zero address");
        require(
            sender != marketingWallet && sender != distributionPool,
            "ELEMENTS: futur and rewardsPool cannot cashout rewards"
        );
        uint256[2] memory rewardTax = nodeManager.getAllNodesRewards(sender);
        uint256 rewardAmount = rewardTax[0];
        require(
            rewardAmount > 0,
            "ELEMENTS: You don't have enough reward to cash out"
        );
        super._transfer(distributionPool, sender, rewardAmount);
        nodeManager.cashoutAllNodesRewards(sender);
    }

    function rescueFunds(uint amount) public onlyOwner {
        if (amount > address(this).balance) amount = address(this).balance;
        payable(owner()).transfer(amount);
    }

    function changeSwapLiquify(bool newVal) public onlyOwner {
        swapLiquify = newVal;
    }

    function getNodeNumberOf(address account) public view returns (uint256) {
        return nodeManager.getNodeNumberOf(account);
    }

    function getRewardAmountOf(
        address account
    ) public view onlyOwner returns (uint256[2] memory) {
        return nodeManager.getAllNodesRewards(account);
    }

    function getRewardAmount() public view returns (uint256[2] memory) {
        require(_msgSender() != address(0), "SENDER CAN'T BE ZERO");
        require(nodeManager.isNodeOwner(_msgSender()), "NO NODE OWNER");
        return nodeManager.getAllNodesRewards(_msgSender());
    }

    function updateTiersRewards(uint256[] memory newVal) external onlyOwner {
        require(newVal.length == 5, "Wrong length");
        nodeManager.updateTiersRewards(newVal);
    }

    function getNodesNames() public view returns (string memory) {
        require(_msgSender() != address(0), "SENDER CAN'T BE ZERO");
        require(nodeManager.isNodeOwner(_msgSender()), "NO NODE OWNER");
        return nodeManager.getNodesNames(_msgSender());
    }

    function getNodesCreatime() public view returns (string memory) {
        require(_msgSender() != address(0), "SENDER CAN'T BE ZERO");
        require(nodeManager.isNodeOwner(_msgSender()), "NO NODE OWNER");
        return nodeManager.getNodesCreationTime(_msgSender());
    }

    function getNodesRewards() public view returns (string memory) {
        require(_msgSender() != address(0), "SENDER CAN'T BE ZERO");
        require(nodeManager.isNodeOwner(_msgSender()), "NO NODE OWNER");
        return nodeManager.getNodesRewards(_msgSender());
    }

    function getNodesLastClaims() public view returns (string memory) {
        require(_msgSender() != address(0), "SENDER CAN'T BE ZERO");
        require(nodeManager.isNodeOwner(_msgSender()), "NO NODE OWNER");
        return nodeManager.getNodesLastClaimTime(_msgSender());
    }

    function getTotalStakedReward() public view returns (uint256) {
        return nodeManager.totalStaked();
    }

    function getTotalCreatedNodes() public view returns (uint256) {
        return nodeManager.totalNodesCreated();
    }

    function openTrading() external onlyOwner {
        require(!tradingOpen, "trading is already open");
        tradingOpen = true;
    }

    function updateMaxTxAmount(uint256 newVal) public onlyOwner {
        maxTx = newVal;
    }
}