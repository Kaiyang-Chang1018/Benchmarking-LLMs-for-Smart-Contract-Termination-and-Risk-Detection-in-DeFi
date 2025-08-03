pragma solidity ^0.7.5;

contract TIA {
    address public owner;
    mapping(uint32 => TIAInfo) public TIAcommit;

    struct TIAInfo {
        uint32 TIAHeight;
        bytes32 hash;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    constructor() public {
        owner=msg.sender;
    }

    function transferOwner(address _owner) public onlyOwner() {
        owner = _owner;
    }

    function commitTIAIndex(uint32 _openBitHeight, uint32 _TIAHeight, bytes32 _hash) public onlyOwner() {
        TIAInfo memory newTIA = TIAInfo({
        TIAHeight : _TIAHeight,
        hash : _hash
        });
        TIAcommit[_openBitHeight] = newTIA;
    }
}