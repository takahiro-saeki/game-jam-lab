class_name ChargeStageCatalog
extends RefCounted

const STAGES := [
	{
		"id": "generator_core",
		"order": 1,
		"name_ja": "ジェネレーター・コア",
		"name_en": "GENERATOR CORE",
		"mechanic_ja": "手動入力・精密充電",
		"mechanic_en": "Manual input and precision charge",
		"build_tag": "manual",
		"reward_id": "flywheel",
		"accent": "4deeea",
		"target_seconds": 210.0,
		"climax_id": "grid_wraith",
	},
	{
		"id": "capacitor_vault",
		"order": 2,
		"name_ja": "キャパシター・ヴォルト",
		"name_en": "CAPACITOR VAULT",
		"mechanic_ja": "容量・大放電",
		"mechanic_en": "Capacity and burst discharge",
		"build_tag": "capacity",
		"reward_id": "deep_bank",
		"accent": "3a86ff",
		"target_seconds": 210.0,
		"climax_id": "vault_lock",
	},
	{
		"id": "thermal_plant",
		"order": 3,
		"name_ja": "サーマル・プラント",
		"name_en": "THERMAL PLANT",
		"mechanic_ja": "熱・冷却・過充電",
		"mechanic_en": "Heat, cooling and overcharge",
		"build_tag": "risk",
		"reward_id": "redline_loop",
		"accent": "ff5c5c",
		"target_seconds": 210.0,
		"climax_id": "thermal_runaway",
	},
	{
		"id": "relay_network",
		"order": 4,
		"name_ja": "リレー・ネットワーク",
		"name_en": "RELAY NETWORK",
		"mechanic_ja": "連鎖・コンボ",
		"mechanic_en": "Chains and combos",
		"build_tag": "chain",
		"reward_id": "cascade_bus",
		"accent": "9b5de5",
		"target_seconds": 210.0,
		"climax_id": "relay_storm",
	},
	{
		"id": "drone_array",
		"order": 5,
		"name_ja": "ドローン・アレイ",
		"name_en": "DRONE ARRAY",
		"mechanic_ja": "自動化・指令",
		"mechanic_en": "Automation and commands",
		"build_tag": "auto",
		"reward_id": "swarm_clock",
		"accent": "55efc4",
		"target_seconds": 210.0,
		"climax_id": "rogue_foreman",
	},
	{
		"id": "surge_lab",
		"order": 6,
		"name_ja": "サージ・ラボ",
		"name_en": "SURGE LAB",
		"mechanic_ja": "乱数・クリティカル・再抽選",
		"mechanic_en": "Variance, criticals and rerolls",
		"build_tag": "critical",
		"reward_id": "loaded_dice",
		"accent": "ffb703",
		"target_seconds": 210.0,
		"climax_id": "probability_break",
	},
]

const BOSSES := [
	{
		"id": "grid_leech",
		"name_ja": "グリッド・リーチ",
		"name_en": "GRID LEECH",
		"counter_tag": "manual",
		"rule_ja": "最大充電セルを予告吸収する",
		"rule_en": "Telegraphs a drain from the fullest cell",
		"accent": "4deeea",
	},
	{
		"id": "thermal_titan",
		"name_ja": "サーマル・タイタン",
		"name_en": "THERMAL TITAN",
		"counter_tag": "cooling",
		"rule_ja": "冷却効率を下げ、高熱時に弱点をさらす",
		"rule_en": "Suppresses cooling and exposes a weakness at high heat",
		"accent": "ff5c5c",
	},
]

const TRUE_BOSS := {
	"id": "charge_singularity",
	"name_ja": "チャージ・シンギュラリティ",
	"name_en": "CHARGE SINGULARITY",
	"counter_tag": "all",
	"rule_ja": "六つの回路ルールを三段階で試す",
	"rule_en": "Tests all six circuit rules across three phases",
	"accent": "f5f0db",
}

static func stage(id: String) -> Dictionary:
	for definition in STAGES:
		if str(definition.id) == id:
			return definition.duplicate(true)
	return {}

static func boss(id: String) -> Dictionary:
	for definition in BOSSES:
		if str(definition.id) == id:
			return definition.duplicate(true)
	if id == str(TRUE_BOSS.id):
		return TRUE_BOSS.duplicate(true)
	return {}

static func stage_ids() -> Array[String]:
	var ids: Array[String] = []
	for definition in STAGES:
		ids.append(str(definition.id))
	return ids

static func boss_ids() -> Array[String]:
	var ids: Array[String] = []
	for definition in BOSSES:
		ids.append(str(definition.id))
	return ids
