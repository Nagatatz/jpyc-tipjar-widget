import assert from "node:assert/strict";
import { test } from "node:test";
import { buildJpycTransferUri } from "../src/domain/PaymentUri.res.js";
import { fromYen, toBigint, toDisplay } from "../src/domain/TipAmount.res.js";

// Exact pinned public contract, not a wallet or a real recipient.
const target = "0xE7C3D8C9a439feDe00D2600032D5dB0Be71C3c29";
const scale = 10n ** 18n;

test("generated amounts round-trip through the Polygon EIP-681 URI without rounding", () => {
  const seed = 0x5252;
  let state = seed;
  const amounts = [0, 1, 100, 500, 1000, 2 ** 31 - 1];
  for (let i = 0; i < 256; i++) {
    state = (Math.imul(state, 1664525) + 1013904223) >>> 0;
    amounts.push(state & 0x7fffffff);
  }

  for (const [i, amount] of amounts.entries()) {
    const recipient = `0x${(i + 1).toString(16).padStart(40, "0")}`;
    const value = fromYen(amount);
    const expected = BigInt(amount) * scale;
    const base = `ethereum:${target}@137/transfer?address=${recipient}`;
    const context = `seed=${seed} amount=${amount}`;
    assert.equal(toBigint(value), expected, context);
    assert.equal(toDisplay(value), String(amount), context);
    assert.equal(buildJpycTransferUri(recipient, value), `${base}&uint256=${expected}`, context);
    assert.equal(buildJpycTransferUri(recipient, undefined), base, context);
  }
});

test("empty recipient never produces a sendable URI", () => {
  assert.equal(buildJpycTransferUri("", undefined), "");
  assert.equal(buildJpycTransferUri("", fromYen(100)), "");
});
