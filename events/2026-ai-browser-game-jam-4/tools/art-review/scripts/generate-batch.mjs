import { mkdir, readFile, writeFile } from "node:fs/promises";
import { resolve, dirname, sep } from "node:path";
import { fileURLToPath } from "node:url";

const scriptsRoot = dirname(fileURLToPath(import.meta.url));
const toolRoot = resolve(scriptsRoot, "..");
const eventRoot = resolve(toolRoot, "../..");
const manifestPath = resolve(toolRoot, "data/review-manifest.json");
const assetRoot = resolve(eventRoot, "godot/assets/charge_clicker/pixellab");
const apiBase = "https://api.pixellab.ai/v2";

const args = process.argv.slice(2);
const valueAfter = (flag) => {
  const index = args.indexOf(flag);
  return index >= 0 ? args[index + 1] : undefined;
};
const batchId = valueAfter("--batch");
const dryRun = args.includes("--dry-run");
const force = args.includes("--force");

if (!batchId) {
  console.error("Usage: node scripts/generate-batch.mjs --batch <id> [--dry-run] [--force]");
  process.exit(2);
}

function safeOutputPath(relativePath) {
  const target = resolve(assetRoot, relativePath);
  if (target !== assetRoot && !target.startsWith(`${assetRoot}${sep}`)) {
    throw new Error(`Unsafe output path: ${relativePath}`);
  }
  return target;
}

async function saveManifest(manifest) {
  manifest.updatedAt = new Date().toISOString();
  await writeFile(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`, "utf8");
}

const manifest = JSON.parse(await readFile(manifestPath, "utf8"));
const batch = manifest.batches.find((item) => item.id === batchId);
if (!batch) {
  console.error(`Unknown batch: ${batchId}`);
  process.exit(2);
}

const pending = batch.candidates.filter((candidate) => force || candidate.generation.status !== "generated");
if (pending.length === 0) {
  console.log(`${batch.title}: all candidates are already generated`);
  process.exit(0);
}

console.log(`${batch.title}: ${pending.length} candidate(s)`);
for (const candidate of pending) {
  console.log(`- ${candidate.id}: ${candidate.title} (${candidate.width}x${candidate.height}, ${candidate.model})`);
}
if (dryRun) process.exit(0);

const secret = process.env.PIXELLAB_SECRET;
if (!secret) {
  console.error("PIXELLAB_SECRET is not configured. Pass it through the environment or Node --env-file.");
  process.exit(2);
}

for (const candidate of pending) {
  const endpoint = candidate.model === "pixflux" ? "create-image-pixflux" : "create-image-pixen";
  candidate.generation = { ...candidate.generation, status: "generating", error: null };
  await saveManifest(manifest);
  console.log(`Generating ${candidate.id}...`);

  try {
    const response = await fetch(`${apiBase}/${endpoint}`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${secret}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        description: candidate.prompt,
        image_size: { width: candidate.width, height: candidate.height },
        no_background: candidate.noBackground,
        detail: candidate.detail,
        ...(candidate.view ? { view: candidate.view } : {}),
        ...(candidate.direction ? { direction: candidate.direction } : {}),
        ...(candidate.seed !== null && candidate.seed !== undefined ? { seed: candidate.seed } : {}),
      }),
    });
    if (!response.ok) {
      throw new Error(`PixelLab API ${response.status}: ${(await response.text()).slice(0, 500)}`);
    }

    const result = await response.json();
    const png = Buffer.from(result.image?.base64 || "", "base64");
    if (png.length < 8 || png.subarray(0, 4).toString("hex") !== "89504e47") {
      throw new Error("PixelLab response did not contain a valid PNG");
    }

    const output = safeOutputPath(candidate.file);
    await mkdir(dirname(output), { recursive: true });
    await writeFile(output, png);
    candidate.generation = {
      status: "generated",
      generatedAt: new Date().toISOString(),
      usage: result.usage ?? null,
      error: null,
    };
    console.log(`Saved ${candidate.file}`);
  } catch (error) {
    candidate.generation = {
      ...candidate.generation,
      status: "failed",
      error: String(error.message || error).slice(0, 1000),
    };
    console.error(`Failed ${candidate.id}: ${candidate.generation.error}`);
  }
  await saveManifest(manifest);
}
