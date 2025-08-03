/**
 *Submitted for verification at testnet.bscscan.com on 2025-01-15
*/

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
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);
}

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );


}

contract Claiming_Contract is Ownable {
    IERC20 public mainToken;
    bool public isClaimEnabled;
    uint256 public totalClaimable;
    struct User {
        uint256 token_balance;
        uint256 claimed_tokens;
        uint256 ref_reward;
    }
    mapping(address => User) public users;
    event ClaimToken(address indexed _user, uint256 indexed _amount);
    constructor(IERC20 _token) {
        mainToken = _token;
    }
    function claimTokens() external {
        require(isClaimEnabled, "Claim has not enabled yet");
        User storage user = users[msg.sender];
        require(user.token_balance > 0, "No tokens purchased");
        uint256 claimableTokens = user.token_balance - user.claimed_tokens;
        require(claimableTokens > 0, "No tokens to claim");
        user.claimed_tokens += claimableTokens;
        mainToken.transfer(msg.sender, claimableTokens);
        emit ClaimToken(msg.sender, claimableTokens);
    }

    function claimRefReward() public {
        require(isClaimEnabled, "Claim has not enabled yet");
        User storage user = users[msg.sender];
        uint256 claimAmount = user.ref_reward;
        require(claimAmount > 0, "No tokens to claim");
        user.ref_reward = 0;
        mainToken.transfer(msg.sender, claimAmount);
        emit ClaimToken(msg.sender, claimAmount);
    }

    function whitelistAddresses(
        address[] memory _addresses,
        uint256[] memory _tokenAmount,
        uint256[] memory _refAmount
    ) external onlyOwner {
        require(
            _addresses.length == _tokenAmount.length,
            "Addresses and amounts must be equal"
        );

        for (uint256 i = 0; i < _addresses.length; i++) {
            users[_addresses[i]].token_balance += _tokenAmount[i];
            users[_addresses[i]].ref_reward += _refAmount[i];
            totalClaimable += _tokenAmount[i] + _refAmount[i];
        }
    }

    function startClaim() external onlyOwner {
        isClaimEnabled = true;
    }
    // change tokens
    function updateToken(address _token) external onlyOwner {
        mainToken = IERC20(_token);
    }
    // to withdraw out tokens
    function transferTokens(IERC20 token, uint256 _value) external onlyOwner {
        token.transfer(msg.sender, _value);
    }
}