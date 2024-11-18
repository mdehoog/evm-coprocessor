// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface ICoprocessor {
    function enqueue(address addr, bytes32 hash) external returns (bool);
}
