const { buildEddsa, buildBabyjub } = require("circomlibjs");

async function signMessage(msg, prvKey) {
  const babyJub = await buildBabyjub();
  const F = babyJub.F;
  const eddsa = await buildEddsa();

  msg = babyJub.F.e(msg);
  const pubKey = eddsa.prv2pub(prvKey);

  const signature = eddsa.signMiMC(prvKey, msg);
  if (!eddsa.verifyMiMC(msg, signature, pubKey)) {
    throw new Error("Signature can't be validated");
  }

  return {
    Ax: F.toObject(pubKey[0]),
    Ay: F.toObject(pubKey[1]),
    R8x: F.toObject(signature.R8[0]),
    R8y: F.toObject(signature.R8[1]),
    S: signature.S,
    M: F.toObject(msg),
  };
}

module.exports = { signMessage };
