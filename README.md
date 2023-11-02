# BabyRoll

Welcome to BabyRoll, an educational initiative brought to you by CyberAcademy and Oxorio.

## Project Overview

ZK rollup is a layer 2 scaling solution for Ethereum and other blockchain platforms. It allows multiple transactions to be bundled together off-chain, reducing the load on the main chain and improving scalability and transaction throughput. BabyRoll provides a beginner-friendly environment to understand the fundamental concepts behind ZK rollup and its implementation using Circom.

## How to Use

To get started with the BabyRoll project, follow these steps:

1. **Clone the Repository:**

```bash
git clone git@github.com:oxor-io/circom_workshop.git
cd circom_workshop
```

2. **Explore the Code:**
   Familiarize yourself with the project structure and existing codebase.

3. **Completing Homework Tasks:**
   The project includes several TODO tasks to enhance your understanding and skills. Your homework assignments are as follows:

- **Prevent Replay Attack:**
  Implement a solution to prevent replay attacks by adding a nonce to transactions.

- **Overflow Check:**
  Add an overflow check for the recipient's balance to prevent unintended behavior.

- **Write Verifier Smart Contract:**
  Write a verifier smart contract to validate the correctness of the ZK rollup proofs.

- **Optional: MultyTx Rollup Support:**
  If you are feeling adventurous, explore adding support for processing multiple transactions (MultyTx rollup). This task is optional but highly encouraged for a more comprehensive learning experience.

4. **Script Commands:**
   BabyRoll provides convenient script commands to simplify the development process. Here are the available commands:

- **Run `npm run generateTestInput`:**
  Create an `input.json` file with signal values for BabyRoll.

- **Run `npm run test circuit`:**
  Compile BabyRoll, generate a proof with `input.json` as signal values, and run the verification process.

- **Run `npm run solidityVerifier circuit`:**
  Create a verifier smart contract. Note: Ensure you have a file with a `.zkey` extension in the "build" folder (generated when you run `npm run test circuit` or `npm run testNoPots circuit`).

- **Run `npm run getCalldata`:**
  Generate calldata for the `verifyProof` function with the proofs you created earlier.

## Resources

- [Circom Documentation](https://docs.circom.io/getting-started/installation/)
- [ZK Rollup Explained](https://ethereum.org/en/developers/docs/scaling/zk-rollups/)

## Support

If you encounter any issues, have questions, or need assistance, please reach out to us in the issues section. Happy coding!
