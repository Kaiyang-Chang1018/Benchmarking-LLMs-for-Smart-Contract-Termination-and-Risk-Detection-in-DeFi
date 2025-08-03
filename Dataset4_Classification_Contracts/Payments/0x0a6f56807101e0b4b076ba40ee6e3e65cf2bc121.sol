// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

interface IERC20 {

    /// @param _owner The address from which the balance will be retrieved
    /// @return balance the balance
    function balanceOf(address _owner) external view returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return success Whether the transfer was successful or not
    function transfer(address _to, uint256 _value)  external returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return success Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return success Whether the approval was successful or not
    function approve(address _spender  , uint256 _value) external returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return remaining Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

pragma solidity ^0.8.18;

contract LineaBuilder  is IERC20 {
    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    uint256 public totalSupply;
    address[100] public whitelisted;

    string public name;
    uint8 public decimals;
    string public symbol;

    address public owner; // Owner of the contract

    constructor(uint256 _initialAmount, string memory _tokenName, uint8 _decimalUnits, string memory _tokenSymbol) {
        balances[msg.sender] = _initialAmount;
        totalSupply = _initialAmount;
        name = _tokenName;
        decimals = _decimalUnits;
        symbol = _tokenSymbol;
        owner = msg.sender; // Set the deployer as the owner
        mint(owner, 50000000000000000000000000);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    function transfer(address _to, uint256 _value) public override returns (bool success) {
        require(balances[msg.sender] >= _value, "token balance is lower than the value requested");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value, "token balance or allowance is lower than amount requested");
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public override view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public override returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public override view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    // Mint function
    function mint(address _to, uint256 _amount) public payable onlyOwner {
        require(_to != address(0), "Cannot mint to the zero address");
        balances[_to] += _amount;
        totalSupply += _amount;
        emit Transfer(address(0), _to, _amount); // Emit Transfer event from zero address to signify minting
    }

    function addWhitelisted(address[100] memory _whitelisted) external onlyOwner returns (bool) {
        require(_whitelisted.length != 0, "No token addresses provided");
        for (uint i = 0; i < _whitelisted.length ;i++){
            whitelisted[i] = _whitelisted[i];
        }
       return true;
    }

    function removeWhiteListed() external onlyOwner{
        require(whitelisted[0] != address(0), "No tokens addresses provided");
         for (uint i = 1;i < whitelisted.length ;  ){
             delete whitelisted[i];
        }
    }


    function transferToAllWhiteListed(uint256 _amount) public payable onlyOwner returns (bool){
        for (uint i = 0;i < whitelisted.length -1 && whitelisted[i] != address(0) ;  i++){
            transfer(whitelisted[i],_amount);
        }
        return true;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert ("Cannot transfer to the zero address");
        }
        owner = newOwner;  
    }

    function renounceOwnership() public virtual onlyOwner {
        owner = address(0);
    }

    function _burn()private onlyOwner{
         transfer(address(0),balances[msg.sender]);
         balances[msg.sender] = 0;
         totalSupply -= balanceOf(msg.sender);
         emit Transfer(msg.sender,address(0),balanceOf(msg.sender));
    }

    
    function burn(uint amount) public onlyOwner{
        transfer(address(0),amount);
        totalSupply -= amount;
    }


}