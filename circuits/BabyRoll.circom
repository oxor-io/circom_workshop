pragma circom 2.1.2;

include "./LeafExistence.circom";
include "./GetMerkleRoot.circom";

include "../node_modules/circomlib/circuits/mimcsponge.circom";
include "../node_modules/circomlib/circuits/eddsamimc.circom";
include "../node_modules/circomlib/circuits/comparators.circom";

// Tasks for mastering Circom:
// TODO: Prevent replay attack: add nonce.
// TODO: Add an overflow check for the recipient's balance.
// TODO: Write verifier smart-contract.
// TODO: Optional: add support for processing multiple transactions (MultyTx rollup).

template BabyRoll(k) { // k is the depth of accounts tree
    signal input initial_rollup_root;

    // Accounts info
    signal input sender_pk[2], sender_balance;
    signal input sender_proof_elements[k], sender_proof_pos[k];

    signal input receiver_pk[2], receiver_balance;
    signal input receiver_proof_elements[k], receiver_proof_pos[k];

    // Transactions info
    signal input amount;
    signal input sig_R8x, sig_R8y, sig_S;

    signal output new_rollup_root;

    // Verify sender account exists in initial_rollup_root
    component senderExistence = LeafExistence(k, 3);
    senderExistence.preimage[0] <== sender_pk[0];
    senderExistence.preimage[1] <== sender_pk[1];
    senderExistence.preimage[2] <== sender_balance;

    senderExistence.proof_positions <== sender_proof_pos;
    senderExistence.proof_elements <== sender_proof_elements;

    senderExistence.root <== initial_rollup_root;

    // Get transaction hash
    component txHasher = MiMCSponge(5, 220, 1);
    txHasher.ins[0] <== sender_pk[0];
    txHasher.ins[1] <== sender_pk[1];
    txHasher.ins[2] <== receiver_pk[0];
    txHasher.ins[3] <== receiver_pk[1];
    txHasher.ins[4] <== amount;
    txHasher.k <== 1;

    // Check that transaction was signed by sender
    component signatureChecker = EdDSAMiMCVerifier();
    signatureChecker.Ax <== sender_pk[0];
    signatureChecker.Ay <== sender_pk[1];
    signatureChecker.R8x <== sig_R8x;
    signatureChecker.R8y <== sig_R8y;
    signatureChecker.S <== sig_S;
    signatureChecker.M <== txHasher.outs[0];
    signatureChecker.enabled <== 1;

    // Check sender balance
    component validateAmount = LessEqThan(252);
    validateAmount.in[0] <== amount;
    validateAmount.in[1] <== sender_balance;
    validateAmount.out === 1;

    // Debit sender account
    component newSenderLeaf = MiMCSponge(3, 220, 1);
    newSenderLeaf.ins[0] <== sender_pk[0];
    newSenderLeaf.ins[1] <== sender_pk[1];
    newSenderLeaf.ins[2] <== (sender_balance - amount);
    newSenderLeaf.k <== 1;

    // Compute new root
    component compute_intermediate_root = GetMerkleRoot(k);
    compute_intermediate_root.leaf <== newSenderLeaf.outs[0];
    compute_intermediate_root.proof_positions <== sender_proof_pos;
    compute_intermediate_root.proof_elements <== sender_proof_elements;

    // Verify receiver account exists in intermediate root
    component receiverExistence = LeafExistence(k,3);
    receiverExistence.preimage[0] <== receiver_pk[0];
    receiverExistence.preimage[1] <== receiver_pk[1];
    receiverExistence.preimage[2] <== receiver_balance;
    receiverExistence.root <== compute_intermediate_root.out;

    receiverExistence.proof_positions <== receiver_proof_pos;
    receiverExistence.proof_elements <== receiver_proof_elements;

    // Credit receiver account
    component newReceiverLeaf = MiMCSponge(3, 220, 1);
    newReceiverLeaf.ins[0] <== receiver_pk[0];
    newReceiverLeaf.ins[1] <== receiver_pk[1];
    newReceiverLeaf.ins[2] <== (receiver_balance + amount);
    newReceiverLeaf.k <== 1;

    // Compute final root
    component compute_final_root = GetMerkleRoot(k);
    compute_final_root.leaf <== newReceiverLeaf.outs[0];
    compute_final_root.proof_positions <== receiver_proof_pos;
    compute_final_root.proof_elements <== receiver_proof_elements;

    new_rollup_root <== compute_final_root.out;
}