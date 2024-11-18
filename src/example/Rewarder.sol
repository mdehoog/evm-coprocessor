// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Coprocess} from "../Coprocess.sol";
import {ICoprocessor} from "../ICoprocessor.sol";
import {Miner} from "./Miner.sol";
import {Listener} from "./Listener.sol";

contract Rewarder is Coprocess {
    Miner[] public miners;
    Listener[] public listeners;

    mapping(address => uint256) public rewards;

    event Winner(address winner);

    constructor(ICoprocessor coprocessor) Coprocess(coprocessor) {}

    function addMiner(Miner miner) public {
        miners.push(miner);
    }

    function addListener(Listener listener) public {
        listeners.push(listener);
    }

    function run(bytes32 hash) public coprocess {
        uint256 min = 2 ** 256 - 1;
        address winner;

        for (uint256 i = 0; i < miners.length; i++) {
            bytes32 h = keccak256(abi.encodePacked(hash, i));
            uint256 start = gasleft();
            miners[i].mine(h);
            uint256 gas = start - gasleft();
            if (gas < min) {
                min = gas;
                winner = address(miners[i]);
            }
        }

        rewards[winner] += 1;
        emit Winner(winner);

        for (uint256 i = 0; i < listeners.length; i++) {
            listeners[i].notify(winner);
        }
    }
}
