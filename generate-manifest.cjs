const fs = require("fs");
const path = require("path");

const distDir = path.join(__dirname, "dist");
const outFile = path.join(distDir, "precache-manifest.json");

function walk(dir, base = "") {
  let results = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const rel = path.posix.join(base, entry.name);
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      results = results.concat(walk(full, rel));
    } else {
      results.push("./" + rel);
    }
  }
  return results;
}

const files = walk(distDir).filter(f => f !== "./precache-manifest.json");
fs.writeFileSync(outFile, JSON.stringify(files));
console.log(`Wrote ${files.length} entries to precache-manifest.json`);
