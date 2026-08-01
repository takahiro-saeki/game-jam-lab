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
var menu_time := 0.0
var hover_index := -1
var card_rects: Array[Rect2] = []
var stars: Array[Vector3] = []

func _ready() -> void:
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
		return
	if event is InputEventMouseMotion:
		hover_index = card_at(event.position)
		queue_redraw()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var clicked := card_at(event.position)
		if clicked >= 0:
			launch_game(clicked)
	elif event is InputEventScreenTouch and event.pressed:
		var touched := card_at(event.position)
		if touched >= 0:
			launch_game(touched)
	elif event is InputEventKey and event.pressed:
		if event.keycode in [KEY_1, KEY_KP_1]:
			launch_game(0)
		elif event.keycode in [KEY_2, KEY_KP_2]:
			launch_game(1)
		elif event.keycode in [KEY_3, KEY_KP_3]:
			launch_game(2)

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
	active_game.return_to_menu.connect(return_to_menu)
	add_child(active_game)
	queue_redraw()

func return_to_menu() -> void:
	if active_game == null:
		return
	active_game.queue_free()
	active_game = null
	hover_index = -1
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

	draw_string(ThemeDB.fallback_font, Vector2(48, 58), "AI BROWSER GAME JAM 4", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Palette.MUTED)
	draw_string(ThemeDB.fallback_font, Vector2(48, 114), "CHARGE! // THREE GAME LAB", HORIZONTAL_ALIGNMENT_LEFT, -1, 42, Palette.PAPER)
	draw_string(ThemeDB.fallback_font, Vector2(48, 151), "Three polished vertical slices. Play them all, then choose the submission.", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Palette.MUTED)

	draw_card(0, "ZERO PERCENT CITY", "MINI METROIDVANIA", ZERO_ART, Palette.CYAN, ["Explore on borrowed power", "Unlock dash + double jump", "Reach the city core"])
	draw_card(1, "CHARGEBACK", "DECK-BUILDING ROGUELIKE", CHARGEBACK_ART, Palette.MINT, ["Dispute hostile charges", "Turn debt into damage", "Defeat predatory billing"])
	draw_card(2, "CAPACITOR DEFENSE", "CIRCUIT TOWER DEFENSE", CAPACITOR_ART, Palette.VIOLET, ["Route visible power packets", "Store energy for bursts", "Protect the reactor"])

	draw_string(ThemeDB.fallback_font, Vector2(48, 686), "SELECT WITH 1 / 2 / 3 OR TAP A CARD  •  ESC RETURNS TO THIS LAB", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Palette.MUTED)

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
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(20, 246), genre, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, accent)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(20, 282), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Palette.PAPER)
	for bullet_index in range(bullets.size()):
		var y := rect.position.y + 322 + bullet_index * 31
		draw_circle(Vector2(rect.position.x + 25, y - 5), 3.5, accent)
		draw_string(ThemeDB.fallback_font, Vector2(rect.position.x + 39, y), bullets[bullet_index], HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Palette.MUTED)
	var button_rect := Rect2(rect.position + Vector2(20, 402), Vector2(rect.size.x - 40, 34))
	draw_style_box(Palette.rounded_box(accent if hovered else Palette.PANEL_2, 10), button_rect)
	draw_string(ThemeDB.fallback_font, button_rect.position + Vector2(0, 23), "PLAY PROTOTYPE", HORIZONTAL_ALIGNMENT_CENTER, button_rect.size.x, 15, Palette.INK if hovered else Palette.PAPER)
