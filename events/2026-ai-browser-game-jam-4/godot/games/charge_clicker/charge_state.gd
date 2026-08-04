class_name ChargePrototypeState
extends RefCounted

# PROJECT CHARGE v4
# Every manual input deals damage immediately and produces spendable CHARGE.
# AUTO fire is online from the first second. Enemy rules only create bonus
# windows; they never erase progress, drain resources, or stop base damage.

const BOSS_MAX_HP := 6200.0
const MAX_SKILL_RANK := 25
const RESTORE_GOAL := 1.0

enum StagePhase { RESTORE, BOSS, REWARD, CLEAR }

const UPGRADE_DEFINITIONS := [
	{"id": "impact_coil", "base_cost": 10.0, "growth": 1.54},
	{"id": "combo_gear", "base_cost": 22.0, "growth": 1.57},
	{"id": "critical_math", "base_cost": 38.0, "growth": 1.60},
	{"id": "auto_cannon", "base_cost": 14.0, "growth": 1.54},
	{"id": "rapid_relay", "base_cost": 28.0, "growth": 1.57},
	{"id": "drone_bay", "base_cost": 58.0, "growth": 1.61},
	{"id": "charge_generator", "base_cost": 20.0, "growth": 1.56},
	{"id": "core_resonance", "base_cost": 52.0, "growth": 1.61},
]

var credits := 0
var lifetime_charge := 0
var elapsed := 0.0
var stage_elapsed := 0.0
var stage_clear_time := -1.0

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

var manual_inputs := 0
var auto_hits := 0
var critical_hits := 0
var purchases := 0
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
	manual_inputs = 0
	auto_hits = 0
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
	reset_encounter()

func begin_campaign_boss(boss_id: String, hp: float, is_enhanced: bool = false, is_singularity: bool = false) -> void:
	current_stage_id = ""
	current_build_tag = "all" if is_singularity else "boss"
	current_boss_id = boss_id
	boss_max_hp = maxf(100.0, hp)
	enhanced_boss = is_enhanced
	singularity_boss = is_singularity
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

func refresh_stats() -> void:
	var impact_level := upgrade_level("impact_coil")
	var auto_level := upgrade_level("auto_cannon")
	var rapid_level := upgrade_level("rapid_relay")
	var drone_level := upgrade_level("drone_bay")
	var charge_level := upgrade_level("charge_generator")
	var resonance_level := upgrade_level("core_resonance")
	manual_damage = pow(1.48, impact_level) * (1.0 + floorf(float(impact_level) / 5.0) * 0.35)
	auto_damage = 0.75 * pow(1.43, auto_level) * (1.0 + float(drone_level) * 0.08)
	auto_interval = maxf(0.09, 1.0 / (1.0 + float(rapid_level) * 0.14))
	drone_count = 1 + int(drone_level / 4)
	if "swarm_clock" in beast_cores:
		drone_count += 1
	charge_per_click = pow(1.18, charge_level)
	auto_charge_per_shot = 0.22 * pow(1.12, charge_level)
	critical_chance = minf(0.58, 0.04 + float(upgrade_level("critical_math")) * 0.025)
	critical_multiplier = 2.0 + floorf(float(upgrade_level("critical_math")) / 5.0) * 0.25
	combo_bonus_per_stack = 0.025 + float(upgrade_level("combo_gear")) * 0.006
	combo_cap = 10 + upgrade_level("combo_gear") * 2
	core_power = 1.0 + float(resonance_level) * 0.12

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
	return maxi(1, int(round(float(definition.base_cost) * pow(float(definition.growth), level))))

func skill_unlocked(id: String) -> bool:
	return not upgrade_definition(id).is_empty()

func can_purchase(id: String) -> bool:
	return upgrade_level(id) < MAX_SKILL_RANK and credits >= upgrade_cost(id)

func purchase_upgrade(id: String) -> bool:
	if not can_purchase(id):
		return false
	credits -= upgrade_cost(id)
	upgrade_levels[id] = upgrade_level(id) + 1
	purchases += 1
	if first_purchase_time < 0.0:
		first_purchase_time = elapsed
	var duration := 5.0 * core_power
	if current_stage_id == "pyre_wyrm" or "redheat_conversion" in beast_cores:
		overdrive_timer = maxf(overdrive_timer, duration)
		last_mechanic_event = "upgrade_overdrive"
	if "furnace_sovereign" in boss_cores:
		overdrive_timer = maxf(overdrive_timer, duration + 3.0)
	refresh_stats()
	return true

func skill_points_bought() -> int:
	var total := 0
	for definition in UPGRADE_DEFINITIONS:
		total += upgrade_level(str(definition.id))
	return total

func respec_skills() -> int:
	var refunded := 0
	for definition in UPGRADE_DEFINITIONS:
		var id := str(definition.id)
		var old_level := upgrade_level(id)
		for rank in range(old_level):
			refunded += maxi(1, int(round(float(definition.base_cost) * pow(float(definition.growth), rank))))
		upgrade_levels[id] = 0
	credits += refunded
	refresh_stats()
	return refunded

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

func manual_attack(critical_mode: int = -1) -> Dictionary:
	if stage_phase != StagePhase.BOSS:
		return {"valid": false, "damage": 0.0, "charge": 0, "critical": false, "boss_defeated": false}
	manual_inputs += 1
	manual_streak = mini(combo_cap, manual_streak + 1) if combo_timer > 0.0 else 1
	combo_timer = 0.7
	var forced_analysis := "phase_computation" in beast_cores and analysis >= 100.0
	var is_critical := critical_mode == 1 or forced_analysis or (critical_mode < 0 and rng.randf() < effective_critical_chance("manual"))
	if is_critical:
		critical_hits += 1
		if forced_analysis:
			analysis = 0.0
	else:
		analysis = minf(100.0, analysis + 6.0 * core_power)
	var combo_multiplier := 1.0 + float(maxi(0, manual_streak - 1)) * combo_bonus_per_stack
	var damage := manual_damage * combo_multiplier * (critical_multiplier if is_critical else 1.0)
	var modified := modify_attack("manual", damage, is_critical)
	damage = float(modified.damage)
	var shockwave := 0.0
	if "impact_guidance" in beast_cores and manual_inputs % 10 == 0:
		shockwave = manual_damage * 4.0 * core_power
		last_mechanic_event = "impact_shockwave"
	var echo := 0.0
	if "cascade_relay" in beast_cores and rng.randf() < minf(0.5, 0.16 * core_power):
		echo = damage * 0.55 * core_power
		last_mechanic_event = "relay_echo"
	var earned := grant_charge(charge_per_click)
	var applied := deal_damage(damage + shockwave + echo)
	if "predation_reversal" in boss_cores:
		earned += grant_charge(applied * 0.0025 * core_power)
	var burst := trigger_singularity_burst("manual")
	return {
		"valid": true,
		"damage": applied + burst,
		"base_damage": damage,
		"shockwave": shockwave,
		"echo": echo,
		"charge": earned,
		"critical": is_critical,
		"mechanic": last_mechanic_event,
		"boss_defeated": stage_phase == StagePhase.CLEAR,
	}

func manual_charge(critical_mode: int = -1) -> Dictionary:
	return manual_attack(critical_mode)

func auto_attack(critical_mode: int = -1) -> Dictionary:
	if stage_phase != StagePhase.BOSS:
		return {"valid": false, "damage": 0.0, "charge": 0, "critical": false, "boss_defeated": false}
	auto_hits += 1
	var is_critical := critical_mode == 1 or (critical_mode < 0 and rng.randf() < effective_critical_chance("auto") * 0.55)
	if is_critical:
		critical_hits += 1
	else:
		analysis = minf(100.0, analysis + 1.5 * float(drone_count) * core_power)
	var damage := auto_damage * float(drone_count) * (critical_multiplier if is_critical else 1.0)
	var modified := modify_attack("auto", damage, is_critical)
	damage = float(modified.damage)
	var echo := 0.0
	if "cascade_relay" in beast_cores and rng.randf() < minf(0.5, 0.12 * core_power):
		echo = damage * 0.45 * core_power
		last_mechanic_event = "relay_echo"
	var earned := grant_charge(auto_charge_per_shot * float(drone_count))
	var applied := deal_damage(damage + echo)
	if "predation_reversal" in boss_cores:
		earned += grant_charge(applied * 0.0025 * core_power)
	var burst := trigger_singularity_burst("auto")
	return {
		"valid": true,
		"damage": applied + burst,
		"echo": echo,
		"charge": earned,
		"critical": is_critical,
		"mechanic": last_mechanic_event,
		"boss_defeated": stage_phase == StagePhase.CLEAR,
	}

func modify_attack(source: String, damage: float, is_critical: bool) -> Dictionary:
	var multiplier := 1.0
	last_mechanic_event = ""
	if overdrive_timer > 0.0:
		multiplier *= 1.75
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
	last_damage_multiplier = multiplier
	return {"damage": damage * multiplier, "multiplier": multiplier}

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
				if singularity_progress >= 10:
					singularity_progress = 0
					singularity_seal = mini(6, singularity_seal + 1)
					last_mechanic_event = "seal_break"
				return 1.6
			return 1.0
		2:
			var success := source == "manual" if singularity_rule == 0 else source == "auto" if singularity_rule == 1 else is_critical if singularity_rule == 2 else manual_streak >= 6
			return 1.65 if success else 1.0
		3:
			enemy_charge = minf(100.0, enemy_charge + (2.2 if source == "manual" else 1.1 * float(drone_count)))
			return 1.15
	return 1.0

func trigger_singularity_burst(_source: String) -> float:
	if not singularity_boss or singularity_phase != 3 or enemy_charge < 100.0 or stage_phase != StagePhase.BOSS:
		return 0.0
	enemy_charge = 0.0
	var burst := boss_max_hp * 0.035 * core_power
	last_mechanic_event = "singularity_burst"
	return deal_damage(burst)

func effective_critical_chance(source: String = "manual") -> float:
	var result := critical_chance
	if current_stage_id == "phase_mantis" and phase_index == 2:
		result += 0.28
	if "phase_computation" in beast_cores and analysis >= 100.0:
		return 1.0
	if source == "auto" and "swarm_clock" in beast_cores:
		result += 0.03 * core_power
	return clampf(result, 0.0, 0.82)

func grant_charge(amount: float) -> int:
	if amount <= 0.0:
		return 0
	charge_fraction += amount
	var whole := int(floorf(charge_fraction))
	if whole <= 0:
		return 0
	charge_fraction -= float(whole)
	credits += whole
	lifetime_charge += whole
	if current_stage_id == "vaultback":
		vault_charge_meter += float(whole)
		if vault_charge_meter >= 50.0:
			vault_charge_meter = fmod(vault_charge_meter, 50.0)
			shell_open_timer = 6.0
			last_mechanic_event = "shell_open"
	if "deep_storage" in beast_cores and lifetime_charge > 0 and lifetime_charge % 100 < whole:
		var bonus := maxi(1, int(round(20.0 * core_power)))
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
	shell_open_timer = maxf(0.0, shell_open_timer - delta)
	overdrive_timer = maxf(0.0, overdrive_timer - delta)
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
	var combo_average := 1.0 + float(mini(combo_cap, 8)) * combo_bonus_per_stack * 0.55
	return manual_damage * clicks_per_second * combo_average * (1.0 + critical_chance * (critical_multiplier - 1.0))

func estimated_auto_dps() -> float:
	return auto_damage * float(drone_count) / maxf(0.01, auto_interval) * (1.0 + critical_chance * 0.55 * (critical_multiplier - 1.0))

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
	var next_cost := upgrade_cost("impact_coil")
	return clampf(float(credits) / maxf(1.0, float(next_cost)), 0.0, 1.0)

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
		"version": 4,
		"credits": credits,
		"lifetime_charge": lifetime_charge,
		"elapsed": elapsed,
		"manual_inputs": manual_inputs,
		"auto_hits": auto_hits,
		"critical_hits": critical_hits,
		"purchases": purchases,
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
		"encounter_index": encounter_index,
		"charge_fraction": charge_fraction,
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
	if int(data.get("version", 0)) != 4:
		return false
	reset()
	credits = maxi(0, int(data.get("credits", 0)))
	lifetime_charge = maxi(0, int(data.get("lifetime_charge", credits)))
	elapsed = maxf(0.0, float(data.get("elapsed", 0.0)))
	manual_inputs = maxi(0, int(data.get("manual_inputs", 0)))
	auto_hits = maxi(0, int(data.get("auto_hits", 0)))
	critical_hits = maxi(0, int(data.get("critical_hits", 0)))
	purchases = maxi(0, int(data.get("purchases", 0)))
	lifetime_output = maxf(0.0, float(data.get("lifetime_output", 0.0)))
	highest_output = maxf(0.0, float(data.get("highest_output", 0.0)))
	first_purchase_time = float(data.get("first_purchase_time", -1.0))
	var saved_levels: Dictionary = data.get("upgrade_levels", {})
	for definition in UPGRADE_DEFINITIONS:
		var id := str(definition.id)
		upgrade_levels[id] = clampi(int(saved_levels.get(id, 0)), 0, MAX_SKILL_RANK)
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
	encounter_index = maxi(0, int(data.get("encounter_index", 0)))
	charge_fraction = clampf(float(data.get("charge_fraction", 0.0)), 0.0, 0.999)
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
	refresh_stats()
	return true
