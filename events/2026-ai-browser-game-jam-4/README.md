# AI Browser Game Jam 4 — CHARGE!

- **Jam:** AI Browser Game Jam 4
- **Theme:** CHARGE!
- **Development:** August 1–15, 2026
- **Engine:** Godot 4.6 / GDScript / Compatibility renderer
- **Target:** Browser, keyboard/mouse, gamepad, and touch
- **AI workflow:** OpenAI Codex for design, implementation, testing, balancing, and documentation; OpenAI image generation for key art.

## Playable concepts

1. **ZERO PERCENT CITY** — a compact battery-powered metroidvania.
2. **CHARGEBACK** — a financial deck-building roguelike where your credit limit is your life.
3. **CAPACITOR DEFENSE** — a circuit-routing tower defense driven by visible energy packets.
4. **PROJECT CHARGE** — a mechanical-beast hunting clicker where every input attacks or issues a PURE command, while five visible machines expand through 86 branching skills and permanent stolen-core synergies.

The four concepts share one web build and launcher so they can be compared under identical conditions. The original three are complete vertical slices. PROJECT CHARGE has been rebuilt around six visible mechanical-beast battles: any three hunts lead to a chosen normal boss and ending, while the remaining beasts and ARCH SINGULARITY lead to a persistent two-choice epilogue and an optional three-form ultimate boss.

## Selected concept: PROJECT CHARGE

The selected candidate is an active mechanical-beast clicker where every attack produces its own upgrade currency. A compact normal ending can continue into an expanded true route with the same build.

- [Original active-clicker concept](docs/CHARGE_CLICKER_GDD.md)
- [Previous v5 five-gear specification](docs/PROJECT_CHARGE_V5_GDD.md)
- [Previous v7 PURE COMMAND / records / Infinite specification](docs/PROJECT_CHARGE_V7_GDD.md)
- [Current v8 OVERLIMIT / PRIME CURRENT specification](docs/PROJECT_CHARGE_V8_GDD.md)
- [Archived v6 tiered-overclock specification](docs/PROJECT_CHARGE_V6_GDD.md)
- [Previous v4 direct-CHARGE specification](docs/PROJECT_CHARGE_V4_GDD.md)
- [Production and validation plan](docs/CHARGE_CLICKER_PRODUCTION_PLAN.md)
- [Current playtest guide](docs/PROJECT_CHARGE_PLAYTEST.md)
- [PixelLab style and prompt brief](docs/PIXELLAB_STYLE_BRIEF.md)
- [v5 protagonist, gear, and region selections](docs/V5_PIXEL_ASSET_REVIEW.md)
- [UI Identity / anti-AI pass](docs/UI_IDENTITY_PASS.md)
- [Suno BGM production brief](docs/SUNO_MUSIC_BRIEF.md)

## Controls

### Shared

- Select a game with `1`, `2`, `3`, the arrow keys, the gamepad D-pad/left stick, or by clicking/tapping its card. Confirm with `Enter`, `Space`, or gamepad `A`.
- Press `Esc`, gamepad `B`, or use **Game Lab** to return to the launcher.
- Japanese is selected automatically on Japanese devices. Use the language switch or press `L` / gamepad `View/Share` to change between Japanese and English.
- Open **Gamepad Setup** from the launcher (or press `F1` / `C`) to remap confirm/use, dash, attack/active ability, menu actions, back, language, and tool cycling. Duplicate assignments are swapped and changes are saved automatically. The D-pad and left stick remain dedicated to movement/navigation.

### ZERO PERCENT CITY

- Move: `A` / `D`, `←` / `→`, or gamepad D-pad/left stick
- Jump: `Space` / `Z` / `↑`, or gamepad `A` / D-pad up
- Dash after unlocking it: `X` / `Shift` / `↓`, or gamepad `X` / D-pad down
- Normal attack: `C` / `J`, or gamepad `Y`. Chain three attacks for an empowered finisher; dash impacts deal heavier damage.
- The first obstruction can be jumped normally or smashed with the newly acquired dash.
- Defeat enemies to recycle power, collect traversal modules, destroy the Core Warden, then reboot the city.
- Touch: left/right, attack, jump, and dash buttons appear on touch devices.

### CHARGEBACK

- Click/tap a card, or select one with the arrow keys / D-pad / left stick and play it with `Space` / gamepad `A`.
- Click **End Turn**, press `Enter` / `E`, or use gamepad `Start`.
- Keyboard card shortcuts: `1`–`9`.
- Choose one of three credit policies before a run. Playing two cards from one archetype triggers its synergy; playing defense, debt, and audit in one turn balances the books.
- Defeated authorizations award one of three cards, including at least one upgraded card. Press `R` or the configured active-ability button to skip a reward for credit.
- Switch Japanese/English at any time with the in-game language button, `L`, or the configured language button.

### CAPACITOR DEFENSE

- Select a tool, then click/tap a circuit socket. Keyboard: `1`–`5` or `Q` / `E`; gamepad: left/right shoulder or `X`.
- Select sockets with the arrow keys or gamepad D-pad/left stick, then build with `Space` / gamepad `A`.
- Extend cables only from a live cyan socket.
- Place at least one tower, then select **Launch Wave**, press `Enter`, or use gamepad `Start`.
- Press `F` or select the header controls for `1×`, `2×`, or `3×` simulation speed.
- Adjacent capacitors amplify towers; adjacent arc towers chain attacks. Building capacitor, arc, and pulse equipment activates network resonance.
- Deliver packets and ground hostiles to fill Overcharge, then press `R` / `V` or gamepad `Y` for five seconds of rapid-fire Overdrive.

### PROJECT CHARGE

- Choose any three of six mechanical beasts, defeat one of two abyssal bosses, and reach the normal ending. Continue with the same build through the remaining hunts, enhanced boss, and ARCH SINGULARITY. After its credits, Continue returns to a persistent choice between ascending and answering the deeper signal.
- Press the large **CHARGE ATTACK** button, `Space`, `Enter` / `X`, right-click, or the configured gamepad action. One input always produces exactly one manual command; holding a key never creates hidden auto-clicks.
- The AUTO cannon fires from the beginning and remains online while manual attacks continue; no activation purchase or toggle is required.
- Heat, cooling, meltdown, stored cells, and mandatory DISCHARGE have been removed. Enemy mechanics provide bonus windows and never erase progress.
- Spend CHARGE across five visible machines: Striker Arm, Dynamo Heart, Autogun Rig, Drone Hive, and Core Frame. Each card has a human-selected PixelLab emblem and opens its own branching skill tree; together they contain 86 nodes and 317 ranks across three technology tiers.
- The human-selected Volt Nomad is visible as the player character during every fight, with separate idle, pile-driver recoil, and PURE COMMAND feedback. Scrap Mine, Geothermal Core, and Biocircuit Crystal backgrounds switch automatically with the selected enemy.
- The Dynamo tree eventually unlocks **PURE COMMAND**. It permanently replaces the weaker direct click, generates six times the CHARGE, builds AUTO overcharge, places marks, and preserves indirect Striker command effects.
- Gatling and Rail mutations can both be completed and fuse into the Hybrid barrel. Core Frame nodes require the corresponding defeated-beast core, so hunt order changes which builds become available.
- Ten persistent hunt records cover normal campaign goals, including all 317 skill ranks. Infinite Mode is an optional CHARGE workshop with escalating waves and no exclusive achievements or wave-gated abilities.
- Open a tree by clicking one of the five gear cards, pressing `1`–`5` / `T`, or gamepad `Menu`. Navigate nodes with the D-pad, switch gear with `Q` / `E` or shoulder buttons, and purchase with `Enter` / gamepad `A`.
- TIER II unlocks after the first normal boss; TIER III unlocks after all six beast cores. ARCH SINGULARITY unlocks permanent TIER IV OVERLIMIT restoration. Switch the visible tier with `Z` / `X` or the mapped language/active button while the tree is open.
- OVERLIMIT has no equipment slots or exclusions: all five acquired rewrites remain active simultaneously. The first is free with the recovered Singularity Residue; later restorations cost escalating CHARGE and survive standard skill respec.
- Respec all five trees for free from the hunt map. Exact current and maximum enemy HP are always shown beside the percentage gauge.
- Each beast changes the optimal rhythm through positive targets: timed armor breaks, CHARGE milestones, upgrade overdrive, manual/AUTO chains, drone marking, and analysis-guaranteed criticals.
- Every defeated beast grants a named core automatically. Its rule becomes a permanent player ability for later battles.
- GRID LEECH opens a short eight-click shatter window. THERMAL TITAN exposes its furnace after twenty clicks. ARCH rotates through three bonus-driven trials. The optional PRIME CURRENT then fights across Crownless Engine, Null Cathedral, and First Current forms.
- Progress, CHARGE, upgrade ranks, acquired cores, enemy HP, and the current hunt save automatically and resume after closing the browser.
- Defeating the real final boss permanently reveals `ARTWORK` on the title screen. Its four true-ending illustrations support fullscreen viewing, three zoom levels, hidden UI, controller/touch input, and complete true-ending replay.
- Use the arrow keys, D-pad, or left stick on maps and the skill tree. Ending results can be copied with `C` or the configured active-ability button.
- The header tracks total session time. Normal and true endings expose a detailed JSON report and append it locally, while the deterministic benchmark runner records comparable automated clear times.
- Human-selected Suno tracks give the original nine enemies unique battle music plus map/tree and normal-ending themes. v8 adds selected dedicated masters for all three PRIME CURRENT forms, true credits, and the artwork gallery. World-engine credits remain an independent replaceable slot.
- To erase the campaign and start over, press `R` twice within the three-second confirmation window. Persistent hunt records remain unlocked.

## Local development

```bash
cd events/2026-ai-browser-game-jam-4/godot
godot --editor project.godot
```

Run the gameplay smoke tests:

```bash
godot --headless --path events/2026-ai-browser-game-jam-4/godot \
  -s res://tests/smoke_test.gd
```

Regenerate the deterministic PROJECT CHARGE timing report:

```bash
godot --headless --path events/2026-ai-browser-game-jam-4/godot \
  -s res://tests/project_charge_benchmark.gd
```

Export a local browser build:

```bash
mkdir -p build/web
godot --headless --path events/2026-ai-browser-game-jam-4/godot \
  --export-release Web "$PWD/build/web/index.html"
```

Build the itch.io submission ZIP. This preset adds a release-only feature that
opens PROJECT CHARGE directly while preserving the four-game launcher in the
ordinary development build:

```bash
events/2026-ai-browser-game-jam-4/tools/build-itch-project-charge.sh
```

## AI and asset disclosure

- Game concepts, GDScript implementation, testing, balancing, and documentation were created in collaboration with OpenAI Codex.
- The three original launcher/key-art images and the ZERO PERCENT CITY gameplay backdrop were created with OpenAI image generation from original prompts written for this project. PROJECT CHARGE combines procedural Godot effects with original PixelLab machinery, UI, mechanical beasts, and fifteen PRIME CURRENT form candidates including slender dark-king and world-scale refinements; prompts, API settings, generations used, and selection notes are recorded locally.
- PROJECT CHARGE uses sixteen original instrumental Suno generations selected by the user from A/B candidates. All nine original enemies and all three PRIME CURRENT forms have exclusive battle music, with separate map/tree, ending, and artwork tracks. Exact song URLs, IDs, processing, and runtime assignments are recorded in [`docs/SUNO_MUSIC_BRIEF.md`](docs/SUNO_MUSIC_BRIEF.md).
- No third-party game code, trademarked characters, or downloaded art assets are included.
- Japanese UI text uses Noto Sans JP from Google Fonts under the SIL Open Font License 1.1; the license is included at [`godot/assets/fonts/OFL-NotoSansJP.txt`](godot/assets/fonts/OFL-NotoSansJP.txt).
- Runtime visuals, particles, UI, and sound effects are generated by the Godot project itself; mastered BGM is stored as Ogg Vorbis or 48 kHz stereo MP3.

Image-generation prompts and original asset provenance are recorded in [`docs/ASSET_PROVENANCE.md`](docs/ASSET_PROVENANCE.md).

## Status

The original three vertical slices are feature-complete and independently playable. PROJECT CHARGE v8 contains six direct mechanical-beast battles, always-on AUTO fire, five dedicated gear trees with 86 standard nodes and 317 ranks, five permanent simultaneous OVERLIMIT rewrites, PURE COMMAND evolution, eight stolen cores, normal and world-engine endings, a three-form PRIME CURRENT final chapter, an eight-scene skippable true-ending slideshow, persistent achievements, optional Infinite Mode, bilingual UI/results, atomic saves, playtest telemetry, and mouse/touch/keyboard/remappable-gamepad navigation. Deterministic simulations complete the original normal/full routes in about 6.4/10.7 minutes at five inputs per second; PRIME CURRENT takes about 11.6–12.8 minutes with one OVERLIMIT or 2.7 minutes with all five in the maximum-rank benchmark. Fifteen PixelLab final-boss proposals and their reviews are recorded locally; Volt Nomad remains the approved protagonist art.
