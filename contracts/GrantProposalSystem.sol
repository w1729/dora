// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract GrantProposalSystem is AccessControl, ReentrancyGuard {
    // Roles
    bytes32 public constant REVIEWER_ROLE = keccak256("REVIEWER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    // Proposal status
    enum ProposalStatus {
        Draft,
        Submitted,
        UnderReview,
        Approved,
        Rejected,
        Funded,
        Completed,
        Cancelled
    }

    // Milestone status
    enum MilestoneStatus {
        Pending,
        Submitted,
        Approved,
        Rejected
    }

    // Proposal struct
    struct Proposal {
        address proposer;
        string ipfsHash;           // Main proposal content
        uint256 requestedAmount;
        uint256 fundedAmount;
        uint256 createTime;
        uint256 lastUpdateTime;
        ProposalStatus status;
        uint256 reviewCount;
        uint256 milestoneCount;
        mapping(uint256 => Milestone) milestones;
        mapping(address => bool) reviewers;
        mapping(address => Review) reviews;
    }

    // Milestone struct
    struct Milestone {
        string ipfsHash;           // Milestone details
        uint256 amount;
        uint256 deadline;
        MilestoneStatus status;
        string deliverableHash;    // IPFS hash of deliverables
    }

    // Review struct
    struct Review {
        string ipfsHash;           // Review content
        bool recommendation;       // true = approve, false = reject
        uint256 timestamp;
    }

    // State variables
    mapping(uint256 => Proposal) public proposals;
    uint256 public proposalCount;
    IERC20 public grantToken;
    uint256 public minReviewsRequired;
    uint256 public maxProposalAmount;
    
    // Events
    event ProposalCreated(uint256 indexed proposalId, address indexed proposer, string ipfsHash);
    event ProposalUpdated(uint256 indexed proposalId, string newIpfsHash);
    event ProposalStatusChanged(uint256 indexed proposalId, ProposalStatus status);
    event ReviewSubmitted(uint256 indexed proposalId, address indexed reviewer, string ipfsHash);
    event MilestoneAdded(uint256 indexed proposalId, uint256 milestoneId, string ipfsHash);
    event MilestoneCompleted(uint256 indexed proposalId, uint256 milestoneId, string deliverableHash);
    event FundsReleased(uint256 indexed proposalId, uint256 milestoneId, uint256 amount);

    constructor(address _grantToken) {
        grantToken = IERC20(_grantToken);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        minReviewsRequired = 2;
        maxProposalAmount = 100000 * 10**18; // 100,000 tokens
    }

    // Admin functions
    function setMinReviewsRequired(uint256 _minReviews) external onlyRole(ADMIN_ROLE) {
        minReviewsRequired = _minReviews;
    }

    function setMaxProposalAmount(uint256 _maxAmount) external onlyRole(ADMIN_ROLE) {
        maxProposalAmount = _maxAmount;
    }

    function addReviewer(address reviewer) external onlyRole(ADMIN_ROLE) {
        grantRole(REVIEWER_ROLE, reviewer);
    }

    function removeReviewer(address reviewer) external onlyRole(ADMIN_ROLE) {
        revokeRole(REVIEWER_ROLE, reviewer);
    }

    // Proposal management functions
    function createProposal(string calldata ipfsHash, uint256 requestedAmount) external returns (uint256) {
        require(requestedAmount <= maxProposalAmount, "Amount exceeds maximum");
        
        uint256 proposalId = proposalCount++;
        Proposal storage proposal = proposals[proposalId];
        
        proposal.proposer = msg.sender;
        proposal.ipfsHash = ipfsHash;
        proposal.requestedAmount = requestedAmount;
        proposal.createTime = block.timestamp;
        proposal.lastUpdateTime = block.timestamp;
        proposal.status = ProposalStatus.Draft;
        
        emit ProposalCreated(proposalId, msg.sender, ipfsHash);
        return proposalId;
    }

    function updateProposal(uint256 proposalId, string calldata newIpfsHash) external {
        Proposal storage proposal = proposals[proposalId];
        require(msg.sender == proposal.proposer, "Not proposer");
        require(proposal.status == ProposalStatus.Draft, "Not in draft");
        
        proposal.ipfsHash = newIpfsHash;
        proposal.lastUpdateTime = block.timestamp;
        
        emit ProposalUpdated(proposalId, newIpfsHash);
    }

    function submitProposal(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];
        require(msg.sender == proposal.proposer, "Not proposer");
        require(proposal.status == ProposalStatus.Draft, "Not in draft");
        
        proposal.status = ProposalStatus.Submitted;
        proposal.lastUpdateTime = block.timestamp;
        
        emit ProposalStatusChanged(proposalId, ProposalStatus.Submitted);
    }

    // Review functions
    function submitReview(
        uint256 proposalId, 
        string calldata reviewHash, 
        bool recommendation
    ) external onlyRole(REVIEWER_ROLE) {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.status == ProposalStatus.Submitted || 
                proposal.status == ProposalStatus.UnderReview, "Invalid status");
        require(!proposal.reviewers[msg.sender], "Already reviewed");
        
        proposal.reviewers[msg.sender] = true;
        proposal.reviews[msg.sender] = Review({
            ipfsHash: reviewHash,
            recommendation: recommendation,
            timestamp: block.timestamp
        });
        proposal.reviewCount++;
        
        if (proposal.status == ProposalStatus.Submitted) {
            proposal.status = ProposalStatus.UnderReview;
        }
        
        emit ReviewSubmitted(proposalId, msg.sender, reviewHash);
    }

    // Milestone management
    function addMilestone(
        uint256 proposalId,
        string calldata ipfsHash,
        uint256 amount,
        uint256 deadline
    ) external {
        Proposal storage proposal = proposals[proposalId];
        require(msg.sender == proposal.proposer, "Not proposer");
        require(proposal.status == ProposalStatus.Draft, "Not in draft");
        
        uint256 milestoneId = proposal.milestoneCount++;
        Milestone storage milestone = proposal.milestones[milestoneId];
        
        milestone.ipfsHash = ipfsHash;
        milestone.amount = amount;
        milestone.deadline = deadline;
        milestone.status = MilestoneStatus.Pending;
        
        emit MilestoneAdded(proposalId, milestoneId, ipfsHash);
    }

    function submitMilestoneDeliverable(
        uint256 proposalId,
        uint256 milestoneId,
        string calldata deliverableHash
    ) external {
        Proposal storage proposal = proposals[proposalId];
        require(msg.sender == proposal.proposer, "Not proposer");
        require(proposal.status == ProposalStatus.Funded, "Not funded");
        
        Milestone storage milestone = proposal.milestones[milestoneId];
        require(milestone.status == MilestoneStatus.Pending, "Invalid status");
        require(block.timestamp <= milestone.deadline, "Deadline passed");
        
        milestone.deliverableHash = deliverableHash;
        milestone.status = MilestoneStatus.Submitted;
        
        emit MilestoneCompleted(proposalId, milestoneId, deliverableHash);
    }

    // Admin approval and funding functions
    function approveProposal(uint256 proposalId) external onlyRole(ADMIN_ROLE) {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.status == ProposalStatus.UnderReview, "Invalid status");
        require(proposal.reviewCount >= minReviewsRequired, "Insufficient reviews");
        
        proposal.status = ProposalStatus.Approved;
        emit ProposalStatusChanged(proposalId, ProposalStatus.Approved);
    }

    function fundProposal(uint256 proposalId) external onlyRole(ADMIN_ROLE) {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.status == ProposalStatus.Approved, "Not approved");
        
        proposal.status = ProposalStatus.Funded;
        proposal.fundedAmount = proposal.requestedAmount;
        
        require(grantToken.transferFrom(
            msg.sender,
            address(this),
            proposal.requestedAmount
        ), "Transfer failed");
        
        emit ProposalStatusChanged(proposalId, ProposalStatus.Funded);
    }

    function releaseMilestoneFunding(
        uint256 proposalId,
        uint256 milestoneId
    ) external onlyRole(ADMIN_ROLE) nonReentrant {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.status == ProposalStatus.Funded, "Not funded");
        
        Milestone storage milestone = proposal.milestones[milestoneId];
        require(milestone.status == MilestoneStatus.Submitted, "Not submitted");
        
        milestone.status = MilestoneStatus.Approved;
        
        require(grantToken.transfer(
            proposal.proposer,
            milestone.amount
        ), "Transfer failed");
        
        emit FundsReleased(proposalId, milestoneId, milestone.amount);
    }

    // View functions
    function getProposalDetails(uint256 proposalId) external view returns (
        address proposer,
        string memory ipfsHash,
        uint256 requestedAmount,
        uint256 fundedAmount,
        uint256 createTime,
        uint256 lastUpdateTime,
        ProposalStatus status,
        uint256 reviewCount,
        uint256 milestoneCount
    ) {
        Proposal storage proposal = proposals[proposalId];
        return (
            proposal.proposer,
            proposal.ipfsHash,
            proposal.requestedAmount,
            proposal.fundedAmount,
            proposal.createTime,
            proposal.lastUpdateTime,
            proposal.status,
            proposal.reviewCount,
            proposal.milestoneCount
        );
    }

    function getMilestone(uint256 proposalId, uint256 milestoneId) external view returns (
        string memory ipfsHash,
        uint256 amount,
        uint256 deadline,
        MilestoneStatus status,
        string memory deliverableHash
    ) {
        Milestone storage milestone = proposals[proposalId].milestones[milestoneId];
        return (
            milestone.ipfsHash,
            milestone.amount,
            milestone.deadline,
            milestone.status,
            milestone.deliverableHash
        );
    }

    function getReview(uint256 proposalId, address reviewer) external view returns (
        string memory ipfsHash,
        bool recommendation,
        uint256 timestamp
    ) {
        Review storage review = proposals[proposalId].reviews[reviewer];
        return (review.ipfsHash, review.recommendation, review.timestamp);
    }
}