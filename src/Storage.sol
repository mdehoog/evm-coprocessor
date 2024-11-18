// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

abstract contract Storage {
    function getBytes32(bytes32 slot) internal view returns (bytes32 value) {
        assembly {
            value := sload(slot)
        }
    }

    function setBytes32(bytes32 slot, bytes32 value) internal {
        assembly {
            sstore(slot, value)
        }
    }

    function getAddress(bytes32 slot) internal view returns (address value) {
        assembly {
            value := sload(slot)
        }
    }

    function setAddress(bytes32 slot, address value) internal {
        assembly {
            sstore(slot, value)
        }
    }
}
