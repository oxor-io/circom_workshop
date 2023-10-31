const { MerkleTree } = require("fixed-merkle-tree");
const { buildMimcSponge } = require("circomlibjs");

async function generateTree(levels, leafData) {
  const mimcSponge = await buildMimcSponge();

  function hashFn(l, r) {
    const res = mimcSponge.multiHash([l, r], 1, 1); // elements, key, number of outputs
    return mimcSponge.F.toObject(res);
  }

  const leaves = leafData.map((val) => {
    const res = mimcSponge.multiHash(val, 1, 1);
    return mimcSponge.F.toObject(res);
  });

  const tree = new MerkleTree(levels, leaves, { hashFunction: hashFn });

  return tree;
}

module.exports = { generateTree };
