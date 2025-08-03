// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IUniswapV2Router02 {
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

interface ITaxToken {
    function addInitialLiquidity(uint256 tokenAmount) external payable;
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferOwnership(address newOwner) external;
}

contract UniswapFirstBuy is Ownable {
    uint256 public totalEthContributed;
    uint256 public totalTokensBought;

    uint256 public maxContribution = 0.5 ether;
    mapping(address => uint256) public ethContributions;

    ITaxToken public token;

    bool public isOpen = true;
    bool public isLiquidityAdded = false;

    IUniswapV2Router02 public immutable uniswapV2Router;

    event EthContributed(address addr, uint256 amount);

    constructor(address uniswapAddress)
    {
        uniswapV2Router = IUniswapV2Router02(
            uniswapAddress //Uniswap V2 Router
        );
    }

    function setTokenAddress(address addr) public onlyOwner {
        token = ITaxToken(addr);
    }

    function setMaxContribution(uint256 newMax) public onlyOwner {
        maxContribution = newMax;
    }

    function setIsOpen(bool _isOpen) public onlyOwner {
        isOpen = _isOpen;
    }

    function launchToken(uint256 tokenAmount) public payable onlyOwner {
        require(!isLiquidityAdded, "Already launched");
        require(msg.value > 0, "Must send ETH");

        isOpen = false;

        token.approve(address(token), tokenAmount);
        token.addInitialLiquidity{value: msg.value}(tokenAmount);

        if (totalEthContributed > 0)
            buyTokensWithEth(totalEthContributed);

        isLiquidityAdded = true;
    }

    receive() external payable {
        require(isOpen, "Contributions closed now");
        require(msg.value > 0, "Must send ETH");
        require(ethContributions[msg.sender] + msg.value <= maxContribution, "Contribution exceeds limit");

        ethContributions[msg.sender] += msg.value;
        totalEthContributed += msg.value;

        emit EthContributed(msg.sender, msg.value);
    }

    // Function to buy tokens with the ETH pool
    function buyTokensWithEth(uint256 ethAmount) internal {
        require(address(this).balance >= ethAmount, "Insufficient ETH balance");

        // Set up the path to swap ETH for tokens
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(token);

        uint256 initialTokenBalance = token.balanceOf(address(this));

        // Make the swap
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethAmount}(
            0, // accept any number of Tokens
            path,
            address(this),
            block.timestamp
        );

        // Update the total tokens bought
        totalTokensBought = token.balanceOf(address(this)) - initialTokenBalance;
    }

    // Function for users to withdraw their tokens
    function withdrawTokens() public {
        require(isLiquidityAdded, "Liquidity not yet added");
        uint256 userEthContribution = ethContributions[msg.sender];
        require(userEthContribution > 0, "No ETH contribution");

        uint256 tokenAmount = calculateTokenAmount(msg.sender);
        ethContributions[msg.sender] = 0;
        token.transfer(msg.sender, tokenAmount);
    }

    // Calculate the amount of tokens a user can withdraw
    function calculateTokenAmount(address userAddy) public view returns (uint256) {
        if (totalEthContributed == 0)
            return 0;

        return (ethContributions[userAddy] * totalTokensBought) / totalEthContributed;
    }

    function getCurrentContribution() public view returns (uint256) {
        return ethContributions[msg.sender];
    }

    function setTokenOwner(address newOwner) public onlyOwner {
        token.transferOwnership(newOwner);
    }

    function emergencyWithdraw() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}