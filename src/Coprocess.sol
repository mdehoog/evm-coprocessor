// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Storage} from "./Storage.sol";
import {ICoprocess} from "./ICoprocess.sol";
import {ICoprocessor} from "./ICoprocessor.sol";

abstract contract Coprocess is ICoprocess, Storage {
    bytes32 public constant COPROCESSOR_SLOT = bytes32(uint256(keccak256("coprocess.coprocessor")) - 1);

    constructor(ICoprocessor coprocessor) {
        setAddress(COPROCESSOR_SLOT, address(coprocessor));
    }

    function getCoprocessor() public view returns (ICoprocessor) {
        return ICoprocessor(getAddress(COPROCESSOR_SLOT));
    }

    modifier coprocess() {
        bytes32 hash = keccak256(msg.data);
        if (!getCoprocessor().enqueue(address(this), hash)) {
            _;
        }
    }

    function process(bytes calldata transcript) external {
        require(msg.sender == address(getCoprocessor()));

        // TODO decode transcript into [*calls, sload checks, sstores, logs], and replay
    }
}
