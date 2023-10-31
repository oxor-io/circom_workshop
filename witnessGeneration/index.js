const { generateTree } = require("./GenerateMerkleTree");
const { signMessage } = require("./GenerateSignedMessage");
const { buildBabyjub, buildEddsa, buildMimcSponge } = require("circomlibjs");
const fs = require("fs");
const path = require("path");

const privKeySrc =
  "0001020304050607080900010203040506070809000102030405060708090001"; // Random private key

const TREE_HEIGHT = 1;
const MIMC_KEY = 1;
const NUMBER_OF_OUTPUTS = 1;
const AMOUNT = 50n;

const ALICE_INIT_BALANCE = 100n;
const BOB_INIT_BALANCE = 50n;

let babyJub, F;
let eddsa, mimcSponge;

async function initializeLibraries() {
  babyJub = await buildBabyjub();
  F = babyJub.F;

  eddsa = await buildEddsa();
  mimcSponge = await buildMimcSponge();
}

async function main() {
  await initializeLibraries();

  const alicePrivKey = Buffer.from(privKeySrc, "hex");
  const bobPrivKey = Buffer.from(
    privKeySrc.split("").reverse().join(""),
    "hex"
  );

  const alice = createUserObject(alicePrivKey, ALICE_INIT_BALANCE);
  const bob = createUserObject(bobPrivKey, BOB_INIT_BALANCE);

  const leafsData = [alice.getState(), bob.getState()];
  const tree = await generateTree(TREE_HEIGHT, leafsData);
  const initialRoot = tree.root.toString();

  const msg = mimcSponge.multiHash(
    [...alice.pubKey, ...bob.pubKey, AMOUNT],
    MIMC_KEY,
    NUMBER_OF_OUTPUTS
  );

  const { R8x, R8y, S } = await signMessage(msg, alice.prvKey);

  const aliceProof = tree.proof(tree.elements[0]);

  updateBalanceAndTree(alice, tree);
  const bobProof = tree.proof(tree.elements[1]);

  const witness = {
    initial_rollup_root: initialRoot,

    sender_pk: convertPubKeyToString(alice.pubKey),
    sender_balance: ALICE_INIT_BALANCE.toString(),
    sender_proof_elements: aliceProof.pathElements.toString(),
    sender_proof_pos: aliceProof.pathIndices,

    receiver_pk: convertPubKeyToString(bob.pubKey),
    receiver_balance: bob.balance.toString(),
    receiver_proof_elements: bobProof.pathElements.toString(),
    receiver_proof_pos: bobProof.pathIndices.toString(),

    amount: AMOUNT.toString(),

    sig_R8x: R8x.toString(),
    sig_R8y: R8y.toString(),
    sig_S: S.toString(),
  };

  const outputPath = path.join(__dirname, "..", "input.json");
  fs.writeFileSync(outputPath, JSON.stringify(witness), "utf-8");
}

function createUserObject(prvKey, balance) {
  return {
    prvKey,
    balance,
    pubKey: eddsa.prv2pub(prvKey),

    getState() {
      return [this.pubKey[0], this.pubKey[1], this.balance];
    },
    getLeaf() {
      const res = mimcSponge.multiHash(
        this.getState(),
        MIMC_KEY,
        NUMBER_OF_OUTPUTS
      );

      return mimcSponge.F.toObject(res);
    },
  };
}

function updateBalanceAndTree(sender, tree) {
  sender.balance -= AMOUNT;
  tree.update(0, sender.getLeaf());
}

function convertPubKeyToString(pubKey) {
  return pubKey.map((val) => BigInt(F.toObject(val)).toString());
}

main().catch((e) => {
  console.error(e);
  process.exitCode = 1;
});
