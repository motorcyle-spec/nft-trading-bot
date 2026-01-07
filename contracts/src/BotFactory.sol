// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title BotFactory
 * @dev Factory contract for deploying trading bot instances using EIP-1167 minimal proxies
 * 
 * Features:
 * - Creates bot instances with deterministic addresses using CREATE2
 * - Maintains registry of deployed bots
 * - Mints corresponding NFTs for ownership tracking
 * - Implements access control for administrative functions
 */

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {BotProxy} from "./BotProxy.sol";
import {BotRegistry} from "./BotRegistry.sol";
import {BotNFT} from "./BotNFT.sol";

contract BotFactory is Ownable {
    
    // ============ State Variables ============
    
    address public botImplementation;
    BotRegistry public immutable botRegistry;
    BotNFT public immutable botNFT;
    
    uint256 public botCounter;
    uint256 public deploymentFee;
    
    mapping(address => uint256) public botOwners;
    
    // ============ Events ============
    
    event BotDeployed(
        address indexed botAddress,
        address indexed owner,
        uint256 indexed tokenId,
        bytes32 salt
    );

    event DeploymentFeeUpdated(uint256 newFee);
    event ImplementationUpdated(address newImplementation);
    
    // ============ Constructor ============
    
    constructor(
        address _botImplementation,
        address _botRegistry,
        address _botNFT,
        uint256 _deploymentFee
    ) Ownable(msg.sender) {
        botImplementation = _botImplementation;
        botRegistry = BotRegistry(_botRegistry);
        botNFT = BotNFT(_botNFT);
        deploymentFee = _deploymentFee;
    }
    
    // ============ External Functions ============
    
    /**
     * @dev Deploy a new trading bot instance
     * @param _salt Salt for deterministic address calculation
     * @return botAddress Address of the newly deployed bot
     */
    function deployBot(bytes32 _salt) external payable returns (address botAddress) {
        require(msg.value >= deploymentFee, "Insufficient deployment fee");
        
        // Deploy bot using EIP-1167 minimal proxy
        botAddress = Clones.cloneDeterministic(botImplementation, _salt);
        
        // Update counter and register
        botCounter++;
        uint256 tokenId = botCounter;
        
        // Register bot address
        botRegistry.registerBot(botAddress, msg.sender, tokenId);
        botOwners[botAddress] = tokenId;
        
        // Mint NFT to owner
        botNFT.mint(msg.sender, tokenId, "");
        
        emit BotDeployed(botAddress, msg.sender, tokenId, _salt);
        
        return botAddress;
    }
    
    /**
     * @dev Calculate deterministic address for a bot deployment
     * @param _salt Salt for address calculation
     * @return Predicted bot address
     */
    function predictBotAddress(bytes32 _salt) external view returns (address) {
        return Clones.predictDeterministicAddress(botImplementation, _salt);
    }
    
    /**
     * @dev Get bot address by token ID
     * @param _tokenId NFT token ID
     * @return Bot address
     */
    function getBotAddress(uint256 _tokenId) external view returns (address) {
        return botRegistry.getBotAddress(_tokenId);
    }
    
    /**
     * @dev Update deployment fee
     * @param _newFee New fee in wei
     */
    function setDeploymentFee(uint256 _newFee) external onlyOwner {
        deploymentFee = _newFee;
        emit DeploymentFeeUpdated(_newFee);
    }
    
    /**
     * @dev Update implementation address
     * @param _newImplementation New implementation address
     */
    function setImplementation(address _newImplementation) external onlyOwner {
        require(_newImplementation != address(0), "Invalid implementation");
        botImplementation = _newImplementation;
        emit ImplementationUpdated(_newImplementation);
    }
    
    /**
     * @dev Withdraw collected fees
     */
    function withdrawFees() external onlyOwner {
        (bool success, ) = payable(owner()).call{value: address(this).balance}("");
        require(success, "Withdrawal failed");
    }
    
    // ============ Fallback ============
    
    receive() external payable {}
}
