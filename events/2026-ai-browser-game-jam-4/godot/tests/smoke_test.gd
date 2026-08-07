extends SceneTree

const ZeroGame = preload("res://games/zero_percent_city/zero_percent_city.gd")
const ChargebackGame = preload("res://games/chargeback/chargeback.gd")
const CapacitorGame = preload("res://games/capacitor_defense/capacitor_defense.gd")
const ChargeClickerGame = preload("res://games/charge_clicker/charge_clicker.gd")
const ChargeClickerState = preload("res://games/charge_clicker/charge_state.gd")
const ChargeClickerSave = preload("res://games/charge_clicker/charge_save.gd")
const ChargeStageCatalog = preload("res://games/charge_clicker/stage_catalog.gd")
const ChargeCampaignRoute = preload("res://games/charge_clicker/charge_route.gd")
const ChargeGearCatalog = preload("res://games/charge_clicker/gear_catalog.gd")
const ChargeAchievements = preload("res://games/charge_clicker/charge_achievements.gd")
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
	test_charge_clicker_v5()
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

func test_charge_clicker_v5() -> void:
	print("\nPROJECT CHARGE V8 — OVERLIMIT / PRIME CURRENT / TRUE ENDING")
	var state := ChargeClickerState.new()
	state.rng.seed = 404
	check(state.auto_enabled and state.stage_phase == state.StagePhase.BOSS, "v8 starts with AUTO fire online and direct enemy combat")
	check(ChargeGearCatalog.GEARS.size() == 5 and ChargeGearCatalog.SKILLS.size() == 86 and ChargeGearCatalog.total_max_ranks() == 317, "five visible gear trees contain eighty-six nodes and 317 attainable ranks")
	check(ChargeGearCatalog.skills_for_gear_tier("striker", 2).size() == 5 and ChargeGearCatalog.skills_for_gear_tier("core", 3).size() == 5, "Tier II and III expand every gear from three to five nodes")
	check(state.technology_tier() == 1 and not state.skill_unlocked("servo_overdrive") and state.skill_lock_reason("servo_overdrive") == "tier:2", "Tier II remains visibly locked before the normal boss")
	var tier_state := ChargeClickerState.new()
	tier_state.grant_boss_core("predation_reversal")
	check(tier_state.technology_tier() == 2 and tier_state.skill_unlocked("servo_overdrive") and not tier_state.skill_unlocked("abyss_breaker"), "a normal boss core unlocks Tier II without prematurely opening Tier III")
	for core_id in ["impact_guidance", "deep_storage", "redheat_conversion", "cascade_relay", "swarm_clock", "phase_computation"]:
		tier_state.grant_beast_core(core_id)
	check(tier_state.technology_tier() == 3 and tier_state.skill_unlocked("abyss_breaker"), "all six beast cores unlock the true-route Tier III")
	check(state.skill_unlocked("impact_coil") and not state.skill_unlocked("combo_gear"), "tree roots begin available while branch nodes enforce visible prerequisites")
	var hp_before := state.boss_hp
	var first_hit := state.manual_attack(0)
	check(float(first_hit.damage) >= 1.0 and state.boss_hp < hp_before, "every click deals damage immediately")
	check(int(first_hit.charge) == 1 and state.credits == 1, "every opening click generates one spendable CHARGE")
	var hp_before_auto := state.boss_hp
	state.tick(1.1, false)
	check(state.auto_hits > 0 and state.boss_hp < hp_before_auto, "the starting AUTO cannon attacks without a purchase or toggle")
	check(state.heat == 0.0 and state.meltdowns == 0 and not bool(state.discharge().valid), "heat, meltdown and mandatory DISCHARGE are removed from the core loop")

	state.begin_stage("gearmaw", "manual", 1.0, 10000.0, 0)
	for input in range(11):
		state.manual_attack(0)
	var break_hit := state.manual_attack(0)
	check(str(break_hit.mechanic) == "armor_break" and float(break_hit.damage) >= state.manual_damage * 4.0, "GEARMAW rewards every twelfth click with a four-times armor break")

	state.credits = 100000
	var old_manual := state.manual_damage
	var first_cost := state.upgrade_cost("impact_coil")
	check(state.purchase_upgrade("impact_coil") and state.manual_damage > old_manual, "IMPACT COIL raises direct click damage")
	check(state.upgrade_cost("impact_coil") > first_cost, "repeatable upgrade costs scale with each rank")
	var old_auto := state.estimated_auto_dps()
	check(state.purchase_upgrade("auto_cannon") and state.purchase_upgrade("auto_cannon") and state.purchase_upgrade("rapid_relay") and state.estimated_auto_dps() > old_auto, "AUTO damage and fire rate grow through their own prerequisite tree")
	check(state.skill_unlocked("core_resonance") and not state.skill_unlocked("impact_memory"), "core-frame root is available while stolen-core branches wait for their matching beast")
	var credits_before_respec := state.credits
	var refunded := state.respec_skills()
	check(refunded > 0 and state.skill_points_bought() == 0 and state.credits > credits_before_respec, "map respec refunds the full invested CHARGE across all five trees")

	state.credits = 1000000
	for rank in range(2):
		state.purchase_upgrade("charge_generator")
	for rank in range(2):
		state.purchase_upgrade("auto_induction")
	for rank in range(3):
		state.purchase_upgrade("compound_interest")
	check(state.purchase_upgrade("zero_output_generator") and state.manual_mode == "generate", "DYNAMO capstone permanently evolves the click into PURE COMMAND")
	var generator_hp := state.boss_hp
	var generator_hit := state.manual_attack(0)
	check(float(generator_hit.damage) == 0.0 and state.boss_hp == generator_hp and int(generator_hit.charge) >= 6, "PURE COMMAND deals zero direct damage while generating substantially more points")
	check(state.auto_boost_stacks == 1 and state.estimated_auto_dps() > old_auto, "PURE COMMAND overclocks the automatic arsenal instead of replacing it")
	check(state.toggle_manual_mode() and state.manual_mode == "generate", "PURE COMMAND cannot be toggled back to the weaker direct attack")

	state.begin_stage("vaultback", "charge", 1.0, 10000.0, 1)
	state.grant_charge(50.0)
	var open_hit := state.auto_attack(0)
	check(state.shell_open_timer > 0.0 and state.last_damage_multiplier >= 2.0 and float(open_hit.damage) > state.auto_damage * 2.0, "VAULTBACK turns PURE generation into a positive AUTO damage window")
	state.begin_stage("pyre_wyrm", "upgrade", 1.0, 10000.0, 2)
	state.credits = 1000
	state.purchase_upgrade("impact_coil")
	check(state.overdrive_timer > 0.0, "PYRE WYRM rewards buying an upgrade with overdrive instead of heat punishment")
	state.grant_beast_core("impact_guidance")
	state.grant_beast_core("cascade_relay")
	state.grant_beast_core("phase_computation")
	state.purchase_upgrade("core_resonance")
	state.purchase_upgrade("core_resonance")
	state.analysis = 100.0
	var guaranteed := state.manual_attack(-1)
	check(bool(guaranteed.critical) and state.analysis == 0.0, "PHASE MANTIS core converts analysis into a guaranteed critical hit")
	check(state.beast_cores.size() == 3 and state.skill_unlocked("impact_memory") and state.core_power >= 1.0, "defeated beast cores coexist and unlock their own CORE FRAME branches")
	state.grant_boss_core("predation_reversal")
	var feedback_before := state.credits
	state.manual_attack(1)
	check(state.credits > feedback_before, "PREDATION REVERSAL converts a share of outgoing damage back into CHARGE")

	var hybrid_state := ChargeClickerState.new()
	hybrid_state.credits = 10000
	hybrid_state.upgrade_levels["burst_loader"] = 3
	hybrid_state.upgrade_levels["chain_rounds"] = 3
	var bought_gatling := hybrid_state.purchase_upgrade("gatling_protocol")
	var bought_rail := hybrid_state.purchase_upgrade("rail_protocol")
	check(bought_gatling and bought_rail and hybrid_state.skill_points_bought() == 8, "gatling and rail branches can both complete in one campaign")
	check(is_equal_approx(hybrid_state.auto_interval, 0.95 * 0.7425) and is_equal_approx(hybrid_state.auto_damage, 0.9 * 2.304), "dual weapon mutations fuse into the deliberate HYBRID profile")
	check(hybrid_state.total_possible_ranks() == 317, "all 317 displayed upgrade ranks are attainable")

	var game := ChargeClickerGame.new()
	game.persistence_enabled = false
	root.add_child(game)
	game.is_japanese = true
	check(game.title_screen_open and game.title_button_rects.size() == 6, "PROJECT CHARGE opens on a complete title screen with persistent records")
	game.open_audio_settings()
	check(game.settings_open and game.settings_row_rects.size() == 5 and AudioServer.get_bus_index("Music") >= 0 and AudioServer.get_bus_index("SFX") >= 0, "settings expose saved audio and visual-comfort controls on separate buses")
	game.close_audio_settings()
	game.open_credits(true)
	check(game.credits_open and game.desired_bgm_key() == "ending_normal", "title and endings can open the full scrolling credits roll")
	game.close_credits()
	game.title_screen_open = false
	game.queue_encounter_intro("gearmaw")
	check(game.comms_time > 0.0 and not game.comms_text_ja.is_empty() and game.comms_queue.size() == 1, "each hunt can stage a non-blocking bilingual character exchange")
	check(game.BGMStreams.size() == 14 and game.desired_bgm_key() == "map", "music routing includes separate normal, world-engine and true-ending contexts")
	var unique_encounter_music := {}
	for music_key in game.EncounterBGMKeys.values():
		unique_encounter_music[str(music_key)] = true
	check(game.EncounterBGMKeys.size() == 12 and unique_encounter_music.size() == 10, "the original nine enemies remain unique while all three final forms share one connected suite")
	var expected_encounter_music := {
		"gearmaw": "hunt",
		"vaultback": "vaultback",
		"pyre_wyrm": "pyre_wyrm",
		"relay_hydra": "relay_hydra",
		"swarm_matriarch": "swarm_matriarch",
		"phase_mantis": "phase_mantis",
		"grid_leech": "grid_leech",
		"thermal_titan": "boss",
		"arch_singularity": "singularity",
		"prime_current_form_1": "prime_current",
		"prime_current_form_2": "prime_current",
		"prime_current_form_3": "prime_current",
	}
	check(game.EncounterBGMKeys == expected_encounter_music, "selected Suno masters are assigned to the intended enemy identities")
	check(game.AutoProjectileTextures.size() == 3 and game.AutoProjectileTextures["standard"].resource_path.ends_with("auto-vfx-arc-lance-v10-a.png"), "PixelLab AUTO projectiles are integrated for standard, gatling and rail weapon forms")
	check(game.OverlimitSocketTexture.resource_path.ends_with("overlimit-socket-seraph-lock-v10-c.png"), "the selected seraph-lock emblem distinguishes OVERLIMIT nodes")
	check(game.MechanicalBeastTextures["prime_current_form_3"].resource_path.ends_with("final-fallen-machine-seraph-v9-c-cutout.png"), "the transparent cutout of the human-selected Fallen Machine Seraph is integrated into final form three")
	check(str(ChargeStageCatalog.boss("prime_current_form_3").name_en) == "PRIME CURRENT — FALLEN MACHINE SERAPH", "final form three uses the selected Fallen Machine Seraph identity")
	var music_test_phases := {
		game.CampaignRoute.RoutePhase.STAGE: "hunt",
		game.CampaignRoute.RoutePhase.BOSS: "boss",
		game.CampaignRoute.RoutePhase.SINGULARITY: "singularity",
		game.CampaignRoute.RoutePhase.POST_TRUE_CHOICE: "ending_world",
		game.CampaignRoute.RoutePhase.FINAL_BOSS: "prime_current",
		game.CampaignRoute.RoutePhase.FINAL_END: "ending_true",
	}
	var music_routes_match := true
	for phase in music_test_phases:
		game.campaign_route.phase = phase
		music_routes_match = music_routes_match and game.desired_bgm_key() == str(music_test_phases[phase])
	game.campaign_route.phase = game.CampaignRoute.RoutePhase.MAP
	check(music_routes_match, "campaign phases select hunt, boss, true-boss and ending music deterministically")
	game.open_gear_tree(2)
	check(game.gear_tree_open and game.selected_tree_skills().size() == 7, "combat UI opens a dedicated, navigable skill tree for the selected gear")
	check(game.tree_node_rect(game.selected_tree_skills()[0]).size.x >= 44.0 and game.tree_node_rect(game.selected_tree_skills()[0]).size.y >= 44.0, "skill-tree nodes remain touch-sized")
	game.close_gear_tree()
	check(game.format_integer(12000000.0) == "12,000,000", "enemy HP formatter exposes exact readable totals")
	check(game.start_stage_by_index(0) and game.run.current_stage_id == "gearmaw", "hunt-map selection launches the chosen mechanical beast")
	var manual_before_hold: int = game.run.manual_inputs
	game.begin_charge()
	game._process(1.0)
	game.end_charge()
	check(game.run.manual_inputs == manual_before_hold + 1, "holding the attack input no longer generates repeated manual clicks")
	game.run.boss_hp = 1.0
	game.perform_charge(false, 1)
	check(game.run.stage_phase == game.ChargeState.StagePhase.CLEAR, "one direct click can finish a weakened beast without a discharge step")
	check(game.complete_stage_and_return_to_route(), "hunt clear returns to the six-beast map")
	check("gearmaw" in game.campaign_route.completed_stage_ids and "impact_guidance" in game.run.beast_cores, "defeated beast core is integrated automatically")
	game.free()

	var route := ChargeCampaignRoute.new()
	for id in ["gearmaw", "vaultback", "pyre_wyrm"]:
		check(route.select_stage(id), "route can select beast %s" % id)
		check(route.complete_current_stage(str(ChargeStageCatalog.stage(id).core_id)), "route records defeated beast %s" % id)
	check(route.phase == route.RoutePhase.BOSS_SELECT, "any three beast defeats unlock normal boss selection")
	check(route.choose_first_boss("grid_leech") and route.defeat_current_boss(), "one normal boss produces a complete normal ending")
	check(route.continue_true_route(), "normal ending can continue into the true route")
	for id in route.available_stage_ids():
		route.select_stage(id)
		route.complete_current_stage(str(ChargeStageCatalog.stage(id).core_id))
	check(route.phase == route.RoutePhase.ENHANCED_BOSS and route.current_boss_id == "thermal_titan", "the unchosen boss returns enhanced after all six beasts")
	check(route.defeat_current_boss() and route.phase == route.RoutePhase.SINGULARITY, "six beast cores and two boss victories unlock ARCH SINGULARITY")
	check(route.current_boss_id == "arch_singularity", "true boss uses the finalized ARCH SINGULARITY identity")
	var infinite_route := ChargeCampaignRoute.new()
	check(infinite_route.restore_snapshot(route.snapshot()) and infinite_route.defeat_current_boss(), "true-boss victory restores into the complete ending")
	check(infinite_route.phase == infinite_route.RoutePhase.POST_TRUE_CHOICE and infinite_route.start_infinite(), "world-engine victory unlocks optional Infinite Mode without adding wave-gated systems")
	check(infinite_route.infinite_wave == 1 and infinite_route.complete_infinite_wave() and infinite_route.infinite_wave == 2, "Infinite Mode records a cleared wave and advances without resetting the build")
	check(infinite_route.leave_infinite() and infinite_route.phase == infinite_route.RoutePhase.POST_TRUE_CHOICE, "Infinite Mode can return to the post-Arch story choice")

	var overlimit_run := ChargeClickerState.new()
	for definition in ChargeGearCatalog.SKILLS:
		overlimit_run.upgrade_levels[str(definition.id)] = int(definition.max_rank)
	overlimit_run.refresh_stats()
	check(overlimit_run.unlock_overlimit_system() and overlimit_run.singularity_residue == 1 and overlimit_run.technology_tier() == 4, "ARCH residue unlocks Tier IV and grants one free permanent restoration")
	check(overlimit_run.upgrade_cost("heavenbreaker_command") == 0, "the recovered residue makes the first OVERLIMIT restoration free")
	overlimit_run.credits = 5000000000
	var bought_every_overlimit := true
	for index in range(ChargeGearCatalog.OVERLIMITS.size()):
		var definition: Dictionary = ChargeGearCatalog.OVERLIMITS[index]
		bought_every_overlimit = bought_every_overlimit and overlimit_run.purchase_upgrade(str(definition.id))
		if index == 0:
			check(overlimit_run.upgrade_cost("perpetual_sun") == 20000000, "later OVERLIMIT restorations expose the intended escalating CHARGE economy")
	check(bought_every_overlimit and overlimit_run.overlimit_count() == 5 and overlimit_run.skill_points_bought() == 317, "all five OVERLIMITS remain simultaneously active outside the standard 317 ranks")
	overlimit_run.respec_skills()
	check(overlimit_run.overlimit_count() == 5, "standard free respec never removes permanent OVERLIMIT restorations")

	var final_route := ChargeCampaignRoute.new()
	check(final_route.restore_snapshot(route.snapshot()) and final_route.defeat_current_boss(), "the post-Arch route can be restored before the final branch")
	check(final_route.choose_world_engine_credits() and final_route.phase == final_route.RoutePhase.POST_TRUE_CHOICE, "choosing the world-engine credits preserves the two-choice checkpoint")
	check(final_route.answer_deep_signal() and final_route.final_boss_form == 1, "answering the deep signal starts the real final boss at form one")
	check(final_route.defeat_current_boss() and final_route.final_boss_form == 2 and final_route.defeat_current_boss() and final_route.final_boss_form == 3, "the real final boss advances through three saved forms")
	check(final_route.defeat_current_boss() and final_route.phase == final_route.RoutePhase.FINAL_END and final_route.final_boss_defeated, "defeating form three reaches the true ending")
	check(final_route.complete_final_credits() and final_route.phase == final_route.RoutePhase.POSTGAME, "true credits return to a persistent postgame terminal")

	var achievement_run := ChargeClickerState.new()
	var achievement_route := infinite_route
	for definition in ChargeGearCatalog.SKILLS:
		achievement_run.upgrade_levels[str(definition.id)] = int(definition.max_rank)
	for core_id in ["impact_guidance", "deep_storage", "redheat_conversion", "cascade_relay", "swarm_clock", "phase_computation"]:
		achievement_run.grant_beast_core(core_id)
	achievement_run.grant_boss_core("predation_reversal")
	achievement_run.grant_boss_core("furnace_sovereign")
	achievement_run.refresh_stats()
	var achievement_state := ChargeAchievements.new()
	achievement_state.evaluate(achievement_run, achievement_route)
	check(achievement_state.is_unlocked("all_skills") and achievement_state.unlocked_count() == ChargeAchievements.DEFINITIONS.size(), "standard records include full skill mastery without an Infinite-exclusive achievement")

	var save_path := "/tmp/project_charge_v5_smoke_test.cfg"
	var save := ChargeClickerSave.new(save_path)
	check(save.save_bundle(state, route, achievement_state) == OK, "v8 run, route and persistent records serialize atomically")
	var restored_state := ChargeClickerState.new()
	var restored_route := ChargeCampaignRoute.new()
	var restored_achievements := ChargeAchievements.new()
	check(save.load_bundle_into(restored_state, restored_route, restored_achievements), "v8 campaign save restores successfully")
	check("impact_guidance" in restored_state.beast_cores and restored_state.lifetime_charge == state.lifetime_charge and restored_route.phase == restored_route.RoutePhase.SINGULARITY, "save preserves CHARGE, repeatable upgrades, cores and route position")
	check(restored_achievements.is_unlocked("all_skills"), "achievement records persist independently of campaign state")
	var telemetry := ChargeClickerState.new()
	telemetry.set_playtest_mode("benchmark")
	telemetry.begin_stage("gearmaw", "manual", 1.0, 1.0, 0)
	telemetry.boss_hp = 1.0
	telemetry.advance_session_time(0.25)
	telemetry.tick(0.25, false)
	telemetry.manual_attack(1)
	var telemetry_report := telemetry.build_playtest_report(route.snapshot(), "test")
	check(telemetry.encounter_history.size() == 1 and float(telemetry.encounter_history[0].duration_seconds) > 0.0, "playtest telemetry records per-encounter clear time and counters")
	check(str(telemetry_report.mode) == "benchmark" and telemetry_report.encounters.size() == 1 and str(telemetry_report.build_id) == telemetry.BUILD_ID, "playtest report distinguishes benchmark runs and exports structured history")
	save.clear()

	var normal_seconds := simulate_project_charge_v5(false)
	var true_seconds := simulate_project_charge_v5(true)
	print("PROJECT CHARGE v8 efficient normal route: %.1f seconds" % normal_seconds)
	print("PROJECT CHARGE v8 efficient true route: %.1f seconds" % true_seconds)
	check(normal_seconds > 0.0 and normal_seconds < true_seconds, "true route is materially longer than the normal judging route")

func simulate_project_charge_v5(include_true_route: bool) -> float:
	var simulated := ChargeClickerState.new()
	simulated.rng.seed = 144
	var stages: Array[String] = []
	if include_true_route:
		stages.assign(ChargeStageCatalog.stage_ids())
	else:
		stages.assign(["gearmaw", "vaultback", "pyre_wyrm"])
	for stage_index in range(stages.size()):
		var id := str(stages[stage_index])
		var definition := ChargeStageCatalog.stage(id)
		simulated.begin_stage(id, str(definition.build_tag), 1.0, ChargeStageCatalog.stage_hp(id, stage_index), stage_index)
		var encounter_started := simulated.elapsed
		drive_project_charge_v5(simulated, 24000)
		print("  v8 sim %s: %.1fs, maxHP %.0f, upgrades %d, autoDPS %.0f, charge %d" % [id, simulated.elapsed - encounter_started, simulated.boss_max_hp, simulated.skill_points_bought(), simulated.estimated_auto_dps(), simulated.credits])
		simulated.grant_beast_core(str(definition.core_id))
		if stage_index == 2:
			var boss := ChargeStageCatalog.boss("grid_leech")
			simulated.begin_campaign_boss("grid_leech", float(boss.hp), false, false)
			var boss_started := simulated.elapsed
			drive_project_charge_v5(simulated, 36000)
			print("  v8 sim grid_leech: %.1fs, maxHP %.0f, autoDPS %.0f" % [simulated.elapsed - boss_started, simulated.boss_max_hp, simulated.estimated_auto_dps()])
			simulated.grant_boss_core(str(boss.core_id))
			if not include_true_route:
				return simulated.elapsed
	if include_true_route:
		var enhanced := ChargeStageCatalog.boss("thermal_titan")
		simulated.begin_campaign_boss("thermal_titan", float(enhanced.enhanced_hp), true, false)
		var enhanced_started := simulated.elapsed
		drive_project_charge_v5(simulated, 60000)
		print("  v8 sim thermal_titan+: %.1fs, maxHP %.0f, autoDPS %.0f" % [simulated.elapsed - enhanced_started, simulated.boss_max_hp, simulated.estimated_auto_dps()])
		simulated.grant_boss_core(str(enhanced.core_id))
		var singularity := ChargeStageCatalog.boss("arch_singularity")
		simulated.begin_campaign_boss("arch_singularity", float(singularity.hp), false, true)
		var singularity_started := simulated.elapsed
		drive_project_charge_v5(simulated, 90000)
		print("  v8 sim arch_singularity: %.1fs, hp %.0f, phase %d, upgrades %d, click %.0f, autoDPS %.0f, global %.2f, drones %d, interval %.3f, core %.2f, charge %d" % [simulated.elapsed - singularity_started, simulated.boss_hp, simulated.singularity_phase, simulated.skill_points_bought(), simulated.manual_damage, simulated.estimated_auto_dps(), simulated.global_output_multiplier(), simulated.drone_count, simulated.auto_interval, simulated.core_power, simulated.credits])
	return simulated.elapsed

func drive_project_charge_v5(simulated, max_steps: int) -> void:
	for step in range(max_steps):
		simulated.manual_attack(-1)
		simulated.advance_session_time(0.2)
		simulated.tick(0.2, false)
		purchase_affordable_skills(simulated)
		if simulated.stage_phase == simulated.StagePhase.CLEAR:
			return

func purchase_affordable_skills(simulated) -> void:
	# Breadth-first buying keeps all three roots viable, then follows unlocked
	# branches. Repeat because one rank can immediately unlock the next node.
	for pass_index in range(4):
		var bought := false
		for definition in ChargeClickerState.UPGRADE_DEFINITIONS:
			var id := str(definition.id)
			if simulated.can_purchase(id):
				simulated.purchase_upgrade(id)
				bought = true
		if not bought:
			return

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

	var campaign_game := ChargeClickerGame.new()
	campaign_game.persistence_enabled = false
	root.add_child(campaign_game)
	check(campaign_game.campaign_route.phase == campaign_game.CampaignRoute.RoutePhase.MAP, "new PROJECT CHARGE runs open on the six-stage circuit map")
	var campaign_stick := InputEventJoypadMotion.new()
	campaign_stick.axis = JOY_AXIS_LEFT_X
	campaign_stick.axis_value = 1.0
	campaign_game.handle_campaign_input(campaign_stick)
	check(campaign_game.campaign_selected == 1, "left stick navigates the PROJECT CHARGE circuit map")
	campaign_game.handle_campaign_input(campaign_stick)
	check(campaign_game.campaign_selected == 1, "held analog input is latched instead of scrolling repeatedly")
	campaign_stick.axis_value = 0.0
	campaign_game.handle_campaign_input(campaign_stick)
	campaign_game.campaign_selected = 0
	check(campaign_game.start_stage_by_index(0), "the selected map card launches its playable circuit")
	check(campaign_game.campaign_route.phase == campaign_game.CampaignRoute.RoutePhase.STAGE and campaign_game.run.current_stage_id == "generator_core", "map selection connects route and encounter state")
	campaign_game.run.apply_output(campaign_game.run.restore_goal, true)
	campaign_game.run.boss_hp = 1.0
	campaign_game.run.apply_output(2.0, false)
	check(campaign_game.select_reward(0), "a cleared campaign stage still offers a permanent build choice")
	check(campaign_game.complete_stage_and_return_to_route(), "stage clear registers the circuit and returns to route progression")
	check("generator_core" in campaign_game.campaign_route.completed_stage_ids and "flywheel" in campaign_game.run.circuit_rewards, "stage completion grants its named circuit reward")
	for stage_index in [1, 2]:
		check(campaign_game.start_stage_by_index(stage_index), "campaign stage %d launches from the map" % (stage_index + 1))
		campaign_game.run.apply_output(campaign_game.run.restore_goal, true)
		campaign_game.run.boss_hp = 1.0
		campaign_game.run.apply_output(2.0, false)
		campaign_game.select_reward(stage_index % 3)
		campaign_game.complete_stage_and_return_to_route()
	check(campaign_game.campaign_route.phase == campaign_game.CampaignRoute.RoutePhase.BOSS_SELECT, "three playable stage clears open the in-game boss selection screen")
	check(campaign_game.choose_campaign_boss(0) and campaign_game.run.current_boss_id == "grid_leech", "boss selection launches the chosen boss encounter")
	campaign_game.run.boss_hp = 1.0
	campaign_game.run.apply_output(2.0, false)
	check(campaign_game.complete_campaign_boss() and campaign_game.campaign_route.phase == campaign_game.CampaignRoute.RoutePhase.NORMAL_END, "the chosen boss reaches the complete normal ending screen")
	var share_result := campaign_game.campaign_result_text()
	check("PROJECT CHARGE" in share_result and "3/6" in share_result, "ending results produce a compact shareable campaign record")
	check(campaign_game.campaign_route.continue_true_route(), "normal ending can continue into the same build without reset")
	campaign_game.free()
	var reset_guard_game := ChargeClickerGame.new()
	reset_guard_game.persistence_enabled = false
	root.add_child(reset_guard_game)
	reset_guard_game.run.credits = 77
	check(not reset_guard_game.request_reset() and reset_guard_game.run.credits == 77, "the first PROJECT CHARGE reset input only arms a confirmation window")
	check(reset_guard_game.request_reset() and reset_guard_game.run.credits == 0, "a confirmed second reset starts a fresh campaign")
	reset_guard_game.free()

	var mechanics := ChargeClickerState.new()
	mechanics.begin_stage("capacitor_vault", "capacity", 1000.0, 1000.0)
	mechanics.add_charge_energy(mechanics.capacity * 2.0, 0.0, false)
	var vault_partial: Dictionary = mechanics.discharge(0)
	mechanics.add_charge_energy(mechanics.total_capacity(), 0.0, false)
	var vault_super: Dictionary = mechanics.discharge(0)
	check(float(vault_super.output) > float(vault_partial.output) * 4.0, "CAPACITOR VAULT strongly rewards six-cell burst timing")
	mechanics.begin_stage("relay_network", "chain", 1000.0, 1000.0)
	for chain in range(3):
		mechanics.add_charge_energy(mechanics.capacity, 0.0, false)
		mechanics.discharge(0)
	check(mechanics.stage_combo == 3 and mechanics.total_charge() > 0.0, "RELAY NETWORK chains rapid discharges and feeds charge forward")
	mechanics.begin_stage("surge_lab", "critical", 1000.0, 1000.0)
	check(mechanics.effective_critical_chance() > mechanics.critical_chance + 0.15, "SURGE LAB exposes a visible high-variance critical window")
	mechanics.begin_campaign_boss("thermal_titan", 1000.0, false, false)
	mechanics.boss_attack_timer = 1.0
	var titan_warning_hit: Dictionary = mechanics.apply_output(100.0, true)
	check(not bool(titan_warning_hit.interrupt) and is_equal_approx(mechanics.boss_attack_timer, 1.0), "THERMAL TITAN cannot be bypassed with the GRID LEECH interrupt rule")
	for id in ["manual", "critical", "auto", "cooling", "capacity", "discharge", "insulation", "surge"]:
		mechanics.upgrade_levels[id] = 2
	check(mechanics.active_synergies().size() == 4, "the eight upgrades form four functional two-part synergies")
	var campaign_seconds := simulate_project_charge_normal_route()
	print("PROJECT CHARGE efficient normal-route simulation: %.1f seconds" % campaign_seconds)
	check(campaign_seconds >= 600.0 and campaign_seconds <= 1100.0, "an efficient three-stage normal route lands in the 10–18 minute automation band")
	var true_route_seconds := simulate_project_charge_true_route()
	print("PROJECT CHARGE efficient true-route simulation: %.1f seconds" % true_route_seconds)
	check(true_route_seconds >= 1500.0 and true_route_seconds <= 3000.0, "an efficient full true route lands in the 25–50 minute automation band")

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

	var stage_ids := ChargeStageCatalog.stage_ids()
	check(stage_ids.size() == 6 and stage_ids.duplicate().all(func(id): return not str(id).is_empty()), "campaign catalog defines six named circuit stages")
	var route := ChargeCampaignRoute.new()
	check(route.adopt_vertical_slice("flywheel"), "Phase 2 result can seed the six-stage campaign")
	check(route.completed_stage_ids == ["generator_core"] and route.phase == route.RoutePhase.MAP, "vertical slice becomes the first completed campaign stage")
	check(route.select_stage("thermal_plant") and route.complete_current_stage("redline_loop"), "a second stage can be selected and completed")
	check(route.select_stage("drone_array") and route.complete_current_stage("swarm_clock"), "a third stage can be selected and completed")
	check(route.phase == route.RoutePhase.BOSS_SELECT and route.normal_route_ready(), "any three completed stages unlock the normal boss choice")
	check(route.choose_first_boss("grid_leech") and route.defeat_current_boss(), "the first selected boss can be defeated")
	check(route.phase == route.RoutePhase.NORMAL_END and route.normal_end_seen, "first boss defeat produces a complete normal ending")
	check(route.continue_true_route(), "normal ending can continue without resetting the build")
	for stage_id in route.available_stage_ids():
		check(route.select_stage(stage_id), "remaining campaign stage %s can start" % stage_id)
		check(route.complete_current_stage(str(ChargeStageCatalog.stage(stage_id).reward_id)), "remaining campaign stage %s can complete" % stage_id)
	check(route.phase == route.RoutePhase.ENHANCED_BOSS and route.current_boss_id == "thermal_titan", "six stages lead to the undefeated enhanced boss")
	check(route.defeat_current_boss(), "enhanced boss can be defeated")
	check(route.phase == route.RoutePhase.SINGULARITY and route.true_route_ready(), "all stages and both bosses unlock CHARGE SINGULARITY")
	var route_snapshot := route.snapshot()
	var restored_route := ChargeCampaignRoute.new()
	check(restored_route.restore_snapshot(route_snapshot), "campaign route can be serialized and restored")
	check(restored_route.phase == restored_route.RoutePhase.SINGULARITY and restored_route.completed_stage_ids.size() == 6, "restored campaign preserves true-route progression")
	var campaign_save_path := "user://project_charge_campaign_smoke_test.cfg"
	var campaign_save := ChargeClickerSave.new(campaign_save_path)
	check(campaign_save.save_bundle(timed_run, restored_route) == OK, "run and campaign can be saved atomically")
	var bundle_run := ChargeClickerState.new()
	var bundle_route := ChargeCampaignRoute.new()
	check(campaign_save.load_bundle_into(bundle_run, bundle_route), "run and campaign can be loaded atomically")
	check(bundle_route.phase == bundle_route.RoutePhase.SINGULARITY and is_equal_approx(bundle_run.stage_clear_time, timed_run.stage_clear_time), "campaign bundle preserves both progression layers")
	campaign_save.clear()
	check(restored_route.defeat_current_boss() and restored_route.phase == restored_route.RoutePhase.POST_TRUE_CHOICE, "CHARGE SINGULARITY defeat reaches the persistent post-Arch choice")

func simulate_project_charge_normal_route() -> float:
	var simulated := ChargeClickerState.new()
	var upgrade_plan := ["manual", "discharge", "surge", "cooling", "critical", "capacity", "auto", "insulation", "manual", "critical", "auto", "cooling", "capacity", "discharge", "insulation", "surge"]
	var upgrade_cursor := 0
	for stage_id in ["generator_core", "capacitor_vault", "thermal_plant"]:
		var definition := ChargeStageCatalog.stage(stage_id)
		simulated.begin_stage(stage_id, str(definition.build_tag), float(definition.restore_target), float(definition.climax_hp))
		for step in range(12000):
			simulated.manual_charge(0)
			simulated.tick(0.15, false)
			if simulated.is_full() and (simulated.overcharge >= 30.0 or simulated.boss_warning_active()):
				var shot := simulated.discharge(0)
				simulated.apply_output(float(shot.output), bool(shot.super))
			while upgrade_cursor < upgrade_plan.size() and simulated.can_purchase(str(upgrade_plan[upgrade_cursor])):
				simulated.purchase_upgrade(str(upgrade_plan[upgrade_cursor]))
				upgrade_cursor += 1
			if simulated.stage_phase == simulated.StagePhase.REWARD:
				simulated.select_reward(["flywheel", "coolant", "relay"][simulated.circuit_rewards.size() % 3])
				simulated.grant_stage_circuit(str(definition.reward_id))
				break
	var normal_boss := ChargeStageCatalog.boss("grid_leech")
	simulated.begin_campaign_boss("grid_leech", float(normal_boss.hp), false, false)
	for step in range(16000):
		simulated.manual_charge(0)
		simulated.tick(0.15, false)
		if simulated.is_full() and (simulated.overcharge >= 30.0 or simulated.boss_warning_active()):
			var shot: Dictionary = simulated.discharge(0)
			simulated.apply_output(float(shot.output), bool(shot.super))
		if simulated.stage_phase == simulated.StagePhase.REWARD:
			break
	return simulated.elapsed

func simulate_project_charge_true_route() -> float:
	var simulated := ChargeClickerState.new()
	var upgrade_plan := ["manual", "discharge", "surge", "cooling", "critical", "capacity", "auto", "insulation", "manual", "critical", "auto", "cooling", "capacity", "discharge", "insulation", "surge", "manual", "discharge", "surge", "cooling", "critical", "capacity", "auto", "insulation"]
	var upgrade_cursor := 0
	for stage_index in range(ChargeStageCatalog.STAGES.size()):
		var definition: Dictionary = ChargeStageCatalog.STAGES[stage_index]
		simulated.begin_stage(str(definition.id), str(definition.build_tag), float(definition.restore_target), float(definition.climax_hp))
		for step in range(20000):
			simulated.manual_charge(0)
			simulated.tick(0.15, false)
			if simulated.is_full() and (simulated.overcharge >= 30.0 or simulated.boss_warning_active()):
				var shot := simulated.discharge(0)
				simulated.apply_output(float(shot.output), bool(shot.super))
			while upgrade_cursor < upgrade_plan.size() and simulated.can_purchase(str(upgrade_plan[upgrade_cursor])):
				simulated.purchase_upgrade(str(upgrade_plan[upgrade_cursor]))
				upgrade_cursor += 1
			if simulated.stage_phase == simulated.StagePhase.REWARD:
				simulated.select_reward(["flywheel", "coolant", "relay"][stage_index % 3])
				simulated.grant_stage_circuit(str(definition.reward_id))
				break
		if stage_index == 2:
			var normal_boss := ChargeStageCatalog.boss("grid_leech")
			simulated.begin_campaign_boss("grid_leech", float(normal_boss.hp), false, false)
			drive_simulated_boss(simulated, 24000)
	var enhanced_boss := ChargeStageCatalog.boss("thermal_titan")
	simulated.begin_campaign_boss("thermal_titan", float(enhanced_boss.enhanced_hp), true, false)
	drive_simulated_boss(simulated, 30000)
	var singularity := ChargeStageCatalog.boss("charge_singularity")
	simulated.begin_campaign_boss("charge_singularity", float(singularity.hp), false, true)
	drive_simulated_boss(simulated, 48000)
	return simulated.elapsed

func drive_simulated_boss(simulated, max_steps: int) -> void:
	for step in range(max_steps):
		simulated.manual_charge(0)
		simulated.tick(0.15, false)
		if simulated.is_full() and (simulated.overcharge >= 30.0 or simulated.boss_warning_active()):
			var shot: Dictionary = simulated.discharge(0)
			simulated.apply_output(float(shot.output), bool(shot.super))
		if simulated.stage_phase == simulated.StagePhase.REWARD:
			return
