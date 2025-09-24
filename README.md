# BitVault Pro - Institutional Asset Tokenization Platform

[![Stacks](https://img.shields.io/badge/Stacks-Blockchain-brightgreen)](https://www.stacks.co/)
[![Clarity](https://img.shields.io/badge/Clarity-Smart%20Contracts-blue)](https://clarity-lang.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Tests](https://img.shields.io/badge/Tests-Passing-green)](tests/)

## 🌟 Overview

BitVault Pro is a revolutionary institutional-grade asset tokenization platform built on the Stacks blockchain, leveraging Bitcoin's unmatched security and immutability. The platform transforms illiquid real-world assets into liquid, tradeable digital securities through sophisticated fractional ownership models.

### Key Value Propositions

- **Bitcoin-Secured Infrastructure**: Built on Stacks' unique Bitcoin-secured blockchain
- **Institutional Compliance**: Automated KYC/AML verification and regulatory frameworks
- **Fractional Ownership**: Democratizes access to high-value asset classes
- **Transparent Governance**: Decentralized governance with stake-weighted voting
- **Automated Distributions**: Real-time dividend distribution with proportional calculations

## 🏗️ Architecture

### Core Components

1. **Asset Registry**: Immutable ownership records secured by Bitcoin
2. **Tokenization Engine**: Fractional tokenization enabling micro-investments
3. **Compliance Framework**: Multi-tier KYC verification system
4. **Governance Protocol**: Decentralized decision-making mechanisms
5. **Price Oracle System**: Integrated asset valuation feeds
6. **Dividend Distribution**: Automated yield calculations and distributions

### Smart Contract Structure

```
contracts/
├── bitvault.clar          # Main contract with core tokenization logic
└── ...                    # Additional contract modules (future expansion)
```

## 🚀 Features

### Asset Tokenization

- **Real Estate**: Commercial properties, residential developments
- **Commodities**: Precious metals, energy assets, agricultural products  
- **Art & Collectibles**: Fine art, rare collectibles, luxury items
- **Financial Instruments**: Bonds, structured products, alternative investments

### Governance & Compliance

- **Stake-Weighted Voting**: Proportional governance rights based on token holdings
- **KYC/AML Integration**: Multi-level verification (up to institutional grade level 5)
- **Regulatory Compliance**: Built-in frameworks for institutional adoption
- **Transparent Operations**: All transactions recorded on Bitcoin-secured blockchain

### Financial Operations

- **Dividend Distribution**: Automated proportional yield calculations
- **Price Oracle Integration**: Real-time asset valuations
- **Fractional Ownership**: Granular ownership units (100,000 tokens per asset)
- **Liquidity Management**: Enhanced liquidity for traditionally illiquid assets

## 📋 Prerequisites

- **Clarinet CLI**: Version 2.0 or higher
- **Node.js**: Version 18 or higher  
- **Stacks Wallet**: For mainnet/testnet interactions
- **Git**: For version control

## 🛠️ Installation

### 1. Clone the Repository

```bash
git clone https://github.com/emediong-godwin/bitvault.git
cd bitvault
```

### 2. Install Dependencies

```bash
# Install Node.js dependencies for testing
npm install

# Verify Clarinet installation
clarinet --version
```

### 3. Environment Setup

```bash
# Initialize Clarinet project (if needed)
clarinet check

# Format contracts
clarinet fmt --in-place
```

## 🧪 Testing

### Run Contract Tests

```bash
# Run all tests
npm test

# Run tests with coverage and gas analysis
npm run test:report

# Watch mode for development
npm run test:watch
```

### Manual Contract Validation

```bash
# Check contract syntax and analysis
clarinet check

# Console testing environment
clarinet console
```

## 📖 Usage Examples

### Asset Tokenization

```clarity
;; Tokenize a real estate property
(contract-call? .bitvault tokenize-asset 
    "https://metadata.bitvault.io/property/123" 
    u50000000000)  ;; $50M valuation in micro-STX
```

### Governance Participation

```clarity
;; Submit a governance proposal
(contract-call? .bitvault submit-governance-proposal
    u1  ;; asset-id
    "Refinancing Proposal for Property 123"
    u144  ;; 24 hour voting period
    u30000)  ;; 30% quorum requirement
```

### Dividend Claims

```clarity
;; Claim accumulated dividends
(contract-call? .bitvault distribute-dividends u1)
```

## 🔧 Configuration

### Network Settings

The platform supports multiple Stacks network configurations:

- **Devnet**: Local development (`settings/Devnet.toml`)
- **Testnet**: Public testing (`settings/Testnet.toml`)  
- **Mainnet**: Production deployment (`settings/Mainnet.toml`)

### Contract Parameters

Key configurable parameters in the smart contract:

```clarity
;; Asset valuation limits
MAX_ASSET_VALUE: 1,000,000,000,000 micro-STX ($1T)
MIN_ASSET_VALUE: 1,000 micro-STX ($1K)

;; Governance timing
MAX_PROPOSAL_DURATION: 144 blocks (~24 hours)
MIN_PROPOSAL_DURATION: 12 blocks (~2 hours)

;; Tokenization economics
TOKENS_PER_ASSET: 100,000 (granular ownership units)
```

## 📊 Contract Functions

### Public Functions

| Function | Description | Access Level |
|----------|-------------|--------------|
| `tokenize-asset` | Create new tokenized asset | Owner Only |
| `distribute-dividends` | Claim proportional dividends | Token Holders |
| `submit-governance-proposal` | Create governance proposal | Stakeholders (10%+ ownership) |
| `cast-governance-vote` | Vote on proposals | Token Holders |

### Read-Only Functions

| Function | Description | Returns |
|----------|-------------|---------|
| `get-asset-by-id` | Retrieve asset information | Asset details |
| `get-token-balance` | Check token balance | Balance amount |
| `get-proposal-by-id` | Get proposal details | Proposal information |
| `get-asset-price-feed` | Current asset valuation | Price data |

## 🛡️ Security Features

### Access Controls

- **Owner-only functions**: Critical operations restricted to contract owner
- **KYC verification**: Multi-level compliance checks
- **Governance thresholds**: Minimum stake requirements for proposals

### Data Validation

- **Input sanitization**: Comprehensive parameter validation
- **Range checks**: Min/max limits on all numerical inputs  
- **Expiry validation**: Time-bounded operations with proper checks

### Error Handling

- **Comprehensive error codes**: Detailed error categorization
- **Graceful failures**: Safe state transitions on errors
- **Audit trail**: All operations logged on-chain

## 🔄 Deployment

### Testnet Deployment

```bash
# Deploy to testnet
clarinet deployments generate --testnet

# Apply deployment
clarinet deployments apply -p deployments/testnet-deployment-plan.yaml
```

### Mainnet Deployment

```bash
# Generate mainnet deployment plan
clarinet deployments generate --mainnet

# Review and apply (requires mainnet STX)
clarinet deployments apply -p deployments/mainnet-deployment-plan.yaml
```

## 📈 Roadmap

### Phase 1: Core Platform (Current)

- [x] Asset tokenization framework
- [x] Fractional ownership system  
- [x] Basic governance mechanism
- [x] Dividend distribution engine

### Phase 2: Enhanced Features (Q1 2025)

- [ ] Advanced KYC integration
- [ ] Multi-asset portfolio management
- [ ] Enhanced price oracle system
- [ ] Mobile wallet integration

### Phase 3: Institutional Features (Q2 2025)

- [ ] Institutional custody solutions
- [ ] Advanced compliance reporting
- [ ] Cross-chain asset bridging
- [ ] Automated market making

### Phase 4: Ecosystem Expansion (Q3 2025)

- [ ] Third-party asset integrations
- [ ] DeFi protocol partnerships
- [ ] Advanced analytics dashboard
- [ ] Mobile applications

## 🤝 Contributing

We welcome contributions from the community! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details on:

- Code style and standards
- Pull request process
- Issue reporting
- Development workflow

### Development Setup

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make changes and test thoroughly
4. Commit changes (`git commit -m 'Add amazing feature'`)
5. Push to branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Stacks Foundation**: For the innovative Bitcoin-secured blockchain
- **Hiro Systems**: For excellent developer tooling and documentation
- **Clarity Community**: For best practices and security insights
- **Bitcoin Community**: For the foundational security layer
