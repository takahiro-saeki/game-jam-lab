import { readFile, writeFile } from "node:fs/promises";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const scriptsRoot = dirname(fileURLToPath(import.meta.url));
const manifestPath = resolve(scriptsRoot, "../data/review-manifest.json");

const palettePrompt = "limited palette matching deep navy #09111F #111D31 #182B43, charge cyan #4DEEEA, restrained amber #FFB703, danger coral #FF5C5C, and warm highlight #F5F0DB";
const finishPrompt = `premium authored 16-bit pixel art UI component, front-facing orthographic view, crisp large pixel clusters, hard chamfered silhouette, practical mechanical construction, ${palettePrompt}, transparent background, no scenery, no characters, no readable text, no letters, no numbers, no symbols, no logo, no watermark, no blur, no antialiasing, no generic mobile-game card, no soft rounded rectangle, no glossy gradient`;

function candidate({ id, title, titleJa, variation, description, width, height, file }) {
  return {
    id,
    title,
    titleJa,
    variation,
    prompt: `${description}, ${finishPrompt}.`,
    model: "pixen",
    width,
    height,
    noBackground: true,
    detail: "medium detail",
    view: null,
    direction: null,
    seed: null,
    file,
    generation: {
      status: "planned",
      generatedAt: null,
      usage: null,
      error: null,
    },
    codexReview: {
      status: "planned",
      rank: null,
      score: null,
      summary: "生成後に、実寸の読みやすさ・構造の正確さ・既存UIとの接続性を評価します。",
      strengths: [],
      concerns: [],
    },
    humanReview: {
      status: "unreviewed",
      rating: null,
      note: "",
      reviewedAt: null,
    },
  };
}

const batches = [
  {
    id: "phase2-upgrade-rack",
    order: 9,
    title: "Eight-module upgrade rack",
    titleJa: "8モジュール・アップグレードラック",
    objective: "同じ丸角カード8枚を、ゲーム世界に存在する一体型の機械ラックへ置き換える。文字・数値・個別アイコンはGodotで重ねる。",
    gate: "4×2の8ソケットが正確に読め、各ソケットの暗い余白へ日本語2行とアイコンを重ねられる案を選ぶ。",
    status: "generating",
    candidates: [
      candidate({
        id: "upgrade-rack-switchboard-a",
        title: "Maintenance Switchboard",
        titleJa: "重工業メンテナンス盤",
        variation: "Direction A — the recommended normal-game identity: bolted rails, bus lines, and service-bay asymmetry.",
        description: "One single wide industrial upgrade backplate built as exactly eight empty module sockets arranged four across and two rows, thick bolted navy steel outer rails, angular maintenance cutouts, dark quiet socket interiors, a continuous cyan electrical bus connecting all sockets, six tiny amber service lamps at most, deliberately asymmetric wear and repair plates, every socket clearly separated and large enough for later icon and Japanese label overlays",
        width: 384,
        height: 128,
        file: "source/ui/upgrade-rack-switchboard-a.png",
      }),
      candidate({
        id: "upgrade-rack-ceramic-a",
        title: "High-voltage Ceramic Rack",
        titleJa: "高圧セラミック実験盤",
        variation: "Direction B — a cleaner scientific identity with porcelain insulators and graphite bus rails.",
        description: "One single wide high-voltage laboratory upgrade backplate built as exactly eight empty module sockets arranged four across and two rows, graphite metal bus rails, warm ivory ceramic insulator corners, dark navy recessed socket interiors, precise cyan terminal contacts, sparse amber measurement diodes, clean engineered spacing with subtle handmade irregularities, every socket clearly separated and large enough for later icon and Japanese label overlays",
        width: 384,
        height: 128,
        file: "source/ui/upgrade-rack-ceramic-a.png",
      }),
      candidate({
        id: "upgrade-rack-corrupted-a",
        title: "Corrupted Conduit Rack",
        titleJa: "侵食コンジット盤",
        variation: "Direction C — a damaged late-game identity with restrained red fractures and repaired power paths.",
        description: "One single wide damaged power-station upgrade backplate built as exactly eight empty module sockets arranged four across and two rows, broken dark conduits repaired with cyan bypass cables, restrained coral electrical fractures creeping across the outer frame, a few mismatched steel patches and bolts, socket interiors remain calm and unobstructed, dangerous but still functional, every socket clearly separated and large enough for later icon and Japanese label overlays",
        width: 384,
        height: 128,
        file: "source/ui/upgrade-rack-corrupted-a.png",
      }),
    ],
  },
  {
    id: "phase2-control-console-kit",
    order: 10,
    title: "CHARGE / DISCHARGE / AUTO console kit",
    titleJa: "主操作・制御盤フレームセット",
    objective: "CHARGE・DISCHARGE・AUTOを同じ丸角カードから分離し、それぞれ操作原理が異なる三つの機械として成立させる。",
    gate: "1枚の中に接触しない3筐体が正確に分かれ、左＝充電、中央＝放電、右＝自動化の異なる輪郭をGodotで切り出せる案を選ぶ。",
    status: "generating",
    candidates: [
      candidate({
        id: "control-kit-switchboard-a",
        title: "Switchboard Control Family",
        titleJa: "重工業スイッチボード系",
        variation: "Direction A — three visibly related but role-specific maintenance controls.",
        description: "A coherent pixel-art asset kit containing exactly three separate empty industrial control housings arranged left to right in one horizontal row with generous transparent gaps and no touching parts: first a tall heavy CHARGE plunger housing with vertical detents and a recessed icon well, second a much wider DISCHARGE bus housing with exactly six output contact slots and a recessed icon well, third a compact AUTO relay housing with a mechanical lock notch and recessed icon well, all three share bolted navy steel and cyan wiring but have unmistakably different silhouettes",
        width: 384,
        height: 128,
        file: "source/ui/control-kit-switchboard-a.png",
      }),
      candidate({
        id: "control-kit-ceramic-a",
        title: "Ceramic Laboratory Controls",
        titleJa: "高圧セラミック操作系",
        variation: "Direction B — porcelain-insulated scientific controls with less neon and more material contrast.",
        description: "A coherent pixel-art asset kit containing exactly three separate empty high-voltage laboratory control housings arranged left to right in one horizontal row with generous transparent gaps and no touching parts: first a tall CHARGE compression chamber framed by ivory ceramic insulators, second a much wider DISCHARGE manifold with exactly six graphite terminals, third a compact AUTO latching relay with a circular rotor recess, shared dark navy metal and restrained cyan contacts, all three have clearly different engineered silhouettes",
        width: 384,
        height: 128,
        file: "source/ui/control-kit-ceramic-a.png",
      }),
      candidate({
        id: "control-kit-corrupted-a",
        title: "Emergency Bypass Controls",
        titleJa: "侵食・緊急バイパス操作系",
        variation: "Direction C — repaired emergency controls suitable for boss and true-route states.",
        description: "A coherent pixel-art asset kit containing exactly three separate empty damaged power-station control housings arranged left to right in one horizontal row with generous transparent gaps and no touching parts: first a tall CHARGE housing reinforced by a cyan bypass coil, second a much wider DISCHARGE breaker manifold with exactly six output contacts and restrained coral fractures, third a compact AUTO relay clamped by an emergency lock, mismatched repair plates and exposed cables, all three remain readable and have unmistakably different silhouettes",
        width: 384,
        height: 128,
        file: "source/ui/control-kit-corrupted-a.png",
      }),
    ],
  },
  {
    id: "phase2-wraith-gauge",
    order: 11,
    title: "GRID WRAITH segmented siphon gauge",
    titleJa: "GRID WRAITH・6分割侵食ゲージ",
    objective: "一般的な丸いHPバーを廃止し、6セルと直接関係する送電管・侵食装置としてボス耐久値を見せる。",
    gate: "空の6セグメントが一目で数えられ、左の敵アンカーと各セルへの警告演出をGodotで追加できる案を選ぶ。",
    status: "generating",
    candidates: [
      candidate({
        id: "wraith-gauge-switchboard-a",
        title: "Siphon Bus Spine",
        titleJa: "吸収バス・スパイン",
        variation: "Direction A — a boss-linked industrial bus that physically breaks segment by segment.",
        description: "One long horizontal empty boss integrity gauge housing designed as an industrial siphon bus, exactly six clearly separated dark meter chambers connected by thick navy conduit vertebrae, one larger mechanical anchor socket on the far left for a creature portrait overlay, cyan current inlet details and restrained coral warning clamps, empty transparent meter interiors ready for procedural fill and break effects",
        width: 320,
        height: 80,
        file: "source/ui/wraith-gauge-switchboard-a.png",
      }),
      candidate({
        id: "wraith-gauge-ceramic-a",
        title: "Insulator Test Spine",
        titleJa: "絶縁試験スパイン",
        variation: "Direction B — six porcelain-isolated chambers that read as dangerous laboratory containment.",
        description: "One long horizontal empty boss integrity gauge housing designed as a high-voltage test spine, exactly six clearly separated dark glass meter chambers divided by warm ivory ceramic insulators and graphite rails, one larger circular specimen anchor on the far left for a creature portrait overlay, sparse cyan terminals and tiny coral overload contacts, empty transparent meter interiors ready for procedural fill",
        width: 320,
        height: 80,
        file: "source/ui/wraith-gauge-ceramic-a.png",
      }),
      candidate({
        id: "wraith-gauge-corrupted-a",
        title: "Corruption Siphon Vein",
        titleJa: "侵食吸収ヴェイン",
        variation: "Direction C — a semi-organic broken conduit whose red corruption retreats under damage.",
        description: "One long horizontal empty boss integrity gauge housing designed as a corrupted machine conduit, exactly six clearly separated dark meter chambers held by broken navy armor, one predatory cable anchor on the far left for a creature portrait overlay, restrained coral fractures and hooked siphon wires flowing through the frame with cyan repair staples, empty transparent meter interiors ready for procedural corruption fill and segment shattering",
        width: 320,
        height: 80,
        file: "source/ui/wraith-gauge-corrupted-a.png",
      }),
      candidate({
        id: "wraith-gauge-switchboard-b",
        title: "Six Breaker Seals",
        titleJa: "六連ブレーカーシール",
        variation: "Focused A revision — remove the central hub and reduce the structure to six large breakable seals.",
        description: "Exactly six and only six large identical empty industrial breaker frames placed in one perfectly straight horizontal row, equal spacing, each frame is a simple dark square chamber with chamfered corners and one thick cyan terminal underneath, the six frames are connected by one thin navy cable, no central hub, no end cap, no extra small compartments, no internal markings, no meter fill, designed to break one frame at a time",
        width: 320,
        height: 80,
        file: "source/ui/wraith-gauge-switchboard-b.png",
      }),
      candidate({
        id: "wraith-gauge-ceramic-b",
        title: "Six Insulator Chambers",
        titleJa: "六連絶縁チャンバー",
        variation: "Focused B revision — six large isolated chambers, with no portrait anchor or decorative subdivisions.",
        description: "Exactly six and only six large identical empty high-voltage chamber frames placed in one perfectly straight horizontal row, equal spacing, every chamber has a dark square empty center and four warm ivory ceramic corner clamps, the six chambers are linked by one thin graphite rail with tiny cyan contacts, no circular hub, no end cap, no extra small compartments, no internal markings, no meter fill",
        width: 320,
        height: 80,
        file: "source/ui/wraith-gauge-ceramic-b.png",
      }),
      candidate({
        id: "wraith-gauge-corrupted-b",
        title: "Six Fracture Cells",
        titleJa: "六連侵食セル",
        variation: "Focused C revision — six readable armored cells with corruption confined to the outer cable.",
        description: "Exactly six and only six large identical empty damaged machine frames placed in one perfectly straight horizontal row, equal spacing, every frame has a calm dark square empty center and thick chipped navy armor, one restrained coral fracture cable snakes behind the six frames and is stapled by cyan repair clamps, no central hub, no end cap, no extra small compartments, no internal markings, no meter fill",
        width: 320,
        height: 80,
        file: "source/ui/wraith-gauge-corrupted-b.png",
      }),
    ],
  },
  {
    id: "phase2-shard-accumulator",
    order: 12,
    title: "Energy shard accumulator",
    titleJa: "エネルギー片・蓄積カウンター",
    objective: "小さなアイコンと数字だけの資源表示を、報酬粒子が流れ込むゲーム固有の蓄積装置へ変える。",
    gate: "左に32〜40pxのエネルギー片、右に4〜6桁の数値を重ねられ、獲得時の流入アニメーションを想像できる案を選ぶ。",
    status: "generating",
    candidates: [
      candidate({
        id: "shard-accumulator-switchboard-a",
        title: "Shard Hopper Odometer",
        titleJa: "破片ホッパー・積算計",
        variation: "Direction A — a tactile maintenance hopper with an odometer window.",
        description: "One compact horizontal energy-shard accumulator housing, a large open circular receptacle on the left sized for a glowing shard icon overlay, a dark wide mechanical odometer window on the right sized for four to six digits, angular navy steel hopper walls, a short cyan intake conduit, two tiny amber tally lamps, a few bolts and service scratches, all central areas empty for Godot overlays",
        width: 192,
        height: 96,
        file: "source/ui/shard-accumulator-switchboard-a.png",
      }),
      candidate({
        id: "shard-accumulator-ceramic-a",
        title: "Vacuum Charge Counter",
        titleJa: "真空蓄電カウンター",
        variation: "Direction B — a clean lab receptacle with ceramic isolation and a dark numeric tube.",
        description: "One compact horizontal high-voltage energy-shard counter housing, a large round vacuum receptacle on the left framed by warm ivory ceramic insulators for a glowing shard icon overlay, a dark graphite numeric tube window on the right sized for four to six digits, restrained cyan contacts, one small amber measurement diode, engineered laboratory construction with empty centers for Godot overlays",
        width: 192,
        height: 96,
        file: "source/ui/shard-accumulator-ceramic-a.png",
      }),
      candidate({
        id: "shard-accumulator-corrupted-a",
        title: "Unstable Fragment Canister",
        titleJa: "不安定破片キャニスター",
        variation: "Direction C — a repaired containment vessel that flashes under large rewards.",
        description: "One compact horizontal damaged energy-shard accumulator housing, a large cracked circular containment socket on the left sized for a glowing shard icon overlay, a dark reinforced numeric window on the right sized for four to six digits, restrained coral fractures trapped by cyan repair clamps, a short intake cable and mismatched armor plates, dangerous but functional, all central areas empty for Godot overlays",
        width: 192,
        height: 96,
        file: "source/ui/shard-accumulator-corrupted-a.png",
      }),
      candidate({
        id: "shard-accumulator-switchboard-b",
        title: "Blank Shard Intake",
        titleJa: "無表示・破片取入口",
        variation: "Focused A revision — treat the numeric area as a completely blank maintenance plate, not a counter display.",
        description: "One compact horizontal industrial shard-intake housing with two clearly different empty zones, on the left one large open circular mechanical socket for a separate glowing shard sprite, on the right one completely blank flat near-black rectangular maintenance plate for a later Godot text overlay, the blank plate contains absolutely no pixels except a uniform dark fill, angular navy steel edges, cyan intake pipe, two tiny amber bolts outside the blank plate",
        width: 192,
        height: 96,
        file: "source/ui/shard-accumulator-switchboard-b.png",
      }),
      candidate({
        id: "shard-accumulator-ceramic-b",
        title: "Blank Ceramic Intake",
        titleJa: "無表示・絶縁取入口",
        variation: "Focused B revision — one porcelain receptacle and one featureless graphite overlay plate.",
        description: "One compact horizontal high-voltage shard-intake housing with two clearly different empty zones, on the left one large open round socket held by four warm ivory ceramic insulators for a separate glowing shard sprite, on the right one completely blank flat near-black graphite plate for a later Godot text overlay, the blank plate contains absolutely no pixels except a uniform dark fill, restrained cyan terminals and one amber bolt outside the blank plate",
        width: 192,
        height: 96,
        file: "source/ui/shard-accumulator-ceramic-b.png",
      }),
      candidate({
        id: "shard-accumulator-corrupted-b",
        title: "Blank Containment Intake",
        titleJa: "無表示・封じ込め取入口",
        variation: "Focused C revision — damaged outer containment with a calm, perfectly blank value plate.",
        description: "One compact horizontal damaged shard-intake housing with two clearly different empty zones, on the left one large cracked circular containment socket for a separate glowing shard sprite, on the right one completely blank flat near-black reinforced plate for a later Godot text overlay, the blank plate contains absolutely no pixels except a uniform dark fill, restrained coral fractures remain only on the outer navy armor and are held by cyan repair clamps",
        width: 192,
        height: 96,
        file: "source/ui/shard-accumulator-corrupted-b.png",
      }),
    ],
  },
];

const manifest = JSON.parse(await readFile(manifestPath, "utf8"));
for (const batch of batches) {
  const existingIndex = manifest.batches.findIndex((item) => item.id === batch.id);
  if (existingIndex >= 0) {
    const existing = manifest.batches[existingIndex];
    const previousCandidates = new Map(existing.candidates.map((item) => [item.id, item]));
    batch.candidates = batch.candidates.map((item) => {
      const previous = previousCandidates.get(item.id);
      if (!previous) return item;
      return {
        ...item,
        generation: previous.generation,
        codexReview: previous.codexReview,
        humanReview: previous.humanReview,
      };
    });
    manifest.batches[existingIndex] = batch;
  } else {
    manifest.batches.push(batch);
  }
}
manifest.batches.sort((a, b) => a.order - b.order);
manifest.updatedAt = new Date().toISOString();
await writeFile(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`, "utf8");
console.log(`Synced ${batches.length} UI identity batches (${batches.reduce((sum, batch) => sum + batch.candidates.length, 0)} candidates).`);
