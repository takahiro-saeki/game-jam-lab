class_name ChargePrototypeState
extends RefCounted

const PERPETUAL_SUN_GENERATION_MULTIPLIER := 12.0

# PROJECT CHARGE v5 — five-gear build engine.
# Manual commands generate resources, marks and firing orders while the AUTO
# arsenal grows into the late-game damage engine. Every node belongs to one
# visible, navigable gear tree.

const GearCatalog = preload("res://games/charge_clicker/gear_catalog.gd")

const BOSS_MAX_HP := 6200.0
const MAX_SKILL_RANK := 10
const RESTORE_GOAL := 1.0
const BUILD_ID := "v11-cinematic-balance"
const OVERLIMIT_RESTORATION_COST := 40000000

enum StagePhase { RESTORE, BOSS, REWARD, CLEAR }

const UPGRADE_DEFINITIONS := GearCatalog.SKILLS + GearCatalog.OVERLIMITS

var credits := 0
var lifetime_charge := 0
var elapsed := 0.0
var session_elapsed := 0.0
var stage_elapsed := 0.0
var stage_clear_time := -1.0
var session_id := ""
var playtest_mode := "human"
var encounter_history: Array[Dictionary] = []
var purchase_history: Array[Dictionary] = []
var exported_endings: Array[String] = []
var encounter_recorded := false
var encounter_started_session_time := 0.0
var encounter_start_manual_inputs := 0
var encounter_start_auto_hits := 0
var encounter_start_critical_hits := 0
var encounter_start_purchases := 0
var encounter_start_output := 0.0
var encounter_start_credits := 0
var encounter_start_ranks := 0

var manual_damage := 1.0
var auto_damage := 0.75
var auto_interval := 1.0
var drone_count := 1
var charge_per_click := 1.0
var auto_charge_per_shot := 0.22
var critical_chance := 0.04
var critical_multiplier := 2.0
var combo_bonus_per_stack := 0.025
var combo_cap := 10
var core_power := 1.0
var manual_mode := "attack"
var generator_multiplier := 6.0
var auto_boost_stacks := 0
var auto_boost_timer := 0.0
var target_marks := 0
var auto_burst_counter := 0
var support_counter := 0
var world_hive_counter := 0
var overlimit_system_unlocked := false
var singularity_residue := 0
var overlimit_invested_charge := 0
var overlimit_trigger_counter := 0
var perpetual_sun_meter := 0.0
var perpetual_sun_timer := 0.0
var infinite_mode := false
var infinite_wave := 0

var manual_inputs := 0
var auto_hits := 0
var critical_hits := 0
var purchases := 0
var invested_charge := 0
var lifetime_output := 0.0
var highest_output := 0.0
var first_purchase_time := -1.0
var manual_streak := 0
var combo_timer := 0.0
var charge_fraction := 0.0
var auto_timer := 0.0
var upgrade_levels: Dictionary = {}
var rng := RandomNumberGenerator.new()

var stage_phase := StagePhase.BOSS
var boss_hp := BOSS_MAX_HP
var boss_max_hp := BOSS_MAX_HP
var current_stage_id := "gearmaw"
var current_build_tag := "manual"
var current_boss_id := "gearmaw"
var enhanced_boss := false
var singularity_boss := false
var final_boss := false
var final_boss_form := 0
var encounter_index := 0

var beast_cores: Array[String] = []
var boss_cores: Array[String] = []
var circuit_rewards: Array[String] = []

# Positive opportunity state. These values are also drawn by the combat UI.
var armor_cracks := 0
var enemy_armor_layers := 3
var shell_open_timer := 0.0
var vault_charge_meter := 0.0
var overdrive_timer := 0.0
var hydra_heads := 3
var stage_combo := 0
var source_switch_timer := 0.0
var last_attack_source := ""
var drones := 3
var marked_drones := 0
var phase_index := 0
var phase_timer := 3.0
var analysis := 0.0
var siphon_window_timer := 0.0
var siphon_cooldown := 7.0
var siphon_hits := 0
var furnace_hits := 0
var furnace_open_timer := 0.0
var singularity_phase := 1
var singularity_seal := 0
var singularity_rule := 0
var singularity_rule_timer := 7.0
var singularity_progress := 0
var enemy_charge := 0.0

var boss_interrupts := 0
var boss_drains := 0
var last_damage_multiplier := 1.0
var last_mechanic_event := ""

# Legacy counters retained in result/save interfaces. They never increase in v4.
var partial_discharges := 0
var super_discharges := 0
var meltdowns := 0
var heat := 0.0
var overcharge := 0.0
var auto_enabled := true
var cells: Array[float] = []
var capacity := 0.0
var restore_progress := 0.0
var restore_goal := 1.0
var boss_attack_timer := 0.0

func _init() -> void:
	rng.randomize()
	reset()

func reset() -> void:
	credits = 0
	lifetime_charge = 0
	elapsed = 0.0
	session_elapsed = 0.0
	session_id = "%d-%06d" % [int(Time.get_unix_time_from_system()), rng.randi_range(0, 999999)]
	playtest_mode = "human"
	encounter_history.clear()
	purchase_history.clear()
	exported_endings.clear()
	manual_inputs = 0
	auto_hits = 0
	critical_hits = 0
	purchases = 0
	invested_charge = 0
	lifetime_output = 0.0
	highest_output = 0.0
	first_purchase_time = -1.0
	manual_mode = "attack"
	auto_boost_stacks = 0
	auto_boost_timer = 0.0
	target_marks = 0
	auto_burst_counter = 0
	support_counter = 0
	world_hive_counter = 0
	overlimit_system_unlocked = false
	singularity_residue = 0
	overlimit_invested_charge = 0
	overlimit_trigger_counter = 0
	perpetual_sun_meter = 0.0
	perpetual_sun_timer = 0.0
	infinite_mode = false
	infinite_wave = 0
	upgrade_levels.clear()
	for definition in UPGRADE_DEFINITIONS:
		upgrade_levels[str(definition.id)] = 0
	beast_cores.clear()
	boss_cores.clear()
	circuit_rewards.clear()
	refresh_stats()
	begin_stage("gearmaw", "manual", 1.0, BOSS_MAX_HP, 0)

func begin_stage(stage_id: String, build_tag: String, _unused_goal: float, hp: float, order_index: int = 0) -> void:
	current_stage_id = stage_id
	current_build_tag = build_tag
	current_boss_id = stage_id
	encounter_index = maxi(0, order_index)
	boss_max_hp = maxf(100.0, hp)
	enhanced_boss = false
	singularity_boss = false
	final_boss = false
	final_boss_form = 0
	infinite_mode = false
	infinite_wave = 0
	reset_encounter()

func begin_campaign_boss(boss_id: String, hp: float, is_enhanced: bool = false, is_singularity: bool = false) -> void:
	current_stage_id = ""
	current_build_tag = "all" if is_singularity else "boss"
	current_boss_id = boss_id
	boss_max_hp = maxf(100.0, hp)
	enhanced_boss = is_enhanced
	singularity_boss = is_singularity
	final_boss = false
	final_boss_form = 0
	infinite_mode = false
	infinite_wave = 0
	reset_encounter()

func begin_final_boss_form(boss_id: String, hp: float, form: int) -> void:
	current_stage_id = ""
	current_build_tag = "overlimit"
	current_boss_id = boss_id
	boss_max_hp = maxf(100.0, hp)
	enhanced_boss = false
	singularity_boss = false
	final_boss = true
	final_boss_form = clampi(form, 1, 3)
	infinite_mode = false
	infinite_wave = 0
	reset_encounter()

func begin_infinite_wave(encounter_id: String, hp: float, wave: int) -> void:
	current_stage_id = ""
	current_build_tag = "infinite"
	current_boss_id = encounter_id
	boss_max_hp = maxf(100.0, hp)
	enhanced_boss = false
	singularity_boss = false
	final_boss = false
	final_boss_form = 0
	infinite_mode = true
	infinite_wave = maxi(1, wave)
	encounter_index = infinite_wave - 1
	reset_encounter()

func reset_encounter() -> void:
	stage_phase = StagePhase.BOSS
	boss_hp = boss_max_hp
	stage_elapsed = 0.0
	stage_clear_time = -1.0
	manual_streak = 0
	combo_timer = 0.0
	auto_timer = minf(0.35, auto_interval)
	charge_fraction = 0.0
	armor_cracks = 0
	enemy_armor_layers = 3
	shell_open_timer = 0.0
	vault_charge_meter = 0.0
	overdrive_timer = 0.0
	hydra_heads = 3
	stage_combo = 0
	source_switch_timer = 0.0
	last_attack_source = ""
	drones = 3
	marked_drones = 0
	phase_index = 0
	phase_timer = 3.0
	analysis = 0.0
	siphon_window_timer = 0.0
	siphon_cooldown = 6.0
	siphon_hits = 0
	furnace_hits = 0
	furnace_open_timer = 0.0
	singularity_phase = 1
	singularity_seal = 0
	singularity_rule = 0
	singularity_rule_timer = 7.0
	singularity_progress = 0
	enemy_charge = 0.0
	boss_interrupts = 0
	boss_drains = 0
	last_damage_multiplier = 1.0
	last_mechanic_event = ""
	auto_boost_stacks = 0
	auto_boost_timer = 0.0
	target_marks = 0
	auto_burst_counter = 0
	support_counter = 0
	world_hive_counter = 0
	overlimit_trigger_counter = 0
	perpetual_sun_meter = 0.0
	perpetual_sun_timer = 0.0
	encounter_recorded = false
	encounter_started_session_time = session_elapsed
	encounter_start_manual_inputs = manual_inputs
	encounter_start_auto_hits = auto_hits
	encounter_start_critical_hits = critical_hits
	encounter_start_purchases = purchases
	encounter_start_output = lifetime_output
	encounter_start_credits = credits
	encounter_start_ranks = skill_points_bought()

func set_playtest_mode(mode: String) -> void:
	playtest_mode = mode if mode in ["human", "benchmark", "ai_agent"] else "human"

func advance_session_time(delta: float) -> void:
	session_elapsed += maxf(0.0, delta)

func current_encounter_id() -> String:
	return current_boss_id if not current_boss_id.is_empty() else current_stage_id

func current_encounter_kind() -> String:
	if infinite_mode:
		return "infinite"
	if singularity_boss:
		return "true_boss"
	if final_boss:
		return "final_boss_form_%d" % final_boss_form
	if enhanced_boss:
		return "enhanced_boss"
	return "beast" if not current_stage_id.is_empty() else "normal_boss"

func finalize_encounter_record() -> void:
	if encounter_recorded:
		return
	encounter_recorded = true
	encounter_history.append({
		"id": current_encounter_id(),
		"kind": current_encounter_kind(),
		"order": encounter_index,
		"duration_seconds": stage_clear_time,
		"session_start_seconds": encounter_started_session_time,
		"session_end_seconds": session_elapsed,
		"max_hp": boss_max_hp,
		"manual_inputs": manual_inputs - encounter_start_manual_inputs,
		"auto_hits": auto_hits - encounter_start_auto_hits,
		"critical_hits": critical_hits - encounter_start_critical_hits,
		"purchases": purchases - encounter_start_purchases,
		"damage": lifetime_output - encounter_start_output,
		"charge_start": encounter_start_credits,
		"charge_end": credits,
		"upgrade_ranks_start": encounter_start_ranks,
		"upgrade_ranks_end": skill_points_bought(),
	})

func mark_ending_exported(ending: String) -> void:
	if ending not in exported_endings:
		exported_endings.append(ending)

func ending_exported(ending: String) -> bool:
	return ending in exported_endings

func build_playtest_report(route_snapshot: Dictionary, ending: String) -> Dictionary:
	return {
		"schema_version": 1,
		"build_id": BUILD_ID,
		"session_id": session_id,
		"mode": playtest_mode,
		"ending": ending,
		"generated_at": Time.get_datetime_string_from_system(true),
		"session_seconds": session_elapsed,
		"combat_seconds": elapsed,
		"totals": {
			"manual_inputs": manual_inputs,
			"auto_hits": auto_hits,
			"critical_hits": critical_hits,
			"purchases": purchases,
			"upgrade_ranks": skill_points_bought(),
			"possible_ranks": total_possible_ranks(),
			"lifetime_charge": lifetime_charge,
			"lifetime_damage": lifetime_output,
			"highest_hit": highest_output,
		},
		"route": route_snapshot.duplicate(true),
		"encounters": encounter_history.duplicate(true),
		"purchase_history": purchase_history.duplicate(true),
		"upgrade_levels": upgrade_levels.duplicate(true),
	}

func refresh_stats() -> void:
	var impact_level := upgrade_level("impact_coil")
	var auto_level := upgrade_level("auto_cannon")
	var rapid_level := upgrade_level("rapid_relay")
	var drone_level := upgrade_level("drone_bay")
	var charge_level := upgrade_level("charge_generator")
	var resonance_level := upgrade_level("core_resonance")
	manual_damage = pow(1.36, impact_level) * (1.0 + float(upgrade_level("armor_punch")) * 0.16) * pow(1.28, upgrade_level("servo_overdrive")) * pow(1.25, upgrade_level("abyss_breaker"))
	auto_damage = 0.9 * pow(1.42, auto_level) * pow(1.18, upgrade_level("heavy_ordnance")) * (1.0 + float(drone_level) * 0.10) * pow(1.18, upgrade_level("command_link")) * pow(1.32, upgrade_level("twin_barrel")) * pow(1.22, upgrade_level("singularity_cannon"))
	auto_interval = maxf(0.06, 0.95 / (1.0 + float(rapid_level) * 0.18) * pow(0.88, upgrade_level("chrono_relay")))
	var gatling_active := upgrade_level("gatling_protocol") > 0
	var rail_active := upgrade_level("rail_protocol") > 0
	if gatling_active and rail_active:
		# Both completed branches fuse into a late Tier-I payoff instead of leaving
		# one permanently missing rank. The values are the deliberate product of
		# both mutations: fast enough to read as gatling, heavy enough to read as rail.
		auto_interval *= 0.7425
		auto_damage *= 2.304
	elif gatling_active:
		auto_interval *= 0.45
		auto_damage *= 0.72
	elif rail_active:
		auto_interval *= 1.65
		auto_damage *= 3.2
	drone_count = 1 + int(upgrade_level("swarm_clockwork") / 2) + upgrade_level("replication_foundry")
	if "swarm_clock" in beast_cores:
		drone_count += 1 + int(upgrade_level("swarm_memory") / 3)
	var recovered_cores := beast_cores.size() + boss_cores.size()
	var shared_generation := pow(1.35, upgrade_level("deep_capacitor")) * pow(1.60, upgrade_level("infinite_dynamo")) * (1.0 + float(recovered_cores) * float(upgrade_level("resonance_economy")) * 0.035) * (1.0 + float(recovered_cores) * float(upgrade_level("salvage_lattice")) * 0.012)
	# PERPETUAL SUN is the late-game economy break: restoring Dynamo first
	# should make collecting the other four 40M OVERLIMIT rewrites practical.
	if upgrade_level("perpetual_sun") > 0:
		shared_generation *= PERPETUAL_SUN_GENERATION_MULTIPLIER
	charge_per_click = pow(1.22, charge_level) * pow(1.30, upgrade_level("kinetic_recovery")) * shared_generation
	auto_charge_per_shot = 0.16 * (1.0 + float(upgrade_level("auto_induction")) * 0.25) * (1.0 + float(upgrade_level("charge_drone")) * 0.30) * pow(1.40, upgrade_level("war_dividend")) * pow(1.32, upgrade_level("harvester_drones")) * shared_generation
	critical_chance = minf(0.74, 0.04 + float(upgrade_level("critical_math")) * 0.04 + float(upgrade_level("phase_tracker")) * 0.03)
	critical_multiplier = 2.0 + float(upgrade_level("critical_math")) * 0.12 + float(boss_cores.size() * upgrade_level("core_prism")) * 0.05
	combo_bonus_per_stack = 0.025 + float(upgrade_level("combo_gear")) * 0.012
	combo_cap = 8 + upgrade_level("combo_gear") * 3
	core_power = (1.0 + float(resonance_level) * 0.10) * pow(1.14, upgrade_level("dual_core_link"))

func technology_tier() -> int:
	if overlimit_system_unlocked:
		return 4
	if beast_cores.size() >= 6:
		return 3
	if not boss_cores.is_empty():
		return 2
	return 1

func global_output_multiplier() -> float:
	var multiplier := 1.0
	var boss_forge := upgrade_level("boss_core_forge")
	if boss_forge > 0:
		multiplier *= 1.0 + float(boss_cores.size() * boss_forge) * 0.05
	var crown := upgrade_level("six_core_crown")
	if crown > 0:
		multiplier *= 1.0 + float(beast_cores.size() * crown) * 0.010
	var convergence := upgrade_level("core_convergence")
	if convergence > 0:
		multiplier *= 1.0 + float(beast_cores.size() * convergence) * 0.004
	var bank := upgrade_level("event_bank")
	if bank > 0:
		multiplier *= 1.0 + minf(0.5, log(1.0 + float(credits)) * 0.015 * float(bank))
	if singularity_boss:
		multiplier *= 1.0 + float(upgrade_level("singularity_decoder")) * 0.10
		if upgrade_level("world_engine_key") > 0:
			multiplier *= 1.25
	var active_overlimits := overlimit_count()
	if active_overlimits > 0:
		var overlimit_convergence := [1.0, 1.8, 3.2, 5.5, 9.0, 15.0]
		multiplier *= float(overlimit_convergence[active_overlimits])
	if perpetual_sun_timer > 0.0:
		multiplier *= 3.5
	return multiplier

func unlock_overlimit_system() -> bool:
	if overlimit_system_unlocked:
		return false
	overlimit_system_unlocked = true
	# The recovered residue is now the narrative key that unlocks Tier IV.
	# Every permanent OVERLIMIT restoration uses the same readable CHARGE price.
	singularity_residue = 0
	return true

func overlimit_count() -> int:
	var total := 0
	for definition in GearCatalog.OVERLIMITS:
		if upgrade_level(str(definition.id)) > 0:
			total += 1
	return total

func is_overlimit(id: String) -> bool:
	return bool(upgrade_definition(id).get("overlimit", false))

func upgrade_definition(id: String) -> Dictionary:
	for definition in UPGRADE_DEFINITIONS:
		if str(definition.id) == id:
			return definition
	return {}

func upgrade_level(id: String) -> int:
	return int(upgrade_levels.get(id, 0))

func upgrade_cost(id: String) -> int:
	var definition := upgrade_definition(id)
	var level := upgrade_level(id)
	if definition.is_empty() or level >= int(definition.get("max_rank", MAX_SKILL_RANK)):
		return 0
	if bool(definition.get("overlimit", false)):
		return OVERLIMIT_RESTORATION_COST
	var raw_cost := float(definition.base_cost) * pow(float(definition.growth), level)
	var discount := minf(0.48, float(upgrade_level("purchase_optimizer")) * 0.06 + float(upgrade_level("cost_compressor")) * 0.05)
	return maxi(1, int(round(raw_cost * (1.0 - discount))))

func skill_max_rank(id: String) -> int:
	var definition := upgrade_definition(id)
	return int(definition.get("max_rank", MAX_SKILL_RANK)) if not definition.is_empty() else 0

func skill_unlocked(id: String) -> bool:
	var definition := upgrade_definition(id)
	if definition.is_empty():
		return false
	if int(definition.get("tier", 1)) > technology_tier():
		return false
	if bool(definition.get("overlimit", false)):
		var gear_id := str(definition.get("gear", ""))
		if gear_level(gear_id) < GearCatalog.max_ranks_for_gear(gear_id):
			return false
	var parent := str(definition.get("parent", ""))
	if not parent.is_empty() and upgrade_level(parent) < int(definition.get("parent_rank", 1)):
		return false
	var required_core := str(definition.get("requires_core", ""))
	if not required_core.is_empty() and required_core not in beast_cores:
		return false
	if bool(definition.get("requires_boss_core", false)) and boss_cores.is_empty():
		return false
	var exclusive := str(definition.get("exclusive", ""))
	if not exclusive.is_empty() and upgrade_level(exclusive) > 0:
		return false
	return true

func skill_lock_reason(id: String) -> String:
	var definition := upgrade_definition(id)
	if definition.is_empty():
		return "missing"
	var required_tier := int(definition.get("tier", 1))
	if required_tier > technology_tier():
		return "tier:%d" % required_tier
	if bool(definition.get("overlimit", false)):
		var gear_id := str(definition.get("gear", ""))
		if gear_level(gear_id) < GearCatalog.max_ranks_for_gear(gear_id):
			return "gear_max:%s" % gear_id
	var exclusive := str(definition.get("exclusive", ""))
	if not exclusive.is_empty() and upgrade_level(exclusive) > 0:
		return "exclusive:%s" % exclusive
	var required_core := str(definition.get("requires_core", ""))
	if not required_core.is_empty() and required_core not in beast_cores:
		return "core:%s" % required_core
	if bool(definition.get("requires_boss_core", false)) and boss_cores.is_empty():
		return "boss_core"
	var parent := str(definition.get("parent", ""))
	if not parent.is_empty() and upgrade_level(parent) < int(definition.get("parent_rank", 1)):
		return "parent:%s:%d" % [parent, int(definition.get("parent_rank", 1))]
	return ""

func can_purchase(id: String) -> bool:
	return skill_unlocked(id) and upgrade_level(id) < skill_max_rank(id) and credits >= upgrade_cost(id)

func purchase_upgrade(id: String) -> bool:
	if not can_purchase(id):
		return false
	var paid := upgrade_cost(id)
	credits -= paid
	if is_overlimit(id):
		overlimit_invested_charge += paid
	else:
		invested_charge += paid
	upgrade_levels[id] = upgrade_level(id) + 1
	if id == "zero_output_generator":
		manual_mode = "generate"
	purchases += 1
	var definition := upgrade_definition(id)
	purchase_history.append({
		"event": "purchase",
		"skill_id": id,
		"gear": str(definition.get("gear", "")),
		"tier": int(definition.get("tier", 1)),
		"rank": upgrade_level(id),
		"cost": paid,
		"session_seconds": session_elapsed,
		"combat_seconds": elapsed,
		"encounter_id": current_encounter_id(),
	})
	if first_purchase_time < 0.0:
		first_purchase_time = elapsed
	var duration := (5.0 + float(upgrade_level("furnace_memory")) * 0.8) * core_power
	if current_stage_id == "pyre_wyrm" or "redheat_conversion" in beast_cores:
		overdrive_timer = maxf(overdrive_timer, duration)
		last_mechanic_event = "upgrade_overdrive"
	if "furnace_sovereign" in boss_cores:
		overdrive_timer = maxf(overdrive_timer, duration + 3.0 + float(upgrade_level("boss_matrix")) * 0.6)
	refresh_stats()
	if not is_overlimit(id) and upgrade_level("feedback_loop") > 0:
		var returned := grant_charge(float(paid) * 0.15)
		invested_charge = maxi(0, invested_charge - returned)
	if not is_overlimit(id) and upgrade_level("perpetual_engine") > 0:
		var perpetual_return := grant_charge(float(paid) * 0.25)
		invested_charge = maxi(0, invested_charge - perpetual_return)
	var reclamation_rate := float(upgrade_level("reclamation_bus")) * 0.03 + float(upgrade_level("closed_economy")) * 0.02
	if not is_overlimit(id) and reclamation_rate > 0.0:
		var reclamation_return := grant_charge(float(paid) * reclamation_rate)
		invested_charge = maxi(0, invested_charge - reclamation_return)
	return true

func skill_points_bought() -> int:
	var total := 0
	for definition in GearCatalog.SKILLS:
		total += upgrade_level(str(definition.id))
	return total

func gear_level(gear_id: String) -> int:
	var total := 0
	for definition in GearCatalog.SKILLS:
		if str(definition.gear) == gear_id:
			total += upgrade_level(str(definition.id))
	return total

func total_possible_ranks() -> int:
	return GearCatalog.total_max_ranks()

func respec_skills() -> int:
	var refunded := invested_charge
	purchase_history.append({
		"event": "respec",
		"refund": refunded,
		"session_seconds": session_elapsed,
		"combat_seconds": elapsed,
		"encounter_id": current_encounter_id(),
	})
	for definition in GearCatalog.SKILLS:
		var id := str(definition.id)
		upgrade_levels[id] = 0
	credits += refunded
	invested_charge = 0
	manual_mode = "attack"
	refresh_stats()
	return refunded

func generation_mode_unlocked() -> bool:
	return upgrade_level("zero_output_generator") > 0

func toggle_manual_mode() -> bool:
	if not generation_mode_unlocked():
		manual_mode = "attack"
		return false
	# PURE COMMAND permanently replaces the basic attack once unlocked. Keeping
	# this compatibility method makes old callers harmless without exposing a
	# weaker mode toggle to the player.
	manual_mode = "generate"
	return true

func grant_beast_core(id: String) -> bool:
	if id.is_empty() or id in beast_cores:
		return false
	beast_cores.append(id)
	if id not in circuit_rewards:
		circuit_rewards.append(id)
	refresh_stats()
	return true

func grant_stage_circuit(id: String) -> bool:
	return grant_beast_core(id)

func grant_boss_core(id: String) -> bool:
	if id.is_empty() or id in boss_cores:
		return false
	boss_cores.append(id)
	return true

func active_synergies() -> Array[String]:
	return beast_cores.duplicate()

func synergy_active(_id: String) -> bool:
	return false

func register_overlimit_activation() -> float:
	if upgrade_level("six_core_apotheosis") <= 0 or stage_phase != StagePhase.BOSS:
		return 0.0
	overlimit_trigger_counter += 1
	if overlimit_trigger_counter < 5:
		return 0.0
	overlimit_trigger_counter = 0
	last_mechanic_event = "six_core_apotheosis"
	return deal_damage(boss_max_hp * 0.006)

func trigger_overlimit_signature(ratio: float, event_id: String) -> float:
	if stage_phase != StagePhase.BOSS:
		return 0.0
	last_mechanic_event = event_id
	var applied := deal_damage(boss_max_hp * ratio)
	if stage_phase == StagePhase.BOSS:
		applied += register_overlimit_activation()
	return applied

func manual_attack(critical_mode: int = -1) -> Dictionary:
	if stage_phase != StagePhase.BOSS:
		return {"valid": false, "damage": 0.0, "charge": 0, "critical": false, "boss_defeated": false}
	last_mechanic_event = ""
	manual_inputs += 1
	manual_streak = mini(combo_cap, manual_streak + 1) if combo_timer > 0.0 else 1
	combo_timer = 0.7
	var generating := generation_mode_unlocked()
	manual_mode = "generate" if generating else "attack"
	if generating:
		var boost_cap := 10 + upgrade_level("command_capacitor") * 2
		auto_boost_stacks = mini(boost_cap, auto_boost_stacks + 1)
		auto_boost_timer = 2.2 + float(upgrade_level("command_capacitor")) * 0.5
	var forced_analysis := "phase_computation" in beast_cores and analysis >= 100.0
	var is_critical := critical_mode == 1 or forced_analysis or (critical_mode < 0 and rng.randf() < effective_critical_chance("manual"))
	if is_critical:
		critical_hits += 1
		if forced_analysis:
			analysis = 0.0
	else:
		analysis = minf(100.0, analysis + (6.0 + float(upgrade_level("phase_memory")) * 1.2) * core_power)
	var combo_multiplier := 1.0 + float(maxi(0, manual_streak - 1)) * combo_bonus_per_stack
	var phase_critical_bonus := 1.0 + float(upgrade_level("phase_memory")) * 0.12 if forced_analysis else 1.0
	var damage := 0.0 if generating else manual_damage * combo_multiplier * (critical_multiplier if is_critical else 1.0) * phase_critical_bonus
	if not generating and objective_ratio() >= 0.65:
		damage *= 1.0 + float(upgrade_level("execution_protocol")) * 0.20
	var modified := modify_attack("manual", damage, is_critical)
	damage = float(modified.damage)
	var shockwave := 0.0
	if "impact_guidance" in beast_cores and manual_inputs % 10 == 0:
		shockwave = manual_damage * (4.0 + float(upgrade_level("impact_memory")) * 0.8) * core_power
		last_mechanic_event = "impact_shockwave"
	var punch_rank := upgrade_level("armor_punch")
	if punch_rank > 0 and manual_inputs % maxi(4, 12 - punch_rank * 2) == 0:
		shockwave += manual_damage * (1.5 + float(punch_rank) * 0.75)
		last_mechanic_event = "armor_punch"
	if upgrade_level("worldsplitter") > 0 and manual_inputs % 25 == 0:
		var fracture_ratio := 0.003 + float(upgrade_level("fracture_archive")) * 0.0005
		if final_boss:
			fracture_ratio *= 0.18
		shockwave += boss_max_hp * fracture_ratio
		last_mechanic_event = "worldsplitter"
	if generating and objective_ratio() >= 0.65:
		shockwave *= 1.0 + float(upgrade_level("execution_protocol")) * 0.20
	var echo := 0.0
	var relay_memory := upgrade_level("relay_memory")
	if not generating and "cascade_relay" in beast_cores and rng.randf() < minf(0.72, (0.16 + float(relay_memory) * 0.035) * core_power):
		echo = damage * (0.55 + float(relay_memory) * 0.10) * core_power
		last_mechanic_event = "relay_echo"
	var economy_multiplier := 1.0 + minf(1.0, float(credits) / 100.0 * 0.02 * float(upgrade_level("compound_interest")))
	var charge_amount := charge_per_click * economy_multiplier * (generator_multiplier if generating else 1.0)
	if upgrade_level("harvest_knuckle") > 0 and manual_inputs % 10 == 0:
		charge_amount += 10.0 * core_power
		last_mechanic_event = "harvest"
	var salvage_rank := upgrade_level("salvage_impulse")
	if salvage_rank > 0 and manual_inputs % 25 == 0:
		charge_amount += charge_per_click * float(salvage_rank) * 4.0
		last_mechanic_event = "salvage_impulse"
	var earned := grant_charge(charge_amount)
	var applied := deal_damage(damage + shockwave + echo)
	var overlimit_damage := 0.0
	if upgrade_level("heavenbreaker_command") > 0 and manual_inputs % 20 == 0 and stage_phase == StagePhase.BOSS:
		overlimit_damage += trigger_overlimit_signature(0.003, "heavenbreaker_command")
		if stage_phase == StagePhase.BOSS:
			overlimit_damage += deal_damage(auto_damage * float(drone_count) * 8.0 * global_output_multiplier())
	var commanded_volley := 0.0
	if is_critical and upgrade_level("twin_trigger") > 0 and stage_phase == StagePhase.BOSS:
		var volley_damage := auto_damage * float(drone_count) * (2.0 + float(upgrade_level("omega_trigger")) * 0.8) * global_output_multiplier()
		if singularity_boss or enhanced_boss:
			volley_damage = minf(volley_damage, direct_hit_cap())
		commanded_volley = deal_damage(volley_damage)
		last_mechanic_event = "twin_trigger"
	var escort_rank := upgrade_level("escort_protocol")
	if generating and escort_rank > 0 and manual_inputs % maxi(5, 11 - escort_rank) == 0 and stage_phase == StagePhase.BOSS:
		var escort_damage := auto_damage * float(drone_count) * float(escort_rank) * 0.35 * global_output_multiplier()
		if singularity_boss or enhanced_boss:
			escort_damage = minf(escort_damage, direct_hit_cap())
		commanded_volley += deal_damage(escort_damage)
		last_mechanic_event = "escort_volley"
	var cadence_rank := upgrade_level("terminal_cadence")
	if generating and cadence_rank > 0 and manual_inputs % maxi(10, 18 - cadence_rank * 2) == 0 and stage_phase == StagePhase.BOSS:
		var cadence_damage := auto_damage * float(drone_count) * (0.5 + float(cadence_rank) * 0.35) * global_output_multiplier()
		if singularity_boss or enhanced_boss:
			cadence_damage = minf(cadence_damage, direct_hit_cap())
		commanded_volley += deal_damage(cadence_damage)
		last_mechanic_event = "terminal_cadence"
	var painter_rank := upgrade_level("target_painter")
	if painter_rank > 0:
		target_marks = mini(12 + upgrade_level("formation_matrix") * 2, target_marks + 1)
	if "predation_reversal" in boss_cores:
		earned += grant_charge(predation_feedback(applied + commanded_volley, "manual"))
	var burst := trigger_singularity_burst("manual")
	return {
		"valid": true,
		"damage": applied + commanded_volley + burst + overlimit_damage,
		"base_damage": damage,
		"shockwave": shockwave,
		"echo": echo,
		"commanded_volley": commanded_volley,
		"charge": earned,
		"critical": is_critical,
		"generating": generating,
		"mechanic": last_mechanic_event,
		"boss_defeated": stage_phase == StagePhase.CLEAR,
	}

func manual_charge(critical_mode: int = -1) -> Dictionary:
	return manual_attack(critical_mode)

func auto_attack(critical_mode: int = -1) -> Dictionary:
	if stage_phase != StagePhase.BOSS:
		return {"valid": false, "damage": 0.0, "charge": 0, "critical": false, "boss_defeated": false}
	last_mechanic_event = ""
	auto_hits += 1
	var is_critical := critical_mode == 1 or (critical_mode < 0 and rng.randf() < effective_critical_chance("auto") * 0.55)
	if is_critical:
		critical_hits += 1
	else:
		analysis = minf(100.0, analysis + (1.5 + float(upgrade_level("phase_memory")) * 0.3) * float(drone_count) * core_power)
	var damage := auto_damage * float(drone_count) * (critical_multiplier if is_critical else 1.0)
	if is_critical:
		damage *= 1.0 + float(upgrade_level("adaptive_feed")) * 0.12
	if auto_boost_timer > 0.0:
		damage *= 1.0 + float(auto_boost_stacks) * (0.10 + float(upgrade_level("overflow_bus")) * 0.02)
	if target_marks > 0:
		damage *= 1.0 + float(target_marks) * (0.10 + float(upgrade_level("target_painter")) * 0.02 + float(upgrade_level("horizon_mark")) * 0.05)
		target_marks = mini(target_marks, upgrade_level("mark_memory") + upgrade_level("formation_matrix"))
		last_mechanic_event = "painted_volley"
	var hunter_rank := upgrade_level("hunter_drone")
	var hp_ratio := boss_hp / maxf(1.0, boss_max_hp)
	if hunter_rank > 0 and hp_ratio <= 0.5:
		damage *= 1.0 + float(hunter_rank) * (0.28 if hp_ratio <= 0.25 else 0.18)
	if upgrade_level("hive_mind") > 0:
		damage *= 1.0 + float(maxi(0, drone_count - 1)) * 0.18
	damage *= pow(1.0 + float(maxi(0, drone_count - 1)) * 0.035, upgrade_level("synchronized_swarm"))
	damage *= pow(1.15, upgrade_level("legion_protocol"))
	var burst_rank := upgrade_level("burst_loader")
	var burst_fired := false
	if burst_rank > 0:
		auto_burst_counter += 1
		var storm_rank := upgrade_level("storm_loader")
		if auto_burst_counter >= maxi(3, 10 - burst_rank - storm_rank):
			auto_burst_counter = 0
			burst_fired = true
			damage *= 3.0 + float(storm_rank) * 0.75 + float(upgrade_level("phase_magazine")) * 0.20
			last_mechanic_event = "auto_burst"
	if is_critical and upgrade_level("annihilation_round") > 0:
		damage *= 2.2
		last_mechanic_event = "annihilation_round"
	var modified := modify_attack("auto", damage, is_critical)
	damage = float(modified.damage)
	var echo := 0.0
	var chain_rank := upgrade_level("chain_rounds")
	var echo_chamber_rank := upgrade_level("echo_chamber")
	if chain_rank > 0 and rng.randf() < minf(0.75, float(chain_rank) * 0.09 + float(echo_chamber_rank) * 0.06):
		echo += damage * (0.32 + float(chain_rank) * 0.08 + float(echo_chamber_rank) * 0.10)
		last_mechanic_event = "chain_round"
	var relay_memory := upgrade_level("relay_memory")
	if "cascade_relay" in beast_cores and rng.randf() < minf(0.72, (0.12 + float(relay_memory) * 0.03) * core_power):
		echo += damage * (0.45 + float(relay_memory) * 0.09) * core_power
		last_mechanic_event = "relay_echo"
	var reserve_multiplier := 1.0 + minf(0.30, log(1.0 + float(credits)) * 0.01 * float(upgrade_level("reserve_transformer")))
	var earned := grant_charge(auto_charge_per_shot * float(drone_count) * reserve_multiplier)
	if burst_fired and upgrade_level("capacitor_rounds") > 0:
		earned += grant_charge(charge_per_click * float(upgrade_level("capacitor_rounds")) * 1.5)
	if upgrade_level("support_fabricator") > 0:
		support_counter += 1
		if support_counter >= 20:
			support_counter = 0
			earned += grant_charge(12.0 * core_power)
			last_mechanic_event = "support_fabricated"
	var hive_volley := 0.0
	if upgrade_level("world_hive") > 0:
		world_hive_counter += 1
		var sovereign_rank := upgrade_level("sovereign_marker")
		if world_hive_counter >= maxi(7, 12 - sovereign_rank):
			world_hive_counter = 0
			var hive_ratio := 0.0015 + float(sovereign_rank) * 0.00025
			if final_boss:
				hive_ratio *= 0.18
			hive_volley = boss_max_hp * hive_ratio
			last_mechanic_event = "world_hive"
	var applied := deal_damage(damage + echo + hive_volley)
	var overlimit_damage := 0.0
	if upgrade_level("event_horizon_cannon") > 0 and auto_hits % 20 == 0 and stage_phase == StagePhase.BOSS:
		overlimit_damage += trigger_overlimit_signature(0.0025, "event_horizon_cannon")
	if upgrade_level("sovereign_swarm") > 0 and auto_hits % 12 == 0 and stage_phase == StagePhase.BOSS:
		overlimit_damage += trigger_overlimit_signature(0.002, "sovereign_swarm")
	if upgrade_level("six_core_apotheosis") > 0 and overlimit_count() == 1 and auto_hits % 50 == 0 and stage_phase == StagePhase.BOSS:
		overlimit_damage += trigger_overlimit_signature(0.006, "six_core_apotheosis")
	if "predation_reversal" in boss_cores:
		earned += grant_charge(predation_feedback(applied, "auto"))
	var burst := trigger_singularity_burst("auto")
	return {
		"valid": true,
		"damage": applied + burst + overlimit_damage,
		"echo": echo,
		"charge": earned,
		"critical": is_critical,
		"mechanic": last_mechanic_event,
		"boss_defeated": stage_phase == StagePhase.CLEAR,
	}

func modify_attack(source: String, damage: float, is_critical: bool) -> Dictionary:
	var multiplier := 1.0
	if overdrive_timer > 0.0:
		multiplier *= 1.75 + float(upgrade_level("furnace_memory")) * 0.05
		last_mechanic_event = "overdrive"
	if current_stage_id == "gearmaw" and source == "manual":
		armor_cracks += 1
		if armor_cracks >= 12:
			armor_cracks = 0
			enemy_armor_layers = maxi(0, enemy_armor_layers - 1)
			multiplier *= 4.0
			last_mechanic_event = "armor_break"
	elif current_stage_id == "vaultback" and shell_open_timer > 0.0:
		multiplier *= 2.1
		last_mechanic_event = "shell_open"
	elif current_stage_id == "pyre_wyrm" and overdrive_timer > 0.0:
		multiplier *= 1.35
		last_mechanic_event = "furnace_overdrive"
	elif current_stage_id == "relay_hydra":
		update_source_combo(source)
		multiplier *= 1.0 + float(stage_combo) * 0.14
		if stage_combo >= 4:
			last_mechanic_event = "relay_chain"
	elif current_stage_id == "swarm_matriarch":
		if source == "manual":
			marked_drones = mini(drones, marked_drones + 1)
		elif marked_drones > 0:
			multiplier *= 1.0 + float(marked_drones) * 0.48
			marked_drones = 0
			last_mechanic_event = "drone_purge"
	elif current_stage_id == "phase_mantis" and is_critical:
		multiplier *= 1.7
		last_mechanic_event = "phase_critical"

	if current_boss_id == "grid_leech" and siphon_window_timer > 0.0 and source == "manual":
		siphon_hits += 1
		if siphon_hits >= 8:
			multiplier *= 5.0
			siphon_window_timer = 0.0
			siphon_cooldown = 7.0
			boss_interrupts += 1
			grant_charge(25.0 * core_power)
			last_mechanic_event = "siphon_break"
	elif current_boss_id == "thermal_titan":
		if source == "manual" and furnace_open_timer <= 0.0:
			furnace_hits += 1
			if furnace_hits >= 20:
				furnace_hits = 0
				furnace_open_timer = 6.0
				last_mechanic_event = "furnace_open"
		if furnace_open_timer > 0.0:
			multiplier *= 2.0

	if singularity_boss:
		multiplier *= singularity_multiplier(source, is_critical)
	elif final_boss:
		match final_boss_form:
			1:
				var required := "manual" if int(stage_elapsed / 6.0) % 2 == 0 else "auto"
				multiplier *= 1.55 if source == required else 0.72
			2:
				multiplier *= 1.75 if is_critical or manual_streak >= 6 else 0.82
			3:
				multiplier *= 1.0 + minf(0.65, objective_ratio() * 0.65)
	multiplier *= global_output_multiplier()
	last_damage_multiplier = multiplier
	var final_damage := damage * multiplier
	if singularity_boss or enhanced_boss or final_boss:
		final_damage = minf(final_damage, direct_hit_cap())
	return {"damage": final_damage, "multiplier": multiplier}

func direct_hit_cap() -> float:
	if final_boss:
		return boss_max_hp * (0.00006 + float(overlimit_count()) * 0.000015 + float(upgrade_level("lawbreaker_bus")) * 0.00001)
	if enhanced_boss and not singularity_boss:
		return boss_max_hp * (0.001 + float(upgrade_level("lawbreaker_bus")) * 0.00004)
	var cap_ratio := 0.00035 + float(upgrade_level("singularity_decoder")) * 0.00005
	if upgrade_level("world_engine_key") > 0:
		cap_ratio += 0.00010
	cap_ratio += float(upgrade_level("lawbreaker_bus")) * 0.00003
	return boss_max_hp * cap_ratio

func predation_feedback(applied_damage: float, source: String) -> float:
	var raw_feedback := applied_damage * (0.0025 + float(upgrade_level("boss_matrix")) * 0.0005) * core_power
	var feedback_cap := 18.0 + float(upgrade_level("boss_matrix")) * 8.0 + float(upgrade_level("deep_capacitor")) * 4.0 + float(upgrade_level("infinite_dynamo")) * 20.0
	if source == "manual":
		feedback_cap *= 2.0
	return minf(raw_feedback, feedback_cap)

func update_source_combo(source: String) -> void:
	if not last_attack_source.is_empty() and source != last_attack_source and source_switch_timer > 0.0:
		stage_combo = mini(6, stage_combo + 1)
	else:
		stage_combo = maxi(0, stage_combo - 1)
	last_attack_source = source
	source_switch_timer = 2.0

func singularity_multiplier(source: String, is_critical: bool) -> float:
	match singularity_phase:
		1:
			var required := "manual" if singularity_seal % 2 == 0 else "auto"
			if source == required:
				singularity_progress += 1
				if singularity_progress >= maxi(5, 10 - upgrade_level("singularity_decoder")):
					singularity_progress = 0
					singularity_seal = mini(6, singularity_seal + 1)
					last_mechanic_event = "seal_break"
				return 1.6
			return 1.0
		2:
			var success := source == "manual" if singularity_rule == 0 else source == "auto" if singularity_rule == 1 else is_critical if singularity_rule == 2 else manual_streak >= 6
			return 1.65 if success else 1.0
		3:
			enemy_charge = minf(100.0, enemy_charge + (2.0 if source == "manual" else 1.0 + float(drone_count) * 0.10))
			return 1.15
	return 1.0

func trigger_singularity_burst(_source: String) -> float:
	if not singularity_boss or singularity_phase != 3 or enemy_charge < 100.0 or stage_phase != StagePhase.BOSS:
		return 0.0
	enemy_charge = 0.0
	var burst := boss_max_hp * 0.006 * minf(2.0, core_power)
	last_mechanic_event = "singularity_burst"
	return deal_damage(burst)

func effective_critical_chance(source: String = "manual") -> float:
	var result := critical_chance
	if current_stage_id == "phase_mantis" and phase_index == 2:
		result += 0.28
	if "phase_computation" in beast_cores and analysis >= 100.0:
		return 1.0
	if source == "auto" and "swarm_clock" in beast_cores:
		result += (0.03 + float(upgrade_level("swarm_memory")) * 0.012) * core_power
	if source == "auto":
		result += float(upgrade_level("phase_tracker")) * 0.035
	return clampf(result, 0.0, 0.82)

func grant_charge(amount: float) -> int:
	if amount <= 0.0:
		return 0
	charge_fraction += amount
	var whole := int(floorf(charge_fraction))
	if whole <= 0:
		return 0
	charge_fraction -= float(whole)
	var previous_lifetime := lifetime_charge
	credits += whole
	lifetime_charge += whole
	if upgrade_level("perpetual_sun") > 0 and stage_phase == StagePhase.BOSS:
		var solar_threshold := maxf(1000000.0, boss_max_hp * 0.00020)
		perpetual_sun_meter += float(whole)
		if perpetual_sun_meter >= solar_threshold:
			perpetual_sun_meter = fmod(perpetual_sun_meter, solar_threshold)
			perpetual_sun_timer = 8.0
			last_mechanic_event = "perpetual_sun"
			deal_damage(boss_max_hp * 0.003)
			register_overlimit_activation()
	if current_stage_id == "vaultback":
		vault_charge_meter += float(whole)
		if vault_charge_meter >= 50.0:
			vault_charge_meter = fmod(vault_charge_meter, 50.0)
			shell_open_timer = 6.0
			last_mechanic_event = "shell_open"
	var milestones := int(lifetime_charge / 100) - int(previous_lifetime / 100)
	if milestones > 0 and (upgrade_level("dividend_coil") > 0 or "deep_storage" in beast_cores):
		var bonus_per_milestone := float(upgrade_level("dividend_coil")) * 5.0
		if "deep_storage" in beast_cores:
			bonus_per_milestone += 20.0 * (1.0 + float(upgrade_level("storage_memory")) * 0.18) * core_power
		var bonus := maxi(1, int(round(float(milestones) * bonus_per_milestone)))
		credits += bonus
		lifetime_charge += bonus
		whole += bonus
		last_mechanic_event = "charge_dividend"
	return whole

func deal_damage(amount: float) -> float:
	if stage_phase != StagePhase.BOSS or amount <= 0.0:
		return 0.0
	var applied := minf(boss_hp, amount)
	boss_hp = maxf(0.0, boss_hp - amount)
	lifetime_output += applied
	highest_output = maxf(highest_output, amount)
	if current_stage_id == "relay_hydra":
		hydra_heads = maxi(0, 3 - int(floorf(objective_ratio() * 3.0)))
	if boss_hp <= 0.0:
		stage_phase = StagePhase.CLEAR
		stage_clear_time = stage_elapsed
		finalize_encounter_record()
	return applied

func tick(delta: float, _manual_held: bool = false) -> Dictionary:
	var result := {
		"auto_hits": 0,
		"auto_damage": 0.0,
		"charge": 0,
		"critical": false,
		"boss_defeated": false,
		"mechanic": "",
		"opportunity_opened": false,
	}
	if stage_phase != StagePhase.BOSS:
		return result
	elapsed += delta
	stage_elapsed += delta
	combo_timer = maxf(0.0, combo_timer - delta)
	if combo_timer <= 0.0:
		manual_streak = 0
	source_switch_timer = maxf(0.0, source_switch_timer - delta)
	auto_boost_timer = maxf(0.0, auto_boost_timer - delta)
	if auto_boost_timer <= 0.0:
		auto_boost_stacks = 0
	shell_open_timer = maxf(0.0, shell_open_timer - delta)
	overdrive_timer = maxf(0.0, overdrive_timer - delta)
	perpetual_sun_timer = maxf(0.0, perpetual_sun_timer - delta)
	furnace_open_timer = maxf(0.0, furnace_open_timer - delta)
	phase_timer -= delta
	if phase_timer <= 0.0:
		phase_index = wrapi(phase_index + 1, 0, 4)
		phase_timer += 3.0
	if current_boss_id == "grid_leech":
		if siphon_window_timer > 0.0:
			siphon_window_timer = maxf(0.0, siphon_window_timer - delta)
		elif siphon_cooldown > 0.0:
			siphon_cooldown -= delta
			if siphon_cooldown <= 0.0:
				siphon_window_timer = 3.5
				siphon_hits = 0
				result.opportunity_opened = true
	if singularity_boss:
		var hp_ratio := boss_hp / maxf(1.0, boss_max_hp)
		singularity_phase = 1 if hp_ratio > 0.66 else 2 if hp_ratio > 0.33 else 3
		if singularity_phase == 2:
			singularity_rule_timer -= delta
			if singularity_rule_timer <= 0.0:
				singularity_rule = wrapi(singularity_rule + 1, 0, 4)
				singularity_rule_timer += 7.0
	auto_timer -= delta
	var safety := 0
	while auto_timer <= 0.0 and stage_phase == StagePhase.BOSS and safety < 32:
		safety += 1
		auto_timer += auto_interval
		var shot := auto_attack()
		result.auto_hits = int(result.auto_hits) + 1
		result.auto_damage = float(result.auto_damage) + float(shot.damage)
		result.charge = int(result.charge) + int(shot.charge)
		result.critical = bool(result.critical) or bool(shot.critical)
		if not str(shot.mechanic).is_empty():
			result.mechanic = str(shot.mechanic)
	if stage_phase == StagePhase.CLEAR:
		result.boss_defeated = true
	return result

func objective_ratio() -> float:
	return 1.0 - boss_hp / maxf(1.0, boss_max_hp)

func estimated_manual_dps(clicks_per_second: float = 4.0) -> float:
	if generation_mode_unlocked():
		return 0.0
	var combo_average := 1.0 + float(mini(combo_cap, 8)) * combo_bonus_per_stack * 0.55
	return manual_damage * clicks_per_second * combo_average * (1.0 + critical_chance * (critical_multiplier - 1.0))

func estimated_auto_dps() -> float:
	var result := auto_damage * float(drone_count) / maxf(0.01, auto_interval) * (1.0 + critical_chance * 0.55 * (critical_multiplier - 1.0))
	if upgrade_level("hive_mind") > 0:
		result *= 1.0 + float(maxi(0, drone_count - 1)) * 0.18
	if auto_boost_timer > 0.0:
		result *= 1.0 + float(auto_boost_stacks) * 0.10
	return result

func boss_warning_active() -> bool:
	return current_boss_id == "grid_leech" and siphon_window_timer > 0.0

func boss_attack_interruptible() -> bool:
	return boss_warning_active()

func most_charged_cell() -> int:
	return 0

func total_charge() -> float:
	return float(credits)

func total_capacity() -> float:
	return 1.0

func charge_ratio() -> float:
	var next_cost := 0
	for definition in UPGRADE_DEFINITIONS:
		var id := str(definition.id)
		if skill_unlocked(id) and upgrade_level(id) < skill_max_rank(id):
			var cost := upgrade_cost(id)
			if next_cost == 0 or cost < next_cost:
				next_cost = cost
	return clampf(float(credits) / maxf(1.0, float(next_cost)), 0.0, 1.0) if next_cost > 0 else 1.0

func filled_cells() -> int:
	return 0

func is_full() -> bool:
	return false

func next_cell_index() -> int:
	return 0

func toggle_auto() -> bool:
	auto_enabled = true
	return true

func discharge(_critical_mode: int = -1) -> Dictionary:
	return {"valid": false, "output": 0.0, "credits": 0, "super": false, "critical": false}

func apply_output(output: float, _was_super: bool) -> Dictionary:
	var applied := deal_damage(output)
	return {"phase_changed": stage_phase == StagePhase.CLEAR, "boss_started": false, "boss_defeated": stage_phase == StagePhase.CLEAR, "interrupt": false, "applied": applied, "credits": 0, "mechanic": last_mechanic_event}

func consume_pending_core_damage() -> float:
	return 0.0

func select_reward(_id: String) -> bool:
	return false

func snapshot() -> Dictionary:
	return {
		"version": 8,
		"build_id": BUILD_ID,
		"credits": credits,
		"lifetime_charge": lifetime_charge,
		"elapsed": elapsed,
		"session_elapsed": session_elapsed,
		"session_id": session_id,
		"playtest_mode": playtest_mode,
		"encounter_history": encounter_history.duplicate(true),
		"purchase_history": purchase_history.duplicate(true),
		"exported_endings": exported_endings.duplicate(),
		"encounter_recorded": encounter_recorded,
		"encounter_started_session_time": encounter_started_session_time,
		"encounter_start_manual_inputs": encounter_start_manual_inputs,
		"encounter_start_auto_hits": encounter_start_auto_hits,
		"encounter_start_critical_hits": encounter_start_critical_hits,
		"encounter_start_purchases": encounter_start_purchases,
		"encounter_start_output": encounter_start_output,
		"encounter_start_credits": encounter_start_credits,
		"encounter_start_ranks": encounter_start_ranks,
		"manual_inputs": manual_inputs,
		"auto_hits": auto_hits,
		"critical_hits": critical_hits,
		"purchases": purchases,
		"invested_charge": invested_charge,
		"lifetime_output": lifetime_output,
		"highest_output": highest_output,
		"first_purchase_time": first_purchase_time,
		"upgrade_levels": upgrade_levels.duplicate(true),
		"beast_cores": beast_cores.duplicate(),
		"boss_cores": boss_cores.duplicate(),
		"current_stage_id": current_stage_id,
		"current_build_tag": current_build_tag,
		"current_boss_id": current_boss_id,
		"boss_hp": boss_hp,
		"boss_max_hp": boss_max_hp,
		"stage_phase": stage_phase,
		"stage_elapsed": stage_elapsed,
		"stage_clear_time": stage_clear_time,
		"enhanced_boss": enhanced_boss,
		"singularity_boss": singularity_boss,
		"final_boss": final_boss,
		"final_boss_form": final_boss_form,
		"encounter_index": encounter_index,
		"charge_fraction": charge_fraction,
		"manual_mode": manual_mode,
		"auto_boost_stacks": auto_boost_stacks,
		"auto_boost_timer": auto_boost_timer,
		"target_marks": target_marks,
		"auto_burst_counter": auto_burst_counter,
		"support_counter": support_counter,
		"world_hive_counter": world_hive_counter,
		"overlimit_system_unlocked": overlimit_system_unlocked,
		"singularity_residue": singularity_residue,
		"overlimit_invested_charge": overlimit_invested_charge,
		"overlimit_trigger_counter": overlimit_trigger_counter,
		"perpetual_sun_meter": perpetual_sun_meter,
		"perpetual_sun_timer": perpetual_sun_timer,
		"infinite_mode": infinite_mode,
		"infinite_wave": infinite_wave,
		"armor_cracks": armor_cracks,
		"enemy_armor_layers": enemy_armor_layers,
		"shell_open_timer": shell_open_timer,
		"vault_charge_meter": vault_charge_meter,
		"overdrive_timer": overdrive_timer,
		"stage_combo": stage_combo,
		"hydra_heads": hydra_heads,
		"drones": drones,
		"marked_drones": marked_drones,
		"phase_index": phase_index,
		"phase_timer": phase_timer,
		"analysis": analysis,
		"siphon_window_timer": siphon_window_timer,
		"siphon_cooldown": siphon_cooldown,
		"siphon_hits": siphon_hits,
		"furnace_hits": furnace_hits,
		"furnace_open_timer": furnace_open_timer,
		"singularity_phase": singularity_phase,
		"singularity_seal": singularity_seal,
		"singularity_rule": singularity_rule,
		"singularity_rule_timer": singularity_rule_timer,
		"singularity_progress": singularity_progress,
		"enemy_charge": enemy_charge,
	}

func restore_snapshot(data: Dictionary) -> bool:
	var version := int(data.get("version", 0))
	if version not in [5, 6, 7, 8]:
		return false
	reset()
	credits = maxi(0, int(data.get("credits", 0)))
	lifetime_charge = maxi(0, int(data.get("lifetime_charge", credits)))
	elapsed = maxf(0.0, float(data.get("elapsed", 0.0)))
	session_elapsed = maxf(elapsed, float(data.get("session_elapsed", elapsed)))
	session_id = str(data.get("session_id", session_id))
	set_playtest_mode(str(data.get("playtest_mode", "human")))
	encounter_history.clear()
	for value in data.get("encounter_history", []):
		if value is Dictionary:
			encounter_history.append(value.duplicate(true))
	purchase_history.clear()
	for value in data.get("purchase_history", []):
		if value is Dictionary:
			purchase_history.append(value.duplicate(true))
	exported_endings.clear()
	for value in data.get("exported_endings", []):
		var ending := str(value)
		if not ending.is_empty() and ending not in exported_endings:
			exported_endings.append(ending)
	manual_inputs = maxi(0, int(data.get("manual_inputs", 0)))
	auto_hits = maxi(0, int(data.get("auto_hits", 0)))
	critical_hits = maxi(0, int(data.get("critical_hits", 0)))
	purchases = maxi(0, int(data.get("purchases", 0)))
	invested_charge = maxi(0, int(data.get("invested_charge", 0)))
	lifetime_output = maxf(0.0, float(data.get("lifetime_output", 0.0)))
	highest_output = maxf(0.0, float(data.get("highest_output", 0.0)))
	first_purchase_time = float(data.get("first_purchase_time", -1.0))
	var saved_levels: Dictionary = data.get("upgrade_levels", {})
	for definition in UPGRADE_DEFINITIONS:
		var id := str(definition.id)
		upgrade_levels[id] = clampi(int(saved_levels.get(id, 0)), 0, int(definition.get("max_rank", MAX_SKILL_RANK)))
	beast_cores.clear()
	for value in data.get("beast_cores", []):
		var core := str(value)
		if not core.is_empty() and core not in beast_cores:
			beast_cores.append(core)
			circuit_rewards.append(core)
	boss_cores.clear()
	for value in data.get("boss_cores", []):
		var core := str(value)
		if not core.is_empty() and core not in boss_cores:
			boss_cores.append(core)
	current_stage_id = str(data.get("current_stage_id", "gearmaw"))
	current_build_tag = str(data.get("current_build_tag", "manual"))
	current_boss_id = str(data.get("current_boss_id", current_stage_id))
	boss_max_hp = maxf(100.0, float(data.get("boss_max_hp", BOSS_MAX_HP)))
	boss_hp = clampf(float(data.get("boss_hp", boss_max_hp)), 0.0, boss_max_hp)
	stage_phase = clampi(int(data.get("stage_phase", StagePhase.BOSS)), StagePhase.RESTORE, StagePhase.CLEAR)
	stage_elapsed = maxf(0.0, float(data.get("stage_elapsed", 0.0)))
	stage_clear_time = float(data.get("stage_clear_time", -1.0))
	enhanced_boss = bool(data.get("enhanced_boss", false))
	singularity_boss = bool(data.get("singularity_boss", false))
	final_boss = bool(data.get("final_boss", false))
	final_boss_form = clampi(int(data.get("final_boss_form", 0)), 0, 3)
	encounter_index = maxi(0, int(data.get("encounter_index", 0)))
	charge_fraction = clampf(float(data.get("charge_fraction", 0.0)), 0.0, 0.999)
	manual_mode = "generate" if generation_mode_unlocked() else "attack"
	var restored_boost_cap := 10 + upgrade_level("command_capacitor") * 2
	auto_boost_stacks = clampi(int(data.get("auto_boost_stacks", 0)), 0, restored_boost_cap)
	auto_boost_timer = maxf(0.0, float(data.get("auto_boost_timer", 0.0)))
	target_marks = clampi(int(data.get("target_marks", 0)), 0, 12)
	auto_burst_counter = maxi(0, int(data.get("auto_burst_counter", 0)))
	support_counter = maxi(0, int(data.get("support_counter", 0)))
	world_hive_counter = maxi(0, int(data.get("world_hive_counter", 0)))
	overlimit_system_unlocked = bool(data.get("overlimit_system_unlocked", false))
	# v11 retires residue as a spendable token. Preserve the serialized field for
	# backward compatibility, but normalize every restored campaign to zero.
	singularity_residue = 0
	overlimit_invested_charge = maxi(0, int(data.get("overlimit_invested_charge", 0)))
	overlimit_trigger_counter = clampi(int(data.get("overlimit_trigger_counter", 0)), 0, 4)
	perpetual_sun_meter = maxf(0.0, float(data.get("perpetual_sun_meter", 0.0)))
	perpetual_sun_timer = maxf(0.0, float(data.get("perpetual_sun_timer", 0.0)))
	infinite_mode = bool(data.get("infinite_mode", false))
	infinite_wave = maxi(0, int(data.get("infinite_wave", 0)))
	armor_cracks = clampi(int(data.get("armor_cracks", 0)), 0, 11)
	enemy_armor_layers = clampi(int(data.get("enemy_armor_layers", 3)), 0, 3)
	shell_open_timer = maxf(0.0, float(data.get("shell_open_timer", 0.0)))
	vault_charge_meter = clampf(float(data.get("vault_charge_meter", 0.0)), 0.0, 49.999)
	overdrive_timer = maxf(0.0, float(data.get("overdrive_timer", 0.0)))
	stage_combo = clampi(int(data.get("stage_combo", 0)), 0, 6)
	hydra_heads = clampi(int(data.get("hydra_heads", 3)), 0, 3)
	drones = clampi(int(data.get("drones", 3)), 1, 6)
	marked_drones = clampi(int(data.get("marked_drones", 0)), 0, drones)
	phase_index = clampi(int(data.get("phase_index", 0)), 0, 3)
	phase_timer = maxf(0.01, float(data.get("phase_timer", 3.0)))
	analysis = clampf(float(data.get("analysis", 0.0)), 0.0, 100.0)
	siphon_window_timer = maxf(0.0, float(data.get("siphon_window_timer", 0.0)))
	siphon_cooldown = maxf(0.0, float(data.get("siphon_cooldown", 6.0)))
	siphon_hits = clampi(int(data.get("siphon_hits", 0)), 0, 8)
	furnace_hits = clampi(int(data.get("furnace_hits", 0)), 0, 20)
	furnace_open_timer = maxf(0.0, float(data.get("furnace_open_timer", 0.0)))
	singularity_phase = clampi(int(data.get("singularity_phase", 1)), 1, 3)
	singularity_seal = clampi(int(data.get("singularity_seal", 0)), 0, 6)
	singularity_rule = clampi(int(data.get("singularity_rule", 0)), 0, 3)
	singularity_rule_timer = maxf(0.01, float(data.get("singularity_rule_timer", 7.0)))
	singularity_progress = clampi(int(data.get("singularity_progress", 0)), 0, 9)
	enemy_charge = clampf(float(data.get("enemy_charge", 0.0)), 0.0, 100.0)
	encounter_recorded = bool(data.get("encounter_recorded", stage_phase == StagePhase.CLEAR))
	encounter_started_session_time = maxf(0.0, float(data.get("encounter_started_session_time", session_elapsed - stage_elapsed)))
	encounter_start_manual_inputs = maxi(0, int(data.get("encounter_start_manual_inputs", manual_inputs)))
	encounter_start_auto_hits = maxi(0, int(data.get("encounter_start_auto_hits", auto_hits)))
	encounter_start_critical_hits = maxi(0, int(data.get("encounter_start_critical_hits", critical_hits)))
	encounter_start_purchases = maxi(0, int(data.get("encounter_start_purchases", purchases)))
	encounter_start_output = maxf(0.0, float(data.get("encounter_start_output", lifetime_output)))
	encounter_start_credits = maxi(0, int(data.get("encounter_start_credits", credits)))
	encounter_start_ranks = maxi(0, int(data.get("encounter_start_ranks", skill_points_bought())))
	refresh_stats()
	return true
