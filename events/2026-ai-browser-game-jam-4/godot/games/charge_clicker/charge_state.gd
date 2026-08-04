class_name ChargePrototypeState
extends RefCounted

const CELL_COUNT := 6
const MAX_HEAT := 100.0
const MAX_OVERCHARGE := 100.0
const RESTORE_GOAL := 1.0 # Kept for compatibility with old preview/test callers.
const BOSS_MAX_HP := 21000.0
const MAX_SKILL_RANK := 3

enum StagePhase { RESTORE, BOSS, REWARD, CLEAR }

# Three roots lead into three readable branches. A predecessor at rank 2
# unlocks the next node. Costs are intentionally steep enough that the normal
# ending produces a focused build, while the true route can complete the tree.
const UPGRADE_DEFINITIONS := [
	{"id": "manual", "costs": [35, 135, 390], "requires": ""},
	{"id": "critical", "costs": [55, 180, 470], "requires": "manual"},
	{"id": "surge", "costs": [70, 220, 560], "requires": "critical"},
	{"id": "capacity", "costs": [35, 135, 390], "requires": ""},
	{"id": "discharge", "costs": [60, 190, 500], "requires": "capacity"},
	{"id": "auto", "costs": [35, 135, 390], "requires": ""},
	{"id": "cooling", "costs": [55, 180, 470], "requires": "auto"},
	{"id": "insulation", "costs": [70, 220, 560], "requires": "cooling"},
]

var cells: Array[float] = []
var capacity := 55.0
var manual_power := 11.0
var auto_rate := 6.0
var cooling_rate := 8.5
var discharge_multiplier := 1.0
var critical_chance := 0.06
var critical_multiplier := 2.0
var heat_generation := 1.0
var full_discharge_bonus := 0.8
var meltdown_retention := 0.12

var credits := 0
var heat := 0.0
var overcharge := 0.0
var auto_enabled := false
var elapsed := 0.0
var auto_buffer := 0.0
var auto_overflow := 0.0
var manual_streak := 0

var manual_inputs := 0
var partial_discharges := 0
var super_discharges := 0
var meltdowns := 0
var critical_hits := 0
var purchases := 0
var lifetime_output := 0.0
var highest_output := 0.0
var first_purchase_time := -1.0
var upgrade_levels: Dictionary = {}
var rng := RandomNumberGenerator.new()

var stage_phase := StagePhase.BOSS
var restore_progress := 0.0
var restore_goal := RESTORE_GOAL
var boss_hp := BOSS_MAX_HP
var boss_max_hp := BOSS_MAX_HP
var boss_attack_timer := 8.0
var boss_drains := 0
var boss_interrupts := 0
var stage_clear_time := -1.0
var reward_id := ""
var current_stage_id := "gearmaw"
var current_build_tag := "manual"
var current_boss_id := "gearmaw"
var stage_elapsed := 0.0
var enhanced_boss := false
var singularity_boss := false
var singularity_phase := 1
var encounter_index := 0

var stage_combo := 0
var combo_timer := 0.0
var manual_boost_timer := 0.0
var beast_cores: Array[String] = []
var boss_cores: Array[String] = []
var circuit_rewards: Array[String] = [] # v2 name retained as a read-only-compatible alias.

# Per-enemy readable state.
var enemy_armor_layers := 3
var armor_cracks := 0
var armor_repair_timer := 0.0
var shell_open_timer := 0.0
var hydra_heads := 3
var drones := 2
var marked_drones := 0
var drone_spawn_timer := 7.0
var phase_index := 0
var phase_timer := 3.0
var analysis := 0.0
var enemy_charge := 0.0
var singularity_seal := 0
var singularity_rule := 0
var singularity_rule_timer := 7.0
var meltdown_guard_available := false
var pending_core_damage := 0.0
var last_discharge_heat := 0.0
var last_discharge_streak := 0
var last_discharge_critical := false
var last_discharge_full := false
var last_damage_multiplier := 1.0
var last_mechanic_event := ""

func _init() -> void:
	rng.randomize()
	reset()

func reset() -> void:
	cells.clear()
	for index in range(CELL_COUNT):
		cells.append(0.0)
	credits = 0
	heat = 0.0
	overcharge = 0.0
	auto_enabled = false
	elapsed = 0.0
	auto_buffer = 0.0
	auto_overflow = 0.0
	manual_streak = 0
	manual_inputs = 0
	partial_discharges = 0
	super_discharges = 0
	meltdowns = 0
	critical_hits = 0
	purchases = 0
	lifetime_output = 0.0
	highest_output = 0.0
	first_purchase_time = -1.0
	upgrade_levels.clear()
	for definition in UPGRADE_DEFINITIONS:
		upgrade_levels[str(definition.id)] = 0
	beast_cores.clear()
	boss_cores.clear()
	circuit_rewards.clear()
	current_stage_id = "gearmaw"
	current_build_tag = "manual"
	current_boss_id = "gearmaw"
	encounter_index = 0
	refresh_stats()
	begin_stage("gearmaw", "manual", RESTORE_GOAL, BOSS_MAX_HP, 0)

func begin_stage(stage_id: String, build_tag: String, _unused_goal: float, hp: float, order_index: int = 0) -> void:
	current_stage_id = stage_id
	current_build_tag = build_tag
	current_boss_id = stage_id
	encounter_index = maxi(0, order_index)
	boss_max_hp = maxf(1000.0, hp)
	enhanced_boss = false
	singularity_boss = false
	reset_encounter(StagePhase.BOSS)

func begin_campaign_boss(boss_id: String, hp: float, is_enhanced: bool = false, is_singularity: bool = false) -> void:
	current_stage_id = ""
	current_build_tag = "all" if is_singularity else "boss"
	current_boss_id = boss_id
	boss_max_hp = maxf(1000.0, hp)
	enhanced_boss = is_enhanced
	singularity_boss = is_singularity
	reset_encounter(StagePhase.BOSS)

func reset_encounter(next_phase: int) -> void:
	clear_cells()
	heat = 0.0
	overcharge = 0.0
	auto_buffer = 0.0
	auto_overflow = 0.0
	manual_streak = 0
	stage_phase = next_phase
	restore_progress = 0.0
	boss_hp = boss_max_hp
	boss_attack_timer = 7.8 if not enhanced_boss else 6.2
	boss_drains = 0
	boss_interrupts = 0
	stage_clear_time = -1.0
	reward_id = ""
	stage_elapsed = 0.0
	stage_combo = 0
	combo_timer = 0.0
	manual_boost_timer = 0.0
	enemy_armor_layers = 3
	armor_cracks = 0
	armor_repair_timer = 0.0
	shell_open_timer = 0.0
	hydra_heads = 3
	drones = 2
	marked_drones = 0
	drone_spawn_timer = 7.0
	phase_index = 0
	phase_timer = 3.0
	analysis = 0.0
	enemy_charge = 0.0
	singularity_phase = 1
	singularity_seal = 0
	singularity_rule = 0
	singularity_rule_timer = 7.0
	pending_core_damage = 0.0
	last_mechanic_event = ""
	meltdown_guard_available = upgrade_level("insulation") >= 3 or "furnace_sovereign" in boss_cores

func refresh_stats() -> void:
	capacity = 55.0 * (1.0 + 0.15 * upgrade_level("capacity"))
	manual_power = 11.0 * (1.0 + 0.20 * upgrade_level("manual"))
	auto_rate = 6.0 * (1.0 + 0.25 * upgrade_level("auto"))
	cooling_rate = 8.5 * (1.0 + 0.20 * upgrade_level("cooling"))
	discharge_multiplier = 1.0 + 0.18 * upgrade_level("discharge")
	critical_chance = minf(0.72, 0.06 + 0.05 * upgrade_level("critical"))
	critical_multiplier = 2.5 if upgrade_level("critical") >= 3 else 2.0
	full_discharge_bonus = 0.8 + 0.20 * upgrade_level("surge")
	heat_generation = pow(0.92, upgrade_level("cooling"))
	meltdown_retention = minf(0.68, 0.12 + 0.15 * upgrade_level("insulation"))
	for index in range(cells.size()):
		cells[index] = minf(cells[index], capacity)

func skill_unlocked(id: String) -> bool:
	var definition := upgrade_definition(id)
	if definition.is_empty():
		return false
	var required := str(definition.get("requires", ""))
	return required.is_empty() or upgrade_level(required) >= 2

func skill_points_bought() -> int:
	var total := 0
	for definition in UPGRADE_DEFINITIONS:
		total += upgrade_level(str(definition.id))
	return total

func respec_skills() -> int:
	var refunded := 0
	for definition in UPGRADE_DEFINITIONS:
		var id := str(definition.id)
		var levels := upgrade_level(id)
		var costs: Array = definition.costs
		for rank in range(levels):
			refunded += int(costs[rank])
		upgrade_levels[id] = 0
	credits += refunded
	refresh_stats()
	return refunded

func synergy_active(_id: String) -> bool:
	return false

func active_synergies() -> Array[String]:
	return beast_cores.duplicate()

func grant_stage_circuit(id: String) -> bool:
	return grant_beast_core(id)

func grant_beast_core(id: String) -> bool:
	if id.is_empty() or id in beast_cores:
		return false
	beast_cores.append(id)
	if id not in circuit_rewards:
		circuit_rewards.append(id)
	refresh_stats()
	return true

func grant_boss_core(id: String) -> bool:
	if id.is_empty() or id in boss_cores:
		return false
	boss_cores.append(id)
	return true

func effective_critical_chance() -> float:
	var result := critical_chance
	if current_stage_id == "phase_mantis":
		result += 0.22 if phase_index == 2 else -0.02
	if "phase_computation" in beast_cores and analysis >= 100.0:
		return 1.0
	return clampf(result, 0.0, 0.88)

func total_capacity() -> float:
	return capacity * CELL_COUNT

func total_charge() -> float:
	var total := 0.0
	for value in cells:
		total += value
	return total

func charge_ratio() -> float:
	return total_charge() / maxf(1.0, total_capacity())

func filled_cells() -> int:
	var count := 0
	for value in cells:
		if value >= capacity - 0.01:
			count += 1
	return count

func is_full() -> bool:
	return filled_cells() == CELL_COUNT

func next_cell_index() -> int:
	for index in range(cells.size()):
		if cells[index] < capacity - 0.001:
			return index
	return -1

func manual_charge(critical_mode: int = -1) -> Dictionary:
	manual_inputs += 1
	manual_streak = mini(24, manual_streak + 1)
	var impact_proc := "impact_guidance" in beast_cores and manual_inputs % 12 == 0
	var is_critical := critical_mode == 1 or (critical_mode < 0 and rng.randf() < effective_critical_chance())
	if is_critical:
		critical_hits += 1
	var streak_multiplier := 1.0 + float(mini(12, manual_streak) - 1) * 0.018
	var amount := manual_power * streak_multiplier * (critical_multiplier if is_critical else 1.0) * (3.0 if impact_proc else 1.0)
	if current_stage_id == "gearmaw":
		armor_cracks = mini(6, armor_cracks + (3 if impact_proc else 1))
		armor_repair_timer = 2.4
	if current_stage_id == "swarm_matriarch" and drones > marked_drones:
		marked_drones = mini(drones, marked_drones + 1)
	if current_stage_id == "swarm_matriarch" or "swarm_clock" in beast_cores:
		manual_boost_timer = 2.6
	var result := add_charge_energy(amount, 2.7 * heat_generation, true)
	result.critical = is_critical
	result.input_amount = amount
	result.core_pulse = impact_proc
	if heat >= MAX_HEAT:
		result.meltdown = true
		result.lost = trigger_meltdown()
	else:
		result.meltdown = false
		result.lost = 0.0
	return result

func add_charge_energy(amount: float, heat_gain: float, allow_overcharge: bool) -> Dictionary:
	var was_full := is_full()
	var remaining := maxf(0.0, amount)
	var added := 0.0
	while remaining > 0.001:
		var index := next_cell_index()
		if index < 0:
			break
		var room := capacity - cells[index]
		var transfer := minf(room, remaining)
		cells[index] += transfer
		remaining -= transfer
		added += transfer
	if allow_overcharge and remaining > 0.0:
		overcharge = minf(MAX_OVERCHARGE, overcharge + remaining / maxf(1.0, manual_power) * 7.0)
	elif "swarm_clock" in beast_cores and remaining > 0.0:
		auto_overflow = minf(total_capacity() * 0.35, auto_overflow + remaining)
	if singularity_boss and singularity_phase == 3 and stage_phase == StagePhase.BOSS:
		var pressure := 8.0 + 8.0 * (1.0 - boss_hp / maxf(1.0, boss_max_hp))
		enemy_charge = minf(100.0, enemy_charge + added / maxf(1.0, total_capacity()) * pressure)
	heat = minf(MAX_HEAT, heat + maxf(0.0, heat_gain))
	return {"added": added, "overflow": remaining, "became_full": not was_full and is_full(), "is_full": is_full()}

func tick(delta: float, manual_held: bool = false) -> Dictionary:
	if stage_phase == StagePhase.BOSS:
		elapsed += delta
		stage_elapsed += delta
	combo_timer = maxf(0.0, combo_timer - delta)
	manual_boost_timer = maxf(0.0, manual_boost_timer - delta)
	shell_open_timer = maxf(0.0, shell_open_timer - delta)
	if combo_timer <= 0.0:
		stage_combo = 0
	if current_stage_id == "gearmaw" and armor_cracks > 0:
		armor_repair_timer -= delta
		if armor_repair_timer <= 0.0:
			armor_cracks -= 1
			armor_repair_timer = 0.75
	if current_stage_id == "phase_mantis":
		phase_timer -= delta
		if phase_timer <= 0.0:
			phase_index = wrapi(phase_index + 1, 0, 4)
			phase_timer += 3.0
	if current_stage_id == "swarm_matriarch":
		drone_spawn_timer -= delta
		if drone_spawn_timer <= 0.0:
			drones = mini(4, drones + 1)
			drone_spawn_timer = 7.5
	var cooling_multiplier := 0.15 if manual_held else 1.0
	if current_stage_id == "pyre_wyrm":
		cooling_multiplier *= 0.72
	if current_boss_id == "thermal_titan":
		cooling_multiplier *= 0.55 if enhanced_boss else 0.72
	heat = maxf(0.0, heat - cooling_rate * cooling_multiplier * delta)
	var auto_added := 0.0
	var became_full := false
	if auto_enabled and not is_full() and stage_phase == StagePhase.BOSS:
		var effective_auto := auto_rate
		if manual_boost_timer > 0.0:
			effective_auto *= 1.5
		if current_stage_id == "swarm_matriarch":
			effective_auto *= maxf(0.28, 1.0 - float(drones) * 0.16)
		auto_buffer += effective_auto * delta
		if auto_buffer >= 0.5:
			var amount := auto_buffer
			auto_buffer = 0.0
			var result := add_charge_energy(amount, amount / maxf(1.0, manual_power) * 0.42 * heat_generation, false)
			auto_added = float(result.added)
			became_full = bool(result.became_full)
	var did_meltdown := false
	var lost := 0.0
	if heat >= MAX_HEAT:
		did_meltdown = true
		lost = trigger_meltdown()
	var stage_result := tick_stage(delta)
	return {
		"auto_added": auto_added, "became_full": became_full, "meltdown": did_meltdown, "lost": lost,
		"boss_warning": bool(stage_result.boss_warning), "boss_drain": bool(stage_result.boss_drain),
		"drain_cell": int(stage_result.drain_cell), "drained": float(stage_result.drained),
		"boss_healed": float(stage_result.boss_healed), "thermal_spike": bool(stage_result.thermal_spike),
		"singularity_burst": bool(stage_result.singularity_burst), "singularity_phase": singularity_phase,
	}

func tick_stage(delta: float) -> Dictionary:
	var result := {"boss_warning": false, "boss_drain": false, "thermal_spike": false, "singularity_burst": false, "drain_cell": -1, "drained": 0.0, "boss_healed": 0.0}
	if stage_phase != StagePhase.BOSS:
		return result
	if singularity_boss:
		var ratio := boss_hp / maxf(1.0, boss_max_hp)
		singularity_phase = 1 if ratio > 0.66 else 2 if ratio > 0.33 else 3
		if singularity_phase == 2:
			singularity_rule_timer -= delta
			if singularity_rule_timer <= 0.0:
				singularity_rule = wrapi(singularity_rule + 1, 0, 4)
				singularity_rule_timer += 7.0
		if singularity_phase == 3 and enemy_charge >= 100.0:
			var healed := boss_max_hp * 0.0025
			boss_hp = minf(boss_max_hp, boss_hp + healed)
			enemy_charge = 18.0
			result.singularity_burst = true
			result.boss_healed = healed
	var previous_timer := boss_attack_timer
	boss_attack_timer -= delta
	if previous_timer > 2.0 and boss_attack_timer <= 2.0:
		result.boss_warning = true
	if boss_attack_timer > 0.0:
		return result
	if current_boss_id == "thermal_titan" or (singularity_boss and singularity_phase == 2 and singularity_rule == 2):
		var spike := 27.0 if enhanced_boss or singularity_boss else 19.0
		heat = minf(MAX_HEAT, heat + spike * heat_generation)
		boss_drains += 1
		boss_attack_timer = 6.0 if enhanced_boss or singularity_boss else 7.3
		result.thermal_spike = true
		return result
	if current_boss_id == "grid_leech" or singularity_boss:
		var index := most_charged_cell()
		var drained := 0.0
		if index >= 0:
			drained = cells[index] * (0.58 if enhanced_boss or singularity_boss else 0.4)
			cells[index] = maxf(0.0, cells[index] - drained)
			if enhanced_boss:
				var second := most_charged_cell()
				if second >= 0:
					var extra := cells[second] * 0.34
					cells[second] -= extra
					drained += extra
		var healed := drained * (0.12 if "predation_reversal" in boss_cores else 0.28)
		boss_hp = minf(boss_max_hp, boss_hp + healed)
		boss_drains += 1
		boss_attack_timer = maxf(4.8, 8.4 - float(boss_drains) * 0.2)
		result.boss_drain = true
		result.drain_cell = index
		result.drained = drained
		result.boss_healed = healed
		return result
	boss_attack_timer = 7.0
	return result

func most_charged_cell() -> int:
	var best_index := -1
	var best_value := 0.0
	for index in range(cells.size()):
		if cells[index] > best_value:
			best_value = cells[index]
			best_index = index
	return best_index

func boss_warning_active() -> bool:
	return stage_phase == StagePhase.BOSS and boss_attack_timer <= 2.0 and (current_boss_id in ["grid_leech", "thermal_titan"] or singularity_boss)

func boss_attack_interruptible() -> bool:
	return current_boss_id == "grid_leech" or (singularity_boss and singularity_phase != 2)

func apply_output(output: float, was_super: bool) -> Dictionary:
	var result := {"phase_changed": false, "boss_started": false, "boss_defeated": false, "interrupt": false, "applied": 0.0, "credits": 0, "mechanic": ""}
	if stage_phase != StagePhase.BOSS:
		return result
	var damage := maxf(0.0, output)
	var multiplier := 1.0
	last_mechanic_event = ""
	if current_stage_id == "gearmaw":
		if enemy_armor_layers > 0:
			if was_super or armor_cracks >= 3:
				enemy_armor_layers -= 1
				armor_cracks = 0
				multiplier *= 1.05
				last_mechanic_event = "armor_break"
			else:
				multiplier *= 0.45 + (0.15 if upgrade_level("discharge") >= 3 else 0.0)
				last_mechanic_event = "armor_block"
	elif current_stage_id == "vaultback":
		if was_super:
			shell_open_timer = 5.0 + overcharge * 0.025
			multiplier *= 1.55
			last_mechanic_event = "shell_break"
		elif shell_open_timer > 0.0:
			multiplier *= 1.12
		else:
			multiplier *= 0.32
			last_mechanic_event = "shell_block"
	elif current_stage_id == "pyre_wyrm":
		if last_discharge_heat >= 65.0 and last_discharge_heat <= 90.0:
			multiplier *= 1.62
			last_mechanic_event = "redline_hit"
		elif last_discharge_heat > 90.0:
			multiplier *= 0.88
		else:
			multiplier *= 0.55
	elif current_stage_id == "relay_hydra":
		if stage_combo >= 2:
			multiplier *= 1.0 + float(stage_combo - 1) * 0.14
		if hydra_heads > 0 and damage * multiplier >= boss_max_hp * (0.08 + float(3 - hydra_heads) * 0.02):
			hydra_heads -= 1
			last_mechanic_event = "head_severed"
	elif current_stage_id == "swarm_matriarch":
		if auto_enabled and marked_drones > 0:
			drones = maxi(0, drones - marked_drones)
			marked_drones = 0
			multiplier *= 1.3
			last_mechanic_event = "drone_purge"
		else:
			multiplier *= maxf(0.48, 1.0 - float(drones) * 0.11)
	elif current_stage_id == "phase_mantis":
		if last_discharge_critical:
			multiplier *= 1.7
			analysis = 0.0
			last_mechanic_event = "phase_critical"
		else:
			multiplier *= 0.78
			analysis = minf(100.0, analysis + 22.0 + (12.0 if phase_index == 2 else 0.0))
	if current_boss_id == "grid_leech" and boss_warning_active() and was_super:
		multiplier *= 1.4
		boss_attack_timer = 8.4
		boss_interrupts += 1
		result.interrupt = true
		last_mechanic_event = "siphon_interrupt"
	elif current_boss_id == "thermal_titan":
		multiplier *= 1.55 if last_discharge_heat >= 65.0 and last_discharge_heat <= 90.0 else 0.58
		if was_super:
			boss_attack_timer += 1.2
	if singularity_boss:
		multiplier *= singularity_multiplier(was_super)
	if "redheat_conversion" in beast_cores and last_discharge_heat >= 60.0:
		multiplier *= 1.14
	if "furnace_sovereign" in boss_cores and last_discharge_heat >= 65.0:
		multiplier *= 1.16
	damage *= multiplier
	last_damage_multiplier = multiplier
	boss_hp = maxf(0.0, boss_hp - damage)
	result.applied = damage
	result.mechanic = last_mechanic_event
	var earned := maxi(1, int(round(damage / 250.0))) if damage > 0.0 else 0
	credits += earned
	result.credits = earned
	lifetime_output += damage
	highest_output = maxf(highest_output, damage)
	if "predation_reversal" in boss_cores and damage > 0.0:
		add_charge_energy(minf(capacity * 0.22, damage * 0.003), 0.0, false)
	if boss_hp <= 0.0:
		stage_phase = StagePhase.CLEAR
		stage_clear_time = stage_elapsed
		result.phase_changed = true
		result.boss_defeated = true
	return result

func singularity_multiplier(was_super: bool) -> float:
	match singularity_phase:
		1:
			var success := false
			match singularity_seal:
				0: success = last_discharge_streak >= 8
				1: success = was_super
				2: success = last_discharge_heat >= 65.0
				3: success = stage_combo >= 2
				4: success = auto_enabled
				5: success = last_discharge_critical
			if success:
				singularity_seal = mini(6, singularity_seal + 1)
				last_mechanic_event = "seal_break"
				return 1.55
			return 0.52
		2:
			match singularity_rule:
				0: return 1.5 if not was_super else 0.5
				1: return 1.55 if was_super else 0.42
				2: return 1.4 if last_discharge_heat >= 65.0 else 0.62
				_: return 1.45 if last_discharge_critical else 0.65
		3:
			return 1.18 if enemy_charge < 78.0 else 0.9
	return 1.0

func objective_ratio() -> float:
	return 1.0 - boss_hp / maxf(1.0, boss_max_hp)

func select_reward(_id: String) -> bool:
	return false

func discharge(critical_mode: int = -1) -> Dictionary:
	var stored := total_charge()
	if stored < 0.5:
		return {"valid": false, "output": 0.0, "credits": 0, "super": false, "critical": false}
	var was_full := is_full()
	var forced_analysis := "phase_computation" in beast_cores and analysis >= 100.0
	var is_critical := critical_mode == 1 or forced_analysis or (critical_mode < 0 and rng.randf() < effective_critical_chance() * 0.7)
	if is_critical:
		critical_hits += 1
	var full_multiplier := 1.0 + full_discharge_bonus if was_full else 1.0
	var overcharge_multiplier := 1.0 + overcharge * 0.01
	var heat_multiplier := 1.0 + maxf(0.0, heat - 50.0) * 0.004
	var crit_multiplier := critical_multiplier if is_critical else 1.0
	if current_stage_id == "relay_hydra" or "cascade_relay" in beast_cores:
		stage_combo = mini(5, stage_combo + 1) if combo_timer > 0.0 else 1
		combo_timer = 4.0
	var output := stored * discharge_multiplier * full_multiplier * overcharge_multiplier * heat_multiplier * crit_multiplier
	if auto_overflow > 0.0:
		output += auto_overflow * discharge_multiplier * 1.4
		auto_overflow = 0.0
	last_discharge_heat = heat
	last_discharge_streak = manual_streak
	last_discharge_critical = is_critical
	last_discharge_full = was_full
	if forced_analysis:
		analysis = 0.0
	clear_cells()
	if was_full and "deep_storage" in beast_cores:
		for index in range(cells.size()):
			cells[index] = capacity * 0.15
	if "cascade_relay" in beast_cores:
		add_charge_energy(capacity * minf(0.32, 0.07 * float(maxi(1, stage_combo))), 0.0, false)
	heat = maxf(0.0, heat - (24.0 if upgrade_level("cooling") >= 3 else 18.0))
	overcharge = 0.0
	manual_streak = 0
	if was_full:
		super_discharges += 1
		if "furnace_sovereign" in boss_cores:
			meltdown_guard_available = true
	else:
		partial_discharges += 1
	return {"valid": true, "output": output, "credits": 0, "super": was_full, "critical": is_critical}

func clear_cells() -> void:
	for index in range(cells.size()):
		cells[index] = 0.0

func trigger_meltdown() -> float:
	if meltdown_guard_available:
		meltdown_guard_available = false
		heat = 72.0
		last_mechanic_event = "meltdown_guard"
		return 0.0
	var before := total_charge()
	for index in range(cells.size()):
		cells[index] *= meltdown_retention
	var lost := before - total_charge()
	if "redheat_conversion" in beast_cores:
		pending_core_damage += lost * 0.42
	heat = 34.0
	overcharge = 0.0
	manual_streak = 0
	meltdowns += 1
	return lost

func consume_pending_core_damage() -> float:
	var damage := pending_core_damage
	pending_core_damage = 0.0
	return damage

func toggle_auto() -> bool:
	auto_enabled = not auto_enabled
	return auto_enabled

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
	if definition.is_empty() or level >= MAX_SKILL_RANK:
		return 0
	return int(definition.costs[level])

func can_purchase(id: String) -> bool:
	return skill_unlocked(id) and upgrade_level(id) < MAX_SKILL_RANK and credits >= upgrade_cost(id)

func purchase_upgrade(id: String) -> bool:
	if not can_purchase(id):
		return false
	var cost := upgrade_cost(id)
	credits -= cost
	upgrade_levels[id] = upgrade_level(id) + 1
	purchases += 1
	if first_purchase_time < 0.0:
		first_purchase_time = elapsed
	refresh_stats()
	return true

func snapshot() -> Dictionary:
	return {
		"version": 3, "cells": cells.duplicate(), "credits": credits, "heat": heat, "overcharge": overcharge,
		"auto_enabled": auto_enabled, "elapsed": elapsed, "auto_overflow": auto_overflow, "manual_streak": manual_streak,
		"manual_inputs": manual_inputs, "partial_discharges": partial_discharges, "super_discharges": super_discharges,
		"meltdowns": meltdowns, "critical_hits": critical_hits, "purchases": purchases, "lifetime_output": lifetime_output,
		"highest_output": highest_output, "first_purchase_time": first_purchase_time, "upgrade_levels": upgrade_levels.duplicate(true),
		"stage_phase": stage_phase, "boss_hp": boss_hp, "boss_max_hp": boss_max_hp, "boss_attack_timer": boss_attack_timer,
		"boss_drains": boss_drains, "boss_interrupts": boss_interrupts, "stage_clear_time": stage_clear_time,
		"current_stage_id": current_stage_id, "current_build_tag": current_build_tag, "current_boss_id": current_boss_id,
		"stage_elapsed": stage_elapsed, "enhanced_boss": enhanced_boss, "singularity_boss": singularity_boss,
		"singularity_phase": singularity_phase, "encounter_index": encounter_index, "stage_combo": stage_combo,
		"combo_timer": combo_timer, "manual_boost_timer": manual_boost_timer, "beast_cores": beast_cores.duplicate(),
		"boss_cores": boss_cores.duplicate(), "enemy_armor_layers": enemy_armor_layers, "armor_cracks": armor_cracks,
		"armor_repair_timer": armor_repair_timer, "shell_open_timer": shell_open_timer, "hydra_heads": hydra_heads,
		"drones": drones, "marked_drones": marked_drones, "drone_spawn_timer": drone_spawn_timer, "phase_index": phase_index,
		"phase_timer": phase_timer, "analysis": analysis, "enemy_charge": enemy_charge, "singularity_seal": singularity_seal,
		"singularity_rule": singularity_rule, "singularity_rule_timer": singularity_rule_timer,
		"meltdown_guard_available": meltdown_guard_available, "pending_core_damage": pending_core_damage,
	}

func restore_snapshot(data: Dictionary) -> bool:
	if int(data.get("version", 0)) != 3:
		return false
	reset()
	var saved_levels: Dictionary = data.get("upgrade_levels", {})
	for definition in UPGRADE_DEFINITIONS:
		var id := str(definition.id)
		upgrade_levels[id] = clampi(int(saved_levels.get(id, 0)), 0, MAX_SKILL_RANK)
	for value in data.get("beast_cores", []):
		var core := str(value)
		if not core.is_empty() and core not in beast_cores:
			beast_cores.append(core)
			circuit_rewards.append(core)
	for value in data.get("boss_cores", []):
		var core := str(value)
		if not core.is_empty() and core not in boss_cores:
			boss_cores.append(core)
	refresh_stats()
	credits = maxi(0, int(data.get("credits", 0)))
	heat = clampf(float(data.get("heat", 0.0)), 0.0, MAX_HEAT)
	overcharge = clampf(float(data.get("overcharge", 0.0)), 0.0, MAX_OVERCHARGE)
	auto_enabled = bool(data.get("auto_enabled", false))
	elapsed = maxf(0.0, float(data.get("elapsed", 0.0)))
	auto_overflow = maxf(0.0, float(data.get("auto_overflow", 0.0)))
	manual_streak = maxi(0, int(data.get("manual_streak", 0)))
	manual_inputs = maxi(0, int(data.get("manual_inputs", 0)))
	partial_discharges = maxi(0, int(data.get("partial_discharges", 0)))
	super_discharges = maxi(0, int(data.get("super_discharges", 0)))
	meltdowns = maxi(0, int(data.get("meltdowns", 0)))
	critical_hits = maxi(0, int(data.get("critical_hits", 0)))
	purchases = maxi(0, int(data.get("purchases", 0)))
	lifetime_output = maxf(0.0, float(data.get("lifetime_output", 0.0)))
	highest_output = maxf(0.0, float(data.get("highest_output", 0.0)))
	first_purchase_time = float(data.get("first_purchase_time", -1.0))
	stage_phase = clampi(int(data.get("stage_phase", StagePhase.BOSS)), StagePhase.BOSS, StagePhase.CLEAR)
	boss_max_hp = maxf(1000.0, float(data.get("boss_max_hp", BOSS_MAX_HP)))
	boss_hp = clampf(float(data.get("boss_hp", boss_max_hp)), 0.0, boss_max_hp)
	boss_attack_timer = maxf(0.01, float(data.get("boss_attack_timer", 8.0)))
	boss_drains = maxi(0, int(data.get("boss_drains", 0)))
	boss_interrupts = maxi(0, int(data.get("boss_interrupts", 0)))
	stage_clear_time = float(data.get("stage_clear_time", -1.0))
	current_stage_id = str(data.get("current_stage_id", "gearmaw"))
	current_build_tag = str(data.get("current_build_tag", "manual"))
	current_boss_id = str(data.get("current_boss_id", current_stage_id))
	stage_elapsed = maxf(0.0, float(data.get("stage_elapsed", 0.0)))
	enhanced_boss = bool(data.get("enhanced_boss", false))
	singularity_boss = bool(data.get("singularity_boss", false))
	singularity_phase = clampi(int(data.get("singularity_phase", 1)), 1, 3)
	encounter_index = maxi(0, int(data.get("encounter_index", 0)))
	stage_combo = maxi(0, int(data.get("stage_combo", 0)))
	combo_timer = maxf(0.0, float(data.get("combo_timer", 0.0)))
	manual_boost_timer = maxf(0.0, float(data.get("manual_boost_timer", 0.0)))
	enemy_armor_layers = clampi(int(data.get("enemy_armor_layers", 3)), 0, 3)
	armor_cracks = clampi(int(data.get("armor_cracks", 0)), 0, 6)
	armor_repair_timer = maxf(0.0, float(data.get("armor_repair_timer", 0.0)))
	shell_open_timer = maxf(0.0, float(data.get("shell_open_timer", 0.0)))
	hydra_heads = clampi(int(data.get("hydra_heads", 3)), 0, 3)
	drones = clampi(int(data.get("drones", 2)), 0, 4)
	marked_drones = clampi(int(data.get("marked_drones", 0)), 0, drones)
	drone_spawn_timer = maxf(0.0, float(data.get("drone_spawn_timer", 7.0)))
	phase_index = clampi(int(data.get("phase_index", 0)), 0, 3)
	phase_timer = maxf(0.01, float(data.get("phase_timer", 3.0)))
	analysis = clampf(float(data.get("analysis", 0.0)), 0.0, 100.0)
	enemy_charge = clampf(float(data.get("enemy_charge", 0.0)), 0.0, 100.0)
	singularity_seal = clampi(int(data.get("singularity_seal", 0)), 0, 6)
	singularity_rule = clampi(int(data.get("singularity_rule", 0)), 0, 3)
	singularity_rule_timer = maxf(0.01, float(data.get("singularity_rule_timer", 7.0)))
	meltdown_guard_available = bool(data.get("meltdown_guard_available", false))
	pending_core_damage = maxf(0.0, float(data.get("pending_core_damage", 0.0)))
	var saved_cells: Array = data.get("cells", [])
	if saved_cells.size() == CELL_COUNT:
		for index in range(CELL_COUNT):
			cells[index] = clampf(float(saved_cells[index]), 0.0, capacity)
	return true
