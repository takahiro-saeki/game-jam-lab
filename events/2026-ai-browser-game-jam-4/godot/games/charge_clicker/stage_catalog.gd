class_name ChargeStageCatalog
extends RefCounted

# PROJECT CHARGE v3 turns each circuit into a visible mechanical beast battle.
# The same six beasts can be tackled in any order; encounter order supplies the
# campaign-wide inflation while each definition supplies its own rule and core.
const STAGES := [
	{
		"id": "gearmaw",
		"order": 1,
		"name_ja": "鉄殻穿獣 ギアモウ",
		"name_en": "GEARMAW, IRON BORER",
		"mechanic_ja": "装甲亀裂・手動入力",
		"mechanic_en": "Armor cracks and manual input",
		"objective_ja": "手動入力で装甲を割り、亀裂が閉じる前に放電する",
		"objective_en": "Crack its plating manually, then discharge before it repairs",
		"build_tag": "manual",
		"core_id": "impact_guidance",
		"core_name_ja": "衝撃誘導核",
		"core_name_en": "IMPACT GUIDANCE CORE",
		"core_effect_ja": "12回目の手動充電が3倍になり、装甲を破砕する",
		"core_effect_en": "Every 12th manual charge is tripled and cracks armor",
		"accent": "ffb703",
		"base_hp": 21000.0,
	},
	{
		"id": "vaultback",
		"order": 2,
		"name_ja": "蓄雷甲獣 ヴォルトバック",
		"name_en": "VAULTBACK, THUNDER SHELL",
		"mechanic_ja": "6セル同期・開殻",
		"mechanic_en": "Six-cell sync and shell break",
		"objective_ja": "部分放電を耐え、6セル同期放電で甲殻を開く",
		"objective_en": "It resists partial shots; six-cell discharge opens the shell",
		"build_tag": "capacity",
		"core_id": "deep_storage",
		"core_name_ja": "深層蓄電核",
		"core_name_en": "DEEP STORAGE CORE",
		"core_effect_ja": "満充電放電後、各セルへ15%の電力を残す",
		"core_effect_en": "Full discharge leaves 15% charge in every cell",
		"accent": "3a86ff",
		"base_hp": 22500.0,
	},
	{
		"id": "pyre_wyrm",
		"order": 3,
		"name_ja": "灼炉蛇 パイア・ワーム",
		"name_en": "PYRE WYRM, FURNACE SERPENT",
		"mechanic_ja": "高熱弱点・メルトダウン",
		"mechanic_en": "Redline weakness and meltdown",
		"objective_ja": "熱を65〜90%へ保ち、露出した炉心へ放電する",
		"objective_en": "Hold 65–90% heat and discharge into its exposed furnace",
		"build_tag": "heat",
		"core_id": "redheat_conversion",
		"core_name_ja": "赤熱変換核",
		"core_name_en": "REDHEAT CONVERSION CORE",
		"core_effect_ja": "高熱時のダメージ増加。事故損失の一部を攻撃へ変換",
		"core_effect_en": "Boosts redline damage and converts some meltdown loss into damage",
		"accent": "ff5c5c",
		"base_hp": 23500.0,
	},
	{
		"id": "relay_hydra",
		"order": 4,
		"name_ja": "継電多頭獣 リレイ・ヒドラ",
		"name_en": "RELAY HYDRA, THREE-HEAD BUS",
		"mechanic_ja": "連続放電・三頭再生",
		"mechanic_en": "Discharge chains and three heads",
		"objective_ja": "4秒以内に放電をつなぎ、再生する三つの頭を順に落とす",
		"objective_en": "Chain shots within four seconds and sever all three heads",
		"build_tag": "chain",
		"core_id": "cascade_relay",
		"core_name_ja": "連鎖継電核",
		"core_name_en": "CASCADE RELAY CORE",
		"core_effect_ja": "放電後に電力を還流し、4秒以内の次弾を強化する",
		"core_effect_en": "Refunds charge and strengthens the next discharge within four seconds",
		"accent": "9b5de5",
		"base_hp": 22000.0,
	},
	{
		"id": "swarm_matriarch",
		"order": 5,
		"name_ja": "群制母機 スウォーム・マトリアーク",
		"name_en": "SWARM MATRIARCH",
		"mechanic_ja": "妨害ドローン・AUTO指令",
		"mechanic_en": "Jammer drones and AUTO commands",
		"objective_ja": "手動入力で子機を標識し、AUTO稼働中の放電で掃討する",
		"objective_en": "Mark drones manually and purge them with AUTO-assisted discharge",
		"build_tag": "auto",
		"core_id": "swarm_clock",
		"core_name_ja": "群制時計核",
		"core_name_en": "SWARM CLOCK CORE",
		"core_effect_ja": "AUTOの余剰を保存し、手動入力でAUTOを一時加速する",
		"core_effect_en": "Stores AUTO overflow and lets manual input briefly accelerate AUTO",
		"accent": "55efc4",
		"base_hp": 21500.0,
	},
	{
		"id": "phase_mantis",
		"order": 6,
		"name_ja": "位相蟷螂 フェイズ・マンティス",
		"name_en": "PHASE MANTIS",
		"mechanic_ja": "臨界窓・解析保証",
		"mechanic_en": "Critical windows and analysis",
		"objective_ja": "回転する弱点位相を読み、非臨界弾で解析を完成させる",
		"objective_en": "Read its rotating phase; non-crits build a guaranteed critical",
		"build_tag": "critical",
		"core_id": "phase_computation",
		"core_name_ja": "位相演算核",
		"core_name_en": "PHASE COMPUTATION CORE",
		"core_effect_ja": "非クリティカルで解析を蓄積し、次の臨界を保証する",
		"core_effect_en": "Non-critical shots build analysis toward a guaranteed critical",
		"accent": "f15bb5",
		"base_hp": 20500.0,
	},
]

const BOSSES := [
	{
		"id": "grid_leech",
		"name_ja": "深淵吸核獣 グリッド・リーチ",
		"name_en": "GRID LEECH, ABYSSAL SIPHON",
		"counter_tag": "full discharge",
		"rule_ja": "予告された吸収触手を満充電放電で中断する",
		"rule_en": "Interrupt telegraphed siphon tentacles with a full discharge",
		"core_id": "predation_reversal",
		"core_name_ja": "捕食反転核",
		"core_name_en": "PREDATION REVERSAL CORE",
		"core_effect_ja": "放電ダメージの一部をセルへ還流し、敵の回復を奪う",
		"core_effect_en": "Returns part of discharge damage as charge and steals enemy recovery",
		"hp": 145000.0,
		"enhanced_hp": 510000.0,
		"accent": "4deeea",
	},
	{
		"id": "thermal_titan",
		"name_ja": "熔炉巨獣 サーマル・タイタン",
		"name_en": "THERMAL TITAN, FORGE COLOSSUS",
		"counter_tag": "redline heat",
		"rule_ja": "65〜90%の高熱域で炉心装甲を開き、熱波を放電で冷却する",
		"rule_en": "Expose its core at 65–90% heat and cool through discharge",
		"core_id": "furnace_sovereign",
		"core_name_ja": "炉皇耐熱核",
		"core_name_en": "FURNACE SOVEREIGN CORE",
		"core_effect_ja": "高熱ダメージを強化し、満充電放電後に事故を一度防ぐ",
		"core_effect_en": "Boosts redline damage and grants meltdown protection after full discharge",
		"hp": 150000.0,
		"enhanced_hp": 530000.0,
		"accent": "ff5c5c",
	},
]

const TRUE_BOSS := {
	"id": "arch_singularity",
	"name_ja": "地核機神 アーク・シンギュラリティ",
	"name_en": "ARCH SINGULARITY, THE WORLD ENGINE",
	"counter_tag": "all six cores",
	"rule_ja": "六獣封鎖、回路反転、特異点充電の三相を突破する",
	"rule_en": "Break six-core seals, reversed circuits, and singularity charge",
	"hp": 700000.0,
	"accent": "f5f0db",
}

const ENCOUNTER_SCALING := [1.0, 1.32, 1.72, 3.15, 4.35, 5.8]

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

static func stage_hp(id: String, encounter_index: int) -> float:
	var definition := stage(id)
	if definition.is_empty():
		return 20000.0
	var index := clampi(encounter_index, 0, ENCOUNTER_SCALING.size() - 1)
	return float(definition.base_hp) * float(ENCOUNTER_SCALING[index])
