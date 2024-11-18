// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ICoprocessor} from "./ICoprocessor.sol";

interface ICoprocess {
    function getCoprocessor() external view returns (ICoprocessor);
    function process(bytes calldata transcript) external;
}
