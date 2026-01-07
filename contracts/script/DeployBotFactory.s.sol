// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/BotFactory.sol";
import "../src/BotRegistry.sol";
import "../src/BotNFT.sol";
import "../src/TradingBot.sol";

contract DeployBotFactory is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy implementation
        TradingBot botImplementation = new TradingBot();
        console.log("BotImplementation deployed to:", address(botImplementation));
        
        // Deploy registry
        BotRegistry registry = new BotRegistry();
        console.log("BotRegistry deployed to:", address(registry));
        
        // Deploy NFT
        BotNFT nft = new BotNFT(
            "Trading Bot NFT",
            "TBOT",
            "ipfs://QmXxxx/",
            msg.sender
        );
        console.log("BotNFT deployed to:", address(nft));
        
        // Deploy factory
        BotFactory factory = new BotFactory(
            address(botImplementation),
            address(registry),
            address(nft),
            0.1 ether
        );
        console.log("BotFactory deployed to:", address(factory));
        
        vm.stopBroadcast();
    }
}
