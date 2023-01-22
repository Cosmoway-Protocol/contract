// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICosmowayProtocolConditioner {
    function request(
        address requester,
        bytes memory condition,
        bytes memory request
    ) external returns (bool);
}
