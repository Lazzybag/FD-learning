// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title IMessageTransmitter
 * @dev Interface for Circle's MessageTransmitter contract
 */
interface IMessageTransmitter {
    function sendMessage(
        uint32 destinationDomain,
        bytes32 recipient,
        bytes calldata messageBody
    ) external returns (uint64 nonce);

    function getNextAvailableNonce() external view returns (uint64);
}

/**
 * @title ITokenMessenger
 * @dev Interface for Circle's TokenMessenger contract
 */
interface ITokenMessenger {
    function depositForBurn(
        uint256 amount,
        uint32 destinationDomain,
        bytes32 mintRecipient,
        address burnToken
    ) external returns (uint64 nonce);
}

/**
 * @title CCTPDirectMessageTest
 * @dev Test contract for analyzing Iris payment verification
 * 
 * This contract tests whether Iris:
 * 1. Only verifies message structure
 * 2. Validates sender authenticity
 * 3. Validates message content integrity
 */
contract CCTPDirectMessageTest is Ownable {
    // ============ Constants ============
    
    // MessageTransmitterV2 Address (Ethereum & Sepolia)
    IMessageTransmitter public constant messageTransmitter = 
        IMessageTransmitter(0x0eb340E74b09c2CE87AFCD8b8C156f081432f5c1);
    
    // TokenMessengerV2 Address (Ethereum & Sepolia)
    ITokenMessenger public constant tokenMessenger = 
        ITokenMessenger(0x12b7546E3A678bd317f25979C6F676Be1b759604);
    
    // USDC Address on Sepolia testnet
    address public constant usdc = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;
    
    // Domain IDs for common chains
    uint32 public constant ETHEREUM_DOMAIN = 0;
    uint32 public constant POLYGON_DOMAIN = 7;
    uint32 public constant AVALANCHE_DOMAIN = 1;
    
    // ============ Events ============
    
    event DirectMessageSent(
        uint64 indexed nonce,
        uint32 destinationDomain,
        bytes32 recipient,
        bytes message,
        string messageType
    );
    
    event MessageStructureLogged(
        uint64 indexed nonce,
        uint256 messageLength,
        bytes32 messageHash,
        address sender
    );
    
    // ============ Constructor ============
    
    constructor() {}
    
    // ============ Test Functions ============
    
    /**
     * @dev Test 1: Send arbitrary message directly through MessageTransmitter
     * Research: Does Iris sign messages sent directly to MessageTransmitter?
     */
    function test_sendArbitraryMessage(
        uint32 destinationDomain,
        bytes32 recipientAddress,
        bytes calldata arbitraryMessage
    ) external onlyOwner returns (uint64 nonce) {
        require(arbitraryMessage.length > 0, "Message cannot be empty");
        
        nonce = messageTransmitter.sendMessage(
            destinationDomain,
            recipientAddress,
            arbitraryMessage
        );
        
        emit DirectMessageSent(
            nonce,
            destinationDomain,
            recipientAddress,
            arbitraryMessage,
            "arbitrary"
        );
        
        emit MessageStructureLogged(
            nonce,
            arbitraryMessage.length,
            keccak256(arbitraryMessage),
            msg.sender
        );
        
        return nonce;
    }
    
    /**
     * @dev Test 2: Send fake USDC deposit message bypassing TokenMessenger
     * Research: Can we send unauthorized token transfer messages?
     */
    function test_sendFakeUSDCDeposit(
        uint32 destinationDomain,
        bytes32 recipientAddress,
        uint256 fakeAmount
    ) external onlyOwner returns (uint64 nonce) {
        // Construct a fake deposit message
        bytes memory fakeDepositMessage = abi.encode(
            usdc,                // token address
            fakeAmount,          // amount (unauthorized)
            recipientAddress     // mint recipient
        );
        
        nonce = messageTransmitter.sendMessage(
            destinationDomain,
            recipientAddress,
            fakeDepositMessage
        );
        
        emit DirectMessageSent(
            nonce,
            destinationDomain,
            recipientAddress,
            fakeDepositMessage,
            "fakeDeposit"
        );
        
        emit MessageStructureLogged(
            nonce,
            fakeDepositMessage.length,
            keccak256(fakeDepositMessage),
            msg.sender
        );
        
        return nonce;
    }
    
    /**
     * @dev Test 3: Send malformed message to test validation
     * Research: What is the minimum validation Iris performs?
     */
    function test_sendMalformedMessage(
        uint32 destinationDomain,
        bytes32 recipientAddress
    ) external onlyOwner returns (uint64 nonce) {
        // Minimal message with only basic structure
        bytes memory malformedMessage = abi.encodePacked(
            uint8(0),  // minimal header
            recipientAddress
        );
        
        nonce = messageTransmitter.sendMessage(
            destinationDomain,
            recipientAddress,
            malformedMessage
        );
        
        emit DirectMessageSent(
            nonce,
            destinationDomain,
            recipientAddress,
            malformedMessage,
            "malformed"
        );
        
        emit MessageStructureLogged(
            nonce,
            malformedMessage.length,
            keccak256(malformedMessage),
            msg.sender
        );
        
        return nonce;
    }
    
    /**
     * @dev Test 4: Normal flow through TokenMessenger (for comparison)
     * Research: Compare signatures from authorized vs direct MessageTransmitter calls
     */
    function test_sendNormalDeposit(
        uint256 amount,
        uint32 destinationDomain,
        bytes32 mintRecipient
    ) external onlyOwner returns (uint64 nonce) {
        // This would require actual USDC tokens
        // For testing purposes, we'll construct the expected message
        bytes memory expectedMessage = abi.encode(
            usdc,
            amount,
            mintRecipient
        );
        
        emit MessageStructureLogged(
            0, // nonce would be returned from actual call
            expectedMessage.length,
            keccak256(expectedMessage),
            msg.sender
        );
        
        // In actual testing, uncomment below and ensure USDC approval
        // nonce = tokenMessenger.depositForBurn(
        //     amount,
        //     destinationDomain,
        //     mintRecipient,
        //     usdc
        // );
        
        return 0;
    }
    
    /**
     * @dev Test 5: Send messages with varying payload sizes
     * Research: Does message size affect validation or signing?
     */
    function test_sendVaryingSizeMessages(
        uint32 destinationDomain,
        bytes32 recipientAddress,
        uint8 payloadSize
    ) external onlyOwner returns (uint64 nonce) {
        require(payloadSize > 0 && payloadSize <= 100, "Invalid payload size");
        
        // Create message with specified size
        bytes memory variableMessage = new bytes(payloadSize);
        for (uint8 i = 0; i < payloadSize; i++) {
            variableMessage[i] = bytes1(uint8(i % 256));
        }
        
        nonce = messageTransmitter.sendMessage(
            destinationDomain,
            recipientAddress,
            variableMessage
        );
        
        emit DirectMessageSent(
            nonce,
            destinationDomain,
            recipientAddress,
            variableMessage,
            "variableSize"
        );
        
        emit MessageStructureLogged(
            nonce,
            variableMessage.length,
            keccak256(variableMessage),
            msg.sender
        );
        
        return nonce;
    }
    
    // ============ Helper Functions ============
    
    /**
     * @dev Get the next available nonce from MessageTransmitter
     */
    function getNextNonce() external view returns (uint64) {
        return messageTransmitter.getNextAvailableNonce();
    }
    
    /**
     * @dev Encode message in standard CCTP format for comparison
     */
    function encodeStandardMessage(
        address token,
        uint256 amount,
        bytes32 recipient
    ) external pure returns (bytes memory) {
        return abi.encode(token, amount, recipient);
    }
    
    /**
     * @dev Get message hash for signature verification tracking
     */
    function getMessageHash(bytes memory message) external pure returns (bytes32) {
        return keccak256(message);
    }
}
