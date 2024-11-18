// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Listener {
    event Winner(address winner);

    function notify(address winner) public {
        emit Winner(winner);
    }
}
