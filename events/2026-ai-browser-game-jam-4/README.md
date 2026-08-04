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
4. **PROJECT CHARGE** — a mechanical-beast hunting clicker about six-cell synchronization, risk-managed discharge, an eight-node skill tree, and stolen cores that permanently change the build.

The four concepts share one web build and launcher so they can be compared under identical conditions. The original three are complete vertical slices. PROJECT CHARGE has been rebuilt around six visible mechanical-beast battles: any three hunts lead to a chosen normal boss and ending, while the remaining beasts, enhanced boss, and ARCH SINGULARITY form its optional true route.

## Next concept: CHARGE! active clicker

The next candidate is a 20-minute active clicker built around six charge cells, player-selected circuit stages, and a complete normal ending that can continue into an approximately one-hour true route.

- [Game design document](docs/CHARGE_CLICKER_GDD.md)
- [Current v3 mechanical-beast specification](docs/PROJECT_CHARGE_V3_GDD.md)
- [Production and validation plan](docs/CHARGE_CLICKER_PRODUCTION_PLAN.md)
- [Current playtest guide](docs/PROJECT_CHARGE_PLAYTEST.md)
- [PixelLab style and prompt brief](docs/PIXELLAB_STYLE_BRIEF.md)
- [UI Identity / anti-AI pass](docs/UI_IDENTITY_PASS.md)

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

- Choose any three of six mechanical beasts, defeat one of two abyssal bosses, and reach the normal ending. Continue with the same build through the remaining hunts, enhanced boss, and ARCH SINGULARITY for the true ending.
- Hold the large **CHARGE** button, `Space`, or the configured primary gamepad button to fill six cells.
- Press **DISCHARGE**, `Enter` / `X`, right-click, or the configured secondary gamepad button to turn stored energy directly into damage.
- A partial discharge is safe. Filling all six cells triggers a large synchronization bonus.
- Continue charging after all six cells are full to raise the Overcharge multiplier. Excess heat causes a meltdown and removes most stored energy.
- Toggle slow automatic charging with `A` or the configured active-ability button.
- Damage awards mechanical scrap, making every attack feed immediately into the skill tree.
- Buy one of eight three-rank skills by clicking/tapping it or pressing `1`–`8`. Raising a predecessor to LV2 unlocks the next node.
- On gamepad, navigate upgrades with the D-pad and purchase the selected upgrade with `Start / Options`.
- Respec the full tree for free from the hunt map with `T` or gamepad `Start / Options`.
- Each beast changes the optimal rhythm: cracking armor manually, breaking a shell with six-cell sync, thermal redlining, severing heads through discharge chains, marking drones for AUTO purge, or reading critical windows.
- Every defeated beast grants a named core automatically. Its rule becomes a permanent player ability for later battles.
- GRID LEECH warns before draining the fullest cell. THERMAL TITAN suppresses cooling and becomes vulnerable at high heat. The true boss rotates through three trials based on all six systems.
- Progress, scrap, skill ranks, acquired cores, and the current hunt save automatically and resume after closing the browser.
- Use the arrow keys, D-pad, or left stick on maps and the skill tree. Ending results can be copied with `C` or the configured active-ability button.
- To erase the full campaign and start over, press `R` twice within the three-second confirmation window.

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

Export a local browser build:

```bash
mkdir -p build/web
godot --headless --path events/2026-ai-browser-game-jam-4/godot \
  --export-release Web "$PWD/build/web/index.html"
```

## AI and asset disclosure

- Game concepts, GDScript implementation, testing, balancing, and documentation were created in collaboration with OpenAI Codex.
- The three original launcher/key-art images and the ZERO PERCENT CITY gameplay backdrop were created with OpenAI image generation from original prompts written for this project. PROJECT CHARGE combines procedural Godot effects with original PixelLab machinery, UI, and nine mechanical-beast candidates; prompts, API settings, generations used, and selection notes are recorded locally.
- No third-party game code, trademarked characters, or downloaded art assets are included.
- Japanese UI text uses Noto Sans JP from Google Fonts under the SIL Open Font License 1.1; the license is included at [`godot/assets/fonts/OFL-NotoSansJP.txt`](godot/assets/fonts/OFL-NotoSansJP.txt).
- Runtime visuals, particles, UI, and sound effects are generated by the Godot project itself.

Image-generation prompts and original asset provenance are recorded in [`docs/ASSET_PROVENANCE.md`](docs/ASSET_PROVENANCE.md).

## Status

The original three vertical slices are feature-complete and independently playable. PROJECT CHARGE v3 now contains six direct mechanical-beast battles, six automatically integrated cores, a branching eight-skill tree with free respec, two selectable bosses, a normal ending, continuous true route, enhanced boss, three-phase true boss, bilingual UI/results, atomic v3 saves, and mouse/touch/keyboard/remappable-gamepad navigation. Deterministic efficient-play simulations complete the normal route in about 11.5 minutes and the full true route in about 53 minutes; first-time human targets remain 18–25 and 50–70 minutes. Fifty-three PixelLab candidates have been generated and recorded, including the newly integrated first-pass art for all nine enemies. The next major milestone is the returning user playtest, followed by targeted balance and three-variant art revisions only where the in-game cast is weakest.
