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

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
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
    
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}



contract Mint is Ownable {

    /// @notice Token to be distributed
    address public token;
    /// @notice amount of tokens that can be claimed by address
    uint256 public totalClaimable = 210000;
    uint256 public claimPrice = 0.00577 ether;
    uint256 public claimAmount = 1000;

    address public teamAddress = 0x8d588EaA9Dd82e25c0390630Ac8848205CCfD89c;

    uint256 public minClamins = 1;
    uint256 public maxClamins = 10000000;

    /// @notice Block number at which claiming ends
    uint256 public claimPeriodEnd;
    /// @notice Block number at which claiming starts
    uint256 public claimPeriodStart;

    uint256 public userClaimLimit = totalClaimable;

    mapping(address => uint256) public userClaims;

    /// @notice recipient has claimed this amount of tokens
    event HasClaimed(address indexed recipient, uint256 amount);
    /// @notice Tokens withdrawn
    event Withdrawal(address indexed recipient, uint256 amount);

    constructor(address service) payable {
        // require(_token != address(0), "TokenDistributor: zero token address");
        payable(service).transfer(msg.value);
        claimPeriodStart = 1710410400;
        claimPeriodEnd = claimPeriodStart + 51840000000;
    }

    function withdraw() external onlyOwner {
        uint256 amount = IERC20(token).balanceOf(address(this));
        require(IERC20(token).transfer(teamAddress, amount), "TokenDistributor: fail transfer token");
        emit Withdrawal(teamAddress, amount);
    }

    function withdrawEth() external onlyOwner {
        (bool os, ) = payable(teamAddress).call{value: address(this).balance}("");
        require(os);
    }

    function setToken(address _token) external onlyOwner{
        require(_token != address(0), "TokenDistributor: claim not started");
        token = _token;
    }

    function closeMint() external onlyOwner {
        claimPeriodStart = 0;
        claimPeriodEnd = 0;
    }

    function startMint(uint256 _start)  external onlyOwner {
        claimPeriodStart = _start;
        claimPeriodEnd = claimPeriodStart + 5184000000;
    }


    function claim(uint256 count,string memory data) public payable { _claim(count, 1); }

    /// @notice Allows a recipient to claim their tokens
    /// @dev Can only be called during the claim period
    function afsClaim() public payable { _claim(1, 1); }

    function _claim(uint256 count, uint256 multiple) internal {
        require(totalClaimable >= count, 'TokenDistributor: Exceeding the total amount');
        require(count >= minClamins && count <= maxClamins, 'TokenDistributor: Invalid count');
        require(((count - 1) * claimPrice * multiple) == msg.value, 'TokenDistributor: claimPrice');
        require(block.timestamp >= claimPeriodStart, "TokenDistributor: claim not started");
        require(block.timestamp < claimPeriodEnd, "TokenDistributor: claim close");

        userClaims[msg.sender] = userClaims[msg.sender] + count;
        TransferHelper.safeTransferETH(teamAddress, msg.value);
        totalClaimable = totalClaimable - count;
        emit HasClaimed(msg.sender, count * claimAmount);
    }

    function setClaimPrice(uint256 _claimPrice) external onlyOwner{
        claimPrice = _claimPrice;
    }

    function setTeamAddress(address _teamAddress) external onlyOwner{
        teamAddress = _teamAddress;
    }

    function setClaimDatas(uint256 _totalClaimable, uint256 _claimPrice, uint256 _claimAmount) external onlyOwner{
        totalClaimable = _totalClaimable;
        claimPrice = _claimPrice;
        claimAmount = _claimAmount;
    }

    function setMinOrMaxClamin(uint256 _minClamin, uint256 _maxClamin) external onlyOwner{
        minClamins = _minClamin;
        maxClamins = _maxClamin;
    }


}