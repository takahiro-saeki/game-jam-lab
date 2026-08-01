extends SceneTree

const ZeroGame = preload("res://games/zero_percent_city/zero_percent_city.gd")
const ChargebackGame = preload("res://games/chargeback/chargeback.gd")
const CapacitorGame = preload("res://games/capacitor_defense/capacitor_defense.gd")
const Launcher = preload("res://main.gd")

var failures: Array[String] = []

func _init() -> void:
	call_deferred("run_tests")

func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS  ", description)
	else:
		failures.append(description)
		push_error("FAIL  " + description)

func run_tests() -> void:
	test_input_map()
	test_launcher()
	test_zero_percent_city()
	test_chargeback()
	test_capacitor_defense()
	await process_frame
	await process_frame
	if failures.is_empty():
		print("\nAll game loop smoke tests passed.")
		quit(0)
	else:
		print("\n%d smoke test(s) failed." % failures.size())
		quit(1)

func test_input_map() -> void:
	print("\nINPUT MAP")
	check(action_has_key("move_left", KEY_LEFT), "left arrow moves the player")
	check(action_has_key("move_right", KEY_RIGHT), "right arrow moves the player")
	check(action_has_key("jump", KEY_UP), "up arrow jumps")
	check(action_has_key("dash", KEY_DOWN), "down arrow dashes")
	check(action_has_joy_axis("move_left", JOY_AXIS_LEFT_X, -1.0), "left stick moves the player")
	check(action_has_joy_button("jump", JOY_BUTTON_A), "gamepad A jumps")
	check(action_has_joy_button("dash", JOY_BUTTON_X), "gamepad X dashes")

func action_has_key(action: StringName, keycode: Key) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey and event.physical_keycode == keycode:
			return true
	return false

func action_has_joy_button(action: StringName, button: JoyButton) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadButton and event.button_index == button:
			return true
	return false

func action_has_joy_axis(action: StringName, axis: JoyAxis, value: float) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadMotion and event.axis == axis and is_equal_approx(event.axis_value, value):
			return true
	return false

func joy_button(button: JoyButton) -> InputEventJoypadButton:
	var event := InputEventJoypadButton.new()
	event.button_index = button
	event.pressed = true
	return event

func test_launcher() -> void:
	print("\nLAUNCHER")
	var launcher := Launcher.new()
	root.add_child(launcher)
	launcher.is_japanese = false
	launcher.hover_index = 0
	launcher._unhandled_input(joy_button(JOY_BUTTON_DPAD_RIGHT))
	check(launcher.hover_index == 1, "gamepad direction selects a game")
	launcher._unhandled_input(joy_button(JOY_BUTTON_A))
	check(launcher.active_game != null, "gamepad A launches the selected game")
	launcher.active_game.toggle_language()
	check(launcher.is_japanese, "in-game language choice persists in the launcher")
	launcher.return_to_menu()
	launcher.free()

func test_zero_percent_city() -> void:
	print("\nZERO PERCENT CITY")
	var game := ZeroGame.new()
	root.add_child(game)
	game.is_japanese = true
	game._unhandled_input(joy_button(JOY_BUTTON_A))
	check(game.run_state == game.RunState.PLAYING, "run boots into PLAYING")
	check(game.player_pos == Vector2(130, 600), "gamepad A boots the run")
	check(game.loc("日本語", "English") == "日本語", "Japanese copy is selected")
	game.player_pos = game.pickups[0].rect.get_center()
	game.handle_interactions(0.016)
	check(game.has_dash, "dash module can be acquired")
	check(game.break_wall(game.walls[0].rect), "dash wall can be broken")
	game.has_double_jump = true
	game.player_pos = Vector2(3446, 114)
	game.handle_interactions(0.016)
	check(game.run_state == game.RunState.COMPLETE, "city core completes the run")
	game.free()

func test_chargeback() -> void:
	print("\nCHARGEBACK")
	var game := ChargebackGame.new()
	root.add_child(game)
	game.is_japanese = false
	game.start_run()
	check(game.hand.size() == 5, "opening hand draws five cards")
	game.toggle_language()
	check(game.is_japanese and game.deck[0].title == "異議申立て", "in-game language toggle relocalizes cards")
	check(game.enemy.name == "無料体験ヒドラ", "in-game language toggle relocalizes the encounter")
	check(game.enemy.hp == 58, "first authorization loads")
	var pool: Array[Dictionary] = game.all_cards()
	game.hand = [game.find_card(pool, "dispute").duplicate()]
	game.update_card_rects()
	game.energy = 3
	game.shield = 0
	game.hover_card = 0
	game.handle_controller_button(JOY_BUTTON_A)
	check(game.shield == 9 and game.energy == 2, "DISPUTE spends energy and grants block")
	check(game.hand.is_empty(), "gamepad A plays the selected card")
	game.hand = [game.find_card(pool, "chargeback").duplicate()]
	game.energy = 3
	game.credit = 50
	var before_hp: int = game.enemy.hp
	game.play_card(0)
	check(game.enemy.hp == before_hp - 19, "CHARGEBACK scales with missing credit")
	game.enemy.hp = 1
	game.deal_damage(2)
	game.win_encounter()
	check(game.state == game.GameState.REWARD and game.reward_cards.size() == 3, "victory offers three rewards")
	game.free()

func test_capacitor_defense() -> void:
	print("\nCAPACITOR DEFENSE")
	var game := CapacitorGame.new()
	root.add_child(game)
	game.is_japanese = true
	game.reset_run()
	check(game.wave_name(0) == "偵察電流", "wave names use Japanese copy")
	game.handle_controller_button(JOY_BUTTON_RIGHT_SHOULDER)
	game.handle_controller_button(JOY_BUTTON_RIGHT_SHOULDER)
	check(game.build_mode == game.BuildMode.ARC, "gamepad shoulder cycles build tools")
	game.hover_node = 1
	game.handle_controller_button(JOY_BUTTON_A)
	check(game.nodes[1].building == "arc" and game.credits == 82, "arc tower builds on a live socket")
	game.move_node_focus(Vector2.RIGHT)
	check(game.hover_node == 2, "gamepad direction selects the next socket")
	game.build_mode = game.BuildMode.CABLE
	game.handle_controller_button(JOY_BUTTON_A)
	check(game.nodes[2].active and game.credits == 76, "cable extends the powered grid")
	game.build_mode = game.BuildMode.CAPACITOR
	game.handle_node(2)
	check(game.nodes[2].building == "capacitor" and game.credits == 54, "capacitor builds on the new route")
	game.nodes[1].charge = 1.0
	game.enemies = [{"distance": 480.0, "hp": 30, "max_hp": 30, "speed": 0.0, "reward": 1, "boss": false, "slow": 0.0, "flash": 0.0}]
	var before_hp: int = game.enemies[0].hp
	game.update_towers(0.016)
	check(game.enemies[0].hp < before_hp, "charged tower damages an enemy in range")
	game.state = game.GameState.BUILD
	game.launch_wave()
	check(game.state == game.GameState.WAVE, "armed grid launches a wave")
	game.free()
