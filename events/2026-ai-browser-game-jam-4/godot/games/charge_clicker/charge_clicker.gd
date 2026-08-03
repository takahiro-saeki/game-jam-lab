extends Node2D

signal return_to_menu
signal language_changed(is_japanese: bool)

const Palette = preload("res://shared/palette.gd")
const Synth = preload("res://shared/synth.gd")
const ControllerConfig = preload("res://shared/controller_bindings.gd")
const ChargeState = preload("res://games/charge_clicker/charge_state.gd")
const ChargeSave = preload("res://games/charge_clicker/charge_save.gd")
const CampaignRoute = preload("res://games/charge_clicker/charge_route.gd")
const StageCatalog = preload("res://games/charge_clicker/stage_catalog.gd")
const DisplayFont = preload("res://assets/fonts/DotGothic16-Regular.ttf")
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
const UpgradeRackTexture: Texture2D = preload("res://assets/charge_clicker/pixellab/source/ui/upgrade-rack-switchboard-a.png")
const ControlConsoleKitTexture: Texture2D = preload("res://assets/charge_clicker/pixellab/source/ui/control-kit-switchboard-a.png")
const WraithGaugeTexture: Texture2D = preload("res://assets/charge_clicker/pixellab/source/ui/wraith-gauge-switchboard-a.png")
const ShardAccumulatorTexture: Texture2D = preload("res://assets/charge_clicker/pixellab/source/ui/shard-accumulator-corrupted-b.png")

const VIEW := Vector2(1280, 720)
const REACTOR_CENTER := Vector2(212, 286)
const SHARD_ACCUMULATOR_RECT := Rect2(524, 5, 196, 78)
const SHARD_SOCKET_CENTER := Vector2(575, 44)
const CONTROL_CHARGE_REGION := Rect2(0, 0, 104, 128)
const CONTROL_DISCHARGE_REGION := Rect2(104, 0, 174, 128)
const CONTROL_AUTO_REGION := Rect2(278, 0, 106, 128)
const UPGRADE_RACK_CENTER_REGION := Rect2(76, 4, 232, 120)

var synth: JamSynth
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
var auto_effect_timer := 0.0
var autosave_timer := 0.0
var reward_selected := 0
var controller_upgrade_selected := 0
var controller_axis_latch := Vector2i.ZERO
var campaign_selected := 0
var campaign_hovered := -1

var charge_rect := Rect2(70, 502, 284, 108)
var discharge_rect := Rect2(452, 340, 510, 76)
var auto_rect := Rect2(980, 340, 220, 76)
var menu_rect := Rect2(1102, 22, 138, 42)
var language_rect := Rect2(932, 22, 152, 42)
var reset_rect := Rect2(34, 22, 126, 42)
var upgrade_rects: Array[Rect2] = []
var reward_rects: Array[Rect2] = [Rect2(154, 300, 300, 220), Rect2(490, 300, 300, 220), Rect2(826, 300, 300, 220)]
var clear_retry_rect := Rect2(382, 554, 236, 54)
var clear_menu_rect := Rect2(662, 554, 236, 54)
var stage_map_rects: Array[Rect2] = []
var boss_select_rects: Array[Rect2] = [Rect2(126, 224, 470, 292), Rect2(684, 224, 470, 292)]
var campaign_primary_rect := Rect2(450, 558, 380, 58)
var campaign_secondary_rect := Rect2(450, 632, 380, 48)
var campaign_copy_rect := Rect2(800, 232, 186, 38)

func _ready() -> void:
	apply_web_art_preview()
	synth = Synth.new()
	add_child(synth)
	run = ChargeState.new()
	campaign_route = CampaignRoute.new()
	save_manager = ChargeSave.new()
	for row in range(2):
		for column in range(4):
			upgrade_rects.append(Rect2(438 + column * 194, 494 + row * 94, 184, 84))
	for row in range(2):
		for column in range(3):
			stage_map_rects.append(Rect2(62 + column * 404, 180 + row * 208, 348, 176))
	var resumed: bool = persistence_enabled and save_manager.load_bundle_into(run, campaign_route)
	if persistence_enabled and not resumed and save_manager.load_into(run):
		resumed = true
		migrate_vertical_slice_save()
	if art_preview_enabled:
		if campaign_preview_screen.is_empty():
			campaign_route.reset()
			campaign_route.select_stage("generator_core")
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
		show_message(loc("回路マップから最初の復旧先を選択", "SELECT YOUR FIRST CIRCUIT FROM THE MAP"), 5.0)
	queue_redraw()

func migrate_vertical_slice_save() -> void:
	if run.stage_phase == ChargeState.StagePhase.CLEAR and not run.reward_id.is_empty():
		run.grant_stage_circuit("flywheel")
		campaign_route.adopt_vertical_slice(run.reward_id)
	else:
		campaign_route.select_stage("generator_core")

func apply_web_art_preview() -> void:
	if not OS.has_feature("web"):
		return
	var window = JavaScriptBridge.get_interface("window")
	if window == null:
		return
	var values := parse_query_string(str(window.location.search))
	campaign_preview_screen = str(values.get("campaign_preview", ""))
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
			for id in ["generator_core", "capacitor_vault", "thermal_plant"]:
				campaign_route.select_stage(id)
				campaign_route.complete_current_stage(str(StageCatalog.stage(id).reward_id))
			campaign_selected = 0
		"normal_end":
			for id in ["generator_core", "capacitor_vault", "thermal_plant"]:
				campaign_route.select_stage(id)
				campaign_route.complete_current_stage(str(StageCatalog.stage(id).reward_id))
			campaign_route.choose_first_boss("grid_leech")
			campaign_route.defeat_current_boss()
		"true_map":
			for id in ["generator_core", "capacitor_vault", "thermal_plant"]:
				campaign_route.select_stage(id)
				campaign_route.complete_current_stage(str(StageCatalog.stage(id).reward_id))
			campaign_route.choose_first_boss("grid_leech")
			campaign_route.defeat_current_boss()
			campaign_route.continue_true_route()
		_:
			campaign_selected = 0

func configure_art_preview_state() -> void:
	run.stage_phase = ChargeState.StagePhase.BOSS
	run.boss_hp = ChargeState.BOSS_MAX_HP * 0.62
	run.boss_attack_timer = 5.8
	run.credits = 128
	run.heat = 46.0
	run.overcharge = 28.0
	for index in range(run.cells.size()):
		run.cells[index] = run.capacity * [0.94, 0.78, 0.61, 0.45, 0.28, 0.12][index]

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
	if screen_shake > 0.0:
		screen_shake = maxf(0.0, screen_shake - delta)
	if screen_flash > 0.0:
		screen_flash = maxf(0.0, screen_flash - delta * 2.4)
	if discharge_wave > 0.0:
		discharge_wave = maxf(0.0, discharge_wave - delta * 1.4)
	if shard_pulse > 0.0:
		shard_pulse = maxf(0.0, shard_pulse - delta * 1.7)
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
	if not campaign_gameplay_active():
		if autosave_timer <= 0.0:
			autosave_timer = 5.0
			save_progress()
		update_effects(delta)
		queue_redraw()
		return

	if charge_held:
		charge_repeat_timer -= delta
		while charge_repeat_timer <= 0.0:
			perform_charge(true)
			charge_repeat_timer += 0.145

	var tick_result: Dictionary = run.tick(delta, charge_held)
	if bool(tick_result.became_full):
		show_full_ready()
	if bool(tick_result.meltdown):
		show_meltdown(float(tick_result.lost))
	if bool(tick_result.boss_warning):
		show_boss_warning()
	if bool(tick_result.boss_drain):
		show_boss_drain(int(tick_result.drain_cell), float(tick_result.drained), float(tick_result.boss_healed))
	if bool(tick_result.thermal_spike):
		show_thermal_spike(float(tick_result.boss_healed))
	if float(tick_result.auto_added) > 0.0:
		auto_effect_timer -= delta
		if auto_effect_timer <= 0.0:
			auto_effect_timer = 0.16
			var target_index: int = maxi(0, run.next_cell_index())
			spawn_sparks(Vector2(502 + target_index * 125, 244), Palette.VIOLET, 2, 55.0)
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
	if campaign_screen_visible():
		handle_campaign_input(event)
		return
	if run.stage_phase in [ChargeState.StagePhase.REWARD, ChargeState.StagePhase.CLEAR]:
		handle_completion_input(event)
		return
	if event is InputEventMouseMotion:
		mouse_position = event.position
		hover_upgrade = upgrade_at(event.position)
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
		perform_discharge()
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
				show_message(loc("真ルート解放 — 残り3回路を復旧せよ", "TRUE ROUTE OPEN — RESTORE THE REMAINING CIRCUITS"), 3.0)
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
		show_message(loc("この回路は復旧済み", "THIS CIRCUIT IS ALREADY RESTORED"), 1.4)
		synth.error()
		return false
	run.begin_stage(id, str(definition.build_tag), float(definition.restore_target), float(definition.climax_hp))
	reward_selected = 0
	show_message(loc("回路接続：", "CIRCUIT LINKED: ") + stage_name(definition), 2.2)
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
	show_message(loc("主敵性回路、接続", "HOSTILE MASTER CIRCUIT CONNECTED"), 2.4)
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
		run.grant_stage_circuit(str(completed_definition.reward_id))
	if not campaign_route.complete_current_stage(run.reward_id):
		return false
	campaign_selected = 0 if campaign_route.phase == CampaignRoute.RoutePhase.BOSS_SELECT else first_available_stage_index()
	show_message(loc("回路をマップへ登録", "CIRCUIT REGISTERED TO THE GRID"), 2.0)
	synth.confirm()
	save_progress()
	return true

func complete_campaign_boss() -> bool:
	if not campaign_route.defeat_current_boss():
		return false
	run.stage_phase = ChargeState.StagePhase.CLEAR
	screen_flash = 1.0
	screen_shake = 0.75
	synth.play_chord([130.81, 196.0, 261.63, 392.0, 523.25], 0.75, -17.0)
	save_progress()
	return true

func campaign_result_text() -> String:
	var ending := loc("通常復旧", "NORMAL RESTORATION") if campaign_route.phase == CampaignRoute.RoutePhase.NORMAL_END else loc("完全復旧", "TOTAL RESTORATION")
	var synergy_labels: Array[String] = []
	for id in run.active_synergies():
		synergy_labels.append(active_synergy_label(id))
	var synergy_text := loc("なし", "NONE") if synergy_labels.is_empty() else " / ".join(PackedStringArray(synergy_labels))
	return "PROJECT CHARGE — %s\n%s %s | %s %d/6 | %s %d/2\n%s %s | %s %s | %s %d" % [
		ending,
		loc("時間", "TIME"), format_time(run.elapsed),
		loc("回路", "CIRCUITS"), campaign_route.completed_stage_ids.size(),
		loc("ボス", "BOSSES"), campaign_route.defeated_boss_ids.size(),
		loc("最大放電", "PEAK"), format_number(run.highest_output),
		loc("シナジー", "SYNERGIES"), synergy_text,
		loc("メルトダウン", "MELTDOWNS"), run.meltdowns,
	]

func copy_campaign_result() -> void:
	result_copy_succeeded = set_clipboard_text(campaign_result_text())
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
			perform_discharge()
		KEY_A:
			toggle_auto()
		KEY_L:
			toggle_language()
		KEY_R:
			request_reset()
		KEY_1, KEY_KP_1:
			try_purchase(0)
		KEY_2, KEY_KP_2:
			try_purchase(1)
		KEY_3, KEY_KP_3:
			try_purchase(2)
		KEY_4, KEY_KP_4:
			try_purchase(3)
		KEY_5, KEY_KP_5:
			try_purchase(4)
		KEY_6, KEY_KP_6:
			try_purchase(5)
		KEY_7, KEY_KP_7:
			try_purchase(6)
		KEY_8, KEY_KP_8:
			try_purchase(7)

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
		perform_discharge()
	elif event.button_index == controller_button("combat_action"):
		toggle_auto()
	elif event.button_index == controller_button("menu"):
		try_purchase(controller_upgrade_selected)
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
	elif discharge_rect.has_point(point):
		perform_discharge()
	elif auto_rect.has_point(point):
		toggle_auto()
	else:
		var index := upgrade_at(point)
		if index >= 0:
			try_purchase(index)

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
	var target := Vector2(505 + maxi(0, cell_index) * 125, 245)
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
	var column := controller_upgrade_selected % 4
	var row := controller_upgrade_selected / 4
	column = wrapi(column + direction.x, 0, 4)
	row = wrapi(row + direction.y, 0, 2)
	controller_upgrade_selected = row * 4 + column
	hover_upgrade = controller_upgrade_selected
	var copy := upgrade_copy(controller_upgrade_selected)
	show_message(loc("選択：", "SELECTED: ") + str(copy.title) + loc("　STARTで購入", "  ·  START TO BUY"), 1.4)
	synth.click()
	queue_redraw()

func begin_charge() -> void:
	if charge_held or run.stage_phase in [ChargeState.StagePhase.REWARD, ChargeState.StagePhase.CLEAR]:
		return
	charge_held = true
	charge_repeat_timer = 0.145
	perform_charge()

func end_charge() -> void:
	charge_held = false
	charge_repeat_timer = 0.0

func perform_charge(play_sound: bool = true, critical_mode: int = -1) -> Dictionary:
	if run.stage_phase in [ChargeState.StagePhase.REWARD, ChargeState.StagePhase.CLEAR]:
		return {"critical": false, "became_full": false, "meltdown": false, "lost": 0.0}
	var before_index: int = run.next_cell_index()
	var result: Dictionary = run.manual_charge(critical_mode)
	var target_index: int = before_index if before_index >= 0 else 5
	var target := Vector2(502 + target_index * 125, 244)
	spawn_sparks(REACTOR_CENTER, Palette.AMBER if bool(result.critical) else Palette.CYAN, 4 if bool(result.critical) else 2, 105.0)
	particles.append({"pos": REACTOR_CENTER, "velocity": (target - REACTOR_CENTER) * 2.8, "life": 0.24, "max_life": 0.24, "color": Palette.PAPER if bool(result.critical) else Palette.CYAN, "size": 4.0})
	if play_sound:
		var pitch := 205.0 + float(run.filled_cells()) * 54.0 + float(run.manual_streak) * 7.0
		synth.play_tone(pitch * (1.45 if bool(result.critical) else 1.0), 0.05, -23.0, 3)
	if bool(result.critical):
		add_floating(REACTOR_CENTER + Vector2(0, -88), loc("クリティカル ×2", "CRITICAL ×2"), Palette.AMBER, 18)
	if bool(result.became_full):
		show_full_ready()
	if bool(result.meltdown):
		show_meltdown(float(result.lost))
	return result

func perform_discharge(play_sound: bool = true, critical_mode: int = -1) -> Dictionary:
	if run.stage_phase in [ChargeState.StagePhase.REWARD, ChargeState.StagePhase.CLEAR]:
		return {"valid": false, "output": 0.0, "credits": 0, "super": false, "critical": false}
	var result: Dictionary = run.discharge(critical_mode)
	if not bool(result.valid):
		show_message(loc("先にエネルギーを充電しよう", "CHARGE SOME ENERGY FIRST"), 1.2)
		if play_sound:
			synth.error()
		return result
	end_charge()
	discharge_wave = 1.0
	screen_flash = 0.8 if bool(result.super) else 0.38
	screen_shake = 0.48 if bool(result.super) else 0.2
	var color := Palette.AMBER if bool(result.super) else Palette.CYAN
	spawn_sparks(Vector2(720, 260), color, 36 if bool(result.super) else 18, 260.0)
	spawn_resource_flow(discharge_rect.get_center(), SHARD_SOCKET_CENTER, color, 8 if bool(result.super) else 5)
	shard_pulse = 1.0
	add_floating(Vector2(720, 285), "%s OUTPUT" % format_number(float(result.output)), color, 30 if bool(result.super) else 24)
	var stage_result: Dictionary = run.apply_output(float(result.output), bool(result.super))
	result.stage = stage_result
	if bool(stage_result.boss_started):
		show_message(loc("復旧完了 — ", "RESTORATION COMPLETE — ") + encounter_name() + loc("が侵入！", " INTRUDES!"), 3.0)
		screen_flash = 1.0
		screen_shake = 0.65
		spawn_sparks(Vector2(815, 130), Palette.CORAL, 34, 260.0)
	elif bool(stage_result.boss_defeated):
		end_charge()
		if campaign_route.phase == CampaignRoute.RoutePhase.STAGE:
			show_message(encounter_name() + loc("撃破 — 回路報酬を選択", " DEFEATED — SELECT A CIRCUIT REWARD"), 3.0)
		else:
			complete_campaign_boss()
		screen_flash = 1.0
		screen_shake = 0.7
		synth.play_chord([196.0, 293.66, 392.0, 587.33], 0.6, -19.0)
	elif bool(stage_result.interrupt):
		show_message(loc("吸収を中断！ 超放電ダメージ×1.35", "DRAIN INTERRUPTED! SUPER DAMAGE ×1.35"), 2.0)
		add_floating(Vector2(815, 136), loc("中断", "INTERRUPT"), Palette.MINT, 22)
	elif run.stage_phase == ChargeState.StagePhase.BOSS:
		show_message(loc("%sへ %s ダメージ" % [encounter_name(), format_number(float(stage_result.applied))], "%s DAMAGE TO %s" % [format_number(float(stage_result.applied)), encounter_name()]), 1.4)
	elif bool(result.super):
		show_message(loc("SUPER DISCHARGE！ 復旧出力 +%s" % format_number(float(stage_result.applied)), "SUPER DISCHARGE! +%s RESTORATION" % format_number(float(stage_result.applied))), 2.0)
	if bool(result.super):
		if play_sound:
			synth.play_chord([130.81, 261.63, 392.0, 659.25], 0.38, -19.0)
	else:
		if run.stage_phase == ChargeState.StagePhase.RESTORE:
			show_message(loc("部分放電 — 復旧出力 +%s" % format_number(float(stage_result.applied)), "PARTIAL DISCHARGE — +%s RESTORATION" % format_number(float(stage_result.applied))), 1.5)
		if play_sound:
			synth.play_chord([220.0, 329.63, 440.0], 0.2, -23.0)
	save_progress()
	return result

func toggle_auto(play_sound: bool = true) -> bool:
	var enabled: bool = run.toggle_auto()
	show_message(loc("AUTO充電：ON", "AUTO CHARGE: ON") if enabled else loc("AUTO充電：OFF", "AUTO CHARGE: OFF"), 1.2)
	if play_sound:
		synth.play_tone(523.25 if enabled else 261.63, 0.1, -22.0, 3)
	save_progress()
	return enabled

func try_purchase(index: int, play_sound: bool = true) -> bool:
	if index < 0 or index >= ChargeState.UPGRADE_DEFINITIONS.size():
		return false
	var id := str(ChargeState.UPGRADE_DEFINITIONS[index].id)
	var synergy_count_before: int = run.active_synergies().size()
	if not run.purchase_upgrade(id):
		show_message(loc("エネルギー片が足りません", "NOT ENOUGH ENERGY SHARDS"), 1.1)
		if play_sound:
			synth.error()
			return false
	var copy := upgrade_copy(index)
	var synergy_count_after: int = run.active_synergies().size()
	if synergy_count_after > synergy_count_before:
		show_message(loc("シナジー起動：", "SYNERGY ONLINE: ") + active_synergy_label(run.active_synergies()[-1]), 2.4)
	else:
		show_message(loc("強化完了：", "UPGRADED: ") + str(copy.title), 1.4)
	spawn_sparks(upgrade_rects[index].get_center(), upgrade_color(index), 12, 125.0)
	spawn_resource_flow(SHARD_SOCKET_CENTER, upgrade_rects[index].get_center(), upgrade_color(index), 5)
	shard_pulse = 0.75
	if play_sound:
		synth.confirm()
	save_progress()
	return true

func show_full_ready() -> void:
	screen_flash = maxf(screen_flash, 0.3)
	show_message(loc("6セル同期完了 — 放電するか、さらに過充電するか", "SIX CELLS SYNCED — DISCHARGE OR RISK OVERCHARGE"), 2.4)
	spawn_sparks(Vector2(815, 245), Palette.AMBER, 20, 145.0)
	synth.play_chord([261.63, 392.0, 523.25], 0.24, -22.0)

func show_meltdown(lost: float) -> void:
	end_charge()
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

func encounter_name() -> String:
	var boss_definition := StageCatalog.boss(run.current_boss_id)
	if not boss_definition.is_empty():
		return str(boss_definition.get("name_ja" if is_japanese else "name_en", run.current_boss_id))
	var names := {
		"grid_wraith": ["グリッド・レイス", "GRID WRAITH"],
		"vault_lock": ["ヴォルト・ロック", "VAULT LOCK"],
		"thermal_runaway": ["サーマル・ランナウェイ", "THERMAL RUNAWAY"],
		"relay_storm": ["リレー・ストーム", "RELAY STORM"],
		"rogue_foreman": ["ローグ・フォアマン", "ROGUE FOREMAN"],
		"probability_break": ["プロバビリティ・ブレイク", "PROBABILITY BREAK"],
	}
	var copy: Array = names.get(run.current_boss_id, ["敵性回路", "HOSTILE CIRCUIT"])
	return str(copy[0] if is_japanese else copy[1])

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
	var labels := {
		"flywheel": ["運動フライホイール", "KINETIC FLYWHEEL"],
		"deep_bank": ["深層蓄電庫", "DEEP BANK"],
		"redline_loop": ["赤熱循環路", "REDLINE LOOP"],
		"cascade_bus": ["連鎖バス", "CASCADE BUS"],
		"swarm_clock": ["群制御クロック", "SWARM CLOCK"],
		"loaded_dice": ["荷電ダイス", "LOADED DICE"],
	}
	var copy: Array = labels.get(id, [id, id.to_upper()])
	return str(copy[0] if is_japanese else copy[1])

func current_rule_copy() -> String:
	if run.singularity_boss:
		return loc("三相試験 %d/3：%s" % [run.singularity_phase, ["", "6セル同期", "高熱制御", "臨界放電"][run.singularity_phase]], "TRIAL %d/3: %s" % [run.singularity_phase, ["", "SIX-CELL SYNC", "THERMAL CONTROL", "CRITICAL DISCHARGE"][run.singularity_phase]])
	if run.current_boss_id == "thermal_titan":
		return loc("高熱時のみ弱点露出 — 68%以上で放電", "WEAK AT HIGH HEAT — DISCHARGE ABOVE 68%")
	if run.current_boss_id == "grid_leech":
		return loc("予告吸収を超放電で中断", "INTERRUPT TELEGRAPHED DRAINS WITH SUPER")
	var definition := current_stage_definition()
	if definition.is_empty():
		return loc("6セルを充電して放電", "CHARGE SIX CELLS AND DISCHARGE")
	return str(definition.get("objective_ja" if is_japanese else "objective_en", ""))

func upgrade_at(point: Vector2) -> int:
	for index in range(upgrade_rects.size()):
		if upgrade_rects[index].has_point(point):
			return index
	return -1

func upgrade_color(index: int) -> Color:
	return [Palette.CYAN, Palette.BLUE, Palette.VIOLET, Palette.MINT, Palette.AMBER, Palette.MAGENTA, Palette.GREEN, Palette.CORAL][index]

func upgrade_copy(index: int) -> Dictionary:
	var copies := [
		{"title": loc("手動コイル", "HAND COIL"), "desc": loc("1入力の充電 +3.5", "+3.5 CHARGE PER INPUT")},
		{"title": loc("拡張セル", "WIDE CELLS"), "desc": loc("各セル容量 +9", "+9 CAPACITY PER CELL")},
		{"title": loc("自動ドローン", "AUTO DRONE"), "desc": loc("AUTO速度 +3.5/秒", "+3.5 AUTO PER SEC")},
		{"title": loc("冷却ループ", "COOLING LOOP"), "desc": loc("冷却速度 +2.3/秒", "+2.3 COOLING PER SEC")},
		{"title": loc("放電増幅器", "DISCHARGE AMP"), "desc": loc("全放電出力 +18%", "+18% ALL DISCHARGE")},
		{"title": loc("臨界演算", "CRITICAL MATH"), "desc": loc("クリティカル率 +4.5%", "+4.5% CRITICAL CHANCE")},
		{"title": loc("耐熱被膜", "HEAT SHIELD"), "desc": loc("発熱-12%・事故保持+7%", "-12% HEAT, +7% RETAIN")},
		{"title": loc("六連サージ", "SIXFOLD SURGE"), "desc": loc("満充電放電 +18%", "+18% FULL DISCHARGE")},
	]
	return copies[index]

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

func format_time(seconds: float) -> String:
	var total := int(seconds)
	return "%02d:%02d" % [total / 60, total % 60]

func tutorial_hint() -> String:
	if run.stage_phase == ChargeState.StagePhase.BOSS and run.boss_warning_active() and run.current_boss_id != "thermal_titan" and not (run.singularity_boss and run.singularity_phase == 2):
		return loc("超放電で吸収を中断するか、先に部分放電で退避", "INTERRUPT WITH SUPER, OR BANK A PARTIAL DISCHARGE NOW")
	if run.manual_inputs == 0:
		return loc("大きなCHARGEボタンを押す / Space / A・×", "PRESS CHARGE / SPACE / A · CROSS")
	if run.partial_discharges + run.super_discharges == 0 and run.filled_cells() < 6:
		return loc("いつでも放電できる。6セルなら出力が大幅上昇", "DISCHARGE ANY TIME. FILL ALL SIX FOR A LARGE BONUS.")
	if run.purchases == 0 and run.credits > 0:
		return loc("獲得したエネルギー片で強化を購入", "SPEND ENERGY SHARDS ON AN UPGRADE")
	if run.is_full():
		return loc("今なら安全に超放電。押し続ければ高倍率だが発熱する", "SUPER DISCHARGE NOW, OR HOLD FOR RISKY OVERCHARGE")
	if run.stage_phase == ChargeState.StagePhase.BOSS:
		return current_rule_copy()
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
	if not campaign_screen_visible() and run.stage_phase in [ChargeState.StagePhase.REWARD, ChargeState.StagePhase.CLEAR]:
		draw_completion_overlay()
	if screen_flash > 0.0:
		var flash_color := Palette.CORAL if run.meltdowns > 0 and run.heat <= 35.0 and message_time > 1.0 else Palette.CYAN
		draw_rect(Rect2(Vector2.ZERO, VIEW), Palette.with_alpha(flash_color, screen_flash * 0.18))

func draw_background() -> void:
	# Phase 2 provisional PixelLab selections. The 320x180 backdrop scales to
	# 1280x720 by an exact 4x, preserving the native pixel clusters.
	draw_texture_rect(generator_background, Rect2(Vector2.ZERO, VIEW), false, Color(0.72, 0.82, 0.94, 0.26))
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.015, 0.03, 0.07, 0.48))
	for x in range(-120, 1440, 80):
		draw_line(Vector2(x, 0), Vector2(x - 260, 720), Palette.with_alpha(Palette.BLUE, 0.045), 1.0)
	for y in range(100, 720, 72):
		draw_line(Vector2(0, y), Vector2(1280, y), Palette.with_alpha(Palette.CYAN, 0.026), 1.0)
	for index in range(36):
		var point := Vector2(fmod(index * 193.0, 1280.0), fmod(index * 109.0, 720.0))
		var pulse := 0.14 + sin(animation_time * 1.8 + index) * 0.08
		draw_circle(point, 1.2, Palette.with_alpha(Palette.CYAN, pulse))

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
	draw_string(DisplayFont, Vector2(62, 132), loc("真回路マップ", "TRUE CIRCUIT MAP") if true_route else loc("回路復旧マップ", "CIRCUIT RESTORATION MAP"), HORIZONTAL_ALIGNMENT_LEFT, 580, 28, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(62, 158), loc("残りの回路でビルドを完成させる", "COMPLETE YOUR BUILD THROUGH THE REMAINING CIRCUITS") if true_route else loc("好きな3回路を復旧するとボスを選べる", "RESTORE ANY THREE CIRCUITS TO CHOOSE A BOSS"), HORIZONTAL_ALIGNMENT_LEFT, 650, 13, Palette.MUTED)
	draw_campaign_progress(Vector2(844, 129), accent)
	for index in range(StageCatalog.STAGES.size()):
		draw_stage_map_card(index, StageCatalog.STAGES[index])
	draw_string(Palette.UI_FONT, Vector2(0, 598), loc("クリック / 方向キーで選択　決定で接続", "CLICK OR MOVE TO SELECT · CONFIRM TO CONNECT"), HORIZONTAL_ALIGNMENT_CENTER, 1280, 13, Palette.MUTED)
	var synergies: Array[String] = run.active_synergies()
	var build_text := loc("稼働シナジー %d/4", "ACTIVE SYNERGIES %d/4") % synergies.size()
	if not synergies.is_empty():
		build_text += "  ·  " + active_synergy_label(synergies[-1])
	draw_string(DisplayFont, Vector2(0, 632), build_text, HORIZONTAL_ALIGNMENT_CENTER, 1280, 14, Palette.AMBER if not synergies.is_empty() else Palette.MUTED)
	draw_string(Palette.UI_FONT, Vector2(0, 660), loc("進行・資源・強化は回路をまたいで自動保存", "PROGRESS, SHARDS AND UPGRADES AUTOSAVE ACROSS CIRCUITS"), HORIZONTAL_ALIGNMENT_CENTER, 1280, 11, Palette.MUTED)

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
	draw_string(Palette.UI_FONT, rect.position + Vector2(30, 100), str(definition.get("objective_ja" if is_japanese else "objective_en", "")), HORIZONTAL_ALIGNMENT_LEFT, 294, 11, Palette.MUTED)
	if completed:
		draw_string(Palette.UI_FONT, rect.position + Vector2(30, 124), loc("獲得回路：", "CIRCUIT: ") + stage_circuit_label(str(definition.reward_id)), HORIZONTAL_ALIGNMENT_LEFT, 288, 10, Palette.MINT)
	draw_string(Palette.UI_FONT, rect.position + Vector2(30, 145), loc("推奨：", "BUILD: ") + str(definition.build_tag).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, 190, 11, accent)
	if completed:
		draw_string(DisplayFont, rect.position + Vector2(218, 145), loc("復旧済み", "RESTORED"), HORIZONTAL_ALIGNMENT_RIGHT, 100, 12, Palette.MINT)
	elif selected:
		draw_string(DisplayFont, rect.position + Vector2(218, 145), loc("接続可能", "READY"), HORIZONTAL_ALIGNMENT_RIGHT, 100, 12, Palette.PAPER)

func draw_boss_selection() -> void:
	draw_string(DisplayFont, Vector2(0, 148), loc("主敵性回路を選択", "SELECT A MASTER HOSTILE"), HORIZONTAL_ALIGNMENT_CENTER, 1280, 32, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(0, 180), loc("ここから通常クリアまで約5〜7分。現在のビルドに合う方を選ぶ", "ABOUT 5–7 MINUTES TO THE NORMAL ENDING · CHOOSE FOR YOUR BUILD"), HORIZONTAL_ALIGNMENT_CENTER, 1280, 14, Palette.MUTED)
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
	draw_string(DisplayFont, rect.position + Vector2(0, 159), str(definition.get("name_ja" if is_japanese else "name_en", definition.id)), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 24, Palette.PAPER)
	draw_string(Palette.UI_FONT, rect.position + Vector2(34, 199), str(definition.get("rule_ja" if is_japanese else "rule_en", "")), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 68, 13, Palette.MUTED)
	draw_string(DisplayFont, rect.position + Vector2(0, 254), loc("対抗：", "COUNTER: ") + str(definition.counter_tag).to_upper(), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 13, accent)

func draw_boss_briefing() -> void:
	var definition := StageCatalog.boss(campaign_route.current_boss_id)
	var singularity: bool = campaign_route.phase == CampaignRoute.RoutePhase.SINGULARITY
	var accent := Color(str(definition.get("accent", "f5f0db")))
	var label := loc("真の最終回路", "TRUE FINAL CIRCUIT") if singularity else loc("強化主敵性回路", "ENHANCED MASTER HOSTILE")
	draw_string(DisplayFont, Vector2(0, 156), label, HORIZONTAL_ALIGNMENT_CENTER, 1280, 18, accent)
	draw_string(DisplayFont, Vector2(0, 220), str(definition.get("name_ja" if is_japanese else "name_en", campaign_route.current_boss_id)), HORIZONTAL_ALIGNMENT_CENTER, 1280, 38, Palette.PAPER)
	var center := Vector2(640, 340)
	for ring in range(5):
		draw_arc(center, 72 + ring * 22, -PI * 0.6 + animation_time * (0.15 + ring * 0.04) * (-1.0 if ring % 2 else 1.0), PI * 1.25 + animation_time * (0.15 + ring * 0.04) * (-1.0 if ring % 2 else 1.0), 48, Palette.with_alpha(accent, 0.8 - ring * 0.12), 4.0)
	draw_string(Palette.UI_FONT, Vector2(350, 470), str(definition.get("rule_ja" if is_japanese else "rule_en", "")), HORIZONTAL_ALIGNMENT_CENTER, 580, 15, Palette.MUTED)
	draw_campaign_button(campaign_primary_rect, loc("最終接続を開始", "ENGAGE FINAL CIRCUIT") if singularity else loc("強化ボス戦を開始", "ENGAGE ENHANCED BOSS"), accent, true)
	draw_campaign_button(campaign_secondary_rect, loc("ゲーム選択へ", "RETURN TO GAME LAB"), Palette.MUTED, false)

func draw_campaign_ending(true_end: bool) -> void:
	var accent := Palette.PAPER if true_end else Palette.AMBER
	draw_string(DisplayFont, Vector2(0, 142), loc("完全復旧", "TOTAL RESTORATION") if true_end else loc("通常復旧完了", "RESTORATION COMPLETE"), HORIZONTAL_ALIGNMENT_CENTER, 1280, 34, accent)
	draw_string(Palette.UI_FONT, Vector2(0, 178), loc("六回路は一つの発電網として再起動した", "ALL SIX CIRCUITS NOW OPERATE AS ONE GRID") if true_end else loc("選択した三回路で都市の主電源を取り戻した", "YOUR THREE CIRCUITS RESTORED THE CITY'S MAIN POWER"), HORIZONTAL_ALIGNMENT_CENTER, 1280, 15, Palette.MUTED)
	var panel := Rect2(264, 218, 752, 300)
	draw_machine_plate(panel, Palette.with_alpha(Palette.PANEL, 0.94), Palette.with_alpha(accent, 0.5), 18.0, 2.0)
	var stats := [
		[loc("総プレイ時間", "TOTAL TIME"), format_time(run.elapsed)],
		[loc("復旧回路", "CIRCUITS"), "%d / 6" % campaign_route.completed_stage_ids.size()],
		[loc("撃破ボス", "BOSSES"), "%d / 2" % campaign_route.defeated_boss_ids.size()],
		[loc("最大放電", "PEAK OUTPUT"), format_number(run.highest_output)],
		[loc("稼働シナジー", "ACTIVE SYNERGIES"), "%d / 4" % run.active_synergies().size()],
		[loc("メルトダウン", "MELTDOWNS"), str(run.meltdowns)],
	]
	for index in range(stats.size()):
		var row := index % 3
		var column := index / 3
		var x := panel.position.x + 54 + column * 370
		var y := panel.position.y + 62 + row * 72
		draw_string(Palette.UI_FONT, Vector2(x, y), str(stats[index][0]), HORIZONTAL_ALIGNMENT_LEFT, 230, 12, Palette.MUTED)
		draw_string(DisplayFont, Vector2(x, y + 27), str(stats[index][1]), HORIZONTAL_ALIGNMENT_LEFT, 250, 20, Palette.PAPER)
	var copy_label := loc("C  結果をコピー", "C  COPY RESULT")
	if result_copied_time > 0.0:
		copy_label = loc("コピー済み", "COPIED") if result_copy_succeeded else loc("コピーできません", "COPY FAILED")
	draw_campaign_button(campaign_copy_rect, copy_label, Palette.MINT if result_copy_succeeded else Palette.CORAL, false)
	draw_string(Palette.UI_FONT, Vector2(0, 544), loc("制作：Godot + Codex　ピクセルアート：PixelLab", "BUILT WITH GODOT + CODEX · PIXEL ART WITH PIXELLAB"), HORIZONTAL_ALIGNMENT_CENTER, 1280, 10, Palette.with_alpha(Palette.MUTED, 0.8))
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
	draw_string(Palette.UI_FONT, Vector2(612, 26), loc("エネルギー片", "ENERGY SHARDS"), HORIZONTAL_ALIGNMENT_CENTER, 82, 9, Palette.MUTED)
	draw_string(Palette.UI_FONT, Vector2(612, 57), "%04d" % run.credits, HORIZONTAL_ALIGNMENT_CENTER, 82, 22, Palette.AMBER)
	draw_string(Palette.UI_FONT, Vector2(752, 31), loc("経過", "ELAPSED"), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Palette.MUTED)
	draw_string(Palette.UI_FONT, Vector2(752, 62), format_time(run.elapsed), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Palette.PAPER)
	draw_small_button(reset_rect, loc("R  もう一度", "R  CONFIRM") if reset_confirm_time > 0.0 else loc("R  初期化", "R  RESET"), Palette.CORAL)
	draw_small_button(language_rect, "日本語 / EN", Palette.MINT)
	draw_small_button(menu_rect, loc("ゲーム選択", "GAME LAB"), Palette.CYAN)

func campaign_header_context() -> String:
	if campaign_route == null:
		return loc("GENERATOR CORE・縦切り版", "GENERATOR CORE · VERTICAL SLICE")
	if campaign_route.phase in [CampaignRoute.RoutePhase.MAP, CampaignRoute.RoutePhase.TRUE_MAP]:
		return loc("回路マップ", "CIRCUIT MAP") + " · %d/6" % campaign_route.completed_stage_ids.size()
	if campaign_route.phase == CampaignRoute.RoutePhase.BOSS_SELECT:
		return loc("主敵性回路を選択", "SELECT MASTER HOSTILE")
	if campaign_route.phase in [CampaignRoute.RoutePhase.NORMAL_END, CampaignRoute.RoutePhase.TRUE_END]:
		return loc("復旧記録", "RESTORATION RECORD")
	if not run.current_stage_id.is_empty():
		var definition := current_stage_definition()
		if not definition.is_empty():
			return stage_name(definition)
	return encounter_name()

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
	draw_string(DisplayFont, Vector2(58, 140), loc("CHARGE REACTOR", "CHARGE REACTOR"), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Palette.MUTED)
	draw_texture_rect(reactor_texture, Rect2(REACTOR_CENTER - Vector2(96, 96), Vector2(192, 192)), false, Color(0.84, 0.9, 1.0, 0.9))
	var pulse: float = 1.0 + sin(animation_time * (2.0 + run.charge_ratio() * 4.0)) * (0.015 + run.charge_ratio() * 0.025)
	var radius: float = 100.0 * pulse
	for ring in range(4):
		draw_arc(REACTOR_CENTER, radius + ring * 9.0, -PI * 0.75 + animation_time * (0.24 + ring * 0.05) * (-1.0 if ring % 2 else 1.0), PI * 1.1 + animation_time * (0.24 + ring * 0.05) * (-1.0 if ring % 2 else 1.0), 48, Palette.with_alpha(Palette.CYAN, 0.42 - ring * 0.07), 2.0)
	var reactor_color: Color = Palette.CORAL if run.heat > 80.0 else Palette.AMBER if run.is_full() else Palette.CYAN
	draw_circle(REACTOR_CENTER, 78.0, Palette.with_alpha(reactor_color, 0.1 + run.charge_ratio() * 0.16))
	draw_arc(REACTOR_CENTER, 80.0, -PI * 0.5, -PI * 0.5 + TAU * run.charge_ratio(), 64, reactor_color, 8.0)
	draw_circle(REACTOR_CENTER, 51.0, Palette.with_alpha(Palette.INK, 0.96))
	draw_circle(REACTOR_CENTER, 43.0 + sin(animation_time * 4.0) * 2.0, Palette.with_alpha(reactor_color, 0.16 + run.charge_ratio() * 0.32))
	draw_string(Palette.UI_FONT, REACTOR_CENTER + Vector2(-78, -5), "%d / %d" % [int(run.total_charge()), int(run.total_capacity())], HORIZONTAL_ALIGNMENT_CENTER, 156, 22, Palette.PAPER)
	draw_string(Palette.UI_FONT, REACTOR_CENTER + Vector2(-78, 23), loc("蓄積電力", "STORED POWER"), HORIZONTAL_ALIGNMENT_CENTER, 156, 11, Palette.MUTED)

	draw_meter(Rect2(64, 408, 296, 20), run.heat / 100.0, heat_color(), loc("熱", "HEAT"), "%d%%" % int(run.heat))
	draw_meter(Rect2(64, 452, 296, 20), run.overcharge / 100.0, Palette.AMBER, loc("過充電", "OVERCHARGE"), "×%.2f" % (1.0 + run.overcharge * 0.01))

	var hovered := charge_rect.has_point(mouse_position) or charge_held
	var charge_color := Palette.AMBER if run.is_full() else Palette.CYAN
	var charge_fill := Palette.with_alpha(charge_color, 0.28 if charge_held else 0.19 if hovered else 0.065)
	draw_machine_plate(charge_rect, charge_fill, Palette.with_alpha(charge_color, 1.0 if hovered else 0.68), 16.0, 3.0 if charge_held else 2.0)
	var mechanism_rect := Rect2(charge_rect.position + Vector2(5, 7 + (5 if charge_held else 0)), Vector2(88, 94))
	draw_console_region(CONTROL_CHARGE_REGION, mechanism_rect, Color(1.0, 1.0, 1.0, 1.0))
	draw_texture_rect(charge_control_texture, Rect2(charge_rect.position + Vector2(28, 28 + (4 if charge_held else 0)), Vector2(44, 44)), false, Color.WHITE)
	for step in range(6):
		var contact_color := charge_color if step < run.filled_cells() else Palette.with_alpha(Palette.MUTED, 0.22)
		draw_rect(Rect2(charge_rect.position + Vector2(107 + step * 25, 17), Vector2(17, 4)), contact_color)
	draw_string(DisplayFont, charge_rect.position + Vector2(94, 50), "CHARGE", HORIZONTAL_ALIGNMENT_CENTER, charge_rect.size.x - 104, 28, Palette.PAPER)
	draw_string(Palette.UI_FONT, charge_rect.position + Vector2(94, 79), loc("クリック・長押し / SPACE / A・×", "CLICK · HOLD / SPACE / A · CROSS"), HORIZONTAL_ALIGNMENT_CENTER, charge_rect.size.x - 104, 11, Palette.MUTED)
	draw_string(Palette.UI_FONT, Vector2(58, 650), tutorial_hint(), HORIZONTAL_ALIGNMENT_LEFT, 310, 13, Palette.AMBER if run.is_full() else Palette.MUTED)
	draw_string(Palette.UI_FONT, Vector2(58, 675), loc("入力 %d  放電 %d  事故 %d", "INPUTS %d  DISCHARGES %d  MELTDOWNS %d") % [run.manual_inputs, run.partial_discharges + run.super_discharges, run.meltdowns], HORIZONTAL_ALIGNMENT_LEFT, 310, 11, Palette.MUTED)

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
	if run.stage_phase == ChargeState.StagePhase.BOSS:
		var wraith_alpha := 0.24 + sin(animation_time * 2.4) * 0.035
		draw_texture_rect(grid_wraith_texture, Rect2(687, 125, 256, 256), false, Color(0.82, 0.94, 1.0, wraith_alpha))
	for index in range(6):
		draw_cell(index)
	if run.stage_phase == ChargeState.StagePhase.BOSS and run.boss_warning_active():
		var target_index: int = maxi(0, run.most_charged_cell())
		var siphon_start := Vector2(1018, 151)
		var siphon_end := Vector2(505 + target_index * 125, 160)
		var bend := Vector2(siphon_end.x, 147)
		var warning_alpha := 0.45 + sin(animation_time * 15.0) * 0.25
		draw_polyline(PackedVector2Array([siphon_start, bend, siphon_end]), Palette.with_alpha(Palette.CORAL, warning_alpha), 3.0, true)
		var pulse_position := bend.lerp(siphon_end, fmod(animation_time * 2.2, 1.0))
		draw_circle(pulse_position, 5.0, Palette.CORAL)
	for index in range(5):
		var start := Vector2(558 + index * 125, 244)
		var finish := Vector2(571 + index * 125, 244)
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
	draw_string(DisplayFont, Vector2(438, 482), loc("アップグレード・モジュールラック — クリックまたは数字キー", "UPGRADE MODULE RACK — CLICK OR USE NUMBER KEYS"), HORIZONTAL_ALIGNMENT_LEFT, 760, 11, Palette.MUTED)
	var active_synergy_count: int = run.active_synergies().size()
	draw_string(DisplayFont, Vector2(1030, 482), loc("シナジー %d/4", "SYNERGY %d/4") % active_synergy_count, HORIZONTAL_ALIGNMENT_RIGHT, 184, 11, Palette.AMBER if active_synergy_count > 0 else Palette.MUTED)
	var rack_rect := Rect2(428, 488, 788, 178)
	draw_machine_plate(rack_rect, Palette.with_alpha(Palette.INK, 0.68), Palette.with_alpha(Palette.CYAN, 0.24), 12.0, 1.0)
	draw_texture_rect_region(UpgradeRackTexture, Rect2(430, 490, 784, 172), UPGRADE_RACK_CENTER_REGION, Color(0.78, 0.86, 0.95, 0.78))
	for index in range(upgrade_rects.size()):
		draw_upgrade(index)
	draw_synergy_links()

	if discharge_wave > 0.0:
		var progress: float = 1.0 - discharge_wave
		draw_arc(Vector2(815, 245), 70.0 + progress * 410.0, 0.0, TAU, 64, Palette.with_alpha(Palette.AMBER if run.super_discharges > 0 else Palette.CYAN, discharge_wave * 0.8), 5.0)

func draw_stage_rule_indicator() -> void:
	var rect := Rect2(452, 424, 748, 20)
	var ratio := 0.0
	var label := ""
	var accent := Palette.CYAN
	if run.current_boss_id == "thermal_titan" or (run.singularity_boss and run.singularity_phase == 2):
		ratio = run.heat / 100.0
		label = loc("弱点温度 %d%% / 68%%", "WEAKNESS HEAT %d%% / 68%%") % int(run.heat)
		accent = Palette.CORAL if run.heat >= 68.0 else Palette.AMBER
	elif run.singularity_boss:
		ratio = run.objective_ratio()
		label = current_rule_copy()
		accent = Palette.PAPER
	else:
		match run.current_stage_id:
			"generator_core":
				ratio = float(run.manual_streak) / 12.0
				label = loc("入力リズム %d/12", "INPUT RHYTHM %d/12") % run.manual_streak
			"capacitor_vault":
				ratio = float(run.filled_cells()) / 6.0
				label = loc("バースト同期 %d/6", "BURST SYNC %d/6") % run.filled_cells()
				accent = Palette.BLUE
			"thermal_plant":
				ratio = run.heat / 100.0
				label = loc("レッドライン %d%%", "REDLINE %d%%") % int(run.heat)
				accent = Palette.CORAL if run.heat >= 68.0 else Palette.AMBER
			"relay_network":
				ratio = float(run.stage_combo) / 8.0
				label = loc("放電チェイン ×%d", "DISCHARGE CHAIN ×%d") % maxi(1, run.stage_combo)
				accent = Palette.VIOLET
			"drone_array":
				ratio = run.manual_boost_timer / 2.6
				label = loc("AUTO指令 %s", "AUTO COMMAND %s") % ("BOOST" if run.manual_boost_timer > 0.0 else "STANDBY")
				accent = Palette.MINT
			"surge_lab":
				ratio = run.effective_critical_chance()
				label = loc("臨界ウィンドウ %d%%", "CRITICAL WINDOW %d%%") % int(run.effective_critical_chance() * 100.0)
				accent = Palette.AMBER
			_:
				ratio = run.objective_ratio()
				label = current_rule_copy()
	draw_machine_plate(rect, Palette.with_alpha(Palette.INK, 0.84), Palette.with_alpha(accent, 0.32), 4.0, 1.0)
	for index in range(12):
		var lit := ratio * 12.0 > float(index)
		draw_rect(Rect2(rect.position + Vector2(5 + index * 39, 6), Vector2(32, 8)), accent if lit else Palette.with_alpha(accent, 0.08))
	draw_string(DisplayFont, Vector2(914, 439), label, HORIZONTAL_ALIGNMENT_RIGHT, 276, 11, Palette.PAPER)

func draw_cell(index: int) -> void:
	var rect := Rect2(452 + index * 125, 160, 106, 154)
	var ratio: float = run.cells[index] / maxf(1.0, run.capacity)
	var full := ratio >= 0.999
	var color: Color = Palette.AMBER if full else [Palette.CYAN, Palette.BLUE, Palette.VIOLET, Palette.MAGENTA, Palette.MINT, Palette.GREEN][index]
	if run.stage_phase == ChargeState.StagePhase.BOSS and run.boss_warning_active() and index == run.most_charged_cell():
		color = Palette.CORAL
		draw_machine_plate(rect.grow(10.0), Palette.with_alpha(Palette.CORAL, 0.12 + sin(animation_time * 16.0) * 0.08), Palette.CORAL, 12.0, 2.0)
	if full:
		draw_machine_plate(rect.grow(7.0), Palette.with_alpha(color, 0.12 + sin(animation_time * 5.0 + index) * 0.05), Palette.with_alpha(color, 0.5), 10.0, 1.0)
	draw_machine_plate(rect, Palette.INK, Palette.with_alpha(color, 0.24), 9.0, 1.0)
	var inner := Rect2(rect.position + Vector2(8, 8), rect.size - Vector2(16, 16))
	if ratio > 0.0:
		var fill_height := inner.size.y * ratio
		var fill_rect := Rect2(Vector2(inner.position.x, inner.end.y - fill_height), Vector2(inner.size.x, fill_height))
		draw_machine_plate(fill_rect, Palette.with_alpha(color, 0.42 if not full else 0.68), Palette.with_alpha(color, 0.7), minf(6.0, fill_height * 0.18), 1.0)
		for stripe in range(3):
			var stripe_y := fill_rect.position.y + fmod(animation_time * 36.0 + stripe * 31.0, maxf(1.0, fill_rect.size.y))
			draw_line(Vector2(fill_rect.position.x + 5, stripe_y), Vector2(fill_rect.end.x - 5, stripe_y), Palette.with_alpha(Palette.PAPER, 0.18), 1.0)
	draw_texture_rect(cell_texture, Rect2(rect.position + Vector2(5, 5), Vector2(96, 144)), false, Color(0.9, 0.95, 1.0, 1.0))
	draw_machine_plate(Rect2(rect.position + Vector2(12, 61), Vector2(82, 37)), Color(0.025, 0.05, 0.10, 0.78), Palette.with_alpha(color, 0.28), 5.0, 1.0)
	draw_string(Palette.UI_FONT, rect.position + Vector2(0, 25), "%02d" % (index + 1), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 13, Palette.MUTED)
	draw_string(Palette.UI_FONT, rect.position + Vector2(0, 91), "%d%%" % int(ratio * 100.0), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 22, Palette.PAPER)
	draw_string(Palette.UI_FONT, rect.position + Vector2(0, 133), loc("同期", "SYNC") if full else loc("充電", "CHARGE"), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 11, color)

func draw_upgrade(index: int) -> void:
	var rect := upgrade_rects[index]
	var definition: Dictionary = ChargeState.UPGRADE_DEFINITIONS[index]
	var id := str(definition.id)
	var copy := upgrade_copy(index)
	var color := upgrade_color(index)
	var affordable: bool = run.can_purchase(id)
	var hovered := hover_upgrade == index
	var linked := upgrade_has_active_synergy(index)
	var background := Palette.with_alpha(Palette.INK, 0.9 if hovered else 0.76 if affordable else 0.84)
	draw_machine_plate(rect, background, Palette.with_alpha(Palette.AMBER if linked else color, 1.0 if hovered or linked else 0.46 if affordable else 0.2), 7.0, 2.0 if hovered or linked else 1.0)
	draw_rect(Rect2(rect.position + Vector2(5, 6), Vector2(4, rect.size.y - 12)), Palette.with_alpha(color, 0.92 if affordable else 0.22))
	draw_rect(Rect2(rect.position + Vector2(12, 5), Vector2(rect.size.x - 24, 3)), Palette.with_alpha(color, 0.42 if affordable else 0.12))
	draw_circle(rect.position + Vector2(rect.size.x - 12, 12), 3.5, color if affordable else Palette.with_alpha(Palette.MUTED, 0.28))
	draw_string(Palette.UI_FONT, rect.position + Vector2(10, 20), "%d" % (index + 1), HORIZONTAL_ALIGNMENT_LEFT, 22, 12, color)
	draw_string(DisplayFont, rect.position + Vector2(32, 20), str(copy.title), HORIZONTAL_ALIGNMENT_LEFT, 136, 12, Palette.PAPER)
	draw_string(Palette.UI_FONT, rect.position + Vector2(12, 44), str(copy.desc), HORIZONTAL_ALIGNMENT_LEFT, 160, 10, Palette.MUTED)
	draw_string(Palette.UI_FONT, rect.position + Vector2(12, 70), "LV.%d" % run.upgrade_level(id), HORIZONTAL_ALIGNMENT_LEFT, 72, 11, color)
	draw_texture_rect(energy_shard_texture, Rect2(rect.position + Vector2(100, 55), Vector2(18, 18)), false, Color.WHITE if affordable else Color(0.48, 0.52, 0.58, 0.7))
	draw_string(Palette.UI_FONT, rect.position + Vector2(119, 70), "%d" % run.upgrade_cost(id), HORIZONTAL_ALIGNMENT_RIGHT, 55, 12, Palette.AMBER if affordable else Palette.MUTED)

func upgrade_has_active_synergy(index: int) -> bool:
	return (index in [0, 5] and run.synergy_active("precision_loop")) or (index in [2, 3] and run.synergy_active("autonomous_cooling")) or (index in [1, 4] and run.synergy_active("burst_bank")) or (index in [6, 7] and run.synergy_active("redline_armor"))

func draw_synergy_links() -> void:
	var links := [
		[0, 5, "precision_loop", Palette.MAGENTA],
		[2, 3, "autonomous_cooling", Palette.MINT],
		[1, 4, "burst_bank", Palette.BLUE],
		[6, 7, "redline_armor", Palette.CORAL],
	]
	for link in links:
		if not run.synergy_active(str(link[2])):
			continue
		var start: Vector2 = upgrade_rects[int(link[0])].get_center()
		var finish: Vector2 = upgrade_rects[int(link[1])].get_center()
		var color: Color = link[3]
		var pulse := 0.42 + sin(animation_time * 4.0 + int(link[0])) * 0.18
		draw_polyline(PackedVector2Array([start, Vector2(start.x, 578), Vector2(finish.x, 578), finish]), Palette.with_alpha(color, pulse), 2.0, true)

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
	draw_string(DisplayFont, Vector2(446, 129), title, HORIZONTAL_ALIGNMENT_LEFT, 220, 15, accent)
	draw_string(Palette.UI_FONT, Vector2(446, 147), phase, HORIZONTAL_ALIGNMENT_LEFT, 280, 10, Palette.MUTED)
	if is_boss:
		draw_texture_rect(WraithGaugeTexture, Rect2(824, 105, 390, 58), false, Color(0.9, 0.94, 1.0, 0.82))
		var remaining_ratio: float = clampf(run.boss_hp / maxf(1.0, run.boss_max_hp), 0.0, 1.0)
		var remaining_seals := int(ceil(remaining_ratio * 6.0))
		var seal_positions := [842.0, 883.0, 924.0, 1080.0, 1121.0, 1162.0]
		for index in range(6):
			var seal_rect := Rect2(seal_positions[index], 128, 31, 13)
			var intact := index < remaining_seals
			draw_machine_plate(seal_rect, Palette.with_alpha(Palette.CORAL if intact else Palette.CYAN, 0.8 if intact else 0.12), Palette.CORAL if intact else Palette.with_alpha(Palette.CYAN, 0.38), 3.0, 1.0)
		var value_text := "%d%%" % int(round(remaining_ratio * 100.0))
		if run.boss_warning_active():
			value_text = "%.1fs" % maxf(0.0, run.boss_attack_timer)
		draw_string(Palette.UI_FONT, Vector2(980, 143), value_text, HORIZONTAL_ALIGNMENT_CENTER, 92, 15, Palette.PAPER)
		draw_string(Palette.UI_FONT, Vector2(980, 157), boss_integrity_label(), HORIZONTAL_ALIGNMENT_CENTER, 92, 7, Palette.MUTED)
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
	draw_string(DisplayFont, Vector2(0, 168), loc("STAGE CLEAR", "STAGE CLEAR"), HORIZONTAL_ALIGNMENT_CENTER, 1280, 40, Palette.AMBER)
	var definition := current_stage_definition()
	draw_string(DisplayFont, Vector2(0, 205), stage_name(definition), HORIZONTAL_ALIGNMENT_CENTER, 1280, 18, Palette.PAPER)
	var reward_name := ""
	for index in range(3):
		var reward := reward_copy(index)
		if str(reward.id) == run.reward_id:
			reward_name = str(reward.title)
	var stats := [
		[loc("クリアタイム", "CLEAR TIME"), format_time(run.stage_clear_time)],
		[loc("最大放電", "PEAK OUTPUT"), format_number(run.highest_output)],
		[loc("超放電", "SUPER DISCHARGES"), str(run.super_discharges)],
		[loc("吸収中断", "DRAIN INTERRUPTS"), str(run.boss_interrupts)],
		[loc("メルトダウン", "MELTDOWNS"), str(run.meltdowns)],
		[loc("獲得回路", "CIRCUIT REWARD"), reward_name],
	]
	for index in range(stats.size()):
		var y := 250 + index * 42
		draw_string(Palette.UI_FONT, Vector2(340, y), str(stats[index][0]), HORIZONTAL_ALIGNMENT_LEFT, 250, 14, Palette.MUTED)
		draw_string(Palette.UI_FONT, Vector2(610, y), str(stats[index][1]), HORIZONTAL_ALIGNMENT_RIGHT, 300, 17, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(0, 520), loc("回路を登録すると次のステージ選択へ進む", "REGISTER THIS CIRCUIT AND RETURN TO THE MAP"), HORIZONTAL_ALIGNMENT_CENTER, 1280, 14, Palette.CYAN)
	draw_machine_plate(clear_retry_rect, Palette.AMBER, Palette.PAPER, 10.0, 2.0)
	draw_string(DisplayFont, clear_retry_rect.position + Vector2(0, 34), loc("回路マップへ", "CIRCUIT MAP"), HORIZONTAL_ALIGNMENT_CENTER, clear_retry_rect.size.x, 16, Palette.INK)
	draw_machine_plate(clear_menu_rect, Palette.PANEL_2, Palette.CYAN, 10.0, 1.0)
	draw_string(Palette.UI_FONT, clear_menu_rect.position + Vector2(0, 34), loc("ゲーム選択", "GAME LAB"), HORIZONTAL_ALIGNMENT_CENTER, clear_menu_rect.size.x, 16, Palette.PAPER)

func boss_integrity_label() -> String:
	if run.singularity_boss:
		return loc("事象安定度", "EVENT STABILITY")
	if run.current_boss_id == "thermal_titan":
		return loc("炉心装甲", "CORE ARMOR")
	if run.current_boss_id == "grid_leech":
		return loc("吸収器耐久", "SIPHON INTEGRITY")
	return loc("敵性回路耐久", "HOSTILE INTEGRITY")
