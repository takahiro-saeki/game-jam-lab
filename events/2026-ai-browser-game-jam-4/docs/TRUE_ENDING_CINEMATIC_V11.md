# VOLT NOMAD — TRUE ENDING CINEMATIC v11

Status: **Human Review approved — all four illustrations formally adopted on 2026-08-07.**

## Artwork archive

- Defeating PRIME CURRENT form three permanently unlocks `ARTWORK` on the title screen. Skipping the cinematic or credits does not prevent the unlock.
- The unlock lives in persistent hunt records rather than campaign progression, so starting a new hunt never removes it. Existing complete-clear saves migrate automatically from `final_boss_defeated`.
- The archive presents all four approved illustrations with bilingual scene notes, fullscreen viewing, three zoom levels, optional hidden UI, keyboard/controller/touch navigation, and full true-ending replay.
- Artwork is a post-clear reward and does not add items to upgrade, achievement, or completion-rate totals.

## Runtime structure

- 8 narrative scenes, 6.5–8.0 seconds each, approximately 57 seconds total.
- Scenes advance automatically; confirm/click advances early and back/escape skips.
- Godot adds slow pan, zoom, fade, bilingual captions, progress segments, and then opens the scrolling credits automatically.
- During the true credits, the four illustrations continue cycling at low brightness behind the text.
- Images ship as 1280×720 PNGs. No video codec or streamed media is required.

## Generated illustration prompt set

All four images used OpenAI built-in image generation in `stylized-concept` mode. Existing PixelLab PNGs were supplied as character design references. Every prompt required a 16:9 cinematic composition, a dark caption-safe area, no embedded text/UI/logo/watermark, and preservation of the referenced silhouettes and colors.

### SILENCE BELOW

- References: VOLT NOMAD and ARCH SINGULARITY.
- Scene: the stopped world engine hangs inside a colossal subterranean mechanical cathedral while released cyan, amber, and violet current rises like memory.
- Composition: hero in the foreground, ARCH at immense scale, deep navy negative space for captions.
- Mood: sacred stillness after battle, melancholy but hopeful.
- Output: `godot/assets/charge_clicker/ending/ending-silence-below-v11.png`.

### MEMORY OF COLOSSI

- References: VOLT NOMAD, GRID LEECH, and THERMAL TITAN.
- Scene: the two damaged mechanical beasts appear as recovered guardian memories inside a subterranean archive rather than attacking.
- Composition: both colossi dominate the chamber behind the smaller protagonist; dark caption-safe right side.
- Mood: elegiac revelation with cyan memory light and restrained furnace embers.
- Output: `godot/assets/charge_clicker/ending/ending-memory-colossi-v11.png`.

### THE CURRENT REMEMBERS

- References: VOLT NOMAD and FALLEN MACHINE SERAPH.
- Scene: in the silent aftermath, the slender dark seraph descends with broken wings while its current divides into memories instead of exploding.
- Composition: strong scale contrast, hero and seraph readable in profile, dark mechanical cathedral around them.
- Mood: solemn release, cyan current, violet heart glow, and one warm beam from above.
- Output: `godot/assets/charge_clicker/ending/ending-current-remembers-v11.png`.

### CORE OF DAWN

- Reference: VOLT NOMAD.
- Scene: the hero ascends from the last subterranean gate toward a natural dawn while six recovered core lights orbit quietly.
- Composition: hero left of center, dark machinery transitioning to a spacious warm horizon suitable for final credits.
- Mood: cathartic, restrained, and peaceful rather than triumphant.
- Output: `godot/assets/charge_clicker/ending/ending-core-dawn-v11.png`.
