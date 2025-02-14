// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract ZKProofPaymaster is Ownable, ReentrancyGuard {
    IERC20 public immutable USDC;
    
    struct Stake {
        uint256 nativeTokenAmount;
        uint256 usdcAmount;
        uint256 maxGasAllowed;     // Maximum gas user can use
        uint256 gasUsed;           // Actual gas used
        bool withdrawalApproved;    // Admin approval for withdrawal
    }
    
    mapping(address => Stake) public stakes;
    mapping(address => bool) public authorizedVerifiers;  // Contracts authorized to use gas
    
    uint256 public constant MIN_STAKE = 0.01 ether;
    uint256 public constant MIN_USDC_STAKE = 10e6; // 10 USDC (6 decimals)
    uint256 public gasPrice;  // Current gas price set by admin
    
    event StakedNative(address indexed user, uint256 amount, uint256 maxGasAllowed);
    event StakedUSDC(address indexed user, uint256 amount, uint256 maxGasAllowed);
    event GasUsed(address indexed user, uint256 gasUsed);
    event WithdrawalApproved(address indexed user);
    event WithdrawnNative(address indexed user, uint256 amount);
    event WithdrawnUSDC(address indexed user, uint256 amount);
    event VerifierAuthorized(address indexed verifier);
    event VerifierRemoved(address indexed verifier);
    event GasPriceUpdated(uint256 newPrice);
    
    constructor(address _usdcAddress, uint256 initialGasPrice) {
        USDC = IERC20(_usdcAddress);
        gasPrice = initialGasPrice;
    }
    
    modifier onlyAuthorizedVerifier() {
        require(authorizedVerifiers[msg.sender], "Not authorized verifier");
        _;
    }
    
    // Admin functions
    function setGasPrice(uint256 newPrice) external onlyOwner {
        gasPrice = newPrice;
        emit GasPriceUpdated(newPrice);
    }
    
    function authorizeVerifier(address verifier) external onlyOwner {
        authorizedVerifiers[verifier] = true;
        emit VerifierAuthorized(verifier);
    }
    
    function removeVerifier(address verifier) external onlyOwner {
        authorizedVerifiers[verifier] = false;
        emit VerifierRemoved(verifier);
    }
    
    function approveWithdrawal(address user) external onlyOwner {
        stakes[user].withdrawalApproved = true;
        emit WithdrawalApproved(user);
    }
    
    // Calculate max gas allowed based on stake
    function calculateMaxGas(uint256 nativeAmount, uint256 usdcAmount) internal view returns (uint256) {
        uint256 nativeGas = nativeAmount / gasPrice;
        uint256 usdcGas = (usdcAmount / 2000) / gasPrice; // Simple ETH/USDC conversion
        return nativeGas + usdcGas;
    }
    
    // Stake native token (ETH/MATIC)
    function stakeNative() external payable nonReentrant {
        require(msg.value >= MIN_STAKE, "Stake amount too low");
        Stake storage userStake = stakes[msg.sender];
        userStake.nativeTokenAmount += msg.value;
        userStake.maxGasAllowed = calculateMaxGas(userStake.nativeTokenAmount, userStake.usdcAmount);
        emit StakedNative(msg.sender, msg.value, userStake.maxGasAllowed);
    }
    
    // Stake USDC
    function stakeUSDC(uint256 amount) external nonReentrant {
        require(amount >= MIN_USDC_STAKE, "Stake amount too low");
        require(USDC.transferFrom(msg.sender, address(this), amount), "USDC transfer failed");
        
        Stake storage userStake = stakes[msg.sender];
        userStake.usdcAmount += amount;
        userStake.maxGasAllowed = calculateMaxGas(userStake.nativeTokenAmount, userStake.usdcAmount);
        emit StakedUSDC(msg.sender, amount, userStake.maxGasAllowed);
    }
    
    // Record gas usage - called by authorized verifier contracts
    function recordGasUsage(address user, uint256 gasUsed) external onlyAuthorizedVerifier {
        Stake storage userStake = stakes[user];
        require(userStake.gasUsed + gasUsed <= userStake.maxGasAllowed, "Exceeds max gas allowance");
        userStake.gasUsed += gasUsed;
        emit GasUsed(user, gasUsed);
    }
    
    // Withdraw native token stake
    function withdrawNative() external nonReentrant {
        Stake storage userStake = stakes[msg.sender];
        require(userStake.withdrawalApproved, "Withdrawal not approved");
        require(userStake.nativeTokenAmount > 0, "No stake to withdraw");
        
        uint256 amount = userStake.nativeTokenAmount;
        userStake.nativeTokenAmount = 0;
        userStake.maxGasAllowed = calculateMaxGas(0, userStake.usdcAmount);
        userStake.withdrawalApproved = false;
        
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        emit WithdrawnNative(msg.sender, amount);
    }
    
    // Withdraw USDC stake
    function withdrawUSDC() external nonReentrant {
        Stake storage userStake = stakes[msg.sender];
        require(userStake.withdrawalApproved, "Withdrawal not approved");
        require(userStake.usdcAmount > 0, "No stake to withdraw");
        
        uint256 amount = userStake.usdcAmount;
        userStake.usdcAmount = 0;
        userStake.maxGasAllowed = calculateMaxGas(userStake.nativeTokenAmount, 0);
        userStake.withdrawalApproved = false;
        
        require(USDC.transfer(msg.sender, amount), "USDC transfer failed");
        emit WithdrawnUSDC(msg.sender, amount);
    }
    
    // View functions
    function getStake(address user) external view returns (
        uint256 nativeTokenAmount,
        uint256 usdcAmount,
        uint256 maxGasAllowed,
        uint256 gasUsed,
        bool withdrawalApproved
    ) {
        Stake memory userStake = stakes[user];
        return (
            userStake.nativeTokenAmount,
            userStake.usdcAmount,
            userStake.maxGasAllowed,
            userStake.gasUsed,
            userStake.withdrawalApproved
        );
    }
    
    // Accept native token deposits
    receive() external payable {}
}