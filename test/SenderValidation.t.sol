// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "forge-std/Test.sol";
import "../src/CCTPDirectMessageTest.sol";

/**
 * @title SenderValidation
 * @dev Tests for sender validation in Circle's Iris
 * 
 * Research Questions:
 * - Does Iris validate the sender of messages?
 * - Are messages from unauthorized senders still signed?
 * - Is there sender authentication in the verification flow?
 */
contract SenderValidation is Test {
    CCTPDirectMessageTest public testContract;
    CCTPDirectMessageTest public secondContract;
    
    address constant AUTHORIZED_SENDER = 0x12b7546E3A678bd317f25979C6F676Be1b759604; // TokenMessenger
    address constant UNAUTHORIZED_SENDER = 0x1234567890123456789012345678901234567890;
    
    uint32 constant SEPOLIA_DOMAIN = 0;
    bytes32 constant TEST_RECIPIENT = bytes32(uint256(0xabcd));
    
    function setUp() public {
        testContract = new CCTPDirectMessageTest();
        secondContract = new CCTPDirectMessageTest();
    }
    
    // ============ Test 1: Authorized Sender ============
    
    /**
     * Test: Message from owner (authorized sender)
     */
    function test_messageFromOwner() public {
        bytes memory message = abi.encode(uint256(100), "authorized");
        
        vm.prank(address(this)); // This is the owner
        try testContract.test_sendArbitraryMessage(
            SEPOLIA_DOMAIN,
            TEST_RECIPIENT,
            message
        ) returns (uint64 nonce) {
            assertGt(nonce, 0);
            console.log("✓ Message from owner (authorized) accepted, nonce:", nonce);
        } catch {
            revert("Owner message should be accepted");
        }
    }
    
    // ============ Test 2: Unauthorized Sender ============
    
    /**
     * Test: Non-owner attempting to send message
     * Expected: Should fail due to onlyOwner modifier
     */
    function test_messageFromUnauthorizedSender() public {
        bytes memory message = abi.encode(uint256(200), "unauthorized");
        
        vm.prank(UNAUTHORIZED_SENDER);
        try testContract.test_sendArbitraryMessage(
            SEPOLIA_DOMAIN,
            TEST_RECIPIENT,
            message
        ) {
            revert("Unauthorized sender should be rejected");
        } catch Error(string memory reason) {
            console.log("✓ Unauthorized sender correctly rejected:", reason);
        }
    }
    
    // ============ Test 3: Multiple Contract Instances ============
    
    /**
     * Test: Different contract instances sending same message
     * Research: Do different senders get different signatures from Iris?
     */
    function test_differentContractInstancesSameSender() public {
        bytes memory message = abi.encode(uint256(300), "multi-instance");
        
        // First contract sends
        try testContract.test_sendArbitraryMessage(
            SEPOLIA_DOMAIN,
            TEST_RECIPIENT,
            message
        ) returns (uint64 nonce1) {
            console.log("✓ First contract message, nonce:", nonce1);
            
            // In real scenario, would compare Iris signatures
            // If Iris doesn't validate sender, both should get signed
            console.log("  Message from contract 1:", address(testContract));
        } catch {
            revert("First contract message should be accepted");
        }
    }
    
    // ============ Test 4: Message Content Modification ============
    
    /**
     * Test: Same message from different senders
     * Research: Does Iris produce same signature for same message?
     */
    function test_identicalMessageDifferentSenders() public {
        bytes memory identicalMessage = abi.encode(
            address(0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238),
            uint256(1000e6),
            TEST_RECIPIENT
        );
        
        bytes32 messageHash = keccak256(identicalMessage);
        console.log("Identical message hash:");
        console.logBytes32(messageHash);
        
        try testContract.test_sendArbitraryMessage(
            SEPOLIA_DOMAIN,
            TEST_RECIPIENT,
            identicalMessage
        ) returns (uint64 nonce) {
            console.log("✓ Message accepted, nonce:", nonce);
            console.log("  Research: Check if Iris signature is deterministic");
            console.log("  for identical message content from different senders");
        } catch {
            revert("Identical message should be accepted");
        }
    }
    
    // ============ Test 5: Token Messenger vs Direct Call ============
    
    /**
     * Test: Compare direct call with normal TokenMessenger flow
     * Research: Are signatures different when bypassing TokenMessenger?
     */
    function test_tokenMessengerBypassComparison() public {
        uint256 testAmount = 100e6;
        bytes memory bypassMessage = abi.encode(
            address(0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238),
            testAmount,
            TEST_RECIPIENT
        );
        
        // Simulate what TokenMessenger would send
        try testContract.test_sendArbitraryMessage(
            SEPOLIA_DOMAIN,
            TEST_RECIPIENT,
            bypassMessage
        ) returns (uint64 nonce) {
            console.log("✓ Bypassed TokenMessenger, nonce:", nonce);
            console.log("  Message content (bypassed):", bypassMessage.length, "bytes");
            console.log("  Research: Compare signature from:");
            console.log("    1. Direct MessageTransmitter call (above)");
            console.log("    2. Normal TokenMessenger.depositForBurn() call");
        } catch {
            revert("Bypass message should be accepted");
        }
    }
    
    // ============ Test 6: Sender Validation Logging ============
    
    /**
     * Test: Document sender information in messages
     */
    function test_senderInformationLogging() public {
        bytes memory testMessage = abi.encode(
            uint256(999),
            msg.sender,
            address(this)
        );
        
        console.log("Sender Analysis:");
        console.log("  Caller address:", address(this));
        console.log("  Contract address:", address(testContract));
        console.log("  Message size:", testMessage.length);
        
        try testContract.test_sendArbitraryMessage(
            SEPOLIA_DOMAIN,
            TEST_RECIPIENT,
            testMessage
        ) returns (uint64 nonce) {
            console.log("  Nonce assigned:", nonce);
            console.log("  Research: Check if Iris validates msg.sender");
        } catch {
            revert("Message should be accepted");
        }
    }
}
