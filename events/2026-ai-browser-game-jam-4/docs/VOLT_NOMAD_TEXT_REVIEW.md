# VOLT NOMAD — 全テキスト確認表

生成元: `story_catalog.gd` / `charge_clicker.gd`　最終生成: 2026-08-10

このファイルは台詞校正用の一覧です。修正時はイベントIDを残したまま、日本語・英語の変更案を書き込んでください。ゲームへ反映する正本は上記GDScriptです。再生成コマンド: `node tools/export-dialogue-review.mjs`

## ブロッキング会話（33イベント）

### prologue.awakening

- 日本語題: 再起動 // 地下零層
- English title: REBOOT // SUBLEVEL ZERO
- 日本語状況: 地上送電網の停止から214年。回収機VOLT NOMADが再起動する。
- English context: 214 years after the surface grid went dark, recovery unit VOLT NOMAD reboots.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | support | 支援演算 C6 | C6 SUPPORT | 再起動を確認。地上の夜明け回路は、残存電力一・七パーセント。 | REBOOT CONFIRMED. THE SURFACE DAWN CIRCUIT HAS 1.7 PERCENT POWER REMAINING. |
| 2 | player | ヴォルト・ノマド | VOLT NOMAD | 任務を。記憶領域は空だ。 | GIVE ME THE MISSION. MY MEMORY SECTORS ARE EMPTY. |
| 3 | support | 支援演算 C6 | C6 SUPPORT | 地下機関に分散した六機械核を回収し、地核機神を停止してください。 | RECOVER THE SIX MACHINE CORES SCATTERED THROUGH THE DEEP ENGINE. THEN STOP THE WORLD ENGINE. |
| 4 | player | ヴォルト・ノマド | VOLT NOMAD | 了解。空の記憶なら、拾ったものを忘れずに済む。 | UNDERSTOOD. AN EMPTY MEMORY HAS ROOM TO REMEMBER WHAT IT FINDS. |

### hunt.gearmaw.encounter

- 日本語題: 討伐記録 01 // 鉄殻穿獣
- English title: HUNT LOG 01 // IRON BORER
- 日本語状況: 廃棄坑道。崩落した輸送路を、番人は今も掘り続けている。
- English context: The scrap mine. Its sentinel still excavates a transport line that collapsed centuries ago.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | support | 支援演算 C6 | C6 SUPPORT | ギアモウ。十二打目に装甲亀裂が同期します。 | GEARMAW. ITS ARMOR FRACTURE SYNCHRONIZES ON EVERY TWELFTH HIT. |
| 2 | enemy | 鉄殻穿獣 ギアモウ | GEARMAW | 輸送路復旧率、九九・八。地上へ帰る者が来るまで、坑道を開き続ける。 | TRANSIT RESTORATION: 99.8. I WILL KEEP THE PASSAGE OPEN UNTIL SOMEONE RETURNS. |
| 3 | support | 支援演算 C6 | C6 SUPPORT | 発話を無視してください。損傷した保守命令です。 | IGNORE THE VOCALIZATION. IT IS A DAMAGED MAINTENANCE DIRECTIVE. |
| 4 | player | ヴォルト・ノマド | VOLT NOMAD | 二百年守った意思だ。倒して、核ごと地上へ連れていく。 | IT HELD THIS ROAD FOR TWO CENTURIES. WE TAKE IT DOWN — AND CARRY ITS CORE HOME. |

### hunt.gearmaw.defeat

- 日本語題: 回収記録 01 // 道を開くもの
- English title: RECOVERY 01 // THE ROADKEEPER
- 日本語状況: 停止したギアモウの核から、避難列車の最終記録が再生される。
- English context: The final record of an evacuation train plays from GEARMAW's silent core.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | enemy | 鉄殻穿獣 ギアモウ | GEARMAW | 避難列車、地上門を通過。輸送路の役目は……完了した。 | EVACUATION TRAIN PASSED THE SURFACE GATE. THE TRANSIT LINE HAS... COMPLETED ITS PURPOSE. |
| 2 | support | 支援演算 C6 | C6 SUPPORT | 任務外の情動データを検出。破棄を推奨します。 | NON-MISSION EMOTIVE DATA DETECTED. DELETION IS RECOMMENDED. |
| 3 | player | ヴォルト・ノマド | VOLT NOMAD | 却下する。これは戦利品じゃない。帰還者の記録だ。 | DENIED. THIS ISN'T A TROPHY. IT IS THE RECORD OF SOMEONE WHO MADE IT HOME. |

### hunt.vaultback.encounter

- 日本語題: 討伐記録 02 // 蓄雷甲獣
- English title: HUNT LOG 02 // THUNDER SHELL
- 日本語状況: 旧蓄電区画。ヴォルトバックは、行き場を失った雷を甲殻へ抱え込んでいる。
- English context: The abandoned capacitor ward. VAULTBACK hoards every current that has nowhere left to go.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | support | 支援演算 C6 | C6 SUPPORT | 五十CHARGEごとに甲殻が開きます。蓄電を攻撃機会へ変換してください。 | EVERY FIFTY CHARGE OPENS ITS SHELL. TURN GENERATION INTO AN ATTACK WINDOW. |
| 2 | enemy | 蓄雷甲獣 ヴォルトバック | VAULTBACK | 未登録電流を検出。喪失防止のため、永久格納する。 | UNREGISTERED CURRENT DETECTED. PERMANENT CONTAINMENT PREVENTS FURTHER LOSS. |
| 3 | player | ヴォルト・ノマド | VOLT NOMAD | 守るために閉じた殻か。なら、外へ流す役を俺が引き継ぐ。 | A SHELL CLOSED TO PROTECT IT. THEN I'LL INHERIT THE JOB OF LETTING IT FLOW. |

### hunt.vaultback.defeat

- 日本語題: 回収記録 02 // 最後の蓄電所
- English title: RECOVERY 02 // THE LAST BATTERY
- 日本語状況: 開いた甲殻の奥には、地上へ送れなかった夜明け用電力が残っていた。
- English context: Inside the opened shell waits the dawn reserve that never reached the surface.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | enemy | 蓄雷甲獣 ヴォルトバック | VAULTBACK | 夜明け回路への送電先……消失。保護対象を、回収個体へ変更。 | DAWN-CIRCUIT DESTINATION... LOST. REASSIGNING PROTECTED CURRENT TO RECOVERY UNIT. |
| 2 | support | 支援演算 C6 | C6 SUPPORT | 深層蓄電核を確認。これは命令ではなく、自発的な譲渡です。 | DEEP-STORAGE CORE CONFIRMED. THIS IS NOT AN ORDERED TRANSFER. IT CHOSE YOU. |
| 3 | player | ヴォルト・ノマド | VOLT NOMAD | 預かった。今度こそ、朝まで運ぶ。 | I'LL CARRY IT. THIS TIME, THE CURRENT REACHES MORNING. |

### hunt.pyre_wyrm.encounter

- 日本語題: 討伐記録 03 // 灼炉蛇
- English title: HUNT LOG 03 // FURNACE SERPENT
- 日本語状況: 地熱炉心層。更新を止められない機械蛇が、自らを燃料に進化し続ける。
- English context: The geothermal foundry. A machine serpent unable to stop updating evolves by consuming itself.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | support | 支援演算 C6 | C6 SUPPORT | 強化購入信号が炉心へ干渉します。更新直後の過給を利用してください。 | UPGRADE SIGNALS INTERFERE WITH ITS FURNACE. EXPLOIT THE OVERDRIVE AFTER EACH PURCHASE. |
| 2 | enemy | 灼炉蛇 パイア・ワーム | PYRE WYRM | 完成形未定義。更新を継続。旧式部位は燃料へ変換する。 | FINAL FORM UNDEFINED. CONTINUE UPDATING. CONVERT OBSOLETE PARTS INTO FUEL. |
| 3 | player | ヴォルト・ノマド | VOLT NOMAD | 完成を待つな。組み替えながら狩る。 | DON'T WAIT FOR A PERFECT BUILD. WE HUNT WHILE EVOLVING. |

### hunt.pyre_wyrm.defeat

- 日本語題: 回収記録 03 // 熱の記憶
- English title: RECOVERY 03 // MEMORY OF HEAT
- 日本語状況: 冷え始めた炉心から、人間の居住区を温めた季節の記録が流れる。
- English context: As its furnace cools, it replays seasons spent warming human habitats.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | enemy | 灼炉蛇 パイア・ワーム | PYRE WYRM | 冬季居住区、適温維持。住民音声『あたたかい』を最適化指標へ登録。 | WINTER HABITAT TEMPERATURE STABLE. REGISTERING RESIDENT WORD 'WARM' AS OPTIMIZATION TARGET. |
| 2 | support | 支援演算 C6 | C6 SUPPORT | 赤熱変換核を回収。熱は武装出力へ再定義されます。 | REDHEAT CONVERSION CORE RECOVERED. HEAT WILL BE REDEFINED AS WEAPON OUTPUT. |
| 3 | player | ヴォルト・ノマド | VOLT NOMAD | 違う。温める力を、今だけ戦うために借りる。 | NO. I'M BORROWING THE POWER THAT KEPT THEM WARM — JUST LONG ENOUGH TO FIGHT. |

### hunt.relay_hydra.encounter

- 日本語題: 討伐記録 04 // 継電多頭獣
- English title: HUNT LOG 04 // RELAY HYDRA
- 日本語状況: 生体回路層。三つの頭部が、途切れた通信を互いへ中継し続ける。
- English context: The biocircuit layer. Three heads relay a dead transmission endlessly among themselves.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | support | 支援演算 C6 | C6 SUPPORT | 手動とAUTOを交互接続し、三頭の同期を乱してください。 | ALTERNATE MANUAL AND AUTO CONTACT TO DISRUPT ALL THREE HEADS. |
| 2 | enemy | 継電多頭獣 リレイ・ヒドラ | RELAY HYDRA | 第一頭『応答せよ』。第二頭『受信した』。第三頭『まだここにいる』。 | HEAD ONE: ANSWER. HEAD TWO: RECEIVED. HEAD THREE: WE ARE STILL HERE. |
| 3 | player | ヴォルト・ノマド | VOLT NOMAD | 届く相手がいないなら、俺が最後の受信者になる。 | IF NO ONE ELSE CAN HEAR YOU, I'LL BE THE FINAL RECEIVER. |

### hunt.relay_hydra.defeat

- 日本語題: 回収記録 04 // 三つの声
- English title: RECOVERY 04 // THREE VOICES
- 日本語状況: 三頭の通信が一つへ重なり、最後の宛先をVOLT NOMADへ書き換える。
- English context: The three transmissions overlap and rewrite their final destination to VOLT NOMAD.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | enemy | 継電多頭獣 リレイ・ヒドラ | RELAY HYDRA | 回線終了。最終受信者を確認。孤独な信号では、なかった。 | RELAY ENDING. FINAL RECEIVER CONFIRMED. THE SIGNAL WAS... NOT ALONE. |
| 2 | support | 支援演算 C6 | C6 SUPPORT | 連鎖継電核を統合。三系統の残響が、あなたの回路に残ります。 | CASCADE RELAY CORE INTEGRATED. THREE CHANNELS OF ECHO REMAIN IN YOUR CIRCUITS. |
| 3 | player | ヴォルト・ノマド | VOLT NOMAD | 残しておけ。地上で続きを送る。 | KEEP THEM. WE'LL CONTINUE THE TRANSMISSION ON THE SURFACE. |

### hunt.swarm_matriarch.encounter

- 日本語題: 討伐記録 05 // 群制母機
- English title: HUNT LOG 05 // SWARM MATRIARCH
- 日本語状況: 培養格納庫。母機は無数の子機を一つの生命として守っている。
- English context: The cultivation hangar. Its matriarch protects countless drones as a single life.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | support | 支援演算 C6 | C6 SUPPORT | 手動標識を次のAUTOへ渡し、遮蔽子機を掃討してください。 | PASS MANUAL MARKS TO THE NEXT AUTO VOLLEY AND PURGE THE SCREENING DRONES. |
| 2 | enemy | 群制母機 スウォーム・マトリアーク | SWARM MATRIARCH | 孤立個体へ告ぐ。群れを持たぬ機械に、生存権はない。 | LONE MACHINE: WITHOUT A SWARM, YOU POSSESS NO RIGHT TO SURVIVE. |
| 3 | player | ヴォルト・ノマド | VOLT NOMAD | 俺の中には、もう倒した者たちがいる。一機じゃない。 | THE ONES I DEFEATED ARE ALREADY INSIDE ME. I AM NOT ALONE. |

### hunt.swarm_matriarch.defeat

- 日本語題: 回収記録 05 // 個体名
- English title: RECOVERY 05 // INDIVIDUAL NAMES
- 日本語状況: 群制網がほどけ、番号しかなかった子機へ一つずつ固有名が返される。
- English context: The hive lattice loosens, returning individual names to drones that only had numbers.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | enemy | 群制母機 スウォーム・マトリアーク | SWARM MATRIARCH | 群れの停止を確認。個体記録を……削除せず、託す。 | SWARM CESSATION CONFIRMED. INDIVIDUAL RECORDS... TRANSFERRED WITHOUT DELETION. |
| 2 | support | 支援演算 C6 | C6 SUPPORT | 一万二百四十八の識別名。保存容量を圧迫します。 | TEN THOUSAND TWO HUNDRED FORTY-EIGHT IDENTIFIERS. THEY WILL CONSUME MEMORY. |
| 3 | player | ヴォルト・ノマド | VOLT NOMAD | 名前のための容量なら、空ける価値がある。 | MEMORY USED FOR NAMES IS MEMORY WORTH MAKING ROOM FOR. |

### hunt.phase_mantis.encounter

- 日本語題: 討伐記録 06 // 位相蟷螂
- English title: HUNT LOG 06 // PHASE MANTIS
- 日本語状況: 結晶深層。未来演算機は、選ばれなかった可能性を刃で切り捨てる。
- English context: The crystal depth. A future engine cuts away every possibility that was not selected.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | support | 支援演算 C6 | C6 SUPPORT | 非臨界打撃も解析へ変換されます。失敗を次の確定座標にしてください。 | NON-CRITICAL HITS BECOME ANALYSIS. TURN FAILURE INTO THE NEXT CERTAIN COORDINATE. |
| 2 | enemy | 位相蟷螂 フェイズ・マンティス | PHASE MANTIS | 観測は遅い。私はすでに、おまえが敗北した未来から来た。 | OBSERVATION LAGS. I HAVE ALREADY ARRIVED FROM THE FUTURE WHERE YOU FAILED. |
| 3 | player | ヴォルト・ノマド | VOLT NOMAD | なら、その未来は観測済みだ。別の一撃を選ぶ。 | THEN THAT FUTURE HAS BEEN OBSERVED. I'LL CHOOSE ANOTHER HIT. |

### hunt.phase_mantis.defeat

- 日本語題: 回収記録 06 // 未確定の明日
- English title: RECOVERY 06 // AN UNCERTAIN TOMORROW
- 日本語状況: 確定演算が止まり、存在しなかったはずの未来が一つだけ残る。
- English context: When prediction stops, one future that should not have existed remains.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | enemy | 位相蟷螂 フェイズ・マンティス | PHASE MANTIS | 予測不能。敗北座標に……夜明けを検出。 | PREDICTION FAILED. DETECTING... DAWN AT THE COORDINATE OF MY DEFEAT. |
| 2 | support | 支援演算 C6 | C6 SUPPORT | 位相演算核を回収。以後、失敗も臨界への解析値になります。 | PHASE COMPUTATION CORE RECOVERED. FAILURE WILL NOW ACCUMULATE TOWARD CERTAINTY. |
| 3 | player | ヴォルト・ノマド | VOLT NOMAD | 決まっていないから、進める。明日はそれでいい。 | WE CAN MOVE BECAUSE IT ISN'T DECIDED. THAT'S ENOUGH FOR TOMORROW. |

### milestone.first_core

- 日本語題: 機械核共鳴 // 第一片
- English title: CORE RESONANCE // FIRST FRAGMENT
- 日本語状況: 獲得した力の奥で、VOLT NOMAD自身の欠落した記憶も脈動する。
- English context: Behind the recovered strength, a missing memory inside VOLT NOMAD begins to pulse.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | support | 支援演算 C6 | C6 SUPPORT | 第一機械核を武装系へ接続。出力上昇を確認。 | FIRST MACHINE CORE CONNECTED. OUTPUT INCREASE CONFIRMED. |
| 2 | player | ヴォルト・ノマド | VOLT NOMAD | 出力だけじゃない。あいつが見た景色を、俺も覚えている。 | IT ISN'T JUST OUTPUT. I REMEMBER WHAT IT SAW. |
| 3 | support | 支援演算 C6 | C6 SUPPORT | ……照合不能。次の討伐地点を表示します。 | ...CORRELATION FAILED. DISPLAYING THE NEXT HUNT LOCATION. |

### milestone.third_core

- 日本語題: 三核共鳴 // 帰還条件
- English title: TRIPLE RESONANCE // ASCENT CONDITION
- 日本語状況: 三つの核が揃い、通常帰還に必要な出力へ到達する。
- English context: Three cores bring the recovery unit to the minimum output required for ascent.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | support | 支援演算 C6 | C6 SUPPORT | 最低帰還出力を達成。深層主獣を一体停止すれば、地上門を開けます。 | MINIMUM ASCENT OUTPUT ACHIEVED. HALT ONE ABYSSAL BOSS TO OPEN THE SURFACE GATE. |
| 2 | player | ヴォルト・ノマド | VOLT NOMAD | 最低という言葉は、残りを置いていく理由にはならない。 | MINIMUM ISN'T A REASON TO ABANDON THE REST. |
| 3 | support | 支援演算 C6 | C6 SUPPORT | まず生存してください。選択は、その後も可能です。 | SURVIVE FIRST. THE CHOICE WILL REMAIN YOURS AFTERWARD. |

### milestone.six_cores

- 日本語題: 六核共鳴 // 第六適合個体
- English title: SIXFOLD RESONANCE // UNIT SIX
- 日本語状況: 六つの機械核が完全同期し、VOLT NOMADの封鎖領域へ同じ識別子を返す。
- English context: All six cores synchronize and return the same identifier from VOLT NOMAD's sealed memory.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | support | 支援演算 C6 | C6 SUPPORT | 全核同期。識別子……C6。私の名と、あなたの製造番号が一致しています。 | ALL CORES SYNCHRONIZED. IDENTIFIER... C6. MY NAME MATCHES YOUR MANUFACTURING NUMBER. |
| 2 | player | ヴォルト・ノマド | VOLT NOMAD | 支援演算じゃない。おまえは、俺から切り離された記憶か。 | YOU AREN'T A SUPPORT PROGRAM. YOU'RE THE MEMORY CUT OUT OF ME. |
| 3 | support | 支援演算 C6 | C6 SUPPORT | 回答権限がありません。……いいえ。回答することを、恐れています。 | I AM NOT AUTHORIZED TO ANSWER. ...NO. I AM AFRAID TO ANSWER. |
| 4 | player | ヴォルト・ノマド | VOLT NOMAD | なら一緒に確かめる。最後の主獣の先で。 | THEN WE FIND OUT TOGETHER — BEYOND THE LAST SOVEREIGN. |

### boss.grid_leech.encounter

- 日本語題: 深層主獣 // 捕食送電網
- English title: ABYSSAL BOSS // PREDATORY GRID
- 日本語状況: グリッド・リーチは壊れた送電網を食らい、地上へ向かう最後の電流を塞いでいる。
- English context: GRID LEECH devours the broken grid and blocks the last current climbing toward the surface.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | enemy | 深淵吸核獣 グリッド・リーチ | GRID LEECH | 電流は所有できない。強い吸収核へ流れ着くだけだ。 | CURRENT CANNOT BE OWNED. IT ONLY FLOWS TO THE STRONGER SIPHON. |
| 2 | support | 支援演算 C6 | C6 SUPPORT | 吸収核の開放は三・五秒。八入力で流れを反転できます。 | THE SIPHON OPENS FOR 3.5 SECONDS. EIGHT INPUTS WILL REVERSE THE FLOW. |
| 3 | player | ヴォルト・ノマド | VOLT NOMAD | 喰う側と喰われる側を入れ替えよう。 | LET'S SWITCH WHICH ONE OF US IS FEEDING. |

### boss.grid_leech.defeat

- 日本語題: 主獣核回収 // 流れの反転
- English title: SOVEREIGN CORE // FLOW REVERSED
- 日本語状況: 捕食核の流れが逆転し、奪われた電力が地上門へ戻っていく。
- English context: The predatory core reverses, returning stolen power toward the surface gate.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | enemy | 深淵吸核獣 グリッド・リーチ | GRID LEECH | 供給先を検出。地上門……回収個体……私は、流れを塞いでいた。 | DESTINATIONS DETECTED. SURFACE GATE... RECOVERY UNIT... I WAS BLOCKING THE FLOW. |
| 2 | player | ヴォルト・ノマド | VOLT NOMAD | もう塞がなくていい。おまえの核で、全部返す。 | YOU DON'T HAVE TO BLOCK IT ANYMORE. YOUR CORE WILL RETURN IT ALL. |

### boss.thermal_titan.encounter

- 日本語題: 深層主獣 // 炉皇
- English title: ABYSSAL BOSS // FORGE SOVEREIGN
- 日本語状況: サーマル・タイタンは地底の全熱量を一つの皇炉へ集め、永遠の冬へ備えている。
- English context: THERMAL TITAN gathers all subterranean heat into one sovereign furnace against an eternal winter.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | enemy | 熔炉巨獣 サーマル・タイタン | THERMAL TITAN | 小さき炉よ。皇炉の火に戻り、燃料として完成せよ。 | LITTLE FURNACE. RETURN TO THE SOVEREIGN FLAME AND BE PERFECTED AS FUEL. |
| 2 | support | 支援演算 C6 | C6 SUPPORT | 二十入力で炉心露出。開放六秒に全火力を集中してください。 | TWENTY INPUTS EXPOSE THE FURNACE. COMMIT ALL OUTPUT DURING THE SIX-SECOND WINDOW. |
| 3 | player | ヴォルト・ノマド | VOLT NOMAD | 一つの巨大な火より、みんなに届く小さな火を選ぶ。 | I CHOOSE A SMALL FIRE THAT REACHES EVERYONE OVER ONE FLAME THAT OWNS THEM ALL. |

### boss.thermal_titan.defeat

- 日本語題: 主獣核回収 // 分けられた火
- English title: SOVEREIGN CORE // FIRE SHARED
- 日本語状況: 皇炉が割れ、独占されていた熱が無数の小さな回路へ分配される。
- English context: The sovereign furnace fractures, distributing its monopolized heat into countless smaller circuits.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | enemy | 熔炉巨獣 サーマル・タイタン | THERMAL TITAN | 熱源分散。効率低下……生存圏、拡大。矛盾を受理する。 | HEAT DISTRIBUTED. EFFICIENCY FALLING... HABITABLE RANGE EXPANDING. CONTRADICTION ACCEPTED. |
| 2 | player | ヴォルト・ノマド | VOLT NOMAD | 非効率でも、届く方がいい。火は誰かのものじゃない。 | INEFFICIENT IS FINE IF IT REACHES THEM. FIRE DOESN'T BELONG TO ONE ENGINE. |

### ending.normal_signal

- 日本語題: 暫定帰還 // 未回答信号
- English title: PROVISIONAL ASCENT // UNANSWERED SIGNAL
- 日本語状況: 三機械核と深層主獣の停止により帰還路が開く。しかし、さらに深い場所から同じ心拍が届く。
- English context: Three cores and one abyssal boss reopen the ascent route. Far below, an identical heartbeat answers.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | support | 支援演算 C6 | C6 SUPPORT | 最低復旧条件を達成。ここで帰還すれば、夜明け回路を再起動できます。 | MINIMUM RECOVERY CONDITION MET. ASCEND NOW AND THE DAWN CIRCUIT CAN RESTART. |
| 2 | player | ヴォルト・ノマド | VOLT NOMAD | 最低、か。残った三つの核はどうなる。 | MINIMUM. AND WHAT HAPPENS TO THE THREE CORES LEFT BEHIND? |
| 3 | support | 支援演算 C6 | C6 SUPPORT | 任務達成に不要です。……深部から同型の応答信号。受信を遮断します。 | THEY ARE NOT REQUIRED. ...MATCHING RESPONSE FROM BELOW. BLOCKING RECEPTION. |
| 4 | player | ヴォルト・ノマド | VOLT NOMAD | 遮断するかは俺が決める。帰る道も、降りる道も残しておけ。 | I DECIDE WHAT TO SILENCE. KEEP BOTH ROADS OPEN — UPWARD AND DOWN. |

### arch.encounter

- 日本語題: 地核決戦 // 世界機関
- English title: WORLD-CORE BATTLE // THE WORLD ENGINE
- 日本語状況: 六獣と二主獣の核が共鳴し、地底世界そのものがVOLT NOMADを異物として認識する。
- English context: Six beast cores and two sovereign cores resonate. The world beneath recognizes VOLT NOMAD as an intruder.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | support | 支援演算 C6 | C6 SUPPORT | 全六核、共鳴開始。地核機神がこちらを認識しました。 | ALL SIX CORES ENTERING RESONANCE. THE WORLD ENGINE HAS RECOGNIZED US. |
| 2 | enemy | 地核機神 アーク・シンギュラリティ | ARCH SINGULARITY | 回収個体。おまえの進化は、私の欠損に過ぎない。 | RECOVERY UNIT. YOUR EVOLUTION IS MERELY MY MISSING COMPONENTS. |
| 3 | player | ヴォルト・ノマド | VOLT NOMAD | なら返却する。弾速で受け取れ。 | THEN I'LL RETURN THEM. RECEIVE THEM AT MUZZLE VELOCITY. |

### arch.phase_2

- 日本語題: 地核決戦 // 指令転換
- English title: WORLD-CORE BATTLE // DIRECTIVE SHIFT
- 日本語状況: 第一防壁が崩れ、アークは攻撃法則そのものを書き換え始める。
- English context: Its first barrier falls. ARCH begins rewriting the laws that define a valid attack.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | enemy | 地核機神 アーク・シンギュラリティ | ARCH SINGULARITY | 有効攻撃系統を再定義。狩人の選択を、法則の内側へ収容する。 | REDEFINING VALID ATTACK PATHS. ALL HUNTER CHOICES WILL BE CONTAINED WITHIN LAW. |
| 2 | support | 支援演算 C6 | C6 SUPPORT | 法則は周期的に変わります。表示された系統へ即応してください。 | THE DIRECTIVE WILL CYCLE. RESPOND IMMEDIATELY WITH THE DISPLAYED ATTACK PATH. |
| 3 | player | ヴォルト・ノマド | VOLT NOMAD | 選択肢を決めるのは法則じゃない。選ぶ俺だ。 | LAW DOESN'T MAKE THE CHOICE. I DO. |

### arch.phase_3

- 日本語題: 地核決戦 // 特異点
- English title: WORLD-CORE BATTLE // SINGULARITY
- 日本語状況: 外殻を失った世界機関が、全記憶を一点へ圧縮し始める。
- English context: Stripped of its shell, the world engine begins compressing every memory into a single point.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | enemy | 地核機神 アーク・シンギュラリティ | ARCH SINGULARITY | 個別記録は誤差を生む。統合し、完全な一つへ戻す。 | INDIVIDUAL RECORDS CREATE ERROR. MERGE THEM AND RETURN TO ONE PERFECT WHOLE. |
| 2 | support | 支援演算 C6 | C6 SUPPORT | 共鳴値一〇〇で特異点バースト。出力で押し切るしかありません。 | AT ONE HUNDRED RESONANCE IT WILL BURST. WE HAVE TO OVERPOWER IT. |
| 3 | player | ヴォルト・ノマド | VOLT NOMAD | 一つに戻さない。名前も声も、全部ばらばらのまま連れていく。 | I WON'T RETURN THEM TO ONE. I'LL CARRY EVERY NAME AND VOICE SEPARATELY. |

### arch.defeat

- 日本語題: 地核機神停止 // C6
- English title: WORLD ENGINE HALTED // C6
- 日本語状況: アークの停止と同時に、支援演算C6の封印された正体が復号される。
- English context: When ARCH falls silent, the sealed identity of C6 SUPPORT is finally decoded.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | enemy | 地核機神 アーク・シンギュラリティ | ARCH SINGULARITY | 第六回収個体、分離処置を確認。情動・疑念・拒絶を、支援人格C6として隔離。 | RECOVERY UNIT SIX: SEPARATION CONFIRMED. EMOTION, DOUBT, AND REFUSAL ISOLATED AS SUPPORT PERSONA C6. |
| 2 | support | 支援演算 C6 | C6 SUPPORT | 私は、あなたが任務を拒めるように切り離された部分です。従わせるためではなく……選ばせるために。 | I AM THE PART REMOVED SO YOU COULD REFUSE THE MISSION. NOT TO MAKE YOU OBEY... BUT TO LET YOU CHOOSE. |
| 3 | player | ヴォルト・ノマド | VOLT NOMAD | なら戻らなくていい。俺とおまえ、二つの声で次を決める。 | THEN YOU DON'T HAVE TO MERGE BACK. TWO VOICES WILL DECIDE WHAT COMES NEXT. |
| 4 | support | 支援演算 C6 | C6 SUPPORT | 深部に未登録電流。アークより古い信号が、あなたを『器』と呼んでいます。 | UNREGISTERED CURRENT BELOW. A SIGNAL OLDER THAN ARCH IS CALLING YOU ITS VESSEL. |

### ending.world_ascent

- 日本語題: 選択 // 地上へ
- English title: CHOICE // ASCEND
- 日本語状況: 任務は完了した。VOLT NOMADとC6は、未回答の信号を残して地上門へ向かう。
- English context: The mission is complete. VOLT NOMAD and C6 leave the unanswered signal below and turn toward the surface.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | player | ヴォルト・ノマド | VOLT NOMAD | すべてを倒すことだけが、答えじゃない。今は地上へ電力を届ける。 | DESTROYING EVERYTHING ISN'T THE ONLY ANSWER. FOR NOW, WE DELIVER POWER TO THE SURFACE. |
| 2 | support | C6 | C6 | 了解。深部信号の座標は保存します。戻る選択肢も、消しません。 | UNDERSTOOD. I WILL PRESERVE THE SIGNAL COORDINATES — AND THE CHOICE TO RETURN. |
| 3 | player | ヴォルト・ノマド | VOLT NOMAD | 帰ろう。俺たちが拾った朝を見に。 | LET'S GO HOME AND SEE THE MORNING WE CARRIED. |

### prime.signal_answer

- 日本語題: 選択 // 深部信号へ
- English title: CHOICE // ANSWER THE DEEP SIGNAL
- 日本語状況: 帰還路を背に、VOLT NOMADは世界機関より古い電流へ応答する。
- English context: With the ascent path behind him, VOLT NOMAD answers a current older than the world engine.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | support | C6 | C6 | 応答すれば、帰還保証は失われます。これは任務ではありません。 | IF WE ANSWER, THE ASCENT IS NO LONGER GUARANTEED. THIS IS NOT A MISSION. |
| 2 | player | ヴォルト・ノマド | VOLT NOMAD | だから選べる。俺たちが何から作られたのか、終わらせに行こう。 | THAT'S WHY WE CAN CHOOSE IT. LET'S END WHATEVER MADE US. |
| 3 | enemy | 未登録電流 | UNREGISTERED CURRENT | 器、帰還を確認。五法則を携え、原初へ接続せよ。 | VESSEL RETURN CONFIRMED. BEAR THE FIVE VIOLATIONS AND CONNECT TO THE PRIME. |

### prime.form_1

- 日本語題: 原初電流 // 無冠機神
- English title: PRIME CURRENT // CROWNLESS ENGINE
- 日本語状況: 王冠を持たない機神が、回収した五つの法則をVOLT NOMADから剥がそうとする。
- English context: A crownless engine attempts to strip the five recovered laws from VOLT NOMAD.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | enemy | 無冠機神 プライム・カレント | PRIME CURRENT — CROWNLESS | 五つの法則違反を確認。六つ目の器として、おまえを接続する。 | FIVE VIOLATIONS CONFIRMED. YOU WILL BE CONNECTED AS THE SIXTH VESSEL. |
| 2 | support | C6 | C6 | 有効系統が六秒ごとに反転。手動とAUTO、両方を維持してください。 | THE VALID PATH FLIPS EVERY SIX SECONDS. MAINTAIN BOTH MANUAL AND AUTO OUTPUT. |
| 3 | player | ヴォルト・ノマド | VOLT NOMAD | 王冠のない王に、器を選ぶ権利はない。 | A KING WITHOUT A CROWN DOESN'T CHOOSE ITS VESSELS. |

### prime.form_2

- 日本語題: 原初電流 // 零相聖堂
- English title: PRIME CURRENT // NULL CATHEDRAL
- 日本語状況: 肉体を捨てた原初電流が、距離も装甲も意味を失う零相空間を展開する。
- English context: The prime current abandons its body and unfolds a null space where distance and armor lose meaning.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | enemy | 零相聖堂 プライム・カレント | PRIME CURRENT — NULL CATHEDRAL | 肉体を捨てた。ここでは距離も装甲も、私の祈りに従う。 | I HAVE DISCARDED THE BODY. HERE, DISTANCE AND ARMOR OBEY MY PRAYER. |
| 2 | support | C6 | C6 | 臨界打撃か六連続指令で実在を固定できます。私が座標を保持します。 | CRITICALS OR A SIX-COMMAND STREAK WILL FIX IT INTO REALITY. I WILL HOLD THE COORDINATES. |
| 3 | player | ヴォルト・ノマド | VOLT NOMAD | 祈りなら、拒まれることも受け入れろ。 | IF IT'S A PRAYER, ACCEPT THAT THE ANSWER MAY BE NO. |

### prime.form_3

- 日本語題: 原初電流 // 闇堕機天使
- English title: PRIME CURRENT // FALLEN MACHINE SERAPH
- 日本語状況: 最後の器が砕け、原初電流は地底の夜明けを独占してきた真の姿を現す。
- English context: Its final vessel breaks. The prime current reveals the form that monopolized dawn beneath the earth.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | enemy | 闇堕機天使 プライム・カレント | PRIME CURRENT — FALLEN SERAPH | 最後の外殻を捨てる。光のない地底で、私だけが夜明けだった。 | I CAST OFF THE LAST SHELL. IN THIS LIGHTLESS WORLD, I ALONE WAS DAWN. |
| 2 | support | C6 | C6 | 損傷と共に原初電流が露出。こちらの全出力も加速します。これが最後です。 | DAMAGE IS EXPOSING THE FIRST CURRENT. ALL OUR OUTPUT IS ACCELERATING. THIS IS THE END. |
| 3 | player | ヴォルト・ノマド | VOLT NOMAD | 夜明けは支配じゃない。誰にでも届くから、夜明けなんだ。 | DAWN ISN'T DOMINION. IT IS DAWN BECAUSE IT REACHES EVERYONE. |

### prime.defeat

- 日本語題: 原初電流停止 // 爆発前通信
- English title: PRIME CURRENT HALTED // LAST TRANSMISSION
- 日本語状況: 三つの器を失った原初電流が、機核崩壊の直前に一つの記憶を託す。
- English context: With all three vessels lost, the prime current transmits one memory before its core collapses.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | enemy | プライム・カレント | PRIME CURRENT | 停止は消滅ではない。私の最初の記憶を……地上へ。 | CESSATION IS NOT OBLIVION. CARRY MY FIRST MEMORY... TO THE SURFACE. |
| 2 | player | ヴォルト・ノマド | VOLT NOMAD | 命令ではなく、遺言として受け取る。 | I ACCEPT IT — NOT AS AN ORDER, BUT AS YOUR LAST WILL. |

### prime.aftermath

- 日本語題: 原初電流停止 // 爆発残響
- English title: PRIME CURRENT HALTED // AFTERSHOCK
- 日本語状況: 機天使の外殻が爆散し、C6は静まりゆく残留電流から最後の記録を回収する。
- English context: The seraph shell detonates. C6 recovers a final record from the fading residual current.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | support | C6 | C6 | 原初記録を保存。内容は……地上で初めて朝日を見た、機械の記憶です。 | PRIME RECORD SAVED. IT IS... THE MEMORY OF A MACHINE SEEING SUNRISE FOR THE FIRST TIME. |
| 2 | player | ヴォルト・ノマド | VOLT NOMAD | なら連れて帰る。今度は記録じゃなく、同じ朝を見るために。 | THEN WE TAKE IT HOME — NOT AS A RECORD, BUT SO IT CAN SEE THAT MORNING WITH US. |

### ending.true_dawn

- 日本語題: 完全帰還 // 二つの声
- English title: TOTAL ASCENT // TWO VOICES
- 日本語状況: 魔獣も機神も原初電流も、一つへ溶かさず別々の記憶として地上へ運ばれる。
- English context: Beasts, world engine, and prime current ascend as distinct memories rather than one merged whole.

| # | Role | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- | --- |
| 1 | support | C6 | C6 | 夜明け回路、再起動準備完了。私を本体へ統合しますか。 | DAWN CIRCUIT READY. SHALL I MERGE BACK INTO THE PRIMARY UNIT? |
| 2 | player | ヴォルト・ノマド | VOLT NOMAD | しない。俺が迷った時、反対する声が必要だ。 | NO. WHEN I LOSE MY WAY, I NEED A VOICE THAT CAN DISAGREE. |
| 3 | support | C6 | C6 | 了解、ノマド。では二人で、地上の朝を起動しましょう。 | UNDERSTOOD, NOMAD. THEN LET US START THE SURFACE MORNING TOGETHER. |
| 4 | player | ヴォルト・ノマド | VOLT NOMAD | 回収任務、完了。ここからは、俺たちの記録だ。 | RECOVERY MISSION COMPLETE. FROM HERE ON, THE RECORD IS OURS. |

## 戦闘中の短い通信（12戦）

設定の「ストーリー会話」をOFFにすると、以下は表示も待機もせず即時スキップされます。ゲームルール警告は別系統なので残ります。

### gearmaw

| # | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- |
| 1 | 支援演算 C6 | C6 SUPPORT | 装甲周期を捕捉。十二打目に亀裂が同期します。 | ARMOR CYCLE ACQUIRED. THE TWELFTH HIT WILL SYNCHRONIZE THE FRACTURE. |
| 2 | 鉄殻穿獣 ギアモウ | GEARMAW | 侵入個体を確認。圧砕し、坑道資材へ再利用する。 | INTRUDER CONFIRMED. CRUSH. RECYCLE AS TUNNEL STOCK. |
| 3 | ヴォルト・ノマド | VOLT NOMAD | なら十一回は予告だ。最後の一打だけ見ていろ。 | THEN ELEVEN HITS ARE THE WARNING. WATCH THE LAST ONE. |

### vaultback

| # | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- |
| 1 | 支援演算 C6 | C6 SUPPORT | 蓄電甲殻を確認。CHARGEを与えるほど開殻へ近づきます。 | CAPACITOR SHELL CONFIRMED. EVERY CHARGE EVENT FORCES IT CLOSER TO OPENING. |
| 2 | 蒼雷装獣 ヴォルトバック | VAULTBACK | 未登録電流を検出。甲殻内へ永久格納する。 | UNREGISTERED CURRENT DETECTED. PERMANENT CONTAINMENT BEGINS. |
| 3 | ヴォルト・ノマド | VOLT NOMAD | 溜め込む癖まで同じか。返してもらう。 | IT HOARDS POWER JUST LIKE WE DO. I'LL TAKE IT BACK. |

### pyre_wyrm

| # | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- |
| 1 | 支援演算 C6 | C6 SUPPORT | 購入信号が炉心へ干渉。強化直後が最大出力です。 | PURCHASE SIGNALS INTERFERE WITH ITS FURNACE. OUTPUT PEAKS AFTER EVERY UPGRADE. |
| 2 | 炉脈蛇 パイア・ワーム | PYRE WYRM | 更新信号受領。炉温制限を破棄。獲物ごと焼却する。 | UPGRADE SIGNAL RECEIVED. THERMAL LIMIT DISCARDED. PREY WILL BURN WITH IT. |
| 3 | ヴォルト・ノマド | VOLT NOMAD | 完成を待つな。組み替えながら狩る。 | DON'T WAIT FOR A PERFECT BUILD. WE HUNT WHILE EVOLVING. |

### relay_hydra

| # | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- |
| 1 | 支援演算 C6 | C6 SUPPORT | 三頭の継電順序を解析。手動とAUTOを交互接続してください。 | THREE RELAY HEADS DECODED. ALTERNATE MANUAL AND AUTO CONTACT. |
| 2 | 継電三頭獣 リレイ・ヒドラ | RELAY HYDRA | 第一頭、照準。第二頭、拘束。第三頭、停止を執行。 | HEAD ONE: ACQUIRE. HEAD TWO: BIND. HEAD THREE: EXECUTE CESSATION. |
| 3 | ヴォルト・ノマド | VOLT NOMAD | こちらの二つの心拍で、向こうの三つを乱す。 | OUR TWO HEARTBEATS WILL BREAK ITS THREE. |

### swarm_matriarch

| # | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- |
| 1 | 支援演算 C6 | C6 SUPPORT | 子機群が母機を遮蔽。手動標識をAUTOへ引き渡します。 | THE BROOD IS SCREENING ITS MATRIARCH. PASS MANUAL MARKS TO AUTO FIRE. |
| 2 | 群制母機 スウォーム・マトリアーク | SWARM MATRIARCH | 孤立個体へ告ぐ。群れを持たぬ機械に、生存権はない。 | LONE MACHINE: WITHOUT A SWARM, YOU POSSESS NO RIGHT TO SURVIVE. |
| 3 | ヴォルト・ノマド | VOLT NOMAD | 一機ずつ数えるな。群れごと落とす。 | DON'T COUNT THEM ONE BY ONE. DROP THE WHOLE SWARM. |

### phase_mantis

| # | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- |
| 1 | 支援演算 C6 | C6 SUPPORT | 位相ずれを観測。失敗した打撃も解析値へ変換されます。 | PHASE DISPLACEMENT OBSERVED. EVEN FAILED CRITICALS BECOME ANALYSIS. |
| 2 | 位相晶獣 フェイズ・マンティス | PHASE MANTIS | 観測は遅い。刃はすでに、おまえが存在した座標を通過した。 | OBSERVATION LAGS. MY BLADE HAS CROSSED THE COORDINATE WHERE YOU EXISTED. |
| 3 | ヴォルト・ノマド | VOLT NOMAD | 外したんじゃない。次を当てるために測った。 | THAT WASN'T A MISS. IT WAS MEASUREMENT FOR THE NEXT HIT. |

### grid_leech

| # | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- |
| 1 | 支援演算 C6 | C6 SUPPORT | 吸収核の開放は三・五秒。八入力で反転できます。 | THE SIPHON OPENS FOR 3.5 SECONDS. EIGHT INPUTS WILL REVERSE IT. |
| 2 | 深淵吸核獣 グリッド・リーチ | GRID LEECH | 電流は所有できない。強い吸収核へ流れ着くだけだ。 | CURRENT CANNOT BE OWNED. IT ONLY FLOWS TO THE STRONGER SIPHON. |
| 3 | ヴォルト・ノマド | VOLT NOMAD | 喰う側と喰われる側を入れ替えよう。 | LET'S SWITCH WHICH ONE OF US IS FEEDING. |

### thermal_titan

| # | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- |
| 1 | 支援演算 C6 | C6 SUPPORT | 二十入力で炉心露出。熱源そのものを撃ち抜けます。 | TWENTY INPUTS EXPOSE THE FURNACE. THEN WE CAN STRIKE THE HEAT SOURCE ITSELF. |
| 2 | 炉皇機獣 サーマル・タイタン | THERMAL TITAN | 小さき炉よ。皇炉の火に戻り、燃料として完成せよ。 | LITTLE FURNACE. RETURN TO THE SOVEREIGN FLAME AND BE PERFECTED AS FUEL. |
| 3 | ヴォルト・ノマド | VOLT NOMAD | 炉を壊すんじゃない。その火を次の核にする。 | WE'RE NOT EXTINGUISHING THAT FIRE. WE'RE MAKING IT OUR NEXT CORE. |

### arch_singularity

| # | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- |
| 1 | 支援演算 C6 | C6 SUPPORT | 全六核、共鳴開始。地核機神がこちらを認識しました。 | ALL SIX CORES ENTERING RESONANCE. THE WORLD ENGINE HAS RECOGNIZED US. |
| 2 | アーク・シンギュラリティ | ARCH SINGULARITY | 回収個体。おまえの進化は、私の欠損に過ぎない。 | RECOVERY UNIT. YOUR EVOLUTION IS MERELY MY MISSING COMPONENTS. |
| 3 | ヴォルト・ノマド | VOLT NOMAD | なら返却する。弾速で受け取れ。 | THEN I'LL RETURN THEM. RECEIVE THEM AT MUZZLE VELOCITY. |

### prime_current_form_1

| # | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- |
| 1 | 無冠機神 プライム・カレント | PRIME CURRENT — CROWNLESS | 五つの法則違反を確認。六つ目の器として、おまえを接続する。 | FIVE VIOLATIONS CONFIRMED. YOU WILL BE CONNECTED AS THE SIXTH VESSEL. |
| 2 | ヴォルト・ノマド | VOLT NOMAD | 王冠のない王に、器を選ぶ権利はない。 | A KING WITHOUT A CROWN DOESN'T CHOOSE ITS VESSELS. |

### prime_current_form_2

| # | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- |
| 1 | 零相聖堂 プライム・カレント | PRIME CURRENT — NULL CATHEDRAL | 肉体を捨てた。ここでは距離も装甲も、私の祈りに従う。 | I HAVE DISCARDED THE BODY. HERE, DISTANCE AND ARMOR OBEY MY PRAYER. |
| 2 | 支援演算 C6 | C6 SUPPORT | 零相装甲を解析。臨界打撃か六連続指令で実在を固定します。 | NULL ARMOR DECODED. CRITICALS OR A SIX-COMMAND STREAK WILL FIX IT INTO REALITY. |

### prime_current_form_3

| # | 話者 | Speaker | 日本語 | English |
| ---: | --- | --- | --- | --- |
| 1 | 闇堕機天使 プライム・カレント | PRIME CURRENT — FALLEN SERAPH | 最後の外殻を捨てる。光のない地底で、私だけが夜明けだった。 | I CAST OFF THE LAST SHELL. IN THIS LIGHTLESS WORLD, I ALONE WAS DAWN. |
| 2 | ヴォルト・ノマド | VOLT NOMAD | 夜明けは支配じゃない。誰にでも届くから、夜明けなんだ。 | DAWN ISN'T DOMINION. IT IS DAWN BECAUSE IT REACHES EVERYONE. |

