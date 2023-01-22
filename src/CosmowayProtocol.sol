// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./interfaces/ICosmowayKeyDeliverProtocol.sol";
import "./CosmowayError.sol";

contract CosmowayProtocol is ICosmowayKeyDeliverProtocol {
    struct Keyset {
        string cid;
        bytes[] secretShards;
        address[] to;
        ICosmowayProtocolConditioner conditioner;
        bytes condition;
        bool[] accepted;
    }

    struct AccessRequest {
        uint keysetId;
        address requester;
        bytes32 pubKey;
        bytes[] rekeyShards;
    }

    Keyset[] public keysets;
    AccessRequest[] public accessRequests;

    function uploadKeyset(
        string memory cid,
        bytes[] memory secretShards,
        address[] memory to,
        ICosmowayProtocolConditioner conditioner,
        bytes memory condition
    ) external override returns (uint keysetId) {
        if (secretShards.length != to.length) revert InvalidKeyset();
        bool[] memory accepted = new bool[](secretShards.length);
        keysetId = keysets.length;
        keysets.push(
            Keyset(cid, secretShards, to, conditioner, condition, accepted)
        );
        for (uint i = 0; i < to.length; i++) {
            emit KeysetUploaded(keysetId, to[i], secretShards[i]);
        }
    }

    function receiveKey(
        uint keysetId,
        uint delegatorId,
        bool accept,
        string memory reason
    ) external override {
        if (keysets[keysetId].to[delegatorId] != msg.sender)
            revert NotDelegator();

        keysets[keysetId].accepted[delegatorId] = accept;
        emit KeysetReceived(keysetId, msg.sender, accept, reason);
    }

    function request(
        uint keysetId,
        bytes memory requestPayload,
        bytes32 pubKey
    ) external override returns (uint accessId) {
        Keyset memory usingKeyset = keysets[keysetId];
        try
            usingKeyset.conditioner.request(
                msg.sender,
                usingKeyset.condition,
                requestPayload
            )
        returns (bool result) {
            if (!result) revert ConditionNotMet();
        } catch {
            revert ConditionNotMet();
        }

        accessId = accessRequests.length;
        bytes[] memory accepted = new bytes[](usingKeyset.secretShards.length);
        accessRequests.push(
            AccessRequest(keysetId, msg.sender, pubKey, accepted)
        );

        emit AccessRequested(keysetId, msg.sender, accessId, pubKey);
    }

    function submitRekey(
        uint accessId,
        uint delegatorId,
        bytes memory rekeyShard
    ) external override {
        AccessRequest storage access = accessRequests[accessId];
        if (keysets[access.keysetId].to[delegatorId] != msg.sender)
            revert NotDelegator();

        access.rekeyShards[delegatorId] = rekeyShard;
        emit RekeyUploaded(accessId, access.requester, rekeyShard);
    }
}
