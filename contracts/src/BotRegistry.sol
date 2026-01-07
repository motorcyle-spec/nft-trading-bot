// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title BotRegistry
 * @dev Maintains mappings between bot addresses, token IDs, and owners
 * 
 * Provides lookup functions for bot management and ownership verification
 */

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract BotRegistry is Ownable {
    constructor() Ownable(msg.sender) {}
    
    // ============ State Variables ============
    
    mapping(address => uint256) public botToTokenId;
    mapping(uint256 => address) public tokenIdToBot;
    mapping(address => address) public botOwner;
    mapping(address => bool) public registeredBots;
    
    address[] public allBots;
    
    // ============ Events ============
    
    event BotRegistered(address indexed botAddress, address indexed owner, uint256 indexed tokenId);
    event BotUnregistered(address indexed botAddress);
    
    // ============ External Functions ============
    
    /**
     * @dev Register a new bot
     * @param _botAddress Address of the bot to register
     * @param _owner Owner of the bot
     * @param _tokenId NFT token ID
     */
    function registerBot(
        address _botAddress,
        address _owner,
        uint256 _tokenId
    ) external onlyOwner {
        require(_botAddress != address(0), "Invalid bot address");
        require(_owner != address(0), "Invalid owner");
        require(!registeredBots[_botAddress], "Bot already registered");
        
        botToTokenId[_botAddress] = _tokenId;
        tokenIdToBot[_tokenId] = _botAddress;
        botOwner[_botAddress] = _owner;
        registeredBots[_botAddress] = true;
        
        allBots.push(_botAddress);
        
        emit BotRegistered(_botAddress, _owner, _tokenId);
    }
    
    /**
     * @dev Unregister a bot
     * @param _botAddress Address of the bot to unregister
     */
    function unregisterBot(address _botAddress) external onlyOwner {
        require(registeredBots[_botAddress], "Bot not registered");
        
        registeredBots[_botAddress] = false;
        emit BotUnregistered(_botAddress);
    }
    
    /**
     * @dev Get bot address by token ID
     * @param _tokenId NFT token ID
     * @return Bot address
     */
    function getBotAddress(uint256 _tokenId) external view returns (address) {
        return tokenIdToBot[_tokenId];
    }
    
    /**
     * @dev Get token ID by bot address
     * @param _botAddress Bot address
     * @return Token ID
     */
    function getTokenId(address _botAddress) external view returns (uint256) {
        return botToTokenId[_botAddress];
    }
    
    /**
     * @dev Get owner of a bot
     * @param _botAddress Bot address
     * @return Owner address
     */
    function getOwner(address _botAddress) external view returns (address) {
        return botOwner[_botAddress];
    }
    
    /**
     * @dev Check if bot is registered
     * @param _botAddress Bot address
     * @return Is registered
     */
    function isRegistered(address _botAddress) external view returns (bool) {
        return registeredBots[_botAddress];
    }
    
    /**
     * @dev Get total number of registered bots
     * @return Number of bots
     */
    function getBotCount() external view returns (uint256) {
        return allBots.length;
    }
    
    /**
     * @dev Get bot address by index
     * @param _index Index in all bots array
     * @return Bot address
     */
    function getBotByIndex(uint256 _index) external view returns (address) {
        require(_index < allBots.length, "Index out of bounds");
        return allBots[_index];
    }
}
