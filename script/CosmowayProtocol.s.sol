// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "forge-std/Script.sol";
import "../src/CosmowayProtocol.sol";
import "../src/conditioners/AssetConditioner.sol";

contract CosmowayProtocolScript is Script {
    function run() public {
        uint deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // deploy main protocol
        CosmowayProtocol cosmoway = new CosmowayProtocol();

        // deploy asset conditioners
        ERC20Conditioner erc20Conditioner = new ERC20Conditioner();
        ERC721Conditioner erc721Conditioner = new ERC721Conditioner();
        ERC1155Conditioner erc1155Conditioner = new ERC1155Conditioner();

        vm.stopBroadcast();
    }
}
