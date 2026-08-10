#!/usr/bin/env node

import { readFile, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const toolDir = dirname(fileURLToPath(import.meta.url));
const eventRoot = resolve(toolDir, "..");
const storyPath = resolve(eventRoot, "godot/games/charge_clicker/story_catalog.gd");
const gamePath = resolve(eventRoot, "godot/games/charge_clicker/charge_clicker.gd");
const outputPath = resolve(eventRoot, "docs/VOLT_NOMAD_TEXT_REVIEW.md");

const [storySource, gameSource] = await Promise.all([
  readFile(storyPath, "utf8"),
  readFile(gamePath, "utf8"),
]);

const decode = (raw = "") => {
  try {
    return JSON.parse(`"${raw}"`);
  } catch {
    return raw.replaceAll("\\n", "\n").replaceAll('\\"', '"');
  }
};
const md = (value = "") => String(value).replaceAll("|", "\\|").replaceAll("\n", "<br>");
const quoted = (source) => [...source.matchAll(/"((?:\\.|[^"\\])*)"/g)].map((match) => decode(match[1]));
const field = (source, key) => {
  const match = source.match(new RegExp(`"${key}"\\s*:\\s*"((?:\\\\.|[^"\\\\])*)"`));
  return match ? decode(match[1]) : "";
};

const eventStarts = [...storySource.matchAll(/"id"\s*:\s*"([^"]+)"/g)];
const events = eventStarts.map((match, index) => {
  const start = match.index;
  const end = index + 1 < eventStarts.length ? eventStarts[index + 1].index : storySource.indexOf("\n]\n", start);
  const block = storySource.slice(start, end > start ? end : undefined);
  const lines = [...block.matchAll(/line\(([^\n]+)\)/g)]
    .map((lineMatch) => quoted(lineMatch[1]))
    .filter((args) => args.length >= 5)
    .map((args) => ({ role: args[0], speakerJa: args[1], speakerEn: args[2], textJa: args[3], textEn: args[4] }));
  return {
    id: match[1],
    titleJa: field(block, "title_ja"),
    titleEn: field(block, "title_en"),
    contextJa: field(block, "context_ja"),
    contextEn: field(block, "context_en"),
    lines,
  };
});

const introStart = gameSource.indexOf("func queue_encounter_intro(encounter_id: String) -> void:");
const introEnd = gameSource.indexOf("\nfunc ", introStart + 8);
const introSource = gameSource.slice(introStart, introEnd);
const branchStarts = [...introSource.matchAll(/^\t\t"([^"]+)":/gm)];
const comms = branchStarts.map((match, index) => {
  const start = match.index;
  const end = index + 1 < branchStarts.length ? branchStarts[index + 1].index : introSource.length;
  const block = introSource.slice(start, end);
  const lines = [...block.matchAll(/queue_comms\(([^\n]+)\)/g)].map((call) => {
    const args = quoted(call[1]);
    const support = call[1].trimStart().startsWith("support_ja");
    return {
      speakerJa: support ? "支援演算 C6" : (args[0] ?? ""),
      speakerEn: support ? "C6 SUPPORT" : (args[1] ?? ""),
      textJa: support ? (args[0] ?? "") : (args[2] ?? ""),
      textEn: support ? (args[1] ?? "") : (args[3] ?? ""),
    };
  });
  return { id: match[1], lines };
}).filter((entry) => entry.lines.length > 0);

const output = [];
output.push("# VOLT NOMAD — 全テキスト確認表");
output.push("");
output.push(`生成元: \`story_catalog.gd\` / \`charge_clicker.gd\`　最終生成: ${new Date().toISOString().slice(0, 10)}`);
output.push("");
output.push("このファイルは台詞校正用の一覧です。修正時はイベントIDを残したまま、日本語・英語の変更案を書き込んでください。ゲームへ反映する正本は上記GDScriptです。再生成コマンド: `node tools/export-dialogue-review.mjs`");
output.push("");
output.push(`## ブロッキング会話（${events.length}イベント）`);
output.push("");
for (const event of events) {
  output.push(`### ${event.id}`);
  output.push("");
  output.push(`- 日本語題: ${event.titleJa}`);
  output.push(`- English title: ${event.titleEn}`);
  output.push(`- 日本語状況: ${event.contextJa}`);
  output.push(`- English context: ${event.contextEn}`);
  output.push("");
  output.push("| # | Role | 話者 | Speaker | 日本語 | English |");
  output.push("| ---: | --- | --- | --- | --- | --- |");
  event.lines.forEach((line, index) => {
    output.push(`| ${index + 1} | ${md(line.role)} | ${md(line.speakerJa)} | ${md(line.speakerEn)} | ${md(line.textJa)} | ${md(line.textEn)} |`);
  });
  output.push("");
}
output.push(`## 戦闘中の短い通信（${comms.length}戦）`);
output.push("");
output.push("設定の「ストーリー会話」をOFFにすると、以下は表示も待機もせず即時スキップされます。ゲームルール警告は別系統なので残ります。");
output.push("");
for (const entry of comms) {
  output.push(`### ${entry.id}`);
  output.push("");
  output.push("| # | 話者 | Speaker | 日本語 | English |");
  output.push("| ---: | --- | --- | --- | --- |");
  entry.lines.forEach((line, index) => {
    output.push(`| ${index + 1} | ${md(line.speakerJa)} | ${md(line.speakerEn)} | ${md(line.textJa)} | ${md(line.textEn)} |`);
  });
  output.push("");
}

await writeFile(outputPath, `${output.join("\n")}\n`, "utf8");
console.log(`Wrote ${events.length} story events and ${comms.length} combat exchanges to ${outputPath}`);
