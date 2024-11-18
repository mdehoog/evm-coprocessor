// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IOffchain {
    function isOffchain() external returns (bool);
    function getStorageRoot() external returns (bytes32);
    function setStorageRoot(bytes32 oldRoot, bytes32 newRoot) external;
}
