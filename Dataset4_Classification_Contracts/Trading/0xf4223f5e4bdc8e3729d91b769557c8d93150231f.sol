// SPDX-License-Identifier: MIT
// Tells the Solidity compiler to compile only from v0.8.13 to v0.9.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import './SharedStructs.sol';
import '../libraries/Utils.sol';

contract AccessControl {    

    address public owner;
    address public auditor;
    address public settlementContract;

    bool public definedContract = false;

    mapping(address => bool) private custodianAddresses; 
    mapping(address => uint8) private custodianCategory; // 1 - Big custodians  2 - Individuals
    mapping(address => bool) private allowableTokens;
    

    event CustodianAdded(address custodianAddress, uint8 custodianCategory);

    constructor(address _auditorAddress, address _wethAddress){
        checkZeroAddress(_auditorAddress);
        auditor = _auditorAddress;
        allowableTokens[_wethAddress] = true;
        owner = msg.sender;
    }

    function onlyOwner (address sentAddress) private view {
        require(sentAddress == owner, "Not contract owner");
        return;
    }

    function checkZeroAddress(address _address) internal pure {
        require (_address != address(0), "Invalid address");
    }

    function onlySettlementAndAuditor(address settlementContractOrAuditorAddress) private view {
        require((settlementContractOrAuditorAddress == auditor) || (settlementContractOrAuditorAddress == settlementContract), "No permission to release");
        return;
    }

     function onlySettlement(address settlementContractOrAuditorAddress) private view {
        require((settlementContractOrAuditorAddress == settlementContract), "No permission to lock");
        return;
    }
    

    function onlyAllowed (address sentAddress) external view {
        require(custodianAddresses[sentAddress] == true || sentAddress == auditor, "Custodian Not allowed");
        return;
    }

    function onlyAllowedToken(address tokenAddress) external view {
        require(allowableTokens[tokenAddress] == true, "Token not allowed");
        return;
    }

    function isAuditor(address auditorAddress) external view returns (bool) {
        require(auditor == auditorAddress, "Address is not the auditor");
        return true;
    }

    function setMultipleCustodiansAllowable(address[] calldata newCustodianAddresses, uint8[] calldata custodianCategories) external {
        require(newCustodianAddresses.length == custodianCategories.length);
        onlyOwner(msg.sender);
        for (uint8 i = 0; i< newCustodianAddresses.length; i++){
            setCustodianAllowable(newCustodianAddresses[i], custodianCategories[i]);
        }
    }

    function setCustodianAllowable(address custodianAddress, uint8 custodianCategoryValue) public {
        onlyOwner(msg.sender);
        checkZeroAddress(custodianAddress);
        require(custodianAddresses[custodianAddress] == false, "custodian already added");
        require(custodianCategoryValue == 1 || custodianCategoryValue == 2, "invalid custodian category");
        custodianAddresses[custodianAddress] = true;
        custodianCategory[custodianAddress] = custodianCategoryValue;
        emit CustodianAdded(custodianAddress, custodianCategoryValue);
    }

    function getCustodianAllowable(address custodianAddress) external view returns (bool, uint8) {
        return (custodianAddresses[custodianAddress], custodianCategory[custodianAddress]);
    }

    function isVirtualCustodian(address custodianAddress) external view returns (bool) {
        return 2 == custodianCategory[custodianAddress];
    }
    function isBrickAndMortar(address custodianAddress) external view returns (bool){
        return 1 == custodianCategory[custodianAddress];
    }

    function validateSettlement(address creditor, address debtor) external view {
        require ((custodianAddresses[creditor] && custodianAddresses[debtor]), "Invalid creditor/debtor");    
    }  

    function setTokenAllowable(address tokenAddress) external {
        onlyOwner(msg.sender);
        allowableTokens[tokenAddress] = true;
    }

    function removeTokenAllowable(address tokenAddress) external {
        onlyOwner(msg.sender);
        allowableTokens[tokenAddress] = false;
    }

    function getTokenAllowable(address tokenAddress) public view returns (bool) {
        return allowableTokens[tokenAddress];
    }

    function changeOwnership(address ownerAddress) external {
        onlyOwner(msg.sender);
        checkZeroAddress(ownerAddress);
        owner = ownerAddress;
    }

    function addSettlementContractAddress(address settlementAddress) public {
        onlyOwner(msg.sender);
        require (definedContract == false, "Cannot redefine linked settlement contract");
        checkZeroAddress(settlementAddress);
        settlementContract = settlementAddress;
        definedContract = true;
    }
}
// SPDX-License-Identifier: MIT
// Tells the Solidity compiler to compile only from v0.8.13 to v0.9.0
pragma solidity ^0.8.0;

import "./AccessControl.sol";
import "./Settlement.sol";
/* 1 for custodian 
2 for token 
3 for deletion of settlement 
4 release funds
5 quorum changes
6 signer changes
*/
contract Multisig {

    address[] public owners;
    mapping (address => bool) public isOwner;
    uint256 public requiredSignatures;
    uint public timelock;
    AccessControl accessControl;
    Settlement settlement;
    uint constant AVERAGE_BLOCK_PER_DAY = 7200;
    uint256 STALE_TRANSACTION_BLOCKS;

    event Approved(uint transactionId, uint8 operation);
    event Revoked(uint transactionId, uint8 operation);
    event Executed(uint transactionId, uint8 operation);
    event NewTransaction(uint transactionId, uint8 operation, bool add);

    struct Custodian {
        address[] newCustodianAddress;
        uint8[] custodianCategories;
        uint256 unlockTimestamp;
        uint256 staleTimestamp;
        bool executed;
        bool add; // true to add false to remove
    }

    struct Token {
        address newTokenAddress;
        uint256 unlockTimestamp;
        uint256 staleTimestamp;
        bool executed;
        bool add; // true to add false to remove
    }

    struct SettlementTransaction {
        uint settlementUUID;
        uint256 unlockTimestamp;
        uint256 staleTimestamp;
        bool executed;
    }

    struct ReleaseFunds {
        address custodianAddress;
        address[] tokenAddresses;
        uint256 unlockTimestamp;
        uint256 staleTimestamp;
        bool executed;
    }

    struct QuorumTreshold{
        bool add;
        uint256 unlockTimestamp;
        uint256 staleTimestamp;
        bool executed;
    }

    struct Signers {
        address signer;
        bool add;
        uint256 unlockTimestamp;
        uint256 staleTimestamp;
        bool executed;
    }

    Custodian[] public CustodianTransactions;    
    Token[] public TokenTransactions;
    SettlementTransaction[] public SettlementTransactions;
    ReleaseFunds[] public ReleaseFundsTransactions;
    QuorumTreshold[] public QuorumTresholdTransactions;
    Signers[] public SignersTransactions;

    mapping(uint => mapping(uint => mapping(address => bool))) public approved;

    modifier onlyOwner(){
        require(isOwner[msg.sender], "not owner");
        _;
    }

    modifier txValid(uint _transactionId, uint8 _operation){
        bool valid = false;
        if (_operation == 1){
            valid = _transactionId < CustodianTransactions.length;
        }
        if (_operation == 2){
            valid =_transactionId < TokenTransactions.length;
        }
        if (_operation == 3){
           valid =_transactionId < SettlementTransactions.length;
        }
        if (_operation == 4){
           valid =_transactionId < ReleaseFundsTransactions.length;
        }
        if (_operation == 5){
           valid =_transactionId < QuorumTresholdTransactions.length;
        }
        if (_operation == 6){
           valid =_transactionId < SignersTransactions.length;
        }
        require(valid, "invalid tx id");
        _;
    }

    function _getTransactionTimestamps(uint _transactionId, uint8 _operationType)private view returns (uint256 unlockTimestamp, uint256 staleTimestamp){
        if (_operationType == 1){
            Custodian storage custodian = CustodianTransactions[_transactionId];
            return (custodian.unlockTimestamp, custodian.staleTimestamp);
        }
        if (_operationType == 2){
            Token storage token = TokenTransactions[_transactionId];
            return (token.unlockTimestamp, token.staleTimestamp);
        }
        if (_operationType == 3){
            SettlementTransaction storage settlementTransaction = SettlementTransactions[_transactionId];
            return (settlementTransaction.unlockTimestamp, settlementTransaction.staleTimestamp);
        }
        if (_operationType == 4 ){
            ReleaseFunds storage releaseFunds = ReleaseFundsTransactions[_transactionId];
            return (releaseFunds.unlockTimestamp, releaseFunds.staleTimestamp);
        }
        if (_operationType == 5 ){
            QuorumTreshold storage quorumTreshold = QuorumTresholdTransactions[_transactionId];
            return (quorumTreshold.unlockTimestamp, quorumTreshold.staleTimestamp);
        }
        if (_operationType == 6 ){
            Signers storage signers = SignersTransactions[_transactionId];
            return (signers.unlockTimestamp, signers.staleTimestamp);
        }
        require(1==0, "wrong data");
    }

    modifier txNotExecuted(uint _transactionId, uint8 _operation){
        bool valid = false;
        if (_operation == 1){
            valid = CustodianTransactions[_transactionId].executed == false;
        }
        if (_operation == 2){
            valid = TokenTransactions[_transactionId].executed == false;
        }
        if (_operation == 3){
            valid = SettlementTransactions[_transactionId].executed == false;
        }
        if (_operation == 4){
            valid = ReleaseFundsTransactions[_transactionId].executed == false;
        }
        if (_operation == 5){
            valid = QuorumTresholdTransactions[_transactionId].executed == false;
        }
        if (_operation == 6){
            valid = SignersTransactions[_transactionId].executed == false;
        }
        require(valid, "tx already executed");
        _;
    }

    function getOwners() public view returns(address[] memory _owners){
        return (owners);
    }

    function _getTimestamp(uint8 multipler) private view returns (uint timestamp){
        return block.number + multipler*timelock;
    }

    function _checkTimelocks(uint proposedUnlockTime, uint256 _staleTimelock) private view { 
        require (proposedUnlockTime < block.number, "timelock not met");
        require (_staleTimelock > block.number, "transaction staled");
    }

    constructor(address[] memory _owners, uint _requiredSignatures, address _accessControlAddress, address _settlementAddress,
        uint _timelockInDays, uint _staleTransactionInDays)
    {
        require(_owners.length > 0, "not valid owners");
        require(_requiredSignatures > 0 && _requiredSignatures <= _owners.length, "invalid data");
        require(_timelockInDays > 0, "invalid timelock");
        _checkZeroAddress(_accessControlAddress);
        accessControl = AccessControl(_accessControlAddress);
        settlement = Settlement(payable(_settlementAddress));

        for (uint i=0; i< _owners.length; i++){
            _checkZeroAddress(_owners[i]);
            require(!isOwner[_owners[i]], "owner not unique");
            isOwner[_owners[i]] = true;
            owners.push(_owners[i]);
        }

        timelock = AVERAGE_BLOCK_PER_DAY* _timelockInDays;
        STALE_TRANSACTION_BLOCKS = AVERAGE_BLOCK_PER_DAY * _staleTransactionInDays; //transaction goes stale after defined days
        requiredSignatures = _requiredSignatures;
    }

    function submitCustodiansAllowable(address[] calldata _newCustodianAddresses, uint8[] calldata _custodianCategories) public onlyOwner {
        CustodianTransactions.push(Custodian({
            newCustodianAddress: _newCustodianAddresses,
            custodianCategories: _custodianCategories,
            unlockTimestamp: 0,
            staleTimestamp: block.number + STALE_TRANSACTION_BLOCKS,
            executed: false,
            add: true
        }));
        emit NewTransaction(CustodianTransactions.length -1, 1, true);
    }

    function submitTokenAllowed(address _newTokenAddress) public onlyOwner {
        TokenTransactions.push(Token({
            newTokenAddress: _newTokenAddress,
            unlockTimestamp: 0,
            staleTimestamp: block.number + STALE_TRANSACTION_BLOCKS,
            executed: false,
            add: true
        }));
        emit NewTransaction(TokenTransactions.length -1, 2, true);
    }

    function submitTokenRemoved(address _newTokenAddress) public onlyOwner {
        TokenTransactions.push(Token({
            newTokenAddress: _newTokenAddress,
            unlockTimestamp: 0,
            staleTimestamp: block.number + STALE_TRANSACTION_BLOCKS,
            executed: false,
            add: false
        }));
        emit NewTransaction(TokenTransactions.length -1, 2, false);
    }

    function submitSettlementDeletion(uint _settlementUUID) public onlyOwner {
        SettlementTransactions.push(SettlementTransaction({
            settlementUUID: _settlementUUID,
            unlockTimestamp: 0,
            staleTimestamp: block.number + STALE_TRANSACTION_BLOCKS,
            executed: false
        }));
        emit NewTransaction(SettlementTransactions.length -1, 3, true);
    }

    function submitReleaseFunds(address _custodianAddress, address[] memory _tokenAddresses) public onlyOwner{
        _checkZeroAddress(_custodianAddress);
        ReleaseFundsTransactions.push(ReleaseFunds({
            custodianAddress: _custodianAddress,
            unlockTimestamp: 0,
            staleTimestamp: block.number + STALE_TRANSACTION_BLOCKS,
            tokenAddresses: _tokenAddresses,
            executed: false
        }));
        emit NewTransaction(ReleaseFundsTransactions.length -1, 4, true);
    }

    function submitChangeQuorum(bool _add) public onlyOwner{
        QuorumTresholdTransactions.push(QuorumTreshold({
            add:_add,
            unlockTimestamp: 0,
            staleTimestamp: block.number + STALE_TRANSACTION_BLOCKS,
            executed: false
        }));
        emit NewTransaction(QuorumTresholdTransactions.length -1, 5, true);
    }

    function submitSigner(address _signerAddress, bool _add) public onlyOwner{
        _checkZeroAddress(_signerAddress);
        SignersTransactions.push(Signers({
            signer: _signerAddress,
            add:_add,
            unlockTimestamp: 0,
            staleTimestamp: block.number + STALE_TRANSACTION_BLOCKS,
            executed: false
        }));
        emit NewTransaction(SignersTransactions.length -1, 6, true);
    }


    function approveTransaction(uint _transactionId, uint8 _operationType) public 
        onlyOwner() 
        txValid(_transactionId, _operationType)
        txNotExecuted(_transactionId, _operationType) { // 1 for custodian 2 for token 3 for deletion of settlement
        require (!approved[_transactionId][_operationType][msg.sender], "tx already approved");
        (uint256 unlockTimestamp, uint256 staleTimestamp)  = _getTransactionTimestamps(_transactionId, _operationType);
        require(block.number < staleTimestamp, "tx is stale");
        approved[_transactionId][_operationType][msg.sender] = true;
        if(unlockTimestamp == 0 && _getApprovalCount(_transactionId, _operationType) >= requiredSignatures){
            updateTimeLock(_transactionId, _operationType);
        }
        emit Approved(_transactionId, _operationType);
    }

    function updateTimeLock(uint _transactionId, uint8 _operationType) private {
        if (_operationType == 1){
            Custodian storage custodian = CustodianTransactions[_transactionId];
            custodian.unlockTimestamp = block.number + AVERAGE_BLOCK_PER_DAY;
        }
        if (_operationType == 2){
            Token storage token = TokenTransactions[_transactionId];
            token.unlockTimestamp = _getTimestamp(1);
        }
        if (_operationType == 3){
            SettlementTransaction storage settlementTransaction = SettlementTransactions[_transactionId];
            settlementTransaction.unlockTimestamp = _getTimestamp(1);
        }
        if (_operationType == 4 ){
            ReleaseFunds storage releaseFunds = ReleaseFundsTransactions[_transactionId];
            releaseFunds.unlockTimestamp = _getTimestamp(1); 
        }
        if (_operationType == 5 ){
            QuorumTreshold storage quorumTreshold = QuorumTresholdTransactions[_transactionId];
            quorumTreshold.unlockTimestamp = _getTimestamp(2);
        }
        if (_operationType == 6 ){
            Signers storage signers = SignersTransactions[_transactionId];
            signers.unlockTimestamp = _getTimestamp(2);
        }
    }

    function revokeTransaction(uint _transactionId, uint8 _operationType) public 
        onlyOwner() 
        txValid(_transactionId, _operationType)
        txNotExecuted(_transactionId, _operationType) { 
        require (approved[_transactionId][_operationType][msg.sender], "tx not approved");
        approved[_transactionId][_operationType][msg.sender] = false;
        emit Revoked(_transactionId, _operationType);
    }

    function executeTransaction(uint _transactionId, uint8 _operationType) external
    onlyOwner()
    txValid(_transactionId, _operationType)
    txNotExecuted(_transactionId, _operationType) {
        require(_getApprovalCount(_transactionId, _operationType) >= requiredSignatures, "not enough approvals");
        if (_operationType == 1){
            Custodian storage custodian = CustodianTransactions[_transactionId];
            _checkTimelocks(custodian.unlockTimestamp, custodian.staleTimestamp);
            custodian.executed = true;
            accessControl.setMultipleCustodiansAllowable(custodian.newCustodianAddress, custodian.custodianCategories);
        }
        if (_operationType == 2){
            Token storage token = TokenTransactions[_transactionId];
            _checkTimelocks(token.unlockTimestamp, token.staleTimestamp);
            token.executed = true;
            if (token.add) {
                accessControl.setTokenAllowable(token.newTokenAddress);
            } else {
                accessControl.removeTokenAllowable(token.newTokenAddress);
            }
        }
        if (_operationType == 3){
            SettlementTransaction storage settlementTransaction = SettlementTransactions[_transactionId];
            _checkTimelocks(settlementTransaction.unlockTimestamp, settlementTransaction.staleTimestamp);
            settlementTransaction.executed = true;
            settlement.deleteSettlement(settlementTransaction.settlementUUID);
        }
        if (_operationType == 4 ){
            ReleaseFunds storage releaseFunds = ReleaseFundsTransactions[_transactionId];
            _checkTimelocks(releaseFunds.unlockTimestamp, releaseFunds.staleTimestamp);
            releaseFunds.executed = true;
            settlement.releaseFunds(releaseFunds.custodianAddress, releaseFunds.tokenAddresses);
        }
        if (_operationType == 5 ){
            QuorumTreshold storage quorumTreshold = QuorumTresholdTransactions[_transactionId];
            _checkTimelocks(quorumTreshold.unlockTimestamp, quorumTreshold.staleTimestamp);
            quorumTreshold.executed = true;
            if(quorumTreshold.add) {
                require(owners.length > requiredSignatures, "cannot add more than signers");
                requiredSignatures++;
            }
            else {
                require(requiredSignatures > 1, "quorum need to be higher than 1");
                requiredSignatures--;
            }
        }
        if (_operationType == 6 ){
            Signers storage signers = SignersTransactions[_transactionId];
            _checkTimelocks(signers.unlockTimestamp, signers.staleTimestamp);
            signers.executed = true;
            if(signers.add) {
                require(isOwner[signers.signer] == false, "already a signer");
                owners.push(signers.signer);
                isOwner[signers.signer] = true;
            } else {
                require(isOwner[signers.signer] == true, " not a signer");
                require(owners.length > requiredSignatures, "fewer signers than quorum");
                uint deleteIndex = 0;
                for (uint index = 0; index<owners.length; index++) {
                    if (owners[index] == signers.signer){
                        deleteIndex = index;
                    }
                }
                _deleteOwner(deleteIndex);
                isOwner[signers.signer] = false;
            }
        }
        emit Executed(_transactionId, _operationType);
    }

    function _deleteOwner(uint _index) private {
        for (uint i = _index; i< owners.length -1; i++){
            owners[i] = owners[i+1];
        }
        owners.pop();
    }

    function _getApprovalCount(uint _transactionId, uint8 _operation) private view returns (uint count){
        for (uint i = 0; i < owners.length; i++) {
            if (approved[_transactionId][_operation][owners[i]]){
                count += 1;
            }
        }
        return count;
    }

    function getCustodianData(uint _transactionId) public view returns (address[] memory _custodians, uint8[] memory _category, 
        uint256 _unlockBlock, bool _executed, bool _add){
        Custodian memory data = CustodianTransactions[_transactionId];
        _custodians = data.newCustodianAddress;
        _category = data.custodianCategories;
        _unlockBlock = data.unlockTimestamp;
        _executed = data.executed;
        _add = data.add;    
    }


    function _checkZeroAddress(address _address) internal pure {
        require (_address != address(0), "Invalid address");
    }
}
// SPDX-License-Identifier: MIT
// Tells the Solidity compiler to compile only from v0.8.13 to v0.9.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./AccessControl.sol";
import './SharedStructs.sol';
import './SharedStructs.sol';

import './SharedStructs.sol';

struct SettlementStruct {
        address debtor;
        address creditor;
        SharedStructs.TokenStruct[] transactedTokens;
        SharedStructs.TokenStruct[] releasedFromDebtorTokens;
        SharedStructs.TokenStruct[] releasedFromCreditorTokens;
        bool exists;
        bool authorized;
}

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint256 value) external returns (bool);
    function withdraw(uint _amount) external;
}

contract Settlement {
    using SafeERC20 for IERC20;    

    address public owner;
    address public executor;
    address public WETH_address;
    IWETH public weth;

    AccessControl accessControl;
    event PendingSettlement(uint256 settlementUUID, address debtor, address creditor);
    event ExecutedSettlement(uint256 settlementUUID, address debtor, address creditor);
    event Deposit(address depositor, address token,  uint256 depositedAmount, uint256 currentAmount);
    event Redemption(address depositor, address token,  uint256 depositedAmount, uint256 currentAmount);
    event CustodianSignature(uint settlementUUID);
    event Locked(address depositor, address token,  uint256 lockedAmount, uint256 currentAmount);
    event Unlocked(address depositor, address token,  uint256 lockedAmount);
    event DeleteSettlement(uint256 settlementUUID);
    event ReleaseFunds(address settlementUUID);
    event ChangeOwnership(address newOwner);




    mapping(address => mapping (address => uint256)) private custodianBalances;
    mapping(address => mapping (address => uint256)) private lockedCustodianBalances;
    mapping(uint256 => SettlementStruct) private custodianSettlements;

    constructor(address AccessControlAddress, address executorAddress, address _wEthAddress){
        owner = msg.sender;
        checkZeroAddress(executorAddress);
        executor = executorAddress;
        checkZeroAddress(AccessControlAddress);
        accessControl = AccessControl(AccessControlAddress);
        WETH_address = _wEthAddress;
        weth = IWETH(WETH_address);
        //_paused = false;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    modifier onlyExecutor {
        require(msg.sender == executor, "Not contract executor");
        _;
    }

    function checkZeroAddress(address _address) internal pure {
        require (_address != address(0), "Invalid address");
    }

    function deposit(address _tokenAddress, uint256 _amount) public {
        accessControl.onlyAllowed(msg.sender);
        accessControl.onlyAllowedToken(_tokenAddress);
        IERC20 token = IERC20(_tokenAddress);
        token.safeTransferFrom(msg.sender, address(this), _amount);
        if (accessControl.isBrickAndMortar(msg.sender)){
            custodianBalances[msg.sender][_tokenAddress] += _amount;
            emit Deposit(msg.sender, _tokenAddress, _amount, custodianBalances[msg.sender][_tokenAddress]);
        } else {
            lockedCustodianBalances[msg.sender][_tokenAddress] += _amount;
            emit Locked(msg.sender, _tokenAddress, _amount, lockedCustodianBalances[msg.sender][_tokenAddress]);
        }                
    }

    receive() external payable {
        accessControl.onlyAllowed(msg.sender);
        require(msg.value > 0, "No ETH sent");
        uint msgValue = msg.value;
        weth.deposit{value: msg.value}();
        if (accessControl.isBrickAndMortar(msg.sender)){
            custodianBalances[msg.sender][WETH_address] += msgValue;
            emit Deposit(msg.sender, WETH_address, msgValue, custodianBalances[msg.sender][WETH_address]);
        } else {
            lockedCustodianBalances[msg.sender][WETH_address] += msgValue;
            emit Locked(msg.sender, WETH_address, msgValue, lockedCustodianBalances[msg.sender][WETH_address]);
        }
    }

    function createPendingSettlement(uint256 _settlementUUID, address _debtor, address _creditor, SharedStructs.TokenStruct[] memory _transactedTokens, 
        SharedStructs.TokenStruct[] memory _releasedFromDebtor, SharedStructs.TokenStruct[] memory _releasedFromCreditor) external onlyExecutor /*whenNotPaused*/ {
        require(!custodianSettlements[_settlementUUID].exists, "Settlement already exists");
        accessControl.validateSettlement(_creditor, _debtor);
        SettlementStruct storage newSettlement = custodianSettlements[_settlementUUID];
        newSettlement.debtor = _debtor;
        newSettlement.creditor = _creditor;
        newSettlement.exists = true;
        newSettlement.authorized = false;
        for (uint256 i = 0; i < _transactedTokens.length; i++) {
            require(accessControl.getTokenAllowable(_transactedTokens[i].tokenAddress), "not allowed token");
            newSettlement.transactedTokens.push(_transactedTokens[i]);
        }
        if(_releasedFromDebtor.length > 0){
            require(accessControl.isVirtualCustodian(_debtor), "not VC to have funds released");
            for (uint256 i = 0; i < _releasedFromDebtor.length; i++) {
                require(accessControl.getTokenAllowable(_releasedFromDebtor[i].tokenAddress), "not allowed token");
                newSettlement.releasedFromDebtorTokens.push(_releasedFromDebtor[i]);
            }
        }
        if(_releasedFromCreditor.length > 0){
            require(accessControl.isVirtualCustodian(_creditor), "not VC to have funds released");        
            for (uint256 i = 0; i < _releasedFromCreditor.length; i++) {
                require(accessControl.getTokenAllowable(_releasedFromCreditor[i].tokenAddress), "not allowed token");
                newSettlement.releasedFromCreditorTokens.push(_releasedFromCreditor[i]);
            }
        }
        emit PendingSettlement(_settlementUUID, _debtor, _creditor);
    }

    function authorizeSettlement(uint256 _settlementUUID) public {
        accessControl.onlyAllowed(msg.sender);
        require(!custodianSettlements[_settlementUUID].authorized, "settlement already authorized");
        require(_mappingObjectExists(_settlementUUID), "Inexistent settlement");
        if (accessControl.isBrickAndMortar(msg.sender)) {
            require(msg.sender == custodianSettlements[_settlementUUID].debtor, "Address is not the debtor");
            _lockFunds(_settlementUUID);
        }
        else if (accessControl.isVirtualCustodian(custodianSettlements[_settlementUUID].debtor)) {
            require(accessControl.isAuditor(msg.sender));
        } else {
            revert("Invalid custodian category");
        }
        custodianSettlements[_settlementUUID].authorized = true;
        emit CustodianSignature(_settlementUUID);
    }

    function authorizeMultiple(uint256[] memory _settlementUUIDs) public {
        for (uint256 i = 0; i< _settlementUUIDs.length; i++) {
            authorizeSettlement(_settlementUUIDs[i]);
        }
    }

    function executeSettlement(uint256[] memory _executedIds) external onlyExecutor {
        for (uint256 settlementIndex= 0; settlementIndex < _executedIds.length; settlementIndex++) {
            require(_mappingObjectExists(_executedIds[settlementIndex]), "Inexistent settlement");
            require(custodianSettlements[_executedIds[settlementIndex]].authorized, "Settlement not signed");
            _settle(_executedIds[settlementIndex]);
            _freeStorage(_executedIds[settlementIndex]);
        }
    }

    function _mappingObjectExists(uint256 settlementUUID) private view returns (bool){
        return custodianSettlements[settlementUUID].exists == true ? true : false;
    }

    function _settle(uint256 _settlementUUID) private {
        SettlementStruct storage settlement = custodianSettlements[_settlementUUID];
        for (uint index = 0; index < settlement.transactedTokens.length; index++) {
            if(accessControl.isBrickAndMortar(settlement.creditor)) {
            //moves from locked debtor to unlocked creditor if creditor is category 1(BRICK)
                lockedCustodianBalances[settlement.debtor][settlement.transactedTokens[index].tokenAddress] -= settlement.transactedTokens[index].tokenAmount;
                custodianBalances[settlement.creditor][settlement.transactedTokens[index].tokenAddress] += settlement.transactedTokens[index].tokenAmount;
            } else if (accessControl.isVirtualCustodian(settlement.creditor)) {
                //moves from locked debtor to locked creditor if creditor is category 2(VC)
                lockedCustodianBalances[settlement.debtor][settlement.transactedTokens[index].tokenAddress] -= settlement.transactedTokens[index].tokenAmount;
                lockedCustodianBalances[settlement.creditor][settlement.transactedTokens[index].tokenAddress] += settlement.transactedTokens[index].tokenAmount;
            }
        }
        if (settlement.releasedFromDebtorTokens.length != 0) _unlockFunds(settlement.debtor, settlement.releasedFromDebtorTokens);
        if (settlement.releasedFromCreditorTokens.length != 0) _unlockFunds(settlement.creditor, settlement.releasedFromCreditorTokens);
        emit ExecutedSettlement(_settlementUUID, settlement.debtor, settlement.creditor);
    }

    function _lockFunds(uint256 _settlementUUID) private {
        SettlementStruct storage settlement = custodianSettlements[_settlementUUID];
        for (uint index = 0; index < settlement.transactedTokens.length; index++) {
            //moves from unlocked debtor to locked debtor
            custodianBalances[settlement.debtor][settlement.transactedTokens[index].tokenAddress] -= settlement.transactedTokens[index].tokenAmount;
            lockedCustodianBalances[settlement.debtor][settlement.transactedTokens[index].tokenAddress] += settlement.transactedTokens[index].tokenAmount;
        }
    }

    function _freeStorage(uint256 key) private {
        delete custodianSettlements[key].transactedTokens;
        delete custodianSettlements[key].releasedFromDebtorTokens;
        delete custodianSettlements[key].releasedFromCreditorTokens;

        delete custodianSettlements[key].debtor;
        delete custodianSettlements[key].creditor;
        custodianSettlements[key].exists = false;
        custodianSettlements[key].authorized = false;
    }

    function redeem(address _tokenAddress, uint256 _amount) public {
        accessControl.onlyAllowed(msg.sender);
        IERC20 token = IERC20(_tokenAddress);
        require(_amount <= custodianBalances[msg.sender][_tokenAddress], "Insuficient funds");
        custodianBalances[msg.sender][_tokenAddress] -= _amount;
        if(_tokenAddress == WETH_address) {
            require(weth.transfer(msg.sender,_amount), "Failed to transfer");
        } else {
            token.safeTransfer(msg.sender, _amount);
        }
        emit Redemption(msg.sender, _tokenAddress, _amount, custodianBalances[msg.sender][_tokenAddress]);        
    }

    function getBalancesOfToken(address _custodianAddress, address _tokenAddress) public view returns (uint256 balance, uint256 lockedBalance){
        return (custodianBalances[_custodianAddress][_tokenAddress], lockedCustodianBalances[_custodianAddress][_tokenAddress]);
    }

    function getSettlementData(uint256 _settlementId) public view returns (address debtor, address creditor, 
        SharedStructs.TokenStruct[] memory transactedTokens, SharedStructs.TokenStruct[] memory releasedFromDebtorTokens, 
        SharedStructs.TokenStruct[] memory releasedFromCreditorTokens, bool authorized) {
        return (custodianSettlements[_settlementId].debtor, custodianSettlements[_settlementId].creditor, 
            custodianSettlements[_settlementId].transactedTokens, custodianSettlements[_settlementId].releasedFromDebtorTokens,
            custodianSettlements[_settlementId].releasedFromCreditorTokens, 
            custodianSettlements[_settlementId].authorized);
    }

    function getContractData() public view returns (address executorAddress, address adminAddress){
        return (executor, owner);
    }

    function _unlockFunds(address entity, SharedStructs.TokenStruct[] memory tokens) internal {
        for (uint index = 0; index < tokens.length; index++) {
            lockedCustodianBalances[entity][tokens[index].tokenAddress] -= tokens[index].tokenAmount;
            custodianBalances[entity][tokens[index].tokenAddress] += tokens[index].tokenAmount;
        }
    }
    
    function deleteSettlement(uint256 _settlementUUID) external onlyOwner {
        if (!accessControl.isVirtualCustodian(custodianSettlements[_settlementUUID].debtor)){
            //Only non VC users need to move funds
            if (custodianSettlements[_settlementUUID].authorized){
            SettlementStruct storage settlement = custodianSettlements[_settlementUUID];
                for (uint index = 0; index < settlement.transactedTokens.length; index++) {
                    //moves from locked debtor to unlocked debtor
                    lockedCustodianBalances[settlement.debtor][settlement.transactedTokens[index].tokenAddress] -= settlement.transactedTokens[index].tokenAmount;      
                    custodianBalances[settlement.debtor][settlement.transactedTokens[index].tokenAddress] += settlement.transactedTokens[index].tokenAmount; 
                }
            }
        }        
        _freeStorage(_settlementUUID);
        emit DeleteSettlement(_settlementUUID);

    }

    function releaseFunds(address custodianAddress, address[] calldata tokenAddresses) external onlyOwner {
        require(accessControl.isVirtualCustodian(custodianAddress), "cannot release non VCs");
        for(uint index = 0; index < tokenAddresses.length; index++){
            uint amount = lockedCustodianBalances[custodianAddress][tokenAddresses[index]];
            lockedCustodianBalances[custodianAddress][tokenAddresses[index]] -= amount;
            custodianBalances[custodianAddress][tokenAddresses[index]] += amount;
        }
        emit ReleaseFunds(custodianAddress);
    }

    function changeOwnership(address _ownerAddress) external onlyOwner {
        checkZeroAddress(_ownerAddress);
        owner = _ownerAddress;
        emit ChangeOwnership(_ownerAddress);
    }
}
// SPDX-License-Identifier: MIT
// Tells the Solidity compiler to compile only from v0.8.13 to v0.9.0
pragma solidity ^0.8.0;

contract SharedStructs {
  struct TokenStruct {
    address tokenAddress;
    uint256 tokenAmount;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Utils {
    // Utility Functions
    function addressToString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint256 i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint256(uint160(x)) / (2**(8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function append(
        string memory a,
        address b,
        address c
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(a, addressToString(b), " ", addressToString(c))
            );
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}