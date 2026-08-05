import { readFile, writeFile } from "node:fs/promises";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const scriptsRoot = dirname(fileURLToPath(import.meta.url));
const manifestPath = resolve(scriptsRoot, "../data/review-manifest.json");

const finish = "Premium authored 16-bit pixel art, crisp deliberate pixel clusters, slim readable silhouette, limited deep navy #09111F #111D31 #182B43, charge cyan #4DEEEA, restrained amber #FFB703 and coral #FF5C5C, warm ivory #F5F0DB, hard one-to-two pixel dark outline, readable at 64 to 96 pixels, isolated complete object on transparent background, no ground, no scenery, no text, no letters, no numbers, no symbols, no logo, no watermark, no blur, no antialiasing, no chibi proportions, no bulky construction robot, no resemblance to an existing franchise";

function candidate({ id, title, titleJa, variation, description, file, review }) {
  return {
    id,
    title,
    titleJa,
    variation,
    prompt: `${description}. ${finish}.`,
    model: "pixen",
    width: 192,
    height: 192,
    noBackground: true,
    detail: "highly detailed",
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
    codexReview: review,
    humanReview: {
      status: "unreviewed",
      rating: null,
      note: "",
      reviewedAt: null,
    },
  };
}

const batch = {
  id: "v6-protagonist-refine",
  order: 23,
  title: "Slender protagonist refinement",
  titleJa: "主人公ロボット・細身スタイリッシュ再提案",
  objective: "採用中のフォージ・ピルグリムが持つ撃鉄腕と胸部発電機を保ちつつ、より人間らしく細身で、主人公として感情移入できる造形へ更新する。",
  gate: "96px表示で顔、利き腕、胸部コア、脚の人物的プロポーションが読み取れ、待機・打撃・PURE CHARGEの三差分へ発展できる1案を選ぶ。",
  status: "ready",
  candidates: [
    candidate({
      id: "protagonist-arc-runner-v6-a",
      title: "Arc Runner",
      titleJa: "弧走機 アーク・ランナー",
      variation: "Most human and agile: a relic hunter built around long legs, a calm face, and one transformable strike arm.",
      description: "A single original player-character automaton in a confident front three-quarter pose facing right, human-like athletic proportions about seven heads tall, narrow waist, long articulated legs, compact shoulders, expressive ivory mask with one calm cyan eye slit, asymmetrical right forearm that transforms into a short pile-driver without becoming oversized, visible circular dynamo heart, short torn cable mantle, exactly six small empty salvage sockets along a slim spine rail, elegant underground relic hunter, capable of a relaxed idle pose, sharp forward punch and braced PURE CHARGE stance",
      file: "source/protagonist/protagonist-arc-runner-v6-a.png",
      review: {
        status: "alternate",
        rank: 3,
        score: 86,
        summary: "人間的な顔、胸部コア、撃鉄腕は役割が明快です。現採用品より脚は細い一方、右腕が依然大きく、全体は豪腕ヒーロー寄りです。",
        strengths: ["手動攻撃の主役となる腕が一目で分かる", "顔の存在で主人公性が強い"],
        concerns: ["細身という希望に対して右腕の面積が大きい", "顔が生身に見えるため世界観上の説明が必要"],
      },
    }),
    candidate({
      id: "protagonist-relic-duelist-v6-a",
      title: "Relic Duelist",
      titleJa: "遺機闘士 レリック・デュエリスト",
      variation: "Heroic and stylish: coat-like armor panels and a compact piston gauntlet, without reading as a sword fighter.",
      description: "A single original player-character automaton in a heroic front three-quarter pose facing right, slender masculine-neutral humanoid silhouette about seven heads tall, tapered chest and long boots, split mechanical coat panels made from repaired navy armor, ivory human-like faceplate with a narrow cyan visor, compact piston gauntlet on the right hand as the only weapon, open left hand controlling electric arcs, exposed amber flywheel beneath the sternum, six subtle empty core mounts on a back harness, stylish but practical beast hunter, no sword, no gun, suitable for idle, punch recoil and energy-channeling animation",
      file: "source/protagonist/protagonist-relic-duelist-v6-a.png",
      review: {
        status: "alternate",
        rank: 2,
        score: 91,
        summary: "最も人間に近く、細身のコート型シルエットは主人公として魅力的です。発電表現は強い一方、撃鉄武器が小さく戦い方はやや伝わりにくくなります。",
        strengths: ["細身でスタイリッシュという要望に最も素直", "電撃を操る手と胸部機関がPURE CHARGEへ展開しやすい"],
        concerns: ["生身の髪と肌に見える部分が多い", "手動打撃の武器が96px表示で埋もれる可能性"],
      },
    }),
    candidate({
      id: "protagonist-volt-nomad-v6-a",
      title: "Volt Nomad",
      titleJa: "雷跡機 ヴォルト・ノマド",
      variation: "Mysterious and personal: hood-like antenna fins, exposed cables, and a lean industrial frame.",
      description: "A single original player-character automaton in a poised front three-quarter pose facing right, lean and human-like frame about seven heads tall, narrow limbs with exposed tendon cables, small hood-like antenna fins framing an ivory face with two restrained cyan sensor eyes, right hand enclosed in a sleek telescoping impact bracer, left hand bare and expressive, luminous round chest core, asymmetric hip armor and a short cable scarf, six empty modular sockets integrated into the back, lonely underground wanderer rather than a factory machine, designed for readable idle breathing, lunging strike and crouched power-generation poses",
      file: "source/protagonist/protagonist-volt-nomad-v6-a.png",
      review: {
        status: "recommended",
        rank: 1,
        score: 94,
        summary: "本命。細身の完全機械体、人間的な手足、胸部コアが両立し、現主人公よりスタイリッシュです。打撃腕も残り、三つの動作差分へ展開できます。",
        strengths: ["ロボットであることを保ったまま人物性がある", "左右非対称の輪郭と胸部コアが64〜96pxでも読める"],
        concerns: ["生成画は前傾姿勢のため、採用時は待機差分を直立寄りに設計する", "六ソケットは背面差分またはGodot演出で補う"],
      },
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
    return {
      ...item,
      generation: old.generation,
      humanReview: old.humanReview,
    };
  });
  manifest.batches[existingIndex] = batch;
} else {
  manifest.batches.push(batch);
}
manifest.batches.sort((a, b) => a.order - b.order);
manifest.updatedAt = new Date().toISOString();
await writeFile(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`, "utf8");
console.log(`Synced ${batch.id} (${batch.candidates.length} candidates).`);
