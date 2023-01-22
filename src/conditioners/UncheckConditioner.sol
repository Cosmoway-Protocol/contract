// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/ICosmowayProtocolConditioner.sol";

contract UncheckConditioner is ICosmowayProtocolConditioner {
    function request(
        address requester,
        bytes memory condition,
        bytes memory request
    ) external override returns (bool) {
        return true;
    }
}
