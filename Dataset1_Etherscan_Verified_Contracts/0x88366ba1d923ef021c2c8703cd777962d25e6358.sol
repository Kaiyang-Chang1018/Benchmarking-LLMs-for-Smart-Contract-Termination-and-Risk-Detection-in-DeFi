// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DenizToken {
    string public name = "DenizToken";
    string public symbol = "DNZ";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    address public feeRecipient; // عنوان المحفظة التي تستلم العمولة
    uint256 public feePercentage = 2; // نسبة العمولة (2%)

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // المُنشئ: يحدد العنوان الذي يستلم العمولة عند نشر العقد
    constructor(address _feeRecipient) {
        require(_feeRecipient != address(0), "Fee recipient cannot be zero address");
        totalSupply = 200000000 * (10 ** uint256(decimals)); // 200 مليون
        balanceOf[msg.sender] = totalSupply; // تخصيص جميع التوكنات لصاحب العقد
        feeRecipient = _feeRecipient; // تعيين المحفظة التي تستقبل العمولة
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        uint256 fee = (_value * feePercentage) / 100; // حساب العمولة (2%)
        uint256 amountToTransfer = _value - fee; // المبلغ الفعلي بعد خصم العمولة

        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += amountToTransfer;
        balanceOf[feeRecipient] += fee; // إرسال العمولة إلى المحفظة المحددة

        emit Transfer(msg.sender, _to, amountToTransfer);
        emit Transfer(msg.sender, feeRecipient, fee); // تسجيل العمولة كمعاملة
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 fee = (_value * feePercentage) / 100; // حساب العمولة (2%)
        uint256 amountToTransfer = _value - fee;

        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");

        balanceOf[_from] -= _value;
        balanceOf[_to] += amountToTransfer;
        balanceOf[feeRecipient] += fee; // إرسال العمولة إلى المحفظة المحددة
        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, amountToTransfer);
        emit Transfer(_from, feeRecipient, fee); // تسجيل العمولة كمعاملة
        return true;
    }

    // تعديل مستلم العمولة
    function setFeeRecipient(address _feeRecipient) public {
        require(msg.sender == feeRecipient, "Only current fee recipient can set a new one");
        require(_feeRecipient != address(0), "Fee recipient cannot be zero address");
        feeRecipient = _feeRecipient;
    }

    // تعديل نسبة العمولة
    function setFeePercentage(uint256 _feePercentage) public {
        require(msg.sender == feeRecipient, "Only fee recipient can set fee percentage");
        require(_feePercentage <= 10, "Fee percentage cannot exceed 10%");
        feePercentage = _feePercentage;
    }
}