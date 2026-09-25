// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "forge-std/Test.sol";
import "../src/CCTPDirectMessageTest.sol";

/**
 * @title IrisSignatureAnalysis
 * @dev Tests for analyzing Iris signature verification behavior
 * 
 * Research Questions:
 * - Does Iris sign all messages regardless of sender?
 * - Are signatures deterministic for identical messages?
 * - Does Iris validate message content or only structure?
 */
contract IrisSignatureAnalysis is Test {
    CCTPDirectMessageTest public testContract;
    
    uint32 constant SEPOLIA_DOMAIN = 0;
    bytes32 constant TEST_RECIPIENT = bytes32(uint256(0x7777));
    
    function setUp() public {
        testContract = new CCTPDirectMessageTest();
    }
    
    // ============ Test 1: Fake USDC Deposit Signing ============
    
    /**
     * Test: Send fake USDC deposit and track nonce
     * Research: Will Iris sign an unauthorized token transfer message?
     */
    function test_fakeUSDCDepositSigning() public {
        uint256 unauthorizedAmount = 999999e6; // 999,999 USDC (fake)
        
        try testContract.test_sendFakeUSDCDeposit(
            SEPOLIA_DOMAIN,
            TEST_RECIPIENT,
            unauthorizedAmount
        ) returns (uint64 nonce) {
            assertGt(nonce, 0);
            console.log("✓ Fake USDC deposit accepted, nonce:", nonce);
            console.log("  Amount: 999,999 USDC (unauthorized)");
            console.log("  Research: Check if Iris signed this message");
            console.log("  Expected: Iris signature should validate message structure only");
        } catch Error(string memory reason) {
            console.log("✗ Fake USDC deposit rejected:", reason);
        }
    }
    
    // ============ Test 2: Multiple Messages Nonce Sequence ============
    
    /**
     * Test: Send multiple messages and verify nonce sequencing
     * Research: Are all messages assigned nonces by MessageTransmitter?
     */
    function test_multipleMessagesNonceSequence() public {
        uint64 firstNonce;
        uint64 secondNonce;
        uint64 thirdNonce;
        
        // Message 1
        try testContract.test_sendArbitraryMessage(
            SEPOLIA_DOMAIN,
            TEST_RECIPIENT,
            abi.encode("message1", uint256(1))
        ) returns (uint64 nonce) {
            firstNonce = nonce;
            console.log("Message 1 - Nonce:", nonce);
        } catch {
            revert("First message should be accepted");
        }
        
        // Message 2
        try testContract.test_sendArbitraryMessage(
            SEPOLIA_DOMAIN,
            TEST_RECIPIENT,
            abi.encode("message2", uint256(2))
        ) returns (uint64 nonce) {
            secondNonce = nonce;
            console.log("Message 2 - Nonce:", nonce);
        } catch {
            revert("Second message should be accepted");
        }
        
        // Message 3
        try testContract.test_sendArbitraryMessage(
            SEPOLIA_DOMAIN,
            TEST_RECIPIENT,
            abi.encode("message3", uint256(3))
        ) returns (uint64 nonce) {
            thirdNonce = nonce;
            console.log("Message 3 - Nonce:", nonce);
        } catch {
            revert("Third message should be accepted");
        }
        
        // Verify sequential nonces
        assertTrue(secondNonce > firstNonce, "Nonces should be sequential");
        assertTrue(thirdNonce > secondNonce, "Nonces should be sequential");
        console.log("✓ Nonce sequencing verified");
        console.log("  All arbitrary messages received valid nonces");
    }
    
    // ============ Test 3: Message Hash Consistency ============
    
    /**
     * Test: Verify message hash consistency for Iris tracking
     */
    function test_messageHashConsistency() public {
        bytes memory message1 = abi.encode(uint256(111), "test");
        bytes memory message2 = abi.encode(uint256(111), "test");
        bytes memory message3 = abi.encode(uint256(112), "test");
        
        bytes32 hash1 = keccak256(message1);
        bytes32 hash2 = keccak256(message2);
        bytes32 hash3 = keccak256(message3);
        
        console.log("Message Hash Analysis:");
        console.log("Message 1 hash:");
        console.logBytes32(hash1);
        console.log("Message 2 hash (identical content):");
        console.logBytes32(hash2);
        console.log("Message 3 hash (different content):");
        console.logBytes32(hash3);
        
        assertEq(hash1, hash2, "Identical messages should have same hash");
        assertNotEq(hash1, hash3, "Different messages should have different hash");
        
        console.log("✓ Hash consistency verified");
        console.log("  Research: These hashes should be used to track");
        console.log("  Iris signatures for identical message content");
    }
    
    // ============ Test 4: Signature Determinism Check ============
    
    /**
     * Test: Determine if Iris signatures are deterministic
     * Research: Same message = same signature from Iris?
     */
    function test_signatureDeterminism() public {
        bytes memory deterministicMessage = abi.encode(
            address(0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238),
            uint256(1000e6),
            TEST_RECIPIENT
        );
        
        bytes32 messageHash = keccak256(deterministicMessage);
        
        console.log("Signature Determinism Test:");
        console.logBytes32(messageHash);
        console.log("Message size:", deterministicMessage.length);
        
        try testContract.test_sendArbitraryMessage(
            SEPOLIA_DOMAIN,
            TEST_RECIPIENT,
            deterministicMessage
        ) returns (uint64 nonce) {
            console.log("✓ Message accepted, nonce:", nonce);
            console.log("  Research: Send identical message again from different");
            console.log("  contract/sender and compare Iris signatures");
            console.log("  If signatures are identical -> deterministic");
            console.log("  If different -> signatures depend on message source/sender");
        } catch {
            revert("Message should be accepted");
        }
    }
    
    // ============ Test 5: Cross-Domain Message Signing ============
    
    /**
     * Test: Send same message to different domains
     * Research: Does destination domain affect Iris signing?
     */
    function test_crossDomainMessageSigning() public {
        bytes memory universalMessage = abi.encode(
            uint256(5000),
            "cross-domain",
            address(0x1234567890123456789012345678901234567890)
        );
        
        bytes32 messageHash = keccak256(universalMessage);
        console.log("Universal message hash:");
        console.logBytes32(messageHash);
        
        // Message to Polygon
        try testContract.test_sendArbitraryMessage(
            7, // Polygon domain
            TEST_RECIPIENT,
            universalMessage
        ) returns (uint64 nonce1) {
            console.log("✓ Message to Polygon domain, nonce:", nonce1);
        } catch {
            revert("Message to Polygon should be accepted");
        }
        
        // In a separate test run, send to Avalanche
        console.log("  Research: Also send to Avalanche (domain 1)");
        console.log("  Compare Iris signatures across different domains");
    }
    
    // ============ Test 6: Signature Verification Readiness ============
    
    /**
     * Test: Prepare data for off-chain Iris signature verification
     */
    function test_prepareForIrisVerification() public {
        bytes memory targetMessage = abi.encode(
            address(0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238),
            uint256(50000e6),
            TEST_RECIPIENT
        );
        
        uint64 nonce = 0;
        try testContract.test_sendArbitraryMessage(
            SEPOLIA_DOMAIN,
            TEST_RECIPIENT,
            targetMessage
        ) returns (uint64 returnedNonce) {
            nonce = returnedNonce;
        } catch {
            revert("Message should be accepted");
        }
        
        console.log("Iris Verification Data:");
        console.log("======================");
        console.log("Nonce:", nonce);
        console.log("Domain:", SEPOLIA_DOMAIN);
        console.log("Message size:", targetMessage.length, "bytes");
        console.logBytes("Message content:");
        console.logBytes(targetMessage);
        console.log("Message hash:");
        console.logBytes32(keccak256(targetMessage));
        console.log("Recipient:");
        console.logBytes32(TEST_RECIPIENT);
        
        console.log("\nNext Steps:");
        console.log("1. Query Circle's Iris API for signature with this nonce");
        console.log("2. Verify if Iris returns a valid signature");
        console.log("3. Compare signatures across different message types");
        console.log("4. Test if signature validates on destination chain");
    }
}
