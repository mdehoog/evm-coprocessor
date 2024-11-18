// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Offchain} from "../Offchain.sol";
import {ICoprocess} from "../ICoprocess.sol";

contract Miner is Offchain {
    mapping(bytes32 => uint256) private cache;

    constructor(ICoprocess coprocess) Offchain(coprocess) {}

    function mine(bytes32 hash) external returns (uint256) {
        if (cache[hash] != 0) {
            return cache[hash];
        }
        for (uint256 i = 1;; i++) {
            uint256 candidate = uint256(keccak256(abi.encodePacked(hash, i)));
            if (probablyPrime(candidate, 10)) {
                cache[hash] = i;
                return i;
            }
        }
        return 0;
    }

    // https://en.wikipedia.org/wiki/Miller%E2%80%93Rabin_primality_test
    function probablyPrime(uint256 n, uint256 k) public view returns (bool) {
        if (n == 2 || n == 3) {
            return true;
        }
        if (n % 2 == 0 || n < 2) {
            return false;
        }

        uint256 s = 0;
        uint256 d = n - 1;
        while (d % 2 == 0) {
            d = d / 2;
            s++;
        }

        for (uint256 i = 0; i < k; i++) {
            uint256 a = 2 + (uint256(keccak256(abi.encodePacked(n, i))) % (n - 3));
            uint256 x = expmod(a, d, n);
            for (uint256 j = 0; j < s; j++) {
                uint256 y = expmod(x, 2, n);
                if (y == 1 && x != 1 && x != n - 1) {
                    return false;
                }
                x = y;
            }
            if (x != 1) {
                return false;
            }
        }
        return true;
    }

    function expmod(uint256 base, uint256 e, uint256 m) internal view returns (uint256 o) {
        assembly {
            let p := mload(0x40)
            mstore(p, 0x20) // Length of Base
            mstore(add(p, 0x20), 0x20) // Length of Exponent
            mstore(add(p, 0x40), 0x20) // Length of Modulus
            mstore(add(p, 0x60), base) // Base
            mstore(add(p, 0x80), e) // Exponent
            mstore(add(p, 0xa0), m) // Modulus
            if iszero(staticcall(sub(gas(), 2000), 0x05, p, 0xc0, p, 0x20)) { revert(0, 0) }
            o := mload(p)
        }
    }
}
