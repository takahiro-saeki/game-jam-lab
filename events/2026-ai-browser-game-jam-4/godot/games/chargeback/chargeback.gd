extends Node2D

signal return_to_menu

const Palette = preload("res://shared/palette.gd")
const Synth = preload("res://shared/synth.gd")
const KEY_ART = preload("res://assets/keyart/chargeback.jpg")

enum GameState { INTRO, PLAYER_TURN, ENEMY_TURN, REWARD, WON, LOST }

const VIEW := Vector2(1280, 720)

var synth: JamSynth
var state := GameState.INTRO
var run_turns := 0
var encounter := 0
var credit := 100
var max_credit := 100
var energy := 3
var shield := 0
var counter := 0
var enemy: Dictionary = {}
var enemy_intent := 0
var enemy_intent_name := ""
var enemy_weak := 0
var enemy_vulnerable := 0
var deck: Array[Dictionary] = []
var draw_pile: Array[Dictionary] = []
var discard_pile: Array[Dictionary] = []
var hand: Array[Dictionary] = []
var reward_cards: Array[Dictionary] = []
var card_rects: Array[Rect2] = []
var reward_rects: Array[Rect2] = []
var end_turn_rect := Rect2(1084, 416, 166, 54)
var menu_rect := Rect2(1100, 18, 154, 38)
var enemy_delay := 0.0
var animation_time := 0.0
var screen_shake := 0.0
var screen_flash := 0.0
var banner := ""
var banner_time := 0.0
var floating_texts: Array[Dictionary] = []
var sparks: Array[Dictionary] = []
var hover_card := -1
var tutorial_step := 0

func _ready() -> void:
	synth = Synth.new()
	add_child(synth)
	queue_redraw()

func _process(delta: float) -> void:
	animation_time += delta
	if screen_shake > 0.0: screen_shake = maxf(0.0, screen_shake - delta)
	if screen_flash > 0.0: screen_flash = maxf(0.0, screen_flash - delta)
	if banner_time > 0.0: banner_time -= delta
	update_effects(delta)
	if state == GameState.ENEMY_TURN:
		enemy_delay -= delta
		if enemy_delay <= 0.0:
			resolve_enemy_turn()
	queue_redraw()

func all_cards() -> Array[Dictionary]:
	return [
		card("dispute", "DISPUTE", 1, "Gain 9 BLOCK.", Palette.CYAN),
		card("freeze", "FREEZE ACCOUNT", 1, "Gain 5 BLOCK. Enemy deals 3 less next turn.", Palette.BLUE),
		card("cashback", "CASHBACK", 1, "Deal 5. Restore 4 CREDIT.", Palette.MINT),
		card("chargeback", "CHARGEBACK", 2, "Deal 14 + 1 per 10 missing CREDIT.", Palette.CORAL),
		card("fraud_alert", "FRAUD ALERT", 1, "Gain 5 BLOCK. Return 8 damage if charged.", Palette.AMBER),
		card("autopay", "AUTOPAY", 0, "Gain 1 ENERGY. Draw 1. Lose 2 CREDIT.", Palette.VIOLET),
		card("audit", "FORENSIC AUDIT", 1, "Deal 4. Draw 2.", Palette.MAGENTA),
		card("interest", "INTEREST TRAP", 1, "Deal 7. Next hit deals +50%.", Palette.CORAL),
		card("limit", "LIMIT INCREASE", 2, "Max CREDIT +5. Gain 12 BLOCK.", Palette.CYAN),
		card("refund", "FULL REFUND", 2, "Deal 8. Restore 11 CREDIT.", Palette.MINT),
		card("bankruptcy", "TACTICAL DEFAULT", 3, "Lose 7 CREDIT. Deal 32.", Palette.AMBER),
	]

func card(id: String, title: String, cost: int, description: String, color: Color) -> Dictionary:
	return {"id": id, "title": title, "cost": cost, "description": description, "color": color}

func initial_deck() -> Array[Dictionary]:
	var pool := all_cards()
	var cards: Array[Dictionary] = []
	for index in range(4): cards.append(find_card(pool, "dispute").duplicate())
	for index in range(3): cards.append(find_card(pool, "cashback").duplicate())
	for index in range(2): cards.append(find_card(pool, "chargeback").duplicate())
	cards.append(find_card(pool, "fraud_alert").duplicate())
	cards.append(find_card(pool, "autopay").duplicate())
	return cards

func find_card(pool: Array[Dictionary], id: String) -> Dictionary:
	for item in pool:
		if item.id == id: return item
	return {}

func start_run() -> void:
	state = GameState.PLAYER_TURN
	encounter = 0
	credit = 100
	max_credit = 100
	run_turns = 0
	deck = initial_deck()
	tutorial_step = 1
	start_encounter()
	synth.play_chord([220.0, 329.63, 440.0], 0.22, -23.0)

func start_encounter() -> void:
	var encounters := [
		{"name": "FREE TRIAL HYDRA", "subtitle": "CANCEL BUTTON: MISSING", "hp": 58, "max_hp": 58, "patterns": [8, 11, 6, 14], "color": Palette.MAGENTA},
		{"name": "CONVENIENCE CORP.", "subtitle": "FEE FOR VIEWING THIS FEE", "hp": 88, "max_hp": 88, "patterns": [10, 7, 16, 12], "color": Palette.AMBER},
		{"name": "MEGACART PRIME", "subtitle": "FINAL AUTHORIZATION PENDING", "hp": 142, "max_hp": 142, "patterns": [12, 18, 9, 24, 15], "color": Palette.CORAL},
	]
	enemy = encounters[encounter].duplicate(true)
	enemy.turn = 0
	enemy_weak = 0
	enemy_vulnerable = 0
	shield = 0
	counter = 0
	draw_pile = deck.duplicate(true)
	draw_pile.shuffle()
	discard_pile.clear()
	hand.clear()
	show_banner("AUTHORIZATION %d / 3" % (encounter + 1), 1.8)
	start_player_turn()

func start_player_turn() -> void:
	state = GameState.PLAYER_TURN
	run_turns += 1
	energy = 3
	shield = 0
	counter = 0
	draw_cards(5 - hand.size())
	set_enemy_intent()

func set_enemy_intent() -> void:
	var pattern: Array = enemy.patterns
	var base: int = pattern[int(enemy.turn) % pattern.size()]
	if enemy_weak > 0:
		base = maxi(0, base - 3)
		enemy_weak -= 1
	enemy_intent = base
	var names := ["RECURRING CHARGE", "HIDDEN SURCHARGE", "EXPEDITED FEE", "DYNAMIC MARKUP"]
	enemy_intent_name = names[int(enemy.turn) % names.size()]

func draw_cards(amount: int) -> void:
	for count in range(amount):
		if draw_pile.is_empty():
			if discard_pile.is_empty(): return
			draw_pile = discard_pile.duplicate(true)
			draw_pile.shuffle()
			discard_pile.clear()
		sparks.append({"pos": Vector2(89, 637), "vel": Vector2(randf_range(80, 170), randf_range(-160, -80)), "life": 0.5, "color": Palette.MINT})
		hand.append(draw_pile.pop_back())
	update_card_rects()

func update_card_rects() -> void:
	card_rects.clear()
	var count := hand.size()
	if count == 0: return
	var width := 190.0
	var gap := minf(22.0, (1000.0 - width * count) / maxf(1.0, count - 1.0))
	var total := width * count + gap * (count - 1)
	var start_x := maxf(24.0, 640.0 - total * 0.5)
	for index in range(count):
		card_rects.append(Rect2(start_x + index * (width + gap), 494, width, 206))

func play_card(index: int) -> void:
	if state != GameState.PLAYER_TURN or index < 0 or index >= hand.size(): return
	var played: Dictionary = hand[index]
	if int(played.cost) > energy:
		show_banner("INSUFFICIENT AVAILABLE CREDIT", 1.0)
		synth.error()
		return
	energy -= int(played.cost)
	var id: String = played.id
	match id:
		"dispute":
			gain_block(9)
		"freeze":
			gain_block(5)
			enemy_weak += 2
			float_text(Vector2(880, 250), "FROZEN", Palette.BLUE)
		"cashback":
			deal_damage(5)
			restore_credit(4)
		"chargeback":
			deal_damage(14 + int((max_credit - credit) / 10.0))
		"fraud_alert":
			gain_block(5)
			counter += 8
		"autopay":
			energy += 1
			lose_credit(2, false)
			draw_cards(1)
		"audit":
			deal_damage(4)
			draw_cards(2)
		"interest":
			deal_damage(7)
			enemy_vulnerable += 1
			float_text(Vector2(880, 250), "EXPOSED", Palette.CORAL)
		"limit":
			max_credit += 5
			credit = mini(max_credit, credit + 5)
			gain_block(12)
		"refund":
			deal_damage(8)
			restore_credit(11)
		"bankruptcy":
			lose_credit(7, false)
			deal_damage(32)
	discard_pile.append(played)
	hand.remove_at(index)
	hover_card = -1
	update_card_rects()
	synth.play_tone(320.0 + float(played.cost) * 120.0, 0.09, -21.0, 3)
	if enemy.hp <= 0:
		win_encounter()
	elif credit <= 0:
		lose_run()

func deal_damage(base_amount: int) -> void:
	var amount := base_amount
	if enemy_vulnerable > 0:
		amount = int(ceil(amount * 1.5))
		enemy_vulnerable -= 1
	enemy.hp = maxi(0, int(enemy.hp) - amount)
	float_text(Vector2(881, 256), "-%d" % amount, Palette.PAPER)
	spawn_sparks(Vector2(881, 265), enemy.color, 12)
	screen_shake = 0.1 + minf(0.2, amount / 100.0)

func gain_block(amount: int) -> void:
	shield += amount
	float_text(Vector2(255, 297), "+%d BLOCK" % amount, Palette.CYAN)
	spawn_sparks(Vector2(255, 300), Palette.CYAN, 7)

func restore_credit(amount: int) -> void:
	var restored := mini(amount, max_credit - credit)
	credit += restored
	if restored > 0: float_text(Vector2(246, 206), "+%d" % restored, Palette.MINT)

func lose_credit(amount: int, shake: bool = true) -> void:
	credit = maxi(0, credit - amount)
	float_text(Vector2(246, 206), "-%d" % amount, Palette.CORAL)
	if shake:
		screen_shake = 0.28
		screen_flash = 0.25

func end_turn() -> void:
	if state != GameState.PLAYER_TURN: return
	for item in hand: discard_pile.append(item)
	hand.clear()
	update_card_rects()
	state = GameState.ENEMY_TURN
	enemy_delay = 0.72
	show_banner("TRANSACTION PROCESSING…", 0.7)
	synth.click()

func resolve_enemy_turn() -> void:
	var absorbed := mini(shield, enemy_intent)
	var damage := maxi(0, enemy_intent - shield)
	if absorbed > 0:
		float_text(Vector2(285, 302), "BLOCKED %d" % absorbed, Palette.CYAN)
		spawn_sparks(Vector2(300, 300), Palette.CYAN, 10)
	if damage > 0:
		lose_credit(damage)
		synth.error()
	else:
		synth.play_tone(190.0, 0.09, -21.0, 1)
	if counter > 0 and enemy_intent > 0:
		deal_damage(counter)
		float_text(Vector2(879, 214), "FRAUD REVERSED", Palette.AMBER)
	shield = 0
	counter = 0
	enemy.turn = int(enemy.turn) + 1
	if credit <= 0:
		lose_run()
	elif enemy.hp <= 0:
		win_encounter()
	else:
		start_player_turn()

func win_encounter() -> void:
	spawn_sparks(Vector2(880, 270), enemy.color, 35)
	synth.play_chord([392.0, 493.88, 587.33], 0.35, -21.0)
	for item in hand: discard_pile.append(item)
	hand.clear()
	if encounter >= 2:
		state = GameState.WON
		screen_flash = 0.8
	else:
		state = GameState.REWARD
		credit = mini(max_credit, credit + 9)
		generate_rewards()
		show_banner("CHARGE REVERSED — SELECT EVIDENCE", 2.0)

func generate_rewards() -> void:
	var pool := all_cards().duplicate(true)
	pool.shuffle()
	reward_cards = pool.slice(4, 7)
	reward_rects = [Rect2(252, 220, 230, 300), Rect2(525, 220, 230, 300), Rect2(798, 220, 230, 300)]

func take_reward(index: int) -> void:
	if state != GameState.REWARD or index < 0 or index >= reward_cards.size(): return
	deck.append(reward_cards[index].duplicate())
	encounter += 1
	synth.confirm()
	start_encounter()

func lose_run() -> void:
	state = GameState.LOST
	hand.clear()
	update_card_rects()
	synth.play_tone(92.0, 0.7, -13.0, 2)

func restart() -> void:
	start_run()

func show_banner(text: String, duration: float) -> void:
	banner = text
	banner_time = duration

func float_text(position: Vector2, text: String, color: Color) -> void:
	floating_texts.append({"pos": position, "text": text, "color": color, "life": 1.0})

func spawn_sparks(position: Vector2, color: Color, amount: int) -> void:
	for index in range(amount):
		sparks.append({"pos": position, "vel": Vector2.from_angle(randf() * TAU) * randf_range(45.0, 210.0), "life": randf_range(0.25, 0.65), "color": color})

func update_effects(delta: float) -> void:
	for item in floating_texts:
		item.pos.y -= 48.0 * delta
		item.life -= delta
	for item in sparks:
		item.pos += item.vel * delta
		item.vel *= pow(0.04, delta)
		item.life -= delta
	for index in range(floating_texts.size() - 1, -1, -1):
		if floating_texts[index].life <= 0.0: floating_texts.remove_at(index)
	for index in range(sparks.size() - 1, -1, -1):
		if sparks[index].life <= 0.0: sparks.remove_at(index)

func card_at(point: Vector2) -> int:
	for index in range(card_rects.size() - 1, -1, -1):
		if card_rects[index].has_point(point): return index
	return -1

func reward_at(point: Vector2) -> int:
	for index in range(reward_rects.size()):
		if reward_rects[index].has_point(point): return index
	return -1

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		hover_card = card_at(event.position)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		handle_click(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		handle_click(event.position)
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			return_to_menu.emit()
		elif state == GameState.INTRO:
			start_run()
		elif state == GameState.PLAYER_TURN:
			if event.keycode in [KEY_ENTER, KEY_E]: end_turn()
			elif event.keycode >= KEY_1 and event.keycode <= KEY_9: play_card(int(event.keycode - KEY_1))
		elif state in [GameState.WON, GameState.LOST] and event.keycode in [KEY_ENTER, KEY_SPACE, KEY_R]:
			restart()

func handle_click(point: Vector2) -> void:
	if menu_rect.has_point(point):
		return_to_menu.emit()
		return
	match state:
		GameState.INTRO:
			start_run()
		GameState.PLAYER_TURN:
			var selected := card_at(point)
			if selected >= 0: play_card(selected)
			elif end_turn_rect.has_point(point): end_turn()
		GameState.REWARD:
			take_reward(reward_at(point))
		GameState.WON, GameState.LOST:
			restart()

func shake_offset() -> Vector2:
	if screen_shake <= 0.0: return Vector2.ZERO
	return Vector2(randf_range(-6, 6), randf_range(-4, 4)) * minf(1.0, screen_shake * 5.0)

func _draw() -> void:
	if state == GameState.INTRO:
		draw_intro()
		return
	var shake := shake_offset()
	draw_arena(shake)
	draw_interface()
	draw_effects(shake)
	if state == GameState.REWARD: draw_reward()
	elif state == GameState.WON: draw_result(true)
	elif state == GameState.LOST: draw_result(false)
	if screen_flash > 0.0:
		draw_rect(Rect2(Vector2.ZERO, VIEW), Palette.with_alpha(Palette.CORAL, screen_flash * 0.25))

func draw_intro() -> void:
	draw_texture_rect(KEY_ART, Rect2(Vector2.ZERO, VIEW), false)
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.02, 0.04, 0.05, 0.55))
	draw_string(ThemeDB.fallback_font, Vector2(62, 76), "PROTOTYPE 02  //  DECK-BUILDING ROGUELIKE", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Palette.MINT)
	draw_string(ThemeDB.fallback_font, Vector2(62, 142), "CHARGEBACK", HORIZONTAL_ALIGNMENT_LEFT, -1, 58, Palette.PAPER)
	draw_string(ThemeDB.fallback_font, Vector2(65, 185), "Your credit line is your lifeline.", HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Palette.MUTED)
	var panel := Rect2(62, 380, 570, 202)
	draw_style_box(Palette.rounded_box(Color(0.035, 0.07, 0.075, 0.93), 20, Palette.MINT, 2), panel)
	draw_string(ThemeDB.fallback_font, Vector2(88, 422), "HOW TO DISPUTE REALITY", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Palette.MINT)
	draw_string(ThemeDB.fallback_font, Vector2(88, 463), "Read the next charge. Spend 3 energy on evidence.", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Palette.PAPER)
	draw_string(ThemeDB.fallback_font, Vector2(88, 501), "Block fees, recover credit, then weaponize your debt.", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Palette.MUTED)
	draw_string(ThemeDB.fallback_font, Vector2(88, 539), "CLICK / TAP CARDS  •  ENTER ENDS TURN", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Palette.MUTED)
	draw_string(ThemeDB.fallback_font, Vector2(62, 650), "PRESS ANY KEY OR TAP TO AUTHORIZE", HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Palette.MINT)
	draw_menu_button()

func draw_arena(shake: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color("071311"))
	for index in range(18):
		var x := fmod(index * 113.0 + animation_time * (8 + index % 3), 1400.0) - 60.0
		draw_line(Vector2(x, 90), Vector2(x - 150, 485), Palette.with_alpha(Palette.MINT, 0.045), 1)
	for index in range(9):
		var y := 100.0 + index * 45.0
		draw_line(Vector2(0, y), Vector2(1280, y), Palette.with_alpha(Palette.MUTED, 0.025), 1)
	# Player card guardian.
	var p := Vector2(247, 275) + shake
	draw_circle(p, 116 + sin(animation_time * 2.2) * 4, Palette.with_alpha(Palette.MINT, 0.055))
	draw_style_box(Palette.rounded_box(Palette.PAPER, 22, Palette.MINT, 4), Rect2(p - Vector2(112, 67), Vector2(224, 134)))
	draw_rect(Rect2(p + Vector2(-88, -43), Vector2(176, 25)), Palette.INK)
	draw_circle(p + Vector2(-65, -30), 5, Palette.MINT)
	draw_circle(p + Vector2(-47, -30), 5, Palette.MINT)
	draw_string(ThemeDB.fallback_font, p + Vector2(-88, 25), "CARD // 000", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Palette.INK)
	if shield > 0:
		draw_arc(p, 98, -2.65, -0.48, 38, Palette.CYAN, 7)
		draw_string(ThemeDB.fallback_font, p + Vector2(-35, -88), "%d BLOCK" % shield, HORIZONTAL_ALIGNMENT_CENTER, 70, 15, Palette.CYAN)
	# Enemy billing entity.
	var e := Vector2(882, 270) + shake
	var enemy_color: Color = enemy.color
	draw_circle(e, 132 + sin(animation_time * 2.8) * 5, Palette.with_alpha(enemy_color, 0.075))
	for sheet in range(4):
		var offset := Vector2((sheet - 1.5) * 16.0, abs(sheet - 1.5) * 8.0)
		var r := Rect2(e - Vector2(88, 102) + offset, Vector2(176, 205))
		draw_style_box(Palette.rounded_box(Palette.PAPER if sheet == 3 else Palette.PANEL_2, 12, enemy_color, 3 if sheet == 3 else 1), r)
		if sheet == 3:
			for line in range(5):
				draw_rect(Rect2(r.position + Vector2(24, 32 + line * 24), Vector2(128 - line * 9, 5)), Palette.with_alpha(Palette.INK, 0.55))
			draw_rect(Rect2(r.position + Vector2(24, 166), Vector2(128, 20)), enemy_color)
			draw_string(ThemeDB.fallback_font, r.position + Vector2(24, 182), "PAY NOW", HORIZONTAL_ALIGNMENT_CENTER, 128, 13, Palette.INK)
	# Projectile preview.
	if state == GameState.ENEMY_TURN:
		var progress := clampf(1.0 - enemy_delay / 0.72, 0.0, 1.0)
		var packet := e.lerp(p, progress)
		draw_circle(packet, 18, enemy_color)
		draw_circle(packet, 30, Palette.with_alpha(enemy_color, 0.14))

func draw_interface() -> void:
	draw_rect(Rect2(0, 0, 1280, 96), Color(0.02, 0.06, 0.055, 0.96))
	draw_string(ThemeDB.fallback_font, Vector2(26, 34), "AVAILABLE CREDIT", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Palette.MUTED)
	draw_style_box(Palette.rounded_box(Palette.INK, 7), Rect2(26, 48, 280, 18))
	var credit_color := Palette.MINT if credit > 30 else Palette.CORAL
	draw_style_box(Palette.rounded_box(credit_color, 7), Rect2(26, 48, 280 * float(credit) / max_credit, 18))
	draw_string(ThemeDB.fallback_font, Vector2(320, 67), "%d / %d" % [credit, max_credit], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, credit_color)
	draw_string(ThemeDB.fallback_font, Vector2(465, 34), "ENERGY", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Palette.MUTED)
	for pip in range(5):
		draw_circle(Vector2(480 + pip * 28, 58), 9, Palette.AMBER if pip < energy else Palette.PANEL_2)
	draw_string(ThemeDB.fallback_font, Vector2(655, 34), "CASE", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Palette.MUTED)
	draw_string(ThemeDB.fallback_font, Vector2(655, 65), "%d / 3" % (encounter + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Palette.PAPER)
	draw_string(ThemeDB.fallback_font, Vector2(748, 34), enemy.name, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Palette.PAPER)
	draw_style_box(Palette.rounded_box(Palette.INK, 6), Rect2(748, 51, 290, 14))
	draw_style_box(Palette.rounded_box(enemy.color, 6), Rect2(748, 51, 290 * float(enemy.hp) / enemy.max_hp, 14))
	draw_string(ThemeDB.fallback_font, Vector2(748, 85), enemy.subtitle, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Palette.MUTED)
	draw_menu_button()

	var intent_panel := Rect2(1015, 126, 225, 132)
	draw_style_box(Palette.rounded_box(Palette.PANEL, 16, Palette.CORAL, 2), intent_panel)
	draw_string(ThemeDB.fallback_font, Vector2(1036, 157), "NEXT CHARGE", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Palette.MUTED)
	draw_string(ThemeDB.fallback_font, Vector2(1036, 194), "%d" % enemy_intent, HORIZONTAL_ALIGNMENT_LEFT, -1, 32, Palette.CORAL)
	draw_string(ThemeDB.fallback_font, Vector2(1085, 191), enemy_intent_name, HORIZONTAL_ALIGNMENT_LEFT, 135, 13, Palette.PAPER)
	draw_string(ThemeDB.fallback_font, Vector2(1036, 231), "BLOCK %d  •  RETURN %d" % [shield, counter], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Palette.CYAN)

	if state == GameState.PLAYER_TURN:
		draw_style_box(Palette.rounded_box(Palette.CORAL, 12), end_turn_rect)
		draw_string(ThemeDB.fallback_font, Vector2(end_turn_rect.position.x, end_turn_rect.position.y + 34), "END TURN", HORIZONTAL_ALIGNMENT_CENTER, end_turn_rect.size.x, 16, Palette.INK)
	for index in range(hand.size()):
		draw_card(hand[index], card_rects[index], index, index == hover_card)
	draw_string(ThemeDB.fallback_font, Vector2(26, 688), "DRAW %d" % draw_pile.size(), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Palette.MUTED)
	draw_string(ThemeDB.fallback_font, Vector2(110, 688), "DISCARD %d" % discard_pile.size(), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Palette.MUTED)
	if banner_time > 0.0:
		var rect := Rect2(390, 110, 500, 42)
		draw_style_box(Palette.rounded_box(Color(0.02, 0.08, 0.07, 0.95), 12, Palette.MINT, 1), rect)
		draw_string(ThemeDB.fallback_font, Vector2(390, 137), banner, HORIZONTAL_ALIGNMENT_CENTER, 500, 15, Palette.PAPER)
	if tutorial_step == 1 and state == GameState.PLAYER_TURN:
		var tip := Rect2(28, 402, 440, 62)
		draw_style_box(Palette.rounded_box(Palette.PANEL, 12, Palette.AMBER, 1), tip)
		draw_string(ThemeDB.fallback_font, Vector2(45, 428), "TIP: Enemy plans %d. Build BLOCK or accept debt" % enemy_intent, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Palette.PAPER)
		draw_string(ThemeDB.fallback_font, Vector2(45, 449), "to power up CHARGEBACK. The risk is yours.", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Palette.MUTED)

func draw_card(item: Dictionary, rect: Rect2, index: int, hovered: bool) -> void:
	var draw_rect := rect
	if hovered and state == GameState.PLAYER_TURN: draw_rect.position.y -= 14
	var affordable := int(item.cost) <= energy
	var accent: Color = item.color if affordable else Palette.MUTED
	draw_style_box(Palette.rounded_box(Palette.PAPER if affordable else Color("9aa0a2"), 15, accent, 3), draw_rect)
	draw_circle(draw_rect.position + Vector2(25, 26), 18, accent)
	draw_string(ThemeDB.fallback_font, draw_rect.position + Vector2(11, 32), str(item.cost), HORIZONTAL_ALIGNMENT_CENTER, 28, 18, Palette.INK)
	draw_string(ThemeDB.fallback_font, draw_rect.position + Vector2(49, 31), item.title, HORIZONTAL_ALIGNMENT_LEFT, draw_rect.size.x - 58, 14, Palette.INK)
	draw_rect(Rect2(draw_rect.position + Vector2(15, 54), Vector2(draw_rect.size.x - 30, 6)), accent)
	draw_multiline_string(ThemeDB.fallback_font, draw_rect.position + Vector2(17, 91), item.description, HORIZONTAL_ALIGNMENT_LEFT, draw_rect.size.x - 34, 15, 4, Palette.INK)
	draw_string(ThemeDB.fallback_font, draw_rect.position + Vector2(17, 185), "EVIDENCE %02d" % (index + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Palette.with_alpha(Palette.INK, 0.55))

func draw_reward() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.01, 0.035, 0.03, 0.88))
	draw_string(ThemeDB.fallback_font, Vector2(0, 116), "EVIDENCE RECOVERED", HORIZONTAL_ALIGNMENT_CENTER, 1280, 32, Palette.PAPER)
	draw_string(ThemeDB.fallback_font, Vector2(0, 151), "Choose one card for the next authorization. +9 CREDIT restored.", HORIZONTAL_ALIGNMENT_CENTER, 1280, 16, Palette.MINT)
	for index in range(reward_cards.size()):
		var rect := reward_rects[index]
		draw_style_box(Palette.rounded_box(Palette.PANEL, 20, reward_cards[index].color, 2), rect.grow(8))
		draw_card(reward_cards[index], Rect2(rect.position + Vector2(20, 34), Vector2(190, 206)), index, false)
		draw_string(ThemeDB.fallback_font, Vector2(rect.position.x, rect.position.y + 275), "ADD TO DECK", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 15, Palette.PAPER)
	draw_menu_button()

func draw_effects(shake: Vector2) -> void:
	for item in floating_texts:
		draw_string(ThemeDB.fallback_font, item.pos + shake, item.text, HORIZONTAL_ALIGNMENT_CENTER, 180, 19, Palette.with_alpha(item.color, clampf(item.life, 0, 1)))
	for item in sparks:
		draw_circle(item.pos + shake, 3.5, Palette.with_alpha(item.color, clampf(item.life * 2.0, 0, 1)))

func draw_result(victory: bool) -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.01, 0.03, 0.025, 0.86))
	var accent := Palette.MINT if victory else Palette.CORAL
	var panel := Rect2(310, 150, 660, 420)
	draw_style_box(Palette.rounded_box(Palette.PANEL, 26, accent, 3), panel)
	draw_string(ThemeDB.fallback_font, Vector2(310, 220), "ALL CHARGES REVERSED" if victory else "CREDIT LINE EXHAUSTED", HORIZONTAL_ALIGNMENT_CENTER, 660, 31, Palette.PAPER)
	draw_string(ThemeDB.fallback_font, Vector2(310, 260), "ACCOUNT HOLDER: FREE" if victory else "CLAIM DENIED — FOR NOW", HORIZONTAL_ALIGNMENT_CENTER, 660, 16, accent)
	draw_string(ThemeDB.fallback_font, Vector2(350, 334), "CASES", HORIZONTAL_ALIGNMENT_CENTER, 180, 14, Palette.MUTED)
	draw_string(ThemeDB.fallback_font, Vector2(350, 374), "%d / 3" % (3 if victory else encounter), HORIZONTAL_ALIGNMENT_CENTER, 180, 29, Palette.PAPER)
	draw_string(ThemeDB.fallback_font, Vector2(550, 334), "TURNS", HORIZONTAL_ALIGNMENT_CENTER, 180, 14, Palette.MUTED)
	draw_string(ThemeDB.fallback_font, Vector2(550, 374), str(run_turns), HORIZONTAL_ALIGNMENT_CENTER, 180, 29, Palette.PAPER)
	draw_string(ThemeDB.fallback_font, Vector2(750, 334), "DECK", HORIZONTAL_ALIGNMENT_CENTER, 180, 14, Palette.MUTED)
	draw_string(ThemeDB.fallback_font, Vector2(750, 374), "%d CARDS" % deck.size(), HORIZONTAL_ALIGNMENT_CENTER, 180, 29, Palette.PAPER)
	draw_style_box(Palette.rounded_box(accent, 12), Rect2(426, 466, 428, 54))
	draw_string(ThemeDB.fallback_font, Vector2(426, 500), "TAP OR PRESS ENTER TO FILE AGAIN", HORIZONTAL_ALIGNMENT_CENTER, 428, 16, Palette.INK)
	draw_menu_button()

func draw_menu_button() -> void:
	draw_style_box(Palette.rounded_box(Color(0.025, 0.07, 0.065, 0.94), 10, Palette.with_alpha(Palette.MUTED, 0.55), 1), menu_rect)
	draw_string(ThemeDB.fallback_font, Vector2(menu_rect.position.x, menu_rect.position.y + 25), "← GAME LAB", HORIZONTAL_ALIGNMENT_CENTER, menu_rect.size.x, 14, Palette.PAPER)
