# Circle Iris Payment Verification Research

This repository contains security research on Circle's CCTP (Cross-Chain Transfer Protocol) Iris payment verification mechanism, conducted in an isolated Foundry testing environment.

## Research Focus

Analyzing whether Iris verifies only message structure correctness or if it also validates sender authenticity and message content integrity.

## Quick Start

### Prerequisites
- Foundry installed ([Install Foundry](https://book.getfoundry.sh/getting-started/installation))
- Sepolia testnet ETH in your wallet
- Private key for gas fee transactions

### Setup (2 minutes)

1. **Clone and navigate:**
   ```bash
   cd FD-learning
   ```

2. **Create .env file:**
   ```bash
   cp .env.example .env
   ```
   Edit `.env` with your Sepolia RPC URL and private key

3. **Install dependencies:**
   ```bash
   forge install foundry-rs/forge-std --no-commit
   ```

4. **Run tests:**
   ```bash
   forge test -vvv
   ```

## Project Structure

```
FD-learning/
├── src/
│   └── CCTPDirectMessageTest.sol    # Main test contract
├── test/
│   ├── MessageVerification.t.sol    # Message structure tests
│   ├── SenderValidation.t.sol       # Sender validation tests
│   └── IrisSignatureAnalysis.t.sol  # Iris signature tests
├── script/
│   └── Deploy.s.sol                 # Deployment script
├── foundry.toml                     # Foundry config
├── .env.example                     # Environment template
└── README.md
```

## Key Contracts Analyzed

- **MessageTransmitterV2**: `0x0eb340E74b09c2CE87AFCD8b8C156f081432f5c1`
- **TokenMessengerV2**: `0x12b7546E3A678bd317f25979C6F676Be1b759604`
- **USDC (Sepolia)**: `0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238`

## Research Methodology

1. **Message Structure Verification** - Test if arbitrary message formats are accepted
2. **Sender Validation** - Verify if sender authenticity is checked
3. **Iris Signature Analysis** - Monitor if Iris signs all messages or applies validation
4. **Comparative Testing** - Compare signatures from different message sources

## Running Specific Tests

```bash
# Test message structure validation
forge test --match-contract MessageVerification -vvv

# Test sender validation
forge test --match-contract SenderValidation -vvv

# Test Iris signature analysis
forge test --match-contract IrisSignatureAnalysis -vvv

# Run all tests with gas reports
forge test -vvv --gas-report
```

## Important Notes

- All tests run in an **isolated Foundry environment**
- No actual transfers or state changes occur
- Tests use fork testing against Sepolia testnet
- This is for **authorized security research only**
- Follow responsible disclosure practices

## Responsible Disclosure

Any findings will be reported through Circle's official security channels and bug bounty program.

## References

- [Circle CCTP Documentation](https://developers.circle.com/stablecoin/docs/cctp-protocol)
- [Foundry Book](https://book.getfoundry.sh/)
- [Circle GitHub](https://github.com/circlefin)
