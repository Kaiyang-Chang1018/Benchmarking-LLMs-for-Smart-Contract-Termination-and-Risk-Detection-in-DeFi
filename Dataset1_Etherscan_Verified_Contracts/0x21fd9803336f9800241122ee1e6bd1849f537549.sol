// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.12;

import {RSAVerify} from "@ensdomains/ens-contracts/contracts/dnssec-oracle/algorithms/RSAVerify.sol";
import {BytesUtils} from "@ensdomains/ens-contracts/contracts/dnssec-oracle/BytesUtils.sol";
import {Base64} from "base64/base64.sol";
import {Asn1Decode, NodePtr} from "./Asn1Decode.sol";
import {LCPUtils} from "./LCPUtils.sol";
import {ILCPClientErrors} from "./ILCPClientErrors.sol";

/**
 * @dev AVRValidator provides the validation functions of Intel's Attestation Verification Report(AVR)
 *      An AVR is signed with Intel's signing key, and the signing key is certified by Intel's Root CA.
 */
library AVRValidator {
    using Asn1Decode for bytes;
    using BytesUtils for bytes;

    // OID_SHA256_WITH_RSA_ENCRYPTION is the OID of sha256WithRSAEncryption(1.2.840.113549.1.1.11)
    bytes32 internal constant OID_SHA256_WITH_RSA_ENCRYPTION =
        0x2a864886f70d01010b0000000000000000000000000000000000000000000000;
    // OID_RSA_ENCRYPTION is the OID of rsaEncryption(1.2.840.113549.1.1.1)
    bytes32 internal constant OID_RSA_ENCRYPTION = 0x2a864886f70d0101010000000000000000000000000000000000000000000000;
    // FLAG_DISALLOWED indicates that the advisory or quote status is not allowed.
    uint256 internal constant FLAG_DISALLOWED = 0;
    // FLAG_ALLOWED indicates that the advisory or quote status is allowed.
    uint256 internal constant FLAG_ALLOWED = 1;
    // '"'
    bytes32 internal constant CHAR_DOUBLE_QUOTE = bytes32(hex"22");
    // ','
    bytes32 internal constant CHAR_COMMA = bytes32(hex"2c");
    // '['
    bytes32 internal constant CHAR_LIST_START = bytes32(hex"5b");
    // ']'
    bytes32 internal constant CHAR_LIST_END = bytes32(hex"5d");

    uint256 internal constant OFFSET_JSON_NUMBER_VALUE = 1;
    uint256 internal constant OFFSET_JSON_STRING_VALUE = 2;
    uint256 internal constant OFFSET_JSON_LIST_VALUE = 1;

    bytes32 internal constant HASHED_GROUP_OUT_OF_DATE = keccak256("GROUP_OUT_OF_DATE");
    bytes32 internal constant HASHED_CONFIGURATION_NEEDED = keccak256("CONFIGURATION_NEEDED");
    bytes32 internal constant HASHED_SW_HARDENING_NEEDED = keccak256("SW_HARDENING_NEEDED");
    bytes32 internal constant HASHED_CONFIGURATION_AND_SW_HARDENING_NEEDED =
        keccak256("CONFIGURATION_AND_SW_HARDENING_NEEDED");

    struct RSAParams {
        bytes modulus;
        bytes exponent;
        uint256 notAfter; // seconds since epoch
    }

    struct ReportAllowedStatus {
        // quote status => flag(0: not allowed, 1: allowed)
        mapping(string => uint256) allowedQuoteStatuses;
        // advisory id => flag(0: not allowed, 1: allowed)
        mapping(string => uint256) allowedAdvisories;
    }

    // ------------------ Public functions ------------------

    struct ReportExtractedElements {
        address enclaveKey;
        address operator;
        uint64 attestationTime;
        bytes32 mrenclave;
    }

    function verifyReport(
        bool developmentMode,
        AVRValidator.RSAParams storage verifiedRootCAParams,
        mapping(bytes32 => AVRValidator.RSAParams) storage verifiedSigningRSAParams,
        ReportAllowedStatus storage allowedStatuses,
        bytes calldata report,
        bytes calldata signingCert,
        bytes calldata signature
    ) public returns (ReportExtractedElements memory) {
        RSAParams storage params = verifiedSigningRSAParams[keccak256(signingCert)];
        if (params.notAfter == 0) {
            if (verifiedRootCAParams.notAfter <= block.timestamp) {
                revert ILCPClientErrors.LCPClientIASRootCertExpired();
            }
            AVRValidator.RSAParams memory p =
                verifySigningCert(verifiedRootCAParams.modulus, verifiedRootCAParams.exponent, signingCert);
            params.modulus = p.modulus;
            params.exponent = p.exponent;
            // NOTE: notAfter is the minimum of rootCACert and signingCert
            if (verifiedRootCAParams.notAfter > p.notAfter) {
                params.notAfter = p.notAfter;
            } else {
                params.notAfter = verifiedRootCAParams.notAfter;
            }
        } else if (params.notAfter <= block.timestamp) {
            revert ILCPClientErrors.LCPClientIASCertExpired();
        }
        if (!verifySignature(sha256(report), signature, params.exponent, params.modulus)) {
            revert ILCPClientErrors.LCPClientAVRInvalidSignature();
        }
        return validateAndExtractElements(developmentMode, report, allowedStatuses);
    }

    /**
     * @dev verifySignature verifies the RSA signature of the report.
     * @param reportSha256 is sha256(AVR)
     * @param signature is the RSA signature of the AVR
     * @param exponent is the exponent of the signing public key
     * @param modulus is the modulus of the signing public key
     */
    function verifySignature(
        bytes32 reportSha256,
        bytes calldata signature,
        bytes memory exponent,
        bytes memory modulus
    ) public view returns (bool) {
        (bool ok, bytes memory result) = RSAVerify.rsarecover(modulus, exponent, signature);
        // Verify it ends with the hash of our data
        return ok && reportSha256 == result.readBytes32(result.length - 32);
    }

    /**
     * @dev verifyRootCACert verifies the root CA certificate.
     *      Please read the comments of parseCertificate for the expected structure of the certificate.
     */
    function verifyRootCACert(bytes calldata rootCACert) public view returns (RSAParams memory) {
        (bytes memory modulus, bytes memory exponent, bytes32 signedData, bytes memory signature, uint256 notAfter) =
            parseCertificate(rootCACert);
        (bool ok, bytes memory result) = RSAVerify.rsarecover(modulus, exponent, signature);
        // Verify it ends with the hash of our data
        require(ok && signedData == result.readBytes32(result.length - 32), "signature verification failed");
        return RSAParams(modulus, exponent, notAfter);
    }

    /**
     * @dev verifySigningCert verifies the signing certificate with the public key of the root CA certificate.
     *      Please read the comments of parseCertificate for the expected structure of the certificate.
     */
    function verifySigningCert(
        bytes memory rootCAPublicKeyModulus,
        bytes memory rootCAPublicKeyExponent,
        bytes calldata signingCert
    ) public view returns (RSAParams memory) {
        (bytes memory modulus, bytes memory exponent, bytes32 signedData, bytes memory signature, uint256 notAfter) =
            parseCertificate(signingCert);
        (bool ok, bytes memory result) =
            RSAVerify.rsarecover(rootCAPublicKeyModulus, rootCAPublicKeyExponent, signature);
        // Verify it ends with the hash of our data
        require(ok && signedData == result.readBytes32(result.length - 32), "signature verification failed");
        return RSAParams(modulus, exponent, notAfter);
    }

    /**
     * @dev validateAndExtractElements try to parse a given report.
     * The parser expects the following structure(pretty printed):
     * {
     *   "id": "120273546145229684841731255506776325150",
     *   "timestamp": "2022-12-01T09:49:53.473230",
     *   "version": 4,
     *   "advisoryURL": "https://security-center.intel.com", // optional
     *   "advisoryIDs": [ // optional
     *      "INTEL-SA-00219",
     *      "INTEL-SA-00289",
     *      "INTEL-SA-00614",
     *      "INTEL-SA-00617",
     *      "INTEL-SA-00477",
     *      "INTEL-SA-00615",
     *      "INTEL-SA-00334"
     *   ],
     *   "isvEnclaveQuoteStatus": "GROUP_OUT_OF_DATE",
     *   // optional
     *   "platformInfoBlob": "1502006504000F00000F0F020202800E0000000000000000000D00000C000000020000000000000BF1FF71C73902CC168C67B32BABE311C8DCD69AA9A065D5DA1F575FA5939FD06B43FC187CDBDF97C972CA863F96A6EA5E6BB7313B5A38E28C2D117C990CEAA9CF3A",
     *   "isvEnclaveQuoteBody": "AgAAAPELAAALAAoAAAAAALCbZcb+Fr6JI5sV5pIlYVt2GdTw6l8Ea6v+ySKOFbzvDQ3//wKAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABwAAAAAAAAAHAAAAAAAAADRdEEo/Gd2j3BUnuFH3PJYMIqpCpDr30GLCEPnHnp+kAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACD1xnnferKFHD2uvYqTXdDA8iZ22kCD5xw7h38CMfOngAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABNFlyxvu2l+vFxOlwhIAe+KlPZewAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
     * }
     */
    function validateAndExtractElements(
        bool developmentMode,
        bytes calldata report,
        ReportAllowedStatus storage allowedStatus
    ) public view returns (ReportExtractedElements memory) {
        // find 'timestamp' key
        (uint256 i, bytes memory timestamp) = consumeTimestampReportJSON(report, 0);
        uint256 checkpoint;

        // find 'version' key
        i = consumeVersionReportJSON(report, i);
        checkpoint = i;

        // find 'isvEnclaveQuoteStatus' key
        bytes memory status;
        (i, status) = consumeIsvEnclaveQuoteStatusReportJSON(report, i);
        // skip the validation for quote status and advisories if status is "OK"
        if (!(status.length == 2 && status[0] == 0x4f && status[1] == 0x4b)) {
            require(
                allowedStatus.allowedQuoteStatuses[string(status)] == FLAG_ALLOWED, "the quote status is not allowed"
            );
            bytes32 h = keccak256(status);
            if (
                h == HASHED_GROUP_OUT_OF_DATE || h == HASHED_CONFIGURATION_NEEDED || h == HASHED_SW_HARDENING_NEEDED
                    || h == HASHED_CONFIGURATION_AND_SW_HARDENING_NEEDED
            ) {
                // find 'advisoryIDs' key and validate them
                checkpoint = consumeAdvisoryIdsReportJSON(report, checkpoint);
                validateAdvisories(report, checkpoint, allowedStatus.allowedAdvisories);
            }
        }

        // find 'platformInfoBlob' key(optional)
        i = consumePlatformInfoBlobReportJSONIfExists(report, i);

        // find 'isvEnclaveQuoteBody' key
        i = consumeIsvEnclaveQuoteBodyReportJSON(report, i);

        // decode isvEnclaveQuoteBody
        // 576 bytes is the length of the quote
        bytes memory quoteDecoded = Base64.decode(string(report[i:i + 576]));

        /**
         * parse the quote fields as follows:
         * https://api.trustedservices.intel.com/documents/sgx-attestation-api-spec.pdf (p.26-27)
         */
        uint8 attributesFlags = quoteDecoded.readUint8(96);
        // check debug flag(0b0000_0010)
        if (developmentMode) {
            require(attributesFlags & uint8(2) != uint8(0), "disallowed production enclave");
        } else {
            require(attributesFlags & uint8(2) == uint8(0), "disallowed debug enclave");
        }
        uint256 attestationTime = LCPUtils.attestationTimestampToSeconds(timestamp);
        require(attestationTime <= type(uint64).max, "timestamp is too large");
        // report data layout
        // |report data type: 1|enclave public key: 20|operator: 20|reserved: 23
        // |368                |369                   |389         |409
        require(quoteDecoded[368] == bytes1(uint8(1)), "report data type is not 1");
        return ReportExtractedElements(
            address(quoteDecoded.readBytes20(369)),
            address(quoteDecoded.readBytes20(389)),
            uint64(attestationTime),
            quoteDecoded.readBytes32(112)
        );
    }

    function validateAdvisories(
        bytes calldata report,
        uint256 offset,
        mapping(string => uint256) storage allowedAdvisories
    ) public view returns (uint256) {
        require(offset < report.length && report[offset] == CHAR_LIST_START);
        offset++;

        uint256 lastStart = offset;
        bool itemStart = false;
        bytes32 chr;

        for (; offset < report.length; offset++) {
            chr = report[offset];
            if (chr == CHAR_DOUBLE_QUOTE) {
                itemStart = !itemStart;
                if (itemStart) {
                    lastStart = offset + 1;
                }
            } else if (chr == CHAR_COMMA) {
                require(
                    allowedAdvisories[string(report[lastStart:lastStart + offset - lastStart - 1])] == FLAG_ALLOWED,
                    "disallowed advisory is included"
                );
            } else if (chr == CHAR_LIST_END) {
                if (offset - lastStart > 0) {
                    require(
                        allowedAdvisories[string(report[lastStart:lastStart + offset - lastStart - 1])] == FLAG_ALLOWED,
                        "disallowed advisory is included"
                    );
                }
                require(!itemStart, "insufficient doubleQuotes number");
                return offset + 1;
            }
        }
        revert("missing listEnd");
    }

    // ------------------ Private functions ------------------

    /**
     * @dev parseCertificate parses a given certificate.
     *      The parser expects the following structure:
     *      - `Certificate.signatureAlgorithm` must be sha256WithRSAEncryption(1.2.840.113549.1.1.11)
     *      - `Certificate.tbsCertificate.signature` must be sha256WithRSAEncryption(1.2.840.113549.1.1.11)
     *      - `Certificate.tbsCertificate.subjectPublicKeyInfo.algorithm` must be rsaEncryption(1.2.840.113549.1.1.1)
     *
     *     https://datatracker.ietf.org/doc/html/rfc5280#section-4.1
     *     Certificate  ::=  SEQUENCE  {
     *         tbsCertificate       TBSCertificate,
     *         signatureAlgorithm   AlgorithmIdentifier,
     *         signatureValue       BIT STRING  }
     *
     *     TBSCertificate  ::=  SEQUENCE  {
     *         version         [0]  EXPLICIT Version DEFAULT v1,
     *         serialNumber         CertificateSerialNumber,
     *         signature            AlgorithmIdentifier,
     *         issuer               Name,
     *         validity             Validity,
     *         subject              Name,
     *         subjectPublicKeyInfo SubjectPublicKeyInfo,
     *         issuerUniqueID  [1]  IMPLICIT UniqueIdentifier OPTIONAL,
     *                                 -- If present, version MUST be v2 or v3
     *         subjectUniqueID [2]  IMPLICIT UniqueIdentifier OPTIONAL,
     *                                 -- If present, version MUST be v2 or v3
     *         extensions      [3]  EXPLICIT Extensions OPTIONAL
     *                                 -- If present, version MUST be v3
     *     }
     * @param cert The der-encoded ASN1 certificate
     * @return modulus of public key
     * @return exponent of public key
     * @return signedData is sha256(tbsCertificate)
     * @return signature of certificate
     * @return notAfter is the timestamp when the certificate is expired
     */
    function parseCertificate(bytes memory cert)
        private
        view
        returns (bytes memory, bytes memory, bytes32 signedData, bytes memory signature, uint256 notAfter)
    {
        // node: tbsCertificate
        uint256 node = cert.firstChildOf(cert.root());
        {
            // n: signatureAlgorithm
            uint256 n = cert.nextSiblingOf(node);
            // ensure that the signature algorithm is sha256WithRSAEncryption
            require(
                cert.bytes32At(cert.firstChildOf(n)) == OID_SHA256_WITH_RSA_ENCRYPTION,
                "signature algorithm is not sha256WithRSAEncryption"
            );
            // n: signatureValue
            n = cert.nextSiblingOf(n);
            signature = cert.bytesAt(n);
            // signedData is sha256(tbsCertificate)
            signedData = sha256(cert.allBytesAt(node));
        }
        // node: version or serial number
        node = cert.firstChildOf(node);
        // version is optional
        // 0xa0(10 1 00000) represents CONTXET_SPECIFIC and CONSTRUCTED and tag 0
        if (cert[NodePtr.ixs(node)] == 0xa0) {
            node = cert.nextSiblingOf(node);
        }
        // node: serial number

        // Signature algorithm
        node = cert.nextSiblingOf(node);
        // ensure that the signature algorithm is sha256WithRSAEncryption
        require(
            cert.bytes32At(cert.firstChildOf(node)) == OID_SHA256_WITH_RSA_ENCRYPTION,
            "signature algorithm is not sha256WithRSAEncryption"
        );

        // Issuer (no need to validate)
        node = cert.nextSiblingOf(node);
        // Validity
        node = cert.nextSiblingOf(node);
        {
            /*
            Validity ::= SEQUENCE {
                notBefore      Time,
                notAfter       Time
            }
            */
            // n: notBefore
            uint256 n = cert.firstChildOf(node);
            require(LCPUtils.rfc5280TimeToSeconds(cert.bytesAt(n)) <= block.timestamp, "certificate is not valid yet");
            notAfter = LCPUtils.rfc5280TimeToSeconds(cert.bytesAt(cert.nextSiblingOf(n)));
            require(block.timestamp <= notAfter, "certificate is expired");
        }
        // Subject (no need to validate)
        node = cert.nextSiblingOf(node);

        /**
         * SubjectPublicKeyInfo ::= SEQUENCE
         *     {
         *     algorithm           AlgorithmIdentifier,
         *     subjectPublicKey    BITSTRING
         *     }
         */
        // subjectPublicKeyInfo
        node = cert.nextSiblingOf(node);
        // algorithm (AlgorithmIdentifier)
        node = cert.firstChildOf(node);
        // https://datatracker.ietf.org/doc/html/rfc5912
        // AlgorithmIdentifier{ALGORITHM-TYPE, ALGORITHM-TYPE:AlgorithmSet} ::=
        //     SEQUENCE {
        //         algorithm   ALGORITHM-TYPE.&id({AlgorithmSet}),
        //         parameters  ALGORITHM-TYPE.
        //                &Params({AlgorithmSet}{@algorithm}) OPTIONAL
        //     }
        // ensure that oid matches rsaEncryption
        require(
            cert.bytes32At(cert.firstChildOf(node)) == OID_RSA_ENCRYPTION, "signature algorithm is not rsaEncryption"
        );

        // subjectPublicKey
        node = cert.nextSiblingOf(node);

        // https://datatracker.ietf.org/doc/html/rfc8017#appendix-A.1.1
        // RSAPublicKey ::= SEQUENCE {
        //     modulus           INTEGER,  -- n
        //     publicExponent    INTEGER   -- e
        // }
        node = cert.firstChildOf(cert.rootOfBitStringAt(node));
        // prefix '00' that represents a positive integer
        require(cert[NodePtr.ixf(node)] == 0, "exponent must be positive");

        return (
            // modulus
            cert.substring(NodePtr.ixf(node) + 1, NodePtr.ixl(node) - NodePtr.ixf(node)),
            // exponent
            cert.bytesAt(cert.nextSiblingOf(node)),
            signedData,
            signature,
            notAfter
        );
    }

    function consumeJSONKey(bytes calldata report, uint256 i, string memory keyStr) private pure returns (uint256) {
        uint256 len = bytes(keyStr).length;
        assert(len > 0 && len <= 32);
        bytes32 key = bytes32(bytes(keyStr));
        uint256 limit = report.length - len - 2;
        unchecked {
            while (
                i < limit
                    && !(
                        bytes32(report[i]) == CHAR_DOUBLE_QUOTE && bytes32(report[i + 1 + len]) == CHAR_DOUBLE_QUOTE
                            && bytes32(report[i + 1:i + 1 + len]) == key
                    )
            ) {
                i++;
            }
        }
        require(i < limit, "key not found");
        // advance the index to the value
        return i + len + 2;
    }

    function consumeTimestampReportJSON(bytes calldata report, uint256 i)
        private
        pure
        returns (uint256, bytes memory)
    {
        i = consumeJSONKey(report, i, "timestamp") + OFFSET_JSON_STRING_VALUE;
        return (i + 26, report[i:i + 26]);
    }

    function consumeVersionReportJSON(bytes calldata report, uint256 i) private pure returns (uint256) {
        i = consumeJSONKey(report, i, "version") + OFFSET_JSON_NUMBER_VALUE;
        // check if the version matches "4,"(0x34, 0x2c)
        require(bytes2(report[i:i + 2]) == bytes2(hex"342c"), "version mismatch");
        return i + 2;
    }

    function consumeAdvisoryIdsReportJSON(bytes calldata report, uint256 i) private pure returns (uint256) {
        return consumeJSONKey(report, i, "advisoryIDs") + OFFSET_JSON_LIST_VALUE;
    }

    function consumeIsvEnclaveQuoteStatusReportJSON(bytes calldata report, uint256 i)
        private
        pure
        returns (uint256, bytes memory)
    {
        i = consumeJSONKey(report, i, "isvEnclaveQuoteStatus") + OFFSET_JSON_STRING_VALUE;
        (bytes memory status, uint256 offset) = LCPUtils.readBytesUntil(report, i, bytes1(CHAR_DOUBLE_QUOTE));
        return (offset + 2, status);
    }

    function consumePlatformInfoBlobReportJSONIfExists(bytes calldata report, uint256 i)
        private
        pure
        returns (uint256)
    {
        if (bytes32(report[i:i + 18]) != bytes32("\"platformInfoBlob\"")) {
            return i;
        } else if (bytes32(report[i + 18 + 1]) != CHAR_DOUBLE_QUOTE) {
            // TODO remove this check after the AVR of the RA simulation is fixed
            return i;
        }
        // "platformInfoBlob":"
        i = i + 18 + 2;
        // TLV Header as hex string
        // 0-2: Type
        // 2-4: Version
        // 4-8: Size
        return i + 8 + hexBytesToUint(bytes4(report[i + 4:i + 8])) * 2;
    }

    function consumeIsvEnclaveQuoteBodyReportJSON(bytes calldata report, uint256 i) private pure returns (uint256) {
        return consumeJSONKey(report, i, "isvEnclaveQuoteBody") + OFFSET_JSON_STRING_VALUE;
    }

    function hexBytesToUint(bytes4 ss) private pure returns (uint256) {
        uint256 val = 0;
        uint8 zero = uint8(48); //0
        uint8 nine = uint8(57); //9
        // solhint-disable-next-line var-name-mixedcase
        uint8 A = uint8(65); //A
        uint8 a = uint8(97); // a
        // solhint-disable-next-line var-name-mixedcase
        uint8 F = uint8(70); //F
        uint8 f = uint8(102); //f
        for (uint256 i = 0; i < 4; ++i) {
            uint8 byt = uint8(ss[i]);
            if (byt >= zero && byt <= nine) byt = byt - zero;
            else if (byt >= a && byt <= f) byt = byt - a + 10;
            else if (byt >= A && byt <= F) byt = byt - A + 10;
            val = (val << 4) | (byt & 0xF);
        }
        return val;
    }
}
// SPDX-License-Identifier: MIT
// This is a fork implementation of https://github.com/JonahGroendal/asn1-decode
// The original code is licensed under MIT License.
/*
MIT License

Copyright (c) 2019 Jonah Groendal

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
pragma solidity ^0.8.12;

import "@ensdomains/ens-contracts/contracts/dnssec-oracle/BytesUtils.sol";

library NodePtr {
    // Unpack first byte index
    function ixs(uint256 self) internal pure returns (uint256) {
        return uint80(self);
    }
    // Unpack first content byte index

    function ixf(uint256 self) internal pure returns (uint256) {
        return uint80(self >> 80);
    }
    // Unpack last content byte index

    function ixl(uint256 self) internal pure returns (uint256) {
        return uint80(self >> 160);
    }
    // Pack 3 uint80s into a uint256

    function getPtr(uint256 _ixs, uint256 _ixf, uint256 _ixl) internal pure returns (uint256) {
        _ixs |= _ixf << 80;
        _ixs |= _ixl << 160;
        return _ixs;
    }
}

library Asn1Decode {
    using NodePtr for uint256;
    using BytesUtils for bytes;

    /*
    * @dev Get the root node. First step in traversing an ASN1 structure
    * @param der The DER-encoded ASN1 structure
    * @return A pointer to the outermost node
    */
    function root(bytes memory der) internal pure returns (uint256) {
        return readNodeLength(der, 0);
    }

    /*
    * @dev Get the root node of an ASN1 structure that's within a bit string value
    * @param der The DER-encoded ASN1 structure
    * @return A pointer to the outermost node
    */
    function rootOfBitStringAt(bytes memory der, uint256 ptr) internal pure returns (uint256) {
        require(der[ptr.ixs()] == 0x03, "Not type BIT STRING");
        return readNodeLength(der, ptr.ixf() + 1);
    }

    /*
    * @dev Get the root node of an ASN1 structure that's within an octet string value
    * @param der The DER-encoded ASN1 structure
    * @return A pointer to the outermost node
    */
    function rootOfOctetStringAt(bytes memory der, uint256 ptr) internal pure returns (uint256) {
        require(der[ptr.ixs()] == 0x04, "Not type OCTET STRING");
        return readNodeLength(der, ptr.ixf());
    }

    /*
    * @dev Get the next sibling node
    * @param der The DER-encoded ASN1 structure
    * @param ptr Points to the indices of the current node
    * @return A pointer to the next sibling node
    */
    function nextSiblingOf(bytes memory der, uint256 ptr) internal pure returns (uint256) {
        return readNodeLength(der, ptr.ixl() + 1);
    }

    /*
    * @dev Get the first child node of the current node
    * @param der The DER-encoded ASN1 structure
    * @param ptr Points to the indices of the current node
    * @return A pointer to the first child node
    */
    function firstChildOf(bytes memory der, uint256 ptr) internal pure returns (uint256) {
        require(der[ptr.ixs()] & 0x20 == 0x20, "Not a constructed type");
        return readNodeLength(der, ptr.ixf());
    }

    /*
    * @dev Use for looping through children of a node (either i or j).
    * @param i Pointer to an ASN1 node
    * @param j Pointer to another ASN1 node of the same ASN1 structure
    * @return True iff j is child of i or i is child of j.
    */
    function isChildOf(uint256 i, uint256 j) internal pure returns (bool) {
        return (((i.ixf() <= j.ixs()) && (j.ixl() <= i.ixl())) || ((j.ixf() <= i.ixs()) && (i.ixl() <= j.ixl())));
    }

    /*
    * @dev Extract value of node from DER-encoded structure
    * @param der The der-encoded ASN1 structure
    * @param ptr Points to the indices of the current node
    * @return Value bytes of node
    */
    function bytesAt(bytes memory der, uint256 ptr) internal pure returns (bytes memory) {
        return der.substring(ptr.ixf(), ptr.ixl() + 1 - ptr.ixf());
    }

    /*
    * @dev Extract entire node from DER-encoded structure
    * @param der The DER-encoded ASN1 structure
    * @param ptr Points to the indices of the current node
    * @return All bytes of node
    */
    function allBytesAt(bytes memory der, uint256 ptr) internal pure returns (bytes memory) {
        return der.substring(ptr.ixs(), ptr.ixl() + 1 - ptr.ixs());
    }

    /*
    * @dev Extract value of node from DER-encoded structure
    * @param der The DER-encoded ASN1 structure
    * @param ptr Points to the indices of the current node
    * @return Value bytes of node as bytes32
    */
    function bytes32At(bytes memory der, uint256 ptr) internal pure returns (bytes32) {
        return der.readBytesN(ptr.ixf(), ptr.ixl() + 1 - ptr.ixf());
    }

    /*
    * @dev Extract value of node from DER-encoded structure
    * @param der The der-encoded ASN1 structure
    * @param ptr Points to the indices of the current node
    * @return Uint value of node
    */
    function uintAt(bytes memory der, uint256 ptr) internal pure returns (uint256) {
        require(der[ptr.ixs()] == 0x02, "Not type INTEGER");
        require(der[ptr.ixf()] & 0x80 == 0, "Not positive");
        uint256 len = ptr.ixl() + 1 - ptr.ixf();
        return uint256(der.readBytesN(ptr.ixf(), len) >> (32 - len) * 8);
    }

    /*
    * @dev Extract value of a positive integer node from DER-encoded structure
    * @param der The DER-encoded ASN1 structure
    * @param ptr Points to the indices of the current node
    * @return Value bytes of a positive integer node
    */
    function uintBytesAt(bytes memory der, uint256 ptr) internal pure returns (bytes memory) {
        require(der[ptr.ixs()] == 0x02, "Not type INTEGER");
        require(der[ptr.ixf()] & 0x80 == 0, "Not positive");
        uint256 valueLength = ptr.ixl() + 1 - ptr.ixf();
        if (der[ptr.ixf()] == 0) {
            return der.substring(ptr.ixf() + 1, valueLength - 1);
        } else {
            return der.substring(ptr.ixf(), valueLength);
        }
    }

    function keccakOfBytesAt(bytes memory der, uint256 ptr) internal pure returns (bytes32) {
        return der.keccak(ptr.ixf(), ptr.ixl() + 1 - ptr.ixf());
    }

    function keccakOfAllBytesAt(bytes memory der, uint256 ptr) internal pure returns (bytes32) {
        return der.keccak(ptr.ixs(), ptr.ixl() + 1 - ptr.ixs());
    }

    /*
    * @dev Extract value of bitstring node from DER-encoded structure
    * @param der The DER-encoded ASN1 structure
    * @param ptr Points to the indices of the current node
    * @return Value of bitstring converted to bytes
    */
    function bitstringAt(bytes memory der, uint256 ptr) internal pure returns (bytes memory) {
        require(der[ptr.ixs()] == 0x03, "Not type BIT STRING");
        // Only 00 padded bitstr can be converted to bytestr!
        require(der[ptr.ixf()] == 0x00);
        uint256 valueLength = ptr.ixl() + 1 - ptr.ixf();
        return der.substring(ptr.ixf() + 1, valueLength - 1);
    }

    function readNodeLength(bytes memory der, uint256 ix) private pure returns (uint256) {
        uint256 length;
        uint80 ixFirstContentByte;
        uint80 ixLastContentByte;
        if ((der[ix + 1] & 0x80) == 0) {
            length = uint8(der[ix + 1]);
            ixFirstContentByte = uint80(ix + 2);
            ixLastContentByte = uint80(ixFirstContentByte + length - 1);
        } else {
            uint8 lengthbytesLength = uint8(der[ix + 1] & 0x7F);
            if (lengthbytesLength == 1) {
                length = der.readUint8(ix + 2);
            } else if (lengthbytesLength == 2) {
                length = der.readUint16(ix + 2);
            } else {
                length = uint256(der.readBytesN(ix + 2, lengthbytesLength) >> (32 - lengthbytesLength) * 8);
            }
            ixFirstContentByte = uint80(ix + 2 + lengthbytesLength);
            ixLastContentByte = uint80(ixFirstContentByte + length - 1);
        }
        return NodePtr.getPtr(ix, ixFirstContentByte, ixLastContentByte);
    }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.12;

interface ILCPClientErrors {
    error LCPClientRootCACertAlreadyInitialized();
    error LCPClientClientStateInvalidLatestHeight();
    error LCPClientClientStateFrozen();
    error LCPClientClientStateInvalidKeyExpiration();
    error LCPClientClientStateInvalidMrenclaveLength();
    error LCPClientClientStateUnexpectedMrenclave();
    error LCPClientClientStateEmptyOperators();
    error LCPClientClientStateInvalidOperatorAddress();
    error LCPClientClientStateInvalidOperatorAddressLength();
    error LCPClientClientStateInvalidOperatorsNonce();
    error LCPClientClientStateUnexpectedOperatorsNonce(uint64 expectedNonce);

    error LCPClientOperatorsInvalidOrder(address prevOperator, address nextOperator);
    error LCPClientClientStateInvalidOperatorsThreshold();

    error LCPClientConsensusStateInvalidTimestamp();
    error LCPClientConsensusStateInvalidStateId();

    error LCPClientClientStateNotFound();
    error LCPClientConsensusStateNotFound();
    error LCPClientUnknownProxyMessageHeader();
    error LCPClientUnknownProtoTypeUrl();

    error LCPClientMembershipVerificationInvalidHeight();
    error LCPClientMembershipVerificationInvalidPrefix();
    error LCPClientMembershipVerificationInvalidPath();
    error LCPClientMembershipVerificationInvalidValue();
    error LCPClientMembershipVerificationInvalidStateId();

    error LCPClientUpdateStateEmittedStatesMustNotEmpty();
    error LCPClientUpdateStatePrevStateIdMustNotEmpty();
    error LCPClientUpdateStateUnexpectedPrevStateId();

    error LCPClientMisbehaviourPrevStatesMustNotEmpty();

    error LCPClientEnclaveKeyNotExist();
    error LCPClientEnclaveKeyExpired();
    error LCPClientEnclaveKeyUnexpectedOperator(address expected, address actual);
    error LCPClientEnclaveKeyUnexpectedExpiredAt();

    error LCPClientOperatorSignaturesInsufficient(uint256 success);

    error LCPClientIASRootCertExpired();
    error LCPClientIASCertExpired();

    error LCPClientAVRInvalidSignature();
    error LCPClientAVRAlreadyExpired();

    error LCPClientInvalidSignaturesLength();

    error LCPClientAVRUnexpectedOperator(address actual, address expected);

    error LCPClientUpdateOperatorsPermissionless();
    error LCPClientUpdateOperatorsSignatureUnexpectedOperator(address actual, address expected);
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.12;

import {LCPClientBase} from "./LCPClientBase.sol";

contract LCPClient is LCPClientBase {
    constructor(address ibcHandler_, bool developmentMode_, bytes memory rootCACert)
        LCPClientBase(ibcHandler_, developmentMode_)
    {
        initializeRootCACert(rootCACert);
    }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.12;

import {ILightClient} from "@hyperledger-labs/yui-ibc-solidity/contracts/core/02-client/ILightClient.sol";
import {IBCHeight} from "@hyperledger-labs/yui-ibc-solidity/contracts/core/02-client/IBCHeight.sol";
import {Height} from "@hyperledger-labs/yui-ibc-solidity/contracts/proto/Client.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {
    IbcLightclientsLcpV1ClientState as ProtoClientState,
    IbcLightclientsLcpV1ConsensusState as ProtoConsensusState,
    IbcLightclientsLcpV1RegisterEnclaveKeyMessage as RegisterEnclaveKeyMessage,
    IbcLightclientsLcpV1UpdateClientMessage as UpdateClientMessage,
    IbcLightclientsLcpV1UpdateOperatorsMessage as UpdateOperatorsMessage
} from "./proto/ibc/lightclients/lcp/v1/LCP.sol";
import {LCPCommitment} from "./LCPCommitment.sol";
import {LCPOperator} from "./LCPOperator.sol";
import {LCPProtoMarshaler} from "./LCPProtoMarshaler.sol";
import {AVRValidator} from "./AVRValidator.sol";
import {ILCPClientErrors} from "./ILCPClientErrors.sol";

abstract contract LCPClientBase is ILightClient, ILCPClientErrors {
    using IBCHeight for Height.Data;

    // --------------------- Data structures ---------------------

    struct ConsensusState {
        bytes32 stateId;
        uint64 timestamp;
    }

    struct EKInfo {
        uint64 expiredAt;
        address operator;
    }

    struct ClientStorage {
        ProtoClientState.Data clientState;
        AVRValidator.ReportAllowedStatus allowedStatuses;
        // height => consensus state
        mapping(uint128 => ConsensusState) consensusStates;
        // enclave key => EKInfo
        mapping(address => EKInfo) ekInfos;
    }

    // --------------------- Events ---------------------

    event RegisteredEnclaveKey(string clientId, address enclaveKey, uint256 expiredAt, address operator);

    // --------------------- Immutable fields ---------------------

    /// @dev ibcHandler is the address of the IBC handler contract.
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    address internal immutable ibcHandler;
    /// @dev if developmentMode is true, the client allows the remote attestation of IAS in development.
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    bool internal immutable developmentMode;

    // --------------------- Storage fields ---------------------

    mapping(string => ClientStorage) internal clientStorages;

    // rootCA's public key parameters
    AVRValidator.RSAParams internal verifiedRootCAParams;
    // keccak256(signingCert) => RSAParams of signing public key
    mapping(bytes32 => AVRValidator.RSAParams) internal verifiedSigningRSAParams;

    // --------------------- Constructor ---------------------

    /// @custom:oz-upgrades-unsafe-allow constructor
    /// @param ibcHandler_ the address of the IBC handler contract
    /// @param developmentMode_ if true, the client allows the enclave debug mode
    constructor(address ibcHandler_, bool developmentMode_) {
        ibcHandler = ibcHandler_;
        developmentMode = developmentMode_;
    }

    // --------------------- Modifiers ---------------------

    modifier onlyIBC() {
        require(msg.sender == ibcHandler);
        _;
    }

    // --------------------- Public methods ---------------------

    /// @dev isDevelopmentMode returns true if the client allows the enclave debug mode.
    function isDevelopmentMode() public view returns (bool) {
        return developmentMode;
    }

    /// @dev initializeRootCACert initializes the root CA's public key parameters.
    /// All contracts that inherit LCPClientBase should call this in the constructor or initializer.
    function initializeRootCACert(bytes memory rootCACert) internal {
        if (verifiedRootCAParams.notAfter != 0) {
            revert LCPClientRootCACertAlreadyInitialized();
        }
        verifiedRootCAParams = AVRValidator.verifyRootCACert(rootCACert);
    }

    /**
     * @dev initializeClient initializes a new client with the given state.
     *      If succeeded, it returns heights at which the consensus state are stored.
     *      The function must be only called by IBCHandler.
     */
    function initializeClient(
        string calldata clientId,
        bytes calldata protoClientState,
        bytes calldata protoConsensusState
    ) public onlyIBC returns (Height.Data memory height) {
        ProtoClientState.Data memory clientState = LCPProtoMarshaler.unmarshalClientState(protoClientState);
        ProtoConsensusState.Data memory consensusState = LCPProtoMarshaler.unmarshalConsensusState(protoConsensusState);

        // validate an initial state
        if (clientState.latest_height.revision_number != 0 || clientState.latest_height.revision_height != 0) {
            revert LCPClientClientStateInvalidLatestHeight();
        }
        if (clientState.frozen) {
            revert LCPClientClientStateFrozen();
        }
        if (clientState.key_expiration == 0) {
            revert LCPClientClientStateInvalidKeyExpiration();
        }
        if (clientState.mrenclave.length != 32) {
            revert LCPClientClientStateInvalidMrenclaveLength();
        }
        if (clientState.operators_nonce != 0) {
            revert LCPClientClientStateInvalidOperatorsNonce();
        }
        if (
            clientState.operators.length != 0
                && (clientState.operators_threshold_numerator == 0 || clientState.operators_threshold_denominator == 0)
        ) {
            revert LCPClientClientStateInvalidOperatorsThreshold();
        }
        if (clientState.operators_threshold_numerator > clientState.operators_threshold_denominator) {
            revert LCPClientClientStateInvalidOperatorsThreshold();
        }
        if (consensusState.timestamp != 0) {
            revert LCPClientConsensusStateInvalidTimestamp();
        }
        if (consensusState.state_id.length != 0) {
            revert LCPClientConsensusStateInvalidStateId();
        }

        // ensure the operators are sorted(ascending order) and unique
        address prev;
        for (uint256 i = 0; i < clientState.operators.length; i++) {
            if (clientState.operators[i].length != 20) {
                revert LCPClientClientStateInvalidOperatorAddressLength();
            }
            address addr = address(bytes20(clientState.operators[i]));
            if (addr == address(0)) {
                revert LCPClientClientStateInvalidOperatorAddress();
            }
            if (prev != address(0)) {
                if (prev >= addr) {
                    revert LCPClientOperatorsInvalidOrder(prev, addr);
                }
            }
            prev = addr;
        }
        ClientStorage storage clientStorage = clientStorages[clientId];
        clientStorage.clientState = clientState;

        // set allowed quote status and advisories
        for (uint256 i = 0; i < clientState.allowed_quote_statuses.length; i++) {
            clientStorage.allowedStatuses.allowedQuoteStatuses[clientState.allowed_quote_statuses[i]] =
                AVRValidator.FLAG_ALLOWED;
        }
        for (uint256 i = 0; i < clientState.allowed_advisory_ids.length; i++) {
            clientStorage.allowedStatuses.allowedAdvisories[clientState.allowed_advisory_ids[i]] =
                AVRValidator.FLAG_ALLOWED;
        }

        return clientState.latest_height;
    }

    /**
     * @dev getTimestampAtHeight returns the timestamp of the consensus state at the given height.
     */
    function getTimestampAtHeight(string calldata clientId, Height.Data calldata height) public view returns (uint64) {
        ConsensusState storage consensusState = clientStorages[clientId].consensusStates[height.toUint128()];
        if (consensusState.timestamp == 0) {
            revert LCPClientConsensusStateNotFound();
        }
        return consensusState.timestamp;
    }

    /**
     * @dev getLatestHeight returns the latest height of the client state corresponding to `clientId`.
     */
    function getLatestHeight(string calldata clientId) public view returns (Height.Data memory) {
        ProtoClientState.Data storage clientState = clientStorages[clientId].clientState;
        if (clientState.latest_height.revision_height == 0) {
            revert LCPClientClientStateNotFound();
        }
        return clientState.latest_height;
    }
    /**
     * @dev getStatus returns the status of the client corresponding to `clientId`.
     */

    function getStatus(string calldata clientId) public view returns (ClientStatus) {
        return clientStorages[clientId].clientState.frozen ? ClientStatus.Frozen : ClientStatus.Active;
    }

    /**
     * @dev getLatestInfo returns the latest height, the latest timestamp, and the status of the client corresponding to `clientId`.
     */
    function getLatestInfo(string calldata clientId)
        public
        view
        returns (Height.Data memory latestHeight, uint64 latestTimestamp, ClientStatus status)
    {
        ClientStorage storage clientStorage = clientStorages[clientId];
        latestHeight = clientStorage.clientState.latest_height;
        latestTimestamp = clientStorage.consensusStates[latestHeight.toUint128()].timestamp;
        status = clientStorage.clientState.frozen ? ClientStatus.Frozen : ClientStatus.Active;
    }

    /**
     * @dev routeUpdateClient returns the calldata to the receiving function of the client message.
     *      Light client contract may encode a client message as other encoding scheme(e.g. ethereum ABI)
     *      Check ADR-001 for details.
     */
    function routeUpdateClient(string calldata clientId, bytes calldata protoClientMessage)
        public
        pure
        returns (bytes4, bytes memory)
    {
        (bytes32 typeUrlHash, bytes memory args) = LCPProtoMarshaler.routeClientMessage(clientId, protoClientMessage);
        if (typeUrlHash == LCPProtoMarshaler.UPDATE_CLIENT_MESSAGE_TYPE_URL_HASH) {
            return (this.updateClient.selector, args);
        } else if (typeUrlHash == LCPProtoMarshaler.REGISTER_ENCLAVE_KEY_MESSAGE_TYPE_URL_HASH) {
            return (this.registerEnclaveKey.selector, args);
        } else if (typeUrlHash == LCPProtoMarshaler.UPDATE_OPERATORS_MESSAGE_TYPE_URL_HASH) {
            return (this.updateOperators.selector, args);
        } else {
            revert LCPClientUnknownProtoTypeUrl();
        }
    }

    /**
     * @dev verifyMembership is a generic proof verification method which verifies a proof of the existence of a value at a given CommitmentPath at the specified height.
     * The caller is expected to construct the full CommitmentPath from a CommitmentPrefix and a standardized path (as defined in ICS 24).
     */
    function verifyMembership(
        string calldata clientId,
        Height.Data calldata height,
        uint64,
        uint64,
        bytes calldata proof,
        bytes memory prefix,
        bytes memory path,
        bytes calldata value
    ) public view returns (bool) {
        (
            LCPCommitment.CommitmentProofs memory commitmentProofs,
            LCPCommitment.VerifyMembershipProxyMessage memory message
        ) = LCPCommitment.parseVerifyMembershipCommitmentProofs(proof);
        ClientStorage storage clientStorage = clientStorages[clientId];
        validateProxyMessage(clientStorage, message, height, prefix, path);
        if (keccak256(value) != message.value) {
            revert LCPClientMembershipVerificationInvalidValue();
        }
        verifyCommitmentProofs(clientStorage, commitmentProofs);
        return true;
    }

    /**
     * @dev verifyNonMembership is a generic proof verification method which verifies the absence of a given CommitmentPath at a specified height.
     * The caller is expected to construct the full CommitmentPath from a CommitmentPrefix and a standardized path (as defined in ICS 24).
     */
    function verifyNonMembership(
        string calldata clientId,
        Height.Data calldata height,
        uint64,
        uint64,
        bytes calldata proof,
        bytes calldata prefix,
        bytes calldata path
    ) public view returns (bool) {
        (
            LCPCommitment.CommitmentProofs memory commitmentProofs,
            LCPCommitment.VerifyMembershipProxyMessage memory message
        ) = LCPCommitment.parseVerifyMembershipCommitmentProofs(proof);
        ClientStorage storage clientStorage = clientStorages[clientId];
        validateProxyMessage(clientStorage, message, height, prefix, path);
        if (message.value != bytes32(0)) {
            revert LCPClientMembershipVerificationInvalidValue();
        }
        verifyCommitmentProofs(clientStorage, commitmentProofs);
        return true;
    }

    function validateProxyMessage(
        ClientStorage storage clientStorage,
        LCPCommitment.VerifyMembershipProxyMessage memory message,
        Height.Data calldata height,
        bytes memory prefix,
        bytes memory path
    ) internal view {
        uint128 messageHeight = message.height.toUint128();
        uint128 heightValue = height.toUint128();
        ConsensusState storage consensusState = clientStorage.consensusStates[messageHeight];
        if (consensusState.stateId == bytes32(0)) {
            revert LCPClientConsensusStateNotFound();
        }
        if (heightValue != messageHeight) {
            revert LCPClientMembershipVerificationInvalidHeight();
        }
        if (keccak256(prefix) != keccak256(message.prefix)) {
            revert LCPClientMembershipVerificationInvalidPrefix();
        }
        if (keccak256(path) != keccak256(message.path)) {
            revert LCPClientMembershipVerificationInvalidPath();
        }
        if (consensusState.stateId != message.stateId) {
            revert LCPClientMembershipVerificationInvalidStateId();
        }
    }

    function verifyCommitmentProofs(
        ClientStorage storage clientStorage,
        LCPCommitment.CommitmentProofs memory commitmentProofs
    ) internal view {
        bytes32 commitment = keccak256(commitmentProofs.message);
        verifySignatures(clientStorage, commitment, commitmentProofs.signatures);
    }

    /**
     * @dev getClientState returns the clientState corresponding to `clientId`.
     *      If it's not found, the function returns false.
     */
    function getClientState(string calldata clientId) public view returns (bytes memory clientStateBytes, bool) {
        ProtoClientState.Data storage clientState = clientStorages[clientId].clientState;
        if (clientState.mrenclave.length == 0) {
            return (clientStateBytes, false);
        }
        return (LCPProtoMarshaler.marshal(clientState), true);
    }

    /**
     * @dev getConsensusState returns the consensusState corresponding to `clientId` and `height`.
     *      If it's not found, the function returns false.
     */
    function getConsensusState(string calldata clientId, Height.Data calldata height)
        public
        view
        returns (bytes memory consensusStateBytes, bool)
    {
        ConsensusState storage consensusState = clientStorages[clientId].consensusStates[height.toUint128()];
        if (consensusState.timestamp == 0 && consensusState.stateId == bytes32(0)) {
            return (consensusStateBytes, false);
        }
        return (LCPProtoMarshaler.marshalConsensusState(consensusState.stateId, consensusState.timestamp), true);
    }

    function verifySignatures(ClientStorage storage clientStorage, bytes32 commitment, bytes[] memory signatures)
        internal
        view
    {
        uint256 sigNum = signatures.length;
        uint256 opNum = clientStorage.clientState.operators.length;
        if (opNum == 0) {
            if (sigNum != 1) {
                revert LCPClientInvalidSignaturesLength();
            }
            ensureActiveKey(clientStorage, verifyECDSASignature(commitment, signatures[0]));
        } else {
            if (sigNum != opNum) {
                revert LCPClientInvalidSignaturesLength();
            }
            uint256 success = 0;
            for (uint256 i = 0; i < sigNum; i++) {
                bytes memory sig = signatures[i];
                if (sig.length != 0) {
                    ensureActiveKey(
                        clientStorage,
                        verifyECDSASignature(commitment, sig),
                        address(bytes20(clientStorage.clientState.operators[i]))
                    );
                    unchecked {
                        success++;
                    }
                }
            }
            ensureSufficientValidSignatures(clientStorage.clientState, success);
        }
    }

    function updateClient(string calldata clientId, UpdateClientMessage.Data calldata message)
        public
        returns (Height.Data[] memory heights)
    {
        ClientStorage storage clientStorage = clientStorages[clientId];
        verifySignatures(clientStorage, keccak256(message.proxy_message), message.signatures);

        LCPCommitment.HeaderedProxyMessage memory hm =
            abi.decode(message.proxy_message, (LCPCommitment.HeaderedProxyMessage));
        if (hm.header == LCPCommitment.LCP_MESSAGE_HEADER_UPDATE_STATE) {
            return updateState(clientStorage, abi.decode(hm.message, (LCPCommitment.UpdateStateProxyMessage)));
        } else if (hm.header == LCPCommitment.LCP_MESSAGE_HEADER_MISBEHAVIOUR) {
            return submitMisbehaviour(clientStorage, abi.decode(hm.message, (LCPCommitment.MisbehaviourProxyMessage)));
        } else {
            revert LCPClientUnknownProxyMessageHeader();
        }
    }

    function updateState(ClientStorage storage clientStorage, LCPCommitment.UpdateStateProxyMessage memory pmsg)
        internal
        returns (Height.Data[] memory heights)
    {
        ConsensusState storage consensusState;
        ProtoClientState.Data storage clientState = clientStorage.clientState;
        if (clientState.frozen) {
            revert LCPClientClientStateFrozen();
        }

        if (clientState.latest_height.revision_number == 0 && clientState.latest_height.revision_height == 0) {
            if (pmsg.emittedStates.length == 0) {
                revert LCPClientUpdateStateEmittedStatesMustNotEmpty();
            }
        } else {
            consensusState = clientStorage.consensusStates[pmsg.prevHeight.toUint128()];
            if (pmsg.prevStateId == bytes32(0)) {
                revert LCPClientUpdateStatePrevStateIdMustNotEmpty();
            }
            if (consensusState.stateId != pmsg.prevStateId) {
                revert LCPClientUpdateStateUnexpectedPrevStateId();
            }
        }

        LCPCommitment.validationContextEval(pmsg.context, block.timestamp * 1e9);

        uint128 latestHeight = clientState.latest_height.toUint128();
        uint128 postHeight = pmsg.postHeight.toUint128();
        if (latestHeight < postHeight) {
            clientState.latest_height = pmsg.postHeight;
        }

        consensusState = clientStorage.consensusStates[postHeight];
        consensusState.stateId = pmsg.postStateId;
        consensusState.timestamp = uint64(pmsg.timestamp);

        heights = new Height.Data[](1);
        heights[0] = pmsg.postHeight;
        return heights;
    }

    function submitMisbehaviour(ClientStorage storage clientStorage, LCPCommitment.MisbehaviourProxyMessage memory pmsg)
        internal
        returns (Height.Data[] memory heights)
    {
        ProtoClientState.Data storage clientState = clientStorage.clientState;
        if (clientState.frozen) {
            revert LCPClientClientStateFrozen();
        }
        uint256 prevStatesNum = pmsg.prevStates.length;
        if (prevStatesNum == 0) {
            revert LCPClientMisbehaviourPrevStatesMustNotEmpty();
        }

        for (uint256 i = 0; i < prevStatesNum; i++) {
            LCPCommitment.PrevState memory prev = pmsg.prevStates[i];
            uint128 prevHeight = prev.height.toUint128();
            if (prev.stateId == bytes32(0)) {
                revert LCPClientUpdateStatePrevStateIdMustNotEmpty();
            }
            if (clientStorage.consensusStates[prevHeight].stateId != prev.stateId) {
                revert LCPClientUpdateStateUnexpectedPrevStateId();
            }
        }

        LCPCommitment.validationContextEval(pmsg.context, block.timestamp * 1e9);

        clientStorage.clientState.frozen = true;
        return heights;
    }

    function registerEnclaveKey(string calldata clientId, RegisterEnclaveKeyMessage.Data calldata message)
        public
        returns (Height.Data[] memory heights)
    {
        ClientStorage storage clientStorage = clientStorages[clientId];
        AVRValidator.ReportExtractedElements memory reElems = AVRValidator.verifyReport(
            developmentMode,
            verifiedRootCAParams,
            verifiedSigningRSAParams,
            clientStorage.allowedStatuses,
            message.report,
            message.signing_cert,
            message.signature
        );

        if (bytes32(clientStorage.clientState.mrenclave) != reElems.mrenclave) {
            revert LCPClientClientStateUnexpectedMrenclave();
        }

        // if `operator_signature` is empty, the operator address is zero
        address operator;
        if (message.operator_signature.length != 0) {
            operator = verifyECDSASignature(
                keccak256(LCPOperator.computeEIP712RegisterEnclaveKey(message.report)), message.operator_signature
            );
        }
        if (reElems.operator != address(0) && reElems.operator != operator) {
            revert LCPClientAVRUnexpectedOperator(operator, reElems.operator);
        }
        uint64 expiredAt = reElems.attestationTime + clientStorage.clientState.key_expiration;
        if (expiredAt <= block.timestamp) {
            revert LCPClientAVRAlreadyExpired();
        }
        EKInfo storage ekInfo = clientStorage.ekInfos[reElems.enclaveKey];
        if (ekInfo.expiredAt != 0) {
            if (ekInfo.operator != operator) {
                revert LCPClientEnclaveKeyUnexpectedOperator(ekInfo.operator, operator);
            }
            if (ekInfo.expiredAt != expiredAt) {
                revert LCPClientEnclaveKeyUnexpectedExpiredAt();
            }
            // NOTE: if the key already exists, don't update any state
            return heights;
        }
        ekInfo.expiredAt = expiredAt;
        ekInfo.operator = operator;

        emit RegisteredEnclaveKey(clientId, reElems.enclaveKey, expiredAt, operator);

        // Note: client and consensus state are not always updated in registerEnclaveKey
        return heights;
    }

    function updateOperators(string calldata clientId, UpdateOperatorsMessage.Data calldata message)
        public
        returns (Height.Data[] memory heights)
    {
        ProtoClientState.Data storage clientState = clientStorages[clientId].clientState;
        uint256 opNum = clientState.operators.length;
        uint256 sigNum = message.signatures.length;
        if (opNum == 0) {
            revert LCPClientUpdateOperatorsPermissionless();
        }
        if (sigNum != opNum) {
            revert LCPClientInvalidSignaturesLength();
        }
        if (message.new_operators_threshold_numerator == 0 || message.new_operators_threshold_denominator == 0) {
            revert LCPClientClientStateInvalidOperatorsThreshold();
        }
        uint64 nonce = clientState.operators_nonce;
        uint64 nextNonce = nonce + 1;
        if (message.nonce != nextNonce) {
            revert LCPClientClientStateUnexpectedOperatorsNonce(nextNonce);
        }
        address[] memory newOperators = new address[](message.new_operators.length);
        for (uint256 i = 0; i < message.new_operators.length; i++) {
            if (message.new_operators[i].length != 20) {
                revert LCPClientClientStateInvalidOperatorAddressLength();
            }
            newOperators[i] = address(bytes20(message.new_operators[i]));
        }
        bytes32 commitment = keccak256(
            LCPOperator.computeEIP712UpdateOperators(
                clientId,
                nextNonce,
                newOperators,
                message.new_operators_threshold_numerator,
                message.new_operators_threshold_denominator
            )
        );
        uint256 success = 0;
        for (uint256 i = 0; i < sigNum; i++) {
            if (message.signatures[i].length > 0) {
                address operator = verifyECDSASignature(commitment, message.signatures[i]);
                if (operator != address(bytes20(clientState.operators[i]))) {
                    revert LCPClientUpdateOperatorsSignatureUnexpectedOperator(
                        operator, address(bytes20(clientState.operators[i]))
                    );
                }
                unchecked {
                    success++;
                }
            }
        }
        ensureSufficientValidSignatures(clientState, success);
        delete clientState.operators;
        // ensure the new operators are sorted(ascending order) and unique
        for (uint256 i = 0; i < newOperators.length; i++) {
            if (i > 0) {
                unchecked {
                    address prev = newOperators[i - 1];
                    if (prev >= newOperators[i]) {
                        revert LCPClientOperatorsInvalidOrder(prev, newOperators[i]);
                    }
                }
            }
            clientState.operators.push(message.new_operators[i]);
        }
        clientState.operators_nonce = nextNonce;
        clientState.operators_threshold_numerator = message.new_operators_threshold_numerator;
        clientState.operators_threshold_denominator = message.new_operators_threshold_denominator;
        return heights;
    }

    function ensureActiveKey(ClientStorage storage clientStorage, address ekAddr, address opAddr) internal view {
        EKInfo storage ekInfo = clientStorage.ekInfos[ekAddr];
        uint256 expiredAt = ekInfo.expiredAt;
        if (expiredAt == 0) {
            revert LCPClientEnclaveKeyNotExist();
        }
        if (expiredAt <= block.timestamp) {
            revert LCPClientEnclaveKeyExpired();
        }
        if (ekInfo.operator != opAddr) {
            revert LCPClientEnclaveKeyUnexpectedOperator(ekInfo.operator, opAddr);
        }
    }

    function ensureActiveKey(ClientStorage storage clientStorage, address ekAddr) internal view {
        EKInfo storage ekInfo = clientStorage.ekInfos[ekAddr];
        uint256 expiredAt = ekInfo.expiredAt;
        if (expiredAt == 0) {
            revert LCPClientEnclaveKeyNotExist();
        }
        if (expiredAt <= block.timestamp) {
            revert LCPClientEnclaveKeyExpired();
        }
    }

    function ensureSufficientValidSignatures(ProtoClientState.Data storage clientState, uint256 success)
        internal
        view
    {
        if (
            success * clientState.operators_threshold_denominator
                < clientState.operators_threshold_numerator * clientState.operators.length
        ) {
            revert LCPClientOperatorSignaturesInsufficient(success);
        }
    }

    function verifyECDSASignature(bytes32 commitment, bytes memory signature, address signer)
        internal
        pure
        returns (bool)
    {
        return verifyECDSASignature(commitment, signature) == signer;
    }

    function verifyECDSASignature(bytes32 commitment, bytes memory signature) internal pure returns (address) {
        if (uint8(signature[64]) < 27) {
            signature[64] = bytes1(uint8(signature[64]) + 27);
        }
        return ECDSA.recover(commitment, signature);
    }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.12;

import {Height} from "@hyperledger-labs/yui-ibc-solidity/contracts/proto/Client.sol";

library LCPCommitment {
    uint16 internal constant LCP_MESSAGE_VERSION = 1;
    uint16 internal constant LCP_MESSAGE_TYPE_UPDATE_STATE = 1;
    uint16 internal constant LCP_MESSAGE_TYPE_STATE = 2;
    uint16 internal constant LCP_MESSAGE_TYPE_MISBEHAVIOUR = 3;
    uint16 internal constant LCP_MESSAGE_CONTEXT_TYPE_EMPTY = 0;
    uint16 internal constant LCP_MESSAGE_CONTEXT_TYPE_TRUSTING_PERIOD = 1;

    bytes32 internal constant LCP_MESSAGE_HEADER_UPDATE_STATE =
        bytes32(uint256(LCP_MESSAGE_VERSION) << 240 | uint256(LCP_MESSAGE_TYPE_UPDATE_STATE) << 224);
    bytes32 internal constant LCP_MESSAGE_HEADER_STATE =
        bytes32(uint256(LCP_MESSAGE_VERSION) << 240 | uint256(LCP_MESSAGE_TYPE_STATE) << 224);
    bytes32 internal constant LCP_MESSAGE_HEADER_MISBEHAVIOUR =
        bytes32(uint256(LCP_MESSAGE_VERSION) << 240 | uint256(LCP_MESSAGE_TYPE_MISBEHAVIOUR) << 224);

    error LCPCommitmentUnexpectedProxyMessageHeader();
    error LCPCommtimentInvalidTrustingPeriodContextLength();
    error LCPCommitmentUnknownValidationContextType();
    error LCPCommtimentTrustingPeriodContextOutOfTrustingPeriod();
    error LCPCommitmentTrustingPeriodHeaderFromFuture();

    struct HeaderedProxyMessage {
        bytes32 header;
        bytes message;
    }

    struct UpdateStateProxyMessage {
        Height.Data prevHeight;
        bytes32 prevStateId;
        Height.Data postHeight;
        bytes32 postStateId;
        uint128 timestamp;
        bytes context;
        EmittedState[] emittedStates;
    }

    struct EmittedState {
        Height.Data height;
        bytes state;
    }

    function parseUpdateStateProxyMessage(bytes calldata messageBytes)
        internal
        pure
        returns (UpdateStateProxyMessage memory)
    {
        HeaderedProxyMessage memory hm = abi.decode(messageBytes, (HeaderedProxyMessage));
        // MSB first
        // 0-1:  version
        // 2-3:  message type
        // 4-31: reserved
        if (hm.header != LCP_MESSAGE_HEADER_UPDATE_STATE) {
            revert LCPCommitmentUnexpectedProxyMessageHeader();
        }
        return abi.decode(hm.message, (UpdateStateProxyMessage));
    }

    struct MisbehaviourProxyMessage {
        PrevState[] prevStates;
        bytes context;
        bytes clientMessage;
    }

    struct PrevState {
        Height.Data height;
        bytes32 stateId;
    }

    function parseMisbehaviourProxyMessage(bytes calldata messageBytes)
        internal
        pure
        returns (MisbehaviourProxyMessage memory)
    {
        HeaderedProxyMessage memory hm = abi.decode(messageBytes, (HeaderedProxyMessage));
        // MSB first
        // 0-1:  version
        // 2-3:  message type
        // 4-31: reserved
        if (hm.header != LCP_MESSAGE_HEADER_MISBEHAVIOUR) {
            revert LCPCommitmentUnexpectedProxyMessageHeader();
        }
        return abi.decode(hm.message, (MisbehaviourProxyMessage));
    }

    struct ValidationContext {
        bytes32 header;
        bytes context;
    }

    struct TrustingPeriodContext {
        uint128 untrustedHeaderTimestamp;
        uint128 trustedStateTimestamp;
        uint128 trustingPeriod;
        uint128 clockDrift;
    }

    function parseValidationContext(bytes memory context) internal pure returns (ValidationContext memory) {
        return abi.decode(context, (ValidationContext));
    }

    function extractContextType(bytes32 header) internal pure returns (uint16) {
        // MSB first
        // 0-1:  type
        // 2-31: reserved
        return uint16(uint256(header) >> 240);
    }

    function validationContextEval(bytes memory context, uint256 currentTimestampNanos) internal pure {
        ValidationContext memory vc = parseValidationContext(context);
        // MSB first
        // 0-1:  type
        // 2-31: reserved
        uint16 contextType = extractContextType(vc.header);
        if (contextType == LCP_MESSAGE_CONTEXT_TYPE_EMPTY) {
            return;
        } else if (contextType == LCP_MESSAGE_CONTEXT_TYPE_TRUSTING_PERIOD) {
            if (vc.context.length != 64) {
                revert LCPCommtimentInvalidTrustingPeriodContextLength();
            }
            return trustingPeriodContextEval(parseTrustingPeriodContext(vc.context), currentTimestampNanos);
        } else {
            revert LCPCommitmentUnknownValidationContextType();
        }
    }

    function parseTrustingPeriodContext(bytes memory context) internal pure returns (TrustingPeriodContext memory) {
        (bytes32 timestamps, bytes32 params) = abi.decode(context, (bytes32, bytes32));
        // timestamps
        // 0-15: untrusted_header_timestamp
        // 16-31: trusted_state_timestamp
        uint128 untrustedHeaderTimestamp = uint128(uint256(timestamps) >> 128);
        uint128 trustedStateTimestamp = uint128(uint256(timestamps));

        // params
        // 0-15: trusting_period
        // 16-31: clock_drift
        uint128 trustingPeriod = uint128(uint256(params) >> 128);
        uint128 clockDrift = uint128(uint256(params));

        return TrustingPeriodContext(untrustedHeaderTimestamp, trustedStateTimestamp, trustingPeriod, clockDrift);
    }

    function trustingPeriodContextEval(TrustingPeriodContext memory context, uint256 currentTimestampNanos)
        internal
        pure
    {
        if (currentTimestampNanos >= context.trustedStateTimestamp + context.trustingPeriod) {
            revert LCPCommtimentTrustingPeriodContextOutOfTrustingPeriod();
        } else if (currentTimestampNanos + context.clockDrift <= context.untrustedHeaderTimestamp) {
            revert LCPCommitmentTrustingPeriodHeaderFromFuture();
        }
        return;
    }

    struct CommitmentProofs {
        bytes message;
        bytes[] signatures;
    }

    struct VerifyMembershipProxyMessage {
        bytes prefix;
        bytes path;
        bytes32 value;
        Height.Data height;
        bytes32 stateId;
    }

    function parseVerifyMembershipProxyMessage(bytes memory messageBytes)
        internal
        pure
        returns (VerifyMembershipProxyMessage memory)
    {
        HeaderedProxyMessage memory hm = abi.decode(messageBytes, (HeaderedProxyMessage));
        // MSB first
        // 0-1:  version
        // 2-3:  message type
        // 4-31: reserved
        if (hm.header != LCP_MESSAGE_HEADER_STATE) {
            revert LCPCommitmentUnexpectedProxyMessageHeader();
        }
        return abi.decode(hm.message, (VerifyMembershipProxyMessage));
    }

    function parseVerifyMembershipCommitmentProofs(bytes calldata commitmentProofsBytes)
        internal
        pure
        returns (CommitmentProofs memory, VerifyMembershipProxyMessage memory)
    {
        CommitmentProofs memory commitmentProofs = abi.decode(commitmentProofsBytes, (CommitmentProofs));
        return (commitmentProofs, parseVerifyMembershipProxyMessage(commitmentProofs.message));
    }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.12;

library LCPOperator {
    type ChainType is uint16;

    bytes32 internal constant TYPEHASH_DOMAIN_SEPARATOR =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)");
    bytes32 internal constant TYPEHASH_REGISTER_ENCLAVE_KEY = keccak256("RegisterEnclaveKey(string avr)");
    bytes32 internal constant TYPEHASH_UPDATE_OPERATORS = keccak256(
        "UpdateOperators(string clientId,uint64 nonce,address[] newOperators,uint64 thresholdNumerator,uint64 thresholdDenominator)"
    );

    bytes32 internal constant DOMAIN_SEPARATOR_NAME = keccak256("LCPClient");
    bytes32 internal constant DOMAIN_SEPARATOR_VERSION = keccak256("1");

    // domainSeparatorUniversal()
    bytes32 internal constant DOMAIN_SEPARATOR_REGISTER_ENCLAVE_KEY =
        0x7fd21c2453e80741907e7ff11fd62ae1daa34c6fc0c2eced821f1c1d3fe88a4c;
    ChainType internal constant CHAIN_TYPE_EVM = ChainType.wrap(1);
    // chainTypeSalt(CHAIN_TYPE_EVM, hex"")
    bytes32 internal constant CHAIN_TYPE_EVM_SALT = keccak256(abi.encodePacked(CHAIN_TYPE_EVM, hex""));

    function chainTypeSalt(ChainType chainType, bytes memory args) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(chainType, args));
    }

    function domainSeparatorUniversal() internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                TYPEHASH_DOMAIN_SEPARATOR, DOMAIN_SEPARATOR_NAME, DOMAIN_SEPARATOR_VERSION, 0, address(0), bytes32(0)
            )
        );
    }

    function domainSeparatorEVM(uint256 chainId, address verifyingContract) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                TYPEHASH_DOMAIN_SEPARATOR,
                DOMAIN_SEPARATOR_NAME,
                DOMAIN_SEPARATOR_VERSION,
                chainId,
                verifyingContract,
                CHAIN_TYPE_EVM_SALT
            )
        );
    }

    function computeEIP712RegisterEnclaveKey(bytes calldata avr) internal pure returns (bytes memory) {
        return abi.encodePacked(
            hex"1901",
            DOMAIN_SEPARATOR_REGISTER_ENCLAVE_KEY,
            keccak256(abi.encode(TYPEHASH_REGISTER_ENCLAVE_KEY, keccak256(avr)))
        );
    }

    function computeEIP712UpdateOperators(
        string calldata clientId,
        uint64 nonce,
        address[] memory newOperators,
        uint64 thresholdNumerator,
        uint64 thresholdDenominator
    ) internal view returns (bytes memory) {
        return computeEIP712UpdateOperators(
            block.chainid, address(this), clientId, nonce, newOperators, thresholdNumerator, thresholdDenominator
        );
    }

    function computeEIP712UpdateOperators(
        uint256 chainId,
        address verifyingContract,
        string calldata clientId,
        uint64 nonce,
        address[] memory newOperators,
        uint64 thresholdNumerator,
        uint64 thresholdDenominator
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(
            hex"1901",
            domainSeparatorEVM(chainId, verifyingContract),
            keccak256(
                abi.encode(
                    TYPEHASH_UPDATE_OPERATORS,
                    keccak256(bytes(clientId)),
                    nonce,
                    keccak256(abi.encodePacked(newOperators)),
                    thresholdNumerator,
                    thresholdDenominator
                )
            )
        );
    }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.12;

import {
    IbcLightclientsLcpV1ClientState as ClientState,
    IbcLightclientsLcpV1ConsensusState as ConsensusState,
    IbcLightclientsLcpV1RegisterEnclaveKeyMessage as RegisterEnclaveKeyMessage,
    IbcLightclientsLcpV1UpdateClientMessage as UpdateClientMessage,
    IbcLightclientsLcpV1UpdateOperatorsMessage as UpdateOperatorsMessage
} from "./proto/ibc/lightclients/lcp/v1/LCP.sol";
import {GoogleProtobufAny as Any} from "@hyperledger-labs/yui-ibc-solidity/contracts/proto/GoogleProtobufAny.sol";

library LCPProtoMarshaler {
    string constant UPDATE_CLIENT_MESSAGE_TYPE_URL = "/ibc.lightclients.lcp.v1.UpdateClientMessage";
    string constant REGISTER_ENCLAVE_KEY_MESSAGE_TYPE_URL = "/ibc.lightclients.lcp.v1.RegisterEnclaveKeyMessage";
    string constant UPDATE_OPERATORS_MESSAGE_TYPE_URL = "/ibc.lightclients.lcp.v1.UpdateOperatorsMessage";
    string constant CLIENT_STATE_TYPE_URL = "/ibc.lightclients.lcp.v1.ClientState";
    string constant CONSENSUS_STATE_TYPE_URL = "/ibc.lightclients.lcp.v1.ConsensusState";

    bytes32 constant UPDATE_CLIENT_MESSAGE_TYPE_URL_HASH = keccak256(abi.encodePacked(UPDATE_CLIENT_MESSAGE_TYPE_URL));
    bytes32 constant REGISTER_ENCLAVE_KEY_MESSAGE_TYPE_URL_HASH =
        keccak256(abi.encodePacked(REGISTER_ENCLAVE_KEY_MESSAGE_TYPE_URL));
    bytes32 constant UPDATE_OPERATORS_MESSAGE_TYPE_URL_HASH =
        keccak256(abi.encodePacked(UPDATE_OPERATORS_MESSAGE_TYPE_URL));
    bytes32 constant CLIENT_STATE_TYPE_URL_HASH = keccak256(abi.encodePacked(CLIENT_STATE_TYPE_URL));
    bytes32 constant CONSENSUS_STATE_TYPE_URL_HASH = keccak256(abi.encodePacked(CONSENSUS_STATE_TYPE_URL));

    function marshal(UpdateClientMessage.Data calldata message) public pure returns (bytes memory) {
        Any.Data memory any;
        any.type_url = UPDATE_CLIENT_MESSAGE_TYPE_URL;
        any.value = UpdateClientMessage.encode(message);
        return Any.encode(any);
    }

    function marshalConsensusState(bytes32 stateId, uint64 timestamp) public pure returns (bytes memory) {
        Any.Data memory anyConsensusState;
        anyConsensusState.type_url = CONSENSUS_STATE_TYPE_URL;
        anyConsensusState.value =
            ConsensusState.encode(ConsensusState.Data({state_id: abi.encodePacked(stateId), timestamp: timestamp}));
        return Any.encode(anyConsensusState);
    }

    function marshal(RegisterEnclaveKeyMessage.Data calldata message) public pure returns (bytes memory) {
        Any.Data memory any;
        any.type_url = REGISTER_ENCLAVE_KEY_MESSAGE_TYPE_URL;
        any.value = RegisterEnclaveKeyMessage.encode(message);
        return Any.encode(any);
    }

    function marshal(ClientState.Data calldata clientState) public pure returns (bytes memory) {
        Any.Data memory anyClientState;
        anyClientState.type_url = CLIENT_STATE_TYPE_URL;
        anyClientState.value = ClientState.encode(clientState);
        return Any.encode(anyClientState);
    }

    function marshal(ConsensusState.Data calldata consensusState) public pure returns (bytes memory) {
        Any.Data memory anyConsensusState;
        anyConsensusState.type_url = CONSENSUS_STATE_TYPE_URL;
        anyConsensusState.value = ConsensusState.encode(consensusState);
        return Any.encode(anyConsensusState);
    }

    function routeClientMessage(string calldata clientId, bytes calldata protoClientMessage)
        public
        pure
        returns (bytes32 typeUrlHash, bytes memory args)
    {
        Any.Data memory anyClientMessage = Any.decode(protoClientMessage);
        typeUrlHash = keccak256(abi.encodePacked(anyClientMessage.type_url));
        if (typeUrlHash == UPDATE_CLIENT_MESSAGE_TYPE_URL_HASH) {
            UpdateClientMessage.Data memory message = UpdateClientMessage.decode(anyClientMessage.value);
            return (typeUrlHash, abi.encode(clientId, message));
        } else if (typeUrlHash == REGISTER_ENCLAVE_KEY_MESSAGE_TYPE_URL_HASH) {
            RegisterEnclaveKeyMessage.Data memory message = RegisterEnclaveKeyMessage.decode(anyClientMessage.value);
            return (typeUrlHash, abi.encode(clientId, message));
        } else if (typeUrlHash == UPDATE_OPERATORS_MESSAGE_TYPE_URL_HASH) {
            UpdateOperatorsMessage.Data memory message = UpdateOperatorsMessage.decode(anyClientMessage.value);
            return (typeUrlHash, abi.encode(clientId, message));
        } else {
            revert("unsupported client message type");
        }
    }

    function unmarshalClientState(bytes calldata bz) public pure returns (ClientState.Data memory clientState) {
        Any.Data memory anyClientState = Any.decode(bz);
        require(
            keccak256(abi.encodePacked(anyClientState.type_url)) == CLIENT_STATE_TYPE_URL_HASH,
            "invalid client state type url"
        );
        return ClientState.decode(anyClientState.value);
    }

    function unmarshalConsensusState(bytes calldata bz)
        public
        pure
        returns (ConsensusState.Data memory consensusState)
    {
        Any.Data memory anyConsensusState = Any.decode(bz);
        require(
            keccak256(abi.encodePacked(anyConsensusState.type_url)) == CONSENSUS_STATE_TYPE_URL_HASH,
            "invalid consensus state type url"
        );
        return ConsensusState.decode(anyConsensusState.value);
    }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.12;

import {BytesUtils} from "@ensdomains/ens-contracts/contracts/dnssec-oracle/BytesUtils.sol";
import {DateTime} from "solidity-datetime/contracts/DateTime.sol";

library LCPUtils {
    error LCPUtilsReadBytesUntilNotFound();
    error LCPUtilsRFC5280TimeToSecondsInvalidFormat(bytes timestamp);
    error LCPUtilsTimestampFromDateTimeInvalidDateTime();

    /**
     * @dev readBytesUntil reads bytes until the needle is found.
     */
    function readBytesUntil(bytes memory src, uint256 offset, bytes1 needle)
        internal
        pure
        returns (bytes memory bz, uint256 pos)
    {
        pos = BytesUtils.find(src, offset, src.length, needle);
        if (pos == type(uint256).max) {
            revert LCPUtilsReadBytesUntilNotFound();
        }
        return (BytesUtils.substring(src, offset, pos - offset), pos);
    }

    /**
     * @dev attestationTimestampToSeconds parses ISO 8601 date time string to unix timestamp in seconds
     *      The parse assumes the format YYYY-MM-DDTHH:mm:ss.ssssss and its timezone is UTC.
     *      The timestamp spec is described in "4.2.1 Report Data" section of the following document:
     *      https://api.trustedservices.intel.com/documents/sgx-attestation-api-spec.pdf
     *      > The time shall be in UTC and the encoding shall be compliant to ISO 8601 standard.
     *      NOTE The parser rounds timestamp to the nearest second.
     * @param timestamp included in Report Data. e.g. 2022-12-01T09:49:53.473230
     */
    function attestationTimestampToSeconds(bytes memory timestamp) internal pure returns (uint256) {
        // ensure the timestamp[10] is 'T'
        require(timestamp.length >= 19 && timestamp[10] == bytes1(uint8(84)));
        return timestampFromDateTime(
            uint256(uint8(timestamp[0]) - 48) * 1000 + uint256(uint8(timestamp[1]) - 48) * 100
                + uint256(uint8(timestamp[2]) - 48) * 10 + uint8(timestamp[3]) - 48, // year
            uint256(uint8(timestamp[5]) - 48) * 10 + uint8(timestamp[6]) - 48, // month
            uint256(uint8(timestamp[8]) - 48) * 10 + uint8(timestamp[9]) - 48, // day
            uint256(uint8(timestamp[11]) - 48) * 10 + uint8(timestamp[12]) - 48, // hour
            uint256(uint8(timestamp[14]) - 48) * 10 + uint8(timestamp[15]) - 48, // minute
            uint256(uint8(timestamp[17]) - 48) * 10 + uint8(timestamp[18]) - 48 // second
        );
    }

    /**
     * @dev parseValidityTime parses X.509 validity time string to unix timestamp in seconds
     *      Its format is YYMMDDHHMMSSZ(UTCTime) or YYYYMMDDHHMMSSZ(GeneralizedTime)
     *      More details:
     *        - https://datatracker.ietf.org/doc/html/rfc5280#section-4.1.2.5.1
     *        - https://datatracker.ietf.org/doc/html/rfc5280#section-4.1.2.5.2
     * @param timestamp e.g. 221201094953Z(UTCTime) or 20221201094953Z(GeneralizedTime)
     */
    function rfc5280TimeToSeconds(bytes memory timestamp) internal pure returns (uint256) {
        uint256 year = 0;
        uint8 offset = 0;
        if (timestamp.length == 13) {
            // UTCTime
            if (uint8(timestamp[0]) - 48 < 5) {
                year += 2000;
            } else {
                year += 1900;
            }
        } else if (timestamp.length == 15) {
            // GeneralizedTime
            year += uint256(uint8(timestamp[0]) - 48) * 1000 + uint256(uint8(timestamp[1]) - 48) * 100;
            offset = 2;
        } else {
            revert LCPUtilsRFC5280TimeToSecondsInvalidFormat(timestamp);
        }
        year += uint256(uint8(timestamp[offset]) - 48) * 10 + uint8(timestamp[offset + 1]) - 48;
        // ensure the last char is 'Z'
        require(timestamp[timestamp.length - 1] == bytes1(uint8(90)));
        return timestampFromDateTime(
            year,
            uint256(uint8(timestamp[offset + 2]) - 48) * 10 + uint8(timestamp[offset + 3]) - 48, // month
            uint256(uint8(timestamp[offset + 4]) - 48) * 10 + uint8(timestamp[offset + 5]) - 48, // day
            uint256(uint8(timestamp[offset + 6]) - 48) * 10 + uint8(timestamp[offset + 7]) - 48, // hour
            uint256(uint8(timestamp[offset + 8]) - 48) * 10 + uint8(timestamp[offset + 9]) - 48, // minute
            uint256(uint8(timestamp[offset + 10]) - 48) * 10 + uint8(timestamp[offset + 11]) - 48 // second
        );
    }

    function timestampFromDateTime(
        uint256 year,
        uint256 month,
        uint256 day,
        uint256 hour,
        uint256 minute,
        uint256 second
    ) private pure returns (uint256) {
        if (!DateTime.isValidDateTime(year, month, day, hour, minute, second)) {
            revert LCPUtilsTimestampFromDateTimeInvalidDateTime();
        }
        return DateTime.timestampFromDateTime(year, month, day, hour, minute, second);
    }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.12;
import "@hyperledger-labs/yui-ibc-solidity/contracts/proto/ProtoBufRuntime.sol";
import "@hyperledger-labs/yui-ibc-solidity/contracts/proto/GoogleProtobufAny.sol";
import "@hyperledger-labs/yui-ibc-solidity/contracts/proto/Client.sol";

library IbcLightclientsLcpV1UpdateClientMessage {


  //struct definition
  struct Data {
    bytes proxy_message;
    bytes[] signatures;
  }

  // Decoder section

  /**
   * @dev The main decoder for memory
   * @param bs The bytes array to be decoded
   * @return The decoded struct
   */
  function decode(bytes memory bs) internal pure returns (Data memory) {
    (Data memory x, ) = _decode(32, bs, bs.length);
    return x;
  }

  /**
   * @dev The main decoder for storage
   * @param self The in-storage struct
   * @param bs The bytes array to be decoded
   */
  function decode(Data storage self, bytes memory bs) internal {
    (Data memory x, ) = _decode(32, bs, bs.length);
    store(x, self);
  }
  // inner decoder

  /**
   * @dev The decoder for internal usage
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param sz The number of bytes expected
   * @return The decoded struct
   * @return The number of bytes decoded
   */
  function _decode(uint256 p, bytes memory bs, uint256 sz)
    internal
    pure
    returns (Data memory, uint)
  {
    Data memory r;
    uint[3] memory counters;
    uint256 fieldId;
    ProtoBufRuntime.WireType wireType;
    uint256 bytesRead;
    uint256 offset = p;
    uint256 pointer = p;
    while (pointer < offset + sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if (fieldId == 1) {
        pointer += _read_proxy_message(pointer, bs, r);
      } else
      if (fieldId == 2) {
        pointer += _read_unpacked_repeated_signatures(pointer, bs, nil(), counters);
      } else
      {
        pointer += ProtoBufRuntime._skip_field_decode(wireType, pointer, bs);
      }

    }
    pointer = offset;
    if (counters[2] > 0) {
      require(r.signatures.length == 0);
      r.signatures = new bytes[](counters[2]);
    }

    while (pointer < offset + sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if (fieldId == 2) {
        pointer += _read_unpacked_repeated_signatures(pointer, bs, r, counters);
      } else
      {
        pointer += ProtoBufRuntime._skip_field_decode(wireType, pointer, bs);
      }
    }
    return (r, sz);
  }

  // field readers

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_proxy_message(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (bytes memory x, uint256 sz) = ProtoBufRuntime._decode_bytes(p, bs);
    r.proxy_message = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_unpacked_repeated_signatures(
    uint256 p,
    bytes memory bs,
    Data memory r,
    uint[3] memory counters
  ) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (bytes memory x, uint256 sz) = ProtoBufRuntime._decode_bytes(p, bs);
    if (isNil(r)) {
      counters[2] += 1;
    } else {
      r.signatures[r.signatures.length - counters[2]] = x;
      counters[2] -= 1;
    }
    return sz;
  }


  // Encoder section

  /**
   * @dev The main encoder for memory
   * @param r The struct to be encoded
   * @return The encoded byte array
   */
  function encode(Data memory r) internal pure returns (bytes memory) {
    bytes memory bs = new bytes(_estimate(r));
    uint256 sz = _encode(r, 32, bs);
    assembly {
      mstore(bs, sz)
    }
    return bs;
  }
  // inner encoder

  /**
   * @dev The encoder for internal usage
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    uint256 offset = p;
    uint256 pointer = p;
    uint256 i;
    if (r.proxy_message.length != 0) {
    pointer += ProtoBufRuntime._encode_key(
      1,
      ProtoBufRuntime.WireType.LengthDelim,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_bytes(r.proxy_message, pointer, bs);
    }
    if (r.signatures.length != 0) {
    for(i = 0; i < r.signatures.length; i++) {
      pointer += ProtoBufRuntime._encode_key(
        2,
        ProtoBufRuntime.WireType.LengthDelim,
        pointer,
        bs)
      ;
      pointer += ProtoBufRuntime._encode_bytes(r.signatures[i], pointer, bs);
    }
    }
    return pointer - offset;
  }
  // nested encoder

  /**
   * @dev The encoder for inner struct
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode_nested(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    /**
     * First encoded `r` into a temporary array, and encode the actual size used.
     * Then copy the temporary array into `bs`.
     */
    uint256 offset = p;
    uint256 pointer = p;
    bytes memory tmp = new bytes(_estimate(r));
    uint256 tmpAddr = ProtoBufRuntime.getMemoryAddress(tmp);
    uint256 bsAddr = ProtoBufRuntime.getMemoryAddress(bs);
    uint256 size = _encode(r, 32, tmp);
    pointer += ProtoBufRuntime._encode_varint(size, pointer, bs);
    ProtoBufRuntime.copyBytes(tmpAddr + 32, bsAddr + pointer, size);
    pointer += size;
    delete tmp;
    return pointer - offset;
  }
  // estimator

  /**
   * @dev The estimator for a struct
   * @param r The struct to be encoded
   * @return The number of bytes encoded in estimation
   */
  function _estimate(
    Data memory r
  ) internal pure returns (uint) {
    uint256 e;uint256 i;
    e += 1 + ProtoBufRuntime._sz_lendelim(r.proxy_message.length);
    for(i = 0; i < r.signatures.length; i++) {
      e += 1 + ProtoBufRuntime._sz_lendelim(r.signatures[i].length);
    }
    return e;
  }
  // empty checker

  function _empty(
    Data memory r
  ) internal pure returns (bool) {
    
  if (r.proxy_message.length != 0) {
    return false;
  }

  if (r.signatures.length != 0) {
    return false;
  }

    return true;
  }


  //store function
  /**
   * @dev Store in-memory struct to storage
   * @param input The in-memory struct
   * @param output The in-storage struct
   */
  function store(Data memory input, Data storage output) internal {
    output.proxy_message = input.proxy_message;
    output.signatures = input.signatures;

  }


  //array helpers for Signatures
  /**
   * @dev Add value to an array
   * @param self The in-memory struct
   * @param value The value to add
   */
  function addSignatures(Data memory self, bytes memory value) internal pure {
    /**
     * First resize the array. Then add the new element to the end.
     */
    bytes[] memory tmp = new bytes[](self.signatures.length + 1);
    for (uint256 i = 0; i < self.signatures.length; i++) {
      tmp[i] = self.signatures[i];
    }
    tmp[self.signatures.length] = value;
    self.signatures = tmp;
  }


  //utility functions
  /**
   * @dev Return an empty struct
   * @return r The empty struct
   */
  function nil() internal pure returns (Data memory r) {
    assembly {
      r := 0
    }
  }

  /**
   * @dev Test whether a struct is empty
   * @param x The struct to be tested
   * @return r True if it is empty
   */
  function isNil(Data memory x) internal pure returns (bool r) {
    assembly {
      r := iszero(x)
    }
  }
}
//library IbcLightclientsLcpV1UpdateClientMessage

library IbcLightclientsLcpV1RegisterEnclaveKeyMessage {


  //struct definition
  struct Data {
    bytes report;
    bytes signature;
    bytes signing_cert;
    bytes operator_signature;
  }

  // Decoder section

  /**
   * @dev The main decoder for memory
   * @param bs The bytes array to be decoded
   * @return The decoded struct
   */
  function decode(bytes memory bs) internal pure returns (Data memory) {
    (Data memory x, ) = _decode(32, bs, bs.length);
    return x;
  }

  /**
   * @dev The main decoder for storage
   * @param self The in-storage struct
   * @param bs The bytes array to be decoded
   */
  function decode(Data storage self, bytes memory bs) internal {
    (Data memory x, ) = _decode(32, bs, bs.length);
    store(x, self);
  }
  // inner decoder

  /**
   * @dev The decoder for internal usage
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param sz The number of bytes expected
   * @return The decoded struct
   * @return The number of bytes decoded
   */
  function _decode(uint256 p, bytes memory bs, uint256 sz)
    internal
    pure
    returns (Data memory, uint)
  {
    Data memory r;
    uint256 fieldId;
    ProtoBufRuntime.WireType wireType;
    uint256 bytesRead;
    uint256 offset = p;
    uint256 pointer = p;
    while (pointer < offset + sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if (fieldId == 1) {
        pointer += _read_report(pointer, bs, r);
      } else
      if (fieldId == 2) {
        pointer += _read_signature(pointer, bs, r);
      } else
      if (fieldId == 3) {
        pointer += _read_signing_cert(pointer, bs, r);
      } else
      if (fieldId == 4) {
        pointer += _read_operator_signature(pointer, bs, r);
      } else
      {
        pointer += ProtoBufRuntime._skip_field_decode(wireType, pointer, bs);
      }

    }
    return (r, sz);
  }

  // field readers

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_report(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (bytes memory x, uint256 sz) = ProtoBufRuntime._decode_bytes(p, bs);
    r.report = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_signature(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (bytes memory x, uint256 sz) = ProtoBufRuntime._decode_bytes(p, bs);
    r.signature = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_signing_cert(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (bytes memory x, uint256 sz) = ProtoBufRuntime._decode_bytes(p, bs);
    r.signing_cert = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_operator_signature(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (bytes memory x, uint256 sz) = ProtoBufRuntime._decode_bytes(p, bs);
    r.operator_signature = x;
    return sz;
  }


  // Encoder section

  /**
   * @dev The main encoder for memory
   * @param r The struct to be encoded
   * @return The encoded byte array
   */
  function encode(Data memory r) internal pure returns (bytes memory) {
    bytes memory bs = new bytes(_estimate(r));
    uint256 sz = _encode(r, 32, bs);
    assembly {
      mstore(bs, sz)
    }
    return bs;
  }
  // inner encoder

  /**
   * @dev The encoder for internal usage
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    uint256 offset = p;
    uint256 pointer = p;
    
    if (r.report.length != 0) {
    pointer += ProtoBufRuntime._encode_key(
      1,
      ProtoBufRuntime.WireType.LengthDelim,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_bytes(r.report, pointer, bs);
    }
    if (r.signature.length != 0) {
    pointer += ProtoBufRuntime._encode_key(
      2,
      ProtoBufRuntime.WireType.LengthDelim,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_bytes(r.signature, pointer, bs);
    }
    if (r.signing_cert.length != 0) {
    pointer += ProtoBufRuntime._encode_key(
      3,
      ProtoBufRuntime.WireType.LengthDelim,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_bytes(r.signing_cert, pointer, bs);
    }
    if (r.operator_signature.length != 0) {
    pointer += ProtoBufRuntime._encode_key(
      4,
      ProtoBufRuntime.WireType.LengthDelim,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_bytes(r.operator_signature, pointer, bs);
    }
    return pointer - offset;
  }
  // nested encoder

  /**
   * @dev The encoder for inner struct
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode_nested(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    /**
     * First encoded `r` into a temporary array, and encode the actual size used.
     * Then copy the temporary array into `bs`.
     */
    uint256 offset = p;
    uint256 pointer = p;
    bytes memory tmp = new bytes(_estimate(r));
    uint256 tmpAddr = ProtoBufRuntime.getMemoryAddress(tmp);
    uint256 bsAddr = ProtoBufRuntime.getMemoryAddress(bs);
    uint256 size = _encode(r, 32, tmp);
    pointer += ProtoBufRuntime._encode_varint(size, pointer, bs);
    ProtoBufRuntime.copyBytes(tmpAddr + 32, bsAddr + pointer, size);
    pointer += size;
    delete tmp;
    return pointer - offset;
  }
  // estimator

  /**
   * @dev The estimator for a struct
   * @param r The struct to be encoded
   * @return The number of bytes encoded in estimation
   */
  function _estimate(
    Data memory r
  ) internal pure returns (uint) {
    uint256 e;
    e += 1 + ProtoBufRuntime._sz_lendelim(r.report.length);
    e += 1 + ProtoBufRuntime._sz_lendelim(r.signature.length);
    e += 1 + ProtoBufRuntime._sz_lendelim(r.signing_cert.length);
    e += 1 + ProtoBufRuntime._sz_lendelim(r.operator_signature.length);
    return e;
  }
  // empty checker

  function _empty(
    Data memory r
  ) internal pure returns (bool) {
    
  if (r.report.length != 0) {
    return false;
  }

  if (r.signature.length != 0) {
    return false;
  }

  if (r.signing_cert.length != 0) {
    return false;
  }

  if (r.operator_signature.length != 0) {
    return false;
  }

    return true;
  }


  //store function
  /**
   * @dev Store in-memory struct to storage
   * @param input The in-memory struct
   * @param output The in-storage struct
   */
  function store(Data memory input, Data storage output) internal {
    output.report = input.report;
    output.signature = input.signature;
    output.signing_cert = input.signing_cert;
    output.operator_signature = input.operator_signature;

  }



  //utility functions
  /**
   * @dev Return an empty struct
   * @return r The empty struct
   */
  function nil() internal pure returns (Data memory r) {
    assembly {
      r := 0
    }
  }

  /**
   * @dev Test whether a struct is empty
   * @param x The struct to be tested
   * @return r True if it is empty
   */
  function isNil(Data memory x) internal pure returns (bool r) {
    assembly {
      r := iszero(x)
    }
  }
}
//library IbcLightclientsLcpV1RegisterEnclaveKeyMessage

library IbcLightclientsLcpV1UpdateOperatorsMessage {


  //struct definition
  struct Data {
    uint64 nonce;
    bytes[] new_operators;
    uint64 new_operators_threshold_numerator;
    uint64 new_operators_threshold_denominator;
    bytes[] signatures;
  }

  // Decoder section

  /**
   * @dev The main decoder for memory
   * @param bs The bytes array to be decoded
   * @return The decoded struct
   */
  function decode(bytes memory bs) internal pure returns (Data memory) {
    (Data memory x, ) = _decode(32, bs, bs.length);
    return x;
  }

  /**
   * @dev The main decoder for storage
   * @param self The in-storage struct
   * @param bs The bytes array to be decoded
   */
  function decode(Data storage self, bytes memory bs) internal {
    (Data memory x, ) = _decode(32, bs, bs.length);
    store(x, self);
  }
  // inner decoder

  /**
   * @dev The decoder for internal usage
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param sz The number of bytes expected
   * @return The decoded struct
   * @return The number of bytes decoded
   */
  function _decode(uint256 p, bytes memory bs, uint256 sz)
    internal
    pure
    returns (Data memory, uint)
  {
    Data memory r;
    uint[6] memory counters;
    uint256 fieldId;
    ProtoBufRuntime.WireType wireType;
    uint256 bytesRead;
    uint256 offset = p;
    uint256 pointer = p;
    while (pointer < offset + sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if (fieldId == 1) {
        pointer += _read_nonce(pointer, bs, r);
      } else
      if (fieldId == 2) {
        pointer += _read_unpacked_repeated_new_operators(pointer, bs, nil(), counters);
      } else
      if (fieldId == 3) {
        pointer += _read_new_operators_threshold_numerator(pointer, bs, r);
      } else
      if (fieldId == 4) {
        pointer += _read_new_operators_threshold_denominator(pointer, bs, r);
      } else
      if (fieldId == 5) {
        pointer += _read_unpacked_repeated_signatures(pointer, bs, nil(), counters);
      } else
      {
        pointer += ProtoBufRuntime._skip_field_decode(wireType, pointer, bs);
      }

    }
    pointer = offset;
    if (counters[2] > 0) {
      require(r.new_operators.length == 0);
      r.new_operators = new bytes[](counters[2]);
    }
    if (counters[5] > 0) {
      require(r.signatures.length == 0);
      r.signatures = new bytes[](counters[5]);
    }

    while (pointer < offset + sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if (fieldId == 2) {
        pointer += _read_unpacked_repeated_new_operators(pointer, bs, r, counters);
      } else
      if (fieldId == 5) {
        pointer += _read_unpacked_repeated_signatures(pointer, bs, r, counters);
      } else
      {
        pointer += ProtoBufRuntime._skip_field_decode(wireType, pointer, bs);
      }
    }
    return (r, sz);
  }

  // field readers

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_nonce(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (uint64 x, uint256 sz) = ProtoBufRuntime._decode_uint64(p, bs);
    r.nonce = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_unpacked_repeated_new_operators(
    uint256 p,
    bytes memory bs,
    Data memory r,
    uint[6] memory counters
  ) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (bytes memory x, uint256 sz) = ProtoBufRuntime._decode_bytes(p, bs);
    if (isNil(r)) {
      counters[2] += 1;
    } else {
      r.new_operators[r.new_operators.length - counters[2]] = x;
      counters[2] -= 1;
    }
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_new_operators_threshold_numerator(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (uint64 x, uint256 sz) = ProtoBufRuntime._decode_uint64(p, bs);
    r.new_operators_threshold_numerator = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_new_operators_threshold_denominator(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (uint64 x, uint256 sz) = ProtoBufRuntime._decode_uint64(p, bs);
    r.new_operators_threshold_denominator = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_unpacked_repeated_signatures(
    uint256 p,
    bytes memory bs,
    Data memory r,
    uint[6] memory counters
  ) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (bytes memory x, uint256 sz) = ProtoBufRuntime._decode_bytes(p, bs);
    if (isNil(r)) {
      counters[5] += 1;
    } else {
      r.signatures[r.signatures.length - counters[5]] = x;
      counters[5] -= 1;
    }
    return sz;
  }


  // Encoder section

  /**
   * @dev The main encoder for memory
   * @param r The struct to be encoded
   * @return The encoded byte array
   */
  function encode(Data memory r) internal pure returns (bytes memory) {
    bytes memory bs = new bytes(_estimate(r));
    uint256 sz = _encode(r, 32, bs);
    assembly {
      mstore(bs, sz)
    }
    return bs;
  }
  // inner encoder

  /**
   * @dev The encoder for internal usage
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    uint256 offset = p;
    uint256 pointer = p;
    uint256 i;
    if (r.nonce != 0) {
    pointer += ProtoBufRuntime._encode_key(
      1,
      ProtoBufRuntime.WireType.Varint,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_uint64(r.nonce, pointer, bs);
    }
    if (r.new_operators.length != 0) {
    for(i = 0; i < r.new_operators.length; i++) {
      pointer += ProtoBufRuntime._encode_key(
        2,
        ProtoBufRuntime.WireType.LengthDelim,
        pointer,
        bs)
      ;
      pointer += ProtoBufRuntime._encode_bytes(r.new_operators[i], pointer, bs);
    }
    }
    if (r.new_operators_threshold_numerator != 0) {
    pointer += ProtoBufRuntime._encode_key(
      3,
      ProtoBufRuntime.WireType.Varint,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_uint64(r.new_operators_threshold_numerator, pointer, bs);
    }
    if (r.new_operators_threshold_denominator != 0) {
    pointer += ProtoBufRuntime._encode_key(
      4,
      ProtoBufRuntime.WireType.Varint,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_uint64(r.new_operators_threshold_denominator, pointer, bs);
    }
    if (r.signatures.length != 0) {
    for(i = 0; i < r.signatures.length; i++) {
      pointer += ProtoBufRuntime._encode_key(
        5,
        ProtoBufRuntime.WireType.LengthDelim,
        pointer,
        bs)
      ;
      pointer += ProtoBufRuntime._encode_bytes(r.signatures[i], pointer, bs);
    }
    }
    return pointer - offset;
  }
  // nested encoder

  /**
   * @dev The encoder for inner struct
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode_nested(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    /**
     * First encoded `r` into a temporary array, and encode the actual size used.
     * Then copy the temporary array into `bs`.
     */
    uint256 offset = p;
    uint256 pointer = p;
    bytes memory tmp = new bytes(_estimate(r));
    uint256 tmpAddr = ProtoBufRuntime.getMemoryAddress(tmp);
    uint256 bsAddr = ProtoBufRuntime.getMemoryAddress(bs);
    uint256 size = _encode(r, 32, tmp);
    pointer += ProtoBufRuntime._encode_varint(size, pointer, bs);
    ProtoBufRuntime.copyBytes(tmpAddr + 32, bsAddr + pointer, size);
    pointer += size;
    delete tmp;
    return pointer - offset;
  }
  // estimator

  /**
   * @dev The estimator for a struct
   * @param r The struct to be encoded
   * @return The number of bytes encoded in estimation
   */
  function _estimate(
    Data memory r
  ) internal pure returns (uint) {
    uint256 e;uint256 i;
    e += 1 + ProtoBufRuntime._sz_uint64(r.nonce);
    for(i = 0; i < r.new_operators.length; i++) {
      e += 1 + ProtoBufRuntime._sz_lendelim(r.new_operators[i].length);
    }
    e += 1 + ProtoBufRuntime._sz_uint64(r.new_operators_threshold_numerator);
    e += 1 + ProtoBufRuntime._sz_uint64(r.new_operators_threshold_denominator);
    for(i = 0; i < r.signatures.length; i++) {
      e += 1 + ProtoBufRuntime._sz_lendelim(r.signatures[i].length);
    }
    return e;
  }
  // empty checker

  function _empty(
    Data memory r
  ) internal pure returns (bool) {
    
  if (r.nonce != 0) {
    return false;
  }

  if (r.new_operators.length != 0) {
    return false;
  }

  if (r.new_operators_threshold_numerator != 0) {
    return false;
  }

  if (r.new_operators_threshold_denominator != 0) {
    return false;
  }

  if (r.signatures.length != 0) {
    return false;
  }

    return true;
  }


  //store function
  /**
   * @dev Store in-memory struct to storage
   * @param input The in-memory struct
   * @param output The in-storage struct
   */
  function store(Data memory input, Data storage output) internal {
    output.nonce = input.nonce;
    output.new_operators = input.new_operators;
    output.new_operators_threshold_numerator = input.new_operators_threshold_numerator;
    output.new_operators_threshold_denominator = input.new_operators_threshold_denominator;
    output.signatures = input.signatures;

  }


  //array helpers for NewOperators
  /**
   * @dev Add value to an array
   * @param self The in-memory struct
   * @param value The value to add
   */
  function addNewOperators(Data memory self, bytes memory value) internal pure {
    /**
     * First resize the array. Then add the new element to the end.
     */
    bytes[] memory tmp = new bytes[](self.new_operators.length + 1);
    for (uint256 i = 0; i < self.new_operators.length; i++) {
      tmp[i] = self.new_operators[i];
    }
    tmp[self.new_operators.length] = value;
    self.new_operators = tmp;
  }

  //array helpers for Signatures
  /**
   * @dev Add value to an array
   * @param self The in-memory struct
   * @param value The value to add
   */
  function addSignatures(Data memory self, bytes memory value) internal pure {
    /**
     * First resize the array. Then add the new element to the end.
     */
    bytes[] memory tmp = new bytes[](self.signatures.length + 1);
    for (uint256 i = 0; i < self.signatures.length; i++) {
      tmp[i] = self.signatures[i];
    }
    tmp[self.signatures.length] = value;
    self.signatures = tmp;
  }


  //utility functions
  /**
   * @dev Return an empty struct
   * @return r The empty struct
   */
  function nil() internal pure returns (Data memory r) {
    assembly {
      r := 0
    }
  }

  /**
   * @dev Test whether a struct is empty
   * @param x The struct to be tested
   * @return r True if it is empty
   */
  function isNil(Data memory x) internal pure returns (bool r) {
    assembly {
      r := iszero(x)
    }
  }
}
//library IbcLightclientsLcpV1UpdateOperatorsMessage

library IbcLightclientsLcpV1ClientState {


  //struct definition
  struct Data {
    bytes mrenclave;
    uint64 key_expiration;
    bool frozen;
    Height.Data latest_height;
    string[] allowed_quote_statuses;
    string[] allowed_advisory_ids;
    bytes[] operators;
    uint64 operators_nonce;
    uint64 operators_threshold_numerator;
    uint64 operators_threshold_denominator;
  }

  // Decoder section

  /**
   * @dev The main decoder for memory
   * @param bs The bytes array to be decoded
   * @return The decoded struct
   */
  function decode(bytes memory bs) internal pure returns (Data memory) {
    (Data memory x, ) = _decode(32, bs, bs.length);
    return x;
  }

  /**
   * @dev The main decoder for storage
   * @param self The in-storage struct
   * @param bs The bytes array to be decoded
   */
  function decode(Data storage self, bytes memory bs) internal {
    (Data memory x, ) = _decode(32, bs, bs.length);
    store(x, self);
  }
  // inner decoder

  /**
   * @dev The decoder for internal usage
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param sz The number of bytes expected
   * @return The decoded struct
   * @return The number of bytes decoded
   */
  function _decode(uint256 p, bytes memory bs, uint256 sz)
    internal
    pure
    returns (Data memory, uint)
  {
    Data memory r;
    uint[11] memory counters;
    uint256 fieldId;
    ProtoBufRuntime.WireType wireType;
    uint256 bytesRead;
    uint256 offset = p;
    uint256 pointer = p;
    while (pointer < offset + sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if (fieldId == 1) {
        pointer += _read_mrenclave(pointer, bs, r);
      } else
      if (fieldId == 2) {
        pointer += _read_key_expiration(pointer, bs, r);
      } else
      if (fieldId == 3) {
        pointer += _read_frozen(pointer, bs, r);
      } else
      if (fieldId == 4) {
        pointer += _read_latest_height(pointer, bs, r);
      } else
      if (fieldId == 5) {
        pointer += _read_unpacked_repeated_allowed_quote_statuses(pointer, bs, nil(), counters);
      } else
      if (fieldId == 6) {
        pointer += _read_unpacked_repeated_allowed_advisory_ids(pointer, bs, nil(), counters);
      } else
      if (fieldId == 7) {
        pointer += _read_unpacked_repeated_operators(pointer, bs, nil(), counters);
      } else
      if (fieldId == 8) {
        pointer += _read_operators_nonce(pointer, bs, r);
      } else
      if (fieldId == 9) {
        pointer += _read_operators_threshold_numerator(pointer, bs, r);
      } else
      if (fieldId == 10) {
        pointer += _read_operators_threshold_denominator(pointer, bs, r);
      } else
      {
        pointer += ProtoBufRuntime._skip_field_decode(wireType, pointer, bs);
      }

    }
    pointer = offset;
    if (counters[5] > 0) {
      require(r.allowed_quote_statuses.length == 0);
      r.allowed_quote_statuses = new string[](counters[5]);
    }
    if (counters[6] > 0) {
      require(r.allowed_advisory_ids.length == 0);
      r.allowed_advisory_ids = new string[](counters[6]);
    }
    if (counters[7] > 0) {
      require(r.operators.length == 0);
      r.operators = new bytes[](counters[7]);
    }

    while (pointer < offset + sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if (fieldId == 5) {
        pointer += _read_unpacked_repeated_allowed_quote_statuses(pointer, bs, r, counters);
      } else
      if (fieldId == 6) {
        pointer += _read_unpacked_repeated_allowed_advisory_ids(pointer, bs, r, counters);
      } else
      if (fieldId == 7) {
        pointer += _read_unpacked_repeated_operators(pointer, bs, r, counters);
      } else
      {
        pointer += ProtoBufRuntime._skip_field_decode(wireType, pointer, bs);
      }
    }
    return (r, sz);
  }

  // field readers

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_mrenclave(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (bytes memory x, uint256 sz) = ProtoBufRuntime._decode_bytes(p, bs);
    r.mrenclave = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_key_expiration(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (uint64 x, uint256 sz) = ProtoBufRuntime._decode_uint64(p, bs);
    r.key_expiration = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_frozen(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (bool x, uint256 sz) = ProtoBufRuntime._decode_bool(p, bs);
    r.frozen = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_latest_height(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (Height.Data memory x, uint256 sz) = _decode_Height(p, bs);
    r.latest_height = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_unpacked_repeated_allowed_quote_statuses(
    uint256 p,
    bytes memory bs,
    Data memory r,
    uint[11] memory counters
  ) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (string memory x, uint256 sz) = ProtoBufRuntime._decode_string(p, bs);
    if (isNil(r)) {
      counters[5] += 1;
    } else {
      r.allowed_quote_statuses[r.allowed_quote_statuses.length - counters[5]] = x;
      counters[5] -= 1;
    }
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_unpacked_repeated_allowed_advisory_ids(
    uint256 p,
    bytes memory bs,
    Data memory r,
    uint[11] memory counters
  ) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (string memory x, uint256 sz) = ProtoBufRuntime._decode_string(p, bs);
    if (isNil(r)) {
      counters[6] += 1;
    } else {
      r.allowed_advisory_ids[r.allowed_advisory_ids.length - counters[6]] = x;
      counters[6] -= 1;
    }
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_unpacked_repeated_operators(
    uint256 p,
    bytes memory bs,
    Data memory r,
    uint[11] memory counters
  ) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (bytes memory x, uint256 sz) = ProtoBufRuntime._decode_bytes(p, bs);
    if (isNil(r)) {
      counters[7] += 1;
    } else {
      r.operators[r.operators.length - counters[7]] = x;
      counters[7] -= 1;
    }
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_operators_nonce(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (uint64 x, uint256 sz) = ProtoBufRuntime._decode_uint64(p, bs);
    r.operators_nonce = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_operators_threshold_numerator(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (uint64 x, uint256 sz) = ProtoBufRuntime._decode_uint64(p, bs);
    r.operators_threshold_numerator = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_operators_threshold_denominator(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (uint64 x, uint256 sz) = ProtoBufRuntime._decode_uint64(p, bs);
    r.operators_threshold_denominator = x;
    return sz;
  }

  // struct decoder
  /**
   * @dev The decoder for reading a inner struct field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The decoded inner-struct
   * @return The number of bytes used to decode
   */
  function _decode_Height(uint256 p, bytes memory bs)
    internal
    pure
    returns (Height.Data memory, uint)
  {
    uint256 pointer = p;
    (uint256 sz, uint256 bytesRead) = ProtoBufRuntime._decode_varint(pointer, bs);
    pointer += bytesRead;
    (Height.Data memory r, ) = Height._decode(pointer, bs, sz);
    return (r, sz + bytesRead);
  }


  // Encoder section

  /**
   * @dev The main encoder for memory
   * @param r The struct to be encoded
   * @return The encoded byte array
   */
  function encode(Data memory r) internal pure returns (bytes memory) {
    bytes memory bs = new bytes(_estimate(r));
    uint256 sz = _encode(r, 32, bs);
    assembly {
      mstore(bs, sz)
    }
    return bs;
  }
  // inner encoder

  /**
   * @dev The encoder for internal usage
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    uint256 offset = p;
    uint256 pointer = p;
    uint256 i;
    if (r.mrenclave.length != 0) {
    pointer += ProtoBufRuntime._encode_key(
      1,
      ProtoBufRuntime.WireType.LengthDelim,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_bytes(r.mrenclave, pointer, bs);
    }
    if (r.key_expiration != 0) {
    pointer += ProtoBufRuntime._encode_key(
      2,
      ProtoBufRuntime.WireType.Varint,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_uint64(r.key_expiration, pointer, bs);
    }
    if (r.frozen != false) {
    pointer += ProtoBufRuntime._encode_key(
      3,
      ProtoBufRuntime.WireType.Varint,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_bool(r.frozen, pointer, bs);
    }
    
    pointer += ProtoBufRuntime._encode_key(
      4,
      ProtoBufRuntime.WireType.LengthDelim,
      pointer,
      bs
    );
    pointer += Height._encode_nested(r.latest_height, pointer, bs);
    
    if (r.allowed_quote_statuses.length != 0) {
    for(i = 0; i < r.allowed_quote_statuses.length; i++) {
      pointer += ProtoBufRuntime._encode_key(
        5,
        ProtoBufRuntime.WireType.LengthDelim,
        pointer,
        bs)
      ;
      pointer += ProtoBufRuntime._encode_string(r.allowed_quote_statuses[i], pointer, bs);
    }
    }
    if (r.allowed_advisory_ids.length != 0) {
    for(i = 0; i < r.allowed_advisory_ids.length; i++) {
      pointer += ProtoBufRuntime._encode_key(
        6,
        ProtoBufRuntime.WireType.LengthDelim,
        pointer,
        bs)
      ;
      pointer += ProtoBufRuntime._encode_string(r.allowed_advisory_ids[i], pointer, bs);
    }
    }
    if (r.operators.length != 0) {
    for(i = 0; i < r.operators.length; i++) {
      pointer += ProtoBufRuntime._encode_key(
        7,
        ProtoBufRuntime.WireType.LengthDelim,
        pointer,
        bs)
      ;
      pointer += ProtoBufRuntime._encode_bytes(r.operators[i], pointer, bs);
    }
    }
    if (r.operators_nonce != 0) {
    pointer += ProtoBufRuntime._encode_key(
      8,
      ProtoBufRuntime.WireType.Varint,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_uint64(r.operators_nonce, pointer, bs);
    }
    if (r.operators_threshold_numerator != 0) {
    pointer += ProtoBufRuntime._encode_key(
      9,
      ProtoBufRuntime.WireType.Varint,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_uint64(r.operators_threshold_numerator, pointer, bs);
    }
    if (r.operators_threshold_denominator != 0) {
    pointer += ProtoBufRuntime._encode_key(
      10,
      ProtoBufRuntime.WireType.Varint,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_uint64(r.operators_threshold_denominator, pointer, bs);
    }
    return pointer - offset;
  }
  // nested encoder

  /**
   * @dev The encoder for inner struct
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode_nested(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    /**
     * First encoded `r` into a temporary array, and encode the actual size used.
     * Then copy the temporary array into `bs`.
     */
    uint256 offset = p;
    uint256 pointer = p;
    bytes memory tmp = new bytes(_estimate(r));
    uint256 tmpAddr = ProtoBufRuntime.getMemoryAddress(tmp);
    uint256 bsAddr = ProtoBufRuntime.getMemoryAddress(bs);
    uint256 size = _encode(r, 32, tmp);
    pointer += ProtoBufRuntime._encode_varint(size, pointer, bs);
    ProtoBufRuntime.copyBytes(tmpAddr + 32, bsAddr + pointer, size);
    pointer += size;
    delete tmp;
    return pointer - offset;
  }
  // estimator

  /**
   * @dev The estimator for a struct
   * @param r The struct to be encoded
   * @return The number of bytes encoded in estimation
   */
  function _estimate(
    Data memory r
  ) internal pure returns (uint) {
    uint256 e;uint256 i;
    e += 1 + ProtoBufRuntime._sz_lendelim(r.mrenclave.length);
    e += 1 + ProtoBufRuntime._sz_uint64(r.key_expiration);
    e += 1 + 1;
    e += 1 + ProtoBufRuntime._sz_lendelim(Height._estimate(r.latest_height));
    for(i = 0; i < r.allowed_quote_statuses.length; i++) {
      e += 1 + ProtoBufRuntime._sz_lendelim(bytes(r.allowed_quote_statuses[i]).length);
    }
    for(i = 0; i < r.allowed_advisory_ids.length; i++) {
      e += 1 + ProtoBufRuntime._sz_lendelim(bytes(r.allowed_advisory_ids[i]).length);
    }
    for(i = 0; i < r.operators.length; i++) {
      e += 1 + ProtoBufRuntime._sz_lendelim(r.operators[i].length);
    }
    e += 1 + ProtoBufRuntime._sz_uint64(r.operators_nonce);
    e += 1 + ProtoBufRuntime._sz_uint64(r.operators_threshold_numerator);
    e += 1 + ProtoBufRuntime._sz_uint64(r.operators_threshold_denominator);
    return e;
  }
  // empty checker

  function _empty(
    Data memory r
  ) internal pure returns (bool) {
    
  if (r.mrenclave.length != 0) {
    return false;
  }

  if (r.key_expiration != 0) {
    return false;
  }

  if (r.frozen != false) {
    return false;
  }

  if (r.allowed_quote_statuses.length != 0) {
    return false;
  }

  if (r.allowed_advisory_ids.length != 0) {
    return false;
  }

  if (r.operators.length != 0) {
    return false;
  }

  if (r.operators_nonce != 0) {
    return false;
  }

  if (r.operators_threshold_numerator != 0) {
    return false;
  }

  if (r.operators_threshold_denominator != 0) {
    return false;
  }

    return true;
  }


  //store function
  /**
   * @dev Store in-memory struct to storage
   * @param input The in-memory struct
   * @param output The in-storage struct
   */
  function store(Data memory input, Data storage output) internal {
    output.mrenclave = input.mrenclave;
    output.key_expiration = input.key_expiration;
    output.frozen = input.frozen;
    Height.store(input.latest_height, output.latest_height);
    output.allowed_quote_statuses = input.allowed_quote_statuses;
    output.allowed_advisory_ids = input.allowed_advisory_ids;
    output.operators = input.operators;
    output.operators_nonce = input.operators_nonce;
    output.operators_threshold_numerator = input.operators_threshold_numerator;
    output.operators_threshold_denominator = input.operators_threshold_denominator;

  }


  //array helpers for AllowedQuoteStatuses
  /**
   * @dev Add value to an array
   * @param self The in-memory struct
   * @param value The value to add
   */
  function addAllowedQuoteStatuses(Data memory self, string memory value) internal pure {
    /**
     * First resize the array. Then add the new element to the end.
     */
    string[] memory tmp = new string[](self.allowed_quote_statuses.length + 1);
    for (uint256 i = 0; i < self.allowed_quote_statuses.length; i++) {
      tmp[i] = self.allowed_quote_statuses[i];
    }
    tmp[self.allowed_quote_statuses.length] = value;
    self.allowed_quote_statuses = tmp;
  }

  //array helpers for AllowedAdvisoryIds
  /**
   * @dev Add value to an array
   * @param self The in-memory struct
   * @param value The value to add
   */
  function addAllowedAdvisoryIds(Data memory self, string memory value) internal pure {
    /**
     * First resize the array. Then add the new element to the end.
     */
    string[] memory tmp = new string[](self.allowed_advisory_ids.length + 1);
    for (uint256 i = 0; i < self.allowed_advisory_ids.length; i++) {
      tmp[i] = self.allowed_advisory_ids[i];
    }
    tmp[self.allowed_advisory_ids.length] = value;
    self.allowed_advisory_ids = tmp;
  }

  //array helpers for Operators
  /**
   * @dev Add value to an array
   * @param self The in-memory struct
   * @param value The value to add
   */
  function addOperators(Data memory self, bytes memory value) internal pure {
    /**
     * First resize the array. Then add the new element to the end.
     */
    bytes[] memory tmp = new bytes[](self.operators.length + 1);
    for (uint256 i = 0; i < self.operators.length; i++) {
      tmp[i] = self.operators[i];
    }
    tmp[self.operators.length] = value;
    self.operators = tmp;
  }


  //utility functions
  /**
   * @dev Return an empty struct
   * @return r The empty struct
   */
  function nil() internal pure returns (Data memory r) {
    assembly {
      r := 0
    }
  }

  /**
   * @dev Test whether a struct is empty
   * @param x The struct to be tested
   * @return r True if it is empty
   */
  function isNil(Data memory x) internal pure returns (bool r) {
    assembly {
      r := iszero(x)
    }
  }
}
//library IbcLightclientsLcpV1ClientState

library IbcLightclientsLcpV1ConsensusState {


  //struct definition
  struct Data {
    bytes state_id;
    uint64 timestamp;
  }

  // Decoder section

  /**
   * @dev The main decoder for memory
   * @param bs The bytes array to be decoded
   * @return The decoded struct
   */
  function decode(bytes memory bs) internal pure returns (Data memory) {
    (Data memory x, ) = _decode(32, bs, bs.length);
    return x;
  }

  /**
   * @dev The main decoder for storage
   * @param self The in-storage struct
   * @param bs The bytes array to be decoded
   */
  function decode(Data storage self, bytes memory bs) internal {
    (Data memory x, ) = _decode(32, bs, bs.length);
    store(x, self);
  }
  // inner decoder

  /**
   * @dev The decoder for internal usage
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param sz The number of bytes expected
   * @return The decoded struct
   * @return The number of bytes decoded
   */
  function _decode(uint256 p, bytes memory bs, uint256 sz)
    internal
    pure
    returns (Data memory, uint)
  {
    Data memory r;
    uint256 fieldId;
    ProtoBufRuntime.WireType wireType;
    uint256 bytesRead;
    uint256 offset = p;
    uint256 pointer = p;
    while (pointer < offset + sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if (fieldId == 1) {
        pointer += _read_state_id(pointer, bs, r);
      } else
      if (fieldId == 2) {
        pointer += _read_timestamp(pointer, bs, r);
      } else
      {
        pointer += ProtoBufRuntime._skip_field_decode(wireType, pointer, bs);
      }

    }
    return (r, sz);
  }

  // field readers

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_state_id(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (bytes memory x, uint256 sz) = ProtoBufRuntime._decode_bytes(p, bs);
    r.state_id = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_timestamp(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (uint64 x, uint256 sz) = ProtoBufRuntime._decode_uint64(p, bs);
    r.timestamp = x;
    return sz;
  }


  // Encoder section

  /**
   * @dev The main encoder for memory
   * @param r The struct to be encoded
   * @return The encoded byte array
   */
  function encode(Data memory r) internal pure returns (bytes memory) {
    bytes memory bs = new bytes(_estimate(r));
    uint256 sz = _encode(r, 32, bs);
    assembly {
      mstore(bs, sz)
    }
    return bs;
  }
  // inner encoder

  /**
   * @dev The encoder for internal usage
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    uint256 offset = p;
    uint256 pointer = p;
    
    if (r.state_id.length != 0) {
    pointer += ProtoBufRuntime._encode_key(
      1,
      ProtoBufRuntime.WireType.LengthDelim,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_bytes(r.state_id, pointer, bs);
    }
    if (r.timestamp != 0) {
    pointer += ProtoBufRuntime._encode_key(
      2,
      ProtoBufRuntime.WireType.Varint,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_uint64(r.timestamp, pointer, bs);
    }
    return pointer - offset;
  }
  // nested encoder

  /**
   * @dev The encoder for inner struct
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode_nested(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    /**
     * First encoded `r` into a temporary array, and encode the actual size used.
     * Then copy the temporary array into `bs`.
     */
    uint256 offset = p;
    uint256 pointer = p;
    bytes memory tmp = new bytes(_estimate(r));
    uint256 tmpAddr = ProtoBufRuntime.getMemoryAddress(tmp);
    uint256 bsAddr = ProtoBufRuntime.getMemoryAddress(bs);
    uint256 size = _encode(r, 32, tmp);
    pointer += ProtoBufRuntime._encode_varint(size, pointer, bs);
    ProtoBufRuntime.copyBytes(tmpAddr + 32, bsAddr + pointer, size);
    pointer += size;
    delete tmp;
    return pointer - offset;
  }
  // estimator

  /**
   * @dev The estimator for a struct
   * @param r The struct to be encoded
   * @return The number of bytes encoded in estimation
   */
  function _estimate(
    Data memory r
  ) internal pure returns (uint) {
    uint256 e;
    e += 1 + ProtoBufRuntime._sz_lendelim(r.state_id.length);
    e += 1 + ProtoBufRuntime._sz_uint64(r.timestamp);
    return e;
  }
  // empty checker

  function _empty(
    Data memory r
  ) internal pure returns (bool) {
    
  if (r.state_id.length != 0) {
    return false;
  }

  if (r.timestamp != 0) {
    return false;
  }

    return true;
  }


  //store function
  /**
   * @dev Store in-memory struct to storage
   * @param input The in-memory struct
   * @param output The in-storage struct
   */
  function store(Data memory input, Data storage output) internal {
    output.state_id = input.state_id;
    output.timestamp = input.timestamp;

  }



  //utility functions
  /**
   * @dev Return an empty struct
   * @return r The empty struct
   */
  function nil() internal pure returns (Data memory r) {
    assembly {
      r := 0
    }
  }

  /**
   * @dev Test whether a struct is empty
   * @param x The struct to be tested
   * @return r True if it is empty
   */
  function isNil(Data memory x) internal pure returns (bool r) {
    assembly {
      r := iszero(x)
    }
  }
}
//library IbcLightclientsLcpV1ConsensusState
pragma solidity ^0.8.4;

library BytesUtils {
    error OffsetOutOfBoundsError(uint256 offset, uint256 length);

    /*
     * @dev Returns the keccak-256 hash of a byte range.
     * @param self The byte string to hash.
     * @param offset The position to start hashing at.
     * @param len The number of bytes to hash.
     * @return The hash of the byte range.
     */
    function keccak(
        bytes memory self,
        uint256 offset,
        uint256 len
    ) internal pure returns (bytes32 ret) {
        require(offset + len <= self.length);
        assembly {
            ret := keccak256(add(add(self, 32), offset), len)
        }
    }

    /*
     * @dev Returns a positive number if `other` comes lexicographically after
     *      `self`, a negative number if it comes before, or zero if the
     *      contents of the two bytes are equal.
     * @param self The first bytes to compare.
     * @param other The second bytes to compare.
     * @return The result of the comparison.
     */
    function compare(
        bytes memory self,
        bytes memory other
    ) internal pure returns (int256) {
        return compare(self, 0, self.length, other, 0, other.length);
    }

    /*
     * @dev Returns a positive number if `other` comes lexicographically after
     *      `self`, a negative number if it comes before, or zero if the
     *      contents of the two bytes are equal. Comparison is done per-rune,
     *      on unicode codepoints.
     * @param self The first bytes to compare.
     * @param offset The offset of self.
     * @param len    The length of self.
     * @param other The second bytes to compare.
     * @param otheroffset The offset of the other string.
     * @param otherlen    The length of the other string.
     * @return The result of the comparison.
     */
    function compare(
        bytes memory self,
        uint256 offset,
        uint256 len,
        bytes memory other,
        uint256 otheroffset,
        uint256 otherlen
    ) internal pure returns (int256) {
        if (offset + len > self.length) {
            revert OffsetOutOfBoundsError(offset + len, self.length);
        }
        if (otheroffset + otherlen > other.length) {
            revert OffsetOutOfBoundsError(otheroffset + otherlen, other.length);
        }

        uint256 shortest = len;
        if (otherlen < len) shortest = otherlen;

        uint256 selfptr;
        uint256 otherptr;

        assembly {
            selfptr := add(self, add(offset, 32))
            otherptr := add(other, add(otheroffset, 32))
        }
        for (uint256 idx = 0; idx < shortest; idx += 32) {
            uint256 a;
            uint256 b;
            assembly {
                a := mload(selfptr)
                b := mload(otherptr)
            }
            if (a != b) {
                // Mask out irrelevant bytes and check again
                uint256 mask;
                if (shortest - idx >= 32) {
                    mask = type(uint256).max;
                } else {
                    mask = ~(2 ** (8 * (idx + 32 - shortest)) - 1);
                }
                int256 diff = int256(a & mask) - int256(b & mask);
                if (diff != 0) return diff;
            }
            selfptr += 32;
            otherptr += 32;
        }

        return int256(len) - int256(otherlen);
    }

    /*
     * @dev Returns true if the two byte ranges are equal.
     * @param self The first byte range to compare.
     * @param offset The offset into the first byte range.
     * @param other The second byte range to compare.
     * @param otherOffset The offset into the second byte range.
     * @param len The number of bytes to compare
     * @return True if the byte ranges are equal, false otherwise.
     */
    function equals(
        bytes memory self,
        uint256 offset,
        bytes memory other,
        uint256 otherOffset,
        uint256 len
    ) internal pure returns (bool) {
        return keccak(self, offset, len) == keccak(other, otherOffset, len);
    }

    /*
     * @dev Returns true if the two byte ranges are equal with offsets.
     * @param self The first byte range to compare.
     * @param offset The offset into the first byte range.
     * @param other The second byte range to compare.
     * @param otherOffset The offset into the second byte range.
     * @return True if the byte ranges are equal, false otherwise.
     */
    function equals(
        bytes memory self,
        uint256 offset,
        bytes memory other,
        uint256 otherOffset
    ) internal pure returns (bool) {
        return
            keccak(self, offset, self.length - offset) ==
            keccak(other, otherOffset, other.length - otherOffset);
    }

    /*
     * @dev Compares a range of 'self' to all of 'other' and returns True iff
     *      they are equal.
     * @param self The first byte range to compare.
     * @param offset The offset into the first byte range.
     * @param other The second byte range to compare.
     * @return True if the byte ranges are equal, false otherwise.
     */
    function equals(
        bytes memory self,
        uint256 offset,
        bytes memory other
    ) internal pure returns (bool) {
        return
            self.length == offset + other.length &&
            equals(self, offset, other, 0, other.length);
    }

    /*
     * @dev Returns true if the two byte ranges are equal.
     * @param self The first byte range to compare.
     * @param other The second byte range to compare.
     * @return True if the byte ranges are equal, false otherwise.
     */
    function equals(
        bytes memory self,
        bytes memory other
    ) internal pure returns (bool) {
        return
            self.length == other.length &&
            equals(self, 0, other, 0, self.length);
    }

    /*
     * @dev Returns the 8-bit number at the specified index of self.
     * @param self The byte string.
     * @param idx The index into the bytes
     * @return The specified 8 bits of the string, interpreted as an integer.
     */
    function readUint8(
        bytes memory self,
        uint256 idx
    ) internal pure returns (uint8 ret) {
        return uint8(self[idx]);
    }

    /*
     * @dev Returns the 16-bit number at the specified index of self.
     * @param self The byte string.
     * @param idx The index into the bytes
     * @return The specified 16 bits of the string, interpreted as an integer.
     */
    function readUint16(
        bytes memory self,
        uint256 idx
    ) internal pure returns (uint16 ret) {
        require(idx + 2 <= self.length);
        assembly {
            ret := and(mload(add(add(self, 2), idx)), 0xFFFF)
        }
    }

    /*
     * @dev Returns the 32-bit number at the specified index of self.
     * @param self The byte string.
     * @param idx The index into the bytes
     * @return The specified 32 bits of the string, interpreted as an integer.
     */
    function readUint32(
        bytes memory self,
        uint256 idx
    ) internal pure returns (uint32 ret) {
        require(idx + 4 <= self.length);
        assembly {
            ret := and(mload(add(add(self, 4), idx)), 0xFFFFFFFF)
        }
    }

    /*
     * @dev Returns the 32 byte value at the specified index of self.
     * @param self The byte string.
     * @param idx The index into the bytes
     * @return The specified 32 bytes of the string.
     */
    function readBytes32(
        bytes memory self,
        uint256 idx
    ) internal pure returns (bytes32 ret) {
        require(idx + 32 <= self.length);
        assembly {
            ret := mload(add(add(self, 32), idx))
        }
    }

    /*
     * @dev Returns the 32 byte value at the specified index of self.
     * @param self The byte string.
     * @param idx The index into the bytes
     * @return The specified 32 bytes of the string.
     */
    function readBytes20(
        bytes memory self,
        uint256 idx
    ) internal pure returns (bytes20 ret) {
        require(idx + 20 <= self.length);
        assembly {
            ret := and(
                mload(add(add(self, 32), idx)),
                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000
            )
        }
    }

    /*
     * @dev Returns the n byte value at the specified index of self.
     * @param self The byte string.
     * @param idx The index into the bytes.
     * @param len The number of bytes.
     * @return The specified 32 bytes of the string.
     */
    function readBytesN(
        bytes memory self,
        uint256 idx,
        uint256 len
    ) internal pure returns (bytes32 ret) {
        require(len <= 32);
        require(idx + len <= self.length);
        assembly {
            let mask := not(sub(exp(256, sub(32, len)), 1))
            ret := and(mload(add(add(self, 32), idx)), mask)
        }
    }

    function memcpy(uint256 dest, uint256 src, uint256 len) private pure {
        // Copy word-length chunks while possible
        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        unchecked {
            uint256 mask = (256 ** (32 - len)) - 1;
            assembly {
                let srcpart := and(mload(src), not(mask))
                let destpart := and(mload(dest), mask)
                mstore(dest, or(destpart, srcpart))
            }
        }
    }

    /*
     * @dev Copies a substring into a new byte string.
     * @param self The byte string to copy from.
     * @param offset The offset to start copying at.
     * @param len The number of bytes to copy.
     */
    function substring(
        bytes memory self,
        uint256 offset,
        uint256 len
    ) internal pure returns (bytes memory) {
        require(offset + len <= self.length);

        bytes memory ret = new bytes(len);
        uint256 dest;
        uint256 src;

        assembly {
            dest := add(ret, 32)
            src := add(add(self, 32), offset)
        }
        memcpy(dest, src, len);

        return ret;
    }

    // Maps characters from 0x30 to 0x7A to their base32 values.
    // 0xFF represents invalid characters in that range.
    bytes constant base32HexTable =
        hex"00010203040506070809FFFFFFFFFFFFFF0A0B0C0D0E0F101112131415161718191A1B1C1D1E1FFFFFFFFFFFFFFFFFFFFF0A0B0C0D0E0F101112131415161718191A1B1C1D1E1F";

    /**
     * @dev Decodes unpadded base32 data of up to one word in length.
     * @param self The data to decode.
     * @param off Offset into the string to start at.
     * @param len Number of characters to decode.
     * @return The decoded data, left aligned.
     */
    function base32HexDecodeWord(
        bytes memory self,
        uint256 off,
        uint256 len
    ) internal pure returns (bytes32) {
        require(len <= 52);

        uint256 ret = 0;
        uint8 decoded;
        for (uint256 i = 0; i < len; i++) {
            bytes1 char = self[off + i];
            require(char >= 0x30 && char <= 0x7A);
            decoded = uint8(base32HexTable[uint256(uint8(char)) - 0x30]);
            require(decoded <= 0x20);
            if (i == len - 1) {
                break;
            }
            ret = (ret << 5) | decoded;
        }

        uint256 bitlen = len * 5;
        if (len % 8 == 0) {
            // Multiple of 8 characters, no padding
            ret = (ret << 5) | decoded;
        } else if (len % 8 == 2) {
            // Two extra characters - 1 byte
            ret = (ret << 3) | (decoded >> 2);
            bitlen -= 2;
        } else if (len % 8 == 4) {
            // Four extra characters - 2 bytes
            ret = (ret << 1) | (decoded >> 4);
            bitlen -= 4;
        } else if (len % 8 == 5) {
            // Five extra characters - 3 bytes
            ret = (ret << 4) | (decoded >> 1);
            bitlen -= 1;
        } else if (len % 8 == 7) {
            // Seven extra characters - 4 bytes
            ret = (ret << 2) | (decoded >> 3);
            bitlen -= 3;
        } else {
            revert();
        }

        return bytes32(ret << (256 - bitlen));
    }

    /**
     * @dev Finds the first occurrence of the byte `needle` in `self`.
     * @param self The string to search
     * @param off The offset to start searching at
     * @param len The number of bytes to search
     * @param needle The byte to search for
     * @return The offset of `needle` in `self`, or 2**256-1 if it was not found.
     */
    function find(
        bytes memory self,
        uint256 off,
        uint256 len,
        bytes1 needle
    ) internal pure returns (uint256) {
        for (uint256 idx = off; idx < off + len; idx++) {
            if (self[idx] == needle) {
                return idx;
            }
        }
        return type(uint256).max;
    }
}
pragma solidity ^0.8.4;

library ModexpPrecompile {
    /**
     * @dev Computes (base ^ exponent) % modulus over big numbers.
     */
    function modexp(
        bytes memory base,
        bytes memory exponent,
        bytes memory modulus
    ) internal view returns (bool success, bytes memory output) {
        bytes memory input = abi.encodePacked(
            uint256(base.length),
            uint256(exponent.length),
            uint256(modulus.length),
            base,
            exponent,
            modulus
        );

        output = new bytes(modulus.length);

        assembly {
            success := staticcall(
                gas(),
                5,
                add(input, 32),
                mload(input),
                add(output, 32),
                mload(modulus)
            )
        }
    }
}
pragma solidity ^0.8.4;

import "../BytesUtils.sol";
import "./ModexpPrecompile.sol";

library RSAVerify {
    /**
     * @dev Recovers the input data from an RSA signature, returning the result in S.
     * @param N The RSA public modulus.
     * @param E The RSA public exponent.
     * @param S The signature to recover.
     * @return True if the recovery succeeded.
     */
    function rsarecover(
        bytes memory N,
        bytes memory E,
        bytes memory S
    ) internal view returns (bool, bytes memory) {
        return ModexpPrecompile.modexp(S, E, N);
    }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {Height} from "../../proto/Client.sol";

library IBCHeight {
    function toUint128(Height.Data memory self) internal pure returns (uint128) {
        return (uint128(self.revision_number) << 64) | uint128(self.revision_height);
    }

    function fromUint128(uint128 height) internal pure returns (Height.Data memory) {
        return Height.Data({revision_number: uint64(height >> 64), revision_height: uint64(height)});
    }

    function isZero(Height.Data memory self) internal pure returns (bool) {
        return self.revision_number == 0 && self.revision_height == 0;
    }

    function lt(Height.Data memory self, Height.Data memory other) internal pure returns (bool) {
        return self.revision_number < other.revision_number
            || (self.revision_number == other.revision_number && self.revision_height < other.revision_height);
    }

    function lte(Height.Data memory self, Height.Data memory other) internal pure returns (bool) {
        return self.revision_number < other.revision_number
            || (self.revision_number == other.revision_number && self.revision_height <= other.revision_height);
    }

    function eq(Height.Data memory self, Height.Data memory other) internal pure returns (bool) {
        return self.revision_number == other.revision_number && self.revision_height == other.revision_height;
    }

    function gt(Height.Data memory self, Height.Data memory other) internal pure returns (bool) {
        return self.revision_number > other.revision_number
            || (self.revision_number == other.revision_number && self.revision_height > other.revision_height);
    }

    function gte(Height.Data memory self, Height.Data memory other) internal pure returns (bool) {
        return self.revision_number > other.revision_number
            || (self.revision_number == other.revision_number && self.revision_height >= other.revision_height);
    }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {Height} from "../../proto/Client.sol";

/**
 * @dev This defines an interface for Light Client contract can be integrated with ibc-solidity.
 * You can register the Light Client contract that implements this through `registerClient` on IBCHandler.
 */
interface ILightClient {
    /**
     * @dev ConsensusStateUpdate represents a consensus state update.
     */
    struct ConsensusStateUpdate {
        // commitment for updated consensusState
        bytes32 consensusStateCommitment;
        // updated height
        Height.Data height;
    }

    /**
     * @dev ClientStatus represents the status of a client.
     */
    enum ClientStatus {
        Active,
        Expired,
        Frozen
    }

    /**
     * @dev initializeClient initializes a new client with the given state.
     *      If succeeded, it returns heights at which the consensus state are stored.
     *      The function must be only called by IBCHandler.
     */
    function initializeClient(
        string calldata clientId,
        bytes calldata protoClientState,
        bytes calldata protoConsensusState
    ) external returns (Height.Data memory height);

    /**
     * @dev routeUpdateClient returns the calldata to the receiving function of the client message.
     *      Light client contract may encode a client message as other encoding scheme(e.g. ethereum ABI)
     *      Check ADR-001 for details.
     */
    function routeUpdateClient(string calldata clientId, bytes calldata protoClientMessage)
        external
        pure
        returns (bytes4 selector, bytes memory args);

    /**
     * @dev getTimestampAtHeight returns the timestamp of the consensus state at the given height.
     *      The timestamp is nanoseconds since unix epoch.
     */
    function getTimestampAtHeight(string calldata clientId, Height.Data calldata height)
        external
        view
        returns (uint64);

    /**
     * @dev getLatestHeight returns the latest height of the client state corresponding to `clientId`.
     */
    function getLatestHeight(string calldata clientId) external view returns (Height.Data memory);

    /**
     * @dev getStatus returns the status of the client corresponding to `clientId`.
     */
    function getStatus(string calldata clientId) external view returns (ClientStatus);

    /**
     * @dev getLatestInfo returns the latest height, the latest timestamp, and the status of the client corresponding to `clientId`.
     */
    function getLatestInfo(string calldata clientId)
        external
        view
        returns (Height.Data memory latestHeight, uint64 latestTimestamp, ClientStatus status);

    /**
     * @dev verifyMembership is a generic proof verification method which verifies a proof of the existence of a value at a given CommitmentPath at the specified height.
     * The caller is expected to construct the full CommitmentPath from a CommitmentPrefix and a standardized path (as defined in ICS 24).
     * This function should not perform `call` to the IBC contract. However, `staticcall` is permitted.
     */
    function verifyMembership(
        string calldata clientId,
        Height.Data calldata height,
        uint64 delayTimePeriod,
        uint64 delayBlockPeriod,
        bytes calldata proof,
        bytes calldata prefix,
        bytes calldata path,
        bytes calldata value
    ) external returns (bool);

    /**
     * @dev verifyNonMembership is a generic proof verification method which verifies the absence of a given CommitmentPath at a specified height.
     * The caller is expected to construct the full CommitmentPath from a CommitmentPrefix and a standardized path (as defined in ICS 24).
     * This function should not perform `call` to the IBC contract. However, `staticcall` is permitted.
     */
    function verifyNonMembership(
        string calldata clientId,
        Height.Data calldata height,
        uint64 delayTimePeriod,
        uint64 delayBlockPeriod,
        bytes calldata proof,
        bytes calldata prefix,
        bytes calldata path
    ) external returns (bool);

    /**
     * @dev getClientState returns the clientState corresponding to `clientId`.
     *      If it's not found, the function returns false.
     */
    function getClientState(string calldata clientId) external view returns (bytes memory, bool);

    /**
     * @dev getConsensusState returns the consensusState corresponding to `clientId` and `height`.
     *      If it's not found, the function returns false.
     */
    function getConsensusState(string calldata clientId, Height.Data calldata height)
        external
        view
        returns (bytes memory, bool);
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;
import "./ProtoBufRuntime.sol";
import "./GoogleProtobufAny.sol";

library Height {


  //struct definition
  struct Data {
    uint64 revision_number;
    uint64 revision_height;
  }

  // Decoder section

  /**
   * @dev The main decoder for memory
   * @param bs The bytes array to be decoded
   * @return The decoded struct
   */
  function decode(bytes memory bs) internal pure returns (Data memory) {
    (Data memory x, ) = _decode(32, bs, bs.length);
    return x;
  }

  /**
   * @dev The main decoder for storage
   * @param self The in-storage struct
   * @param bs The bytes array to be decoded
   */
  function decode(Data storage self, bytes memory bs) internal {
    (Data memory x, ) = _decode(32, bs, bs.length);
    store(x, self);
  }
  // inner decoder

  /**
   * @dev The decoder for internal usage
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param sz The number of bytes expected
   * @return The decoded struct
   * @return The number of bytes decoded
   */
  function _decode(uint256 p, bytes memory bs, uint256 sz)
    internal
    pure
    returns (Data memory, uint)
  {
    Data memory r;
    uint256 fieldId;
    ProtoBufRuntime.WireType wireType;
    uint256 bytesRead;
    uint256 offset = p;
    uint256 pointer = p;
    while (pointer < offset + sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if (fieldId == 1) {
        pointer += _read_revision_number(pointer, bs, r);
      } else
      if (fieldId == 2) {
        pointer += _read_revision_height(pointer, bs, r);
      } else
      {
        pointer += ProtoBufRuntime._skip_field_decode(wireType, pointer, bs);
      }

    }
    return (r, sz);
  }

  // field readers

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_revision_number(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (uint64 x, uint256 sz) = ProtoBufRuntime._decode_uint64(p, bs);
    r.revision_number = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_revision_height(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (uint64 x, uint256 sz) = ProtoBufRuntime._decode_uint64(p, bs);
    r.revision_height = x;
    return sz;
  }


  // Encoder section

  /**
   * @dev The main encoder for memory
   * @param r The struct to be encoded
   * @return The encoded byte array
   */
  function encode(Data memory r) internal pure returns (bytes memory) {
    bytes memory bs = new bytes(_estimate(r));
    uint256 sz = _encode(r, 32, bs);
    assembly {
      mstore(bs, sz)
    }
    return bs;
  }
  // inner encoder

  /**
   * @dev The encoder for internal usage
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    uint256 offset = p;
    uint256 pointer = p;
    
    if (r.revision_number != 0) {
    pointer += ProtoBufRuntime._encode_key(
      1,
      ProtoBufRuntime.WireType.Varint,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_uint64(r.revision_number, pointer, bs);
    }
    if (r.revision_height != 0) {
    pointer += ProtoBufRuntime._encode_key(
      2,
      ProtoBufRuntime.WireType.Varint,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_uint64(r.revision_height, pointer, bs);
    }
    return pointer - offset;
  }
  // nested encoder

  /**
   * @dev The encoder for inner struct
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode_nested(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    /**
     * First encoded `r` into a temporary array, and encode the actual size used.
     * Then copy the temporary array into `bs`.
     */
    uint256 offset = p;
    uint256 pointer = p;
    bytes memory tmp = new bytes(_estimate(r));
    uint256 tmpAddr = ProtoBufRuntime.getMemoryAddress(tmp);
    uint256 bsAddr = ProtoBufRuntime.getMemoryAddress(bs);
    uint256 size = _encode(r, 32, tmp);
    pointer += ProtoBufRuntime._encode_varint(size, pointer, bs);
    ProtoBufRuntime.copyBytes(tmpAddr + 32, bsAddr + pointer, size);
    pointer += size;
    delete tmp;
    return pointer - offset;
  }
  // estimator

  /**
   * @dev The estimator for a struct
   * @param r The struct to be encoded
   * @return The number of bytes encoded in estimation
   */
  function _estimate(
    Data memory r
  ) internal pure returns (uint) {
    uint256 e;
    e += 1 + ProtoBufRuntime._sz_uint64(r.revision_number);
    e += 1 + ProtoBufRuntime._sz_uint64(r.revision_height);
    return e;
  }
  // empty checker

  function _empty(
    Data memory r
  ) internal pure returns (bool) {
    
  if (r.revision_number != 0) {
    return false;
  }

  if (r.revision_height != 0) {
    return false;
  }

    return true;
  }


  //store function
  /**
   * @dev Store in-memory struct to storage
   * @param input The in-memory struct
   * @param output The in-storage struct
   */
  function store(Data memory input, Data storage output) internal {
    output.revision_number = input.revision_number;
    output.revision_height = input.revision_height;

  }



  //utility functions
  /**
   * @dev Return an empty struct
   * @return r The empty struct
   */
  function nil() internal pure returns (Data memory r) {
    assembly {
      r := 0
    }
  }

  /**
   * @dev Test whether a struct is empty
   * @param x The struct to be tested
   * @return r True if it is empty
   */
  function isNil(Data memory x) internal pure returns (bool r) {
    assembly {
      r := iszero(x)
    }
  }
}
//library Height
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;
import "./ProtoBufRuntime.sol";

library GoogleProtobufAny {


  //struct definition
  struct Data {
    string type_url;
    bytes value;
  }

  // Decoder section

  /**
   * @dev The main decoder for memory
   * @param bs The bytes array to be decoded
   * @return The decoded struct
   */
  function decode(bytes memory bs) internal pure returns (Data memory) {
    (Data memory x, ) = _decode(32, bs, bs.length);
    return x;
  }

  /**
   * @dev The main decoder for storage
   * @param self The in-storage struct
   * @param bs The bytes array to be decoded
   */
  function decode(Data storage self, bytes memory bs) internal {
    (Data memory x, ) = _decode(32, bs, bs.length);
    store(x, self);
  }
  // inner decoder

  /**
   * @dev The decoder for internal usage
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param sz The number of bytes expected
   * @return The decoded struct
   * @return The number of bytes decoded
   */
  function _decode(uint256 p, bytes memory bs, uint256 sz)
    internal
    pure
    returns (Data memory, uint)
  {
    Data memory r;
    uint[3] memory counters;
    uint256 fieldId;
    ProtoBufRuntime.WireType wireType;
    uint256 bytesRead;
    uint256 offset = p;
    uint256 pointer = p;
    while (pointer < offset + sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if (fieldId == 1) {
        pointer += _read_type_url(pointer, bs, r, counters);
      }
      else if (fieldId == 2) {
        pointer += _read_value(pointer, bs, r, counters);
      }

      else {
        if (wireType == ProtoBufRuntime.WireType.Fixed64) {
          uint256 size;
          (, size) = ProtoBufRuntime._decode_fixed64(pointer, bs);
          pointer += size;
        }
        if (wireType == ProtoBufRuntime.WireType.Fixed32) {
          uint256 size;
          (, size) = ProtoBufRuntime._decode_fixed32(pointer, bs);
          pointer += size;
        }
        if (wireType == ProtoBufRuntime.WireType.Varint) {
          uint256 size;
          (, size) = ProtoBufRuntime._decode_varint(pointer, bs);
          pointer += size;
        }
        if (wireType == ProtoBufRuntime.WireType.LengthDelim) {
          uint256 size;
          (, size) = ProtoBufRuntime._decode_lendelim(pointer, bs);
          pointer += size;
        }
      }

    }
    return (r, sz);
  }

  // field readers

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_type_url(
    uint256 p,
    bytes memory bs,
    Data memory r,
    uint[3] memory counters
  ) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (string memory x, uint256 sz) = ProtoBufRuntime._decode_string(p, bs);
    if (isNil(r)) {
      counters[1] += 1;
    } else {
      r.type_url = x;
      if (counters[1] > 0) counters[1] -= 1;
    }
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_value(
    uint256 p,
    bytes memory bs,
    Data memory r,
    uint[3] memory counters
  ) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (bytes memory x, uint256 sz) = ProtoBufRuntime._decode_bytes(p, bs);
    if (isNil(r)) {
      counters[2] += 1;
    } else {
      r.value = x;
      if (counters[2] > 0) counters[2] -= 1;
    }
    return sz;
  }


  // Encoder section

  /**
   * @dev The main encoder for memory
   * @param r The struct to be encoded
   * @return The encoded byte array
   */
  function encode(Data memory r) internal pure returns (bytes memory) {
    bytes memory bs = new bytes(_estimate(r));
    uint256 sz = _encode(r, 32, bs);
    assembly {
      mstore(bs, sz)
    }
    return bs;
  }
  // inner encoder

  /**
   * @dev The encoder for internal usage
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    uint256 offset = p;
    uint256 pointer = p;

    pointer += ProtoBufRuntime._encode_key(
      1,
      ProtoBufRuntime.WireType.LengthDelim,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_string(r.type_url, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(
      2,
      ProtoBufRuntime.WireType.LengthDelim,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_bytes(r.value, pointer, bs);
    return pointer - offset;
  }
  // nested encoder

  /**
   * @dev The encoder for inner struct
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode_nested(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    /**
     * First encoded `r` into a temporary array, and encode the actual size used.
     * Then copy the temporary array into `bs`.
     */
    uint256 offset = p;
    uint256 pointer = p;
    bytes memory tmp = new bytes(_estimate(r));
    uint256 tmpAddr = ProtoBufRuntime.getMemoryAddress(tmp);
    uint256 bsAddr = ProtoBufRuntime.getMemoryAddress(bs);
    uint256 size = _encode(r, 32, tmp);
    pointer += ProtoBufRuntime._encode_varint(size, pointer, bs);
    ProtoBufRuntime.copyBytes(tmpAddr + 32, bsAddr + pointer, size);
    pointer += size;
    delete tmp;
    return pointer - offset;
  }
  // estimator

  /**
   * @dev The estimator for a struct
   * @param r The struct to be encoded
   * @return The number of bytes encoded in estimation
   */
  function _estimate(
    Data memory r
  ) internal pure returns (uint) {
    uint256 e;
    e += 1 + ProtoBufRuntime._sz_lendelim(bytes(r.type_url).length);
    e += 1 + ProtoBufRuntime._sz_lendelim(r.value.length);
    return e;
  }

  //store function
  /**
   * @dev Store in-memory struct to storage
   * @param input The in-memory struct
   * @param output The in-storage struct
   */
  function store(Data memory input, Data storage output) internal {
    output.type_url = input.type_url;
    output.value = input.value;

  }



  //utility functions
  /**
   * @dev Return an empty struct
   * @return r The empty struct
   */
  function nil() internal pure returns (Data memory r) {
    assembly {
      r := 0
    }
  }

  /**
   * @dev Test whether a struct is empty
   * @param x The struct to be tested
   * @return r True if it is empty
   */
  function isNil(Data memory x) internal pure returns (bool r) {
    assembly {
      r := iszero(x)
    }
  }
}
//library Any
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;


/**
 * @title Runtime library for ProtoBuf serialization and/or deserialization.
 * All ProtoBuf generated code will use this library.
 */
library ProtoBufRuntime {
  // Types defined in ProtoBuf
  enum WireType { Varint, Fixed64, LengthDelim, StartGroup, EndGroup, Fixed32 }
  // Constants for bytes calculation
  uint256 constant WORD_LENGTH = 32;
  uint256 constant HEADER_SIZE_LENGTH_IN_BYTES = 4;
  uint256 constant BYTE_SIZE = 8;
  uint256 constant REMAINING_LENGTH = WORD_LENGTH - HEADER_SIZE_LENGTH_IN_BYTES;
  string constant OVERFLOW_MESSAGE = "length overflow";

  //Storages
  /**
   * @dev Encode to storage location using assembly to save storage space.
   * @param location The location of storage
   * @param encoded The encoded ProtoBuf bytes
   */
  function encodeStorage(bytes storage location, bytes memory encoded)
    internal
  {
    /**
     * This code use the first four bytes as size,
     * and then put the rest of `encoded` bytes.
     */
    uint256 length = encoded.length;
    uint256 firstWord;
    uint256 wordLength = WORD_LENGTH;
    uint256 remainingLength = REMAINING_LENGTH;

    assembly {
      firstWord := mload(add(encoded, wordLength))
    }
    firstWord =
      (firstWord >> (BYTE_SIZE * HEADER_SIZE_LENGTH_IN_BYTES)) |
      (length << (BYTE_SIZE * REMAINING_LENGTH));

    assembly {
      sstore(location.slot, firstWord)
    }

    if (length > REMAINING_LENGTH) {
      length -= REMAINING_LENGTH;
      for (uint256 i = 0; i < ceil(length, WORD_LENGTH); i++) {
        assembly {
          let offset := add(mul(i, wordLength), remainingLength)
          let slotIndex := add(i, 1)
          sstore(
            add(location.slot, slotIndex),
            mload(add(add(encoded, wordLength), offset))
          )
        }
      }
    }
  }

  /**
   * @dev Decode storage location using assembly using the format in `encodeStorage`.
   * @param location The location of storage
   * @return The encoded bytes
   */
  function decodeStorage(bytes storage location)
    internal
    view
    returns (bytes memory)
  {
    /**
     * This code is to decode the first four bytes as size,
     * and then decode the rest using the decoded size.
     */
    uint256 firstWord;
    uint256 remainingLength = REMAINING_LENGTH;
    uint256 wordLength = WORD_LENGTH;

    assembly {
      firstWord := sload(location.slot)
    }

    uint256 length = firstWord >> (BYTE_SIZE * REMAINING_LENGTH);
    bytes memory encoded = new bytes(length);

    assembly {
      mstore(add(encoded, remainingLength), firstWord)
    }

    if (length > REMAINING_LENGTH) {
      length -= REMAINING_LENGTH;
      for (uint256 i = 0; i < ceil(length, WORD_LENGTH); i++) {
        assembly {
          let offset := add(mul(i, wordLength), remainingLength)
          let slotIndex := add(i, 1)
          mstore(
            add(add(encoded, wordLength), offset),
            sload(add(location.slot, slotIndex))
          )
        }
      }
    }
    return encoded;
  }

  /**
   * @dev Fast memory copy of bytes using assembly.
   * @param src The source memory address
   * @param dest The destination memory address
   * @param len The length of bytes to copy
   */
  function copyBytes(uint256 src, uint256 dest, uint256 len) internal pure {
    if (len == 0) {
      return;
    }

    // Copy word-length chunks while possible
    for (; len > WORD_LENGTH; len -= WORD_LENGTH) {
      assembly {
        mstore(dest, mload(src))
      }
      dest += WORD_LENGTH;
      src += WORD_LENGTH;
    }

    // Copy remaining bytes
    uint256 mask = 256**(WORD_LENGTH - len) - 1;
    assembly {
      let srcpart := and(mload(src), not(mask))
      let destpart := and(mload(dest), mask)
      mstore(dest, or(destpart, srcpart))
    }
  }

  /**
   * @dev Use assembly to get memory address.
   * @param r The in-memory bytes array
   * @return The memory address of `r`
   */
  function getMemoryAddress(bytes memory r) internal pure returns (uint256) {
    uint256 addr;
    assembly {
      addr := r
    }
    return addr;
  }

  /**
   * @dev Implement Math function of ceil
   * @param a The denominator
   * @param m The numerator
   * @return r The result of ceil(a/m)
   */
  function ceil(uint256 a, uint256 m) internal pure returns (uint256 r) {
    return (a + m - 1) / m;
  }

  // Decoders
  /**
   * This section of code `_decode_(u)int(32|64)`, `_decode_enum` and `_decode_bool`
   * is to decode ProtoBuf native integers,
   * using the `varint` encoding.
   */

  /**
   * @dev Decode integers
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The decoded integer
   * @return The length of `bs` used to get decoded
   */
  function _decode_uint32(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint32, uint256)
  {
    (uint256 varint, uint256 sz) = _decode_varint(p, bs);
    return (uint32(varint), sz);
  }

  /**
   * @dev Decode integers
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The decoded integer
   * @return The length of `bs` used to get decoded
   */
  function _decode_uint64(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint64, uint256)
  {
    (uint256 varint, uint256 sz) = _decode_varint(p, bs);
    return (uint64(varint), sz);
  }

  /**
   * @dev Decode integers
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The decoded integer
   * @return The length of `bs` used to get decoded
   */
  function _decode_int32(uint256 p, bytes memory bs)
    internal
    pure
    returns (int32, uint256)
  {
    (uint256 varint, uint256 sz) = _decode_varint(p, bs);
    int32 r;
    assembly {
      r := varint
    }
    return (r, sz);
  }

  /**
   * @dev Decode integers
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The decoded integer
   * @return The length of `bs` used to get decoded
   */
  function _decode_int64(uint256 p, bytes memory bs)
    internal
    pure
    returns (int64, uint256)
  {
    (uint256 varint, uint256 sz) = _decode_varint(p, bs);
    int64 r;
    assembly {
      r := varint
    }
    return (r, sz);
  }

  /**
   * @dev Decode enum
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The decoded enum's integer
   * @return The length of `bs` used to get decoded
   */
  function _decode_enum(uint256 p, bytes memory bs)
    internal
    pure
    returns (int64, uint256)
  {
    return _decode_int64(p, bs);
  }

  /**
   * @dev Decode enum
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The decoded boolean
   * @return The length of `bs` used to get decoded
   */
  function _decode_bool(uint256 p, bytes memory bs)
    internal
    pure
    returns (bool, uint256)
  {
    (uint256 varint, uint256 sz) = _decode_varint(p, bs);
    if (varint == 0) {
      return (false, sz);
    }
    return (true, sz);
  }

  /**
   * This section of code `_decode_sint(32|64)`
   * is to decode ProtoBuf native signed integers,
   * using the `zig-zag` encoding.
   */

  /**
   * @dev Decode signed integers
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The decoded integer
   * @return The length of `bs` used to get decoded
   */
  function _decode_sint32(uint256 p, bytes memory bs)
    internal
    pure
    returns (int32, uint256)
  {
    (int256 varint, uint256 sz) = _decode_varints(p, bs);
    return (int32(varint), sz);
  }

  /**
   * @dev Decode signed integers
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The decoded integer
   * @return The length of `bs` used to get decoded
   */
  function _decode_sint64(uint256 p, bytes memory bs)
    internal
    pure
    returns (int64, uint256)
  {
    (int256 varint, uint256 sz) = _decode_varints(p, bs);
    return (int64(varint), sz);
  }

  /**
   * @dev Decode string
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The decoded string
   * @return The length of `bs` used to get decoded
   */
  function _decode_string(uint256 p, bytes memory bs)
    internal
    pure
    returns (string memory, uint256)
  {
    (bytes memory x, uint256 sz) = _decode_lendelim(p, bs);
    return (string(x), sz);
  }

  /**
   * @dev Decode bytes array
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The decoded bytes array
   * @return The length of `bs` used to get decoded
   */
  function _decode_bytes(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes memory, uint256)
  {
    return _decode_lendelim(p, bs);
  }

  /**
   * @dev Decode ProtoBuf key
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The decoded field ID
   * @return The decoded WireType specified in ProtoBuf
   * @return The length of `bs` used to get decoded
   */
  function _decode_key(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256, WireType, uint256)
  {
    (uint256 x, uint256 n) = _decode_varint(p, bs);
    WireType typeId = WireType(x & 7);
    uint256 fieldId = x / 8;
    return (fieldId, typeId, n);
  }

  /**
   * @dev Decode ProtoBuf varint
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The decoded unsigned integer
   * @return The length of `bs` used to get decoded
   */
  function _decode_varint(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256, uint256)
  {
    /**
     * Read a byte.
     * Use the lower 7 bits and shift it to the left,
     * until the most significant bit is 0.
     * Refer to https://developers.google.com/protocol-buffers/docs/encoding
     */
    uint256 x = 0;
    uint256 sz = 0;
    uint256 length = bs.length + WORD_LENGTH;
    assembly {
      let b := 0x80
      p := add(bs, p)
      for {

      } eq(0x80, and(b, 0x80)) {

      } {
        if eq(lt(sub(p, bs), length), 0) {
          mstore(
            0,
            0x08c379a000000000000000000000000000000000000000000000000000000000
          ) //error function selector
          mstore(4, 32)
          mstore(36, 15)
          mstore(
            68,
            0x6c656e677468206f766572666c6f770000000000000000000000000000000000
          ) // length overflow in hex
          revert(0, 83)
        }
        let tmp := mload(p)
        let pos := 0
        for {

        } and(eq(0x80, and(b, 0x80)), lt(pos, 32)) {

        } {
          if eq(lt(sub(p, bs), length), 0) {
            mstore(
              0,
              0x08c379a000000000000000000000000000000000000000000000000000000000
            ) //error function selector
            mstore(4, 32)
            mstore(36, 15)
            mstore(
              68,
              0x6c656e677468206f766572666c6f770000000000000000000000000000000000
            ) // length overflow in hex
            revert(0, 83)
          }
          b := byte(pos, tmp)
          x := or(x, shl(mul(7, sz), and(0x7f, b)))
          sz := add(sz, 1)
          pos := add(pos, 1)
          p := add(p, 0x01)
        }
      }
    }
    return (x, sz);
  }

  /**
   * @dev Decode ProtoBuf zig-zag encoding
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The decoded signed integer
   * @return The length of `bs` used to get decoded
   */
  function _decode_varints(uint256 p, bytes memory bs)
    internal
    pure
    returns (int256, uint256)
  {
    /**
     * Refer to https://developers.google.com/protocol-buffers/docs/encoding
     */
    (uint256 u, uint256 sz) = _decode_varint(p, bs);
    int256 s;
    assembly {
      s := xor(shr(1, u), add(not(and(u, 1)), 1))
    }
    return (s, sz);
  }

  /**
   * @dev Decode ProtoBuf fixed-length encoding
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The decoded unsigned integer
   * @return The length of `bs` used to get decoded
   */
  function _decode_uintf(uint256 p, bytes memory bs, uint256 sz)
    internal
    pure
    returns (uint256, uint256)
  {
    /**
     * Refer to https://developers.google.com/protocol-buffers/docs/encoding
     */
    uint256 x = 0;
    uint256 length = bs.length + WORD_LENGTH;
    assert(p + sz <= length);
    assembly {
      let i := 0
      p := add(bs, p)
      let tmp := mload(p)
      for {

      } lt(i, sz) {

      } {
        x := or(x, shl(mul(8, i), byte(i, tmp)))
        p := add(p, 0x01)
        i := add(i, 1)
      }
    }
    return (x, sz);
  }

  /**
   * `_decode_(s)fixed(32|64)` is the concrete implementation of `_decode_uintf`
   */
  function _decode_fixed32(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint32, uint256)
  {
    (uint256 x, uint256 sz) = _decode_uintf(p, bs, 4);
    return (uint32(x), sz);
  }

  function _decode_fixed64(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint64, uint256)
  {
    (uint256 x, uint256 sz) = _decode_uintf(p, bs, 8);
    return (uint64(x), sz);
  }

  function _decode_sfixed32(uint256 p, bytes memory bs)
    internal
    pure
    returns (int32, uint256)
  {
    (uint256 x, uint256 sz) = _decode_uintf(p, bs, 4);
    int256 r;
    assembly {
      r := x
    }
    return (int32(r), sz);
  }

  function _decode_sfixed64(uint256 p, bytes memory bs)
    internal
    pure
    returns (int64, uint256)
  {
    (uint256 x, uint256 sz) = _decode_uintf(p, bs, 8);
    int256 r;
    assembly {
      r := x
    }
    return (int64(r), sz);
  }

  /**
   * @dev Decode bytes array
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The decoded bytes array
   * @return The length of `bs` used to get decoded
   */
  function _decode_lendelim(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes memory, uint256)
  {
    /**
     * First read the size encoded in `varint`, then use the size to read bytes.
     */
    (uint256 len, uint256 sz) = _decode_varint(p, bs);
    bytes memory b = new bytes(len);
    uint256 length = bs.length + WORD_LENGTH;
    assert(p + sz + len <= length);
    uint256 sourcePtr;
    uint256 destPtr;
    assembly {
      destPtr := add(b, 32)
      sourcePtr := add(add(bs, p), sz)
    }
    copyBytes(sourcePtr, destPtr, len);
    return (b, sz + len);
  }

  /**
   * @dev Skip the decoding of a single field
   * @param wt The WireType of the field
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The length of `bs` to skipped
   */
  function _skip_field_decode(WireType wt, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    if (wt == ProtoBufRuntime.WireType.Fixed64) {
      return 8;
    } else if (wt == ProtoBufRuntime.WireType.Fixed32) {
      return 4;
    } else if (wt == ProtoBufRuntime.WireType.Varint) {
      (, uint256 size) = ProtoBufRuntime._decode_varint(p, bs);
      return size;
    } else {
      require(wt == ProtoBufRuntime.WireType.LengthDelim);
      (uint256 len, uint256 size) = ProtoBufRuntime._decode_varint(p, bs);
      return size + len;
    }
  }

  // Encoders
  /**
   * @dev Encode ProtoBuf key
   * @param x The field ID
   * @param wt The WireType specified in ProtoBuf
   * @param p The offset of bytes array `bs`
   * @param bs The bytes array to encode
   * @return The length of encoded bytes
   */
  function _encode_key(uint256 x, WireType wt, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    uint256 i;
    assembly {
      i := or(mul(x, 8), mod(wt, 8))
    }
    return _encode_varint(i, p, bs);
  }

  /**
   * @dev Encode ProtoBuf varint
   * @param x The unsigned integer to be encoded
   * @param p The offset of bytes array `bs`
   * @param bs The bytes array to encode
   * @return The length of encoded bytes
   */
  function _encode_varint(uint256 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    /**
     * Refer to https://developers.google.com/protocol-buffers/docs/encoding
     */
    uint256 sz = 0;
    assembly {
      let bsptr := add(bs, p)
      let byt := and(x, 0x7f)
      for {

      } gt(shr(7, x), 0) {

      } {
        mstore8(bsptr, or(0x80, byt))
        bsptr := add(bsptr, 1)
        sz := add(sz, 1)
        x := shr(7, x)
        byt := and(x, 0x7f)
      }
      mstore8(bsptr, byt)
      sz := add(sz, 1)
    }
    return sz;
  }

  /**
   * @dev Encode ProtoBuf zig-zag encoding
   * @param x The signed integer to be encoded
   * @param p The offset of bytes array `bs`
   * @param bs The bytes array to encode
   * @return The length of encoded bytes
   */
  function _encode_varints(int256 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    /**
     * Refer to https://developers.google.com/protocol-buffers/docs/encoding
     */
    uint256 encodedInt = _encode_zigzag(x);
    return _encode_varint(encodedInt, p, bs);
  }

  /**
   * @dev Encode ProtoBuf bytes
   * @param xs The bytes array to be encoded
   * @param p The offset of bytes array `bs`
   * @param bs The bytes array to encode
   * @return The length of encoded bytes
   */
  function _encode_bytes(bytes memory xs, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    uint256 xsLength = xs.length;
    uint256 sz = _encode_varint(xsLength, p, bs);
    uint256 count = 0;
    assembly {
      let bsptr := add(bs, add(p, sz))
      let xsptr := add(xs, 32)
      for {

      } lt(count, xsLength) {

      } {
        mstore8(bsptr, byte(0, mload(xsptr)))
        bsptr := add(bsptr, 1)
        xsptr := add(xsptr, 1)
        count := add(count, 1)
      }
    }
    return sz + count;
  }

  /**
   * @dev Encode ProtoBuf string
   * @param xs The string to be encoded
   * @param p The offset of bytes array `bs`
   * @param bs The bytes array to encode
   * @return The length of encoded bytes
   */
  function _encode_string(string memory xs, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_bytes(bytes(xs), p, bs);
  }

  /**
   * `_encode_(u)int(32|64)`, `_encode_enum` and `_encode_bool`
   * are concrete implementation of `_encode_varint`
   */
  function _encode_uint32(uint32 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_varint(x, p, bs);
  }

  function _encode_uint64(uint64 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_varint(x, p, bs);
  }

  function _encode_int32(int32 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    uint64 twosComplement;
    assembly {
      twosComplement := x
    }
    return _encode_varint(twosComplement, p, bs);
  }

  function _encode_int64(int64 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    uint64 twosComplement;
    assembly {
      twosComplement := x
    }
    return _encode_varint(twosComplement, p, bs);
  }

  function _encode_enum(int32 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_int32(x, p, bs);
  }

  function _encode_bool(bool x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    if (x) {
      return _encode_varint(1, p, bs);
    } else return _encode_varint(0, p, bs);
  }

  /**
   * `_encode_sint(32|64)`, `_encode_enum` and `_encode_bool`
   * are the concrete implementation of `_encode_varints`
   */
  function _encode_sint32(int32 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_varints(x, p, bs);
  }

  function _encode_sint64(int64 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_varints(x, p, bs);
  }

  /**
   * `_encode_(s)fixed(32|64)` is the concrete implementation of `_encode_uintf`
   */
  function _encode_fixed32(uint32 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_uintf(x, p, bs, 4);
  }

  function _encode_fixed64(uint64 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_uintf(x, p, bs, 8);
  }

  function _encode_sfixed32(int32 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    uint32 twosComplement;
    assembly {
      twosComplement := x
    }
    return _encode_uintf(twosComplement, p, bs, 4);
  }

  function _encode_sfixed64(int64 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    uint64 twosComplement;
    assembly {
      twosComplement := x
    }
    return _encode_uintf(twosComplement, p, bs, 8);
  }

  /**
   * @dev Encode ProtoBuf fixed-length integer
   * @param x The unsigned integer to be encoded
   * @param p The offset of bytes array `bs`
   * @param bs The bytes array to encode
   * @return The length of encoded bytes
   */
  function _encode_uintf(uint256 x, uint256 p, bytes memory bs, uint256 sz)
    internal
    pure
    returns (uint256)
  {
    assembly {
      let bsptr := add(sz, add(bs, p))
      let count := sz
      for {

      } gt(count, 0) {

      } {
        bsptr := sub(bsptr, 1)
        mstore8(bsptr, byte(sub(32, count), x))
        count := sub(count, 1)
      }
    }
    return sz;
  }

  /**
   * @dev Encode ProtoBuf zig-zag signed integer
   * @param i The unsigned integer to be encoded
   * @return The encoded unsigned integer
   */
  function _encode_zigzag(int256 i) internal pure returns (uint256) {
    if (i >= 0) {
      return uint256(i) * 2;
    } else return uint256(i * -2) - 1;
  }

  // Estimators
  /**
   * @dev Estimate the length of encoded LengthDelim
   * @param i The length of LengthDelim
   * @return The estimated encoded length
   */
  function _sz_lendelim(uint256 i) internal pure returns (uint256) {
    return i + _sz_varint(i);
  }

  /**
   * @dev Estimate the length of encoded ProtoBuf field ID
   * @param i The field ID
   * @return The estimated encoded length
   */
  function _sz_key(uint256 i) internal pure returns (uint256) {
    if (i < 16) {
      return 1;
    } else if (i < 2048) {
      return 2;
    } else if (i < 262144) {
      return 3;
    } else {
      revert("not supported");
    }
  }

  /**
   * @dev Estimate the length of encoded ProtoBuf varint
   * @param i The unsigned integer
   * @return The estimated encoded length
   */
  function _sz_varint(uint256 i) internal pure returns (uint256) {
    uint256 count = 1;
    assembly {
      i := shr(7, i)
      for {

      } gt(i, 0) {

      } {
        i := shr(7, i)
        count := add(count, 1)
      }
    }
    return count;
  }

  /**
   * `_sz_(u)int(32|64)` and `_sz_enum` are the concrete implementation of `_sz_varint`
   */
  function _sz_uint32(uint32 i) internal pure returns (uint256) {
    return _sz_varint(i);
  }

  function _sz_uint64(uint64 i) internal pure returns (uint256) {
    return _sz_varint(i);
  }

  function _sz_int32(int32 i) internal pure returns (uint256) {
    if (i < 0) {
      return 10;
    } else return _sz_varint(uint32(i));
  }

  function _sz_int64(int64 i) internal pure returns (uint256) {
    if (i < 0) {
      return 10;
    } else return _sz_varint(uint64(i));
  }

  function _sz_enum(int64 i) internal pure returns (uint256) {
    if (i < 0) {
      return 10;
    } else return _sz_varint(uint64(i));
  }

  /**
   * `_sz_sint(32|64)` and `_sz_enum` are the concrete implementation of zig-zag encoding
   */
  function _sz_sint32(int32 i) internal pure returns (uint256) {
    return _sz_varint(_encode_zigzag(i));
  }

  function _sz_sint64(int64 i) internal pure returns (uint256) {
    return _sz_varint(_encode_zigzag(i));
  }

  /**
   * `_estimate_packed_repeated_(uint32|uint64|int32|int64|sint32|sint64)`
   */
  function _estimate_packed_repeated_uint32(uint32[] memory a) internal pure returns (uint256) {
    uint256 e = 0;
    for (uint i = 0; i < a.length; i++) {
      e += _sz_uint32(a[i]);
    }
    return e;
  }

  function _estimate_packed_repeated_uint64(uint64[] memory a) internal pure returns (uint256) {
    uint256 e = 0;
    for (uint i = 0; i < a.length; i++) {
      e += _sz_uint64(a[i]);
    }
    return e;
  }

  function _estimate_packed_repeated_int32(int32[] memory a) internal pure returns (uint256) {
    uint256 e = 0;
    for (uint i = 0; i < a.length; i++) {
      e += _sz_int32(a[i]);
    }
    return e;
  }

  function _estimate_packed_repeated_int64(int64[] memory a) internal pure returns (uint256) {
    uint256 e = 0;
    for (uint i = 0; i < a.length; i++) {
      e += _sz_int64(a[i]);
    }
    return e;
  }

  function _estimate_packed_repeated_sint32(int32[] memory a) internal pure returns (uint256) {
    uint256 e = 0;
    for (uint i = 0; i < a.length; i++) {
      e += _sz_sint32(a[i]);
    }
    return e;
  }

  function _estimate_packed_repeated_sint64(int64[] memory a) internal pure returns (uint256) {
    uint256 e = 0;
    for (uint i = 0; i < a.length; i++) {
      e += _sz_sint64(a[i]);
    }
    return e;
  }

  // Element counters for packed repeated fields
  function _count_packed_repeated_varint(uint256 p, uint256 len, bytes memory bs) internal pure returns (uint256) {
    uint256 count = 0;
    uint256 end = p + len;
    while (p < end) {
      uint256 sz;
      (, sz) = _decode_varint(p, bs);
      p += sz;
      count += 1;
    }
    return count;
  }

  // Soltype extensions
  /**
   * @dev Decode Solidity integer and/or fixed-size bytes array, filling from lowest bit.
   * @param n The maximum number of bytes to read
   * @param p The offset of bytes array `bs`
   * @param bs The bytes array to encode
   * @return The bytes32 representation
   * @return The number of bytes used to decode
   */
  function _decode_sol_bytesN_lower(uint8 n, uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes32, uint256)
  {
    uint256 r;
    (uint256 len, uint256 sz) = _decode_varint(p, bs);
    if (len + sz > n + 3) {
      revert(OVERFLOW_MESSAGE);
    }
    p += 3;
    assert(p < bs.length + WORD_LENGTH);
    assembly {
      r := mload(add(p, bs))
    }
    for (uint256 i = len - 2; i < WORD_LENGTH; i++) {
      r /= 256;
    }
    return (bytes32(r), len + sz);
  }

  /**
   * @dev Decode Solidity integer and/or fixed-size bytes array, filling from highest bit.
   * @param n The maximum number of bytes to read
   * @param p The offset of bytes array `bs`
   * @param bs The bytes array to encode
   * @return The bytes32 representation
   * @return The number of bytes used to decode
   */
  function _decode_sol_bytesN(uint8 n, uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes32, uint256)
  {
    (uint256 len, uint256 sz) = _decode_varint(p, bs);
    uint256 wordLength = WORD_LENGTH;
    uint256 byteSize = BYTE_SIZE;
    if (len + sz > n + 3) {
      revert(OVERFLOW_MESSAGE);
    }
    p += 3;
    bytes32 acc;
    assert(p < bs.length + WORD_LENGTH);
    assembly {
      acc := mload(add(p, bs))
      let difference := sub(wordLength, sub(len, 2))
      let bits := mul(byteSize, difference)
      acc := shl(bits, shr(bits, acc))
    }
    return (acc, len + sz);
  }

  /*
   * `_decode_sol*` are the concrete implementation of decoding Solidity types
   */
  function _decode_sol_address(uint256 p, bytes memory bs)
    internal
    pure
    returns (address, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytesN(20, p, bs);
    return (address(bytes20(r)), sz);
  }

  function _decode_sol_bool(uint256 p, bytes memory bs)
    internal
    pure
    returns (bool, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(1, p, bs);
    if (r == 0) {
      return (false, sz);
    }
    return (true, sz);
  }

  function _decode_sol_uint(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256, uint256)
  {
    return _decode_sol_uint256(p, bs);
  }

  function _decode_sol_uintN(uint8 n, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256, uint256)
  {
    (bytes32 u, uint256 sz) = _decode_sol_bytesN_lower(n, p, bs);
    uint256 r;
    assembly {
      r := u
    }
    return (r, sz);
  }

  function _decode_sol_uint8(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint8, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(1, p, bs);
    return (uint8(r), sz);
  }

  function _decode_sol_uint16(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint16, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(2, p, bs);
    return (uint16(r), sz);
  }

  function _decode_sol_uint24(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint24, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(3, p, bs);
    return (uint24(r), sz);
  }

  function _decode_sol_uint32(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint32, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(4, p, bs);
    return (uint32(r), sz);
  }

  function _decode_sol_uint40(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint40, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(5, p, bs);
    return (uint40(r), sz);
  }

  function _decode_sol_uint48(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint48, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(6, p, bs);
    return (uint48(r), sz);
  }

  function _decode_sol_uint56(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint56, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(7, p, bs);
    return (uint56(r), sz);
  }

  function _decode_sol_uint64(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint64, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(8, p, bs);
    return (uint64(r), sz);
  }

  function _decode_sol_uint72(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint72, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(9, p, bs);
    return (uint72(r), sz);
  }

  function _decode_sol_uint80(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint80, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(10, p, bs);
    return (uint80(r), sz);
  }

  function _decode_sol_uint88(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint88, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(11, p, bs);
    return (uint88(r), sz);
  }

  function _decode_sol_uint96(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint96, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(12, p, bs);
    return (uint96(r), sz);
  }

  function _decode_sol_uint104(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint104, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(13, p, bs);
    return (uint104(r), sz);
  }

  function _decode_sol_uint112(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint112, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(14, p, bs);
    return (uint112(r), sz);
  }

  function _decode_sol_uint120(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint120, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(15, p, bs);
    return (uint120(r), sz);
  }

  function _decode_sol_uint128(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint128, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(16, p, bs);
    return (uint128(r), sz);
  }

  function _decode_sol_uint136(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint136, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(17, p, bs);
    return (uint136(r), sz);
  }

  function _decode_sol_uint144(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint144, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(18, p, bs);
    return (uint144(r), sz);
  }

  function _decode_sol_uint152(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint152, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(19, p, bs);
    return (uint152(r), sz);
  }

  function _decode_sol_uint160(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint160, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(20, p, bs);
    return (uint160(r), sz);
  }

  function _decode_sol_uint168(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint168, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(21, p, bs);
    return (uint168(r), sz);
  }

  function _decode_sol_uint176(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint176, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(22, p, bs);
    return (uint176(r), sz);
  }

  function _decode_sol_uint184(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint184, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(23, p, bs);
    return (uint184(r), sz);
  }

  function _decode_sol_uint192(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint192, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(24, p, bs);
    return (uint192(r), sz);
  }

  function _decode_sol_uint200(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint200, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(25, p, bs);
    return (uint200(r), sz);
  }

  function _decode_sol_uint208(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint208, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(26, p, bs);
    return (uint208(r), sz);
  }

  function _decode_sol_uint216(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint216, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(27, p, bs);
    return (uint216(r), sz);
  }

  function _decode_sol_uint224(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint224, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(28, p, bs);
    return (uint224(r), sz);
  }

  function _decode_sol_uint232(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint232, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(29, p, bs);
    return (uint232(r), sz);
  }

  function _decode_sol_uint240(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint240, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(30, p, bs);
    return (uint240(r), sz);
  }

  function _decode_sol_uint248(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint248, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(31, p, bs);
    return (uint248(r), sz);
  }

  function _decode_sol_uint256(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(32, p, bs);
    return (uint256(r), sz);
  }

  function _decode_sol_int(uint256 p, bytes memory bs)
    internal
    pure
    returns (int256, uint256)
  {
    return _decode_sol_int256(p, bs);
  }

  function _decode_sol_intN(uint8 n, uint256 p, bytes memory bs)
    internal
    pure
    returns (int256, uint256)
  {
    (bytes32 u, uint256 sz) = _decode_sol_bytesN_lower(n, p, bs);
    int256 r;
    assembly {
      r := u
      r := signextend(sub(sz, 4), r)
    }
    return (r, sz);
  }

  function _decode_sol_bytes(uint8 n, uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes32, uint256)
  {
    (bytes32 u, uint256 sz) = _decode_sol_bytesN(n, p, bs);
    return (u, sz);
  }

  function _decode_sol_int8(uint256 p, bytes memory bs)
    internal
    pure
    returns (int8, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(1, p, bs);
    return (int8(r), sz);
  }

  function _decode_sol_int16(uint256 p, bytes memory bs)
    internal
    pure
    returns (int16, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(2, p, bs);
    return (int16(r), sz);
  }

  function _decode_sol_int24(uint256 p, bytes memory bs)
    internal
    pure
    returns (int24, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(3, p, bs);
    return (int24(r), sz);
  }

  function _decode_sol_int32(uint256 p, bytes memory bs)
    internal
    pure
    returns (int32, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(4, p, bs);
    return (int32(r), sz);
  }

  function _decode_sol_int40(uint256 p, bytes memory bs)
    internal
    pure
    returns (int40, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(5, p, bs);
    return (int40(r), sz);
  }

  function _decode_sol_int48(uint256 p, bytes memory bs)
    internal
    pure
    returns (int48, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(6, p, bs);
    return (int48(r), sz);
  }

  function _decode_sol_int56(uint256 p, bytes memory bs)
    internal
    pure
    returns (int56, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(7, p, bs);
    return (int56(r), sz);
  }

  function _decode_sol_int64(uint256 p, bytes memory bs)
    internal
    pure
    returns (int64, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(8, p, bs);
    return (int64(r), sz);
  }

  function _decode_sol_int72(uint256 p, bytes memory bs)
    internal
    pure
    returns (int72, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(9, p, bs);
    return (int72(r), sz);
  }

  function _decode_sol_int80(uint256 p, bytes memory bs)
    internal
    pure
    returns (int80, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(10, p, bs);
    return (int80(r), sz);
  }

  function _decode_sol_int88(uint256 p, bytes memory bs)
    internal
    pure
    returns (int88, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(11, p, bs);
    return (int88(r), sz);
  }

  function _decode_sol_int96(uint256 p, bytes memory bs)
    internal
    pure
    returns (int96, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(12, p, bs);
    return (int96(r), sz);
  }

  function _decode_sol_int104(uint256 p, bytes memory bs)
    internal
    pure
    returns (int104, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(13, p, bs);
    return (int104(r), sz);
  }

  function _decode_sol_int112(uint256 p, bytes memory bs)
    internal
    pure
    returns (int112, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(14, p, bs);
    return (int112(r), sz);
  }

  function _decode_sol_int120(uint256 p, bytes memory bs)
    internal
    pure
    returns (int120, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(15, p, bs);
    return (int120(r), sz);
  }

  function _decode_sol_int128(uint256 p, bytes memory bs)
    internal
    pure
    returns (int128, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(16, p, bs);
    return (int128(r), sz);
  }

  function _decode_sol_int136(uint256 p, bytes memory bs)
    internal
    pure
    returns (int136, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(17, p, bs);
    return (int136(r), sz);
  }

  function _decode_sol_int144(uint256 p, bytes memory bs)
    internal
    pure
    returns (int144, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(18, p, bs);
    return (int144(r), sz);
  }

  function _decode_sol_int152(uint256 p, bytes memory bs)
    internal
    pure
    returns (int152, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(19, p, bs);
    return (int152(r), sz);
  }

  function _decode_sol_int160(uint256 p, bytes memory bs)
    internal
    pure
    returns (int160, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(20, p, bs);
    return (int160(r), sz);
  }

  function _decode_sol_int168(uint256 p, bytes memory bs)
    internal
    pure
    returns (int168, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(21, p, bs);
    return (int168(r), sz);
  }

  function _decode_sol_int176(uint256 p, bytes memory bs)
    internal
    pure
    returns (int176, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(22, p, bs);
    return (int176(r), sz);
  }

  function _decode_sol_int184(uint256 p, bytes memory bs)
    internal
    pure
    returns (int184, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(23, p, bs);
    return (int184(r), sz);
  }

  function _decode_sol_int192(uint256 p, bytes memory bs)
    internal
    pure
    returns (int192, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(24, p, bs);
    return (int192(r), sz);
  }

  function _decode_sol_int200(uint256 p, bytes memory bs)
    internal
    pure
    returns (int200, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(25, p, bs);
    return (int200(r), sz);
  }

  function _decode_sol_int208(uint256 p, bytes memory bs)
    internal
    pure
    returns (int208, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(26, p, bs);
    return (int208(r), sz);
  }

  function _decode_sol_int216(uint256 p, bytes memory bs)
    internal
    pure
    returns (int216, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(27, p, bs);
    return (int216(r), sz);
  }

  function _decode_sol_int224(uint256 p, bytes memory bs)
    internal
    pure
    returns (int224, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(28, p, bs);
    return (int224(r), sz);
  }

  function _decode_sol_int232(uint256 p, bytes memory bs)
    internal
    pure
    returns (int232, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(29, p, bs);
    return (int232(r), sz);
  }

  function _decode_sol_int240(uint256 p, bytes memory bs)
    internal
    pure
    returns (int240, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(30, p, bs);
    return (int240(r), sz);
  }

  function _decode_sol_int248(uint256 p, bytes memory bs)
    internal
    pure
    returns (int248, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(31, p, bs);
    return (int248(r), sz);
  }

  function _decode_sol_int256(uint256 p, bytes memory bs)
    internal
    pure
    returns (int256, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(32, p, bs);
    return (int256(r), sz);
  }

  function _decode_sol_bytes1(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes1, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(1, p, bs);
    return (bytes1(r), sz);
  }

  function _decode_sol_bytes2(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes2, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(2, p, bs);
    return (bytes2(r), sz);
  }

  function _decode_sol_bytes3(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes3, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(3, p, bs);
    return (bytes3(r), sz);
  }

  function _decode_sol_bytes4(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes4, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(4, p, bs);
    return (bytes4(r), sz);
  }

  function _decode_sol_bytes5(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes5, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(5, p, bs);
    return (bytes5(r), sz);
  }

  function _decode_sol_bytes6(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes6, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(6, p, bs);
    return (bytes6(r), sz);
  }

  function _decode_sol_bytes7(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes7, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(7, p, bs);
    return (bytes7(r), sz);
  }

  function _decode_sol_bytes8(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes8, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(8, p, bs);
    return (bytes8(r), sz);
  }

  function _decode_sol_bytes9(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes9, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(9, p, bs);
    return (bytes9(r), sz);
  }

  function _decode_sol_bytes10(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes10, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(10, p, bs);
    return (bytes10(r), sz);
  }

  function _decode_sol_bytes11(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes11, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(11, p, bs);
    return (bytes11(r), sz);
  }

  function _decode_sol_bytes12(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes12, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(12, p, bs);
    return (bytes12(r), sz);
  }

  function _decode_sol_bytes13(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes13, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(13, p, bs);
    return (bytes13(r), sz);
  }

  function _decode_sol_bytes14(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes14, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(14, p, bs);
    return (bytes14(r), sz);
  }

  function _decode_sol_bytes15(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes15, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(15, p, bs);
    return (bytes15(r), sz);
  }

  function _decode_sol_bytes16(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes16, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(16, p, bs);
    return (bytes16(r), sz);
  }

  function _decode_sol_bytes17(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes17, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(17, p, bs);
    return (bytes17(r), sz);
  }

  function _decode_sol_bytes18(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes18, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(18, p, bs);
    return (bytes18(r), sz);
  }

  function _decode_sol_bytes19(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes19, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(19, p, bs);
    return (bytes19(r), sz);
  }

  function _decode_sol_bytes20(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes20, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(20, p, bs);
    return (bytes20(r), sz);
  }

  function _decode_sol_bytes21(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes21, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(21, p, bs);
    return (bytes21(r), sz);
  }

  function _decode_sol_bytes22(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes22, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(22, p, bs);
    return (bytes22(r), sz);
  }

  function _decode_sol_bytes23(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes23, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(23, p, bs);
    return (bytes23(r), sz);
  }

  function _decode_sol_bytes24(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes24, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(24, p, bs);
    return (bytes24(r), sz);
  }

  function _decode_sol_bytes25(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes25, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(25, p, bs);
    return (bytes25(r), sz);
  }

  function _decode_sol_bytes26(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes26, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(26, p, bs);
    return (bytes26(r), sz);
  }

  function _decode_sol_bytes27(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes27, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(27, p, bs);
    return (bytes27(r), sz);
  }

  function _decode_sol_bytes28(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes28, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(28, p, bs);
    return (bytes28(r), sz);
  }

  function _decode_sol_bytes29(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes29, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(29, p, bs);
    return (bytes29(r), sz);
  }

  function _decode_sol_bytes30(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes30, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(30, p, bs);
    return (bytes30(r), sz);
  }

  function _decode_sol_bytes31(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes31, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(31, p, bs);
    return (bytes31(r), sz);
  }

  function _decode_sol_bytes32(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes32, uint256)
  {
    return _decode_sol_bytes(32, p, bs);
  }

  /*
   * `_encode_sol*` are the concrete implementation of encoding Solidity types
   */
  function _encode_sol_address(address x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(uint160(x)), 20, p, bs);
  }

  function _encode_sol_uint(uint256 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 32, p, bs);
  }

  function _encode_sol_uint8(uint8 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 1, p, bs);
  }

  function _encode_sol_uint16(uint16 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 2, p, bs);
  }

  function _encode_sol_uint24(uint24 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 3, p, bs);
  }

  function _encode_sol_uint32(uint32 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 4, p, bs);
  }

  function _encode_sol_uint40(uint40 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 5, p, bs);
  }

  function _encode_sol_uint48(uint48 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 6, p, bs);
  }

  function _encode_sol_uint56(uint56 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 7, p, bs);
  }

  function _encode_sol_uint64(uint64 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 8, p, bs);
  }

  function _encode_sol_uint72(uint72 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 9, p, bs);
  }

  function _encode_sol_uint80(uint80 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 10, p, bs);
  }

  function _encode_sol_uint88(uint88 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 11, p, bs);
  }

  function _encode_sol_uint96(uint96 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 12, p, bs);
  }

  function _encode_sol_uint104(uint104 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 13, p, bs);
  }

  function _encode_sol_uint112(uint112 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 14, p, bs);
  }

  function _encode_sol_uint120(uint120 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 15, p, bs);
  }

  function _encode_sol_uint128(uint128 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 16, p, bs);
  }

  function _encode_sol_uint136(uint136 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 17, p, bs);
  }

  function _encode_sol_uint144(uint144 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 18, p, bs);
  }

  function _encode_sol_uint152(uint152 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 19, p, bs);
  }

  function _encode_sol_uint160(uint160 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 20, p, bs);
  }

  function _encode_sol_uint168(uint168 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 21, p, bs);
  }

  function _encode_sol_uint176(uint176 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 22, p, bs);
  }

  function _encode_sol_uint184(uint184 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 23, p, bs);
  }

  function _encode_sol_uint192(uint192 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 24, p, bs);
  }

  function _encode_sol_uint200(uint200 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 25, p, bs);
  }

  function _encode_sol_uint208(uint208 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 26, p, bs);
  }

  function _encode_sol_uint216(uint216 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 27, p, bs);
  }

  function _encode_sol_uint224(uint224 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 28, p, bs);
  }

  function _encode_sol_uint232(uint232 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 29, p, bs);
  }

  function _encode_sol_uint240(uint240 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 30, p, bs);
  }

  function _encode_sol_uint248(uint248 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 31, p, bs);
  }

  function _encode_sol_uint256(uint256 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 32, p, bs);
  }

  function _encode_sol_int(int256 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(x, 32, p, bs);
  }

  function _encode_sol_int8(int8 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 1, p, bs);
  }

  function _encode_sol_int16(int16 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 2, p, bs);
  }

  function _encode_sol_int24(int24 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 3, p, bs);
  }

  function _encode_sol_int32(int32 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 4, p, bs);
  }

  function _encode_sol_int40(int40 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 5, p, bs);
  }

  function _encode_sol_int48(int48 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 6, p, bs);
  }

  function _encode_sol_int56(int56 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 7, p, bs);
  }

  function _encode_sol_int64(int64 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 8, p, bs);
  }

  function _encode_sol_int72(int72 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 9, p, bs);
  }

  function _encode_sol_int80(int80 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 10, p, bs);
  }

  function _encode_sol_int88(int88 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 11, p, bs);
  }

  function _encode_sol_int96(int96 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 12, p, bs);
  }

  function _encode_sol_int104(int104 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 13, p, bs);
  }

  function _encode_sol_int112(int112 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 14, p, bs);
  }

  function _encode_sol_int120(int120 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 15, p, bs);
  }

  function _encode_sol_int128(int128 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 16, p, bs);
  }

  function _encode_sol_int136(int136 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 17, p, bs);
  }

  function _encode_sol_int144(int144 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 18, p, bs);
  }

  function _encode_sol_int152(int152 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 19, p, bs);
  }

  function _encode_sol_int160(int160 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 20, p, bs);
  }

  function _encode_sol_int168(int168 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 21, p, bs);
  }

  function _encode_sol_int176(int176 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 22, p, bs);
  }

  function _encode_sol_int184(int184 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 23, p, bs);
  }

  function _encode_sol_int192(int192 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 24, p, bs);
  }

  function _encode_sol_int200(int200 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 25, p, bs);
  }

  function _encode_sol_int208(int208 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 26, p, bs);
  }

  function _encode_sol_int216(int216 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 27, p, bs);
  }

  function _encode_sol_int224(int224 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 28, p, bs);
  }

  function _encode_sol_int232(int232 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 29, p, bs);
  }

  function _encode_sol_int240(int240 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 30, p, bs);
  }

  function _encode_sol_int248(int248 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 31, p, bs);
  }

  function _encode_sol_int256(int256 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(x, 32, p, bs);
  }

  function _encode_sol_bytes1(bytes1 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 1, p, bs);
  }

  function _encode_sol_bytes2(bytes2 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 2, p, bs);
  }

  function _encode_sol_bytes3(bytes3 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 3, p, bs);
  }

  function _encode_sol_bytes4(bytes4 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 4, p, bs);
  }

  function _encode_sol_bytes5(bytes5 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 5, p, bs);
  }

  function _encode_sol_bytes6(bytes6 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 6, p, bs);
  }

  function _encode_sol_bytes7(bytes7 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 7, p, bs);
  }

  function _encode_sol_bytes8(bytes8 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 8, p, bs);
  }

  function _encode_sol_bytes9(bytes9 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 9, p, bs);
  }

  function _encode_sol_bytes10(bytes10 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 10, p, bs);
  }

  function _encode_sol_bytes11(bytes11 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 11, p, bs);
  }

  function _encode_sol_bytes12(bytes12 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 12, p, bs);
  }

  function _encode_sol_bytes13(bytes13 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 13, p, bs);
  }

  function _encode_sol_bytes14(bytes14 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 14, p, bs);
  }

  function _encode_sol_bytes15(bytes15 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 15, p, bs);
  }

  function _encode_sol_bytes16(bytes16 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 16, p, bs);
  }

  function _encode_sol_bytes17(bytes17 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 17, p, bs);
  }

  function _encode_sol_bytes18(bytes18 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 18, p, bs);
  }

  function _encode_sol_bytes19(bytes19 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 19, p, bs);
  }

  function _encode_sol_bytes20(bytes20 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 20, p, bs);
  }

  function _encode_sol_bytes21(bytes21 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 21, p, bs);
  }

  function _encode_sol_bytes22(bytes22 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 22, p, bs);
  }

  function _encode_sol_bytes23(bytes23 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 23, p, bs);
  }

  function _encode_sol_bytes24(bytes24 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 24, p, bs);
  }

  function _encode_sol_bytes25(bytes25 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 25, p, bs);
  }

  function _encode_sol_bytes26(bytes26 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 26, p, bs);
  }

  function _encode_sol_bytes27(bytes27 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 27, p, bs);
  }

  function _encode_sol_bytes28(bytes28 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 28, p, bs);
  }

  function _encode_sol_bytes29(bytes29 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 29, p, bs);
  }

  function _encode_sol_bytes30(bytes30 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 30, p, bs);
  }

  function _encode_sol_bytes31(bytes31 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 31, p, bs);
  }

  function _encode_sol_bytes32(bytes32 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(x, 32, p, bs);
  }

  /**
   * @dev Encode the key of Solidity integer and/or fixed-size bytes array.
   * @param sz The number of bytes used to encode Solidity types
   * @param p The offset of bytes array `bs`
   * @param bs The bytes array to encode
   * @return The number of bytes used to encode
   */
  function _encode_sol_header(uint256 sz, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    uint256 offset = p;
    p += _encode_varint(sz + 2, p, bs);
    p += _encode_key(1, WireType.LengthDelim, p, bs);
    p += _encode_varint(sz, p, bs);
    return p - offset;
  }

  /**
   * @dev Encode Solidity type
   * @param x The unsinged integer to be encoded
   * @param sz The number of bytes used to encode Solidity types
   * @param p The offset of bytes array `bs`
   * @param bs The bytes array to encode
   * @return The number of bytes used to encode
   */
  function _encode_sol(uint256 x, uint256 sz, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    uint256 offset = p;
    uint256 size;
    p += 3;
    size = _encode_sol_raw_other(x, p, bs, sz);
    p += size;
    _encode_sol_header(size, offset, bs);
    return p - offset;
  }

  /**
   * @dev Encode Solidity type
   * @param x The signed integer to be encoded
   * @param sz The number of bytes used to encode Solidity types
   * @param p The offset of bytes array `bs`
   * @param bs The bytes array to encode
   * @return The number of bytes used to encode
   */
  function _encode_sol(int256 x, uint256 sz, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    uint256 offset = p;
    uint256 size;
    p += 3;
    size = _encode_sol_raw_other(x, p, bs, sz);
    p += size;
    _encode_sol_header(size, offset, bs);
    return p - offset;
  }

  /**
   * @dev Encode Solidity type
   * @param x The fixed-size byte array to be encoded
   * @param sz The number of bytes used to encode Solidity types
   * @param p The offset of bytes array `bs`
   * @param bs The bytes array to encode
   * @return The number of bytes used to encode
   */
  function _encode_sol_bytes(bytes32 x, uint256 sz, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    uint256 offset = p;
    uint256 size;
    p += 3;
    size = _encode_sol_raw_bytes_array(x, p, bs, sz);
    p += size;
    _encode_sol_header(size, offset, bs);
    return p - offset;
  }

  /**
   * @dev Get the actual size needed to encoding an unsigned integer
   * @param x The unsigned integer to be encoded
   * @param sz The maximum number of bytes used to encode Solidity types
   * @return The number of bytes needed for encoding `x`
   */
  function _get_real_size(uint256 x, uint256 sz)
    internal
    pure
    returns (uint256)
  {
    uint256 base = 0xff;
    uint256 realSize = sz;
    while (
      x & (base << (realSize * BYTE_SIZE - BYTE_SIZE)) == 0 && realSize > 0
    ) {
      realSize -= 1;
    }
    if (realSize == 0) {
      realSize = 1;
    }
    return realSize;
  }

  /**
   * @dev Get the actual size needed to encoding an signed integer
   * @param x The signed integer to be encoded
   * @param sz The maximum number of bytes used to encode Solidity types
   * @return The number of bytes needed for encoding `x`
   */
  function _get_real_size(int256 x, uint256 sz)
    internal
    pure
    returns (uint256)
  {
    int256 base = 0xff;
    if (x >= 0) {
      uint256 tmp = _get_real_size(uint256(x), sz);
      int256 remainder = (x & (base << (tmp * BYTE_SIZE - BYTE_SIZE))) >>
        (tmp * BYTE_SIZE - BYTE_SIZE);
      if (remainder >= 128) {
        tmp += 1;
      }
      return tmp;
    }

    uint256 realSize = sz;
    while (
      x & (base << (realSize * BYTE_SIZE - BYTE_SIZE)) ==
      (base << (realSize * BYTE_SIZE - BYTE_SIZE)) &&
      realSize > 0
    ) {
      realSize -= 1;
    }
    {
      int256 remainder = (x & (base << (realSize * BYTE_SIZE - BYTE_SIZE))) >>
        (realSize * BYTE_SIZE - BYTE_SIZE);
      if (remainder < 128) {
        realSize += 1;
      }
    }
    return realSize;
  }

  /**
   * @dev Encode the fixed-bytes array
   * @param x The fixed-size byte array to be encoded
   * @param sz The maximum number of bytes used to encode Solidity types
   * @param p The offset of bytes array `bs`
   * @param bs The bytes array to encode
   * @return The number of bytes needed for encoding `x`
   */
  function _encode_sol_raw_bytes_array(
    bytes32 x,
    uint256 p,
    bytes memory bs,
    uint256 sz
  ) internal pure returns (uint256) {
    /**
     * The idea is to not encode the leading bytes of zero.
     */
    uint256 actualSize = sz;
    for (uint256 i = 0; i < sz; i++) {
      uint8 current = uint8(x[sz - 1 - i]);
      if (current == 0 && actualSize > 1) {
        actualSize--;
      } else {
        break;
      }
    }
    assembly {
      let bsptr := add(bs, p)
      let count := actualSize
      for {

      } gt(count, 0) {

      } {
        mstore8(bsptr, byte(sub(actualSize, count), x))
        bsptr := add(bsptr, 1)
        count := sub(count, 1)
      }
    }
    return actualSize;
  }

  /**
   * @dev Encode the signed integer
   * @param x The signed integer to be encoded
   * @param sz The maximum number of bytes used to encode Solidity types
   * @param p The offset of bytes array `bs`
   * @param bs The bytes array to encode
   * @return The number of bytes needed for encoding `x`
   */
  function _encode_sol_raw_other(
    int256 x,
    uint256 p,
    bytes memory bs,
    uint256 sz
  ) internal pure returns (uint256) {
    /**
     * The idea is to not encode the leading bytes of zero.or one,
     * depending on whether it is positive.
     */
    uint256 realSize = _get_real_size(x, sz);
    assembly {
      let bsptr := add(bs, p)
      let count := realSize
      for {

      } gt(count, 0) {

      } {
        mstore8(bsptr, byte(sub(32, count), x))
        bsptr := add(bsptr, 1)
        count := sub(count, 1)
      }
    }
    return realSize;
  }

  /**
   * @dev Encode the unsigned integer
   * @param x The unsigned integer to be encoded
   * @param sz The maximum number of bytes used to encode Solidity types
   * @param p The offset of bytes array `bs`
   * @param bs The bytes array to encode
   * @return The number of bytes needed for encoding `x`
   */
  function _encode_sol_raw_other(
    uint256 x,
    uint256 p,
    bytes memory bs,
    uint256 sz
  ) internal pure returns (uint256) {
    uint256 realSize = _get_real_size(x, sz);
    assembly {
      let bsptr := add(bs, p)
      let count := realSize
      for {

      } gt(count, 0) {

      } {
        mstore8(bsptr, byte(sub(32, count), x))
        bsptr := add(bsptr, 1)
        count := sub(count, 1)
      }
    }
    return realSize;
  }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.20;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS
    }

    /**
     * @dev The signature derives the `address(0)`.
     */
    error ECDSAInvalidSignature();

    /**
     * @dev The signature has an invalid length.
     */
    error ECDSAInvalidSignatureLength(uint256 length);

    /**
     * @dev The signature has an S value that is in the upper half order.
     */
    error ECDSAInvalidSignatureS(bytes32 s);

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with `signature` or an error. This will not
     * return address(0) without also returning an error description. Errors are documented using an enum (error type)
     * and a bytes32 providing additional information about the error.
     *
     * If no error is returned, then the address can be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     */
    function tryRecover(
        bytes32 hash,
        bytes memory signature
    ) internal pure returns (address recovered, RecoverError err, bytes32 errArg) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly ("memory-safe") {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength, bytes32(signature.length));
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, signature);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[ERC-2098 short signatures]
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address recovered, RecoverError err, bytes32 errArg) {
        unchecked {
            bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
            // We do not check for an overflow here since the shift operation results in 0 or 1.
            uint8 v = uint8((uint256(vs) >> 255) + 27);
            return tryRecover(hash, v, r, s);
        }
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, r, vs);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address recovered, RecoverError err, bytes32 errArg) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS, s);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature, bytes32(0));
        }

        return (signer, RecoverError.NoError, bytes32(0));
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, v, r, s);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Optionally reverts with the corresponding custom error according to the `error` argument provided.
     */
    function _throwError(RecoverError error, bytes32 errorArg) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert ECDSAInvalidSignature();
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert ECDSAInvalidSignatureLength(uint256(errorArg));
        } else if (error == RecoverError.InvalidSignatureS) {
            revert ECDSAInvalidSignatureS(errorArg);
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

/// @title Base64
/// @author Brecht Devos - <brecht@loopring.org>
/// @notice Provides functions for encoding/decoding base64
library Base64 {
    string internal constant TABLE_ENCODE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    bytes  internal constant TABLE_DECODE = hex"0000000000000000000000000000000000000000000000000000000000000000"
                                            hex"00000000000000000000003e0000003f3435363738393a3b3c3d000000000000"
                                            hex"00000102030405060708090a0b0c0d0e0f101112131415161718190000000000"
                                            hex"001a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132330000000000";

    function encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return '';

        // load the table into memory
        string memory table = TABLE_ENCODE;

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        // add some extra buffer at the end required for the writing
        string memory result = new string(encodedLen + 32);

        assembly {
            // set the actual output length
            mstore(result, encodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 3 bytes at a time
            for {} lt(dataPtr, endPtr) {}
            {
                // read 3 bytes
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                // write 4 characters
                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr( 6, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(        input,  0x3F))))
                resultPtr := add(resultPtr, 1)
            }

            // padding with '='
            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
        }

        return result;
    }

    function decode(string memory _data) internal pure returns (bytes memory) {
        bytes memory data = bytes(_data);

        if (data.length == 0) return new bytes(0);
        require(data.length % 4 == 0, "invalid base64 decoder input");

        // load the table into memory
        bytes memory table = TABLE_DECODE;

        // every 4 characters represent 3 bytes
        uint256 decodedLen = (data.length / 4) * 3;

        // add some extra buffer at the end required for the writing
        bytes memory result = new bytes(decodedLen + 32);

        assembly {
            // padding with '='
            let lastBytes := mload(add(data, mload(data)))
            if eq(and(lastBytes, 0xFF), 0x3d) {
                decodedLen := sub(decodedLen, 1)
                if eq(and(lastBytes, 0xFFFF), 0x3d3d) {
                    decodedLen := sub(decodedLen, 1)
                }
            }

            // set the actual output length
            mstore(result, decodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 4 characters at a time
            for {} lt(dataPtr, endPtr) {}
            {
               // read 4 characters
               dataPtr := add(dataPtr, 4)
               let input := mload(dataPtr)

               // write 3 bytes
               let output := add(
                   add(
                       shl(18, and(mload(add(tablePtr, and(shr(24, input), 0xFF))), 0xFF)),
                       shl(12, and(mload(add(tablePtr, and(shr(16, input), 0xFF))), 0xFF))),
                   add(
                       shl( 6, and(mload(add(tablePtr, and(shr( 8, input), 0xFF))), 0xFF)),
                               and(mload(add(tablePtr, and(        input , 0xFF))), 0xFF)
                    )
                )
                mstore(resultPtr, shl(232, output))
                resultPtr := add(resultPtr, 3)
            }
        }

        return result;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ----------------------------------------------------------------------------
// DateTime Library v2.0
//
// A gas-efficient Solidity date and time library
//
// https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
//
// Tested date range 1970/01/01 to 2345/12/31
//
// Conventions:
// Unit      | Range         | Notes
// :-------- |:-------------:|:-----
// timestamp | >= 0          | Unix timestamp, number of seconds since 1970/01/01 00:00:00 UTC
// year      | 1970 ... 2345 |
// month     | 1 ... 12      |
// day       | 1 ... 31      |
// hour      | 0 ... 23      |
// minute    | 0 ... 59      |
// second    | 0 ... 59      |
// dayOfWeek | 1 ... 7       | 1 = Monday, ..., 7 = Sunday
//
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018-2019. The MIT Licence.
// ----------------------------------------------------------------------------

library DateTime {
    uint256 constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint256 constant SECONDS_PER_HOUR = 60 * 60;
    uint256 constant SECONDS_PER_MINUTE = 60;
    int256 constant OFFSET19700101 = 2440588;

    uint256 constant DOW_MON = 1;
    uint256 constant DOW_TUE = 2;
    uint256 constant DOW_WED = 3;
    uint256 constant DOW_THU = 4;
    uint256 constant DOW_FRI = 5;
    uint256 constant DOW_SAT = 6;
    uint256 constant DOW_SUN = 7;

    // ------------------------------------------------------------------------
    // Calculate the number of days from 1970/01/01 to year/month/day using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and subtracting the offset 2440588 so that 1970/01/01 is day 0
    //
    // days = day
    //      - 32075
    //      + 1461 * (year + 4800 + (month - 14) / 12) / 4
    //      + 367 * (month - 2 - (month - 14) / 12 * 12) / 12
    //      - 3 * ((year + 4900 + (month - 14) / 12) / 100) / 4
    //      - offset
    // ------------------------------------------------------------------------
    function _daysFromDate(uint256 year, uint256 month, uint256 day) internal pure returns (uint256 _days) {
        require(year >= 1970);
        int256 _year = int256(year);
        int256 _month = int256(month);
        int256 _day = int256(day);

        int256 __days = _day - 32075 + (1461 * (_year + 4800 + (_month - 14) / 12)) / 4
            + (367 * (_month - 2 - ((_month - 14) / 12) * 12)) / 12
            - (3 * ((_year + 4900 + (_month - 14) / 12) / 100)) / 4 - OFFSET19700101;

        _days = uint256(__days);
    }

    // ------------------------------------------------------------------------
    // Calculate year/month/day from the number of days since 1970/01/01 using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and adding the offset 2440588 so that 1970/01/01 is day 0
    //
    // int L = days + 68569 + offset
    // int N = 4 * L / 146097
    // L = L - (146097 * N + 3) / 4
    // year = 4000 * (L + 1) / 1461001
    // L = L - 1461 * year / 4 + 31
    // month = 80 * L / 2447
    // dd = L - 2447 * month / 80
    // L = month / 11
    // month = month + 2 - 12 * L
    // year = 100 * (N - 49) + year + L
    // ------------------------------------------------------------------------
    function _daysToDate(uint256 _days) internal pure returns (uint256 year, uint256 month, uint256 day) {
        unchecked {
            int256 __days = int256(_days);

            int256 L = __days + 68569 + OFFSET19700101;
            int256 N = (4 * L) / 146097;
            L = L - (146097 * N + 3) / 4;
            int256 _year = (4000 * (L + 1)) / 1461001;
            L = L - (1461 * _year) / 4 + 31;
            int256 _month = (80 * L) / 2447;
            int256 _day = L - (2447 * _month) / 80;
            L = _month / 11;
            _month = _month + 2 - 12 * L;
            _year = 100 * (N - 49) + _year + L;

            year = uint256(_year);
            month = uint256(_month);
            day = uint256(_day);
        }
    }

    function timestampFromDate(uint256 year, uint256 month, uint256 day) internal pure returns (uint256 timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }

    function timestampFromDateTime(
        uint256 year,
        uint256 month,
        uint256 day,
        uint256 hour,
        uint256 minute,
        uint256 second
    )
        internal
        pure
        returns (uint256 timestamp)
    {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + hour * SECONDS_PER_HOUR
            + minute * SECONDS_PER_MINUTE + second;
    }

    function timestampToDate(uint256 timestamp) internal pure returns (uint256 year, uint256 month, uint256 day) {
        unchecked {
            (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        }
    }

    function timestampToDateTime(uint256 timestamp)
        internal
        pure
        returns (uint256 year, uint256 month, uint256 day, uint256 hour, uint256 minute, uint256 second)
    {
        unchecked {
            (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
            uint256 secs = timestamp % SECONDS_PER_DAY;
            hour = secs / SECONDS_PER_HOUR;
            secs = secs % SECONDS_PER_HOUR;
            minute = secs / SECONDS_PER_MINUTE;
            second = secs % SECONDS_PER_MINUTE;
        }
    }

    function isValidDate(uint256 year, uint256 month, uint256 day) internal pure returns (bool valid) {
        if (year >= 1970 && month > 0 && month <= 12) {
            uint256 daysInMonth = _getDaysInMonth(year, month);
            if (day > 0 && day <= daysInMonth) {
                valid = true;
            }
        }
    }

    function isValidDateTime(uint256 year, uint256 month, uint256 day, uint256 hour, uint256 minute, uint256 second)
        internal
        pure
        returns (bool valid)
    {
        if (isValidDate(year, month, day)) {
            if (hour < 24 && minute < 60 && second < 60) {
                valid = true;
            }
        }
    }

    function isLeapYear(uint256 timestamp) internal pure returns (bool leapYear) {
        (uint256 year,,) = _daysToDate(timestamp / SECONDS_PER_DAY);
        leapYear = _isLeapYear(year);
    }

    function _isLeapYear(uint256 year) internal pure returns (bool leapYear) {
        leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
    }

    function isWeekDay(uint256 timestamp) internal pure returns (bool weekDay) {
        weekDay = getDayOfWeek(timestamp) <= DOW_FRI;
    }

    function isWeekEnd(uint256 timestamp) internal pure returns (bool weekEnd) {
        weekEnd = getDayOfWeek(timestamp) >= DOW_SAT;
    }

    function getDaysInMonth(uint256 timestamp) internal pure returns (uint256 daysInMonth) {
        (uint256 year, uint256 month,) = _daysToDate(timestamp / SECONDS_PER_DAY);
        daysInMonth = _getDaysInMonth(year, month);
    }

    function _getDaysInMonth(uint256 year, uint256 month) internal pure returns (uint256 daysInMonth) {
        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            daysInMonth = 31;
        } else if (month != 2) {
            daysInMonth = 30;
        } else {
            daysInMonth = _isLeapYear(year) ? 29 : 28;
        }
    }

    // 1 = Monday, 7 = Sunday
    function getDayOfWeek(uint256 timestamp) internal pure returns (uint256 dayOfWeek) {
        uint256 _days = timestamp / SECONDS_PER_DAY;
        dayOfWeek = ((_days + 3) % 7) + 1;
    }

    function getYear(uint256 timestamp) internal pure returns (uint256 year) {
        (year,,) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function getMonth(uint256 timestamp) internal pure returns (uint256 month) {
        (, month,) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function getDay(uint256 timestamp) internal pure returns (uint256 day) {
        (,, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function getHour(uint256 timestamp) internal pure returns (uint256 hour) {
        uint256 secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
    }

    function getMinute(uint256 timestamp) internal pure returns (uint256 minute) {
        uint256 secs = timestamp % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
    }

    function getSecond(uint256 timestamp) internal pure returns (uint256 second) {
        second = timestamp % SECONDS_PER_MINUTE;
    }

    function addYears(uint256 timestamp, uint256 _years) internal pure returns (uint256 newTimestamp) {
        (uint256 year, uint256 month, uint256 day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year += _years;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + (timestamp % SECONDS_PER_DAY);
        require(newTimestamp >= timestamp);
    }

    function addMonths(uint256 timestamp, uint256 _months) internal pure returns (uint256 newTimestamp) {
        (uint256 year, uint256 month, uint256 day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        month += _months;
        year += (month - 1) / 12;
        month = ((month - 1) % 12) + 1;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + (timestamp % SECONDS_PER_DAY);
        require(newTimestamp >= timestamp);
    }

    function addDays(uint256 timestamp, uint256 _days) internal pure returns (uint256 newTimestamp) {
        newTimestamp = timestamp + _days * SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }

    function addHours(uint256 timestamp, uint256 _hours) internal pure returns (uint256 newTimestamp) {
        newTimestamp = timestamp + _hours * SECONDS_PER_HOUR;
        require(newTimestamp >= timestamp);
    }

    function addMinutes(uint256 timestamp, uint256 _minutes) internal pure returns (uint256 newTimestamp) {
        newTimestamp = timestamp + _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp >= timestamp);
    }

    function addSeconds(uint256 timestamp, uint256 _seconds) internal pure returns (uint256 newTimestamp) {
        newTimestamp = timestamp + _seconds;
        require(newTimestamp >= timestamp);
    }

    function subYears(uint256 timestamp, uint256 _years) internal pure returns (uint256 newTimestamp) {
        (uint256 year, uint256 month, uint256 day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year -= _years;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + (timestamp % SECONDS_PER_DAY);
        require(newTimestamp <= timestamp);
    }

    function subMonths(uint256 timestamp, uint256 _months) internal pure returns (uint256 newTimestamp) {
        (uint256 year, uint256 month, uint256 day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint256 yearMonth = year * 12 + (month - 1) - _months;
        year = yearMonth / 12;
        month = (yearMonth % 12) + 1;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + (timestamp % SECONDS_PER_DAY);
        require(newTimestamp <= timestamp);
    }

    function subDays(uint256 timestamp, uint256 _days) internal pure returns (uint256 newTimestamp) {
        newTimestamp = timestamp - _days * SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }

    function subHours(uint256 timestamp, uint256 _hours) internal pure returns (uint256 newTimestamp) {
        newTimestamp = timestamp - _hours * SECONDS_PER_HOUR;
        require(newTimestamp <= timestamp);
    }

    function subMinutes(uint256 timestamp, uint256 _minutes) internal pure returns (uint256 newTimestamp) {
        newTimestamp = timestamp - _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp <= timestamp);
    }

    function subSeconds(uint256 timestamp, uint256 _seconds) internal pure returns (uint256 newTimestamp) {
        newTimestamp = timestamp - _seconds;
        require(newTimestamp <= timestamp);
    }

    function diffYears(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _years) {
        require(fromTimestamp <= toTimestamp);
        (uint256 fromYear,,) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint256 toYear,,) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _years = toYear - fromYear;
    }

    function diffMonths(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _months) {
        require(fromTimestamp <= toTimestamp);
        (uint256 fromYear, uint256 fromMonth,) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint256 toYear, uint256 toMonth,) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _months = toYear * 12 + toMonth - fromYear * 12 - fromMonth;
    }

    function diffDays(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _days) {
        require(fromTimestamp <= toTimestamp);
        _days = (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
    }

    function diffHours(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _hours) {
        require(fromTimestamp <= toTimestamp);
        _hours = (toTimestamp - fromTimestamp) / SECONDS_PER_HOUR;
    }

    function diffMinutes(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _minutes) {
        require(fromTimestamp <= toTimestamp);
        _minutes = (toTimestamp - fromTimestamp) / SECONDS_PER_MINUTE;
    }

    function diffSeconds(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _seconds) {
        require(fromTimestamp <= toTimestamp);
        _seconds = toTimestamp - fromTimestamp;
    }
}