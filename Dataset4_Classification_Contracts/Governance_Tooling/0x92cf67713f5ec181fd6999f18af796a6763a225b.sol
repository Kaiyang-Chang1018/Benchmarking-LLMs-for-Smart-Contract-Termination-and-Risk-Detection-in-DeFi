/**
 *Submitted for verification at mumbai.polygonscan.com on 2024-04-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ConsensusNode {
    uint256 internal confirmationsRequired = 3;
    address[] public nodes;
    
    struct ExecProposal{
        bytes32 uid;
        address to;
        bytes  data;
        uint nonce;
        uint confirmations;
    }

    
    mapping(bytes32 => ExecProposal) public eps;
    mapping(bytes32 =>mapping(address =>bool)) public confirmations;
    mapping(address => bool) _isNode;
    mapping(bytes32 => bool) _isExecuted;

    modifier onlyNode(){
        require(_isNode[msg.sender],"You are not the Node");
        _;
    }

    modifier onlyConsensus(){
        require(msg.sender == address(this),"Call the consensus function");
        _;
    }

    constructor(address[] memory _nodes){
        require(_nodes.length >= confirmationsRequired,"Minimum 3 Node");
        for (uint i; i < _nodes.length; i++){
            address nextOwner = _nodes[i];

            require(!_isNode[nextOwner],"duplicated Node");

            _isNode[nextOwner] = true;
            nodes.push(nextOwner);

        }
        
    }

    event ProposalConsensusRequest(
        address sender,
        address to,
        bytes  data,
        uint256 nonce,
        bytes32 txId
    );

    event discard(bytes32 txId);

    event assignRequired(
        uint256 blockNumber,
        uint8 minConfirm
        );

    event ProposalExecuted(
        bytes32 proposal_id,
        address sender
    );

    event ProposalAccepted(bytes32 txId, address sender, uint confirmation_count);

    //@dev Creating a transaction and adding to the queue for consideration
    function MakeProposal(
        address _to, 
        uint256 _nonce,
        bytes calldata _data
    ) external  onlyNode returns(bytes32 txId) {
        
        txId = txToByte(_to,_data,_nonce);
        
        //if this consensus already executed, -> do nothing
        require(!_isExecuted[txId], "proposal already executed");
        
        //if particular sender node already done this proposal -> do nothing
        require(!confirmations[txId][msg.sender], "already proposed by you");

        //mark proposal as confirmed by a sender 
        confirmations[txId][msg.sender] = true;

        
        if (eps[txId].uid != 0) //already exists and waiting for confirmation
        {
            ExecProposal storage execProposal = eps[txId];
            execProposal.confirmations++;

            if (execProposal.confirmations >= confirmationsRequired){
                callFunction(txId);
                emit ProposalExecuted(txId, msg.sender);
            }
            else{
                emit ProposalAccepted(txId, msg.sender, eps[txId].confirmations);
            }
            

        } else { //no such proposal, create
            eps[txId] = ExecProposal({
                    uid : txId,
                    to : _to,
                    data : _data,
                    nonce : _nonce,
                    confirmations:1
                });
            emit ProposalAccepted(txId, msg.sender, eps[txId].confirmations);
        }
    }


    //@dev sending a transaction
    function callFunction(bytes32 txId) private  {
        ExecProposal storage execProposal = eps[txId];

        //check if proposal exists
        require(execProposal.uid != 0, "not queued");

        //check confirmations
        require(
            execProposal.confirmations >= confirmationsRequired,
            "not enough confirmations "
        );
        
        //do call
        (bool success, ) = execProposal.to.call{value:0}(execProposal.data);
        
        require(success, "proposal function call error");
            
        //mark as processed, remove
        _isExecuted[txId] = true;
        delete eps[txId];

    }

    function txToByte(
        address to,
        bytes calldata _data,
        uint nonce
    ) internal pure returns (bytes32 _txId){

        bytes32 txId = keccak256(abi.encode(
            to,
            _data,
            nonce
        ));
        return txId;
    }

    function addNode(address newNode) public onlyConsensus{
        require(newNode != address(0), "Error zero address");
        _isNode[newNode] = true;
        nodes.push(newNode);
    }

    function delNode(uint indexNode) public onlyConsensus {
        uint ownerLength = nodes.length;
        require(indexNode <= ownerLength, "Node index cannot be higher than their number"); // index must be less than or equal to array length
        require(ownerLength -1  >= confirmationsRequired, "error minimal count owner");

        _isNode[nodes[indexNode]] = false;

        for (uint i = indexNode; i < ownerLength -1; i++){
            nodes[i] = nodes[i+1];
        }
        
        delete nodes[ownerLength-1];
        nodes.pop();
    }

    function assignRequiredConf(uint8 _confReq) public onlyConsensus{
        require(nodes.length >= _confReq, "error node.length < _confReq");
        require(_confReq >= 2, "Minimal confRequire 2");
        
        confirmationsRequired = _confReq;
        emit assignRequired(block.number,_confReq);
    }

    function seeNodes() external view returns(address[] memory){
        return nodes;
    }

    function isExecuted(bytes32 txId) external view returns(bool){
        return _isExecuted[txId];
    }

    function seeMinCofReq() public view returns(uint){
        return confirmationsRequired;
    }


}