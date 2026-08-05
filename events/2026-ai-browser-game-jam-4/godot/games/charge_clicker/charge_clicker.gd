extends Node2D

signal return_to_menu
signal language_changed(is_japanese: bool)

const Palette = preload("res://shared/palette.gd")
const Synth = preload("res://shared/synth.gd")
const ControllerConfig = preload("res://shared/controller_bindings.gd")
const ChargeState = preload("res://games/charge_clicker/charge_state.gd")
const GearCatalog = preload("res://games/charge_clicker/gear_catalog.gd")
const ChargeSave = preload("res://games/charge_clicker/charge_save.gd")
const CampaignRoute = preload("res://games/charge_clicker/charge_route.gd")
const StageCatalog = preload("res://games/charge_clicker/stage_catalog.gd")
const DisplayFont = preload("res://assets/fonts/DotGothic16-Regular.ttf")
const BGMStreams := {
	"map": preload("res://assets/audio/project_charge/subterranean_hunt.ogg"),
	"hunt": preload("res://assets/audio/project_charge/piston_hunt_loop.ogg"),
	"boss": preload("res://assets/audio/project_charge/forge_of_breakpoints.ogg"),
	"singularity": preload("res://assets/audio/project_charge/arch_singularity.ogg"),
	"ending": preload("res://assets/audio/project_charge/core_of_dawn.ogg"),
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
}
const UpgradeRackTexture: Texture2D = preload("res://assets/charge_clicker/pixellab/source/ui/upgrade-rack-switchboard-a.png")
const ControlConsoleKitTexture: Texture2D = preload("res://assets/charge_clicker/pixellab/source/ui/control-kit-switchboard-a.png")
const WraithGaugeTexture: Texture2D = preload("res://assets/charge_clicker/pixellab/source/ui/wraith-gauge-switchboard-a.png")
const ShardAccumulatorTexture: Texture2D = preload("res://assets/charge_clicker/pixellab/source/ui/shard-accumulator-corrupted-b.png")

const VIEW := Vector2(1280, 720)
const AUDIO_SETTINGS_PATH := "user://project_charge_audio.cfg"
const BGM_VOLUME_DB := -10.0
const BGM_SILENT_DB := -60.0
const BGM_CROSSFADE_SECONDS := 0.85
const REACTOR_CENTER := Vector2(212, 286)
const SHARD_ACCUMULATOR_RECT := Rect2(524, 5, 196, 78)
const SHARD_SOCKET_CENTER := Vector2(575, 44)
const CONTROL_CHARGE_REGION := Rect2(0, 0, 104, 128)
const CONTROL_DISCHARGE_REGION := Rect2(104, 0, 174, 128)
const CONTROL_AUTO_REGION := Rect2(278, 0, 106, 128)
const UPGRADE_RACK_CENTER_REGION := Rect2(76, 4, 232, 120)
const PLAYTEST_LOG_PATH := "user://project_charge_playtests.jsonl"

var synth: JamSynth
var bgm_players: Array[AudioStreamPlayer] = []
var bgm_active_index := -1
var bgm_key := ""
var bgm_crossfade: Tween
var music_enabled := true
var run
var save_manager
var campaign_route
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
var campaign_preview_screen := ""

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

var charge_rect := Rect2(70, 502, 284, 88)
var mode_toggle_rect := Rect2(70, 598, 284, 44)
var discharge_rect := Rect2(452, 340, 510, 76)
var auto_rect := Rect2(980, 340, 220, 76)
var enemy_click_rect := Rect2(860, 160, 352, 242)
var menu_rect := Rect2(1102, 22, 138, 42)
var language_rect := Rect2(932, 22, 152, 42)
var music_rect := Rect2(858, 22, 62, 42)
var reset_rect := Rect2(34, 22, 126, 42)
var upgrade_rects: Array[Rect2] = []
var gear_rects: Array[Rect2] = []
var tree_tab_rects: Array[Rect2] = []
var tree_tier_rects: Array[Rect2] = [Rect2(538, 174, 76, 34), Rect2(624, 174, 76, 34), Rect2(710, 174, 76, 34)]
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

func _ready() -> void:
	apply_web_art_preview()
	synth = Synth.new()
	add_child(synth)
	run = ChargeState.new()
	campaign_route = CampaignRoute.new()
	save_manager = ChargeSave.new()
	for index in range(GearCatalog.GEARS.size()):
		gear_rects.append(Rect2(438 + index * 156, 500, 148, 160))
		tree_tab_rects.append(Rect2(58 + index * 214, 112, 202, 52))
	for row in range(2):
		for column in range(3):
			stage_map_rects.append(Rect2(62 + column * 404, 180 + row * 208, 348, 176))
	var resumed: bool = persistence_enabled and save_manager.load_bundle_into(run, campaign_route)
	if art_preview_enabled:
		if campaign_preview_screen.is_empty():
			campaign_route.reset()
			campaign_route.select_stage("gearmaw")
			configure_art_preview_state()
		else:
			configure_campaign_preview()
	if campaign_route.phase in [CampaignRoute.RoutePhase.MAP, CampaignRoute.RoutePhase.TRUE_MAP]:
		campaign_selected = first_available_stage_index()
	elif campaign_route.phase == CampaignRoute.RoutePhase.BOSS_SELECT:
		campaign_selected = 0
	if resumed:
		show_message(loc("保存したキャンペーンを再開", "CAMPAIGN RESUMED"), 3.0)
	else:
		show_message(loc("討伐地図から最初の機械魔獣を選択", "SELECT YOUR FIRST MECHANICAL BEAST"), 5.0)
	setup_music()
	refresh_music()
	queue_redraw()

func setup_music() -> void:
	var settings := ConfigFile.new()
	if settings.load(AUDIO_SETTINGS_PATH) == OK:
		music_enabled = bool(settings.get_value("audio", "music_enabled", true))
	if DisplayServer.get_name() == "headless":
		return
	for index in range(2):
		var player := AudioStreamPlayer.new()
		player.name = "BGM%d" % (index + 1)
		player.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
		player.volume_db = BGM_SILENT_DB
		add_child(player)
		bgm_players.append(player)

func desired_bgm_key() -> String:
	if campaign_route == null:
		return "map"
	match campaign_route.phase:
		CampaignRoute.RoutePhase.STAGE:
			return "hunt"
		CampaignRoute.RoutePhase.BOSS, CampaignRoute.RoutePhase.ENHANCED_BOSS:
			return "boss"
		CampaignRoute.RoutePhase.SINGULARITY:
			return "singularity"
		CampaignRoute.RoutePhase.NORMAL_END, CampaignRoute.RoutePhase.TRUE_END:
			return "ending"
		_:
			return "map"

func refresh_music(force := false) -> void:
	var next_key := desired_bgm_key()
	if next_key == bgm_key and not force:
		return
	bgm_key = next_key
	if bgm_players.is_empty() or not music_enabled:
		return
	var next_stream := BGMStreams.get(next_key) as AudioStreamOggVorbis
	if next_stream == null:
		return
	next_stream.loop = true
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

func toggle_music() -> void:
	music_enabled = not music_enabled
	var settings := ConfigFile.new()
	settings.set_value("audio", "music_enabled", music_enabled)
	settings.save(AUDIO_SETTINGS_PATH)
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
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and music_rect.has_point(event.position):
		toggle_music()
		return true
	if event is InputEventScreenTouch and event.pressed and music_rect.has_point(event.position):
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
	campaign_preview_screen = str(values.get("campaign_preview", ""))
	art_preview_encounter = str(values.get("encounter", ""))
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
		_:
			campaign_selected = 0

func configure_art_preview_state() -> void:
	var preview_id := art_preview_encounter if not art_preview_encounter.is_empty() else "gearmaw"
	var stage_definition := StageCatalog.stage(preview_id)
	var boss_definition := StageCatalog.boss(preview_id)
	if not stage_definition.is_empty():
		run.begin_stage(preview_id, str(stage_definition.build_tag), 1.0, StageCatalog.stage_hp(preview_id, 0), 0)
	elif not boss_definition.is_empty():
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

func parse_query_string(raw_query: String) -> Dictionary:
	var values := {}
	for pair in raw_query.trim_prefix("?").split("&", false):
		var parts := pair.split("=", true, 1)
		if parts.size() == 2:
			values[str(parts[0])] = str(parts[1])
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
	shard_pulse = 0.0
	charge_held = false
	gear_tree_open = false
	screen_flash = 0.0
	screen_shake = 0.0
	discharge_wave = 0.0
	show_message(loc("新しいキャンペーンを開始", "NEW CAMPAIGN INITIALIZED"), 1.8)
	synth.play_chord([220.0, 329.63, 440.0], 0.22, -24.0)
	queue_redraw()

func request_reset() -> bool:
	if reset_confirm_time > 0.0:
		reset_run()
		return true
	reset_confirm_time = 3.0
	show_message(loc("全進行を消去します。3秒以内にもう一度R / 初期化", "ERASE ALL PROGRESS? PRESS R / RESET AGAIN WITHIN 3 SECONDS"), 3.0)
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
	if message_time > 0.0:
		message_time -= delta
	if result_copied_time > 0.0:
		result_copied_time -= delta
	if reset_confirm_time > 0.0:
		reset_confirm_time -= delta
	autosave_timer -= delta
	if art_preview_enabled:
		update_effects(delta)
		queue_redraw()
		return
	if campaign_route.phase not in [CampaignRoute.RoutePhase.NORMAL_END, CampaignRoute.RoutePhase.TRUE_END]:
		run.advance_session_time(delta)
	if not campaign_gameplay_active():
		if autosave_timer <= 0.0:
			autosave_timer = 5.0
			save_progress()
		update_effects(delta)
		queue_redraw()
		return

	var tick_result: Dictionary = run.tick(delta, false)
	if int(tick_result.auto_hits) > 0:
		auto_effect_timer -= delta
		if auto_effect_timer <= 0.0:
			auto_effect_timer = 0.10
			spawn_sparks(Vector2(1030, 248), Palette.VIOLET, 3, 75.0)
			add_floating(Vector2(1030, 230), "-%s" % format_number(float(tick_result.auto_damage)), Palette.VIOLET, 13)
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
	if campaign_route.phase in [CampaignRoute.RoutePhase.BOSS, CampaignRoute.RoutePhase.ENHANCED_BOSS, CampaignRoute.RoutePhase.SINGULARITY]:
		return run.stage_phase == ChargeState.StagePhase.BOSS
	return false

func campaign_screen_visible() -> bool:
	if campaign_route == null or (art_preview_enabled and campaign_preview_screen.is_empty()):
		return false
	if campaign_route.phase in [CampaignRoute.RoutePhase.MAP, CampaignRoute.RoutePhase.TRUE_MAP, CampaignRoute.RoutePhase.BOSS_SELECT, CampaignRoute.RoutePhase.NORMAL_END, CampaignRoute.RoutePhase.TRUE_END]:
		return true
	return campaign_route.phase in [CampaignRoute.RoutePhase.ENHANCED_BOSS, CampaignRoute.RoutePhase.SINGULARITY] and run.stage_phase == ChargeState.StagePhase.CLEAR

func _unhandled_input(event: InputEvent) -> void:
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
		elif event.keycode == KEY_C and campaign_route.phase in [CampaignRoute.RoutePhase.NORMAL_END, CampaignRoute.RoutePhase.TRUE_END]:
			copy_campaign_result()
		elif event.keycode == KEY_R:
			request_reset()
		elif event.keycode == KEY_T and campaign_route.phase in [CampaignRoute.RoutePhase.MAP, CampaignRoute.RoutePhase.TRUE_MAP]:
			open_gear_tree(0)
		elif event.keycode == KEY_ESCAPE:
			return_to_menu.emit()
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
				elif event.button_index == controller_button("combat_action") and campaign_route.phase in [CampaignRoute.RoutePhase.NORMAL_END, CampaignRoute.RoutePhase.TRUE_END]:
					copy_campaign_result()
				elif event.button_index == controller_button("language"):
					toggle_language()
				elif event.button_index == controller_button("menu") and campaign_route.phase in [CampaignRoute.RoutePhase.MAP, CampaignRoute.RoutePhase.TRUE_MAP]:
					open_gear_tree(selected_gear_index)
				elif event.button_index == controller_button("back"):
					return_to_menu.emit()
	elif event is InputEventJoypadMotion:
		var direction := controller_motion_direction(event)
		if direction != Vector2i.ZERO:
			navigate_campaign_selection(direction)

func handle_campaign_point(point: Vector2) -> void:
	if menu_rect.has_point(point):
		return_to_menu.emit()
		return
	if campaign_secondary_rect.has_point(point) and campaign_route.phase in [CampaignRoute.RoutePhase.NORMAL_END, CampaignRoute.RoutePhase.TRUE_END, CampaignRoute.RoutePhase.ENHANCED_BOSS, CampaignRoute.RoutePhase.SINGULARITY]:
		return_to_menu.emit()
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
	if campaign_copy_rect.has_point(point) and campaign_route.phase in [CampaignRoute.RoutePhase.NORMAL_END, CampaignRoute.RoutePhase.TRUE_END]:
		copy_campaign_result()
		return
	var index := campaign_index_at(point)
	if index >= 0:
		campaign_selected = index
		activate_campaign_selection()
		return
	if campaign_primary_rect.has_point(point) and campaign_route.phase in [CampaignRoute.RoutePhase.NORMAL_END, CampaignRoute.RoutePhase.TRUE_END, CampaignRoute.RoutePhase.ENHANCED_BOSS, CampaignRoute.RoutePhase.SINGULARITY]:
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
		CampaignRoute.RoutePhase.ENHANCED_BOSS, CampaignRoute.RoutePhase.SINGULARITY:
			launch_current_campaign_boss()
		CampaignRoute.RoutePhase.TRUE_END:
			reset_run()
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
	var hp := float(definition.get("hp", ChargeState.BOSS_MAX_HP))
	if enhanced:
		hp = float(definition.get("enhanced_hp", hp * 1.65))
	run.begin_campaign_boss(str(definition.id), hp, enhanced, singularity)
	show_message(loc("深層主獣との戦闘開始", "ABYSSAL BOSS ENGAGED"), 2.4)
	screen_flash = 0.8
	screen_shake = 0.35
	synth.play_chord([110.0, 146.83, 220.0], 0.55, -19.0)
	save_progress()
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
	synth.confirm()
	save_progress()
	return true

func complete_campaign_boss() -> bool:
	var defeated_definition := StageCatalog.boss(campaign_route.current_boss_id)
	if not defeated_definition.is_empty() and defeated_definition.has("core_id"):
		run.grant_boss_core(str(defeated_definition.core_id))
	if not campaign_route.defeat_current_boss():
		return false
	run.stage_phase = ChargeState.StagePhase.CLEAR
	screen_flash = 1.0
	screen_shake = 0.75
	synth.play_chord([130.81, 196.0, 261.63, 392.0, 523.25], 0.75, -17.0)
	record_campaign_result_if_needed()
	save_progress()
	return true

func campaign_ending_key() -> String:
	return "true" if campaign_route.phase == CampaignRoute.RoutePhase.TRUE_END else "normal"

func current_playtest_report() -> Dictionary:
	return run.build_playtest_report(campaign_route.snapshot(), campaign_ending_key())

func campaign_result_json() -> String:
	return JSON.stringify(current_playtest_report(), "  ")

func record_campaign_result_if_needed() -> bool:
	if campaign_route.phase not in [CampaignRoute.RoutePhase.NORMAL_END, CampaignRoute.RoutePhase.TRUE_END]:
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
	return "PROJECT CHARGE — %s\n%s %s | %s %s | %s %d/6 | %s %d/2\n%s %s | %s %d | %s %d | ID %s" % [
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
		KEY_ENTER, KEY_X:
			perform_charge()
		KEY_A:
			perform_charge()
		KEY_G:
			toggle_generation_mode()
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
		toggle_generation_mode()
	elif event.button_index == controller_button("menu"):
		open_gear_tree(selected_gear_index)
	elif event.button_index == controller_button("language"):
		toggle_language()
	elif event.button_index == controller_button("back"):
		return_to_menu.emit()

func handle_point(point: Vector2) -> void:
	if menu_rect.has_point(point):
		return_to_menu.emit()
	elif language_rect.has_point(point):
		toggle_language()
	elif reset_rect.has_point(point):
		request_reset()
	elif mode_toggle_rect.has_point(point):
		toggle_generation_mode()
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
			else:
				complete_stage_and_return_to_route()
		elif event.button_index == controller_button("language"):
			toggle_language()
		elif event.button_index == controller_button("back"):
			return_to_menu.emit()
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
	if menu_rect.has_point(point) or clear_menu_rect.has_point(point):
		return_to_menu.emit()
	elif language_rect.has_point(point):
		toggle_language()
	elif run.stage_phase == ChargeState.StagePhase.REWARD:
		for index in range(reward_rects.size()):
			if reward_rects[index].has_point(point):
				select_reward(index)
				return
	elif clear_retry_rect.has_point(point):
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
	synth.play_tone(146.83, 0.28, -17.0, 1)

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
	if persistence_enabled and save_manager != null:
		save_manager.save_bundle(run, campaign_route)

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
	selected_tree_tier = clampi(selected_tree_tier, 1, 3)
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
	selected_tree_tier = clampi(tier, 1, 3)
	controller_upgrade_selected = 0
	var label := loc("基礎機構", "FOUNDATION") if selected_tree_tier == 1 else loc("主獣オーバークロック", "BOSS OVERCLOCK") if selected_tree_tier == 2 else loc("六核特異改造", "SIX-CORE SINGULARITY")
	show_message("TIER %s // %s" % [roman_tier(selected_tree_tier), label], 1.2)
	synth.click()
	queue_redraw()

func roman_tier(tier: int) -> String:
	return "I" if tier == 1 else "II" if tier == 2 else "III"

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
		elif event.keycode == KEY_G:
			toggle_generation_mode()
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
			set_tree_tier(wrapi(selected_tree_tier - 2, 0, 3) + 1)
		elif event.keycode == KEY_X:
			set_tree_tier(selected_tree_tier % 3 + 1)
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
					toggle_generation_mode()
				elif event.button_index == controller_button("language"):
					set_tree_tier(selected_tree_tier % 3 + 1)
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
		var pitch := (420.0 if generating else 190.0) + float(mini(16, run.manual_streak)) * 12.0
		synth.play_tone(pitch * (1.5 if bool(result.critical) else 1.0), 0.045, -23.0, 3)
	if bool(result.critical):
		add_floating(target + Vector2(0, -62), loc("クリティカル", "CRITICAL"), Palette.AMBER, 18)
		screen_shake = maxf(screen_shake, 0.18)
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
	if bool(result.boss_defeated):
		handle_enemy_defeated()
	elif generating:
		show_message(loc("PURE CHARGE：ダメージ0 / CHARGE +%d / AUTO過給 ×%d" % [int(result.charge), run.auto_boost_stacks], "PURE CHARGE: 0 DAMAGE / +%d CHARGE / AUTO BOOST ×%d" % [int(result.charge), run.auto_boost_stacks]), 0.9)
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
	if campaign_route.phase == CampaignRoute.RoutePhase.STAGE:
		show_message(encounter_name() + loc("撃破 — 機械核を回収", " DEFEATED — CORE RECOVERED"), 3.0)
	else:
		complete_campaign_boss()
	screen_flash = 1.0
	screen_shake = 0.7
	synth.play_chord([196.0, 293.66, 392.0, 587.33], 0.6, -19.0)
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
			show_message(loc("CHARGEが足りません", "NOT ENOUGH CHARGE"), 1.1)
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
		synth.confirm()
	save_progress()
	return true

func toggle_generation_mode() -> bool:
	if not run.toggle_manual_mode():
		show_message(loc("発電心臓の『零出力発電』でPURE CHARGEを解禁", "UNLOCK ZERO-OUTPUT DRIVE IN THE DYNAMO TREE"), 2.0)
		synth.error()
		return false
	show_message(loc("手動モード：", "MANUAL MODE: ") + (loc("PURE CHARGE — ダメージ0 / 発電6倍", "PURE CHARGE — 0 DAMAGE / 6× GENERATION") if run.manual_mode == "generate" else loc("CHARGE ATTACK — 直接攻撃", "CHARGE ATTACK — DIRECT DAMAGE")), 2.0)
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
	if run.manual_inputs == 0:
		return loc("CHARGE ATTACKを押すと即ダメージ＋CHARGE獲得", "PRESS CHARGE ATTACK FOR INSTANT DAMAGE + CHARGE")
	if run.purchases == 0 and run.credits > 0:
		return loc("獲得したCHARGEで下の5ギアを開き、ツリーを強化", "OPEN ONE OF FIVE GEARS AND SPEND CHARGE IN ITS TREE")
	return current_rule_copy()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color("060b16"))
	draw_background()
	var shake_offset := Vector2.ZERO
	if screen_shake > 0.0:
		shake_offset = Vector2(sin(animation_time * 73.0), cos(animation_time * 91.0)) * screen_shake * 9.0
	draw_set_transform(shake_offset)
	draw_header()
	if campaign_screen_visible():
		draw_campaign_screen()
	else:
		draw_reactor_panel()
		draw_circuit_panel()
	draw_particles_and_text()
	draw_set_transform(Vector2.ZERO)
	if gear_tree_open:
		draw_gear_tree_overlay()
	if not campaign_screen_visible() and run.stage_phase in [ChargeState.StagePhase.REWARD, ChargeState.StagePhase.CLEAR]:
		draw_completion_overlay()
	if screen_flash > 0.0:
		var flash_color := Palette.CORAL if run.meltdowns > 0 and run.heat <= 35.0 and message_time > 1.0 else Palette.CYAN
		draw_rect(Rect2(Vector2.ZERO, VIEW), Palette.with_alpha(flash_color, screen_flash * 0.18))

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
		CampaignRoute.RoutePhase.TRUE_END:
			draw_campaign_ending(true)
		CampaignRoute.RoutePhase.ENHANCED_BOSS, CampaignRoute.RoutePhase.SINGULARITY:
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
	var accent := Color(str(definition.get("accent", "f5f0db")))
	var label := loc("真の地核機神", "TRUE WORLD ENGINE") if singularity else loc("強化深層主獣", "ENHANCED ABYSSAL BOSS")
	draw_string(DisplayFont, Vector2(0, 156), label, HORIZONTAL_ALIGNMENT_CENTER, 1280, 18, accent)
	draw_string(DisplayFont, Vector2(0, 220), str(definition.get("name_ja" if is_japanese else "name_en", campaign_route.current_boss_id)), HORIZONTAL_ALIGNMENT_CENTER, 1280, 38, Palette.PAPER)
	var center := Vector2(640, 340)
	for ring in range(5):
		draw_arc(center, 72 + ring * 22, -PI * 0.6 + animation_time * (0.15 + ring * 0.04) * (-1.0 if ring % 2 else 1.0), PI * 1.25 + animation_time * (0.15 + ring * 0.04) * (-1.0 if ring % 2 else 1.0), 48, Palette.with_alpha(accent, 0.8 - ring * 0.12), 4.0)
	var portrait: Texture2D = MechanicalBeastTextures.get(str(definition.id), grid_wraith_texture)
	draw_texture_rect(portrait, Rect2(center - Vector2(116, 116), Vector2(232, 232)), false, Color(0.96, 0.97, 1.0, 1.0))
	draw_string(Palette.UI_FONT, Vector2(350, 470), str(definition.get("rule_ja" if is_japanese else "rule_en", "")), HORIZONTAL_ALIGNMENT_CENTER, 580, 15, Palette.MUTED)
	draw_campaign_button(campaign_primary_rect, loc("地核決戦を開始", "ENGAGE THE WORLD ENGINE") if singularity else loc("強化ボス戦を開始", "ENGAGE ENHANCED BOSS"), accent, true)
	draw_campaign_button(campaign_secondary_rect, loc("ゲーム選択へ", "RETURN TO GAME LAB"), Palette.MUTED, false)

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
	draw_campaign_button(campaign_primary_rect, loc("新しいキャンペーン", "NEW CAMPAIGN") if true_end else loc("真ルートへ続く", "CONTINUE TRUE ROUTE"), accent, true)
	draw_campaign_button(campaign_secondary_rect, loc("ゲーム選択へ", "RETURN TO GAME LAB"), Palette.MUTED, false)

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
	draw_string(DisplayFont, Vector2(178, 34), "PROJECT CHARGE", HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(178, 60), campaign_header_context(), HORIZONTAL_ALIGNMENT_LEFT, 330, 13, Palette.MUTED)
	var accumulator_tint := Color(1.0, 1.0, 1.0, 0.94 + shard_pulse * 0.06)
	draw_texture_rect(ShardAccumulatorTexture, SHARD_ACCUMULATOR_RECT, false, accumulator_tint)
	if shard_pulse > 0.0:
		for ring in range(3):
			draw_arc(SHARD_SOCKET_CENTER, 23.0 + ring * 7.0 + (1.0 - shard_pulse) * 8.0, 0.0, TAU, 24, Palette.with_alpha(Palette.CYAN, shard_pulse * (0.5 - ring * 0.1)), 2.0)
	draw_texture_rect(energy_shard_texture, Rect2(SHARD_SOCKET_CENTER - Vector2(18, 18), Vector2(36, 36)), false)
	draw_string(Palette.UI_FONT, Vector2(606, 25), "CHARGE", HORIZONTAL_ALIGNMENT_CENTER, 94, 10, Palette.MUTED)
	draw_string(Palette.UI_FONT, Vector2(606, 56), format_number(run.credits), HORIZONTAL_ALIGNMENT_CENTER, 94, 22, Palette.AMBER)
	draw_string(Palette.UI_FONT, Vector2(752, 31), loc("総時間", "SESSION"), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Palette.MUTED)
	draw_string(Palette.UI_FONT, Vector2(752, 62), format_time(run.session_elapsed), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Palette.PAPER)
	draw_small_button(reset_rect, loc("R  もう一度", "R  CONFIRM") if reset_confirm_time > 0.0 else loc("R  初期化", "R  RESET"), Palette.CORAL)
	draw_small_button(music_rect, "M BGM" if music_enabled else "M OFF", Palette.MINT if music_enabled else Palette.CORAL)
	draw_small_button(language_rect, "日本語 / EN", Palette.MINT)
	draw_small_button(menu_rect, loc("ゲーム選択", "GAME LAB"), Palette.CYAN)

func campaign_header_context() -> String:
	if campaign_route == null:
		return loc("GENERATOR CORE・縦切り版", "GENERATOR CORE · VERTICAL SLICE")
	if campaign_route.phase in [CampaignRoute.RoutePhase.MAP, CampaignRoute.RoutePhase.TRUE_MAP]:
		return loc("深層討伐地図", "ABYSSAL HUNT MAP") + " · %d/6" % campaign_route.completed_stage_ids.size()
	if campaign_route.phase == CampaignRoute.RoutePhase.BOSS_SELECT:
		return loc("通常ボスを選択", "SELECT NORMAL BOSS")
	if campaign_route.phase in [CampaignRoute.RoutePhase.NORMAL_END, CampaignRoute.RoutePhase.TRUE_END]:
		return loc("討伐記録", "HUNT RECORD")
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
	draw_string(DisplayFont, charge_rect.position + Vector2(82, 39), loc("PURE CHARGE", "PURE CHARGE") if run.manual_mode == "generate" else loc("CHARGE攻撃", "CHARGE ATTACK"), HORIZONTAL_ALIGNMENT_CENTER, charge_rect.size.x - 88, 21, Palette.PAPER)
	draw_string(Palette.UI_FONT, charge_rect.position + Vector2(82, 66), loc("0ダメージ / 発電6倍 / AUTO過給", "0 DAMAGE / 6× GENERATION / AUTO BOOST") if run.manual_mode == "generate" else loc("1入力＝1打撃＋CHARGE", "ONE INPUT = ONE HIT + CHARGE"), HORIZONTAL_ALIGNMENT_CENTER, charge_rect.size.x - 88, 10, Palette.MUTED)
	var mode_available: bool = run.generation_mode_unlocked()
	var mode_color := Palette.MINT if mode_available else Palette.MUTED
	draw_machine_plate(mode_toggle_rect, Palette.with_alpha(mode_color, 0.16 if mode_available else 0.035), Palette.with_alpha(mode_color, 0.78 if mode_available else 0.25), 9.0, 1.0)
	draw_string(DisplayFont, mode_toggle_rect.position + Vector2(0, 27), loc("G  手動モード切替", "G  SWITCH MANUAL MODE") if mode_available else loc("発電ツリーでPURE CHARGE解禁", "UNLOCK PURE CHARGE IN DYNAMO TREE"), HORIZONTAL_ALIGNMENT_CENTER, mode_toggle_rect.size.x, 12, Palette.PAPER if mode_available else Palette.MUTED)
	var footer := Rect2(54, 649, 312, 31)
	draw_machine_plate(footer, Palette.with_alpha(Palette.INK, 0.72), Palette.with_alpha(Palette.CYAN, 0.18), 5.0, 1.0)
	draw_string(Palette.UI_FONT, Vector2(62, 662), tutorial_hint(), HORIZONTAL_ALIGNMENT_LEFT, 296, 9, Palette.AMBER if run.credits >= cheapest_upgrade_cost() else Palette.MUTED)
	draw_string(Palette.UI_FONT, Vector2(62, 676), loc("クリック %d  AUTO %d  臨界 %d", "CLICKS %d  AUTO %d  CRITS %d") % [run.manual_inputs, run.auto_hits, run.critical_hits], HORIZONTAL_ALIGNMENT_LEFT, 296, 8, Palette.MUTED)

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
	var generating: bool = run.manual_mode == "generate"
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
		state_label = "PURE CHARGE"
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
		var enemy_pulse := 0.96 + sin(animation_time * 2.4) * 0.035
		var hovered := enemy_click_rect.has_point(mouse_position)
		draw_circle(enemy_center, 116.0, Palette.with_alpha(Palette.CORAL, 0.05 + (0.05 if hovered else 0.0)))
		draw_arc(enemy_center, 120.0, -PI * 0.5, -PI * 0.5 + TAU * (1.0 - run.objective_ratio()), 56, Palette.with_alpha(Palette.CORAL, 0.48), 4.0)
		draw_texture_rect(enemy_texture, Rect2(enemy_center - Vector2(116, 116) + Vector2(0, sin(animation_time * 1.7) * 2.0), Vector2(232, 232)), false, Color(enemy_pulse, enemy_pulse, enemy_pulse, 1.0))
		if hovered:
			draw_string(DisplayFont, Vector2(enemy_click_rect.position.x, enemy_click_rect.end.y + 15), loc("クリックで攻撃", "CLICK TO ATTACK"), HORIZONTAL_ALIGNMENT_CENTER, enemy_click_rect.size.x, 13, Palette.AMBER)
		var tracer_progress := fmod(animation_time / maxf(0.15, run.auto_interval), 1.0)
		var tracer_start := Vector2(810, 350)
		var tracer_end := enemy_center - Vector2(88, 0)
		draw_line(tracer_start, tracer_end, Palette.with_alpha(Palette.VIOLET, 0.12), 2.0)
		draw_circle(tracer_start.lerp(tracer_end, tracer_progress), 4.0, Palette.VIOLET)

	draw_stage_rule_indicator()
	var status := message if message_time > 0.0 else tutorial_hint()
	draw_string(Palette.UI_FONT, Vector2(448, 455), status, HORIZONTAL_ALIGNMENT_CENTER, 770, 14, Palette.PAPER)
	draw_string(DisplayFont, Vector2(438, 482), loc("5ギア・66ノード — ギアを選んで専用ツリーを開く", "FIVE GEARS · 66 NODES — OPEN A GEAR'S DEDICATED TREE"), HORIZONTAL_ALIGNMENT_LEFT, 760, 11, Palette.MUTED)
	draw_string(DisplayFont, Vector2(1030, 482), "%d / %d" % [run.skill_points_bought(), run.total_possible_ranks()], HORIZONTAL_ALIGNMENT_RIGHT, 184, 11, Palette.AMBER if run.skill_points_bought() > 0 else Palette.MUTED)
	var rack_rect := Rect2(428, 488, 788, 178)
	draw_machine_plate(rack_rect, Palette.with_alpha(Palette.INK, 0.91), Palette.with_alpha(Palette.CYAN, 0.28), 12.0, 1.0)
	for rail in range(6):
		var rail_x := rack_rect.position.x + 18.0 + rail * 126.0
		draw_line(Vector2(rail_x, rack_rect.position.y + 8), Vector2(rail_x + 92, rack_rect.position.y + 8), Palette.with_alpha(Palette.CYAN, 0.11), 2.0)
		draw_circle(Vector2(rail_x, rack_rect.end.y - 9), 2.0, Palette.with_alpha(Palette.CYAN, 0.20))
	draw_gear_rack()

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
		draw_machine_plate(rect, Palette.with_alpha(Palette.INK, 0.92 if selected else 0.78), Palette.with_alpha(color, 1.0 if selected or hovered else 0.40), 9.0, 2.0 if selected or hovered else 1.0)
		draw_rect(Rect2(rect.position + Vector2(7, 7), Vector2(rect.size.x - 14, 4)), Palette.with_alpha(color, 0.75 if level > 0 else 0.25))
		draw_texture_rect(gear_texture, Rect2(rect.position + Vector2(9, 16), Vector2(44, 44)), false, Color(1.0, 1.0, 1.0, 0.98 if level > 0 or selected else 0.68))
		draw_string(Palette.UI_FONT, rect.position + Vector2(120, 25), "%02d" % (index + 1), HORIZONTAL_ALIGNMENT_RIGHT, 18, 9, color)
		draw_string(DisplayFont, rect.position + Vector2(54, 31), gear_name(gear), HORIZONTAL_ALIGNMENT_LEFT, 68, 11, Palette.PAPER)
		draw_string(Palette.UI_FONT, rect.position + Vector2(54, 52), str(gear.get("tag_ja" if is_japanese else "tag_en", "")), HORIZONTAL_ALIGNMENT_LEFT, 82, 8, Palette.MUTED)
		for tier in range(1, 4):
			var tier_level := 0
			for skill in GearCatalog.skills_for_gear_tier(str(gear.id), tier):
				tier_level += run.upgrade_level(str(skill.id))
			var tier_max := GearCatalog.max_ranks_for_gear_tier(str(gear.id), tier)
			var tier_ratio := float(tier_level) / float(maxi(1, tier_max))
			var tier_y := rect.position.y + 76 + (tier - 1) * 17
			var tier_unlocked: bool = tier <= run.technology_tier()
			draw_string(Palette.UI_FONT, Vector2(rect.position.x + 12, tier_y + 8), "T%s" % roman_tier(tier), HORIZONTAL_ALIGNMENT_LEFT, 20, 7, color if tier_unlocked else Palette.MUTED)
			draw_rect(Rect2(rect.position.x + 34, tier_y + 2, 96, 6), Palette.with_alpha(color, 0.10 if tier_unlocked else 0.035))
			draw_rect(Rect2(rect.position.x + 34, tier_y + 2, 96 * tier_ratio, 6), Palette.AMBER if tier_level >= tier_max else color)
		draw_string(DisplayFont, rect.position + Vector2(12, 137), "LV %d / %d" % [level, maximum], HORIZONTAL_ALIGNMENT_LEFT, 124, 11, color if level > 0 else Palette.MUTED)
		draw_string(Palette.UI_FONT, rect.position + Vector2(12, 154), loc("ツリーを開く", "OPEN TREE"), HORIZONTAL_ALIGNMENT_RIGHT, 124, 9, Palette.PAPER if hovered or selected else Palette.MUTED)

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
		draw_string(Palette.UI_FONT, tab.position + Vector2(179, 18), "%02d" % (index + 1), HORIZONTAL_ALIGNMENT_RIGHT, 14, 8, color)
		draw_string(DisplayFont, tab.position + Vector2(50, 23), gear_name(gear), HORIZONTAL_ALIGNMENT_LEFT, 126, 12, Palette.PAPER if selected else Palette.MUTED)
		draw_string(Palette.UI_FONT, tab.position + Vector2(50, 42), "LV %d / %d" % [run.gear_level(str(gear.id)), GearCatalog.max_ranks_for_gear(str(gear.id))], HORIZONTAL_ALIGNMENT_LEFT, 126, 9, color)
	draw_small_button(tree_close_rect, loc("閉じる", "CLOSE"), Palette.CORAL)

	var current_gear: Dictionary = GearCatalog.GEARS[selected_gear_index]
	var accent := Color(str(current_gear.accent))
	draw_string(DisplayFont, Vector2(66, 198), gear_name(current_gear), HORIZONTAL_ALIGNMENT_LEFT, 176, 18, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(250, 196), str(current_gear.get("desc_ja" if is_japanese else "desc_en", "")), HORIZONTAL_ALIGNMENT_LEFT, 272, 10, Palette.MUTED)
	for tier_index in range(3):
		var tier := tier_index + 1
		var tier_rect := tree_tier_rects[tier_index]
		var tier_selected := selected_tree_tier == tier
		var tier_unlocked: bool = tier <= run.technology_tier()
		var tier_color := accent if tier_unlocked else Palette.MUTED
		draw_machine_plate(tier_rect, Palette.with_alpha(tier_color, 0.24 if tier_selected else 0.045), Palette.with_alpha(tier_color, 1.0 if tier_selected else 0.30), 6.0, 2.0 if tier_selected else 1.0)
		draw_string(DisplayFont, tier_rect.position + Vector2(0, 22), "TIER %s" % roman_tier(tier), HORIZONTAL_ALIGNMENT_CENTER, tier_rect.size.x, 10, Palette.PAPER if tier_selected else tier_color)
		if not tier_unlocked:
			draw_string(Palette.UI_FONT, tier_rect.position + Vector2(0, 31), "LOCK", HORIZONTAL_ALIGNMENT_CENTER, tier_rect.size.x, 6, Palette.CORAL)
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
	var border := Palette.AMBER if level > 0 else accent if unlocked else Palette.MUTED
	draw_machine_plate(rect, Palette.with_alpha(Palette.INK, 0.96 if selected else 0.86), Palette.with_alpha(border, 1.0 if selected else 0.62 if level > 0 else 0.28), 10.0, 3.0 if selected else 1.0)
	draw_rect(Rect2(rect.position + Vector2(7, 7), Vector2(5, rect.size.y - 14)), Palette.with_alpha(border, 0.9 if level > 0 or selected else 0.2))
	var copy := skill_copy(definition)
	draw_string(DisplayFont, rect.position + Vector2(20, 25), str(copy.title), HORIZONTAL_ALIGNMENT_LEFT, 184, 12, Palette.PAPER if unlocked else Palette.MUTED)
	draw_string(Palette.UI_FONT, rect.position + Vector2(20, 47), "LV %d / %d" % [level, maximum], HORIZONTAL_ALIGNMENT_LEFT, 90, 10, border)
	if maxed:
		draw_string(DisplayFont, rect.position + Vector2(108, 48), "MAX", HORIZONTAL_ALIGNMENT_RIGHT, 88, 11, Palette.MINT)
	elif not unlocked:
		draw_string(DisplayFont, rect.position + Vector2(108, 48), "LOCK", HORIZONTAL_ALIGNMENT_RIGHT, 88, 10, Palette.CORAL)
	else:
		draw_string(Palette.UI_FONT, rect.position + Vector2(108, 48), "%d CHARGE" % run.upgrade_cost(id), HORIZONTAL_ALIGNMENT_RIGHT, 88, 10, Palette.AMBER if affordable else Palette.MUTED)
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
	var gear_texture: Texture2D = GearTextures.get(str(definition.gear))
	draw_texture_rect(gear_texture, Rect2(1114, 194, 78, 78), false, Color(1.0, 1.0, 1.0, 0.88))
	draw_string(Palette.UI_FONT, Vector2(842, 214), str(GearCatalog.gear(str(definition.gear)).get("tag_ja" if is_japanese else "tag_en", "")), HORIZONTAL_ALIGNMENT_LEFT, 340, 11, accent)
	draw_string(DisplayFont, Vector2(842, 248), str(copy.title), HORIZONTAL_ALIGNMENT_LEFT, 262, 22, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(842, 280), str(copy.desc), HORIZONTAL_ALIGNMENT_LEFT, 340, 13, Palette.MUTED)
	draw_line(Vector2(842, 300), Vector2(1192, 300), Palette.with_alpha(accent, 0.22), 1.0)
	draw_string(Palette.UI_FONT, Vector2(842, 328), loc("現在ランク", "CURRENT RANK"), HORIZONTAL_ALIGNMENT_LEFT, 160, 11, Palette.MUTED)
	draw_string(DisplayFont, Vector2(1010, 330), "%d / %d" % [run.upgrade_level(id), run.skill_max_rank(id)], HORIZONTAL_ALIGNMENT_RIGHT, 182, 18, accent)
	draw_tree_gear_stats(str(definition.gear), Vector2(842, 354), accent)
	var lock_reason: String = run.skill_lock_reason(id)
	if not lock_reason.is_empty():
		draw_string(Palette.UI_FONT, Vector2(842, 510), skill_lock_text(id), HORIZONTAL_ALIGNMENT_LEFT, 350, 12, Palette.CORAL)
	elif run.upgrade_level(id) >= run.skill_max_rank(id):
		draw_string(Palette.UI_FONT, Vector2(842, 510), loc("このノードは最大強化済み", "THIS NODE IS FULLY UPGRADED"), HORIZONTAL_ALIGNMENT_LEFT, 350, 12, Palette.MINT)
	else:
		draw_string(Palette.UI_FONT, Vector2(842, 510), loc("次ランク費用：%d CHARGE" % run.upgrade_cost(id), "NEXT RANK: %d CHARGE" % run.upgrade_cost(id)), HORIZONTAL_ALIGNMENT_LEFT, 350, 12, Palette.AMBER if run.can_purchase(id) else Palette.MUTED)
	var purchasable: bool = run.can_purchase(id)
	draw_campaign_button(tree_purchase_rect, loc("購入 / 強化", "PURCHASE / UPGRADE") if run.upgrade_level(id) < run.skill_max_rank(id) else "MAX", accent if purchasable else Palette.MUTED, purchasable)
	if campaign_route.phase in [CampaignRoute.RoutePhase.MAP, CampaignRoute.RoutePhase.TRUE_MAP]:
		draw_campaign_button(tree_respec_rect, loc("無料リスペック", "FREE RESPEC"), Palette.MINT, false)
	else:
		draw_string(Palette.UI_FONT, Vector2(918, 648), loc("AUTO砲はツリー表示中も戦闘を継続", "AUTO FIRE CONTINUES WHILE THIS TREE IS OPEN"), HORIZONTAL_ALIGNMENT_CENTER, 286, 10, Palette.VIOLET)
	draw_string(Palette.UI_FONT, Vector2(816, 690), loc("方向キー：選択　ENTER/A：購入　Q/E：ギア　Z/X・Y：TIER", "D-PAD: SELECT · ENTER/A: BUY · Q/E: GEAR · Z/X OR Y: TIER"), HORIZONTAL_ALIGNMENT_CENTER, 408, 9, Palette.MUTED)

func draw_tree_gear_stats(gear_id: String, origin: Vector2, accent: Color) -> void:
	var lines: Array[String] = []
	match gear_id:
		"striker":
			lines = [loc("クリック威力  %s" % format_number(run.manual_damage), "CLICK POWER  %s" % format_number(run.manual_damage)), loc("臨界率  %.0f%%" % (run.critical_chance * 100.0), "CRIT CHANCE  %.0f%%" % (run.critical_chance * 100.0)), loc("連打上限  %d" % run.combo_cap, "COMBO CAP  %d" % run.combo_cap)]
		"dynamo":
			lines = [loc("手動発電  %.2f" % run.charge_per_click, "MANUAL GEN  %.2f" % run.charge_per_click), loc("AUTO発電  %.2f/弾" % run.auto_charge_per_shot, "AUTO GEN  %.2f/SHOT" % run.auto_charge_per_shot), loc("手動モード  %s" % run.manual_mode.to_upper(), "MANUAL MODE  %s" % run.manual_mode.to_upper())]
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
	if run.upgrade_level("gatling_protocol") > 0:
		return loc("ガトリング", "GATLING")
	if run.upgrade_level("rail_protocol") > 0:
		return loc("レール砲", "RAIL")
	return loc("標準砲", "STANDARD")

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
	draw_string(Palette.UI_FONT, Vector2(446, 147), phase, HORIZONTAL_ALIGNMENT_LEFT, 360, 10, Palette.MUTED)
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
		draw_string(Palette.UI_FONT, Vector2(824, 158), "%s / %s HP" % [format_integer(run.boss_hp), format_integer(run.boss_max_hp)], HORIZONTAL_ALIGNMENT_CENTER, 390, 9, Palette.PAPER)
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
	draw_small_button(menu_rect, loc("ゲーム選択", "GAME LAB"), Palette.CYAN)

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
	draw_string(DisplayFont, Vector2(0, 168), loc("機械魔獣 討伐", "MECHANICAL BEAST DEFEATED") if is_stage_hunt else loc("深層主獣 討伐", "ABYSSAL BOSS DEFEATED"), HORIZONTAL_ALIGNMENT_CENTER, 1280, 34, Palette.AMBER)
	var definition := current_stage_definition()
	draw_string(DisplayFont, Vector2(0, 205), stage_name(definition) if not definition.is_empty() else encounter_name(), HORIZONTAL_ALIGNMENT_CENTER, 1280, 18, Palette.PAPER)
	var core_name := loc("主獣核（自動統合）", "BOSS CORE — AUTO INTEGRATED")
	if not definition.is_empty():
		core_name = str(definition.get("core_name_ja" if is_japanese else "core_name_en", "CORE"))
	var stats := [
		[loc("クリアタイム", "CLEAR TIME"), format_time(run.stage_clear_time)],
		[loc("手動 / AUTO命中", "MANUAL / AUTO HITS"), "%d / %d" % [run.manual_inputs, run.auto_hits]],
		[loc("最大打撃", "PEAK HIT"), format_number(run.highest_output)],
		[loc("累計CHARGE", "TOTAL CHARGE"), format_number(run.lifetime_charge)],
		[loc("強化レベル合計", "TOTAL UPGRADE LEVELS"), str(run.skill_points_bought())],
		[loc("回収機械核", "RECOVERED CORE"), core_name],
	]
	for index in range(stats.size()):
		var y := 250 + index * 42
		draw_string(Palette.UI_FONT, Vector2(340, y), str(stats[index][0]), HORIZONTAL_ALIGNMENT_LEFT, 250, 14, Palette.MUTED)
		draw_string(Palette.UI_FONT, Vector2(610, y), str(stats[index][1]), HORIZONTAL_ALIGNMENT_RIGHT, 300, 17, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(0, 520), loc("核は自動で統合され、以後のすべての戦闘で効果を発揮する", "THE CORE IS AUTOMATICALLY INTEGRATED FOR EVERY FUTURE BATTLE"), HORIZONTAL_ALIGNMENT_CENTER, 1280, 14, Palette.CYAN)
	draw_machine_plate(clear_retry_rect, Palette.AMBER, Palette.PAPER, 10.0, 2.0)
	draw_string(DisplayFont, clear_retry_rect.position + Vector2(0, 34), loc("討伐地図へ", "HUNT MAP"), HORIZONTAL_ALIGNMENT_CENTER, clear_retry_rect.size.x, 16, Palette.INK)
	draw_machine_plate(clear_menu_rect, Palette.PANEL_2, Palette.CYAN, 10.0, 1.0)
	draw_string(Palette.UI_FONT, clear_menu_rect.position + Vector2(0, 34), loc("ゲーム選択", "GAME LAB"), HORIZONTAL_ALIGNMENT_CENTER, clear_menu_rect.size.x, 16, Palette.PAPER)

func boss_integrity_label() -> String:
	if run.singularity_boss:
		return loc("事象安定度", "EVENT STABILITY")
	if run.current_boss_id == "thermal_titan":
		return loc("炉心装甲", "CORE ARMOR")
	if run.current_boss_id == "grid_leech":
		return loc("吸収器耐久", "SIPHON INTEGRITY")
	return loc("機械魔獣耐久", "MECHANICAL BEAST HP")
