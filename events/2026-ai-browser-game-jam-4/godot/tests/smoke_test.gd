extends SceneTree

const ZeroGame = preload("res://games/zero_percent_city/zero_percent_city.gd")
const ChargebackGame = preload("res://games/chargeback/chargeback.gd")
const CapacitorGame = preload("res://games/capacitor_defense/capacitor_defense.gd")

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

func test_zero_percent_city() -> void:
	print("\nZERO PERCENT CITY")
	var game := ZeroGame.new()
	root.add_child(game)
	game.is_japanese = true
	game.reset_run()
	check(game.run_state == game.RunState.PLAYING, "run boots into PLAYING")
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
	game.is_japanese = true
	game.start_run()
	check(game.hand.size() == 5, "opening hand draws five cards")
	check(game.find_card(game.all_cards(), "dispute").title == "異議申立て", "cards use Japanese copy")
	check(game.enemy.hp == 58, "first authorization loads")
	var pool: Array[Dictionary] = game.all_cards()
	game.hand = [game.find_card(pool, "dispute").duplicate()]
	game.energy = 3
	game.shield = 0
	game.play_card(0)
	check(game.shield == 9 and game.energy == 2, "DISPUTE spends energy and grants block")
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
	game.build_mode = game.BuildMode.ARC
	game.handle_node(1)
	check(game.nodes[1].building == "arc" and game.credits == 82, "arc tower builds on a live socket")
	game.build_mode = game.BuildMode.CABLE
	game.handle_node(2)
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
