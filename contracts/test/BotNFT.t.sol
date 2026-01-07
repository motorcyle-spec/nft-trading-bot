// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/BotNFT.sol";

contract BotNFTTest is Test {
    BotNFT public nft;
    address public owner = address(0x1);
    address public factory = address(0x2);
    address public user = address(0x3);
    
    function setUp() public {
        vm.prank(owner);
        nft = new BotNFT("Bot NFT", "BNFT", "ipfs://", factory);
    }
    
    function testMint() public {
        vm.prank(factory);
        nft.mint(user, 1, "ipfs://metadata");
        
        assertEq(nft.balanceOf(user), 1);
        assertEq(nft.ownerOf(1), user);
    }
    
    function testUpdateMetadata() public {
        vm.prank(factory);
        nft.mint(user, 1, "ipfs://metadata");
        
        vm.prank(user);
        nft.updateMetadata(1, "ipfs://new-metadata");
        assertEq(nft.tokenMetadata(1), "ipfs://new-metadata");
    }
    
    function testRoyalty() public {
        vm.prank(owner);
        nft.setDefaultRoyalty(owner, 500); // 5%
        
        (address receiver, uint256 royaltyAmount) = nft.royaltyInfo(1, 10000);
        assertEq(receiver, owner);
        assertEq(royaltyAmount, 500);
    }
}
