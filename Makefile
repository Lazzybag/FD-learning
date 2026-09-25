.PHONY: help install test clean deploy

help:
	@echo "Circle Iris Research - Available Commands:"
	@echo "==========================================="
	@echo "make install          - Install dependencies"
	@echo "make test            - Run all tests with verbose output"
	@echo "make test-message    - Run message verification tests only"
	@echo "make test-sender     - Run sender validation tests only"
	@echo "make test-iris       - Run Iris signature analysis tests only"
	@echo "make test-gas        - Run tests with gas report"
	@echo "make deploy          - Deploy to Sepolia testnet"
	@echo "make clean           - Clean build artifacts"
	@echo ""

install:
	@echo "Installing Foundry dependencies..."
	forge install foundry-rs/forge-std --no-commit

test:
	@echo "Running all tests..."
	forge test -vvv

test-message:
	@echo "Running message verification tests..."
	forge test --match-contract MessageVerification -vvv

test-sender:
	@echo "Running sender validation tests..."
	forge test --match-contract SenderValidation -vvv

test-iris:
	@echo "Running Iris signature analysis tests..."
	forge test --match-contract IrisSignatureAnalysis -vvv

test-gas:
	@echo "Running tests with gas report..."
	forge test -vvv --gas-report

deploy:
	@echo "Deploying to Sepolia testnet..."
	@if [ -z "$(PRIVATE_KEY)" ]; then \
		echo "Error: PRIVATE_KEY not set"; \
		exit 1; \
	fi
	@if [ -z "$(SEPOLIA_RPC_URL)" ]; then \
		echo "Error: SEPOLIA_RPC_URL not set"; \
		exit 1; \
	fi
	forge script script/Deploy.s.sol:Deploy --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast

clean:
	@echo "Cleaning build artifacts..."
	forge clean
	rm -rf cache out
