pragma solidity 0.8.9;

// SPDX-License-Identifier: MIT

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
library EnumerableSet {
    struct Set {
        bytes32[] _values;
        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;
            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}


contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface Token {
    function transferFrom(address, address, uint) external returns (bool);
    function transfer(address, uint) external returns (bool);
    function balanceOf(address tokenOwner) external returns (uint);
}

contract ALICE_STAKING is Ownable {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    event RewardsTransferred(address holder, uint256 amount);
    
    //total tokens staked
    uint256 public totalstaked = 0;
    // Fees address...
    address public devAddress = 0xA7C17B9cD55ca9679D4Bd72d9ba1c9345D7b89D2;
    
    // alice token contract...
    address public alice = 0x405154cFAF5Ea4EF57B65b86959c73Dd079FA312;
    
    uint256 public rewardRate = 0;
    
    // reward interval 365 days
    uint256 public rewardInterval = 365 days;
    
    uint256 public MinimumWithdrawTime = 7 days;
    uint256 public penalty = 5;

    uint256 public reth = 0;
    uint256 public ethpool = 0;
    uint256 public ethstartblock;
    uint256 public totalClaimedRewards;
    
    EnumerableSet.AddressSet private holders;
    
    mapping (address => uint256) public depositedTokens;
    mapping (address => uint256) public stakingTime;
    mapping (address => uint256) public lastClaimedTime;
    mapping (address => uint256) public totalEarnedTokens;
    mapping (address => uint256) public totalEths;
    mapping (address => uint256) public lastETHtime;
    
    function updateAccount(address account) private {

        uint256 pendingDivs = getPendingDivs(account);
        uint256 conbalance = Token(alice).balanceOf(address(this));
        uint256 sur = conbalance.sub(totalstaked);
        lastClaimedTime[account] = block.timestamp;

        if (sur >= pendingDivs){
        if (pendingDivs != 0) {
            totalEarnedTokens[account] = totalEarnedTokens[account].add(pendingDivs);
            totalClaimedRewards = totalClaimedRewards.add(pendingDivs);

            Token(alice).transfer(account, pendingDivs);
            emit RewardsTransferred(account, pendingDivs);
        }
    }
    }
    
    function getPendingDivs(address _holder) public view returns (uint256 _pendingDivs) {
        if (!holders.contains(_holder)) return 0;
        if (!holders.contains(_holder)) return 0;
        if (block.timestamp.sub(stakingTime[msg.sender]) <= MinimumWithdrawTime) return 0;
        
        uint256 timeDiff = block.timestamp.sub(lastClaimedTime[_holder]);
        uint256 stakedAmount = depositedTokens[_holder];
        
        uint256 pendingDivs = stakedAmount.mul(rewardRate).mul(timeDiff).div(rewardInterval).div(1e2);
        return pendingDivs;
    }
    
    function getNumberOfHolders() public view returns (uint256) {
        return holders.length();
    }
    
    function deposit(uint256 amountToStake) public {
        
        Token(alice).transferFrom(msg.sender, address(this), amountToStake);
        updateAccount(msg.sender);
        stakingTime[msg.sender] = block.timestamp;
        depositedTokens[msg.sender] = depositedTokens[msg.sender].add(amountToStake);
        totalstaked = totalstaked.add(amountToStake);
        if (!holders.contains(msg.sender)) {
            holders.add(msg.sender);
        }
       lastETHtime[msg.sender] = block.timestamp;
    }
    
    function withdraw(uint256 amountToWithdraw) public {
        require(depositedTokens[msg.sender] >= amountToWithdraw, "Invalid amount to withdraw");
        claimtheETH(msg.sender);
        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(amountToWithdraw);
        totalstaked = totalstaked.sub(amountToWithdraw);
        if (holders.contains(msg.sender) && depositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
        
        uint256 _lastClaimedTime = block.timestamp.sub(stakingTime[msg.sender]);
        if (_lastClaimedTime >= MinimumWithdrawTime) {
            require(Token(alice).transfer(msg.sender, amountToWithdraw), "Could not transfer tokens.");
        }
        
        if (_lastClaimedTime < MinimumWithdrawTime) {
            uint256 WithdrawFee = amountToWithdraw.div(100).mul(penalty);
            uint256 amountAfterFee = amountToWithdraw.sub(WithdrawFee);
            require(Token(alice).transfer(msg.sender, amountAfterFee), "Could not transfer tokens.");
            require(Token(alice).transfer(devAddress, WithdrawFee), "Could not transfer tokens.");
        }
        
        updateAccount(msg.sender);
        lastETHtime[msg.sender] = block.timestamp;
    }
    
    function claimDivs() public {
        updateAccount(msg.sender);
    }

    function ClaimETH() public {
        claimtheETH(msg.sender);
    }

    function claimtheETH(address account) private {
        if(block.timestamp.sub(stakingTime[account]) >= MinimumWithdrawTime){
        uint256 eth = GetPendingETH(account);
        reth = reth - eth;
        lastETHtime[account] = block.timestamp;
        bool success;
        (success, ) = (account).call{value: eth}("");
        totalEths[account] = totalEths[account] + eth;
        }
    }

    function GetPendingETH(address _holder) public view returns (uint256 _pethss) {
        uint256 timeDiff = block.timestamp.sub(lastETHtime[_holder]);
        uint256 tdiff = (timeDiff > ethpool) ? ethpool : timeDiff;
        uint256 stakedAmount = depositedTokens[_holder];
        uint256 _pendingeths = stakedAmount.mul(reth).mul(tdiff).div(totalstaked).div(ethpool);
        return _pendingeths;
    }
    // function to allow admin to set dev address..
    function setDevaddress(address _devAadd) public onlyOwner {
        devAddress = _devAadd;
    }

    function setRewardRate(uint256 _rate) public onlyOwner {
        rewardRate = _rate;
    }

    function CreatePool(uint256 _eths, uint256 _pdays) public onlyOwner {
        reth = _eths* 1 ether;
        ethpool = _pdays * 1 days;
        ethstartblock = block.timestamp;
    }
    
    function setWDFees(uint256 _fees, uint256 _days) public onlyOwner {
        penalty = _fees;
        MinimumWithdrawTime = _days* 1 days;
    }

    // function to allow admin to claim *any* ERC20 tokens sent to this contract
    function transferAnyERC20Tokens(address _tokenAddress, address _to, uint256 _amount) public onlyOwner {
        require(alice != _tokenAddress, "Cannot withdraw native token");
        Token(_tokenAddress).transfer(_to, _amount);
    }
    function TakeOutTheEthers() external onlyOwner {
        bool success;
        (success, ) = owner().call{value: address(this).balance}("");
    } 

     receive() external payable {}
}