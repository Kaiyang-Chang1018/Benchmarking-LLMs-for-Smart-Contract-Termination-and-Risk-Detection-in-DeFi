// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// A Peer-to-Peer Electronic Cash System on the Ethereum Network
contract M {
    string public name     = "M";
    string public symbol   = "M";
    uint8  public decimals = 18;

    event Transfer(address indexed from,  address indexed to,      uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    uint                                           public totalSupply;
    mapping (address => uint)                      public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;

    // (1) Contract auctions off M issuance for ETH sent to contract
    mapping (uint    => uint)                      public mBuysTotal; // ETH sent to contract, by epoch
    mapping (uint    => mapping (address => uint)) public mBuys; // ETH sent to contract, by epoch and sender, unsettled

    // (2) Contract auctions off ETH proceeds from auction 1 for M sent to 0x0000000000000000000000000000000000000000
    mapping (uint    => uint)                      public eBuysTotal; // M sent to address(0), by epoch
    mapping (uint    => mapping (address => uint)) public eBuys; // M sent to address(0), by epoch and sender, unsettled

    function approve(address spender, uint value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external returns (bool) {
        return transferFrom(msg.sender, to, value);
    }

    function transferFrom(address from, address to, uint value) public returns (bool) {
        require(balanceOf[from] >= value);
        if (from != msg.sender && allowance[from][msg.sender] != type(uint).max) {
            require(allowance[from][msg.sender] >= value);
            allowance[from][msg.sender] -= value;
        }
        balanceOf[from] -= value;
        balanceOf[to]   += value;
        if (to == address(0)) {
            // bid on ETH received by the contract in the previous epoch (auction 2)
            uint _epoch = epoch();
            require(_epoch > 0);
            eBuysTotal[_epoch] += value;
            eBuys[_epoch][from] += value;
        }
        emit Transfer(from, to, value);
        return true;
    }

    receive() external payable {
        // bid on M issuance (auction 1)
        uint _epoch = epoch();
        mBuysTotal[_epoch] += msg.value;
        mBuys[_epoch][msg.sender] += msg.value;
    }

    function epoch() public view returns (uint) {
        // ~12 days per epoch; epoch 0 starts in late August 2024
        return (block.timestamp/(2**20))-1645;
    }

    function issuance(uint _epoch) public pure returns (uint) {
        if (_epoch > 153) {
            return 10000*(10**18); // small tail emission to support network security
        } else {
            return (155-_epoch)*10000*(10**18); // fair initial distribution (no premine)
        }
    }

    // settle bids on M (auction 1)
    function mBuySettle(uint _epoch, address buyer) external {
        require(_epoch < epoch()); // epoch must be concluded
        uint mAllocation = (issuance(_epoch)*mBuys[_epoch][buyer])/mBuysTotal[_epoch];
        mBuys[_epoch][buyer] = 0;
        totalSupply += mAllocation;
        balanceOf[buyer] += mAllocation;
    }

    // settle bids on ETH (auction 2)
    function eBuySettle(uint _epoch, address buyer) external {
        require(_epoch < epoch()); // epoch must be concluded
        uint eAllocation = (mBuysTotal[_epoch-1]*eBuys[_epoch][buyer])/eBuysTotal[_epoch];
        eBuys[_epoch][buyer] = 0;
        (bool sent,) = buyer.call{value: eAllocation}("");
        require(sent);
    }
}

/*
Copyright (c) 2024 0xdf5383362516C6f088681410e64A627E69A05Bcb

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/