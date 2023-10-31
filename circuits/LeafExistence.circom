pragma circom 2.1.2;

include "./GetMerkleRoot.circom";
include "../node_modules/circomlib/circuits/mimcsponge.circom";

template LeafExistence(k, l) { // k is depth of the tree, l is length preimage of hasher
    signal input preimage[l];
    signal input proof_elements[k], proof_positions[k];
    signal input root;

    component hasher = MiMCSponge(l, 220, 1);

    hasher.ins <== preimage;
    hasher.k <== 1;

    component compute_root = GetMerkleRoot(k);

    compute_root.leaf <== hasher.outs[0];
    compute_root.proof_elements <== proof_elements;
    compute_root.proof_positions <== proof_positions;

    root === compute_root.out;
}
