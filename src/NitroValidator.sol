// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {CBORDecoding} from "@solidity-cbor/CBORDecoding.sol";
import {CertManager} from "@nitroprover/CertManager.sol";
import {NitroProver} from "@nitroprover/NitroProver.sol";

contract NitroValidator is NitroProver {
    constructor(CertManager certManager) NitroProver(certManager) {}

    function validateAttestation(bytes memory attestation, uint256 maxAge)
        external
        view
        returns (bytes memory, bytes memory)
    {
        (bytes memory enclaveKey,, bytes memory rawPcrs) = verifyAttestation(attestation, maxAge);
        bytes memory pcr0 = CBORDecoding.decodeMappingGetValue(rawPcrs, hex"00");
        return (enclaveKey, pcr0);
    }
}
