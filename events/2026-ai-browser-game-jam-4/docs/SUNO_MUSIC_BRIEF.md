# PROJECT CHARGE — Suno BGM制作ブリーフ

## 採用・実装結果（2026-08-06）

全11曲の採用案をユーザーが試聴して確定し、SunoのWAV原音からGodot/Web用Ogg Vorbisへ変換した。六体の機械魔獣、二体の通常ボス、真ボスはすべて固有BGMを持ち、地図・ツリーとエンディングにも独立した曲を割り当てている。ゲーム内では約0.85秒のクロスフェードで切り替え、全曲をループ再生する。`M`キーで即時ミュートでき、タイトルまたはヘッダーの設定画面からMaster / BGM / SFXを個別調整できる。設定は端末へ保存される。

| 用途 | 採用曲 | 案 | Suno原曲 | ゲーム用ファイル | 長さ |
|---|---|---:|---|---|---:|
| 地図・ツリー・ボス選択 | Subterranean Hunt | B | [38e390e5](https://suno.com/song/38e390e5-211a-42c6-bba1-9d0bae8d8c4a) | `subterranean_hunt.ogg` | 2:18 |
| ギアモウ | Piston Hunt Loop | A | [e8a9630a](https://suno.com/song/e8a9630a-0232-4f61-a5cb-965fa47adb97) | `piston_hunt_loop.ogg` | 2:54 |
| ヴォルトバック | Blue Vault Pulse | A | [d4693641](https://suno.com/song/d4693641-6e67-4e0c-852e-d1eac03383e2) | `blue_vault_pulse.ogg` | 3:00 |
| パイア・ワーム | Redline Molt | B | [059ca762](https://suno.com/song/059ca762-c4fb-4939-accd-7e44a9c617b2) | `redline_molt.ogg` | 3:00 |
| リレイ・ヒドラ | Cascade Trinity | A | [2ef6ef83](https://suno.com/song/2ef6ef83-f5fd-4f4c-8f45-61d555253cb6) | `cascade_trinity.ogg` | 3:00 |
| スウォーム・マトリアーク | Hive Command Lattice | A | [856931c9](https://suno.com/song/856931c9-15fa-40c3-bb29-ff656d3c99b8) | `hive_command_lattice.ogg` | 3:00 |
| フェイズ・マンティス | Critical Parallax | B | [f968b738](https://suno.com/song/f968b738-6e79-4a72-a712-d5544c2628d9) | `critical_parallax.ogg` | 3:00 |
| グリッド・リーチ | Siphon Breakpoint | A | [357a05b0](https://suno.com/song/357a05b0-1683-4638-9e86-e253e9e92123) | `siphon_breakpoint.ogg` | 3:00 |
| サーマル・タイタン／強化ボス | Forge of Breakpoints | B | [939de7cd](https://suno.com/song/939de7cd-8c5b-45cf-bd1c-083f2e424ffb) | `forge_of_breakpoints.ogg` | 2:19 |
| 真ボス | Arch Singularity | A | [79144c1c](https://suno.com/song/79144c1c-bc79-4873-a200-01cbe32b80e0) | `arch_singularity.ogg` | 2:11 |
| 通常・真エンディング | Core of Dawn | A | [d196ebaf](https://suno.com/song/d196ebaf-3d80-4a38-8881-b3b0fba76023) | `core_of_dawn.ogg` | 2:20 |

原音は48 kHz / 16-bit / stereo WAV。波形のダイナミクスを変える再圧縮型ノーマライズは避け、曲ごとの固定ゲインで約 -18 LUFSへ統一してからVorbis quality 5へ変換した。追加6曲の変換後は -18.03〜-18.08 LUFS、全11曲で合計約30.3 MiB。元WAVはリポジトリへ含めず、各Oggのメタデータにタイトル、作者名 `NeoN Lament`、Suno song IDを保存している。

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

### 確定した敵別割り当て

| 敵 | 曲 |
|---|---|
| ギアモウ | Piston Hunt Loop A（既存） |
| ヴォルトバック | Blue Vault Pulse A |
| パイア・ワーム | Redline Molt B |
| リレイ・ヒドラ | Cascade Trinity A |
| スウォーム・マトリアーク | Hive Command Lattice A |
| フェイズ・マンティス | Critical Parallax B |
| グリッド・リーチ | Siphon Breakpoint A |
| サーマル・タイタン | Forge of Breakpoints B（既存） |
| アーク・シンギュラリティ | Arch Singularity A（既存） |

### 初回生成候補（2026-08-06・差し替え前）

全12候補をSuno v5.5 / Advanced / Instrumentalで生成したが、Sunoの自動尺によって一部が16秒〜1分台になったため、選考対象から外した。以下は生成履歴と出典追跡のために残す。

| 敵 | A | B |
|---|---|---|
| ヴォルトバック | [Blue Vault Pulse A](https://suno.com/song/a45f0023-c229-4b3a-8544-d04b5b02d971) | [Blue Vault Pulse B](https://suno.com/song/17608c80-33ae-4f71-9733-9586645deaf0) |
| パイア・ワーム | [Redline Molt A](https://suno.com/song/84c0ad31-a984-43c6-9717-f95990273a07) | [Redline Molt B](https://suno.com/song/72f2d770-04f8-4690-a59d-4916c5f40c86) |
| リレイ・ヒドラ | [Cascade Trinity A](https://suno.com/song/6c4a0e1d-5646-4dd1-94c8-27db24d85477) | [Cascade Trinity B](https://suno.com/song/9f1f8777-1341-48b3-833a-5eb82618ede4) |
| スウォーム・マトリアーク | [Hive Command Lattice A](https://suno.com/song/f8f48fd1-c68f-4c68-9858-23c796d638c9) | [Hive Command Lattice B](https://suno.com/song/f0a24f3c-83b7-4f44-ad94-155514416d8b) |
| フェイズ・マンティス | [Critical Parallax A](https://suno.com/song/4513110f-139a-478b-8fff-dba98279030d) | [Critical Parallax B](https://suno.com/song/3892aae9-541b-48f5-8bb0-9e634b46e3b7) |
| グリッド・リーチ | [Siphon Breakpoint A](https://suno.com/song/b58c5f8a-f2ab-494e-9e31-21e476bfe5d6) | [Siphon Breakpoint B](https://suno.com/song/d1aea7cd-73af-40fe-a481-9b437019e97e) |

### 3分ループ再生成候補（2026-08-06・選考完了）

Suno v5.5 / Advanced / Instrumentalに加えて、長さを`Custom 3:00`へ固定した。プロンプトも8〜16小節の反復セル、4秒以内の主グルーヴ開始、長いブレイク・フェードアウト・終止音の禁止、最終小節と冒頭の和声・拍・空気感の一致を明示した。

カスタム尺でも早く終わったリレイ・ヒドラ初回A（1:54）とグリッド・リーチ初回A（2:34）は除外し、その2体だけ再抽選した。下記の最終12候補はすべて2:58〜3:00。

ユーザー選択はヴォルトバックA、パイア・ワームB、リレイ・ヒドラA、スウォーム・マトリアークA、フェイズ・マンティスB、グリッド・リーチA。採用6曲はWAVから固定ゲインでマスタリングし、上表のOggとして実装済み。

| 敵 | A | B |
|---|---|---|
| ヴォルトバック | [Blue Vault Pulse 3M Loop A — 3:00](https://suno.com/song/d4693641-6e67-4e0c-852e-d1eac03383e2) | [Blue Vault Pulse 3M Loop B — 2:59](https://suno.com/song/b43491a6-65e4-4ea0-90d8-a9a87a6fd625) |
| パイア・ワーム | [Redline Molt 3M Loop A — 3:00](https://suno.com/song/b0a7addd-f790-423b-b2e0-35fdea31561f) | [Redline Molt 3M Loop B — 3:00](https://suno.com/song/059ca762-c4fb-4939-accd-7e44a9c617b2) |
| リレイ・ヒドラ | [Cascade Trinity 3M Loop A — 3:00](https://suno.com/song/2ef6ef83-f5fd-4f4c-8f45-61d555253cb6) | [Cascade Trinity 3M Loop B — 3:00](https://suno.com/song/75b65cf2-5e63-4dc1-ae9d-621e4e6a3944) |
| スウォーム・マトリアーク | [Hive Command Lattice 3M Loop A — 3:00](https://suno.com/song/856931c9-15fa-40c3-bb29-ff656d3c99b8) | [Hive Command Lattice 3M Loop B — 2:58](https://suno.com/song/ac0e9945-68a2-43e8-aa7c-44fa97503785) |
| フェイズ・マンティス | [Critical Parallax 3M Loop A — 3:00](https://suno.com/song/1fb0ce55-ef2b-43ba-85b9-625d87116664) | [Critical Parallax 3M Loop B — 3:00](https://suno.com/song/f968b738-6e79-4a72-a712-d5544c2628d9) |
| グリッド・リーチ | [Siphon Breakpoint 3M Loop A — 3:00](https://suno.com/song/357a05b0-1683-4638-9e86-e253e9e92123) | [Siphon Breakpoint 3M Loop B — 3:00](https://suno.com/song/e6534aad-95b6-48e5-9a5b-04373f72b450) |

## v8追加曲 — PRIME CURRENT / 2つのエンディング

実装側には `prime_current`, `ending_world`, `ending_true` の独立スロットを追加済み。マスター確定までは既存曲を仮配置する。

### 本当のラスボス3形態 — `Prime Current: The Current Remembers`

Custom 3:00、Instrumental。3形態を1曲で連続させ、各区間を切り出してもループできる構成。

> Instrumental three-form ultimate boss suite for PRIME CURRENT, the first machine consciousness buried beneath a defeated world-engine. Exactly three minutes, 158 BPM, F sharp minor moving toward an unresolved luminous mode, begin the main combat pulse within four seconds. Form one: colossal crownless industrial footsteps, low piston polyrhythm and a wounded six-note machine motif. Form two: the body unfolds into a null cathedral, circular broken-beat percussion, phase-cancelled synthesizers and three rotating attack voices. Form three: armor disappears, leaving white-cyan current, exposed machine bones and five colored OVERLIMIT themes converging into a clear heroic counter-melody. Futuristic sacred machinery without choir or vocals, frightening then tragic, precise transients and open midrange for rapid clicks and alarms. Use repeating eight-to-sixteen-bar cells, no long breakdown, no fade-out, no final cadence; last bar must reconnect harmonically and rhythmically to the first.

### 地核機神エンド — `After the World Engine`

通常帰還を選んだ際の約3分エンドロール。達成感はあるが、深部信号がまだ残っている。

> Instrumental ending-credits piece after the defeat of ARCH SINGULARITY. Exactly three minutes, 82 BPM, D major shaded by B minor, warm analog pads, intimate synthetic piano, soft struck metal and a slow electrical heartbeat. Resolve the established PROJECT CHARGE four-note motif with dignity, but leave a faint low six-note signal unanswered beneath the final section, suggesting something deeper still lives. Reflective mechanical dawn, earned relief rather than triumph, spacious mix, no vocals, no trailer orchestra, no fade-out. Build from sparse memory fragments to a warm full statement, then return to the opening heartbeat so the credits can loop seamlessly.

### 真エンディング — `The Current Remembers`

8枚の紙芝居と真エンドロール用。多少長く聴けるようCustom 3:00。通常エンドとは明確に別曲。

> Instrumental true-ending music for a lone automaton who learns that the defeated beasts, world-engine and final current were all fragments of one surviving memory. Exactly three minutes, 76 BPM, begin with solitary ivory-piano notes and quiet cable resonance, gradually introduce warm analog strings, glass harmonics and five gentle colored synth voices that weave into one transformed PROJECT CHARGE motif. Bittersweet, humane and luminous; grief becoming chosen rest, never sentimental or grandiose. The last minute should feel like first daylight reaching an underground machine for the first time. No vocals, no choir, no cinematic boom, no fade-out; sustain a soft electrical pulse that can loop back into the first piano note for long illustrated credits.

### 真エンディング正式採用（2026-08-08）

Suno v5.5 / Advanced / Instrumental / Custom 3:00で生成。ユーザーレビューによりBを正式採用し、`the_current_remembers.mp3`として独立した`ending_true`スロットへ実装した。通常エンディング曲とは共有しない。

| 候補 | 尺 | Suno |
|---|---:|---|
| A | 3:00 | [The Current Remembers — True Ending 3M A](https://suno.com/song/6917c795-70b8-4074-9f42-5a3641ad37cc) |
| **B（正式採用）** | **3:00** | [The Current Remembers — True Ending 3M R2 B](https://suno.com/song/41766ea9-2ffe-489d-9daf-e723c62806c2) |

予備として[R2 A（2:59）](https://suno.com/song/9c5f48f1-9e20-4df5-930a-29a5428d85ed)も保持する。初回抽選B（2:34）は尺要件を満たさないため選考対象外。
