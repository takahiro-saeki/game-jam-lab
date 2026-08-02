class_name ChargePrototypeState
extends RefCounted

const CELL_COUNT := 6
const MAX_HEAT := 100.0
const MAX_OVERCHARGE := 100.0
const RESTORE_GOAL := 45000.0
const BOSS_MAX_HP := 70000.0

enum StagePhase { RESTORE, BOSS, REWARD, CLEAR }

const UPGRADE_DEFINITIONS := [
	{"id": "manual", "base_cost": 12, "growth": 1.55},
	{"id": "capacity", "base_cost": 14, "growth": 1.58},
	{"id": "auto", "base_cost": 12, "growth": 1.62},
	{"id": "cooling", "base_cost": 14, "growth": 1.6},
	{"id": "discharge", "base_cost": 16, "growth": 1.65},
	{"id": "critical", "base_cost": 18, "growth": 1.68},
	{"id": "insulation", "base_cost": 20, "growth": 1.72},
	{"id": "surge", "base_cost": 22, "growth": 1.75},
]

var cells: Array[float] = []
var capacity := 55.0
var manual_power := 11.0
var auto_rate := 6.0
var cooling_rate := 8.5
var discharge_multiplier := 1.0
var critical_chance := 0.06
var heat_generation := 1.0
var full_discharge_bonus := 0.8
var meltdown_retention := 0.12

var credits := 0
var heat := 0.0
var overcharge := 0.0
var auto_enabled := false
var elapsed := 0.0
var auto_buffer := 0.0
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

var stage_phase := StagePhase.RESTORE
var restore_progress := 0.0
var boss_hp := BOSS_MAX_HP
var boss_attack_timer := 9.0
var boss_drains := 0
var boss_interrupts := 0
var stage_clear_time := -1.0
var reward_id := ""

func _init() -> void:
	rng.randomize()
	reset()

func reset() -> void:
	cells.clear()
	for index in range(CELL_COUNT):
		cells.append(0.0)
	capacity = 55.0
	manual_power = 11.0
	auto_rate = 6.0
	cooling_rate = 8.5
	discharge_multiplier = 1.0
	critical_chance = 0.06
	heat_generation = 1.0
	full_discharge_bonus = 0.8
	meltdown_retention = 0.12
	credits = 0
	heat = 0.0
	overcharge = 0.0
	auto_enabled = false
	elapsed = 0.0
	auto_buffer = 0.0
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
	stage_phase = StagePhase.RESTORE
	restore_progress = 0.0
	boss_hp = BOSS_MAX_HP
	boss_attack_timer = 9.0
	boss_drains = 0
	boss_interrupts = 0
	stage_clear_time = -1.0
	reward_id = ""
	upgrade_levels.clear()
	for definition in UPGRADE_DEFINITIONS:
		upgrade_levels[str(definition.id)] = 0

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
	manual_streak = mini(12, manual_streak + 1)
	var is_critical := critical_mode == 1 or (critical_mode < 0 and rng.randf() < critical_chance)
	if is_critical:
		critical_hits += 1
	var streak_multiplier := 1.0 + float(manual_streak - 1) * 0.018
	var amount := manual_power * streak_multiplier * (2.0 if is_critical else 1.0)
	var result := add_charge_energy(amount, 2.7 * heat_generation, true)
	result.critical = is_critical
	result.input_amount = amount
	if heat >= MAX_HEAT:
		result.meltdown = true
		result.lost = trigger_meltdown()
	else:
		result.meltdown = false
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
	heat = minf(MAX_HEAT, heat + maxf(0.0, heat_gain))
	return {
		"added": added,
		"overflow": remaining,
		"became_full": not was_full and is_full(),
		"is_full": is_full(),
	}

func tick(delta: float, manual_held: bool = false) -> Dictionary:
	if stage_phase not in [StagePhase.REWARD, StagePhase.CLEAR]:
		elapsed += delta
	var cooling_multiplier := 0.15 if manual_held else 1.0
	heat = maxf(0.0, heat - cooling_rate * cooling_multiplier * delta)
	var auto_added := 0.0
	var became_full := false
	if auto_enabled and not is_full() and stage_phase not in [StagePhase.REWARD, StagePhase.CLEAR]:
		auto_buffer += auto_rate * delta
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
		"auto_added": auto_added,
		"became_full": became_full,
		"meltdown": did_meltdown,
		"lost": lost,
		"boss_warning": bool(stage_result.boss_warning),
		"boss_drain": bool(stage_result.boss_drain),
		"drain_cell": int(stage_result.drain_cell),
		"drained": float(stage_result.drained),
		"boss_healed": float(stage_result.boss_healed),
	}

func tick_stage(delta: float) -> Dictionary:
	var result := {"boss_warning": false, "boss_drain": false, "drain_cell": -1, "drained": 0.0, "boss_healed": 0.0}
	if stage_phase != StagePhase.BOSS:
		return result
	var previous_timer := boss_attack_timer
	boss_attack_timer -= delta
	if previous_timer > 2.0 and boss_attack_timer <= 2.0:
		result.boss_warning = true
	if boss_attack_timer > 0.0:
		return result
	var index := most_charged_cell()
	var drained := 0.0
	if index >= 0:
		drained = cells[index] * 0.38
		cells[index] = maxf(0.0, cells[index] - drained)
	var healed := drained * 0.24
	boss_hp = minf(BOSS_MAX_HP, boss_hp + healed)
	heat = minf(MAX_HEAT, heat + 8.0 * heat_generation)
	boss_drains += 1
	boss_attack_timer = maxf(5.8, 8.6 - float(boss_drains) * 0.22)
	result.boss_drain = true
	result.drain_cell = index
	result.drained = drained
	result.boss_healed = healed
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
	return stage_phase == StagePhase.BOSS and boss_attack_timer <= 2.0

func apply_output(output: float, was_super: bool) -> Dictionary:
	var result := {
		"phase_changed": false,
		"boss_started": false,
		"boss_defeated": false,
		"interrupt": false,
		"applied": 0.0,
	}
	if stage_phase == StagePhase.RESTORE:
		var restored := output * (1.08 if was_super else 1.0)
		restore_progress = minf(RESTORE_GOAL, restore_progress + restored)
		result.applied = restored
		if restore_progress >= RESTORE_GOAL:
			stage_phase = StagePhase.BOSS
			boss_hp = BOSS_MAX_HP
			boss_attack_timer = 8.0
			result.phase_changed = true
			result.boss_started = true
	elif stage_phase == StagePhase.BOSS:
		var damage := output
		if boss_warning_active() and was_super:
			damage *= 1.35
			boss_attack_timer = 8.6
			boss_interrupts += 1
			result.interrupt = true
		boss_hp = maxf(0.0, boss_hp - damage)
		result.applied = damage
		if boss_hp <= 0.0:
			stage_phase = StagePhase.REWARD
			stage_clear_time = elapsed
			result.phase_changed = true
			result.boss_defeated = true
	return result

func objective_ratio() -> float:
	if stage_phase == StagePhase.RESTORE:
		return restore_progress / RESTORE_GOAL
	if stage_phase == StagePhase.BOSS:
		return 1.0 - boss_hp / BOSS_MAX_HP
	return 1.0

func select_reward(id: String) -> bool:
	if stage_phase != StagePhase.REWARD or id not in ["flywheel", "coolant", "relay"]:
		return false
	reward_id = id
	match id:
		"flywheel":
			manual_power *= 1.15
			full_discharge_bonus += 0.12
		"coolant":
			cooling_rate *= 1.25
			heat_generation *= 0.88
		"relay":
			auto_rate *= 1.35
			discharge_multiplier *= 1.06
	credits += 45
	stage_phase = StagePhase.CLEAR
	return true

func discharge(critical_mode: int = -1) -> Dictionary:
	var stored := total_charge()
	if stored < 0.5:
		return {"valid": false, "output": 0.0, "credits": 0, "super": false, "critical": false}
	var was_full := is_full()
	var is_critical := critical_mode == 1 or (critical_mode < 0 and rng.randf() < critical_chance * 0.65)
	if is_critical:
		critical_hits += 1
	var full_multiplier := 1.0 + full_discharge_bonus if was_full else 1.0
	var overcharge_multiplier := 1.0 + overcharge * 0.01
	var heat_multiplier := 1.0 + maxf(0.0, heat - 50.0) * 0.004
	var critical_multiplier := 1.75 if is_critical else 1.0
	var output := stored * discharge_multiplier * full_multiplier * overcharge_multiplier * heat_multiplier * critical_multiplier
	var earned := maxi(1, int(round(output / 28.0)))
	credits += earned
	lifetime_output += output
	highest_output = maxf(highest_output, output)
	if was_full:
		super_discharges += 1
	else:
		partial_discharges += 1
	clear_cells()
	heat = maxf(0.0, heat - 18.0)
	overcharge = 0.0
	manual_streak = 0
	return {"valid": true, "output": output, "credits": earned, "super": was_full, "critical": is_critical}

func clear_cells() -> void:
	for index in range(cells.size()):
		cells[index] = 0.0

func trigger_meltdown() -> float:
	var before := total_charge()
	for index in range(cells.size()):
		cells[index] *= meltdown_retention
	var lost := before - total_charge()
	heat = 34.0
	overcharge = 0.0
	manual_streak = 0
	meltdowns += 1
	return lost

func toggle_auto() -> bool:
	auto_enabled = not auto_enabled
	return auto_enabled

func upgrade_level(id: String) -> int:
	return int(upgrade_levels.get(id, 0))

func upgrade_cost(id: String) -> int:
	for definition in UPGRADE_DEFINITIONS:
		if str(definition.id) == id:
			return int(round(float(definition.base_cost) * pow(float(definition.growth), upgrade_level(id))))
	return 999999

func can_purchase(id: String) -> bool:
	return credits >= upgrade_cost(id)

func purchase_upgrade(id: String) -> bool:
	var cost := upgrade_cost(id)
	if credits < cost or not upgrade_levels.has(id):
		return false
	credits -= cost
	upgrade_levels[id] = upgrade_level(id) + 1
	purchases += 1
	if first_purchase_time < 0.0:
		first_purchase_time = elapsed
	match id:
		"manual":
			manual_power += 3.5
		"capacity":
			capacity += 9.0
			for index in range(cells.size()):
				cells[index] = minf(cells[index], capacity)
		"auto":
			auto_rate += 3.5
		"cooling":
			cooling_rate += 2.3
		"discharge":
			discharge_multiplier += 0.18
		"critical":
			critical_chance = minf(0.55, critical_chance + 0.045)
		"insulation":
			heat_generation = maxf(0.38, heat_generation * 0.88)
			meltdown_retention = minf(0.65, meltdown_retention + 0.07)
		"surge":
			full_discharge_bonus += 0.18
	return true

func snapshot() -> Dictionary:
	return {
		"version": 1,
		"cells": cells.duplicate(),
		"capacity": capacity,
		"manual_power": manual_power,
		"auto_rate": auto_rate,
		"cooling_rate": cooling_rate,
		"discharge_multiplier": discharge_multiplier,
		"critical_chance": critical_chance,
		"heat_generation": heat_generation,
		"full_discharge_bonus": full_discharge_bonus,
		"meltdown_retention": meltdown_retention,
		"credits": credits,
		"heat": heat,
		"overcharge": overcharge,
		"auto_enabled": auto_enabled,
		"elapsed": elapsed,
		"manual_streak": manual_streak,
		"manual_inputs": manual_inputs,
		"partial_discharges": partial_discharges,
		"super_discharges": super_discharges,
		"meltdowns": meltdowns,
		"critical_hits": critical_hits,
		"purchases": purchases,
		"lifetime_output": lifetime_output,
		"highest_output": highest_output,
		"first_purchase_time": first_purchase_time,
		"upgrade_levels": upgrade_levels.duplicate(true),
		"stage_phase": stage_phase,
		"restore_progress": restore_progress,
		"boss_hp": boss_hp,
		"boss_attack_timer": boss_attack_timer,
		"boss_drains": boss_drains,
		"boss_interrupts": boss_interrupts,
		"stage_clear_time": stage_clear_time,
		"reward_id": reward_id,
	}

func restore_snapshot(data: Dictionary) -> bool:
	if int(data.get("version", 0)) != 1:
		return false
	reset()
	capacity = maxf(1.0, float(data.get("capacity", capacity)))
	manual_power = maxf(0.1, float(data.get("manual_power", manual_power)))
	auto_rate = maxf(0.0, float(data.get("auto_rate", auto_rate)))
	cooling_rate = maxf(0.0, float(data.get("cooling_rate", cooling_rate)))
	discharge_multiplier = maxf(0.1, float(data.get("discharge_multiplier", discharge_multiplier)))
	critical_chance = clampf(float(data.get("critical_chance", critical_chance)), 0.0, 1.0)
	heat_generation = maxf(0.1, float(data.get("heat_generation", heat_generation)))
	full_discharge_bonus = maxf(0.0, float(data.get("full_discharge_bonus", full_discharge_bonus)))
	meltdown_retention = clampf(float(data.get("meltdown_retention", meltdown_retention)), 0.0, 0.95)
	credits = maxi(0, int(data.get("credits", credits)))
	heat = clampf(float(data.get("heat", heat)), 0.0, MAX_HEAT)
	overcharge = clampf(float(data.get("overcharge", overcharge)), 0.0, MAX_OVERCHARGE)
	auto_enabled = bool(data.get("auto_enabled", auto_enabled))
	elapsed = maxf(0.0, float(data.get("elapsed", elapsed)))
	manual_streak = maxi(0, int(data.get("manual_streak", manual_streak)))
	manual_inputs = maxi(0, int(data.get("manual_inputs", manual_inputs)))
	partial_discharges = maxi(0, int(data.get("partial_discharges", partial_discharges)))
	super_discharges = maxi(0, int(data.get("super_discharges", super_discharges)))
	meltdowns = maxi(0, int(data.get("meltdowns", meltdowns)))
	critical_hits = maxi(0, int(data.get("critical_hits", critical_hits)))
	purchases = maxi(0, int(data.get("purchases", purchases)))
	lifetime_output = maxf(0.0, float(data.get("lifetime_output", lifetime_output)))
	highest_output = maxf(0.0, float(data.get("highest_output", highest_output)))
	first_purchase_time = float(data.get("first_purchase_time", first_purchase_time))
	var saved_levels: Dictionary = data.get("upgrade_levels", {})
	for definition in UPGRADE_DEFINITIONS:
		var id := str(definition.id)
		upgrade_levels[id] = maxi(0, int(saved_levels.get(id, 0)))
	stage_phase = clampi(int(data.get("stage_phase", stage_phase)), StagePhase.RESTORE, StagePhase.CLEAR)
	restore_progress = clampf(float(data.get("restore_progress", restore_progress)), 0.0, RESTORE_GOAL)
	boss_hp = clampf(float(data.get("boss_hp", boss_hp)), 0.0, BOSS_MAX_HP)
	boss_attack_timer = maxf(0.01, float(data.get("boss_attack_timer", boss_attack_timer)))
	boss_drains = maxi(0, int(data.get("boss_drains", boss_drains)))
	boss_interrupts = maxi(0, int(data.get("boss_interrupts", boss_interrupts)))
	stage_clear_time = float(data.get("stage_clear_time", stage_clear_time))
	reward_id = str(data.get("reward_id", reward_id))
	var saved_cells: Array = data.get("cells", [])
	if saved_cells.size() == CELL_COUNT:
		for index in range(CELL_COUNT):
			cells[index] = clampf(float(saved_cells[index]), 0.0, capacity)
	return true
