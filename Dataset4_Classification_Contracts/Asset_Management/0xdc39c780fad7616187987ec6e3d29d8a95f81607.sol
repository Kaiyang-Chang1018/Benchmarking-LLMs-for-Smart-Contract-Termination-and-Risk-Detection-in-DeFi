// Sources flattened with hardhat v2.8.3 https://hardhat.org

// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.4.2

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}


// File @openzeppelin/contracts/security/ReentrancyGuard.sol@v4.4.2
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File contracts/NAMXVesting.sol
pragma solidity 0.8.19;

contract NAMXvesting is ReentrancyGuard {

    struct LockData{
        uint256 amounts;
        uint256 timestamps;
    }
    
    bool public initialLocksSet;
    
    mapping(address => LockData[]) public lockData;
    mapping(address => uint256) public withdrawn;
    mapping(address => uint256) public lockedTokens;
    mapping(address => uint256) public claimTime;

    IERC20 public TargetToken;
    

    constructor(IERC20 tokenAddress) {
        TargetToken = tokenAddress;
    }

    function _setUpLock(address _account, uint256 _amount, uint256 _timestamp) private returns (uint256){
        lockData[_account].push(LockData(_amount, _timestamp));
        lockedTokens[_account] = _amount;
        claimTime[_account] = _timestamp;
        return _amount;
    }

    function _setUpLocks() private {
        uint256 tokensNeeded = 0;

        // 120 million - unlock on Thursday May 01 2025 00:00:00 GMT+0000
        tokensNeeded += _setUpLock(0xCAD2594b9F4c9FE14b5f143bA80ADB260C30A1e7, 120_000_000 ether, 1704042000); 
        tokensNeeded += _setUpLock(0xD3A4b021688ECDfe824A7E1d75378aea0327325F, 120_000_000 ether, 1704042000);
        tokensNeeded += _setUpLock(0x958857f700c804464b9313de463C495fd49669A8, 120_000_000 ether, 1704042000);

        //24 million
        tokensNeeded += _setUpLock(0x4DC804E6965a2f7F106aCD783697648676C8d3A8, 24_000_000 ether, 1704042000);
        
        
        //18 million
        tokensNeeded += _setUpLock(0x2E91E11CfdC44605dA1A3F21cd90e425d1E87c76, 18_000_000 ether, 1704042000);
        tokensNeeded += _setUpLock(0xc9Bf46b0dF89810E1F0305c33AA757e3C06d2917, 18_000_000 ether, 1704042000);
        

        //12 million
        tokensNeeded += _setUpLock(0x3aea9D189f955317A137909cd5b6D55920126acE, 12_000_000 ether, 1704042000);
        tokensNeeded += _setUpLock(0x36cdc8AA3Ef883F3023c1f339A9bC4d783D12398, 12_000_000 ether, 1704042000);
        tokensNeeded += _setUpLock(0x7A053926f816F442721a1a50b72d3FaF05D61764, 12_000_000 ether, 1704042000);
        tokensNeeded += _setUpLock(0x2a7813A24F3F65C5cE28fe867bae4AddfF39538d, 12_000_000 ether, 1704042000);
        
        //6 million
        tokensNeeded += _setUpLock(0x8131d7167E051c455c5f9beD56129c8D43AB2C87, 6_000_000 ether, 1704042000);
        tokensNeeded += _setUpLock(0x9391F927600BA804135c10E9e3Bf3D994d126953, 6_000_000 ether, 1704042000);
        tokensNeeded += _setUpLock(0x71b8b2b035528a31A435500E61Ab3CAADf02BE79, 6_000_000 ether, 1704042000);
        tokensNeeded += _setUpLock(0x4b666c25dc3854b54E636cc318FCb3C11D61eb9d, 6_000_000 ether, 1704042000);



        require(TargetToken.transferFrom(msg.sender, address(this), tokensNeeded), "Please approve tokens first and check max transaction limits");
    }

    function setUpAutomaticLocks() external {
        require(!initialLocksSet, "Initial locks already set");

        _setUpLocks();

        initialLocksSet = true;
    }

    function lock(uint256 amount, uint256 releaseTimestamp) external {
        _lock(msg.sender, amount, releaseTimestamp);
    }

    function lockFor(address account, uint256 amount, uint256 releaseTimestamp) external {
        _lock(account, amount, releaseTimestamp);
    }

    function _lock(address _account, uint256 _amount, uint256 _releaseTimestamp) internal {
        require(lockData[_account].length == 0, "Lock/Vesting for this address already exist");

        _setUpLock(_account, _amount, _releaseTimestamp);

        require(TargetToken.transferFrom(msg.sender, address(this), _amount), "Please approve tokens first");
    }


    function vest(uint256[] memory amounts, uint256[] memory releaseTimestamps) external {
        _vest(msg.sender, amounts, releaseTimestamps);
    }

    function vestFor(address account, uint256[] memory amounts, uint256[] memory releaseTimestamps) external {
        _vest(account, amounts, releaseTimestamps);
    }

    function _vest(address account, uint256[] memory _amounts, uint256[] memory _releaseTimestamps) internal {
        require(lockData[account].length == 0, "Lock/Vesting for this address already exist");
        require(_amounts.length == _releaseTimestamps.length, "Wrong amount of variables");

        for(uint i=1; i<_releaseTimestamps.length; i++) {
            require(_releaseTimestamps[i-1] < _releaseTimestamps[i], "Wrong sequence of timestamps");
        }

        uint256 tokensNeeded = 0;

        for(uint i=0; i<_amounts.length; i++) {
            tokensNeeded += _setUpLock(account, _amounts[i], _releaseTimestamps[i]);
        }

        require(TargetToken.transferFrom(msg.sender, address(this), tokensNeeded), "Please approve tokens first");
    }

    function canClaim(address account) public view returns (uint256) {
        uint256 amount = 0;
        for (uint i=0; i<lockData[account].length; i++) {
            if (lockData[account][i].timestamps <= block.timestamp) {
                amount += lockData[account][i].amounts;
            } else break;
        }

        return amount - withdrawn[account];
    }

    function claim() external nonReentrant {
        uint256 claimable = canClaim(msg.sender);

        require(TargetToken.transfer(msg.sender, claimable), "Cannot transfer tokens");
        
        withdrawn[msg.sender] += claimable;
        lockedTokens[msg.sender] = 0;
    }
}