# PROJECT CHARGE — PixelLab Style Brief

> Status: 17 candidates generated; five provisional selections integrated; human approval pending
> Scope: Phase 2 style validation and first production-detail batch
> Rule: compare every candidate in the actual Godot HUD before final approval

## 1. Art direction

Industrial science-fiction pixel art with a dark reactor chamber, precise geometric machinery, and energy that changes from cyan to amber to coral as risk rises. The image should feel like a modern premium indie game while remaining legible at small scale.

Avoid generic neon cyberpunk clutter. The visual identity is a calm, nearly black machine interior interrupted by a few extremely bright charge paths.

## 2. Native specification

| Item | Specification |
|---|---|
| Base sprite grid | 48px visual units |
| Reactor source | 192×192px, transparent PNG |
| Environment source | 192×108px minimum; 320×180px preferred if the account supports it |
| Display scaling | integer scaling with nearest filtering |
| Outline | 1–2 native pixels, dark navy rather than pure black |
| Light direction | center emission plus weak top-left ambient light |
| Perspective | direct front view for reactor; shallow front-facing chamber for background |
| Maximum working palette | 16 colors before effects |
| Text | never baked into an image |

## 3. Locked palette

| Role | Hex |
|---|---|
| Deep background | `#09111F` |
| Panel navy | `#111D31` |
| Raised surface | `#182B43` |
| Primary charge | `#4DEEEA` |
| Secondary charge | `#3A86FF` |
| Automation | `#9B5DE5` |
| Full charge | `#FFB703` |
| Danger | `#FF5C5C` |
| Stable system | `#55EFC4` |
| Highlight | `#F5F0DB` |

PixelLab may introduce a few transition colors, but the dominant hues must stay close to this palette.

## 4. Reactor trial

Generate three candidates. They must share the same prompt and settings; only the emphasized silhouette changes.

### Shared prompt

```text
A front-facing circular industrial energy reactor for a science-fiction power station, centered and perfectly symmetrical, six clearly readable radial capacitor chambers around one dark central core, cyan electric conduits, restrained amber warning lights, heavy dark navy machine casing, premium 16-bit pixel art, crisp clusters, limited palette, high silhouette readability, isolated object on transparent background, no floor, no scenery, no character, no text, no numbers, no logo, no watermark, no blur, no antialiasing
```

### Candidate variations

1. **Turbine** — emphasize six turbine-like vanes and a compact center.
2. **Containment ring** — emphasize concentric rings and a suspended core.
3. **Hex core** — emphasize a hexagonal center connected to six round capacitor pods.

### Approval checks

- Six-fold structure is recognizable at 96×96 display size.
- The center remains readable underneath the procedural charge ring.
- Cyan, amber, and coral Godot effects remain visible on top.
- The sprite works on both `#09111F` and `#111D31`.
- It does not resemble an existing franchise prop or logo.

## 5. GENERATOR CORE environment trial

Generate two candidates after choosing the reactor silhouette.

### Prompt

```text
Wide interior of a colossal abandoned generator chamber built around an unseen circular reactor, front-facing 2D game backdrop, layered steel ribs, six heavy power conduits leading toward the center, dark maintenance gantries at the bottom edge, sparse cyan emergency current, a few restrained amber warning lamps, deep navy shadows, premium 16-bit pixel art, crisp limited-color clusters, atmospheric depth without visual clutter, large calm central negative space for gameplay UI, no characters, no enemies, no text, no numbers, no logo, no watermark, no interface, no foreground objects blocking the center, no blur, no antialiasing
```

Variations:

1. **Cathedral scale** — tall ribs and a monumental, quiet silhouette.
2. **Dense machine room** — more conduits and panels, while preserving the central quiet area.

### Approval checks

- UI text remains readable at 20–35% image opacity.
- Bright background pixels do not compete with energy cells or the boss warning.
- Horizontal and vertical edges survive nearest-neighbor scaling.
- Cropping to 16:9 does not remove the six-conduit motif.

## 6. Integration plan

1. Save untouched PixelLab downloads under `godot/assets/charge_clicker/pixellab/source/`.
2. Save approved, manually cleaned files under `godot/assets/charge_clicker/pixellab/approved/`.
3. Record prompts, generation date, tool, dimensions, and any edits in `ASSET_PROVENANCE.md`.
4. Import with nearest filtering and no mipmap smoothing.
5. Render the reactor behind the procedural rings at 1×, 2×, and gameplay scale.
6. Render the environment at 20%, 30%, and 40% opacity and compare UI contrast.
7. Approve or reject in the 1280×720 Godot capture before generating animations.

## 7. Generation budget for Phase 2

- Reactor: maximum 3 initial generations plus 2 focused revisions.
- Environment: maximum 2 initial generations plus 1 focused revision.
- After the gameplay gate passes, generate only three candidates per new production category before requesting human review.

The gameplay gate passed before the cell, mini-boss, and currency batches began. The three-candidate limit prevents art volume from hiding unresolved gameplay or causing unnecessary style drift.

## 8. Phase 2 review result — August 2, 2026

The complete prompts, API settings, generation usage, Codex scores, and human-review fields live in [`../tools/art-review/data/review-manifest.json`](../tools/art-review/data/review-manifest.json).

### Reactor

| Rank | Candidate | Score | Decision |
|---:|---|---:|---|
| 1 | Hex Core A | 91 | Provisional selection; exactly six readable pods |
| 2 | Containment Ring A | 84 | Strong alternate; reads closer to eight directions |
| 3 | Turbine A | 78 | Energetic but outer attachments weaken the six-part read |
| 4 | Hex Core C — Heavy Industry | 74 | Focused revision produced eight outer nodes |
| 5 | Hex Core B — Clean Cluster | 68 | Focused revision collapsed to four pods |

### Environment

| Rank | Candidate | Score | Decision |
|---:|---|---:|---|
| 1 | Dense Machine Room A | 90 | Provisional selection; six conduits and useful central void |
| 2 | Cathedral Scale A | 83 | Strong alternate; busier radial structure |
| 3 | Six-Conduit Machine Room B | 77 | Focused revision produced eight conduits and too much brown |

### Charge cell module

| Rank | Candidate | Score | Decision |
|---:|---|---:|---|
| 1 | Hex Capsule Cell | 94 | Provisional selection; quiet meter window and shared hex language |
| 2 | Industrial Rail Cell | 88 | Strong machinery read; upper dial competes with status UI |
| 3 | Vacuum Tube Cell | 84 | Premium prop, but its bright inner tube looks pre-charged |

### GRID WRAITH

| Rank | Candidate | Score | Decision |
|---:|---|---:|---|
| 1 | Manta Siphon | 95 | Provisional selection; distinct predatory silhouette and HUD fit |
| 2 | Cable Leech | 91 | Clearest draining ability; circular form competes with the reactor |
| 3 | Broken Hex Wraith | 82 | Clear six-way structure but weak threat read at small size |

### Energy shard

| Rank | Candidate | Score | Decision |
|---:|---|---:|---|
| 1 | Faceted Core Shard | 95 | Provisional selection; retains the clearest shard silhouette at 24px |
| 2 | Hex Battery Fragment | 89 | Rich detail but resembles a coin when reduced |
| 3 | Coil Spark Fragment | 85 | Dynamic alternate better suited to a booster or component |

`Hex Core A`, `Dense Machine Room A`, `Hex Capsule Cell`, `Manta Siphon`, and `Faceted Core Shard` are provisionally rendered in Godot. The review tool can switch every candidate in all five categories inside a fixed boss-state preview. They remain source candidates—not final approved assets—until the human review is saved and the 1280×720 gameplay preview is accepted.
