import esbuild from "esbuild"
import path from "path";
import { fileURLToPath } from 'url';
import { cpSync, mkdirSync, rmSync, writeFileSync } from "fs"

rmSync("dist", { recursive: true, force: true })
mkdirSync("dist")

writeFileSync("dist/package.json", JSON.stringify({ main: "main.js" }))
cpSync("src/index.html", "dist/index.html")

function build(opts) {
  esbuild.build(opts).then((result) => {
    if (result.errors.length > 0) {
      console.error(result.errors);
    }
    if (result.warnings.length > 0) {
      console.error(result.warnings);
    }
  });
}

const outdir = path.join(path.dirname(fileURLToPath(import.meta.url)), 'dist');

build({
  entryPoints: ['src/main.mjs'],
  bundle: true,
  sourcemap: false,
  platform: 'node',
  target: 'node16.15',
  outdir: 'dist',
  external: ['electron'],
})

build({
  entryPoints: ['src/preload.mjs'],
  bundle: true,
  sourcemap: false,
  outdir: 'dist',
  external: ['electron'],
})

build({
  entryPoints: ['src/renderer.mjs'],
  bundle: true,
  sourcemap: false,
  outdir: 'dist',
})
