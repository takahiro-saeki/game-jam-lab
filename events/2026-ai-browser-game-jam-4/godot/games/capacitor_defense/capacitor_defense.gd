extends Node2D

signal return_to_menu

const Palette = preload("res://shared/palette.gd")
const Synth = preload("res://shared/synth.gd")
const KEY_ART = preload("res://assets/keyart/capacitor-defense.jpg")

enum GameState { INTRO, BUILD, WAVE, WON, LOST }
enum BuildMode { CABLE, CAPACITOR, ARC, PULSE, UPGRADE }

const VIEW := Vector2(1280, 720)
const FIELD_RIGHT := 1020.0

var synth: JamSynth
var state := GameState.INTRO
var build_mode := BuildMode.CABLE
var credits := 112
var base_hp := 20
var max_base_hp := 20
var wave_index := 0
var wave_spawned := 0
var spawn_timer := 0.0
var elapsed := 0.0
var packet_timer := 0.0
var packet_id := 0
var screen_shake := 0.0
var screen_flash := 0.0
var message := ""
var message_time := 0.0
var hover_node := -1

var path_points := PackedVector2Array([
	Vector2(-30, 190), Vector2(240, 190), Vector2(240, 535), Vector2(540, 535),
	Vector2(540, 230), Vector2(810, 230), Vector2(810, 565), Vector2(1045, 565),
])
var path_lengths: Array[float] = []
var total_path_length := 0.0
var nodes: Array[Dictionary] = []
var enemies: Array[Dictionary] = []
var packets: Array[Dictionary] = []
var projectiles: Array[Dictionary] = []
var particles: Array[Dictionary] = []
var mode_rects: Array[Rect2] = []
var launch_rect := Rect2(1038, 608, 224, 62)
var menu_rect := Rect2(1100, 18, 154, 38)

var waves := [
	{"name": "SCOUT CURRENT", "count": 8, "hp": 22, "speed": 78.0, "interval": 0.75, "reward": 3},
	{"name": "BROWNOUT PACK", "count": 11, "hp": 32, "speed": 86.0, "interval": 0.62, "reward": 4},
	{"name": "SURGE SWARM", "count": 14, "hp": 38, "speed": 102.0, "interval": 0.48, "reward": 4},
	{"name": "INSULATOR COLUMN", "count": 10, "hp": 72, "speed": 66.0, "interval": 0.72, "reward": 6},
	{"name": "BLACKOUT ENGINE", "count": 1, "hp": 540, "speed": 46.0, "interval": 0.2, "reward": 40},
]

func _ready() -> void:
	synth = Synth.new()
	add_child(synth)
	calculate_path()
	build_grid()
	mode_rects = [
		Rect2(1038, 195, 104, 72), Rect2(1150, 195, 112, 72),
		Rect2(1038, 277, 104, 72), Rect2(1150, 277, 112, 72),
		Rect2(1038, 359, 224, 62),
	]
	queue_redraw()

func calculate_path() -> void:
	path_lengths.clear()
	total_path_length = 0.0
	for index in range(path_points.size() - 1):
		var length := path_points[index].distance_to(path_points[index + 1])
		path_lengths.append(length)
		total_path_length += length

func build_grid() -> void:
	var positions := [
		Vector2(82, 397), Vector2(190, 397), Vector2(320, 402), Vector2(412, 315),
		Vector2(424, 480), Vector2(548, 371), Vector2(665, 326), Vector2(666, 464),
		Vector2(783, 390), Vector2(900, 344), Vector2(914, 485),
	]
	nodes.clear()
	for index in range(positions.size()):
		nodes.append({
			"pos": positions[index], "active": index <= 1, "building": "reactor" if index == 0 else "",
			"charge": 0.0, "stored": 0.0, "cooldown": 0.0, "level": 1, "pulse": 0.0,
		})

func reset_run() -> void:
	credits = 112
	base_hp = 20
	wave_index = 0
	wave_spawned = 0
	enemies.clear()
	packets.clear()
	projectiles.clear()
	particles.clear()
	build_grid()
	build_mode = BuildMode.CABLE
	state = GameState.BUILD
	show_message("ROUTE CABLES, PLACE TOWERS, THEN LAUNCH THE WAVE", 4.0)
	synth.play_chord([196.0, 293.66, 392.0], 0.24, -23.0)

func _process(delta: float) -> void:
	elapsed += delta
	if message_time > 0.0: message_time -= delta
	if screen_shake > 0.0: screen_shake = maxf(0.0, screen_shake - delta)
	if screen_flash > 0.0: screen_flash = maxf(0.0, screen_flash - delta)
	if state in [GameState.BUILD, GameState.WAVE]:
		update_power(delta)
		update_towers(delta)
		update_projectiles(delta)
	if state == GameState.WAVE:
		update_wave(delta)
	update_particles(delta)
	queue_redraw()

func update_wave(delta: float) -> void:
	var wave: Dictionary = waves[wave_index]
	if wave_spawned < int(wave.count):
		spawn_timer -= delta
		if spawn_timer <= 0.0:
			spawn_enemy(wave)
			spawn_timer = float(wave.interval)
	update_enemies(delta)
	if wave_spawned >= int(wave.count) and enemies.is_empty():
		wave_index += 1
		if wave_index >= waves.size():
			state = GameState.WON
			screen_flash = 0.9
			synth.play_chord([261.63, 329.63, 392.0, 523.25], 0.8, -20.0)
		else:
			state = GameState.BUILD
			credits += 18 + wave_index * 3
			show_message("WAVE CLEARED — GRID CREDIT AWARDED", 2.5)
			synth.confirm()

func spawn_enemy(wave: Dictionary) -> void:
	wave_spawned += 1
	var boss := wave_index == waves.size() - 1
	enemies.append({
		"distance": 0.0, "hp": int(wave.hp), "max_hp": int(wave.hp), "speed": float(wave.speed),
		"reward": int(wave.reward), "boss": boss, "slow": 0.0, "flash": 0.0,
	})
	spawn_particles(path_points[0], Palette.CORAL, 7)

func update_enemies(delta: float) -> void:
	for enemy in enemies:
		enemy.flash = maxf(0.0, float(enemy.flash) - delta)
		enemy.slow = maxf(0.0, float(enemy.slow) - delta)
		var factor := 0.62 if enemy.slow > 0.0 else 1.0
		enemy.distance += enemy.speed * factor * delta
	for index in range(enemies.size() - 1, -1, -1):
		var enemy := enemies[index]
		if enemy.hp <= 0:
			credits += int(enemy.reward)
			spawn_particles(path_position(enemy.distance), Palette.AMBER, 12 if not enemy.boss else 42)
			synth.play_tone(135.0 if enemy.boss else 220.0, 0.12, -19.0, 1)
			enemies.remove_at(index)
		elif enemy.distance >= total_path_length:
			var damage := 6 if enemy.boss else 1
			base_hp = maxi(0, base_hp - damage)
			screen_shake = 0.34
			screen_flash = 0.25
			synth.error()
			enemies.remove_at(index)
			if base_hp <= 0:
				state = GameState.LOST
				enemies.clear()
				packets.clear()
				return

func update_power(delta: float) -> void:
	packet_timer -= delta
	if packet_timer <= 0.0:
		packet_timer = 0.42
		spawn_power_packet()
	for packet in packets:
		var route: Array = packet.route
		if int(packet.segment) >= route.size() - 1:
			deliver_packet(packet)
			packet.done = true
			continue
		var from: Vector2 = nodes[route[int(packet.segment)]].pos
		var to: Vector2 = nodes[route[int(packet.segment) + 1]].pos
		var segment_length := from.distance_to(to)
		packet.t += (240.0 / maxf(1.0, segment_length)) * delta
		if packet.t >= 1.0:
			packet.t -= 1.0
			packet.segment += 1
	for index in range(packets.size() - 1, -1, -1):
		if packets[index].done: packets.remove_at(index)

func spawn_power_packet() -> void:
	var candidates: Array[int] = []
	for index in range(1, nodes.size()):
		if nodes[index].active and nodes[index].building != "":
			var path := find_node_path(0, index)
			if not path.is_empty(): candidates.append(index)
	if candidates.is_empty(): return
	packet_id += 1
	var target := candidates[packet_id % candidates.size()]
	var route := find_node_path(0, target)
	packets.append({"route": route, "segment": 0, "t": 0.0, "target": target, "done": false})

func deliver_packet(packet: Dictionary) -> void:
	var target: int = packet.target
	var node: Dictionary = nodes[target]
	node.pulse = 0.35
	if node.building == "capacitor":
		node.stored = minf(6.0, float(node.stored) + 1.0)
		if node.stored >= 5.0:
			discharge_capacitor(target)
	else:
		node.charge = minf(4.0 + int(node.level), float(node.charge) + 1.0)
	spawn_particles(node.pos, Palette.CYAN, 3)

func discharge_capacitor(index: int) -> void:
	var capacitor: Dictionary = nodes[index]
	capacitor.stored = 0.0
	capacitor.pulse = 0.8
	for target in range(nodes.size()):
		if target == index: continue
		var node: Dictionary = nodes[target]
		if node.building in ["arc", "pulse"] and node.pos.distance_to(capacitor.pos) <= 310.0 and not find_node_path(index, target).is_empty():
			node.charge = minf(5.0 + int(node.level), float(node.charge) + 2.0 + int(capacitor.level) * 0.5)
			projectiles.append({"kind": "energy", "from": capacitor.pos, "to": node.pos, "life": 0.24, "max": 0.24})
	spawn_particles(capacitor.pos, Palette.VIOLET, 22)
	synth.play_tone(660.0, 0.14, -22.0, 3)

func update_towers(delta: float) -> void:
	for index in range(nodes.size()):
		var node: Dictionary = nodes[index]
		node.pulse = maxf(0.0, float(node.pulse) - delta)
		node.cooldown = maxf(0.0, float(node.cooldown) - delta)
		if node.building not in ["arc", "pulse"] or node.charge < 1.0 or node.cooldown > 0.0:
			continue
		var range_value := (175.0 if node.building == "arc" else 145.0) + (int(node.level) - 1) * 18.0
		var target_index := select_target(node.pos, range_value)
		if target_index < 0: continue
		var target: Dictionary = enemies[target_index]
		var target_pos := path_position(target.distance)
		node.charge -= 1.0
		if node.building == "arc":
			var damage := 11 + (int(node.level) - 1) * 6
			target.hp -= damage
			target.flash = 0.12
			node.cooldown = maxf(0.28, 0.62 - (int(node.level) - 1) * 0.08)
			projectiles.append({"kind": "arc", "from": node.pos, "to": target_pos, "life": 0.16, "max": 0.16})
			synth.play_tone(410.0, 0.04, -29.0, 1)
		else:
			var damage := 7 + (int(node.level) - 1) * 4
			for enemy in enemies:
				if path_position(enemy.distance).distance_to(target_pos) < 76.0:
					enemy.hp -= damage
					enemy.slow = 0.7
					enemy.flash = 0.15
			node.cooldown = maxf(0.65, 1.28 - (int(node.level) - 1) * 0.13)
			projectiles.append({"kind": "pulse", "from": node.pos, "to": target_pos, "life": 0.34, "max": 0.34})
			synth.play_tone(180.0, 0.08, -27.0, 3)

func select_target(origin: Vector2, range_value: float) -> int:
	var result := -1
	var furthest := -1.0
	for index in range(enemies.size()):
		var position := path_position(enemies[index].distance)
		if origin.distance_to(position) <= range_value and enemies[index].distance > furthest:
			furthest = enemies[index].distance
			result = index
	return result

func update_projectiles(delta: float) -> void:
	for item in projectiles: item.life -= delta
	for index in range(projectiles.size() - 1, -1, -1):
		if projectiles[index].life <= 0.0: projectiles.remove_at(index)

func update_particles(delta: float) -> void:
	for particle in particles:
		particle.life -= delta
		particle.pos += particle.vel * delta
		particle.vel *= pow(0.08, delta)
	for index in range(particles.size() - 1, -1, -1):
		if particles[index].life <= 0.0: particles.remove_at(index)

func spawn_particles(position: Vector2, color: Color, amount: int) -> void:
	for index in range(amount):
		particles.append({"pos": position, "vel": Vector2.from_angle(randf() * TAU) * randf_range(35.0, 150.0), "life": randf_range(0.25, 0.65), "color": color})

func find_node_path(start: int, goal: int) -> Array[int]:
	if not nodes[start].active or not nodes[goal].active: return []
	var queue: Array[int] = [start]
	var came_from := {start: -1}
	while not queue.is_empty():
		var current: int = queue.pop_front()
		if current == goal: break
		for neighbor in node_neighbors(current):
			if nodes[neighbor].active and not came_from.has(neighbor):
				came_from[neighbor] = current
				queue.append(neighbor)
	if not came_from.has(goal): return []
	var result: Array[int] = []
	var cursor := goal
	while cursor != -1:
		result.push_front(cursor)
		cursor = int(came_from[cursor])
	return result

func node_neighbors(index: int) -> Array[int]:
	var result: Array[int] = []
	for other in range(nodes.size()):
		if other != index and nodes[index].pos.distance_to(nodes[other].pos) <= 157.0:
			result.append(other)
	return result

func path_position(distance: float) -> Vector2:
	var remaining := clampf(distance, 0.0, total_path_length)
	for index in range(path_lengths.size()):
		if remaining <= path_lengths[index]:
			return path_points[index].lerp(path_points[index + 1], remaining / path_lengths[index])
		remaining -= path_lengths[index]
	return path_points[path_points.size() - 1]

func node_at(point: Vector2) -> int:
	for index in range(nodes.size()):
		if nodes[index].pos.distance_to(point) <= 27.0: return index
	return -1

func cost_for_mode(mode: int) -> int:
	return [6, 22, 30, 36, 26][mode]

func handle_node(index: int) -> void:
	if index < 0 or state not in [GameState.BUILD, GameState.WAVE]: return
	var node: Dictionary = nodes[index]
	var cost := cost_for_mode(build_mode)
	match build_mode:
		BuildMode.CABLE:
			if node.active:
				show_message("THIS SOCKET IS ALREADY ON THE GRID", 1.2)
				return
			var adjacent := false
			for neighbor in node_neighbors(index):
				if nodes[neighbor].active: adjacent = true
			if not adjacent:
				show_message("EXTEND FROM AN ACTIVE CYAN SOCKET", 1.4)
				synth.error()
				return
			if spend(cost):
				node.active = true
				spawn_particles(node.pos, Palette.CYAN, 12)
				synth.confirm()
		BuildMode.CAPACITOR, BuildMode.ARC, BuildMode.PULSE:
			if not node.active or node.building != "":
				show_message("BUILDINGS REQUIRE AN EMPTY ACTIVE SOCKET", 1.4)
				synth.error()
				return
			if spend(cost):
				node.building = ["", "capacitor", "arc", "pulse"][build_mode]
				node.charge = 0.0
				spawn_particles(node.pos, mode_color(build_mode), 14)
				synth.confirm()
		BuildMode.UPGRADE:
			if node.building not in ["capacitor", "arc", "pulse"] or int(node.level) >= 3:
				show_message("SELECT A LEVEL 1 OR 2 BUILDING", 1.3)
				synth.error()
				return
			var upgrade_cost := cost + (int(node.level) - 1) * 12
			if spend(upgrade_cost):
				node.level += 1
				node.charge += 2.0
				spawn_particles(node.pos, Palette.AMBER, 18)
				synth.confirm()

func spend(amount: int) -> bool:
	if credits < amount:
		show_message("NOT ENOUGH GRID CREDIT", 1.3)
		synth.error()
		return false
	credits -= amount
	return true

func mode_color(mode: int) -> Color:
	return [Palette.CYAN, Palette.VIOLET, Palette.CYAN, Palette.AMBER, Palette.MINT][mode]

func launch_wave() -> void:
	if state != GameState.BUILD: return
	var armed := false
	for node in nodes:
		if node.building in ["arc", "pulse"]: armed = true
	if not armed:
		show_message("PLACE AT LEAST ONE DEFENSE TOWER", 1.8)
		synth.error()
		return
	state = GameState.WAVE
	wave_spawned = 0
	spawn_timer = 0.35
	show_message("WAVE %d — %s" % [wave_index + 1, waves[wave_index].name], 2.0)
	synth.play_chord([146.83, 220.0, 293.66], 0.2, -21.0)

func show_message(text: String, duration: float) -> void:
	message = text
	message_time = duration

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		hover_node = node_at(event.position)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		handle_click(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		handle_click(event.position)
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			return_to_menu.emit()
		elif state == GameState.INTRO:
			reset_run()
		elif state == GameState.BUILD and event.keycode in [KEY_ENTER, KEY_SPACE]:
			launch_wave()
		elif state in [GameState.WON, GameState.LOST] and event.keycode in [KEY_ENTER, KEY_SPACE, KEY_R]:
			reset_run()

func handle_click(point: Vector2) -> void:
	if menu_rect.has_point(point):
		return_to_menu.emit()
		return
	if state == GameState.INTRO:
		reset_run()
		return
	if state in [GameState.WON, GameState.LOST]:
		reset_run()
		return
	for index in range(mode_rects.size()):
		if mode_rects[index].has_point(point):
			build_mode = index as BuildMode
			synth.click()
			return
	if launch_rect.has_point(point):
		launch_wave()
		return
	handle_node(node_at(point))

func _draw() -> void:
	if state == GameState.INTRO:
		draw_intro()
		return
	draw_field()
	draw_sidebar()
	draw_effects()
	if state == GameState.WON: draw_result(true)
	elif state == GameState.LOST: draw_result(false)
	if screen_flash > 0.0:
		draw_rect(Rect2(Vector2.ZERO, VIEW), Palette.with_alpha(Palette.CORAL, screen_flash * 0.24))

func draw_intro() -> void:
	draw_texture_rect(KEY_ART, Rect2(Vector2.ZERO, VIEW), false)
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.02, 0.03, 0.08, 0.52))
	draw_string(ThemeDB.fallback_font, Vector2(62, 76), "PROTOTYPE 03  //  CIRCUIT TOWER DEFENSE", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Palette.VIOLET)
	draw_string(ThemeDB.fallback_font, Vector2(62, 142), "CAPACITOR DEFENSE", HORIZONTAL_ALIGNMENT_LEFT, -1, 51, Palette.PAPER)
	draw_string(ThemeDB.fallback_font, Vector2(64, 184), "A tower without charge is only architecture.", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Palette.MUTED)
	var panel := Rect2(62, 376, 590, 210)
	draw_style_box(Palette.rounded_box(Color(0.035, 0.05, 0.12, 0.94), 20, Palette.VIOLET, 2), panel)
	draw_string(ThemeDB.fallback_font, Vector2(88, 416), "GRID PROTOCOL", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Palette.VIOLET)
	draw_string(ThemeDB.fallback_font, Vector2(88, 458), "1. Extend cyan cable into empty sockets.", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Palette.PAPER)
	draw_string(ThemeDB.fallback_font, Vector2(88, 492), "2. Build towers. Watch power packets travel.", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Palette.PAPER)
	draw_string(ThemeDB.fallback_font, Vector2(88, 526), "3. Capacitors store five packets, then burst-charge nearby towers.", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Palette.MUTED)
	draw_string(ThemeDB.fallback_font, Vector2(62, 650), "PRESS ANY KEY OR TAP TO ENERGIZE", HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Palette.VIOLET)
	draw_menu_button()

func draw_field() -> void:
	draw_rect(Rect2(0, 0, FIELD_RIGHT, 720), Color("070a14"))
	for x in range(0, int(FIELD_RIGHT), 36):
		draw_line(Vector2(x, 96), Vector2(x, 720), Palette.with_alpha(Palette.BLUE, 0.035), 1)
	for y in range(96, 721, 36):
		draw_line(Vector2(0, y), Vector2(FIELD_RIGHT, y), Palette.with_alpha(Palette.BLUE, 0.035), 1)
	# Enemy path.
	for index in range(path_points.size() - 1):
		draw_line(path_points[index], path_points[index + 1], Palette.with_alpha(Palette.CORAL, 0.16), 38, true)
		draw_line(path_points[index], path_points[index + 1], Palette.with_alpha(Palette.CORAL, 0.42), 3, true)
		var direction := path_points[index].direction_to(path_points[index + 1])
		var length := path_points[index].distance_to(path_points[index + 1])
		for step in range(36, int(length), 72):
			var point := path_points[index] + direction * step
			draw_line(point - direction * 8, point + direction * 8, Palette.with_alpha(Palette.AMBER, 0.45), 3)
	# Potential and live circuit edges.
	for index in range(nodes.size()):
		for neighbor in node_neighbors(index):
			if neighbor <= index: continue
			var active: bool = bool(nodes[index].active) and bool(nodes[neighbor].active)
			var color := Palette.with_alpha(Palette.CYAN, 0.42 if active else 0.065)
			draw_line(nodes[index].pos, nodes[neighbor].pos, color, 5 if active else 2, true)
			if active: draw_line(nodes[index].pos, nodes[neighbor].pos, Palette.with_alpha(Palette.PAPER, 0.16), 1, true)
	for index in range(nodes.size()): draw_node(index)
	for packet in packets: draw_packet(packet)
	for enemy in enemies: draw_enemy(enemy)
	for item in projectiles: draw_projectile(item)
	# Base reactor endpoint.
	draw_style_box(Palette.rounded_box(Palette.PANEL, 12, Palette.CORAL, 2), Rect2(972, 529, 45, 72))
	draw_string(ThemeDB.fallback_font, Vector2(972, 622), "CORE", HORIZONTAL_ALIGNMENT_CENTER, 45, 11, Palette.MUTED)

func draw_node(index: int) -> void:
	var node: Dictionary = nodes[index]
	var pos: Vector2 = node.pos
	var hovered := hover_node == index
	if not node.active:
		draw_circle(pos, 18 if not hovered else 22, Palette.with_alpha(Palette.MUTED, 0.16))
		draw_arc(pos, 17, 0, TAU, 24, Palette.with_alpha(Palette.MUTED, 0.38), 2)
		return
	var glow := 0.1 + float(node.pulse) * 0.35 + (0.08 if hovered else 0.0)
	draw_circle(pos, 30 + float(node.pulse) * 18, Palette.with_alpha(Palette.CYAN, glow))
	draw_circle(pos, 20, Palette.PANEL)
	draw_arc(pos, 20, 0, TAU, 28, Palette.CYAN, 3)
	match node.building:
		"reactor":
			draw_circle(pos, 13 + sin(elapsed * 4.0) * 2, Palette.CYAN)
			draw_circle(pos, 6, Palette.PAPER)
		"capacitor":
			draw_rect(Rect2(pos + Vector2(-12, -18), Vector2(24, 36)), Palette.VIOLET)
			draw_rect(Rect2(pos + Vector2(-7, 12 - float(node.stored) * 5.0), Vector2(14, float(node.stored) * 5.0)), Palette.PAPER)
			draw_line(pos + Vector2(-6, -23), pos + Vector2(-6, -17), Palette.PAPER, 3)
			draw_line(pos + Vector2(6, -23), pos + Vector2(6, -17), Palette.PAPER, 3)
		"arc":
			draw_colored_polygon(PackedVector2Array([pos + Vector2(-15, 13), pos + Vector2(0, -21), pos + Vector2(15, 13)]), Palette.CYAN)
			draw_circle(pos + Vector2(0, -12), 6, Palette.PAPER)
		"pulse":
			draw_circle(pos, 15, Palette.AMBER)
			draw_circle(pos, 8, Palette.PANEL)
			draw_arc(pos, 25, -1.0, 1.0, 12, Palette.AMBER, 3)
	if node.building in ["arc", "pulse"]:
		var charge_color := Palette.CYAN if node.charge >= 1.0 else Palette.CORAL
		for pip in range(int(4 + node.level)):
			draw_circle(pos + Vector2(-18 + pip * 8, 29), 2.5, charge_color if pip < int(ceil(node.charge)) else Palette.PANEL_2)
	if node.building != "" and node.building != "reactor":
		draw_string(ThemeDB.fallback_font, pos + Vector2(-18, -27), "L%d" % node.level, HORIZONTAL_ALIGNMENT_CENTER, 36, 10, Palette.PAPER)

func draw_packet(packet: Dictionary) -> void:
	var route: Array = packet.route
	var segment: int = mini(int(packet.segment), route.size() - 1)
	var pos: Vector2
	if segment >= route.size() - 1:
		pos = nodes[route[-1]].pos
	else:
		pos = nodes[route[segment]].pos.lerp(nodes[route[segment + 1]].pos, float(packet.t))
	draw_circle(pos, 9, Palette.with_alpha(Palette.CYAN, 0.13))
	draw_circle(pos, 4.5, Palette.PAPER)
	draw_line(pos - Vector2(10, 0), pos, Palette.CYAN, 3)

func draw_enemy(enemy: Dictionary) -> void:
	var pos := path_position(enemy.distance)
	var size := 26.0 if enemy.boss else 16.0
	var color := Palette.PAPER if enemy.flash > 0.0 else Palette.CORAL
	draw_circle(pos, size + 9, Palette.with_alpha(Palette.CORAL, 0.12))
	draw_style_box(Palette.rounded_box(color, 6, Palette.AMBER if enemy.boss else Palette.CORAL, 2), Rect2(pos - Vector2(size, size * 0.72), Vector2(size * 2, size * 1.44)))
	draw_circle(pos + Vector2(-size * 0.35, 0), 3, Palette.INK)
	draw_circle(pos + Vector2(size * 0.35, 0), 3, Palette.INK)
	var hp_width := 52.0 if enemy.boss else 34.0
	draw_rect(Rect2(pos + Vector2(-hp_width * 0.5, -size - 15), Vector2(hp_width, 5)), Palette.INK)
	draw_rect(Rect2(pos + Vector2(-hp_width * 0.5, -size - 15), Vector2(hp_width * float(enemy.hp) / enemy.max_hp, 5)), Palette.AMBER)

func draw_projectile(item: Dictionary) -> void:
	var alpha := clampf(float(item.life) / item.max, 0, 1)
	if item.kind == "arc":
		var points := PackedVector2Array([item.from])
		for index in range(1, 6):
			points.append(item.from.lerp(item.to, index / 6.0) + Vector2(randf_range(-7, 7), randf_range(-7, 7)))
		points.append(item.to)
		draw_polyline(points, Palette.with_alpha(Palette.CYAN, alpha), 4)
	elif item.kind == "pulse":
		var radius := 76.0 * (1.0 - alpha * 0.65)
		draw_circle(item.to, radius, Palette.with_alpha(Palette.AMBER, 0.08 * alpha))
		draw_arc(item.to, radius, 0, TAU, 40, Palette.with_alpha(Palette.AMBER, alpha), 3)
	else:
		draw_line(item.from, item.to, Palette.with_alpha(Palette.VIOLET, alpha), 7)
		draw_line(item.from, item.to, Palette.with_alpha(Palette.PAPER, alpha), 2)

func draw_sidebar() -> void:
	draw_rect(Rect2(FIELD_RIGHT, 0, 1280 - FIELD_RIGHT, 720), Color("101528"))
	draw_rect(Rect2(0, 0, 1280, 96), Color(0.025, 0.035, 0.08, 0.97))
	draw_string(ThemeDB.fallback_font, Vector2(24, 34), "REACTOR INTEGRITY", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Palette.MUTED)
	draw_style_box(Palette.rounded_box(Palette.INK, 7), Rect2(24, 49, 255, 17))
	var hp_color := Palette.CYAN if base_hp > 6 else Palette.CORAL
	draw_style_box(Palette.rounded_box(hp_color, 7), Rect2(24, 49, 255 * float(base_hp) / max_base_hp, 17))
	draw_string(ThemeDB.fallback_font, Vector2(294, 67), "%d / %d" % [base_hp, max_base_hp], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, hp_color)
	draw_string(ThemeDB.fallback_font, Vector2(420, 34), "GRID CREDIT", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Palette.MUTED)
	draw_string(ThemeDB.fallback_font, Vector2(420, 68), "¤ %03d" % credits, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Palette.AMBER)
	draw_string(ThemeDB.fallback_font, Vector2(590, 34), "WAVE", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Palette.MUTED)
	draw_string(ThemeDB.fallback_font, Vector2(590, 68), "%d / %d" % [mini(wave_index + 1, waves.size()), waves.size()], HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Palette.PAPER)
	if wave_index < waves.size():
		draw_string(ThemeDB.fallback_font, Vector2(708, 34), waves[wave_index].name, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Palette.PAPER)
		var remaining := int(waves[wave_index].count) - wave_spawned + enemies.size() if state == GameState.WAVE else int(waves[wave_index].count)
		draw_string(ThemeDB.fallback_font, Vector2(708, 67), "%d HOSTILES" % remaining, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Palette.CORAL)
	draw_menu_button()

	draw_string(ThemeDB.fallback_font, Vector2(1038, 131), "BUILD GRID", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Palette.PAPER)
	draw_string(ThemeDB.fallback_font, Vector2(1038, 158), "Tap a tool, then a socket.", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Palette.MUTED)
	var labels := [["CABLE", "¤6"], ["CAPACITOR", "¤22"], ["ARC TOWER", "¤30"], ["PULSE", "¤36"], ["UPGRADE", "¤26+"]]
	for index in range(mode_rects.size()):
		var selected := build_mode == index
		var accent := mode_color(index)
		draw_style_box(Palette.rounded_box(accent if selected else Palette.PANEL, 12, accent, 2), mode_rects[index])
		draw_string(ThemeDB.fallback_font, Vector2(mode_rects[index].position.x, mode_rects[index].position.y + 29), labels[index][0], HORIZONTAL_ALIGNMENT_CENTER, mode_rects[index].size.x, 13, Palette.INK if selected else Palette.PAPER)
		draw_string(ThemeDB.fallback_font, Vector2(mode_rects[index].position.x, mode_rects[index].position.y + 53), labels[index][1], HORIZONTAL_ALIGNMENT_CENTER, mode_rects[index].size.x, 12, Palette.INK if selected else Palette.MUTED)

	var telemetry := Rect2(1038, 440, 224, 142)
	draw_style_box(Palette.rounded_box(Palette.INK, 14, Palette.with_alpha(Palette.CYAN, 0.25), 1), telemetry)
	draw_string(ThemeDB.fallback_font, Vector2(1056, 469), "POWER TELEMETRY", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Palette.CYAN)
	var active_count := 0
	var stored := 0.0
	for node in nodes:
		if node.active: active_count += 1
		stored += float(node.charge) + float(node.stored)
	draw_string(ThemeDB.fallback_font, Vector2(1056, 505), "LIVE SOCKETS", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Palette.MUTED)
	draw_string(ThemeDB.fallback_font, Vector2(1210, 505), str(active_count), HORIZONTAL_ALIGNMENT_RIGHT, 35, 15, Palette.PAPER)
	draw_string(ThemeDB.fallback_font, Vector2(1056, 535), "STORED CHARGE", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Palette.MUTED)
	draw_string(ThemeDB.fallback_font, Vector2(1210, 535), "%.0f" % stored, HORIZONTAL_ALIGNMENT_RIGHT, 35, 15, Palette.PAPER)
	draw_string(ThemeDB.fallback_font, Vector2(1056, 565), "PACKETS IN FLIGHT", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Palette.MUTED)
	draw_string(ThemeDB.fallback_font, Vector2(1210, 565), str(packets.size()), HORIZONTAL_ALIGNMENT_RIGHT, 35, 15, Palette.PAPER)

	var launch_color := Palette.CORAL if state == GameState.BUILD else Palette.PANEL_2
	draw_style_box(Palette.rounded_box(launch_color, 14), launch_rect)
	draw_string(ThemeDB.fallback_font, Vector2(launch_rect.position.x, launch_rect.position.y + 38), "LAUNCH WAVE" if state == GameState.BUILD else "WAVE IN PROGRESS", HORIZONTAL_ALIGNMENT_CENTER, launch_rect.size.x, 16, Palette.INK if state == GameState.BUILD else Palette.MUTED)
	if message_time > 0.0:
		var rect := Rect2(260, 108, 500, 42)
		draw_style_box(Palette.rounded_box(Color(0.025, 0.05, 0.1, 0.95), 11, Palette.CYAN, 1), rect)
		draw_string(ThemeDB.fallback_font, Vector2(260, 135), message, HORIZONTAL_ALIGNMENT_CENTER, 500, 14, Palette.PAPER)

func draw_effects() -> void:
	for particle in particles:
		draw_circle(particle.pos, 3.2, Palette.with_alpha(particle.color, clampf(particle.life * 2.0, 0, 1)))

func draw_result(victory: bool) -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.01, 0.02, 0.06, 0.86))
	var accent := Palette.CYAN if victory else Palette.CORAL
	var panel := Rect2(300, 150, 680, 420)
	draw_style_box(Palette.rounded_box(Palette.PANEL, 26, accent, 3), panel)
	draw_string(ThemeDB.fallback_font, Vector2(300, 221), "GRID FULLY CHARGED" if victory else "REACTOR BLACKOUT", HORIZONTAL_ALIGNMENT_CENTER, 680, 34, Palette.PAPER)
	draw_string(ThemeDB.fallback_font, Vector2(300, 262), "THE LAST SURGE HAS BEEN GROUNDED" if victory else "THE CIRCUIT COULD NOT HOLD", HORIZONTAL_ALIGNMENT_CENTER, 680, 16, accent)
	draw_string(ThemeDB.fallback_font, Vector2(355, 340), "WAVES", HORIZONTAL_ALIGNMENT_CENTER, 170, 14, Palette.MUTED)
	draw_string(ThemeDB.fallback_font, Vector2(355, 380), "%d / 5" % (5 if victory else wave_index), HORIZONTAL_ALIGNMENT_CENTER, 170, 29, Palette.PAPER)
	draw_string(ThemeDB.fallback_font, Vector2(555, 340), "CORE", HORIZONTAL_ALIGNMENT_CENTER, 170, 14, Palette.MUTED)
	draw_string(ThemeDB.fallback_font, Vector2(555, 380), "%d / 20" % base_hp, HORIZONTAL_ALIGNMENT_CENTER, 170, 29, Palette.PAPER)
	draw_string(ThemeDB.fallback_font, Vector2(755, 340), "GRID CREDIT", HORIZONTAL_ALIGNMENT_CENTER, 170, 14, Palette.MUTED)
	draw_string(ThemeDB.fallback_font, Vector2(755, 380), str(credits), HORIZONTAL_ALIGNMENT_CENTER, 170, 29, Palette.PAPER)
	draw_style_box(Palette.rounded_box(accent, 12), Rect2(426, 468, 428, 54))
	draw_string(ThemeDB.fallback_font, Vector2(426, 502), "TAP OR PRESS ENTER TO REBUILD", HORIZONTAL_ALIGNMENT_CENTER, 428, 16, Palette.INK)
	draw_menu_button()

func draw_menu_button() -> void:
	draw_style_box(Palette.rounded_box(Color(0.03, 0.04, 0.09, 0.95), 10, Palette.with_alpha(Palette.MUTED, 0.55), 1), menu_rect)
	draw_string(ThemeDB.fallback_font, Vector2(menu_rect.position.x, menu_rect.position.y + 25), "← GAME LAB", HORIZONTAL_ALIGNMENT_CENTER, menu_rect.size.x, 14, Palette.PAPER)
