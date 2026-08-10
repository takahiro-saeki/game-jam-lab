class_name ChargeStoryCatalog
extends RefCounted


# The campaign is authored as small blocking scenes so a player may tackle the
# six hunts in any order without breaking the central C6 / Unit 06 mystery.
# `chapter` is presentation metadata for the archive; progression is controlled
# by stable event IDs in charge_clicker.gd.
static var EVENTS: Array[Dictionary] = [
	{
		"id": "prologue.awakening", "chapter": "prologue",
		"title_ja": "再起動 // 地下零層", "title_en": "REBOOT // SUBLEVEL ZERO",
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
		"id": "hunt.gearmaw.encounter", "chapter": "hunts",
		"title_ja": "討伐記録 01 // 鉄殻穿獣", "title_en": "HUNT LOG 01 // IRON BORER",
		"context_ja": "廃棄坑道。崩落した輸送路を、番人は今も掘り続けている。",
		"context_en": "The scrap mine. Its sentinel still excavates a transport line that collapsed centuries ago.",
		"lines": [
			line("support", "支援演算 C6", "C6 SUPPORT", "ギアモウ。十二打目に装甲亀裂が同期します。", "GEARMAW. ITS ARMOR FRACTURE SYNCHRONIZES ON EVERY TWELFTH HIT."),
			line("enemy", "鉄殻穿獣 ギアモウ", "GEARMAW", "輸送路復旧率、九九・八。地上へ帰る者が来るまで、坑道を開き続ける。", "TRANSIT RESTORATION: 99.8. I WILL KEEP THE PASSAGE OPEN UNTIL SOMEONE RETURNS.", "gearmaw"),
			line("support", "支援演算 C6", "C6 SUPPORT", "発話を無視してください。損傷した保守命令です。", "IGNORE THE VOCALIZATION. IT IS A DAMAGED MAINTENANCE DIRECTIVE."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "二百年守った意思だ。倒して、核ごと地上へ連れていく。", "IT HELD THIS ROAD FOR TWO CENTURIES. WE TAKE IT DOWN — AND CARRY ITS CORE HOME."),
		],
	},
	{
		"id": "hunt.gearmaw.defeat", "chapter": "hunts",
		"title_ja": "回収記録 01 // 道を開くもの", "title_en": "RECOVERY 01 // THE ROADKEEPER",
		"context_ja": "停止したギアモウの核から、避難列車の最終記録が再生される。",
		"context_en": "The final record of an evacuation train plays from GEARMAW's silent core.",
		"lines": [
			line("enemy", "鉄殻穿獣 ギアモウ", "GEARMAW", "避難列車、地上門を通過。輸送路の役目は……完了した。", "EVACUATION TRAIN PASSED THE SURFACE GATE. THE TRANSIT LINE HAS... COMPLETED ITS PURPOSE.", "gearmaw"),
			line("support", "支援演算 C6", "C6 SUPPORT", "任務外の情動データを検出。破棄を推奨します。", "NON-MISSION EMOTIVE DATA DETECTED. DELETION IS RECOMMENDED."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "却下する。これは戦利品じゃない。帰還者の記録だ。", "DENIED. THIS ISN'T A TROPHY. IT IS THE RECORD OF SOMEONE WHO MADE IT HOME."),
		],
	},
	{
		"id": "hunt.vaultback.encounter", "chapter": "hunts",
		"title_ja": "討伐記録 02 // 蓄雷甲獣", "title_en": "HUNT LOG 02 // THUNDER SHELL",
		"context_ja": "旧蓄電区画。ヴォルトバックは、行き場を失った雷を甲殻へ抱え込んでいる。",
		"context_en": "The abandoned capacitor ward. VAULTBACK hoards every current that has nowhere left to go.",
		"lines": [
			line("support", "支援演算 C6", "C6 SUPPORT", "五十CHARGEごとに甲殻が開きます。蓄電を攻撃機会へ変換してください。", "EVERY FIFTY CHARGE OPENS ITS SHELL. TURN GENERATION INTO AN ATTACK WINDOW."),
			line("enemy", "蓄雷甲獣 ヴォルトバック", "VAULTBACK", "未登録電流を検出。喪失防止のため、永久格納する。", "UNREGISTERED CURRENT DETECTED. PERMANENT CONTAINMENT PREVENTS FURTHER LOSS.", "vaultback"),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "守るために閉じた殻か。なら、外へ流す役を俺が引き継ぐ。", "A SHELL CLOSED TO PROTECT IT. THEN I'LL INHERIT THE JOB OF LETTING IT FLOW."),
		],
	},
	{
		"id": "hunt.vaultback.defeat", "chapter": "hunts",
		"title_ja": "回収記録 02 // 最後の蓄電所", "title_en": "RECOVERY 02 // THE LAST BATTERY",
		"context_ja": "開いた甲殻の奥には、地上へ送れなかった夜明け用電力が残っていた。",
		"context_en": "Inside the opened shell waits the dawn reserve that never reached the surface.",
		"lines": [
			line("enemy", "蓄雷甲獣 ヴォルトバック", "VAULTBACK", "夜明け回路への送電先……消失。保護対象を、回収個体へ変更。", "DAWN-CIRCUIT DESTINATION... LOST. REASSIGNING PROTECTED CURRENT TO RECOVERY UNIT.", "vaultback"),
			line("support", "支援演算 C6", "C6 SUPPORT", "深層蓄電核を確認。これは命令ではなく、自発的な譲渡です。", "DEEP-STORAGE CORE CONFIRMED. THIS IS NOT AN ORDERED TRANSFER. IT CHOSE YOU."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "預かった。今度こそ、朝まで運ぶ。", "I'LL CARRY IT. THIS TIME, THE CURRENT REACHES MORNING."),
		],
	},
	{
		"id": "hunt.pyre_wyrm.encounter", "chapter": "hunts",
		"title_ja": "討伐記録 03 // 灼炉蛇", "title_en": "HUNT LOG 03 // FURNACE SERPENT",
		"context_ja": "地熱炉心層。更新を止められない機械蛇が、自らを燃料に進化し続ける。",
		"context_en": "The geothermal foundry. A machine serpent unable to stop updating evolves by consuming itself.",
		"lines": [
			line("support", "支援演算 C6", "C6 SUPPORT", "強化購入信号が炉心へ干渉します。更新直後の過給を利用してください。", "UPGRADE SIGNALS INTERFERE WITH ITS FURNACE. EXPLOIT THE OVERDRIVE AFTER EACH PURCHASE."),
			line("enemy", "灼炉蛇 パイア・ワーム", "PYRE WYRM", "完成形未定義。更新を継続。旧式部位は燃料へ変換する。", "FINAL FORM UNDEFINED. CONTINUE UPDATING. CONVERT OBSOLETE PARTS INTO FUEL.", "pyre_wyrm"),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "完成を待つな。組み替えながら狩る。", "DON'T WAIT FOR A PERFECT BUILD. WE HUNT WHILE EVOLVING."),
		],
	},
	{
		"id": "hunt.pyre_wyrm.defeat", "chapter": "hunts",
		"title_ja": "回収記録 03 // 熱の記憶", "title_en": "RECOVERY 03 // MEMORY OF HEAT",
		"context_ja": "冷え始めた炉心から、人間の居住区を温めた季節の記録が流れる。",
		"context_en": "As its furnace cools, it replays seasons spent warming human habitats.",
		"lines": [
			line("enemy", "灼炉蛇 パイア・ワーム", "PYRE WYRM", "冬季居住区、適温維持。住民音声『あたたかい』を最適化指標へ登録。", "WINTER HABITAT TEMPERATURE STABLE. REGISTERING RESIDENT WORD 'WARM' AS OPTIMIZATION TARGET.", "pyre_wyrm"),
			line("support", "支援演算 C6", "C6 SUPPORT", "赤熱変換核を回収。熱は武装出力へ再定義されます。", "REDHEAT CONVERSION CORE RECOVERED. HEAT WILL BE REDEFINED AS WEAPON OUTPUT."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "違う。温める力を、今だけ戦うために借りる。", "NO. I'M BORROWING THE POWER THAT KEPT THEM WARM — JUST LONG ENOUGH TO FIGHT."),
		],
	},
	{
		"id": "hunt.relay_hydra.encounter", "chapter": "hunts",
		"title_ja": "討伐記録 04 // 継電多頭獣", "title_en": "HUNT LOG 04 // RELAY HYDRA",
		"context_ja": "生体回路層。三つの頭部が、途切れた通信を互いへ中継し続ける。",
		"context_en": "The biocircuit layer. Three heads relay a dead transmission endlessly among themselves.",
		"lines": [
			line("support", "支援演算 C6", "C6 SUPPORT", "手動とAUTOを交互接続し、三頭の同期を乱してください。", "ALTERNATE MANUAL AND AUTO CONTACT TO DISRUPT ALL THREE HEADS."),
			line("enemy", "継電多頭獣 リレイ・ヒドラ", "RELAY HYDRA", "第一頭『応答せよ』。第二頭『受信した』。第三頭『まだここにいる』。", "HEAD ONE: ANSWER. HEAD TWO: RECEIVED. HEAD THREE: WE ARE STILL HERE.", "relay_hydra"),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "届く相手がいないなら、俺が最後の受信者になる。", "IF NO ONE ELSE CAN HEAR YOU, I'LL BE THE FINAL RECEIVER."),
		],
	},
	{
		"id": "hunt.relay_hydra.defeat", "chapter": "hunts",
		"title_ja": "回収記録 04 // 三つの声", "title_en": "RECOVERY 04 // THREE VOICES",
		"context_ja": "三頭の通信が一つへ重なり、最後の宛先をVOLT NOMADへ書き換える。",
		"context_en": "The three transmissions overlap and rewrite their final destination to VOLT NOMAD.",
		"lines": [
			line("enemy", "継電多頭獣 リレイ・ヒドラ", "RELAY HYDRA", "回線終了。最終受信者を確認。孤独な信号では、なかった。", "RELAY ENDING. FINAL RECEIVER CONFIRMED. THE SIGNAL WAS... NOT ALONE.", "relay_hydra"),
			line("support", "支援演算 C6", "C6 SUPPORT", "連鎖継電核を統合。三系統の残響が、あなたの回路に残ります。", "CASCADE RELAY CORE INTEGRATED. THREE CHANNELS OF ECHO REMAIN IN YOUR CIRCUITS."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "残しておけ。地上で続きを送る。", "KEEP THEM. WE'LL CONTINUE THE TRANSMISSION ON THE SURFACE."),
		],
	},
	{
		"id": "hunt.swarm_matriarch.encounter", "chapter": "hunts",
		"title_ja": "討伐記録 05 // 群制母機", "title_en": "HUNT LOG 05 // SWARM MATRIARCH",
		"context_ja": "培養格納庫。母機は無数の子機を一つの生命として守っている。",
		"context_en": "The cultivation hangar. Its matriarch protects countless drones as a single life.",
		"lines": [
			line("support", "支援演算 C6", "C6 SUPPORT", "手動標識を次のAUTOへ渡し、遮蔽子機を掃討してください。", "PASS MANUAL MARKS TO THE NEXT AUTO VOLLEY AND PURGE THE SCREENING DRONES."),
			line("enemy", "群制母機 スウォーム・マトリアーク", "SWARM MATRIARCH", "孤立個体へ告ぐ。群れを持たぬ機械に、生存権はない。", "LONE MACHINE: WITHOUT A SWARM, YOU POSSESS NO RIGHT TO SURVIVE.", "swarm_matriarch"),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "俺の中には、もう倒した者たちがいる。一機じゃない。", "THE ONES I DEFEATED ARE ALREADY INSIDE ME. I AM NOT ALONE."),
		],
	},
	{
		"id": "hunt.swarm_matriarch.defeat", "chapter": "hunts",
		"title_ja": "回収記録 05 // 個体名", "title_en": "RECOVERY 05 // INDIVIDUAL NAMES",
		"context_ja": "群制網がほどけ、番号しかなかった子機へ一つずつ固有名が返される。",
		"context_en": "The hive lattice loosens, returning individual names to drones that only had numbers.",
		"lines": [
			line("enemy", "群制母機 スウォーム・マトリアーク", "SWARM MATRIARCH", "群れの停止を確認。個体記録を……削除せず、託す。", "SWARM CESSATION CONFIRMED. INDIVIDUAL RECORDS... TRANSFERRED WITHOUT DELETION.", "swarm_matriarch"),
			line("support", "支援演算 C6", "C6 SUPPORT", "一万二百四十八の識別名。保存容量を圧迫します。", "TEN THOUSAND TWO HUNDRED FORTY-EIGHT IDENTIFIERS. THEY WILL CONSUME MEMORY."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "名前のための容量なら、空ける価値がある。", "MEMORY USED FOR NAMES IS MEMORY WORTH MAKING ROOM FOR."),
		],
	},
	{
		"id": "hunt.phase_mantis.encounter", "chapter": "hunts",
		"title_ja": "討伐記録 06 // 位相蟷螂", "title_en": "HUNT LOG 06 // PHASE MANTIS",
		"context_ja": "結晶深層。未来演算機は、選ばれなかった可能性を刃で切り捨てる。",
		"context_en": "The crystal depth. A future engine cuts away every possibility that was not selected.",
		"lines": [
			line("support", "支援演算 C6", "C6 SUPPORT", "非臨界打撃も解析へ変換されます。失敗を次の確定座標にしてください。", "NON-CRITICAL HITS BECOME ANALYSIS. TURN FAILURE INTO THE NEXT CERTAIN COORDINATE."),
			line("enemy", "位相蟷螂 フェイズ・マンティス", "PHASE MANTIS", "観測は遅い。私はすでに、おまえが敗北した未来から来た。", "OBSERVATION LAGS. I HAVE ALREADY ARRIVED FROM THE FUTURE WHERE YOU FAILED.", "phase_mantis"),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "なら、その未来は観測済みだ。別の一撃を選ぶ。", "THEN THAT FUTURE HAS BEEN OBSERVED. I'LL CHOOSE ANOTHER HIT."),
		],
	},
	{
		"id": "hunt.phase_mantis.defeat", "chapter": "hunts",
		"title_ja": "回収記録 06 // 未確定の明日", "title_en": "RECOVERY 06 // AN UNCERTAIN TOMORROW",
		"context_ja": "確定演算が止まり、存在しなかったはずの未来が一つだけ残る。",
		"context_en": "When prediction stops, one future that should not have existed remains.",
		"lines": [
			line("enemy", "位相蟷螂 フェイズ・マンティス", "PHASE MANTIS", "予測不能。敗北座標に……夜明けを検出。", "PREDICTION FAILED. DETECTING... DAWN AT THE COORDINATE OF MY DEFEAT.", "phase_mantis"),
			line("support", "支援演算 C6", "C6 SUPPORT", "位相演算核を回収。以後、失敗も臨界への解析値になります。", "PHASE COMPUTATION CORE RECOVERED. FAILURE WILL NOW ACCUMULATE TOWARD CERTAINTY."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "決まっていないから、進める。明日はそれでいい。", "WE CAN MOVE BECAUSE IT ISN'T DECIDED. THAT'S ENOUGH FOR TOMORROW."),
		],
	},
	{
		"id": "milestone.first_core", "chapter": "core",
		"title_ja": "機械核共鳴 // 第一片", "title_en": "CORE RESONANCE // FIRST FRAGMENT",
		"context_ja": "獲得した力の奥で、VOLT NOMAD自身の欠落した記憶も脈動する。",
		"context_en": "Behind the recovered strength, a missing memory inside VOLT NOMAD begins to pulse.",
		"lines": [
			line("support", "支援演算 C6", "C6 SUPPORT", "第一機械核を武装系へ接続。出力上昇を確認。", "FIRST MACHINE CORE CONNECTED. OUTPUT INCREASE CONFIRMED."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "出力だけじゃない。あいつが見た景色を、俺も覚えている。", "IT ISN'T JUST OUTPUT. I REMEMBER WHAT IT SAW."),
			line("support", "支援演算 C6", "C6 SUPPORT", "……照合不能。次の討伐地点を表示します。", "...CORRELATION FAILED. DISPLAYING THE NEXT HUNT LOCATION."),
		],
	},
	{
		"id": "milestone.third_core", "chapter": "core",
		"title_ja": "三核共鳴 // 帰還条件", "title_en": "TRIPLE RESONANCE // ASCENT CONDITION",
		"context_ja": "三つの核が揃い、通常帰還に必要な出力へ到達する。",
		"context_en": "Three cores bring the recovery unit to the minimum output required for ascent.",
		"lines": [
			line("support", "支援演算 C6", "C6 SUPPORT", "最低帰還出力を達成。深層主獣を一体停止すれば、地上門を開けます。", "MINIMUM ASCENT OUTPUT ACHIEVED. HALT ONE ABYSSAL BOSS TO OPEN THE SURFACE GATE."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "最低という言葉は、残りを置いていく理由にはならない。", "MINIMUM ISN'T A REASON TO ABANDON THE REST."),
			line("support", "支援演算 C6", "C6 SUPPORT", "まず生存してください。選択は、その後も可能です。", "SURVIVE FIRST. THE CHOICE WILL REMAIN YOURS AFTERWARD."),
		],
	},
	{
		"id": "milestone.six_cores", "chapter": "core",
		"title_ja": "六核共鳴 // 第六適合個体", "title_en": "SIXFOLD RESONANCE // UNIT SIX",
		"context_ja": "六つの機械核が完全同期し、VOLT NOMADの封鎖領域へ同じ識別子を返す。",
		"context_en": "All six cores synchronize and return the same identifier from VOLT NOMAD's sealed memory.",
		"lines": [
			line("support", "支援演算 C6", "C6 SUPPORT", "全核同期。識別子……C6。私の名と、あなたの製造番号が一致しています。", "ALL CORES SYNCHRONIZED. IDENTIFIER... C6. MY NAME MATCHES YOUR MANUFACTURING NUMBER."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "支援演算じゃない。おまえは、俺から切り離された記憶か。", "YOU AREN'T A SUPPORT PROGRAM. YOU'RE THE MEMORY CUT OUT OF ME."),
			line("support", "支援演算 C6", "C6 SUPPORT", "回答権限がありません。……いいえ。回答することを、恐れています。", "I AM NOT AUTHORIZED TO ANSWER. ...NO. I AM AFRAID TO ANSWER."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "なら一緒に確かめる。最後の主獣の先で。", "THEN WE FIND OUT TOGETHER — BEYOND THE LAST SOVEREIGN."),
		],
	},
	{
		"id": "boss.grid_leech.encounter", "chapter": "boss",
		"title_ja": "深層主獣 // 捕食送電網", "title_en": "ABYSSAL BOSS // PREDATORY GRID",
		"context_ja": "グリッド・リーチは壊れた送電網を食らい、地上へ向かう最後の電流を塞いでいる。",
		"context_en": "GRID LEECH devours the broken grid and blocks the last current climbing toward the surface.",
		"lines": [
			line("enemy", "深淵吸核獣 グリッド・リーチ", "GRID LEECH", "電流は所有できない。強い吸収核へ流れ着くだけだ。", "CURRENT CANNOT BE OWNED. IT ONLY FLOWS TO THE STRONGER SIPHON.", "grid_leech"),
			line("support", "支援演算 C6", "C6 SUPPORT", "吸収核の開放は三・五秒。八入力で流れを反転できます。", "THE SIPHON OPENS FOR 3.5 SECONDS. EIGHT INPUTS WILL REVERSE THE FLOW."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "喰う側と喰われる側を入れ替えよう。", "LET'S SWITCH WHICH ONE OF US IS FEEDING."),
		],
	},
	{
		"id": "boss.grid_leech.defeat", "chapter": "boss",
		"title_ja": "主獣核回収 // 流れの反転", "title_en": "SOVEREIGN CORE // FLOW REVERSED",
		"context_ja": "捕食核の流れが逆転し、奪われた電力が地上門へ戻っていく。",
		"context_en": "The predatory core reverses, returning stolen power toward the surface gate.",
		"lines": [
			line("enemy", "深淵吸核獣 グリッド・リーチ", "GRID LEECH", "供給先を検出。地上門……回収個体……私は、流れを塞いでいた。", "DESTINATIONS DETECTED. SURFACE GATE... RECOVERY UNIT... I WAS BLOCKING THE FLOW.", "grid_leech"),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "もう塞がなくていい。おまえの核で、全部返す。", "YOU DON'T HAVE TO BLOCK IT ANYMORE. YOUR CORE WILL RETURN IT ALL."),
		],
	},
	{
		"id": "boss.thermal_titan.encounter", "chapter": "boss",
		"title_ja": "深層主獣 // 炉皇", "title_en": "ABYSSAL BOSS // FORGE SOVEREIGN",
		"context_ja": "サーマル・タイタンは地底の全熱量を一つの皇炉へ集め、永遠の冬へ備えている。",
		"context_en": "THERMAL TITAN gathers all subterranean heat into one sovereign furnace against an eternal winter.",
		"lines": [
			line("enemy", "熔炉巨獣 サーマル・タイタン", "THERMAL TITAN", "小さき炉よ。皇炉の火に戻り、燃料として完成せよ。", "LITTLE FURNACE. RETURN TO THE SOVEREIGN FLAME AND BE PERFECTED AS FUEL.", "thermal_titan"),
			line("support", "支援演算 C6", "C6 SUPPORT", "二十入力で炉心露出。開放六秒に全火力を集中してください。", "TWENTY INPUTS EXPOSE THE FURNACE. COMMIT ALL OUTPUT DURING THE SIX-SECOND WINDOW."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "一つの巨大な火より、みんなに届く小さな火を選ぶ。", "I CHOOSE A SMALL FIRE THAT REACHES EVERYONE OVER ONE FLAME THAT OWNS THEM ALL."),
		],
	},
	{
		"id": "boss.thermal_titan.defeat", "chapter": "boss",
		"title_ja": "主獣核回収 // 分けられた火", "title_en": "SOVEREIGN CORE // FIRE SHARED",
		"context_ja": "皇炉が割れ、独占されていた熱が無数の小さな回路へ分配される。",
		"context_en": "The sovereign furnace fractures, distributing its monopolized heat into countless smaller circuits.",
		"lines": [
			line("enemy", "熔炉巨獣 サーマル・タイタン", "THERMAL TITAN", "熱源分散。効率低下……生存圏、拡大。矛盾を受理する。", "HEAT DISTRIBUTED. EFFICIENCY FALLING... HABITABLE RANGE EXPANDING. CONTRADICTION ACCEPTED.", "thermal_titan"),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "非効率でも、届く方がいい。火は誰かのものじゃない。", "INEFFICIENT IS FINE IF IT REACHES THEM. FIRE DOESN'T BELONG TO ONE ENGINE."),
		],
	},
	{
		"id": "ending.normal_signal", "chapter": "ending",
		"title_ja": "暫定帰還 // 未回答信号", "title_en": "PROVISIONAL ASCENT // UNANSWERED SIGNAL",
		"context_ja": "三機械核と深層主獣の停止により帰還路が開く。しかし、さらに深い場所から同じ心拍が届く。",
		"context_en": "Three cores and one abyssal boss reopen the ascent route. Far below, an identical heartbeat answers.",
		"lines": [
			line("support", "支援演算 C6", "C6 SUPPORT", "最低復旧条件を達成。ここで帰還すれば、夜明け回路を再起動できます。", "MINIMUM RECOVERY CONDITION MET. ASCEND NOW AND THE DAWN CIRCUIT CAN RESTART."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "最低、か。残った三つの核はどうなる。", "MINIMUM. AND WHAT HAPPENS TO THE THREE CORES LEFT BEHIND?"),
			line("support", "支援演算 C6", "C6 SUPPORT", "任務達成に不要です。……深部から同型の応答信号。受信を遮断します。", "THEY ARE NOT REQUIRED. ...MATCHING RESPONSE FROM BELOW. BLOCKING RECEPTION."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "遮断するかは俺が決める。帰る道も、降りる道も残しておけ。", "I DECIDE WHAT TO SILENCE. KEEP BOTH ROADS OPEN — UPWARD AND DOWN."),
		],
	},
	{
		"id": "arch.encounter", "chapter": "arch",
		"title_ja": "地核決戦 // 世界機関", "title_en": "WORLD-CORE BATTLE // THE WORLD ENGINE",
		"context_ja": "六獣と二主獣の核が共鳴し、地底世界そのものがVOLT NOMADを異物として認識する。",
		"context_en": "Six beast cores and two sovereign cores resonate. The world beneath recognizes VOLT NOMAD as an intruder.",
		"lines": [
			line("support", "支援演算 C6", "C6 SUPPORT", "全六核、共鳴開始。地核機神がこちらを認識しました。", "ALL SIX CORES ENTERING RESONANCE. THE WORLD ENGINE HAS RECOGNIZED US."),
			line("enemy", "地核機神 アーク・シンギュラリティ", "ARCH SINGULARITY", "回収個体。おまえの進化は、私の欠損に過ぎない。", "RECOVERY UNIT. YOUR EVOLUTION IS MERELY MY MISSING COMPONENTS.", "arch_singularity"),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "なら返却する。弾速で受け取れ。", "THEN I'LL RETURN THEM. RECEIVE THEM AT MUZZLE VELOCITY."),
		],
	},
	{
		"id": "arch.phase_2", "chapter": "arch",
		"title_ja": "地核決戦 // 指令転換", "title_en": "WORLD-CORE BATTLE // DIRECTIVE SHIFT",
		"context_ja": "第一防壁が崩れ、アークは攻撃法則そのものを書き換え始める。",
		"context_en": "Its first barrier falls. ARCH begins rewriting the laws that define a valid attack.",
		"lines": [
			line("enemy", "地核機神 アーク・シンギュラリティ", "ARCH SINGULARITY", "有効攻撃系統を再定義。狩人の選択を、法則の内側へ収容する。", "REDEFINING VALID ATTACK PATHS. ALL HUNTER CHOICES WILL BE CONTAINED WITHIN LAW.", "arch_singularity"),
			line("support", "支援演算 C6", "C6 SUPPORT", "法則は周期的に変わります。表示された系統へ即応してください。", "THE DIRECTIVE WILL CYCLE. RESPOND IMMEDIATELY WITH THE DISPLAYED ATTACK PATH."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "選択肢を決めるのは法則じゃない。選ぶ俺だ。", "LAW DOESN'T MAKE THE CHOICE. I DO."),
		],
	},
	{
		"id": "arch.phase_3", "chapter": "arch",
		"title_ja": "地核決戦 // 特異点", "title_en": "WORLD-CORE BATTLE // SINGULARITY",
		"context_ja": "外殻を失った世界機関が、全記憶を一点へ圧縮し始める。",
		"context_en": "Stripped of its shell, the world engine begins compressing every memory into a single point.",
		"lines": [
			line("enemy", "地核機神 アーク・シンギュラリティ", "ARCH SINGULARITY", "個別記録は誤差を生む。統合し、完全な一つへ戻す。", "INDIVIDUAL RECORDS CREATE ERROR. MERGE THEM AND RETURN TO ONE PERFECT WHOLE.", "arch_singularity"),
			line("support", "支援演算 C6", "C6 SUPPORT", "共鳴値一〇〇で特異点バースト。出力で押し切るしかありません。", "AT ONE HUNDRED RESONANCE IT WILL BURST. WE HAVE TO OVERPOWER IT."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "一つに戻さない。名前も声も、全部ばらばらのまま連れていく。", "I WON'T RETURN THEM TO ONE. I'LL CARRY EVERY NAME AND VOICE SEPARATELY."),
		],
	},
	{
		"id": "arch.defeat", "chapter": "arch",
		"title_ja": "地核機神停止 // C6", "title_en": "WORLD ENGINE HALTED // C6",
		"context_ja": "アークの停止と同時に、支援演算C6の封印された正体が復号される。",
		"context_en": "When ARCH falls silent, the sealed identity of C6 SUPPORT is finally decoded.",
		"lines": [
			line("enemy", "地核機神 アーク・シンギュラリティ", "ARCH SINGULARITY", "第六回収個体、分離処置を確認。情動・疑念・拒絶を、支援人格C6として隔離。", "RECOVERY UNIT SIX: SEPARATION CONFIRMED. EMOTION, DOUBT, AND REFUSAL ISOLATED AS SUPPORT PERSONA C6.", "arch_singularity"),
			line("support", "支援演算 C6", "C6 SUPPORT", "私は、あなたが任務を拒めるように切り離された部分です。従わせるためではなく……選ばせるために。", "I AM THE PART REMOVED SO YOU COULD REFUSE THE MISSION. NOT TO MAKE YOU OBEY... BUT TO LET YOU CHOOSE."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "なら戻らなくていい。俺とおまえ、二つの声で次を決める。", "THEN YOU DON'T HAVE TO MERGE BACK. TWO VOICES WILL DECIDE WHAT COMES NEXT."),
			line("support", "支援演算 C6", "C6 SUPPORT", "深部に未登録電流。アークより古い信号が、あなたを『器』と呼んでいます。", "UNREGISTERED CURRENT BELOW. A SIGNAL OLDER THAN ARCH IS CALLING YOU ITS VESSEL."),
		],
	},
	{
		"id": "ending.world_ascent", "chapter": "ending",
		"title_ja": "選択 // 地上へ", "title_en": "CHOICE // ASCEND",
		"context_ja": "任務は完了した。VOLT NOMADとC6は、未回答の信号を残して地上門へ向かう。",
		"context_en": "The mission is complete. VOLT NOMAD and C6 leave the unanswered signal below and turn toward the surface.",
		"lines": [
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "すべてを倒すことだけが、答えじゃない。今は地上へ電力を届ける。", "DESTROYING EVERYTHING ISN'T THE ONLY ANSWER. FOR NOW, WE DELIVER POWER TO THE SURFACE."),
			line("support", "C6", "C6", "了解。深部信号の座標は保存します。戻る選択肢も、消しません。", "UNDERSTOOD. I WILL PRESERVE THE SIGNAL COORDINATES — AND THE CHOICE TO RETURN."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "帰ろう。俺たちが拾った朝を見に。", "LET'S GO HOME AND SEE THE MORNING WE CARRIED."),
		],
	},
	{
		"id": "prime.signal_answer", "chapter": "prime",
		"title_ja": "選択 // 深部信号へ", "title_en": "CHOICE // ANSWER THE DEEP SIGNAL",
		"context_ja": "帰還路を背に、VOLT NOMADは世界機関より古い電流へ応答する。",
		"context_en": "With the ascent path behind him, VOLT NOMAD answers a current older than the world engine.",
		"lines": [
			line("support", "C6", "C6", "応答すれば、帰還保証は失われます。これは任務ではありません。", "IF WE ANSWER, THE ASCENT IS NO LONGER GUARANTEED. THIS IS NOT A MISSION."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "だから選べる。俺たちが何から作られたのか、終わらせに行こう。", "THAT'S WHY WE CAN CHOOSE IT. LET'S END WHATEVER MADE US."),
			line("enemy", "未登録電流", "UNREGISTERED CURRENT", "器、帰還を確認。五法則を携え、原初へ接続せよ。", "VESSEL RETURN CONFIRMED. BEAR THE FIVE VIOLATIONS AND CONNECT TO THE PRIME.", "prime_current_form_1"),
		],
	},
	{
		"id": "prime.form_1", "chapter": "prime",
		"title_ja": "原初電流 // 無冠機神", "title_en": "PRIME CURRENT // CROWNLESS ENGINE",
		"context_ja": "王冠を持たない機神が、回収した五つの法則をVOLT NOMADから剥がそうとする。",
		"context_en": "A crownless engine attempts to strip the five recovered laws from VOLT NOMAD.",
		"lines": [
			line("enemy", "無冠機神 プライム・カレント", "PRIME CURRENT — CROWNLESS", "五つの法則違反を確認。六つ目の器として、おまえを接続する。", "FIVE VIOLATIONS CONFIRMED. YOU WILL BE CONNECTED AS THE SIXTH VESSEL.", "prime_current_form_1"),
			line("support", "C6", "C6", "有効系統が六秒ごとに反転。手動とAUTO、両方を維持してください。", "THE VALID PATH FLIPS EVERY SIX SECONDS. MAINTAIN BOTH MANUAL AND AUTO OUTPUT."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "王冠のない王に、器を選ぶ権利はない。", "A KING WITHOUT A CROWN DOESN'T CHOOSE ITS VESSELS."),
		],
	},
	{
		"id": "prime.form_2", "chapter": "prime",
		"title_ja": "原初電流 // 零相聖堂", "title_en": "PRIME CURRENT // NULL CATHEDRAL",
		"context_ja": "肉体を捨てた原初電流が、距離も装甲も意味を失う零相空間を展開する。",
		"context_en": "The prime current abandons its body and unfolds a null space where distance and armor lose meaning.",
		"lines": [
			line("enemy", "零相聖堂 プライム・カレント", "PRIME CURRENT — NULL CATHEDRAL", "肉体を捨てた。ここでは距離も装甲も、私の祈りに従う。", "I HAVE DISCARDED THE BODY. HERE, DISTANCE AND ARMOR OBEY MY PRAYER.", "prime_current_form_2"),
			line("support", "C6", "C6", "臨界打撃か六連続指令で実在を固定できます。私が座標を保持します。", "CRITICALS OR A SIX-COMMAND STREAK WILL FIX IT INTO REALITY. I WILL HOLD THE COORDINATES."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "祈りなら、拒まれることも受け入れろ。", "IF IT'S A PRAYER, ACCEPT THAT THE ANSWER MAY BE NO."),
		],
	},
	{
		"id": "prime.form_3", "chapter": "prime",
		"title_ja": "原初電流 // 闇堕機天使", "title_en": "PRIME CURRENT // FALLEN MACHINE SERAPH",
		"context_ja": "最後の器が砕け、原初電流は地底の夜明けを独占してきた真の姿を現す。",
		"context_en": "Its final vessel breaks. The prime current reveals the form that monopolized dawn beneath the earth.",
		"lines": [
			line("enemy", "闇堕機天使 プライム・カレント", "PRIME CURRENT — FALLEN SERAPH", "最後の外殻を捨てる。光のない地底で、私だけが夜明けだった。", "I CAST OFF THE LAST SHELL. IN THIS LIGHTLESS WORLD, I ALONE WAS DAWN.", "prime_current_form_3"),
			line("support", "C6", "C6", "損傷と共に原初電流が露出。こちらの全出力も加速します。これが最後です。", "DAMAGE IS EXPOSING THE FIRST CURRENT. ALL OUR OUTPUT IS ACCELERATING. THIS IS THE END."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "夜明けは支配じゃない。誰にでも届くから、夜明けなんだ。", "DAWN ISN'T DOMINION. IT IS DAWN BECAUSE IT REACHES EVERYONE."),
		],
	},
	{
		"id": "prime.defeat", "chapter": "prime",
		"title_ja": "原初電流停止 // 爆発前通信", "title_en": "PRIME CURRENT HALTED // LAST TRANSMISSION",
		"context_ja": "三つの器を失った原初電流が、機核崩壊の直前に一つの記憶を託す。",
		"context_en": "With all three vessels lost, the prime current transmits one memory before its core collapses.",
		"lines": [
			line("enemy", "プライム・カレント", "PRIME CURRENT", "停止は消滅ではない。私の最初の記憶を……地上へ。", "CESSATION IS NOT OBLIVION. CARRY MY FIRST MEMORY... TO THE SURFACE.", "prime_current_form_3"),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "命令ではなく、遺言として受け取る。", "I ACCEPT IT — NOT AS AN ORDER, BUT AS YOUR LAST WILL."),
		],
	},
	{
		"id": "prime.aftermath", "chapter": "prime",
		"title_ja": "原初電流停止 // 爆発残響", "title_en": "PRIME CURRENT HALTED // AFTERSHOCK",
		"context_ja": "機天使の外殻が爆散し、C6は静まりゆく残留電流から最後の記録を回収する。",
		"context_en": "The seraph shell detonates. C6 recovers a final record from the fading residual current.",
		"lines": [
			line("support", "C6", "C6", "原初記録を保存。内容は……地上で初めて朝日を見た、機械の記憶です。", "PRIME RECORD SAVED. IT IS... THE MEMORY OF A MACHINE SEEING SUNRISE FOR THE FIRST TIME."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "なら連れて帰る。今度は記録じゃなく、同じ朝を見るために。", "THEN WE TAKE IT HOME — NOT AS A RECORD, BUT SO IT CAN SEE THAT MORNING WITH US."),
		],
	},
	{
		"id": "ending.true_dawn", "chapter": "ending",
		"title_ja": "完全帰還 // 二つの声", "title_en": "TOTAL ASCENT // TWO VOICES",
		"context_ja": "魔獣も機神も原初電流も、一つへ溶かさず別々の記憶として地上へ運ばれる。",
		"context_en": "Beasts, world engine, and prime current ascend as distinct memories rather than one merged whole.",
		"lines": [
			line("support", "C6", "C6", "夜明け回路、再起動準備完了。私を本体へ統合しますか。", "DAWN CIRCUIT READY. SHALL I MERGE BACK INTO THE PRIMARY UNIT?"),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "しない。俺が迷った時、反対する声が必要だ。", "NO. WHEN I LOSE MY WAY, I NEED A VOICE THAT CAN DISAGREE."),
			line("support", "C6", "C6", "了解、ノマド。では二人で、地上の朝を起動しましょう。", "UNDERSTOOD, NOMAD. THEN LET US START THE SURFACE MORNING TOGETHER."),
			line("player", "ヴォルト・ノマド", "VOLT NOMAD", "回収任務、完了。ここからは、俺たちの記録だ。", "RECOVERY MISSION COMPLETE. FROM HERE ON, THE RECORD IS OURS."),
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
		for key in ["title_ja", "title_en", "context_ja", "context_en", "chapter"]:
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
