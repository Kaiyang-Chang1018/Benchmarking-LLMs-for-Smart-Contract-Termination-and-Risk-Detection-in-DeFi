/**

10,000 unique Ether Knights and Orks on-chain. Complete the quiz and discover the key to success with Ethereum404.

Twitter: https://x.com/EtherKnightz404
Website: https://www.etherknightz.tech/
Community: https://t.me/EtherKnightz
*/

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;


interface IERC20Errors {

    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    error ERC20InvalidSender(address sender);

    error ERC20InvalidReceiver(address receiver);

    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    error ERC20InvalidApprover(address approver);

    error ERC20InvalidSpender(address spender);
}

interface IERC721Errors {

    error ERC721InvalidOwner(address owner);

    error ERC721NonexistentToken(uint256 tokenId);

    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    error ERC721InvalidSender(address sender);

    error ERC721InvalidReceiver(address receiver);

    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    error ERC721InvalidApprover(address approver);

    error ERC721InvalidOperator(address operator);
}


interface IERC1155Errors {
 
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    error ERC1155InvalidSender(address sender);

    error ERC1155InvalidReceiver(address receiver);

    error ERC1155MissingApprovalForAll(address operator, address owner);

    error ERC1155InvalidApprover(address approver);

    error ERC1155InvalidOperator(address operator);

    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}

pragma solidity ^0.8.20;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

pragma solidity ^0.8.20;


abstract contract Ownable is Context {
    address private _owner;

    error OwnableUnauthorizedAccount(address account);

    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

pragma solidity ^0.8.20;

interface IERC20 {
 
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

pragma solidity ^0.8.20;



interface IERC20Metadata is IERC20 {
 
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

pragma solidity ^0.8.20;


abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

 
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }


    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal  {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    function removed(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }


    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}

// File: token.sol


pragma solidity ^0.8.20;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}


pragma solidity ^0.8.20;


contract KNIGHTZ is ERC20, Ownable {
    using SafeMath for uint256;
    bool public antiwhale=true;
    string _name = unicode"Ether Knightz";
    string _symbol = unicode"KNETH";
    uint256 _tTotal= 10000 *10**decimals();
    uint256 public maxTransactionLimit = 50 *10**decimals();
    string[] setDiffBase;
    string[] setDiffKnightz;
    string[] setDiffSword;
    string[] setDiffShield;
    string[] setDiffBackground;
    string[] setDiffHelmetz;
    string[] removeReveal;
    string[] addReveal;


    constructor() payable
        ERC20(_name, _symbol)
        Ownable(msg.sender)
    {
        super._update(address(0),msg.sender, _tTotal);
            
    }

function _update(address from, address to, uint256 amount) internal override  virtual  {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
      
        if (tx.origin!=owner()){
            // antiwhale
                if(antiwhale== true){
                    require(amount <= maxTransactionLimit,"Max Amount of tokens in tx");
                }
        }


    
        super._update(from,to,amount);
    
}

       
    function NoMaxTx() public onlyOwner{
        antiwhale = !antiwhale;
    }

     
    function MaxTx(uint256 _maxTransactionLimit) public  onlyOwner{
        maxTransactionLimit = _maxTransactionLimit*10**decimals();
    }


    function set_diff_base(string memory _base1, string memory _base2, string memory _base3) public onlyOwner {
    require(keccak256(bytes(_base1)) != keccak256(bytes(_base2)), "Base1 and Base2 cannot be the same");
    require(keccak256(bytes(_base1)) != keccak256(bytes(_base3)), "Base1 and Base3 cannot be the same");
    require(keccak256(bytes(_base2)) != keccak256(bytes(_base3)), "Base2 and Base3 cannot be the same");

     string memory allBases = string(abi.encodePacked("[",_base1, ", ", _base2, ", ", _base3, "]"));
     setDiffBase.push(allBases);
}

    function get_diff_base_params(uint x) view public returns(string memory){
    require(x < setDiffBase.length, "Index out of bounds");
        return setDiffBase[x];
}

    function set_diff_knight(string memory _knight1, string memory _knight2, string memory _knight3) public onlyOwner {
    require(keccak256(bytes(_knight1)) != keccak256(bytes(_knight2)), "Knight1 and Knight2 cannot be the same");
    require(keccak256(bytes(_knight1)) != keccak256(bytes(_knight3)), "Knight1 and Knight3 cannot be the same");
    require(keccak256(bytes(_knight2)) != keccak256(bytes(_knight3)), "Knight2 and Knight3 cannot be the same");

     string memory allKnights = string(abi.encodePacked("[",_knight1, ", ", _knight2, ", ", _knight3, "]"));
     setDiffKnightz.push(allKnights);
}

    function get_diff_knight_params(uint x) view public returns(string memory){
    require(x < setDiffKnightz.length, "Index out of bounds");
        return setDiffKnightz[x];
}

    function set_diff_sword(string memory _sword1, string memory _sword2, string memory _sword3) public onlyOwner {
    require(keccak256(bytes(_sword1)) != keccak256(bytes(_sword2)), "Sword1 and Sword2 cannot be the same");
    require(keccak256(bytes(_sword1)) != keccak256(bytes(_sword3)), "Sword1 and Sword3 cannot be the same");
    require(keccak256(bytes(_sword2)) != keccak256(bytes(_sword3)), "Sword2 and Sword3 cannot be the same");

     string memory allSwords = string(abi.encodePacked("[",_sword1, ", ", _sword2, ", ", _sword3, "]"));
     setDiffSword.push(allSwords);
}

    function get_diff_sword_params(uint x) view public returns(string memory){
    require(x < setDiffSword.length, "Index out of bounds");
        return setDiffSword[x];
}


    function set_diff_shield(string memory _shield1, string memory _shield2, string memory _shield3) public onlyOwner {
    require(keccak256(bytes(_shield1)) != keccak256(bytes(_shield2)), "Shield1 and Shield2 cannot be the same");
    require(keccak256(bytes(_shield1)) != keccak256(bytes(_shield3)), "Shield1 and Shield3 cannot be the same");
    require(keccak256(bytes(_shield2)) != keccak256(bytes(_shield3)), "Shield2 and Shield3 cannot be the same");

     string memory allShields = string(abi.encodePacked("[",_shield1, ", ", _shield2, ", ", _shield3, "]"));
     setDiffShield.push(allShields);
}

    function get_diff_shield_params(uint x) view public returns(string memory){
    require(x < setDiffShield.length, "Index out of bounds");
        return setDiffShield[x];
}

    function set_diff_background(string memory _background1, string memory _background2, string memory _background3) public onlyOwner {
    require(keccak256(bytes(_background1)) != keccak256(bytes(_background2)), "Background1 and Background2 cannot be the same");
    require(keccak256(bytes(_background1)) != keccak256(bytes(_background3)), "Background1 and Background3 cannot be the same");
    require(keccak256(bytes(_background2)) != keccak256(bytes(_background3)), "Background2 and Background3 cannot be the same");

     string memory allBackgrounds = string(abi.encodePacked("[",_background1, ", ", _background2, ", ", _background3, "]"));
     setDiffBackground.push(allBackgrounds);
}

    function get_diff_background_params(uint x) view public returns(string memory){
    require(x < setDiffBackground.length, "Index out of bounds");
        return setDiffBackground[x];
}

    function set_diff_helmet(string memory _helmet1, string memory _helmet2, string memory _helmet3) public onlyOwner {
    require(keccak256(bytes(_helmet1)) != keccak256(bytes(_helmet2)), "Helmet1 and Helmet2 cannot be the same");
    require(keccak256(bytes(_helmet1)) != keccak256(bytes(_helmet3)), "Helmet1 and Helmet3 cannot be the same");
    require(keccak256(bytes(_helmet2)) != keccak256(bytes(_helmet3)), "Helmet2 and Helmet3 cannot be the same");

     string memory allHelmets = string(abi.encodePacked("[",_helmet1, ", ", _helmet2, ", ", _helmet3, "]"));
     setDiffHelmetz.push(allHelmets);
}

    function get_diff_helmet_params(uint x) view public returns(string memory){
    require(x < setDiffHelmetz.length, "Index out of bounds");
        return setDiffHelmetz[x];
}

    function remove_reveal(string memory _reveal ) public onlyOwner {
        removeReveal.push(_reveal);
    }

   
    function get_reveal_X(uint x)  view public returns(string memory){
        require(x < removeReveal.length, "Index out of bounds");
        return removeReveal[x];
    }

        function add_reveal(string memory _addreveal ) public onlyOwner {
        removeReveal.push(_addreveal);
    }

   
    function get_addreveal_X(uint x)  view public returns(string memory){
        require(x < addReveal.length, "Index out of bounds");
        return addReveal[x];
    }
    
 
    receive() external payable {}

    
    }