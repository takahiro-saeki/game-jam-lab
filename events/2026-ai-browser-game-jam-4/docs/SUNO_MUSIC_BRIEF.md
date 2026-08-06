# PROJECT CHARGE — Suno BGM制作ブリーフ

## 採用・実装結果（2026-08-05）

全5用途の採用案をユーザーが試聴して確定し、SunoのWAV原音からGodot/Web用Ogg Vorbisへ変換した。ゲーム内では約0.85秒のクロスフェードで切り替え、全曲をループ再生する。`M`キーで即時ミュートでき、タイトルまたはヘッダーの設定画面からMaster / BGM / SFXを個別調整できる。設定は端末へ保存される。

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

## 敵別BGM拡張（2026-08-06）

既存の `Piston Hunt Loop` はギアモウ専用、`Forge of Breakpoints` はサーマル・タイタン専用として残す。`Arch Singularity` は真ボス専用のまま維持する。以下の6曲を追加すれば、六獣・二通常ボス・真ボスの全9体が固有曲になる。

全曲共通でInstrumentalをオンにし、同じプロンプトからA/Bを1回ずつ生成する。理想は2〜3分。除外要素は上記の「生成時に避けたい要素」を共通で使用する。

### VAULTBACK — `Blue Vault Pulse`

> Instrumental mechanical beast battle theme for VAULTBACK, a colossal thunder-shell creature that stores player energy until its armor opens. 124 BPM, D minor, deep capacitor thumps, gated electrical bass, restrained breakbeat, glassy blue arpeggios that grow brighter every eight bars, heavy shell-closing metal impacts, a compact four-note PROJECT CHARGE motif emerging from the stored electricity. The groove should feel patient, pressurized and rewarding when the shell opens, not frantic. Premium modern indie game soundtrack, clear rhythmic pocket for rapid clicking and weapon SFX, loop-friendly A-B-A structure, no vocals, no final cadence.

### PYRE WYRM — `Redline Molt`

> Instrumental electro-industrial combat loop for PYRE WYRM, a furnace serpent that enters overdrive whenever the player purchases an upgrade. 142 BPM, E Phrygian dominant, dry forge hammers, coiling syncopated synth bass, rising heat pulses, short bursts of distorted guitar-like synthesizer without becoming metal music, a four-note PROJECT CHARGE motif reshaped as a red-hot warning signal. Alternate controlled pressure with brief eight-bar overdrive blooms so upgrade moments feel explosive. Crisp transients, strong low-end machinery, generous space for attack SFX, seamless loop, no vocals, no cinematic ending.

### RELAY HYDRA — `Cascade Trinity`

> Instrumental mechanical battle track for RELAY HYDRA, a three-headed bus creature powered by alternating manual and automatic attacks. 136 BPM, C sharp minor, three interlocking rhythmic voices: piston drums, staccato modular bass and bright relay-click percussion, constantly passing a four-note PROJECT CHARGE motif between left, center and right positions. Clear call-and-response phrases that build into a six-step cascading chain, energetic and clever rather than chaotic, subtle polyrhythm over a readable four-four pulse. Wide but uncluttered mix for gameplay SFX, loopable development, no vocals, no long intro or final hit.

### SWARM MATRIARCH — `Hive Command Lattice`

> Instrumental high-tech battle loop for SWARM MATRIARCH, a mechanical brood queen commanding clouds of attack drones. 148 BPM, A minor, precise micro-percussion, fast hovering rotor rhythms, elastic sub bass, small bright synth particles circling a slower authoritative lead, the PROJECT CHARGE four-note motif multiplied into a controlled swarm pattern. Sections should alternate between scattered marks and synchronized automatic volleys, elegant tactical intensity instead of noisy insect horror. Modern detailed game production, preserve midrange space for clicks and drone shots, seamless loop shape, no vocals, no triumphant ending.

### PHASE MANTIS — `Critical Parallax`

> Instrumental precision boss-like battle loop for PHASE MANTIS, a crystalline machine predator that shifts phase and rewards guaranteed critical timing. 150 BPM, F sharp minor, razor-clean broken beats, glass harmonics, phase-shifted arpeggios, sudden half-beat silences, focused synthetic bass and a four-note PROJECT CHARGE motif appearing in mirrored and displaced forms. Build tension toward recurring analysis-complete windows where the harmony snaps into perfect alignment, cerebral, dangerous and stylish, never ambient. High rhythmic clarity for active clicking, restrained distortion, loopable A-B-C-A form, no vocals and no conclusive ending.

### GRID LEECH — `Siphon Breakpoint`

> Instrumental industrial boss battle music for GRID LEECH, an abyssal machine parasite that opens a siphon core for a short eight-click break window. 146 BPM, B minor, predatory suction-like sub pulses, cable snaps, hydraulic percussion, cold cyan modular sequences and a corrupted four-note PROJECT CHARGE motif that resolves only during recurring short breakout sections. Create obvious tension-and-release cycles: compressed stalking groove, three-second opening, violent mechanical payoff, then renewed pursuit. Menacing but readable, wide low end, clean attack transients and space for alarms and rapid clicks, loopable without a final chord, no vocals.

### 採用後の割り当て

| 敵 | 曲 |
|---|---|
| ギアモウ | Piston Hunt Loop A（既存） |
| ヴォルトバック | Blue Vault Pulse（要A/B選択） |
| パイア・ワーム | Redline Molt（要A/B選択） |
| リレイ・ヒドラ | Cascade Trinity（要A/B選択） |
| スウォーム・マトリアーク | Hive Command Lattice（要A/B選択） |
| フェイズ・マンティス | Critical Parallax（要A/B選択） |
| グリッド・リーチ | Siphon Breakpoint（要A/B選択） |
| サーマル・タイタン | Forge of Breakpoints B（既存） |
| アーク・シンギュラリティ | Arch Singularity A（既存） |

### 生成済み候補（2026-08-06）

全12候補をSuno v5.5 / Advanced / Instrumentalで生成済み。A/BはSunoの生成結果順であり、現時点では未採用。

| 敵 | A | B |
|---|---|---|
| ヴォルトバック | [Blue Vault Pulse A](https://suno.com/song/a45f0023-c229-4b3a-8544-d04b5b02d971) | [Blue Vault Pulse B](https://suno.com/song/17608c80-33ae-4f71-9733-9586645deaf0) |
| パイア・ワーム | [Redline Molt A](https://suno.com/song/84c0ad31-a984-43c6-9717-f95990273a07) | [Redline Molt B](https://suno.com/song/72f2d770-04f8-4690-a59d-4916c5f40c86) |
| リレイ・ヒドラ | [Cascade Trinity A](https://suno.com/song/6c4a0e1d-5646-4dd1-94c8-27db24d85477) | [Cascade Trinity B](https://suno.com/song/9f1f8777-1341-48b3-833a-5eb82618ede4) |
| スウォーム・マトリアーク | [Hive Command Lattice A](https://suno.com/song/f8f48fd1-c68f-4c68-9858-23c796d638c9) | [Hive Command Lattice B](https://suno.com/song/f0a24f3c-83b7-4f44-ad94-155514416d8b) |
| フェイズ・マンティス | [Critical Parallax A](https://suno.com/song/4513110f-139a-478b-8fff-dba98279030d) | [Critical Parallax B](https://suno.com/song/3892aae9-541b-48f5-8bb0-9e634b46e3b7) |
| グリッド・リーチ | [Siphon Breakpoint A](https://suno.com/song/b58c5f8a-f2ab-494e-9e31-21e476bfe5d6) | [Siphon Breakpoint B](https://suno.com/song/d1aea7cd-73af-40fe-a481-9b437019e97e) |
