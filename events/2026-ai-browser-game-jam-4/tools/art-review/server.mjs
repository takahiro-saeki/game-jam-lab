import { createServer } from "node:http";
import { readFile, writeFile } from "node:fs/promises";
import { extname, resolve, dirname, sep } from "node:path";
import { fileURLToPath } from "node:url";

const toolRoot = dirname(fileURLToPath(import.meta.url));
const eventRoot = resolve(toolRoot, "../..");
const publicRoot = resolve(toolRoot, "public");
const dataRoot = resolve(toolRoot, "data");
const manifestPath = resolve(toolRoot, "data/review-manifest.json");
const assetRoot = resolve(eventRoot, "godot/assets/charge_clicker/pixellab");
const gameBuildRoot = resolve(eventRoot, "build/web");
const port = Number(process.env.ART_REVIEW_PORT || 6670);

const mime = {
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".png": "image/png",
  ".webp": "image/webp",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
};

function send(response, status, body, contentType = "text/plain; charset=utf-8") {
  response.writeHead(status, {
    "Content-Type": contentType,
    "Cache-Control": "no-store",
    "X-Content-Type-Options": "nosniff",
  });
  response.end(body);
}

function safePath(root, pathname) {
  const decoded = decodeURIComponent(pathname).replace(/^\/+/, "");
  const target = resolve(root, decoded);
  if (target !== root && !target.startsWith(`${root}${sep}`)) return null;
  return target;
}

async function readManifest() {
  return JSON.parse(await readFile(manifestPath, "utf8"));
}

async function writeManifest(manifest) {
  manifest.updatedAt = new Date().toISOString();
  await writeFile(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`, "utf8");
}

async function readJsonBody(request) {
  const chunks = [];
  let size = 0;
  for await (const chunk of request) {
    size += chunk.length;
    if (size > 256 * 1024) throw new Error("Request body is too large");
    chunks.push(chunk);
  }
  return JSON.parse(Buffer.concat(chunks).toString("utf8"));
}

async function updateReview(request, response) {
  const body = await readJsonBody(request);
  const allowedStatuses = new Set(["unreviewed", "approved", "hold", "rejected"]);
  if (typeof body.candidateId !== "string" || !allowedStatuses.has(body.status)) {
    send(response, 400, JSON.stringify({ error: "Invalid review" }), mime[".json"]);
    return;
  }

  const manifest = await readManifest();
  const candidate = manifest.batches
    .flatMap((batch) => batch.candidates)
    .find((item) => item.id === body.candidateId);
  if (!candidate) {
    send(response, 404, JSON.stringify({ error: "Candidate not found" }), mime[".json"]);
    return;
  }

  candidate.humanReview = {
    status: body.status,
    rating: Number.isInteger(body.rating) && body.rating >= 1 && body.rating <= 5
      ? body.rating
      : null,
    note: typeof body.note === "string" ? body.note.trim().slice(0, 2000) : "",
    reviewedAt: new Date().toISOString(),
  };
  await writeManifest(manifest);
  send(response, 200, JSON.stringify({ ok: true, humanReview: candidate.humanReview }), mime[".json"]);
}

const server = createServer(async (request, response) => {
  try {
    const url = new URL(request.url || "/", `http://${request.headers.host || "localhost"}`);

    if (request.method === "GET" && url.pathname === "/api/manifest") {
      send(response, 200, await readFile(manifestPath), mime[".json"]);
      return;
    }
    if (request.method === "POST" && url.pathname === "/api/review") {
      await updateReview(request, response);
      return;
    }
    if (request.method !== "GET") {
      send(response, 405, "Method Not Allowed");
      return;
    }

    let filePath;
    if (url.pathname.startsWith("/assets/")) {
      filePath = safePath(assetRoot, url.pathname.slice("/assets/".length));
    } else if (url.pathname.startsWith("/review-data/")) {
      filePath = safePath(dataRoot, url.pathname.slice("/review-data/".length));
    } else if (url.pathname.startsWith("/game/")) {
      const requested = url.pathname === "/game/" ? "index.html" : url.pathname.slice("/game/".length);
      filePath = safePath(gameBuildRoot, requested);
    } else {
      const requested = url.pathname === "/" ? "index.html" : url.pathname;
      filePath = safePath(publicRoot, requested);
    }
    if (!filePath) {
      send(response, 403, "Forbidden");
      return;
    }

    const content = await readFile(filePath);
    send(response, 200, content, mime[extname(filePath).toLowerCase()] || "application/octet-stream");
  } catch (error) {
    const status = error?.code === "ENOENT" ? 404 : 500;
    send(response, status, status === 404 ? "Not Found" : `Server error: ${error.message}`);
  }
});

server.listen(port, "127.0.0.1", () => {
  console.log(`VOLT NOMAD Art Review: http://127.0.0.1:${port}`);
});
