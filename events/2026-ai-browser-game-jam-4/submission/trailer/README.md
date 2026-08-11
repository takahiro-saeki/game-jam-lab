# VOLT NOMAD Official Trailer

## Deliverable

- `volt-nomad-official-trailer-v2.mp4` — current gameplay-first master
- `volt-nomad-official-trailer.mp4`
- V2: 1920 x 1080, H.264 video + AAC stereo audio, 30 fps, 60 seconds
- V1: 1280 x 720, H.264 video + AAC stereo audio, 30 fps, 63 seconds
- Audio is mixed 4 dB below the Suno master to leave comfortable headroom.

V2 opens on live combat at frame one and keeps 51.5 of its 60 seconds inside
the real game before the cinematic and end card. Combat, gear-tree UI,
particles, boss presentation, and defeat effects are rendered by the game;
only progression and camera-ready states are scripted in
`godot/tools/trailer_capture.gd`.

Compose the Godot Movie Maker AVI and selected music into the upload master:

```bash
FFMPEG_BIN=/path/to/ffmpeg \
  events/2026-ai-browser-game-jam-4/tools/compose-trailer.sh \
  volt-nomad-trailer-v2-silent.avi \
  music/volt-nomad-six-core-transmission-a.mp3 \
  volt-nomad-official-trailer-v2.mp4
```

## Music

Selected master: **VOLT NOMAD — Six-Core Transmission Trailer 64s (A)**

- [Suno A — selected](https://suno.com/song/27da6b2a-4bd7-4735-9efb-f61ccb26f5ad)
- [Suno B — alternate](https://suno.com/song/7ccdff3d-e72c-4b82-915d-6f432c15df31)

Both original MP3 files are preserved in `music/`. A was selected because its
clear quiet/loud transitions align better with the map, skill-tree, world-engine,
PRIME CURRENT, and logo beats.

### Suno prompt

> 60–70 SECOND INSTRUMENTAL GAMEPLAY TRAILER CUE for VOLT NOMAD, target 1:04,
> 138 BPM, F-sharp minor. No intro: immediate four-note glass-metal signal and
> electrical heartbeat; at 0:04 precise piston percussion; 0:13 active-clicker
> pulse and cyan arpeggios; 0:22 five interlocking synthetic voices with no
> vocals; 0:30 massive world-engine drums; 0:37 darker violet bass and rising
> polyrhythm; 0:44 fallen-seraph climax with choir-like synthesizers but
> absolutely no human voices; 0:50 fractured collapse hits and a half-second
> breath; 0:55 transformed hopeful motif; decisive logo hit near 1:00 with a
> clean short tail. Premium pixel-action sci-fi game trailer, crisp transients,
> controlled dynamics, memorable motif, space for UI SFX. No vocals, lyrics,
> spoken word, long ambient intro, generic cyberpunk club beat, wall-of-sound
> compression, fade-out, or extra song section.

## Beat sheet

| Time | Visual |
| --- | --- |
| 00:00 | Fresh Gearmaw combat: click → damage → CHARGE |
| 00:04 | Upgraded Gearmaw combat: manual and AUTO acceleration |
| 00:10 | Five interlocking gear trees |
| 00:16 | Six-beast route selection |
| 00:21 | Relay Hydra alternate hunt |
| 00:27 | ARCH SINGULARITY |
| 00:34 | PRIME CURRENT form I |
| 00:40 | PRIME CURRENT form III |
| 00:47 | PixelLab defeat-collapse effects |
| 00:51 | PRIME CURRENT cinematic art |
| 00:55 | Final title and itch.io URL |

itch.io accepts a YouTube or Vimeo URL for its trailer field, not a direct MP4
upload. Upload this MP4 to one of those services, then paste the resulting URL
into the project editor.
