// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ICosmowayProtocolConditioner.sol";

/*
 * ICosmowayKeyDeliverProtocol
 *   This sub-protocol is used to delegatee encrypted key to
 *   another user. First, a content provider will generate a
 *   key pair to encrypted the content, the secret key is
 *   devided into multiple shares and sent to delegatees via
 *   this protocol. The requirements of delegatees might be
 *   vary, hence it will be implement in another sub-protocol.
 *
 *   A content consumer will send a request for a content,
 *   during the request, the condition is checked. If the
 *   request transaction succeeded, delegatees should encrypt
 *   their secret shards with the consumer's public key and
 *   send via this protocol.
 *
 *   TODO:
 *      - Check validity of ciphertexts
 *      - Check validity of secret shards
 *      - Consensus-based abuse report system
 *      - Incentives
 */
interface ICosmowayKeyDeliverProtocol {
    event KeysetUploaded(
        uint indexed keysetId,
        address indexed delegatee,
        uint delegateeId,
        bytes shard
    );
    event KeysetReceived(
        uint indexed keysetId,
        address indexed delegatee,
        bool accept,
        string reason
    );
    event AccessRequested(
        uint indexed keysetId,
        address indexed requester,
        uint indexed accessId,
        bytes pubKey
    );
    event RekeyUploaded(
        uint indexed accessId,
        uint indexed delegateeId,
        address indexed requester,
        bytes shard
    );

    /// @notice Upload encrypted file cid, secret shares, delegatees, conditioner, and condition
    function uploadKeyset(
        string memory cid,
        bytes[] memory secretShards,
        address[] memory to,
        ICosmowayProtocolConditioner conditioner,
        bytes memory condition
    ) external returns (uint keysetId);

    /// @notice Report if a key is received by a node
    function receiveKey(
        uint keysetId,
        uint delegateeId,
        bool accept,
        string memory reason
    ) external;

    /// @notice Ask nodes for re-encrypted secret shards
    function request(
        uint keysetId,
        bytes memory requestPayload,
        bytes memory pubKey
    ) external returns (uint accessId);

    /// @notice Submit a re-encrypted secret shard for an access request
    function submitRekey(
        uint accessId,
        uint delegateeId,
        bytes memory rekeyShard
    ) external;
}
