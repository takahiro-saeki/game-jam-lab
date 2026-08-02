extends Node2D

signal return_to_menu
signal language_changed(is_japanese: bool)

const Palette = preload("res://shared/palette.gd")
const Synth = preload("res://shared/synth.gd")
const ControllerConfig = preload("res://shared/controller_bindings.gd")
const ChargeState = preload("res://games/charge_clicker/charge_state.gd")

const VIEW := Vector2(1280, 720)
const REACTOR_CENTER := Vector2(212, 286)

var synth: JamSynth
var run
var is_japanese := false
var controller_bindings: Dictionary = ControllerConfig.default_bindings()

var animation_time := 0.0
var charge_held := false
var charge_repeat_timer := 0.0
var screen_shake := 0.0
var screen_flash := 0.0
var discharge_wave := 0.0
var message := ""
var message_time := 0.0
var hover_upgrade := -1
var mouse_position := Vector2(-100, -100)
var particles: Array[Dictionary] = []
var floating_texts: Array[Dictionary] = []
var auto_effect_timer := 0.0

var charge_rect := Rect2(70, 502, 284, 108)
var discharge_rect := Rect2(452, 340, 510, 76)
var auto_rect := Rect2(980, 340, 220, 76)
var menu_rect := Rect2(1102, 22, 138, 42)
var language_rect := Rect2(932, 22, 152, 42)
var reset_rect := Rect2(34, 22, 126, 42)
var upgrade_rects: Array[Rect2] = []

func _ready() -> void:
	synth = Synth.new()
	add_child(synth)
	run = ChargeState.new()
	for row in range(2):
		for column in range(4):
			upgrade_rects.append(Rect2(438 + column * 194, 494 + row * 94, 184, 84))
	show_message(loc("CHARGEで6セルを満たし、好きな瞬間にDISCHARGE", "FILL SIX CELLS WITH CHARGE. DISCHARGE WHEN YOU CHOOSE."), 5.0)
	queue_redraw()

func reset_run() -> void:
	run.reset()
	particles.clear()
	floating_texts.clear()
	charge_held = false
	screen_flash = 0.0
	screen_shake = 0.0
	discharge_wave = 0.0
	show_message(loc("コアを再起動しました", "CORE REBOOTED"), 1.8)
	synth.play_chord([220.0, 329.63, 440.0], 0.22, -24.0)
	queue_redraw()

func _process(delta: float) -> void:
	animation_time += delta
	if screen_shake > 0.0:
		screen_shake = maxf(0.0, screen_shake - delta)
	if screen_flash > 0.0:
		screen_flash = maxf(0.0, screen_flash - delta * 2.4)
	if discharge_wave > 0.0:
		discharge_wave = maxf(0.0, discharge_wave - delta * 1.4)
	if message_time > 0.0:
		message_time -= delta

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
	if float(tick_result.auto_added) > 0.0:
		auto_effect_timer -= delta
		if auto_effect_timer <= 0.0:
			auto_effect_timer = 0.16
			var target_index: int = maxi(0, run.next_cell_index())
			spawn_sparks(Vector2(502 + target_index * 125, 244), Palette.VIOLET, 2, 55.0)

	update_effects(delta)
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
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
			reset_run()
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
		reset_run()
	elif discharge_rect.has_point(point):
		perform_discharge()
	elif auto_rect.has_point(point):
		toggle_auto()
	else:
		var index := upgrade_at(point)
		if index >= 0:
			try_purchase(index)

func controller_button(action: String) -> int:
	return int(controller_bindings.get(action, ControllerConfig.DEFAULTS.get(action, JOY_BUTTON_A)))

func begin_charge() -> void:
	if charge_held:
		return
	charge_held = true
	charge_repeat_timer = 0.145
	perform_charge()

func end_charge() -> void:
	charge_held = false
	charge_repeat_timer = 0.0

func perform_charge(play_sound: bool = true, critical_mode: int = -1) -> Dictionary:
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
	add_floating(Vector2(720, 285), "%s OUTPUT" % format_number(float(result.output)), color, 30 if bool(result.super) else 24)
	if bool(result.super):
		show_message(loc("SUPER DISCHARGE！ 6セル同期ボーナス", "SUPER DISCHARGE! SIX-CELL SYNC BONUS"), 2.2)
		if play_sound:
			synth.play_chord([130.81, 261.63, 392.0, 659.25], 0.38, -19.0)
	else:
		show_message(loc("部分放電 — 安全に出力を回収", "PARTIAL DISCHARGE — SAFE OUTPUT BANKED"), 1.5)
		if play_sound:
			synth.play_chord([220.0, 329.63, 440.0], 0.2, -23.0)
	return result

func toggle_auto(play_sound: bool = true) -> bool:
	var enabled: bool = run.toggle_auto()
	show_message(loc("AUTO充電：ON", "AUTO CHARGE: ON") if enabled else loc("AUTO充電：OFF", "AUTO CHARGE: OFF"), 1.2)
	if play_sound:
		synth.play_tone(523.25 if enabled else 261.63, 0.1, -22.0, 3)
	return enabled

func try_purchase(index: int, play_sound: bool = true) -> bool:
	if index < 0 or index >= ChargeState.UPGRADE_DEFINITIONS.size():
		return false
	var id := str(ChargeState.UPGRADE_DEFINITIONS[index].id)
	if not run.purchase_upgrade(id):
		show_message(loc("エネルギー片が足りません", "NOT ENOUGH ENERGY SHARDS"), 1.1)
		if play_sound:
			synth.error()
		return false
	var copy := upgrade_copy(index)
	show_message(loc("強化完了：", "UPGRADED: ") + str(copy.title), 1.4)
	spawn_sparks(upgrade_rects[index].get_center(), upgrade_color(index), 12, 125.0)
	if play_sound:
		synth.confirm()
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
	if run.manual_inputs == 0:
		return loc("大きなCHARGEボタンを押す / Space / A・×", "PRESS CHARGE / SPACE / A · CROSS")
	if run.partial_discharges + run.super_discharges == 0 and run.filled_cells() < 6:
		return loc("いつでも放電できる。6セルなら出力が大幅上昇", "DISCHARGE ANY TIME. FILL ALL SIX FOR A LARGE BONUS.")
	if run.purchases == 0 and run.credits > 0:
		return loc("獲得したエネルギー片で強化を購入", "SPEND ENERGY SHARDS ON AN UPGRADE")
	if run.is_full():
		return loc("今なら安全に超放電。押し続ければ高倍率だが発熱する", "SUPER DISCHARGE NOW, OR HOLD FOR RISKY OVERCHARGE")
	return loc("部分放電で安全に稼ぐか、6セル同期を狙うか", "BANK A SAFE PARTIAL DISCHARGE OR BUILD A SIX-CELL SYNC")

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color("060b16"))
	draw_background()
	var shake_offset := Vector2.ZERO
	if screen_shake > 0.0:
		shake_offset = Vector2(sin(animation_time * 73.0), cos(animation_time * 91.0)) * screen_shake * 9.0
	draw_set_transform(shake_offset)
	draw_header()
	draw_reactor_panel()
	draw_circuit_panel()
	draw_particles_and_text()
	draw_set_transform(Vector2.ZERO)
	if screen_flash > 0.0:
		var flash_color := Palette.CORAL if run.meltdowns > 0 and run.heat <= 35.0 and message_time > 1.0 else Palette.CYAN
		draw_rect(Rect2(Vector2.ZERO, VIEW), Palette.with_alpha(flash_color, screen_flash * 0.18))

func draw_background() -> void:
	for x in range(-120, 1440, 80):
		draw_line(Vector2(x, 0), Vector2(x - 260, 720), Palette.with_alpha(Palette.BLUE, 0.045), 1.0)
	for y in range(100, 720, 72):
		draw_line(Vector2(0, y), Vector2(1280, y), Palette.with_alpha(Palette.CYAN, 0.026), 1.0)
	for index in range(36):
		var point := Vector2(fmod(index * 193.0, 1280.0), fmod(index * 109.0, 720.0))
		var pulse := 0.14 + sin(animation_time * 1.8 + index) * 0.08
		draw_circle(point, 1.2, Palette.with_alpha(Palette.CYAN, pulse))

func draw_header() -> void:
	draw_rect(Rect2(0, 0, 1280, 86), Color("080f1f"))
	draw_line(Vector2(0, 86), Vector2(1280, 86), Palette.with_alpha(Palette.CYAN, 0.32), 1.0)
	draw_string(Palette.UI_FONT, Vector2(178, 34), "PROJECT CHARGE", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(178, 60), loc("30秒 コア・プロトタイプ", "30-SECOND CORE PROTOTYPE"), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Palette.MUTED)
	draw_string(Palette.UI_FONT, Vector2(610, 34), loc("エネルギー片", "ENERGY SHARDS"), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Palette.MUTED)
	draw_string(Palette.UI_FONT, Vector2(610, 65), "%04d" % run.credits, HORIZONTAL_ALIGNMENT_LEFT, -1, 27, Palette.AMBER)
	draw_string(Palette.UI_FONT, Vector2(770, 34), loc("経過", "ELAPSED"), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Palette.MUTED)
	draw_string(Palette.UI_FONT, Vector2(770, 63), format_time(run.elapsed), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Palette.PAPER)
	draw_small_button(reset_rect, loc("R  再起動", "R  REBOOT"), Palette.CORAL)
	draw_small_button(language_rect, "日本語 / EN", Palette.MINT)
	draw_small_button(menu_rect, loc("ゲーム選択", "GAME LAB"), Palette.CYAN)

func draw_small_button(rect: Rect2, text: String, accent: Color) -> void:
	var hovered := rect.has_point(mouse_position)
	draw_style_box(Palette.rounded_box(Palette.with_alpha(accent, 0.18 if hovered else 0.06), 10, Palette.with_alpha(accent, 0.85 if hovered else 0.42), 1), rect)
	draw_string(Palette.UI_FONT, rect.position + Vector2(0, 27), text, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 13, Palette.PAPER)

func draw_reactor_panel() -> void:
	var panel := Rect2(32, 106, 360, 582)
	draw_style_box(Palette.rounded_box(Palette.PANEL, 24, Palette.with_alpha(Palette.CYAN, 0.32), 2), panel)
	draw_string(Palette.UI_FONT, Vector2(58, 140), loc("CHARGE REACTOR", "CHARGE REACTOR"), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Palette.MUTED)
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
	draw_style_box(Palette.rounded_box(Palette.with_alpha(charge_color, 0.92 if charge_held else 0.72 if hovered else 0.16), 22, charge_color, 3), charge_rect)
	draw_string(Palette.UI_FONT, charge_rect.position + Vector2(0, 47), "CHARGE", HORIZONTAL_ALIGNMENT_CENTER, charge_rect.size.x, 31, Palette.INK if hovered else Palette.PAPER)
	draw_string(Palette.UI_FONT, charge_rect.position + Vector2(0, 78), loc("クリック・長押し / SPACE / A・×", "CLICK · HOLD / SPACE / A · CROSS"), HORIZONTAL_ALIGNMENT_CENTER, charge_rect.size.x, 12, Palette.INK if hovered else Palette.MUTED)
	draw_string(Palette.UI_FONT, Vector2(58, 650), tutorial_hint(), HORIZONTAL_ALIGNMENT_LEFT, 310, 13, Palette.AMBER if run.is_full() else Palette.MUTED)
	draw_string(Palette.UI_FONT, Vector2(58, 675), loc("入力 %d  放電 %d  事故 %d", "INPUTS %d  DISCHARGES %d  MELTDOWNS %d") % [run.manual_inputs, run.partial_discharges + run.super_discharges, run.meltdowns], HORIZONTAL_ALIGNMENT_LEFT, 310, 11, Palette.MUTED)

func draw_meter(rect: Rect2, ratio: float, color: Color, label: String, value: String) -> void:
	draw_string(Palette.UI_FONT, rect.position + Vector2(0, -7), label, HORIZONTAL_ALIGNMENT_LEFT, 150, 12, Palette.MUTED)
	draw_string(Palette.UI_FONT, rect.position + Vector2(146, -7), value, HORIZONTAL_ALIGNMENT_RIGHT, 150, 12, color)
	draw_style_box(Palette.rounded_box(Palette.INK, 8), rect)
	if ratio > 0.001:
		draw_style_box(Palette.rounded_box(color, 8), Rect2(rect.position, Vector2(rect.size.x * clampf(ratio, 0.0, 1.0), rect.size.y)))

func heat_color() -> Color:
	if run.heat >= 80.0:
		return Palette.CORAL
	if run.heat >= 55.0:
		return Palette.AMBER
	return Palette.MINT

func draw_circuit_panel() -> void:
	var panel := Rect2(416, 106, 832, 582)
	draw_style_box(Palette.rounded_box(Palette.PANEL, 24, Palette.with_alpha(Palette.VIOLET, 0.32), 2), panel)
	draw_string(Palette.UI_FONT, Vector2(446, 140), loc("6-CELL SYNCHRONIZER", "6-CELL SYNCHRONIZER"), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Palette.MUTED)
	for index in range(6):
		draw_cell(index)
	for index in range(5):
		var start := Vector2(558 + index * 125, 244)
		var finish := Vector2(571 + index * 125, 244)
		draw_line(start, finish, Palette.with_alpha(Palette.CYAN, 0.4 if run.cells[index] >= run.capacity - 0.01 else 0.12), 3.0)

	var can_discharge: bool = run.total_charge() >= 0.5
	var super_ready: bool = run.is_full()
	var discharge_color := Palette.AMBER if super_ready else Palette.CYAN
	var discharge_hover := discharge_rect.has_point(mouse_position)
	draw_style_box(Palette.rounded_box(Palette.with_alpha(discharge_color, 0.82 if discharge_hover and can_discharge else 0.17 if can_discharge else 0.035), 18, Palette.with_alpha(discharge_color, 0.95 if can_discharge else 0.25), 2), discharge_rect)
	draw_string(Palette.UI_FONT, discharge_rect.position + Vector2(0, 34), loc("SUPER DISCHARGE", "SUPER DISCHARGE") if super_ready else "DISCHARGE", HORIZONTAL_ALIGNMENT_CENTER, discharge_rect.size.x, 24, Palette.INK if discharge_hover and can_discharge else Palette.PAPER)
	draw_string(Palette.UI_FONT, discharge_rect.position + Vector2(0, 59), loc("ENTER / X / X・□　右クリック", "ENTER / X / X · SQUARE  ·  RIGHT CLICK"), HORIZONTAL_ALIGNMENT_CENTER, discharge_rect.size.x, 11, Palette.INK if discharge_hover and can_discharge else Palette.MUTED)

	var auto_color := Palette.VIOLET if run.auto_enabled else Palette.MUTED
	var auto_hover := auto_rect.has_point(mouse_position)
	draw_style_box(Palette.rounded_box(Palette.with_alpha(auto_color, 0.65 if auto_hover or run.auto_enabled else 0.08), 18, auto_color, 2), auto_rect)
	draw_string(Palette.UI_FONT, auto_rect.position + Vector2(0, 32), "AUTO  %s" % ("ON" if run.auto_enabled else "OFF"), HORIZONTAL_ALIGNMENT_CENTER, auto_rect.size.x, 19, Palette.PAPER)
	draw_string(Palette.UI_FONT, auto_rect.position + Vector2(0, 57), loc("A / Y・△", "A / Y · TRIANGLE"), HORIZONTAL_ALIGNMENT_CENTER, auto_rect.size.x, 11, Palette.MUTED)

	var status := message if message_time > 0.0 else tutorial_hint()
	draw_string(Palette.UI_FONT, Vector2(448, 455), status, HORIZONTAL_ALIGNMENT_CENTER, 770, 14, Palette.AMBER if run.is_full() else Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(438, 482), loc("アップグレード — クリックまたは数字キー", "UPGRADES — CLICK OR USE NUMBER KEYS"), HORIZONTAL_ALIGNMENT_LEFT, 760, 12, Palette.MUTED)
	for index in range(upgrade_rects.size()):
		draw_upgrade(index)

	if discharge_wave > 0.0:
		var progress: float = 1.0 - discharge_wave
		draw_arc(Vector2(815, 245), 70.0 + progress * 410.0, 0.0, TAU, 64, Palette.with_alpha(Palette.AMBER if run.super_discharges > 0 else Palette.CYAN, discharge_wave * 0.8), 5.0)

func draw_cell(index: int) -> void:
	var rect := Rect2(452 + index * 125, 160, 106, 154)
	var ratio: float = run.cells[index] / maxf(1.0, run.capacity)
	var full := ratio >= 0.999
	var color: Color = Palette.AMBER if full else [Palette.CYAN, Palette.BLUE, Palette.VIOLET, Palette.MAGENTA, Palette.MINT, Palette.GREEN][index]
	if full:
		draw_style_box(Palette.rounded_box(Palette.with_alpha(color, 0.12 + sin(animation_time * 5.0 + index) * 0.05), 15), rect.grow(7.0))
	draw_style_box(Palette.rounded_box(Palette.INK, 13, Palette.with_alpha(color, 0.85 if full else 0.36), 2), rect)
	var inner := Rect2(rect.position + Vector2(8, 8), rect.size - Vector2(16, 16))
	if ratio > 0.0:
		var fill_height := inner.size.y * ratio
		var fill_rect := Rect2(Vector2(inner.position.x, inner.end.y - fill_height), Vector2(inner.size.x, fill_height))
		draw_style_box(Palette.rounded_box(Palette.with_alpha(color, 0.42 if not full else 0.68), 8), fill_rect)
		for stripe in range(3):
			var stripe_y := fill_rect.position.y + fmod(animation_time * 36.0 + stripe * 31.0, maxf(1.0, fill_rect.size.y))
			draw_line(Vector2(fill_rect.position.x + 5, stripe_y), Vector2(fill_rect.end.x - 5, stripe_y), Palette.with_alpha(Palette.PAPER, 0.18), 1.0)
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
	var background := Palette.with_alpha(color, 0.22 if hovered else 0.09 if affordable else 0.035)
	draw_style_box(Palette.rounded_box(background, 13, Palette.with_alpha(color, 0.95 if hovered else 0.5 if affordable else 0.23), 2 if hovered else 1), rect)
	draw_string(Palette.UI_FONT, rect.position + Vector2(10, 20), "%d" % (index + 1), HORIZONTAL_ALIGNMENT_LEFT, 22, 12, color)
	draw_string(Palette.UI_FONT, rect.position + Vector2(32, 20), str(copy.title), HORIZONTAL_ALIGNMENT_LEFT, 140, 12, Palette.PAPER)
	draw_string(Palette.UI_FONT, rect.position + Vector2(10, 44), str(copy.desc), HORIZONTAL_ALIGNMENT_LEFT, 164, 10, Palette.MUTED)
	draw_string(Palette.UI_FONT, rect.position + Vector2(10, 70), "LV.%d" % run.upgrade_level(id), HORIZONTAL_ALIGNMENT_LEFT, 72, 11, color)
	draw_string(Palette.UI_FONT, rect.position + Vector2(82, 70), "◆ %d" % run.upgrade_cost(id), HORIZONTAL_ALIGNMENT_RIGHT, 92, 12, Palette.AMBER if affordable else Palette.MUTED)

func draw_particles_and_text() -> void:
	for item in particles:
		var alpha := clampf(float(item.life) / maxf(0.01, float(item.max_life)), 0.0, 1.0)
		draw_circle(Vector2(item.pos), float(item.size) * alpha, Palette.with_alpha(Color(item.color), alpha))
	for item in floating_texts:
		var alpha := clampf(float(item.life) / maxf(0.01, float(item.max_life)), 0.0, 1.0)
		draw_string(Palette.UI_FONT, Vector2(item.pos) + Vector2(-150, 0), str(item.text), HORIZONTAL_ALIGNMENT_CENTER, 300, int(item.size), Palette.with_alpha(Color(item.color), alpha))
