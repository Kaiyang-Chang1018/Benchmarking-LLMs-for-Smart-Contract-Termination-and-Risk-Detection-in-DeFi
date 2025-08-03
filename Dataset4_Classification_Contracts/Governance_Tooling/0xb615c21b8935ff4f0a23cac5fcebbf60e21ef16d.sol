//SPDX-License-Identifier: MIT Licensed
pragma solidity ^0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

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
            "Ownable: new owner is the zero address"
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

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function decimals() external view returns (uint8);
}

contract tokenDistribution is Ownable {
    IERC20 public mainToken;

    uint256 public totalUsers;
    uint256 public startTime;
    bool public isStarted;

    uint256 public threeMonths = 90 days;

    address[] public UsersAddresses;
    struct User {
        uint256 claimedAmount;
        uint256 claimAbleAmount;
        uint256 lastClaimTime;
    }

    mapping(address => User) public users;
    mapping(address => bool) public isExist;

    constructor(IERC20 _token) {
        mainToken = _token;
    }

    function claimAmount() public {
        require(isExist[_msgSender()], "Not a participant");
        uint256 amount = users[msg.sender].claimAbleAmount;
        require(amount > 0, "No claimable amount");
        require(
            address(mainToken) != address(0),
            "Presale token address not set"
        );
        require(
            amount <= mainToken.balanceOf(address(this)),
            "Not enough tokens in the contract"
        );
        require(isStarted, "Claim is not enable");
        require(block.timestamp > startTime, "wait for start time");
        uint256 claimAmount_ = users[msg.sender].claimAbleAmount;
        users[msg.sender].claimedAmount += claimAmount_;
        mainToken.transfer(msg.sender, claimAmount_);
        users[msg.sender].claimAbleAmount = 0;

        users[msg.sender].lastClaimTime = block.timestamp;
    }

    function start() external onlyOwner {
        require(!isStarted, "Already ended");
        isStarted = true;
        startTime = block.timestamp + threeMonths;
    }

    // change tokens
    function updateToken(address _token) external onlyOwner {
        mainToken = IERC20(_token);
    }

    function whitelistAddresses(
        address[] memory _addresses,
        uint256[] memory _tokenAmount
    ) external onlyOwner {
        require(
            _addresses.length == _tokenAmount.length,
            "Addresses and amounts must be equal"
        );

        for (uint256 i = 0; i < _addresses.length; i++) {
            if (!isExist[_addresses[i]]) {
                isExist[_addresses[i]] = true;
                UsersAddresses.push(_addresses[i]);
            }
            users[_addresses[i]].claimAbleAmount += _tokenAmount[i];
        }
    }

    // to withdraw stuck Eths
    function initiateTransfer(uint256 _value) external onlyOwner {
        payable(msg.sender).transfer(_value);
    }

    function totalUsersCount() external view returns (uint256) {
        return UsersAddresses.length;
    }

    function withdrawStuckTokens(IERC20 token, uint256 _value)
        external
        onlyOwner
    {
        token.transfer(msg.sender, _value);
    }

    receive() external payable {}
}