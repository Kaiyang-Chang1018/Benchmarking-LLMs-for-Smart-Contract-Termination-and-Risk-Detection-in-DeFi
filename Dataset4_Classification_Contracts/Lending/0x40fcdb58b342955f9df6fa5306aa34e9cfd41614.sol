// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
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

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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
     * by making the `nonReentrant` function external, and make it call a
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract CrowdFund is ReentrancyGuard, Ownable {
    using SafeMath for uint256;

    uint256 public _minimumContribution;
    uint256 public _maximumContribution;
    uint256 public _deadline; //seconds
    uint256 public _targetGoal;
    uint256 public _raisedAmount;
    uint256 public _totalContributors;
    uint256 public _price;
    uint256 public _crowdFundDuration;
    uint256 public _extensionTimes = 0;
    bool public _emergencyRefundEnabled;

    address[] private _contributorsList;
    mapping(address => uint256) public _contributors;

    mapping(address => uint256) public _refundableAmount;

    event RefundRequested(address contributor, uint256 amount);
    event RefundWithdrawn(address contributor, uint256 amount);

    enum ContractState {
        Paused,
        Active,
        Refunding
    }
    ContractState public _currentState;

    event DepositsEnabled();
    event DepositsPaused();
    event RefundEnabled();
    event ContributionMade(address contributor, uint256 amount);
    event RefundIssued(address contributor, uint256 amount);
    event FundsWithdrawn(uint256 amount);
    event MinimumContributionChanged(uint256 newMinimum);
    event MaximumContributionChanged(uint256 newMaximum);
    event DeadlineExtended();

    constructor(
        uint256 targetGoal_,
        uint256 crowdFundDuration_,
        uint256 price_,
        uint256 minimumContribution_,
        uint256 maximumContribution_
    ) Ownable() {
        require(targetGoal_ > 0, "Target goal must be greater than zero");
        require(crowdFundDuration_ > 0, "Duration  must be greater than zero");
        require(price_ > 0, "Price must be greater than zero");
        require(
            minimumContribution_ > 0,
            "Minimum contribution must be greater than zero"
        );
        require(
            maximumContribution_ >= minimumContribution_,
            "Maximum contribution must be greater than or equal to minimum contribution"
        );

        _deadline = block.timestamp + crowdFundDuration_;
        _crowdFundDuration = crowdFundDuration_;
        _targetGoal = targetGoal_;
        _minimumContribution = minimumContribution_;
        _maximumContribution = maximumContribution_;
        _price = price_;
        _currentState = ContractState.Active;
        _emergencyRefundEnabled = false;
    }

    function enableEmergencyRefund() external onlyOwner {
        require(!_emergencyRefundEnabled, "Emergency Refund already enabled");
        _emergencyRefundEnabled = true;
    }

    function enableDeposits() public onlyOwner {
        require(
            _currentState != ContractState.Active,
            "The deposits are already active"
        );
        _currentState = ContractState.Active;
        emit DepositsEnabled();
    }

    function pauseDeposits() public onlyOwner {
        require(
            _currentState != ContractState.Paused,
            "The deposits are already paused"
        );
        _currentState = ContractState.Paused;
        emit DepositsPaused();
    }

    function enableRefunds() public onlyOwner {
        require(
            _currentState != ContractState.Refunding,
            "Refunding is already enabled"
        );
        _currentState = ContractState.Refunding;
        emit RefundEnabled();
    }

    function getTokenAmount(address contributor) public view returns (uint256) {
        uint256 contribution = _contributors[contributor];
        return contribution / _price;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function contribute() public payable nonReentrant {
        require(
            block.timestamp < _deadline,
            "Crowd Funding deadline has passed."
        );
        require(
            _currentState == ContractState.Active,
            "Contract is not active"
        );
        require(
            msg.value >= _minimumContribution,
            "Contribution is less than the minimum required amount."
        );

        uint256 newContribution = _contributors[msg.sender] + msg.value;
        require(
            newContribution <= _maximumContribution,
            "Contribution exceeds the maximum allowed amount."
        );

        uint256 newTotalRaised = _raisedAmount + msg.value;
        require(
            newTotalRaised <= _targetGoal,
            "Contribution would exceed the target amount."
        );

        if (_contributors[msg.sender] == 0) {
            _totalContributors++;
            _contributorsList.push(msg.sender);
        }

        _contributors[msg.sender] = newContribution;
        _raisedAmount += msg.value;

        emit ContributionMade(msg.sender, msg.value);
    }

    function requestRefund(address contributor) public onlyOwner {
        require(_contributors[contributor] > 0, "Not a contributor");
        require(
            _currentState == ContractState.Refunding,
            "Refunds are not currently enabled"
        );

        uint256 amount = _contributors[contributor];
        _contributors[contributor] = 0;
        _raisedAmount = _raisedAmount.sub(amount);
        _refundableAmount[contributor] = amount;

        removeContributor(contributor);

        emit RefundRequested(contributor, amount);
    }

    function withdrawRefund() public nonReentrant {
        uint256 amount;

        if (_emergencyRefundEnabled) {
            amount = _contributors[msg.sender];
            require(amount > 0, "No contribution found");
            _contributors[msg.sender] = 0; // Zero out the contribution
        } else {
            amount = _refundableAmount[msg.sender];
            require(amount > 0, "No refund available");
            _refundableAmount[msg.sender] = 0; // Clear the refundable amount
        }

        require(
            address(this).balance >= amount,
            "Insufficient contract balance"
        );

        if (_raisedAmount >= amount) {
            _raisedAmount -= amount; // Update total raised amount
        } else {
            _raisedAmount = 0; // Set to zero if amount is greater than _raisedAmount
        }

        removeContributor(msg.sender); // Remove from contributors list

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        emit RefundWithdrawn(msg.sender, amount);
    }

    function getRefundableAmount(
        address contributor
    ) public view returns (uint256) {
        return _refundableAmount[contributor];
    }

    function ownerWithdraw() public onlyOwner nonReentrant {
        uint256 amount = address(this).balance;

        (bool success, ) = payable(owner()).call{value: amount}("");
        require(success, "Transfer failed");

        emit FundsWithdrawn(amount);
    }

    function setMinimumContribution(uint256 newMinimum) public onlyOwner {
        require(
            newMinimum <= _maximumContribution,
            "Minimum contribution cannot be greater than maximum contribution"
        );
        _minimumContribution = newMinimum;
        emit MinimumContributionChanged(newMinimum);
    }

    function setMaximumContribution(uint256 newMaximum) public onlyOwner {
        require(
            newMaximum >= _minimumContribution,
            "Maximum contribution cannot be less than minimum contribution"
        );
        _maximumContribution = newMaximum;
        emit MaximumContributionChanged(newMaximum);
    }

    function extendDeadline() public onlyOwner {
        require(
            _extensionTimes < 3,
            "you have reached the maximum amount of extension times"
        );

        _deadline += _crowdFundDuration;
        _extensionTimes += 1;

        emit DeadlineExtended();
    }

    function removeContributor(address contributor) private {
        for (uint i = 0; i < _contributorsList.length; i++) {
            if (_contributorsList[i] == contributor) {
                _contributorsList[i] = _contributorsList[
                    _contributorsList.length - 1
                ];
                _contributorsList.pop();
                _totalContributors--;
                break;
            }
        }
    }

    function getContributorsList() public view returns (address[] memory) {
        return _contributorsList;
    }
}