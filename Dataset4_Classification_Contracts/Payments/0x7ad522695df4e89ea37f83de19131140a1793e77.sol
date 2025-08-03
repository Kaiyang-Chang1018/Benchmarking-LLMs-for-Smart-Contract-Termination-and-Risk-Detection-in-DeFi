// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

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

// File: presaleev.sol


pragma solidity ^0.8.0;


contract Presale {
    IERC20 public usdcToken; // USDC token contract interface
    address public owner;
    uint256 public maxContribution = 500 * 1e6; // 500 USDC in smallest units (assuming 6 decimals)
    uint256 public hardCap = 100000 * 1e6; // Hard cap set at 100,000 USDC
    uint256 public totalContributions;
    mapping(address => uint256) public contributions;

    // Event that logs the contribution
    event Contributed(address contributor, uint256 amount);

    constructor(address _usdcTokenAddress) {
        usdcToken = IERC20(_usdcTokenAddress);
        owner = msg.sender;
    }

    function contribute(uint256 amount) public {
        require(totalContributions + amount <= hardCap, "Contribution would exceed hard cap");
        require(contributions[msg.sender] + amount <= maxContribution, "Contribution exceeds max allowance per wallet");
        
        // Transfer USDC tokens from contributor to this contract
        bool success = usdcToken.transferFrom(msg.sender, address(this), amount);
        require(success, "USDC transfer failed");

        contributions[msg.sender] += amount;
        totalContributions += amount;
        emit Contributed(msg.sender, amount);
    }

    // Function to withdraw the funds (USDC tokens) to the owner's address
    function withdrawFunds() public {
        require(msg.sender == owner, "Only the owner can withdraw funds");
        uint256 balance = usdcToken.balanceOf(address(this));
        bool success = usdcToken.transfer(owner, balance);
        require(success, "Failed to withdraw funds");
    }

    // Modifier to restrict certain functions to only the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner is allowed to perform this action");
        _;
    }
}