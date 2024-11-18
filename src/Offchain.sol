// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IOffchain} from "./IOffchain.sol";
import {Storage} from "./Storage.sol";
import {ICoprocess} from "./ICoprocess.sol";

abstract contract Offchain is IOffchain, Storage {
    bytes32 public constant STORAGE_ROOT_SLOT = bytes32(uint256(keccak256("offchain.storage.root")) - 1);
    bytes32 public constant COPROCESS_SLOT = bytes32(uint256(keccak256("offchain.coprocess")) - 1);

    constructor(ICoprocess coprocess) {
        setAddress(COPROCESS_SLOT, address(coprocess));
    }

    function getCoprocess() public view returns (ICoprocess) {
        return ICoprocess(getAddress(COPROCESS_SLOT));
    }

    function supportsInterface(bytes4 interfaceID) external pure virtual returns (bool) {
        return interfaceID == this.supportsInterface.selector // ERC165
            || interfaceID == this.isOffchain.selector ^ this.getStorageRoot.selector ^ this.setStorageRoot.selector; // IOffchain
    }

    function isOffchain() public pure virtual returns (bool) {
        return true;
    }

    function getStorageRoot() public view returns (bytes32) {
        return getBytes32(STORAGE_ROOT_SLOT);
    }

    function setStorageRoot(bytes32 oldRoot, bytes32 newRoot) public {
        require(msg.sender == address(getCoprocess()));
        require(getStorageRoot() == oldRoot);
        setBytes32(STORAGE_ROOT_SLOT, newRoot);
    }
}
