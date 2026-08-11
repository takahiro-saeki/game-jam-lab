extends Node2D

signal return_to_menu
signal language_changed(is_japanese: bool)

const Palette = preload("res://shared/palette.gd")
const Synth = preload("res://shared/synth.gd")
const ControllerConfig = preload("res://shared/controller_bindings.gd")
const AudioSettings = preload("res://shared/project_charge_audio_settings.gd")
const ChargeState = preload("res://games/charge_clicker/charge_state.gd")
const GearCatalog = preload("res://games/charge_clicker/gear_catalog.gd")
const ChargeSave = preload("res://games/charge_clicker/charge_save.gd")
const AchievementState = preload("res://games/charge_clicker/charge_achievements.gd")
const CampaignRoute = preload("res://games/charge_clicker/charge_route.gd")
const StageCatalog = preload("res://games/charge_clicker/stage_catalog.gd")
const StoryCatalog = preload("res://games/charge_clicker/story_catalog.gd")
const DisplayFont = preload("res://assets/fonts/DotGothic16-Regular.ttf")
const BGMStreams := {
	# Human-selected standalone-product masters: Awakening Below A for the title
	# screen and Six-Core Descent B for hunt-map planning.
	"title": preload("res://assets/audio/project_charge/awakening_below.mp3"),
	"map": preload("res://assets/audio/project_charge/six_core_descent.mp3"),
	"hunt": preload("res://assets/audio/project_charge/piston_hunt_loop.ogg"),
	"vaultback": preload("res://assets/audio/project_charge/blue_vault_pulse.ogg"),
	"pyre_wyrm": preload("res://assets/audio/project_charge/redline_molt.ogg"),
	"relay_hydra": preload("res://assets/audio/project_charge/cascade_trinity.ogg"),
	"swarm_matriarch": preload("res://assets/audio/project_charge/hive_command_lattice.ogg"),
	"phase_mantis": preload("res://assets/audio/project_charge/critical_parallax.ogg"),
	"grid_leech": preload("res://assets/audio/project_charge/siphon_breakpoint.ogg"),
	"boss": preload("res://assets/audio/project_charge/forge_of_breakpoints.ogg"),
	"singularity": preload("res://assets/audio/project_charge/arch_singularity.ogg"),
	"ending_normal": preload("res://assets/audio/project_charge/core_of_dawn.ogg"),
	# Dedicated composition slots. The true-ending master is the approved
	# three-minute Suno B arrangement; world-engine credits remain independent.
	"ending_world": preload("res://assets/audio/project_charge/arch_singularity.ogg"),
	"ending_true": preload("res://assets/audio/project_charge/the_current_remembers.mp3"),
	# Human-selected Suno masters for the three bodies of PRIME CURRENT:
	# Crownless Protocol B, Null Cathedral A, and Fallen Seraph Current A.
	"prime_current_form_1": preload("res://assets/audio/project_charge/prime_current_crownless_protocol.mp3"),
	"prime_current_form_2": preload("res://assets/audio/project_charge/prime_current_null_cathedral.mp3"),
	"prime_current_form_3": preload("res://assets/audio/project_charge/prime_current_fallen_seraph.mp3"),
	# The archive uses its selected reflective A master and never borrows combat
	# or true-ending music.
	"artwork_gallery": preload("res://assets/audio/project_charge/recovered_memory_archive.mp3"),
}
const VictoryJingleStream: AudioStream = preload("res://assets/audio/project_charge/nomad_victory_signal.mp3")
# Every enemy encounter has its own mastered track. The generic keys remain the
# dedicated Gearmaw and Thermal Titan tracks as well as safe fallback values.
const EncounterBGMKeys := {
	"gearmaw": "hunt",
	"vaultback": "vaultback",
	"pyre_wyrm": "pyre_wyrm",
	"relay_hydra": "relay_hydra",
	"swarm_matriarch": "swarm_matriarch",
	"phase_mantis": "phase_mantis",
	"grid_leech": "grid_leech",
	"thermal_titan": "boss",
	"arch_singularity": "singularity",
	"prime_current_form_1": "prime_current_form_1",
	"prime_current_form_2": "prime_current_form_2",
	"prime_current_form_3": "prime_current_form_3",
}
const ReactorTextures := {
	"reactor-turbine-a": preload("res://assets/charge_clicker/pixellab/source/reactor/reactor-turbine-a.png"),
	"reactor-containment-a": preload("res://assets/charge_clicker/pixellab/source/reactor/reactor-containment-a.png"),
	"reactor-hex-a": preload("res://assets/charge_clicker/pixellab/source/reactor/reactor-hex-a.png"),
	"reactor-hex-b": preload("res://assets/charge_clicker/pixellab/source/reactor/reactor-hex-b.png"),
	"reactor-hex-c": preload("res://assets/charge_clicker/pixellab/source/reactor/reactor-hex-c.png"),
}
const GeneratorBackgrounds := {
	"environment-cathedral-a": preload("res://assets/charge_clicker/pixellab/source/environment/environment-cathedral-a.png"),
	"environment-machine-room-a": preload("res://assets/charge_clicker/pixellab/source/environment/environment-machine-room-a.png"),
	"environment-machine-room-b": preload("res://assets/charge_clicker/pixellab/source/environment/environment-machine-room-b.png"),
}
const CellTextures := {
	"cell-industrial-rail-a": preload("res://assets/charge_clicker/pixellab/source/cell/cell-industrial-rail-a.png"),
	"cell-hex-capsule-a": preload("res://assets/charge_clicker/pixellab/source/cell/cell-hex-capsule-a.png"),
	"cell-vacuum-tube-a": preload("res://assets/charge_clicker/pixellab/source/cell/cell-vacuum-tube-a.png"),
}
const GridWraithTextures := {
	"wraith-cable-leech-a": preload("res://assets/charge_clicker/pixellab/source/boss/wraith-cable-leech-a.png"),
	"wraith-broken-hex-a": preload("res://assets/charge_clicker/pixellab/source/boss/wraith-broken-hex-a.png"),
	"wraith-manta-siphon-a": preload("res://assets/charge_clicker/pixellab/source/boss/wraith-manta-siphon-a.png"),
}
const MechanicalBeastTextures := {
	"gearmaw": preload("res://assets/charge_clicker/pixellab/source/enemy/beast-gearmaw-a.png"),
	"vaultback": preload("res://assets/charge_clicker/pixellab/source/enemy/beast-vaultback-a.png"),
	"pyre_wyrm": preload("res://assets/charge_clicker/pixellab/source/enemy/beast-pyre-wyrm-a.png"),
	"relay_hydra": preload("res://assets/charge_clicker/pixellab/source/enemy/beast-relay-hydra-a.png"),
	"swarm_matriarch": preload("res://assets/charge_clicker/pixellab/source/enemy/beast-swarm-matriarch-a.png"),
	"phase_mantis": preload("res://assets/charge_clicker/pixellab/source/enemy/beast-phase-mantis-a.png"),
	"grid_leech": preload("res://assets/charge_clicker/pixellab/source/enemy/boss-grid-leech-v3-a.png"),
	"thermal_titan": preload("res://assets/charge_clicker/pixellab/source/enemy/boss-thermal-titan-a.png"),
	"arch_singularity": preload("res://assets/charge_clicker/pixellab/source/enemy/boss-arch-singularity-a.png"),
	"prime_current_form_1": preload("res://assets/charge_clicker/pixellab/source/enemy/final-crownless-reliquary-v8-b.png"),
	"prime_current_form_2": preload("res://assets/charge_clicker/pixellab/source/enemy/final-null-cathedral-radial-v8-a.png"),
	"prime_current_form_3": preload("res://assets/charge_clicker/pixellab/source/enemy/final-fallen-machine-seraph-v9-c-cutout.png"),
}
const EnergyShardTextures := {
	"shard-faceted-core-a": preload("res://assets/charge_clicker/pixellab/source/icon/shard-faceted-core-a.png"),
	"shard-hex-battery-a": preload("res://assets/charge_clicker/pixellab/source/icon/shard-hex-battery-a.png"),
	"shard-coil-spark-a": preload("res://assets/charge_clicker/pixellab/source/icon/shard-coil-spark-a.png"),
}
const ChargeControlTextures := {
	"charge-piston-a": preload("res://assets/charge_clicker/pixellab/source/control/charge-piston-a.png"),
	"charge-hex-pad-a": preload("res://assets/charge_clicker/pixellab/source/control/charge-hex-pad-a.png"),
	"charge-convergence-a": preload("res://assets/charge_clicker/pixellab/source/control/charge-convergence-a.png"),
}
const DischargeControlTextures := {
	"discharge-breaker-a": preload("res://assets/charge_clicker/pixellab/source/control/discharge-breaker-a.png"),
	"discharge-six-bus-a": preload("res://assets/charge_clicker/pixellab/source/control/discharge-six-bus-a.png"),
	"discharge-wave-a": preload("res://assets/charge_clicker/pixellab/source/control/discharge-wave-a.png"),
}
const AutoControlTextures := {
	"auto-drone-dock-a": preload("res://assets/charge_clicker/pixellab/source/control/auto-drone-dock-a.png"),
	"auto-open-relay-a": preload("res://assets/charge_clicker/pixellab/source/control/auto-open-relay-a.png"),
	"auto-stopped-rotor-a": preload("res://assets/charge_clicker/pixellab/source/control/auto-stopped-rotor-a.png"),
}
const ProtagonistTexture: Texture2D = preload("res://assets/charge_clicker/pixellab/source/protagonist/protagonist-volt-nomad-v6-a.png")
const GearTextures := {
	"striker": preload("res://assets/charge_clicker/pixellab/source/gear/gear-striker-piston-a.png"),
	"dynamo": preload("res://assets/charge_clicker/pixellab/source/gear/gear-dynamo-flywheel-a.png"),
	"autogun": preload("res://assets/charge_clicker/pixellab/source/gear/gear-autogun-rail-a.png"),
	"drone": preload("res://assets/charge_clicker/pixellab/source/gear/gear-drone-crown-a.png"),
	"core": preload("res://assets/charge_clicker/pixellab/source/gear/gear-core-cradle-a.png"),
}
const AutoProjectileTextures := {
	"standard": preload("res://assets/charge_clicker/pixellab/source/vfx/auto-vfx-arc-lance-v10-a.png"),
	"gatling": preload("res://assets/charge_clicker/pixellab/source/vfx/auto-vfx-gatling-packet-v10-b.png"),
	"rail": preload("res://assets/charge_clicker/pixellab/source/vfx/auto-vfx-horizon-spike-v10-c.png"),
}
const OverlimitSocketTexture: Texture2D = preload("res://assets/charge_clicker/pixellab/source/ui/overlimit-socket-seraph-lock-v10-c.png")
const EndingIllustrations := {
	"silence": preload("res://assets/charge_clicker/ending/ending-silence-below-v11.png"),
	"colossi": preload("res://assets/charge_clicker/ending/ending-memory-colossi-v11.png"),
	"current": preload("res://assets/charge_clicker/ending/ending-current-remembers-v11.png"),
	"dawn": preload("res://assets/charge_clicker/ending/ending-core-dawn-v11.png"),
}
const BossArtwork := {
	"gearmaw": preload("res://assets/charge_clicker/ending/art-gearmaw-v12.png"),
	"vaultback": preload("res://assets/charge_clicker/ending/art-vaultback-v12.png"),
	"pyre_wyrm": preload("res://assets/charge_clicker/ending/art-pyre-wyrm-v12.png"),
	"relay_hydra": preload("res://assets/charge_clicker/ending/art-relay-hydra-v12.png"),
	"swarm_matriarch": preload("res://assets/charge_clicker/ending/art-swarm-matriarch-v12.png"),
	"phase_mantis": preload("res://assets/charge_clicker/ending/art-phase-mantis-v12.png"),
	"grid_leech": preload("res://assets/charge_clicker/ending/art-grid-leech-v12.png"),
	"thermal_titan": preload("res://assets/charge_clicker/ending/art-thermal-titan-v12.png"),
	"arch_singularity": preload("res://assets/charge_clicker/ending/art-arch-singularity-v12.png"),
	"prime_current": preload("res://assets/charge_clicker/ending/art-prime-current-v12.png"),
}
const ArtworkGallery := [
	{"id":"silence","title_ja":"地核の沈黙","title_en":"SILENCE BELOW","desc_ja":"世界機関の停止後、静まり返った地核で帰還信号を待つヴォルト・ノマド。","desc_en":"VOLT NOMAD WAITS FOR THE ASCENT SIGNAL IN THE SILENT WORLD ENGINE.","texture":EndingIllustrations["silence"],"accent":Palette.CYAN},
	{"id":"colossi","title_ja":"主獣たちの記憶","title_en":"MEMORY OF COLOSSI","desc_ja":"討伐した機械魔獣たちが遺した、生存と抵抗の記録。","desc_en":"A RECORD OF SURVIVAL AND RESISTANCE LEFT BY THE MECHANICAL COLOSSI.","texture":EndingIllustrations["colossi"],"accent":Palette.VIOLET},
	{"id":"current","title_ja":"原初電流の記憶","title_en":"THE CURRENT REMEMBERS","desc_ja":"無冠機神と六つの機核が、一つの意志として最後の電流へ触れる。","desc_en":"THE CROWNLESS ENGINE AND SIX CORES MEET THE LAST CURRENT AS ONE WILL.","texture":EndingIllustrations["current"],"accent":Palette.AMBER},
	{"id":"dawn","title_ja":"夜明けの機核","title_en":"CORE OF DAWN","desc_ja":"戦いの終わりに選び取られた、地上へ続く静かな夜明け。","desc_en":"A QUIET DAWN CHOSEN AT THE END OF THE HUNT, LEADING BACK TO THE SURFACE.","texture":EndingIllustrations["dawn"],"accent":Palette.MINT},
	{"id":"gearmaw","title_ja":"鉄殻を穿つもの","title_en":"THE IRON BORER","desc_ja":"廃棄坑道を砕くギアモウ。その衝撃核は、第六適合個体の最初の力となった。","desc_en":"GEARMAW BORES THROUGH THE SCRAP OSSUARY — THE FIRST CORE CLAIMED BY UNIT SIX.","texture":BossArtwork["gearmaw"],"accent":Palette.AMBER},
	{"id":"vaultback","title_ja":"青雷の開殻","title_en":"THUNDER SHELL OPEN","desc_ja":"ヴォルトバックの蓄雷甲が開き、数世紀分の電流が深層を昼へ変える。","desc_en":"VAULTBACK OPENS ITS THUNDER SHELL, TURNING THE DEPTHS TO DAY WITH CENTURIES OF CHARGE.","texture":BossArtwork["vaultback"],"accent":Palette.CYAN},
	{"id":"pyre_wyrm","title_ja":"灼炉の蛇行","title_en":"FURNACE SERPENT","desc_ja":"強化のたびに赤熱するパイア・ワーム。地熱炉心層そのものが、長い身体へ組み替わる。","desc_en":"PYRE WYRM REWRITES THE GEOTHERMAL FOUNDRY INTO ONE ENDLESS OVERDRIVE.","texture":BossArtwork["pyre_wyrm"],"accent":Palette.CORAL},
	{"id":"relay_hydra","title_ja":"三頭継電","title_en":"CASCADE TRINITY","desc_ja":"三つの頭部を渡る電流。手動とAUTOの一撃だけが、その継電律を断ち切れる。","desc_en":"CURRENT PASSES BETWEEN THREE HEADS; ONLY A PERFECT MANUAL/AUTO RELAY CAN BREAK IT.","texture":BossArtwork["relay_hydra"],"accent":Palette.VIOLET},
	{"id":"swarm_matriarch","title_ja":"群制の月","title_en":"THE SWARM MOON","desc_ja":"無数の子機を一つの意志として操る母機。標識された一点へ、群れの夜が収束する。","desc_en":"THE MATRIARCH COMMANDS A THOUSAND DRONES AS ONE WILL, CONVERGING ON A SINGLE MARK.","texture":BossArtwork["swarm_matriarch"],"accent":Palette.MINT},
	{"id":"phase_mantis","title_ja":"臨界の一瞬","title_en":"CRITICAL PARALLAX","desc_ja":"位相の狭間に残る唯一の実体。フェイズ・マンティスを捉える、一度きりの臨界窓。","desc_en":"ONE PHYSICAL BODY REMAINS BETWEEN PHASES — A SINGLE CRITICAL WINDOW.","texture":BossArtwork["phase_mantis"],"accent":Palette.VIOLET},
	{"id":"grid_leech","title_ja":"深淵の吸収核","title_en":"ABYSSAL SIPHON","desc_ja":"崩壊した送電網を喰らうグリッド・リーチ。開いた吸収核へ、八つの指令が届く。","desc_en":"GRID LEECH FEEDS ON A RUINED POWER NETWORK UNTIL EIGHT COMMANDS REACH ITS OPEN CORE.","texture":BossArtwork["grid_leech"],"accent":Palette.CYAN},
	{"id":"thermal_titan","title_ja":"炉皇の露出","title_en":"FORGE COLOSSUS","desc_ja":"サーマル・タイタンの炉心が露出する六秒間。巨獣よりも大きな好機が、熱波の奥で脈打つ。","desc_en":"FOR SIX SECONDS THE TITAN'S FURNACE LIES OPEN — AN OPPORTUNITY LARGER THAN THE COLOSSUS.","texture":BossArtwork["thermal_titan"],"accent":Palette.CORAL},
	{"id":"arch_singularity","title_ja":"世界機関の覚醒","title_en":"THE WORLD ENGINE","desc_ja":"六つの共鳴核を掲げ、ヴォルト・ノマドは地底世界そのものへ最後の停止命令を送る。","desc_en":"WITH SIX RESONANCE CORES, VOLT NOMAD SENDS A FINAL HALT COMMAND TO THE WORLD BELOW.","texture":BossArtwork["arch_singularity"],"accent":Palette.PAPER},
	{"id":"prime_current","title_ja":"原初電流・三相記憶","title_en":"PRIME CURRENT","desc_ja":"無冠機神、零相聖堂、闇堕機天使。三つの器を捨てても、最初の電流は停止を拒んだ。","desc_en":"CROWNLESS ENGINE, NULL CATHEDRAL, FALLEN SERAPH — THREE VESSELS FOR THE FIRST CURRENT.","texture":BossArtwork["prime_current"],"accent":Palette.PAPER},
]
const ARTWORK_PAGE_SIZE := 4
const RegionBackgrounds := {
	"scrap": preload("res://assets/charge_clicker/pixellab/source/environment/bg-scrap-ossuary-a.png"),
	"geothermal": preload("res://assets/charge_clicker/pixellab/source/environment/bg-geo-pressure-foundry-a.png"),
	"biocrystal": preload("res://assets/charge_clicker/pixellab/source/environment/bg-biocrystal-observatory-a.png"),
}
const EncounterRegions := {
	"gearmaw": "scrap",
	"vaultback": "scrap",
	"grid_leech": "scrap",
	"pyre_wyrm": "geothermal",
	"thermal_titan": "geothermal",
	"relay_hydra": "biocrystal",
	"swarm_matriarch": "biocrystal",
	"phase_mantis": "biocrystal",
	"arch_singularity": "biocrystal",
	"prime_current_form_1": "biocrystal",
	"prime_current_form_2": "biocrystal",
	"prime_current_form_3": "biocrystal",
}
const UpgradeRackTexture: Texture2D = preload("res://assets/charge_clicker/pixellab/source/ui/upgrade-rack-switchboard-a.png")
const ControlConsoleKitTexture: Texture2D = preload("res://assets/charge_clicker/pixellab/source/ui/control-kit-switchboard-a.png")
const WraithGaugeTexture: Texture2D = preload("res://assets/charge_clicker/pixellab/source/ui/wraith-gauge-switchboard-a.png")
const ShardAccumulatorTexture: Texture2D = preload("res://assets/charge_clicker/pixellab/source/ui/shard-accumulator-corrupted-b.png")
const DefeatVFX := {
	"fracture": preload("res://assets/charge_clicker/pixellab/source/vfx/defeat-vfx-core-fracture-v12-a.png"),
	"halo": preload("res://assets/charge_clicker/pixellab/source/vfx/defeat-vfx-voltage-halo-v12-b.png"),
	"shards": preload("res://assets/charge_clicker/pixellab/source/vfx/defeat-vfx-machine-shards-v12-c.png"),
}
const ENCOUNTER_LAB_IDS := [
	"gearmaw", "vaultback", "pyre_wyrm", "relay_hydra", "swarm_matriarch", "phase_mantis",
	"grid_leech", "thermal_titan", "arch_singularity",
	"prime_current_form_1", "prime_current_form_2", "prime_current_form_3",
]

const VIEW := Vector2(1280, 720)
const BGM_VOLUME_DB := -10.0
const BGM_SILENT_DB := -60.0
const BGM_CROSSFADE_SECONDS := 0.85
const FINAL_DEFEAT_CINEMATIC_SECONDS := 9.0
const EPILOGUE_SCENE_SECONDS := [6.5, 7.0, 7.0, 7.5, 7.0, 7.0, 7.5, 8.0]
const EPILOGUE_FADE_SECONDS := 0.85
const REACTOR_CENTER := Vector2(212, 286)
const SHARD_ACCUMULATOR_RECT := Rect2(524, 5, 196, 78)
const SHARD_SOCKET_CENTER := Vector2(575, 44)
const CONTROL_CHARGE_REGION := Rect2(0, 0, 104, 128)
const CONTROL_DISCHARGE_REGION := Rect2(104, 0, 174, 128)
const CONTROL_AUTO_REGION := Rect2(278, 0, 106, 128)
const UPGRADE_RACK_CENTER_REGION := Rect2(76, 4, 232, 120)
const PLAYTEST_LOG_PATH := "user://project_charge_playtests.jsonl"

var synth: JamSynth
var audio_settings
var bgm_players: Array[AudioStreamPlayer] = []
var bgm_active_index := -1
var bgm_key := ""
var bgm_crossfade: Tween
var bgm_jingle_duck: Tween
var victory_jingle_player: AudioStreamPlayer
var victory_jingle_fade: Tween
var music_enabled := true
var music_volume_before_mute := 0.72
var run
var save_manager
var campaign_route
var achievements
var is_japanese := false
var controller_bindings: Dictionary = ControllerConfig.default_bindings()
var persistence_enabled := true
var reactor_texture: Texture2D = ReactorTextures["reactor-hex-a"]
var generator_background: Texture2D = GeneratorBackgrounds["environment-machine-room-a"]
var cell_texture: Texture2D = CellTextures["cell-hex-capsule-a"]
var grid_wraith_texture: Texture2D = GridWraithTextures["wraith-manta-siphon-a"]
var energy_shard_texture: Texture2D = EnergyShardTextures["shard-coil-spark-a"]
var charge_control_texture: Texture2D = ChargeControlTextures["charge-piston-a"]
var discharge_control_texture: Texture2D = DischargeControlTextures["discharge-wave-a"]
var auto_control_texture: Texture2D = AutoControlTextures["auto-stopped-rotor-a"]
var art_preview_enabled := false
var art_preview_encounter := ""
var art_preview_tree_gear := ""
var art_preview_tree_tier := 3
var campaign_preview_screen := ""
var debug_battle_id := ""
var debug_battle_overlimit_count := 5
var encounter_lab_enabled := false
var encounter_lab_open := false
var encounter_lab_selected := 0
var encounter_lab_text_enabled := true
var encounter_lab_last_action := ""
var encounter_lab_freeze_combat := false

var animation_time := 0.0
var charge_held := false
var charge_repeat_timer := 0.0
var screen_shake := 0.0
var screen_flash := 0.0
var discharge_wave := 0.0
var message := ""
var message_time := 0.0
var result_copied_time := 0.0
var result_copy_succeeded := true
var reset_confirm_time := 0.0
var hover_upgrade := -1
var mouse_position := Vector2(-100, -100)
var particles: Array[Dictionary] = []
var floating_texts: Array[Dictionary] = []
var resource_packets: Array[Dictionary] = []
var shard_pulse := 0.0
var protagonist_action_pulse := 0.0
var manual_impact_pulse := 0.0
var manual_impact_critical := false
var manual_impact_generating := false
var auto_impact_pulse := 0.0
var auto_effect_timer := 0.0
var autosave_timer := 0.0
var reward_selected := 0
var controller_upgrade_selected := 0
var selected_gear_index := 0
var selected_tree_tier := 1
var gear_tree_open := false
var controller_axis_latch := Vector2i.ZERO
var campaign_selected := 0
var campaign_hovered := -1
var title_screen_open := true
var title_has_saved_campaign := false
var title_selected := 0
var title_new_confirm_time := 0.0
var settings_open := false
var settings_selected := 0
var credits_open := false
var credits_return_to_title := false
var credits_context := "title"
var credits_scroll := 0.0
var epilogue_open := false
var epilogue_scene := 0
var epilogue_scene_time := 0.0
var epilogue_return_to_artwork := false
var final_defeat_cinematic_open := false
var final_defeat_cinematic_time := 0.0
var final_defeat_burst_stage := 0
var defeat_preview_open := false
var defeat_preview_time := 0.0
var defeat_preview_encounter_id := ""
var defeat_preview_return_to_lab := false
var defeat_preview_burst_stage := 0
var defeat_preview_duration := 4.8
var pending_campaign_defeat_resolution := false
var artwork_open := false
var artwork_viewer_open := false
var artwork_selected := 0
var artwork_zoom_level := 0
var artwork_ui_visible := true
var achievements_open := false
var achievement_notice: Dictionary = {}
var achievement_notice_time := 0.0
var comms_queue: Array[Dictionary] = []
var comms_speaker_ja := ""
var comms_speaker_en := ""
var comms_text_ja := ""
var comms_text_en := ""
var comms_time := 0.0
var comms_role := "auto"
var debug_dialogue_requested := false
var pending_debug_dialogue: Dictionary = {}
var story_event_open := false
var story_event_id := ""
var story_event_definition: Dictionary = {}
var story_event_line_index := 0
var story_event_from_lab := false
var story_event_from_log := false
var story_event_from_encounter_lab := false
var story_event_after_action := ""
var story_event_queue: Array[Dictionary] = []
var story_lab_open := false
var story_lab_selected := 0
var story_lab_scroll := 0
var story_log_open := false
var story_log_selected := 0
var story_log_scroll := 0
var story_log_return_to_title := false
var story_preview_event_id := ""
var story_archive_preview_all := false
var browser_test_muted := false
var story_singularity_phase := 1
var tutorial_open := false
var tutorial_page := 0

var charge_rect := Rect2(70, 502, 284, 88)
var mode_toggle_rect := Rect2(70, 598, 284, 44)
var discharge_rect := Rect2(452, 340, 510, 76)
var auto_rect := Rect2(980, 340, 220, 76)
var enemy_click_rect := Rect2(860, 160, 352, 242)
var menu_rect := Rect2(1102, 22, 138, 42)
var language_rect := Rect2(932, 22, 152, 42)
var settings_rect := Rect2(846, 22, 74, 42)
var reset_rect := Rect2(34, 22, 126, 42)
var upgrade_rects: Array[Rect2] = []
var gear_rects: Array[Rect2] = []
var tree_tab_rects: Array[Rect2] = []
var tree_tier_rects: Array[Rect2] = [Rect2(500, 174, 66, 34), Rect2(574, 174, 66, 34), Rect2(648, 174, 66, 34), Rect2(722, 174, 66, 34)]
var tree_close_rect := Rect2(1132, 112, 82, 46)
var tree_purchase_rect := Rect2(918, 560, 286, 50)
var tree_respec_rect := Rect2(918, 622, 286, 42)
var reward_rects: Array[Rect2] = [Rect2(154, 300, 300, 220), Rect2(490, 300, 300, 220), Rect2(826, 300, 300, 220)]
var clear_retry_rect := Rect2(382, 554, 236, 54)
var clear_menu_rect := Rect2(662, 554, 236, 54)
var stage_map_rects: Array[Rect2] = []
var boss_select_rects: Array[Rect2] = [Rect2(126, 224, 470, 292), Rect2(684, 224, 470, 292)]
var campaign_primary_rect := Rect2(450, 558, 380, 58)
var campaign_secondary_rect := Rect2(450, 632, 380, 48)
var campaign_copy_rect := Rect2(800, 232, 186, 38)
var respec_rect := Rect2(1012, 616, 190, 42)
var title_button_rects: Array[Rect2] = [
	Rect2(726, 304, 410, 62),
	Rect2(726, 380, 410, 54),
	Rect2(726, 448, 96, 48),
	Rect2(830, 448, 96, 48),
	Rect2(934, 448, 96, 48),
	Rect2(1038, 448, 98, 48),
	Rect2(726, 510, 410, 48),
]
var settings_row_rects: Array[Rect2] = [
	Rect2(356, 170, 568, 48),
	Rect2(356, 226, 568, 48),
	Rect2(356, 282, 568, 48),
	Rect2(356, 338, 568, 48),
	Rect2(356, 394, 568, 48),
	Rect2(356, 450, 568, 48),
]
var settings_close_rect := Rect2(704, 610, 220, 48)
var settings_reset_rect := Rect2(356, 610, 220, 48)
var settings_tutorial_rect := Rect2(480, 536, 320, 46)
var campaign_credits_rect := Rect2(326, 632, 292, 48)
var campaign_ending_return_rect := Rect2(662, 632, 292, 48)
var credits_close_rect := Rect2(1032, 642, 190, 46)
var achievements_close_rect := Rect2(514, 642, 252, 46)
var campaign_achievement_rect := Rect2(34, 632, 260, 48)
var epilogue_skip_rect := Rect2(1036, 28, 186, 44)
var artwork_card_rects: Array[Rect2] = [
	Rect2(42, 124, 278, 222),
	Rect2(348, 124, 278, 222),
	Rect2(654, 124, 278, 222),
	Rect2(960, 124, 278, 222),
]
var artwork_view_rect := Rect2(674, 566, 242, 52)
var artwork_replay_rect := Rect2(932, 566, 258, 52)
var artwork_close_rect := Rect2(1040, 42, 176, 46)
var artwork_full_back_rect := Rect2(28, 24, 152, 44)
var artwork_full_zoom_rect := Rect2(930, 24, 132, 44)
var artwork_full_ui_rect := Rect2(1074, 24, 178, 44)
var artwork_full_previous_rect := Rect2(24, 310, 70, 100)
var artwork_full_next_rect := Rect2(1186, 310, 70, 100)
var story_skip_rect := Rect2(1020, 28, 188, 44)
var story_language_rect := Rect2(832, 28, 172, 44)
var story_log_rect := Rect2(862, 616, 140, 42)
var story_log_close_rect := Rect2(1034, 28, 188, 44)
var story_log_replay_rect := Rect2(828, 598, 368, 48)
var tutorial_next_rect := Rect2(778, 590, 392, 54)
var tutorial_skip_rect := Rect2(92, 590, 220, 48)
var encounter_lab_action_rects: Array[Rect2] = [
	Rect2(824, 196, 352, 54),
	Rect2(824, 262, 352, 54),
	Rect2(824, 328, 352, 54),
	Rect2(824, 394, 352, 54),
	Rect2(824, 460, 352, 54),
]
var encounter_lab_text_rect := Rect2(824, 536, 352, 48)
var encounter_lab_close_rect := Rect2(1004, 622, 172, 44)
var encounter_lab_return_rect := Rect2(1080, 80, 160, 38)

func _ready() -> void:
	apply_web_art_preview()
	audio_settings = AudioSettings.new()
	audio_settings.load_settings()
	if browser_test_muted:
		# Local browser QA must never surprise someone working nearby. This is an
		# in-memory override only; it deliberately leaves player settings untouched.
		audio_settings.master_volume = 0.0
		audio_settings.music_volume = 0.0
		audio_settings.sfx_volume = 0.0
		audio_settings.apply()
	music_enabled = audio_settings.music_volume > 0.001
	music_volume_before_mute = maxf(0.72, audio_settings.music_volume)
	synth = Synth.new()
	add_child(synth)
	run = ChargeState.new()
	campaign_route = CampaignRoute.new()
	achievements = AchievementState.new()
	save_manager = ChargeSave.new()
	for index in range(GearCatalog.GEARS.size()):
		gear_rects.append(Rect2(438 + index * 156, 500, 148, 160))
		tree_tab_rects.append(Rect2(58 + index * 214, 112, 202, 52))
	for row in range(2):
		for column in range(3):
			stage_map_rects.append(Rect2(62 + column * 404, 180 + row * 208, 348, 176))
	var resumed: bool = persistence_enabled and save_manager.load_bundle_into(run, campaign_route, achievements)
	# v7 saves ended on the old TRUE_END screen. Route migration moves them to
	# the signal choice; restore the new post-Arch system grant once.
	if campaign_route.true_end_seen and not run.overlimit_system_unlocked:
		run.unlock_overlimit_system()
	title_has_saved_campaign = resumed
	title_screen_open = not art_preview_enabled
	if encounter_lab_enabled:
		configure_encounter_lab()
	elif not debug_battle_id.is_empty():
		configure_debug_battle()
	elif art_preview_enabled:
		if campaign_preview_screen.is_empty():
			campaign_route.reset()
			campaign_route.select_stage("gearmaw")
			configure_art_preview_state()
		else:
			configure_campaign_preview()
		configure_art_preview_tree()
	if campaign_route.phase in [CampaignRoute.RoutePhase.MAP, CampaignRoute.RoutePhase.TRUE_MAP]:
		campaign_selected = first_available_stage_index()
	elif campaign_route.phase == CampaignRoute.RoutePhase.BOSS_SELECT:
		campaign_selected = 0
	if encounter_lab_enabled:
		show_message(loc("開発検証：全敵演出ラボ // セーブ無効", "LOCAL QA: ENCOUNTER LAB // SAVE DISABLED"), 4.0)
	elif not debug_battle_id.is_empty():
		show_message(loc("開発検証：PRIME CURRENT直行 // セーブ無効", "LOCAL QA: PRIME CURRENT DIRECT // SAVE DISABLED"), 4.0)
	elif resumed:
		show_message(loc("保存したキャンペーンを再開", "CAMPAIGN RESUMED"), 3.0)
	else:
		show_message(loc("討伐地図から最初の機械魔獣を選択", "SELECT YOUR FIRST MECHANICAL BEAST"), 5.0)
	if debug_dialogue_requested:
		message_time = 0.0
		debug_show_dialogue(
			str(pending_debug_dialogue.get("speaker_ja", "デバッグ通信")),
			str(pending_debug_dialogue.get("speaker_en", "DEBUG COMMS")),
			str(pending_debug_dialogue.get("text_ja", "任意テキストボックスの表示確認。")),
			str(pending_debug_dialogue.get("text_en", "ARBITRARY DIALOGUE BOX PREVIEW.")),
			float(pending_debug_dialogue.get("duration", 12.0)),
			str(pending_debug_dialogue.get("role", "support"))
		)
	if not story_preview_event_id.is_empty():
		title_screen_open = false
		start_story_event(story_preview_event_id, true)
	elif story_archive_preview_all:
		unlock_story_archive_for_preview()
		open_story_log(true)
	setup_music()
	evaluate_achievements(false)
	refresh_music()
	queue_redraw()

func setup_music() -> void:
	if DisplayServer.get_name() == "headless":
		return
	for index in range(2):
		var player := AudioStreamPlayer.new()
		player.name = "BGM%d" % (index + 1)
		player.bus = AudioSettings.BUS_MUSIC
		player.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
		player.volume_db = BGM_SILENT_DB
		add_child(player)
		bgm_players.append(player)
	victory_jingle_player = AudioStreamPlayer.new()
	victory_jingle_player.name = "VictoryJingle"
	victory_jingle_player.bus = AudioSettings.BUS_MUSIC
	victory_jingle_player.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
	victory_jingle_player.stream = VictoryJingleStream
	add_child(victory_jingle_player)

func desired_bgm_key() -> String:
	if final_defeat_cinematic_open:
		return "prime_current_form_3"
	if epilogue_open:
		return "ending_true"
	if artwork_open:
		return "artwork_gallery"
	if credits_open:
		return "ending_true" if credits_context in ["final", "artwork_replay"] else "ending_world" if credits_context == "world" else "ending_normal"
	if title_screen_open:
		return "title"
	if campaign_route == null:
		return "map"
	match campaign_route.phase:
		CampaignRoute.RoutePhase.STAGE:
			return str(EncounterBGMKeys.get(run.current_stage_id, "hunt"))
		CampaignRoute.RoutePhase.BOSS, CampaignRoute.RoutePhase.ENHANCED_BOSS:
			return str(EncounterBGMKeys.get(run.current_boss_id, "boss")) if run.current_boss_id in ["grid_leech", "thermal_titan"] else "boss"
		CampaignRoute.RoutePhase.SINGULARITY:
			return "singularity"
		CampaignRoute.RoutePhase.FINAL_BOSS:
			var final_encounter_id: String = campaign_route.current_boss_id if not campaign_route.current_boss_id.is_empty() else run.current_boss_id
			return str(EncounterBGMKeys.get(final_encounter_id, "prime_current_form_1"))
		CampaignRoute.RoutePhase.INFINITE:
			return str(EncounterBGMKeys.get(run.current_boss_id, "hunt"))
		CampaignRoute.RoutePhase.NORMAL_END:
			return "ending_normal"
		CampaignRoute.RoutePhase.POST_TRUE_CHOICE:
			return "ending_world"
		CampaignRoute.RoutePhase.FINAL_END, CampaignRoute.RoutePhase.POSTGAME:
			return "ending_true"
		_:
			return "map"

func refresh_music(force := false) -> void:
	var next_key := desired_bgm_key()
	if next_key == bgm_key and not force:
		return
	bgm_key = next_key
	if bgm_players.is_empty() or not music_enabled:
		return
	var next_stream := BGMStreams.get(next_key) as AudioStream
	if next_stream == null:
		return
	if next_stream is AudioStreamOggVorbis:
		(next_stream as AudioStreamOggVorbis).loop = true
	elif next_stream is AudioStreamMP3:
		(next_stream as AudioStreamMP3).loop = true
	if bgm_crossfade != null and bgm_crossfade.is_valid():
		bgm_crossfade.kill()
	var previous_index := bgm_active_index
	var next_index := 0 if previous_index != 0 else 1
	var next_player := bgm_players[next_index]
	next_player.stop()
	next_player.stream = next_stream
	next_player.volume_db = BGM_SILENT_DB
	next_player.play()
	bgm_active_index = next_index
	bgm_crossfade = create_tween().set_parallel(true)
	bgm_crossfade.tween_property(next_player, "volume_db", BGM_VOLUME_DB, BGM_CROSSFADE_SECONDS)
	if previous_index >= 0:
		var previous_player := bgm_players[previous_index]
		bgm_crossfade.tween_property(previous_player, "volume_db", BGM_SILENT_DB, BGM_CROSSFADE_SECONDS)
		bgm_crossfade.finished.connect(func() -> void:
			if is_instance_valid(previous_player) and previous_player != bgm_players[bgm_active_index]:
				previous_player.stop()
		)


func play_defeat_jingle(kind: String) -> void:
	# The selected 13-second Suno cue has an immediate authored opening. We use a
	# short, softly faded excerpt so a kill reads as a musical event without
	# slowing the clicker loop or spilling far into the next screen.
	var hold := 2.15 if kind == "hunt" else 2.75 if kind == "boss" else 1.75
	if music_enabled and bgm_active_index >= 0 and desired_bgm_key() == bgm_key:
		if bgm_jingle_duck != null and bgm_jingle_duck.is_valid():
			bgm_jingle_duck.kill()
		var player := bgm_players[bgm_active_index]
		bgm_jingle_duck = create_tween()
		bgm_jingle_duck.tween_property(player, "volume_db", BGM_VOLUME_DB - 12.0, 0.07)
		bgm_jingle_duck.tween_interval(hold)
		bgm_jingle_duck.tween_property(player, "volume_db", BGM_VOLUME_DB, 0.34)
	if music_enabled and victory_jingle_player != null:
		if victory_jingle_fade != null and victory_jingle_fade.is_valid():
			victory_jingle_fade.kill()
		victory_jingle_player.stop()
		victory_jingle_player.pitch_scale = 1.08 if kind == "hunt" else 0.96 if kind == "boss" else 1.14
		victory_jingle_player.volume_db = -4.5 if kind == "boss" else -6.0
		victory_jingle_player.play()
		victory_jingle_fade = create_tween()
		victory_jingle_fade.tween_interval(hold)
		victory_jingle_fade.tween_property(victory_jingle_player, "volume_db", BGM_SILENT_DB, 0.38)
		victory_jingle_fade.finished.connect(func() -> void:
			if is_instance_valid(victory_jingle_player):
				victory_jingle_player.stop()
		)
	else:
		# Retain deterministic synthesized coverage for headless tests and any
		# platform unable to instantiate the streamed master.
		synth.defeat_jingle(kind)

func toggle_music() -> void:
	if audio_settings == null:
		return
	if audio_settings.music_volume > 0.001:
		music_volume_before_mute = audio_settings.music_volume
		audio_settings.music_volume = 0.0
	else:
		audio_settings.music_volume = maxf(0.1, music_volume_before_mute)
	audio_settings.save_settings()
	music_enabled = audio_settings.music_volume > 0.001
	if bgm_crossfade != null and bgm_crossfade.is_valid():
		bgm_crossfade.kill()
	if music_enabled:
		bgm_key = ""
		refresh_music()
		show_message(loc("BGM：オン", "MUSIC: ON"), 1.2)
	else:
		for player in bgm_players:
			player.stop()
			player.volume_db = BGM_SILENT_DB
		bgm_active_index = -1
		show_message(loc("BGM：オフ", "MUSIC: OFF"), 1.2)
	synth.click()
	queue_redraw()

func handle_music_toggle_input(event: InputEvent) -> bool:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_M:
		toggle_music()
		return true
	return false

func migrate_vertical_slice_save() -> void:
	# v4 intentionally uses a separate save file. Keeping this no-op makes old
	# development callers harmless without importing incompatible progression.
	pass

func apply_web_art_preview() -> void:
	if not OS.has_feature("web"):
		return
	var window = JavaScriptBridge.get_interface("window")
	if window == null:
		return
	var values := parse_query_string(str(window.location.search))
	var preview_hostname := str(window.location.hostname).to_lower()
	var is_local_preview_host := preview_hostname in ["127.0.0.1", "localhost", "::1"]
	campaign_preview_screen = str(values.get("campaign_preview", "")) if is_local_preview_host else ""
	debug_battle_id = str(values.get("debug_battle", "")) if is_local_preview_host else ""
	encounter_lab_enabled = is_local_preview_host and str(values.get("encounter_lab", "")) == "1"
	browser_test_muted = is_local_preview_host and str(values.get("mute_test", "")) == "1"
	var overlimit_value := str(values.get("overlimits", "all"))
	debug_battle_overlimit_count = 5 if overlimit_value == "all" else clampi(int(overlimit_value), 0, 5)
	story_preview_event_id = str(values.get("story_preview", "")) if OS.is_debug_build() else ""
	story_archive_preview_all = is_local_preview_host and str(values.get("story_archive", "")) == "all"
	debug_dialogue_requested = str(values.get("debug_dialogue", "")) == "1"
	if story_archive_preview_all:
		# Release exports are used for browser QA, so gate this by hostname rather
		# than OS.is_debug_build(). Never read or mutate the player's real save.
		persistence_enabled = false
	if not debug_battle_id.is_empty():
		persistence_enabled = false
	if encounter_lab_enabled:
		persistence_enabled = false
	if debug_dialogue_requested:
		pending_debug_dialogue = {
			"speaker_ja": str(values.get("dialogue_speaker", "デバッグ通信")),
			"speaker_en": str(values.get("dialogue_speaker_en", "DEBUG COMMS")),
			"text_ja": str(values.get("dialogue_text", "任意テキストボックスの表示確認。")),
			"text_en": str(values.get("dialogue_text_en", "ARBITRARY DIALOGUE BOX PREVIEW.")),
			"duration": clampf(float(str(values.get("dialogue_duration", "12.0"))), 1.0, 60.0),
			"role": str(values.get("dialogue_role", "support")),
		}
	art_preview_encounter = str(values.get("encounter", ""))
	art_preview_tree_gear = str(values.get("tree", ""))
	art_preview_tree_tier = clampi(int(str(values.get("tier", "3"))), 1, 4)
	if not story_preview_event_id.is_empty():
		art_preview_enabled = true
		persistence_enabled = false
	if values.has("artwork_index"):
		artwork_selected = clampi(int(str(values.get("artwork_index", "0"))), 0, ArtworkGallery.size() - 1)
	if str(values.get("art_preview", "")) != "1" and campaign_preview_screen.is_empty():
		return
	art_preview_enabled = true
	persistence_enabled = false
	var reactor_id := str(values.get("reactor", "reactor-hex-a"))
	var environment_id := str(values.get("environment", "environment-machine-room-a"))
	var cell_id := str(values.get("cell", "cell-hex-capsule-a"))
	var wraith_id := str(values.get("wraith", "wraith-manta-siphon-a"))
	var shard_id := str(values.get("shard", "shard-coil-spark-a"))
	var charge_control_id := str(values.get("charge_control", "charge-piston-a"))
	var discharge_control_id := str(values.get("discharge_control", "discharge-wave-a"))
	var auto_control_id := str(values.get("auto_control", "auto-stopped-rotor-a"))
	if ReactorTextures.has(reactor_id):
		reactor_texture = ReactorTextures[reactor_id]
	if GeneratorBackgrounds.has(environment_id):
		generator_background = GeneratorBackgrounds[environment_id]
	if CellTextures.has(cell_id):
		cell_texture = CellTextures[cell_id]
	if GridWraithTextures.has(wraith_id):
		grid_wraith_texture = GridWraithTextures[wraith_id]
	if EnergyShardTextures.has(shard_id):
		energy_shard_texture = EnergyShardTextures[shard_id]
	if ChargeControlTextures.has(charge_control_id):
		charge_control_texture = ChargeControlTextures[charge_control_id]
	if DischargeControlTextures.has(discharge_control_id):
		discharge_control_texture = DischargeControlTextures[discharge_control_id]
	if AutoControlTextures.has(auto_control_id):
		auto_control_texture = AutoControlTextures[auto_control_id]

func configure_campaign_preview() -> void:
	run.reset()
	campaign_route.reset()
	match campaign_preview_screen:
		"title":
			title_screen_open = true
			title_has_saved_campaign = false
			campaign_route.phase = CampaignRoute.RoutePhase.MAP
		"boss_select":
			for id in ["gearmaw", "vaultback", "pyre_wyrm"]:
				campaign_route.select_stage(id)
				var core_id := str(StageCatalog.stage(id).core_id)
				run.grant_beast_core(core_id)
				campaign_route.complete_current_stage(core_id)
			campaign_selected = 0
		"normal_end":
			for id in ["gearmaw", "vaultback", "pyre_wyrm"]:
				campaign_route.select_stage(id)
				var core_id := str(StageCatalog.stage(id).core_id)
				run.grant_beast_core(core_id)
				campaign_route.complete_current_stage(core_id)
			campaign_route.choose_first_boss("grid_leech")
			run.grant_boss_core("predation_reversal")
			campaign_route.defeat_current_boss()
		"true_map":
			for id in ["gearmaw", "vaultback", "pyre_wyrm"]:
				campaign_route.select_stage(id)
				var core_id := str(StageCatalog.stage(id).core_id)
				run.grant_beast_core(core_id)
				campaign_route.complete_current_stage(core_id)
			campaign_route.choose_first_boss("grid_leech")
			run.grant_boss_core("predation_reversal")
			campaign_route.defeat_current_boss()
			campaign_route.continue_true_route()
		"post_true_choice":
			campaign_route.true_end_seen = true
			campaign_route.phase = CampaignRoute.RoutePhase.POST_TRUE_CHOICE
			run.overlimit_system_unlocked = true
			run.singularity_residue = 0
			for definition in GearCatalog.SKILLS:
				run.upgrade_levels[str(definition.id)] = int(definition.max_rank)
			run.refresh_stats()
		"final_end":
			campaign_route.true_end_seen = true
			campaign_route.final_boss_defeated = true
			campaign_route.phase = CampaignRoute.RoutePhase.FINAL_END
			run.overlimit_system_unlocked = true
			for definition in GearCatalog.SKILLS:
				run.upgrade_levels[str(definition.id)] = int(definition.max_rank)
			for definition in GearCatalog.OVERLIMITS:
				run.upgrade_levels[str(definition.id)] = 1
			run.refresh_stats()
		"final_defeat":
			campaign_route.true_end_seen = true
			campaign_route.final_boss_defeated = true
			campaign_route.phase = CampaignRoute.RoutePhase.FINAL_END
			var explosion_definition := StageCatalog.boss("prime_current_form_3")
			run.begin_final_boss_form("prime_current_form_3", float(explosion_definition.hp), 3)
			run.boss_hp = 0.0
			run.stage_phase = ChargeState.StagePhase.CLEAR
			start_final_defeat_sequence()
		"final_explosion":
			campaign_route.true_end_seen = true
			campaign_route.final_boss_defeated = true
			campaign_route.phase = CampaignRoute.RoutePhase.FINAL_END
			var final_definition := StageCatalog.boss("prime_current_form_3")
			run.begin_final_boss_form("prime_current_form_3", float(final_definition.hp), 3)
			run.boss_hp = 0.0
			run.stage_phase = ChargeState.StagePhase.CLEAR
			start_final_defeat_cinematic()
		"artwork_gallery":
			campaign_route.true_end_seen = true
			campaign_route.final_boss_defeated = true
			campaign_route.final_credits_seen = true
			campaign_route.phase = CampaignRoute.RoutePhase.POSTGAME
			achievements.unlock_artwork_gallery()
			artwork_open = true
			title_screen_open = false
		_:
			campaign_selected = 0


func configure_debug_battle() -> bool:
	var aliases := {
		"prime_1": "prime_current_form_1",
		"prime_2": "prime_current_form_2",
		"prime_3": "prime_current_form_3",
		"prime_sequence": "prime_current_form_1",
	}
	var encounter_id := str(aliases.get(debug_battle_id, debug_battle_id))
	if encounter_id not in StageCatalog.final_boss_ids():
		debug_battle_id = ""
		return false
	run.reset()
	campaign_route.reset()
	for definition in StageCatalog.STAGES:
		var stage_id := str(definition.id)
		var core_id := str(definition.core_id)
		campaign_route.completed_stage_ids.append(stage_id)
		campaign_route.stage_rewards[stage_id] = core_id
		run.grant_beast_core(core_id)
	for definition in StageCatalog.BOSSES:
		var boss_id := str(definition.id)
		campaign_route.defeated_boss_ids.append(boss_id)
		run.grant_boss_core(str(definition.core_id))
	campaign_route.first_boss_id = str(StageCatalog.BOSSES[0].id)
	campaign_route.normal_end_seen = true
	campaign_route.true_end_seen = true
	campaign_route.deep_signal_answered = true
	campaign_route.tutorial_completed = true
	run.unlock_overlimit_system()
	for definition in GearCatalog.SKILLS:
		run.upgrade_levels[str(definition.id)] = int(definition.max_rank)
	for index in range(mini(debug_battle_overlimit_count, GearCatalog.OVERLIMITS.size())):
		run.upgrade_levels[str(GearCatalog.OVERLIMITS[index].id)] = 1
	run.credits = 240000000.0
	run.refresh_stats()
	var final_definition := StageCatalog.boss(encounter_id)
	var form := int(final_definition.get("form", 1))
	campaign_route.final_boss_form = form
	campaign_route.current_boss_id = encounter_id
	campaign_route.phase = CampaignRoute.RoutePhase.FINAL_BOSS
	run.begin_final_boss_form(encounter_id, float(final_definition.hp), form)
	title_screen_open = false
	var event_id := story_encounter_event_id(encounter_id)
	if not event_id.is_empty():
		start_story_event_once(event_id)
	return true


func configure_encounter_lab() -> void:
	run.reset()
	campaign_route.reset()
	encounter_lab_open = true
	encounter_lab_selected = clampi(encounter_lab_selected, 0, ENCOUNTER_LAB_IDS.size() - 1)
	encounter_lab_text_enabled = audio_settings.story_dialogue_enabled
	encounter_lab_last_action = loc("敵と確認項目を選択してください", "SELECT AN ENCOUNTER AND A PREVIEW STATE")
	encounter_lab_freeze_combat = false
	title_screen_open = false
	settings_open = false
	clear_comms()


func prepare_encounter_lab_build() -> void:
	run.reset()
	campaign_route.reset()
	for definition in StageCatalog.STAGES:
		run.grant_beast_core(str(definition.core_id))
	for definition in StageCatalog.BOSSES:
		run.grant_boss_core(str(definition.core_id))
	run.unlock_overlimit_system()
	for definition in GearCatalog.SKILLS:
		run.upgrade_levels[str(definition.id)] = int(definition.max_rank)
	for definition in GearCatalog.OVERLIMITS:
		run.upgrade_levels[str(definition.id)] = 1
	run.credits = 240000000.0
	run.refresh_stats()


func encounter_lab_selected_id() -> String:
	return str(ENCOUNTER_LAB_IDS[clampi(encounter_lab_selected, 0, ENCOUNTER_LAB_IDS.size() - 1)])


func encounter_lab_name(encounter_id: String) -> String:
	var definition := StageCatalog.stage(encounter_id)
	if definition.is_empty():
		definition = StageCatalog.boss(encounter_id)
	return str(definition.get("name_ja" if is_japanese else "name_en", encounter_id))


func configure_encounter_lab_battle(hp_ratio: float) -> bool:
	var encounter_id := encounter_lab_selected_id()
	var stage_definition := StageCatalog.stage(encounter_id)
	var boss_definition := StageCatalog.boss(encounter_id)
	if stage_definition.is_empty() and boss_definition.is_empty():
		return false
	prepare_encounter_lab_build()
	if not stage_definition.is_empty():
		campaign_route.phase = CampaignRoute.RoutePhase.STAGE
		campaign_route.current_stage_id = encounter_id
		var hp := StageCatalog.stage_hp(encounter_id, 5)
		run.begin_stage(encounter_id, str(stage_definition.build_tag), 1.0, hp, 5)
	else:
		campaign_route.current_boss_id = encounter_id
		if encounter_id in StageCatalog.final_boss_ids():
			campaign_route.phase = CampaignRoute.RoutePhase.FINAL_BOSS
			campaign_route.final_boss_form = int(boss_definition.get("form", 1))
			run.begin_final_boss_form(encounter_id, float(boss_definition.hp), campaign_route.final_boss_form)
		else:
			var singularity := encounter_id == str(StageCatalog.TRUE_BOSS.id)
			campaign_route.phase = CampaignRoute.RoutePhase.SINGULARITY if singularity else CampaignRoute.RoutePhase.BOSS
			run.begin_campaign_boss(encounter_id, float(boss_definition.hp), false, singularity)
	run.boss_hp = run.boss_max_hp * clampf(hp_ratio, 0.001, 1.0)
	encounter_lab_open = false
	encounter_lab_freeze_combat = true
	defeat_preview_open = false
	story_event_open = false
	clear_comms()
	var player_dialogue_setting: bool = bool(audio_settings.story_dialogue_enabled)
	audio_settings.story_dialogue_enabled = encounter_lab_text_enabled
	queue_encounter_intro(encounter_id)
	audio_settings.story_dialogue_enabled = player_dialogue_setting
	encounter_lab_last_action = loc("戦闘画面を固定表示中 — F8でラボへ", "COMBAT STATE FROZEN — PRESS F8 FOR LAB")
	bgm_key = ""
	refresh_music()
	queue_redraw()
	return true


func open_encounter_lab_story(defeat: bool) -> bool:
	var encounter_id := encounter_lab_selected_id()
	var event_id := story_encounter_event_id(encounter_id)
	if defeat:
		event_id = "prime.aftermath" if encounter_id == "prime_current_form_3" else story_defeat_event_id(encounter_id)
	if event_id.is_empty():
		encounter_lab_last_action = loc("この状態に専用会話はありません", "NO AUTHORED SCENE FOR THIS STATE")
		queue_redraw()
		return false
	if not encounter_lab_text_enabled:
		encounter_lab_last_action = loc("テキストOFF：%s を即時スキップ" % event_id, "TEXT OFF: %s SKIPPED IMMEDIATELY" % event_id)
		synth.click()
		queue_redraw()
		return true
	encounter_lab_open = false
	if not start_story_event(event_id, true):
		encounter_lab_open = true
		return false
	story_event_from_lab = false
	story_event_from_encounter_lab = true
	return true


func start_encounter_defeat_preview(encounter_id: String, return_to_lab := true, duration := 4.8) -> void:
	defeat_preview_encounter_id = encounter_id
	defeat_preview_time = 0.0
	defeat_preview_open = true
	defeat_preview_return_to_lab = return_to_lab
	defeat_preview_burst_stage = 0
	defeat_preview_duration = maxf(1.8, duration)
	encounter_lab_open = false
	encounter_lab_freeze_combat = true
	message_time = 0.0
	clear_comms()
	end_charge()
	screen_flash = 0.85
	screen_shake = 0.72
	var kind := "phase" if encounter_id in StageCatalog.final_boss_ids() else "boss" if encounter_id not in StageCatalog.stage_ids() else "hunt"
	play_defeat_jingle(kind)
	synth.boss_collapse_burst(1)
	queue_redraw()


func finish_encounter_defeat_preview() -> void:
	var resolve_campaign := pending_campaign_defeat_resolution
	defeat_preview_open = false
	defeat_preview_time = 0.0
	defeat_preview_encounter_id = ""
	defeat_preview_burst_stage = 0
	defeat_preview_duration = 4.8
	if defeat_preview_return_to_lab:
		encounter_lab_open = true
		encounter_lab_last_action = loc("撃破アニメーションを確認しました", "DEFEAT ANIMATION PREVIEWED")
	defeat_preview_return_to_lab = false
	if resolve_campaign:
		pending_campaign_defeat_resolution = false
		resolve_campaign_enemy_defeat()
	queue_redraw()

func configure_art_preview_state() -> void:
	var preview_id := art_preview_encounter if not art_preview_encounter.is_empty() else "gearmaw"
	var stage_definition := StageCatalog.stage(preview_id)
	var boss_definition := StageCatalog.boss(preview_id)
	if not stage_definition.is_empty():
		run.begin_stage(preview_id, str(stage_definition.build_tag), 1.0, StageCatalog.stage_hp(preview_id, 0), 0)
	elif not boss_definition.is_empty():
		if preview_id in StageCatalog.final_boss_ids():
			run.begin_final_boss_form(preview_id, float(boss_definition.get("hp", ChargeState.BOSS_MAX_HP)), int(boss_definition.get("form", 1)))
		else:
			run.begin_campaign_boss(preview_id, float(boss_definition.get("hp", ChargeState.BOSS_MAX_HP)), false, preview_id == "arch_singularity")
	else:
		run.begin_stage("gearmaw", "manual", 1.0, ChargeState.BOSS_MAX_HP, 0)
	run.boss_hp = run.boss_max_hp * 0.62
	run.credits = 128
	run.lifetime_charge = 356
	run.manual_inputs = 42
	run.armor_cracks = 7
	run.upgrade_levels["impact_coil"] = 3
	run.upgrade_levels["combo_gear"] = 2
	run.upgrade_levels["critical_math"] = 1
	run.upgrade_levels["auto_cannon"] = 3
	run.upgrade_levels["rapid_relay"] = 2
	run.upgrade_levels["charge_generator"] = 3
	run.upgrade_levels["drone_bay"] = 2
	run.refresh_stats()

func configure_art_preview_tree() -> void:
	if art_preview_tree_gear.is_empty():
		return
	for definition in StageCatalog.STAGES:
		run.grant_beast_core(str(definition.core_id))
	for definition in StageCatalog.BOSSES:
		run.grant_boss_core(str(definition.core_id))
	run.unlock_overlimit_system()
	for definition in GearCatalog.SKILLS:
		run.upgrade_levels[str(definition.id)] = int(definition.max_rank)
	run.credits = 240000000.0
	run.refresh_stats()
	selected_tree_tier = art_preview_tree_tier
	for index in range(GearCatalog.GEARS.size()):
		if str(GearCatalog.GEARS[index].id) == art_preview_tree_gear:
			selected_gear_index = index
			break
	gear_tree_open = true
	controller_upgrade_selected = 0

func parse_query_string(raw_query: String) -> Dictionary:
	var values := {}
	for pair in raw_query.trim_prefix("?").split("&", false):
		var parts := pair.split("=", true, 1)
		if parts.size() == 2:
			values[str(parts[0]).uri_decode()] = str(parts[1]).replace("+", " ").uri_decode()
	return values

func reset_run() -> void:
	reset_confirm_time = 0.0
	run.reset()
	campaign_route.reset()
	campaign_selected = 0
	campaign_hovered = -1
	if persistence_enabled:
		save_manager.clear()
	particles.clear()
	floating_texts.clear()
	resource_packets.clear()
	story_event_queue.clear()
	story_log_open = false
	shard_pulse = 0.0
	protagonist_action_pulse = 0.0
	manual_impact_pulse = 0.0
	manual_impact_critical = false
	manual_impact_generating = false
	auto_impact_pulse = 0.0
	charge_held = false
	gear_tree_open = false
	screen_flash = 0.0
	screen_shake = 0.0
	discharge_wave = 0.0
	show_message(loc("新しいキャンペーンを開始", "NEW CAMPAIGN INITIALIZED"), 1.8)
	synth.play_chord([220.0, 329.63, 440.0], 0.22, -24.0)
	save_progress()
	start_story_event_once("prologue.awakening")
	queue_redraw()

func enter_campaign_from_title() -> void:
	title_screen_open = false
	title_new_confirm_time = 0.0
	show_message(loc("討伐を再開", "HUNT RESUMED") if title_has_saved_campaign else loc("最初の機械魔獣を選択", "SELECT YOUR FIRST MECHANICAL BEAST"), 2.0)
	synth.confirm()
	queue_redraw()

func request_new_campaign_from_title() -> void:
	if title_has_saved_campaign and title_new_confirm_time <= 0.0:
		title_new_confirm_time = 3.0
		show_message(loc("キャンペーンを初期化します（実績は保持）。もう一度選択して確定", "RESET THE CAMPAIGN? RECORDS WILL REMAIN. SELECT AGAIN TO CONFIRM"), 3.0)
		synth.error()
		queue_redraw()
		return
	reset_run()
	title_has_saved_campaign = false
	title_screen_open = false
	title_new_confirm_time = 0.0
	queue_redraw()

func request_reset() -> bool:
	if reset_confirm_time > 0.0:
		reset_run()
		return true
	reset_confirm_time = 3.0
	show_message(loc("キャンペーンを初期化します（実績は保持）。3秒以内にもう一度R", "RESET CAMPAIGN? RECORDS REMAIN. PRESS R AGAIN WITHIN 3 SECONDS"), 3.0)
	synth.error()
	queue_redraw()
	return false

func _process(delta: float) -> void:
	animation_time += delta
	refresh_music()
	if screen_shake > 0.0:
		screen_shake = maxf(0.0, screen_shake - delta)
	if screen_flash > 0.0:
		screen_flash = maxf(0.0, screen_flash - delta * 2.4)
	if discharge_wave > 0.0:
		discharge_wave = maxf(0.0, discharge_wave - delta * 1.4)
	if shard_pulse > 0.0:
		shard_pulse = maxf(0.0, shard_pulse - delta * 1.7)
	if protagonist_action_pulse > 0.0:
		protagonist_action_pulse = maxf(0.0, protagonist_action_pulse - delta * 5.2)
	if manual_impact_pulse > 0.0:
		manual_impact_pulse = maxf(0.0, manual_impact_pulse - delta * 6.2)
	if auto_impact_pulse > 0.0:
		auto_impact_pulse = maxf(0.0, auto_impact_pulse - delta * 7.5)
	if message_time > 0.0:
		message_time -= delta
	if result_copied_time > 0.0:
		result_copied_time -= delta
	if reset_confirm_time > 0.0:
		reset_confirm_time -= delta
	if title_new_confirm_time > 0.0:
		title_new_confirm_time -= delta
	if achievement_notice_time > 0.0:
		achievement_notice_time -= delta
	update_comms(delta)
	if defeat_preview_open:
		defeat_preview_time += delta
		var next_preview_burst := mini(3, int(defeat_preview_time / 0.85))
		while defeat_preview_burst_stage < next_preview_burst:
			defeat_preview_burst_stage += 1
			synth.boss_collapse_burst(defeat_preview_burst_stage + 1)
			screen_flash = maxf(screen_flash, 0.72)
			screen_shake = maxf(screen_shake, 0.62 + float(defeat_preview_burst_stage) * 0.08)
		if defeat_preview_time >= defeat_preview_duration:
			finish_encounter_defeat_preview()
		update_effects(delta)
		queue_redraw()
		return
	if encounter_lab_open:
		update_effects(delta)
		queue_redraw()
		return
	if tutorial_open:
		update_effects(delta)
		queue_redraw()
		return
	if story_event_open or story_lab_open or story_log_open:
		update_effects(delta)
		queue_redraw()
		return
	if final_defeat_cinematic_open:
		update_final_defeat_cinematic(delta)
		update_effects(delta)
		queue_redraw()
		return
	if epilogue_open:
		epilogue_scene_time += delta
		if epilogue_scene_time >= epilogue_scene_duration(epilogue_scene):
			advance_true_epilogue(false)
		queue_redraw()
		return
	if artwork_open:
		update_effects(delta)
		queue_redraw()
		return
	if achievements_open:
		queue_redraw()
		return
	if credits_open:
		credits_scroll = minf(60.0, credits_scroll + delta)
		queue_redraw()
		return
	if title_screen_open or settings_open:
		update_effects(delta)
		queue_redraw()
		return
	autosave_timer -= delta
	if art_preview_enabled:
		update_effects(delta)
		queue_redraw()
		return
	if encounter_lab_enabled and encounter_lab_freeze_combat:
		update_effects(delta)
		queue_redraw()
		return
	if campaign_route.phase not in [CampaignRoute.RoutePhase.NORMAL_END, CampaignRoute.RoutePhase.POST_TRUE_CHOICE, CampaignRoute.RoutePhase.FINAL_END, CampaignRoute.RoutePhase.POSTGAME]:
		run.advance_session_time(delta)
	if not campaign_gameplay_active():
		if autosave_timer <= 0.0:
			autosave_timer = 5.0
			save_progress()
		update_effects(delta)
		queue_redraw()
		return

	var tick_result: Dictionary = run.tick(delta, false)
	check_singularity_story_phase()
	if int(tick_result.auto_hits) > 0:
		auto_impact_pulse = 1.0
		auto_effect_timer -= delta
		if auto_effect_timer <= 0.0:
			auto_effect_timer = 0.10
			spawn_sparks(Vector2(1030, 248), Palette.VIOLET, 3, 75.0)
			add_floating(Vector2(1030, 230), "-%s" % format_number(float(tick_result.auto_damage)), Palette.VIOLET, 13)
			synth.auto_shot(auto_mutation_key())
	if bool(tick_result.opportunity_opened):
		show_message(loc("吸収核が開いた — 3.5秒以内に8クリック！", "SIPHON OPEN — LAND EIGHT CLICKS IN 3.5 SECONDS!"), 2.0)
		synth.play_tone(659.25, 0.16, -19.0, 2)
	if bool(tick_result.boss_defeated):
		handle_enemy_defeated()
	if autosave_timer <= 0.0:
		autosave_timer = 5.0
		save_progress()

	update_effects(delta)
	queue_redraw()

func campaign_gameplay_active() -> bool:
	if campaign_route == null:
		return true
	if campaign_route.phase == CampaignRoute.RoutePhase.STAGE:
		return run.stage_phase not in [ChargeState.StagePhase.REWARD, ChargeState.StagePhase.CLEAR]
	if campaign_route.phase in [CampaignRoute.RoutePhase.BOSS, CampaignRoute.RoutePhase.ENHANCED_BOSS, CampaignRoute.RoutePhase.SINGULARITY, CampaignRoute.RoutePhase.FINAL_BOSS, CampaignRoute.RoutePhase.INFINITE]:
		return run.stage_phase == ChargeState.StagePhase.BOSS
	return false

func campaign_screen_visible() -> bool:
	if campaign_route == null or (art_preview_enabled and campaign_preview_screen.is_empty()):
		return false
	if campaign_route.phase in [CampaignRoute.RoutePhase.MAP, CampaignRoute.RoutePhase.TRUE_MAP, CampaignRoute.RoutePhase.BOSS_SELECT, CampaignRoute.RoutePhase.NORMAL_END, CampaignRoute.RoutePhase.POST_TRUE_CHOICE, CampaignRoute.RoutePhase.FINAL_END, CampaignRoute.RoutePhase.POSTGAME]:
		return true
	return campaign_route.phase in [CampaignRoute.RoutePhase.ENHANCED_BOSS, CampaignRoute.RoutePhase.SINGULARITY, CampaignRoute.RoutePhase.FINAL_BOSS] and run.stage_phase == ChargeState.StagePhase.CLEAR

func _unhandled_input(event: InputEvent) -> void:
	# Consume the event so a click/confirm that closes one screen cannot also
	# activate a control on the next screen in the same frame.
	get_viewport().set_input_as_handled()
	if encounter_lab_enabled and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F8:
		return_to_encounter_lab()
		return
	if encounter_lab_enabled and not encounter_lab_open and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and encounter_lab_return_rect.has_point(event.position):
		return_to_encounter_lab()
		return
	if encounter_lab_enabled and not encounter_lab_open and event is InputEventScreenTouch and event.pressed and encounter_lab_return_rect.has_point(event.position):
		return_to_encounter_lab()
		return
	if defeat_preview_open:
		handle_defeat_preview_input(event)
		return
	if encounter_lab_open:
		handle_encounter_lab_input(event)
		return
	if tutorial_open:
		handle_tutorial_input(event)
		return
	if story_lab_available() and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F9:
		toggle_story_lab()
		return
	if story_event_open:
		handle_story_event_input(event)
		return
	if story_lab_open:
		handle_story_lab_input(event)
		return
	if story_log_open:
		handle_story_log_input(event)
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F10:
		debug_show_dialogue(
			"デバッグ通信", "DEBUG COMMS",
			"任意会話ボックスの表示テスト。URLパラメータから話者と本文を差し替えられます。",
			"ARBITRARY DIALOGUE TEST. SPEAKER AND BODY COPY CAN BE REPLACED THROUGH URL PARAMETERS.",
			12.0
		)
		return
	if final_defeat_cinematic_open:
		handle_final_defeat_input(event)
		return
	if epilogue_open:
		handle_epilogue_input(event)
		return
	if artwork_open:
		handle_artwork_input(event)
		return
	if achievements_open:
		handle_achievements_input(event)
		return
	if credits_open:
		handle_credits_input(event)
		return
	if settings_open:
		handle_audio_settings_input(event)
		return
	if title_screen_open:
		handle_title_input(event)
		return
	if handle_settings_open_input(event):
		return
	if handle_music_toggle_input(event):
		return
	if gear_tree_open:
		handle_gear_tree_input(event)
		return
	if campaign_screen_visible():
		handle_campaign_input(event)
		return
	if run.stage_phase in [ChargeState.StagePhase.REWARD, ChargeState.StagePhase.CLEAR]:
		handle_completion_input(event)
		return
	if event is InputEventMouseMotion:
		mouse_position = event.position
		hover_upgrade = gear_at(event.position)
		queue_redraw()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		mouse_position = event.position
		if event.pressed:
			if charge_rect.has_point(event.position):
				begin_charge()
			else:
				handle_point(event.position)
		else:
			end_charge()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		perform_charge()
	elif event is InputEventScreenTouch:
		if event.pressed:
			if charge_rect.has_point(event.position):
				begin_charge()
			else:
				handle_point(event.position)
		else:
			end_charge()
	elif event is InputEventKey and not event.echo:
		handle_key(event)
	elif event is InputEventJoypadButton:
		handle_controller_button(event)
	elif event is InputEventJoypadMotion:
		var direction := controller_motion_direction(event)
		if direction != Vector2i.ZERO:
			navigate_upgrade(direction)

func handle_settings_open_input(event: InputEvent) -> bool:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F1:
		open_audio_settings()
		return true
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and settings_rect.has_point(event.position):
		open_audio_settings()
		return true
	if event is InputEventScreenTouch and event.pressed and settings_rect.has_point(event.position):
		open_audio_settings()
		return true
	return false

func handle_title_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_position = event.position
		for index in range(title_button_count()):
			if title_button_rects[index].has_point(event.position):
				title_selected = index
				break
		queue_redraw()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if language_rect.has_point(event.position):
			toggle_language()
			return
		for index in range(title_button_count()):
			if title_button_rects[index].has_point(event.position):
				title_selected = index
				activate_title_selection()
				return
	elif event is InputEventScreenTouch and event.pressed:
		if language_rect.has_point(event.position):
			toggle_language()
			return
		for index in range(title_button_count()):
			if title_button_rects[index].has_point(event.position):
				title_selected = index
				activate_title_selection()
				return
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_L:
			toggle_language()
		elif event.keycode == KEY_ESCAPE:
			return
		elif event.keycode == KEY_M:
			toggle_music()
		elif event.keycode in [KEY_UP, KEY_W]:
			title_selected = wrapi(title_selected - 1, 0, title_button_count())
			synth.click()
		elif event.keycode in [KEY_DOWN, KEY_S]:
			title_selected = wrapi(title_selected + 1, 0, title_button_count())
			synth.click()
		elif event.keycode in [KEY_ENTER, KEY_SPACE]:
			activate_title_selection()
	elif event is InputEventJoypadButton and event.pressed:
		if event.button_index == controller_button("back"):
			return
		elif event.button_index in [JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_LEFT]:
			title_selected = wrapi(title_selected - 1, 0, title_button_count())
			synth.click()
		elif event.button_index in [JOY_BUTTON_DPAD_DOWN, JOY_BUTTON_DPAD_RIGHT]:
			title_selected = wrapi(title_selected + 1, 0, title_button_count())
			synth.click()
		elif event.button_index == controller_button("primary"):
			activate_title_selection()
		elif event.button_index == controller_button("language"):
			toggle_language()
	elif event is InputEventJoypadMotion:
		var direction := controller_motion_direction(event)
		if direction != Vector2i.ZERO:
			var step := direction.y if direction.y != 0 else direction.x
			title_selected = wrapi(title_selected + step, 0, title_button_count())
			synth.click()
	queue_redraw()

func activate_title_selection() -> void:
	match title_selected:
		0:
			if title_has_saved_campaign:
				enter_campaign_from_title()
			else:
				request_new_campaign_from_title()
		1:
			request_new_campaign_from_title()
		2:
			open_audio_settings()
		3:
			open_achievements()
		4:
			open_credits(true)
		5:
			open_story_log(true)
		6:
			open_artwork_gallery()

func title_button_count() -> int:
	return title_button_rects.size() if achievements != null and achievements.artwork_gallery_unlocked else title_button_rects.size() - 1

func open_artwork_gallery() -> bool:
	if achievements == null or not achievements.artwork_gallery_unlocked:
		return false
	artwork_open = true
	artwork_viewer_open = false
	artwork_selected = clampi(artwork_selected, 0, ArtworkGallery.size() - 1)
	artwork_zoom_level = 0
	artwork_ui_visible = true
	title_screen_open = false
	settings_open = false
	achievements_open = false
	end_charge()
	bgm_key = ""
	refresh_music()
	synth.confirm()
	queue_redraw()
	return true

func close_artwork_gallery() -> void:
	artwork_open = false
	artwork_viewer_open = false
	artwork_zoom_level = 0
	artwork_ui_visible = true
	title_screen_open = true
	title_selected = mini(5, title_button_count() - 1)
	bgm_key = ""
	refresh_music()
	synth.click()
	queue_redraw()

func open_artwork_viewer(index: int = -1) -> void:
	if index >= 0:
		artwork_selected = wrapi(index, 0, ArtworkGallery.size())
	artwork_viewer_open = true
	artwork_zoom_level = 0
	artwork_ui_visible = true
	synth.confirm()
	queue_redraw()

func close_artwork_viewer() -> void:
	artwork_viewer_open = false
	artwork_zoom_level = 0
	artwork_ui_visible = true
	synth.click()
	queue_redraw()

func change_artwork_selection(step: int) -> void:
	artwork_selected = wrapi(artwork_selected + step, 0, ArtworkGallery.size())
	synth.click()
	queue_redraw()

func artwork_page_start() -> int:
	return floori(float(artwork_selected) / float(ARTWORK_PAGE_SIZE)) * ARTWORK_PAGE_SIZE

func artwork_index_for_slot(slot: int) -> int:
	var index := artwork_page_start() + slot
	return index if index < ArtworkGallery.size() else -1

func cycle_artwork_zoom(step: int = 1) -> void:
	artwork_zoom_level = wrapi(artwork_zoom_level + step, 0, 3)
	synth.click()
	queue_redraw()

func replay_true_ending_from_artwork() -> void:
	artwork_open = false
	artwork_viewer_open = false
	open_true_epilogue(true)

func handle_artwork_input(event: InputEvent) -> void:
	if artwork_viewer_open:
		handle_artwork_viewer_input(event)
		return
	if event is InputEventMouseMotion:
		mouse_position = event.position
		for slot in range(artwork_card_rects.size()):
			if artwork_card_rects[slot].has_point(event.position):
				var index := artwork_index_for_slot(slot)
				if index >= 0:
					artwork_selected = index
				break
		queue_redraw()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		handle_artwork_point(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		handle_artwork_point(event.position)
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			close_artwork_gallery()
		elif event.keycode in [KEY_LEFT, KEY_A, KEY_UP, KEY_W]:
			change_artwork_selection(-1)
		elif event.keycode in [KEY_RIGHT, KEY_D, KEY_DOWN, KEY_S]:
			change_artwork_selection(1)
		elif event.keycode in [KEY_ENTER, KEY_SPACE]:
			open_artwork_viewer()
		elif event.keycode == KEY_R:
			replay_true_ending_from_artwork()
		elif event.keycode == KEY_L:
			toggle_language()
		elif event.keycode == KEY_M:
			toggle_music()
	elif event is InputEventJoypadButton and event.pressed:
		if event.button_index == controller_button("back"):
			close_artwork_gallery()
		elif event.button_index in [JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_UP]:
			change_artwork_selection(-1)
		elif event.button_index in [JOY_BUTTON_DPAD_RIGHT, JOY_BUTTON_DPAD_DOWN]:
			change_artwork_selection(1)
		elif event.button_index == controller_button("primary"):
			open_artwork_viewer()
		elif event.button_index == controller_button("combat_action"):
			replay_true_ending_from_artwork()
	elif event is InputEventJoypadMotion:
		var direction := controller_motion_direction(event)
		if direction != Vector2i.ZERO:
			change_artwork_selection(direction.x if direction.x != 0 else direction.y)

func handle_artwork_point(point: Vector2) -> void:
	if artwork_close_rect.has_point(point):
		close_artwork_gallery()
		return
	if artwork_view_rect.has_point(point):
		open_artwork_viewer()
		return
	if artwork_replay_rect.has_point(point):
		replay_true_ending_from_artwork()
		return
	for slot in range(artwork_card_rects.size()):
		if artwork_card_rects[slot].has_point(point):
			var index := artwork_index_for_slot(slot)
			if index < 0:
				return
			artwork_selected = index
			open_artwork_viewer(index)
			return

func handle_artwork_viewer_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not artwork_ui_visible:
			artwork_ui_visible = true
			queue_redraw()
			return
		if artwork_full_back_rect.has_point(event.position):
			close_artwork_viewer()
		elif artwork_full_previous_rect.has_point(event.position):
			change_artwork_selection(-1)
		elif artwork_full_next_rect.has_point(event.position):
			change_artwork_selection(1)
		elif artwork_full_zoom_rect.has_point(event.position):
			cycle_artwork_zoom()
		elif artwork_full_ui_rect.has_point(event.position):
			artwork_ui_visible = false
			queue_redraw()
	elif event is InputEventScreenTouch and event.pressed:
		if not artwork_ui_visible:
			artwork_ui_visible = true
			queue_redraw()
			return
		if artwork_full_back_rect.has_point(event.position):
			close_artwork_viewer()
		elif artwork_full_previous_rect.has_point(event.position):
			change_artwork_selection(-1)
		elif artwork_full_next_rect.has_point(event.position):
			change_artwork_selection(1)
		elif artwork_full_zoom_rect.has_point(event.position):
			cycle_artwork_zoom()
		elif artwork_full_ui_rect.has_point(event.position):
			artwork_ui_visible = false
			queue_redraw()
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			close_artwork_viewer()
		elif event.keycode in [KEY_LEFT, KEY_A]:
			change_artwork_selection(-1)
		elif event.keycode in [KEY_RIGHT, KEY_D]:
			change_artwork_selection(1)
		elif event.keycode in [KEY_UP, KEY_W, KEY_Z]:
			cycle_artwork_zoom()
		elif event.keycode in [KEY_DOWN, KEY_S]:
			cycle_artwork_zoom(-1)
		elif event.keycode in [KEY_H, KEY_TAB, KEY_ENTER, KEY_SPACE]:
			artwork_ui_visible = not artwork_ui_visible
			queue_redraw()
		elif event.keycode == KEY_M:
			toggle_music()
	elif event is InputEventJoypadButton and event.pressed:
		if event.button_index == controller_button("back"):
			close_artwork_viewer()
		elif event.button_index in [JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_LEFT_SHOULDER]:
			change_artwork_selection(-1)
		elif event.button_index in [JOY_BUTTON_DPAD_RIGHT, JOY_BUTTON_RIGHT_SHOULDER]:
			change_artwork_selection(1)
		elif event.button_index == JOY_BUTTON_DPAD_UP:
			cycle_artwork_zoom()
		elif event.button_index == JOY_BUTTON_DPAD_DOWN:
			cycle_artwork_zoom(-1)
		elif event.button_index == controller_button("primary"):
			artwork_ui_visible = not artwork_ui_visible
			queue_redraw()

func open_achievements() -> void:
	achievements_open = true
	settings_open = false
	gear_tree_open = false
	end_charge()
	synth.confirm()
	queue_redraw()

func close_achievements() -> void:
	achievements_open = false
	synth.click()
	queue_redraw()

func handle_achievements_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if achievements_close_rect.has_point(event.position):
			close_achievements()
	elif event is InputEventScreenTouch and event.pressed:
		if achievements_close_rect.has_point(event.position):
			close_achievements()
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_ESCAPE, KEY_ENTER, KEY_SPACE, KEY_H]:
			close_achievements()
	elif event is InputEventJoypadButton and event.pressed:
		if event.button_index in [controller_button("back"), controller_button("primary")]:
			close_achievements()

func open_credits(from_title: bool, context: String = "") -> void:
	credits_open = true
	credits_return_to_title = from_title
	credits_context = context if not context.is_empty() else "title" if from_title else "normal"
	credits_scroll = 0.0
	settings_open = false
	end_charge()
	bgm_key = ""
	refresh_music()
	synth.confirm()
	queue_redraw()

func close_credits() -> void:
	credits_open = false
	credits_scroll = 0.0
	if credits_context == "world":
		title_screen_open = true
		title_has_saved_campaign = true
	elif credits_context == "final":
		campaign_route.complete_final_credits()
		title_screen_open = true
		title_has_saved_campaign = true
	elif credits_context == "artwork_replay":
		artwork_open = true
		artwork_viewer_open = false
		title_screen_open = false
	save_progress()
	bgm_key = ""
	refresh_music()
	synth.click()
	queue_redraw()

func start_final_defeat_sequence() -> void:
	end_charge()
	gear_tree_open = false
	message_time = 0.0
	clear_comms()
	# The last will now lands while the defeated seraph is still visible. With
	# dialogue disabled, start_story_event performs the after-action immediately.
	if not start_story_event_once("prime.defeat", "start_final_defeat_cinematic"):
		start_final_defeat_cinematic()


func start_final_defeat_cinematic() -> void:
	final_defeat_cinematic_open = true
	final_defeat_cinematic_time = 0.0
	final_defeat_burst_stage = 0
	message_time = 0.0
	clear_comms()
	end_charge()
	# Keep form-three music under the collapse. The true-ending master begins
	# only after the enemy has visibly disintegrated and the epilogue opens.
	bgm_key = ""
	refresh_music()
	synth.boss_collapse_burst(0)
	screen_flash = 1.0
	screen_shake = 0.95
	queue_redraw()

func update_final_defeat_cinematic(delta: float) -> void:
	final_defeat_cinematic_time += delta
	var next_burst_stage := mini(4, int(final_defeat_cinematic_time / 1.15))
	while final_defeat_burst_stage < next_burst_stage:
		final_defeat_burst_stage += 1
		synth.boss_collapse_burst(final_defeat_burst_stage)
		screen_flash = maxf(screen_flash, 0.78 if final_defeat_burst_stage < 4 else 1.0)
		screen_shake = maxf(screen_shake, 0.72 + float(final_defeat_burst_stage) * 0.08)
	if final_defeat_cinematic_time >= FINAL_DEFEAT_CINEMATIC_SECONDS:
		finish_final_defeat_cinematic()

func finish_final_defeat_cinematic() -> void:
	if not final_defeat_cinematic_open:
		return
	final_defeat_cinematic_open = false
	final_defeat_cinematic_time = 0.0
	final_defeat_burst_stage = 0
	clear_comms()
	synth.true_clear()
	queue_story_event_once("prime.aftermath")
	queue_story_event_once("ending.true_dawn", "true_epilogue")

func handle_final_defeat_input(event: InputEvent) -> void:
	var skip_requested := false
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		skip_requested = epilogue_skip_rect.has_point(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		skip_requested = epilogue_skip_rect.has_point(event.position)
	elif event is InputEventKey and event.pressed and not event.echo:
		skip_requested = event.keycode in [KEY_ESCAPE, KEY_ENTER, KEY_SPACE]
	elif event is InputEventJoypadButton and event.pressed:
		skip_requested = event.button_index in [controller_button("back"), controller_button("primary")]
	if skip_requested and final_defeat_cinematic_time >= 1.0:
		finish_final_defeat_cinematic()

func open_true_epilogue(return_to_artwork: bool = false) -> void:
	epilogue_open = true
	epilogue_scene = 0
	epilogue_scene_time = 0.0
	epilogue_return_to_artwork = return_to_artwork
	end_charge()
	bgm_key = ""
	refresh_music()
	queue_redraw()

func epilogue_scene_duration(scene_index: int) -> float:
	return float(EPILOGUE_SCENE_SECONDS[clampi(scene_index, 0, EPILOGUE_SCENE_SECONDS.size() - 1)])

func advance_true_epilogue(play_sound: bool = true) -> void:
	if not epilogue_open:
		return
	if epilogue_scene < 7:
		epilogue_scene += 1
		epilogue_scene_time = 0.0
		if play_sound:
			synth.confirm()
	else:
		finish_true_epilogue()
	queue_redraw()

func finish_true_epilogue() -> void:
	epilogue_open = false
	open_credits(false, "artwork_replay" if epilogue_return_to_artwork else "final")
	epilogue_return_to_artwork = false

func handle_epilogue_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if epilogue_skip_rect.has_point(event.position):
			finish_true_epilogue()
		else:
			advance_true_epilogue()
	elif event is InputEventScreenTouch and event.pressed:
		if epilogue_skip_rect.has_point(event.position):
			finish_true_epilogue()
		else:
			advance_true_epilogue()
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			finish_true_epilogue()
		elif event.keycode in [KEY_ENTER, KEY_SPACE, KEY_RIGHT]:
			advance_true_epilogue()
		elif event.keycode == KEY_LEFT and epilogue_scene > 0:
			epilogue_scene -= 1
			epilogue_scene_time = 0.0
	elif event is InputEventJoypadButton and event.pressed:
		if event.button_index == controller_button("back"):
			finish_true_epilogue()
		elif event.button_index == controller_button("primary"):
			advance_true_epilogue()

func handle_credits_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if credits_close_rect.has_point(event.position):
			close_credits()
	elif event is InputEventScreenTouch and event.pressed:
		if credits_close_rect.has_point(event.position):
			close_credits()
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_ESCAPE, KEY_ENTER, KEY_SPACE]:
			close_credits()
		elif event.keycode in [KEY_DOWN, KEY_S]:
			credits_scroll = minf(60.0, credits_scroll + 4.0)
		elif event.keycode in [KEY_UP, KEY_W]:
			credits_scroll = maxf(0.0, credits_scroll - 4.0)
	elif event is InputEventJoypadButton and event.pressed:
		if event.button_index in [controller_button("back"), controller_button("primary")]:
			close_credits()

func open_audio_settings() -> void:
	settings_open = true
	settings_selected = clampi(settings_selected, 0, settings_row_rects.size() - 1)
	end_charge()
	synth.click()
	queue_redraw()

func close_audio_settings() -> void:
	settings_open = false
	synth.click()
	queue_redraw()

func handle_audio_settings_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_position = event.position
		for index in range(settings_row_rects.size()):
			if settings_row_rects[index].has_point(event.position):
				settings_selected = index
				break
		queue_redraw()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		handle_audio_settings_point(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		handle_audio_settings_point(event.position)
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_ESCAPE, KEY_F1]:
			close_audio_settings()
		elif event.keycode == KEY_R:
			open_tutorial(true)
		elif event.keycode in [KEY_UP, KEY_W]:
			settings_selected = wrapi(settings_selected - 1, 0, settings_row_rects.size())
			synth.click()
		elif event.keycode in [KEY_DOWN, KEY_S]:
			settings_selected = wrapi(settings_selected + 1, 0, settings_row_rects.size())
			synth.click()
		elif event.keycode in [KEY_LEFT, KEY_A]:
			adjust_audio_setting(settings_selected, -1)
		elif event.keycode in [KEY_RIGHT, KEY_D]:
			adjust_audio_setting(settings_selected, 1)
	elif event is InputEventJoypadButton and event.pressed:
		if event.button_index == controller_button("back"):
			close_audio_settings()
		elif event.button_index == JOY_BUTTON_DPAD_UP:
			settings_selected = wrapi(settings_selected - 1, 0, settings_row_rects.size())
			synth.click()
		elif event.button_index == JOY_BUTTON_DPAD_DOWN:
			settings_selected = wrapi(settings_selected + 1, 0, settings_row_rects.size())
			synth.click()
		elif event.button_index == JOY_BUTTON_DPAD_LEFT:
			adjust_audio_setting(settings_selected, -1)
		elif event.button_index == JOY_BUTTON_DPAD_RIGHT:
			adjust_audio_setting(settings_selected, 1)
	elif event is InputEventJoypadMotion:
		var direction := controller_motion_direction(event)
		if direction.y != 0:
			settings_selected = wrapi(settings_selected + direction.y, 0, settings_row_rects.size())
			synth.click()
		elif direction.x != 0:
			adjust_audio_setting(settings_selected, direction.x)
	queue_redraw()

func handle_audio_settings_point(point: Vector2) -> void:
	if settings_close_rect.has_point(point):
		close_audio_settings()
		return
	if settings_reset_rect.has_point(point):
		audio_settings.reset_defaults()
		music_enabled = true
		music_volume_before_mute = audio_settings.music_volume
		bgm_key = ""
		refresh_music()
		synth.confirm()
		queue_redraw()
		return
	if settings_tutorial_rect.has_point(point):
		open_tutorial(true)
		return
	for index in range(settings_row_rects.size()):
		var row := settings_row_rects[index]
		if row.has_point(point):
			settings_selected = index
			if index == 5:
				set_audio_setting(index, 0.0 if audio_settings.story_dialogue_enabled else 1.0)
				return
			var slider_left := row.position.x + 230.0
			var ratio := clampf((point.x - slider_left) / 280.0, 0.0, 1.0)
			set_audio_setting(index, ratio)
			return

func adjust_audio_setting(index: int, direction: int) -> void:
	var values := audio_setting_values()
	if index < 0 or index >= values.size():
		return
	if index == 5:
		set_audio_setting(index, 0.0 if audio_settings.story_dialogue_enabled else 1.0)
		return
	var step := 0.1 if index < 3 else 0.25
	set_audio_setting(index, clampf(float(values[index]) + float(direction) * step, 0.0, 1.0))

func set_audio_setting(index: int, value: float) -> void:
	match index:
		0:
			audio_settings.master_volume = value
		1:
			audio_settings.music_volume = value
			if value > 0.001:
				music_volume_before_mute = value
		2:
			audio_settings.sfx_volume = value
		3:
			audio_settings.screen_shake_intensity = value
		4:
			audio_settings.flash_intensity = value
		5:
			audio_settings.story_dialogue_enabled = value >= 0.5
	var was_enabled := music_enabled
	audio_settings.save_settings()
	music_enabled = audio_settings.music_volume > 0.001
	if music_enabled and (not was_enabled or bgm_active_index < 0):
		bgm_key = ""
		refresh_music()
	synth.click()
	queue_redraw()

func audio_setting_values() -> Array[float]:
	return [
		audio_settings.master_volume,
		audio_settings.music_volume,
		audio_settings.sfx_volume,
		audio_settings.screen_shake_intensity,
		audio_settings.flash_intensity,
		1.0 if audio_settings.story_dialogue_enabled else 0.0,
	]

func handle_campaign_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_position = event.position
		var hovered := campaign_index_at(event.position)
		campaign_hovered = hovered
		if hovered >= 0:
			campaign_selected = hovered
		queue_redraw()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		handle_campaign_point(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		handle_campaign_point(event.position)
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_L:
			toggle_language()
		elif event.keycode == KEY_C and campaign_route.phase in [CampaignRoute.RoutePhase.NORMAL_END, CampaignRoute.RoutePhase.POST_TRUE_CHOICE, CampaignRoute.RoutePhase.FINAL_END, CampaignRoute.RoutePhase.POSTGAME]:
			copy_campaign_result()
		elif event.keycode == KEY_E and campaign_route.phase == CampaignRoute.RoutePhase.NORMAL_END:
			open_credits(false, "normal")
		elif event.keycode == KEY_T and campaign_route.phase in [CampaignRoute.RoutePhase.POST_TRUE_CHOICE, CampaignRoute.RoutePhase.POSTGAME]:
			selected_tree_tier = 4
			open_gear_tree(0)
		elif event.keycode == KEY_H:
			open_achievements()
		elif event.keycode == KEY_J:
			open_story_log(false)
		elif event.keycode == KEY_R:
			request_reset()
		elif event.keycode == KEY_T and campaign_route.phase in [CampaignRoute.RoutePhase.MAP, CampaignRoute.RoutePhase.TRUE_MAP]:
			open_gear_tree(0)
		elif event.keycode == KEY_ESCAPE:
			return_to_title_safely()
		elif event.keycode in [KEY_LEFT, KEY_A]:
			navigate_campaign_selection(Vector2i.LEFT)
		elif event.keycode in [KEY_RIGHT, KEY_D]:
			navigate_campaign_selection(Vector2i.RIGHT)
		elif event.keycode in [KEY_UP, KEY_W]:
			navigate_campaign_selection(Vector2i.UP)
		elif event.keycode in [KEY_DOWN, KEY_S]:
			navigate_campaign_selection(Vector2i.DOWN)
		elif event.keycode in [KEY_ENTER, KEY_SPACE]:
			activate_campaign_selection()
	elif event is InputEventJoypadButton and event.pressed:
		match event.button_index:
			JOY_BUTTON_DPAD_LEFT:
				navigate_campaign_selection(Vector2i.LEFT)
			JOY_BUTTON_DPAD_RIGHT:
				navigate_campaign_selection(Vector2i.RIGHT)
			JOY_BUTTON_DPAD_UP:
				navigate_campaign_selection(Vector2i.UP)
			JOY_BUTTON_DPAD_DOWN:
				navigate_campaign_selection(Vector2i.DOWN)
			_:
				if event.button_index == controller_button("primary"):
					activate_campaign_selection()
				elif event.button_index == controller_button("secondary") and campaign_route.phase == CampaignRoute.RoutePhase.NORMAL_END:
					open_credits(false, "normal")
				elif event.button_index == controller_button("combat_action") and campaign_route.phase in [CampaignRoute.RoutePhase.NORMAL_END, CampaignRoute.RoutePhase.POST_TRUE_CHOICE, CampaignRoute.RoutePhase.FINAL_END, CampaignRoute.RoutePhase.POSTGAME]:
					copy_campaign_result()
				elif event.button_index == controller_button("language"):
					toggle_language()
				elif event.button_index == controller_button("menu") and campaign_route.phase in [CampaignRoute.RoutePhase.MAP, CampaignRoute.RoutePhase.TRUE_MAP]:
					open_gear_tree(selected_gear_index)
				elif event.button_index == controller_button("back"):
					return_to_title_safely()
	elif event is InputEventJoypadMotion:
		var direction := controller_motion_direction(event)
		if direction != Vector2i.ZERO:
			navigate_campaign_selection(direction)

func handle_campaign_point(point: Vector2) -> void:
	if story_log_rect.has_point(point):
		open_story_log(false)
		return
	if menu_rect.has_point(point):
		return_to_title_safely()
		return
	if campaign_ending_return_rect.has_point(point) and campaign_route.phase in [CampaignRoute.RoutePhase.NORMAL_END, CampaignRoute.RoutePhase.POST_TRUE_CHOICE, CampaignRoute.RoutePhase.FINAL_END, CampaignRoute.RoutePhase.POSTGAME]:
		if campaign_route.phase in [CampaignRoute.RoutePhase.FINAL_END, CampaignRoute.RoutePhase.POSTGAME]:
			title_screen_open = true
			title_has_saved_campaign = true
			save_progress()
		else:
			return_to_title_safely()
		return
	if campaign_credits_rect.has_point(point) and campaign_route.phase == CampaignRoute.RoutePhase.NORMAL_END:
		open_credits(false, "normal")
		return
	if campaign_credits_rect.has_point(point) and campaign_route.phase == CampaignRoute.RoutePhase.POSTGAME:
		open_true_epilogue()
		return
	if campaign_achievement_rect.has_point(point) and campaign_route.phase in [CampaignRoute.RoutePhase.NORMAL_END, CampaignRoute.RoutePhase.POST_TRUE_CHOICE, CampaignRoute.RoutePhase.FINAL_END, CampaignRoute.RoutePhase.POSTGAME]:
		open_achievements()
		return
	if campaign_secondary_rect.has_point(point) and campaign_route.phase in [CampaignRoute.RoutePhase.ENHANCED_BOSS, CampaignRoute.RoutePhase.SINGULARITY]:
		return_to_title_safely()
		return
	if language_rect.has_point(point):
		toggle_language()
		return
	if reset_rect.has_point(point):
		request_reset()
		return
	if respec_rect.has_point(point) and campaign_route.phase in [CampaignRoute.RoutePhase.MAP, CampaignRoute.RoutePhase.TRUE_MAP]:
		open_gear_tree(0)
		return
	if respec_rect.has_point(point) and campaign_route.phase in [CampaignRoute.RoutePhase.POST_TRUE_CHOICE, CampaignRoute.RoutePhase.POSTGAME]:
		selected_tree_tier = 4
		open_gear_tree(0)
		return
	if campaign_copy_rect.has_point(point) and campaign_route.phase in [CampaignRoute.RoutePhase.NORMAL_END, CampaignRoute.RoutePhase.POST_TRUE_CHOICE, CampaignRoute.RoutePhase.FINAL_END, CampaignRoute.RoutePhase.POSTGAME]:
		copy_campaign_result()
		return
	var index := campaign_index_at(point)
	if index >= 0:
		campaign_selected = index
		activate_campaign_selection()
		return
	if campaign_route.phase == CampaignRoute.RoutePhase.POST_TRUE_CHOICE and campaign_primary_rect.has_point(point):
		campaign_selected = 0
		activate_campaign_selection()
		return
	if campaign_route.phase == CampaignRoute.RoutePhase.POST_TRUE_CHOICE and campaign_secondary_rect.has_point(point):
		campaign_selected = 1
		activate_campaign_selection()
		return
	if campaign_primary_rect.has_point(point) and campaign_route.phase in [CampaignRoute.RoutePhase.NORMAL_END, CampaignRoute.RoutePhase.ENHANCED_BOSS, CampaignRoute.RoutePhase.SINGULARITY, CampaignRoute.RoutePhase.FINAL_BOSS, CampaignRoute.RoutePhase.FINAL_END, CampaignRoute.RoutePhase.POSTGAME]:
		activate_campaign_selection()

func campaign_index_at(point: Vector2) -> int:
	if campaign_route.phase in [CampaignRoute.RoutePhase.MAP, CampaignRoute.RoutePhase.TRUE_MAP]:
		for index in range(stage_map_rects.size()):
			if stage_map_rects[index].has_point(point):
				return index
	elif campaign_route.phase == CampaignRoute.RoutePhase.BOSS_SELECT:
		for index in range(boss_select_rects.size()):
			if boss_select_rects[index].has_point(point):
				return index
	return -1

func navigate_campaign_selection(direction: Vector2i) -> void:
	if campaign_route.phase in [CampaignRoute.RoutePhase.MAP, CampaignRoute.RoutePhase.TRUE_MAP]:
		var column := campaign_selected % 3
		var row := campaign_selected / 3
		column = wrapi(column + direction.x, 0, 3)
		row = wrapi(row + direction.y, 0, 2)
		campaign_selected = row * 3 + column
		for step in range(6):
			var stage_id := str(StageCatalog.STAGES[campaign_selected].id)
			if stage_id not in campaign_route.completed_stage_ids:
				break
			campaign_selected = wrapi(campaign_selected + (1 if direction.x >= 0 and direction.y >= 0 else -1), 0, 6)
	elif campaign_route.phase == CampaignRoute.RoutePhase.BOSS_SELECT:
		campaign_selected = wrapi(campaign_selected + (1 if direction.x > 0 or direction.y > 0 else -1), 0, 2)
	elif campaign_route.phase == CampaignRoute.RoutePhase.POST_TRUE_CHOICE:
		campaign_selected = wrapi(campaign_selected + (1 if direction.x > 0 or direction.y > 0 else -1), 0, 2)
	synth.click()
	queue_redraw()

func activate_campaign_selection() -> void:
	match campaign_route.phase:
		CampaignRoute.RoutePhase.MAP, CampaignRoute.RoutePhase.TRUE_MAP:
			start_stage_by_index(campaign_selected)
		CampaignRoute.RoutePhase.BOSS_SELECT:
			choose_campaign_boss(campaign_selected)
		CampaignRoute.RoutePhase.NORMAL_END:
			if campaign_route.continue_true_route():
				campaign_selected = first_available_stage_index()
				show_message(loc("真ルート解放 — 残り3体の機械魔獣を討て", "TRUE ROUTE OPEN — HUNT THE REMAINING THREE BEASTS"), 3.0)
				synth.play_chord([196.0, 293.66, 440.0, 587.33], 0.5, -20.0)
				save_progress()
		CampaignRoute.RoutePhase.ENHANCED_BOSS, CampaignRoute.RoutePhase.SINGULARITY, CampaignRoute.RoutePhase.FINAL_BOSS:
			launch_current_campaign_boss()
		CampaignRoute.RoutePhase.POST_TRUE_CHOICE:
			if campaign_selected == 0:
				if campaign_route.choose_world_engine_credits():
					if not start_story_event_once("ending.world_ascent", "world_credits"):
						open_credits(true, "world")
			else:
				if run.overlimit_count() <= 0:
					selected_tree_tier = 4
					open_gear_tree(0)
					show_message(loc("本当のラスボスへ挑むには、まずOVERLIMITを1つ復旧", "RESTORE AT LEAST ONE OVERLIMIT BEFORE ANSWERING THE SIGNAL"), 3.2)
				elif campaign_route.answer_deep_signal():
					if not start_story_event_once("prime.signal_answer", "launch_campaign_boss"):
						launch_current_campaign_boss()
		CampaignRoute.RoutePhase.FINAL_END:
			open_true_epilogue()
		CampaignRoute.RoutePhase.POSTGAME:
			start_infinite_mode()
	queue_redraw()

func first_available_stage_index() -> int:
	for index in range(StageCatalog.STAGES.size()):
		if str(StageCatalog.STAGES[index].id) not in campaign_route.completed_stage_ids:
			return index
	return 0

func start_stage_by_index(index: int) -> bool:
	if index < 0 or index >= StageCatalog.STAGES.size():
		return false
	var definition: Dictionary = StageCatalog.STAGES[index]
	var id := str(definition.id)
	if not campaign_route.select_stage(id):
		show_message(loc("この機械魔獣は討伐済み", "THIS BEAST HAS ALREADY BEEN DEFEATED"), 1.4)
		synth.error()
		return false
	var encounter_order: int = campaign_route.completed_stage_ids.size()
	var hp := StageCatalog.stage_hp(id, encounter_order)
	run.begin_stage(id, str(definition.build_tag), 1.0, hp, encounter_order)
	reward_selected = 0
	show_message(loc("討伐開始：", "HUNT STARTED: ") + stage_name(definition), 2.2)
	var encounter_event_id := story_encounter_event_id(id)
	var tutorial_needed: bool = encounter_order == 0 and not campaign_route.tutorial_completed
	var tutorial_action := "open_tutorial" if tutorial_needed else ""
	if encounter_event_id.is_empty() or not start_story_event_once(encounter_event_id, tutorial_action):
		queue_encounter_intro(id)
		if tutorial_needed:
			open_tutorial()
	synth.play_chord([164.81, 246.94, 329.63], 0.28, -22.0)
	save_progress()
	return true

func choose_campaign_boss(index: int) -> bool:
	if index < 0 or index >= StageCatalog.BOSSES.size():
		return false
	var definition: Dictionary = StageCatalog.BOSSES[index]
	if not campaign_route.choose_first_boss(str(definition.id)):
		return false
	launch_current_campaign_boss()
	return true

func launch_current_campaign_boss() -> bool:
	var definition := StageCatalog.boss(campaign_route.current_boss_id)
	if definition.is_empty():
		return false
	var enhanced: bool = campaign_route.phase == CampaignRoute.RoutePhase.ENHANCED_BOSS
	var singularity: bool = campaign_route.phase == CampaignRoute.RoutePhase.SINGULARITY
	var final_encounter: bool = campaign_route.phase == CampaignRoute.RoutePhase.FINAL_BOSS
	var hp := float(definition.get("hp", ChargeState.BOSS_MAX_HP))
	if enhanced:
		hp = float(definition.get("enhanced_hp", hp * 1.65))
	if final_encounter:
		run.begin_final_boss_form(str(definition.id), hp, int(definition.get("form", campaign_route.final_boss_form)))
	else:
		run.begin_campaign_boss(str(definition.id), hp, enhanced, singularity)
	show_message(loc("原初電流との最終戦闘開始", "PRIME CURRENT ENGAGED") if final_encounter else loc("深層主獣との戦闘開始", "ABYSSAL BOSS ENGAGED"), 2.4)
	story_singularity_phase = run.singularity_phase
	var encounter_event_id := story_encounter_event_id(str(definition.id))
	if encounter_event_id.is_empty() or not start_story_event_once(encounter_event_id):
		queue_encounter_intro(str(definition.id))
	screen_flash = 0.8
	screen_shake = 0.35
	synth.boss_engage()
	save_progress()
	return true

func start_infinite_mode() -> bool:
	if not campaign_route.start_infinite():
		return false
	show_message(loc("Infinite Mode解放 — 実績条件なし・全強化を完成できる", "INFINITE MODE OPEN — NO EXCLUSIVE RECORDS, FINISH ANY STANDARD SKILLS"), 3.0)
	return launch_infinite_wave()

func infinite_encounter_id(wave: int) -> String:
	var ids: Array[String] = []
	ids.append_array(StageCatalog.stage_ids())
	ids.append_array(StageCatalog.boss_ids())
	ids.append(str(StageCatalog.TRUE_BOSS.id))
	return ids[wrapi(maxi(1, wave) - 1, 0, ids.size())]

func infinite_hp_for_wave(wave: int) -> float:
	return float(StageCatalog.TRUE_BOSS.hp) * pow(1.65, float(maxi(0, wave - 1)))

func infinite_reward_for_wave(wave: int) -> int:
	return maxi(1, int(round(2000000.0 * pow(1.8, float(maxi(0, wave - 1))))))

func launch_infinite_wave() -> bool:
	if campaign_route.phase != CampaignRoute.RoutePhase.INFINITE:
		return false
	var wave := maxi(1, campaign_route.infinite_wave)
	var encounter_id := infinite_encounter_id(wave)
	run.begin_infinite_wave(encounter_id, infinite_hp_for_wave(wave), wave)
	show_message(loc("無限演算 WAVE %d — %s" % [wave, encounter_name()], "INFINITE WAVE %d — %s" % [wave, encounter_name()]), 2.6)
	queue_encounter_intro(encounter_id)
	screen_flash = 0.65
	synth.boss_engage()
	save_progress()
	return true

func leave_infinite_mode() -> bool:
	if not campaign_route.leave_infinite():
		return false
	run.infinite_mode = false
	show_message(loc("Infinite Modeを終了 — 完全復旧記録へ帰還", "INFINITE MODE ENDED — RETURNING TO TOTAL RESTORATION"), 2.2)
	save_progress()
	queue_redraw()
	return true

func complete_stage_and_return_to_route() -> bool:
	if campaign_route.phase != CampaignRoute.RoutePhase.STAGE or run.stage_phase != ChargeState.StagePhase.CLEAR:
		return false
	var completed_definition := StageCatalog.stage(campaign_route.current_stage_id)
	if not completed_definition.is_empty():
		run.grant_beast_core(str(completed_definition.core_id))
	if not campaign_route.complete_current_stage(str(completed_definition.get("core_id", ""))):
		return false
	campaign_selected = 0 if campaign_route.phase == CampaignRoute.RoutePhase.BOSS_SELECT else first_available_stage_index()
	show_message(loc("機械核を統合 — 討伐地図へ帰還", "MECHANICAL CORE INTEGRATED — RETURNING TO THE HUNT MAP"), 2.0)
	synth.core_integrated()
	match campaign_route.completed_stage_ids.size():
		1:
			queue_story_event_once("milestone.first_core")
		3:
			queue_story_event_once("milestone.third_core")
		6:
			queue_story_event_once("milestone.six_cores")
	save_progress()
	return true

func complete_campaign_boss(defeat_jingle_already_played := false) -> bool:
	var defeated_id: String = str(campaign_route.current_boss_id)
	var defeated_definition := StageCatalog.boss(campaign_route.current_boss_id)
	var defeated_final_form: bool = bool(run.final_boss)
	if not defeated_definition.is_empty() and defeated_definition.has("core_id"):
		run.grant_boss_core(str(defeated_definition.core_id))
	if campaign_route.current_boss_id == str(StageCatalog.TRUE_BOSS.id):
		run.unlock_overlimit_system()
	if not campaign_route.defeat_current_boss():
		return false
	run.stage_phase = ChargeState.StagePhase.CLEAR
	screen_flash = 1.0
	screen_shake = 0.75
	if defeated_final_form and campaign_route.phase == CampaignRoute.RoutePhase.FINAL_END:
		start_final_defeat_sequence()
	elif defeated_final_form:
		play_defeat_jingle("phase")
		synth.phase_transition(campaign_route.final_boss_form)
	elif not defeat_jingle_already_played:
		play_defeat_jingle("boss")
	var defeat_event_id := story_defeat_event_id(defeated_id)
	if not defeated_final_form and not defeat_event_id.is_empty():
		queue_story_event_once(defeat_event_id)
	if campaign_route.phase == CampaignRoute.RoutePhase.NORMAL_END:
		queue_story_event_once("ending.normal_signal")
	record_campaign_result_if_needed()
	save_progress()
	return true

func campaign_ending_key() -> String:
	if campaign_route.phase in [CampaignRoute.RoutePhase.FINAL_END, CampaignRoute.RoutePhase.POSTGAME]:
		return "prime_current"
	return "world_engine" if campaign_route.true_end_seen else "normal"

func current_playtest_report() -> Dictionary:
	return run.build_playtest_report(campaign_route.snapshot(), campaign_ending_key())

func campaign_result_json() -> String:
	return JSON.stringify(current_playtest_report(), "  ")

func record_campaign_result_if_needed() -> bool:
	if campaign_route.phase not in [CampaignRoute.RoutePhase.NORMAL_END, CampaignRoute.RoutePhase.POST_TRUE_CHOICE, CampaignRoute.RoutePhase.FINAL_END]:
		return false
	var ending := campaign_ending_key()
	if run.ending_exported(ending):
		return true
	if not persistence_enabled:
		return false
	var file: FileAccess
	if FileAccess.file_exists(PLAYTEST_LOG_PATH):
		file = FileAccess.open(PLAYTEST_LOG_PATH, FileAccess.READ_WRITE)
		if file != null:
			file.seek_end()
	else:
		file = FileAccess.open(PLAYTEST_LOG_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_line(JSON.stringify(current_playtest_report()))
	file.close()
	run.mark_ending_exported(ending)
	return true

func campaign_result_text() -> String:
	var ending := loc("通常復旧", "NORMAL RESTORATION") if campaign_route.phase == CampaignRoute.RoutePhase.NORMAL_END else loc("完全復旧", "TOTAL RESTORATION")
	return "VOLT NOMAD — %s\n%s %s | %s %s | %s %d/6 | %s %d/2\n%s %s | %s %d | %s %d | ID %s" % [
		ending,
		loc("総時間", "SESSION"), format_time(run.session_elapsed),
		loc("戦闘", "COMBAT"), format_time(run.elapsed),
		loc("回路", "CIRCUITS"), campaign_route.completed_stage_ids.size(),
		loc("ボス", "BOSSES"), campaign_route.defeated_boss_ids.size(),
		loc("最大打撃", "PEAK HIT"), format_number(run.highest_output),
		loc("強化LV", "UPGRADE LEVELS"), run.skill_points_bought(),
		loc("累計CHARGE", "TOTAL CHARGE"), run.lifetime_charge,
		run.session_id,
	]

func respec_skill_tree() -> void:
	var refunded: int = run.respec_skills()
	show_message(loc("強化経路を初期化：CHARGE +%d" % refunded, "UPGRADE ROUTES RESET: +%d CHARGE" % refunded), 2.2)
	synth.play_chord([196.0, 261.63, 392.0], 0.26, -22.0)
	save_progress()
	queue_redraw()

func copy_campaign_result() -> void:
	result_copy_succeeded = set_clipboard_text(campaign_result_json())
	result_copied_time = 2.0
	if result_copy_succeeded:
		synth.confirm()
	else:
		synth.error()
	queue_redraw()

func set_clipboard_text(text: String) -> bool:
	if not OS.has_feature("web"):
		DisplayServer.clipboard_set(text)
		return true
	var document = JavaScriptBridge.get_interface("document")
	if document == null or document.body == null:
		return false
	var textarea = document.createElement("textarea")
	textarea.value = text
	textarea.setAttribute("readonly", "")
	textarea.style.position = "fixed"
	textarea.style.opacity = "0"
	document.body.appendChild(textarea)
	textarea.focus()
	textarea.select()
	var copied := bool(document.execCommand("copy"))
	document.body.removeChild(textarea)
	return copied

func handle_key(event: InputEventKey) -> void:
	if event.keycode == KEY_SPACE:
		if event.pressed:
			begin_charge()
		else:
			end_charge()
		return
	if not event.pressed:
		return
	match event.keycode:
		KEY_ESCAPE:
			return_to_title_safely()
		KEY_ENTER, KEY_X:
			perform_charge()
		KEY_A:
			perform_charge()
		KEY_T:
			open_gear_tree(selected_gear_index)
		KEY_L:
			toggle_language()
		KEY_R:
			request_reset()
		KEY_1, KEY_KP_1:
			open_gear_tree(0)
		KEY_2, KEY_KP_2:
			open_gear_tree(1)
		KEY_3, KEY_KP_3:
			open_gear_tree(2)
		KEY_4, KEY_KP_4:
			open_gear_tree(3)
		KEY_5, KEY_KP_5:
			open_gear_tree(4)

func handle_controller_button(event: InputEventJoypadButton) -> void:
	if event.pressed and event.button_index in [JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_RIGHT, JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_DOWN]:
		match event.button_index:
			JOY_BUTTON_DPAD_LEFT:
				navigate_upgrade(Vector2i.LEFT)
			JOY_BUTTON_DPAD_RIGHT:
				navigate_upgrade(Vector2i.RIGHT)
			JOY_BUTTON_DPAD_UP:
				navigate_upgrade(Vector2i.UP)
			JOY_BUTTON_DPAD_DOWN:
				navigate_upgrade(Vector2i.DOWN)
		return
	if event.button_index == controller_button("primary"):
		if event.pressed:
			begin_charge()
		else:
			end_charge()
		return
	if not event.pressed:
		return
	if event.button_index == controller_button("secondary"):
		perform_charge()
	elif event.button_index == controller_button("combat_action"):
		perform_charge()
	elif event.button_index == controller_button("menu"):
		open_gear_tree(selected_gear_index)
	elif event.button_index == controller_button("language"):
		toggle_language()
	elif event.button_index == controller_button("back"):
		return_to_title_safely()

func handle_point(point: Vector2) -> void:
	if menu_rect.has_point(point):
		return_to_title_safely()
	elif language_rect.has_point(point):
		toggle_language()
	elif reset_rect.has_point(point):
		request_reset()
	elif enemy_click_rect.has_point(point):
		perform_charge()
	else:
		var index := gear_at(point)
		if index >= 0:
			open_gear_tree(index)

func handle_completion_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_position = event.position
		if run.stage_phase == ChargeState.StagePhase.REWARD:
			for index in range(reward_rects.size()):
				if reward_rects[index].has_point(event.position):
					reward_selected = index
		queue_redraw()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		handle_completion_point(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		handle_completion_point(event.position)
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_L:
			toggle_language()
		elif event.keycode == KEY_R:
			request_reset()
		elif run.stage_phase == ChargeState.StagePhase.REWARD and event.keycode in [KEY_LEFT, KEY_A]:
			reward_selected = wrapi(reward_selected - 1, 0, reward_rects.size())
		elif run.stage_phase == ChargeState.StagePhase.REWARD and event.keycode in [KEY_RIGHT, KEY_D]:
			reward_selected = wrapi(reward_selected + 1, 0, reward_rects.size())
		elif run.stage_phase == ChargeState.StagePhase.REWARD and event.keycode in [KEY_1, KEY_KP_1]:
			select_reward(0)
		elif run.stage_phase == ChargeState.StagePhase.REWARD and event.keycode in [KEY_2, KEY_KP_2]:
			select_reward(1)
		elif run.stage_phase == ChargeState.StagePhase.REWARD and event.keycode in [KEY_3, KEY_KP_3]:
			select_reward(2)
		elif event.keycode in [KEY_ENTER, KEY_SPACE]:
			if run.stage_phase == ChargeState.StagePhase.REWARD:
				select_reward(reward_selected)
			elif campaign_route.phase == CampaignRoute.RoutePhase.INFINITE:
				launch_infinite_wave()
			else:
				complete_stage_and_return_to_route()
	elif event is InputEventJoypadButton and event.pressed:
		if event.button_index in [JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_UP] and run.stage_phase == ChargeState.StagePhase.REWARD:
			reward_selected = wrapi(reward_selected - 1, 0, reward_rects.size())
			synth.click()
		elif event.button_index in [JOY_BUTTON_DPAD_RIGHT, JOY_BUTTON_DPAD_DOWN] and run.stage_phase == ChargeState.StagePhase.REWARD:
			reward_selected = wrapi(reward_selected + 1, 0, reward_rects.size())
			synth.click()
		elif event.button_index == controller_button("primary"):
			if run.stage_phase == ChargeState.StagePhase.REWARD:
				select_reward(reward_selected)
			elif campaign_route.phase == CampaignRoute.RoutePhase.INFINITE:
				launch_infinite_wave()
			else:
				complete_stage_and_return_to_route()
		elif event.button_index == controller_button("language"):
			toggle_language()
		elif event.button_index == controller_button("back"):
			return_to_title_safely()
	elif event is InputEventJoypadMotion and run.stage_phase == ChargeState.StagePhase.REWARD:
		var direction := controller_motion_direction(event)
		if direction != Vector2i.ZERO:
			var step := direction.x if direction.x != 0 else direction.y
			reward_selected = wrapi(reward_selected + step, 0, reward_rects.size())
			synth.click()
			queue_redraw()

func controller_motion_direction(event: InputEventJoypadMotion) -> Vector2i:
	var direction := Vector2i.ZERO
	if event.axis == JOY_AXIS_LEFT_X:
		if absf(event.axis_value) < 0.45:
			controller_axis_latch.x = 0
		elif controller_axis_latch.x == 0:
			controller_axis_latch.x = 1 if event.axis_value > 0.0 else -1
			direction.x = controller_axis_latch.x
	elif event.axis == JOY_AXIS_LEFT_Y:
		if absf(event.axis_value) < 0.45:
			controller_axis_latch.y = 0
		elif controller_axis_latch.y == 0:
			controller_axis_latch.y = 1 if event.axis_value > 0.0 else -1
			direction.y = controller_axis_latch.y
	return direction

func handle_completion_point(point: Vector2) -> void:
	if clear_menu_rect.has_point(point) and campaign_route.phase == CampaignRoute.RoutePhase.INFINITE:
		leave_infinite_mode()
	elif menu_rect.has_point(point) or clear_menu_rect.has_point(point):
		return_to_title_safely()
	elif language_rect.has_point(point):
		toggle_language()
	elif run.stage_phase == ChargeState.StagePhase.REWARD:
		for index in range(reward_rects.size()):
			if reward_rects[index].has_point(point):
				select_reward(index)
				return
	elif clear_retry_rect.has_point(point):
		if campaign_route.phase == CampaignRoute.RoutePhase.INFINITE:
			launch_infinite_wave()
		else:
			complete_stage_and_return_to_route()

func reward_copy(index: int) -> Dictionary:
	return [
		{"id": "flywheel", "title": loc("運動フライホイール", "KINETIC FLYWHEEL"), "tag": loc("手動・超放電", "MANUAL · SUPER"), "desc": loc("手動充電+15%\n満充電放電+12%", "+15% MANUAL CHARGE\n+12% FULL DISCHARGE"), "color": Palette.AMBER},
		{"id": "coolant", "title": loc("極低温クーラント", "CRYO COOLANT"), "tag": loc("冷却・過充電", "COOLING · RISK"), "desc": loc("冷却速度+25%\n発熱-12%", "+25% COOLING\n-12% HEAT GENERATED"), "color": Palette.MINT},
		{"id": "relay", "title": loc("自律リレー種子", "AUTONOMOUS RELAY"), "tag": loc("AUTO・安定", "AUTO · STABLE"), "desc": loc("AUTO速度+35%\n全放電出力+6%", "+35% AUTO RATE\n+6% ALL DISCHARGE"), "color": Palette.VIOLET},
	][index]

func select_reward(index: int) -> bool:
	if index < 0 or index >= reward_rects.size():
		return false
	var reward := reward_copy(index)
	if not run.select_reward(str(reward.id)):
		return false
	reward_selected = index
	screen_flash = 0.8
	spawn_sparks(reward_rects[index].get_center(), Color(reward.color), 30, 240.0)
	synth.play_chord([261.63, 329.63, 392.0, 523.25], 0.42, -20.0)
	show_message(loc("回路を獲得：", "CIRCUIT ACQUIRED: ") + str(reward.title), 2.5)
	save_progress()
	queue_redraw()
	return true

func show_boss_warning() -> void:
	if run.current_boss_id == "thermal_titan" or (run.singularity_boss and run.singularity_phase == 2):
		show_message(loc("警告：2秒後、熱波。高熱弱点へ備えよ", "WARNING: HEAT SURGE IN 2 SECONDS — PREPARE THE REDLINE"), 2.0)
	else:
		show_message(loc("警告：2秒後、最大充電セルを吸収", "WARNING: DRAINING YOUR FULLEST CELL IN 2 SECONDS"), 2.0)
	spawn_sparks(Vector2(815, 130), Palette.CORAL, 16, 170.0)
	synth.warning()

func show_boss_drain(cell_index: int, drained: float, healed: float) -> void:
	screen_shake = 0.38
	screen_flash = 0.45
	var target := cell_center(maxi(0, cell_index))
	spawn_sparks(target, Palette.CORAL, 22, 190.0)
	if cell_index >= 0:
		show_message(loc("セル%02dを吸収：-%.0f / 敵+%.0f" % [cell_index + 1, drained, healed], "CELL %02d DRAINED: -%.0f / ENEMY +%.0f" % [cell_index + 1, drained, healed]), 2.0)
	else:
		show_message(loc("吸収対象なし — 熱だけが上昇", "NOTHING TO DRAIN — HEAT STILL RISES"), 2.0)
	synth.error()
	save_progress()

func show_thermal_spike(healed: float) -> void:
	screen_shake = 0.46
	screen_flash = 0.62
	spawn_sparks(REACTOR_CENTER, Palette.CORAL, 28, 210.0)
	show_message(loc("熱波襲来：熱上昇 / 敵回復 +%.0f" % healed, "THERMAL SURGE: HEAT UP / ENEMY +%.0f" % healed), 2.0)
	synth.play_chord([98.0, 130.81, 155.56], 0.32, -17.0)
	save_progress()

func save_progress() -> void:
	evaluate_achievements(true)
	if persistence_enabled and save_manager != null:
		save_manager.save_bundle(run, campaign_route, achievements)


func return_to_title_safely() -> void:
	# Save synchronously before main.gd frees this node. This closes the gap
	# between five-second autosaves, including story choices and boss launches.
	save_progress()
	return_to_menu.emit()

func evaluate_achievements(show_notice: bool = true) -> void:
	if achievements == null or run == null or campaign_route == null:
		return
	var newly_unlocked: Array[Dictionary] = achievements.evaluate(run, campaign_route)
	if newly_unlocked.is_empty() or not show_notice:
		return
	achievement_notice = newly_unlocked.back()
	achievement_notice_time = 4.0
	if synth != null:
		synth.play_chord([261.63, 392.0, 523.25, 659.25], 0.32, -21.0)

func controller_button(action: String) -> int:
	return int(controller_bindings.get(action, ControllerConfig.DEFAULTS.get(action, JOY_BUTTON_A)))

func navigate_upgrade(direction: Vector2i) -> void:
	if gear_tree_open:
		navigate_tree_node(direction)
		return
	if direction.x != 0 or direction.y != 0:
		selected_gear_index = wrapi(selected_gear_index + (1 if direction.x > 0 or direction.y > 0 else -1), 0, GearCatalog.GEARS.size())
		hover_upgrade = selected_gear_index
		var gear: Dictionary = GearCatalog.GEARS[selected_gear_index]
		show_message(loc("選択：", "SELECTED: ") + gear_name(gear) + loc("　STARTでツリー", "  ·  START FOR TREE"), 1.4)
	synth.click()
	queue_redraw()

func open_gear_tree(index: int) -> void:
	selected_gear_index = clampi(index, 0, GearCatalog.GEARS.size() - 1)
	gear_tree_open = true
	selected_tree_tier = clampi(selected_tree_tier, 1, 4)
	controller_upgrade_selected = 0
	end_charge()
	synth.play_tone(392.0, 0.08, -24.0, 2)
	queue_redraw()

func close_gear_tree() -> void:
	gear_tree_open = false
	synth.click()
	queue_redraw()

func selected_gear_id() -> String:
	return str(GearCatalog.GEARS[selected_gear_index].id)

func selected_tree_skills() -> Array[Dictionary]:
	return GearCatalog.skills_for_gear_tier(selected_gear_id(), selected_tree_tier)

func set_tree_tier(tier: int) -> void:
	selected_tree_tier = clampi(tier, 1, 4)
	controller_upgrade_selected = 0
	var label := loc("基礎機構", "FOUNDATION") if selected_tree_tier == 1 else loc("主獣オーバークロック", "BOSS OVERCLOCK") if selected_tree_tier == 2 else loc("六核特異改造", "SIX-CORE SINGULARITY") if selected_tree_tier == 3 else "OVERLIMIT"
	show_message("TIER %s // %s" % [roman_tier(selected_tree_tier), label], 1.2)
	synth.click()
	queue_redraw()

func roman_tier(tier: int) -> String:
	return "I" if tier == 1 else "II" if tier == 2 else "III" if tier == 3 else "IV"

func selected_skill_definition() -> Dictionary:
	var skills := selected_tree_skills()
	if skills.is_empty():
		return {}
	controller_upgrade_selected = clampi(controller_upgrade_selected, 0, skills.size() - 1)
	return skills[controller_upgrade_selected]

func tree_node_rect(definition: Dictionary) -> Rect2:
	return Rect2(66 + int(definition.col) * 246, 220 + int(definition.row) * 94, 216, 70)

func tree_tier_at(point: Vector2) -> int:
	for index in range(tree_tier_rects.size()):
		if tree_tier_rects[index].has_point(point):
			return index + 1
	return 0

func tree_tab_at(point: Vector2) -> int:
	for index in range(tree_tab_rects.size()):
		if tree_tab_rects[index].has_point(point):
			return index
	return -1

func tree_node_at(point: Vector2) -> int:
	var skills := selected_tree_skills()
	for index in range(skills.size()):
		if tree_node_rect(skills[index]).has_point(point):
			return index
	return -1

func navigate_tree_node(direction: Vector2i) -> void:
	var skills := selected_tree_skills()
	if skills.is_empty():
		return
	controller_upgrade_selected = clampi(controller_upgrade_selected, 0, skills.size() - 1)
	var current := skills[controller_upgrade_selected]
	var best_index := controller_upgrade_selected
	var best_score := 99999.0
	for index in range(skills.size()):
		if index == controller_upgrade_selected:
			continue
		var candidate := skills[index]
		var dx := int(candidate.col) - int(current.col)
		var dy := int(candidate.row) - int(current.row)
		if direction.x < 0 and dx >= 0 or direction.x > 0 and dx <= 0 or direction.y < 0 and dy >= 0 or direction.y > 0 and dy <= 0:
			continue
		var score := float(dx * dx + dy * dy * 2)
		if score < best_score:
			best_score = score
			best_index = index
	controller_upgrade_selected = best_index
	synth.click()
	queue_redraw()

func handle_gear_tree_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_position = event.position
		var hovered := tree_node_at(event.position)
		if hovered >= 0:
			controller_upgrade_selected = hovered
		queue_redraw()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		handle_gear_tree_point(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		handle_gear_tree_point(event.position)
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_ESCAPE, KEY_T]:
			close_gear_tree()
		elif event.keycode in [KEY_ENTER, KEY_SPACE]:
			purchase_selected_tree_node()
		elif event.keycode in [KEY_LEFT, KEY_A]:
			navigate_tree_node(Vector2i.LEFT)
		elif event.keycode in [KEY_RIGHT, KEY_D]:
			navigate_tree_node(Vector2i.RIGHT)
		elif event.keycode in [KEY_UP, KEY_W]:
			navigate_tree_node(Vector2i.UP)
		elif event.keycode in [KEY_DOWN, KEY_S]:
			navigate_tree_node(Vector2i.DOWN)
		elif event.keycode == KEY_Q:
			open_gear_tree(wrapi(selected_gear_index - 1, 0, GearCatalog.GEARS.size()))
		elif event.keycode == KEY_E:
			open_gear_tree(wrapi(selected_gear_index + 1, 0, GearCatalog.GEARS.size()))
		elif event.keycode == KEY_Z:
			set_tree_tier(wrapi(selected_tree_tier - 2, 0, 4) + 1)
		elif event.keycode == KEY_X:
			set_tree_tier(selected_tree_tier % 4 + 1)
		elif event.keycode >= KEY_1 and event.keycode <= KEY_5:
			open_gear_tree(int(event.keycode - KEY_1))
	elif event is InputEventJoypadButton and event.pressed:
		match event.button_index:
			JOY_BUTTON_DPAD_LEFT:
				navigate_tree_node(Vector2i.LEFT)
			JOY_BUTTON_DPAD_RIGHT:
				navigate_tree_node(Vector2i.RIGHT)
			JOY_BUTTON_DPAD_UP:
				navigate_tree_node(Vector2i.UP)
			JOY_BUTTON_DPAD_DOWN:
				navigate_tree_node(Vector2i.DOWN)
			JOY_BUTTON_LEFT_SHOULDER:
				open_gear_tree(wrapi(selected_gear_index - 1, 0, GearCatalog.GEARS.size()))
			JOY_BUTTON_RIGHT_SHOULDER:
				open_gear_tree(wrapi(selected_gear_index + 1, 0, GearCatalog.GEARS.size()))
			_:
				if event.button_index == controller_button("primary"):
					purchase_selected_tree_node()
				elif event.button_index in [controller_button("back"), controller_button("menu")]:
					close_gear_tree()
				elif event.button_index == controller_button("combat_action"):
					purchase_selected_tree_node()
				elif event.button_index == controller_button("language"):
					set_tree_tier(selected_tree_tier % 4 + 1)
	elif event is InputEventJoypadMotion:
		var direction := controller_motion_direction(event)
		if direction != Vector2i.ZERO:
			navigate_tree_node(direction)

func handle_gear_tree_point(point: Vector2) -> void:
	if tree_close_rect.has_point(point):
		close_gear_tree()
		return
	if tree_purchase_rect.has_point(point):
		purchase_selected_tree_node()
		return
	if tree_respec_rect.has_point(point) and campaign_route.phase in [CampaignRoute.RoutePhase.MAP, CampaignRoute.RoutePhase.TRUE_MAP]:
		respec_skill_tree()
		return
	var tier := tree_tier_at(point)
	if tier > 0:
		set_tree_tier(tier)
		return
	var tab_index := tree_tab_at(point)
	if tab_index >= 0:
		open_gear_tree(tab_index)
		return
	var node_index := tree_node_at(point)
	if node_index >= 0:
		controller_upgrade_selected = node_index
		purchase_selected_tree_node()

func purchase_selected_tree_node() -> bool:
	var definition := selected_skill_definition()
	if definition.is_empty():
		return false
	return try_purchase_skill(str(definition.id), tree_node_rect(definition).get_center())

func begin_charge() -> void:
	if charge_held or run.stage_phase in [ChargeState.StagePhase.REWARD, ChargeState.StagePhase.CLEAR]:
		return
	charge_held = true
	perform_charge()

func end_charge() -> void:
	charge_held = false
	charge_repeat_timer = 0.0

func perform_charge(play_sound: bool = true, critical_mode: int = -1) -> Dictionary:
	if run.stage_phase in [ChargeState.StagePhase.REWARD, ChargeState.StagePhase.CLEAR]:
		return {"valid": false, "critical": false, "damage": 0.0, "charge": 0, "boss_defeated": false}
	var result: Dictionary = run.manual_attack(critical_mode)
	protagonist_action_pulse = 1.0
	var generating := bool(result.get("generating", false))
	manual_impact_pulse = 1.0
	manual_impact_critical = bool(result.critical)
	manual_impact_generating = generating
	var attack_origin := charge_rect.get_center()
	var target := Vector2(1038, 248)
	var hit_color := Palette.MINT if generating else Palette.AMBER if bool(result.critical) else Palette.CYAN
	spawn_sparks(SHARD_SOCKET_CENTER if generating else target, hit_color, 8 if bool(result.critical) else 4, 150.0)
	particles.append({"pos": attack_origin, "velocity": ((SHARD_SOCKET_CENTER if generating else target) - attack_origin) * 4.4, "life": 0.18, "max_life": 0.18, "color": hit_color, "size": 5.0})
	if generating:
		add_floating(target + Vector2(0, -28), loc("発電指令", "GENERATOR COMMAND"), Palette.MINT, 18)
	else:
		add_floating(target + Vector2(0, -28), "-%s" % format_number(float(result.damage)), hit_color, 25 if bool(result.critical) else 18)
	if int(result.charge) > 0:
		add_floating(SHARD_SOCKET_CENTER + Vector2(0, 32), "+%d CHARGE" % int(result.charge), Palette.AMBER, 14)
		spawn_resource_flow(attack_origin if generating else target, SHARD_SOCKET_CENTER, Palette.MINT if generating else Palette.CYAN, 3 if generating else 2)
		shard_pulse = 0.55
	if play_sound:
		synth.charge_attack(bool(result.critical), generating)
		var mechanic_sound := str(result.get("mechanic", ""))
		if not mechanic_sound.is_empty():
			synth.mechanic_accent(mechanic_sound)
	if bool(result.critical):
		add_floating(target + Vector2(0, -62), loc("クリティカル", "CRITICAL"), Palette.AMBER, 18)
		screen_shake = maxf(screen_shake, 0.18)
	elif not generating:
		screen_shake = maxf(screen_shake, 0.07)
	match str(result.mechanic):
		"armor_break":
			show_message(loc("装甲破砕！ 12回目のクリックが4倍", "ARMOR BREAK! THE 12TH CLICK HITS FOR 4×"), 1.4)
			add_floating(target + Vector2(0, -88), loc("装甲破砕 ×4", "ARMOR BREAK ×4"), Palette.AMBER, 20)
		"impact_shockwave":
			add_floating(target + Vector2(0, -88), loc("衝撃波", "SHOCKWAVE"), Palette.AMBER, 20)
		"armor_punch":
			add_floating(target + Vector2(0, -88), loc("穿孔衝撃波", "PUNCH SHOCKWAVE"), Palette.AMBER, 20)
		"harvest":
			show_message(loc("動力刈取：追加CHARGE", "POWER HARVEST: BONUS CHARGE"), 1.2)
		"twin_trigger":
			show_message(loc("双発指令：AUTO即時追撃", "TWIN TRIGGER: INSTANT AUTO VOLLEY"), 1.2)
		"siphon_break":
			show_message(loc("吸収核を破砕！ 5倍打撃＋CHARGE獲得", "SIPHON SHATTERED! 5× HIT + CHARGE"), 2.0)
			screen_flash = 0.8
			screen_shake = 0.55
		"furnace_open":
			show_message(loc("炉心露出！ 6秒間すべての攻撃が2倍", "FURNACE EXPOSED! ALL DAMAGE ×2 FOR SIX SECONDS"), 2.0)
		"singularity_burst":
			show_message(loc("特異点バースト！", "SINGULARITY BURST!"), 1.5)
	check_singularity_story_phase()
	if bool(result.boss_defeated):
		handle_enemy_defeated()
	elif generating:
		show_message(loc("PURE指令：直接ダメージ0 / CHARGE +%d / AUTO過給 ×%d" % [int(result.charge), run.auto_boost_stacks], "PURE COMMAND: 0 DIRECT DAMAGE / +%d CHARGE / AUTO BOOST ×%d" % [int(result.charge), run.auto_boost_stacks]), 0.9)
	else:
		var multiplier_text := " ×%.2f" % run.last_damage_multiplier if absf(run.last_damage_multiplier - 1.0) > 0.05 else ""
		show_message(loc("%sへ %sダメージ%s / CHARGE +%d" % [encounter_name(), format_number(float(result.damage)), multiplier_text, int(result.charge)], "%s DAMAGE TO %s%s / CHARGE +%d" % [format_number(float(result.damage)), encounter_name(), multiplier_text, int(result.charge)]), 0.8)
	return result

func perform_discharge(play_sound: bool = true, critical_mode: int = -1) -> Dictionary:
	var hit := perform_charge(play_sound, critical_mode)
	return {"valid": bool(hit.valid), "output": float(hit.damage), "credits": int(hit.charge), "super": false, "critical": bool(hit.critical)}

func toggle_auto(play_sound: bool = true) -> bool:
	run.auto_enabled = true
	show_message(loc("AUTO砲は常時稼働中", "AUTO CANNON IS ALWAYS ONLINE"), 1.2)
	if play_sound:
		synth.play_tone(523.25, 0.1, -22.0, 3)
	return true

func handle_enemy_defeated() -> void:
	end_charge()
	gear_tree_open = false
	var defeated_id := str(run.current_boss_id)
	if encounter_lab_enabled:
		start_encounter_defeat_preview(defeated_id, true)
		return
	# PRIME form transitions retain their bespoke pacing. Every beast, abyssal
	# boss and ARCH kill now receives the authored short collapse first.
	if not run.final_boss:
		pending_campaign_defeat_resolution = true
		var duration := 3.8 if defeated_id not in StageCatalog.stage_ids() else 2.8
		start_encounter_defeat_preview(defeated_id, false, duration)
		return
	resolve_campaign_enemy_defeat()


func resolve_campaign_enemy_defeat() -> void:
	end_charge()
	gear_tree_open = false
	var defeated_stage_id: String = str(run.current_stage_id)
	if campaign_route.phase == CampaignRoute.RoutePhase.INFINITE:
		var completed_wave: int = int(campaign_route.infinite_wave)
		var reward: int = infinite_reward_for_wave(completed_wave)
		run.grant_charge(float(reward))
		campaign_route.complete_infinite_wave()
		show_message(loc("WAVE %d突破 — CHARGE +%s" % [completed_wave, format_number(reward)], "WAVE %d CLEARED — +%s CHARGE" % [completed_wave, format_number(reward)]), 3.0)
	elif campaign_route.phase == CampaignRoute.RoutePhase.STAGE:
		show_message(encounter_name() + loc("撃破 — 機械核を回収", " DEFEATED — CORE RECOVERED"), 3.0)
		var defeat_event_id := story_defeat_event_id(defeated_stage_id)
		if not defeat_event_id.is_empty():
			queue_story_event_once(defeat_event_id)
	else:
		complete_campaign_boss(true)
	screen_flash = 1.0
	screen_shake = 0.7
	save_progress()

func try_purchase(index: int, play_sound: bool = true) -> bool:
	if index < 0 or index >= ChargeState.UPGRADE_DEFINITIONS.size():
		return false
	var definition: Dictionary = ChargeState.UPGRADE_DEFINITIONS[index]
	return try_purchase_skill(str(definition.id), SHARD_SOCKET_CENTER, play_sound)

func try_purchase_skill(id: String, effect_position: Vector2 = SHARD_SOCKET_CENTER, play_sound: bool = true) -> bool:
	var definition: Dictionary = run.upgrade_definition(id)
	if definition.is_empty():
		return false
	if not run.purchase_upgrade(id):
		if run.upgrade_level(id) >= run.skill_max_rank(id):
			show_message(loc("この能力は最大ランクです", "THIS SKILL IS MAXED"), 1.2)
		elif not run.skill_unlocked(id):
			show_message(skill_lock_text(id), 1.8)
		else:
			var missing_charge := maxf(0.0, float(run.upgrade_cost(id)) - run.credits)
			show_message(loc("CHARGE不足 — あと%s必要" % format_number(missing_charge), "NOT ENOUGH CHARGE — NEED %s MORE" % format_number(missing_charge)), 1.8)
		if play_sound:
			synth.error()
		return false
	var copy := skill_copy(definition)
	show_message(loc("出力経路を強化：", "SYSTEM UPGRADED: ") + str(copy.title) + " LV.%d" % run.upgrade_level(id), 1.4)
	var color := gear_color(str(definition.gear))
	spawn_sparks(effect_position, color, 12, 125.0)
	spawn_resource_flow(SHARD_SOCKET_CENTER, effect_position, color, 5)
	shard_pulse = 0.75
	if play_sound:
		var tier := int(definition.get("tier", 1))
		var capstone: bool = int(definition.get("max_rank", 1)) == 1 and run.upgrade_level(id) >= run.skill_max_rank(id)
		if bool(definition.get("overlimit", false)):
			synth.overlimit_restore()
		else:
			synth.purchase(tier, capstone)
	save_progress()
	return true

func toggle_generation_mode() -> bool:
	if not run.toggle_manual_mode():
		show_message(loc("発電心臓の『零出力発電』でPURE COMMANDを解禁", "UNLOCK ZERO-OUTPUT DRIVE IN THE DYNAMO TREE"), 2.0)
		synth.error()
		return false
	show_message(loc("PURE COMMANDは恒久接続済み", "PURE COMMAND IS PERMANENTLY ONLINE"), 2.0)
	synth.play_chord([261.63, 392.0, 523.25], 0.18, -22.0)
	queue_redraw()
	return true

func skill_title_for_id(id: String) -> String:
	for index in range(ChargeState.UPGRADE_DEFINITIONS.size()):
		if str(ChargeState.UPGRADE_DEFINITIONS[index].id) == id:
			return str(upgrade_copy(index).title)
	return id.to_upper()

func show_full_ready() -> void:
	screen_flash = maxf(screen_flash, 0.3)
	show_message(loc("6セル同期完了 — 放電するか、さらに過充電するか", "SIX CELLS SYNCED — DISCHARGE OR RISK OVERCHARGE"), 2.4)
	spawn_sparks(Vector2(815, 245), Palette.AMBER, 20, 145.0)
	synth.play_chord([261.63, 392.0, 523.25], 0.24, -22.0)

func show_meltdown(lost: float) -> void:
	end_charge()
	if lost <= 0.01:
		screen_flash = 0.5
		show_message(loc("耐熱被膜がメルトダウンを遮断", "HEAT SHIELD PREVENTED MELTDOWN"), 2.0)
		add_floating(REACTOR_CENTER + Vector2(0, -100), loc("事故防止", "GUARDED"), Palette.MINT, 26)
		spawn_sparks(REACTOR_CENTER, Palette.MINT, 26, 180.0)
		synth.confirm()
		return
	screen_flash = 1.0
	screen_shake = 0.7
	discharge_wave = 0.7
	show_message(loc("メルトダウン！ 蓄積の大半を喪失", "MELTDOWN! MOST STORED CHARGE LOST"), 2.4)
	add_floating(REACTOR_CENTER + Vector2(0, -100), "-%s" % format_number(lost), Palette.CORAL, 28)
	spawn_sparks(REACTOR_CENTER, Palette.CORAL, 42, 290.0)
	synth.error()

func show_message(text: String, duration: float) -> void:
	message = text
	message_time = duration


func open_tutorial(force := false) -> bool:
	if campaign_route == null or (campaign_route.tutorial_completed and not force):
		return false
	tutorial_open = true
	tutorial_page = 0
	settings_open = false
	message_time = 0.0
	clear_comms()
	end_charge()
	synth.confirm()
	queue_redraw()
	return true


func close_tutorial() -> void:
	if not tutorial_open:
		return
	tutorial_open = false
	tutorial_page = 0
	campaign_route.tutorial_completed = true
	save_progress()
	synth.confirm()
	queue_redraw()


func advance_tutorial() -> void:
	if tutorial_page >= 2:
		close_tutorial()
		return
	tutorial_page += 1
	synth.click()
	queue_redraw()


func handle_tutorial_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if story_language_rect.has_point(event.position):
			toggle_language()
		elif tutorial_skip_rect.has_point(event.position):
			close_tutorial()
		elif tutorial_next_rect.has_point(event.position):
			advance_tutorial()
	elif event is InputEventScreenTouch and event.pressed:
		if story_language_rect.has_point(event.position):
			toggle_language()
		elif tutorial_skip_rect.has_point(event.position):
			close_tutorial()
		else:
			advance_tutorial()
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_L:
			toggle_language()
		elif event.keycode == KEY_ESCAPE:
			close_tutorial()
		elif event.keycode in [KEY_ENTER, KEY_SPACE, KEY_X, KEY_A]:
			advance_tutorial()
	elif event is InputEventJoypadButton and event.pressed:
		if event.button_index == controller_button("language"):
			toggle_language()
		elif event.button_index == controller_button("back"):
			close_tutorial()
		elif event.button_index == controller_button("primary"):
			advance_tutorial()


func tutorial_page_copy() -> Dictionary:
	var pages := [
		{
			"eyebrow_ja": "STEP 01 // 攻撃とCHARGE",
			"eyebrow_en": "STEP 01 // ATTACK & CHARGE",
			"title_ja": "押すたび、敵を削り、力を得る",
			"title_en": "EVERY COMMAND DEALS DAMAGE AND BUILDS POWER",
			"body_ja": "CHARGE ATTACKをクリックするか、SPACE / ENTER / Aを押すと1回攻撃します。\n攻撃するたびに強化資源CHARGEを獲得。AUTO砲は最初から常時稼働します。",
			"body_en": "CLICK CHARGE ATTACK OR PRESS SPACE / ENTER / A FOR ONE MANUAL HIT.\nEVERY COMMAND EARNS CHARGE. THE AUTO CANNON FIRES FROM THE START.",
			"accent": Palette.CYAN,
		},
		{
			"eyebrow_ja": "STEP 02 // 5つのギア",
			"eyebrow_en": "STEP 02 // FIVE GEAR TREES",
			"title_ja": "CHARGEを、次の一撃へ還元する",
			"title_en": "TURN CHARGE INTO A FASTER HUNT",
			"body_ja": "画面下のギアを開き、CHARGEで能力を購入します。\n手動、獲得量、AUTO、群制、機核。複数系統を組み合わせるほど加速します。",
			"body_en": "OPEN A GEAR AT THE BOTTOM AND SPEND CHARGE ON ITS SKILL TREE.\nMIX MANUAL, ECONOMY, AUTO, SWARM AND CORE SYSTEMS TO ACCELERATE.",
			"accent": Palette.VIOLET,
		},
		{
			"eyebrow_ja": "STEP 03 // 討伐経路",
			"eyebrow_en": "STEP 03 // HUNT ROUTE",
			"title_ja": "三体で帰還、六体で深層へ",
			"title_en": "THREE FOR AN ENDING. SIX FOR THE DEEPEST SIGNAL.",
			"body_ja": "六体から好きな三体を倒すと通常ボスへ進めます。そこで帰還しても構いません。\n残る三体とすべての深層ボスを倒せば、本当のラスボスへの道が開きます。",
			"body_en": "DEFEAT ANY THREE OF SIX BEASTS TO FACE A NORMAL BOSS AND REACH AN ENDING.\nHUNT ALL SIX AND EVERY DEEP BOSS TO OPEN THE PATH TO THE REAL FINAL ENEMY.",
			"accent": Palette.AMBER,
		},
	]
	return Dictionary(pages[clampi(tutorial_page, 0, pages.size() - 1)])


func story_lab_available() -> bool:
	return OS.is_debug_build()


func start_story_event(event_id: String, from_lab := false, from_log := false, after_action := "") -> bool:
	var definition := StoryCatalog.event(event_id)
	if definition.is_empty():
		return false
	if not from_lab and not from_log and not audio_settings.story_dialogue_enabled:
		# Narrative can be disabled without losing route progression or the
		# permanent archive. Gameplay warnings and the tutorial remain visible.
		campaign_route.mark_story_event_seen(event_id)
		achievements.archive_story_event(event_id)
		save_progress()
		if not after_action.is_empty():
			perform_story_after_action(after_action)
		return true
	story_event_id = event_id
	story_event_definition = definition
	story_event_line_index = 0
	story_event_from_lab = from_lab
	story_event_from_log = from_log
	story_event_from_encounter_lab = false
	story_event_after_action = after_action
	story_event_open = true
	story_lab_open = false
	story_log_open = false
	if not from_lab and not from_log:
		campaign_route.mark_story_event_seen(event_id)
		achievements.archive_story_event(event_id)
		save_progress()
	message_time = 0.0
	clear_comms()
	end_charge()
	queue_redraw()
	return true


func start_story_event_once(event_id: String, after_action := "") -> bool:
	if campaign_route.has_seen_story_event(event_id):
		return false
	return start_story_event(event_id, false, false, after_action)


func queue_story_event_once(event_id: String, after_action := "") -> bool:
	if campaign_route.has_seen_story_event(event_id):
		if not after_action.is_empty():
			perform_story_after_action(after_action)
		return false
	if story_event_id == event_id:
		return false
	for queued in story_event_queue:
		if str(queued.get("id", "")) == event_id:
			return false
	if story_event_open:
		story_event_queue.append({"id": event_id, "action": after_action})
		return true
	return start_story_event(event_id, false, false, after_action)


func current_story_line() -> Dictionary:
	var lines: Array = story_event_definition.get("lines", [])
	if story_event_line_index < 0 or story_event_line_index >= lines.size():
		return {}
	return Dictionary(lines[story_event_line_index])


func advance_story_event() -> void:
	if not story_event_open:
		return
	var lines: Array = story_event_definition.get("lines", [])
	if story_event_line_index + 1 < lines.size():
		story_event_line_index += 1
		synth.click()
		queue_redraw()
		return
	close_story_event(false)


func close_story_event(skipped := false) -> void:
	if not story_event_open:
		return
	var return_to_lab := story_event_from_lab and story_lab_available()
	var return_to_log := story_event_from_log
	var return_to_encounter_lab_screen := story_event_from_encounter_lab
	var after_action := story_event_after_action
	story_event_open = false
	story_event_id = ""
	story_event_definition.clear()
	story_event_line_index = 0
	story_event_from_lab = false
	story_event_from_log = false
	story_event_from_encounter_lab = false
	story_event_after_action = ""
	story_lab_open = return_to_lab
	story_log_open = return_to_log
	encounter_lab_open = return_to_encounter_lab_screen
	if skipped:
		synth.click()
	else:
		synth.confirm()
	if not return_to_lab and not return_to_log and not return_to_encounter_lab_screen:
		if not after_action.is_empty():
			perform_story_after_action(after_action)
		if not story_event_open and not story_event_queue.is_empty():
			var next_event: Dictionary = story_event_queue.pop_front()
			start_story_event_once(str(next_event.get("id", "")), str(next_event.get("action", "")))
	queue_redraw()


func perform_story_after_action(action: String) -> void:
	match action:
		"open_tutorial":
			open_tutorial()
		"world_credits":
			open_credits(true, "world")
		"launch_campaign_boss":
			launch_current_campaign_boss()
		"true_epilogue":
			open_true_epilogue()
		"start_final_defeat_cinematic":
			start_final_defeat_cinematic()


func story_encounter_event_id(encounter_id: String) -> String:
	if encounter_id in StageCatalog.stage_ids():
		return "hunt.%s.encounter" % encounter_id
	if encounter_id in StageCatalog.boss_ids():
		return "boss.%s.encounter" % encounter_id
	if encounter_id == str(StageCatalog.TRUE_BOSS.id):
		return "arch.encounter"
	var final_forms := {
		"prime_current_form_1": "prime.form_1",
		"prime_current_form_2": "prime.form_2",
		"prime_current_form_3": "prime.form_3",
	}
	return str(final_forms.get(encounter_id, ""))


func story_defeat_event_id(encounter_id: String) -> String:
	if encounter_id in StageCatalog.stage_ids():
		return "hunt.%s.defeat" % encounter_id
	if encounter_id in StageCatalog.boss_ids():
		return "boss.%s.defeat" % encounter_id
	if encounter_id == str(StageCatalog.TRUE_BOSS.id):
		return "arch.defeat"
	return "prime.defeat" if encounter_id == "prime_current_form_3" else ""


func check_singularity_story_phase() -> void:
	if not run.singularity_boss:
		story_singularity_phase = 1
		return
	if run.singularity_phase == story_singularity_phase:
		return
	story_singularity_phase = run.singularity_phase
	if story_singularity_phase == 2:
		queue_story_event_once("arch.phase_2")
	elif story_singularity_phase == 3:
		queue_story_event_once("arch.phase_3")


func encounter_lab_row_rect(index: int) -> Rect2:
	var column := index / 6
	var row := index % 6
	return Rect2(52 + column * 354, 144 + row * 76, 330, 62)


func return_to_encounter_lab() -> void:
	if not encounter_lab_enabled:
		return
	story_event_open = false
	story_event_definition.clear()
	story_event_queue.clear()
	story_event_from_lab = false
	story_event_from_log = false
	story_event_from_encounter_lab = false
	tutorial_open = false
	settings_open = false
	gear_tree_open = false
	defeat_preview_open = false
	final_defeat_cinematic_open = false
	epilogue_open = false
	title_screen_open = false
	encounter_lab_freeze_combat = false
	encounter_lab_open = true
	message_time = 0.0
	clear_comms()
	end_charge()
	bgm_key = ""
	refresh_music()
	synth.click()
	queue_redraw()


func handle_encounter_lab_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		for index in range(ENCOUNTER_LAB_IDS.size()):
			if encounter_lab_row_rect(index).has_point(event.position):
				encounter_lab_selected = index
				break
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if story_language_rect.has_point(event.position):
			toggle_language()
			return
		if encounter_lab_text_rect.has_point(event.position):
			encounter_lab_text_enabled = not encounter_lab_text_enabled
			encounter_lab_last_action = loc("会話表示を切り替えました（ラボ内のみ）", "DIALOGUE PREVIEW TOGGLED (LAB ONLY)")
			synth.click()
			queue_redraw()
			return
		if encounter_lab_close_rect.has_point(event.position):
			encounter_lab_open = false
			title_screen_open = true
			queue_redraw()
			return
		for index in range(ENCOUNTER_LAB_IDS.size()):
			if encounter_lab_row_rect(index).has_point(event.position):
				encounter_lab_selected = index
				synth.click()
				queue_redraw()
				return
		for index in range(encounter_lab_action_rects.size()):
			if encounter_lab_action_rects[index].has_point(event.position):
				activate_encounter_lab_action(index)
				return
	elif event is InputEventScreenTouch and event.pressed:
		var mouse_event := InputEventMouseButton.new()
		mouse_event.button_index = MOUSE_BUTTON_LEFT
		mouse_event.pressed = true
		mouse_event.position = event.position
		handle_encounter_lab_input(mouse_event)
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_L:
			toggle_language()
		elif event.keycode == KEY_T:
			encounter_lab_text_enabled = not encounter_lab_text_enabled
			synth.click()
		elif event.keycode == KEY_ESCAPE:
			encounter_lab_open = false
			title_screen_open = true
		elif event.keycode in [KEY_UP, KEY_W]:
			encounter_lab_selected = (encounter_lab_selected / 6) * 6 + wrapi(encounter_lab_selected % 6 - 1, 0, 6)
			synth.click()
		elif event.keycode in [KEY_DOWN, KEY_S]:
			encounter_lab_selected = (encounter_lab_selected / 6) * 6 + wrapi(encounter_lab_selected % 6 + 1, 0, 6)
			synth.click()
		elif event.keycode in [KEY_LEFT, KEY_A, KEY_RIGHT, KEY_D]:
			encounter_lab_selected = wrapi(encounter_lab_selected + 6, 0, 12)
			synth.click()
		elif event.keycode >= KEY_1 and event.keycode <= KEY_5:
			activate_encounter_lab_action(event.keycode - KEY_1)
		queue_redraw()


func activate_encounter_lab_action(index: int) -> void:
	match index:
		0:
			open_encounter_lab_story(false)
		1:
			configure_encounter_lab_battle(0.5)
		2:
			configure_encounter_lab_battle(0.01)
		3:
			start_encounter_defeat_preview(encounter_lab_selected_id(), true)
		4:
			open_encounter_lab_story(true)


func handle_defeat_preview_input(event: InputEvent) -> void:
	var skip := false
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		skip = epilogue_skip_rect.has_point(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		skip = epilogue_skip_rect.has_point(event.position)
	elif event is InputEventKey and event.pressed and not event.echo:
		skip = event.keycode in [KEY_ESCAPE, KEY_ENTER, KEY_SPACE]
	elif event is InputEventJoypadButton and event.pressed:
		skip = event.button_index in [controller_button("back"), controller_button("primary")]
	if skip and defeat_preview_time >= 0.5:
		finish_encounter_defeat_preview()


func handle_story_event_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if story_language_rect.has_point(event.position):
			toggle_language()
		elif story_skip_rect.has_point(event.position):
			close_story_event(true)
		else:
			advance_story_event()
	elif event is InputEventScreenTouch and event.pressed:
		if story_language_rect.has_point(event.position):
			toggle_language()
		elif story_skip_rect.has_point(event.position):
			close_story_event(true)
		else:
			advance_story_event()
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_L:
			toggle_language()
		elif event.keycode == KEY_ESCAPE:
			close_story_event(true)
		elif event.keycode in [KEY_ENTER, KEY_SPACE, KEY_X, KEY_A]:
			advance_story_event()
	elif event is InputEventJoypadButton and event.pressed:
		if event.button_index == controller_button("language"):
			toggle_language()
		elif event.button_index == controller_button("back"):
			close_story_event(true)
		elif event.button_index == controller_button("primary"):
			advance_story_event()


func toggle_story_lab() -> void:
	if not story_lab_available():
		return
	if story_event_open:
		story_event_from_lab = true
		close_story_event(true)
		story_lab_open = true
	else:
		story_lab_open = not story_lab_open
		if story_lab_open:
			message_time = 0.0
			clear_comms()
			end_charge()
	queue_redraw()


func story_lab_row_rect(slot: int) -> Rect2:
	return Rect2(52, 128 + slot * 68, 520, 58)


func ensure_story_lab_selection_visible() -> void:
	const VISIBLE_ROWS := 7
	if story_lab_selected < story_lab_scroll:
		story_lab_scroll = story_lab_selected
	elif story_lab_selected >= story_lab_scroll + VISIBLE_ROWS:
		story_lab_scroll = story_lab_selected - VISIBLE_ROWS + 1
	story_lab_scroll = clampi(story_lab_scroll, 0, maxi(0, StoryCatalog.event_ids().size() - VISIBLE_ROWS))


func handle_story_lab_input(event: InputEvent) -> void:
	var event_ids := StoryCatalog.event_ids()
	if event_ids.is_empty():
		story_lab_open = false
		return
	if event is InputEventMouseMotion:
		for slot in range(7):
			var index := story_lab_scroll + slot
			if index < event_ids.size() and story_lab_row_rect(slot).has_point(event.position):
				story_lab_selected = index
				break
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if story_language_rect.has_point(event.position):
			toggle_language()
			return
		if story_skip_rect.has_point(event.position):
			story_lab_open = false
			queue_redraw()
			return
		for slot in range(7):
			var index := story_lab_scroll + slot
			if index < event_ids.size() and story_lab_row_rect(slot).has_point(event.position):
				story_lab_selected = index
				start_story_event(event_ids[index], true)
				return
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_ESCAPE, KEY_F9]:
			story_lab_open = false
		elif event.keycode == KEY_L:
			toggle_language()
		elif event.keycode in [KEY_UP, KEY_W]:
			story_lab_selected = wrapi(story_lab_selected - 1, 0, event_ids.size())
			synth.click()
		elif event.keycode in [KEY_DOWN, KEY_S]:
			story_lab_selected = wrapi(story_lab_selected + 1, 0, event_ids.size())
			synth.click()
		elif event.keycode in [KEY_ENTER, KEY_SPACE]:
			start_story_event(event_ids[story_lab_selected], true)
	elif event is InputEventJoypadButton and event.pressed:
		if event.button_index == controller_button("back"):
			story_lab_open = false
		elif event.button_index in [JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_LEFT]:
			story_lab_selected = wrapi(story_lab_selected - 1, 0, event_ids.size())
			synth.click()
		elif event.button_index in [JOY_BUTTON_DPAD_DOWN, JOY_BUTTON_DPAD_RIGHT]:
			story_lab_selected = wrapi(story_lab_selected + 1, 0, event_ids.size())
			synth.click()
		elif event.button_index == controller_button("primary"):
			start_story_event(event_ids[story_lab_selected], true)
		elif event.button_index == controller_button("language"):
			toggle_language()
	ensure_story_lab_selection_visible()
	queue_redraw()


func open_story_log(from_title: bool) -> void:
	story_log_open = true
	story_log_return_to_title = from_title
	story_log_selected = clampi(story_log_selected, 0, maxi(0, StoryCatalog.event_ids().size() - 1))
	if not story_log_selected_unlocked():
		var ids := StoryCatalog.event_ids()
		for index in range(ids.size()):
			if achievements.has_story_event(ids[index]):
				story_log_selected = index
				break
	ensure_story_log_selection_visible()
	settings_open = false
	achievements_open = false
	message_time = 0.0
	clear_comms()
	end_charge()
	synth.confirm()
	queue_redraw()


func unlock_story_archive_for_preview() -> void:
	# Local QA helper only. It deliberately unlocks the permanent archive object
	# without marking campaign-route events as seen or writing a save bundle.
	for event_id in StoryCatalog.event_ids():
		achievements.archive_story_event(event_id)


func close_story_log() -> void:
	story_log_open = false
	story_log_return_to_title = false
	synth.click()
	queue_redraw()


func story_log_row_rect(slot: int) -> Rect2:
	return Rect2(48, 134 + slot * 66, 474, 56)


func ensure_story_log_selection_visible() -> void:
	const VISIBLE_ROWS := 7
	if story_log_selected < story_log_scroll:
		story_log_scroll = story_log_selected
	elif story_log_selected >= story_log_scroll + VISIBLE_ROWS:
		story_log_scroll = story_log_selected - VISIBLE_ROWS + 1
	story_log_scroll = clampi(story_log_scroll, 0, maxi(0, StoryCatalog.event_ids().size() - VISIBLE_ROWS))


func story_log_selected_unlocked() -> bool:
	var ids := StoryCatalog.event_ids()
	return not ids.is_empty() and achievements.has_story_event(ids[clampi(story_log_selected, 0, ids.size() - 1)])


func replay_story_log_selection() -> bool:
	var ids := StoryCatalog.event_ids()
	if ids.is_empty() or not story_log_selected_unlocked():
		synth.error()
		return false
	return start_story_event(ids[story_log_selected], false, true)


func handle_story_log_input(event: InputEvent) -> void:
	var ids := StoryCatalog.event_ids()
	if ids.is_empty():
		close_story_log()
		return
	if event is InputEventMouseMotion:
		for slot in range(7):
			var index := story_log_scroll + slot
			if index < ids.size() and story_log_row_rect(slot).has_point(event.position):
				story_log_selected = index
				break
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if story_language_rect.has_point(event.position):
			toggle_language()
			return
		if story_log_close_rect.has_point(event.position):
			close_story_log()
			return
		if story_log_replay_rect.has_point(event.position):
			replay_story_log_selection()
			return
		for slot in range(7):
			var index := story_log_scroll + slot
			if index < ids.size() and story_log_row_rect(slot).has_point(event.position):
				story_log_selected = index
				synth.click()
				break
	elif event is InputEventScreenTouch and event.pressed:
		if story_language_rect.has_point(event.position):
			toggle_language()
		elif story_log_close_rect.has_point(event.position):
			close_story_log()
		elif story_log_replay_rect.has_point(event.position):
			replay_story_log_selection()
		else:
			for slot in range(7):
				var index := story_log_scroll + slot
				if index < ids.size() and story_log_row_rect(slot).has_point(event.position):
					story_log_selected = index
					break
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_ESCAPE, KEY_J]:
			close_story_log()
		elif event.keycode == KEY_L:
			toggle_language()
		elif event.keycode in [KEY_UP, KEY_W]:
			story_log_selected = wrapi(story_log_selected - 1, 0, ids.size())
			synth.click()
		elif event.keycode in [KEY_DOWN, KEY_S]:
			story_log_selected = wrapi(story_log_selected + 1, 0, ids.size())
			synth.click()
		elif event.keycode in [KEY_ENTER, KEY_SPACE]:
			replay_story_log_selection()
	elif event is InputEventJoypadButton and event.pressed:
		if event.button_index == controller_button("back"):
			close_story_log()
		elif event.button_index in [JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_LEFT]:
			story_log_selected = wrapi(story_log_selected - 1, 0, ids.size())
			synth.click()
		elif event.button_index in [JOY_BUTTON_DPAD_DOWN, JOY_BUTTON_DPAD_RIGHT]:
			story_log_selected = wrapi(story_log_selected + 1, 0, ids.size())
			synth.click()
		elif event.button_index == controller_button("primary"):
			replay_story_log_selection()
		elif event.button_index == controller_button("language"):
			toggle_language()
	ensure_story_log_selection_visible()
	queue_redraw()


# Debug-facing conversation hook. It is intentionally data-only, so tests,
# editor scripts and the web query bridge can preview any localized line
# without changing encounter state or campaign saves.
func debug_show_dialogue(speaker_ja: String, speaker_en: String, text_ja: String, text_en: String, duration := 12.0, role := "support") -> void:
	clear_comms()
	message_time = 0.0
	queue_comms(speaker_ja, speaker_en, text_ja, text_en, clampf(duration, 1.0, 60.0), role if role in ["support", "player", "enemy"] else "support", true)
	queue_redraw()

func queue_comms(speaker_ja: String, speaker_en: String, text_ja: String, text_en: String, duration := 3.2, role := "auto", force := false) -> void:
	if not force and audio_settings != null and not audio_settings.story_dialogue_enabled:
		return
	comms_queue.append({
		"speaker_ja": speaker_ja,
		"speaker_en": speaker_en,
		"text_ja": text_ja,
		"text_en": text_en,
		"duration": duration,
		"role": role,
	})
	if comms_time <= 0.0:
		advance_comms()

func advance_comms() -> void:
	if comms_queue.is_empty():
		comms_speaker_ja = ""
		comms_speaker_en = ""
		comms_text_ja = ""
		comms_text_en = ""
		comms_time = 0.0
		comms_role = "auto"
		return
	var entry: Dictionary = comms_queue.pop_front()
	comms_speaker_ja = str(entry.get("speaker_ja", ""))
	comms_speaker_en = str(entry.get("speaker_en", ""))
	comms_text_ja = str(entry.get("text_ja", ""))
	comms_text_en = str(entry.get("text_en", ""))
	comms_time = float(entry.get("duration", 3.2))
	comms_role = str(entry.get("role", "auto"))

func update_comms(delta: float) -> void:
	if comms_time <= 0.0 or message_time > 0.0:
		return
	comms_time -= delta
	if comms_time <= 0.0:
		advance_comms()

func clear_comms() -> void:
	comms_queue.clear()
	comms_time = 0.0
	advance_comms()

func queue_encounter_intro(encounter_id: String) -> void:
	clear_comms()
	var support_ja := "支援演算 C6"
	var support_en := "C6 SUPPORT"
	match encounter_id:
		"gearmaw":
			queue_comms(support_ja, support_en, "装甲周期を捕捉。十二打目に亀裂が同期します。", "ARMOR CYCLE ACQUIRED. THE TWELFTH HIT WILL SYNCHRONIZE THE FRACTURE.")
			queue_comms("鉄殻穿獣 ギアモウ", "GEARMAW", "侵入個体を確認。圧砕し、坑道資材へ再利用する。", "INTRUDER CONFIRMED. CRUSH. RECYCLE AS TUNNEL STOCK.")
			queue_comms("ヴォルト・ノマド", "VOLT NOMAD", "なら十一回は予告だ。最後の一打だけ見ていろ。", "THEN ELEVEN HITS ARE THE WARNING. WATCH THE LAST ONE.")
		"vaultback":
			queue_comms(support_ja, support_en, "蓄電甲殻を確認。CHARGEを与えるほど開殻へ近づきます。", "CAPACITOR SHELL CONFIRMED. EVERY CHARGE EVENT FORCES IT CLOSER TO OPENING.")
			queue_comms("蒼雷装獣 ヴォルトバック", "VAULTBACK", "未登録電流を検出。甲殻内へ永久格納する。", "UNREGISTERED CURRENT DETECTED. PERMANENT CONTAINMENT BEGINS.")
			queue_comms("ヴォルト・ノマド", "VOLT NOMAD", "溜め込む癖まで同じか。返してもらう。", "IT HOARDS POWER JUST LIKE WE DO. I'LL TAKE IT BACK.")
		"pyre_wyrm":
			queue_comms(support_ja, support_en, "購入信号が炉心へ干渉。強化直後が最大出力です。", "PURCHASE SIGNALS INTERFERE WITH ITS FURNACE. OUTPUT PEAKS AFTER EVERY UPGRADE.")
			queue_comms("炉脈蛇 パイア・ワーム", "PYRE WYRM", "更新信号受領。炉温制限を破棄。獲物ごと焼却する。", "UPGRADE SIGNAL RECEIVED. THERMAL LIMIT DISCARDED. PREY WILL BURN WITH IT.")
			queue_comms("ヴォルト・ノマド", "VOLT NOMAD", "完成を待つな。組み替えながら狩る。", "DON'T WAIT FOR A PERFECT BUILD. WE HUNT WHILE EVOLVING.")
		"relay_hydra":
			queue_comms(support_ja, support_en, "三頭の継電順序を解析。手動とAUTOを交互接続してください。", "THREE RELAY HEADS DECODED. ALTERNATE MANUAL AND AUTO CONTACT.")
			queue_comms("継電三頭獣 リレイ・ヒドラ", "RELAY HYDRA", "第一頭、照準。第二頭、拘束。第三頭、停止を執行。", "HEAD ONE: ACQUIRE. HEAD TWO: BIND. HEAD THREE: EXECUTE CESSATION.")
			queue_comms("ヴォルト・ノマド", "VOLT NOMAD", "こちらの二つの心拍で、向こうの三つを乱す。", "OUR TWO HEARTBEATS WILL BREAK ITS THREE.")
		"swarm_matriarch":
			queue_comms(support_ja, support_en, "子機群が母機を遮蔽。手動標識をAUTOへ引き渡します。", "THE BROOD IS SCREENING ITS MATRIARCH. PASS MANUAL MARKS TO AUTO FIRE.")
			queue_comms("群制母機 スウォーム・マトリアーク", "SWARM MATRIARCH", "孤立個体へ告ぐ。群れを持たぬ機械に、生存権はない。", "LONE MACHINE: WITHOUT A SWARM, YOU POSSESS NO RIGHT TO SURVIVE.")
			queue_comms("ヴォルト・ノマド", "VOLT NOMAD", "一機ずつ数えるな。群れごと落とす。", "DON'T COUNT THEM ONE BY ONE. DROP THE WHOLE SWARM.")
		"phase_mantis":
			queue_comms(support_ja, support_en, "位相ずれを観測。失敗した打撃も解析値へ変換されます。", "PHASE DISPLACEMENT OBSERVED. EVEN FAILED CRITICALS BECOME ANALYSIS.")
			queue_comms("位相晶獣 フェイズ・マンティス", "PHASE MANTIS", "観測は遅い。刃はすでに、おまえが存在した座標を通過した。", "OBSERVATION LAGS. MY BLADE HAS CROSSED THE COORDINATE WHERE YOU EXISTED.")
			queue_comms("ヴォルト・ノマド", "VOLT NOMAD", "外したんじゃない。次を当てるために測った。", "THAT WASN'T A MISS. IT WAS MEASUREMENT FOR THE NEXT HIT.")
		"grid_leech":
			queue_comms(support_ja, support_en, "吸収核の開放は三・五秒。八入力で反転できます。", "THE SIPHON OPENS FOR 3.5 SECONDS. EIGHT INPUTS WILL REVERSE IT.")
			queue_comms("深淵吸核獣 グリッド・リーチ", "GRID LEECH", "電流は所有できない。強い吸収核へ流れ着くだけだ。", "CURRENT CANNOT BE OWNED. IT ONLY FLOWS TO THE STRONGER SIPHON.")
			queue_comms("ヴォルト・ノマド", "VOLT NOMAD", "喰う側と喰われる側を入れ替えよう。", "LET'S SWITCH WHICH ONE OF US IS FEEDING.")
		"thermal_titan":
			queue_comms(support_ja, support_en, "二十入力で炉心露出。熱源そのものを撃ち抜けます。", "TWENTY INPUTS EXPOSE THE FURNACE. THEN WE CAN STRIKE THE HEAT SOURCE ITSELF.")
			queue_comms("炉皇機獣 サーマル・タイタン", "THERMAL TITAN", "小さき炉よ。皇炉の火に戻り、燃料として完成せよ。", "LITTLE FURNACE. RETURN TO THE SOVEREIGN FLAME AND BE PERFECTED AS FUEL.")
			queue_comms("ヴォルト・ノマド", "VOLT NOMAD", "炉を壊すんじゃない。その火を次の核にする。", "WE'RE NOT EXTINGUISHING THAT FIRE. WE'RE MAKING IT OUR NEXT CORE.")
		"arch_singularity":
			queue_comms(support_ja, support_en, "全六核、共鳴開始。地核機神がこちらを認識しました。", "ALL SIX CORES ENTERING RESONANCE. THE WORLD ENGINE HAS RECOGNIZED US.", 3.8)
			queue_comms("アーク・シンギュラリティ", "ARCH SINGULARITY", "回収個体。おまえの進化は、私の欠損に過ぎない。", "RECOVERY UNIT. YOUR EVOLUTION IS MERELY MY MISSING COMPONENTS.", 4.0)
			queue_comms("ヴォルト・ノマド", "VOLT NOMAD", "なら返却する。弾速で受け取れ。", "THEN I'LL RETURN THEM. RECEIVE THEM AT MUZZLE VELOCITY.", 3.5)
		"prime_current_form_1":
			queue_comms("無冠機神 プライム・カレント", "PRIME CURRENT — CROWNLESS", "五つの法則違反を確認。六つ目の器として、おまえを接続する。", "FIVE VIOLATIONS CONFIRMED. YOU WILL BE CONNECTED AS THE SIXTH VESSEL.", 3.8)
			queue_comms("ヴォルト・ノマド", "VOLT NOMAD", "王冠のない王に、器を選ぶ権利はない。", "A KING WITHOUT A CROWN DOESN'T CHOOSE ITS VESSELS.", 3.4)
		"prime_current_form_2":
			queue_comms("零相聖堂 プライム・カレント", "PRIME CURRENT — NULL CATHEDRAL", "肉体を捨てた。ここでは距離も装甲も、私の祈りに従う。", "I HAVE DISCARDED THE BODY. HERE, DISTANCE AND ARMOR OBEY MY PRAYER.", 3.8)
			queue_comms(support_ja, support_en, "零相装甲を解析。臨界打撃か六連続指令で実在を固定します。", "NULL ARMOR DECODED. CRITICALS OR A SIX-COMMAND STREAK WILL FIX IT INTO REALITY.", 3.6)
		"prime_current_form_3":
			queue_comms("闇堕機天使 プライム・カレント", "PRIME CURRENT — FALLEN SERAPH", "最後の外殻を捨てる。光のない地底で、私だけが夜明けだった。", "I CAST OFF THE LAST SHELL. IN THIS LIGHTLESS WORLD, I ALONE WAS DAWN.", 4.0)
			queue_comms("ヴォルト・ノマド", "VOLT NOMAD", "夜明けは支配じゃない。誰にでも届くから、夜明けなんだ。", "DAWN ISN'T DOMINION. IT IS DAWN BECAUSE IT REACHES EVERYONE.", 3.8)

func toggle_language() -> void:
	is_japanese = not is_japanese
	language_changed.emit(is_japanese)
	show_message(loc("日本語に切り替えました", "SWITCHED TO ENGLISH"), 1.2)
	synth.click()
	queue_redraw()

func loc(japanese: String, english: String) -> String:
	return japanese if is_japanese else english

func stage_name(definition: Dictionary) -> String:
	return str(definition.get("name_ja" if is_japanese else "name_en", definition.get("id", "CIRCUIT")))

func current_stage_definition() -> Dictionary:
	return StageCatalog.stage(run.current_stage_id)

func current_enemy_texture() -> Texture2D:
	if MechanicalBeastTextures.has(run.current_boss_id):
		return MechanicalBeastTextures[run.current_boss_id]
	if MechanicalBeastTextures.has(run.current_stage_id):
		return MechanicalBeastTextures[run.current_stage_id]
	return grid_wraith_texture

func cell_center(index: int) -> Vector2:
	return Vector2(486 + index * 84, 242)

func encounter_name() -> String:
	var boss_definition := StageCatalog.boss(run.current_boss_id)
	if not boss_definition.is_empty():
		return str(boss_definition.get("name_ja" if is_japanese else "name_en", run.current_boss_id))
	var beast_definition := StageCatalog.stage(run.current_stage_id)
	if not beast_definition.is_empty():
		return stage_name(beast_definition)
	return loc("機械魔獣", "MECHANICAL BEAST")

func active_synergy_label(id: String) -> String:
	var labels := {
		"precision_loop": ["精密フィードバック", "PRECISION FEEDBACK"],
		"autonomous_cooling": ["自律冷却網", "AUTONOMOUS COOLING"],
		"burst_bank": ["大容量バースト", "BURST BANK"],
		"redline_armor": ["レッドライン装甲", "REDLINE ARMOR"],
	}
	var copy: Array = labels.get(id, [id, id.to_upper()])
	return str(copy[0] if is_japanese else copy[1])

func stage_circuit_label(id: String) -> String:
	for definition in StageCatalog.STAGES:
		if str(definition.core_id) == id:
			return str(definition.get("core_name_ja" if is_japanese else "core_name_en", id))
	for definition in StageCatalog.BOSSES:
		if str(definition.core_id) == id:
			return str(definition.get("core_name_ja" if is_japanese else "core_name_en", id))
	return id.to_upper()

func build_tag_label(id: String) -> String:
	var labels := {
		"manual": ["手動", "MANUAL"],
		"charge": ["発電", "CHARGE"],
		"upgrade": ["強化購入", "UPGRADES"],
		"chain": ["連鎖", "CHAIN"],
		"auto": ["AUTO", "AUTO"],
		"critical": ["臨界", "CRITICAL"],
	}
	var copy: Array = labels.get(id, [id.to_upper(), id.to_upper()])
	return str(copy[0] if is_japanese else copy[1])

func current_rule_copy() -> String:
	if run.final_boss:
		var definition := StageCatalog.boss(run.current_boss_id)
		return str(definition.get("rule_ja" if is_japanese else "rule_en", "OVERLIMIT CONVERGENCE"))
	if run.singularity_boss:
		if run.singularity_phase == 1:
			var source_ja := "クリック" if run.singularity_seal % 2 == 0 else "AUTO"
			var source_en := "MANUAL" if run.singularity_seal % 2 == 0 else "AUTO"
			return loc("六獣共鳴 %d/6：%s命中 %d/10" % [run.singularity_seal, source_ja, run.singularity_progress], "SIX-CORE RESONANCE %d/6: %s HITS %d/10" % [run.singularity_seal, source_en, run.singularity_progress])
		if run.singularity_phase == 2:
			var rules_ja := ["クリック優勢", "AUTO優勢", "臨界優勢", "連打優勢"]
			var rules_en := ["MANUAL BONUS", "AUTO BONUS", "CRITICAL BONUS", "COMBO BONUS"]
			return loc("攻撃系統転換：%s" % rules_ja[run.singularity_rule], "ATTACK DIRECTIVE: %s" % rules_en[run.singularity_rule])
		return loc("特異点共鳴 %d%% — 100%%で自動バースト" % int(run.enemy_charge), "SINGULARITY RESONANCE %d%% — AUTO BURST AT 100%%" % int(run.enemy_charge))
	if run.current_boss_id == "thermal_titan":
		return loc("20クリックで炉心露出 — 開放中は全攻撃2倍", "TWENTY CLICKS EXPOSE THE FURNACE — ALL DAMAGE ×2")
	if run.current_boss_id == "grid_leech":
		return loc("吸収核が開いたら3.5秒以内に8クリック", "WHEN THE SIPHON OPENS, LAND EIGHT CLICKS IN 3.5 SECONDS")
	var definition := current_stage_definition()
	if definition.is_empty():
		return loc("クリックで即攻撃し、得たCHARGEで武器を強化", "CLICK TO HIT; SPEND CHARGE TO UPGRADE YOUR ARSENAL")
	return str(definition.get("objective_ja" if is_japanese else "objective_en", ""))

func gear_at(point: Vector2) -> int:
	for index in range(gear_rects.size()):
		if gear_rects[index].has_point(point):
			return index
	return -1

func upgrade_color(index: int) -> Color:
	if index < 0 or index >= ChargeState.UPGRADE_DEFINITIONS.size():
		return Palette.CYAN
	return gear_color(str(ChargeState.UPGRADE_DEFINITIONS[index].gear))

func upgrade_copy(index: int) -> Dictionary:
	if index < 0 or index >= ChargeState.UPGRADE_DEFINITIONS.size():
		return {"title": "", "desc": ""}
	return skill_copy(ChargeState.UPGRADE_DEFINITIONS[index])

func skill_copy(definition: Dictionary) -> Dictionary:
	return {
		"title": str(definition.get("name_ja" if is_japanese else "name_en", definition.get("id", "SKILL"))),
		"desc": str(definition.get("desc_ja" if is_japanese else "desc_en", "")),
	}

func gear_name(definition: Dictionary) -> String:
	return str(definition.get("name_ja" if is_japanese else "name_en", definition.get("id", "GEAR")))

func gear_color(gear_id: String) -> Color:
	var definition := GearCatalog.gear(gear_id)
	return Color(str(definition.get("accent", "4deeea")))

func skill_lock_text(id: String) -> String:
	var reason: String = run.skill_lock_reason(id)
	if reason.begins_with("parent:"):
		var parts: PackedStringArray = reason.split(":")
		return loc("前提：%s をLV.%sへ", "REQUIRES %s LV.%s") % [skill_title_for_id(str(parts[1])), str(parts[2])]
	if reason.begins_with("core:"):
		return loc("未回収の機械核が必要：", "RECOVER REQUIRED CORE: ") + stage_circuit_label(reason.trim_prefix("core:"))
	if reason.begins_with("exclusive:"):
		return loc("別の変異を選択済み：", "OTHER MUTATION ALREADY CHOSEN: ") + skill_title_for_id(reason.trim_prefix("exclusive:"))
	if reason == "boss_core":
		return loc("通常ボスの機械核を回収すると解禁", "RECOVER A NORMAL BOSS CORE TO UNLOCK")
	if reason == "tier:2":
		return loc("通常ボス撃破後にTIER II解禁", "TIER II UNLOCKS AFTER THE NORMAL BOSS")
	if reason == "tier:3":
		return loc("六体の機械魔獣撃破後にTIER III解禁", "TIER III UNLOCKS AFTER ALL SIX BEASTS")
	if reason == "tier:4":
		return loc("地核機神アーク・シンギュラリティ撃破後に解禁", "TIER IV UNLOCKS AFTER ARCH SINGULARITY")
	if reason.begins_with("gear_max:"):
		return loc("このギアのTIER I〜IIIをすべて最大強化すると復旧可能", "MAX EVERY TIER I-III NODE IN THIS GEAR TO RESTORE IT")
	return loc("このノードはまだロックされています", "THIS NODE IS STILL LOCKED")

func add_floating(position: Vector2, text: String, color: Color, size: int) -> void:
	floating_texts.append({"pos": position, "text": text, "color": color, "size": size, "life": 1.25, "max_life": 1.25})

func spawn_sparks(position: Vector2, color: Color, count: int, speed: float) -> void:
	for index in range(count):
		var angle: float = run.rng.randf_range(0.0, TAU)
		var velocity: Vector2 = Vector2.from_angle(angle) * run.rng.randf_range(speed * 0.35, speed)
		particles.append({"pos": position, "velocity": velocity, "life": run.rng.randf_range(0.28, 0.75), "max_life": 0.75, "color": color, "size": run.rng.randf_range(2.0, 5.5)})

func spawn_resource_flow(start: Vector2, finish: Vector2, color: Color, count: int) -> void:
	for index in range(count):
		resource_packets.append({
			"start": start + Vector2(run.rng.randf_range(-12.0, 12.0), run.rng.randf_range(-8.0, 8.0)),
			"finish": finish + Vector2(run.rng.randf_range(-5.0, 5.0), run.rng.randf_range(-5.0, 5.0)),
			"progress": -float(index) * 0.09,
			"duration": run.rng.randf_range(0.48, 0.7),
			"arc": run.rng.randf_range(38.0, 82.0),
			"color": color,
			"size": run.rng.randf_range(2.5, 4.8),
		})

func update_effects(delta: float) -> void:
	for index in range(particles.size() - 1, -1, -1):
		var item: Dictionary = particles[index]
		item.pos = Vector2(item.pos) + Vector2(item.velocity) * delta
		item.velocity = Vector2(item.velocity) * pow(0.06, delta)
		item.life = float(item.life) - delta
		particles[index] = item
		if float(item.life) <= 0.0:
			particles.remove_at(index)
	for index in range(floating_texts.size() - 1, -1, -1):
		var item: Dictionary = floating_texts[index]
		item.pos = Vector2(item.pos) + Vector2(0, -34) * delta
		item.life = float(item.life) - delta
		floating_texts[index] = item
		if float(item.life) <= 0.0:
			floating_texts.remove_at(index)
	for index in range(resource_packets.size() - 1, -1, -1):
		var packet: Dictionary = resource_packets[index]
		packet.progress = float(packet.progress) + delta / maxf(0.01, float(packet.duration))
		resource_packets[index] = packet
		if float(packet.progress) >= 1.0:
			resource_packets.remove_at(index)

func format_number(value: float) -> String:
	if value >= 1000000000.0:
		return "%.2fB" % (value / 1000000000.0)
	if value >= 1000000.0:
		return "%.2fM" % (value / 1000000.0)
	if value >= 1000.0:
		return "%.1fK" % (value / 1000.0)
	return str(int(round(value)))

func format_integer(value: float) -> String:
	var digits := str(maxi(0, int(round(value))))
	var formatted := ""
	for index in range(digits.length()):
		if index > 0 and (digits.length() - index) % 3 == 0:
			formatted += ","
		formatted += digits[index]
	return formatted

func format_time(seconds: float) -> String:
	var total := int(seconds)
	return "%02d:%02d" % [total / 60, total % 60]

func tutorial_hint() -> String:
	var first_hunt: bool = campaign_route != null and campaign_route.completed_stage_ids.is_empty()
	if first_hunt and run.manual_inputs < 3:
		return loc("実戦ナビ 1/3　CHARGE ATTACKで攻撃＋発電　%d/3入力" % run.manual_inputs, "FIELD GUIDE 1/3  ATTACK + GENERATE WITH CHARGE  %d/3 INPUTS" % run.manual_inputs)
	if first_hunt and run.purchases == 0:
		var first_cost := cheapest_upgrade_cost()
		if run.credits < float(first_cost):
			return loc("実戦ナビ 2/3　最初の強化までCHARGE %s / %s" % [format_number(run.credits), format_number(first_cost)], "FIELD GUIDE 2/3  BUILD CHARGE FOR YOUR FIRST UPGRADE  %s / %s" % [format_number(run.credits), format_number(first_cost)])
		return loc("実戦ナビ 2/3　点灯したギアを開き、最初の能力を購入", "FIELD GUIDE 2/3  OPEN A GLOWING GEAR AND BUY YOUR FIRST NODE")
	if first_hunt and run.purchases < 2:
		return loc("実戦ナビ 3/3　強化接続完了 — 手動とAUTOを同時に育てる", "FIELD GUIDE 3/3  UPGRADE ONLINE — SCALE MANUAL AND AUTO TOGETHER")
	return current_rule_copy()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color("060b16"))
	draw_background()
	if defeat_preview_open:
		draw_encounter_defeat_preview()
		return
	if encounter_lab_open:
		draw_encounter_lab()
		return
	if tutorial_open:
		draw_tutorial_overlay()
		return
	if story_lab_open:
		draw_story_lab()
		return
	if story_log_open:
		draw_story_log()
		return
	if story_event_open and (story_event_from_lab or story_event_from_log or story_event_from_encounter_lab):
		draw_story_preview_stage()
		draw_story_event_overlay()
		return
	if final_defeat_cinematic_open:
		draw_final_defeat_cinematic()
		return
	if epilogue_open:
		draw_true_epilogue()
		return
	if artwork_open:
		draw_artwork_gallery()
		return
	if credits_open:
		draw_credits_roll()
		return
	if title_screen_open:
		draw_title_screen()
		if settings_open:
			draw_audio_settings_overlay()
		if achievements_open:
			draw_achievements_overlay()
		if comms_time > 0.0:
			draw_comms_box(Rect2(94, 548, 1092, 126), true)
		return
	var shake_offset := Vector2.ZERO
	if screen_shake > 0.0:
		shake_offset = Vector2(sin(animation_time * 73.0), cos(animation_time * 91.0)) * screen_shake * 9.0 * audio_settings.screen_shake_intensity
	draw_set_transform(shake_offset)
	draw_header()
	if encounter_lab_enabled and not encounter_lab_open:
		draw_campaign_button(encounter_lab_return_rect, "F8  DEV LAB", Palette.VIOLET, false)
	if campaign_screen_visible():
		draw_campaign_screen()
	else:
		draw_reactor_panel()
		draw_circuit_panel()
	if campaign_screen_visible() and comms_time > 0.0:
		draw_comms_box(Rect2(94, 548, 1092, 126), true)
	draw_particles_and_text()
	draw_set_transform(Vector2.ZERO)
	if gear_tree_open:
		draw_gear_tree_overlay()
	if not campaign_screen_visible() and run.stage_phase in [ChargeState.StagePhase.REWARD, ChargeState.StagePhase.CLEAR]:
		draw_completion_overlay()
	if screen_flash > 0.0:
		var flash_color := Palette.CORAL if run.meltdowns > 0 and run.heat <= 35.0 and message_time > 1.0 else Palette.CYAN
		draw_rect(Rect2(Vector2.ZERO, VIEW), Palette.with_alpha(flash_color, screen_flash * 0.18 * audio_settings.flash_intensity))
	if settings_open:
		draw_audio_settings_overlay()
	if achievements_open:
		draw_achievements_overlay()
	elif achievement_notice_time > 0.0 and not achievement_notice.is_empty():
		draw_achievement_toast()
	if story_event_open:
		draw_story_event_overlay()


func draw_encounter_lab() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.003, 0.008, 0.02, 0.96))
	draw_rect(Rect2(0, 0, 1280, 7), Palette.VIOLET)
	draw_string(DisplayFont, Vector2(48, 54), "DEV // ENCOUNTER LAB", HORIZONTAL_ALIGNMENT_LEFT, 720, 25, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(50, 82), loc("全敵・会話・撃破演出をセーブへ触れずに検証", "PREVIEW EVERY ENEMY, SCENE AND DEFEAT WITHOUT TOUCHING SAVES"), HORIZONTAL_ALIGNMENT_LEFT, 720, 12, Palette.MUTED)
	draw_campaign_button(story_language_rect, loc("日本語 / EN", "EN / 日本語"), Palette.CYAN, false)
	for index in range(ENCOUNTER_LAB_IDS.size()):
		var encounter_id := str(ENCOUNTER_LAB_IDS[index])
		var rect := encounter_lab_row_rect(index)
		var selected := index == encounter_lab_selected
		var definition := StageCatalog.stage(encounter_id)
		if definition.is_empty():
			definition = StageCatalog.boss(encounter_id)
		var accent := Color(str(definition.get("accent", "4deeea")))
		draw_machine_plate(rect, Palette.with_alpha(Palette.PANEL, 0.94), Palette.with_alpha(accent, 0.95 if selected else 0.28), 8.0, 3.0 if selected else 1.0)
		if MechanicalBeastTextures.has(encounter_id):
			draw_texture_rect(MechanicalBeastTextures[encounter_id], Rect2(rect.position + Vector2(8, 5), Vector2(52, 52)), false, Color.WHITE)
		draw_string(DisplayFont, rect.position + Vector2(68, 25), "%02d" % (index + 1), HORIZONTAL_ALIGNMENT_LEFT, 34, 11, accent)
		draw_string(Palette.UI_FONT, rect.position + Vector2(104, 27), encounter_lab_name(encounter_id), HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 112, 14, Palette.PAPER)
		draw_string(Palette.UI_FONT, rect.position + Vector2(68, 48), encounter_id.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 76, 9, Palette.with_alpha(accent, 0.74))
	var selected_id := encounter_lab_selected_id()
	var selected_definition := StageCatalog.stage(selected_id)
	if selected_definition.is_empty():
		selected_definition = StageCatalog.boss(selected_id)
	var selected_accent := Color(str(selected_definition.get("accent", "4deeea")))
	var panel := Rect2(788, 128, 412, 474)
	draw_machine_plate(panel, Palette.with_alpha(Palette.INK, 0.98), Palette.with_alpha(selected_accent, 0.66), 14.0, 2.0)
	draw_string(DisplayFont, Vector2(824, 166), encounter_lab_name(selected_id), HORIZONTAL_ALIGNMENT_LEFT, 352, 18, selected_accent)
	var action_labels := [
		loc("1  戦闘開始会話", "1  ENCOUNTER SCENE"),
		loc("2  戦闘画面・HP 50%", "2  COMBAT STATE · HP 50%"),
		loc("3  戦闘画面・HP 1%", "3  COMBAT STATE · HP 1%"),
		loc("4  撃破アニメーション", "4  DEFEAT ANIMATION"),
		loc("5  撃破後会話", "5  DEFEAT SCENE"),
	]
	for index in range(encounter_lab_action_rects.size()):
		draw_campaign_button(encounter_lab_action_rects[index], str(action_labels[index]), selected_accent if index == 3 else Palette.CYAN, false)
	var text_label := loc("T  会話表示：ON", "T  DIALOGUE: ON") if encounter_lab_text_enabled else loc("T  会話表示：OFF（即時スキップ）", "T  DIALOGUE: OFF · IMMEDIATE SKIP")
	draw_campaign_button(encounter_lab_text_rect, text_label, Palette.MINT if encounter_lab_text_enabled else Palette.CORAL, false)
	draw_campaign_button(encounter_lab_close_rect, loc("終了", "EXIT"), Palette.MUTED, false)
	draw_string(Palette.UI_FONT, Vector2(52, 642), encounter_lab_last_action, HORIZONTAL_ALIGNMENT_LEFT, 900, 12, Palette.AMBER)
	draw_string(Palette.UI_FONT, Vector2(52, 682), loc("上下・左右：敵選択　1〜5：状態表示　T：会話切替　F8：いつでもラボへ戻る", "ARROWS: ENEMY · 1–5: STATE · T: DIALOGUE · F8: RETURN ANY TIME"), HORIZONTAL_ALIGNMENT_LEFT, 1060, 11, Palette.MUTED)


func draw_encounter_defeat_preview() -> void:
	var encounter_id := defeat_preview_encounter_id
	var definition := StageCatalog.stage(encounter_id)
	if definition.is_empty():
		definition = StageCatalog.boss(encounter_id)
	var accent := Color(str(definition.get("accent", "4deeea")))
	var duration := defeat_preview_duration
	var progress := clampf(defeat_preview_time / duration, 0.0, 1.0)
	var effect_time := progress * 4.8
	var center := Vector2(640, 330)
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.001, 0.003, 0.012, 0.90))
	for index in range(26):
		var angle := float(index) * TAU / 26.0 + animation_time * (0.03 if index % 2 == 0 else -0.025)
		var radius := 110.0 + float(index % 7) * 34.0 + progress * 90.0
		draw_circle(center + Vector2.from_angle(angle) * radius, 1.0 + float(index % 3), Palette.with_alpha(accent, (1.0 - progress) * 0.38))
	var tremor_strength := 2.0 + clampf((effect_time - 0.6) / 2.0, 0.0, 1.0) * 12.0
	var tremor := Vector2(sin(effect_time * 47.0), cos(effect_time * 61.0)) * tremor_strength
	var enemy_alpha := clampf(1.0 - maxf(0.0, progress - 0.46) / 0.38, 0.0, 1.0)
	var fracture_progress := clampf(effect_time / 1.25, 0.0, 1.0)
	var fracture_alpha := minf(fracture_progress, clampf((2.45 - effect_time) / 0.55, 0.0, 1.0))
	var fracture_size := Vector2.ONE * lerpf(110.0, 206.0, fracture_progress)
	# PixelLab authored a complete core housing around the useful six-way crack.
	# Crop to its circular center and keep it translucent so the defeated beast
	# remains readable instead of being replaced by a square machine plate.
	draw_texture_rect_region(DefeatVFX.fracture, Rect2(center - fracture_size * 0.5, fracture_size), Rect2(48, 48, 160, 160), Color(1.0, 1.0, 1.0, fracture_alpha * 0.48))
	var halo_progress := clampf((effect_time - 1.15) / 1.65, 0.0, 1.0)
	var halo_alpha := sin(halo_progress * PI) * 0.86
	var halo_size := Vector2.ONE * lerpf(150.0, 500.0, halo_progress)
	draw_texture_rect(DefeatVFX.halo, Rect2(center - halo_size * 0.5, halo_size), false, Color(1.0, 1.0, 1.0, halo_alpha * 0.34))
	# The two intact mechanical plates sit behind the enemy. Native crack rays
	# carry their cyan/violet motif over the body without obscuring its silhouette.
	if MechanicalBeastTextures.has(encounter_id):
		var enemy_size := Vector2(318, 318) * (1.0 + progress * 0.07)
		draw_texture_rect(MechanicalBeastTextures[encounter_id], Rect2(center + tremor - enemy_size * 0.5, enemy_size), false, Color(1.0, 1.0, 1.0, enemy_alpha))
	for crack_index in range(6):
		var crack_angle := float(crack_index) * TAU / 6.0 + 0.12
		var crack_start := center + Vector2.from_angle(crack_angle) * (12.0 + fracture_progress * 9.0)
		var crack_end := center + Vector2.from_angle(crack_angle + sin(float(crack_index) * 2.3) * 0.05) * (34.0 + fracture_progress * 86.0)
		var crack_color := Palette.CYAN if crack_index % 2 == 0 else Palette.VIOLET
		draw_line(crack_start, crack_end, Palette.with_alpha(crack_color, fracture_alpha * enemy_alpha * 0.88), 2.0)
	var shard_progress := clampf((effect_time - 1.9) / 2.3, 0.0, 1.0)
	var shard_alpha := sin(shard_progress * PI) * 0.96
	var shard_size := Vector2.ONE * lerpf(170.0, 460.0, shard_progress)
	draw_texture_rect(DefeatVFX.shards, Rect2(center - shard_size * 0.5, shard_size), false, Color(1.0, 1.0, 1.0, shard_alpha))
	var whiteout := maxf(0.0, 1.0 - absf(effect_time - 2.05) / 0.24)
	if whiteout > 0.0:
		draw_rect(Rect2(Vector2.ZERO, VIEW), Palette.with_alpha(Palette.PAPER, whiteout * 0.58 * audio_settings.flash_intensity))
	draw_rect(Rect2(0, 0, 1280, 82), Color(0.002, 0.005, 0.016, 0.95))
	draw_string(DisplayFont, Vector2(44, 42), loc("機核崩壊 // ", "CORE COLLAPSE // ") + encounter_lab_name(encounter_id), HORIZONTAL_ALIGNMENT_LEFT, 920, 22, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(44, 66), loc("PixelLab三層VFX・Godot時間差合成", "PIXELLAB THREE-LAYER VFX · GODOT TIMING COMPOSITE"), HORIZONTAL_ALIGNMENT_LEFT, 760, 11, accent)
	draw_campaign_button(epilogue_skip_rect, loc("スキップ", "SKIP"), Palette.MUTED, false)


func draw_tutorial_overlay() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.004, 0.01, 0.025, 0.94))
	for ring in range(7):
		draw_arc(Vector2(1100, 350), 130.0 + ring * 45.0, -PI * 0.82, PI * 0.72, 64, Palette.with_alpha(Palette.CYAN if ring % 2 == 0 else Palette.VIOLET, 0.10), 2.0)
	var page := tutorial_page_copy()
	var accent: Color = Color(page.accent)
	draw_rect(Rect2(0, 0, 1280, 7), accent)
	draw_string(DisplayFont, Vector2(82, 76), "VOLT NOMAD // FIELD MANUAL", HORIZONTAL_ALIGNMENT_LEFT, 720, 20, Palette.MUTED)
	draw_campaign_button(story_language_rect, loc("日本語 / EN", "EN / 日本語"), Palette.CYAN, false)
	var panel := Rect2(76, 112, 1128, 438)
	draw_machine_plate(panel, Palette.with_alpha(Palette.INK, 0.97), Palette.with_alpha(accent, 0.78), 20.0, 2.0)
	draw_string(DisplayFont, Vector2(118, 166), str(page.get("eyebrow_ja" if is_japanese else "eyebrow_en", "")), HORIZONTAL_ALIGNMENT_LEFT, 850, 15, accent)
	draw_string(DisplayFont, Vector2(118, 224), str(page.get("title_ja" if is_japanese else "title_en", "")), HORIZONTAL_ALIGNMENT_LEFT, 1000, 27, Palette.PAPER)
	draw_multiline_string(Palette.UI_FONT, Vector2(120, 286), str(page.get("body_ja" if is_japanese else "body_en", "")), HORIZONTAL_ALIGNMENT_LEFT, 900, 18, 5, Palette.PAPER)
	var visual_y := 426.0
	for index in range(3):
		var node := Rect2(148 + index * 330, visual_y, 260, 72)
		var active := index == tutorial_page
		draw_machine_plate(node, Palette.with_alpha(Palette.PANEL, 0.9), Palette.with_alpha(accent if active else Palette.MUTED, 0.85 if active else 0.22), 9.0, 2.0 if active else 1.0)
		draw_string(DisplayFont, node.position + Vector2(0, 29), "%02d" % (index + 1), HORIZONTAL_ALIGNMENT_CENTER, node.size.x, 13, accent if active else Palette.MUTED)
		draw_string(Palette.UI_FONT, node.position + Vector2(0, 54), [loc("攻撃", "ATTACK"), loc("強化", "UPGRADE"), loc("経路", "ROUTE")][index], HORIZONTAL_ALIGNMENT_CENTER, node.size.x, 11, Palette.PAPER if active else Palette.MUTED)
	draw_campaign_button(tutorial_skip_rect, loc("ESC　閉じる", "ESC  CLOSE"), Palette.MUTED, false)
	draw_campaign_button(tutorial_next_rect, loc("決定　開始する", "CONFIRM  START HUNT") if tutorial_page >= 2 else loc("決定　次へ", "CONFIRM  NEXT"), Palette.MINT, true)


func draw_story_lab() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.008, 0.016, 0.038, 0.97))
	for index in range(9):
		var radius := 110.0 + index * 42.0
		draw_arc(Vector2(1010, 356), radius, -PI * 0.76 + animation_time * 0.03, PI * 0.72 + animation_time * 0.03, 64, Palette.with_alpha(Palette.VIOLET if index % 2 else Palette.CYAN, 0.12), 2.0)
	draw_rect(Rect2(0, 0, 1280, 6), Palette.VIOLET)
	draw_string(DisplayFont, Vector2(48, 52), "DEV // STORY LAB", HORIZONTAL_ALIGNMENT_LEFT, 600, 24, Palette.VIOLET)
	draw_string(Palette.UI_FONT, Vector2(50, 84), loc("イベントを直接再生・セーブ非更新", "DIRECT EVENT PLAYBACK · SAVE DATA IS NEVER MUTATED"), HORIZONTAL_ALIGNMENT_LEFT, 740, 14, Palette.MUTED)
	draw_campaign_button(story_language_rect, loc("日本語 / EN", "EN / 日本語"), Palette.CYAN, false)
	draw_campaign_button(story_skip_rect, loc("閉じる  F9", "CLOSE  F9"), Palette.MUTED, false)
	var event_ids := StoryCatalog.event_ids()
	if event_ids.is_empty():
		draw_string(Palette.UI_FONT, Vector2(54, 150), "NO STORY EVENTS", HORIZONTAL_ALIGNMENT_LEFT, 500, 18, Palette.CORAL)
		return
	story_lab_selected = clampi(story_lab_selected, 0, event_ids.size() - 1)
	ensure_story_lab_selection_visible()
	for slot in range(7):
		var index := story_lab_scroll + slot
		if index >= event_ids.size():
			break
		var definition := StoryCatalog.event(event_ids[index])
		var rect := story_lab_row_rect(slot)
		var selected := index == story_lab_selected
		var accent := Palette.VIOLET if selected else Palette.CYAN
		draw_machine_plate(rect, Palette.with_alpha(Palette.PANEL, 0.96), Palette.with_alpha(accent, 0.82 if selected else 0.26), 7.0, 2.0 if selected else 1.0)
		draw_string(DisplayFont, rect.position + Vector2(18, 25), str(definition.get("title_ja" if is_japanese else "title_en", event_ids[index])), HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 36, 14, Palette.PAPER if selected else Palette.MUTED)
		draw_string(DisplayFont, rect.position + Vector2(18, 49), event_ids[index], HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 36, 10, accent)
	var selected_definition := StoryCatalog.event(event_ids[story_lab_selected])
	var preview_rect := Rect2(602, 128, 626, 396)
	draw_machine_plate(preview_rect, Palette.with_alpha(Palette.INK, 0.97), Palette.with_alpha(Palette.VIOLET, 0.54), 12.0, 2.0)
	draw_string(DisplayFont, preview_rect.position + Vector2(28, 44), str(selected_definition.get("title_ja" if is_japanese else "title_en", "STORY EVENT")), HORIZONTAL_ALIGNMENT_LEFT, preview_rect.size.x - 56, 20, Palette.PAPER)
	draw_multiline_string(Palette.UI_FONT, preview_rect.position + Vector2(28, 88), str(selected_definition.get("context_ja" if is_japanese else "context_en", "")), HORIZONTAL_ALIGNMENT_LEFT, preview_rect.size.x - 56, 16, 4, Palette.MUTED)
	var selected_lines: Array = selected_definition.get("lines", [])
	draw_string(DisplayFont, preview_rect.position + Vector2(28, 190), loc("会話 %d行" % selected_lines.size(), "%d DIALOGUE LINES" % selected_lines.size()), HORIZONTAL_ALIGNMENT_LEFT, preview_rect.size.x - 56, 13, Palette.CYAN)
	if not selected_lines.is_empty():
		var first_line: Dictionary = selected_lines[0]
		draw_string(DisplayFont, preview_rect.position + Vector2(28, 232), str(first_line.get("speaker_ja" if is_japanese else "speaker_en", "")), HORIZONTAL_ALIGNMENT_LEFT, preview_rect.size.x - 56, 13, Palette.AMBER)
		draw_multiline_string(Palette.UI_FONT, preview_rect.position + Vector2(28, 270), str(first_line.get("text_ja" if is_japanese else "text_en", "")), HORIZONTAL_ALIGNMENT_LEFT, preview_rect.size.x - 56, 15, 4, Palette.PAPER)
	draw_string(DisplayFont, Vector2(604, 560), loc("ENTER / クリック：再生    ↑↓：選択    L：言語", "ENTER / CLICK: PLAY    ↑↓: SELECT    L: LANGUAGE"), HORIZONTAL_ALIGNMENT_LEFT, 620, 12, Palette.MINT)


func draw_story_log() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.006, 0.014, 0.032, 0.985))
	for index in range(8):
		var radius := 120.0 + index * 43.0
		draw_arc(Vector2(1110, 360), radius, -PI * 0.86 + animation_time * 0.025, PI * 0.64 + animation_time * 0.025, 64, Palette.with_alpha(Palette.CYAN if index % 2 == 0 else Palette.VIOLET, 0.09), 2.0)
	draw_rect(Rect2(0, 0, 1280, 6), Palette.CYAN)
	draw_string(DisplayFont, Vector2(48, 52), loc("会話記録 // 回収メモリ", "STORY LOG // RECOVERED MEMORY"), HORIZONTAL_ALIGNMENT_LEFT, 700, 24, Palette.CYAN)
	var total := StoryCatalog.event_ids().size()
	var recovered: int = achievements.story_archive_ids.size()
	draw_string(Palette.UI_FONT, Vector2(50, 84), loc("回収済み %d / %d　選択した会話は何度でも再生できます" % [recovered, total], "RECOVERED %d / %d · UNLOCKED SCENES MAY BE REPLAYED" % [recovered, total]), HORIZONTAL_ALIGNMENT_LEFT, 760, 14, Palette.MUTED)
	if story_archive_preview_all:
		draw_string(DisplayFont, Vector2(50, 110), loc("開発検証：全メモリ開放中 // セーブ無効", "LOCAL QA: ALL MEMORIES UNLOCKED // SAVE DISABLED"), HORIZONTAL_ALIGNMENT_LEFT, 760, 11, Palette.AMBER)
	draw_campaign_button(story_language_rect, loc("日本語 / EN", "EN / 日本語"), Palette.CYAN, false)
	draw_campaign_button(story_log_close_rect, loc("閉じる  J", "CLOSE  J"), Palette.MUTED, false)
	var ids := StoryCatalog.event_ids()
	if ids.is_empty():
		return
	ensure_story_log_selection_visible()
	for slot in range(7):
		var index := story_log_scroll + slot
		if index >= ids.size():
			break
		var event_id := ids[index]
		var definition := StoryCatalog.event(event_id)
		var unlocked: bool = achievements.has_story_event(event_id)
		var selected := index == story_log_selected
		var rect := story_log_row_rect(slot)
		var accent := Palette.CYAN if unlocked else Palette.MUTED
		draw_machine_plate(rect, Palette.with_alpha(Palette.PANEL, 0.96), Palette.with_alpha(accent, 0.8 if selected else 0.24), 7.0, 2.0 if selected else 1.0)
		draw_string(DisplayFont, rect.position + Vector2(16, 23), "%02d" % (index + 1), HORIZONTAL_ALIGNMENT_LEFT, 38, 11, accent)
		var title := str(definition.get("title_ja" if is_japanese else "title_en", event_id)) if unlocked else loc("未回収記録", "UNRECOVERED LOG")
		draw_string(DisplayFont, rect.position + Vector2(58, 24), title, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 74, 13, Palette.PAPER if unlocked and selected else Palette.MUTED)
		var chapter := str(definition.get("chapter", "story")).to_upper() if unlocked else "LOCKED"
		draw_string(Palette.UI_FONT, rect.position + Vector2(58, 44), chapter, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 74, 9, accent)
	var selected_id := ids[clampi(story_log_selected, 0, ids.size() - 1)]
	var selected_definition := StoryCatalog.event(selected_id)
	var selected_unlocked: bool = achievements.has_story_event(selected_id)
	var panel := Rect2(552, 134, 676, 432)
	draw_machine_plate(panel, Palette.with_alpha(Palette.INK, 0.98), Palette.with_alpha(Palette.VIOLET if selected_unlocked else Palette.MUTED, 0.54), 14.0, 2.0)
	if not selected_unlocked:
		draw_string(DisplayFont, panel.position + Vector2(0, 176), loc("記録はまだ回収されていない", "THIS MEMORY HAS NOT BEEN RECOVERED"), HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, 19, Palette.MUTED)
		draw_string(Palette.UI_FONT, panel.position + Vector2(70, 220), loc("本編で該当イベントを見ると、ここから再生できます。", "ENCOUNTER THIS EVENT IN THE CAMPAIGN TO REPLAY IT HERE."), HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 140, 13, Palette.MUTED)
	else:
		draw_string(DisplayFont, panel.position + Vector2(30, 44), str(selected_definition.get("title_ja" if is_japanese else "title_en", selected_id)), HORIZONTAL_ALIGNMENT_LEFT, panel.size.x - 60, 20, Palette.PAPER)
		draw_multiline_string(Palette.UI_FONT, panel.position + Vector2(30, 82), str(selected_definition.get("context_ja" if is_japanese else "context_en", "")), HORIZONTAL_ALIGNMENT_LEFT, panel.size.x - 60, 14, 3, Palette.MUTED)
		var lines: Array = selected_definition.get("lines", [])
		var y := panel.position.y + 166.0
		for line_index in range(mini(4, lines.size())):
			var entry: Dictionary = lines[line_index]
			var role := str(entry.get("role", "support"))
			var accent := Palette.CORAL if role == "enemy" else Palette.AMBER if role == "player" else Palette.CYAN
			draw_string(DisplayFont, Vector2(panel.position.x + 30, y), str(entry.get("speaker_ja" if is_japanese else "speaker_en", "")), HORIZONTAL_ALIGNMENT_LEFT, 190, 12, accent)
			draw_multiline_string(Palette.UI_FONT, Vector2(panel.position.x + 224, y), str(entry.get("text_ja" if is_japanese else "text_en", "")), HORIZONTAL_ALIGNMENT_LEFT, panel.size.x - 254, 12, 2, Palette.PAPER)
			y += 61.0
	draw_campaign_button(story_log_replay_rect, loc("決定  会話を再生", "CONFIRM  REPLAY SCENE") if selected_unlocked else loc("本編で回収すると解禁", "LOCKED UNTIL RECOVERED"), Palette.MINT if selected_unlocked else Palette.MUTED, selected_unlocked)
	draw_string(Palette.UI_FONT, Vector2(48, 626), loc("↑↓：記録選択　ENTER：再生　L：言語　J / ESC：閉じる", "↑↓: SELECT · ENTER: REPLAY · L: LANGUAGE · J / ESC: CLOSE"), HORIZONTAL_ALIGNMENT_LEFT, 716, 12, Palette.MUTED)


func draw_story_preview_stage() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.005, 0.01, 0.025, 0.84))
	draw_string(DisplayFont, Vector2(44, 116), "VOLT NOMAD", HORIZONTAL_ALIGNMENT_LEFT, 360, 22, Palette.AMBER)
	draw_texture_rect(ProtagonistTexture, Rect2(62, 138, 300, 300), false, Color(0.92, 0.97, 1.0, 0.92))
	var portrait_id := ""
	for entry in story_event_definition.get("lines", []):
		if str(Dictionary(entry).get("portrait_id", "")) != "":
			portrait_id = str(Dictionary(entry).get("portrait_id", ""))
			break
	if MechanicalBeastTextures.has(portrait_id):
		draw_string(DisplayFont, Vector2(824, 116), portrait_id.to_upper(), HORIZONTAL_ALIGNMENT_CENTER, 340, 22, Palette.CORAL)
		draw_texture_rect(MechanicalBeastTextures[portrait_id], Rect2(850, 158, 290, 240), false, Color(0.98, 0.94, 1.0, 0.96))
	draw_line(Vector2(402, 304), Vector2(810, 304), Palette.with_alpha(Palette.VIOLET, 0.36), 2.0)
	draw_circle(Vector2(606, 304), 13.0 + sin(animation_time * 3.0) * 2.0, Palette.with_alpha(Palette.CYAN, 0.62))


func draw_story_event_overlay() -> void:
	var definition := story_event_definition
	var entry := current_story_line()
	if definition.is_empty() or entry.is_empty():
		return
	var role := str(entry.get("role", "support"))
	var accent := Palette.CORAL if role == "enemy" else Palette.AMBER if role == "player" else Palette.CYAN
	var title := str(definition.get("title_ja" if is_japanese else "title_en", "STORY EVENT"))
	var context := str(definition.get("context_ja" if is_japanese else "context_en", ""))
	var speaker := str(entry.get("speaker_ja" if is_japanese else "speaker_en", ""))
	var line := str(entry.get("text_ja" if is_japanese else "text_en", ""))
	var lines: Array = definition.get("lines", [])
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.002, 0.005, 0.014, 0.58))
	draw_rect(Rect2(0, 0, 1280, 116), Color(0.006, 0.014, 0.032, 0.985))
	draw_rect(Rect2(0, 0, 1280, 7), accent)
	draw_string(DisplayFont, Vector2(72, 48), title, HORIZONTAL_ALIGNMENT_LEFT, 730, 18, Palette.PAPER)
	draw_multiline_string(Palette.UI_FONT, Vector2(74, 80), context, HORIZONTAL_ALIGNMENT_LEFT, 730, 13, 2, Palette.MUTED)
	draw_campaign_button(story_language_rect, loc("日本語 / EN", "EN / 日本語"), Palette.CYAN, false)
	draw_campaign_button(story_skip_rect, loc("スキップ  ESC", "SKIP  ESC"), Palette.MUTED, false)
	var panel := Rect2(54, 414, 1172, 256)
	draw_machine_plate(panel, Palette.with_alpha(Palette.INK, 0.985), Palette.with_alpha(accent, 0.88), 12.0, 2.0)
	draw_rect(Rect2(panel.position + Vector2(10, 10), Vector2(7, panel.size.y - 20)), accent)
	var portrait_rect := Rect2(panel.position + Vector2(32, 40), Vector2(150, 150))
	if role == "player":
		draw_texture_rect(ProtagonistTexture, portrait_rect, false, Color(0.95, 0.98, 1.0, 1.0))
	elif role == "enemy":
		var portrait_id := str(entry.get("portrait_id", ""))
		var portrait: Texture2D = MechanicalBeastTextures.get(portrait_id, current_enemy_texture())
		draw_texture_rect(portrait, portrait_rect, false, Color(1.0, 0.96, 1.0, 1.0))
	else:
		draw_circle(portrait_rect.get_center(), 52.0, Palette.with_alpha(Palette.CYAN, 0.13))
		for ring in range(3):
			var radius := 26.0 + ring * 14.0
			draw_arc(portrait_rect.get_center(), radius, animation_time * (0.4 + ring * 0.17), animation_time * (0.4 + ring * 0.17) + PI * 1.45, 24, Palette.with_alpha(Palette.CYAN, 0.86 - ring * 0.2), 3.0)
		draw_string(DisplayFont, portrait_rect.position + Vector2(0, 84), "C6", HORIZONTAL_ALIGNMENT_CENTER, portrait_rect.size.x, 22, Palette.CYAN)
	var text_x := panel.position.x + 212.0
	draw_string(DisplayFont, Vector2(text_x, panel.position.y + 54), speaker, HORIZONTAL_ALIGNMENT_LEFT, 900, 18, accent)
	draw_string(DisplayFont, Vector2(panel.end.x - 160, panel.position.y + 54), "%02d / %02d" % [story_event_line_index + 1, lines.size()], HORIZONTAL_ALIGNMENT_RIGHT, 116, 12, Palette.MUTED)
	draw_line(Vector2(text_x, panel.position.y + 70), Vector2(panel.end.x - 34, panel.position.y + 70), Palette.with_alpha(accent, 0.34), 1.0)
	draw_multiline_string(Palette.UI_FONT, Vector2(text_x, panel.position.y + 112), line, HORIZONTAL_ALIGNMENT_LEFT, panel.size.x - 252.0, 18, 4, Palette.PAPER)
	draw_string(DisplayFont, Vector2(text_x, panel.end.y - 28), loc("クリック / ENTER / A：次へ", "CLICK / ENTER / A: NEXT"), HORIZONTAL_ALIGNMENT_RIGHT, panel.size.x - 252.0, 12, Palette.with_alpha(Palette.MINT, 0.94))

func draw_title_screen() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.01, 0.022, 0.05, 0.46))
	for index in range(7):
		var radius := 76.0 + index * 27.0
		var direction := -1.0 if index % 2 else 1.0
		draw_arc(Vector2(310, 366), radius, -PI * 0.7 + animation_time * 0.09 * direction, PI * 1.25 + animation_time * 0.09 * direction, 64, Palette.with_alpha(Palette.CYAN if index % 2 == 0 else Palette.VIOLET, 0.24 - index * 0.022), 3.0)
	draw_texture_rect(ProtagonistTexture, Rect2(88, 166, 444, 444), false, Color(0.98, 1.0, 1.0, 1.0))
	draw_rect(Rect2(0, 0, 1280, 6), Palette.AMBER)
	draw_string(DisplayFont, Vector2(702, 104), "VOLT", HORIZONTAL_ALIGNMENT_LEFT, 470, 24, Palette.CYAN)
	draw_string(DisplayFont, Vector2(696, 184), "NOMAD", HORIZONTAL_ALIGNMENT_LEFT, 520, 66, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(704, 223), loc("地底機獣討伐アクティブクリッカー", "ABYSSAL MACHINE-HUNT ACTIVE CLICKER"), HORIZONTAL_ALIGNMENT_LEFT, 470, 15, Palette.MUTED)
	draw_line(Vector2(704, 252), Vector2(1136, 252), Palette.with_alpha(Palette.CYAN, 0.46), 2.0)
	draw_string(Palette.UI_FONT, Vector2(704, 280), loc("充電は弾丸。機械核は進化。地核機神を停止せよ。", "CHARGE IS AMMUNITION. CORES ARE EVOLUTION. STOP THE WORLD ENGINE."), HORIZONTAL_ALIGNMENT_LEFT, 470, 12, Palette.AMBER)
	var labels := [
		loc("討伐を続ける", "CONTINUE HUNT") if title_has_saved_campaign else loc("討伐を始める", "BEGIN HUNT"),
		loc("新しい討伐", "NEW HUNT") if title_new_confirm_time <= 0.0 else loc("もう一度押して初期化", "CONFIRM NEW HUNT"),
		loc("設定", "SETTINGS"),
		loc("実績", "RECORDS"),
		loc("制作記録", "CREDITS"),
		loc("会話", "LOG"),
		loc("アートワーク", "ARTWORK"),
	]
	for index in range(title_button_count()):
		draw_title_button(index, str(labels[index]))
	if title_has_saved_campaign:
		draw_string(Palette.UI_FONT, Vector2(726, 582), loc("保存記録", "SAVED HUNT"), HORIZONTAL_ALIGNMENT_LEFT, 150, 10, Palette.MUTED)
		draw_string(DisplayFont, Vector2(820, 584), "%s  ·  %d/6 CORES  ·  LV %d/%d" % [format_time(run.session_elapsed), run.beast_cores.size(), run.skill_points_bought(), run.total_possible_ranks()], HORIZONTAL_ALIGNMENT_LEFT, 330, 12, Palette.MINT)
	draw_string(Palette.UI_FONT, Vector2(726, 624), loc("方向キー / 決定　L：言語　M：BGMミュート", "D-PAD / CONFIRM  ·  L: LANGUAGE  ·  M: MUTE BGM"), HORIZONTAL_ALIGNMENT_LEFT, 470, 11, Palette.MUTED)
	draw_small_button(language_rect, "日本語 / EN", Palette.MINT)
	draw_string(DisplayFont, Vector2(88, 654), "VOLT NOMAD // UNIT 06", HORIZONTAL_ALIGNMENT_LEFT, 420, 15, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(88, 681), loc("第六機核適合個体・深層へ降下待機中", "SIX-CORE COMPATIBLE UNIT · READY TO DESCEND"), HORIZONTAL_ALIGNMENT_LEFT, 460, 11, Palette.MUTED)

func draw_title_button(index: int, label: String) -> void:
	var rect := title_button_rects[index]
	var selected := title_selected == index
	var accent := Palette.AMBER if index <= 1 else Palette.CYAN if index == 2 else Palette.AMBER if index == 3 else Palette.VIOLET if index == 4 else Palette.MINT if index == 5 else Palette.PAPER
	draw_machine_plate(rect, Palette.with_alpha(accent, 0.7 if selected and index == 0 else 0.18 if selected else 0.055), Palette.with_alpha(accent, 1.0 if selected else 0.38), 10.0, 2.0 if selected else 1.0)
	draw_rect(Rect2(rect.position + Vector2(10, 9), Vector2(4, rect.size.y - 18)), Palette.with_alpha(accent, 0.92 if selected else 0.32))
	draw_string(DisplayFont, rect.position + Vector2(20 if rect.size.x < 110 else 30, 39 if rect.size.y >= 60 else 33), label, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - (36 if rect.size.x < 110 else 58), 18 if rect.size.y >= 60 else 12 if rect.size.x < 110 else 14, Palette.INK if selected and index == 0 else Palette.PAPER)
	if selected:
		draw_string(DisplayFont, rect.position + Vector2(rect.size.x - 42, 38 if rect.size.y >= 60 else 32), ">", HORIZONTAL_ALIGNMENT_CENTER, 24, 18, Palette.INK if index == 0 else accent)

func draw_artwork_gallery() -> void:
	if artwork_viewer_open:
		draw_artwork_viewer()
		return
	var selected_entry: Dictionary = ArtworkGallery[artwork_selected]
	var selected_accent: Color = selected_entry.accent
	draw_cinematic_illustration(selected_entry.texture, 0.24, 0.16, artwork_selected % 2 == 1)
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.002, 0.008, 0.022, 0.91))
	for index in range(12):
		var radius := 92.0 + float(index) * 38.0 + sin(animation_time * 0.3 + index) * 7.0
		draw_arc(Vector2(1130, 540), radius, -PI * 0.82, PI * 1.18, 72, Palette.with_alpha(selected_accent, 0.10 - float(index) * 0.006), 2.0)
	draw_rect(Rect2(0, 0, 1280, 6), Palette.MINT)
	draw_string(DisplayFont, Vector2(42, 58), loc("完全クリア記録", "TOTAL CLEAR RECORD"), HORIZONTAL_ALIGNMENT_LEFT, 500, 13, Palette.MINT)
	draw_string(DisplayFont, Vector2(42, 96), loc("アートワーク", "ARTWORK ARCHIVE"), HORIZONTAL_ALIGNMENT_LEFT, 720, 30, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(454, 94), loc("完全停止後に回収された%dの戦闘記憶" % ArtworkGallery.size(), "%d MEMORIES RECOVERED AFTER TOTAL HALT" % ArtworkGallery.size()), HORIZONTAL_ALIGNMENT_LEFT, 500, 12, Palette.MUTED)
	var page_start := artwork_page_start()
	var page_count := ceili(float(ArtworkGallery.size()) / float(ARTWORK_PAGE_SIZE))
	var page_number := floori(float(page_start) / float(ARTWORK_PAGE_SIZE)) + 1
	draw_string(Palette.UI_FONT, Vector2(910, 94), "PAGE %d / %d" % [page_number, page_count], HORIZONTAL_ALIGNMENT_RIGHT, 112, 11, selected_accent)
	draw_campaign_button(artwork_close_rect, loc("タイトルへ", "TITLE"), Palette.MUTED, false)
	var visible_count := mini(ARTWORK_PAGE_SIZE, ArtworkGallery.size() - page_start)
	for slot in range(visible_count):
		draw_artwork_card(page_start + slot, slot)
	var detail_rect := Rect2(42, 374, 1196, 270)
	draw_machine_plate(detail_rect, Color(0.018, 0.042, 0.088, 0.96), Palette.with_alpha(selected_accent, 0.74), 18.0, 2.0)
	draw_string(Palette.UI_FONT, Vector2(76, 414), "MEMORY // %02d / %02d" % [artwork_selected + 1, ArtworkGallery.size()], HORIZONTAL_ALIGNMENT_LEFT, 300, 11, selected_accent)
	draw_string(DisplayFont, Vector2(72, 462), str(selected_entry.get("title_ja" if is_japanese else "title_en")), HORIZONTAL_ALIGNMENT_LEFT, 560, 27, Palette.PAPER)
	draw_line(Vector2(72, 482), Vector2(620, 482), Palette.with_alpha(selected_accent, 0.46), 2.0)
	var description_lines := wrap_text_simple(str(selected_entry.get("desc_ja" if is_japanese else "desc_en")), 36 if is_japanese else 54)
	for line_index in range(description_lines.size()):
		draw_string(Palette.UI_FONT, Vector2(74, 524 + line_index * 28), str(description_lines[line_index]), HORIZONTAL_ALIGNMENT_LEFT, 548, 14, Palette.PAPER)
	draw_campaign_button(artwork_view_rect, loc("全画面で鑑賞", "FULLSCREEN VIEW"), selected_accent, true)
	draw_campaign_button(artwork_replay_rect, loc("真エンディングを再生", "REPLAY TRUE ENDING"), Palette.AMBER, false)
	draw_string(Palette.UI_FONT, Vector2(674, 636), loc("方向キー：選択　ENTER：鑑賞　R：真エンディング　ESC：戻る", "ARROWS: SELECT · ENTER: VIEW · R: TRUE ENDING · ESC: RETURN"), HORIZONTAL_ALIGNMENT_LEFT, 530, 11, Palette.MUTED)

func draw_artwork_card(index: int, slot: int) -> void:
	var entry: Dictionary = ArtworkGallery[index]
	var rect := artwork_card_rects[slot]
	var selected := artwork_selected == index
	var accent: Color = entry.accent
	draw_machine_plate(rect, Color(0.015, 0.032, 0.068, 0.98), Palette.with_alpha(accent, 0.96 if selected else 0.30), 12.0, 3.0 if selected else 1.0)
	var image_rect := Rect2(rect.position + Vector2(12, 12), Vector2(254, 143))
	draw_texture_rect(entry.texture, image_rect, false, Color.WHITE if selected else Color(0.72, 0.77, 0.83, 0.82))
	draw_rect(Rect2(image_rect.position, Vector2(image_rect.size.x, 4)), accent if selected else Palette.with_alpha(accent, 0.35))
	draw_string(Palette.UI_FONT, rect.position + Vector2(14, 178), "%02d" % (index + 1), HORIZONTAL_ALIGNMENT_LEFT, 28, 10, accent)
	draw_string(DisplayFont, rect.position + Vector2(46, 186), str(entry.get("title_ja" if is_japanese else "title_en")), HORIZONTAL_ALIGNMENT_LEFT, 214, 13, Palette.PAPER if selected else Palette.MUTED)
	if selected:
		draw_string(DisplayFont, rect.position + Vector2(238, 207), ">", HORIZONTAL_ALIGNMENT_CENTER, 24, 14, accent)

func draw_artwork_viewer() -> void:
	var entry: Dictionary = ArtworkGallery[artwork_selected]
	var accent: Color = entry.accent
	var texture: Texture2D = entry.texture
	var zoom_levels := [1.0, 1.35, 1.7]
	var zoom := float(zoom_levels[clampi(artwork_zoom_level, 0, zoom_levels.size() - 1)])
	var texture_size := texture.get_size()
	var source_size := texture_size / zoom
	var source_rect := Rect2((texture_size - source_size) * 0.5, source_size)
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color.BLACK)
	draw_texture_rect_region(texture, Rect2(Vector2.ZERO, VIEW), source_rect)
	if not artwork_ui_visible:
		return
	draw_rect(Rect2(0, 0, 1280, 92), Color(0.002, 0.006, 0.018, 0.88))
	draw_rect(Rect2(0, 608, 1280, 112), Color(0.002, 0.006, 0.018, 0.90))
	draw_campaign_button(artwork_full_back_rect, loc("一覧へ", "GALLERY"), Palette.MINT, false)
	draw_campaign_button(artwork_full_zoom_rect, "ZOOM  %.2f×" % zoom, accent, false)
	draw_campaign_button(artwork_full_ui_rect, loc("UIを隠す", "HIDE UI"), Palette.MUTED, false)
	draw_machine_plate(artwork_full_previous_rect, Color(0.004, 0.012, 0.03, 0.68), Palette.with_alpha(accent, 0.58), 12.0, 2.0)
	draw_machine_plate(artwork_full_next_rect, Color(0.004, 0.012, 0.03, 0.68), Palette.with_alpha(accent, 0.58), 12.0, 2.0)
	draw_string(DisplayFont, artwork_full_previous_rect.position + Vector2(10, 65), "<", HORIZONTAL_ALIGNMENT_CENTER, 50, 28, Palette.PAPER)
	draw_string(DisplayFont, artwork_full_next_rect.position + Vector2(10, 65), ">", HORIZONTAL_ALIGNMENT_CENTER, 50, 28, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(206, 54), "ARTWORK // %02d / %02d" % [artwork_selected + 1, ArtworkGallery.size()], HORIZONTAL_ALIGNMENT_LEFT, 360, 12, accent)
	draw_string(DisplayFont, Vector2(48, 650), str(entry.get("title_ja" if is_japanese else "title_en")), HORIZONTAL_ALIGNMENT_LEFT, 600, 24, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(48, 683), loc("左右：作品切替　上下 / Z：ズーム　H：UI表示　ESC：一覧", "LEFT/RIGHT: ART · UP/DOWN/Z: ZOOM · H: UI · ESC: GALLERY"), HORIZONTAL_ALIGNMENT_LEFT, 850, 11, Palette.MUTED)
	draw_string(Palette.UI_FONT, Vector2(996, 680), loc("クリックでUIを再表示", "CLICK TO RESTORE UI"), HORIZONTAL_ALIGNMENT_RIGHT, 236, 10, Palette.with_alpha(accent, 0.72))

func draw_credits_roll() -> void:
	if credits_context in ["final", "artwork_replay"]:
		var ending_cycle := [EndingIllustrations["silence"], EndingIllustrations["colossi"], EndingIllustrations["current"], EndingIllustrations["dawn"]]
		var cycle_seconds := 14.0
		var cycle_index := mini(ending_cycle.size() - 1, int(credits_scroll / cycle_seconds))
		var cycle_progress := clampf(fmod(credits_scroll, cycle_seconds) / cycle_seconds, 0.0, 1.0)
		draw_cinematic_illustration(ending_cycle[cycle_index], cycle_progress, 0.42, cycle_index % 2 == 1)
		draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.002, 0.006, 0.018, 0.79))
	else:
		draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.002, 0.006, 0.018, 0.92))
	for index in range(28):
		var point := Vector2(fmod(float(index * 211), 1280.0), fmod(float(index * 127) + animation_time * 8.0, 720.0))
		draw_circle(point, 1.0 + float(index % 3) * 0.4, Palette.with_alpha(Palette.CYAN, 0.16 + float(index % 4) * 0.04))
	draw_rect(Rect2(0, 0, 1280, 76), Color(0.004, 0.01, 0.025, 0.96))
	draw_string(DisplayFont, Vector2(48, 46), "VOLT NOMAD // CREDITS", HORIZONTAL_ALIGNMENT_LEFT, 600, 22, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(48, 67), loc("地核より回収された制作記録", "PRODUCTION RECORD RECOVERED FROM THE WORLD ENGINE"), HORIZONTAL_ALIGNMENT_LEFT, 650, 10, Palette.MUTED)
	var offset_y := 610.0 - credits_scroll * 31.0
	var sections := [
		["VOLT NOMAD", loc("機械核を継ぎ、地底の世界機関へ挑む", "INHERIT THE MACHINE CORES. DESCEND TO THE WORLD ENGINE."), Palette.AMBER, 28],
		[loc("ゲームデザイン・ディレクション", "GAME DESIGN & DIRECTION"), "TAKAHIRO SAEKI", Palette.CYAN, 15],
		[loc("開発・ゲームデザイン支援", "DEVELOPMENT & DESIGN SUPPORT"), "OPENAI CODEX", Palette.VIOLET, 15],
		[loc("ピクセルアート生成", "PIXEL ART GENERATION"), "PIXELLAB\nART DIRECTION & SELECTION — TAKAHIRO SAEKI", Palette.MINT, 15],
		[loc("シネマティックアート生成", "CINEMATIC ART GENERATION"), "OPENAI IMAGE GENERATION\nART DIRECTION & SELECTION — TAKAHIRO SAEKI", Palette.CYAN, 15],
		[loc("オリジナル音楽", "ORIGINAL MUSIC"), "NEON LAMENT / SUNO · 18 ORIGINAL TRACKS\nAWAKENING BELOW · SIX-CORE DESCENT\nARCH SINGULARITY · NOMAD VICTORY SIGNAL · CORE OF DAWN", Palette.AMBER, 15],
		[loc("ゲームエンジン", "GAME ENGINE"), "GODOT ENGINE", Palette.CYAN, 15],
		[loc("書体", "TYPEFACES"), "DOTGOTHIC16 · NOTO SANS JP\nSIL OPEN FONT LICENSE 1.1", Palette.MINT, 15],
		[loc("スペシャルサンクス", "SPECIAL THANKS"), loc("AI BROWSER GAME JAM 4のプレイヤーと審査員のみなさま", "THE PLAYERS AND JUDGES OF AI BROWSER GAME JAM 4"), Palette.VIOLET, 15],
		[loc("そして、深層へ降りたあなたへ", "AND TO YOU, WHO DESCENDED INTO THE DEPTHS"), "CHARGE COMPLETE", Palette.PAPER, 18],
	]
	var y := offset_y
	for section in sections:
		var heading := str(section[0])
		var body := str(section[1])
		var accent: Color = section[2]
		var body_size := int(section[3])
		draw_string(Palette.UI_FONT, Vector2(0, y), heading, HORIZONTAL_ALIGNMENT_CENTER, 1280, 11, Palette.with_alpha(accent, 0.78))
		y += 36.0
		for line in body.split("\n"):
			draw_string(DisplayFont, Vector2(0, y), str(line), HORIZONTAL_ALIGNMENT_CENTER, 1280, body_size, accent)
			y += float(body_size + 13)
		y += 62.0
	draw_rect(Rect2(0, 624, 1280, 96), Color(0.004, 0.01, 0.025, 0.94))
	draw_string(Palette.UI_FONT, Vector2(48, 675), loc("自動スクロール　上下キーで調整", "AUTO SCROLL · UP/DOWN TO ADJUST"), HORIZONTAL_ALIGNMENT_LEFT, 500, 11, Palette.MUTED)
	draw_campaign_button(credits_close_rect, loc("結果へ戻る", "RETURN"), Palette.MINT, false)

func draw_final_defeat_cinematic() -> void:
	var progress := clampf(final_defeat_cinematic_time / FINAL_DEFEAT_CINEMATIC_SECONDS, 0.0, 1.0)
	var collapse := clampf(final_defeat_cinematic_time / 6.2, 0.0, 1.0)
	var center := Vector2(640, 310)
	var tremor := Vector2(
		sin(final_defeat_cinematic_time * 41.0),
		cos(final_defeat_cinematic_time * 53.0)
	) * (2.0 + collapse * 10.0)
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.002, 0.003, 0.012, 0.88))
	for ring in range(9):
		var ring_progress := fmod(final_defeat_cinematic_time * (0.34 + float(ring) * 0.025) + float(ring) * 0.13, 1.0)
		var radius := 54.0 + ring_progress * (220.0 + float(ring) * 9.0)
		var ring_color := Palette.CYAN if ring % 3 == 0 else Palette.VIOLET if ring % 3 == 1 else Palette.CORAL
		draw_arc(center, radius, -PI + float(ring) * 0.31, PI * (0.35 + ring_progress), 44, Palette.with_alpha(ring_color, (1.0 - ring_progress) * (0.32 + collapse * 0.3)), 2.0 + collapse * 2.0)
	var texture: Texture2D = MechanicalBeastTextures["prime_current_form_3"]
	var body_alpha := clampf(1.0 - maxf(0.0, collapse - 0.48) / 0.52, 0.0, 1.0)
	var body_size := Vector2(330, 330) * (1.0 + collapse * 0.08)
	for ghost in range(3, 0, -1):
		var ghost_offset := Vector2(sin(final_defeat_cinematic_time * 17.0 + ghost), cos(final_defeat_cinematic_time * 19.0 + ghost)) * float(ghost) * (2.0 + collapse * 5.0)
		draw_texture_rect(texture, Rect2(center + tremor + ghost_offset - body_size * 0.5, body_size), false, Color(0.45, 0.55, 1.0, body_alpha * 0.10))
	draw_texture_rect(texture, Rect2(center + tremor - body_size * 0.5, body_size), false, Color(1.0, 1.0, 1.0, body_alpha))
	# PixelLab supplies three authored mechanical layers; Godot owns their timing,
	# scale and translucency so the boss remains readable until the final burst.
	var fracture_progress := clampf(final_defeat_cinematic_time / 2.8, 0.0, 1.0)
	var fracture_alpha := minf(fracture_progress, clampf((5.2 - final_defeat_cinematic_time) / 1.1, 0.0, 1.0))
	var fracture_size := Vector2.ONE * lerpf(120.0, 300.0, fracture_progress)
	draw_texture_rect_region(DefeatVFX.fracture, Rect2(center + tremor - fracture_size * 0.5, fracture_size), Rect2(48, 48, 160, 160), Color(1.0, 1.0, 1.0, fracture_alpha * 0.18))
	var voltage_progress := clampf((final_defeat_cinematic_time - 2.4) / 3.2, 0.0, 1.0)
	var voltage_alpha := sin(voltage_progress * PI) * 0.78
	var voltage_size := Vector2.ONE * lerpf(170.0, 580.0, voltage_progress)
	draw_texture_rect(DefeatVFX.halo, Rect2(center - voltage_size * 0.5, voltage_size), false, Color(1.0, 1.0, 1.0, voltage_alpha * 0.16))
	var authored_shard_progress := clampf((final_defeat_cinematic_time - 4.3) / 3.4, 0.0, 1.0)
	var authored_shard_alpha := sin(authored_shard_progress * PI) * 0.96
	var authored_shard_size := Vector2.ONE * lerpf(180.0, 620.0, authored_shard_progress)
	draw_texture_rect(DefeatVFX.shards, Rect2(center - authored_shard_size * 0.5, authored_shard_size), false, Color(1.0, 1.0, 1.0, authored_shard_alpha))
	var shard_count := 18 + final_defeat_burst_stage * 12
	for index in range(shard_count):
		var angle := float(index) * TAU / float(shard_count) + sin(float(index) * 2.17) * 0.22
		var travel := collapse * (78.0 + float(index % 11) * 17.0)
		var shard_origin := center + Vector2.from_angle(angle) * travel
		var shard_color := Palette.PAPER if index % 4 == 0 else Palette.CYAN if index % 2 == 0 else Palette.VIOLET
		draw_line(shard_origin, shard_origin + Vector2.from_angle(angle) * (7.0 + collapse * 18.0), Palette.with_alpha(shard_color, body_alpha * 0.88), 1.0 + float(index % 3))
	var burst_phase := fmod(final_defeat_cinematic_time, 1.15) / 1.15
	var burst_alpha := maxf(0.0, 1.0 - burst_phase * 4.0)
	draw_circle(center + tremor, 22.0 + burst_phase * 180.0, Palette.with_alpha(Palette.PAPER, burst_alpha * 0.48))
	draw_circle(center + tremor, 8.0 + burst_phase * 90.0, Palette.with_alpha(Palette.CYAN, burst_alpha * 0.7))
	draw_rect(Rect2(0, 0, 1280, 78), Color(0.002, 0.005, 0.016, 0.94))
	draw_string(DisplayFont, Vector2(44, 42), loc("原初電流・機核崩壊", "PRIME CURRENT // CORE COLLAPSE"), HORIZONTAL_ALIGNMENT_LEFT, 720, 24, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(44, 65), loc("最終形態の構造崩壊を確認 — 残留電流を記録中", "FINAL SHELL FAILURE CONFIRMED — RECORDING RESIDUAL CURRENT"), HORIZONTAL_ALIGNMENT_LEFT, 760, 11, Palette.CYAN)
	draw_campaign_button(epilogue_skip_rect, loc("スキップ", "SKIP"), Palette.MUTED, false)
	if comms_time > 0.0:
		draw_comms_box(Rect2(94, 548, 1092, 126), true)
	if progress > 0.82:
		draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.002, 0.004, 0.012, clampf((progress - 0.82) / 0.18, 0.0, 0.82)))

func draw_true_epilogue() -> void:
	var scenes := [
		{"title_ja":"地核の沈黙","title_en":"SILENCE BELOW","text_ja":"アーク・シンギュラリティが止まり、千年続いた機械の鼓動が途絶えた。","text_en":"ARCH SINGULARITY STOPPED. A MECHANICAL HEARTBEAT A THOUSAND YEARS OLD FELL SILENT.","illustration":EndingIllustrations["silence"],"accent":Palette.PAPER},
		{"title_ja":"第六適合個体","title_en":"UNIT SIX","text_ja":"帰還命令を受けたヴォルト・ノマドは、なお深部から届く微かな電流へ振り返る。","text_en":"ORDERED TO ASCEND, VOLT NOMAD TURNED TOWARD A CURRENT STILL WHISPERING FROM BELOW.","illustration":EndingIllustrations["silence"],"accent":Palette.CYAN},
		{"title_ja":"奪ったのではない","title_en":"NOT STOLEN","text_ja":"六体の魔獣核は武器ではなかった。地底世界が残した、六つの生存記録だった。","text_en":"THE SIX BEAST CORES WERE NOT WEAPONS. THEY WERE SIX SURVIVAL RECORDS LEFT BY THE WORLD BELOW.","illustration":EndingIllustrations["colossi"],"accent":Palette.VIOLET},
		{"title_ja":"主獣たちの記憶","title_en":"MEMORY OF COLOSSI","text_ja":"グリッド・リーチも、サーマル・タイタンも、原初電流から世界を守るため壊れ続けていた。","text_en":"GRID LEECH AND THERMAL TITAN HAD BEEN BREAKING THEMSELVES TO HOLD BACK THE FIRST CURRENT.","illustration":EndingIllustrations["colossi"],"accent":Palette.CORAL},
		{"title_ja":"無冠機神","title_en":"THE CROWNLESS ENGINE","text_ja":"王冠を持たぬ機神は支配者ではない。停止することを許されなかった、最初の動力炉だった。","text_en":"THE CROWNLESS ENGINE WAS NO RULER — ONLY THE FIRST REACTOR, NEVER PERMITTED TO STOP.","illustration":EndingIllustrations["current"],"accent":Palette.MINT},
		{"title_ja":"五つのOVERLIMIT","title_en":"FIVE OVERLIMITS","text_ja":"撃鉄、太陽炉、事象砲、主権群体、六核神化。選ばれた装備ではなく、すべてが一つの意志となった。","text_en":"STRIKER, SUN, HORIZON, SWARM, APOTHEOSIS — NOT EQUIPPED PARTS, BUT ONE CONVERGENT WILL.","illustration":EndingIllustrations["current"],"accent":Palette.AMBER},
		{"title_ja":"原初電流の終わり","title_en":"THE CURRENT REMEMBERS","text_ja":"最後の電流は消滅しなかった。機械と獣と狩人の記憶へ分かれ、地上へ昇っていった。","text_en":"THE LAST CURRENT DID NOT VANISH. IT BECAME THE MEMORIES OF MACHINE, BEAST, AND HUNTER — RISING.","illustration":EndingIllustrations["current"],"accent":Palette.PAPER},
		{"title_ja":"夜明けの機核","title_en":"CORE OF DAWN","text_ja":"任務完了。だが今度の沈黙は終わりではない。誰かが選び取った、休息だった。","text_en":"MISSION COMPLETE. THIS SILENCE WAS NOT AN END, BUT A REST SOMEONE FINALLY CHOSE.","illustration":EndingIllustrations["dawn"],"accent":Palette.CYAN},
	]
	var scene: Dictionary = scenes[clampi(epilogue_scene, 0, scenes.size() - 1)]
	var accent: Color = scene.accent
	var scene_duration := epilogue_scene_duration(epilogue_scene)
	var scene_progress := clampf(epilogue_scene_time / maxf(0.001, scene_duration), 0.0, 1.0)
	var fade_in := clampf(epilogue_scene_time / EPILOGUE_FADE_SECONDS, 0.0, 1.0)
	var fade_out := clampf((scene_duration - epilogue_scene_time) / EPILOGUE_FADE_SECONDS, 0.0, 1.0)
	var cinematic_alpha := minf(fade_in, fade_out)
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.002, 0.006, 0.017, 1.0))
	draw_cinematic_illustration(scene.illustration, scene_progress, cinematic_alpha, epilogue_scene % 2 == 1)
	for shade_index in range(10):
		var shade_x := 470.0 + float(shade_index) * 81.0
		draw_rect(Rect2(shade_x, 0, 82, 720), Color(0.002, 0.006, 0.017, 0.045 + float(shade_index) * 0.075))
	draw_rect(Rect2(0, 0, 1280, 62), Color(0.002, 0.006, 0.017, 0.74))
	draw_rect(Rect2(0, 650, 1280, 70), Color(0.002, 0.006, 0.017, 0.82))
	for index in range(9):
		var radius := 95.0 + float(index) * 34.0 + sin(animation_time * 0.35 + index) * 8.0 + scene_progress * 16.0
		draw_arc(Vector2(1080, 310), radius, -PI * 0.72, PI * 1.28, 72, Palette.with_alpha(accent, (0.10 - float(index) * 0.008) * cinematic_alpha), 2.0)
	draw_string(Palette.UI_FONT, Vector2(684, 128), "TRUE ENDING // %02d / %02d  ·  AUTO PLAY" % [epilogue_scene + 1, scenes.size()], HORIZONTAL_ALIGNMENT_LEFT, 490, 12, Palette.with_alpha(accent, cinematic_alpha))
	draw_string(DisplayFont, Vector2(678, 204), str(scene.get("title_ja" if is_japanese else "title_en")), HORIZONTAL_ALIGNMENT_LEFT, 500, 31, Palette.with_alpha(Palette.PAPER, cinematic_alpha))
	draw_line(Vector2(678, 232), Vector2(1172, 232), Palette.with_alpha(accent, 0.52 * cinematic_alpha), 2.0)
	var body := str(scene.get("text_ja" if is_japanese else "text_en"))
	var lines := wrap_text_simple(body, 26 if is_japanese else 42)
	for line_index in range(lines.size()):
		draw_string(Palette.UI_FONT, Vector2(678, 286 + line_index * 34), str(lines[line_index]), HORIZONTAL_ALIGNMENT_LEFT, 480, 15, Palette.with_alpha(Palette.PAPER, cinematic_alpha))
	draw_string(Palette.UI_FONT, Vector2(678, 574), loc("自動再生中　クリック / ENTER：次の場面", "AUTO PLAYING · CLICK / ENTER: NEXT SCENE"), HORIZONTAL_ALIGNMENT_LEFT, 330, 12, Palette.with_alpha(Palette.MUTED, cinematic_alpha))
	draw_campaign_button(epilogue_skip_rect, loc("スキップ", "SKIP"), Palette.MUTED, false)
	var progress_width := 494.0 / float(scenes.size())
	for index in range(scenes.size()):
		var segment_fill := 1.0 if index < epilogue_scene else scene_progress if index == epilogue_scene else 0.0
		draw_rect(Rect2(678 + index * progress_width, 620, progress_width - 6, 5), Palette.with_alpha(Palette.MUTED, 0.2))
		draw_rect(Rect2(678 + index * progress_width, 620, (progress_width - 6) * segment_fill, 5), accent)
	if cinematic_alpha < 1.0:
		draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.0, 0.0, 0.0, 1.0 - cinematic_alpha))

func draw_cinematic_illustration(texture: Texture2D, progress: float, alpha: float, reverse_pan: bool) -> void:
	var texture_size := texture.get_size()
	var zoom := 1.0 + progress * 0.055
	var source_size := texture_size / zoom
	var travel := texture_size - source_size
	var travel_progress := 1.0 - progress if reverse_pan else progress
	var source_position := Vector2(travel.x * travel_progress, travel.y * (0.25 + progress * 0.35))
	var source_rect := Rect2(source_position, source_size)
	draw_texture_rect_region(texture, Rect2(Vector2.ZERO, VIEW), source_rect, Color(1.0, 1.0, 1.0, alpha))

func wrap_text_simple(text: String, max_chars: int) -> Array[String]:
	var lines: Array[String] = []
	var remaining := text
	while remaining.length() > max_chars:
		var split_at := max_chars
		if not is_japanese:
			var candidate := remaining.substr(0, max_chars + 1).rfind(" ")
			if candidate > max_chars / 2:
				split_at = candidate
		lines.append(remaining.substr(0, split_at).strip_edges())
		remaining = remaining.substr(split_at).strip_edges()
	if not remaining.is_empty():
		lines.append(remaining)
	return lines

func draw_audio_settings_overlay() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.004, 0.01, 0.025, 0.92))
	var panel := Rect2(300, 70, 680, 620)
	draw_machine_plate(panel, Color(0.025, 0.055, 0.11, 0.98), Palette.VIOLET, 24.0, 2.0)
	draw_string(DisplayFont, Vector2(356, 122), loc("システム設定", "SYSTEM SETTINGS"), HORIZONTAL_ALIGNMENT_LEFT, 568, 30, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(356, 148), loc("音響・画面効果・会話設定は即時反映されます", "AUDIO, VISUAL AND STORY OPTIONS APPLY IMMEDIATELY"), HORIZONTAL_ALIGNMENT_LEFT, 568, 11, Palette.MUTED)
	var labels := [
		loc("マスター音量", "MASTER VOLUME"),
		loc("BGM音量", "MUSIC VOLUME"),
		loc("効果音量", "SFX VOLUME"),
		loc("画面の揺れ", "SCREEN SHAKE"),
		loc("画面フラッシュ", "SCREEN FLASH"),
		loc("ストーリー会話", "STORY DIALOGUE"),
	]
	var values := audio_setting_values()
	for index in range(settings_row_rects.size()):
		var row := settings_row_rects[index]
		var selected := settings_selected == index
		var accent := Palette.CYAN if index < 3 else Palette.VIOLET if index < 5 else Palette.MINT
		draw_machine_plate(row, Palette.with_alpha(Palette.INK, 0.76), Palette.with_alpha(accent, 0.9 if selected else 0.22), 8.0, 2.0 if selected else 1.0)
		draw_string(Palette.UI_FONT, row.position + Vector2(18, 32), str(labels[index]), HORIZONTAL_ALIGNMENT_LEFT, 196, 13, Palette.PAPER if selected else Palette.MUTED)
		if index == 5:
			var enabled: bool = audio_settings.story_dialogue_enabled
			draw_string(DisplayFont, row.position + Vector2(230, 32), loc("表示する", "SHOW") if enabled else loc("非表示（記録には回収）", "HIDE · STILL ARCHIVED"), HORIZONTAL_ALIGNMENT_LEFT, 310, 13, accent if enabled else Palette.MUTED)
			continue
		var slider := Rect2(row.position + Vector2(230, 20), Vector2(280, 12))
		draw_rect(slider, Palette.with_alpha(Palette.MUTED, 0.18))
		draw_rect(Rect2(slider.position, Vector2(slider.size.x * float(values[index]), slider.size.y)), accent)
		draw_circle(slider.position + Vector2(slider.size.x * float(values[index]), slider.size.y * 0.5), 8.0, Palette.PAPER)
		draw_string(DisplayFont, row.position + Vector2(518, 34), "%d" % int(round(float(values[index]) * 100.0)), HORIZONTAL_ALIGNMENT_RIGHT, 36, 13, accent)
	draw_campaign_button(settings_tutorial_rect, loc("R　チュートリアルを再表示", "R  REPLAY TUTORIAL"), Palette.AMBER, false)
	draw_campaign_button(settings_reset_rect, loc("初期設定へ戻す", "RESTORE DEFAULTS"), Palette.CORAL, false)
	draw_campaign_button(settings_close_rect, loc("閉じる", "CLOSE"), Palette.MINT, true)
	draw_string(Palette.UI_FONT, Vector2(356, 598), loc("上下：項目　左右：調整　R：説明　ESC / B：閉じる", "UP/DOWN: SELECT · LEFT/RIGHT: ADJUST · R: TUTORIAL · ESC/B: CLOSE"), HORIZONTAL_ALIGNMENT_LEFT, 568, 10, Palette.MUTED)

func draw_achievements_overlay() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.002, 0.008, 0.02, 0.94))
	var panel := Rect2(56, 62, 1168, 636)
	draw_machine_plate(panel, Color(0.025, 0.052, 0.10, 0.99), Palette.AMBER, 22.0, 2.0)
	draw_string(DisplayFont, Vector2(94, 112), loc("討伐実績", "HUNT RECORDS"), HORIZONTAL_ALIGNMENT_LEFT, 700, 30, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(94, 142), loc("Infinite Mode専用の実績はありません。通常進行で狙える記録のみです。", "INFINITE MODE HAS NO EXCLUSIVE RECORDS — EVERY GOAL BELONGS TO THE STANDARD HUNT."), HORIZONTAL_ALIGNMENT_LEFT, 820, 12, Palette.MUTED)
	draw_string(DisplayFont, Vector2(970, 126), "%d / %d" % [achievements.unlocked_count(), AchievementState.DEFINITIONS.size()], HORIZONTAL_ALIGNMENT_RIGHT, 200, 24, Palette.AMBER)
	for index in range(AchievementState.DEFINITIONS.size()):
		var definition: Dictionary = AchievementState.DEFINITIONS[index]
		var column := index / 5
		var row := index % 5
		var rect := Rect2(92 + column * 554, 166 + row * 88, 526, 76)
		var unlocked: bool = achievements.is_unlocked(str(definition.id))
		var accent := Palette.MINT if unlocked else Palette.MUTED
		draw_machine_plate(rect, Palette.with_alpha(Palette.INK, 0.78), Palette.with_alpha(accent, 0.82 if unlocked else 0.20), 9.0, 2.0 if unlocked else 1.0)
		draw_circle(rect.position + Vector2(28, 38), 13.0, Palette.with_alpha(accent, 0.22 if unlocked else 0.08))
		draw_string(DisplayFont, rect.position + Vector2(15, 44), "◆" if unlocked else "◇", HORIZONTAL_ALIGNMENT_CENTER, 26, 15, accent)
		draw_string(DisplayFont, rect.position + Vector2(54, 28), str(definition.get("name_ja" if is_japanese else "name_en", definition.id)), HORIZONTAL_ALIGNMENT_LEFT, 300, 15, Palette.PAPER if unlocked else Palette.MUTED)
		draw_string(Palette.UI_FONT, rect.position + Vector2(54, 54), str(definition.get("desc_ja" if is_japanese else "desc_en", "")), HORIZONTAL_ALIGNMENT_LEFT, 350, 11, Palette.PAPER if unlocked else Palette.MUTED)
		draw_string(DisplayFont, rect.position + Vector2(410, 43), achievement_progress(str(definition.id)), HORIZONTAL_ALIGNMENT_CENTER, 100, 12, accent)
	draw_campaign_button(achievements_close_rect, loc("閉じる", "CLOSE"), Palette.MINT, true)

func achievement_progress(id: String) -> String:
	match id:
		"first_core":
			return "%d / 1" % mini(1, run.beast_cores.size())
		"normal_end":
			return "1 / 1" if campaign_route.normal_end_seen else "0 / 1"
		"six_cores":
			return "%d / 6" % run.beast_cores.size()
		"dual_boss_cores":
			return "%d / 2" % run.boss_cores.size()
		"true_end":
			return "1 / 1" if campaign_route.true_end_seen else "0 / 1"
		"pure_command":
			return "ONLINE" if run.generation_mode_unlocked() else "OFFLINE"
		"hybrid_arsenal":
			return "%d / 2" % (int(run.upgrade_level("gatling_protocol") > 0) + int(run.upgrade_level("rail_protocol") > 0))
		"tier_three":
			var tier_three_ranks := 0
			for skill in GearCatalog.SKILLS:
				if int(skill.get("tier", 1)) == 3:
					tier_three_ranks += run.upgrade_level(str(skill.id))
			return "1 / 1" if tier_three_ranks > 0 else "0 / 1"
		"gear_mastery":
			var best := -1
			var target := 0
			for gear in GearCatalog.GEARS:
				var gear_id := str(gear.id)
				var value: int = run.gear_level(gear_id)
				if value > best:
					best = value
					target = GearCatalog.max_ranks_for_gear(gear_id)
			return "%d / %d" % [best, target]
		"all_skills":
			return "%d / %d" % [run.skill_points_bought(), run.total_possible_ranks()]
	return ""

func draw_achievement_toast() -> void:
	var rect := Rect2(380, 96, 520, 72)
	draw_machine_plate(rect, Color(0.025, 0.052, 0.10, 0.98), Palette.AMBER, 12.0, 2.0)
	draw_string(Palette.UI_FONT, rect.position + Vector2(22, 25), loc("実績解除", "RECORD UNLOCKED"), HORIZONTAL_ALIGNMENT_LEFT, 150, 11, Palette.AMBER)
	draw_string(DisplayFont, rect.position + Vector2(22, 54), str(achievement_notice.get("name_ja" if is_japanese else "name_en", "")), HORIZONTAL_ALIGNMENT_LEFT, 470, 18, Palette.PAPER)

func draw_background() -> void:
	# Every approved 320x180 region backdrop scales to 1280x720 at an exact 4x.
	# The legacy art-preview query still owns its selected generator background.
	var background := current_region_background()
	draw_texture_rect(background, Rect2(Vector2.ZERO, VIEW), false, Color(0.78, 0.86, 0.98, 0.58))
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.015, 0.03, 0.07, 0.42))
	for x in range(-120, 1440, 80):
		draw_line(Vector2(x, 0), Vector2(x - 260, 720), Palette.with_alpha(Palette.BLUE, 0.045), 1.0)
	for y in range(100, 720, 72):
		draw_line(Vector2(0, y), Vector2(1280, y), Palette.with_alpha(Palette.CYAN, 0.026), 1.0)
	for index in range(36):
		var point := Vector2(fmod(index * 193.0, 1280.0), fmod(index * 109.0, 720.0))
		var pulse := 0.14 + sin(animation_time * 1.8 + index) * 0.08
		draw_circle(point, 1.2, Palette.with_alpha(Palette.CYAN, pulse))

func current_region_key() -> String:
	if art_preview_enabled and art_preview_encounter.is_empty():
		return "preview"
	var encounter_id := str(run.current_boss_id)
	if encounter_id.is_empty() or not EncounterRegions.has(encounter_id):
		encounter_id = str(run.current_stage_id)
	if EncounterRegions.has(encounter_id):
		return str(EncounterRegions[encounter_id])
	if campaign_route != null and campaign_route.phase in [CampaignRoute.RoutePhase.TRUE_MAP, CampaignRoute.RoutePhase.SINGULARITY]:
		return "biocrystal"
	return "scrap"

func current_region_background() -> Texture2D:
	if current_region_key() == "preview":
		return generator_background
	return RegionBackgrounds.get(current_region_key(), RegionBackgrounds["scrap"])

func current_region_label() -> String:
	match current_region_key():
		"geothermal":
			return loc("地熱炉心層", "GEOTHERMAL CORE")
		"biocrystal":
			return loc("生体回路・結晶深層", "BIOCIRCUIT CRYSTAL DEPTHS")
		"preview":
			return loc("素材比較室", "ART REVIEW CHAMBER")
		_:
			return loc("廃棄坑道", "SCRAP MINE")

func draw_campaign_screen() -> void:
	draw_rect(Rect2(24, 96, 1232, 604), Color(0.018, 0.035, 0.075, 0.93))
	match campaign_route.phase:
		CampaignRoute.RoutePhase.MAP, CampaignRoute.RoutePhase.TRUE_MAP:
			draw_campaign_map()
		CampaignRoute.RoutePhase.BOSS_SELECT:
			draw_boss_selection()
		CampaignRoute.RoutePhase.NORMAL_END:
			draw_campaign_ending(false)
		CampaignRoute.RoutePhase.POST_TRUE_CHOICE:
			draw_post_true_choice()
		CampaignRoute.RoutePhase.FINAL_END:
			draw_final_ending_gate()
		CampaignRoute.RoutePhase.POSTGAME:
			draw_postgame_terminal()
		CampaignRoute.RoutePhase.ENHANCED_BOSS, CampaignRoute.RoutePhase.SINGULARITY, CampaignRoute.RoutePhase.FINAL_BOSS:
			draw_boss_briefing()

func draw_campaign_map() -> void:
	var true_route: bool = campaign_route.phase == CampaignRoute.RoutePhase.TRUE_MAP
	var accent := Palette.VIOLET if true_route else Palette.CYAN
	draw_string(DisplayFont, Vector2(62, 132), loc("深層討伐地図・真層", "TRUE DEPTH HUNT MAP") if true_route else loc("深層討伐地図", "ABYSSAL HUNT MAP"), HORIZONTAL_ALIGNMENT_LEFT, 580, 28, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(62, 158), loc("残り3体を討ち、6つの機械核を完成させる", "HUNT THE FINAL THREE AND COMPLETE ALL SIX CORES") if true_route else loc("好きな3体を討伐すると通常ボスへ進める", "DEFEAT ANY THREE BEASTS TO CHALLENGE A NORMAL BOSS"), HORIZONTAL_ALIGNMENT_LEFT, 680, 13, Palette.MUTED)
	draw_campaign_progress(Vector2(844, 129), accent)
	for index in range(StageCatalog.STAGES.size()):
		draw_stage_map_card(index, StageCatalog.STAGES[index])
	draw_string(Palette.UI_FONT, Vector2(0, 598), loc("クリック / 方向キーで魔獣を選択　決定で討伐開始", "SELECT A BEAST WITH CLICK OR DIRECTION · CONFIRM TO HUNT"), HORIZONTAL_ALIGNMENT_CENTER, 1280, 13, Palette.MUTED)
	var build_text := loc("統合コア %d/6　強化LV %d/%d　CHARGE %s", "INTEGRATED CORES %d/6  ·  UPGRADE LV %d/%d  ·  CHARGE %s") % [run.beast_cores.size(), run.skill_points_bought(), run.total_possible_ranks(), format_number(run.credits)]
	draw_string(DisplayFont, Vector2(62, 632), build_text, HORIZONTAL_ALIGNMENT_LEFT, 780, 14, Palette.AMBER if not run.beast_cores.is_empty() else Palette.MUTED)
	draw_campaign_button(respec_rect, loc("T  スキルツリー", "T  SKILL TREES"), Palette.MINT, false)
	draw_campaign_button(story_log_rect, loc("J  会話記録", "J  STORY LOG"), Palette.CYAN, false)
	draw_string(Palette.UI_FONT, Vector2(62, 660), loc("武器・CHARGE・コアは全ステージへ引き継がれ、自動保存される", "WEAPONS, CHARGE AND CORES PERSIST ACROSS EVERY HUNT AND AUTOSAVE"), HORIZONTAL_ALIGNMENT_LEFT, 850, 11, Palette.MUTED)

func draw_campaign_progress(origin: Vector2, accent: Color) -> void:
	for index in range(6):
		var center := origin + Vector2(index * 54, 0)
		var completed: bool = str(StageCatalog.STAGES[index].id) in campaign_route.completed_stage_ids
		draw_machine_plate(Rect2(center - Vector2(18, 10), Vector2(36, 20)), Palette.with_alpha(accent, 0.8 if completed else 0.07), accent if completed else Palette.with_alpha(accent, 0.25), 4.0, 1.0)
		draw_string(Palette.UI_FONT, center + Vector2(-18, 5), str(index + 1), HORIZONTAL_ALIGNMENT_CENTER, 36, 10, Palette.INK if completed else Palette.MUTED)

func draw_stage_map_card(index: int, definition: Dictionary) -> void:
	var rect := stage_map_rects[index]
	var id := str(definition.id)
	var completed: bool = id in campaign_route.completed_stage_ids
	var selected := campaign_selected == index
	var accent := Color(str(definition.accent))
	var fill := Palette.with_alpha(Palette.PANEL_2, 0.88 if selected else 0.68)
	if completed:
		fill = Palette.with_alpha(Palette.INK, 0.82)
	draw_machine_plate(rect, fill, Palette.with_alpha(accent, 0.95 if selected else 0.28), 14.0, 3.0 if selected else 1.0)
	draw_rect(Rect2(rect.position + Vector2(12, 12), Vector2(5, rect.size.y - 24)), Palette.with_alpha(accent, 0.85 if selected else 0.28))
	draw_string(DisplayFont, rect.position + Vector2(30, 34), "%02d  %s" % [index + 1, stage_name(definition)], HORIZONTAL_ALIGNMENT_LEFT, 294, 17, Palette.PAPER if not completed else Palette.MUTED)
	draw_string(Palette.UI_FONT, rect.position + Vector2(30, 61), str(definition.get("mechanic_ja" if is_japanese else "mechanic_en", "")), HORIZONTAL_ALIGNMENT_LEFT, 294, 12, accent)
	draw_line(rect.position + Vector2(30, 74), rect.position + Vector2(318, 74), Palette.with_alpha(accent, 0.2), 1.0)
	draw_string(Palette.UI_FONT, rect.position + Vector2(30, 100), str(definition.get("objective_ja" if is_japanese else "objective_en", "")), HORIZONTAL_ALIGNMENT_LEFT, 214, 11, Palette.MUTED)
	var portrait: Texture2D = MechanicalBeastTextures.get(id, grid_wraith_texture)
	draw_texture_rect(portrait, Rect2(rect.position + Vector2(252, 78), Vector2(72, 72)), false, Color(0.9, 0.94, 1.0, 0.9 if not completed else 0.38))
	if completed:
		draw_string(Palette.UI_FONT, rect.position + Vector2(30, 124), loc("統合核：", "CORE: ") + stage_circuit_label(str(definition.core_id)), HORIZONTAL_ALIGNMENT_LEFT, 214, 10, Palette.MINT)
	draw_string(Palette.UI_FONT, rect.position + Vector2(30, 145), loc("推奨：", "BUILD: ") + build_tag_label(str(definition.build_tag)), HORIZONTAL_ALIGNMENT_LEFT, 190, 11, accent)
	if completed:
		draw_string(DisplayFont, rect.position + Vector2(218, 145), loc("討伐済み", "DEFEATED"), HORIZONTAL_ALIGNMENT_RIGHT, 100, 12, Palette.MINT)
	elif selected:
		var scale := float(StageCatalog.ENCOUNTER_SCALING[clampi(campaign_route.completed_stage_ids.size(), 0, 5)])
		draw_string(DisplayFont, rect.position + Vector2(200, 145), "×%.2f" % scale, HORIZONTAL_ALIGNMENT_RIGHT, 118, 12, Palette.PAPER)

func draw_boss_selection() -> void:
	draw_string(DisplayFont, Vector2(0, 148), loc("通常ボスを選択", "SELECT A NORMAL BOSS"), HORIZONTAL_ALIGNMENT_CENTER, 1280, 32, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(0, 180), loc("3つの機械核とスキルツリーに合う方を選ぶ", "CHOOSE THE BOSS THAT FITS YOUR THREE CORES AND SKILL TREE"), HORIZONTAL_ALIGNMENT_CENTER, 1280, 14, Palette.MUTED)
	for index in range(StageCatalog.BOSSES.size()):
		draw_boss_choice_card(index, StageCatalog.BOSSES[index])
	draw_string(Palette.UI_FONT, Vector2(0, 560), loc("選ばなかったボスは真ルートで強化される", "THE UNCHOSEN BOSS RETURNS ENHANCED ON THE TRUE ROUTE"), HORIZONTAL_ALIGNMENT_CENTER, 1280, 13, Palette.AMBER)
	draw_string(Palette.UI_FONT, Vector2(0, 604), loc("左右 / クリックで選択　決定で戦闘開始", "LEFT-RIGHT OR CLICK · CONFIRM TO ENGAGE"), HORIZONTAL_ALIGNMENT_CENTER, 1280, 13, Palette.MUTED)

func draw_boss_choice_card(index: int, definition: Dictionary) -> void:
	var rect := boss_select_rects[index]
	var selected := campaign_selected == index
	var accent := Color(str(definition.accent))
	draw_machine_plate(rect, Palette.with_alpha(Palette.PANEL_2, 0.92 if selected else 0.7), Palette.with_alpha(accent, 1.0 if selected else 0.35), 20.0, 3.0 if selected else 1.0)
	var core := rect.position + Vector2(rect.size.x * 0.5, 78)
	draw_circle(core, 42, Palette.with_alpha(accent, 0.12))
	for ring in range(3):
		draw_arc(core, 48 + ring * 10, animation_time * (0.3 + ring * 0.1), PI * 1.4 + animation_time * (0.3 + ring * 0.1), 28, Palette.with_alpha(accent, 0.72 - ring * 0.16), 3.0)
	var portrait: Texture2D = MechanicalBeastTextures.get(str(definition.id), grid_wraith_texture)
	draw_texture_rect(portrait, Rect2(core - Vector2(67, 67), Vector2(134, 134)), false, Color(0.94, 0.96, 1.0, 1.0))
	draw_string(DisplayFont, rect.position + Vector2(0, 159), str(definition.get("name_ja" if is_japanese else "name_en", definition.id)), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 24, Palette.PAPER)
	draw_string(Palette.UI_FONT, rect.position + Vector2(34, 199), str(definition.get("rule_ja" if is_japanese else "rule_en", "")), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 68, 13, Palette.MUTED)
	draw_string(DisplayFont, rect.position + Vector2(0, 254), loc("対抗：", "COUNTER: ") + str(definition.counter_tag).to_upper(), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 13, accent)

func draw_boss_briefing() -> void:
	var definition := StageCatalog.boss(campaign_route.current_boss_id)
	var singularity: bool = campaign_route.phase == CampaignRoute.RoutePhase.SINGULARITY
	var final_encounter: bool = campaign_route.phase == CampaignRoute.RoutePhase.FINAL_BOSS
	var accent := Color(str(definition.get("accent", "f5f0db")))
	var label := loc("本当のラスボス・第%d形態" % campaign_route.final_boss_form, "THE FINAL ADVERSARY · FORM %d" % campaign_route.final_boss_form) if final_encounter else loc("真の地核機神", "TRUE WORLD ENGINE") if singularity else loc("強化深層主獣", "ENHANCED ABYSSAL BOSS")
	draw_string(DisplayFont, Vector2(0, 156), label, HORIZONTAL_ALIGNMENT_CENTER, 1280, 18, accent)
	draw_string(DisplayFont, Vector2(0, 220), str(definition.get("name_ja" if is_japanese else "name_en", campaign_route.current_boss_id)), HORIZONTAL_ALIGNMENT_CENTER, 1280, 38, Palette.PAPER)
	var center := Vector2(640, 340)
	for ring in range(5):
		draw_arc(center, 72 + ring * 22, -PI * 0.6 + animation_time * (0.15 + ring * 0.04) * (-1.0 if ring % 2 else 1.0), PI * 1.25 + animation_time * (0.15 + ring * 0.04) * (-1.0 if ring % 2 else 1.0), 48, Palette.with_alpha(accent, 0.8 - ring * 0.12), 4.0)
	var is_fallen_seraph: bool = str(definition.get("id", "")) == "prime_current_form_3"
	if is_fallen_seraph:
		draw_prime_current_form_three_aura(center, 0.0)
	var portrait: Texture2D = MechanicalBeastTextures.get(str(definition.id), grid_wraith_texture)
	var portrait_size := Vector2(292, 292) if is_fallen_seraph else Vector2(232, 232)
	draw_texture_rect(portrait, Rect2(center - portrait_size * 0.5, portrait_size), false, Color(0.96, 0.97, 1.0, 1.0))
	var rule_y := 510.0 if is_fallen_seraph else 470.0
	draw_string(Palette.UI_FONT, Vector2(350, rule_y), str(definition.get("rule_ja" if is_japanese else "rule_en", "")), HORIZONTAL_ALIGNMENT_CENTER, 580, 15, Palette.MUTED)
	draw_campaign_button(campaign_primary_rect, loc("第%d形態へ接続" % campaign_route.final_boss_form, "ENGAGE FORM %d" % campaign_route.final_boss_form) if final_encounter else loc("地核決戦を開始", "ENGAGE THE WORLD ENGINE") if singularity else loc("強化ボス戦を開始", "ENGAGE ENHANCED BOSS"), accent, true)
	draw_campaign_button(campaign_secondary_rect, loc("タイトルへ", "RETURN TO TITLE"), Palette.MUTED, false)

func draw_post_true_choice() -> void:
	var accent := Palette.PAPER
	draw_string(DisplayFont, Vector2(0, 136), loc("地核機神、停止", "WORLD ENGINE SILENCED"), HORIZONTAL_ALIGNMENT_CENTER, 1280, 30, accent)
	draw_string(Palette.UI_FONT, Vector2(0, 168), loc("だが、破壊したはずの機核から未知の電流が呼びかけている", "YET AN UNKNOWN CURRENT CALLS FROM THE CORE YOU DESTROYED"), HORIZONTAL_ALIGNMENT_CENTER, 1280, 14, Palette.MUTED)
	var panel := Rect2(226, 204, 828, 300)
	draw_machine_plate(panel, Palette.with_alpha(Palette.PANEL, 0.96), Palette.with_alpha(Palette.VIOLET, 0.48), 20.0, 2.0)
	draw_texture_rect(ProtagonistTexture, Rect2(256, 226, 238, 238), false, Color(0.92, 0.97, 1.0, 0.94))
	draw_string(Palette.UI_FONT, Vector2(526, 252), "VOLT NOMAD // INTERNAL LOG", HORIZONTAL_ALIGNMENT_LEFT, 470, 11, Palette.CYAN)
	draw_string(DisplayFont, Vector2(526, 294), loc("『任務は終わった。帰還経路は開いている』", "“THE MISSION IS COMPLETE. THE ASCENT PATH IS OPEN.”"), HORIZONTAL_ALIGNMENT_LEFT, 470, 17, Palette.PAPER)
	draw_string(DisplayFont, Vector2(526, 342), loc("『……それでも、深部から私を呼ぶ信号がある』", "“...AND STILL, SOMETHING BELOW IS CALLING ME.”"), HORIZONTAL_ALIGNMENT_LEFT, 470, 17, Palette.AMBER)
	draw_string(Palette.UI_FONT, Vector2(526, 390), loc("帰還すれば通常エンドロール。本当の敵へ応答するならOVERLIMITが1つ必要。", "ASCEND FOR THE WORLD-ENGINE CREDITS. ANSWERING THE SIGNAL REQUIRES ONE OVERLIMIT."), HORIZONTAL_ALIGNMENT_LEFT, 470, 12, Palette.MUTED)
	draw_string(DisplayFont, Vector2(526, 438), loc("OVERLIMIT  %d / 5    ·    TIER IV 接続済み" % run.overlimit_count(), "OVERLIMIT  %d / 5    ·    TIER IV ONLINE" % run.overlimit_count()), HORIZONTAL_ALIGNMENT_LEFT, 470, 15, Palette.MINT if run.overlimit_count() > 0 else Palette.AMBER)
	draw_campaign_button(campaign_primary_rect, loc("地上へ帰還する・エンドロール", "ASCEND · WORLD-ENGINE CREDITS"), Palette.CYAN, campaign_selected == 0)
	draw_campaign_button(campaign_secondary_rect, loc("深部信号へ応答する", "ANSWER THE DEEP SIGNAL"), Palette.VIOLET, campaign_selected == 1)
	draw_campaign_button(respec_rect, "T  OVERLIMIT", Palette.AMBER, false)

func draw_final_ending_gate() -> void:
	draw_string(DisplayFont, Vector2(0, 156), loc("原初電流、終息", "THE FIRST CURRENT ENDS"), HORIZONTAL_ALIGNMENT_CENTER, 1280, 36, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(0, 194), loc("機械魔獣、地核機神、そして狩人。そのすべての記憶が夜明けへ流れ出す。", "BEASTS, WORLD ENGINE, AND HUNTER — ALL THEIR MEMORIES FLOW TOWARD DAWN."), HORIZONTAL_ALIGNMENT_CENTER, 1280, 14, Palette.MUTED)
	for index in range(5):
		var color := gear_color(str(GearCatalog.GEARS[index].id))
		var center := Vector2(430 + index * 105, 354)
		draw_circle(center, 40, Palette.with_alpha(color, 0.15))
		draw_texture_rect(GearTextures[str(GearCatalog.GEARS[index].id)], Rect2(center - Vector2(32, 32), Vector2(64, 64)), false)
		draw_string(DisplayFont, center + Vector2(-28, 64), "IV", HORIZONTAL_ALIGNMENT_CENTER, 56, 16, color)
	draw_campaign_button(campaign_primary_rect, loc("真エンディングを見る", "VIEW THE TRUE ENDING"), Palette.PAPER, true)
	draw_campaign_button(campaign_ending_return_rect, loc("タイトルへ", "RETURN TO TITLE"), Palette.MUTED, false)

func draw_postgame_terminal() -> void:
	draw_string(DisplayFont, Vector2(0, 156), "VOLT NOMAD // COMPLETE", HORIZONTAL_ALIGNMENT_CENTER, 1280, 34, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(0, 194), loc("真エンディング記録済み。Infinite Modeは強化を完成させるためだけの任意モードです。", "TRUE ENDING RECORDED. INFINITE MODE REMAINS AN OPTIONAL SPACE TO FINISH STANDARD SKILLS."), HORIZONTAL_ALIGNMENT_CENTER, 1280, 14, Palette.MUTED)
	var panel := Rect2(300, 240, 680, 246)
	draw_machine_plate(panel, Palette.with_alpha(Palette.PANEL, 0.95), Palette.with_alpha(Palette.CYAN, 0.4), 18.0, 2.0)
	draw_string(DisplayFont, Vector2(0, 302), loc("本当のラスボス撃破", "PRIME CURRENT DEFEATED"), HORIZONTAL_ALIGNMENT_CENTER, 1280, 22, Palette.MINT)
	draw_string(DisplayFont, Vector2(0, 354), "OVERLIMIT %d / 5   ·   SKILLS %d / %d" % [run.overlimit_count(), run.skill_points_bought(), run.total_possible_ranks()], HORIZONTAL_ALIGNMENT_CENTER, 1280, 18, Palette.AMBER)
	draw_string(Palette.UI_FONT, Vector2(0, 408), loc("Infinite WAVEに固有実績・装備枠解禁はありません", "INFINITE WAVES HAVE NO EXCLUSIVE RECORDS OR EQUIPMENT-SLOT UNLOCKS"), HORIZONTAL_ALIGNMENT_CENTER, 1280, 12, Palette.MUTED)
	draw_campaign_button(campaign_primary_rect, loc("Infinite Modeへ", "ENTER INFINITE MODE"), Palette.VIOLET, true)
	draw_campaign_button(campaign_credits_rect, loc("真エンディングを再生", "REPLAY TRUE ENDING"), Palette.PAPER, false)
	draw_campaign_button(campaign_ending_return_rect, loc("タイトルへ", "RETURN TO TITLE"), Palette.MUTED, false)

func draw_campaign_ending(true_end: bool) -> void:
	var accent := Palette.PAPER if true_end else Palette.AMBER
	draw_string(DisplayFont, Vector2(0, 142), loc("地核機神 討滅", "WORLD ENGINE DESTROYED") if true_end else loc("通常討伐 完了", "NORMAL HUNT COMPLETE"), HORIZONTAL_ALIGNMENT_CENTER, 1280, 34, accent)
	draw_string(Palette.UI_FONT, Vector2(0, 178), loc("六獣と二主獣の核が、地底の呪縛を断ち切った", "SIX BEAST CORES AND TWO BOSS CORES BROKE THE ABYSSAL CURSE") if true_end else loc("三つの機械核で深層主獣を討った。ここで脱出することもできる", "THREE CORES DEFEATED AN ABYSSAL BOSS — YOU MAY ESCAPE HERE"), HORIZONTAL_ALIGNMENT_CENTER, 1280, 15, Palette.MUTED)
	var panel := Rect2(264, 218, 752, 300)
	draw_machine_plate(panel, Palette.with_alpha(Palette.PANEL, 0.94), Palette.with_alpha(accent, 0.5), 18.0, 2.0)
	var stats := [
		[loc("総プレイ時間", "TOTAL TIME"), format_time(run.session_elapsed)],
		[loc("戦闘時間", "COMBAT TIME"), format_time(run.elapsed)],
		[loc("討伐魔獣", "BEASTS"), "%d / 6" % campaign_route.completed_stage_ids.size()],
		[loc("撃破ボス", "BOSSES"), "%d / 2" % campaign_route.defeated_boss_ids.size()],
		[loc("最大打撃", "PEAK HIT"), format_number(run.highest_output)],
		[loc("強化LV", "UPGRADE LEVELS"), "%d / %d" % [run.skill_points_bought(), run.total_possible_ranks()]],
	]
	for index in range(stats.size()):
		var row := index % 3
		var column := index / 3
		var x := panel.position.x + 54 + column * 370
		var y := panel.position.y + 62 + row * 72
		draw_string(Palette.UI_FONT, Vector2(x, y), str(stats[index][0]), HORIZONTAL_ALIGNMENT_LEFT, 230, 12, Palette.MUTED)
		draw_string(DisplayFont, Vector2(x, y + 27), str(stats[index][1]), HORIZONTAL_ALIGNMENT_LEFT, 250, 20, Palette.PAPER)
	var copy_label := loc("C  計測JSONをコピー", "C  COPY PLAYTEST JSON")
	if result_copied_time > 0.0:
		copy_label = loc("コピー済み", "COPIED") if result_copy_succeeded else loc("コピーできません", "COPY FAILED")
	draw_campaign_button(campaign_copy_rect, copy_label, Palette.MINT if result_copy_succeeded else Palette.CORAL, false)
	draw_string(Palette.UI_FONT, Vector2(0, 544), loc("プレイ記録をローカル保存済み　制作：Godot + Codex　PixelLab + Suno", "PLAYTEST LOG SAVED LOCALLY · GODOT + CODEX · PIXELLAB + SUNO"), HORIZONTAL_ALIGNMENT_CENTER, 1280, 10, Palette.with_alpha(Palette.MUTED, 0.8))
	draw_campaign_button(campaign_primary_rect, loc("Infinite Modeへ", "ENTER INFINITE MODE") if true_end else loc("真ルートへ続く", "CONTINUE TRUE ROUTE"), accent, true)
	draw_campaign_button(campaign_achievement_rect, loc("H  実績", "H  RECORDS"), Palette.AMBER, false)
	draw_campaign_button(campaign_credits_rect, loc("E  エンドロール", "E  CREDITS"), Palette.VIOLET, false)
	draw_campaign_button(campaign_ending_return_rect, loc("タイトルへ", "RETURN TO TITLE"), Palette.MUTED, false)

func draw_campaign_button(rect: Rect2, label: String, accent: Color, primary: bool) -> void:
	var hovered := rect.has_point(mouse_position)
	draw_machine_plate(rect, Palette.with_alpha(accent, 0.72 if primary else 0.12 if hovered else 0.05), Palette.with_alpha(accent, 1.0 if hovered or primary else 0.42), 12.0, 2.0)
	draw_string(DisplayFont, rect.position + Vector2(0, 37 if rect.size.y >= 56 else 31), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 17 if primary else 14, Palette.INK if primary else Palette.PAPER)

func draw_header() -> void:
	draw_rect(Rect2(0, 0, 1280, 86), Color("080f1f"))
	draw_rect(Rect2(0, 82, 1280, 4), Palette.with_alpha(Palette.INK, 0.94))
	for index in range(16):
		var rail_x := 8.0 + index * 80.0
		draw_line(Vector2(rail_x, 83), Vector2(rail_x + 50, 83), Palette.with_alpha(Palette.CYAN, 0.2 if index % 3 else 0.42), 2.0)
	draw_rect(Rect2(171, 15, 3, 52), Palette.with_alpha(Palette.CYAN, 0.34))
	draw_string(DisplayFont, Vector2(178, 34), "VOLT NOMAD", HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(178, 60), campaign_header_context(), HORIZONTAL_ALIGNMENT_LEFT, 330, 13, Palette.MUTED)
	var accumulator_tint := Color(1.0, 1.0, 1.0, 0.94 + shard_pulse * 0.06)
	draw_texture_rect(ShardAccumulatorTexture, SHARD_ACCUMULATOR_RECT, false, accumulator_tint)
	if shard_pulse > 0.0:
		for ring in range(3):
			draw_arc(SHARD_SOCKET_CENTER, 23.0 + ring * 7.0 + (1.0 - shard_pulse) * 8.0, 0.0, TAU, 24, Palette.with_alpha(Palette.CYAN, shard_pulse * (0.5 - ring * 0.1)), 2.0)
	draw_texture_rect(energy_shard_texture, Rect2(SHARD_SOCKET_CENTER - Vector2(18, 18), Vector2(36, 36)), false)
	draw_string(Palette.UI_FONT, Vector2(606, 25), "CHARGE", HORIZONTAL_ALIGNMENT_CENTER, 94, 11, Palette.MUTED)
	draw_string(Palette.UI_FONT, Vector2(606, 56), format_number(run.credits), HORIZONTAL_ALIGNMENT_CENTER, 94, 22, Palette.AMBER)
	draw_string(Palette.UI_FONT, Vector2(752, 31), loc("総時間", "SESSION"), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Palette.MUTED)
	draw_string(Palette.UI_FONT, Vector2(752, 62), format_time(run.session_elapsed), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Palette.PAPER)
	draw_small_button(reset_rect, loc("R  もう一度", "R  CONFIRM") if reset_confirm_time > 0.0 else loc("R  初期化", "R  RESET"), Palette.CORAL)
	draw_small_button(settings_rect, loc("設定", "SET"), Palette.VIOLET)
	draw_small_button(language_rect, "日本語 / EN", Palette.MINT)
	draw_small_button(menu_rect, loc("タイトル", "TITLE"), Palette.CYAN)

func campaign_header_context() -> String:
	if campaign_route == null:
		return loc("GENERATOR CORE・縦切り版", "GENERATOR CORE · VERTICAL SLICE")
	if campaign_route.phase in [CampaignRoute.RoutePhase.MAP, CampaignRoute.RoutePhase.TRUE_MAP]:
		return loc("深層討伐地図", "ABYSSAL HUNT MAP") + " · %d/6" % campaign_route.completed_stage_ids.size()
	if campaign_route.phase == CampaignRoute.RoutePhase.BOSS_SELECT:
		return loc("通常ボスを選択", "SELECT NORMAL BOSS")
	if campaign_route.phase in [CampaignRoute.RoutePhase.NORMAL_END, CampaignRoute.RoutePhase.POST_TRUE_CHOICE, CampaignRoute.RoutePhase.FINAL_END, CampaignRoute.RoutePhase.POSTGAME]:
		return loc("討伐記録", "HUNT RECORD")
	if campaign_route.phase == CampaignRoute.RoutePhase.INFINITE:
		return "INFINITE MODE // WAVE %d" % maxi(1, run.infinite_wave)
	if not run.current_stage_id.is_empty():
		var definition := current_stage_definition()
		if not definition.is_empty():
			return stage_name(definition) + " // " + current_region_label()
	return encounter_name() + " // " + current_region_label()

func draw_small_button(rect: Rect2, text: String, accent: Color) -> void:
	var hovered := rect.has_point(mouse_position)
	draw_machine_plate(rect, Palette.with_alpha(accent, 0.18 if hovered else 0.055), Palette.with_alpha(accent, 0.92 if hovered else 0.45), 7.0, 1.0)
	draw_rect(Rect2(rect.position + Vector2(7, 6), Vector2(3, rect.size.y - 12)), Palette.with_alpha(accent, 0.7 if hovered else 0.28))
	draw_string(Palette.UI_FONT, rect.position + Vector2(0, 27), text, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 13, Palette.PAPER)

func machine_panel_points(rect: Rect2, cut: float) -> PackedVector2Array:
	var amount := minf(cut, minf(rect.size.x, rect.size.y) * 0.32)
	return PackedVector2Array([
		rect.position + Vector2(amount, 0),
		Vector2(rect.end.x - amount, rect.position.y),
		Vector2(rect.end.x, rect.position.y + amount),
		rect.end - Vector2(0, amount),
		rect.end - Vector2(amount, 0),
		Vector2(rect.position.x + amount, rect.end.y),
		Vector2(rect.position.x, rect.end.y - amount),
		rect.position + Vector2(0, amount),
	])

func draw_machine_plate(rect: Rect2, fill: Color, border: Color, cut: float = 10.0, border_width: float = 1.0) -> void:
	var points := machine_panel_points(rect, cut)
	draw_colored_polygon(points, fill)
	var outline := points.duplicate()
	outline.append(points[0])
	draw_polyline(outline, border, border_width, true)
	if rect.size.x >= 70.0 and rect.size.y >= 34.0:
		var bolt_color := Palette.with_alpha(Palette.PAPER, 0.3)
		draw_rect(Rect2(rect.position + Vector2(cut + 3, 5), Vector2(3, 3)), bolt_color)
		draw_rect(Rect2(Vector2(rect.end.x - cut - 6, rect.position.y + 5), Vector2(3, 3)), bolt_color)

func draw_console_region(source: Rect2, destination: Rect2, tint: Color = Color.WHITE) -> void:
	draw_texture_rect_region(ControlConsoleKitTexture, destination, source, tint)

func draw_reactor_panel() -> void:
	var panel := Rect2(32, 106, 360, 582)
	draw_machine_plate(panel, Palette.with_alpha(Palette.PANEL, 0.96), Palette.with_alpha(Palette.CYAN, 0.4), 18.0, 2.0)
	draw_line(Vector2(48, 151), Vector2(376, 151), Palette.with_alpha(Palette.CYAN, 0.18), 1.0)
	draw_string(DisplayFont, Vector2(58, 140), loc("深層討伐機・炉巡礼機", "ABYSS HUNTER · FORGE PILGRIM"), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Palette.MUTED)
	if art_preview_enabled and art_preview_encounter.is_empty():
		draw_legacy_reactor_visual()
	else:
		draw_protagonist_hunter()

	var manual_stat := Rect2(58, 398, 144, 70)
	var auto_stat := Rect2(216, 398, 144, 70)
	draw_machine_plate(manual_stat, Palette.with_alpha(Palette.CYAN, 0.07), Palette.with_alpha(Palette.CYAN, 0.34), 8.0, 1.0)
	draw_machine_plate(auto_stat, Palette.with_alpha(Palette.VIOLET, 0.07), Palette.with_alpha(Palette.VIOLET, 0.34), 8.0, 1.0)
	draw_string(Palette.UI_FONT, manual_stat.position + Vector2(0, 23), loc("クリック威力", "CLICK POWER"), HORIZONTAL_ALIGNMENT_CENTER, manual_stat.size.x, 11, Palette.MUTED)
	draw_string(DisplayFont, manual_stat.position + Vector2(0, 53), format_number(run.manual_damage), HORIZONTAL_ALIGNMENT_CENTER, manual_stat.size.x, 22, Palette.CYAN)
	draw_string(Palette.UI_FONT, auto_stat.position + Vector2(0, 23), loc("AUTO DPS", "AUTO DPS"), HORIZONTAL_ALIGNMENT_CENTER, auto_stat.size.x, 11, Palette.MUTED)
	draw_string(DisplayFont, auto_stat.position + Vector2(0, 53), format_number(run.estimated_auto_dps()), HORIZONTAL_ALIGNMENT_CENTER, auto_stat.size.x, 22, Palette.VIOLET)

	var hovered := charge_rect.has_point(mouse_position) or charge_held
	var charge_color := Palette.AMBER if charge_held else Palette.CYAN
	var charge_fill := Palette.with_alpha(charge_color, 0.28 if charge_held else 0.19 if hovered else 0.065)
	draw_machine_plate(charge_rect, charge_fill, Palette.with_alpha(charge_color, 1.0 if hovered else 0.68), 16.0, 3.0 if charge_held else 2.0)
	var mechanism_rect := Rect2(charge_rect.position + Vector2(7, 6 + (3 if charge_held else 0)), Vector2(72, 74))
	draw_console_region(CONTROL_CHARGE_REGION, mechanism_rect, Color(1.0, 1.0, 1.0, 1.0))
	draw_texture_rect(charge_control_texture, Rect2(charge_rect.position + Vector2(24, 22 + (3 if charge_held else 0)), Vector2(38, 38)), false, Color.WHITE)
	for step in range(6):
		var contact_color := charge_color if step < mini(6, run.manual_streak) else Palette.with_alpha(Palette.MUTED, 0.22)
		draw_rect(Rect2(charge_rect.position + Vector2(107 + step * 25, 17), Vector2(17, 4)), contact_color)
	draw_string(DisplayFont, charge_rect.position + Vector2(82, 39), loc("PURE指令", "PURE COMMAND") if run.generation_mode_unlocked() else loc("CHARGE攻撃", "CHARGE ATTACK"), HORIZONTAL_ALIGNMENT_CENTER, charge_rect.size.x - 88, 21, Palette.PAPER)
	draw_string(Palette.UI_FONT, charge_rect.position + Vector2(82, 66), loc("直接0 / 発電6倍 / AUTO指令", "0 DIRECT / 6× GEN / AUTO COMMAND") if run.generation_mode_unlocked() else loc("1入力＝1打撃＋CHARGE", "ONE INPUT = ONE HIT + CHARGE"), HORIZONTAL_ALIGNMENT_CENTER, charge_rect.size.x - 88, 11, Palette.MUTED)
	var mode_available: bool = run.generation_mode_unlocked()
	var mode_color := Palette.MINT if mode_available else Palette.MUTED
	draw_machine_plate(mode_toggle_rect, Palette.with_alpha(mode_color, 0.16 if mode_available else 0.035), Palette.with_alpha(mode_color, 0.78 if mode_available else 0.25), 9.0, 1.0)
	draw_string(DisplayFont, mode_toggle_rect.position + Vector2(0, 27), loc("PURE COMMAND  恒久接続", "PURE COMMAND  PERMANENT") if mode_available else loc("発電ツリーでPURE COMMAND解禁", "UNLOCK PURE COMMAND IN DYNAMO"), HORIZONTAL_ALIGNMENT_CENTER, mode_toggle_rect.size.x, 12, Palette.PAPER if mode_available else Palette.MUTED)
	var footer := Rect2(54, 649, 312, 31)
	draw_machine_plate(footer, Palette.with_alpha(Palette.INK, 0.72), Palette.with_alpha(Palette.CYAN, 0.18), 5.0, 1.0)
	draw_string(Palette.UI_FONT, Vector2(62, 662), tutorial_hint(), HORIZONTAL_ALIGNMENT_LEFT, 296, 11, Palette.AMBER if run.credits >= cheapest_upgrade_cost() else Palette.MUTED)
	draw_string(Palette.UI_FONT, Vector2(62, 676), loc("クリック %d  AUTO %d  臨界 %d", "CLICKS %d  AUTO %d  CRITS %d") % [run.manual_inputs, run.auto_hits, run.critical_hits], HORIZONTAL_ALIGNMENT_LEFT, 296, 10, Palette.MUTED)

func draw_legacy_reactor_visual() -> void:
	draw_texture_rect(reactor_texture, Rect2(REACTOR_CENTER - Vector2(96, 96), Vector2(192, 192)), false, Color(0.84, 0.9, 1.0, 0.9))
	var pulse: float = 1.0 + sin(animation_time * (2.0 + run.charge_ratio() * 4.0)) * (0.015 + run.charge_ratio() * 0.025)
	var radius: float = 100.0 * pulse
	for ring in range(4):
		draw_arc(REACTOR_CENTER, radius + ring * 9.0, -PI * 0.75 + animation_time * (0.24 + ring * 0.05) * (-1.0 if ring % 2 else 1.0), PI * 1.1 + animation_time * (0.24 + ring * 0.05) * (-1.0 if ring % 2 else 1.0), 48, Palette.with_alpha(Palette.CYAN, 0.42 - ring * 0.07), 2.0)
	var reactor_color: Color = Palette.AMBER if run.credits >= cheapest_upgrade_cost() else Palette.CYAN
	draw_circle(REACTOR_CENTER, 78.0, Palette.with_alpha(reactor_color, 0.12 + run.charge_ratio() * 0.18))
	draw_arc(REACTOR_CENTER, 80.0, -PI * 0.5, -PI * 0.5 + TAU * run.charge_ratio(), 64, reactor_color, 8.0)
	draw_circle(REACTOR_CENTER, 51.0, Palette.with_alpha(Palette.INK, 0.96))
	draw_circle(REACTOR_CENTER, 43.0 + sin(animation_time * 4.0) * 2.0, Palette.with_alpha(reactor_color, 0.16 + run.charge_ratio() * 0.32))
	draw_string(Palette.UI_FONT, REACTOR_CENTER + Vector2(-78, -7), format_number(run.credits), HORIZONTAL_ALIGNMENT_CENTER, 156, 23, Palette.PAPER)
	draw_string(Palette.UI_FONT, REACTOR_CENTER + Vector2(-78, 23), "CHARGE", HORIZONTAL_ALIGNMENT_CENTER, 156, 11, Palette.MUTED)

func draw_protagonist_hunter() -> void:
	var generating: bool = run.generation_mode_unlocked()
	var active_color := Palette.MINT if generating else Palette.AMBER if protagonist_action_pulse > 0.05 else Palette.CYAN
	var center := Vector2(212, 265 + sin(animation_time * 1.8) * 2.0)
	if generating:
		center.y -= protagonist_action_pulse * 4.0
	else:
		center.x += protagonist_action_pulse * 15.0
	for ring in range(4):
		var ring_radius := 82.0 + ring * 12.0 + (1.0 - protagonist_action_pulse) * (8.0 if protagonist_action_pulse > 0.0 else 0.0)
		var ring_alpha := 0.34 - ring * 0.055
		if generating:
			ring_alpha += 0.08 + sin(animation_time * 4.0 + ring) * 0.04
		draw_arc(center + Vector2(0, 5), ring_radius, -PI * 0.72 + animation_time * (0.14 + ring * 0.035) * (-1.0 if ring % 2 else 1.0), PI * 1.08 + animation_time * (0.14 + ring * 0.035) * (-1.0 if ring % 2 else 1.0), 44, Palette.with_alpha(active_color, ring_alpha), 2.0)
	if protagonist_action_pulse > 0.18 and not generating:
		for trail in range(3):
			var trail_offset := Vector2(-10.0 - trail * 8.0, 2.0)
			draw_texture_rect(ProtagonistTexture, Rect2(center - Vector2(104, 104) + trail_offset, Vector2(208, 208)), false, Palette.with_alpha(Palette.CYAN, 0.10 - trail * 0.025))
	if generating:
		for spark in range(6):
			var angle := animation_time * 1.2 + TAU * float(spark) / 6.0
			var spark_pos := center + Vector2.from_angle(angle) * (76.0 + sin(animation_time * 3.0 + spark) * 8.0)
			draw_circle(spark_pos, 3.0, Palette.with_alpha(Palette.MINT, 0.72))
	draw_texture_rect(ProtagonistTexture, Rect2(center - Vector2(104, 104), Vector2(208, 208)), false, Color(1.0, 1.0, 1.0, 0.98))
	var state_label := loc("待機", "STANDBY")
	if generating:
		state_label = "PURE COMMAND"
	elif protagonist_action_pulse > 0.05:
		state_label = loc("撃鉄打撃", "PILE-DRIVER STRIKE")
	var status_plate := Rect2(74, 354, 276, 34)
	draw_machine_plate(status_plate, Palette.with_alpha(Palette.INK, 0.88), Palette.with_alpha(active_color, 0.54), 6.0, 1.0)
	draw_string(Palette.UI_FONT, status_plate.position + Vector2(10, 14), state_label, HORIZONTAL_ALIGNMENT_LEFT, 112, 10, active_color)
	draw_string(DisplayFont, status_plate.position + Vector2(116, 24), format_number(run.credits), HORIZONTAL_ALIGNMENT_RIGHT, 112, 19, Palette.PAPER)
	draw_string(Palette.UI_FONT, status_plate.position + Vector2(234, 22), "CHARGE", HORIZONTAL_ALIGNMENT_LEFT, 36, 8, Palette.MUTED)

func cheapest_upgrade_cost() -> int:
	var cheapest := 2147483647
	for definition in ChargeState.UPGRADE_DEFINITIONS:
		var id := str(definition.id)
		if run.skill_unlocked(id) and run.upgrade_level(id) < run.skill_max_rank(id):
			cheapest = mini(cheapest, run.upgrade_cost(id))
	return 0 if cheapest == 2147483647 else cheapest

func draw_meter(rect: Rect2, ratio: float, color: Color, label: String, value: String) -> void:
	draw_string(Palette.UI_FONT, rect.position + Vector2(0, -7), label, HORIZONTAL_ALIGNMENT_LEFT, 150, 12, Palette.MUTED)
	draw_string(Palette.UI_FONT, rect.position + Vector2(146, -7), value, HORIZONTAL_ALIGNMENT_RIGHT, 150, 12, color)
	draw_machine_plate(rect, Palette.INK, Palette.with_alpha(color, 0.35), 4.0, 1.0)
	var clamped := clampf(ratio, 0.0, 1.0)
	var segment_gap := 3.0
	var segment_width := (rect.size.x - 8.0 * segment_gap) / 10.0
	for index in range(10):
		var lit := clamped * 10.0 > float(index)
		var segment_rect := Rect2(rect.position + Vector2(4 + index * (segment_width + segment_gap), 4), Vector2(segment_width, rect.size.y - 8))
		draw_rect(segment_rect, color if lit else Palette.with_alpha(color, 0.1))

func heat_color() -> Color:
	if run.heat >= 80.0:
		return Palette.CORAL
	if run.heat >= 55.0:
		return Palette.AMBER
	return Palette.MINT

func draw_circuit_panel() -> void:
	var panel := Rect2(416, 106, 832, 582)
	draw_machine_plate(panel, Palette.with_alpha(Palette.PANEL, 0.96), Palette.with_alpha(Palette.VIOLET, 0.42), 18.0, 2.0)
	draw_line(Vector2(432, 151), Vector2(1232, 151), Palette.with_alpha(Palette.VIOLET, 0.18), 1.0)
	draw_objective_header()
	draw_direct_attack_combat_panel()
	return
	if run.stage_phase == ChargeState.StagePhase.BOSS:
		var enemy_texture := current_enemy_texture()
		var enemy_pulse := 0.94 + sin(animation_time * 2.4) * 0.04
		draw_circle(Vector2(1098, 246), 101.0, Palette.with_alpha(Palette.CORAL, 0.055 + run.objective_ratio() * 0.06))
		draw_arc(Vector2(1098, 246), 105.0, -PI * 0.5, -PI * 0.5 + TAU * (1.0 - run.objective_ratio()), 48, Palette.with_alpha(Palette.CORAL, 0.4), 3.0)
		draw_texture_rect(enemy_texture, Rect2(990, 145 + sin(animation_time * 1.7) * 2.0, 216, 216), false, Color(enemy_pulse, enemy_pulse, enemy_pulse, 1.0))
	for index in range(6):
		draw_cell(index)
	if run.stage_phase == ChargeState.StagePhase.BOSS and run.boss_warning_active():
		var target_index: int = maxi(0, run.most_charged_cell())
		var siphon_start := Vector2(1018, 151)
		var siphon_end := cell_center(target_index) - Vector2(0, 74)
		var bend := Vector2(siphon_end.x, 147)
		var warning_alpha := 0.45 + sin(animation_time * 15.0) * 0.25
		draw_polyline(PackedVector2Array([siphon_start, bend, siphon_end]), Palette.with_alpha(Palette.CORAL, warning_alpha), 3.0, true)
		var pulse_position := bend.lerp(siphon_end, fmod(animation_time * 2.2, 1.0))
		draw_circle(pulse_position, 5.0, Palette.CORAL)
	for index in range(5):
		var start := cell_center(index) + Vector2(40, 0)
		var finish := cell_center(index + 1) - Vector2(40, 0)
		draw_line(start, finish, Palette.with_alpha(Palette.CYAN, 0.4 if run.cells[index] >= run.capacity - 0.01 else 0.12), 3.0)

	var can_discharge: bool = run.total_charge() >= 0.5
	var super_ready: bool = run.is_full()
	var discharge_color := Palette.AMBER if super_ready else Palette.CYAN
	var discharge_hover := discharge_rect.has_point(mouse_position)
	var discharge_fill := Palette.with_alpha(discharge_color, 0.24 if discharge_hover and can_discharge else 0.1 if can_discharge else 0.025)
	draw_machine_plate(discharge_rect, discharge_fill, Palette.with_alpha(discharge_color, 0.95 if can_discharge else 0.25), 13.0, 2.0)
	draw_console_region(CONTROL_DISCHARGE_REGION, Rect2(discharge_rect.position + Vector2(3, 4), Vector2(104, 68)), Color.WHITE if can_discharge else Color(0.45, 0.5, 0.56, 0.5))
	draw_texture_rect(discharge_control_texture, Rect2(discharge_rect.position + Vector2(34, 18), Vector2(40, 40)), false, Color.WHITE if can_discharge else Color(0.44, 0.48, 0.54, 0.42))
	for index in range(6):
		var contact_ratio: float = run.cells[index] / maxf(1.0, run.capacity)
		var contact_color := Palette.AMBER if contact_ratio >= 0.999 else discharge_color
		var contact_rect := Rect2(discharge_rect.position + Vector2(130 + index * 55, 12), Vector2(40, 7))
		draw_rect(contact_rect, Palette.with_alpha(contact_color, 0.18 + contact_ratio * 0.72))
		draw_line(Vector2(contact_rect.position.x, contact_rect.end.y + 2), Vector2(contact_rect.end.x, contact_rect.end.y + 2), Palette.with_alpha(contact_color, 0.36), 1.0)
	draw_string(DisplayFont, discharge_rect.position + Vector2(108, 42), loc("SUPER DISCHARGE", "SUPER DISCHARGE") if super_ready else "DISCHARGE", HORIZONTAL_ALIGNMENT_CENTER, discharge_rect.size.x - 120, 22, Palette.PAPER)
	draw_string(Palette.UI_FONT, discharge_rect.position + Vector2(108, 64), loc("ENTER / X / X・□　右クリック", "ENTER / X / X · SQUARE  ·  RIGHT CLICK"), HORIZONTAL_ALIGNMENT_CENTER, discharge_rect.size.x - 120, 10, Palette.MUTED)

	var auto_color := Palette.VIOLET if run.auto_enabled else Palette.MUTED
	var auto_hover := auto_rect.has_point(mouse_position)
	draw_machine_plate(auto_rect, Palette.with_alpha(auto_color, 0.2 if auto_hover or run.auto_enabled else 0.045), Palette.with_alpha(auto_color, 0.9 if run.auto_enabled else 0.42), 13.0, 2.0)
	draw_console_region(CONTROL_AUTO_REGION, Rect2(auto_rect.position + Vector2(2, 4), Vector2(70, 68)), Color.WHITE if run.auto_enabled else Color(0.66, 0.7, 0.78, 0.72))
	draw_texture_rect(auto_control_texture, Rect2(auto_rect.position + Vector2(20, 20), Vector2(38, 38)), false, Color.WHITE if run.auto_enabled else Color(0.64, 0.67, 0.76, 0.68))
	var rotor_center := auto_rect.position + Vector2(39, 39)
	if run.auto_enabled:
		draw_arc(rotor_center, 28.0, animation_time * 2.5, animation_time * 2.5 + PI * 1.3, 18, Palette.with_alpha(Palette.VIOLET, 0.8), 2.0)
	else:
		draw_line(rotor_center + Vector2(-19, 19), rotor_center + Vector2(20, -20), Palette.with_alpha(Palette.CORAL, 0.62), 3.0)
	draw_string(DisplayFont, auto_rect.position + Vector2(70, 33), "AUTO  %s" % ("ON" if run.auto_enabled else "OFF"), HORIZONTAL_ALIGNMENT_CENTER, auto_rect.size.x - 77, 17, Palette.PAPER)
	draw_string(Palette.UI_FONT, auto_rect.position + Vector2(70, 58), loc("A / Y・△", "A / Y · TRIANGLE"), HORIZONTAL_ALIGNMENT_CENTER, auto_rect.size.x - 77, 10, Palette.MUTED)
	draw_stage_rule_indicator()

	var status := message if message_time > 0.0 else tutorial_hint()
	draw_string(Palette.UI_FONT, Vector2(448, 455), status, HORIZONTAL_ALIGNMENT_CENTER, 770, 14, Palette.AMBER if run.is_full() else Palette.PAPER)
	draw_string(DisplayFont, Vector2(438, 482), loc("8能力スキルツリー — 前提LV.2で次ノード解放", "EIGHT-SKILL TREE — PREVIOUS NODE LV.2 UNLOCKS NEXT"), HORIZONTAL_ALIGNMENT_LEFT, 760, 11, Palette.MUTED)
	draw_string(DisplayFont, Vector2(1030, 482), "%d / 24" % run.skill_points_bought(), HORIZONTAL_ALIGNMENT_RIGHT, 184, 11, Palette.AMBER if run.skill_points_bought() > 0 else Palette.MUTED)
	var rack_rect := Rect2(428, 488, 788, 178)
	draw_machine_plate(rack_rect, Palette.with_alpha(Palette.INK, 0.68), Palette.with_alpha(Palette.CYAN, 0.24), 12.0, 1.0)
	draw_texture_rect_region(UpgradeRackTexture, Rect2(430, 490, 784, 172), UPGRADE_RACK_CENTER_REGION, Color(0.78, 0.86, 0.95, 0.78))
	for index in range(upgrade_rects.size()):
		draw_upgrade(index)
	draw_skill_tree_links()

	if discharge_wave > 0.0:
		var progress: float = 1.0 - discharge_wave
		draw_arc(Vector2(815, 245), 70.0 + progress * 410.0, 0.0, TAU, 64, Palette.with_alpha(Palette.AMBER if run.super_discharges > 0 else Palette.CYAN, discharge_wave * 0.8), 5.0)

func draw_direct_attack_combat_panel() -> void:
	var manual_panel := Rect2(448, 174, 380, 108)
	var auto_panel := Rect2(448, 294, 380, 108)
	draw_machine_plate(manual_panel, Palette.with_alpha(Palette.CYAN, 0.055), Palette.with_alpha(Palette.CYAN, 0.34), 12.0, 1.0)
	draw_machine_plate(auto_panel, Palette.with_alpha(Palette.VIOLET, 0.055), Palette.with_alpha(Palette.VIOLET, 0.34), 12.0, 1.0)
	draw_string(DisplayFont, manual_panel.position + Vector2(18, 28), loc("MANUAL // 即時打撃", "MANUAL // DIRECT HIT"), HORIZONTAL_ALIGNMENT_LEFT, 240, 14, Palette.CYAN)
	draw_string(Palette.UI_FONT, manual_panel.position + Vector2(18, 56), loc("1クリック", "PER CLICK"), HORIZONTAL_ALIGNMENT_LEFT, 115, 11, Palette.MUTED)
	draw_string(DisplayFont, manual_panel.position + Vector2(126, 58), format_number(run.manual_damage), HORIZONTAL_ALIGNMENT_LEFT, 95, 21, Palette.PAPER)
	draw_string(Palette.UI_FONT, manual_panel.position + Vector2(222, 56), "COMBO", HORIZONTAL_ALIGNMENT_LEFT, 66, 11, Palette.MUTED)
	draw_string(DisplayFont, manual_panel.position + Vector2(290, 58), "×%.2f" % (1.0 + float(maxi(0, run.manual_streak - 1)) * run.combo_bonus_per_stack), HORIZONTAL_ALIGNMENT_LEFT, 78, 18, Palette.AMBER)
	draw_string(Palette.UI_FONT, manual_panel.position + Vector2(18, 87), loc("クリック / SPACE・A　長押し自動連打なし", "CLICK / SPACE · A  ·  NO HOLD AUTO-CLICK"), HORIZONTAL_ALIGNMENT_LEFT, 344, 10, Palette.MUTED)

	draw_string(DisplayFont, auto_panel.position + Vector2(18, 28), loc("AUTO // 常時稼働", "AUTO // ALWAYS ONLINE"), HORIZONTAL_ALIGNMENT_LEFT, 240, 14, Palette.VIOLET)
	draw_string(Palette.UI_FONT, auto_panel.position + Vector2(18, 56), "DPS", HORIZONTAL_ALIGNMENT_LEFT, 46, 11, Palette.MUTED)
	draw_string(DisplayFont, auto_panel.position + Vector2(64, 58), format_number(run.estimated_auto_dps()), HORIZONTAL_ALIGNMENT_LEFT, 82, 21, Palette.PAPER)
	draw_string(Palette.UI_FONT, auto_panel.position + Vector2(160, 56), loc("射撃間隔", "INTERVAL"), HORIZONTAL_ALIGNMENT_LEFT, 76, 11, Palette.MUTED)
	draw_string(DisplayFont, auto_panel.position + Vector2(240, 58), "%.2fs" % run.auto_interval, HORIZONTAL_ALIGNMENT_LEFT, 68, 18, Palette.MINT)
	draw_string(Palette.UI_FONT, auto_panel.position + Vector2(304, 56), "×%d" % run.drone_count, HORIZONTAL_ALIGNMENT_LEFT, 54, 18, Palette.VIOLET)
	draw_string(Palette.UI_FONT, auto_panel.position + Vector2(18, 87), loc("クリックしていない間も攻撃とCHARGE生成が継続", "KEEPS ATTACKING AND GENERATING CHARGE WITHOUT CLICKS"), HORIZONTAL_ALIGNMENT_LEFT, 344, 10, Palette.MUTED)

	if run.stage_phase == ChargeState.StagePhase.BOSS:
		var enemy_texture := current_enemy_texture()
		var enemy_center := enemy_click_rect.get_center()
		var manual_hit_strength := manual_impact_pulse if not manual_impact_generating else 0.0
		var enemy_hit_strength := maxf(manual_hit_strength, auto_impact_pulse * 0.34)
		var enemy_display_center := enemy_center + Vector2(enemy_hit_strength * 11.0, sin(animation_time * 1.7) * 2.0)
		var enemy_pulse := 0.96 + sin(animation_time * 2.4) * 0.035
		var hovered := enemy_click_rect.has_point(mouse_position)
		var is_fallen_seraph: bool = run.current_boss_id == "prime_current_form_3"
		var damage_ratio := 1.0 - clampf(run.boss_hp / maxf(1.0, run.boss_max_hp), 0.0, 1.0)
		var enemy_radius := 146.0 if is_fallen_seraph else 116.0
		if is_fallen_seraph:
			draw_prime_current_form_three_aura(enemy_center, damage_ratio)
		draw_circle(enemy_center, enemy_radius, Palette.with_alpha(Palette.CORAL, 0.05 + (0.05 if hovered else 0.0)))
		draw_arc(enemy_center, enemy_radius + 4.0, -PI * 0.5, -PI * 0.5 + TAU * (1.0 - run.objective_ratio()), 64 if is_fallen_seraph else 56, Palette.with_alpha(Palette.CORAL, 0.58 if is_fallen_seraph else 0.48), 4.0)
		draw_manual_attack_path(enemy_display_center - Vector2(enemy_radius * 0.72, 0.0))
		var enemy_size := Vector2(292, 292) if is_fallen_seraph else Vector2(232, 232)
		var hit_boost := enemy_hit_strength * 0.34
		draw_texture_rect(enemy_texture, Rect2(enemy_display_center - enemy_size * 0.5, enemy_size), false, Color(enemy_pulse + hit_boost, enemy_pulse + hit_boost, enemy_pulse + hit_boost * 0.55, 1.0))
		draw_enemy_impact_overlay(enemy_display_center - Vector2(enemy_radius * 0.72, 0.0), manual_hit_strength, auto_impact_pulse)
		if hovered:
			draw_string(DisplayFont, Vector2(enemy_click_rect.position.x, enemy_click_rect.end.y + 15), loc("クリックで攻撃", "CLICK TO ATTACK"), HORIZONTAL_ALIGNMENT_CENTER, enemy_click_rect.size.x, 13, Palette.AMBER)
		var tracer_progress := fmod(animation_time / maxf(0.15, run.auto_interval), 1.0)
		var tracer_start := Vector2(810, 350)
		var tracer_end := enemy_display_center - Vector2(88, 0)
		draw_line(tracer_start, tracer_end, Palette.with_alpha(Palette.VIOLET, 0.12), 2.0)
		draw_auto_projectile(tracer_start, tracer_end, tracer_progress)

	draw_stage_rule_indicator()
	if message_time > 0.0:
		draw_string(Palette.UI_FONT, Vector2(448, 455), message, HORIZONTAL_ALIGNMENT_CENTER, 770, 14, Palette.PAPER)
	elif comms_time > 0.0:
		draw_comms_strip()
	else:
		draw_string(Palette.UI_FONT, Vector2(448, 455), tutorial_hint(), HORIZONTAL_ALIGNMENT_CENTER, 770, 14, Palette.PAPER)
	draw_string(DisplayFont, Vector2(438, 482), loc("5ギア・86ノード — ギアを選んで専用ツリーを開く", "FIVE GEARS · 86 NODES — OPEN A GEAR'S DEDICATED TREE"), HORIZONTAL_ALIGNMENT_LEFT, 760, 12, Palette.MUTED)
	draw_string(DisplayFont, Vector2(1030, 482), "%d / %d" % [run.skill_points_bought(), run.total_possible_ranks()], HORIZONTAL_ALIGNMENT_RIGHT, 184, 11, Palette.AMBER if run.skill_points_bought() > 0 else Palette.MUTED)
	var rack_rect := Rect2(428, 488, 788, 178)
	draw_machine_plate(rack_rect, Palette.with_alpha(Palette.INK, 0.91), Palette.with_alpha(Palette.CYAN, 0.28), 12.0, 1.0)
	for rail in range(6):
		var rail_x := rack_rect.position.x + 18.0 + rail * 126.0
		draw_line(Vector2(rail_x, rack_rect.position.y + 8), Vector2(rail_x + 92, rack_rect.position.y + 8), Palette.with_alpha(Palette.CYAN, 0.11), 2.0)
		draw_circle(Vector2(rail_x, rack_rect.end.y - 9), 2.0, Palette.with_alpha(Palette.CYAN, 0.20))
	draw_gear_rack()


func draw_manual_attack_path(target: Vector2) -> void:
	if manual_impact_pulse <= 0.0 or manual_impact_generating:
		return
	var intensity := pow(manual_impact_pulse, 0.58)
	var start := Vector2(350, 266)
	var color := Palette.AMBER if manual_impact_critical else Palette.CYAN
	var command_progress := clampf(1.0 - manual_impact_pulse, 0.0, 1.0)
	var projectile_position := start.lerp(target, ease(command_progress, -1.8))
	draw_line(start, target, Palette.with_alpha(color, intensity * 0.20), 7.0)
	draw_line(start, target, Palette.with_alpha(Palette.PAPER, intensity * 0.78), 2.0)
	draw_circle(projectile_position, 7.0 + intensity * 4.0, Palette.with_alpha(color, 0.92))
	draw_circle(projectile_position, 3.0, Palette.PAPER)


func draw_enemy_impact_overlay(target: Vector2, manual_strength: float, automatic_strength: float) -> void:
	var strength := maxf(manual_strength, automatic_strength * 0.46)
	if strength <= 0.0:
		return
	var color := Palette.AMBER if manual_impact_critical and manual_strength > 0.0 else Palette.CYAN if manual_strength > 0.0 else Palette.VIOLET
	var expansion := 1.0 - strength
	draw_circle(target, 6.0 + expansion * 16.0, Palette.with_alpha(Palette.PAPER, strength * 0.56))
	for ring in range(2):
		draw_arc(target, 12.0 + expansion * 30.0 + ring * 9.0, -PI * 0.82 + ring * 0.7, PI * 0.82 + ring * 0.7, 20, Palette.with_alpha(color, strength * (0.92 - ring * 0.24)), 3.0 - ring)
	for ray in range(6):
		var angle := TAU * float(ray) / 6.0 + animation_time * 0.08
		var ray_start := target + Vector2.from_angle(angle) * (10.0 + expansion * 7.0)
		var ray_end := target + Vector2.from_angle(angle) * (24.0 + expansion * 24.0)
		draw_line(ray_start, ray_end, Palette.with_alpha(color, strength * 0.76), 2.0)

func draw_prime_current_form_three_aura(center: Vector2, damage_ratio: float) -> void:
	var pressure := clampf(damage_ratio, 0.0, 1.0)
	var void_radius := 132.0 + sin(animation_time * 0.8) * 5.0
	draw_circle(center, void_radius, Color(0.004, 0.005, 0.018, 0.82))
	for ring in range(3):
		var radius := 118.0 + float(ring) * 20.0 + sin(animation_time * (0.6 + ring * 0.1) + ring) * 4.0
		var direction := -1.0 if ring % 2 else 1.0
		var start_angle := animation_time * (0.14 + ring * 0.045) * direction - PI * 0.5
		var sweep := PI * (1.12 + pressure * 0.55)
		draw_arc(center, radius, start_angle, start_angle + sweep, 54, Palette.with_alpha(Palette.VIOLET if ring == 1 else Palette.CYAN, 0.20 + pressure * 0.18 - ring * 0.035), 2.0 + float(ring))
	var core_colors: Array[Color] = [Palette.CYAN, Palette.AMBER, Palette.VIOLET, Palette.CORAL, Palette.MINT]
	for index in range(core_colors.size()):
		var angle := -PI * 0.5 + TAU * float(index) / float(core_colors.size()) + animation_time * (0.075 + pressure * 0.09)
		var orbit_radius := 138.0 + sin(animation_time * 1.4 + index) * 7.0
		var core_position := center + Vector2.from_angle(angle) * orbit_radius
		var core_color := core_colors[index]
		draw_line(center.lerp(core_position, 0.42), core_position, Palette.with_alpha(core_color, 0.16 + pressure * 0.18), 2.0)
		draw_circle(core_position, 7.0 + sin(animation_time * 3.2 + index) * 1.2, Palette.with_alpha(core_color, 0.22))
		draw_arc(core_position, 11.0, angle + animation_time, angle + animation_time + PI * 1.35, 16, Palette.with_alpha(core_color, 0.72), 2.0)
	for wing in range(6):
		var side := -1.0 if wing % 2 == 0 else 1.0
		var tier := float(wing / 2)
		var root := center + Vector2(side * (28.0 + tier * 8.0), -28.0 + tier * 42.0)
		var tip := center + Vector2(side * (158.0 + pressure * 18.0 - tier * 9.0), -92.0 + tier * 88.0 + sin(animation_time * 1.1 + wing) * 7.0)
		var bend := root.lerp(tip, 0.52) + Vector2(side * 18.0, -18.0 + tier * 8.0)
		draw_polyline(PackedVector2Array([root, bend, tip]), Palette.with_alpha(Palette.CYAN if wing < 2 else Palette.VIOLET, 0.13 + pressure * 0.14), 3.0, true)

func draw_auto_projectile(start: Vector2, target: Vector2, progress: float) -> void:
	var has_gatling: bool = run.upgrade_level("gatling_protocol") > 0
	var has_rail: bool = run.upgrade_level("rail_protocol") > 0
	var projectile_key: String = "standard"
	if has_gatling and has_rail:
		var hybrid_cycle: int = int(floor(animation_time / maxf(0.15, run.auto_interval))) % 3
		projectile_key = str(["gatling", "rail", "standard"][hybrid_cycle])
	elif has_rail:
		projectile_key = "rail"
	elif has_gatling:
		projectile_key = "gatling"
	var projectile: Texture2D = AutoProjectileTextures[projectile_key]
	var projectile_position: Vector2 = start.lerp(target, progress)
	var angle: float = (target - start).angle()
	var flip_x: bool = projectile_key != "gatling"
	var projectile_size: Vector2 = Vector2(92, 46) if projectile_key == "gatling" else Vector2(88, 44)
	draw_set_transform(projectile_position, angle, Vector2(-1.0 if flip_x else 1.0, 1.0))
	draw_texture_rect(projectile, Rect2(-projectile_size * 0.5, projectile_size), false, Color(1.0, 1.0, 1.0, 0.96))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if progress > 0.80:
		var impact_progress := clampf((progress - 0.80) / 0.20, 0.0, 1.0)
		var impact_pulse := sin(impact_progress * PI)
		draw_circle(target, 5.0 + impact_progress * 13.0, Palette.with_alpha(Palette.CYAN, impact_pulse * 0.16))
		draw_arc(target, 7.0 + impact_progress * 20.0, -PI * 0.75, PI * 0.75, 18, Palette.with_alpha(Palette.AMBER if projectile_key == "gatling" else Palette.VIOLET, impact_pulse * 0.82), 2.0)

func draw_comms_strip() -> void:
	draw_comms_box(Rect2(438, 438, 776, 56), false)

func draw_comms_box(rect: Rect2, cinematic: bool) -> void:
	var speaker := comms_speaker_ja if is_japanese else comms_speaker_en
	var line := comms_text_ja if is_japanese else comms_text_en
	var player_speaking := comms_role == "player" or (comms_role == "auto" and speaker in ["ヴォルト・ノマド", "VOLT NOMAD"])
	var support_speaking := comms_role == "support" or (comms_role == "auto" and speaker in ["支援演算 C6", "C6 SUPPORT", "デバッグ通信", "DEBUG COMMS"])
	var enemy_speaking := not player_speaking and not support_speaking
	var accent := Palette.CORAL if enemy_speaking else Palette.AMBER if player_speaking else Palette.CYAN
	draw_machine_plate(rect, Palette.with_alpha(Palette.INK, 0.97), Palette.with_alpha(accent, 0.78), 8.0 if cinematic else 6.0, 2.0 if cinematic else 1.0)
	draw_rect(Rect2(rect.position + Vector2(7, 7), Vector2(5, rect.size.y - 14)), accent)
	var portrait_width := 84.0 if cinematic else 0.0
	if cinematic:
		var portrait_rect := Rect2(rect.position + Vector2(24, 18), Vector2(82, 82))
		if player_speaking:
			draw_texture_rect(ProtagonistTexture, portrait_rect, false, Color(0.94, 0.98, 1.0, 0.96))
		elif enemy_speaking:
			var encounter_id: String = run.current_boss_id if not run.current_boss_id.is_empty() else run.current_stage_id
			var portrait: Texture2D = MechanicalBeastTextures.get(encounter_id, grid_wraith_texture)
			draw_texture_rect(portrait, portrait_rect, false, Color(0.98, 0.94, 1.0, 0.96))
		else:
			draw_circle(portrait_rect.get_center(), 28.0, Palette.with_alpha(Palette.CYAN, 0.18))
			draw_arc(portrait_rect.get_center(), 28.0, animation_time, animation_time + PI * 1.6, 24, accent, 3.0)
	var text_x := rect.position.x + 24.0 + portrait_width
	draw_string(DisplayFont, Vector2(text_x, rect.position.y + (31.0 if cinematic else 21.0)), speaker, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - portrait_width - 46.0, 14 if cinematic else 11, accent)
	var divider_y := rect.position.y + (42.0 if cinematic else 27.0)
	draw_line(Vector2(text_x, divider_y), Vector2(rect.end.x - 18.0, divider_y), Palette.with_alpha(accent, 0.26), 1.0)
	draw_multiline_string(
		Palette.UI_FONT,
		Vector2(text_x, rect.position.y + (65.0 if cinematic else 45.0)),
		line,
		HORIZONTAL_ALIGNMENT_LEFT,
		rect.size.x - portrait_width - 48.0,
		13 if cinematic else 11,
		2,
		Palette.PAPER
	)

func draw_stage_rule_indicator() -> void:
	var rect := Rect2(452, 424, 748, 20)
	var ratio := 0.0
	var label := current_rule_copy()
	var accent := Palette.CYAN
	if run.singularity_boss:
		ratio = (float(run.singularity_seal) + float(run.singularity_progress) / 10.0) / 6.0 if run.singularity_phase == 1 else run.singularity_rule_timer / 7.0 if run.singularity_phase == 2 else run.enemy_charge / 100.0
		accent = Palette.PAPER if run.singularity_phase < 3 else Palette.AMBER
	elif run.current_boss_id == "thermal_titan":
		ratio = run.furnace_open_timer / 6.0 if run.furnace_open_timer > 0.0 else float(run.furnace_hits) / 20.0
		label = loc("炉心開放 %.1f秒 — 全攻撃×2" % run.furnace_open_timer, "FURNACE OPEN %.1fs — ALL DAMAGE ×2" % run.furnace_open_timer) if run.furnace_open_timer > 0.0 else loc("炉心解析 %d/20クリック" % run.furnace_hits, "FURNACE SCAN %d/20 CLICKS" % run.furnace_hits)
		accent = Palette.CORAL if run.furnace_open_timer > 0.0 else Palette.AMBER
	elif run.current_boss_id == "grid_leech":
		ratio = float(run.siphon_hits) / 8.0 if run.siphon_window_timer > 0.0 else 1.0 - run.siphon_cooldown / 7.0
		label = loc("吸収核 %d/8クリック・残り%.1f秒" % [run.siphon_hits, run.siphon_window_timer], "SIPHON %d/8 CLICKS · %.1fs" % [run.siphon_hits, run.siphon_window_timer]) if run.siphon_window_timer > 0.0 else loc("吸収核の開放まで %.1f秒" % run.siphon_cooldown, "SIPHON OPENS IN %.1fs" % run.siphon_cooldown)
		accent = Palette.MINT if run.siphon_window_timer > 0.0 else Palette.CYAN
	else:
		match run.current_stage_id:
			"gearmaw":
				ratio = float(run.armor_cracks) / 12.0
				label = loc("装甲亀裂 %d/12 — 次の破砕打撃×4", "ARMOR CRACKS %d/12 — BREAK HIT ×4") % run.armor_cracks
				accent = Palette.AMBER
			"vaultback":
				ratio = run.shell_open_timer / 6.0 if run.shell_open_timer > 0.0 else run.vault_charge_meter / 50.0
				label = loc("甲殻開放 %.1f秒 — 全攻撃×2.1" % run.shell_open_timer, "SHELL OPEN %.1fs — ALL DAMAGE ×2.1" % run.shell_open_timer) if run.shell_open_timer > 0.0 else loc("開殻CHARGE %d/50" % int(run.vault_charge_meter), "SHELL CHARGE %d/50" % int(run.vault_charge_meter))
				accent = Palette.BLUE
			"pyre_wyrm":
				ratio = run.overdrive_timer / maxf(5.0, 5.0 * run.core_power)
				label = loc("オーバードライブ %.1f秒 — 能力購入で点火" % run.overdrive_timer, "OVERDRIVE %.1fs — BUY AN UPGRADE TO IGNITE" % run.overdrive_timer)
				accent = Palette.CORAL if run.overdrive_timer > 0.0 else Palette.AMBER
			"relay_hydra":
				ratio = float(run.stage_combo) / 6.0
				label = loc("残頭 %d・手動/AUTO連鎖 ×%.2f", "HEADS %d · MANUAL/AUTO CHAIN ×%.2f") % [run.hydra_heads, 1.0 + float(run.stage_combo) * 0.14]
				accent = Palette.VIOLET
			"swarm_matriarch":
				ratio = float(run.marked_drones) / float(maxi(1, run.drones))
				label = loc("子機標識 %d/%d — 次のAUTOで掃討", "DRONES MARKED %d/%d — NEXT AUTO PURGES") % [run.marked_drones, run.drones]
				accent = Palette.MINT
			"phase_mantis":
				ratio = run.analysis / 100.0
				label = loc("解析 %d%%・位相 %d/4（第三位相で臨界率上昇）", "ANALYSIS %d%% · PHASE %d/4 (CRIT BOOST IN PHASE 3)") % [int(run.analysis), run.phase_index + 1]
				accent = Palette.AMBER
			_:
				ratio = run.objective_ratio()
	draw_machine_plate(rect, Palette.with_alpha(Palette.INK, 0.84), Palette.with_alpha(accent, 0.32), 4.0, 1.0)
	for index in range(12):
		var lit := ratio * 12.0 > float(index)
		draw_rect(Rect2(rect.position + Vector2(5 + index * 39, 6), Vector2(32, 8)), accent if lit else Palette.with_alpha(accent, 0.08))
	draw_string(DisplayFont, Vector2(914, 439), label, HORIZONTAL_ALIGNMENT_RIGHT, 276, 11, Palette.PAPER)

func draw_cell(index: int) -> void:
	var rect := Rect2(448 + index * 84, 174, 76, 136)
	var ratio: float = run.cells[index] / maxf(1.0, run.capacity)
	var full := ratio >= 0.999
	var color: Color = Palette.AMBER if full else [Palette.CYAN, Palette.BLUE, Palette.VIOLET, Palette.MAGENTA, Palette.MINT, Palette.GREEN][index]
	if run.stage_phase == ChargeState.StagePhase.BOSS and run.boss_warning_active() and index == run.most_charged_cell():
		color = Palette.CORAL
		draw_machine_plate(rect.grow(10.0), Palette.with_alpha(Palette.CORAL, 0.12 + sin(animation_time * 16.0) * 0.08), Palette.CORAL, 12.0, 2.0)
	if full:
		draw_machine_plate(rect.grow(7.0), Palette.with_alpha(color, 0.12 + sin(animation_time * 5.0 + index) * 0.05), Palette.with_alpha(color, 0.5), 10.0, 1.0)
	draw_machine_plate(rect, Palette.INK, Palette.with_alpha(color, 0.24), 9.0, 1.0)
	var inner := Rect2(rect.position + Vector2(7, 7), rect.size - Vector2(14, 14))
	if ratio > 0.0:
		var fill_height := inner.size.y * ratio
		var fill_rect := Rect2(Vector2(inner.position.x, inner.end.y - fill_height), Vector2(inner.size.x, fill_height))
		draw_machine_plate(fill_rect, Palette.with_alpha(color, 0.42 if not full else 0.68), Palette.with_alpha(color, 0.7), minf(6.0, fill_height * 0.18), 1.0)
		for stripe in range(3):
			var stripe_y := fill_rect.position.y + fmod(animation_time * 36.0 + stripe * 31.0, maxf(1.0, fill_rect.size.y))
			draw_line(Vector2(fill_rect.position.x + 5, stripe_y), Vector2(fill_rect.end.x - 5, stripe_y), Palette.with_alpha(Palette.PAPER, 0.18), 1.0)
	draw_texture_rect(cell_texture, Rect2(rect.position + Vector2(4, 4), rect.size - Vector2(8, 8)), false, Color(0.9, 0.95, 1.0, 1.0))
	draw_machine_plate(Rect2(rect.position + Vector2(8, 54), Vector2(60, 34)), Color(0.025, 0.05, 0.10, 0.78), Palette.with_alpha(color, 0.28), 5.0, 1.0)
	draw_string(Palette.UI_FONT, rect.position + Vector2(0, 25), "%02d" % (index + 1), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 13, Palette.MUTED)
	draw_string(Palette.UI_FONT, rect.position + Vector2(0, 82), "%d%%" % int(ratio * 100.0), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 18, Palette.PAPER)
	draw_string(Palette.UI_FONT, rect.position + Vector2(0, 119), loc("同期", "SYNC") if full else loc("充電", "CHARGE"), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 10, color)

func draw_gear_rack() -> void:
	for index in range(GearCatalog.GEARS.size()):
		var gear: Dictionary = GearCatalog.GEARS[index]
		var rect := gear_rects[index]
		var color := Color(str(gear.accent))
		var selected := selected_gear_index == index
		var hovered := rect.has_point(mouse_position)
		var level: int = run.gear_level(str(gear.id))
		var maximum := GearCatalog.max_ranks_for_gear(str(gear.id))
		var gear_texture: Texture2D = GearTextures.get(str(gear.id))
		var first_cost := first_gear_node_cost(str(gear.id))
		var onboarding_ready: bool = campaign_route != null and campaign_route.completed_stage_ids.is_empty() and run.purchases == 0 and first_cost > 0 and run.credits >= float(first_cost)
		var ready_pulse := 0.72 + sin(animation_time * 6.0 + index * 0.8) * 0.22 if onboarding_ready else 0.0
		var border_alpha := 1.0 if selected or hovered else ready_pulse if onboarding_ready else 0.40
		draw_machine_plate(rect, Palette.with_alpha(Palette.INK, 0.92 if selected else 0.78), Palette.with_alpha(Palette.AMBER if onboarding_ready else color, border_alpha), 9.0, 3.0 if selected or hovered or onboarding_ready else 1.0)
		draw_rect(Rect2(rect.position + Vector2(7, 7), Vector2(rect.size.x - 14, 4)), Palette.with_alpha(color, 0.75 if level > 0 else 0.25))
		draw_texture_rect(gear_texture, Rect2(rect.position + Vector2(9, 16), Vector2(44, 44)), false, Color(1.0, 1.0, 1.0, 0.98 if level > 0 or selected else 0.68))
		draw_string(Palette.UI_FONT, rect.position + Vector2(120, 25), "%02d" % (index + 1), HORIZONTAL_ALIGNMENT_RIGHT, 18, 9, color)
		draw_string(DisplayFont, rect.position + Vector2(54, 31), gear_name(gear), HORIZONTAL_ALIGNMENT_LEFT, 68, 11, Palette.PAPER)
		var tag_rect := Rect2(rect.position + Vector2(53, 37), Vector2(86, 22))
		draw_machine_plate(tag_rect, Palette.with_alpha(color, 0.10), Palette.with_alpha(color, 0.34), 4.0, 1.0)
		draw_string(DisplayFont, tag_rect.position + Vector2(6, 15), str(gear.get("tag_ja" if is_japanese else "tag_en", "")), HORIZONTAL_ALIGNMENT_LEFT, tag_rect.size.x - 10, 10, Palette.PAPER if level > 0 or selected else Palette.with_alpha(Palette.PAPER, 0.78))
		for tier in range(1, 4):
			var tier_level := 0
			for skill in GearCatalog.skills_for_gear_tier(str(gear.id), tier):
				tier_level += run.upgrade_level(str(skill.id))
			var tier_max := GearCatalog.max_ranks_for_gear_tier(str(gear.id), tier)
			var tier_ratio := float(tier_level) / float(maxi(1, tier_max))
			var tier_y := rect.position.y + 76 + (tier - 1) * 17
			var tier_unlocked: bool = tier <= run.technology_tier()
			draw_string(Palette.UI_FONT, Vector2(rect.position.x + 12, tier_y + 8), "T%s" % roman_tier(tier), HORIZONTAL_ALIGNMENT_LEFT, 20, 9, color if tier_unlocked else Palette.MUTED)
			draw_rect(Rect2(rect.position.x + 34, tier_y + 2, 96, 6), Palette.with_alpha(color, 0.10 if tier_unlocked else 0.035))
			draw_rect(Rect2(rect.position.x + 34, tier_y + 2, 96 * tier_ratio, 6), Palette.AMBER if tier_level >= tier_max else color)
		draw_string(DisplayFont, rect.position + Vector2(12, 137), "LV %d / %d" % [level, maximum], HORIZONTAL_ALIGNMENT_LEFT, 124, 11, color if level > 0 else Palette.MUTED)
		var footer_copy := loc("購入可能", "READY TO BUY") if onboarding_ready else loc("ツリーを開く", "OPEN TREE")
		draw_string(Palette.UI_FONT, rect.position + Vector2(12, 154), footer_copy, HORIZONTAL_ALIGNMENT_RIGHT, 124, 11, Palette.AMBER if onboarding_ready else Palette.PAPER if hovered or selected else Palette.MUTED)


func first_gear_node_cost(gear_id: String) -> int:
	var cheapest := 2147483647
	for definition in GearCatalog.skills_for_gear_tier(gear_id, 1):
		var id := str(definition.id)
		if str(definition.get("parent", "")).is_empty() and run.skill_unlocked(id) and run.upgrade_level(id) < run.skill_max_rank(id):
			cheapest = mini(cheapest, run.upgrade_cost(id))
	return 0 if cheapest == 2147483647 else cheapest

func draw_gear_tree_overlay() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.008, 0.016, 0.038, 0.975))
	draw_rect(Rect2(28, 92, 1224, 604), Palette.with_alpha(Palette.PANEL, 0.97))
	for index in range(GearCatalog.GEARS.size()):
		var gear: Dictionary = GearCatalog.GEARS[index]
		var tab := tree_tab_rects[index]
		var color := Color(str(gear.accent))
		var selected := selected_gear_index == index
		var gear_texture: Texture2D = GearTextures.get(str(gear.id))
		draw_machine_plate(tab, Palette.with_alpha(color, 0.26 if selected else 0.045), Palette.with_alpha(color, 1.0 if selected else 0.32), 9.0, 2.0 if selected else 1.0)
		draw_texture_rect(gear_texture, Rect2(tab.position + Vector2(9, 8), Vector2(38, 38)), false, Color(1.0, 1.0, 1.0, 1.0 if selected else 0.62))
		draw_string(Palette.UI_FONT, tab.position + Vector2(179, 18), "%02d" % (index + 1), HORIZONTAL_ALIGNMENT_RIGHT, 14, 10, color)
		draw_string(DisplayFont, tab.position + Vector2(50, 23), gear_name(gear), HORIZONTAL_ALIGNMENT_LEFT, 126, 12, Palette.PAPER if selected else Palette.MUTED)
		draw_string(Palette.UI_FONT, tab.position + Vector2(50, 42), "LV %d / %d" % [run.gear_level(str(gear.id)), GearCatalog.max_ranks_for_gear(str(gear.id))], HORIZONTAL_ALIGNMENT_LEFT, 126, 11, color)
	draw_small_button(tree_close_rect, loc("閉じる", "CLOSE"), Palette.CORAL)

	var current_gear: Dictionary = GearCatalog.GEARS[selected_gear_index]
	var accent := Color(str(current_gear.accent))
	draw_string(DisplayFont, Vector2(66, 198), gear_name(current_gear), HORIZONTAL_ALIGNMENT_LEFT, 176, 18, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(250, 196), str(current_gear.get("desc_ja" if is_japanese else "desc_en", "")), HORIZONTAL_ALIGNMENT_LEFT, 272, 12, Palette.MUTED)
	for tier_index in range(4):
		var tier := tier_index + 1
		var tier_rect := tree_tier_rects[tier_index]
		var tier_selected := selected_tree_tier == tier
		var tier_unlocked: bool = tier <= run.technology_tier()
		var tier_color := accent if tier_unlocked else Palette.MUTED
		draw_machine_plate(tier_rect, Palette.with_alpha(tier_color, 0.24 if tier_selected else 0.045), Palette.with_alpha(tier_color, 1.0 if tier_selected else 0.30), 6.0, 2.0 if tier_selected else 1.0)
		draw_string(DisplayFont, tier_rect.position + Vector2(0, 22), "TIER %s" % roman_tier(tier), HORIZONTAL_ALIGNMENT_CENTER, tier_rect.size.x, 11, Palette.PAPER if tier_selected else tier_color)
		if not tier_unlocked:
			draw_string(Palette.UI_FONT, tier_rect.position + Vector2(0, 31), "LOCK", HORIZONTAL_ALIGNMENT_CENTER, tier_rect.size.x, 8, Palette.CORAL)
		elif tier == 4:
			draw_string(Palette.UI_FONT, tier_rect.position + Vector2(0, 31), "ALL ACTIVE", HORIZONTAL_ALIGNMENT_CENTER, tier_rect.size.x, 7, Palette.AMBER)
	var skills := selected_tree_skills()
	for definition in skills:
		var parent_id := str(definition.get("parent", ""))
		if parent_id.is_empty():
			continue
		var parent: Dictionary = GearCatalog.skill(parent_id)
		var from := tree_node_rect(parent).get_center()
		var to := tree_node_rect(definition).get_center()
		var active: bool = run.upgrade_level(parent_id) >= int(definition.get("parent_rank", 1))
		var elbow := Vector2(from.x, (from.y + to.y) * 0.5)
		draw_polyline(PackedVector2Array([from, elbow, Vector2(to.x, elbow.y), to]), Palette.with_alpha(Palette.AMBER if active else accent, 0.82 if active else 0.18), 3.0 if active else 1.0, true)
	for index in range(skills.size()):
		draw_tree_node(index, skills[index], accent)
	draw_tree_detail_panel(accent)

func draw_tree_node(index: int, definition: Dictionary, accent: Color) -> void:
	var rect := tree_node_rect(definition)
	var id := str(definition.id)
	var level: int = run.upgrade_level(id)
	var maximum: int = run.skill_max_rank(id)
	var unlocked: bool = run.skill_unlocked(id)
	var affordable: bool = run.can_purchase(id)
	var selected := controller_upgrade_selected == index
	var maxed := level >= maximum
	var is_overlimit_node: bool = bool(definition.get("overlimit", false))
	var border := Palette.AMBER if level > 0 else accent if unlocked else Palette.MUTED
	draw_machine_plate(rect, Palette.with_alpha(Palette.INK, 0.96 if selected else 0.86), Palette.with_alpha(border, 1.0 if selected else 0.62 if level > 0 else 0.28), 10.0, 3.0 if selected else 1.0)
	if is_overlimit_node:
		draw_texture_rect(OverlimitSocketTexture, Rect2(rect.end.x - 78, rect.position.y + 2, 72, 68), false, Color(1.0, 1.0, 1.0, 0.34 if selected or level > 0 else 0.18))
	draw_rect(Rect2(rect.position + Vector2(7, 7), Vector2(5, rect.size.y - 14)), Palette.with_alpha(border, 0.9 if level > 0 or selected else 0.2))
	var copy := skill_copy(definition)
	draw_string(DisplayFont, rect.position + Vector2(20, 25), str(copy.title), HORIZONTAL_ALIGNMENT_LEFT, 184, 12, Palette.PAPER if unlocked else Palette.MUTED)
	draw_string(Palette.UI_FONT, rect.position + Vector2(20, 47), "LV %d / %d" % [level, maximum], HORIZONTAL_ALIGNMENT_LEFT, 90, 11, border)
	if maxed:
		draw_string(DisplayFont, rect.position + Vector2(108, 48), "MAX", HORIZONTAL_ALIGNMENT_RIGHT, 88, 11, Palette.MINT)
	elif not unlocked:
		draw_string(DisplayFont, rect.position + Vector2(108, 48), "LOCK", HORIZONTAL_ALIGNMENT_RIGHT, 88, 10, Palette.CORAL)
	else:
		var cost_label := "%s C" % format_number(run.upgrade_cost(id))
		draw_string(DisplayFont, rect.position + Vector2(96, 48), cost_label, HORIZONTAL_ALIGNMENT_RIGHT, 100, 10, Palette.AMBER if affordable else Palette.CORAL)
	var progress := float(level) / float(maxi(1, maximum))
	draw_rect(Rect2(rect.position + Vector2(20, 61), Vector2(176, 5)), Palette.with_alpha(border, 0.10))
	draw_rect(Rect2(rect.position + Vector2(20, 61), Vector2(176 * progress, 5)), border)

func draw_tree_detail_panel(accent: Color) -> void:
	var panel := Rect2(816, 180, 408, 496)
	draw_machine_plate(panel, Palette.with_alpha(Palette.PANEL_2, 0.96), Palette.with_alpha(accent, 0.42), 14.0, 2.0)
	var definition := selected_skill_definition()
	if definition.is_empty():
		return
	var id := str(definition.id)
	var copy := skill_copy(definition)
	var is_overlimit_node: bool = bool(definition.get("overlimit", false))
	var detail_texture: Texture2D = OverlimitSocketTexture if is_overlimit_node else GearTextures.get(str(definition.gear))
	var detail_texture_rect := Rect2(1108, 188, 90, 90) if is_overlimit_node else Rect2(1114, 194, 78, 78)
	draw_texture_rect(detail_texture, detail_texture_rect, false, Color(1.0, 1.0, 1.0, 0.94 if is_overlimit_node else 0.88))
	draw_string(Palette.UI_FONT, Vector2(842, 214), str(GearCatalog.gear(str(definition.gear)).get("tag_ja" if is_japanese else "tag_en", "")), HORIZONTAL_ALIGNMENT_LEFT, 340, 11, accent)
	draw_string(DisplayFont, Vector2(842, 248), str(copy.title), HORIZONTAL_ALIGNMENT_LEFT, 262, 22, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(842, 280), str(copy.desc), HORIZONTAL_ALIGNMENT_LEFT, 340, 13, Palette.MUTED)
	draw_line(Vector2(842, 300), Vector2(1192, 300), Palette.with_alpha(accent, 0.22), 1.0)
	draw_string(Palette.UI_FONT, Vector2(842, 328), loc("現在ランク", "CURRENT RANK"), HORIZONTAL_ALIGNMENT_LEFT, 160, 11, Palette.MUTED)
	draw_string(DisplayFont, Vector2(1010, 330), "%d / %d" % [run.upgrade_level(id), run.skill_max_rank(id)], HORIZONTAL_ALIGNMENT_RIGHT, 182, 18, accent)
	draw_tree_gear_stats(str(definition.gear), Vector2(842, 354), accent)
	var lock_reason: String = run.skill_lock_reason(id)
	var upgrade_cost: int = run.upgrade_cost(id)
	if is_overlimit_node:
		draw_string(DisplayFont, Vector2(842, 494), loc("OVERLIMIT復旧  %d / 5　・　1個で最終戦へ挑戦可能" % run.overlimit_count(), "OVERLIMIT RESTORED  %d / 5 · ONE UNLOCKS THE FINAL BATTLE" % run.overlimit_count()), HORIZONTAL_ALIGNMENT_LEFT, 350, 10, Palette.AMBER)
		draw_string(Palette.UI_FONT, Vector2(842, 516), loc("保有CHARGE  %s" % format_number(run.credits), "CHARGE HELD  %s" % format_number(run.credits)), HORIZONTAL_ALIGNMENT_LEFT, 350, 11, Palette.PAPER)
	if not lock_reason.is_empty():
		draw_string(Palette.UI_FONT, Vector2(842, 540 if is_overlimit_node else 510), skill_lock_text(id), HORIZONTAL_ALIGNMENT_LEFT, 350, 12, Palette.CORAL)
	elif run.upgrade_level(id) >= run.skill_max_rank(id):
		draw_string(Palette.UI_FONT, Vector2(842, 540 if is_overlimit_node else 510), loc("このノードは最大強化済み", "THIS NODE IS FULLY UPGRADED"), HORIZONTAL_ALIGNMENT_LEFT, 350, 12, Palette.MINT)
	else:
		var next_cost_text := loc("必要：%s CHARGE" % format_number(upgrade_cost), "COST: %s CHARGE" % format_number(upgrade_cost))
		var cost_y := 538.0 if is_overlimit_node else 510.0
		draw_string(DisplayFont, Vector2(842, cost_y), next_cost_text, HORIZONTAL_ALIGNMENT_LEFT, 350, 11, Palette.AMBER if run.can_purchase(id) else Palette.CORAL)
		if is_overlimit_node and run.credits < float(upgrade_cost):
			draw_string(Palette.UI_FONT, Vector2(1010, cost_y), loc("不足  %s" % format_number(float(upgrade_cost) - run.credits), "SHORT  %s" % format_number(float(upgrade_cost) - run.credits)), HORIZONTAL_ALIGNMENT_RIGHT, 182, 11, Palette.CORAL)
	var purchasable: bool = run.can_purchase(id)
	var purchase_label := "MAX" if run.upgrade_level(id) >= run.skill_max_rank(id) else loc("CHARGE不足", "NOT ENOUGH CHARGE") if lock_reason.is_empty() and not purchasable else loc("購入 / 強化", "PURCHASE / UPGRADE")
	draw_campaign_button(tree_purchase_rect, purchase_label, accent if purchasable else Palette.MUTED, purchasable)
	if campaign_route.phase in [CampaignRoute.RoutePhase.MAP, CampaignRoute.RoutePhase.TRUE_MAP]:
		draw_campaign_button(tree_respec_rect, loc("無料リスペック", "FREE RESPEC"), Palette.MINT, false)
	else:
		draw_string(Palette.UI_FONT, Vector2(918, 648), loc("AUTO砲はツリー表示中も戦闘を継続", "AUTO FIRE CONTINUES WHILE THIS TREE IS OPEN"), HORIZONTAL_ALIGNMENT_CENTER, 286, 10, Palette.VIOLET)
	draw_string(Palette.UI_FONT, Vector2(816, 690), loc("方向キー：選択　ENTER/A：購入　Q/E：ギア　Z/X・Y：TIER", "D-PAD: SELECT · ENTER/A: BUY · Q/E: GEAR · Z/X OR Y: TIER"), HORIZONTAL_ALIGNMENT_CENTER, 408, 10, Palette.MUTED)

func draw_tree_gear_stats(gear_id: String, origin: Vector2, accent: Color) -> void:
	var lines: Array[String] = []
	match gear_id:
		"striker":
			lines = [loc("クリック威力  %s" % format_number(run.manual_damage), "CLICK POWER  %s" % format_number(run.manual_damage)), loc("臨界率  %.0f%%" % (run.critical_chance * 100.0), "CRIT CHANCE  %.0f%%" % (run.critical_chance * 100.0)), loc("連打上限  %d" % run.combo_cap, "COMBO CAP  %d" % run.combo_cap)]
		"dynamo":
			lines = [loc("手動発電  %.2f" % run.charge_per_click, "MANUAL GEN  %.2f" % run.charge_per_click), loc("AUTO発電  %.2f/弾" % run.auto_charge_per_shot, "AUTO GEN  %.2f/SHOT" % run.auto_charge_per_shot), loc("手動系統  %s" % ("PURE COMMAND" if run.generation_mode_unlocked() else "CHARGE ATTACK"), "MANUAL SYSTEM  %s" % ("PURE COMMAND" if run.generation_mode_unlocked() else "CHARGE ATTACK"))]
		"autogun":
			lines = ["AUTO DPS  %s" % format_number(run.estimated_auto_dps()), loc("射撃間隔  %.2f秒" % run.auto_interval, "INTERVAL  %.2fs" % run.auto_interval), loc("砲身変異  %s" % auto_mutation_label(), "WEAPON FORM  %s" % auto_mutation_label())]
		"drone":
			lines = [loc("稼働機数  %d" % run.drone_count, "ACTIVE DRONES  %d" % run.drone_count), loc("蓄積標識  %d" % run.target_marks, "TARGET MARKS  %d" % run.target_marks), loc("AUTO過給  +%d%%" % (run.auto_boost_stacks * 10), "AUTO BOOST  +%d%%" % (run.auto_boost_stacks * 10))]
		"core":
			lines = [loc("六獣コア  %d/6" % run.beast_cores.size(), "BEAST CORES  %d/6" % run.beast_cores.size()), loc("主獣コア  %d/2" % run.boss_cores.size(), "BOSS CORES  %d/2" % run.boss_cores.size()), loc("共鳴倍率  ×%.2f" % run.core_power, "RESONANCE  ×%.2f" % run.core_power)]
	for index in range(lines.size()):
		draw_machine_plate(Rect2(origin + Vector2(0, index * 43), Vector2(350, 34)), Palette.with_alpha(Palette.INK, 0.62), Palette.with_alpha(accent, 0.18), 5.0, 1.0)
		draw_string(Palette.UI_FONT, origin + Vector2(12, 23 + index * 43), lines[index], HORIZONTAL_ALIGNMENT_LEFT, 326, 11, Palette.PAPER)

func auto_mutation_label() -> String:
	match auto_mutation_key():
		"hybrid":
			return loc("複合砲身", "HYBRID")
		"gatling":
			return loc("ガトリング", "GATLING")
		"rail":
			return loc("レール砲", "RAIL")
	return loc("標準砲", "STANDARD")

func auto_mutation_key() -> String:
	if run.upgrade_level("gatling_protocol") > 0 and run.upgrade_level("rail_protocol") > 0:
		return "hybrid"
	if run.upgrade_level("gatling_protocol") > 0:
		return "gatling"
	if run.upgrade_level("rail_protocol") > 0:
		return "rail"
	return "standard"

func draw_upgrade(index: int) -> void:
	var rect := upgrade_rects[index]
	var definition: Dictionary = ChargeState.UPGRADE_DEFINITIONS[index]
	var id := str(definition.id)
	var copy := upgrade_copy(index)
	var color := upgrade_color(index)
	var affordable: bool = run.can_purchase(id)
	var unlocked: bool = run.skill_unlocked(id)
	var maxed: bool = run.upgrade_level(id) >= ChargeState.MAX_SKILL_RANK
	var hovered := hover_upgrade == index
	var linked: bool = unlocked and run.upgrade_level(id) > 0
	var background := Palette.with_alpha(Palette.INK, 0.9 if hovered else 0.76 if affordable else 0.84)
	draw_machine_plate(rect, background, Palette.with_alpha(Palette.AMBER if linked else color, 1.0 if hovered or linked else 0.46 if affordable else 0.2), 7.0, 2.0 if hovered or linked else 1.0)
	draw_rect(Rect2(rect.position + Vector2(5, 6), Vector2(4, rect.size.y - 12)), Palette.with_alpha(color, 0.92 if unlocked else 0.12))
	draw_rect(Rect2(rect.position + Vector2(12, 5), Vector2(rect.size.x - 24, 3)), Palette.with_alpha(color, 0.42 if affordable else 0.12))
	draw_circle(rect.position + Vector2(rect.size.x - 12, 12), 3.5, color if affordable else Palette.with_alpha(Palette.MUTED, 0.28))
	draw_string(Palette.UI_FONT, rect.position + Vector2(10, 20), "%d" % (index + 1), HORIZONTAL_ALIGNMENT_LEFT, 22, 12, color)
	draw_string(DisplayFont, rect.position + Vector2(32, 20), str(copy.title), HORIZONTAL_ALIGNMENT_LEFT, 136, 12, Palette.PAPER if unlocked else Palette.MUTED)
	var description_lines := str(copy.desc).split("\n")
	for line_index in range(mini(2, description_lines.size())):
		draw_string(Palette.UI_FONT, rect.position + Vector2(12, 39 + line_index * 12), str(description_lines[line_index]), HORIZONTAL_ALIGNMENT_LEFT, 160, 9, Palette.MUTED if unlocked else Palette.with_alpha(Palette.MUTED, 0.45))
	draw_string(Palette.UI_FONT, rect.position + Vector2(12, 70), "LV.%d" % run.upgrade_level(id), HORIZONTAL_ALIGNMENT_LEFT, 72, 11, color)
	if maxed:
		draw_string(Palette.UI_FONT, rect.position + Vector2(105, 70), "MAX", HORIZONTAL_ALIGNMENT_RIGHT, 69, 12, Palette.MINT)
	elif not unlocked:
		draw_string(Palette.UI_FONT, rect.position + Vector2(98, 70), "LOCK", HORIZONTAL_ALIGNMENT_RIGHT, 76, 11, Palette.CORAL)
	else:
		draw_texture_rect(energy_shard_texture, Rect2(rect.position + Vector2(100, 55), Vector2(18, 18)), false, Color.WHITE if affordable else Color(0.48, 0.52, 0.58, 0.7))
		draw_string(Palette.UI_FONT, rect.position + Vector2(119, 70), "%d" % run.upgrade_cost(id), HORIZONTAL_ALIGNMENT_RIGHT, 55, 12, Palette.AMBER if affordable else Palette.MUTED)

func upgrade_has_active_synergy(index: int) -> bool:
	var id := str(ChargeState.UPGRADE_DEFINITIONS[index].id)
	return run.skill_unlocked(id) and run.upgrade_level(id) > 0

func draw_skill_tree_links() -> void:
	# v4 uses eight independent upgrade lines. Order matters, prerequisites do not.
	pass

func draw_particles_and_text() -> void:
	for packet in resource_packets:
		var progress: float = float(packet.progress)
		if progress < 0.0:
			continue
		var eased := 1.0 - pow(1.0 - clampf(progress, 0.0, 1.0), 3.0)
		var packet_position := Vector2(packet.start).lerp(Vector2(packet.finish), eased)
		packet_position.y -= sin(eased * PI) * float(packet.arc)
		var packet_alpha := sin(clampf(progress, 0.0, 1.0) * PI)
		draw_circle(packet_position, float(packet.size), Palette.with_alpha(Color(packet.color), packet_alpha))
		draw_line(packet_position - Vector2(7, 0), packet_position, Palette.with_alpha(Color(packet.color), packet_alpha * 0.45), 2.0)
	for item in particles:
		var alpha := clampf(float(item.life) / maxf(0.01, float(item.max_life)), 0.0, 1.0)
		draw_circle(Vector2(item.pos), float(item.size) * alpha, Palette.with_alpha(Color(item.color), alpha))
	for item in floating_texts:
		var alpha := clampf(float(item.life) / maxf(0.01, float(item.max_life)), 0.0, 1.0)
		draw_string(Palette.UI_FONT, Vector2(item.pos) + Vector2(-150, 0), str(item.text), HORIZONTAL_ALIGNMENT_CENTER, 300, int(item.size), Palette.with_alpha(Color(item.color), alpha))

func draw_objective_header() -> void:
	var is_boss: bool = run.stage_phase == ChargeState.StagePhase.BOSS
	var accent := Palette.CORAL if is_boss else Palette.CYAN
	var definition := current_stage_definition()
	var title := encounter_name() if is_boss else stage_name(definition) if not definition.is_empty() else "GENERATOR CORE"
	var phase := current_rule_copy()
	var current: float = run.boss_max_hp - run.boss_hp if is_boss else run.restore_progress
	var target: float = run.boss_max_hp if is_boss else run.restore_goal
	draw_string(DisplayFont, Vector2(446, 129), title, HORIZONTAL_ALIGNMENT_LEFT, 360, 15, accent)
	draw_string(Palette.UI_FONT, Vector2(446, 147), phase, HORIZONTAL_ALIGNMENT_LEFT, 360, 12, Palette.MUTED)
	if is_boss:
		draw_texture_rect(WraithGaugeTexture, Rect2(824, 105, 390, 58), false, Color(0.9, 0.94, 1.0, 0.82))
		var remaining_ratio: float = clampf(run.boss_hp / maxf(1.0, run.boss_max_hp), 0.0, 1.0)
		var remaining_seals := int(ceil(remaining_ratio * 6.0))
		var seal_positions := [842.0, 883.0, 924.0, 1080.0, 1121.0, 1162.0]
		for index in range(6):
			var seal_rect := Rect2(seal_positions[index], 128, 31, 13)
			var intact := index < remaining_seals
			draw_machine_plate(seal_rect, Palette.with_alpha(Palette.CORAL if intact else Palette.CYAN, 0.8 if intact else 0.12), Palette.CORAL if intact else Palette.with_alpha(Palette.CYAN, 0.38), 3.0, 1.0)
		var value_text := "%.1f%%" % (remaining_ratio * 100.0)
		draw_string(Palette.UI_FONT, Vector2(980, 143), value_text, HORIZONTAL_ALIGNMENT_CENTER, 92, 15, Palette.PAPER)
		draw_string(Palette.UI_FONT, Vector2(824, 158), "%s / %s HP" % [format_integer(run.boss_hp), format_integer(run.boss_max_hp)], HORIZONTAL_ALIGNMENT_CENTER, 390, 11, Palette.PAPER)
	else:
		var ratio: float = clampf(current / maxf(1.0, target), 0.0, 1.0)
		var bar := Rect2(820, 120, 378, 26)
		draw_machine_plate(bar, Palette.INK, Palette.with_alpha(accent, 0.38), 5.0, 1.0)
		for index in range(6):
			var part_ratio := clampf(ratio * 6.0 - float(index), 0.0, 1.0)
			var segment_rect := Rect2(bar.position + Vector2(7 + index * 61, 6), Vector2(53, 14))
			draw_rect(segment_rect, Palette.with_alpha(accent, 0.1 + part_ratio * 0.9))
		draw_string(Palette.UI_FONT, Vector2(820, 158), "%s / %s" % [format_number(current), format_number(target)], HORIZONTAL_ALIGNMENT_CENTER, 378, 10, Palette.PAPER)

func draw_completion_overlay() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.015, 0.025, 0.06, 0.92))
	if run.stage_phase == ChargeState.StagePhase.REWARD:
		draw_reward_overlay()
	else:
		draw_clear_overlay()
	draw_small_button(language_rect, "日本語 / EN", Palette.MINT)
	draw_small_button(menu_rect, loc("タイトル", "TITLE"), Palette.CYAN)

func draw_reward_overlay() -> void:
	var definition := current_stage_definition()
	draw_string(DisplayFont, Vector2(0, 92), stage_name(definition) + loc(" 復旧完了", " RESTORED"), HORIZONTAL_ALIGNMENT_CENTER, 1280, 34, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(0, 132), loc("次の回路へ持ち込む恒久報酬を1つ選択", "CHOOSE ONE PERMANENT CIRCUIT FOR THE NEXT STAGE"), HORIZONTAL_ALIGNMENT_CENTER, 1280, 17, Palette.MUTED)
	draw_string(Palette.UI_FONT, Vector2(0, 210), encounter_name() + loc("を排除した。中枢回路から新しい設計を抽出できる。", " PURGED. EXTRACT ONE DESIGN FROM THE RESTORED CORE."), HORIZONTAL_ALIGNMENT_CENTER, 1280, 15, Palette.CYAN)
	for index in range(reward_rects.size()):
		var rect := reward_rects[index]
		var reward := reward_copy(index)
		var selected := reward_selected == index
		var color := Color(reward.color)
		draw_style_box(Palette.rounded_box(Palette.with_alpha(color, 0.22 if selected else 0.07), 22, Palette.with_alpha(color, 1.0 if selected else 0.42), 3 if selected else 1), rect)
		draw_circle(rect.position + Vector2(150, 58), 28, Palette.with_alpha(color, 0.2))
		draw_arc(rect.position + Vector2(150, 58), 34, -PI * 0.7 + animation_time, PI * 1.15 + animation_time, 32, color, 4)
		draw_string(Palette.UI_FONT, rect.position + Vector2(0, 112), str(reward.title), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 19, Palette.PAPER)
		draw_string(Palette.UI_FONT, rect.position + Vector2(0, 140), str(reward.tag), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 12, color)
		var descriptions := str(reward.desc).split("\n")
		for line_index in range(descriptions.size()):
			draw_string(Palette.UI_FONT, rect.position + Vector2(0, 172 + line_index * 22), str(descriptions[line_index]), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 13, Palette.MUTED)
	draw_string(Palette.UI_FONT, Vector2(0, 565), loc("クリック / 1〜3 / 左右 + 決定", "CLICK / 1–3 / LEFT-RIGHT + CONFIRM"), HORIZONTAL_ALIGNMENT_CENTER, 1280, 14, Palette.MUTED)

func draw_clear_overlay() -> void:
	var panel := Rect2(270, 108, 740, 534)
	draw_machine_plate(panel, Palette.PANEL, Palette.AMBER, 22.0, 2.0)
	var is_stage_hunt: bool = campaign_route.phase == CampaignRoute.RoutePhase.STAGE
	var is_infinite: bool = campaign_route.phase == CampaignRoute.RoutePhase.INFINITE
	draw_string(DisplayFont, Vector2(0, 168), loc("無限演算 突破", "INFINITE WAVE CLEARED") if is_infinite else loc("機械魔獣 討伐", "MECHANICAL BEAST DEFEATED") if is_stage_hunt else loc("深層主獣 討伐", "ABYSSAL BOSS DEFEATED"), HORIZONTAL_ALIGNMENT_CENTER, 1280, 34, Palette.AMBER)
	var definition := current_stage_definition()
	draw_string(DisplayFont, Vector2(0, 205), stage_name(definition) if not definition.is_empty() else encounter_name(), HORIZONTAL_ALIGNMENT_CENTER, 1280, 18, Palette.PAPER)
	var core_name := loc("主獣核（自動統合）", "BOSS CORE — AUTO INTEGRATED")
	if is_infinite:
		core_name = "+%s CHARGE" % format_number(infinite_reward_for_wave(maxi(1, campaign_route.infinite_wave - 1)))
	elif not definition.is_empty():
		core_name = str(definition.get("core_name_ja" if is_japanese else "core_name_en", "CORE"))
	var stats := [
		[loc("クリアタイム", "CLEAR TIME"), format_time(run.stage_clear_time)],
		[loc("手動 / AUTO命中", "MANUAL / AUTO HITS"), "%d / %d" % [run.manual_inputs, run.auto_hits]],
		[loc("最大打撃", "PEAK HIT"), format_number(run.highest_output)],
		[loc("累計CHARGE", "TOTAL CHARGE"), format_number(run.lifetime_charge)],
		[loc("強化レベル合計", "TOTAL UPGRADE LEVELS"), str(run.skill_points_bought())],
		[loc("無限報酬", "INFINITE REWARD") if is_infinite else loc("回収機械核", "RECOVERED CORE"), core_name],
	]
	for index in range(stats.size()):
		var y := 250 + index * 42
		draw_string(Palette.UI_FONT, Vector2(340, y), str(stats[index][0]), HORIZONTAL_ALIGNMENT_LEFT, 250, 14, Palette.MUTED)
		draw_string(Palette.UI_FONT, Vector2(610, y), str(stats[index][1]), HORIZONTAL_ALIGNMENT_RIGHT, 300, 17, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(0, 520), loc("獲得CHARGEで未完成スキルを強化できる。WAVE専用実績はない。", "SPEND THE REWARD ON UNFINISHED SKILLS — WAVES HAVE NO EXCLUSIVE RECORDS.") if is_infinite else loc("核は自動で統合され、以後のすべての戦闘で効果を発揮する", "THE CORE IS AUTOMATICALLY INTEGRATED FOR EVERY FUTURE BATTLE"), HORIZONTAL_ALIGNMENT_CENTER, 1280, 14, Palette.CYAN)
	draw_machine_plate(clear_retry_rect, Palette.AMBER, Palette.PAPER, 10.0, 2.0)
	draw_string(DisplayFont, clear_retry_rect.position + Vector2(0, 34), loc("次のWAVE", "NEXT WAVE") if is_infinite else loc("討伐地図へ", "HUNT MAP"), HORIZONTAL_ALIGNMENT_CENTER, clear_retry_rect.size.x, 16, Palette.INK)
	draw_machine_plate(clear_menu_rect, Palette.PANEL_2, Palette.CYAN, 10.0, 1.0)
	draw_string(Palette.UI_FONT, clear_menu_rect.position + Vector2(0, 34), loc("完全復旧記録へ", "END INFINITE") if is_infinite else loc("タイトルへ", "RETURN TO TITLE"), HORIZONTAL_ALIGNMENT_CENTER, clear_menu_rect.size.x, 16, Palette.PAPER)

func boss_integrity_label() -> String:
	if run.infinite_mode:
		return loc("無限演算耐久", "INFINITE FRAME HP")
	if run.singularity_boss:
		return loc("事象安定度", "EVENT STABILITY")
	if run.current_boss_id == "thermal_titan":
		return loc("炉心装甲", "CORE ARMOR")
	if run.current_boss_id == "grid_leech":
		return loc("吸収器耐久", "SIPHON INTEGRITY")
	return loc("機械魔獣耐久", "MECHANICAL BEAST HP")
