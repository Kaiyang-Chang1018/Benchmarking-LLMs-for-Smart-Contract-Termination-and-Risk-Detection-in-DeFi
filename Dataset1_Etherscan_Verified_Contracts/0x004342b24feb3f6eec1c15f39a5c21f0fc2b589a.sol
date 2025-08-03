// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


interface IERC20 {
    function decimals() external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}


contract Ownable is Context {
    address private _owner;
    address private _previousOwner;

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

contract Migration is ReentrancyGuard, Ownable{

    address public immutable DEAD = 0x000000000000000000000000000000000000dEaD;
    address public immutable withdrawalAddress = 0xcE6084118756Da652F793fd52b45D6FCd48b52D8;

    IERC20 public Catboy; //address of the old version
    IERC20 public CatboyNew; //address of the new version

    bool public migrationStarted = false;

    event Migrated(address walletAddress, uint256 amount);
    event MigrationStarted();
    event MigrationStopped();
    event TokensUpdated(address oldAddress, address newAddress);

    constructor(IERC20 tokenAddressV1, IERC20 tokenAddressV2) {
        CatboyNew = tokenAddressV2;
        Catboy = tokenAddressV1;
    }

    /// @notice Enables the migration
    function startMigration() external onlyOwner{
        require(migrationStarted == false, "Migration is already enabled");
        migrationStarted = true;

        emit MigrationStarted();
    }

    /// @notice Disable the migration
    function stopMigration() external onlyOwner{
        require(migrationStarted == true, "Migration is already disabled");
        migrationStarted = false;
        
        emit MigrationStopped();
    }

    function setTokens(IERC20 Catboyaddr, IERC20 CatboyNewaddr) external onlyOwner{
        Catboy = Catboyaddr;
        CatboyNew = CatboyNewaddr;
    }

    function withdrawETH() public onlyOwner {
        payable(withdrawalAddress).transfer(address(this).balance); 
    }

    function withdrawERC20(address _tokenCA, uint256 _amount) public onlyOwner {
        IERC20(_tokenCA).transfer(withdrawalAddress, _amount);
    }

    function migrateTokens(uint256 amount) public nonReentrant(){
        require(migrationStarted == true, 'Migration not started yet');
        uint256 userV1Balance = Catboy.balanceOf(msg.sender);
        require(userV1Balance >= amount, 'You must hold V1 tokens to migrate');
        require(CatboyNew.balanceOf(address(this)) >= amount, 'Not enough tokens in the contract, contact the team');
        Catboy.transferFrom(msg.sender, DEAD, amount);
        CatboyNew.transfer(msg.sender, amount);
        emit Migrated(msg.sender, amount);
    }

}