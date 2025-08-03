// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract MerkleClaimer {
    IERC20 public token;
    IStaking public staking;
    bytes32 public merkleRoot;
    uint256 public distributed;
    mapping(address => uint256) public claimed;
    mapping(address => bool) public exec;

    event File(bytes32 indexed what, address data);
    event SetMerkleRoot(bytes32 root);
    event Claim(address indexed user, uint256 amount, uint256 total);

    error InvalidFile();
    error Unauthorized();
    error TransferFailed();

    constructor(address _token, address _staking) {
        token = IERC20(_token);
        staking = IStaking(_staking);
        exec[msg.sender] = true;
    }

    modifier auth() {
        if (!exec[msg.sender]) revert Unauthorized();
        _;
    }

    function file(bytes32 what, address data) external auth {
        if (what == "exec") {
            exec[data] = !exec[data];
        } else {
            revert InvalidFile();
        }
        emit File(what, data);
    }

    function setMerkleRoot(bytes32 root) external auth {
        merkleRoot = root;
        emit SetMerkleRoot(root);
    }

    function collect(address _token, uint256 amount) external auth {
        IERC20(_token).transfer(msg.sender, amount);
    }

    function claim(address user, uint256 total, bytes32[] calldata proof) external {
        bytes32 leaf = keccak256(abi.encodePacked(user, total));
        require(verify(proof, merkleRoot, leaf), "invalid proof");
        uint256 amount = total - min(total, claimed[user]);
        claimed[user] = total;
        distributed += amount;
        token.approve(address(staking), amount);
        staking.deposit(amount, user);
        emit Claim(user, amount, amount);
    }

    function verify(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash < proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash == root;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

interface IERC20 {
    function approve(address, uint256) external;
    function transfer(address, uint256) external returns (bool);
}

interface IStaking {
    function deposit(uint256 amount, address to) external;
}