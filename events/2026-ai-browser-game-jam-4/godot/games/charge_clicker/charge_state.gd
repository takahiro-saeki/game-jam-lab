class_name ChargePrototypeState
extends RefCounted

const CELL_COUNT := 6
const MAX_HEAT := 100.0
const MAX_OVERCHARGE := 100.0

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
	elapsed += delta
	var cooling_multiplier := 0.15 if manual_held else 1.0
	heat = maxf(0.0, heat - cooling_rate * cooling_multiplier * delta)
	var auto_added := 0.0
	var became_full := false
	if auto_enabled and not is_full():
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
	return {"auto_added": auto_added, "became_full": became_full, "meltdown": did_meltdown, "lost": lost}

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
