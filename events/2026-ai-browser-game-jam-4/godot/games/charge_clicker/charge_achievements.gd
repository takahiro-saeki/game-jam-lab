class_name ChargeAchievementState
extends RefCounted

const GearCatalog = preload("res://games/charge_clicker/gear_catalog.gd")

# Infinite Mode deliberately has no exclusive achievements. It exists as a
# pressure-free workshop where a completed campaign can finish the standard
# skill collection.
const DEFINITIONS := [
	{"id":"first_core","name_ja":"最初の機核","name_en":"FIRST CORE","desc_ja":"機械魔獣を1体討伐する","desc_en":"Defeat one mechanical beast"},
	{"id":"normal_end","name_ja":"地上への帰路","name_en":"A WAY HOME","desc_ja":"通常エンディングへ到達する","desc_en":"Reach the normal ending"},
	{"id":"six_cores","name_ja":"六獣集積","name_en":"SIXFOLD CIRCUIT","desc_ja":"6体すべての機械魔獣を討伐する","desc_en":"Defeat all six mechanical beasts"},
	{"id":"dual_boss_cores","name_ja":"二主獣継承","name_en":"DUAL SOVEREIGN","desc_ja":"2つの通常ボス核を統合する","desc_en":"Integrate both normal boss cores"},
	{"id":"true_end","name_ja":"地核機神停止","name_en":"WORLD ENGINE HALTED","desc_ja":"真エンディングへ到達する","desc_en":"Reach the true ending"},
	{"id":"pure_command","name_ja":"零出力指令","name_en":"ZERO-OUTPUT COMMAND","desc_ja":"PURE COMMANDを恒久接続する","desc_en":"Permanently connect PURE COMMAND"},
	{"id":"hybrid_arsenal","name_ja":"二律背反砲身","name_en":"PARADOX BARREL","desc_ja":"ガトリングとレール砲を両方完成する","desc_en":"Complete both Gatling and Rail mutations"},
	{"id":"tier_three","name_ja":"真層技術","name_en":"TRUE-DEPTH TECH","desc_ja":"Tier IIIノードを初めて強化する","desc_en":"Purchase the first Tier III rank"},
	{"id":"gear_mastery","name_ja":"一機完全同調","name_en":"GEAR MASTERY","desc_ja":"いずれか1ギアを全ランク強化する","desc_en":"Max every rank in one gear"},
	{"id":"all_skills","name_ja":"完全機装","name_en":"COMPLETE ARSENAL","desc_ja":"5ギアの全スキルを最大強化する","desc_en":"Max every skill across all five gears"},
]

var unlocked_ids: Array[String] = []
var artwork_gallery_unlocked := false
var story_archive_ids: Array[String] = []

func reset_for_tests() -> void:
	unlocked_ids.clear()
	artwork_gallery_unlocked = false
	story_archive_ids.clear()

func archive_story_event(event_id: String) -> bool:
	if event_id.is_empty() or event_id in story_archive_ids:
		return false
	story_archive_ids.append(event_id)
	return true

func has_story_event(event_id: String) -> bool:
	return event_id in story_archive_ids

func evaluate(run, route) -> Array[Dictionary]:
	if route.final_boss_defeated:
		unlock_artwork_gallery()
	var newly_unlocked: Array[Dictionary] = []
	for definition in DEFINITIONS:
		var id := str(definition.id)
		if id in unlocked_ids or not condition_met(id, run, route):
			continue
		unlocked_ids.append(id)
		newly_unlocked.append(definition)
	return newly_unlocked

func condition_met(id: String, run, route) -> bool:
	match id:
		"first_core":
			return run.beast_cores.size() >= 1
		"normal_end":
			return route.normal_end_seen
		"six_cores":
			return run.beast_cores.size() >= 6
		"dual_boss_cores":
			return run.boss_cores.size() >= 2
		"true_end":
			return route.true_end_seen
		"pure_command":
			return run.generation_mode_unlocked()
		"hybrid_arsenal":
			return run.upgrade_level("gatling_protocol") > 0 and run.upgrade_level("rail_protocol") > 0
		"tier_three":
			for skill in GearCatalog.SKILLS:
				if int(skill.get("tier", 1)) == 3 and run.upgrade_level(str(skill.id)) > 0:
					return true
			return false
		"gear_mastery":
			for gear in GearCatalog.GEARS:
				if run.gear_level(str(gear.id)) >= GearCatalog.max_ranks_for_gear(str(gear.id)):
					return true
			return false
		"all_skills":
			return run.skill_points_bought() >= GearCatalog.total_max_ranks()
	return false

func is_unlocked(id: String) -> bool:
	return id in unlocked_ids

func unlocked_count() -> int:
	return unlocked_ids.size()

func unlock_artwork_gallery() -> bool:
	if artwork_gallery_unlocked:
		return false
	artwork_gallery_unlocked = true
	return true

func snapshot() -> Dictionary:
	return {
		"version": 2,
		"unlocked_ids": unlocked_ids.duplicate(),
		"artwork_gallery_unlocked": artwork_gallery_unlocked,
		"story_archive_ids": story_archive_ids.duplicate(),
	}

func restore_snapshot(data: Dictionary) -> bool:
	var version := int(data.get("version", 0))
	if version not in [1, 2]:
		return false
	unlocked_ids.clear()
	story_archive_ids.clear()
	artwork_gallery_unlocked = bool(data.get("artwork_gallery_unlocked", false))
	for value in data.get("unlocked_ids", []):
		var id := str(value)
		if definition(id).is_empty() or id in unlocked_ids:
			continue
		unlocked_ids.append(id)
	if version >= 2:
		for value in data.get("story_archive_ids", []):
			var event_id := str(value)
			if not event_id.is_empty() and event_id not in story_archive_ids:
				story_archive_ids.append(event_id)
	return true

func definition(id: String) -> Dictionary:
	for item in DEFINITIONS:
		if str(item.id) == id:
			return item
	return {}
