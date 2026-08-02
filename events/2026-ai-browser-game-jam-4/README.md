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
4. **PROJECT CHARGE** — an active clicker prototype about six-cell synchronization, safe discharge, and risky overcharge.

The four concepts share one web build and launcher so they can be compared under identical conditions. The original three are complete vertical slices. PROJECT CHARGE is being developed through separate 30-second, 5-minute, and 20-minute quality gates before its content is expanded.

## Next concept: CHARGE! active clicker

The next candidate is a 20-minute active clicker built around six charge cells, player-selected circuit stages, and a complete normal ending that can continue into an approximately one-hour true route.

- [Game design document](docs/CHARGE_CLICKER_GDD.md)
- [Production and validation plan](docs/CHARGE_CLICKER_PRODUCTION_PLAN.md)

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

- Hold the large **CHARGE** button, `Space`, or the configured primary gamepad button to fill six cells.
- Press **DISCHARGE**, `Enter` / `X`, right-click, or the configured secondary gamepad button to bank the current output.
- A partial discharge is safe. Filling all six cells triggers a large synchronization bonus.
- Continue charging after all six cells are full to raise the Overcharge multiplier. Excess heat causes a meltdown and removes most stored energy.
- Toggle slow automatic charging with `A` or the configured active-ability button.
- Buy upgrades by clicking/tapping them or pressing `1`–`8`. Unaffordable upgrades remain readable and show their required cost.
- Press `R` to reboot the current prototype.

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
- The three original launcher/key-art images and the ZERO PERCENT CITY gameplay backdrop were created with OpenAI image generation from original prompts written for this project. PROJECT CHARGE currently uses procedural Godot graphics while its PixelLab style reference is scheduled for the 5-minute vertical slice.
- No third-party game code, trademarked characters, or downloaded art assets are included.
- Japanese UI text uses Noto Sans JP from Google Fonts under the SIL Open Font License 1.1; the license is included at [`godot/assets/fonts/OFL-NotoSansJP.txt`](godot/assets/fonts/OFL-NotoSansJP.txt).
- Runtime visuals, particles, UI, and sound effects are generated by the Godot project itself.

Image-generation prompts and original asset provenance are recorded in [`docs/ASSET_PROVENANCE.md`](docs/ASSET_PROVENANCE.md).

## Status

The original three vertical slices are feature-complete and independently playable. PROJECT CHARGE Phase 1 is playable with six cells, partial and full discharge, overcharge, heat, meltdown, AUTO charging, eight upgrade paths, Japanese/English copy, and shared remappable gamepad controls. Automated smoke coverage verifies all four concepts and the active-clicker's 30-second progression targets.
