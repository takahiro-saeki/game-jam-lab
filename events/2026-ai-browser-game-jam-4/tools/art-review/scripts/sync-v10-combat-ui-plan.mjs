import { readFile, writeFile } from "node:fs/promises";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const scriptsRoot = dirname(fileURLToPath(import.meta.url));
const manifestPath = resolve(scriptsRoot, "../data/review-manifest.json");

const finish = "Premium authored 16-bit pixel art game asset, crisp deliberate pixel clusters, hard one-to-two pixel outline, deep navy #09111F #111D31 #182B43, electric cyan #4DEEEA, restrained violet #9B5DE5, amber #FFB703, coral #FF5C5C and warm ivory #F5F0DB, isolated complete object on transparent background, no ground, no scenery, no text, no letters, no numbers, no logo, no watermark, no blur, no antialiasing, no glossy mobile-game style, no resemblance to an existing franchise";

function candidate({ id, title, titleJa, variation, description, width, height, file }) {
  return {
    id,
    title,
    titleJa,
    variation,
    prompt: `${description}. ${finish}.`,
    model: "pixen",
    width,
    height,
    noBackground: true,
    detail: "highly detailed",
    view: null,
    direction: null,
    seed: null,
    file,
    generation: { status: "planned", generatedAt: null, usage: null, error: null },
    codexReview: {
      status: "pending",
      rank: null,
      score: null,
      summary: "生成後にゲーム内縮小表示と透明度を確認して選定する。",
      strengths: [],
      concerns: [],
    },
    humanReview: { status: "unreviewed", rating: null, note: "", reviewedAt: null },
  };
}

const batch = {
  id: "v10-auto-vfx-overlimit-ui",
  order: 29,
  title: "AUTO weapon VFX and OVERLIMIT restoration UI",
  titleJa: "AUTO攻撃演出・OVERLIMIT復旧UI",
  objective: "細い線と点だけのAUTO射撃を明確な武器攻撃へ変え、最終強化を通常ノードではなく恒久機構の復旧として視覚化する。",
  gate: "AUTO弾は72×28px前後のゲーム表示で進行方向と威力が読める。復旧ソケットは216×72px表示で中央に日本語と費用を重ねても輪郭が残り、偽文字を含まない。",
  status: "ready",
  candidates: [
    candidate({
      id: "auto-vfx-arc-lance-v10-a",
      title: "Arc Lance Packet",
      titleJa: "弧光槍弾",
      variation: "標準AUTO砲向け。電磁槍と圧縮環が一発の攻撃として明瞭。",
      description: "One single horizontal automatic-cannon projectile effect traveling strictly from left to right, an elongated cyan-white plasma lance with a sharp ivory leading tip, two small mechanical compression rings, a compact violet ion tail and sparse amber ignition pixels, strong readable forward motion, the entire projectile fully contained with generous transparent space, no gun, no target, no explosion",
      width: 192,
      height: 96,
      file: "source/vfx/auto-vfx-arc-lance-v10-a.png",
    }),
    candidate({
      id: "auto-vfx-gatling-packet-v10-b",
      title: "Gatling Burst Packet",
      titleJa: "連装徹甲弾群",
      variation: "GATLING向け。三発を一まとまりにして連射力を表現。",
      description: "Exactly three small horizontal automatic-cannon penetrator rounds traveling left to right in a tight staggered formation, each with an amber-hot core, navy mechanical jacket and short cyan electrical wake, together reading as one rapid-fire burst packet, all three projectiles fully contained and clearly separated, generous transparent margin, no gun, no target, no explosion, no additional bullets",
      width: 192,
      height: 96,
      file: "source/vfx/auto-vfx-gatling-packet-v10-b.png",
    }),
    candidate({
      id: "auto-vfx-horizon-spike-v10-c",
      title: "Event-Horizon Spike",
      titleJa: "事象地平穿孔弾",
      variation: "RAIL・終盤向け。黒い針と空間破断環で高出力を表現。",
      description: "One single horizontal endgame rail-cannon projectile traveling strictly left to right, a long thin near-black singularity spike with an ivory-cyan cutting edge, broken violet gravitational rings around its middle, cyan distortion pixels pulled into the tail and one restrained coral warning spark, elegant and dangerous rather than a generic laser, fully contained with transparent margin, no gun, no target, no explosion",
      width: 192,
      height: 96,
      file: "source/vfx/auto-vfx-horizon-spike-v10-c.png",
    }),
    candidate({
      id: "overlimit-socket-five-bus-v10-a",
      title: "Five-Bus Restoration Socket",
      titleJa: "五系統復旧ソケット",
      variation: "既存スイッチボード系。5ギアの接続と恒久復旧が読みやすい。",
      description: "One wide empty OVERLIMIT restoration node housing for a skill tree, heavy asymmetrical navy switchboard metal with exactly five small differently colored conduit terminals feeding a large calm dark central inscription area, a broken safety seal on one corner and cyan repaired wiring, designed as an empty frame with no embedded icon or writing, fully contained orthographic front view",
      width: 256,
      height: 128,
      file: "source/ui/overlimit-socket-five-bus-v10-a.png",
    }),
    candidate({
      id: "overlimit-socket-black-sun-v10-b",
      title: "Black-Sun Relay",
      titleJa: "黒陽継電環",
      variation: "真ボス系。日蝕環の中央へ情報を重ねる静かな構成。",
      description: "One wide empty OVERLIMIT restoration node housing shaped as a broken black-sun relay, a thin incomplete antique-gold eclipse ring behind a dark rectangular information cavity, exactly five restrained colored contact jewels around the outer rim, two cyan current bridges and hard navy mounting brackets, no filled center, no embedded icon, fully contained orthographic front view",
      width: 256,
      height: 128,
      file: "source/ui/overlimit-socket-black-sun-v10-b.png",
    }),
    candidate({
      id: "overlimit-socket-seraph-lock-v10-c",
      title: "Seraph Lock",
      titleJa: "機天封印器",
      variation: "闇堕機天使系。六翼クランプで最終段階らしさを最大化。",
      description: "One wide empty OVERLIMIT restoration node housing designed as a mechanical-seraph seal, six slim asymmetric wing-like conductor clamps folding toward a quiet dark central information plate, an inverted cyan-violet halo behind the plate, five small colored core contacts integrated into the clamps, premium restrained final-tier machinery, no character, no filled center, no embedded icon, fully contained orthographic front view",
      width: 256,
      height: 128,
      file: "source/ui/overlimit-socket-seraph-lock-v10-c.png",
    }),
  ],
};

const manifest = JSON.parse(await readFile(manifestPath, "utf8"));
const existingIndex = manifest.batches.findIndex((item) => item.id === batch.id);
if (existingIndex >= 0) {
  const previous = manifest.batches[existingIndex];
  batch.candidates = batch.candidates.map((item) => {
    const old = previous.candidates.find((candidateItem) => candidateItem.id === item.id);
    if (!old) return item;
    return { ...item, generation: old.generation, codexReview: old.codexReview, humanReview: old.humanReview };
  });
  manifest.batches[existingIndex] = batch;
} else {
  manifest.batches.push(batch);
}
manifest.batches.sort((a, b) => a.order - b.order);
manifest.updatedAt = new Date().toISOString();
await writeFile(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`, "utf8");
console.log(`Synced ${batch.id} (${batch.candidates.length} candidates).`);
