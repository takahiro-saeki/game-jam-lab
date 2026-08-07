# Asset provenance

## 2026-08-06 — PRIME CURRENT v8

- PixelLab API (`pixen`) で本当のラスボス3形態を各3案、合計9枚を生成。第3形態の闇王再設計3案を追加し、最終ボス候補は合計12枚。
- レビューバッチ: `v8-final-boss-form-1`, `v8-final-boss-form-2`, `v8-final-boss-form-3`。
- 暫定ゲーム採用: `final-crownless-reliquary-v8-b.png`, `final-null-cathedral-radial-v8-a.png`, `final-first-current-singular-v8-c.png`。
- 残り6枚も人間レビューと差し替え比較のためリポジトリ内に保持。
- 生成プロンプト、Codex評価、Human Review欄は `tools/art-review/data/review-manifest.json` に保存。
- 第3形態の再設計要望を受け、細身の闇王を軸に追加3案を `v8-final-boss-form-3-dark-king` で生成。ゲームへの差し替えはHuman Review確定後に行う。
- さらに単体人型のスケール不足を解決するため、OpenAI built-in image generationで「日蝕王」「無限王座」「闇堕機天使」の高解像度アートリファレンス3枚を生成し、`docs/art-direction/` に保存。その方向をPixelLab `pixen` の384px透過素材3案 `v9-final-boss-scale-concepts` へ翻訳した。
- PRIME CURRENTのPixelLab候補は初回9枚、細身闇王3枚、スケール再設計3枚の合計15枚。Human Reviewで `final-fallen-machine-seraph-v9-c.png` が評価5・正式採用され、灰色生成背景だけを除いた `final-fallen-machine-seraph-v9-c-cutout.png` を第3形態と真エンディング紙芝居へ統合済み。

## 2026-08-07 — AUTO VFX / OVERLIMIT UI v10

- PixelLab API (`pixen`) でAUTO攻撃3案（192×96）とOVERLIMIT復旧UI3案（256×128）を生成。
- `auto-vfx-arc-lance-v10-a.png`, `auto-vfx-gatling-packet-v10-b.png`, `auto-vfx-horizon-spike-v10-c.png` は標準 / GATLING / RAILの各射撃としてGodotへ統合。
- 復旧UIは `overlimit-socket-seraph-lock-v10-c.png` を共通紋章へ採用。残る2案は未加工API出力のまま比較履歴に保持。
- バッチ、プロンプト、API usage、Codex選考、Human Review欄は `v10-auto-vfx-overlimit-ui` に保存。

Generated with OpenAI's built-in image generation tool on August 1, 2026. The outputs were resized to 1280px-wide JPEGs for the Godot Web build. Generated images contain no requested text, logos, trademarks, or franchise elements.

The Japanese and Latin body UI typeface is [Noto Sans JP](https://github.com/google/fonts/tree/main/ofl/notosansjp). Device labels and display headings use [DotGothic16](https://github.com/google/fonts/tree/main/ofl/dotgothic16). Both are distributed through Google Fonts under the SIL Open Font License 1.1; font files and license copies are stored in `godot/assets/fonts/`.

## PROJECT CHARGE — PixelLab exploration and mechanical-beast production pass

Eighty-nine original pixel-art candidates were generated through PixelLab API v2 on August 2–7, 2026. The first 26 consist of five 192×192 transparent reactor candidates, three 320×180 generator-chamber candidates, three 96×144 transparent charge cells, three 192×192 transparent GRID WRAITH candidates, three 64×64 transparent energy-shard icons, and nine 64×64 transparent control emblems for CHARGE, DISCHARGE, and AUTO OFF. The UI Identity pass added 18 transparent machine-housing candidates: three 384×128 upgrade racks, three 384×128 three-part control kits, six 320×80 GRID WRAITH gauge attempts, and six 192×96 shard-accumulator attempts. The v3 hunt pass added one 256×256 transparent first-pass sprite for each of six mechanical beasts, two normal bosses, and the true boss. The v5 visual-identity pass added three 192×192 protagonist concepts, fifteen 96×96 five-gear emblems, and nine 320×180 region backgrounds. The v6 refinement pass added three slimmer 192×192 protagonist candidates. The v10 combat polish pass added three 192×96 AUTO projectile effects and three 256×128 OVERLIMIT UI concepts. Each successful request consumed one subscription generation. No generated pixels were manually edited during these exploration batches.

- Untouched API outputs: `godot/assets/charge_clicker/pixellab/source/`
- Full prompts, settings, usage, scores, and review decisions: `tools/art-review/data/review-manifest.json`
- Current provisional reactor: `reactor/reactor-hex-a.png`
- Current provisional environment: `environment/environment-machine-room-a.png`
- Current provisional charge cell: `cell/cell-hex-capsule-a.png`
- Current provisional GRID WRAITH: `boss/wraith-manta-siphon-a.png`
- Current provisional energy shard after human review: `icon/shard-coil-spark-a.png`
- Current provisional CHARGE emblem: `control/charge-piston-a.png`
- Current provisional DISCHARGE emblem: `control/discharge-wave-a.png`
- Current provisional AUTO OFF emblem: `control/auto-stopped-rotor-a.png`
- Current provisional upgrade rack: `ui/upgrade-rack-switchboard-a.png`
- Current provisional control-frame kit: `ui/control-kit-switchboard-a.png`
- Current human-selected GRID WRAITH gauge: `ui/wraith-gauge-switchboard-a.png`
- Current human-selected shard accumulator: `ui/shard-accumulator-corrupted-b.png`
- Integrated hunt cast: `enemy/beast-gearmaw-a.png`, `beast-vaultback-a.png`, `beast-pyre-wyrm-a.png`, `beast-relay-hydra-a.png`, `beast-swarm-matriarch-a.png`, and `beast-phase-mantis-a.png`
- Integrated bosses: `enemy/boss-grid-leech-v3-a.png`, `boss-thermal-titan-a.png`, and `boss-arch-singularity-a.png`
- Integrated human-selected v6 protagonist: `protagonist/protagonist-volt-nomad-v6-a.png`
- Integrated v5 gear emblems: `gear/gear-striker-piston-a.png`, `gear-dynamo-flywheel-a.png`, `gear-autogun-rail-a.png`, `gear-drone-crown-a.png`, and `gear-core-cradle-a.png`
- Integrated v5 region backgrounds: `environment/bg-scrap-ossuary-a.png`, `bg-geo-pressure-foundry-a.png`, and `bg-biocrystal-observatory-a.png`

The first eight provisional machinery selections are rendered in the game for an in-context quality check but have not been copied to `approved/`. Human review selected the switchboard control kit and gauge plus the corrupted blank shard accumulator; those three are now integrated into Godot. The switchboard upgrade rack is integrated as an explicitly replaceable provisional selection because its alternate received only a hold rating. All nine hunt sprites are likewise integrated as first-pass candidates so silhouette and rule readability can be judged in the real map and combat layout before additional generations are spent. Human-reviewed selections now provide the v6 Volt Nomad protagonist, five v5 gear emblems, and three v5 encounter regions; untouched alternates stay reviewable. The Phase Mantis wing count, Thermal Titan's humanoid silhouette, and Twin-Rail Autogun silhouette remain explicit refinement targets. Every alternate and prompt remains selectable in the local review board, preserving an auditable generation and selection history.

## PROJECT CHARGE — Suno soundtrack

Five original instrumental tracks were generated in the user's Suno account under the creator name `NeoN Lament` on August 5, 2026, then selected by the user after A/B listening. Exact source URLs and song IDs are recorded in [`SUNO_MUSIC_BRIEF.md`](SUNO_MUSIC_BRIEF.md) and embedded in the Ogg metadata.

On August 6, 2026, twelve additional instrumental candidates were generated as A/B pairs for the six encounters that did not yet have an exclusive track: VAULTBACK, PYRE WYRM, RELAY HYDRA, SWARM MATRIARCH, PHASE MANTIS, and GRID LEECH. Because Suno's automatic duration produced several clips that were too short for gameplay, a second pass used Advanced mode, Instrumental, explicit seamless-loop language, and a custom 3:00 duration. That pass generated twelve candidates plus four rerolls for two early-ending outputs. The user selected VAULTBACK A, PYRE WYRM B, RELAY HYDRA A, SWARM MATRIARCH A, PHASE MANTIS B, and GRID LEECH A. Those six selected WAV masters now ship as processed Ogg derivatives, giving all nine enemy encounters a unique track and bringing the soundtrack to eleven runtime tracks including map and ending music. Exact prompts, durations, source URLs, rejected short outputs, and song IDs are recorded in [`SUNO_MUSIC_BRIEF.md`](SUNO_MUSIC_BRIEF.md).

- Untouched masters: 48 kHz / 16-bit / stereo WAV downloads retained outside the repository by the user.
- Shipped derivatives: `godot/assets/audio/project_charge/*.ogg`.
- Processing: fixed per-track gain to approximately -18 LUFS, Ogg Vorbis quality 5, no stems, remixing, or generated vocals.
- Runtime use: full-track looping, 0.85-second scene crossfades, and an additional -10 dB BGM playback level so synthesized attacks and alarms remain readable.

## ZERO PERCENT CITY

Saved as `godot/assets/keyart/zero-percent-city.jpg`.

```text
Use case: stylized-concept
Asset type: game title and launcher key art
Primary request: ZERO PERCENT CITY, a tiny battery-powered maintenance robot exploring a vast abandoned neon machine city, almost out of energy, finding a glowing charging station while rain falls
Scene/backdrop: layered cyber-industrial city interior with cables, broken platforms, distant machinery, deep silhouettes
Subject: one small expressive maintenance robot with a visible low-battery core, facing a cyan charging beacon
Style/medium: premium 2D game concept art with crisp pixel-art-inspired shapes, modern indie game polish, readable silhouettes
Composition/framing: cinematic landscape 16:9, robot in lower foreground, charging beacon as focal point, open dark space suitable for UI overlay
Lighting/mood: lonely but hopeful, cyan and amber emissive light, deep navy shadows, light rain particles
Color palette: midnight navy, electric cyan, warning amber, restrained magenta
Constraints: no text, no logo, no watermark, no photorealism, no extra characters, no recognizable franchise elements
```

Gameplay background saved as `godot/assets/keyart/zero-percent-city-gameplay.png`.

```text
Use case: production gameplay backdrop
Asset type: wide side-scrolling pixel-art environment
Primary request: an abandoned near-future megacity after a total energy collapse, with distant towers, broken elevated rail, antennas, emergency lights, violet haze, and wet streets far below
Style/medium: crisp limited-palette 16-bit/32-bit pixel art with cinematic depth
Composition/framing: 16:9, quiet central gameplay space and foreground silhouettes restricted to the lower edge so interactive geometry remains readable
Color palette: near-black navy, deep teal, electric cyan, restrained violet and amber
Constraints: no characters, enemies, gameplay platforms, logos, words, UI, borders, or recognizable franchise elements
```

## CHARGEBACK

Saved as `godot/assets/keyart/chargeback.jpg`.

```text
Use case: stylized-concept
Asset type: game title and launcher key art
Primary request: CHARGEBACK, a sentient futuristic credit card hero defending a person from an overwhelming wave of fraudulent digital invoices, subscriptions, hidden fees, and red warning transaction panels
Scene/backdrop: surreal neon financial cyberspace with abstract payment terminals and cascading receipts
Subject: one bold anthropomorphic credit card-shaped guardian projecting a circular refund shield against incoming red invoice shards
Style/medium: premium 2D indie game concept art, graphic editorial illustration mixed with polished card-game visuals, crisp readable shapes
Composition/framing: cinematic landscape 16:9, central guardian, incoming threats from upper background, clean dark areas suitable for UI overlay
Lighting/mood: clever, energetic, defiant, playful corporate satire
Color palette: deep charcoal, mint green, cream, coral red, electric gold
Constraints: no readable text, no numbers, no real company logos, no trademarks, no watermark, no extra characters, no photorealism
```

## CAPACITOR DEFENSE

Saved as `godot/assets/keyart/capacitor-defense.jpg`.

```text
Use case: stylized-concept
Asset type: game title and launcher key art
Primary request: CAPACITOR DEFENSE, a glowing power-core fortress sending visible packets of electricity through a branching circuit network to futuristic defense towers while waves of small machines advance along a winding path
Scene/backdrop: dark tabletop-like techno battlefield built from circuit-board terrain, clear network nodes and luminous cables
Subject: central cyan reactor, several capacitors visibly storing charge, two distinct arc towers firing coordinated electric beams
Style/medium: premium 2D indie strategy game concept art, isometric graphic illustration, crisp readable shapes, polished game-board clarity
Composition/framing: cinematic landscape 16:9, network flows from one side through the center, enemy path clearly separated, open dark margins suitable for UI overlay
Lighting/mood: strategic, energized, satisfying chain reactions
Color palette: graphite black, electric cyan, violet, warm yellow charge pulses, coral enemy accents
Constraints: no text, no logos, no watermark, no photorealism, no recognizable franchise elements, keep the circuit routing visually understandable
```
