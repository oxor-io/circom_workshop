pragma circom 2.1.2;
include "BabyRoll.circom";

component main { public [initial_rollup_root] } = BabyRoll(1);