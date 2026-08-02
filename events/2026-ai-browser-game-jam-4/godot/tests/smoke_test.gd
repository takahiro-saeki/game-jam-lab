extends SceneTree

const ZeroGame = preload("res://games/zero_percent_city/zero_percent_city.gd")
const ChargebackGame = preload("res://games/chargeback/chargeback.gd")
const CapacitorGame = preload("res://games/capacitor_defense/capacitor_defense.gd")
const ChargeClickerGame = preload("res://games/charge_clicker/charge_clicker.gd")
const ChargeClickerState = preload("res://games/charge_clicker/charge_state.gd")
const ChargeClickerSave = preload("res://games/charge_clicker/charge_save.gd")
const Launcher = preload("res://main.gd")
const ControllerConfig = preload("res://shared/controller_bindings.gd")

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
	test_controller_bindings()
	test_launcher()
	test_zero_percent_city()
	test_chargeback()
	test_capacitor_defense()
	test_charge_clicker()
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
	check(action_has_key("attack", KEY_C), "C performs a normal attack")
	check(action_has_joy_button("attack", JOY_BUTTON_Y), "gamepad Y performs the active combat action")

func test_controller_bindings() -> void:
	print("\nCONTROLLER BINDINGS")
	var config := ControllerConfig.new()
	config.reset_defaults(false)
	check(config.get_button("primary") == JOY_BUTTON_A, "default confirm button is A")
	check(config.get_button("combat_action") == JOY_BUTTON_Y, "default combat action button is Y")
	check(config.rebind("primary", JOY_BUTTON_X, false), "a controller action can be rebound")
	check(config.get_button("primary") == JOY_BUTTON_X, "new primary binding is stored")
	check(config.get_button("secondary") == JOY_BUTTON_A, "duplicate binding swaps the previous action")
	check(action_has_joy_button("jump", JOY_BUTTON_X), "custom primary binding updates jump")
	check(action_has_joy_button("dash", JOY_BUTTON_A), "swapped secondary binding updates dash")
	config.reset_defaults(false)

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
	launcher.controller_config.reset_defaults(false)
	launcher.controller_bindings = launcher.controller_config.bindings.duplicate(true)
	launcher.is_japanese = false
	launcher.open_settings()
	check(launcher.settings_open, "gamepad setup screen opens from the launcher")
	launcher.start_rebinding(0)
	launcher.capture_controller_button(JOY_BUTTON_X, false)
	check(launcher.controller_button("primary") == JOY_BUTTON_X, "setup screen captures a new controller button")
	check(launcher.controller_button("secondary") == JOY_BUTTON_A, "setup screen swaps duplicate bindings")
	launcher.close_settings()
	launcher.controller_config.reset_defaults(false)
	launcher.controller_bindings = launcher.controller_config.bindings.duplicate(true)
	launcher.hover_index = 0
	launcher._unhandled_input(joy_button(JOY_BUTTON_DPAD_RIGHT))
	check(launcher.hover_index == 1, "gamepad direction selects a game")
	launcher._unhandled_input(joy_button(JOY_BUTTON_A))
	check(launcher.active_game != null, "gamepad A launches the selected game")
	launcher.active_game.toggle_language()
	check(launcher.is_japanese, "in-game language choice persists in the launcher")
	launcher.return_to_menu()
	check(launcher.card_rects.size() == 4, "launcher exposes all four playable concepts")
	launcher.launch_game(3)
	check(launcher.active_game != null and launcher.active_game.get("run") != null, "fourth launcher card opens PROJECT CHARGE")
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
	game.enemies[0].pos = game.player_pos + Vector2(34, 0)
	var attack_hp: int = game.enemies[0].hp
	game.begin_attack()
	check(game.enemies[0].hp == attack_hp - 1, "normal attack damages a hostile")
	var first_wall: Rect2 = game.walls[0].rect
	var standing_center_y := 650.0 - game.PLAYER_SIZE.y * 0.5
	var jump_apex_bottom := standing_center_y - game.JUMP_SPEED * game.JUMP_SPEED / (2.0 * game.GRAVITY) + game.PLAYER_SIZE.y * 0.5
	check(jump_apex_bottom + 12.0 < first_wall.position.y, "the first wall has comfortable normal-jump clearance")
	check(game.break_wall(game.walls[0].rect), "dash wall can be broken")
	game.has_double_jump = true
	game.player_pos = Vector2(3446, 114)
	game.handle_interactions(0.016)
	check(game.run_state == game.RunState.PLAYING, "city core stays locked until the warden is defeated")
	game.boss_defeated = true
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
	check(game.enemy.hp == 68, "first authorization loads")
	var pool: Array[Dictionary] = game.all_cards()
	game.hand = [game.find_card(pool, "dispute").duplicate()]
	game.update_card_rects()
	game.energy = 3
	game.shield = 0
	game.hover_card = 0
	game.handle_controller_button(JOY_BUTTON_A)
	check(game.shield == 13 and game.counter == 3 and game.energy == 2, "DISPUTE spends energy and activates the selected policy")
	check(game.hand.is_empty(), "gamepad A plays the selected card")
	game.hand = [game.find_card(pool, "chargeback").duplicate()]
	game.energy = 3
	game.credit = 50
	var before_hp: int = game.enemy.hp
	game.play_card(0)
	check(game.enemy.hp == before_hp - 24, "CHARGEBACK scales with missing credit")
	game.archetype_counts = {"defense": 0, "debt": 0, "audit": 0}
	game.archetype_triggered = {"defense": false, "debt": false, "audit": false}
	game.policy_triggered = true
	game.hand = [game.find_card(pool, "dispute").duplicate(), game.find_card(pool, "dispute").duplicate()]
	game.energy = 3
	game.shield = 0
	game.play_card(0)
	game.play_card(0)
	check(game.shield == 23 and game.total_synergies >= 1, "two cards of one archetype trigger a meaningful synergy")
	game.enemy.hp = 1
	game.deal_damage(2)
	game.win_encounter()
	check(game.state == game.GameState.REWARD and game.reward_cards.size() == 3, "victory offers three rewards")
	game.energy = 0
	check(game.card_is_available(game.find_card(pool, "bankruptcy")), "reward cards stay bright and selectable without energy")
	var upgraded_rewards := 0
	for reward in game.reward_cards:
		if reward.upgraded: upgraded_rewards += 1
	check(upgraded_rewards >= 1, "every reward set includes an upgraded card")
	game.state = game.GameState.PLAYER_TURN
	check(not game.card_is_available(game.find_card(pool, "bankruptcy")), "hand cards still dim when energy is insufficient")
	game.start_run(2)
	check(game.policy_id == "forensic" and game.hand.size() == 6, "forensic policy opens with a six-card hand")
	game.free()

	seed(1337)
	var full_run := ChargebackGame.new()
	root.add_child(full_run)
	full_run.start_run(0)
	for decision in range(160):
		if full_run.state == full_run.GameState.PLAYER_TURN:
			for play in range(14):
				var choice := choose_chargeback_card(full_run)
				if choice < 0:
					break
				full_run.play_card(choice)
				if full_run.state != full_run.GameState.PLAYER_TURN:
					break
			if full_run.state == full_run.GameState.PLAYER_TURN:
				full_run.end_turn()
				full_run.resolve_enemy_turn()
		elif full_run.state == full_run.GameState.REWARD:
			var reward_choice := 0
			for index in range(full_run.reward_cards.size()):
				if bool(full_run.reward_cards[index].upgraded):
					reward_choice = index
					break
			full_run.take_reward(reward_choice)
		else:
			break
	check(full_run.state == full_run.GameState.WON, "a synergy-aware card strategy can reverse all three authorizations")
	full_run.free()

func choose_chargeback_card(game: Node) -> int:
	var best_index := -1
	var best_score := -999
	for index in range(game.hand.size()):
		var item: Dictionary = game.hand[index]
		if game.effective_card_cost(item) > game.energy:
			continue
		var id := str(item.id)
		var score := 0
		match id:
			"dispute": score = 72 if game.shield < game.enemy_intent else 24
			"freeze": score = 78 if game.shield < game.enemy_intent else 42
			"fraud_alert": score = 76 if game.shield < game.enemy_intent else 38
			"paper_trail": score = 82 if game.shield < game.enemy_intent else 48
			"class_action": score = 46 + game.shield
			"cashback": score = 55 + (game.max_credit - game.credit)
			"autopay": score = 75 if game.credit > 30 else -50
			"audit": score = 70
			"data_mine": score = 88
			"recurring": score = 38 + game.cards_played_this_turn * 12
			"chargeback": score = 58 + (game.max_credit - game.credit)
			"interest": score = 62
			"leverage": score = 80 if game.credit > 45 and game.energy <= 1 else -40
			"compound": score = 44 + (game.max_credit - game.credit)
			"bankruptcy": score = 74 if game.credit > 34 else -70
			"limit": score = 68
			"refund": score = 64 + (game.max_credit - game.credit)
			_: score = -100
		if int(item.cost) == 0:
			score += 12
		if score > best_score:
			best_score = score
			best_index = index
	return best_index if best_score > 0 else -1

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
	game.set_simulation_speed(3.0)
	check(game.simulation_speed == 3.0, "simulation can run at triple speed")
	game.nodes[3].active = true
	game.nodes[3].building = "pulse"
	check(is_equal_approx(game.network_synergy_multiplier(), 1.25), "capacitor, arc, and pulse unlock network resonance")
	game.overcharge_meter = 100.0
	game.handle_controller_button(JOY_BUTTON_Y)
	check(game.overdrive_time > 0.0 and game.overcharge_meter == 0.0, "gamepad active ability triggers overdrive")
	game.free()

	var full_run := CapacitorGame.new()
	root.add_child(full_run)
	full_run.reset_run()
	full_run.build_mode = full_run.BuildMode.ARC
	full_run.handle_node(1)
	full_run.build_mode = full_run.BuildMode.CABLE
	full_run.handle_node(2)
	full_run.build_mode = full_run.BuildMode.CAPACITOR
	full_run.handle_node(2)
	full_run.build_mode = full_run.BuildMode.CABLE
	full_run.handle_node(3)
	full_run.build_mode = full_run.BuildMode.PULSE
	full_run.handle_node(3)
	full_run.simulation_speed = 3.0
	for wave_number in range(full_run.waves.size()):
		full_run.launch_wave()
		for tick in range(16000):
			full_run._process(1.0 / 60.0)
			if full_run.state != full_run.GameState.WAVE:
				break
		if full_run.state in [full_run.GameState.WON, full_run.GameState.LOST]:
			break
		improve_test_grid(full_run)
	check(full_run.state == full_run.GameState.WON, "a sensible synergistic grid can clear all five waves")
	full_run.free()

func improve_test_grid(game: Node) -> void:
	# Spend inter-wave rewards the same way a first-time player reasonably might:
	# improve the original network, then add one more chained arc before the boss.
	for index in [1, 3, 2]:
		if int(game.nodes[index].level) < 3:
			var cost: int = game.cost_for_mode(game.BuildMode.UPGRADE) + (int(game.nodes[index].level) - 1) * 12
			if game.credits >= cost:
				game.build_mode = game.BuildMode.UPGRADE
				game.handle_node(index)
				return
	if not game.nodes[4].active and game.credits >= 36:
		game.build_mode = game.BuildMode.CABLE
		game.handle_node(4)
		game.build_mode = game.BuildMode.ARC
		game.handle_node(4)

func test_charge_clicker() -> void:
	print("\nPROJECT CHARGE")
	var game := ChargeClickerGame.new()
	game.persistence_enabled = false
	root.add_child(game)
	game.is_japanese = true
	game.run.rng.seed = 404
	check(game.run.cells.size() == 6, "prototype starts with six independent charge cells")
	check(game.loc("充電", "CHARGE") == "充電", "prototype supports Japanese copy")

	for input in range(4):
		game.perform_charge(false, 0)
	var partial: Dictionary = game.perform_discharge(false, 0)
	check(bool(partial.valid) and not bool(partial.super), "stored energy can be banked with a safe partial discharge")
	check(int(partial.credits) > 0, "partial discharge awards spendable energy shards")

	game.run.reset()
	game.run.add_charge_energy(game.run.total_capacity(), 0.0, false)
	var safe_full: Dictionary = game.perform_discharge(false, 0)
	game.run.reset()
	game.run.add_charge_energy(game.run.total_capacity(), 0.0, false)
	for input in range(6):
		game.perform_charge(false, 0)
	var risky_full: Dictionary = game.perform_discharge(false, 0)
	check(bool(safe_full.super) and bool(risky_full.super), "six full cells trigger SUPER DISCHARGE")
	check(float(risky_full.output) > float(safe_full.output) * 1.25, "manual overcharge meaningfully increases full-discharge output")

	game.run.reset()
	game.run.credits = 100
	game.run.elapsed = 18.0
	var manual_before: float = game.run.manual_power
	check(game.try_purchase(0, false), "an affordable upgrade can be purchased")
	check(game.run.manual_power > manual_before, "HAND COIL immediately changes the charge model")
	check(game.run.first_purchase_time <= 30.0, "first purchase can land inside the 30-second target")
	game.handle_controller_button(joy_button(JOY_BUTTON_DPAD_RIGHT))
	check(game.controller_upgrade_selected == 1, "gamepad D-pad navigates the upgrade grid")
	game.handle_controller_button(joy_button(JOY_BUTTON_START))
	check(game.run.upgrade_level("capacity") == 1, "gamepad Start purchases the selected upgrade")

	game.run.reset()
	var auto_before: float = game.run.total_charge()
	game.toggle_auto(false)
	for tick in range(120):
		game.run.tick(1.0 / 60.0, false)
	check(game.run.total_charge() > auto_before, "AUTO mode adds charge without manual input")

	game.run.reset()
	game.run.add_charge_energy(game.run.total_capacity(), 0.0, false)
	game.run.heat = 99.0
	var meltdown: Dictionary = game.perform_charge(false, 0)
	check(bool(meltdown.meltdown) and game.run.meltdowns == 1, "pushing past maximum heat causes a meltdown")
	check(game.run.total_charge() < game.run.total_capacity() * 0.25, "meltdown removes most stored charge without ending the run")

	game.run.reset()
	for step in range(200):
		game.perform_charge(false, 0)
		if game.run.is_full() and game.run.overcharge >= 35.0:
			game.perform_discharge(false, 0)
		if game.run.purchases == 0 and game.run.can_purchase("manual"):
			game.try_purchase(0, false)
		game.run.tick(0.15, false)
	check(game.run.first_purchase_time >= 0.0 and game.run.first_purchase_time <= 30.0, "active play earns the first upgrade within 30 seconds")
	check(game.run.partial_discharges + game.run.super_discharges >= 3, "the 30-second loop supports repeated charge-discharge decisions")
	check(game.run.lifetime_output > 1500.0, "the prototype produces visible escalating output in a short session")
	game.free()

	var stage := ChargeClickerState.new()
	var restored: Dictionary = stage.apply_output(ChargeClickerState.RESTORE_GOAL, true)
	check(bool(restored.boss_started) and stage.stage_phase == stage.StagePhase.BOSS, "restoration target awakens the GENERATOR CORE mini-boss")
	stage.add_charge_energy(stage.total_capacity(), 0.0, false)
	stage.boss_attack_timer = 0.01
	var drain: Dictionary = stage.tick(0.02, false)
	check(bool(drain.boss_drain) and float(drain.drained) > 0.0, "GRID WRAITH drains the fullest cell when its warning expires")
	stage.add_charge_energy(stage.total_capacity(), 0.0, false)
	stage.boss_attack_timer = 1.0
	var interrupted: Dictionary = stage.apply_output(1000.0, true)
	check(bool(interrupted.interrupt) and stage.boss_interrupts == 1, "a full discharge interrupts the warned drain attack")
	stage.boss_hp = 1.0
	var defeated: Dictionary = stage.apply_output(2.0, false)
	check(bool(defeated.boss_defeated) and stage.stage_phase == stage.StagePhase.REWARD, "depleting boss HP opens the circuit reward choice")
	check(stage.select_reward("flywheel") and stage.stage_phase == stage.StagePhase.CLEAR, "choosing a permanent circuit completes the vertical slice")

	var save_path := "user://project_charge_smoke_test.cfg"
	var save := ChargeClickerSave.new(save_path)
	check(save.save(stage) == OK, "phase-two progress can be serialized")
	var restored_save := ChargeClickerState.new()
	check(save.load_into(restored_save), "serialized phase-two progress can be loaded")
	check(restored_save.stage_phase == restored_save.StagePhase.CLEAR and restored_save.reward_id == "flywheel", "save data preserves stage and reward progression")
	save.clear()

	var timed_run := ChargeClickerState.new()
	var upgrade_order := ["manual", "discharge", "surge", "cooling", "critical", "capacity", "auto", "insulation"]
	var upgrade_cursor := 0
	for step in range(3200):
		timed_run.manual_charge(0)
		var stage_tick: Dictionary = timed_run.tick(0.15, false)
		var should_fire: bool = timed_run.is_full() and (timed_run.overcharge >= 35.0 or timed_run.boss_warning_active())
		if should_fire:
			var shot: Dictionary = timed_run.discharge(0)
			timed_run.apply_output(float(shot.output), bool(shot.super))
		while upgrade_cursor < upgrade_order.size() and timed_run.can_purchase(str(upgrade_order[upgrade_cursor])):
			timed_run.purchase_upgrade(str(upgrade_order[upgrade_cursor]))
			upgrade_cursor += 1
		if timed_run.stage_phase == timed_run.StagePhase.REWARD:
			timed_run.select_reward("flywheel")
			break
	check(timed_run.stage_phase == timed_run.StagePhase.CLEAR, "an active upgrade strategy clears the complete Phase 2 slice")
	print("Phase 2 simulated clear time: %.1f seconds" % timed_run.stage_clear_time)
	check(timed_run.stage_clear_time >= 270.0 and timed_run.stage_clear_time <= 420.0, "active Phase 2 completion lands in the 5–7 minute target band")
