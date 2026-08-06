extends Node2D

const Palette = preload("res://shared/palette.gd")
const Synth = preload("res://shared/synth.gd")
const ControllerConfig = preload("res://shared/controller_bindings.gd")
const ZeroPercentCity = preload("res://games/zero_percent_city/zero_percent_city.gd")
const Chargeback = preload("res://games/chargeback/chargeback.gd")
const CapacitorDefense = preload("res://games/capacitor_defense/capacitor_defense.gd")
const ChargeClicker = preload("res://games/charge_clicker/charge_clicker.gd")

const ZERO_ART = preload("res://assets/keyart/zero-percent-city.jpg")
const CHARGEBACK_ART = preload("res://assets/keyart/chargeback.jpg")
const CAPACITOR_ART = preload("res://assets/keyart/capacitor-defense.jpg")

var synth: JamSynth
var active_game: Node
var is_japanese := false
var menu_time := 0.0
var hover_index := 0
var controller_axis_latch := Vector2i.ZERO
var card_rects: Array[Rect2] = []
var stars: Array[Vector3] = []
var language_rect := Rect2(1074, 32, 162, 38)
var settings_button_rect := Rect2(884, 32, 176, 38)
var settings_close_rect := Rect2(816, 620, 168, 42)
var settings_reset_rect := Rect2(296, 620, 190, 42)
var settings_row_rects: Array[Rect2] = []
var controller_config
var controller_bindings: Dictionary = ControllerConfig.default_bindings()
var settings_open := false
var settings_selected := 0
var waiting_for_action := ""
var settings_message := ""
var settings_message_time := 0.0

func _ready() -> void:
	is_japanese = OS.get_locale_language().to_lower().begins_with("ja")
	synth = Synth.new()
	add_child(synth)
	controller_config = ControllerConfig.new()
	controller_config.load_settings()
	controller_bindings = controller_config.bindings.duplicate(true)
	for index in range(80):
		stars.append(Vector3(fmod(index * 173.0, 1280.0), fmod(index * 97.0, 720.0), 0.2 + fmod(index * 0.137, 0.8)))
	card_rects = [
		Rect2(26, 184, 292, 452),
		Rect2(338, 184, 292, 452),
		Rect2(650, 184, 292, 452),
		Rect2(962, 184, 292, 452),
	]
	for index in range(ControllerConfig.ACTIONS.size()):
		settings_row_rects.append(Rect2(296, 168 + index * 50, 688, 44))
	queue_redraw()
	if should_auto_launch_art_preview():
		call_deferred("launch_game", 3)

func should_auto_launch_art_preview() -> bool:
	if not OS.has_feature("web"):
		return false
	var window = JavaScriptBridge.get_interface("window")
	if window == null:
		return false
	var raw_query := str(window.location.search).trim_prefix("?")
	for pair in raw_query.split("&", false):
		var parts := pair.split("=", true, 1)
		if parts.size() == 2 and str(parts[0]) == "game" and str(parts[1]) == "project-charge":
			return true
	return false

func _process(delta: float) -> void:
	menu_time += delta
	if settings_message_time > 0.0:
		settings_message_time -= delta
	if active_game == null:
		queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if settings_open:
		handle_settings_input(event)
		return
	if active_game != null:
		if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
			return_to_menu()
		elif event is InputEventJoypadButton and event.pressed and event.button_index == controller_button("back"):
			return_to_menu()
		return
	if event is InputEventMouseMotion:
		hover_index = card_at(event.position)
		queue_redraw()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if language_rect.has_point(event.position):
			toggle_language()
		elif settings_button_rect.has_point(event.position):
			open_settings()
		else:
			var clicked := card_at(event.position)
			if clicked >= 0:
				launch_game(clicked)
	elif event is InputEventScreenTouch and event.pressed:
		if language_rect.has_point(event.position):
			toggle_language()
		elif settings_button_rect.has_point(event.position):
			open_settings()
		else:
			var touched := card_at(event.position)
			if touched >= 0:
				launch_game(touched)
	elif event is InputEventJoypadMotion:
		handle_controller_motion(event)
	elif event is InputEventJoypadButton and event.pressed:
		if event.button_index in [JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_UP]:
			navigate_menu(-1)
		elif event.button_index in [JOY_BUTTON_DPAD_RIGHT, JOY_BUTTON_DPAD_DOWN]:
			navigate_menu(1)
		elif event.button_index == controller_button("primary"):
			launch_game(maxi(0, hover_index))
		elif event.button_index == controller_button("language"):
			toggle_language()
		elif event.button_index == controller_button("menu"):
			open_settings()
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_L:
			toggle_language()
		elif event.keycode in [KEY_F1, KEY_C]:
			open_settings()
		elif event.keycode in [KEY_LEFT, KEY_UP]:
			navigate_menu(-1)
		elif event.keycode in [KEY_RIGHT, KEY_DOWN]:
			navigate_menu(1)
		elif event.keycode in [KEY_ENTER, KEY_SPACE]:
			launch_game(maxi(0, hover_index))
		elif event.keycode in [KEY_1, KEY_KP_1]:
			launch_game(0)
		elif event.keycode in [KEY_2, KEY_KP_2]:
			launch_game(1)
		elif event.keycode in [KEY_3, KEY_KP_3]:
			launch_game(2)
		elif event.keycode in [KEY_4, KEY_KP_4]:
			launch_game(3)

func navigate_menu(direction: int) -> void:
	if card_rects.is_empty():
		return
	hover_index = wrapi((0 if hover_index < 0 else hover_index) + direction, 0, card_rects.size())
	synth.click()
	queue_redraw()

func handle_controller_motion(event: InputEventJoypadMotion) -> void:
	if event.axis == JOY_AXIS_LEFT_X:
		if absf(event.axis_value) < 0.45:
			controller_axis_latch.x = 0
		elif controller_axis_latch.x == 0:
			controller_axis_latch.x = 1 if event.axis_value > 0.0 else -1
			navigate_menu(controller_axis_latch.x)
	elif event.axis == JOY_AXIS_LEFT_Y:
		if absf(event.axis_value) < 0.45:
			controller_axis_latch.y = 0
		elif controller_axis_latch.y == 0:
			controller_axis_latch.y = 1 if event.axis_value > 0.0 else -1
			navigate_menu(controller_axis_latch.y)

func controller_button(action: String) -> int:
	return int(controller_bindings.get(action, ControllerConfig.DEFAULTS.get(action, JOY_BUTTON_A)))

func open_settings() -> void:
	if active_game != null:
		return
	settings_open = true
	settings_selected = clampi(settings_selected, 0, ControllerConfig.ACTIONS.size() - 1)
	waiting_for_action = ""
	settings_message = loc("変更する項目を選択してください", "SELECT AN ACTION TO REBIND")
	settings_message_time = 2.5
	synth.click()
	queue_redraw()

func close_settings() -> void:
	settings_open = false
	waiting_for_action = ""
	controller_axis_latch = Vector2i.ZERO
	synth.click()
	queue_redraw()

func handle_settings_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var hovered := settings_row_at(event.position)
		if hovered >= 0:
			settings_selected = hovered
		queue_redraw()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		handle_settings_point(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		handle_settings_point(event.position)
	elif event is InputEventJoypadMotion:
		handle_settings_motion(event)
	elif event is InputEventJoypadButton and event.pressed:
		if not waiting_for_action.is_empty():
			capture_controller_button(event.button_index)
		elif event.button_index == controller_button("back") or event.button_index == controller_button("menu"):
			close_settings()
		elif event.button_index in [JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_LEFT]:
			move_settings_selection(-1)
		elif event.button_index in [JOY_BUTTON_DPAD_DOWN, JOY_BUTTON_DPAD_RIGHT]:
			move_settings_selection(1)
		elif event.button_index == controller_button("primary"):
			start_rebinding(settings_selected)
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			if waiting_for_action.is_empty():
				close_settings()
			else:
				waiting_for_action = ""
				settings_message = loc("割り当て変更をキャンセルしました", "REBIND CANCELLED")
				settings_message_time = 1.5
		elif event.keycode in [KEY_UP, KEY_LEFT]:
			move_settings_selection(-1)
		elif event.keycode in [KEY_DOWN, KEY_RIGHT]:
			move_settings_selection(1)
		elif event.keycode in [KEY_ENTER, KEY_SPACE]:
			start_rebinding(settings_selected)
		elif event.keycode == KEY_R:
			reset_controller_bindings()

func handle_settings_point(point: Vector2) -> void:
	if settings_close_rect.has_point(point):
		close_settings()
		return
	if settings_reset_rect.has_point(point):
		reset_controller_bindings()
		return
	var selected := settings_row_at(point)
	if selected >= 0:
		settings_selected = selected
		start_rebinding(selected)

func settings_row_at(point: Vector2) -> int:
	for index in range(settings_row_rects.size()):
		if settings_row_rects[index].has_point(point):
			return index
	return -1

func handle_settings_motion(event: InputEventJoypadMotion) -> void:
	if not waiting_for_action.is_empty():
		return
	if event.axis == JOY_AXIS_LEFT_X:
		if absf(event.axis_value) < 0.45:
			controller_axis_latch.x = 0
		elif controller_axis_latch.x == 0:
			controller_axis_latch.x = 1 if event.axis_value > 0.0 else -1
			move_settings_selection(controller_axis_latch.x)
	elif event.axis == JOY_AXIS_LEFT_Y:
		if absf(event.axis_value) < 0.45:
			controller_axis_latch.y = 0
		elif controller_axis_latch.y == 0:
			controller_axis_latch.y = 1 if event.axis_value > 0.0 else -1
			move_settings_selection(controller_axis_latch.y)

func move_settings_selection(direction: int) -> void:
	settings_selected = wrapi(settings_selected + direction, 0, ControllerConfig.ACTIONS.size())
	synth.click()
	queue_redraw()

func start_rebinding(index: int) -> void:
	if index < 0 or index >= ControllerConfig.ACTIONS.size():
		return
	waiting_for_action = str(ControllerConfig.ACTIONS[index].id)
	settings_message = loc("割り当てるゲームパッドボタンを押してください  •  ESCで中止", "PRESS A GAMEPAD BUTTON  •  ESC CANCELS")
	settings_message_time = 999.0
	synth.confirm()
	queue_redraw()

func capture_controller_button(button: int, save_after: bool = true) -> void:
	if not ControllerConfig.is_allowed(button):
		settings_message = loc("方向キーは移動・選択用として固定されています", "D-PAD IS RESERVED FOR MOVEMENT AND NAVIGATION")
		settings_message_time = 2.2
		synth.error()
		return
	if controller_config.rebind(waiting_for_action, button, save_after):
		controller_bindings = controller_config.bindings.duplicate(true)
		settings_message = loc("割り当てを保存しました", "BINDING SAVED")
		settings_message_time = 1.8
		waiting_for_action = ""
		synth.confirm()
		queue_redraw()

func reset_controller_bindings() -> void:
	controller_config.reset_defaults()
	controller_bindings = controller_config.bindings.duplicate(true)
	waiting_for_action = ""
	settings_message = loc("初期設定に戻しました", "DEFAULT BINDINGS RESTORED")
	settings_message_time = 1.8
	synth.confirm()
	queue_redraw()

func card_at(point: Vector2) -> int:
	for index in range(card_rects.size()):
		if card_rects[index].has_point(point):
			return index
	return -1

func launch_game(index: int) -> void:
	if active_game != null:
		return
	synth.confirm()
	match index:
		0:
			active_game = ZeroPercentCity.new()
		1:
			active_game = Chargeback.new()
		2:
			active_game = CapacitorDefense.new()
		3:
			active_game = ChargeClicker.new()
		_:
			return
	active_game.set("is_japanese", is_japanese)
	active_game.set("controller_bindings", controller_bindings.duplicate(true))
	active_game.return_to_menu.connect(return_to_menu)
	if active_game.has_signal("language_changed"):
		active_game.connect("language_changed", sync_language)
	add_child(active_game)
	queue_redraw()

func sync_language(value: bool) -> void:
	is_japanese = value
	queue_redraw()

func toggle_language() -> void:
	is_japanese = not is_japanese
	synth.click()
	queue_redraw()

func loc(japanese: String, english: String) -> String:
	return japanese if is_japanese else english

func return_to_menu() -> void:
	if active_game == null:
		return
	active_game.queue_free()
	active_game = null
	hover_index = 0
	synth.click()
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1280, 720), Palette.INK)
	if active_game != null:
		return
	for star in stars:
		var pulse := 0.45 + sin(menu_time * (0.7 + star.z) + star.x) * 0.25
		draw_circle(Vector2(star.x, star.y), 0.8 + star.z * 1.3, Palette.with_alpha(Palette.CYAN, pulse * star.z))
	for x in range(-100, 1400, 80):
		draw_line(Vector2(x + fmod(menu_time * 10.0, 80.0), 0), Vector2(x - 260 + fmod(menu_time * 10.0, 80.0), 720), Palette.with_alpha(Palette.BLUE, 0.055), 1.0)

	draw_string(Palette.UI_FONT, Vector2(48, 58), "AI BROWSER GAME JAM 4", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Palette.MUTED)
	draw_string(Palette.UI_FONT, Vector2(48, 114), loc("CHARGE! // 4つのゲーム実験室", "CHARGE! // FOUR GAME LAB"), HORIZONTAL_ALIGNMENT_LEFT, -1, 42, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(48, 151), loc("3本の縦切り版と、新しいアクティブクリッカー。", "Three vertical slices plus a new active-clicker contender."), HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Palette.MUTED)
	draw_settings_button()
	draw_language_toggle()

	draw_card(0, "ZERO PERCENT CITY", loc("ミニメトロイドヴァニア", "MINI METROIDVANIA"), ZERO_ART, Palette.CYAN, [loc("3段攻撃で電力を奪還", "Recycle power with combos"), loc("移動能力を解放", "Unlock traversal modules"), loc("コア防衛機を撃破", "Break the Core Warden")])
	draw_card(1, "CHARGEBACK", loc("デッキ構築ローグライク", "DECK-BUILDING ROGUELIKE"), CHARGEBACK_ART, Palette.MINT, [loc("3つの信用方針", "Choose a credit policy"), loc("カード系統を連携", "Chain card synergies"), loc("証拠カードを強化", "Draft upgraded evidence")])
	draw_card(2, "CAPACITOR DEFENSE", loc("回路タワーディフェンス", "CIRCUIT TOWER DEFENSE"), CAPACITOR_ART, Palette.VIOLET, [loc("電力パケットを配線", "Route power packets"), loc("設備でネットワーク共振", "Build resonant networks"), loc("3倍速と過駆動", "Use 3× speed + Overdrive")])
	draw_card(3, "PROJECT CHARGE", loc("機械魔獣ハント・クリッカー", "MECHANICAL HUNT CLICKER"), null, Palette.AMBER, [loc("一撃ごとに攻撃と蓄電", "Every strike attacks + charges"), loc("5ギア・257段階の武装構築", "Build 5 gears across 257 ranks"), loc("6体の魔獣から真ボスへ", "Hunt 6 beasts, then the true boss")])

	draw_string(Palette.UI_FONT, Vector2(48, 686), loc("1〜4・矢印・ゲームパッドで選択  •  F1で操作設定", "SELECT: 1–4, ARROWS, OR GAMEPAD  •  F1 OPENS CONTROLS"), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Palette.MUTED)
	if settings_open:
		draw_settings()

func draw_card(index: int, title: String, genre: String, texture: Texture2D, accent: Color, bullets: Array[String]) -> void:
	var rect := card_rects[index]
	var hovered := hover_index == index
	var lift := -8.0 if hovered else 0.0
	rect.position.y += lift
	var glow_rect := rect.grow(5.0 if hovered else 2.0)
	draw_style_box(Palette.rounded_box(Palette.with_alpha(accent, 0.16 if hovered else 0.07), 24), glow_rect)
	draw_style_box(Palette.rounded_box(Palette.PANEL, 20, Palette.with_alpha(accent, 0.85 if hovered else 0.35), 2), rect)
	var image_rect := Rect2(rect.position + Vector2(14, 14), Vector2(rect.size.x - 28, 198))
	if texture != null:
		draw_texture_rect(texture, image_rect, false, Color(0.92, 0.96, 1.0, 1.0))
	else:
		draw_charge_preview(image_rect, accent)
	draw_rect(image_rect, Color(0.03, 0.06, 0.12, 0.22))
	draw_string(Palette.UI_FONT, rect.position + Vector2(20, 246), genre, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, accent)
	draw_string(Palette.UI_FONT, rect.position + Vector2(20, 282), title, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 40, 20, Palette.PAPER)
	for bullet_index in range(bullets.size()):
		var y := rect.position.y + 322 + bullet_index * 31
		draw_circle(Vector2(rect.position.x + 25, y - 5), 3.5, accent)
		draw_string(Palette.UI_FONT, Vector2(rect.position.x + 39, y), bullets[bullet_index], HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 58, 13, Palette.MUTED)
	var button_rect := Rect2(rect.position + Vector2(20, 402), Vector2(rect.size.x - 40, 34))
	draw_style_box(Palette.rounded_box(accent if hovered else Palette.PANEL_2, 10), button_rect)
	var play_label := loc("討伐を始める", "BEGIN THE HUNT") if index == 3 else loc("プレイする", "PLAY PROTOTYPE")
	draw_string(Palette.UI_FONT, button_rect.position + Vector2(0, 23), play_label, HORIZONTAL_ALIGNMENT_CENTER, button_rect.size.x, 15, Palette.INK if hovered else Palette.PAPER)

func draw_charge_preview(rect: Rect2, accent: Color) -> void:
	draw_rect(rect, Color("07101e"))
	var center := rect.get_center() - Vector2(0, 12)
	for ring in range(4):
		draw_arc(center, 40.0 + ring * 11.0, -PI * 0.7 + menu_time * (0.3 + ring * 0.08), PI * 1.2 + menu_time * (0.3 + ring * 0.08), 36, Palette.with_alpha(accent, 0.7 - ring * 0.12), 3.0)
	draw_circle(center, 30.0 + sin(menu_time * 3.0) * 2.0, Palette.with_alpha(accent, 0.3))
	for index in range(5):
		var angle := -PI * 0.82 + float(index) * PI * 0.41
		var gear_center := center + Vector2(cos(angle), sin(angle)) * 78.0
		draw_line(center, gear_center, Palette.with_alpha(accent, 0.28), 2.0)
		draw_circle(gear_center, 10.0, Palette.with_alpha(accent, 0.18 + index * 0.06))
		draw_arc(gear_center, 10.0, 0.0, TAU, 12, accent, 1.5)

func draw_language_toggle() -> void:
	draw_style_box(Palette.rounded_box(Palette.PANEL, 10, Palette.with_alpha(Palette.CYAN, 0.5), 1), language_rect)
	draw_string(Palette.UI_FONT, language_rect.position + Vector2(0, 25), "日本語  /  EN" if is_japanese else "JP  /  ENGLISH", HORIZONTAL_ALIGNMENT_CENTER, language_rect.size.x, 14, Palette.PAPER)

func draw_settings_button() -> void:
	draw_style_box(Palette.rounded_box(Palette.PANEL, 10, Palette.with_alpha(Palette.VIOLET, 0.65), 1), settings_button_rect)
	draw_string(Palette.UI_FONT, settings_button_rect.position + Vector2(0, 25), loc("ゲームパッド設定", "GAMEPAD SETUP"), HORIZONTAL_ALIGNMENT_CENTER, settings_button_rect.size.x, 14, Palette.PAPER)

func draw_settings() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color(0.01, 0.02, 0.05, 0.9))
	var panel := Rect2(260, 58, 760, 624)
	draw_style_box(Palette.rounded_box(Palette.PANEL, 24, Palette.VIOLET, 2), panel)
	draw_string(Palette.UI_FONT, Vector2(296, 106), loc("ゲームパッド設定", "GAMEPAD SETUP"), HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(296, 140), loc("方向キーと左スティックは移動・選択用として固定。変更は自動保存されます。", "D-PAD AND LEFT STICK STAY FIXED. CHANGES SAVE AUTOMATICALLY."), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Palette.MUTED)
	for index in range(ControllerConfig.ACTIONS.size()):
		var action: Dictionary = ControllerConfig.ACTIONS[index]
		var row := settings_row_rects[index]
		var selected := index == settings_selected
		var waiting := str(action.id) == waiting_for_action
		var accent := Palette.AMBER if waiting else Palette.CYAN if selected else Palette.VIOLET
		draw_style_box(Palette.rounded_box(Palette.PANEL_2 if selected or waiting else Palette.INK, 12, Palette.with_alpha(accent, 0.95 if selected or waiting else 0.32), 2 if selected or waiting else 1), row)
		draw_string(Palette.UI_FONT, row.position + Vector2(18, 28), str(action.ja if is_japanese else action.en), HORIZONTAL_ALIGNMENT_LEFT, 420, 15, Palette.PAPER)
		var button_rect := Rect2(row.position + Vector2(468, 6), Vector2(202, 32))
		draw_style_box(Palette.rounded_box(accent if waiting else Palette.PANEL, 9, accent, 1), button_rect)
		var button_text := loc("入力待ち…", "PRESS BUTTON…") if waiting else ControllerConfig.button_label(controller_button(str(action.id)))
		draw_string(Palette.UI_FONT, button_rect.position + Vector2(0, 22), button_text, HORIZONTAL_ALIGNMENT_CENTER, button_rect.size.x, 13, Palette.INK if waiting else Palette.PAPER)
	var status := settings_message if settings_message_time > 0.0 else loc("項目を選び、決定ボタンを押してください", "SELECT A ROW, THEN PRESS CONFIRM")
	draw_string(Palette.UI_FONT, Vector2(296, 600), status, HORIZONTAL_ALIGNMENT_LEFT, 688, 14, Palette.AMBER if not waiting_for_action.is_empty() else Palette.MUTED)
	draw_style_box(Palette.rounded_box(Palette.PANEL_2, 10, Palette.CORAL, 1), settings_reset_rect)
	draw_string(Palette.UI_FONT, settings_reset_rect.position + Vector2(0, 27), loc("R：初期設定に戻す", "R: RESTORE DEFAULTS"), HORIZONTAL_ALIGNMENT_CENTER, settings_reset_rect.size.x, 14, Palette.PAPER)
	draw_style_box(Palette.rounded_box(Palette.CYAN, 10), settings_close_rect)
	draw_string(Palette.UI_FONT, settings_close_rect.position + Vector2(0, 27), loc("閉じる", "CLOSE"), HORIZONTAL_ALIGNMENT_CENTER, settings_close_rect.size.x, 14, Palette.INK)
