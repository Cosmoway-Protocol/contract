// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/token/ERC721/IERC721.sol";
import "openzeppelin-contracts/token/ERC1155/IERC1155.sol";
import "../interfaces/ICosmowayProtocolConditioner.sol";

contract ERC721Conditioner is ICosmowayProtocolConditioner {
    // condition: token address
    // request: token id
    // rule: requester own the token
    function request(
        address requester,
        bytes memory condition,
        bytes memory request
    ) external override returns (bool) {
        address addr = abi.decode(condition, (address));
        uint tokenId = abi.decode(request, (uint));
        return IERC721(addr).ownerOf(tokenId) == requester;
    }
}

contract ERC1155Conditioner is ICosmowayProtocolConditioner {
    // condition: token address
    // request: token id
    // rule: requester own the token
    function request(
        address requester,
        bytes memory condition,
        bytes memory request
    ) external override returns (bool) {
        address addr = abi.decode(condition, (address));
        uint tokenId = abi.decode(request, (uint));
        return IERC1155(addr).balanceOf(requester, tokenId) > 0;
    }
}

contract ERC20Conditioner is ICosmowayProtocolConditioner {
    // condition: token address, min amount
    // request: <empty>
    // rule: requester own the token
    function request(
        address requester,
        bytes memory condition,
        bytes memory request
    ) external override returns (bool) {
        (address addr, uint minAmount) = abi.decode(condition, (address, uint));
        return IERC20(addr).balanceOf(requester) > minAmount;
    }
}
