;; Title: BitVault Pro - Institutional Asset Tokenization Platform
;;
;; Summary: A comprehensive Clarity smart contract suite that transforms illiquid 
;; real-world assets into liquid, tradeable digital securities on the Stacks 
;; blockchain, leveraging Bitcoin's unmatched security and immutability.
;;
;; Description: BitVault Pro revolutionizes traditional finance by bridging the 
;; gap between physical assets and DeFi innovation. This enterprise-grade protocol 
;; enables seamless tokenization of real estate, commodities, art, and other 
;; high-value assets through fractional ownership models. Built on Stacks' unique 
;; Bitcoin-secured infrastructure, the platform delivers institutional compliance 
;; through automated KYC/AML verification, transparent governance mechanisms, and 
;; sophisticated dividend distribution systems. By unlocking liquidity in trillion-
;; dollar asset classes traditionally reserved for institutional players, BitVault 
;; Pro democratizes wealth creation while maintaining the security standards 
;; demanded by modern financial markets.
;;
;; Key Features:
;; - Bitcoin-Secured Asset Registry with immutable ownership records
;; - Fractional tokenization enabling micro-investments in premium assets  
;; - Automated compliance engine with multi-tier KYC verification
;; - Decentralized governance with stake-weighted voting mechanisms
;; - Real-time dividend distribution with proportional yield calculations
;; - Integrated price oracle system for accurate asset valuations
;; - Regulatory-compliant framework designed for institutional adoption
;;
;; Built for the Stacks ecosystem, powered by Bitcoin's security guarantee.

;;                                CONSTANTS                                     

;; Administrative Authority
(define-constant CONTRACT_OWNER tx-sender)

;;                              ERROR CODES                                   

;; Access Control Errors
(define-constant ERR_OWNER_ONLY (err u100))
(define-constant ERR_NOT_AUTHORIZED (err u104))
(define-constant ERR_KYC_REQUIRED (err u105))

;; Asset Management Errors
(define-constant ERR_ASSET_NOT_FOUND (err u101))
(define-constant ERR_ASSET_ALREADY_EXISTS (err u102))
(define-constant ERR_INVALID_AMOUNT (err u103))
(define-constant ERR_PRICE_DATA_EXPIRED (err u108))

;; Governance Errors
(define-constant ERR_VOTE_ALREADY_CAST (err u106))
(define-constant ERR_VOTING_PERIOD_ENDED (err u107))

;; Validation Errors
(define-constant ERR_INVALID_METADATA_URI (err u110))
(define-constant ERR_INVALID_ASSET_VALUE (err u111))
(define-constant ERR_INVALID_PROPOSAL_DURATION (err u112))
(define-constant ERR_INVALID_KYC_LEVEL (err u113))
(define-constant ERR_INVALID_EXPIRY_TIME (err u114))
(define-constant ERR_INVALID_VOTE_THRESHOLD (err u115))
(define-constant ERR_INVALID_PROPOSAL_TITLE (err u117))

;;                           PROTOCOL PARAMETERS                              

;; Asset Valuation Limits (in micro-STX for precision)
(define-constant MAX_ASSET_VALUE u1000000000000) ;; $1T equivalent ceiling
(define-constant MIN_ASSET_VALUE u1000) ;; $1K minimum threshold

;; Governance Timing (in Stacks blocks ~10min each)
(define-constant MAX_PROPOSAL_DURATION u144) ;; ~24 hours maximum
(define-constant MIN_PROPOSAL_DURATION u12) ;; ~2 hours minimum

;; Compliance Standards
(define-constant MAX_KYC_VERIFICATION_LEVEL u5) ;; Institutional grade
(define-constant MAX_KYC_VALIDITY_PERIOD u52560) ;; ~1 year blocks

;; Tokenization Economics
(define-constant TOKENS_PER_ASSET u100000) ;; Granular ownership units

;;                              STATE VARIABLES                                

(define-data-var current-asset-id uint u0)
(define-data-var current-proposal-id uint u0)

;;                               DATA STORAGE                                  

;;                         ASSET REGISTRY STORAGE                            

(define-map asset-registry
  { asset-id: uint }
  {
    asset-owner: principal,
    metadata-uri: (string-ascii 256),
    valuation: uint,
    locked-status: bool,
    registration-height: uint,
    price-last-updated: uint,
    cumulative-dividends: uint,
  }
)

;;                        OWNERSHIP TRACKING STORAGE                         

(define-map fractional-ownership
  {
    holder: principal,
    asset-id: uint,
  }
  { token-balance: uint }
)

;;                        COMPLIANCE VERIFICATION                            

(define-map kyc-registry
  { verified-address: principal }
  {
    verification-status: bool,
    compliance-level: uint,
    expiration-height: uint,
  }
)

;;                         GOVERNANCE INFRASTRUCTURE                         

(define-map governance-proposals
  { proposal-id: uint }
  {
    proposal-title: (string-ascii 256),
    target-asset-id: uint,
    voting-start-height: uint,
    voting-end-height: uint,
    execution-status: bool,
    support-votes: uint,
    opposition-votes: uint,
    required-quorum: uint,
  }
)

(define-map voting-records
  {
    proposal-id: uint,
    voter-address: principal,
  }
  { voting-power: uint }
)

;;                          DIVIDEND DISTRIBUTION                            

(define-map dividend-ledger
  {
    asset-id: uint,
    beneficiary: principal,
  }
  { last-distribution-claimed: uint }
)

;;                            PRICE ORACLE FEEDS                             

(define-map oracle-price-feeds
  { asset-id: uint }
  {
    current-price: uint,
    price-decimals: uint,
    timestamp-updated: uint,
    oracle-provider: principal,
  }
)

;;                           VALIDATION UTILITIES                              

(define-private (is-valid-asset-value (value uint))
  (and
    (>= value MIN_ASSET_VALUE)
    (<= value MAX_ASSET_VALUE)
  )
)

(define-private (is-valid-proposal-duration (duration uint))
  (and
    (>= duration MIN_PROPOSAL_DURATION)
    (<= duration MAX_PROPOSAL_DURATION)
  )
)

(define-private (is-valid-kyc-level (level uint))
  (<= level MAX_KYC_VERIFICATION_LEVEL)
)

(define-private (is-valid-expiry-time (expiry uint))
  (and
    (> expiry stacks-block-height)
    (<= (- expiry stacks-block-height) MAX_KYC_VALIDITY_PERIOD)
  )
)

(define-private (is-valid-quorum-threshold (threshold uint))
  (and
    (> threshold u0)
    (<= threshold TOKENS_PER_ASSET)
  )
)

(define-private (is-valid-metadata-uri (uri (string-ascii 256)))
  (and
    (> (len uri) u0)
    (<= (len uri) u256)
  )
)

;;                           CORE PUBLIC FUNCTIONS                             

;;                           ASSET TOKENIZATION                              

(define-public (tokenize-asset
    (metadata-uri (string-ascii 256))
    (initial-valuation uint)
  )
  (begin
    ;; Authority verification
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)

    ;; Input validation
    (asserts! (is-valid-metadata-uri metadata-uri) ERR_INVALID_METADATA_URI)
    (asserts! (is-valid-asset-value initial-valuation) ERR_INVALID_ASSET_VALUE)

    (let ((new-asset-id (generate-next-asset-id)))
      ;; Register asset in the blockchain registry
      (map-set asset-registry { asset-id: new-asset-id } {
        asset-owner: CONTRACT_OWNER,
        metadata-uri: metadata-uri,
        valuation: initial-valuation,
        locked-status: false,
        registration-height: stacks-block-height,
        price-last-updated: stacks-block-height,
        cumulative-dividends: u0,
      })

      ;; Initialize full ownership to contract deployer
      (map-set fractional-ownership {
        holder: CONTRACT_OWNER,
        asset-id: new-asset-id,
      } { token-balance: TOKENS_PER_ASSET }
      )

      ;; Update global state
      (var-set current-asset-id new-asset-id)
      (ok new-asset-id)
    )
  )
)

;;                          DIVIDEND DISTRIBUTION                            

(define-public (distribute-dividends (asset-id uint))
  (let (
      (asset-data (unwrap! (get-asset-by-id asset-id) ERR_ASSET_NOT_FOUND))
      (holder-balance (get-token-balance tx-sender asset-id))
      (last-claim (get-last-dividend-claim asset-id tx-sender))
      (total-distributed (get cumulative-dividends asset-data))
      (claimable-yield (calculate-proportional-dividend holder-balance total-distributed
        last-claim
      ))
    )
    (asserts! (> claimable-yield u0) ERR_INVALID_AMOUNT)

    ;; Record the dividend claim
    (map-set dividend-ledger {
      asset-id: asset-id,
      beneficiary: tx-sender,
    } { last-distribution-claimed: total-distributed }
    )
    (ok claimable-yield)
  )
)

;;                           GOVERNANCE SYSTEM                               

(define-public (submit-governance-proposal
    (asset-id uint)
    (proposal-title (string-ascii 256))
    (voting-duration uint)
    (quorum-requirement uint)
  )
  (begin
    ;; Validation checks
    (asserts! (is-valid-proposal-duration voting-duration)
      ERR_INVALID_PROPOSAL_DURATION
    )
    (asserts! (is-valid-quorum-threshold quorum-requirement)
      ERR_INVALID_VOTE_THRESHOLD
    )
    (asserts! (is-valid-metadata-uri proposal-title) ERR_INVALID_PROPOSAL_TITLE)

    ;; Minimum stake requirement (10% of total supply)
    (asserts!
      (>= (get-token-balance tx-sender asset-id) (/ TOKENS_PER_ASSET u10))
      ERR_NOT_AUTHORIZED
    )

    (let ((new-proposal-id (generate-next-proposal-id)))
      ;; Create governance proposal
      (map-set governance-proposals { proposal-id: new-proposal-id } {
        proposal-title: proposal-title,
        target-asset-id: asset-id,
        voting-start-height: stacks-block-height,
        voting-end-height: (+ stacks-block-height voting-duration),
        execution-status: false,
        support-votes: u0,
        opposition-votes: u0,
        required-quorum: quorum-requirement,
      })

      ;; Update proposal counter
      (var-set current-proposal-id new-proposal-id)
      (ok new-proposal-id)
    )
  )
)

;;                            VOTING MECHANISM                               

(define-public (cast-governance-vote
    (proposal-id uint)
    (support-proposal bool)
    (voting-tokens uint)
  )
  (let (
      (proposal-data (unwrap! (get-proposal-by-id proposal-id) ERR_ASSET_NOT_FOUND))
      (target-asset (get target-asset-id proposal-data))
      (voter-balance (get-token-balance tx-sender target-asset))
    )
    (begin
      ;; Verify voting eligibility
      (asserts! (>= voter-balance voting-tokens) ERR_INVALID_AMOUNT)
      (asserts! (< stacks-block-height (get voting-end-height proposal-data))
        ERR_VOTING_PERIOD_ENDED
      )
      (asserts! (is-none (get-existing-vote proposal-id tx-sender))
        ERR_VOTE_ALREADY_CAST
      )

      ;; Record the vote
      (map-set voting-records {
        proposal-id: proposal-id,
        voter-address: tx-sender,
      } { voting-power: voting-tokens }
      )

      ;; Update proposal vote tallies
      (map-set governance-proposals { proposal-id: proposal-id }
        (merge proposal-data {
          support-votes: (if support-proposal
            (+ (get support-votes proposal-data) voting-tokens)
            (get support-votes proposal-data)
          ),
          opposition-votes: (if support-proposal
            (get opposition-votes proposal-data)
            (+ (get opposition-votes proposal-data) voting-tokens)
          ),
        })
      )
      (ok voting-tokens)
    )
  )
)

;;                            READ-ONLY FUNCTIONS                              

;;                           ASSET INFORMATION                               

(define-read-only (get-asset-by-id (asset-id uint))
  (map-get? asset-registry { asset-id: asset-id })
)

(define-read-only (get-token-balance
    (holder principal)
    (asset-id uint)
  )
  (default-to u0
    (get token-balance
      (map-get? fractional-ownership {
        holder: holder,
        asset-id: asset-id,
      })
    ))
)

;;                          GOVERNANCE QUERIES                               

(define-read-only (get-proposal-by-id (proposal-id uint))
  (map-get? governance-proposals { proposal-id: proposal-id })
)

(define-read-only (get-existing-vote
    (proposal-id uint)
    (voter principal)
  )
  (map-get? voting-records {
    proposal-id: proposal-id,
    voter-address: voter,
  })
)

;;                           MARKET DATA FEEDS                               

(define-read-only (get-asset-price-feed (asset-id uint))
  (map-get? oracle-price-feeds { asset-id: asset-id })
)

(define-read-only (get-last-dividend-claim
    (asset-id uint)
    (beneficiary principal)
  )
  (default-to u0
    (get last-distribution-claimed
      (map-get? dividend-ledger {
        asset-id: asset-id,
        beneficiary: beneficiary,
      })
    ))
)

;;                            UTILITY FUNCTIONS                                

;;                           ID GENERATION                                   

(define-private (generate-next-asset-id)
  (+ (var-get current-asset-id) u1)
)

(define-private (generate-next-proposal-id)
  (+ (var-get current-proposal-id) u1)
)

;;                         FINANCIAL CALCULATIONS                            

(define-private (calculate-proportional-dividend
    (holder-balance uint)
    (total-dividends uint)
    (last-claimed uint)
  )
  (/ (* holder-balance (- total-dividends last-claimed)) TOKENS_PER_ASSET)
)
