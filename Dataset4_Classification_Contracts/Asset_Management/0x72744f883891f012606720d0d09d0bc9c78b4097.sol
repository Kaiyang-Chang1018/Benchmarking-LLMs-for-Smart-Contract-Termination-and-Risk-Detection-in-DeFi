// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/extensions/IERC20Metadata.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// SPDX-License-Identifier: None
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./libraries/TokenUtils.sol";
import "./interfaces/IDividendDistributor.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IWETH.sol";

contract DividendDistributor is IDividendDistributor {
    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IUniswapV2Router02 router;
    IERC20 public RewardToken;

    address[] shareholders;
    mapping(address => uint256) public shareholderIndexes;
    mapping(address => uint256) public shareholderClaims;
    mapping(address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 30 minutes;
    uint256 public minDistribution = 1 * (10 ** 18);

    uint256 currentIndex;
    bool initialized;

    modifier onlyToken() {
        require(msg.sender == _token);
        _;
    }

    constructor(address _router, address _reflectionToken, address token) {
        router = IUniswapV2Router02(_router);
        RewardToken = IERC20(_reflectionToken);
        _token = token;
        uint8 rewardTokenDecimals = TokenUtils.expectDecimals(token);
        uint256 fixedPoint = 10 ** rewardTokenDecimals;
        minDistribution = 1 * fixedPoint;
    }

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function getShareHolders() external view returns (address[] memory) {
        return shareholders;
    }

    function setMinPeriod(uint256 _minPeriod) external override onlyToken {
        minPeriod = _minPeriod;
    }

    function setMinDistribution(
        uint256 _minDistribution
    ) external override onlyToken {
        minDistribution = _minDistribution;
    }

    function setShare(
        address shareholder,
        uint256 amount
    ) external override onlyToken {
        if (shares[shareholder].amount > 0) {
            distributeDividend(shareholder);
        }

        if (amount > 0 && shares[shareholder].amount == 0) {
            addShareholder(shareholder);
        } else if (amount == 0 && shares[shareholder].amount > 0) {
            removeShareholder(shareholder);
        }

        totalShares = totalShares - shares[shareholder].amount + amount;
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(
            shares[shareholder].amount
        );
    }

    function deposit() external payable override onlyToken {
        uint256 balanceBefore = RewardToken.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(RewardToken);

        if (path[0] == path[1]) { //reward token is weth
            IWETH(path[0]).deposit{value: msg.value}();
        } else {
            router.swapExactETHForTokensSupportingFeeOnTransferTokens{
                value: msg.value
            }(0, path, address(this), block.timestamp);
        }
        uint256 amount = RewardToken.balanceOf(address(this)) - balanceBefore;
        totalDividends = totalDividends + amount;
        if (totalShares > 0) {
            dividendsPerShare =
                dividendsPerShare +
                (dividendsPerShareAccuracyFactor * amount) /
                totalShares;
        }
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if (shareholderCount == 0) {
            return;
        }

        uint256 iterations = 0;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }

            if (shouldDistribute(shareholders[currentIndex])) {
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed + gasLeft - gasleft();
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(
        address shareholder
    ) internal view returns (bool) {
        return
            shareholderClaims[shareholder] + minPeriod <= block.timestamp &&
            getUnpaidEarnings(shareholder) >= minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if (shares[shareholder].amount == 0) {
            return;
        }

        uint256 amount = getUnpaidEarnings(shareholder);
        if (amount > 0) {
            totalDistributed = totalDistributed + amount;
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised =
                shares[shareholder].totalRealised +
                amount;
            shares[shareholder].totalExcluded = getCumulativeDividends(
                shares[shareholder].amount
            );
            RewardToken.transfer(shareholder, amount);
        }
    }

    function rewardTokenAddress() external view returns(address) {
        return address(RewardToken);
    }

    function claimDividend() external {
        require(shouldDistribute(msg.sender), "Too soon. Need to wait!");
        distributeDividend(msg.sender);
    }

    function getUnpaidEarnings(
        address shareholder
    ) public view returns (uint256) {
        if (shares[shareholder].amount == 0) {
            return 0;
        }

        uint256 shareholderTotalDividends = getCumulativeDividends(
            shares[shareholder].amount
        );
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;
        if (shareholderTotalDividends <= shareholderTotalExcluded) {
            return 0;
        }

        return shareholderTotalDividends - shareholderTotalExcluded;
    }

    function getCumulativeDividends(
        uint256 share
    ) internal view returns (uint256) {
        return (share * dividendsPerShare) / dividendsPerShareAccuracyFactor;
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[
            shareholders.length - 1
        ];
        shareholderIndexes[
            shareholders[shareholders.length - 1]
        ] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}
// SPDX-License-Identifier: None
pragma solidity ^0.8.17;

interface IDividendDistributor {
    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external;

    function setShare(address shareholder, uint256 amount) external;

    function deposit() external payable;

    function process(uint256 gas) external;

    function setMinPeriod(uint256 _minPeriod) external;

    function setMinDistribution(uint256 _minDistribution) external;

    function rewardTokenAddress() external view returns(address);
}
// SPDX-License-Identifier: None
pragma solidity ^0.8.17;

interface IFACTORY {
    function proofRevenueAddress() external view returns (address);

    function proofRewardPoolAddress() external view returns (address);
}
// SPDX-License-Identifier: None
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "../libraries/ProofFactoryFees.sol";

interface IProofFactoryTokenCutter is IERC20, IERC20Metadata {
    struct BaseData {
        string tokenName;
        string tokenSymbol;
        uint256 initialSupply;
        uint256 percentToLP;
        uint256 whitelistPeriod;
        address owner;
        address devWallet;
        address reflectionToken;
        address routerAddress;
        address initialProofAdmin;
        address[] whitelists;
        address[] nftWhitelist;
    }

    struct WhitelistAdd_ {
        address [] whitelists;
    }

    function setBasicData(
        BaseData memory _baseData,
        ProofFactoryFees.allFees memory fees
    ) external;

    function pair() external view returns (address);

    function swapTradingStatus() external;

    function updateProofFactory(address _newFactory) external;

    function addMoreToWhitelist(
        WhitelistAdd_ memory _WhitelistAdd
    ) external;

    function updateWhitelistPeriod(
        uint256 _whitelistPeriod
    ) external;

    function changeIsTxLimitExempt(
        address holder,
        bool exempt
    ) external;

    event DistributorFail();
}
// SPDX-License-Identifier: None
pragma solidity ^0.8.17;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}
// SPDX-License-Identifier: None
pragma solidity ^0.8.17;

interface IUniswapV2Router02 {
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

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);
}
interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}
// SPDX-License-Identifier: None
pragma solidity ^0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// SPDX-License-Identifier: None
pragma solidity ^0.8.17;

import "./Context.sol";

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        require(owner() == _msgSender(), "caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "new owner is the zero address"
        );
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
// SPDX-License-Identifier: None
pragma solidity ^0.8.17;

library ProofFactoryFees {
    struct allFees {
        uint256 reflectionFee;
        uint256 reflectionFeeOnSell;
        uint256 lpFee;
        uint256 lpFeeOnSell;
        uint256 devFee;
        uint256 devFeeOnSell;
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";

/// @title  TokenUtils
library TokenUtils  {
    /// @dev A safe function to get the decimals of an ERC20 token.
    ///
    /// @dev Reverts with a {CallFailed} error if execution of the query fails or returns an unexpected value.
    ///
    /// @param token The target token.
    ///
    /// @return The amount of decimals of the token.
    function expectDecimals(address token) internal view returns (uint8) {
        (bool success, bytes memory data) = token.staticcall(
            abi.encodeWithSelector(IERC20Metadata.decimals.selector)
        );

        require (success, "invalid");

        return abi.decode(data, (uint8));
    }   
}
// SPDX-License-Identifier: None
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../libraries/Ownable.sol";
import "../libraries/Context.sol";
import "../libraries/ProofFactoryFees.sol";
import "../interfaces/IFACTORY.sol";
import "../interfaces/IDividendDistributor.sol";
import "../interfaces/IUniswapV2Router02.sol";
import "../DividendDistributor.sol";
import "../interfaces/IProofFactoryTokenCutter.sol";

contract ProofFactoryTokenCutter is Context, IProofFactoryTokenCutter {

    //This token was created with PROOF, and audited by Solidity Finance — https://proofplatform.io/projects
    IDividendDistributor public dividendDistributor;
    uint256 distributorGas = 500000;

    mapping(address => bool) public userWhitelist;
    address[] public nftWhitelist;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint256 public whitelistEndTime;
    uint256 public whitelistPeriod;
    bool public whitelistMode = true;
    string private _name;
    string private _symbol;

    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;
    address public proofAdmin;

    bool public restrictWhales = true;

    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isTxLimitExempt;
    mapping(address => bool) public isDividendExempt;

    uint256 public launchedAt;
    uint256 public revenueFee = 2;

    uint256 public reflectionFee;
    uint256 public lpFee;
    uint256 public devFee;

    uint256 public reflectionFeeOnSell;
    uint256 public lpFeeOnSell;
    uint256 public devFeeOnSell;

    uint256 public totalFee;
    uint256 public totalFeeIfSelling;

    IUniswapV2Router02 public router;
    address public pair;
    address public factory;
    address public tokenOwner;
    address payable public devWallet;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public tradingStatus = true;

    uint256 public _maxTxAmount;
    uint256 public _walletMax;
    uint256 public swapThreshold;


    constructor() {
        factory = msg.sender;
    }

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    modifier onlyProofAdmin() {
        require(
            proofAdmin == _msgSender(),
            "not the proofAdmin"
        );
        _;
    }

    modifier onlyOwner() {
        require(tokenOwner == _msgSender(), "not the owner");
        _;
    }

    modifier onlyFactory() {
        require(factory == _msgSender(), "not the factory");
        _;
    }

    function setBasicData(
        BaseData memory _baseData,
        ProofFactoryFees.allFees memory fees
    ) external onlyFactory {
        _name = _baseData.tokenName;
        _symbol = _baseData.tokenSymbol;
        _totalSupply += _baseData.initialSupply;

        //Initial supply
        require(_baseData.percentToLP >= 70, "low lp");
        uint256 forLP = (_baseData.initialSupply * _baseData.percentToLP) / 100; //95%
        uint256 forOwner = _baseData.initialSupply - forLP; //5%

        _balances[msg.sender] += forLP;
        _balances[_baseData.owner] += forOwner;

        emit Transfer(address(0), msg.sender, forLP);
        emit Transfer(address(0), _baseData.owner, forOwner);

        _maxTxAmount = (_baseData.initialSupply * 5) / 1000;
        _walletMax = (_baseData.initialSupply * 1) / 100;
        swapThreshold = (_baseData.initialSupply * 5) / 4000;

        router = IUniswapV2Router02(_baseData.routerAddress);
        pair = IUniswapV2Factory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );

        _allowances[address(this)][address(router)] = type(uint256).max;

        dividendDistributor = new DividendDistributor(
            _baseData.routerAddress,
            _baseData.reflectionToken,
            address(this)
        );

        userWhitelist[address(this)] = true;
        userWhitelist[factory] = true;
        userWhitelist[pair] = true;
        userWhitelist[_baseData.owner] = true;
        userWhitelist[_baseData.initialProofAdmin] = true;
        userWhitelist[_baseData.routerAddress] = true;
        _addWhitelist(_baseData.whitelists);

        nftWhitelist = _baseData.nftWhitelist;

        isFeeExempt[address(this)] = true;
        isFeeExempt[factory] = true;

        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[_baseData.owner] = true;
        isTxLimitExempt[pair] = true;
        isTxLimitExempt[factory] = true;
        isTxLimitExempt[DEAD] = true;
        isTxLimitExempt[ZERO] = true;

        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        isDividendExempt[ZERO] = true;

        whitelistPeriod = _baseData.whitelistPeriod;

        reflectionFee = fees.reflectionFee;
        lpFee = fees.lpFee;
        devFee = fees.devFee;

        reflectionFeeOnSell = fees.reflectionFeeOnSell;
        lpFeeOnSell = fees.lpFeeOnSell;
        devFeeOnSell = fees.devFeeOnSell;

        _calcTotalFee();

        tokenOwner = _baseData.owner;
        devWallet = payable(_baseData.devWallet);
        proofAdmin = _baseData.initialProofAdmin;
    }

    //proofAdmin functions
    function updateProofAdmin(
        address newAdmin
    ) external virtual onlyProofAdmin {
        proofAdmin = newAdmin;
        userWhitelist[newAdmin] = true;
    }

    function updateWhitelistPeriod(
        uint256 _whitelistPeriod
    ) external onlyProofAdmin {
        whitelistPeriod = _whitelistPeriod;
        whitelistEndTime = launchedAt + (60 * _whitelistPeriod);
        whitelistMode = true;
    }

    //Factory functions
    function updateProofFactory(address newFactory) external onlyFactory {
        userWhitelist[newFactory] = true;
        isTxLimitExempt[newFactory] = true;
        isFeeExempt[newFactory] = true;	
        factory = newFactory;
    }

    function swapTradingStatus() external onlyFactory {
        tradingStatus = !tradingStatus;
    }

    function setLaunchedAt() external onlyFactory {
        require(launchedAt == 0, "already launched");
        launchedAt = block.timestamp;
        whitelistEndTime = block.timestamp + (60 * whitelistPeriod);
        whitelistMode = true;
    }

    function cancelToken() external onlyFactory {
        isFeeExempt[address(router)] = true;
        isTxLimitExempt[address(router)] = true;
        isTxLimitExempt[tokenOwner] = true;
        tradingStatus = true;
        restrictWhales = false;
        swapAndLiquifyEnabled = false;
    }

    //Owner functions
    function changeFees(
        uint256 initialReflectionFee,
        uint256 initialReflectionFeeOnSell,
        uint256 initialLpFee,
        uint256 initialLpFeeOnSell,
        uint256 initialDevFee,
        uint256 initialDevFeeOnSell
    ) external onlyOwner {
        reflectionFee = initialReflectionFee;
        lpFee = initialLpFee;
        devFee = initialDevFee;

        reflectionFeeOnSell = initialReflectionFeeOnSell;
        lpFeeOnSell = initialLpFeeOnSell;
        devFeeOnSell = initialDevFeeOnSell;

        _calcTotalFee();
    }

    function changeTxLimit(uint256 newLimit) external onlyOwner {
        _checkLimit(newLimit);
        _maxTxAmount = newLimit;
    }

    function changeWalletLimit(uint256 newLimit) external onlyOwner {
        _checkLimit(newLimit);
        _walletMax = newLimit;
    }

    function changeRestrictWhales(bool newValue) external onlyOwner {
        restrictWhales = newValue;
    }

    function changeIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function changeIsTxLimitExempt(
        address holder,
        bool exempt
    ) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }

    function changeDistributorGas(uint256 _distributorGas) external onlyOwner {
        distributorGas = _distributorGas;
    }

    function changeMinDistSettings(
        uint256 _minPeriod,
        uint256 _minDistLimit
    ) external onlyOwner {
        dividendDistributor.setMinPeriod(_minPeriod);
        dividendDistributor.setMinDistribution(_minDistLimit);
    }

    function reduceProofFee() external onlyOwner {
        require(revenueFee == 2, "!already reduced");
        _checkTimestamp72();

        revenueFee = 1;
        _calcTotalFee();
    }

    function adjustProofFee(uint256 _proofFee) external onlyProofAdmin {	
        require(launchedAt != 0, "!launched");	
        if (block.timestamp >= launchedAt + 72 hours) {	
            require(_proofFee <= 1);	
            revenueFee = _proofFee;	
            totalFee = devFee + lpFee + reflectionFee + revenueFee;	
            totalFeeIfSelling =	
                devFeeOnSell +	
                lpFeeOnSell +	
                reflectionFeeOnSell +	
                revenueFee;	
        } else {	
            require(_proofFee <= 2);	
            revenueFee = _proofFee;	
            totalFee = devFee + lpFee + reflectionFee + revenueFee;	
            totalFeeIfSelling =	
                devFeeOnSell +	
                lpFeeOnSell +	
                reflectionFeeOnSell +	
                revenueFee;	
        }	
    }

    function setDevWallet(address payable newDevWallet) external onlyOwner {
        devWallet = payable(newDevWallet);
    }

    function setOwnerWallet(address payable newOwnerWallet) external onlyOwner {
        tokenOwner = newOwnerWallet;
    }

    function changeSwapBackSettings(
        bool enableSwapBack,
        uint256 newSwapBackLimit
    ) external onlyOwner {
        swapAndLiquifyEnabled = enableSwapBack;
        swapThreshold = newSwapBackLimit;
    }

    function setDistributionCriteria(
        uint256 newMinPeriod_,
        uint256 newMinDistribution_
    ) external onlyOwner {
        dividendDistributor.setDistributionCriteria(
            newMinPeriod_,
            newMinDistribution_
        );
    }

    function getCirculatingSupply() external view returns (uint256) {
        return _totalSupply - balanceOf(DEAD) - balanceOf(ZERO);
    }

    function rewardTokenAddress() external view returns(address) {	
        return dividendDistributor.rewardTokenAddress();	
    }

    function isWhitelisted(address user) public view returns (bool) {
        return userWhitelist[user];
    }

    function holdsSupportedNFT(address user) public view returns (bool) {
        for (uint256 i = 0; i < nftWhitelist.length; i++) {
            if (IERC721(nftWhitelist[i]).balanceOf(user) > 0) {
                return true;
            }
        }
        return false;
    }

    function name() external view virtual override returns (string memory) {
        return _name;
    }

    function symbol() external view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() external view virtual override returns (uint8) {
        return 9;
    }

    function totalSupply() external view virtual override returns (uint256) {
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
    ) external virtual override returns (bool) {
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
    ) external virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) external virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) external virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(
            currentAllowance >= subtractedValue,
            "Decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(tradingStatus, "!trading");
        
        if(whitelistMode) {
            if (block.timestamp >= whitelistEndTime ) {
                whitelistMode = false;
            } else {
                if (sender == pair) { //buy
                    require(isWhitelisted(recipient) || holdsSupportedNFT(recipient), "Not whitelisted");
                } else if (recipient == pair) { //sell
                    require(isWhitelisted(sender) || holdsSupportedNFT(sender), "Not whitelisted");
                } else { //transfer
                    require((isWhitelisted(sender) || holdsSupportedNFT(sender)) && (isWhitelisted(recipient) || holdsSupportedNFT(recipient)), "Not Whitelisted");
                }
            }
        }

        if (inSwapAndLiquify) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (recipient == pair && restrictWhales) {	
            require(	
                amount <= _maxTxAmount ||	
                    (isTxLimitExempt[sender] && isTxLimitExempt[recipient]),	
                "Max TX"	
            );	
        }

        if (!isTxLimitExempt[recipient] && restrictWhales) {
            require(_balances[recipient] + amount <= _walletMax, "wallet");
        }

        if (
            sender != pair &&
            !inSwapAndLiquify &&
            swapAndLiquifyEnabled &&
            _balances[address(this)] >= swapThreshold
        ) {
            swapBack();
        }

        _balances[sender] = _balances[sender] - amount;
        uint256 finalAmount = amount;

        if (sender == pair || recipient == pair) {
            finalAmount = !isFeeExempt[sender] && !isFeeExempt[recipient]
                ? takeFee(sender, recipient, amount)
                : amount;
        }

        _balances[recipient] = _balances[recipient] + finalAmount;

        // Dividend tracker
        if (!isDividendExempt[sender]) {	
            try dividendDistributor.setShare(sender, _balances[sender]) {} catch {	
                emit DistributorFail();	
            }	
        }	
        if (!isDividendExempt[recipient]) {	
            try dividendDistributor.setShare(recipient, _balances[recipient]) {} catch {	
                    emit DistributorFail();	
                }	
        }	
        try dividendDistributor.process(distributorGas) {} catch {	
            emit DistributorFail();	
        }

        emit Transfer(sender, recipient, finalAmount);
        return true;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "Insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        uint256 feeApplicable = pair == recipient
            ? totalFeeIfSelling
            : totalFee;
        uint256 feeAmount = (amount * feeApplicable) / 100;

        _balances[address(this)] = _balances[address(this)] + feeAmount;
        emit Transfer(sender, address(this), feeAmount);

        return amount - feeAmount;
    }

    function swapBack() internal lockTheSwap {
        uint256 tokensToLiquify = _balances[address(this)];
        uint256 amountToLiquify = (tokensToLiquify * lpFee) / totalFee / 2;
        uint256 amountToSwap = tokensToLiquify - amountToLiquify;

        if (amountToSwap == 0) return;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amountETH = address(this).balance;
        uint256 amountEthLiquidity = (amountETH * lpFee) / totalFee / 2;

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value: amountEthLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                0x000000000000000000000000000000000000dEaD,
                block.timestamp
            );
        }

        uint256 amountETHafterLP = address(this).balance;
        uint256 devBalance = (amountETHafterLP * devFee) / totalFee;
        uint256 revenueBalance = (amountETHafterLP * revenueFee) / totalFee;
        uint256 amountEthReflection = amountETHafterLP -
            devBalance -
            revenueBalance;

        if (amountETHafterLP > 0) {
            if (revenueBalance > 0) {
                uint256 revenueSplit = revenueBalance / 2;
                (bool sent, ) = payable(IFACTORY(factory).proofRevenueAddress()).call{value: revenueSplit}("");
                require(sent);
                (bool sent1, ) = payable(IFACTORY(factory).proofRewardPoolAddress()).call{value: revenueSplit}("");
                require(sent1);
            }
            if (devBalance > 0) {
                (bool sent, ) = devWallet.call{value: devBalance}("");
                require(sent);
            }
        }

        try dividendDistributor.deposit{value: amountEthReflection}() {} catch {
            emit DistributorFail();
        }
    }

    function _checkLimit(uint256 _newLimit) internal view {	
        require(launchedAt != 0, "!launched");	
        require(_newLimit >= (_totalSupply * 5) / 1000, "Min 0.5%");	
        require(_newLimit <= (_totalSupply * 3) / 100, "Max 3%");	
    }

    function _checkTimestamp72() internal view {	
        require(launchedAt != 0, "!launched");	
        require(block.timestamp >= launchedAt + 72 hours, "too soon");	
    }

    function _calcTotalFee() internal {
        totalFee = devFee + lpFee + reflectionFee + revenueFee;
        totalFeeIfSelling =
            devFeeOnSell +
            lpFeeOnSell +
            reflectionFeeOnSell +
            revenueFee;
        require(totalFee <= 12, "high fee");
        require(totalFeeIfSelling <= 17, "high fee");
    }

    function _addWhitelist(address[] memory _whitelists) internal {
        uint256 length = _whitelists.length;
        for (uint256 i = 0; i < length; i++) {
            userWhitelist[_whitelists[i]] = true;
        }
    }

    function addMoreToWhitelist(WhitelistAdd_ memory _WhitelistAdd) external onlyFactory {
        _addWhitelist(_WhitelistAdd.whitelists);
    }

    receive() external payable {}
}