extends SceneTree

const ChargeState = preload("res://games/charge_clicker/charge_state.gd")
const StageCatalog = preload("res://games/charge_clicker/stage_catalog.gd")
const OUTPUT_PATH := "res://tests/project_charge_benchmark.latest.json"

func _init() -> void:
	var profiles := [
		{"id": "efficient_5cps", "delta": 0.2, "purchase_interval": 1},
		{"id": "steady_2cps", "delta": 0.5, "purchase_interval": 2},
	]
	var results: Array[Dictionary] = []
	for profile in profiles:
		results.append(simulate_profile(profile, false))
		results.append(simulate_profile(profile, true))
	var payload := {
		"schema_version": 1,
		"build_id": ChargeState.BUILD_ID,
		"generated_at": Time.get_datetime_string_from_system(true),
		"seed": 144,
		"results": results,
	}
	var file := FileAccess.open(OUTPUT_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Could not write %s" % OUTPUT_PATH)
		quit(1)
		return
	file.store_string(JSON.stringify(payload, "  "))
	file.close()
	print(JSON.stringify(payload, "  "))
	quit(0)

func simulate_profile(profile: Dictionary, include_true_route: bool) -> Dictionary:
	var state := ChargeState.new()
	state.rng.seed = 144
	state.set_playtest_mode("benchmark")
	var stages: Array[String] = []
	if include_true_route:
		stages.assign(StageCatalog.stage_ids())
	else:
		stages.assign(["gearmaw", "vaultback", "pyre_wyrm"])
	for stage_index in range(stages.size()):
		var id := stages[stage_index]
		var definition := StageCatalog.stage(id)
		state.begin_stage(id, str(definition.build_tag), 1.0, StageCatalog.stage_hp(id, stage_index), stage_index)
		drive_encounter(state, profile)
		state.grant_beast_core(str(definition.core_id))
		if stage_index == 2:
			var first_boss := StageCatalog.boss("grid_leech")
			state.begin_campaign_boss("grid_leech", float(first_boss.hp), false, false)
			drive_encounter(state, profile)
			state.grant_boss_core(str(first_boss.core_id))
			if not include_true_route:
				return benchmark_result(state, profile, "normal")
	if include_true_route:
		var enhanced := StageCatalog.boss("thermal_titan")
		state.begin_campaign_boss("thermal_titan", float(enhanced.enhanced_hp), true, false)
		drive_encounter(state, profile)
		state.grant_boss_core(str(enhanced.core_id))
		var true_boss := StageCatalog.boss("arch_singularity")
		state.begin_campaign_boss("arch_singularity", float(true_boss.hp), false, true)
		drive_encounter(state, profile)
	return benchmark_result(state, profile, "true")

func drive_encounter(state, profile: Dictionary) -> void:
	var delta := float(profile.delta)
	var purchase_interval := maxi(1, int(profile.purchase_interval))
	for step in range(240000):
		if state.generation_mode_unlocked():
			state.manual_mode = "attack" if step % 4 == 0 else "generate"
		state.manual_attack(-1)
		state.advance_session_time(delta)
		state.tick(delta, false)
		if step % purchase_interval == 0:
			purchase_affordable_skills(state)
		if state.stage_phase == state.StagePhase.CLEAR:
			return
	push_error("Benchmark encounter did not clear: %s" % state.current_encounter_id())

func purchase_affordable_skills(state) -> void:
	for pass_index in range(4):
		var bought := false
		for definition in ChargeState.UPGRADE_DEFINITIONS:
			var id := str(definition.id)
			if state.can_purchase(id):
				state.purchase_upgrade(id)
				bought = true
		if not bought:
			return

func benchmark_result(state, profile: Dictionary, ending: String) -> Dictionary:
	return {
		"profile": str(profile.id),
		"ending": ending,
		"total_seconds": state.elapsed,
		"total_minutes": snappedf(state.elapsed / 60.0, 0.01),
		"encounters": state.encounter_history.duplicate(true),
		"upgrade_ranks": state.skill_points_bought(),
		"possible_ranks": state.total_possible_ranks(),
		"manual_inputs": state.manual_inputs,
		"auto_hits": state.auto_hits,
		"lifetime_charge": state.lifetime_charge,
		"highest_hit": state.highest_output,
	}
