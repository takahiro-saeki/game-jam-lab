const state = {
  manifest: null,
  batch: "all",
  status: "all",
  query: "",
  backdrop: "void",
  scale: "fit",
  compare: new Set(),
};

const elements = {
  summary: document.querySelector("#summary"),
  batchFilter: document.querySelector("#batch-filter"),
  statusFilter: document.querySelector("#status-filter"),
  search: document.querySelector("#search"),
  palette: document.querySelector("#palette"),
  intro: document.querySelector("#batch-intro"),
  grid: document.querySelector("#candidate-grid"),
  empty: document.querySelector("#empty"),
  template: document.querySelector("#candidate-template"),
  compareTray: document.querySelector("#compare-tray"),
  compareItems: document.querySelector("#compare-items"),
  clearCompare: document.querySelector("#clear-compare"),
  dialog: document.querySelector("#preview-dialog"),
  dialogContent: document.querySelector("#dialog-content"),
  closeDialog: document.querySelector("#close-dialog"),
};

const statusLabel = {
  planned: "生成待ち",
  generating: "生成中",
  generated: "生成済み",
  failed: "生成失敗",
  approved: "採用",
  hold: "保留",
  rejected: "不採用",
  unreviewed: "未確認",
};

function allCandidates() {
  return state.manifest.batches.flatMap((batch) => batch.candidates.map((candidate) => ({ batch, candidate })));
}

function imageUrl(candidate) {
  return `/assets/${candidate.file.split("/").map(encodeURIComponent).join("/")}`;
}

function renderHeader() {
  const candidates = allCandidates().map(({ candidate }) => candidate);
  const generated = candidates.filter((item) => item.generation.status === "generated").length;
  const reviewed = candidates.filter((item) => item.humanReview.status !== "unreviewed").length;
  const approved = candidates.filter((item) => item.humanReview.status === "approved").length;
  elements.summary.innerHTML = [
    [generated, `生成済み / ${candidates.length}`],
    [reviewed, "判断済み"],
    [approved, "採用"],
  ].map(([value, label]) => `<div class="summary-item"><strong>${value}</strong><span>${label}</span></div>`).join("");
}

function renderPalette() {
  elements.palette.innerHTML = state.manifest.project.palette
    .map((color) => `<span class="swatch" style="background:${color}" title="${color}"></span>`)
    .join("");
}

function renderBatchFilter() {
  elements.batchFilter.innerHTML = `<option value="all">すべてのバッチ</option>${state.manifest.batches
    .map((batch) => `<option value="${batch.id}">${batch.order}. ${batch.titleJa}</option>`)
    .join("")}`;
  elements.batchFilter.value = state.batch;
}

function renderIntro(items) {
  const batch = state.batch === "all"
    ? null
    : state.manifest.batches.find((item) => item.id === state.batch);
  const title = batch ? batch.titleJa : "すべての候補";
  const en = batch ? batch.title : "ART DIRECTION OVERVIEW";
  const objective = batch
    ? batch.objective
    : "Codexの一次選考、生成条件、人間の判断を一つの画面で照合できます。比較には最大3案まで追加できます。";
  const gate = batch ? batch.gate : `${items.length}件を表示中。各バッチの完成条件を満たした一案だけをゲームへ採用します。`;
  const preview = state.manifest.project.gameplayPreview
    ? `<button class="game-preview-button godot-preview-button" type="button">Godot組み合わせ比較</button>`
    : "";
  const identityPreview = state.manifest.batches.some((item) => item.id === "phase2-upgrade-rack")
    ? `<button class="game-preview-button identity-preview-button" type="button">UI基盤・脱AI感比較</button>`
    : "";
  elements.intro.innerHTML = `<div><span class="eyebrow">${en}</span><h2>${title}</h2><p>${objective}</p><div class="preview-actions">${preview}${identityPreview}</div></div><div class="gate"><strong>APPROVAL GATE</strong><br>${gate}</div>`;
  elements.intro.querySelector(".godot-preview-button")?.addEventListener("click", openGameCombinationPreview);
  elements.intro.querySelector(".identity-preview-button")?.addEventListener("click", openUiIdentityPreview);
}

function openUiIdentityPreview() {
  const rackBatch = state.manifest.batches.find((batch) => batch.id === "phase2-upgrade-rack");
  const controlBatch = state.manifest.batches.find((batch) => batch.id === "phase2-control-console-kit");
  const gaugeBatch = state.manifest.batches.find((batch) => batch.id === "phase2-wraith-gauge");
  const accumulatorBatch = state.manifest.batches.find((batch) => batch.id === "phase2-shard-accumulator");
  if (![rackBatch, controlBatch, gaugeBatch, accumulatorBatch].every(Boolean)) return;
  const selection = state.manifest.project.provisionalSelection || {};
  const option = (candidate) => `<option value="${candidate.id}">${escapeHtml(candidate.titleJa)} — Codex ${candidate.codexReview.score ?? "—"}</option>`;
  elements.dialogContent.innerHTML = `
    <div class="game-preview-lab identity-preview-lab">
      <header>
        <div><span class="eyebrow">UI IDENTITY / ANTI-AI PASS</span><h2>機械部品の組み合わせ比較</h2></div>
        <p>PixelLabs生成物は筐体だけに使い、文字・数値・発光・押下・破損はGodotで重ねます。これはレイアウト方針を比較する合成モックです。</p>
      </header>
      <div class="game-preview-controls identity-preview-controls">
        <label>方向プリセット<select id="identity-preset">
          <option value="recommended">Codex本命</option>
          <option value="switchboard">重工業 A</option>
          <option value="ceramic">高圧実験 B</option>
          <option value="corrupted">侵食設備 C</option>
          <option value="custom">個別選択</option>
        </select></label>
        <label>アップグレードラック<select id="identity-rack-select">${rackBatch.candidates.map(option).join("")}</select></label>
        <label>主操作盤<select id="identity-control-select">${controlBatch.candidates.map(option).join("")}</select></label>
        <label>敵ゲージ<select id="identity-gauge-select">${gaugeBatch.candidates.map(option).join("")}</select></label>
        <label>エネルギー片<select id="identity-accumulator-select">${accumulatorBatch.candidates.map(option).join("")}</select></label>
      </div>
      <div class="identity-stage">
        <div class="identity-stage-header">
          <div class="identity-brand"><span>PROJECT CHARGE</span><small>GENERATOR CORE / UI IDENTITY TEST</small></div>
          <div class="identity-accumulator-wrap"><img id="identity-accumulator-image" alt="エネルギー片カウンター候補"><span class="identity-shard">✦</span><strong>0240</strong></div>
        </div>
        <div class="identity-boss-row"><span>GRID WRAITH / SIPHON INTEGRITY</span><img id="identity-gauge-image" alt="GRID WRAITHゲージ候補"></div>
        <div class="identity-core-mock" aria-label="6セルの仮表示">
          <div class="identity-reactor-mock">CORE<br><strong>72%</strong></div>
          <div class="identity-cells">${Array.from({ length: 6 }, (_, index) => `<i style="--level:${34 + index * 11}%"><b>0${index + 1}</b></i>`).join("")}</div>
        </div>
        <div class="identity-control-wrap"><span>MAIN CONTROL BUS</span><img id="identity-control-image" alt="主操作盤候補"></div>
        <div class="identity-rack-wrap"><span>UPGRADE MODULE RACK / 4 × 2</span><img id="identity-rack-image" alt="アップグレードラック候補"></div>
      </div>
      <p class="identity-preview-note">本命は通常UIを重工業Aで統一し、GRID WRAITHだけ侵食Cを混ぜる構成です。C案はボス警告・真ルートで設備が侵食される差し替えにも使えます。</p>
    </div>`;

  const preset = elements.dialogContent.querySelector("#identity-preset");
  const rackSelect = elements.dialogContent.querySelector("#identity-rack-select");
  const controlSelect = elements.dialogContent.querySelector("#identity-control-select");
  const gaugeSelect = elements.dialogContent.querySelector("#identity-gauge-select");
  const accumulatorSelect = elements.dialogContent.querySelector("#identity-accumulator-select");
  const presets = {
    recommended: {
      rack: selection.upgradeRack || "upgrade-rack-switchboard-a",
      control: selection.controlKit || "control-kit-switchboard-a",
      gauge: selection.wraithGauge || "wraith-gauge-corrupted-b",
      accumulator: selection.shardAccumulator || "shard-accumulator-switchboard-b",
    },
    switchboard: { rack: "upgrade-rack-switchboard-a", control: "control-kit-switchboard-a", gauge: "wraith-gauge-switchboard-b", accumulator: "shard-accumulator-switchboard-b" },
    ceramic: { rack: "upgrade-rack-ceramic-a", control: "control-kit-ceramic-a", gauge: "wraith-gauge-ceramic-b", accumulator: "shard-accumulator-ceramic-b" },
    corrupted: { rack: "upgrade-rack-corrupted-a", control: "control-kit-corrupted-a", gauge: "wraith-gauge-corrupted-b", accumulator: "shard-accumulator-corrupted-b" },
  };
  const updateImages = () => {
    const byId = (batch, id) => batch.candidates.find((candidate) => candidate.id === id);
    elements.dialogContent.querySelector("#identity-rack-image").src = imageUrl(byId(rackBatch, rackSelect.value));
    elements.dialogContent.querySelector("#identity-control-image").src = imageUrl(byId(controlBatch, controlSelect.value));
    elements.dialogContent.querySelector("#identity-gauge-image").src = imageUrl(byId(gaugeBatch, gaugeSelect.value));
    elements.dialogContent.querySelector("#identity-accumulator-image").src = imageUrl(byId(accumulatorBatch, accumulatorSelect.value));
  };
  const applyPreset = (name) => {
    const values = presets[name];
    if (!values) return;
    rackSelect.value = values.rack;
    controlSelect.value = values.control;
    gaugeSelect.value = values.gauge;
    accumulatorSelect.value = values.accumulator;
    updateImages();
  };
  preset.addEventListener("change", () => applyPreset(preset.value));
  [rackSelect, controlSelect, gaugeSelect, accumulatorSelect].forEach((select) => select.addEventListener("change", () => {
    preset.value = "custom";
    updateImages();
  }));
  applyPreset("recommended");
  elements.dialog.showModal();
}

function openGameCombinationPreview() {
  const reactorBatch = state.manifest.batches.find((batch) => batch.id === "phase2-reactor");
  const environmentBatch = state.manifest.batches.find((batch) => batch.id === "phase2-environment");
  const cellBatch = state.manifest.batches.find((batch) => batch.id === "phase2-cell-module");
  const wraithBatch = state.manifest.batches.find((batch) => batch.id === "phase2-grid-wraith");
  const shardBatch = state.manifest.batches.find((batch) => batch.id === "phase2-energy-shard");
  const chargeControlBatch = state.manifest.batches.find((batch) => batch.id === "phase2-charge-control");
  const dischargeControlBatch = state.manifest.batches.find((batch) => batch.id === "phase2-discharge-control");
  const autoControlBatch = state.manifest.batches.find((batch) => batch.id === "phase2-auto-control");
  const selection = state.manifest.project.provisionalSelection || {};
  const option = (candidate) => `<option value="${candidate.id}">${escapeHtml(candidate.titleJa)} — Codex ${candidate.codexReview.score ?? "—"} / あなた ${candidate.humanReview.rating ?? "—"}</option>`;
  elements.dialogContent.innerHTML = `
    <div class="game-preview-lab">
      <header>
        <div><span class="eyebrow">LIVE GODOT WEB PREVIEW</span><h2>組み合わせ比較</h2></div>
        <p>8カテゴリの候補を、固定したボス戦中の実際のGodot描画・UI・発光リングと重ねて確認できます。</p>
      </header>
      <div class="game-preview-controls">
        <label>原子炉<select id="game-reactor-select">${reactorBatch.candidates.map(option).join("")}</select></label>
        <label>背景<select id="game-environment-select">${environmentBatch.candidates.map(option).join("")}</select></label>
        <label>セル<select id="game-cell-select">${cellBatch.candidates.map(option).join("")}</select></label>
        <label>GRID WRAITH<select id="game-wraith-select">${wraithBatch.candidates.map(option).join("")}</select></label>
        <label>エネルギー片<select id="game-shard-select">${shardBatch.candidates.map(option).join("")}</select></label>
        <label>CHARGE<select id="game-charge-control-select">${chargeControlBatch.candidates.map(option).join("")}</select></label>
        <label>DISCHARGE<select id="game-discharge-control-select">${dischargeControlBatch.candidates.map(option).join("")}</select></label>
        <label>AUTO OFF<select id="game-auto-control-select">${autoControlBatch.candidates.map(option).join("")}</select></label>
        <a id="open-game-window" href="#" target="_blank" rel="noreferrer">別タブで開く</a>
      </div>
      <div class="game-preview-status" role="status">選択を反映しています。初回はGodotの読み込みに数秒かかります。</div>
      <iframe id="game-preview-frame" title="PROJECT CHARGE Godot組み合わせプレビュー" allow="autoplay; gamepad"></iframe>
    </div>`;
  const reactorSelect = elements.dialogContent.querySelector("#game-reactor-select");
  const environmentSelect = elements.dialogContent.querySelector("#game-environment-select");
  const cellSelect = elements.dialogContent.querySelector("#game-cell-select");
  const wraithSelect = elements.dialogContent.querySelector("#game-wraith-select");
  const shardSelect = elements.dialogContent.querySelector("#game-shard-select");
  const chargeControlSelect = elements.dialogContent.querySelector("#game-charge-control-select");
  const dischargeControlSelect = elements.dialogContent.querySelector("#game-discharge-control-select");
  const autoControlSelect = elements.dialogContent.querySelector("#game-auto-control-select");
  reactorSelect.value = selection.reactor || reactorBatch.candidates[0].id;
  environmentSelect.value = selection.environment || environmentBatch.candidates[0].id;
  cellSelect.value = selection.cell || cellBatch.candidates[0].id;
  wraithSelect.value = selection.wraith || wraithBatch.candidates[0].id;
  shardSelect.value = selection.shard || shardBatch.candidates[0].id;
  chargeControlSelect.value = selection.chargeControl || chargeControlBatch.candidates[0].id;
  dischargeControlSelect.value = selection.dischargeControl || dischargeControlBatch.candidates[0].id;
  autoControlSelect.value = selection.autoControl || autoControlBatch.candidates[0].id;
  const loadCombination = () => {
    const params = new URLSearchParams({
      art_preview: "1",
      game: "project-charge",
      reactor: reactorSelect.value,
      environment: environmentSelect.value,
      cell: cellSelect.value,
      wraith: wraithSelect.value,
      shard: shardSelect.value,
      charge_control: chargeControlSelect.value,
      discharge_control: dischargeControlSelect.value,
      auto_control: autoControlSelect.value,
    });
    const url = `/game/?${params}`;
    elements.dialogContent.querySelector("#game-preview-frame").src = url;
    elements.dialogContent.querySelector("#open-game-window").href = url;
  };
  reactorSelect.addEventListener("change", loadCombination);
  environmentSelect.addEventListener("change", loadCombination);
  cellSelect.addEventListener("change", loadCombination);
  wraithSelect.addEventListener("change", loadCombination);
  shardSelect.addEventListener("change", loadCombination);
  chargeControlSelect.addEventListener("change", loadCombination);
  dischargeControlSelect.addEventListener("change", loadCombination);
  autoControlSelect.addEventListener("change", loadCombination);
  loadCombination();
  elements.dialog.showModal();
}

function badge(text, className = "") {
  return `<span class="badge ${className}">${text}</span>`;
}

function pointList(title, values, className) {
  if (!values?.length) return "";
  return `<ul class="point-list ${className}" aria-label="${title}">${values.map((value) => `<li>${escapeHtml(value)}</li>`).join("")}</ul>`;
}

function escapeHtml(value) {
  return String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

function filteredItems() {
  const query = state.query.toLocaleLowerCase("ja");
  return allCandidates().filter(({ batch, candidate }) => {
    if (state.batch !== "all" && batch.id !== state.batch) return false;
    if (state.status === "recommended" && candidate.codexReview.status !== "recommended") return false;
    if (!["all", "recommended"].includes(state.status) && candidate.humanReview.status !== state.status) return false;
    if (!query) return true;
    const haystack = [candidate.id, candidate.title, candidate.titleJa, candidate.prompt, candidate.codexReview.summary]
      .join(" ").toLocaleLowerCase("ja");
    return haystack.includes(query);
  });
}

function renderCard(batch, candidate) {
  const fragment = elements.template.content.cloneNode(true);
  const card = fragment.querySelector(".candidate-card");
  card.dataset.id = candidate.id;
  card.dataset.humanStatus = candidate.humanReview.status;

  const badges = fragment.querySelector(".badges");
  if (candidate.codexReview.rank) badges.insertAdjacentHTML("beforeend", badge(`CODEX #${candidate.codexReview.rank}`, "rank"));
  if (candidate.codexReview.status === "recommended") badges.insertAdjacentHTML("beforeend", badge("推奨", "recommended"));
  badges.insertAdjacentHTML("beforeend", badge(statusLabel[candidate.generation.status] || candidate.generation.status, candidate.generation.status));
  if (candidate.humanReview.status !== "unreviewed") badges.insertAdjacentHTML("beforeend", badge(statusLabel[candidate.humanReview.status]));

  const compare = fragment.querySelector(".compare-toggle input");
  compare.checked = state.compare.has(candidate.id);
  compare.disabled = candidate.generation.status !== "generated";
  compare.addEventListener("change", () => toggleCompare(candidate.id, compare));

  const frame = fragment.querySelector(".preview-frame");
  frame.className = `preview-frame ${state.backdrop}`;
  frame.dataset.scale = state.scale;
  if (candidate.generation.status === "generated") {
    frame.style.setProperty("--native-width", candidate.width);
    frame.innerHTML = `<img src="${imageUrl(candidate)}" alt="${escapeHtml(candidate.titleJa)}" width="${candidate.width}" height="${candidate.height}" />`;
    fragment.querySelector(".preview-button").addEventListener("click", () => openPreview(candidate));
  } else if (candidate.generation.status === "failed") {
    frame.innerHTML = `<div class="placeholder">GENERATION FAILED</div>`;
  }

  fragment.querySelector(".candidate-id").textContent = `${batch.order}.${String(batch.candidates.indexOf(candidate) + 1).padStart(2, "0")} / ${candidate.id}`;
  fragment.querySelector("h3").textContent = candidate.titleJa;
  fragment.querySelector(".title-en").textContent = candidate.title;
  const score = fragment.querySelector(".score");
  if (Number.isFinite(candidate.codexReview.score)) {
    score.hidden = false;
    score.querySelector("strong").textContent = candidate.codexReview.score;
  }
  fragment.querySelector(".codex-summary").textContent = candidate.codexReview.summary;
  fragment.querySelector(".review-points").innerHTML = `${pointList("強み", candidate.codexReview.strengths, "good")}${pointList("懸念", candidate.codexReview.concerns, "concern")}`;

  fragment.querySelector(".metadata").innerHTML = [
    ["model", candidate.model], ["size", `${candidate.width}×${candidate.height}`],
    ["transparent", candidate.noBackground ? "yes" : "no"], ["detail", candidate.detail],
    ["seed", candidate.seed ?? "auto"], ["file", candidate.file],
  ].map(([key, value]) => `<dt>${key}</dt><dd>${escapeHtml(value)}</dd>`).join("");
  fragment.querySelector(".prompt").textContent = candidate.prompt;

  const form = fragment.querySelector(".review-form");
  const rating = fragment.querySelector(".rating");
  const note = fragment.querySelector(".review-note");
  rating.value = candidate.humanReview.rating || "";
  note.value = candidate.humanReview.note || "";
  let selectedStatus = candidate.humanReview.status;
  const decisionButtons = [...fragment.querySelectorAll(".decision-buttons button")];
  const syncDecision = () => decisionButtons.forEach((button) => button.classList.toggle("active", button.dataset.status === selectedStatus));
  decisionButtons.forEach((button) => button.addEventListener("click", () => { selectedStatus = button.dataset.status; syncDecision(); }));
  syncDecision();
  form.addEventListener("submit", async (event) => {
    event.preventDefault();
    const saveState = form.querySelector(".save-state");
    const saveButton = form.querySelector(".save-review");
    saveButton.disabled = true;
    saveState.textContent = "保存中…";
    try {
      const response = await fetch("/api/review", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ candidateId: candidate.id, status: selectedStatus, rating: rating.value ? Number(rating.value) : null, note: note.value }),
      });
      if (!response.ok) throw new Error("保存できませんでした");
      const result = await response.json();
      candidate.humanReview = result.humanReview;
      saveState.textContent = "保存しました";
      renderHeader();
      setTimeout(() => { saveState.textContent = ""; }, 1800);
    } catch (error) {
      saveState.textContent = error.message;
    } finally {
      saveButton.disabled = false;
    }
  });
  return fragment;
}

function render() {
  const items = filteredItems();
  renderHeader();
  renderIntro(items);
  elements.grid.replaceChildren(...items.map(({ batch, candidate }) => renderCard(batch, candidate)));
  elements.empty.hidden = items.length > 0;
  renderCompare();
}

function toggleCompare(id, checkbox) {
  if (checkbox.checked && state.compare.size >= 3) {
    checkbox.checked = false;
    alert("比較できるのは3案までです。");
    return;
  }
  checkbox.checked ? state.compare.add(id) : state.compare.delete(id);
  renderCompare();
}

function renderCompare() {
  const selected = allCandidates().filter(({ candidate }) => state.compare.has(candidate.id));
  elements.compareTray.hidden = selected.length === 0;
  elements.compareItems.innerHTML = selected.map(({ candidate }) => `
    <div class="compare-item">
      <img src="${imageUrl(candidate)}" alt="" />
      <div><strong>${escapeHtml(candidate.titleJa)}</strong><span>${escapeHtml(candidate.id)}</span><span>Codex ${candidate.codexReview.score ?? "—"} / あなた ${candidate.humanReview.rating ?? "—"}</span></div>
    </div>`).join("");
}

function openPreview(candidate) {
  elements.dialogContent.innerHTML = `<div class="dialog-preview"><img src="${imageUrl(candidate)}" alt="${escapeHtml(candidate.titleJa)}" /></div>`;
  elements.dialog.showModal();
}

document.querySelectorAll("#backdrop-control button").forEach((button) => button.addEventListener("click", () => {
  state.backdrop = button.dataset.backdrop;
  document.querySelectorAll("#backdrop-control button").forEach((item) => item.setAttribute("aria-pressed", String(item === button)));
  render();
}));
document.querySelectorAll("#scale-control button").forEach((button) => button.addEventListener("click", () => {
  state.scale = button.dataset.scale;
  document.querySelectorAll("#scale-control button").forEach((item) => item.setAttribute("aria-pressed", String(item === button)));
  render();
}));
elements.batchFilter.addEventListener("change", () => { state.batch = elements.batchFilter.value; render(); });
elements.statusFilter.addEventListener("change", () => { state.status = elements.statusFilter.value; render(); });
elements.search.addEventListener("input", () => { state.query = elements.search.value.trim(); render(); });
elements.clearCompare.addEventListener("click", () => { state.compare.clear(); render(); });
function closeDialog() {
  elements.dialog.querySelector("iframe")?.setAttribute("src", "about:blank");
  elements.dialog.close();
}
elements.closeDialog.addEventListener("click", closeDialog);
elements.dialog.addEventListener("click", (event) => { if (event.target === elements.dialog) closeDialog(); });

try {
  const response = await fetch("/api/manifest");
  if (!response.ok) throw new Error(`HTTP ${response.status}`);
  state.manifest = await response.json();
  renderBatchFilter();
  renderPalette();
  render();
} catch (error) {
  elements.grid.innerHTML = `<div class="empty">素材台帳を読み込めませんでした: ${escapeHtml(error.message)}</div>`;
}
