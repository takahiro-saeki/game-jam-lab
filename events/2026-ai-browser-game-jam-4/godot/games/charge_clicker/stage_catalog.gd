class_name ChargeStageCatalog
extends RefCounted

# PROJECT CHARGE v4 turns each circuit into a visible mechanical beast battle.
# The same six beasts can be tackled in any order; encounter order supplies the
# campaign-wide inflation while each definition supplies its own rule and core.
const STAGES := [
	{
		"id": "gearmaw",
		"order": 1,
		"name_ja": "鉄殻穿獣 ギアモウ",
		"name_en": "GEARMAW, IRON BORER",
		"mechanic_ja": "12クリック・衝撃破砕",
		"mechanic_en": "12-click armor break",
		"objective_ja": "12回目のクリックが装甲を割り4倍打撃",
		"objective_en": "Every 12th click breaks armor for a 4× hit",
		"build_tag": "manual",
		"core_id": "impact_guidance",
		"core_name_ja": "衝撃誘導核",
		"core_name_en": "IMPACT GUIDANCE CORE",
		"core_effect_ja": "10回目の手動攻撃へ4倍威力の衝撃波を追加",
		"core_effect_en": "Every 10th manual hit adds a 4× shockwave",
		"accent": "ffb703",
		"base_hp": 12000.0,
	},
	{
		"id": "vaultback",
		"order": 2,
		"name_ja": "蓄雷甲獣 ヴォルトバック",
		"name_en": "VAULTBACK, THUNDER SHELL",
		"mechanic_ja": "CHARGE生成・開殻",
		"mechanic_en": "CHARGE milestones open the shell",
		"objective_ja": "50 CHARGEごとに6秒間、全攻撃が2.1倍",
		"objective_en": "Every 50 CHARGE grants six seconds of 2.1× damage",
		"build_tag": "charge",
		"core_id": "deep_storage",
		"core_name_ja": "深層蓄電核",
		"core_name_en": "DEEP STORAGE CORE",
		"core_effect_ja": "累計100 CHARGEごとに追加CHARGEを配当",
		"core_effect_en": "Every 100 lifetime CHARGE pays a bonus dividend",
		"accent": "3a86ff",
		"base_hp": 12500.0,
	},
	{
		"id": "pyre_wyrm",
		"order": 3,
		"name_ja": "灼炉蛇 パイア・ワーム",
		"name_en": "PYRE WYRM, FURNACE SERPENT",
		"mechanic_ja": "強化購入・オーバードライブ",
		"mechanic_en": "Upgrade-triggered overdrive",
		"objective_ja": "強化購入で短時間オーバードライブ",
		"objective_en": "Buying an upgrade ignites temporary overdrive",
		"build_tag": "upgrade",
		"core_id": "redheat_conversion",
		"core_name_ja": "赤熱変換核",
		"core_name_en": "REDHEAT CONVERSION CORE",
		"core_effect_ja": "以後すべての能力購入で5秒間オーバードライブ",
		"core_effect_en": "Every future upgrade purchase starts a five-second overdrive",
		"accent": "ff5c5c",
		"base_hp": 13000.0,
	},
	{
		"id": "relay_hydra",
		"order": 4,
		"name_ja": "継電多頭獣 リレイ・ヒドラ",
		"name_en": "RELAY HYDRA, THREE-HEAD BUS",
		"mechanic_ja": "手動・AUTO交互連鎖",
		"mechanic_en": "Manual and AUTO relay chain",
		"objective_ja": "手動とAUTOを交互につなぎ最大6連鎖",
		"objective_en": "Alternate manual and AUTO hits for a six-step chain",
		"build_tag": "chain",
		"core_id": "cascade_relay",
		"core_name_ja": "連鎖継電核",
		"core_name_en": "CASCADE RELAY CORE",
		"core_effect_ja": "すべての攻撃が一定確率で追加攻撃へ連鎖",
		"core_effect_en": "Every attack can echo into a free follow-up hit",
		"accent": "9b5de5",
		"base_hp": 12400.0,
	},
	{
		"id": "swarm_matriarch",
		"order": 5,
		"name_ja": "群制母機 スウォーム・マトリアーク",
		"name_en": "SWARM MATRIARCH",
		"mechanic_ja": "手動標識・AUTO掃討",
		"mechanic_en": "Manual marks and AUTO purge",
		"objective_ja": "クリックで標識し、次のAUTOで子機を掃討",
		"objective_en": "Mark drones manually; the next AUTO shot purges them",
		"build_tag": "auto",
		"core_id": "swarm_clock",
		"core_name_ja": "群制時計核",
		"core_name_en": "SWARM CLOCK CORE",
		"core_effect_ja": "恒久AUTOドローンを1機追加し、AUTO臨界率も上昇",
		"core_effect_en": "Adds one permanent AUTO drone and raises AUTO critical chance",
		"accent": "55efc4",
		"base_hp": 12200.0,
	},
	{
		"id": "phase_mantis",
		"order": 6,
		"name_ja": "位相蟷螂 フェイズ・マンティス",
		"name_en": "PHASE MANTIS",
		"mechanic_ja": "臨界窓・解析保証",
		"mechanic_en": "Critical windows and analysis",
		"objective_ja": "解析100%で確定臨界、第三位相は臨界率上昇",
		"objective_en": "Analysis guarantees crits; phase three raises crit chance",
		"build_tag": "critical",
		"core_id": "phase_computation",
		"core_name_ja": "位相演算核",
		"core_name_en": "PHASE COMPUTATION CORE",
		"core_effect_ja": "非クリティカルで解析を蓄積し、次の臨界を保証する",
		"core_effect_en": "Non-critical shots build analysis toward a guaranteed critical",
		"accent": "f15bb5",
		"base_hp": 11800.0,
	},
]

const BOSSES := [
	{
		"id": "grid_leech",
		"name_ja": "深淵吸核獣 グリッド・リーチ",
		"name_en": "GRID LEECH, ABYSSAL SIPHON",
		"counter_tag": "8-click break",
		"rule_ja": "吸収核が開く3.5秒に8回クリックし、5倍破砕とCHARGE報酬",
		"rule_en": "Click the open siphon eight times for a 5× break and CHARGE reward",
		"core_id": "predation_reversal",
		"core_name_ja": "捕食反転核",
		"core_name_en": "PREDATION REVERSAL CORE",
		"core_effect_ja": "攻撃出力の一部をCHARGEへ還元する捕食回路",
		"core_effect_en": "Feeds a portion of attack output back into CHARGE",
		"hp": 160000.0,
		"enhanced_hp": 28000000.0,
		"accent": "4deeea",
	},
	{
		"id": "thermal_titan",
		"name_ja": "熔炉巨獣 サーマル・タイタン",
		"name_en": "THERMAL TITAN, FORGE COLOSSUS",
		"counter_tag": "20-click expose",
		"rule_ja": "20クリックで炉心を6秒開き、すべての攻撃が2倍",
		"rule_en": "Twenty clicks expose its furnace for six seconds of 2× damage",
		"core_id": "furnace_sovereign",
		"core_name_ja": "炉皇耐熱核",
		"core_name_en": "FURNACE SOVEREIGN CORE",
		"core_effect_ja": "能力購入によるオーバードライブを延長する",
		"core_effect_en": "Extends every upgrade-triggered overdrive",
		"hp": 170000.0,
		"enhanced_hp": 30000000.0,
		"accent": "ff5c5c",
	},
]

const TRUE_BOSS := {
	"id": "arch_singularity",
	"name_ja": "地核機神 アーク・シンギュラリティ",
	"name_en": "ARCH SINGULARITY, THE WORLD ENGINE",
	"counter_tag": "all six cores",
	"rule_ja": "六獣共鳴、攻撃系統転換、特異点バーストの三相を突破する",
	"rule_en": "Break six resonances, shifting attack directives, and singularity bursts",
	"hp": 600000000.0,
	"accent": "f5f0db",
}

const FINAL_BOSS_FORMS := [
	{
		"id": "prime_current_form_1",
		"form": 1,
		"name_ja": "無冠機神 プライム・カレント",
		"name_en": "PRIME CURRENT — THE CROWNLESS ENGINE",
		"rule_ja": "6秒ごとに手動指令とAUTO砲の有効系統が反転する",
		"rule_en": "Its vulnerable command path alternates between manual and AUTO every six seconds",
		"hp": 900000000.0,
		"accent": "4deeea",
	},
	{
		"id": "prime_current_form_2",
		"form": 2,
		"name_ja": "零相聖堂 プライム・カレント",
		"name_en": "PRIME CURRENT — NULL CATHEDRAL",
		"rule_ja": "臨界攻撃か6連続以上の手動指令で零相装甲を貫く",
		"rule_en": "Critical hits or a manual streak of six pierce its null-phase armor",
		"hp": 3600000000.0,
		"accent": "9b5de5",
	},
	{
		"id": "prime_current_form_3",
		"form": 3,
		"name_ja": "闇堕機天使 プライム・カレント",
		"name_en": "PRIME CURRENT — FALLEN MACHINE SERAPH",
		"rule_ja": "損傷が進むほど原初電流が露出し、すべての攻撃出力が加速する",
		"rule_en": "As the shell fails, the first current is exposed and all damage accelerates",
		"hp": 14400000000.0,
		"accent": "f5f0db",
	},
]

# Encounter-order inflation deliberately outruns the build's multiplicative
# Tier/core growth. The first hunt remains the onboarding baseline; later hunts
# stay alive long enough for their unique mechanics to matter.
const ENCOUNTER_SCALING := [1.0, 3.5, 7.5, 250.0, 40000.0, 500000.0]

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
	for definition in FINAL_BOSS_FORMS:
		if str(definition.id) == id:
			return definition.duplicate(true)
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

static func final_boss_ids() -> Array[String]:
	var ids: Array[String] = []
	for definition in FINAL_BOSS_FORMS:
		ids.append(str(definition.id))
	return ids

static func stage_hp(id: String, encounter_index: int) -> float:
	var definition := stage(id)
	if definition.is_empty():
		return 20000.0
	var index := clampi(encounter_index, 0, ENCOUNTER_SCALING.size() - 1)
	return float(definition.base_hp) * float(ENCOUNTER_SCALING[index])
