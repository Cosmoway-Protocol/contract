// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "../src/CosmowayProtocol.sol";
import "../src/conditioners/UncheckConditioner.sol";

// TODO: Unhappy path

contract ProtocolTest is Test {
    event KeysetUploaded(
        uint indexed keysetId,
        address indexed delegator,
        bytes shard
    );
    event KeysetReceived(
        uint indexed keysetId,
        address indexed delegator,
        bool accept,
        string reason
    );
    event AccessRequested(
        uint indexed keysetId,
        address indexed requester,
        uint indexed accessId,
        bytes32 pubKey
    );
    event RekeyUploaded(
        uint indexed accessId,
        address indexed requester,
        bytes shard
    );

    CosmowayProtocol cosmoway;
    UncheckConditioner conditioner;
    address delegator1 = 0xFcb123562f989925c883EC46471825AABFFd6d61;
    address delegator2 = 0x44fe1C334C3C1B4F3A953E7e7F58A8F479F0cd4d;
    address requester = 0x15c56C912AC6d67D603259aD77C57e6938B957bF;

    function setUp() public {
        cosmoway = new CosmowayProtocol();
        conditioner = new UncheckConditioner();
    }

    function testIntegration() public {
        // upload key
        // receive
        // request
        // upload rekey
    }

    function testUploadKey() public {
        vm.expectEmit(true, true, true, false);
        emit KeysetUploaded(0, delegator1, "123");
        emit KeysetUploaded(0, delegator2, "456");

        _callUploadKey();
    }

    function testReceiveByDelegator() public {
        _callUploadKey();

        vm.expectEmit(true, true, true, true);
        emit KeysetReceived(0, delegator1, true, "None");

        vm.prank(delegator1);
        cosmoway.receiveKey(0, 0, true, "None");
    }

    function testRequest() public {
        _callUploadKey();

        vm.expectEmit(true, true, true, true);
        emit AccessRequested(0, requester, 0, "000");

        vm.prank(requester);
        cosmoway.request(0, "", "000");
    }

    function testSubmitRekey() public {
        _callUploadKey();

        // request
        vm.prank(requester);
        cosmoway.request(0, "", "000");

        vm.expectEmit(true, true, true, false);
        emit RekeyUploaded(0, requester, "999");

        vm.prank(delegator1);
        cosmoway.submitRekey(0, 0, "999");
    }

    function _callUploadKey() internal {
        bytes[] memory shards = new bytes[](2);
        address[] memory to = new address[](2);
        shards[0] = "123";
        to[0] = delegator1;
        shards[1] = "456";
        to[1] = delegator2;

        cosmoway.uploadKeyset({
            cid: "cid",
            secretShards: shards,
            to: to,
            conditioner: conditioner,
            condition: ""
        });
    }
}
