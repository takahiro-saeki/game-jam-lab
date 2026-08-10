extends SceneTree

const CampaignRoute = preload("res://games/charge_clicker/charge_route.gd")
const StageCatalog = preload("res://games/charge_clicker/stage_catalog.gd")
const StoryCatalog = preload("res://games/charge_clicker/story_catalog.gd")

var failures := 0
var route_cases := 0


func _init() -> void:
	print("\nVOLT NOMAD RELEASE AUDIT")
	audit_catalog_integrity()
	audit_every_hunt_order()
	audit_restore_guards()
	if failures > 0:
		push_error("%d release audit(s) failed." % failures)
		quit(1)
	else:
		print("PASS  %d complete route permutations and release invariants" % route_cases)
		quit(0)


func audit_catalog_integrity() -> void:
	check(StageCatalog.stage_ids().size() == 6, "six hunt encounters remain addressable")
	check(StageCatalog.boss_ids().size() == 2, "two selectable normal bosses remain addressable")
	check(StageCatalog.final_boss_ids().size() == 3, "three PRIME CURRENT forms remain addressable")
	check(StoryCatalog.validate().is_empty(), "all authored Japanese and English story fields validate")
	check(StoryCatalog.event_ids().size() == 33, "the release contains exactly thirty-three stable story memories")
	var required_story_ids: Array[String] = [
		"prologue.awakening", "milestone.first_core", "milestone.third_core", "milestone.six_cores",
		"ending.normal_signal", "arch.encounter", "arch.phase_2", "arch.phase_3", "arch.defeat",
		"ending.world_ascent", "prime.signal_answer", "prime.form_1", "prime.form_2", "prime.form_3",
		"prime.defeat", "prime.aftermath", "ending.true_dawn",
	]
	for stage_id in StageCatalog.stage_ids():
		required_story_ids.append("hunt.%s.encounter" % stage_id)
		required_story_ids.append("hunt.%s.defeat" % stage_id)
	for boss_id in StageCatalog.boss_ids():
		required_story_ids.append("boss.%s.encounter" % boss_id)
		required_story_ids.append("boss.%s.defeat" % boss_id)
	var missing_story: Array[String] = []
	for event_id in required_story_ids:
		if StoryCatalog.event(event_id).is_empty():
			missing_story.append(event_id)
	check(missing_story.is_empty(), "every route-owned story event resolves (%s)" % ", ".join(missing_story))
	var release_assets := [
		"res://assets/audio/project_charge/nomad_victory_signal.mp3",
		"res://assets/charge_clicker/pixellab/source/vfx/defeat-vfx-core-fracture-v12-a.png",
		"res://assets/charge_clicker/pixellab/source/vfx/defeat-vfx-voltage-halo-v12-b.png",
		"res://assets/charge_clicker/pixellab/source/vfx/defeat-vfx-machine-shards-v12-c.png",
	]
	var missing_assets: Array[String] = []
	for asset_path in release_assets:
		if not FileAccess.file_exists(asset_path):
			missing_assets.append(asset_path)
	check(missing_assets.is_empty(), "reviewed victory audio and defeat VFX are packaged (%s)" % ", ".join(missing_assets))


func audit_every_hunt_order() -> void:
	var stage_orders := permutations(StageCatalog.stage_ids())
	for order_value in stage_orders:
		var order: Array = order_value
		for first_boss_id in StageCatalog.boss_ids():
			route_cases += 1
			var route = CampaignRoute.new()
			for index in range(3):
				if not route.select_stage(str(order[index])) or not route.complete_current_stage("core_%s" % order[index]):
					fail_route(route_cases, order, first_boss_id, "opening hunt %d failed" % index)
					break
			if route.phase != CampaignRoute.RoutePhase.BOSS_SELECT:
				fail_route(route_cases, order, first_boss_id, "three hunts did not open boss select")
				continue
			if not route.choose_first_boss(first_boss_id) or not route.defeat_current_boss():
				fail_route(route_cases, order, first_boss_id, "normal boss route failed")
				continue
			if route.phase != CampaignRoute.RoutePhase.NORMAL_END or not route.continue_true_route():
				fail_route(route_cases, order, first_boss_id, "normal ending checkpoint failed")
				continue
			for index in range(3, 6):
				if not route.select_stage(str(order[index])) or not route.complete_current_stage("core_%s" % order[index]):
					fail_route(route_cases, order, first_boss_id, "deep hunt %d failed" % index)
					break
			var expected_second_boss := str(StageCatalog.boss_ids()[1]) if first_boss_id == str(StageCatalog.boss_ids()[0]) else str(StageCatalog.boss_ids()[0])
			if route.phase != CampaignRoute.RoutePhase.ENHANCED_BOSS or route.current_boss_id != expected_second_boss:
				fail_route(route_cases, order, first_boss_id, "unchosen boss was not restored as enhanced boss")
				continue
			if not route.defeat_current_boss() or route.phase != CampaignRoute.RoutePhase.SINGULARITY:
				fail_route(route_cases, order, first_boss_id, "enhanced boss did not open ARCH")
				continue
			if not route.defeat_current_boss() or route.phase != CampaignRoute.RoutePhase.POST_TRUE_CHOICE:
				fail_route(route_cases, order, first_boss_id, "ARCH did not restore the ending choice")
				continue
			if not route.choose_world_engine_credits() or route.phase != CampaignRoute.RoutePhase.POST_TRUE_CHOICE:
				fail_route(route_cases, order, first_boss_id, "credits choice did not preserve the PRIME checkpoint")
				continue
			if not route.answer_deep_signal():
				fail_route(route_cases, order, first_boss_id, "deep signal could not launch PRIME")
				continue
			for expected_form in [2, 3]:
				if not route.defeat_current_boss() or route.final_boss_form != expected_form:
					fail_route(route_cases, order, first_boss_id, "PRIME form %d transition failed" % (expected_form - 1))
					break
			if not route.defeat_current_boss() or route.phase != CampaignRoute.RoutePhase.FINAL_END or not route.final_boss_defeated:
				fail_route(route_cases, order, first_boss_id, "PRIME form three did not reach true credits")
				continue
			if not route.complete_final_credits() or route.phase != CampaignRoute.RoutePhase.POSTGAME:
				fail_route(route_cases, order, first_boss_id, "true credits did not reach postgame")
				continue
			var restored = CampaignRoute.new()
			if not restored.restore_snapshot(route.snapshot()) or restored.snapshot() != route.snapshot():
				fail_route(route_cases, order, first_boss_id, "complete-clear snapshot did not round-trip")


func audit_restore_guards() -> void:
	var invalid_stage = CampaignRoute.new()
	check(invalid_stage.restore_snapshot({"version": 6, "phase": CampaignRoute.RoutePhase.STAGE, "current_stage_id": "missing"}) and invalid_stage.phase == CampaignRoute.RoutePhase.MAP, "invalid active hunt saves recover to the map")
	var invalid_boss = CampaignRoute.new()
	check(invalid_boss.restore_snapshot({"version": 6, "phase": CampaignRoute.RoutePhase.FINAL_BOSS, "current_boss_id": "missing", "normal_end_seen": true}) and invalid_boss.phase == CampaignRoute.RoutePhase.TRUE_MAP, "invalid active boss saves recover to the true map")
	var invalid_infinite = CampaignRoute.new()
	check(invalid_infinite.restore_snapshot({"version": 6, "phase": CampaignRoute.RoutePhase.INFINITE, "infinite_wave": 99}) and invalid_infinite.phase == CampaignRoute.RoutePhase.MAP, "Infinite Mode cannot be restored before ARCH is defeated")


func permutations(values: Array[String]) -> Array:
	if values.is_empty():
		return [[]]
	var result: Array = []
	for index in range(values.size()):
		var remaining := values.duplicate()
		var head: String = str(remaining.pop_at(index))
		for tail_value in permutations(remaining):
			var next: Array = [head]
			next.append_array(tail_value)
			result.append(next)
	return result


func fail_route(case_id: int, order: Array, first_boss_id: String, reason: String) -> void:
	failures += 1
	push_error("ROUTE %d [%s] first=%s: %s" % [case_id, ",".join(order), first_boss_id, reason])


func check(condition: bool, label: String) -> void:
	if condition:
		print("PASS  ", label)
	else:
		failures += 1
		push_error("FAIL  " + label)
