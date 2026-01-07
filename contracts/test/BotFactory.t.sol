// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/BotFactory.sol";
import "../src/BotRegistry.sol";
import "../src/BotNFT.sol";
import "../src/TradingBot.sol";

contract BotFactoryTest is Test {
    BotFactory public factory;
    BotRegistry public registry;
    BotNFT public nft;
    TradingBot public botImplementation;
    
    address public owner = address(0x1);
    address public user = address(0x2);
    
    function setUp() public {
        vm.startPrank(owner);
        
        // Deploy implementation
        botImplementation = new TradingBot();
        registry = new BotRegistry();
        nft = new BotNFT("Bot NFT", "BNFT", "ipfs://", owner);
        factory = new BotFactory(address(botImplementation), address(registry), address(nft), 0.1 ether);

        // Make factory the owner of the registry and nft to allow registration and minting
        registry.transferOwnership(address(factory));
        nft.transferOwnership(address(factory));
        
        // Fund test user accounts
        vm.deal(user, 1 ether);

        vm.stopPrank();
    }
    
    function testDeployBot() public {
        vm.prank(user);
        bytes32 salt = keccak256(abi.encodePacked("bot1"));
        
        address botAddress = factory.deployBot{value: 0.1 ether}(salt);
        
        assertNotEq(botAddress, address(0));
        assertTrue(registry.isRegistered(botAddress));
    }
    
    function testPredictBotAddress() public {
        bytes32 salt = keccak256(abi.encodePacked("bot1"));
        address predicted = factory.predictBotAddress(salt);
        
        assertNotEq(predicted, address(0));
    }

    function testCannotDeploySameSaltTwice() public {
        vm.prank(user);
        bytes32 salt = keccak256(abi.encodePacked("dup-salt"));

        address botAddr = factory.deployBot{value: 0.1 ether}(salt);
        assertNotEq(botAddr, address(0));

        vm.prank(user);
        vm.expectRevert();
        factory.deployBot{value: 0.1 ether}(salt);
    }
}
