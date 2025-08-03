// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IERC20Extended {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract SharbiStaking is Ownable{
    IERC20Extended public token;
    IERC20Extended public rewardToken;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    uint256 currentIndex;
    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10**36;

    bool public halt;

    address[] public shareholders;
    mapping(address => uint256) public shareholderIndexes;
    mapping(address => uint256) public shareholderClaims;
    mapping(address => Share) public shares;

    constructor(address _token, address _rToken) {
        token = IERC20Extended(_token);
        rewardToken = IERC20Extended(_rToken);
    }

    function stake(uint256 amount) external {
        require(!halt,"Staking paused");
        token.transferFrom(msg.sender, address(this), amount);
        setShare(msg.sender, (shares[msg.sender].amount + amount));
    }

    function unStake() external {
        require(!halt,"Staking paused");
        token.transfer(msg.sender, shares[msg.sender].amount);
        setShare(msg.sender, 0);
    }

    function setShare(address shareholder, uint256 amount) internal {
        if (shares[shareholder].amount > 0) {
            distributeDividend(shareholder);
        }

        if (amount > 0 && shares[shareholder].amount == 0) {
            addShareholder(shareholder);
        } else if (amount == 0 && shares[shareholder].amount > 0) {
            removeShareholder(shareholder);
        }

        totalShares = (totalShares - shares[shareholder].amount) + amount;
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(
            shares[shareholder].amount
        );
    }

    function claimDividend() external {
        require(!halt,"Staking paused");
        distributeDividend(msg.sender);
    }

    function distributeDividend(address shareholder) internal {
        if (shares[shareholder].amount == 0) {
            return;
        }

        uint256 amount = getUnpaidEarnings(shareholder);
        if (amount > 0) {
            totalDistributed += amount;
            rewardToken.transfer(shareholder, ((amount * 10 ** rewardToken.decimals()) / (10**18)));
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised += amount;
            shares[shareholder].totalExcluded = getCumulativeDividends(
                shares[shareholder].amount
            );
        }
    }

    function getPaidEarnings(address shareholder)
        public
        view
        returns (uint256)
    {
        return shares[shareholder].totalRealised;
    }

    function getUnpaidEarnings(address shareholder)
        public
        view
        returns (uint256)
    {
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

        return (shareholderTotalDividends - shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share)
        internal
        view
        returns (uint256)
    {
        return
            ((share * dividendsPerShare) / dividendsPerShareAccuracyFactor);
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

    function injectReward(uint256 amount) external onlyOwner {
        rewardToken.transferFrom(msg.sender, address(this), ((amount * 10 ** rewardToken.decimals()) / (10 ** 18)));
        totalDividends += amount;
        dividendsPerShare += (dividendsPerShareAccuracyFactor * amount) / totalShares;
    }

    function setStakeToken(address _token) external onlyOwner {
        token = IERC20Extended(_token);
    }

    function setRewardToken(address _rToken) external onlyOwner {
        rewardToken = IERC20Extended(_rToken);
    }

    function withdrawToken(address _token, uint256 amount) external onlyOwner {
        IERC20Extended(_token).transfer(owner(), amount);
    }

    function haltStaking(bool _state) external onlyOwner {
        halt = _state;
    }
}