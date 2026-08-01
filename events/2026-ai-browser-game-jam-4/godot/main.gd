extends Node2D

const Palette = preload("res://shared/palette.gd")
const Synth = preload("res://shared/synth.gd")
const ZeroPercentCity = preload("res://games/zero_percent_city/zero_percent_city.gd")
const Chargeback = preload("res://games/chargeback/chargeback.gd")
const CapacitorDefense = preload("res://games/capacitor_defense/capacitor_defense.gd")

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

func _ready() -> void:
	is_japanese = OS.get_locale_language().to_lower().begins_with("ja")
	synth = Synth.new()
	add_child(synth)
	for index in range(80):
		stars.append(Vector3(fmod(index * 173.0, 1280.0), fmod(index * 97.0, 720.0), 0.2 + fmod(index * 0.137, 0.8)))
	card_rects = [
		Rect2(44, 184, 376, 452),
		Rect2(452, 184, 376, 452),
		Rect2(860, 184, 376, 452),
	]
	queue_redraw()

func _process(delta: float) -> void:
	menu_time += delta
	if active_game == null:
		queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if active_game != null:
		if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
			return_to_menu()
		elif event is InputEventJoypadButton and event.pressed and event.button_index in [JOY_BUTTON_B, JOY_BUTTON_BACK]:
			return_to_menu()
		return
	if event is InputEventMouseMotion:
		hover_index = card_at(event.position)
		queue_redraw()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if language_rect.has_point(event.position):
			toggle_language()
		else:
			var clicked := card_at(event.position)
			if clicked >= 0:
				launch_game(clicked)
	elif event is InputEventScreenTouch and event.pressed:
		if language_rect.has_point(event.position):
			toggle_language()
		else:
			var touched := card_at(event.position)
			if touched >= 0:
				launch_game(touched)
	elif event is InputEventJoypadMotion:
		handle_controller_motion(event)
	elif event is InputEventJoypadButton and event.pressed:
		match event.button_index:
			JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_UP:
				navigate_menu(-1)
			JOY_BUTTON_DPAD_RIGHT, JOY_BUTTON_DPAD_DOWN:
				navigate_menu(1)
			JOY_BUTTON_A, JOY_BUTTON_START:
				launch_game(maxi(0, hover_index))
			JOY_BUTTON_Y:
				toggle_language()
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_L:
			toggle_language()
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
	active_game.set("is_japanese", is_japanese)
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
	draw_string(Palette.UI_FONT, Vector2(48, 114), loc("CHARGE! // 3つのゲーム実験室", "CHARGE! // THREE GAME LAB"), HORIZONTAL_ALIGNMENT_LEFT, -1, 42, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(48, 151), loc("3本を遊び比べて、応募作を選ぼう。", "Three polished vertical slices. Play them all, then choose the submission."), HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Palette.MUTED)
	draw_language_toggle()

	draw_card(0, "ZERO PERCENT CITY", loc("ミニメトロイドヴァニア", "MINI METROIDVANIA"), ZERO_ART, Palette.CYAN, [loc("借り物の電力で探索", "Explore on borrowed power"), loc("ダッシュと二段ジャンプを解放", "Unlock dash + double jump"), loc("都市のコアを目指す", "Reach the city core")])
	draw_card(1, "CHARGEBACK", loc("デッキ構築ローグライク", "DECK-BUILDING ROGUELIKE"), CHARGEBACK_ART, Palette.MINT, [loc("不正請求に異議を申し立てる", "Dispute hostile charges"), loc("借金をダメージに変える", "Turn debt into damage"), loc("悪質な請求元を倒す", "Defeat predatory billing")])
	draw_card(2, "CAPACITOR DEFENSE", loc("回路タワーディフェンス", "CIRCUIT TOWER DEFENSE"), CAPACITOR_ART, Palette.VIOLET, [loc("電力パケットを配線", "Route visible power packets"), loc("蓄電して一気に放電", "Store energy for bursts"), loc("リアクターを守り抜く", "Protect the reactor")])

	draw_string(Palette.UI_FONT, Vector2(48, 686), loc("1 / 2 / 3・矢印・ゲームパッドで選択  •  ESC / Bで戻る", "SELECT: 1 / 2 / 3, ARROWS, OR GAMEPAD  •  ESC / B RETURNS"), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Palette.MUTED)

func draw_card(index: int, title: String, genre: String, texture: Texture2D, accent: Color, bullets: Array[String]) -> void:
	var rect := card_rects[index]
	var hovered := hover_index == index
	var lift := -8.0 if hovered else 0.0
	rect.position.y += lift
	var glow_rect := rect.grow(5.0 if hovered else 2.0)
	draw_style_box(Palette.rounded_box(Palette.with_alpha(accent, 0.16 if hovered else 0.07), 24), glow_rect)
	draw_style_box(Palette.rounded_box(Palette.PANEL, 20, Palette.with_alpha(accent, 0.85 if hovered else 0.35), 2), rect)
	var image_rect := Rect2(rect.position + Vector2(14, 14), Vector2(rect.size.x - 28, 198))
	draw_texture_rect(texture, image_rect, false, Color(0.92, 0.96, 1.0, 1.0))
	draw_rect(image_rect, Color(0.03, 0.06, 0.12, 0.22))
	draw_string(Palette.UI_FONT, rect.position + Vector2(20, 246), genre, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, accent)
	draw_string(Palette.UI_FONT, rect.position + Vector2(20, 282), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Palette.PAPER)
	for bullet_index in range(bullets.size()):
		var y := rect.position.y + 322 + bullet_index * 31
		draw_circle(Vector2(rect.position.x + 25, y - 5), 3.5, accent)
		draw_string(Palette.UI_FONT, Vector2(rect.position.x + 39, y), bullets[bullet_index], HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Palette.MUTED)
	var button_rect := Rect2(rect.position + Vector2(20, 402), Vector2(rect.size.x - 40, 34))
	draw_style_box(Palette.rounded_box(accent if hovered else Palette.PANEL_2, 10), button_rect)
	draw_string(Palette.UI_FONT, button_rect.position + Vector2(0, 23), loc("プレイする", "PLAY PROTOTYPE"), HORIZONTAL_ALIGNMENT_CENTER, button_rect.size.x, 15, Palette.INK if hovered else Palette.PAPER)

func draw_language_toggle() -> void:
	draw_style_box(Palette.rounded_box(Palette.PANEL, 10, Palette.with_alpha(Palette.CYAN, 0.5), 1), language_rect)
	draw_string(Palette.UI_FONT, language_rect.position + Vector2(0, 25), "日本語  /  EN" if is_japanese else "JP  /  ENGLISH", HORIZONTAL_ALIGNMENT_CENTER, language_rect.size.x, 14, Palette.PAPER)
