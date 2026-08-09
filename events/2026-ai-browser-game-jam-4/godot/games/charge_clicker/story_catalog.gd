class_name ChargeStoryCatalog
extends RefCounted


# The first narrative vertical slice.  These scenes deliberately cover the
# full emotional arc (awakening, encounter, recovered memory and unresolved
# ending) so the presentation can be reviewed before every hunt is authored.
static var EVENTS: Array[Dictionary] = [
	{
		"id": "prologue.awakening",
		"title_ja": "再起動 // 地下零層",
		"title_en": "REBOOT // SUBLEVEL ZERO",
		"context_ja": "地上送電網の停止から214年。回収機VOLT NOMADが再起動する。",
		"context_en": "214 years after the surface grid went dark, recovery unit VOLT NOMAD reboots.",
		"lines": [
			line("support", "支援演算 C6", "C6 SUPPORT", "再起動を確認。地上の夜明け回路は、残存電力一・七パーセント。", "REBOOT CONFIRMED. THE SURFACE DAWN CIRCUIT HAS 1.7 PERCENT POWER REMAINING."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "任務を。記憶領域は空だ。", "GIVE ME THE MISSION. MY MEMORY SECTORS ARE EMPTY."),
			line("support", "支援演算 C6", "C6 SUPPORT", "地下機関に分散した六機械核を回収し、地核機神を停止してください。", "RECOVER THE SIX MACHINE CORES SCATTERED THROUGH THE DEEP ENGINE. THEN STOP THE WORLD ENGINE."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "了解。空の記憶なら、拾ったものを忘れずに済む。", "UNDERSTOOD. AN EMPTY MEMORY HAS ROOM TO REMEMBER WHAT IT FINDS."),
		],
	},
	{
		"id": "hunt.gearmaw.encounter",
		"title_ja": "討伐記録 01 // 鉄殻穿獣",
		"title_en": "HUNT LOG 01 // IRON-SHELL BEAST",
		"context_ja": "廃棄坑道。最初の番人は、崩落した輸送路を今も掘り続けている。",
		"context_en": "The abandoned mine. Its first sentinel still excavates a transport line that collapsed centuries ago.",
		"lines": [
			line("support", "支援演算 C6", "C6 SUPPORT", "鉄殻穿獣ギアモウ。十二打目に装甲亀裂が同期します。", "GEARMAW, THE IRON-SHELL BEAST. ITS ARMOR FRACTURE SYNCHRONIZES ON EVERY TWELFTH HIT."),
			line("enemy", "鉄殻穿獣 ギアモウ", "GEARMAW", "輸送路復旧率、九九・八。地上へ帰る者が来るまで、坑道を開き続ける。", "TRANSIT RESTORATION: 99.8. I WILL KEEP THE PASSAGE OPEN UNTIL SOMEONE RETURNS TO THE SURFACE.", "gearmaw"),
			line("support", "支援演算 C6", "C6 SUPPORT", "発話を無視してください。損傷した保守命令の反復です。", "IGNORE THE VOCALIZATION. IT IS A DAMAGED MAINTENANCE DIRECTIVE REPEATING ITSELF."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "反復でも、二百年守った意思だ。倒して、核ごと地上へ連れていく。", "REPETITION OR NOT, IT HELD THIS ROAD FOR TWO CENTURIES. WE TAKE IT DOWN — AND CARRY ITS CORE TO THE SURFACE."),
		],
	},
	{
		"id": "hunt.gearmaw.defeat",
		"title_ja": "回収記録 // 道を開くもの",
		"title_en": "RECOVERY LOG // THE ROADKEEPER",
		"context_ja": "停止したギアモウの核から、誰のものでもない記憶が再生される。",
		"context_en": "A memory belonging to no single machine plays from GEARMAW's silent core.",
		"lines": [
			line("enemy", "鉄殻穿獣 ギアモウ", "GEARMAW", "最終記録。避難列車、地上門を通過。輸送路の役目は……完了した。", "FINAL LOG. EVACUATION TRAIN PASSED THE SURFACE GATE. THE TRANSIT LINE HAS... COMPLETED ITS PURPOSE.", "gearmaw"),
			line("support", "支援演算 C6", "C6 SUPPORT", "核内部に任務外の情動データを検出。破棄を推奨します。", "NON-MISSION EMOTIVE DATA DETECTED INSIDE THE CORE. DELETION IS RECOMMENDED."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "却下する。これは戦利品じゃない。帰還者の記録だ。", "DENIED. THIS ISN'T A TROPHY. IT IS THE RECORD OF SOMEONE WHO MADE IT HOME."),
		],
	},
	{
		"id": "milestone.first_core",
		"title_ja": "機械核共鳴 // 第一片",
		"title_en": "CORE RESONANCE // FIRST FRAGMENT",
		"context_ja": "獲得した力の奥で、VOLT NOMAD自身の欠落した記憶も脈動する。",
		"context_en": "Behind the stolen strength, a missing memory inside VOLT NOMAD begins to pulse.",
		"lines": [
			line("support", "支援演算 C6", "C6 SUPPORT", "機械核を武装系へ接続。出力上昇を確認しました。", "MACHINE CORE CONNECTED TO THE WEAPON BUS. OUTPUT INCREASE CONFIRMED."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "出力だけじゃない。あいつが見た地上門を、俺も覚えている。", "IT ISN'T JUST OUTPUT. I REMEMBER THE SURFACE GATE IT SAW."),
			line("support", "支援演算 C6", "C6 SUPPORT", "……照合不能。次の討伐地点を表示します。", "...CORRELATION FAILED. DISPLAYING THE NEXT HUNT LOCATION."),
		],
	},
	{
		"id": "ending.normal_signal",
		"title_ja": "暫定帰還 // 未回答信号",
		"title_en": "PROVISIONAL ASCENT // UNANSWERED SIGNAL",
		"context_ja": "三機械核と深層主獣の停止により、地上への帰還路が開く。しかし、さらに深い場所から同じ心拍が届く。",
		"context_en": "Three cores and one abyssal beast reopen the ascent route. Far below, an identical heartbeat answers.",
		"lines": [
			line("support", "支援演算 C6", "C6 SUPPORT", "最低復旧条件を達成。ここで帰還すれば、夜明け回路を再起動できます。", "MINIMUM RECOVERY CONDITION MET. ASCEND NOW AND THE DAWN CIRCUIT CAN RESTART."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "最低、か。残った三つの核はどうなる。", "MINIMUM. AND WHAT HAPPENS TO THE THREE CORES LEFT BEHIND?"),
			line("support", "支援演算 C6", "C6 SUPPORT", "任務達成に不要です。……深部から同型の応答信号。受信を遮断します。", "THEY ARE NOT REQUIRED FOR MISSION COMPLETION. ...MATCHING RESPONSE FROM BELOW. BLOCKING RECEPTION."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "遮断するかは俺が決める。帰る道も、降りる道も残しておけ。", "I DECIDE WHAT TO SILENCE. KEEP BOTH ROADS OPEN — UPWARD AND DOWN."),
		],
	},
]


static func line(role: String, speaker_ja: String, speaker_en: String, text_ja: String, text_en: String, portrait_id := "") -> Dictionary:
	return {
		"role": role,
		"speaker_ja": speaker_ja,
		"speaker_en": speaker_en,
		"text_ja": text_ja,
		"text_en": text_en,
		"portrait_id": portrait_id,
	}


static func event(event_id: String) -> Dictionary:
	for definition in EVENTS:
		if str(definition.get("id", "")) == event_id:
			return definition.duplicate(true)
	return {}


static func event_ids() -> Array[String]:
	var ids: Array[String] = []
	for definition in EVENTS:
		ids.append(str(definition.get("id", "")))
	return ids


static func validate() -> Array[String]:
	var errors: Array[String] = []
	var seen := {}
	for definition in EVENTS:
		var event_id := str(definition.get("id", ""))
		if event_id.is_empty():
			errors.append("event id is empty")
		elif seen.has(event_id):
			errors.append("duplicate event id: %s" % event_id)
		seen[event_id] = true
		for key in ["title_ja", "title_en", "context_ja", "context_en"]:
			if str(definition.get(key, "")).is_empty():
				errors.append("%s missing %s" % [event_id, key])
		var lines: Array = definition.get("lines", [])
		if lines.is_empty():
			errors.append("%s has no lines" % event_id)
		for index in range(lines.size()):
			var entry: Dictionary = lines[index]
			for key in ["speaker_ja", "speaker_en", "text_ja", "text_en"]:
				if str(entry.get(key, "")).is_empty():
					errors.append("%s line %d missing %s" % [event_id, index, key])
	return errors
