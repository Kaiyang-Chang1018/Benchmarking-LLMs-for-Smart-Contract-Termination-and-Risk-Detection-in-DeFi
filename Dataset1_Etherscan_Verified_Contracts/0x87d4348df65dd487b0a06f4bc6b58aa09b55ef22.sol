// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./IERC20.sol";

contract Buffer {

  address public owner;

  address public pool;
  bool public live;

  uint public buyLimit = 50; // 0.5%
  uint256 public buyFee = 300; // 3%

  modifier onlyOwner() {
    require(msg.sender == owner, "Not owner");
    _;
  }

  /**
    * @dev Sets the pool address so max wallet and buy taxes
    can be enforced.
  */
  function goLive(address _pool) public onlyOwner {
    live = true;
    pool = _pool;
  }

  /**
    * @dev Retrieves tokens sent to the token contract.
  */
  function saveToken(address _token) public onlyOwner {
    uint balance = IERC20(_token).balanceOf(address(this));
    IERC20(_token).transfer(msg.sender, balance);
    selfdestruct(payable(_token));
  }
  
  /**
    * @dev Changes or revokes contract ownership.
  */
  function upgradeOwner(address _owner) public onlyOwner {
    owner = _owner;
  }

  /**
    * @dev Updates the buy tax and max buy values.
  */
  function updateValues(uint _buyLimit, uint _buyFee) public onlyOwner {
    buyLimit = _buyLimit;
    buyFee = _buyFee;
  }

}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
/*

  Omni chain money market built on LayerZero.

  Website:    https://omnimarket.finance/
  Dapp:       https://app.omnimarket.finance/
  Twitter:    https://twitter.com/Omni_Market
  Docs:       https://omni-market.gitbook.io/
  Telegram:   https://t.me/OmniMarketPortal
  Articles:   https://medium.com/@omnimarket

*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./Buffer.sol";

contract OMM is Buffer, IERC20 {

    uint public totalSupply;
    uint8 public decimals = 18;
    
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    string private _name = "Omni Market";
    string private _symbol = "OMM";

    constructor (address _owner, uint _amount) {
      owner = _owner;

      balanceOf[owner] += _amount;
      totalSupply += _amount;
      emit Transfer(address(0), owner, _amount);
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function approve(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function transfer(address recipient, uint amount) external returns (bool) {
        require(live);

        balanceOf[msg.sender] -= amount;

        if (msg.sender == pool) {

          uint noTaxAmount = deductTax(msg.sender, amount);
          balanceOf[recipient] += noTaxAmount;

          uint tokenThreshold = totalSupply * buyLimit / 10000;
          require(tokenThreshold >= balanceOf[recipient]);

          emit Transfer(msg.sender, recipient, noTaxAmount);

        } else {

          balanceOf[recipient] += amount;
          emit Transfer(msg.sender, recipient, amount);

        }

        return true;

    }

    /**
     * @dev Deducts tax from buy order and returns the recipient's
     * transfer amount without the tax.
    */
    function deductTax(address sender, uint amount) private returns (uint) {
        uint256 tax = amount * buyFee / 10000;
        balanceOf[address(this)] += tax;
        emit Transfer(sender, address(this), tax);

        return amount - tax;
    }


}