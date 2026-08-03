# Asset provenance

Generated with OpenAI's built-in image generation tool on August 1, 2026. The outputs were resized to 1280px-wide JPEGs for the Godot Web build. Generated images contain no requested text, logos, trademarks, or franchise elements.

The Japanese and Latin body UI typeface is [Noto Sans JP](https://github.com/google/fonts/tree/main/ofl/notosansjp). Device labels and display headings use [DotGothic16](https://github.com/google/fonts/tree/main/ofl/dotgothic16). Both are distributed through Google Fonts under the SIL Open Font License 1.1; font files and license copies are stored in `godot/assets/fonts/`.

## PROJECT CHARGE — PixelLab Phase 2 and production-detail batch

Forty-four original pixel-art candidates were generated through PixelLab API v2 on August 2, 2026. The first 26 consist of five 192×192 transparent reactor candidates, three 320×180 generator-chamber candidates, three 96×144 transparent charge cells, three 192×192 transparent GRID WRAITH candidates, three 64×64 transparent energy-shard icons, and nine 64×64 transparent control emblems for CHARGE, DISCHARGE, and AUTO OFF. The UI Identity pass added 18 transparent machine-housing candidates: three 384×128 upgrade racks, three 384×128 three-part control kits, six 320×80 GRID WRAITH gauge attempts, and six 192×96 shard-accumulator attempts. Each successful request consumed one subscription generation. No generated pixels were manually edited during these exploration batches.

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

The first eight provisional selections are rendered in the game for an in-context quality check but have not been copied to `approved/`. Human review selected the switchboard control kit and gauge plus the corrupted blank shard accumulator; those three are now integrated into Godot. The switchboard upgrade rack is integrated as an explicitly replaceable provisional selection because its alternate received only a hold rating. Every alternate remains selectable in the local review board. Focused revisions were retained in the source set even when they failed their composition requirement, so the selection process and generation disclosure remain auditable.

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
