import { readFile, writeFile } from "node:fs/promises";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const scriptsRoot = dirname(fileURLToPath(import.meta.url));
const manifestPath = resolve(scriptsRoot, "../data/review-manifest.json");

const reviews = {
  "auto-vfx-arc-lance-v10-a": {
    status: "recommended", rank: 1, score: 96,
    summary: "標準AUTO砲へ採用。白い穿孔端、シアンの長い出力体、圧縮環が72〜88px表示でも一発の武器攻撃として読めます。",
    strengths: ["既存の線と点より攻撃方向と質量が明快", "標準砲の工業的な機構と合う"],
    concerns: ["生成方向が左向きなのでGodot側で水平反転して使用"],
  },
  "auto-vfx-gatling-packet-v10-b": {
    status: "recommended", rank: 1, score: 95,
    summary: "GATLING変異へ採用。正確な三連弾が高速連射と弾幕の成長を一目で伝えます。",
    strengths: ["三発が完全に分離し、小表示でも連射と分かる", "アンバー噴炎とシアン弾頭の方向が正しい"],
    concerns: ["標準砲で常用すると密度が高いためGATLING専用に限定"],
  },
  "auto-vfx-horizon-spike-v10-c": {
    status: "recommended", rank: 1, score: 97,
    summary: "RAIL変異へ採用。黒い穿孔軸と紫・シアンの空間破断環が終盤火力を固有化します。",
    strengths: ["通常レーザーではない事象兵器の印象", "弾体が細く敵画像とHP表示を隠さない"],
    concerns: ["生成方向が左向きなのでGodot側で水平反転して使用"],
  },
  "overlimit-socket-five-bus-v10-a": {
    status: "not_recommended", rank: 3, score: 74,
    summary: "単体装置としては魅力的ですが、横長の空欄ノードではなく斜視の基板になり、文字を重ねる領域が不足しています。",
    strengths: ["五色端子と修復配線はOVERLIMITの概念に合う"],
    concerns: ["斜視で既存の正投影UIと不一致", "中央空欄が小さく日本語と価格を置けない"],
  },
  "overlimit-socket-black-sun-v10-b": {
    status: "alternate", rank: 2, score: 87,
    summary: "日蝕継電器の意匠は強く、事象地平砲の専用エンブレム候補。ただし横長フレームではなく円形アイコンになりました。",
    strengths: ["黒陽と五色接点が真ボス系統へ自然に接続", "小型アイコンとして読みやすい"],
    concerns: ["全OVERLIMIT共通枠としてはAUTOGUN寄り", "ノード背景には余白不足"],
  },
  "overlimit-socket-seraph-lock-v10-c": {
    status: "recommended", rank: 1, score: 94,
    summary: "OVERLIMIT共通紋章へ採用。六本の導体翼と五色接点が第三形態へつながり、通常ノードとの差を小面積で作れます。",
    strengths: ["72〜90px表示で最終段階と分かる強い輪郭", "通常ノードと詳細パネルの両方へ重ねられる"],
    concerns: ["文字枠にはならないため、既存のコード描画プレートと組み合わせる"],
  },
};

const manifest = JSON.parse(await readFile(manifestPath, "utf8"));
const batch = manifest.batches.find((item) => item.id === "v10-auto-vfx-overlimit-ui");
if (!batch) throw new Error("v10 batch is missing");
for (const item of batch.candidates) {
  if (reviews[item.id]) item.codexReview = reviews[item.id];
}
batch.status = "ready";
manifest.project.provisionalSelection = {
  ...manifest.project.provisionalSelection,
  v10AutoStandard: "auto-vfx-arc-lance-v10-a",
  v10AutoGatling: "auto-vfx-gatling-packet-v10-b",
  v10AutoRail: "auto-vfx-horizon-spike-v10-c",
  v10OverlimitEmblem: "overlimit-socket-seraph-lock-v10-c",
};
manifest.updatedAt = new Date().toISOString();
await writeFile(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`, "utf8");
console.log("Saved v10 combat/UI reviews and provisional selections.");
