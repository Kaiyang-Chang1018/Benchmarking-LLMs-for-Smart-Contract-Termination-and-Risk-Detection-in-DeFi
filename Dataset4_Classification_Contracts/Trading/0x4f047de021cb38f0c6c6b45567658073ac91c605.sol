// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Simple single owner authorization mixin.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)
abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/// @notice Gas optimized merkle proof verification library.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/MerkleProofLib.sol)
/// @author Modified from Solady (https://github.com/Vectorized/solady/blob/main/src/utils/MerkleProofLib.sol)
library MerkleProofLib {
    function verify(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool isValid) {
        /// @solidity memory-safe-assembly
        assembly {
            if proof.length {
                // Left shifting by 5 is like multiplying by 32.
                let end := add(proof.offset, shl(5, proof.length))

                // Initialize offset to the offset of the proof in calldata.
                let offset := proof.offset

                // Iterate over proof elements to compute root hash.
                // prettier-ignore
                for {} 1 {} {
                    // Slot where the leaf should be put in scratch space. If
                    // leaf > calldataload(offset): slot 32, otherwise: slot 0.
                    let leafSlot := shl(5, gt(leaf, calldataload(offset)))

                    // Store elements to hash contiguously in scratch space.
                    // The xor puts calldataload(offset) in whichever slot leaf
                    // is not occupying, so 0 if leafSlot is 32, and 32 otherwise.
                    mstore(leafSlot, leaf)
                    mstore(xor(leafSlot, 32), calldataload(offset))

                    // Reuse leaf to store the hash to reduce stack operations.
                    leaf := keccak256(0, 64) // Hash both slots of scratch space.

                    offset := add(offset, 32) // Shift 1 word per cycle.

                    // prettier-ignore
                    if iszero(lt(offset, end)) { break }
                }
            }

            isValid := eq(leaf, root) // The proof is valid if the roots match.
        }
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Gas optimized reentrancy protection for smart contracts.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/ReentrancyGuard.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol)
abstract contract ReentrancyGuard {
    uint256 private locked = 1;

    modifier nonReentrant() virtual {
        require(locked == 1, "REENTRANCY");

        locked = 2;

        _;

        locked = 1;
    }
}
// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.10;

interface IMintable {
    function mintTo(address owner, uint256 id) external;
}
// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.10;

import {Owned} from "solmate/auth/Owned.sol";
import {ReentrancyGuard} from "solmate/utils/ReentrancyGuard.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {MerkleProofLib} from "solmate/utils/MerkleProofLib.sol";
import {IMintable} from "../interface/IMintable.sol";

/** 
 * @dev Investor NFT minting / sale contract.
 */
contract InvestorNFTMinterV1 is Owned, ReentrancyGuard, ERC165 {
    bytes4 constant private _MINT_WITH_WHITELIST = bytes4(
        keccak256("isClaimed(uint256)") ^
        keccak256("mintTo(address)") ^
        keccak256("mintTo(address,uint256,bytes32[])")
    );

    // TRUSTED_BENEFICIARY is expected to be the LE7EL DAO multisig,
    // Only beneficiary address will get all the income coming from this contract.
    // Minter contract would be re-deployed if beneficiary changes.
    // solhint-disable-next-line var-name-mixedcase
    address payable public immutable TRUSTED_BENEFICIARY;

    uint256 public price = 0.05 ether;
    uint256 public pricePublic = 0.065 ether;
    bytes32 public merkleRoot;
    
    // 0 - preparation (only owner can premint for free),
    // 1 - GTD (guaranted whitelist mint first),
    // 2 - FCFS (first come first server whitelist mint after GTD),
    // 3 - public (anyone is welcome to mint in public phase). 
    uint256 public phase = 0;

    // Pre-generated order of ids, all ids have the same utility, so no risk attached
    bytes private constant _ALL_IDS = hex"07c6009f08a906f7050907ad016b07c5005904a4017004fb075a01aa0839010201ef02280189006f04aa0030030a06cb06e6020c037f04b20272017604bc06180334048100f70352057b04010169035c00fb01b70043045607b90082038e052600d102f308a30699034a06ac06c802fe04d501fd042200f8043f027306d506f90579042106a10067028807b006ae02bb06a40856012f032c01d6046c08300033086b04e8011a056004c80424030b061f0545075c038b026104f805ed019e00c300ef06f401a5013f087d05720858060f053a0550045f0134060a07a2030607a6031406da018b021e0155089c03e106d604a704f50186042e041a058e04950716025903c600ac0061054707d900bc056e078408570418029604e60065023b066f04c107b7081e03b407ac028704b107ba07f904d801c4031e0785008700260741008b04e101f101cf008c0219042607fd00970866003603b503d5018f084e058706a0035803c700e50285029702a00551047f061507dd04fc010c003b088c0535084b039c0609068b0427034c04ef01ce035d06f8039b06d403f506e3020504d4076504fa02f807740897017b023c033501850736071f04e705a20642024701b806a30344030807c80441033c031704de02c7010a07f8055802d9034906ec044f07240057061a036a003d07e4065c060203d4032705df01ad080f064f02ea0610084203c906aa02a2056303b104280851047e0660022d02dd06680350076e00ff05ff007e0822082e00dc01970506061407200588028b011103c2033d031103e60115089e0016029d07cf0138009906bb009a039702de0444062803e400ce0438003c03b207b206b70847060e087105b3027507690475013a07c100b3030907fb060803e001a7073806d9075e08a5023a017102a1000b03fb0403050f038703cd0677063907a40600040f088e024d05a500d604b8087806830255001c021b03af03a4074706800805036406ee0565005f012e026e06c60390075b0005024405380831002900eb049106bf03ce0694087e00b4039400b9052b05e703d20058012300fd062c061906fc0336054e0627023d081b03d60499005602d8048c07d4043004a905cb008e015f01d805c4049c0280033b03e80432083b047d038105a7030105db074006c9016a024f06980137053e051503ae0106065506dc0074044000f601de00f0012c07f4084005d401d705f00640085e079803bf0431078808280243077003c103890203011302ce007107ae05aa068900b104ec06fe029c05d601810712032d019a069202d10395037101f2025a045b02000445073a01a20063000901c2087f00bd071e03a8076303cf0695052e05a4063f00f5088d01b100bf06d706e202e406b30156028e01a1046603f102f205ca018306b407aa0845063105d0063602d607fc060b08ad080d058d00b7039d081d05cd052700a8058a00140405023002410294006c028f016103400194016e008800af017304f70165006e049303bc06a205cf01db03e2029a07dc06ed02a70231087605990633016f062e030f00b00591057c074502c2071806c008820488080b05b7030d034601dc015b00a300d701d204cf00e7043c054c086102e006d8086304d902dc04bb0772037705010879057f05d7023707510715001b05f6089d015d06eb06af047304be033906db07c3050802f502ac05670047047b080005e00100005c05fc04ed025707a700940096059e01a9048401120754081307170342006d03f602420797031205e4089602c3086f000f058f046b07e300a202ec02b40278036903da078703cc05dd057502140162018d014802a606840573055403a3036204d1002c03b8075902d500cf00a507c907ea073b0603006805a6044a07e204cc03b9084407a308ab0471076603ed05ae0517089a067505960656058b053b01280305033e05d30811065e016c051b076b031d04ea01ff05440409049803fe01c50635069d02230582081202fb0557027b0730027e04150781033a013300ca04b60818010e006a063e036700d5083a07ca015902930125076707490474083d0823015206e1023508040864008d02fa00c40644035e064802df0881081704510783014a038403d0009b04d207f5036e03a601f8063c078a04b707bc0514020a07df020f068c027c01cd010d037905c9073d06ad050206670041043e0300018c0436071907060592089405970363037208650681059c05dc004805290143078c0665022b044d06b103e301ea00b8037d032f025305d501f7070b03d30072002d034d07d70195047a022e064a01c303ac069a02a8084601d3027402fd01df064e004204f90777018a005d0546088304a00091083e0604032303ad03f9072c06be086e01ca080e0778064d03ff014107f705980750048607a900cc03700691049f078f0661075f0034074a082605330326041301880673046303db081a057804c3017a083606f2089304f1027f0580062d07ec077f050005c001eb042d03b302bd036b02910849022400df04d600da054f00c900cb039e083701170160071c003a089102ed085f01b00232013b00e3043301e3089207640121074e066200d0070d0406006b001a05b9080203eb03570671067b02ee055e085c01d404ff0623050b0279013602900076041007ee045202c4052d01d1087b069705b201a4010902d3072506fd05fd0852060606e80190033107cc000102db0222055c087503a103780827055301af073506d20095017c0884028a066e05a304110333036c010b083807390816042f0469014007f20292015800c2064905bc01a005b50714043d04ad038600fc049b07fa085a00a406170052016402b2082a052f0119025d05f204bf0520058c009e0710084d06f502cb0504077c02b700e10653079f027006e7031908690479053405640700041e000d070e056107e9084c05bf05ad0676085d05f3005401390775064303850310000c02c505da055f082d014c04ac05fe066a0177021a008a059f07af045901bb046207a505e6004d088605a0054001b602b0076d05a80217073403ca02cc0556054b078206c407260708070a01e503d704a3013d01b904a5012a015e064c0795056d01bd03be024c0659073706b2033200f300ee012d020e02cd05b600b5023800d40227030404c604a203e90530051c009305e905cc063d04b30199020602ef011d077a04350089021003030354069e067c0872082f05ea03ec00a607f00678049d079c05e107cd03480762046505240268017d03a906c303aa040c01b30868022f040706de0404026a04f2002e014b01ac04df0341045500d908aa06b802f406130458014f073e011e00b6004f04bd06500652024b024a06510277046d05e5029e0727008f04c4070403a502f6068e03960541006002aa01b4019202ae0835026406ce036803740862036d01f5062b087300f2011800c80792007b0889007d070f080807b6079b07210212013e088802da00380702005a02f0086a071a08a0018702a906c7012b0135050702e3060c0347007803b001ae0321051d0110025f02ca054d0450024504610375065b044906460380066305100790077605ee06b6048a076c089803cb01570748001902b300ae050a077b01e6027a0066017907e701ec071d03f0040202150552044e07600146055d080707c403ab014708a7029b0806009d07230853057e028302a301420086030e078e01b2088b04dc02760055045c025b075806bd059b026c051902c9010501be00c70307020100c100bb011407d004c500d807420282019b05fb03180399033f04b0068f059407ed00040824051f038200dd034f0476021c05f50191050c0262017507790032067f00ad077d01ab04da009800a0083f070c066c01a3072207800581042006e5068d04f0022003f204ba051602c60536006406cd080a01fe00c50236084306fa068205c307c002f10295027d07a1067003a20834015406b0026f044207a0079e03de026b04e307bb01d9016802b8067402500542080100ab019f002b053d0011048305c707eb039a07e801490626078d087402eb075705d206a7056b00d303df07520018089904640814057d072800ed05ac005e0218022505f80049043902ad007500800092021f028d072d07da055b041f01bf040807010625065d0208074c084f040a0062079105c60338031604e90020035f0376052a02ab0669075d08a202be04fd04e00576014d028601e00522040e03c506cf01fb056a03ea0193004404fe01cb08540163087a025405110607003105b401cc063704e2063b0690004a03fd0324065f0263011b049606110361071b081c00f4000e0127000202d7079d064703d80131042c031a082c061b0586085907f3000a07cb01da07440490003f04a104190083041d013c046f0773044808ae03f30178028907050454057a029801a60329057006a902b10328015a08190503073c06bc041b020d037a01e801e2074d03c3066d07d6032e06220325011f081508a101d00687008408500180081f04ee03dd048f0037023e038d07be073f07ab037301e701ed089f06f305f7074f07b40013068a04c9045303020269004502d207b8017e055a0248056201f6018202b906ea0035082b04d703a701240281043b053f042b03f70460018e0366023f04e500c0037e07b3035b00e2017205b105d8089b038f02cf00280053058405e808320073035505a1051805af0017023408a4064505be067a001008480233003e02bf05c104670226048d00f104b9047c05930258004c055900ec052101f0072e0478010803f8051e03fc071102840707011605bd039101fc025e007f067207560365079301a80732000700e802d007f604ca088f01e90771020203ee08a604f605740658062a0267087c06ff03e5012201c905f104c00549034b03c40829069b0595002a04770040056c013202e6080c0833053c00fe063002af06df03b60855014e07b507db00e60487036f041c080307550532024604c703d107fe026d0679009c048501530337061607a802b602c0085b06b5007701e1017402c1032b05eb05120069061d01bc051a061e041404c203c00634054a079907860412069604d3026605d90688048e03e7048b05390330005b07310860034e06320249069f011c059000850130056900ea00de07e600810167022a001d046a06ef049a088505f9040b05c804e400c601c8032a0612040d021d001e060506540810045707e1072b032202c805ef045e08ac044304b50353073306b904ab05a901dd00e007bf01f3015c0505029901e4022c0664057705fa015006d308770024000800a1019605b007530638037b022902b5074b004b050d024e0794070303130437007903ba020904ae07960761031503b7061c0423042503fa07f100270198045d001f014404d001260351053100fa0537020408870446048206e4043a049701510006054802e801c1021600a9035a04cb06fb02e1023901660809021104cd06c1050e03a005de00d202fc031f000304f40880072f02f905250768048006e00566054307ce044c00b20021070906c206c5016d06d006ba058904f301b506cc03ef047204920393066603c8044b02070523031c06ab02bc025c052805ec072903880743035905e205ba039202e5065706f101c60620067d045a068503d905d10621036005ab07c207d1079a05130120002504b4076f005000e9039f063a07b10398083c002f0343031b06a60890001202d4084a0820082507890434060d0468044705ce087001ba01450104065a01c705f4060104a80015067e02a500db0629078b056f049e024006d1028c06a500e4082100ba03f40265038c01f9062402510039076a07de06e9059a034505bb00be00aa086d06f0005102f701c005b8010104ce0489069302ba042907ef030c03dc010f042a07c7066b02a4020b041603830252037c0895058500cd046e029f0129040007d30260038a07d2058305c5002300700022010302e704a6010706a801f400f904db04dd071302e2025603bb077e055506ca04af07bd07d502ff07d80686069c07460841021306dd062f007a047005c2007c064b086c017f07ff02e9088a009001fa0568072a0417004605e307e0027107e503bd04eb018408670356019d019c01d502210571052c004e0320064101ee08a800a706f60494059d";
    // solhint-disable-next-line private-vars-leading-underscore
    uint256 private currentIndex = 1;
    
    // This is a packed array of booleans, chunked by phases.
    // solhint-disable-next-line private-vars-leading-underscore
    mapping(uint256 => mapping(uint256 => uint256)) private claimedBitMap;

    IMintable public nftContract;

    event NewNFTContract(address nftContract);
    event NewPhase(uint256 indexed phase, bytes32 merkleRoot);
    event NewPrice(uint256 price, uint256 pricePublic);
    event NewMint(address indexed owner, uint256 indexed nftId, uint256 price, uint256 merkleIndex);

    /**
     * @dev Contract deployment.
     *
     * @param _owner Address which controls the mint phases.
     * @param _beneficiary Address which recieves ETH payments for mints.
     */
    constructor(address _owner, address payable _beneficiary) Owned(_owner) {
        TRUSTED_BENEFICIARY = _beneficiary;
    }

    /**
     * @dev Owner can set an NFT contract which would be used in minting.
     *
     * @param _nftContractAddress Address of NFT contract.
     * @param _merkleRoot Initial Merkle root for GTD phase.
     */
    function ownerSetNFTContract(address _nftContractAddress, bytes32 _merkleRoot) external onlyOwner {
        require(address(nftContract) == address(0), "NFT contract is set once");
        nftContract = IMintable(_nftContractAddress);
        merkleRoot = _merkleRoot;
        emit NewNFTContract(_nftContractAddress);
        emit NewPhase(0, _merkleRoot);
        emit NewPrice(0.05 ether, 0.065 ether);
    }

    /**
     * @dev Owner can switch to GTD, FCFS and public phases.
     *
     * @param _phase 0 - preparation, 1 - GTD, 2 - FCFS, 3 - public.
     */
    function ownerSetPhase(uint256 _phase, bytes32 _merkleRoot) external onlyOwner {
        require(_phase >= 1 && _phase <= 3, "Invalid phase.");
        phase = _phase;
        merkleRoot = _merkleRoot;
        emit NewPhase(_phase, _merkleRoot);
    }

    /**
     * @dev Owner can set the price for GTD, FCFS and public phases.
     *
     * @param _price whitelisted price for mint.
     * @param _pricePublic public price for mint.
     */
    function ownerSetPrice(uint256 _price, uint256 _pricePublic) external onlyOwner {
        require(_price >= 0 && _pricePublic >= 0, "Negative price.");
        price = _price;
        pricePublic = _pricePublic;
        emit NewPrice(_price, _pricePublic);
    }

    /**
     * @dev Mint new NFT in a preparation phase to the team and ambassadors.
     *
     * @param _account Address which will own minted NFT.
     */
    function ownerPremintTo(address _account) external onlyOwner returns (uint256) {
        require(phase == 0, "Premint finished!");
        require(currentIndex < 101, "Max premint 100 NFTs!");
        return _mintTo(_account, 0, 0);
    }

    /**
     * @dev Mint new NFT in a public phase.
     *
     * @param _account Address which will own minted NFT.
     */
    function mintTo(address _account) external payable nonReentrant returns (uint256) {
        require(phase == 3, "Not public, yet");
        return _mintTo(_account, pricePublic, 0);
    }

    /**
     * @dev Mint new NFT in GTD or FCFS phases.
     *
     * @param _account Address which will own minted NFT.
     * @param _index Merkle proof index.
     * @param _merkleProof Whitelisting ticket.
     */
    function mintTo(address _account, uint256 _index, bytes32[] calldata _merkleProof) external payable nonReentrant returns (uint256) {
        uint256 _phase = phase;
        require(_phase > 0, "Mint not started!");
        require(!_isClaimed(_index, _phase), 'Whitelist already used.');

        // Verify the merkle proof.
        bytes32 _node = keccak256(abi.encodePacked(_index, _account, uint256(1)));
        require(MerkleProofLib.verify(_merkleProof, merkleRoot, _node), 'Invalid proof.');

        // Mark it claimed and send the token.
        _setClaimed(_index, _phase);
        return _mintTo(_account, price, _index);
    }

    /**
     * @dev Check if specific user has claimed his NFT in a current phase.
     *
     * @param _index Whitelist index.
     */
    function isClaimed(uint256 _index) public view returns (bool) {
        return _isClaimed(_index, phase);
    }

    /**
     * @dev Check if specific interface is implemented.
     *
     * @param _interfaceID Keccak of matched interface.
     * @return true if interface is implemented.
     */
    function supportsInterface(bytes4 _interfaceID) public view override returns (bool) {
        return _interfaceID == _MINT_WITH_WHITELIST || super.supportsInterface(_interfaceID);
    }

    /**
     * @dev Storage optimisation for checking specific whitelist claim.
     *
     * @param _account Address which would own minted NFT.
     * @param _price The price of mint.
     * @param _index Merkle tree index, 0 for public phase.
     * @return minted id.
     */
    function _mintTo(address _account, uint256 _price, uint256 _index) internal returns (uint256) {
        // Max id is checked on NFT contract level
        uint256 _i = currentIndex;
        currentIndex++;

        if (_price > 0) {
            require(msg.value >= _price, "not enough ETH to mint");
            (bool success,) = TRUSTED_BENEFICIARY.call{value: msg.value}("");
            require(success, "ETH transfer failed.");
        }

        uint256 _id = _getId(_i);
        nftContract.mintTo(_account, _id);
        emit NewMint(_account, _id, _price, _index);
        return _id;
    }

    /**
     * @dev Storage optimisation for checking specific whitelist claim.
     *
     * @param _index Whitelist index.
     * @param _phase Minting phase.
     */
    function _isClaimed(uint256 _index, uint256 _phase) internal view returns (bool) {
        uint256 _claimedWordIndex = _index / 256;
        uint256 _claimedBitIndex = _index % 256;
        uint256 _claimedWord = claimedBitMap[_phase][_claimedWordIndex];
        uint256 _mask = (1 << _claimedBitIndex);
        return _claimedWord & _mask == _mask;
    }

    /**
     * @dev Mark airdrop in a current round as claimed.
     *
     * @param _index Whitelist index.
     * @param _phase Minting phase.
     */
    function _setClaimed(uint256 _index, uint256 _phase) private {
        uint256 _claimedWordIndex = _index / 256;
        uint256 _claimedBitIndex = _index % 256;
        claimedBitMap[_phase][_claimedWordIndex] = claimedBitMap[_phase][_claimedWordIndex] | (1 << _claimedBitIndex);
    }

    /**
     * @dev Based on _i offset extract id of NFT.
     *
     * @param _i Index of token id.
     * @return semi-random NFT id.
     */
    function _getId(uint256 _i) private pure returns (uint16) {
        uint16 _id;
        bytes memory _ids = _ALL_IDS;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            _id := and(mload(add(_ids, mul(_i, 2))), 0xFFFF)
        }
        return _id;
    }
}