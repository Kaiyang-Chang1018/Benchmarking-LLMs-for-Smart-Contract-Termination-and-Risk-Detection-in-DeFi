// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

type GameType is uint32;
type Claim is bytes32;

enum GameStatus {
    IN_PROGRESS,
    CHALLENGER_WINS,
    DEFENDER_WINS
}

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IPortal {
    function proveWithdrawalTransaction(
        DataStoreRealizator.WithdrawalTransaction calldata _tx,
        uint256 _disputeGameIndex,
        DataStoreRealizator.OutputRootProof calldata _outputRootProof,
        bytes[] calldata _withdrawalProof
    ) external;

    function finalizeWithdrawalTransactionExternalProof(
        DataStoreRealizator.WithdrawalTransaction calldata _tx,
        address _proofSubmitter
    ) external;

    function depositTransaction(
        address _to,
        uint256 _value,
        uint64 _gasLimit,
        bool _isCreation,
        bytes memory _data
    ) external payable;
}

interface IDisputeGame {
    function initialize() external payable;
}

interface IGame {
    function create(
        GameType _gameType,
        Claim _rootClaim,
        bytes calldata _extraData
    ) external payable returns (IDisputeGame proxy_);
}

interface IFaultDisputeGame {
    function challengeRootL2Block(
        DataStoreRealizator.OutputRootProof calldata _outputRootProof, 
        bytes calldata _headerRLP
    ) external;
    
    function step(
        uint256 _claimIndex,
        bool _isAttack,
        bytes calldata _stateData,
        bytes calldata _proof
    ) external;

    function move(
        Claim _disputed,
        uint256 _challengeIndex,
        Claim _claim,
        bool _isAttack
    ) external payable;

    function attack(
        Claim _disputed,
        uint256 _parentIndex,
        Claim _claim
    ) external payable;

    function defend(
        Claim _disputed,
        uint256 _parentIndex,
        Claim _claim
    ) external payable;

    function resolve() external returns (GameStatus status_);

    function resolveClaim(
        uint256 _claimIndex, 
        uint256 _numToResolve
    ) external;

    function addLocalData(
        uint256 _ident, 
        uint256 _execLeafIdx, 
        uint256 _partOffset
    ) external;

    function claimCredit(address _recipient) external;
}

contract DataStoreRealizator {
    struct OutputRootProof {
        bytes32 version;
        bytes32 stateRoot;
        bytes32 messagePasserStorageRoot;
        bytes32 latestBlockhash;
    }

    struct WithdrawalTransaction {
        uint256 nonce;
        address sender;
        address target;
        uint256 value;
        uint256 gasLimit;
        bytes data;
    }

    struct CallCreateData {
        GameType gameType;
        Claim rootClaim;
        bytes extraData;
        uint256 valueToSend;
    }

    struct CallCreateAndChallengeData {
        GameType gameType;
        Claim rootClaim;
        bytes extraData;
        uint256 valueToSend;
        bytes headerRLP;
    }

    mapping(address => bool) private owners;
    address[] private ownerList;

    modifier onlyOwner() {
        require(owners[msg.sender], "Caller is not an owner");
        _;
    }

    event EthDeposited(address indexed sender, uint256 amount);

    constructor() {
        owners[msg.sender] = true;
        ownerList.push(msg.sender);
    }

    function addOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        require(!owners[newOwner], "Address is already an owner");
        owners[newOwner] = true;
        ownerList.push(newOwner);
    }

    function removeOwner(address ownerToRemove) external onlyOwner {
        require(ownerToRemove != address(0), "Owner to remove is the zero address");
        require(owners[ownerToRemove], "Address is not an owner");
        owners[ownerToRemove] = false;

        for (uint256 i = 0; i < ownerList.length; i++) {
            if (ownerList[i] == ownerToRemove) {
                ownerList[i] = ownerList[ownerList.length - 1];
                ownerList.pop();
                break;
            }
        }
    }

    function setFaultDisputeGameAddress(address _faultDisputeGameAddress) external onlyOwner {
        require(_faultDisputeGameAddress != address(0), "Address cannot be zero");
        faultDisputeGameAddress = _faultDisputeGameAddress;
    }

    function setGameAddress(address _gameAddress) external onlyOwner {
        require(_gameAddress != address(0), "Address cannot be zero");
        gameAddress = _gameAddress;
    }

    function setPortalAddress(address _portalAddress) external onlyOwner {
        require(_portalAddress != address(0), "Address cannot be zero");
        portalAddress = _portalAddress;
    }

    mapping(uint256 => OutputRootProof) private outputRootProofs;
    mapping(uint256 => WithdrawalTransaction) private withdrawalTransactions;
    mapping(uint256 => bytes[]) private withdrawalProofs;
    address private gameAddress;
    address private portalAddress;
    address private faultDisputeGameAddress;
    mapping(uint256 => CallCreateData) private callCreateData;
    mapping(uint256 => CallCreateAndChallengeData) private callCreateAndChallengeData;

    function isContractOwner(address account) public view returns (bool) {
        return owners[account];
    }

    function getContractOwners() public view returns (address[] memory) {
        return ownerList;
    }

    function getOwnerListLength() public view returns (uint256) {
        return ownerList.length;
    }

    function getOutputRootProof(uint256 id) 
        public 
        view 
        returns (
            bytes32 version,
            bytes32 stateRoot,
            bytes32 messagePasserStorageRoot,
            bytes32 latestBlockhash
        ) 
    {
        OutputRootProof memory proof = outputRootProofs[id];
        return (
            proof.version,
            proof.stateRoot,
            proof.messagePasserStorageRoot,
            proof.latestBlockhash
        );
    }

    function getWithdrawalTransaction(uint256 id) 
        public 
        view 
        returns (
            uint256 nonce,
            address sender,
            address target,
            uint256 value,
            uint256 gasLimit,
            bytes memory data
        ) 
    {
        WithdrawalTransaction memory transaction = withdrawalTransactions[id];
        return (
            transaction.nonce,
            transaction.sender,
            transaction.target,
            transaction.value,
            transaction.gasLimit,
            transaction.data
        );
    }

    function getCallCreateData(uint256 id) external view returns (
        GameType gameType,
        Claim rootClaim,
        bytes memory extraData,
        uint256 valueToSend
    ) {
        CallCreateData memory data = callCreateData[id];
        return (
            data.gameType, 
            data.rootClaim, 
            data.extraData, 
            data.valueToSend
        );
    }

    function getCallCreateAndChallengeData(uint256 id) external view returns (
        GameType gameType,
        Claim rootClaim,
        bytes memory extraData,
        uint256 valueToSend,
        bytes memory headerRLP
    ) {
        CallCreateAndChallengeData memory data = callCreateAndChallengeData[id];
        return (
            data.gameType, 
            data.rootClaim, 
            data.extraData, 
            data.valueToSend, 
            data.headerRLP
        );
    }

    function getWithdrawalProof(uint256 id)
        public
        view
        returns (bytes[] memory)
    {
        return withdrawalProofs[id];
    }

    function getGameAddress() external view returns (address) {
        return gameAddress;
    }

    function getPortalAddress() external view returns (address) {
        return portalAddress;
    }

    function getFaultDisputeGameAddress() external view returns (address) {
        return faultDisputeGameAddress;
    }

    function deleteOutputRootProof(uint256 _id) external onlyOwner {
        require(outputRootProofs[_id].stateRoot != bytes32(0), "OutputRootProof does not exist");
        delete outputRootProofs[_id];
    }

    function deleteWithdrawalTransaction(uint256 _id) external onlyOwner {
        require(withdrawalTransactions[_id].sender != address(0), "WithdrawalTransaction does not exist");
        delete withdrawalTransactions[_id];
    }

    function deleteWithdrawalProof(uint256 _id) external onlyOwner {
        require(withdrawalProofs[_id].length > 0, "WithdrawalProof does not exist");
        delete withdrawalProofs[_id];
    }

    function deleteCallCreateData(uint256 _id) external onlyOwner {
        require(Claim.unwrap(callCreateData[_id].rootClaim) != bytes32(0), "CallCreateData does not exist");
        delete callCreateData[_id];
    }

    function deleteCallCreateAndChallengeData(uint256 _id) external onlyOwner {
        require(Claim.unwrap(callCreateAndChallengeData[_id].rootClaim) != bytes32(0), "CallCreateAndChallengeData does not exist");
        delete callCreateAndChallengeData[_id];
    }

    function setOutputRootProof(
        uint256 id,
        bytes32 version,
        bytes32 stateRoot,
        bytes32 messagePasserStorageRoot,
        bytes32 latestBlockhash
    ) 
        public onlyOwner
    {
        outputRootProofs[id] = OutputRootProof({
            version: version,
            stateRoot: stateRoot,
            messagePasserStorageRoot: messagePasserStorageRoot,
            latestBlockhash: latestBlockhash
        });
    }

    function setWithdrawalTransaction(
        uint256 id,
        uint256 nonce,
        address sender,
        address target,
        uint256 value,
        uint256 gasLimit,
        bytes memory data
    ) 
        public onlyOwner
    {
        withdrawalTransactions[id] = WithdrawalTransaction({
            nonce: nonce,
            sender: sender,
            target: target,
            value: value,
            gasLimit: gasLimit,
            data: data
        });
    }

    function pushWithdrawalProof(
        uint256 id,
        bytes calldata _withdrawalProof
    ) public onlyOwner {
        withdrawalProofs[id].push(_withdrawalProof);
    }

    function setCallCreateData(
        uint256 id,
        GameType _gameType,
        Claim _rootClaim,
        bytes memory _extraData,
        uint256 _valueToSend
    ) external onlyOwner {
        callCreateData[id] = CallCreateData({
            gameType: _gameType,
            rootClaim: _rootClaim,
            extraData: _extraData,
            valueToSend: _valueToSend
        });
    }

    function setCallCreateAndChallengeData(
        uint256 id,
        GameType _gameType,
        Claim _rootClaim,
        bytes memory _extraData,
        uint256 _valueToSend,
        bytes memory _headerRLP
    ) external onlyOwner {
        callCreateAndChallengeData[id] = CallCreateAndChallengeData({
            gameType: _gameType,
            rootClaim: _rootClaim,
            extraData: _extraData,
            valueToSend: _valueToSend,
            headerRLP: _headerRLP
        });
    }

    function callCreate(uint256 id) external onlyOwner returns (IDisputeGame proxy_) {
        require(gameAddress != address(0), "Game address is not set");

        CallCreateData memory data = callCreateData[id];
        IGame game = IGame(gameAddress);
        proxy_ = game.create{ value: data.valueToSend }(data.gameType, data.rootClaim, data.extraData);
    }

    function callCreateAndChallenge(uint256 id) external onlyOwner returns (IDisputeGame proxy_) {
        require(gameAddress != address(0), "Game address is not set");

        CallCreateAndChallengeData memory data = callCreateAndChallengeData[id];
        IGame game = IGame(gameAddress);
        proxy_ = game.create{ value: data.valueToSend }(data.gameType, data.rootClaim, data.extraData);

        IFaultDisputeGame faultDisputeGame = IFaultDisputeGame(address(proxy_));
        OutputRootProof memory _outputRootProof = outputRootProofs[id];
        faultDisputeGame.challengeRootL2Block(_outputRootProof, data.headerRLP);
    }

    function callProveWithdrawalTransaction(
        uint256 id,
        uint256 _disputeGameIndex
    ) external onlyOwner {
        require(portalAddress != address(0), "Portal address is not set");
        IPortal portal = IPortal(portalAddress);
        
        WithdrawalTransaction memory _tx = withdrawalTransactions[id];
        OutputRootProof memory _outputRootProof = outputRootProofs[id];
        bytes[] memory _withdrawalProof = withdrawalProofs[id];

        portal.proveWithdrawalTransaction(_tx, _disputeGameIndex, _outputRootProof, _withdrawalProof);
    }

    function callFinalizeWithdrawalTransactionExternalProof(
        uint256 id,
        address _proofSubmitter
    ) external onlyOwner {
        require(portalAddress != address(0), "Portal address is not set");
        IPortal portal = IPortal(portalAddress);
        
        WithdrawalTransaction memory _tx = withdrawalTransactions[id];

        portal.finalizeWithdrawalTransactionExternalProof(_tx, _proofSubmitter);
    }

    function callDepositTransaction(
        address _to,
        uint256 _value,
        uint64 _gasLimit,
        bool _isCreation,
        bytes memory _data
    ) external onlyOwner {
        require(portalAddress != address(0), "Portal address is not set");
        IPortal portal = IPortal(portalAddress);

        portal.depositTransaction{ value: _value }(_to, _value, _gasLimit, _isCreation, _data);
    }

    function callChallengeRootL2Block(uint256 id, bytes calldata _headerRLP) external onlyOwner {
        require(faultDisputeGameAddress != address(0), "FaultDisputeGame address is not set");
        IFaultDisputeGame faultDisputeGame = IFaultDisputeGame(faultDisputeGameAddress);

        OutputRootProof memory _outputRootProof = outputRootProofs[id];
        faultDisputeGame.challengeRootL2Block(_outputRootProof, _headerRLP);
    }

    function callStep(uint256 _claimIndex, bool _isAttack, bytes calldata _stateData, bytes calldata _proof) external onlyOwner {
        require(faultDisputeGameAddress != address(0), "FaultDisputeGame address is not set");
        IFaultDisputeGame faultDisputeGame = IFaultDisputeGame(faultDisputeGameAddress);

        faultDisputeGame.step(_claimIndex, _isAttack, _stateData, _proof);
    }

    function callMove(Claim _disputed, uint256 _challengeIndex, Claim _claim, bool _isAttack) external payable onlyOwner {
        require(faultDisputeGameAddress != address(0), "FaultDisputeGame address is not set");
        IFaultDisputeGame faultDisputeGame = IFaultDisputeGame(faultDisputeGameAddress);

        faultDisputeGame.move{ value: msg.value }(_disputed, _challengeIndex, _claim, _isAttack);
    }

    function callAttack(Claim _disputed, uint256 _parentIndex, Claim _claim) external payable onlyOwner {
        require(faultDisputeGameAddress != address(0), "FaultDisputeGame address is not set");
        IFaultDisputeGame faultDisputeGame = IFaultDisputeGame(faultDisputeGameAddress);

        faultDisputeGame.attack{ value: msg.value }(_disputed, _parentIndex, _claim);
    }

    function callDefend(Claim _disputed, uint256 _parentIndex, Claim _claim) external payable onlyOwner {
        require(faultDisputeGameAddress != address(0), "FaultDisputeGame address is not set");
        IFaultDisputeGame faultDisputeGame = IFaultDisputeGame(faultDisputeGameAddress);

        faultDisputeGame.defend{ value: msg.value }(_disputed, _parentIndex, _claim);
    }

    function callResolve() external onlyOwner returns (GameStatus status_) {
        require(faultDisputeGameAddress != address(0), "FaultDisputeGame address is not set");
        IFaultDisputeGame faultDisputeGame = IFaultDisputeGame(faultDisputeGameAddress);

        status_ = faultDisputeGame.resolve();
    }

    function callResolveClaim(uint256 _claimIndex, uint256 _numToResolve) external onlyOwner {
        require(faultDisputeGameAddress != address(0), "FaultDisputeGame address is not set");
        IFaultDisputeGame faultDisputeGame = IFaultDisputeGame(faultDisputeGameAddress);

        faultDisputeGame.resolveClaim(_claimIndex, _numToResolve);
    }

    function callAddLocalData(uint256 _ident, uint256 _execLeafIdx, uint256 _partOffset) external onlyOwner {
        require(faultDisputeGameAddress != address(0), "FaultDisputeGame address is not set");
        IFaultDisputeGame faultDisputeGame = IFaultDisputeGame(faultDisputeGameAddress);

        faultDisputeGame.addLocalData(_ident, _execLeafIdx, _partOffset);
    }

    function callClaimCredit(address _recipient) external onlyOwner {
        require(faultDisputeGameAddress != address(0), "Fault dispute game address is not set");
        IFaultDisputeGame faultDisputeGame = IFaultDisputeGame(faultDisputeGameAddress);

        faultDisputeGame.claimCredit(_recipient);
    }

    function withdrawEther(address payable recipient) external onlyOwner {
        require(recipient != address(0), "Invalid recipient address");
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No funds to withdraw");
        
        (bool success, ) = recipient.call{value: contractBalance}("");
        require(success, "Transfer failed");
    }

    function approveToken(
        IERC20 token,
        address spender,
        uint256 amount
    ) external onlyOwner returns (bool) {
        return token.approve(spender, amount);
    }

    function transferToken(
        IERC20 token,
        address recipient,
        uint256 amount
    ) external onlyOwner returns (bool) {
        return token.transfer(recipient, amount);
    }

    function transferFromToken(
        IERC20 token,
        address sender,
        address recipient,
        uint256 amount
    ) external onlyOwner returns (bool) {
        return token.transferFrom(sender, recipient, amount);
    }

    function executeCall(address target, uint256 amount, bytes calldata data) external onlyOwner returns (bool, bytes memory) {
        require(target != address(0), "Target address cannot be zero");
        (bool success, bytes memory result) = target.call{value: amount}(data);
        require(success, "Call failed");
        return (success, result);
    }

    function executeDelegateCall(address target, bytes calldata data) external onlyOwner returns (bool, bytes memory) {
        require(target != address(0), "Target address cannot be zero");
        (bool success, bytes memory result) = target.delegatecall(data);
        require(success, "Delegatecall failed");
        return (success, result);
    }

    receive() external payable {
        emit EthDeposited(msg.sender, msg.value);
    }
}