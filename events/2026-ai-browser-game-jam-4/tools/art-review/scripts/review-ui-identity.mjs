import { readFile, writeFile } from "node:fs/promises";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const scriptsRoot = dirname(fileURLToPath(import.meta.url));
const manifestPath = resolve(scriptsRoot, "../data/review-manifest.json");

const reviews = {
  "upgrade-rack-switchboard-a": {
    status: "recommended", rank: 1, score: 96,
    summary: "暫定本命。4×2の8ソケット、共通バス、左右のサービス区画が一体の設備として読め、丸角カード8枚という現状を最も大きく崩せます。",
    strengths: ["正確に8ソケットあり、各枠へ日本語とアイコンを重ねられる", "左右非対称の整備区画と中央バスが量産カード感を消す"],
    concerns: ["左右の大型空洞は装飾または系統表示としてGodot側で用途を与える必要がある"],
  },
  "upgrade-rack-ceramic-a": {
    status: "alternate", rank: 2, score: 92,
    summary: "8ソケットが最も明瞭で実装しやすい優秀な案です。均一性が強いため、通常設備より研究所ステージや精密アップグレード画面に向きます。",
    strengths: ["正確な4×2構造と広い暗色の文字領域", "セラミックと濃紺の素材差でネオン依存を減らせる"],
    concerns: ["全枠が完全に同形で、使い方によっては再びテンプレート感が出る"],
  },
  "upgrade-rack-corrupted-a": {
    status: "alternate", rank: 3, score: 86,
    summary: "8モジュールと侵食配線は読めますが、独立した小型枠が再びカード列に見えます。通常UIではなくボス侵食中の差し替え素材として有効です。",
    strengths: ["正確に8枠あり、赤い侵食とシアン修復の関係が明確", "暗い内部へ情報を安全に重ねられる"],
    concerns: ["一体型ラックより8枚のカードに近い", "珊瑚色の比率を上げると購入可否の色と競合する"],
  },
  "control-kit-switchboard-a": {
    status: "recommended", rank: 1, score: 97,
    summary: "暫定本命。縦型プランジャー、横長6系統バス、小型リレーが明確に異なる輪郭を持ちつつ、配線色と金属で同じ製品群に見えます。",
    strengths: ["CHARGE・DISCHARGE・AUTOの操作原理が筐体だけで分かれる", "各中央が静かで既存アイコン、発光、文字を重ねやすい"],
    concerns: ["3部品の切り出し矩形を手動で確定し、端のケーブルを欠けさせない調整が必要"],
  },
  "control-kit-ceramic-a": {
    status: "alternate", rank: 2, score: 89,
    summary: "素材感が独特でAI的なネオンカードから離れられます。ただし中央の放電装置が横長バスではなく汎用ダイヤル盤に見え、操作差は本命より弱いです。",
    strengths: ["アイボリー絶縁体が画面に新しい物質感を作る", "三筐体とも暗いオーバーレイ領域が広い"],
    concerns: ["DISCHARGEの外向き・6セル連動が静止画から読み取りにくい", "3筐体の大きさが近く、優先度差が弱い"],
  },
  "control-kit-corrupted-a": {
    status: "alternate", rank: 3, score: 88,
    summary: "緊急設備として強い物語性があります。中央の6端子も明瞭ですが、常設UIにすると危険色が平常化するためボス・真ルート状態への差し替えが適切です。",
    strengths: ["中央に正確な6端子がありセル接続へ展開しやすい", "修理痕と異種ケーブルが手作業感を出す"],
    concerns: ["常時表示では赤い警告の意味が薄れる", "AUTO筐体が操作盤より補給装置にも見える"],
  },
  "wraith-gauge-corrupted-b": {
    status: "recommended", rank: 1, score: 93,
    summary: "集中修正版の暫定本命。大きな暗色セルが6基あり、珊瑚色の侵食と青い修復を各セグメントの破壊演出へつなげられます。",
    strengths: ["6個の主要空洞が読み取れ、普通のHPバーに見えない", "一基ずつ割る・消灯する演出が想像しやすい"],
    concerns: ["端が密集しているため、Godotでは中央6枠を切り出すか個別タイル化する", "装飾密度が高く、数値表示はゲージ外へ置く必要がある"],
  },
  "wraith-gauge-switchboard-b": {
    status: "not_recommended", rank: 2, score: 84,
    summary: "破壊可能な大型シールという方向は良いものの、7基生成されて6セルルールと矛盾します。1基を切り出す部品素材としては利用できます。",
    strengths: ["一基ごとの輪郭が強く、小表示でも破壊状態を作りやすい", "暗色と赤錆でボス用設備らしい"],
    concerns: ["7基あり、そのままでは採用不可", "同形反復が強く中央の敵らしさは別レイヤーで必要"],
  },
  "wraith-gauge-switchboard-a": {
    status: "not_recommended", rank: 3, score: 82,
    summary: "工業的な配線背骨として魅力はありますが、細い区切りが多数あり6分割を伝えません。中央ハブと端部の素材取り候補です。",
    strengths: ["機械的な背骨と中央ハブの固有シルエット", "細い導線は吸収予告アニメーションと相性が良い"],
    concerns: ["6分割ではなく多数の細いリブに見える", "中央ハブが値の読み順を分断する"],
  },
  "wraith-gauge-corrupted-a": {
    status: "not_recommended", rank: 4, score: 80,
    summary: "侵食配線の雰囲気は強い一方、空のゲージ領域と6分割が成立していません。ボス周辺の装飾コンジットとして転用する案です。",
    strengths: ["赤・青ケーブルの対立が敵の吸収と修復を表現できる", "通常UIと大きく異なる不穏な質感"],
    concerns: ["情報を重ねる静かな領域がほぼない", "セグメント数を判別できない"],
  },
  "wraith-gauge-ceramic-a": {
    status: "not_recommended", rank: 5, score: 78,
    summary: "研究設備としては美しいですが、細分化された管と中央標本がボスHPの読みやすさを下げます。特殊ステージの進捗装置向きです。",
    strengths: ["セラミック絶縁体の素材感が独自", "中央標本が物語上のアンカーになる"],
    concerns: ["6分割ではなく多数の小区画", "アンバー面積が大きく満充電表示と競合する"],
  },
  "wraith-gauge-ceramic-b": {
    status: "not_recommended", rank: 6, score: 74,
    summary: "空洞を大きくする修正は効きましたが、約10区画に増えています。単一フレームを切り出す場合のみ利用可能です。",
    strengths: ["均質な空洞はGodotの塗りと相性が良い", "上下レールが配置を安定させる"],
    concerns: ["6ではなく多数の区画を生成", "反復が強く敵固有の異常さが弱い"],
  },
  "shard-accumulator-switchboard-b": {
    status: "recommended", rank: 1, score: 97,
    summary: "集中修正版の暫定本命。大型ソケットと完全に空いた暗色プレートが明瞭で、破片アイコン、4桁数値、流入発光を安全にGodotで重ねられます。",
    strengths: ["偽文字や数字がなく、表示領域を完全に制御できる", "ラック・操作盤の重工業本命と同じ素材言語", "左ソケットが報酬粒子の到着点として強い"],
    concerns: ["右板の横線は数値と干渉しない濃度へ落とす可能性がある"],
  },
  "shard-accumulator-ceramic-b": {
    status: "alternate", rank: 2, score: 92,
    summary: "左の絶縁ソケットと右の空欄パネルが最も整然としています。研究所ルートや希少通貨表示への差し替え候補です。",
    strengths: ["文字領域が広く完全に空いている", "アイボリーの留め具が小表示でも資源装置の輪郭を保つ"],
    concerns: ["通常画面ではアップグレードラックもB案に揃えないと単独で浮く"],
  },
  "shard-accumulator-corrupted-b": {
    status: "alternate", rank: 3, score: 88,
    summary: "単純で強い二窓構造です。珊瑚色の角枠が大報酬や危険な資源を示すため、平常時よりボス中の一時変化に向きます。",
    strengths: ["左アイコンと右数値の領域が明快", "外周だけ侵食しており情報の可読性を保てる"],
    concerns: ["中央の黒面積が大きく、常設すると他の重工業素材より簡素に見える"],
  },
  "shard-accumulator-switchboard-a": {
    status: "not_recommended", rank: 4, score: 76,
    summary: "筐体そのものは魅力的ですが、右窓に偽の数字が焼き込まれました。AIっぽさを直接増やすため、そのままでは不採用です。",
    strengths: ["大型ホッパーと積算計の用途が一目で分かる", "外形は重工業本命とよく合う"],
    concerns: ["偽数字がローカライズと実数値に干渉する", "手修正コストが集中修正版より高い"],
  },
  "shard-accumulator-corrupted-a": {
    status: "not_recommended", rank: 5, score: 73,
    summary: "不安定な封じ込め装置として派手ですが、右側が複数の偽メーターに分かれ、ゲーム内数値を置く場所がありません。",
    strengths: ["エネルギー片が危険物である印象を強く出せる", "左右を貫く配線の勢いがある"],
    concerns: ["数値表示領域が分断されている", "色と細部が多くヘッダーで過度に目立つ"],
  },
  "shard-accumulator-ceramic-a": {
    status: "not_recommended", rank: 6, score: 70,
    summary: "絶縁リングは良いものの、右窓へ判読不能な数字列が生成されました。AI生成物らしさを最も強く感じるため不採用です。",
    strengths: ["左の絶縁リングは単体素材として転用可能", "構成自体はアイコンと数値の順序が明快"],
    concerns: ["偽数字が目立ち、今回の改善目的と正反対", "上部の突起がヘッダー高さに収まりにくい"],
  },
};

const manifest = JSON.parse(await readFile(manifestPath, "utf8"));
let updated = 0;
for (const batch of manifest.batches) {
  for (const item of batch.candidates) {
    if (!reviews[item.id]) continue;
    item.codexReview = reviews[item.id];
    updated += 1;
  }
  if (["phase2-upgrade-rack", "phase2-control-console-kit", "phase2-wraith-gauge", "phase2-shard-accumulator"].includes(batch.id)) {
    batch.status = "ready";
  }
}
manifest.project.provisionalSelection = {
  ...manifest.project.provisionalSelection,
  upgradeRack: "upgrade-rack-switchboard-a",
  controlKit: "control-kit-switchboard-a",
  wraithGauge: "wraith-gauge-corrupted-b",
  shardAccumulator: "shard-accumulator-switchboard-b",
  note: "既存8カテゴリとUI Identity 4カテゴリのCodex一次選考を保存済み。人間レビューで変更可能です。",
};
manifest.updatedAt = new Date().toISOString();
await writeFile(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`, "utf8");
console.log(`Saved ${updated} UI identity reviews and provisional selections.`);
