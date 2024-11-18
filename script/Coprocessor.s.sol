// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Listener} from "../src/example/Listener.sol";
import {Miner} from "../src/example/Miner.sol";
import {Rewarder} from "../src/example/Rewarder.sol";
import {Coprocessor} from "../src/Coprocessor.sol";
import {NitroValidator} from "../src/NitroValidator.sol";
import {CertManager} from "@nitroprover/CertManager.sol";

contract CoprocessorScript is Script {
    Coprocessor public coprocessor;
    Rewarder public rewarder;

    function setUp() public {
        CertManager certManager = new CertManager();
        NitroValidator validator = new NitroValidator(certManager);
        coprocessor = new Coprocessor(validator, "");
        rewarder = new Rewarder(coprocessor);
        for (uint256 i = 0; i < 10; i++) {
            rewarder.addMiner(new Miner(rewarder));
        }
        for (uint256 i = 0; i < 2; i++) {
            rewarder.addListener(new Listener());
        }
    }

    function run() public {
        bytes32 hash = keccak256(abi.encodePacked("hello"));
        rewarder.run(hash);
    }
}
