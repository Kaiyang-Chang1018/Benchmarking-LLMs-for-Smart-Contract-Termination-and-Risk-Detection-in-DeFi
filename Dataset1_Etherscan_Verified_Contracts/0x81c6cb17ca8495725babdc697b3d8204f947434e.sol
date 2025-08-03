// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IERC20 
{
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    error OwnableUnauthorizedAccount(address account);
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
contract depositToken is Ownable {
    address public Pax;
    address bankAddress;

    //  events  //
    event Deposit (address token_, address sender_, uint amount_);
    event DepositETH (address sender_, uint amount_);


    constructor(address token, address _owner,address _bankAddress) Ownable (_owner) {
        Pax = token;
        bankAddress = _bankAddress;

    }
    
    //  Deposit Functions  //
    function depositPax(uint _amount) public {

        // amount should be > 0
        require(_amount > 0, "Amount must be greater than 0");
        require(IERC20(Pax).balanceOf(msg.sender) >= _amount, "Insufficient balance");
        IERC20(Pax).transferFrom(msg.sender, bankAddress, _amount);

        emit Deposit (Pax , msg.sender, _amount);
    }


    function depositTokens(address _token, uint _amount) public {
    require(_amount > 0, "Amount must be greater than 0");
    require(IERC20(_token).balanceOf(msg.sender) >= _amount, "Insufficient balance");

    // Use low-level call to handle USDT's non-standard behavior
    (bool success, bytes memory data) = _token.call(
        abi.encodeWithSelector(IERC20.transferFrom.selector, msg.sender, bankAddress, _amount)
    );
    
    // Check if the transaction was successful and revert if not
    require(success && (data.length == 0 || abi.decode(data, (bool))), "Token transfer failed");

    emit Deposit(_token, msg.sender, _amount);
    }
    function depositETH() external payable  {
       

        require(msg.value >= 0, "Minimum investment wrong"); 
       

       
        emit DepositETH( msg.sender, msg.value);
    }
     // Bank Address
    function changeBankAddress(address _bankAddress) public onlyOwner{
       bankAddress=_bankAddress;
    }
    // withdraw functions for owner  //
    function withdrawTokens(IERC20 token) public onlyOwner{
        uint256 balance = token.balanceOf(address(this));
        token.transfer(msg.sender, balance);
    }

    function withdrawPax (uint _amount) public onlyOwner
    {
        IERC20(Pax).transfer(msg.sender, _amount);
    }

    function withdraw() public onlyOwner {
        (bool os, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(os);
    }
    
    //  view fucntions for return balance  //

    function balanceOf(address _tokenAddress) public view returns(uint)
    {
        uint _balance = IERC20(_tokenAddress).balanceOf(msg.sender);
        return _balance;
    }

    function balanceOfContract (address _tokenAddress) public view returns(uint)
    {
        uint _balance = IERC20(_tokenAddress).balanceOf(address(this));
        return _balance;
    }
}