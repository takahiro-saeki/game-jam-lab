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
	INFINITE,
	POST_TRUE_CHOICE,
	FINAL_BOSS,
	FINAL_END,
	POSTGAME,
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
var world_engine_credits_seen := false
var deep_signal_answered := false
var final_boss_form := 0
var final_boss_defeated := false
var final_credits_seen := false
var infinite_wave := 0
var infinite_best_wave := 0
var story_event_ids: Array[String] = []

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
	world_engine_credits_seen = false
	deep_signal_answered = false
	final_boss_form = 0
	final_boss_defeated = false
	final_credits_seen = false
	infinite_wave = 0
	infinite_best_wave = 0
	story_event_ids.clear()

func has_seen_story_event(event_id: String) -> bool:
	return event_id in story_event_ids

func mark_story_event_seen(event_id: String) -> bool:
	if event_id.is_empty() or event_id in story_event_ids:
		return false
	story_event_ids.append(event_id)
	return true

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
	if not select_stage("gearmaw"):
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
	if phase not in [RoutePhase.BOSS, RoutePhase.ENHANCED_BOSS, RoutePhase.SINGULARITY, RoutePhase.FINAL_BOSS]:
		return false
	if current_boss_id.is_empty():
		return false
	if current_boss_id == str(Catalog.TRUE_BOSS.id):
		true_end_seen = true
		phase = RoutePhase.POST_TRUE_CHOICE
		current_boss_id = ""
		return true
	if current_boss_id in Catalog.final_boss_ids():
		if final_boss_form < Catalog.FINAL_BOSS_FORMS.size():
			final_boss_form += 1
			current_boss_id = str(Catalog.FINAL_BOSS_FORMS[final_boss_form - 1].id)
			phase = RoutePhase.FINAL_BOSS
		else:
			final_boss_defeated = true
			current_boss_id = ""
			phase = RoutePhase.FINAL_END
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

func start_infinite() -> bool:
	if phase not in [RoutePhase.POST_TRUE_CHOICE, RoutePhase.POSTGAME] or not true_end_seen:
		return false
	infinite_wave = maxi(1, infinite_wave)
	phase = RoutePhase.INFINITE
	return true

func complete_infinite_wave() -> bool:
	if phase != RoutePhase.INFINITE:
		return false
	infinite_best_wave = maxi(infinite_best_wave, infinite_wave)
	infinite_wave += 1
	return true

func leave_infinite() -> bool:
	if phase != RoutePhase.INFINITE or not true_end_seen:
		return false
	phase = RoutePhase.POSTGAME if final_boss_defeated else RoutePhase.POST_TRUE_CHOICE
	return true

func choose_world_engine_credits() -> bool:
	if phase != RoutePhase.POST_TRUE_CHOICE or not true_end_seen:
		return false
	world_engine_credits_seen = true
	return true

func answer_deep_signal() -> bool:
	if phase != RoutePhase.POST_TRUE_CHOICE or not true_end_seen:
		return false
	deep_signal_answered = true
	final_boss_form = 1
	current_boss_id = str(Catalog.FINAL_BOSS_FORMS[0].id)
	phase = RoutePhase.FINAL_BOSS
	return true

func complete_final_credits() -> bool:
	if phase != RoutePhase.FINAL_END or not final_boss_defeated:
		return false
	final_credits_seen = true
	phase = RoutePhase.POSTGAME
	return true

func snapshot() -> Dictionary:
	return {
		"version": 5,
		"phase": phase,
		"current_stage_id": current_stage_id,
		"current_boss_id": current_boss_id,
		"completed_stage_ids": completed_stage_ids.duplicate(),
		"stage_rewards": stage_rewards.duplicate(true),
		"defeated_boss_ids": defeated_boss_ids.duplicate(),
		"first_boss_id": first_boss_id,
		"normal_end_seen": normal_end_seen,
		"true_end_seen": true_end_seen,
		"world_engine_credits_seen": world_engine_credits_seen,
		"deep_signal_answered": deep_signal_answered,
		"final_boss_form": final_boss_form,
		"final_boss_defeated": final_boss_defeated,
		"final_credits_seen": final_credits_seen,
		"infinite_wave": infinite_wave,
		"infinite_best_wave": infinite_best_wave,
		"story_event_ids": story_event_ids.duplicate(),
	}

func restore_snapshot(data: Dictionary) -> bool:
	var version := int(data.get("version", 0))
	if version not in [2, 3, 4, 5]:
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
	if current_boss_id not in valid_bosses and current_boss_id != str(Catalog.TRUE_BOSS.id) and current_boss_id not in Catalog.final_boss_ids():
		current_boss_id = ""
	normal_end_seen = bool(data.get("normal_end_seen", false))
	true_end_seen = bool(data.get("true_end_seen", false))
	world_engine_credits_seen = bool(data.get("world_engine_credits_seen", false))
	deep_signal_answered = bool(data.get("deep_signal_answered", false))
	final_boss_form = clampi(int(data.get("final_boss_form", 0)), 0, Catalog.FINAL_BOSS_FORMS.size())
	final_boss_defeated = bool(data.get("final_boss_defeated", false))
	final_credits_seen = bool(data.get("final_credits_seen", false))
	infinite_wave = maxi(0, int(data.get("infinite_wave", 0)))
	infinite_best_wave = maxi(0, int(data.get("infinite_best_wave", 0)))
	for value in data.get("story_event_ids", []):
		var event_id := str(value)
		if not event_id.is_empty() and event_id not in story_event_ids:
			story_event_ids.append(event_id)
	phase = clampi(int(data.get("phase", RoutePhase.MAP)), RoutePhase.MAP, RoutePhase.POSTGAME)
	if version <= 3 and phase == RoutePhase.TRUE_END:
		phase = RoutePhase.POST_TRUE_CHOICE
	if phase == RoutePhase.STAGE and current_stage_id.is_empty():
		phase = RoutePhase.TRUE_MAP if normal_end_seen else RoutePhase.MAP
	if phase in [RoutePhase.BOSS, RoutePhase.ENHANCED_BOSS, RoutePhase.SINGULARITY, RoutePhase.FINAL_BOSS] and current_boss_id.is_empty():
		phase = RoutePhase.TRUE_MAP if normal_end_seen else RoutePhase.BOSS_SELECT
	if phase == RoutePhase.INFINITE and not true_end_seen:
		phase = RoutePhase.MAP
	return true
