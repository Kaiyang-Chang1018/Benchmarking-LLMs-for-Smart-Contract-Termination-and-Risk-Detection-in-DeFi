/*
 *-仅在以太坊主网部署.
 *-任何人都可以使用相同的字节码在其他网络的相同地址上部署DestinyTempleV7,DestinyTempleToken,DestinyToken合约,请谨慎与其交互.
 */
/*=======================================================================================================================
#                                                           ..                                                          #
#                                                           ::                                                          #
#                                                           !!                                                          #
#                                                          .77.                                                         #
#                                                          ~77~                                                         #
#                                                         .7777.                                                        #
#                                                         !7777!                                                        #
#                                                        ^777777^                                                       #
#                                                       ^77777777^                                                      #
#                                                      ^777!~~!777^                                                     #
#                                                     ^7777!::!7777^                                                    #
#                                                   .~77777!  !77777~.                                                  #
#                                                  :!77777!:  :!77777!:                                                 #
#                                                 ~777777!^    ^!777777~                                                #
#                                               :!7777777^      ^7777777!:                                              #
#                                             :!77777777:        :77777777!:                                            #
#                                           :!77777777!.          .!77777777!:                                          #
#                                        .^!77777777!^              ^!77777777!^.                                       #
#                                      :~7777777777^.       ..       .^7777777777~:                                     #
#                                   .^!777777777!^.         ^^         .^!777777777!^.                                  #
#                               .:~!777777777!~:           :77:           :~!777777777!~:.                              #
#                           .:^!7777777777!~:             ^7777^             :~!7777777777!^:.                          #
#                     ..:^~!77777777!!~^:.             .^!777777!^.             .:^~!!77777777!~^:..                    #
#           ...::^^~!!77777777~~^^:..              .:^!777777777777!^:.              ..:^^~~77777777!!~^^::...          #
#           ...::^^~!!77777777~~^^:..              .:^!777777777777!^:.              ..:^^~~77777777!!~^^::...          #
#                     ..:^~!77777777!!~^:.             .^!777777!^.             .:^~!!77777777!~^:..                    #
#                           .:^!7777777777!~:             ^7777^             :~!7777777777!^:.                          #
#                               .:~!777777777!~:           :77:           :~!777777777!~:.                              #
#                                   .^!777777777!^.         ^^         .^!777777777!^.                                  #
#                                      :~7777777777^.       ..       .^7777777777~:                                     #
#                                        .^!77777777!^              ^!77777777!^.                                       #
#                                           :!77777777!.          .!77777777!:                                          #
#                                             :!77777777:        :77777777!:                                            #
#                                               :!7777777^      ^7777777!:                                              #
#                                                 ~777777!^    ^!777777~                                                #
#                                                  :!77777!:  :!77777!:                                                 #
#                                                   .~77777!  !77777~.                                                  #
#                                                     ^7777!::!7777^                                                    #
#                                                      ^777!~~!777^                                                     #
#                                                       ^77777777^                                                      #
#                                                        ^777777^                                                       #
#                                                         !7777!                                                        #
#                                                         .7777.                                                        #
#                                                          ~77~                                                         #
#                                                          .77.                                                         #
#                                                           !!                                                          #
#                                                           ::                                                          #
#                                                           ..                                                          #
#                                                                                                                       #
/*=======================================================================================================================
#                                                                                                                       #
#     ██████╗ ███████╗███████╗████████╗██╗███╗   ██╗██╗   ██╗████████╗███████╗███╗   ███╗██████╗ ██╗     ███████╗       #   
#     ██╔══██╗██╔════╝██╔════╝╚══██╔══╝██║████╗  ██║╚██╗ ██╔╝╚══██╔══╝██╔════╝████╗ ████║██╔══██╗██║     ██╔════╝       #
#     ██║  ██║█████╗  ███████╗   ██║   ██║██╔██╗ ██║ ╚████╔╝    ██║   █████╗  ██╔████╔██║██████╔╝██║     █████╗         #
#     ██║  ██║██╔══╝  ╚════██║   ██║   ██║██║╚██╗██║  ╚██╔╝     ██║   ██╔══╝  ██║╚██╔╝██║██╔═══╝ ██║     ██╔══╝         #
#     ██████╔╝███████╗███████║   ██║   ██║██║ ╚████║   ██║      ██║   ███████╗██║ ╚═╝ ██║██║     ███████╗███████╗       #
#     ╚═════╝ ╚══════╝╚══════╝   ╚═╝   ╚═╝╚═╝  ╚═══╝   ╚═╝      ╚═╝   ╚══════╝╚═╝     ╚═╝╚═╝     ╚══════╝╚══════╝       #
#                                                                                                                       #
=========================================================================================================================
#            __                                 __                               __                                     #
#           /  \ |  o     _  ._ _  o     _.    /  \  _  _  | _|_  _ |  _.       /  \    o _  o                          #
#          | (|/ |< | \/ (_) | | | | \/ (_|   | (|/ _> (_) |  |_ (_ | (_| \/   | (|/ >< | /_ |                          #
#           \__       /              /         \__                        /     \__                                     #
#            __                                  __                                    __                               #
#           /  \  _             _. o ._   _     /  \  _|                    _. ._     /  \  _ o  _  _.  _|  _.          #
#          | (|/ _> |_| \/ |_| (_| | | | (_|   | (|/ (_| |_| \/ |_| >< |_| (_| | |   | (|/ (_ | (_ (_| (_| (_|          #
#           \__         /        |        _|    \__          /                        \__                               #
#            __                             __                    __              __                                    #
#           /  \ o o  _. ._          _     /  \     ._ _   _     /  \     | o    /  \ |_   _. ._    |   _.              #
#          | (|/ | | (_| | | \/ |_| (/_   | (|/ |_| | | | (_)   | (|/ |_| | |   | (|/ | | (_| | |_| |< (_|              #
#           \__ _|           /             \__                   \__             \__                                    #
#                                                                                                                       #
#=======================================================================================================================*/
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);
    
    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);
    
    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);
    
    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);
    
    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
pragma solidity ^0.8.10;

/**
 *  @title -[天命神殿]治理令牌合约.
 *  
 *  @notice -持有令牌可参与[天命神殿]治理.
 *
 *  @author -@Kiyomiya <kiyomiya.eth> <kiyomiya.destinytemple.eth>
 *  @author -@SoltClay <soltclay.destinytemple.eth>
 *  @author -@XiZi <xizi.destinytemple.eth>
 *  @author -@SuYuQing <suyuqing.destinytemple.eth>
 *  @author -@DuYuXuan <duyuxuan.destinytemple.eth>
 *  @author -@Cicada <cicade.destinytemple.eth>
 *  @author -@JianYue <jianyue.destinytemple.eth>
 *  @author -@Umo <umo.destinytemple.eth>
 *  @author -@Uli <uli.destinytemple.eth>
 *  @author -@Haruka <haruka.destinytemple.eth>
 */
contract DestinyTempleToken is IERC20{   
    address private constant MY_DEAR_MOMENTS = 0x2002021020031229201507012018061852013142;
    uint256 constant private MAX_ALLOWANCE = 2**256 - 147777771;
    address private immutable DESTINYTEMPLE;

    uint256 private _totalSupply = 77777777;
    mapping (address => uint256) private  _balances;
    mapping (address => mapping (address => uint256)) private  _allowances;

    modifier onlyDestinyTemple() {
        if(msg.sender != DESTINYTEMPLE) revert("DST: Minter not DestinyTemple");
        _;
    }
    modifier verifyBalance(uint _balance,uint amount){
        if(_balance < amount) revert("DST: transfer amount exceeds balance.");
        _;
    }
    modifier verifyAllowance(address _owner,uint amount){
        if(_owner != msg.sender){
            if(_allowances[_owner][msg.sender] < amount) revert("DST: transfer amount exceeds allowance.");
        }
        _;
        if(_allowances[_owner][msg.sender] < MAX_ALLOWANCE){
            unchecked{ _allowances[_owner][msg.sender] -= amount; }
        }
    }

    /**
     *  @notice -初始令牌分配;设置[DESTINYTEMPLE];设置[MY_DEAR_MOMENTS]和[initialExecutors]对[DESTINYTEMPLE]的授权;
     *
     *  @dev [仅在合约创建时调用一次]
     */
    constructor(address DestinyTemple, address[] memory initialExecutors) payable { 
        DESTINYTEMPLE = DestinyTemple;

        _allowances[MY_DEAR_MOMENTS][DestinyTemple] = MAX_ALLOWANCE;
        emit Approval(MY_DEAR_MOMENTS, DestinyTemple, MAX_ALLOWANCE);
        
        address initialExecutori;
        for(uint i;i<initialExecutors.length;){
            initialExecutori = initialExecutors[i];
            _balances[initialExecutori] = 864200;
            emit Transfer(MY_DEAR_MOMENTS, initialExecutori, 864200);
            _allowances[initialExecutori][DestinyTemple] = MAX_ALLOWANCE;
            emit Approval(initialExecutori, DestinyTemple, MAX_ALLOWANCE);
            unchecked{ ++i; }
        }
        _balances[DESTINYTEMPLE] = 15555538;
        unchecked{ _balances[0x77777DCaEfeaC067f21162cd2F48E5b5dB0A2B97] += 54444439; }
        emit Transfer(MY_DEAR_MOMENTS, DESTINYTEMPLE, 15555538);
        emit Transfer(MY_DEAR_MOMENTS, 0x77777DCaEfeaC067f21162cd2F48E5b5dB0A2B97, 54444439);
    }

    /**
     *  @notice -从[msg.sender]转移[amount]枚[命运神殿令牌]至[to].
     *
     *  @dev [允许任何人调用] -[msg.sender]需要有足够的余额.
     *  @param to -接收地址.
     *  @param amount -数量.
     */
    function transfer(address to, uint256 amount) external verifyBalance(_balances[msg.sender],amount) returns (bool) {
        unchecked{
            _balances[msg.sender] -= amount;
            _balances[to] += amount;
        }
        
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    /**
     *  @notice -从[from]转移[amount]枚[命运神殿令牌]至[to].
     *
     *  @dev [允许任何人调用] -[from]需要有足够余额并且授予[msg.sender]足够的控制数量或其就是[msg.sender].
     *  @param from -发送地址.
     *  @param to -接收地址.
     *  @param amount -数量.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) 
        external
        verifyBalance(_balances[from],amount)
        verifyAllowance(from,amount)
        returns (bool)
    {                
        unchecked{
            _balances[from] -= amount;
            _balances[to] += amount;
        }
        emit Transfer(from, to, amount);
        return true;
    }

    /**
     *  @notice -授予[sender]控制您[amount]枚[命运神殿令牌]的权利.
     *
     *  @dev [允许任何人调用] -警告!请勿授权给不信任的地址,否则其将可以无需再次许可地转移您的[命运神殿令牌].
     *  @param sender -将被授权的地址.
     *  @param amount -数量.
     */
    function approve(address sender, uint256 amount) external returns (bool) {
        _allowances[msg.sender][sender] = amount;
        emit Approval(msg.sender, sender, amount);
        return true;
    }

    /**
     *  @notice -将[_owner]对[msg.sender]的授权[转让][amount]数量给[receiver].
     *
     *  @dev -[允许任何人调用] -[_owner]需要授予[msg.sender]足够的控制数量.
     *       为防止钓鱼利用,禁止使用此方法设置自身对[receiver]的授权.
     *  @param _owner -授权给[msg.sender]的所有者.
     *  @param receiver -接受转让授权地址.
     *  @param amount -数量.
     */
    function transferAllowance(address _owner,address receiver, uint256 amount) external verifyAllowance(_owner,amount) returns (bool) {
        if(_owner == msg.sender) revert("DST: Please use approve().");
        _allowances[_owner][receiver] += amount;
        emit Approval(_owner, receiver, _allowances[_owner][receiver]);
        return true;
    }

    /**
     *  @notice -铸造[amount]枚[命运神殿令牌]至[to].
     *
     *  @dev [仅允许通过DESTINYTEMPLE销毁[命运执行者]令牌来调用铸造]
     *  @param to -铸造令牌接收地址.
     *  @param amount -数量.
     */
    function mint(address to, uint amount) external onlyDestinyTemple returns (bool) {
        unchecked{
            _totalSupply += amount;
            _balances[to] += amount;
        }
        emit Transfer(MY_DEAR_MOMENTS, to, amount);
        return true;
    }
    
    /**
     *  @notice -从[from]销毁[amount]枚[命运神殿令牌].
     *
     *  @dev [允许任何人调用] -[from]需要有足够余额并且授予[msg.sender]足够的控制数量或其就是[msg.sender].
     *  @param from -将被销毁的地址.
     *  @param amount -数量.
     */
    function burnFrom(address from, uint amount)
        external
        verifyBalance(_balances[from], amount)
        verifyAllowance(from,amount)
        returns (bool)
    {
        unchecked{
            _balances[from] -= amount;
            _totalSupply -= amount;
        }
        emit Transfer(from, MY_DEAR_MOMENTS, amount);
        return true;
    }
    
    function owner() external pure returns (address) {
        return address(0);
    }

    function name() external pure returns (string memory) {
        return "DestinyTemple";
    }
    function symbol() external pure returns (string memory) {
        return "DST";
    }
    function decimals() external pure returns (uint) {
        return 0;
    }
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address _owner) external view returns (uint256) {
        return _balances[_owner];
    }
    function allowance(address _owner, address _spender) external view returns (uint256) {
        return _allowances[_owner][_spender];
    }

}
/*=======================================================================================================================
#            __                                 __                               __                                     #
#           /  \ |  o     _  ._ _  o     _.    /  \  _  _  | _|_  _ |  _.       /  \    o _  o                          #
#          | (|/ |< | \/ (_) | | | | \/ (_|   | (|/ _> (_) |  |_ (_ | (_| \/   | (|/ >< | /_ |                          #
#           \__       /              /         \__                        /     \__                                     #
#            __                                  __                                    __                               #
#           /  \  _             _. o ._   _     /  \  _|                    _. ._     /  \  _ o  _  _.  _|  _.          #
#          | (|/ _> |_| \/ |_| (_| | | | (_|   | (|/ (_| |_| \/ |_| >< |_| (_| | |   | (|/ (_ | (_ (_| (_| (_|          #
#           \__         /        |        _|    \__          /                        \__                               #
#            __                             __                    __              __                                    #
#           /  \ o o  _. ._          _     /  \     ._ _   _     /  \     | o    /  \ |_   _. ._    |   _.              #
#          | (|/ | | (_| | | \/ |_| (/_   | (|/ |_| | | | (_)   | (|/ |_| | |   | (|/ | | (_| | |_| |< (_|              #
#           \__ _|           /             \__                   \__             \__                                    #
#                                                                                                                       #
/*======================================================================================================================*
#                                                                                                                       #
#     ██████╗ ███████╗███████╗████████╗██╗███╗   ██╗██╗   ██╗████████╗███████╗███╗   ███╗██████╗ ██╗     ███████╗       #
#     ██╔══██╗██╔════╝██╔════╝╚══██╔══╝██║████╗  ██║╚██╗ ██╔╝╚══██╔══╝██╔════╝████╗ ████║██╔══██╗██║     ██╔════╝       #
#     ██║  ██║█████╗  ███████╗   ██║   ██║██╔██╗ ██║ ╚████╔╝    ██║   █████╗  ██╔████╔██║██████╔╝██║     █████╗         #
#     ██║  ██║██╔══╝  ╚════██║   ██║   ██║██║╚██╗██║  ╚██╔╝     ██║   ██╔══╝  ██║╚██╔╝██║██╔═══╝ ██║     ██╔══╝         #
#     ██████╔╝███████╗███████║   ██║   ██║██║ ╚████║   ██║      ██║   ███████╗██║ ╚═╝ ██║██║     ███████╗███████╗       #
#     ╚═════╝ ╚══════╝╚══════╝   ╚═╝   ╚═╝╚═╝  ╚═══╝   ╚═╝      ╚═╝   ╚══════╝╚═╝     ╚═╝╚═╝     ╚══════╝╚══════╝       #
#                                                                                                                       #
*=======================================================================================================================*
#                                                           ..                                                          #
#                                                           ::                                                          #
#                                                           !!                                                          #
#                                                          .77.                                                         #
#                                                          ~77~                                                         #
#                                                         .7777.                                                        #
#                                                         !7777!                                                        #
#                                                        ^777777^                                                       #
#                                                       ^77777777^                                                      #
#                                                      ^777!~~!777^                                                     #
#                                                     ^7777!::!7777^                                                    #
#                                                   .~77777!  !77777~.                                                  #
#                                                  :!77777!:  :!77777!:                                                 #
#                                                 ~777777!^    ^!777777~                                                #
#                                               :!7777777^      ^7777777!:                                              #
#                                             :!77777777:        :77777777!:                                            #
#                                           :!77777777!.          .!77777777!:                                          #
#                                        .^!77777777!^              ^!77777777!^.                                       #
#                                      :~7777777777^.       ..       .^7777777777~:                                     #
#                                   .^!777777777!^.         ^^         .^!777777777!^.                                  #
#                               .:~!777777777!~:           :77:           :~!777777777!~:.                              #
#                           .:^!7777777777!~:             ^7777^             :~!7777777777!^:.                          #
#                     ..:^~!77777777!!~^:.             .^!777777!^.             .:^~!!77777777!~^:..                    #
#           ...::^^~!!77777777~~^^:..              .:^!777777777777!^:.              ..:^^~~77777777!!~^^::...          #
#           ...::^^~!!77777777~~^^:..              .:^!777777777777!^:.              ..:^^~~77777777!!~^^::...          #
#                     ..:^~!77777777!!~^:.             .^!777777!^.             .:^~!!77777777!~^:..                    #
#                           .:^!7777777777!~:             ^7777^             :~!7777777777!^:.                          #
#                               .:~!777777777!~:           :77:           :~!777777777!~:.                              #
#                                   .^!777777777!^.         ^^         .^!777777777!^.                                  #
#                                      :~7777777777^.       ..       .^7777777777~:                                     #
#                                        .^!77777777!^              ^!77777777!^.                                       #
#                                           :!77777777!.          .!77777777!:                                          #
#                                             :!77777777:        :77777777!:                                            #
#                                               :!7777777^      ^7777777!:                                              #
#                                                 ~777777!^    ^!777777~                                                #
#                                                  :!77777!:  :!77777!:                                                 #
#                                                   .~77777!  !77777~.                                                  #
#                                                     ^7777!::!7777^                                                    #
#                                                      ^777!~~!777^                                                     #
#                                                       ^77777777^                                                      #
#                                                        ^777777^                                                       #
#                                                         !7777!                                                        #
#                                                         .7777.                                                        #
#                                                          ~77~                                                         #
#                                                          .77.                                                         #
#                                                           !!                                                          #
#                                                           ::                                                          #
#                                                           ..                                                          #
#                                                                                                                       #
========================================================================================================================*/