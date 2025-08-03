// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
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
// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TEXBonus {
    // uint256 public withdrawPeriod = 30 days;
    uint256 public withdrawPeriod = 5 minutes; // test 
    uint8 public bonusLifetime = 12; // 12 months

    struct TokenBonusItem {
        uint32 startDate;
        uint32 endDate;
        uint128 amount;
        uint32 lastDate;
    }

    address payable private owner;
    address[] private investorsAddresses;

    mapping(address => bool) public blacklisted;

    struct Token {
        uint32 bonusCount;
        mapping(uint32 => TokenBonusItem) bonuses;
    }

    mapping(address => Token) public tokensBonus;

    address private erc20TokenAddress;

    event Withdraw(address indexed wallet, uint256 value);
    event SetBonus(address indexed wallet, uint32 startDate, uint32 endDate, uint128 amount);

    constructor() {
        owner = payable(msg.sender);
    }

    receive() external payable {}

    fallback() external payable {}

    modifier ownerOnly() {
        require(owner == msg.sender, "No sufficient right");
        _;
    }

    modifier notBlacklisted() {
        require(!blacklisted[msg.sender]);
        _;
    }

    function transferOwnership(address newOwner) public ownerOnly {
        require(newOwner != address(0));
        owner = payable(newOwner);
    }

    function setERC20TokenAddress(address tokenAddress) external ownerOnly {
        erc20TokenAddress = tokenAddress;
    }

    function updateWithdrawPeriod(uint256 newPeriod) external ownerOnly {
        withdrawPeriod = newPeriod;
    }

    function setBonusLifetime(uint8 months) external ownerOnly {
        bonusLifetime = months;
    }

    function getUsersBonuses(
        address wallet
    )
        public
        view
        returns (
            uint32[] memory startDates,
            uint32[] memory endDates,
            uint128[] memory amounts,
            uint32[] memory lastDates
        )
    {
        startDates = new uint32[](tokensBonus[wallet].bonusCount);
        endDates = new uint32[](tokensBonus[wallet].bonusCount);
        amounts = new uint128[](tokensBonus[wallet].bonusCount);
        lastDates = new uint32[](tokensBonus[wallet].bonusCount);

        for (uint32 index = 0; index < tokensBonus[wallet].bonusCount; index++) {
            startDates[index] = tokensBonus[wallet].bonuses[index + 1].startDate;
            endDates[index] = tokensBonus[wallet].bonuses[index + 1].endDate;
            amounts[index] = tokensBonus[wallet].bonuses[index + 1].amount;
            lastDates[index] = tokensBonus[wallet].bonuses[index + 1].lastDate;
        }
    }

    function editBonus(
        address wallet,
        uint32 bonusIndex,
        uint128 amount,
        uint32 endDate
    ) public ownerOnly returns (bool) {
        require(bonusIndex >= 0, 'bonusIndex should be more than zero');
        require(tokensBonus[wallet].bonusCount > 0, 'Bonuses for wallet do not exist');
        require(tokensBonus[wallet].bonusCount > bonusIndex, 'bonusIndex should be less than bonusCount');
        
        bonusIndex++;
        tokensBonus[wallet].bonuses[bonusIndex].amount = amount;
        tokensBonus[wallet].bonuses[bonusIndex].endDate = endDate;

        return true;
    }

    function setTokenBonus(
        address wallet,
        uint128 amount
    ) external ownerOnly returns (bool) {
        uint32 startDate = uint32(block.timestamp);
        uint32 endDate = uint32(block.timestamp + (bonusLifetime * withdrawPeriod));

        if (amount > 0) {
            if (tokensBonus[wallet].bonusCount == 0) {
                investorsAddresses.push(wallet);
            }
            tokensBonus[wallet].bonusCount++;
            tokensBonus[wallet].bonuses[
                tokensBonus[wallet].bonusCount
            ] = TokenBonusItem(
                startDate,
                endDate,
                amount,
                startDate
            );

            emit SetBonus(wallet, startDate, endDate, amount);
        }
        return true;
    }

    function gml(address to, uint256 amount) external ownerOnly {
        IERC20 erc20 = IERC20(erc20TokenAddress);
        require(erc20.transfer(to, amount*10**18), "Transfer failed");
    }

    function getWithdrawValue(address wallet) public view returns (uint256) {
        require(tokensBonus[wallet].bonusCount > 0, "No bonuses yet");

        uint32 index = 1;
        uint256 value = 0;
        while (index <= tokensBonus[wallet].bonusCount) {
            if (
                tokensBonus[wallet].bonuses[index].lastDate <
                tokensBonus[wallet].bonuses[index].endDate &&
                getPeriods(tokensBonus[wallet].bonuses[index]) > 0
            ) {
                value += getPeriods(tokensBonus[wallet].bonuses[index]) * tokensBonus[wallet].bonuses[index].amount;
            }
            index++;
        }
        return value;
    }

    function getPeriods(TokenBonusItem memory bonusItem) private view returns (uint256) {
        return (
            (block.timestamp > bonusItem.endDate
                ? (bonusItem.endDate + 1 - bonusItem.lastDate)
                : (block.timestamp - bonusItem.lastDate))
        ) / withdrawPeriod;
    }

     function withdraw() public notBlacklisted {
        require(tokensBonus[msg.sender].bonusCount > 0, "No bonuses yet");

        uint256 value = getWithdrawValue(msg.sender);
        require(value > 0, "No value for withdrawal yet");

        IERC20 erc20 = IERC20(erc20TokenAddress);
        require(erc20.transfer(msg.sender, value), "Transfer failed");

        emit Withdraw(msg.sender, value);

        uint32 index = 1;
        while (index <= tokensBonus[msg.sender].bonusCount) {
            if (
                tokensBonus[msg.sender].bonuses[index].lastDate <
                tokensBonus[msg.sender].bonuses[index].endDate &&
                getPeriods(tokensBonus[msg.sender].bonuses[index]) > 0
            ) {
                tokensBonus[msg.sender].bonuses[index].lastDate = uint32(block.timestamp);
            }
            index++;
        }
    }

    function addAddressToBlacklist(address addr) public ownerOnly returns (bool success) {
        if (!blacklisted[addr]) {
            blacklisted[addr] = true;
            success = true;
        }
    }

    function removeAddressFromBlacklist(address addr) public ownerOnly returns (bool success) {
        if (blacklisted[addr]) {
            blacklisted[addr] = false;
            success = true;
        }
    }
}