/**
 *Submitted for verification at Etherscan.io on 2024-12-26
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
       
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


contract Ownable {
    address public _owner;

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}
interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

   
}
contract neiro is Ownable{
    
    event Logs(uint256 types,address user,uint256 amount,uint256 tid);
    using SafeMath for uint256;
    address private wituser;
    address private vuser;
    mapping (address => uint256) private tokenid;
    mapping (address => uint256) private usdtid;
    
    IERC20 private USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    IERC20 private Token = IERC20(0x812Ba41e071C7b7fA4EBcFB62dF5F45f6fA853Ee);
    IERC20 private Wbnb = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    
    IUniswapV2Router02 private uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    //test 0xD99D1c33F9fC3444f8101754aBC46c52416550D1     bsc  0x10ED43C718714eb63d5aA57B78B54704E256024E  eth 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    //test        bsc  0x55d398326f99059fF775485246999027B3197955

    uint256[] private price = [100,1000];

    function gettokens() public view returns (IERC20 _USDT,IERC20 _Token ,IERC20 _Wbnb,IUniswapV2Router02 _uniswapV2Router,uint256[] memory _price,address _wituser,address _vuser) {
        _USDT = USDT;
        _Token = Token;
        _Wbnb = Wbnb;
        _uniswapV2Router=uniswapV2Router;
        _price = price;
        _wituser = wituser;
        _vuser = vuser;
    }

   // function getnums() public view returns (uint256 _nn) {
   //     _nn = Token.balanceOf(address(this));
    //}

    function supply(uint256 _id ) public {
        USDT.transferFrom(msg.sender, address(this), price[_id].mul(1000000));
        _buy(price[_id].mul(1000000).mul(8).div(100),msg.sender);
        emit Logs(1,msg.sender,price[_id] ,0);
    }

    function supply2(uint256 _num ) public {
        USDT.transferFrom(msg.sender, address(this), price[0].mul(1000000).mul(_num));
        _buy((price[0]).mul(1000000).mul(8).div(100).mul(_num),msg.sender);
        emit Logs(2,msg.sender,price[0].mul(_num) ,_num);
    }
    function admin_buy(uint256 usdtamount ) public onlyOwner{
        USDT.transferFrom(msg.sender, address(this), usdtamount);
        _buy(usdtamount,msg.sender);
    }
    
    function _buy(uint256 usdtamount ,address _user) private {
        //USDT.approve(address(uniswapV2Router), usdtamount);
        //USDT.transferFrom(msg.sender, address(this), usdtamount);
        //Wbnb.approve(address(uniswapV2Router), usdtamount);
        //uint256 _unum = usdtamount;
        address[] memory path = new address[](3);
        path[0] = address(USDT);
        path[1] = address(Wbnb);
        path[2] = address(Token);
        //uint256[] memory amounts = uniswapV2Router.swapExactTokensForTokens(
        uniswapV2Router.swapExactTokensForTokens(    
            usdtamount,
            0,
            path,
            _user,
            block.timestamp+500
        );
    }

    


    constructor() public {
        _owner = msg.sender;
        wituser = msg.sender;
        vuser = msg.sender;
    }

    function admin_set_token(IERC20 _USDT,IERC20 _Token ,IERC20 _Wbnb) public onlyOwner{
        USDT = _USDT;
        Token = _Token;
        Wbnb = _Wbnb;
    }

    function admin_change_price(uint256 newprice,uint256 _id) public onlyOwner{
        price[_id] = newprice;
    }

    function admin_change_wituser(address newwit) public onlyOwner{
        wituser = newwit;
    }

    function admin_change_vuser(address newv) public onlyOwner{
        vuser = newv;
    }

    function admin_approve(address rolu,uint256 _num) public onlyOwner{
        USDT.approve(rolu, _num);
    }

    function admin_set_role(IUniswapV2Router02 _role) public onlyOwner{
        uniswapV2Router = _role;
    }

    function  withdrawal_usdt(address touser,uint256 num )  public {
        require(msg.sender == wituser, "no admin");
        USDT.transfer(touser, num);
    }
    function  withdrawal_token( address touser,uint256 num)  public {
        require(msg.sender == wituser, "no admin");
        Token.transfer(touser, num);
    }
    function withdrawal_eth(address payable _to)  public onlyOwner{
        _to.transfer(address(this).balance);
    }

    function toEthSignedMessageHash(bytes32 hash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function recoverSigner(bytes32 _msgHash, bytes memory _signature) public pure returns (address){
        require(_signature.length == 65, "invalid signature length");
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(_signature, 0x20))
            s := mload(add(_signature, 0x40))
            v := byte(0, mload(add(_signature, 0x60)))
        }
        return ecrecover(_msgHash, v, r, s);
    }




    function verify(bytes32 _msgHash, bytes memory _signature, address _signer) public pure returns (bool) {
        return recoverSigner(_msgHash, _signature) == _signer;
    }

    function getMessageHash3(address _user,address token,uint256 _num,uint256 _txid,uint32 _time) public pure returns(bytes32){
        return keccak256(abi.encodePacked(_user,token,_num,_txid,_time));
    }

    function find_tokenid(address _user) public view returns (uint256 _tokenid) {
        _tokenid = tokenid[_user]+1;
    }
    function find_usdtid(address _user) public view returns (uint256 _usdtid) {
        _usdtid = usdtid[_user]+1;
    }
    
    function find_time(address _user) public view returns (uint32 _time) {
        _time = uint32(block.timestamp);
    }

    function withdrawtoken(address _user ,address token,uint256 _num,uint256 _txid,uint32 _time, bytes memory _signature ) public  {
        bytes32 _msgHash = toEthSignedMessageHash(getMessageHash3(msg.sender,token,_num,(tokenid[_user]+1),_time));
        require(verify(_msgHash, _signature,vuser), "PET: invalid signature");
        require(_txid == (tokenid[_user]+1), "id wrong");
        require(_time >= uint32(block.timestamp), "time wrong");
        uint256 c = tokenid[msg.sender];
        tokenid[msg.sender] +=1;
        Token.transfer(msg.sender, _num);
        emit Logs(4,_user,_num ,c);
    }
    function withdrawusdt(address _user ,address token,uint256 _num,uint256 _txid,uint32 _time, bytes memory _signature ) public  {
        bytes32 _msgHash = toEthSignedMessageHash(getMessageHash3(msg.sender,token,_num,(usdtid[_user]+1),_time));
        require(verify(_msgHash, _signature,vuser), "PET: invalid signature");
        require(_txid == (usdtid[_user]+1), "id wrong");
        require(_time >= uint32(block.timestamp), "time wrong");
        uint256 c = usdtid[msg.sender];
        usdtid[msg.sender] +=1;
        USDT.transfer(msg.sender, _num);
        emit Logs(3,_user,_num ,c);
    }


    



}