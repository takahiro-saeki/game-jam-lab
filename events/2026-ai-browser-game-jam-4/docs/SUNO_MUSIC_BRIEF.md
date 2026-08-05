# PROJECT CHARGE — Suno BGM制作ブリーフ

## 採用・実装結果（2026-08-05）

全5用途の採用案をユーザーが試聴して確定し、SunoのWAV原音からGodot/Web用Ogg Vorbisへ変換した。ゲーム内では約0.85秒のクロスフェードで切り替え、全曲をループ再生する。`M`キーまたはヘッダーの `M BGM` でオン・オフでき、設定は端末へ保存される。

| 用途 | 採用曲 | 案 | Suno原曲 | ゲーム用ファイル | 長さ |
|---|---|---:|---|---|---:|
| 地図・ツリー・ボス選択 | Subterranean Hunt | B | [38e390e5](https://suno.com/song/38e390e5-211a-42c6-bba1-9d0bae8d8c4a) | `subterranean_hunt.ogg` | 2:18 |
| 六体の通常戦 | Piston Hunt Loop | A | [e8a9630a](https://suno.com/song/e8a9630a-0232-4f61-a5cb-965fa47adb97) | `piston_hunt_loop.ogg` | 2:54 |
| 通常・強化ボス | Forge of Breakpoints | B | [939de7cd](https://suno.com/song/939de7cd-8c5b-45cf-bd1c-083f2e424ffb) | `forge_of_breakpoints.ogg` | 2:19 |
| 真ボス | Arch Singularity | A | [79144c1c](https://suno.com/song/79144c1c-bc79-4873-a200-01cbe32b80e0) | `arch_singularity.ogg` | 2:11 |
| 通常・真エンディング | Core of Dawn | A | [d196ebaf](https://suno.com/song/d196ebaf-3d80-4a38-8881-b3b0fba76023) | `core_of_dawn.ogg` | 2:20 |

原音は48 kHz / 16-bit / stereo WAV。波形のダイナミクスを変える再圧縮型ノーマライズは避け、曲ごとの固定ゲインで約 -18 LUFSへ統一してからVorbis quality 5へ変換した。変換後は -18.0〜-18.1 LUFS、合計約12.3 MiB。元WAVはリポジトリへ含めず、各Oggのメタデータにタイトル、作者名 `NeoN Lament`、Suno song IDを保存している。

## 共通方針

- すべて **Instrumental / ボーカルなし**。
- 16-bit風の音色だけに寄せず、重い機械打楽器と現代的な電子音を混ぜる。画面のピクセルアートに対して音は一段上のスケール感を出す。
- メロディを詰め込みすぎず、クリック音・AUTO射撃・ボス警告が聞こえる中域の余白を残す。
- 曲頭と曲末を大きく盛り上げず、編集でシームレスループにしやすい構造にする。
- 各プロンプトはまず2案ずつ生成し、可能ならWAVで保存する。ゲームには後で音量を揃えたOGGを組み込む。

## 1. 地図・強化画面 — `pc_map_abyssal_relay`

用途: 討伐地図、ギアツリー、通常のメニュー。2〜3分ループ。

**Suno prompt**

> Instrumental dark mechanical exploration music for an underground robot-beast hunting game. 92 BPM, D minor, patient half-time pulse, muted analog sequencer, deep electrical sub bass, sparse found-metal percussion, distant turbine drones, delicate glassy arpeggios that suggest stored charge, one restrained four-note heroic motif, mysterious but purposeful rather than horror. Leave generous midrange space for UI clicks and machinery sound effects. Clear loop-friendly A-B-A structure, steady energy, no dramatic intro or final cadence, premium indie game soundtrack, detailed but not busy.

## 2. 機械魔獣戦 — `pc_hunt_pulse_engine`

用途: 六体の通常戦。2〜3分ループ。

**Suno prompt**

> Instrumental kinetic electro-industrial battle loop for a stylish pixel-art clicker about charging a humanoid machine and hunting mechanical beasts. 132 BPM, E Phrygian, syncopated piston drums, dry metallic impacts, distorted but controlled synth bass, bright cyan-like pulse arpeggio, short call-and-response between a compact lead synth and low brass-like machine stabs. Continuous forward motion with small eight-bar intensity waves so repeated clicking feels rewarding. Aggressive and focused, not chaotic, keep the center frequency range open for attack sounds, seamless loop shape, no long intro, no ending flourish.

## 3. 通常ボス・強化ボス — `pc_boss_furnace_protocol`

用途: GRID LEECH、THERMAL TITAN、強化ボス。3分程度。

**Suno prompt**

> Instrumental mechanical boss battle music, 146 BPM, C minor, massive furnace percussion, hydraulic kick pattern, tense asymmetric seven-against-four accents over a stable four-four pulse, growling modular bass, warning-siren synth motif transformed into a heroic response, brief dropouts that make armor-break and overdrive windows feel explosive. Escalating industrial power without becoming noisy, memorable boss identity, wide low end and crisp transients, room for gameplay sound effects, loopable development with no conclusive ending, modern game soundtrack production.

## 4. 真ボス — `pc_trueboss_arch_singularity`

用途: ARCH SINGULARITY三相。4分前後。最優先曲。

**Suno prompt**

> Instrumental final boss suite for ARCH SINGULARITY, an ancient world-engine awakening beneath the earth. 154 BPM, F sharp minor, three clearly connected phases inside one track: first cold clockwork polyrhythms and a six-note synthetic ritual motif, second overwhelming distorted machinery with rapid percussion and rising choir-like synthesizers but no voices, third luminous high-register arpeggios and a transformed heroic version of the motif over enormous half-time drums. Futuristic sacred machinery, desperate but triumphant, strong rhythmic clarity for an active clicker, avoid wall-of-sound compression, preserve space for attacks and alarms. Designed so each phase section can be cut into a loop; end on sustained mechanical tension rather than a final chord.

## 5. エンディング — `pc_ending_core_dawn`

用途: 通常エンド・真エンド結果画面。1.5〜2分。

**Suno prompt**

> Instrumental reflective ending music for a lone humanoid automaton that has inherited the cores of defeated mechanical beasts. 78 BPM, D major with traces of B minor, warm analog pads, soft struck metal, slow electrical heartbeat, intimate synthetic piano, the same restrained four-note heroic motif now complete, bittersweet underground dawn rather than celebration. Minimal percussion, spacious mix, emotional but unsentimental, suitable beneath result statistics, gentle loopable tail and no abrupt final hit.

## 生成時に避けたい要素

各曲で指定できる場合は、次を除外する。

> vocals, lyrics, spoken word, orchestral trailer clichés, generic cyberpunk nightclub, cheerful chiptune, lo-fi hiss, excessive sidechain pumping, constant risers, huge cinematic impacts every bar, comedy, retro game cover melody, copyrighted character themes

## 初回の生成優先順位

1. 真ボス曲を2案
2. 通常戦を2案
3. 地図・強化画面を2案
4. 通常ボスを2案
5. エンディングを1〜2案

初回実装では各曲の全区間をループし、場面間をクロスフェードする。真ボス三相は同一の組曲を継続して流し、プレイテストで相転移と曲展開が大きくずれる場合のみ、専用ループ点または相別ステムへ発展させる。
