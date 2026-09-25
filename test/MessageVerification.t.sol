// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "forge-std/Test.sol";
import "../src/CCTPDirectMessageTest.sol";

/**
 * @title MessageVerification
 * @dev Tests for message structure verification in Circle's Iris
 * 
 * Research Questions:
 * - Does Iris validate message structure?
 * - Are arbitrary message formats accepted?
 * - What is the minimum valid message structure?
 */
contract MessageVerification is Test {
    CCTPDirectMessageTest public testContract;
    
    // Test constants
    uint32 constant SEPOLIA_DOMAIN = 0;
    bytes32 constant TEST_RECIPIENT = bytes32(uint256(0x1234567890abcdef));
    
    function setUp() public {
        testContract = new CCTPDirectMessageTest();
    }
    
    // ============ Test 1: Arbitrary Message Structure ============
    
    /**
     * Test: Can we send completely arbitrary message structures?
     * Expected: Iris should accept if only validating structure
     */
    function test_arbitraryMessageAcceptance() public {
        bytes memory arbitraryMessage = abi.encodePacked(
            "This is an arbitrary message",
            uint256(12345),
            address(0x1234567890123456789012345678901234567890)
        );
        
        // This should succeed if Iris doesn't validate content
        try testContract.test_sendArbitraryMessage(
            SEPOLIA_DOMAIN,
            TEST_RECIPIENT,
            arbitraryMessage
        ) returns (uint64 nonce) {
            assertGt(nonce, 0, "Nonce should be greater than 0");
            console.log("✓ Arbitrary message accepted with nonce:", nonce);
        } catch Error(string memory reason) {
            console.log("✗ Arbitrary message rejected:", reason);
            revert("Arbitrary message should be accepted");
        }
    }
    
    /**
     * Test: Minimal message structure
     * Expected: What is the absolute minimum accepted?
     */
    function test_minimalMessageStructure() public {
        bytes memory minimalMessage = abi.encodePacked(uint8(0));
        
        try testContract.test_sendMalformedMessage(
            SEPOLIA_DOMAIN,
            TEST_RECIPIENT
        ) returns (uint64 nonce) {
            assertGt(nonce, 0, "Minimal message accepted");
            console.log("✓ Minimal message accepted with nonce:", nonce);
        } catch Error(string memory reason) {
            console.log("✗ Minimal message rejected:", reason);
        }
    }
    
    /**
     * Test: Empty message rejection
     * Expected: Empty messages should be rejected
     */
    function test_emptyMessageRejection() public {
        bytes memory emptyMessage = "";
        
        try testContract.test_sendArbitraryMessage(
            SEPOLIA_DOMAIN,
            TEST_RECIPIENT,
            emptyMessage
        ) {
            revert("Empty message should be rejected");
        } catch Error(string memory reason) {
            console.log("✓ Empty message correctly rejected:", reason);
        }
    }
    
    // ============ Test 2: Message Size Variations ============
    
    /**
     * Test: Small message (< 100 bytes)
     */
    function test_smallMessageAcceptance() public {
        bytes memory smallMessage = abi.encode(
            uint256(100),
            "small"
        );
        
        try testContract.test_sendArbitraryMessage(
            SEPOLIA_DOMAIN,
            TEST_RECIPIENT,
            smallMessage
        ) returns (uint64 nonce) {
            assertTrue(nonce > 0, "Small message should be accepted");
            console.log("✓ Small message accepted, size:", smallMessage.length);
        } catch {
            revert("Small message should be accepted");
        }
    }
    
    /**
     * Test: Large message (1000+ bytes)
     */
    function test_largeMessageHandling() public {
        bytes memory largeMessage = new bytes(1000);
        for (uint i = 0; i < 1000; i++) {
            largeMessage[i] = bytes1(uint8(i % 256));
        }
        
        try testContract.test_sendArbitraryMessage(
            SEPOLIA_DOMAIN,
            TEST_RECIPIENT,
            largeMessage
        ) returns (uint64 nonce) {
            assertTrue(nonce > 0, "Large message handling");
            console.log("✓ Large message accepted, size:", largeMessage.length);
        } catch Error(string memory reason) {
            console.log("Note: Large message rejected -", reason);
        }
    }
    
    // ============ Test 3: Message Format Analysis ============
    
    /**
     * Test: Encoded vs non-encoded message comparison
     */
    function test_encodedVsRawMessage() public {
        address testToken = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;
        uint256 testAmount = 1000e6;
        
        // Encoded message
        bytes memory encodedMessage = abi.encode(
            testToken,
            testAmount,
            TEST_RECIPIENT
        );
        
        // Raw packed message
        bytes memory packedMessage = abi.encodePacked(
            testToken,
            testAmount,
            TEST_RECIPIENT
        );
        
        try testContract.test_sendArbitraryMessage(
            SEPOLIA_DOMAIN,
            TEST_RECIPIENT,
            encodedMessage
        ) returns (uint64 nonce1) {
            console.log("✓ Encoded message accepted, nonce:", nonce1);
            
            // Note: Don't send second message in same test due to nonce sequencing
            // This would be done in separate test runs
            console.log("  Encoded message length:", encodedMessage.length);
        } catch {
            revert("Encoded message should be accepted");
        }
        
        console.log("  Packed message length:", packedMessage.length);
    }
    
    // ============ Test 4: Structure Verification Logging ============
    
    /**
     * Test: Log message structure for analysis
     */
    function test_messageStructureLogging() public {
        bytes memory testMessage = abi.encode(
            uint256(12345),
            address(0xabcd),
            "test"
        );
        
        bytes32 messageHash = keccak256(testMessage);
        
        console.log("Message Analysis:");
        console.log("  Length:", testMessage.length);
        console.logBytes32(messageHash);
        
        try testContract.test_sendArbitraryMessage(
            SEPOLIA_DOMAIN,
            TEST_RECIPIENT,
            testMessage
        ) returns (uint64 nonce) {
            console.log("  Nonce assigned:", nonce);
            assertTrue(nonce > 0);
        } catch {
            revert("Message should be accepted");
        }
    }
}
