// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ICoprocessor} from "./ICoprocessor.sol";
import {ICoprocess} from "./ICoprocess.sol";
import {IOffchain} from "./IOffchain.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {NitroValidator} from "./NitroValidator.sol";

contract Coprocessor is ICoprocessor {
    NitroValidator public immutable nitroValidator;
    bytes32 public immutable pcr0Hash;

    mapping(address => bool) public validSigners;

    mapping(address => mapping(uint256 => bytes32)) public queue;
    mapping(address => uint256) public first;
    mapping(address => uint256) public last;
    bool public offchain = false;

    constructor(NitroValidator _nitroValidator, bytes memory _pcr0) {
        nitroValidator = _nitroValidator;
        pcr0Hash = keccak256(_pcr0);
    }

    function registerSigner(bytes calldata attestation) external {
        (bytes memory enclavePublicKey, bytes memory pcr0) = nitroValidator.validateAttestation(attestation, 10 minutes);
        require(keccak256(pcr0) == pcr0Hash, "invalid pcr0 in attestation");

        address enclaveAddress = address(uint160(uint256(keccak256(enclavePublicKey))));
        validSigners[enclaveAddress] = true;
    }

    function enqueue(address addr, bytes32 hash) public returns (bool) {
        if (offchain) {
            return false;
        }
        last[addr] += 1;
        queue[addr][last[addr]] = keccak256(abi.encodePacked(hash, block.number));
        return true;
    }

    function run(
        address addr,
        uint256 number,
        bytes calldata _offchain,
        bytes calldata transcript,
        bytes calldata signature
    ) public {
        require(last[addr] > first[addr]);
        bytes32 hash = queue[addr][first[addr]];
        delete queue[addr][first[addr]];
        first[addr] += 1;

        bytes32 blockHash = blockhash(number);
        require(blockHash != bytes32(0));
        address signer = ECDSA.recover(keccak256(abi.encodePacked(blockHash, hash, _offchain, transcript)), signature);
        require(validSigners[signer], "invalid signature");

        require(_offchain.length % 84 == 0);
        for (uint256 i = 0; i < _offchain.length / 84; i++) {
            address a = address(uint160(uint256(keccak256(_offchain[i * 84:i * 84 + 20]))));
            bytes32 oldRoot = bytes32(uint256(keccak256(_offchain[i * 84 + 20:i * 84 + 52])));
            bytes32 newRoot = bytes32(uint256(keccak256(_offchain[i * 84 + 52:i * 84 + 84])));
            IOffchain(a).setStorageRoot(oldRoot, newRoot);
        }

        ICoprocess(addr).process(transcript);
    }
}
