#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";

const PNG_SIGNATURE = Buffer.from([
  0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a,
]);

function buildCrcTable() {
  const table = new Uint32Array(256);
  for (let n = 0; n < 256; n += 1) {
    let value = n;
    for (let k = 0; k < 8; k += 1) {
      value = (value & 1) !== 0
        ? (0xedb88320 ^ (value >>> 1))
        : (value >>> 1);
    }
    table[n] = value >>> 0;
  }
  return table;
}

const CRC_TABLE = buildCrcTable();

function crc32(buffer) {
  let crc = 0xffffffff;
  for (const byte of buffer) {
    crc = CRC_TABLE[(crc ^ byte) & 0xff] ^ (crc >>> 8);
  }
  return (crc ^ 0xffffffff) >>> 0;
}

function makeChunk(type, payload) {
  const typeBuffer = Buffer.from(type, "ascii");
  const result = Buffer.alloc(12 + payload.length);
  result.writeUInt32BE(payload.length, 0);
  typeBuffer.copy(result, 4);
  payload.copy(result, 8);
  result.writeUInt32BE(crc32(Buffer.concat([typeBuffer, payload])), 8 + payload.length);
  return result;
}

function rewriteGrab(filePath, x, y) {
  const input = fs.readFileSync(filePath);
  if (input.length < 20 || !input.subarray(0, 8).equals(PNG_SIGNATURE)) {
    throw new Error(`${filePath}: no es un PNG válido`);
  }

  const chunks = [];
  let cursor = 8;
  while (cursor < input.length) {
    const length = input.readUInt32BE(cursor);
    const end = cursor + 12 + length;
    if (end > input.length) {
      throw new Error(`${filePath}: chunk PNG truncado`);
    }
    const type = input.toString("ascii", cursor + 4, cursor + 8);
    if (type !== "grAb") {
      chunks.push(input.subarray(cursor, end));
    }
    cursor = end;
  }

  if (chunks.length === 0 || chunks[0].toString("ascii", 4, 8) !== "IHDR") {
    throw new Error(`${filePath}: falta IHDR`);
  }

  const payload = Buffer.alloc(8);
  payload.writeInt32BE(x, 0);
  payload.writeInt32BE(y, 4);
  const output = Buffer.concat([
    PNG_SIGNATURE,
    chunks[0],
    makeChunk("grAb", payload),
    ...chunks.slice(1),
  ]);

  const temporaryPath = `${filePath}.grab-tmp`;
  fs.writeFileSync(temporaryPath, output);
  fs.renameSync(temporaryPath, filePath);
}

if (process.argv.length < 5) {
  console.error(`Uso: ${path.basename(process.argv[1])} X Y PNG [PNG ...]`);
  process.exit(2);
}

const x = Number.parseInt(process.argv[2], 10);
const y = Number.parseInt(process.argv[3], 10);
if (!Number.isInteger(x) || !Number.isInteger(y)) {
  throw new Error("X e Y deben ser enteros");
}

for (const filePath of process.argv.slice(4)) {
  rewriteGrab(filePath, x, y);
}
