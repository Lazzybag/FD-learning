# Circle Iris Payment Verification - Research Notes

## Hypothesis

**Does Circle's Iris attestation service only verify that message structures are correct, without validating sender authenticity or the actual content of those messages?**

If true, this could allow an attacker to:
1. Send fake token transfer messages directly to MessageTransmitter
2. Bypass the TokenMessenger contract entirely
3. Have Iris sign unauthorized messages

## Research Methodology

### Phase 1: Message Structure Validation
- **Test**: Send arbitrary message formats to MessageTransmitter.sendMessage()
- **Expected Outcome**: If Iris doesn't validate content, all properly-formatted messages receive nonces
- **Files**: `test/MessageVerification.t.sol`

### Phase 2: Sender Validation
- **Test**: Attempt to send messages from unauthorized addresses
- **Expected Outcome**: Check if Iris validates that sender is TokenMessenger
- **Files**: `test/SenderValidation.t.sol`

### Phase 3: Iris Signature Analysis
- **Test**: Monitor which messages receive Iris signatures
- **Expected Outcome**: Track if Iris signs all messages or applies validation
- **Files**: `test/IrisSignatureAnalysis.t.sol`

## Key Findings Format

When tests run, document:

```markdown
### Test Name
- **Nonce Assigned**: [YES/NO]
- **Message Accepted**: [YES/NO]
- **Error (if any)**: [Error message]
- **Analysis**: [What this means for the research]
```

## Next Steps (Off-Chain)

1. **API Query**: After getting nonce, call Circle's Iris API:
   ```
   GET https://iris-api.circle.com/v1/signatures/{nonce}
   ```

2. **Verify Signature**: Check if Iris returned a valid signature

3. **Compare Results**: 
   - Signature from fake deposit message
   - Signature from normal deposit message
   - Signature from arbitrary message

4. **Destination Chain Test**: Try to process fake message on destination chain

## Important Contracts

| Address | Network | Purpose |
|---------|---------|---------|
| 0x0eb340E74b09c2CE87AFCD8b8C156f081432f5c1 | Ethereum/Sepolia | MessageTransmitterV2 |
| 0x12b7546E3A678bd317f25979C6F676Be1b759604 | Ethereum/Sepolia | TokenMessengerV2 |
| 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238 | Sepolia | USDC (testnet) |

## Test Results Log

### Run 1: [Date]
- Message verification tests: [PASS/FAIL]
- Sender validation tests: [PASS/FAIL]
- Iris signature analysis: [PASS/FAIL]
- Key findings: [Summary]

## Responsible Disclosure Plan

Once research is complete:
1. Document all findings
2. Create detailed proof-of-concept
3. Contact Circle Security Team
4. Submit through official bug bounty program
5. Allow reasonable time for patch before public disclosure
