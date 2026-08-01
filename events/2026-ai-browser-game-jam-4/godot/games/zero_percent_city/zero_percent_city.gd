extends Node2D

signal return_to_menu

const Palette = preload("res://shared/palette.gd")
const Synth = preload("res://shared/synth.gd")
const KEY_ART = preload("res://assets/keyart/zero-percent-city.jpg")

enum RunState { INTRO, PLAYING, COMPLETE, FAILED }

const VIEW := Vector2(1280, 720)
const WORLD_WIDTH := 3600.0
const PLAYER_SIZE := Vector2(30, 44)
const GRAVITY := 1780.0
const RUN_SPEED := 255.0
const JUMP_SPEED := 620.0
const DASH_SPEED := 760.0

var synth: JamSynth
var is_japanese := false
var run_state := RunState.INTRO
var run_time := 0.0
var player_pos := Vector2(130, 600)
var player_vel := Vector2.ZERO
var facing := 1.0
var grounded := false
var coyote := 0.0
var dash_time := 0.0
var dash_cooldown := 0.0
var invulnerable := 0.0
var screen_shake := 0.0
var screen_flash := 0.0
var camera_x := 0.0
var battery := 100.0
var checkpoint := Vector2(130, 600)
var has_dash := false
var has_double_jump := false
var air_jumps := 0
var message := ""
var message_time := 0.0
var particles: Array[Dictionary] = []
var touch_points: Dictionary = {}
var touch_jump_was := false
var touch_dash_was := false

var platforms: Array[Rect2] = []
var hazards: Array[Rect2] = []
var stations: Array[Dictionary] = []
var pickups: Array[Dictionary] = []
var walls: Array[Dictionary] = []
var enemies: Array[Dictionary] = []

var left_button := Rect2(28, 580, 92, 92)
var right_button := Rect2(134, 580, 92, 92)
var jump_button := Rect2(1052, 564, 96, 96)
var dash_button := Rect2(1160, 584, 82, 82)
var menu_button := Rect2(1110, 20, 146, 38)

func _ready() -> void:
	synth = Synth.new()
	add_child(synth)
	build_world()
	set_process(true)
	set_physics_process(true)
	queue_redraw()

func build_world() -> void:
	platforms = [
		Rect2(0, 650, WORLD_WIDTH, 90),
		Rect2(320, 550, 190, 22), Rect2(560, 475, 180, 22), Rect2(770, 565, 230, 22),
		Rect2(1120, 535, 180, 22), Rect2(1350, 455, 190, 22), Rect2(1580, 565, 205, 22),
		Rect2(1815, 495, 165, 22), Rect2(2020, 420, 175, 22), Rect2(2225, 545, 250, 22),
		Rect2(2530, 480, 185, 22), Rect2(2760, 405, 180, 22), Rect2(2980, 330, 185, 22),
		Rect2(3200, 255, 310, 22), Rect2(3375, 150, 170, 22),
	]
	hazards = [
		Rect2(1010, 626, 95, 24), Rect2(1540, 626, 62, 24), Rect2(2185, 626, 66, 24),
		Rect2(2730, 626, 82, 24), Rect2(3165, 626, 88, 24),
	]
	stations = [
		{"rect": Rect2(115, 570, 54, 80), "name": "SERVICE BAY 01"},
		{"rect": Rect2(1425, 375, 54, 80), "name": "RELAY STATION 02"},
		{"rect": Rect2(2595, 400, 54, 80), "name": "UPLINK 03"},
	]
	pickups = [
		{"rect": Rect2(820, 521, 34, 44), "type": "dash", "taken": false},
		{"rect": Rect2(2078, 370, 34, 48), "type": "double", "taken": false},
		{"rect": Rect2(625, 435, 22, 32), "type": "cell", "taken": false},
		{"rect": Rect2(1870, 455, 22, 32), "type": "cell", "taken": false},
		{"rect": Rect2(2820, 365, 22, 32), "type": "cell", "taken": false},
	]
	walls = [
		{"rect": Rect2(1040, 422, 48, 228), "broken": false},
		{"rect": Rect2(2470, 500, 42, 150), "broken": false},
	]
	enemies = [
		make_enemy(Vector2(1240, 615), 1140.0, 1370.0, 82.0, false),
		make_enemy(Vector2(1690, 525), 1590.0, 1770.0, 72.0, false),
		make_enemy(Vector2(2300, 505), 2230.0, 2455.0, 94.0, false),
		make_enemy(Vector2(2860, 350), 2780.0, 2930.0, 80.0, true),
		make_enemy(Vector2(3265, 600), 3200.0, 3500.0, 105.0, false),
	]

func make_enemy(position: Vector2, left: float, right: float, speed: float, flying: bool) -> Dictionary:
	return {"pos": position, "left": left, "right": right, "speed": speed, "dir": 1.0, "dead": false, "flying": flying, "phase": position.x * 0.01}

func reset_run() -> void:
	player_pos = Vector2(130, 600)
	player_vel = Vector2.ZERO
	checkpoint = player_pos
	battery = 100.0
	has_dash = false
	has_double_jump = false
	air_jumps = 0
	run_time = 0.0
	camera_x = 0.0
	for pickup in pickups:
		pickup.taken = false
	for wall in walls:
		wall.broken = false
	for enemy in enemies:
		enemy.dead = false
	run_state = RunState.PLAYING
	show_message(loc("電力経路オンライン — 都市のコアを探せ", "POWER ROUTE ONLINE — FIND THE CITY CORE"), 3.0)
	synth.play_chord([261.63, 392.0, 523.25], 0.24, -24.0)

func _process(delta: float) -> void:
	if message_time > 0.0:
		message_time -= delta
	if screen_shake > 0.0:
		screen_shake = maxf(0.0, screen_shake - delta)
	if screen_flash > 0.0:
		screen_flash = maxf(0.0, screen_flash - delta)
	update_particles(delta)
	queue_redraw()

func _physics_process(delta: float) -> void:
	if run_state != RunState.PLAYING:
		return
	run_time += delta
	dash_cooldown = maxf(0.0, dash_cooldown - delta)
	invulnerable = maxf(0.0, invulnerable - delta)
	coyote = 0.11 if grounded else maxf(0.0, coyote - delta)

	var touch_state := get_touch_state()
	var axis := Input.get_axis("move_left", "move_right")
	if touch_state.left:
		axis -= 1.0
	if touch_state.right:
		axis += 1.0
	axis = clampf(axis, -1.0, 1.0)
	if absf(axis) > 0.1:
		facing = signf(axis)

	var wants_jump: bool = Input.is_action_just_pressed("jump") or (bool(touch_state.jump) and not touch_jump_was)
	var wants_dash: bool = Input.is_action_just_pressed("dash") or (bool(touch_state.dash) and not touch_dash_was)
	touch_jump_was = touch_state.jump
	touch_dash_was = touch_state.dash

	if wants_dash and has_dash and dash_cooldown <= 0.0:
		dash_time = 0.17
		dash_cooldown = 0.55
		player_vel = Vector2(facing * DASH_SPEED, 0)
		battery = maxf(0.0, battery - 2.2)
		spawn_burst(player_pos, Palette.CYAN, 12)
		synth.play_tone(180.0, 0.13, -18.0, 2)

	if wants_jump:
		if grounded or coyote > 0.0:
			player_vel.y = -JUMP_SPEED
			grounded = false
			coyote = 0.0
			air_jumps = 0
			synth.play_tone(330.0, 0.08, -23.0, 3)
		elif has_double_jump and air_jumps < 1:
			player_vel.y = -JUMP_SPEED * 0.92
			air_jumps += 1
			spawn_burst(player_pos, Palette.MAGENTA, 9)
			synth.play_tone(520.0, 0.1, -22.0, 3)

	if dash_time > 0.0:
		dash_time -= delta
		player_vel = Vector2(facing * DASH_SPEED, 0)
	else:
		player_vel.x = move_toward(player_vel.x, axis * RUN_SPEED, 1450.0 * delta)
		player_vel.y = minf(player_vel.y + GRAVITY * delta, 920.0)

	move_player_x(player_vel.x * delta)
	move_player_y(player_vel.y * delta)
	update_enemies(delta)
	handle_interactions(delta)

	battery -= delta * (1.05 + (0.18 if dash_time > 0.0 else 0.0))
	if battery <= 0.0:
		battery = 0.0
		power_failure()
	if player_pos.y > 800.0:
		damage_player(18.0)

	var target_camera := clampf(player_pos.x - 520.0, 0.0, WORLD_WIDTH - VIEW.x)
	camera_x = lerpf(camera_x, target_camera, 1.0 - pow(0.0008, delta))

func get_touch_state() -> Dictionary:
	var result := {"left": false, "right": false, "jump": false, "dash": false}
	for point in touch_points.values():
		if left_button.has_point(point): result.left = true
		if right_button.has_point(point): result.right = true
		if jump_button.has_point(point): result.jump = true
		if dash_button.has_point(point): result.dash = true
	return result

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_points[event.index] = event.position
		else:
			touch_points.erase(event.index)
		if run_state == RunState.INTRO and event.pressed:
			reset_run()
		elif run_state in [RunState.COMPLETE, RunState.FAILED] and event.pressed:
			if not menu_button.has_point(event.position):
				reset_run()
	elif event is InputEventScreenDrag:
		touch_points[event.index] = event.position
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if menu_button.has_point(event.position):
			return_to_menu.emit()
		elif run_state == RunState.INTRO:
			reset_run()
		elif run_state in [RunState.COMPLETE, RunState.FAILED]:
			reset_run()
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			return_to_menu.emit()
		elif run_state == RunState.INTRO:
			reset_run()
		elif run_state in [RunState.COMPLETE, RunState.FAILED] and event.keycode in [KEY_ENTER, KEY_SPACE, KEY_R]:
			reset_run()

func player_rect() -> Rect2:
	return Rect2(player_pos - PLAYER_SIZE * 0.5, PLAYER_SIZE)

func solid_rects() -> Array[Rect2]:
	var result: Array[Rect2] = platforms.duplicate()
	for wall in walls:
		if not wall.broken:
			result.append(wall.rect)
	return result

func move_player_x(amount: float) -> void:
	player_pos.x += amount
	var body := player_rect()
	for solid in solid_rects():
		if body.intersects(solid):
			if dash_time > 0.0 and break_wall(solid):
				body = player_rect()
				continue
			if amount > 0.0:
				player_pos.x = solid.position.x - PLAYER_SIZE.x * 0.5
			elif amount < 0.0:
				player_pos.x = solid.end.x + PLAYER_SIZE.x * 0.5
			player_vel.x = 0.0
			body = player_rect()
	player_pos.x = clampf(player_pos.x, PLAYER_SIZE.x * 0.5, WORLD_WIDTH - PLAYER_SIZE.x * 0.5)

func move_player_y(amount: float) -> void:
	grounded = false
	player_pos.y += amount
	var body := player_rect()
	for solid in solid_rects():
		if body.intersects(solid):
			if amount > 0.0:
				player_pos.y = solid.position.y - PLAYER_SIZE.y * 0.5
				grounded = true
				air_jumps = 0
			elif amount < 0.0:
				player_pos.y = solid.end.y + PLAYER_SIZE.y * 0.5
			player_vel.y = 0.0
			body = player_rect()

func break_wall(rect: Rect2) -> bool:
	for wall in walls:
		if wall.rect == rect and not wall.broken:
			wall.broken = true
			spawn_burst(rect.get_center(), Palette.AMBER, 22)
			screen_shake = 0.22
			synth.play_tone(92.0, 0.18, -14.0, 1)
			show_message(loc("障害物を破壊", "OBSTRUCTION PURGED"), 1.3)
			return true
	return false

func update_enemies(delta: float) -> void:
	for enemy in enemies:
		if enemy.dead:
			continue
		enemy.pos.x += enemy.dir * enemy.speed * delta
		if enemy.pos.x <= enemy.left or enemy.pos.x >= enemy.right:
			enemy.dir *= -1.0
		enemy.phase += delta * 3.0
		if enemy.flying:
			enemy.pos.y += sin(enemy.phase) * 24.0 * delta
		var enemy_rect := Rect2(enemy.pos - Vector2(19, 18), Vector2(38, 36))
		if player_rect().intersects(enemy_rect):
			if dash_time > 0.0:
				enemy.dead = true
				battery = minf(100.0, battery + 6.0)
				spawn_burst(enemy.pos, Palette.CORAL, 16)
				synth.play_tone(140.0, 0.12, -16.0, 1)
			else:
				damage_player(12.0)

func handle_interactions(delta: float) -> void:
	var body := player_rect()
	for hazard in hazards:
		if body.intersects(hazard):
			damage_player(16.0)
	for station in stations:
		if body.intersects(station.rect.grow(18.0)):
			var center: Vector2 = station.rect.get_center()
			checkpoint = Vector2(center.x, station.rect.position.y - PLAYER_SIZE.y * 0.5 - 2.0)
			battery = minf(100.0, battery + 48.0 * delta)
			if fmod(run_time, 0.35) < delta:
				spawn_burst(center, Palette.CYAN, 1)
	for pickup in pickups:
		if not pickup.taken and body.intersects(pickup.rect.grow(5.0)):
			pickup.taken = true
			battery = minf(100.0, battery + 28.0)
			match pickup.type:
				"dash":
					has_dash = true
					show_message(loc("インパルスドライブ獲得 — X / SHIFTでダッシュ", "IMPULSE DRIVE ACQUIRED — DASH WITH X / SHIFT"), 3.5)
				"double":
					has_double_jump = true
					show_message(loc("空中セル獲得 — 空中でもう一度ジャンプ", "AERIAL CELL ACQUIRED — JUMP AGAIN IN MID-AIR"), 3.5)
				"cell":
					show_message(loc("緊急セル +28%", "EMERGENCY CELL +28%"), 1.5)
			spawn_burst(pickup.rect.get_center(), Palette.MINT, 24)
			synth.play_chord([523.25, 659.25, 783.99], 0.2, -22.0)
	var core := Rect2(3400, 78, 92, 72)
	if body.intersects(core.grow(12.0)):
		run_state = RunState.COMPLETE
		spawn_burst(core.get_center(), Palette.CYAN, 50)
		screen_flash = 0.8
		synth.play_chord([261.63, 329.63, 392.0, 523.25], 0.8, -21.0)

func damage_player(amount: float) -> void:
	if invulnerable > 0.0 or run_state != RunState.PLAYING:
		return
	invulnerable = 1.0
	battery = maxf(0.0, battery - amount)
	player_pos = checkpoint
	player_vel = Vector2.ZERO
	screen_shake = 0.32
	spawn_burst(player_pos, Palette.CORAL, 18)
	show_message(loc("システム損傷 — 最後の中継点から復旧", "SYSTEM SHOCK — RESTORED AT LAST RELAY"), 1.8)
	synth.error()

func power_failure() -> void:
	run_state = RunState.FAILED
	screen_shake = 0.5
	synth.play_tone(82.0, 0.7, -13.0, 2)

func show_message(text: String, duration: float) -> void:
	message = text
	message_time = duration

func loc(japanese: String, english: String) -> String:
	return japanese if is_japanese else english

func spawn_burst(position: Vector2, color: Color, count: int) -> void:
	for index in range(count):
		var angle := TAU * float(index) / maxf(1.0, float(count)) + randf_range(-0.25, 0.25)
		particles.append({
			"pos": position, "vel": Vector2.from_angle(angle) * randf_range(55.0, 230.0),
			"life": randf_range(0.3, 0.8), "max": 0.8, "color": color,
		})

func update_particles(delta: float) -> void:
	for particle in particles:
		particle.life -= delta
		particle.pos += particle.vel * delta
		particle.vel *= pow(0.06, delta)
	for index in range(particles.size() - 1, -1, -1):
		if particles[index].life <= 0.0:
			particles.remove_at(index)

func world_point(point: Vector2) -> Vector2:
	var shake := Vector2.ZERO
	if screen_shake > 0.0:
		shake = Vector2(randf_range(-6.0, 6.0), randf_range(-4.0, 4.0)) * minf(1.0, screen_shake * 5.0)
	return point - Vector2(camera_x, 0) + shake

func world_rect(rect: Rect2) -> Rect2:
	return Rect2(world_point(rect.position), rect.size)

func _draw() -> void:
	if run_state == RunState.INTRO:
		draw_intro()
		return
	draw_game_world()
	draw_hud()
	if run_state == RunState.COMPLETE:
		draw_end_overlay(true)
	elif run_state == RunState.FAILED:
		draw_end_overlay(false)
	if screen_flash > 0.0:
		draw_rect(Rect2(Vector2.ZERO, VIEW), Palette.with_alpha(Palette.CYAN, screen_flash * 0.28))

func draw_intro() -> void:
	draw_texture_rect(KEY_ART, Rect2(Vector2.ZERO, VIEW), false)
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.02, 0.05, 0.1, 0.54))
	draw_rect(Rect2(0, 0, 1280, 720), Color(0.02, 0.04, 0.09, 0.25))
	draw_string(Palette.UI_FONT, Vector2(64, 80), loc("プロトタイプ 01  //  ミニメトロイドヴァニア", "PROTOTYPE 01  //  MINI METROIDVANIA"), HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Palette.CYAN)
	draw_string(Palette.UI_FONT, Vector2(64, 145), "ZERO PERCENT CITY", HORIZONTAL_ALIGNMENT_LEFT, -1, 52, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(67, 188), loc("街は死んだ。借り物の電力は、まだ生きている。", "The city is dead. Your borrowed charge is not."), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Palette.MUTED)
	var panel := Rect2(64, 392, 550, 190)
	draw_style_box(Palette.rounded_box(Color(0.04, 0.08, 0.14, 0.9), 18, Palette.with_alpha(Palette.CYAN, 0.45), 2), panel)
	draw_string(Palette.UI_FONT, Vector2(88, 430), loc("ミッション", "MISSION"), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Palette.CYAN)
	draw_string(Palette.UI_FONT, Vector2(88, 468), loc("バッテリーが尽きる前に都市のコアへ到達せよ。", "Reach the core before your battery hits zero."), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(88, 506), loc("移動  A / D  •  ジャンプ  SPACE / Z", "MOVE  A / D  •  JUMP  SPACE / Z"), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Palette.MUTED)
	draw_string(Palette.UI_FONT, Vector2(88, 537), loc("ダッシュ  X / SHIFT  •  タッチ操作対応", "DASH  X / SHIFT  •  TOUCH CONTROLS SUPPORTED"), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Palette.MUTED)
	draw_string(Palette.UI_FONT, Vector2(64, 652), loc("キー入力またはタップで起動", "PRESS ANY KEY OR TAP TO BOOT"), HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Palette.CYAN)
	draw_menu_button()

func draw_game_world() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Palette.INK)
	for layer in range(3):
		var parallax := camera_x * (0.12 + layer * 0.13)
		var color := Palette.with_alpha(Palette.BLUE if layer < 2 else Palette.VIOLET, 0.055 + layer * 0.025)
		for index in range(20):
			var x := fmod(index * (161.0 + layer * 31.0) - parallax, 1600.0) - 120.0
			var height := 80.0 + fmod(index * 79.0 + layer * 61.0, 310.0)
			draw_rect(Rect2(x, 650.0 - height, 95.0 + layer * 21.0, height), color)
			draw_line(Vector2(x + 12, 650 - height), Vector2(x + 12, 650), Palette.with_alpha(Palette.CYAN, 0.045), 2)
	for x in range(0, int(WORLD_WIDTH), 120):
		var sx := float(x) - camera_x
		draw_line(Vector2(sx, 650), Vector2(sx + 46, 720), Palette.with_alpha(Palette.CYAN, 0.04), 1)

	for platform in platforms:
		var rect := world_rect(platform)
		if rect.end.x < -40 or rect.position.x > 1320: continue
		draw_rect(rect, Palette.PANEL_2)
		draw_rect(Rect2(rect.position, Vector2(rect.size.x, 4)), Palette.with_alpha(Palette.CYAN, 0.7))
		for bolt_x in range(int(rect.position.x + 24), int(rect.end.x), 64):
			draw_circle(Vector2(bolt_x, rect.position.y + 12), 2, Palette.MUTED)
	for hazard in hazards:
		var rect := world_rect(hazard)
		for spike in range(int(rect.size.x / 16.0)):
			var a := rect.position + Vector2(spike * 16.0, rect.size.y)
			var points := PackedVector2Array([a, a + Vector2(8, -rect.size.y), a + Vector2(16, 0)])
			draw_colored_polygon(points, Palette.CORAL)
	for wall in walls:
		if wall.broken: continue
		var rect: Rect2 = world_rect(wall.rect)
		draw_rect(rect, Palette.PANEL_2)
		for y in range(int(rect.position.y + 10), int(rect.end.y), 22):
			draw_line(Vector2(rect.position.x, y), Vector2(rect.end.x, y - 7), Palette.with_alpha(Palette.AMBER, 0.5), 2)

	for station in stations:
		var rect: Rect2 = world_rect(station.rect)
		draw_style_box(Palette.rounded_box(Palette.PANEL, 8, Palette.CYAN, 2), rect)
		draw_rect(Rect2(rect.position + Vector2(12, 12), Vector2(rect.size.x - 24, 36)), Palette.with_alpha(Palette.CYAN, 0.18))
		var charge_h := 30.0 * (0.6 + sin(run_time * 4.0) * 0.15)
		draw_rect(Rect2(rect.position + Vector2(18, 47 - charge_h), Vector2(rect.size.x - 36, charge_h)), Palette.CYAN)
		draw_line(rect.get_center(), rect.get_center() + Vector2(0, -65), Palette.with_alpha(Palette.CYAN, 0.2), 12)
	for pickup in pickups:
		if pickup.taken: continue
		var rect: Rect2 = world_rect(pickup.rect)
		var accent := Palette.MAGENTA if pickup.type == "double" else Palette.CYAN
		if pickup.type == "cell": accent = Palette.AMBER
		draw_circle(rect.get_center(), rect.size.x * 0.85, Palette.with_alpha(accent, 0.12))
		draw_style_box(Palette.rounded_box(Palette.PANEL, 7, accent, 2), rect)
		draw_rect(Rect2(rect.position + Vector2(8, 8), rect.size - Vector2(16, 16)), accent)
	for enemy in enemies:
		if enemy.dead: continue
		var p := world_point(enemy.pos)
		draw_circle(p, 23, Palette.with_alpha(Palette.CORAL, 0.13))
		draw_style_box(Palette.rounded_box(Palette.CORAL, 7), Rect2(p - Vector2(18, 14), Vector2(36, 28)))
		draw_rect(Rect2(p + Vector2(-10, -5), Vector2(6, 6)), Palette.INK)
		draw_rect(Rect2(p + Vector2(4, -5), Vector2(6, 6)), Palette.INK)
		draw_line(p + Vector2(-9, 17), p + Vector2(-13, 25), Palette.CORAL, 3)
		draw_line(p + Vector2(9, 17), p + Vector2(13, 25), Palette.CORAL, 3)

	var core := world_rect(Rect2(3400, 78, 92, 72))
	draw_circle(core.get_center(), 92 + sin(run_time * 2.5) * 7, Palette.with_alpha(Palette.CYAN, 0.08))
	draw_circle(core.get_center(), 57, Palette.with_alpha(Palette.CYAN, 0.18))
	draw_style_box(Palette.rounded_box(Palette.PANEL, 18, Palette.CYAN, 3), core)
	draw_circle(core.get_center(), 21, Palette.CYAN)
	draw_line(core.get_center(), core.get_center() + Vector2(0, 490), Palette.with_alpha(Palette.CYAN, 0.12), 5)

	for particle in particles:
		var p := world_point(particle.pos)
		var alpha: float = clampf(particle.life / particle.max, 0.0, 1.0)
		draw_circle(p, 2.5 + alpha * 2.5, Palette.with_alpha(particle.color, alpha))
	draw_player()

func draw_player() -> void:
	var p := world_point(player_pos)
	var blink := invulnerable > 0.0 and fmod(invulnerable, 0.15) > 0.075
	if blink: return
	var accent := Palette.CYAN if battery > 25.0 else Palette.CORAL
	if dash_time > 0.0:
		for trail in range(4):
			var trail_rect := Rect2(p - PLAYER_SIZE * 0.5 - Vector2(facing * trail * 15.0, 0), PLAYER_SIZE)
			draw_style_box(Palette.rounded_box(Palette.with_alpha(accent, 0.18 - trail * 0.03), 8), trail_rect)
	draw_circle(p, 31, Palette.with_alpha(accent, 0.1))
	draw_style_box(Palette.rounded_box(Palette.PAPER, 8, accent, 2), Rect2(p - PLAYER_SIZE * 0.5, PLAYER_SIZE))
	draw_rect(Rect2(p + Vector2(-10, -12), Vector2(20, 12)), Palette.INK)
	draw_circle(p + Vector2(-5 + facing * 2, -6), 2.5, accent)
	draw_circle(p + Vector2(5 + facing * 2, -6), 2.5, accent)
	var fill := Rect2(p + Vector2(-8, 5), Vector2(16 * battery / 100.0, 6))
	draw_rect(Rect2(p + Vector2(-8, 5), Vector2(16, 6)), Palette.INK)
	draw_rect(fill, accent)
	draw_line(p + Vector2(-8, 23), p + Vector2(-11, 31), Palette.PAPER, 4)
	draw_line(p + Vector2(8, 23), p + Vector2(11, 31), Palette.PAPER, 4)

func draw_hud() -> void:
	var hud := Rect2(22, 18, 470, 72)
	draw_style_box(Palette.rounded_box(Color(0.035, 0.07, 0.12, 0.92), 14, Palette.with_alpha(Palette.CYAN, 0.25), 1), hud)
	draw_string(Palette.UI_FONT, Vector2(42, 47), loc("借用電力", "BORROWED POWER"), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Palette.MUTED)
	draw_style_box(Palette.rounded_box(Palette.INK, 8), Rect2(42, 58, 270, 15))
	var battery_color := Palette.CYAN if battery > 25.0 else Palette.CORAL
	draw_style_box(Palette.rounded_box(battery_color, 7), Rect2(42, 58, 270 * battery / 100.0, 15))
	draw_string(Palette.UI_FONT, Vector2(326, 72), "%03d%%" % int(ceil(battery)), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, battery_color)
	draw_string(Palette.UI_FONT, Vector2(401, 48), loc("経過", "CORE"), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Palette.MUTED)
	draw_string(Palette.UI_FONT, Vector2(401, 72), "%02d:%02d" % [int(run_time) / 60, int(run_time) % 60], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Palette.PAPER)
	var ability_x := 512.0
	draw_style_box(Palette.rounded_box(Palette.PANEL, 10, Palette.CYAN if has_dash else Palette.PANEL_2, 2), Rect2(ability_x, 23, 128, 45))
	draw_string(Palette.UI_FONT, Vector2(ability_x, 52), (loc("ダッシュ  %s", "DASH  %s") % (loc("解放", "ON") if has_dash else loc("未解放", "LOCKED"))), HORIZONTAL_ALIGNMENT_CENTER, 128, 14, Palette.PAPER if has_dash else Palette.MUTED)
	draw_style_box(Palette.rounded_box(Palette.PANEL, 10, Palette.MAGENTA if has_double_jump else Palette.PANEL_2, 2), Rect2(652, 23, 150, 45))
	draw_string(Palette.UI_FONT, Vector2(652, 52), (loc("空中セル  %s", "AIR CELL  %s") % (loc("解放", "ON") if has_double_jump else loc("未解放", "LOCKED"))), HORIZONTAL_ALIGNMENT_CENTER, 150, 14, Palette.PAPER if has_double_jump else Palette.MUTED)
	draw_menu_button()
	if message_time > 0.0:
		var message_rect := Rect2(330, 104, 620, 42)
		draw_style_box(Palette.rounded_box(Color(0.03, 0.08, 0.13, 0.94), 12, Palette.CYAN, 1), message_rect)
		draw_string(Palette.UI_FONT, Vector2(330, 131), message, HORIZONTAL_ALIGNMENT_CENTER, 620, 15, Palette.PAPER)
	if DisplayServer.is_touchscreen_available() or not touch_points.is_empty():
		draw_touch_controls()

func draw_touch_controls() -> void:
	for data in [[left_button, "◀"], [right_button, "▶"], [jump_button, loc("ジャンプ", "JUMP")], [dash_button, loc("ダッシュ", "DASH")]]:
		var rect: Rect2 = data[0]
		var active := false
		for point in touch_points.values():
			if rect.has_point(point): active = true
		draw_style_box(Palette.rounded_box(Palette.with_alpha(Palette.CYAN if active else Palette.PANEL_2, 0.72), 22, Palette.with_alpha(Palette.CYAN, 0.5), 2), rect)
		draw_string(Palette.UI_FONT, Vector2(rect.position.x, rect.position.y + rect.size.y * 0.58), data[1], HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 15, Palette.PAPER)

func draw_menu_button() -> void:
	draw_style_box(Palette.rounded_box(Color(0.04, 0.08, 0.14, 0.9), 10, Palette.with_alpha(Palette.MUTED, 0.5), 1), menu_button)
	draw_string(Palette.UI_FONT, Vector2(menu_button.position.x, menu_button.position.y + 25), loc("← ゲーム選択", "← GAME LAB"), HORIZONTAL_ALIGNMENT_CENTER, menu_button.size.x, 14, Palette.PAPER)

func draw_end_overlay(victory: bool) -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.015, 0.03, 0.06, 0.78))
	var panel := Rect2(310, 164, 660, 390)
	var accent := Palette.CYAN if victory else Palette.CORAL
	draw_style_box(Palette.rounded_box(Palette.PANEL, 24, accent, 3), panel)
	draw_string(Palette.UI_FONT, Vector2(310, 220), (loc("都市コア復旧", "CITY CORE RESTORED") if victory else loc("電力切れ", "POWER DEPLETED")), HORIZONTAL_ALIGNMENT_CENTER, 660, 34, Palette.PAPER)
	draw_string(Palette.UI_FONT, Vector2(310, 262), (loc("充電経路を確立した", "CHARGE ROUTE COMPLETE") if victory else loc("街は次の起動を待っている", "THE CITY WILL WAIT FOR ANOTHER BOOT")), HORIZONTAL_ALIGNMENT_CENTER, 660, 16, accent)
	if victory:
		draw_string(Palette.UI_FONT, Vector2(310, 335), loc("時間", "TIME"), HORIZONTAL_ALIGNMENT_CENTER, 220, 14, Palette.MUTED)
		draw_string(Palette.UI_FONT, Vector2(310, 373), "%02d:%02d" % [int(run_time) / 60, int(run_time) % 60], HORIZONTAL_ALIGNMENT_CENTER, 220, 28, Palette.PAPER)
		draw_string(Palette.UI_FONT, Vector2(530, 335), loc("残り電力", "POWER LEFT"), HORIZONTAL_ALIGNMENT_CENTER, 220, 14, Palette.MUTED)
		draw_string(Palette.UI_FONT, Vector2(530, 373), "%d%%" % int(battery), HORIZONTAL_ALIGNMENT_CENTER, 220, 28, Palette.PAPER)
		draw_string(Palette.UI_FONT, Vector2(750, 335), loc("モジュール", "MODULES"), HORIZONTAL_ALIGNMENT_CENTER, 220, 14, Palette.MUTED)
		draw_string(Palette.UI_FONT, Vector2(750, 373), "2 / 2", HORIZONTAL_ALIGNMENT_CENTER, 220, 28, Palette.PAPER)
	draw_style_box(Palette.rounded_box(accent, 12), Rect2(430, 452, 420, 52))
	draw_string(Palette.UI_FONT, Vector2(430, 485), loc("タップまたはENTERでもう一度", "TAP OR PRESS ENTER TO RUN AGAIN"), HORIZONTAL_ALIGNMENT_CENTER, 420, 16, Palette.INK)
	draw_menu_button()
