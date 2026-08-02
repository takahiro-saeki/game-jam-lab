class_name ChargeCampaignRoute
extends RefCounted

const Catalog = preload("res://games/charge_clicker/stage_catalog.gd")
const NORMAL_STAGE_REQUIREMENT := 3

enum RoutePhase {
	MAP,
	STAGE,
	BOSS_SELECT,
	BOSS,
	NORMAL_END,
	TRUE_MAP,
	ENHANCED_BOSS,
	SINGULARITY,
	TRUE_END,
}

var phase := RoutePhase.MAP
var current_stage_id := ""
var current_boss_id := ""
var completed_stage_ids: Array[String] = []
var stage_rewards: Dictionary = {}
var defeated_boss_ids: Array[String] = []
var first_boss_id := ""
var normal_end_seen := false
var true_end_seen := false

func reset() -> void:
	phase = RoutePhase.MAP
	current_stage_id = ""
	current_boss_id = ""
	completed_stage_ids.clear()
	stage_rewards.clear()
	defeated_boss_ids.clear()
	first_boss_id = ""
	normal_end_seen = false
	true_end_seen = false

func available_stage_ids() -> Array[String]:
	var result: Array[String] = []
	for id in Catalog.stage_ids():
		if id not in completed_stage_ids:
			result.append(id)
	return result

func select_stage(id: String) -> bool:
	if phase not in [RoutePhase.MAP, RoutePhase.TRUE_MAP]:
		return false
	if id not in Catalog.stage_ids() or id in completed_stage_ids:
		return false
	current_stage_id = id
	phase = RoutePhase.STAGE
	return true

func complete_current_stage(reward_id: String = "") -> bool:
	if phase != RoutePhase.STAGE or current_stage_id.is_empty():
		return false
	if current_stage_id not in completed_stage_ids:
		completed_stage_ids.append(current_stage_id)
	stage_rewards[current_stage_id] = reward_id
	current_stage_id = ""
	advance_after_stage()
	return true

func adopt_vertical_slice(reward_id: String) -> bool:
	if not completed_stage_ids.is_empty() or phase != RoutePhase.MAP:
		return false
	if not select_stage("generator_core"):
		return false
	return complete_current_stage(reward_id)

func advance_after_stage() -> void:
	if completed_stage_ids.size() == NORMAL_STAGE_REQUIREMENT and defeated_boss_ids.is_empty():
		phase = RoutePhase.BOSS_SELECT
		return
	if completed_stage_ids.size() >= Catalog.STAGES.size():
		prepare_post_stage_boss()
		return
	phase = RoutePhase.TRUE_MAP if normal_end_seen else RoutePhase.MAP

func choose_first_boss(id: String) -> bool:
	if phase != RoutePhase.BOSS_SELECT or id not in Catalog.boss_ids():
		return false
	first_boss_id = id
	current_boss_id = id
	phase = RoutePhase.BOSS
	return true

func defeat_current_boss() -> bool:
	if phase not in [RoutePhase.BOSS, RoutePhase.ENHANCED_BOSS, RoutePhase.SINGULARITY]:
		return false
	if current_boss_id.is_empty():
		return false
	if current_boss_id == str(Catalog.TRUE_BOSS.id):
		true_end_seen = true
		phase = RoutePhase.TRUE_END
		current_boss_id = ""
		return true
	if current_boss_id not in Catalog.boss_ids():
		return false
	if current_boss_id not in defeated_boss_ids:
		defeated_boss_ids.append(current_boss_id)
	current_boss_id = ""
	if not normal_end_seen:
		normal_end_seen = true
		phase = RoutePhase.NORMAL_END
	elif completed_stage_ids.size() >= Catalog.STAGES.size() and defeated_boss_ids.size() >= Catalog.BOSSES.size():
		prepare_singularity()
	else:
		phase = RoutePhase.TRUE_MAP
	return true

func continue_true_route() -> bool:
	if phase != RoutePhase.NORMAL_END or not normal_end_seen:
		return false
	phase = RoutePhase.TRUE_MAP
	return true

func prepare_post_stage_boss() -> void:
	for id in Catalog.boss_ids():
		if id not in defeated_boss_ids:
			current_boss_id = id
			phase = RoutePhase.ENHANCED_BOSS
			return
	prepare_singularity()

func prepare_singularity() -> void:
	current_boss_id = str(Catalog.TRUE_BOSS.id)
	phase = RoutePhase.SINGULARITY

func normal_route_ready() -> bool:
	return completed_stage_ids.size() >= NORMAL_STAGE_REQUIREMENT

func true_route_ready() -> bool:
	return completed_stage_ids.size() == Catalog.STAGES.size() and defeated_boss_ids.size() == Catalog.BOSSES.size()

func snapshot() -> Dictionary:
	return {
		"version": 1,
		"phase": phase,
		"current_stage_id": current_stage_id,
		"current_boss_id": current_boss_id,
		"completed_stage_ids": completed_stage_ids.duplicate(),
		"stage_rewards": stage_rewards.duplicate(true),
		"defeated_boss_ids": defeated_boss_ids.duplicate(),
		"first_boss_id": first_boss_id,
		"normal_end_seen": normal_end_seen,
		"true_end_seen": true_end_seen,
	}

func restore_snapshot(data: Dictionary) -> bool:
	if int(data.get("version", 0)) != 1:
		return false
	reset()
	var valid_stages := Catalog.stage_ids()
	for value in data.get("completed_stage_ids", []):
		var id := str(value)
		if id in valid_stages and id not in completed_stage_ids:
			completed_stage_ids.append(id)
	var saved_rewards: Dictionary = data.get("stage_rewards", {})
	for id in completed_stage_ids:
		stage_rewards[id] = str(saved_rewards.get(id, ""))
	var valid_bosses := Catalog.boss_ids()
	for value in data.get("defeated_boss_ids", []):
		var id := str(value)
		if id in valid_bosses and id not in defeated_boss_ids:
			defeated_boss_ids.append(id)
	first_boss_id = str(data.get("first_boss_id", ""))
	if first_boss_id not in valid_bosses:
		first_boss_id = ""
	current_stage_id = str(data.get("current_stage_id", ""))
	if current_stage_id not in valid_stages or current_stage_id in completed_stage_ids:
		current_stage_id = ""
	current_boss_id = str(data.get("current_boss_id", ""))
	if current_boss_id not in valid_bosses and current_boss_id != str(Catalog.TRUE_BOSS.id):
		current_boss_id = ""
	normal_end_seen = bool(data.get("normal_end_seen", false))
	true_end_seen = bool(data.get("true_end_seen", false))
	phase = clampi(int(data.get("phase", RoutePhase.MAP)), RoutePhase.MAP, RoutePhase.TRUE_END)
	if phase == RoutePhase.STAGE and current_stage_id.is_empty():
		phase = RoutePhase.TRUE_MAP if normal_end_seen else RoutePhase.MAP
	if phase in [RoutePhase.BOSS, RoutePhase.ENHANCED_BOSS, RoutePhase.SINGULARITY] and current_boss_id.is_empty():
		phase = RoutePhase.TRUE_MAP if normal_end_seen else RoutePhase.BOSS_SELECT
	return true
