# zkVerify EVM DApp Example

This repository provides a simple example of a decentralized application (DApp) that leverages [zkVerify](https://github.com/zkVerify/zkVerify) for off-chain proof verification, via [zkVerifyJS](https://github.com/zkVerify/zkverifyjs). The DApp demonstrates how to integrate a zk-SNARK circuit, deploy Solidity smart contracts that interact with zkVerify's attestation contract, and build a user interface to interact with the system.

## Folder Structure

The repository is organized into three main directories:

-   `app`: Contains the frontend of the DApp, built with Node.js. This is the user-facing part of the application.
-   `circuit`: Contains the zk-SNARK circuit written in Circom. This is where the logic for the zero-knowledge proof is defined.
-   `contracts`: Contains the Solidity smart contracts, managed with Foundry. These contracts are deployed to an Ethereum-compatible blockchain and interact with the zkVerify attestation contract.

## Prerequisites

Before you begin, ensure you have the following installed:

-   [Node.js](https://nodejs.org/en/)
-   [Foundry](https://getfoundry.sh/)
-   [Circom](https://docs.circom.io/getting-started/installation/)
-   [snarkjs](https://github.com/iden3/snarkjs)

## Installation and Setup

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/zkVerify/zkverify-evm-dapp-example.git
    cd zkverify-evm-dapp-example
    ```

2.  **Install Node.js dependencies:**

    ```bash
    cd app
    npm install
    cd ..
    ```

3.  **Set up environment variables:**

    In the `app` and `contracts` directories, you will find `.env.template` and `.env.secrets.template` files. Copy these to `.env` and `.env.secrets` respectively:

    ```bash
    cp app/.env.template app/.env
    cp contracts/.env.template contracts/.env
    ```

    Fill in the required values, such as your private key and RPC URL.

## Development and Deployment Workflow

### 1. Circuit Development

The `circuit` directory contains the Circom code for the zk-SNARK. The `Makefile` in this directory automates the process of compiling the circuit and generating the necessary keys.

-   **Compile the circuit and generate keys:**

    ```bash
    cd circuit
    make
    ```

    This command will:
    1.  Compile the `circuit.circom` file.
    2.  Perform a local trusted setup (for demonstration purposes, do not use in production).
    3.  Generate the proving key (`circuit_final.zkey`), verification key (`verification_key.json`), and a WebAssembly version of the circuit (`circuit.wasm`).
    4.  Place the generated files in the `setup` directory.

### 2. Smart Contract Development

The `contracts` directory contains the Solidity smart contracts, managed with Foundry.

-   **Build the contracts:**

    ```bash
    cd contracts
    forge build
    ```

-   **Deploy the contracts:**

    The deployment scripts are located in the `script` directory. To deploy the contracts, first copy the .env.template file to .env:

    ```bash
    cd contracts
    forge script script/ZkFactorization.s.sol:ZkFactorizationContractScript --rpc-url <your_rpc_url> --private-key <your_private_key>
    ```

### 3. DApp Interaction

The `app` directory contains the Node.js application that serves as the frontend for the DApp. `zkVerifyJS` is used to interact with the zkVerify Blockchain.

-   **Run the DApp:**

    ```bash
    cd app
    node index.js
    ```

### End-to-End User Workflow

1.  **Generate a Proof:** The user interacts with the DApp's frontend. The DApp uses the compiled circuit (`circuit.wasm`) and the proving key (`circuit_final.zkey`) to generate a proof based on the user's input.

2.  **Submit Proof to zkVerify:** The DApp sends the generated proof and public inputs to the zkVerify service for verification.

3.  **Receive Proof ID:** zkVerify verifies the proof and, if valid, returns a unique `proofId`.

4.  **Interact with the Smart Contract:** The DApp calls a function on the deployed smart contract, passing the `proofId` as an argument.

5.  **On-Chain Attestation:** The smart contract communicates with the zkVerify attestation contract, providing the `proofId`. The attestation contract checks if a proof with that ID has been successfully verified by zkVerify.

6.  **Execute Logic:** If the proof is valid, the smart contract proceeds with its logic (e.g., minting an NFT, transferring tokens, etc.).

## Next Steps

Check out [zkVerify documentation](https://docs.zkverify.io/) for additional info and tutorials:
- [zkVerify Contracts](https://docs.zkverify.io/overview/contract-addresses)
- [zkVerify Supported Verifiers](https://docs.zkverify.io/overview/supported_proofs)
- [zkVerifyJS](https://docs.zkverify.io/overview/zkverifyjs)
- [Dapp Developer Tutorial](https://docs.zkverify.io/overview/getting-started/smart-contract)
- [Utility Solidity Library for DApp Developers](https://github.com/zkVerify/zkv-attestation-contracts/tree/main/contracts/verifiers)
- [zkVerify Aggregation Contract](https://github.com/zkVerify/zkv-attestation-contracts/blob/main/contracts/ZkVerifyAggregationGlobal.sol)