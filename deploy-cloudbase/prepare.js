// 把云版静态资源复制到 site/，供 CloudBase CLI 部署。
// 用法：node prepare.js
const fs = require("fs");
const path = require("path");

const src = path.resolve(__dirname, "..");
const dest = path.resolve(__dirname, "site");
const files = [
  "index.html",
  "manifest.json",
  "sw.js",
  "icon-192.png",
  "icon-512.png",
  "icon-maskable-512.png"
];

fs.rmSync(dest, { recursive: true, force: true });
fs.mkdirSync(dest, { recursive: true });
files.forEach(f => {
  const p = path.join(src, f);
  if (fs.existsSync(p)) fs.copyFileSync(p, path.join(dest, f));
  else console.warn("MISSING " + f);
});
console.log("Prepared " + dest + " (" + files.length + " entries checked)");
