## Demo Video
[Watch Demo Video](https://youtu.be/tQPaPGo0pyA)

## Explanation Video
[Watch Explanation Video](https://youtu.be/3EEa9kmQEhg)

# 🚀 DoraNode

A revolutionary platform simplifying ZK proof verification by enabling native token payments and automated cross-chain verification.

## Overview
DoraNode is a decentralized service that simplifies **zero-knowledge proof (ZKP) verification** on the **ZKVerify Chain**. It enables users to generate ZK proofs and submit them for verification without needing a dedicated ZKVerify-supported wallet or ACME gas tokens.

## 🌟 Features

- **Native Token Payments**: Pay verification fees in your chain's native tokens
- **Paymaster Contract**: Enables dApp sponsorship of verification costs
- **No Wallet Switching**: Seamless cross-chain verification
- **AI Integration**: Automated proposal review and bias detection
- **ZKVRF Implementation**: Fair and verifiable random selection


# DoraNode and Operator Node Setup using Docker

This guide provides step-by-step instructions for running **DoraNode** and **Operator Node** using Docker. Docker simplifies the setup process by containerizing the environment, ensuring consistency across different systems.

---

## Prerequisites

Before proceeding, ensure you have the following installed on your system:

1. **Docker**: Install Docker by following the official installation guide for your operating system:
   - [Docker Installation Guide](https://docs.docker.com/get-docker/)
   
2. **Docker Compose**: Docker Compose is typically included with Docker Desktop. If not, install it separately:
   - [Docker Compose Installation Guide](https://docs.docker.com/compose/install/)

3. **Git**: Clone this repository to your local machine:
   - [Git Installation Guide](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

---

## Setup Instructions


---

### 1. Navigate to the Docker Directory
Change to the `docker` directory where the `docker-compose.yml` file is located:

```bash
cd docker
```

---

### 2. Run Docker Compose
Use Docker Compose to start the DoraNode and Operator Node in detached mode. This will run the containers in the background:

```bash
docker compose up -d
```

#### Explanation:
- `docker compose up`: Starts the containers defined in the `docker-compose.yml` file.
- `-d`: Runs the containers in **detached mode**, meaning they will run in the background.

---

### 3. Verify the Containers are Running
To check the status of the running containers, use the following command:

```bash
docker ps
```

This will display a list of running containers. Ensure that both the DoraNode and Operator Node containers are listed and running.

---

### 4. View Logs (Optional)
If you need to debug or monitor the nodes, you can view the logs for each container:

```bash
docker logs <container-name>
```

Replace `<container-name>` with the name of the container (e.g., `doranode` or `operator-node`).

---

### 6. Stop the Containers
To stop the running containers, use the following command:

```bash
docker compose down
```

This will stop and remove the containers, but it will retain any data stored in volumes.

---


## Setting Up the Frontend
To set up and run the frontend, follow these steps:

1. Navigate to the `Frontend` directory:
   ```sh
   cd Frontend
   ```

2. Install dependencies:
   ```sh
   npm install
   ```

3. Start the development server:
   ```sh
   npm run dev
   ```

   This will start the frontend on the default development port (usually `http://localhost:3000/` or as specified in your configuration).

## Additional Notes
- If you encounter issues, ensure your Node.js and npm versions are up to date.
- If using a specific framework (e.g., React, Vue, Next.js), mention any extra configuration steps required.
- Consider adding environment variable setup instructions if applicable.





## ZKVRF
## ⚠️  Note
>  ZKVRF is a Verifiable Random Function (VRF) project re-implemented in Circom and Noir for zkVerify. Additionally, an automated operator node has been implemented.

ZKRand is a specialized deterministic public-key cryptographic system that leverages zk-SNARK technology through Circom to provide verifiable random numbers. The system is designed to serve decentralized applications on the Citrea chain, particularly for use cases such as:


## Key Features

### Secure Randomness Properties

- **Unpredictability**: Random numbers cannot be guessed in advance
- **Impartiality**: Results are generated without bias
- **Auditability**: The random number generation process is fully verifiable
- **Consistency**: Reliable availability when needed

### Technical Advantages

- **Universal Access**: Generate random numbers directly through a web browser
- **No Special Software**: Works with standard web browsers
- **EVM Compatibility**: Functions on any Ethereum Virtual Machine network with EC precompile support

## Benefits

ZKRand addresses the common trade-offs found in current randomness technologies by providing a balanced solution that optimizes:

- Availability
- Cost efficiency
- Bias resistance
- System uptime


