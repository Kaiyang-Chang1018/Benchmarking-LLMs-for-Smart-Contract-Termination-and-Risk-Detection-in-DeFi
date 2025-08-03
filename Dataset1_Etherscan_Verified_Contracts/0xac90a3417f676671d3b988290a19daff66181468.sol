// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract XCHNGStaking is Ownable {
    IERC20 public xchngToken;
    struct Stake {
        uint256 amount;
        uint256 unlockTime;
        uint256 vXCHNGAmount;
    }

    mapping( address => mapping (uint256 => Stake) ) public stakes;
    mapping (address => uint256 ) public stakeIndex;
    mapping(address => uint256) public vXCHNGBalance;
    uint256 public totalXCHNGStaked;

    event Staked(address indexed user, uint256 amount, uint256 duration, uint256 vXCHNGAmount);
    event Withdrawn(address indexed user, uint256 amount);

    constructor(address _xchngTokenAddress) {
        xchngToken = IERC20(_xchngTokenAddress);
    }

    function stake(uint256 _amount, uint256 _duration) public {
        require(_amount > 0, "Amount must be greater than 0");
        uint256 durationSeconds = _getDurationSeconds(_duration);
        require(durationSeconds > 0, "Invalid duration");

        uint256 vXCHNGAmount = _calculateVXCHNGAmount(_amount, _duration);
        uint256 _stakeIndex = stakeIndex[msg.sender];
        stakes[msg.sender][_stakeIndex] = Stake(_amount, block.timestamp + durationSeconds, vXCHNGAmount);
        stakeIndex[msg.sender] =  _stakeIndex + 1;

        vXCHNGBalance[msg.sender] += vXCHNGAmount;
        totalXCHNGStaked += _amount;

        require(xchngToken.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        emit Staked(msg.sender, _amount, _duration, vXCHNGAmount);
    }

    function withdraw(uint256 _stakeIndex) public {
        Stake memory userStake = stakes[msg.sender][_stakeIndex];
        require(block.timestamp >= userStake.unlockTime, "Stake is still locked");
        require(userStake.amount > 0, "Empty stakeIndex");

        require(xchngToken.transfer(msg.sender, userStake.amount), "Transfer failed");
        totalXCHNGStaked -= userStake.amount;
        delete stakes[msg.sender][_stakeIndex];
        vXCHNGBalance[msg.sender] -= userStake.vXCHNGAmount;

        emit Withdrawn(msg.sender, userStake.amount);
    }

    function stakeInfo(address _user, uint256 _stakeIndex) public view returns (uint256 amount, uint256 unlockTime, uint256 vXCHNGAmount) {
        Stake memory userStake = stakes[_user][_stakeIndex];
        return (userStake.amount, userStake.unlockTime, userStake.vXCHNGAmount);
    }
	
    function transfer(address _sender, uint256 _senderIndex, address _recipient) public onlyOwner {
        Stake memory senderStake = stakes[_sender][_senderIndex];
        require(senderStake.amount > 0, "Invalid _senderIndex");

        uint256 _recipientIndex = stakeIndex[_recipient];
        stakes[_recipient][_recipientIndex] = senderStake;
        stakeIndex[_recipient] =  _recipientIndex + 1;
		vXCHNGBalance[_recipient] += senderStake.vXCHNGAmount;
		
        delete stakes[_sender][_senderIndex];
		vXCHNGBalance[_sender] -= senderStake.vXCHNGAmount;
    }

    function _getDurationSeconds(uint256 _duration) private pure returns (uint256) {
        if (_duration == 6) return 180 days;
        if (_duration == 12) return 365 days;
        if (_duration == 24) return 730 days;
        if (_duration == 48) return 1460 days;
        return 0;
    }

    function _calculateVXCHNGAmount(uint256 _amount, uint256 _duration) private pure returns (uint256) {
        if (_duration == 6) return _amount;
        if (_duration == 12) return _amount * 3 / 2;
        if (_duration == 24) return _amount * 3;
        if (_duration == 48) return _amount * 8;
        return 0;
    }
}