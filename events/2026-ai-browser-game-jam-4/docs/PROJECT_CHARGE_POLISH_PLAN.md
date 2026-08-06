# PROJECT CHARGE — Product Polish Plan

更新日: 2026-08-06

ゲーム内のコアループと進行システムは V6 で固定する。以降は、審査員が短時間でも完成品だと感じられ、気に入ったプレイヤーが真エンドまで遊びたくなる体験品質に集中する。

## 進め方

- Codexだけで完了できる実装・検証は、判断待ちで止めず順番に進める。
- 人の好みが品質を左右する音楽・物語・最終アートだけ、比較対象を絞ってユーザーへ渡す。
- ユーザー確認が必要な時は「見る場所」「選択肢」「判断基準」を一度に提示する。
- 各工程はWebビルド、スモークテスト、必要に応じて自動プレイ計測を通してから確認依頼を出す。

## Phase 1 — Presentation foundation

Status: IMPLEMENTED / VISUAL QA PASSED

Codex:

- ガトリング変異とレール砲変異の排他を撤廃する。
- 両方取得時にHYBRID（複合砲身）を発動し、257/257を達成可能にする。
- PROJECT CHARGE専用タイトル画面を作る。
- Continue / New Hunt / Settings / Game Labを実装する。
- Master / BGM / SFX / 画面揺れ / フラッシュの設定と保存を実装する。
- BGMとSFXをGodotの別Audio Busへ接続する。

User:

- Web版でタイトル画面、設定画面、セーブ再開を一度だけ確認する。
- HYBRID取得時の体感が強すぎる、弱すぎる場合だけ感想を返す。

## Phase 2 — Sound identity

Status: RUNTIME IMPLEMENTED / MUSIC SELECTION WAITING

Codex:

- 既存の単音中心SFXを、攻撃・AUTO・ドローン・購入・警告・撃破・UIの音群へ再設計する。
- 同じ音の連続感を抑えるため、複数レイヤーと微小なピッチ差を設ける。
- 全9敵に固有BGMを割り当てられるランタイム構造へ変更する。
- 既存曲を1体の通常魔獣、1体の通常ボス、真ボスへ割り当てる。
- 残り6曲のSunoプロンプトを、共通モチーフを持つ一つのOSTとして用意する。

User:

- Sunoで残り6曲を各2案生成する（合計12候補）。
- Codexが提示する一覧から各敵のA/Bを選ぶ。
- 必要なら音量差・曲の長さ・好みをコメントする。

決定済み事項:

- 真ボス: Arch Singularity A
- 通常戦の基準曲: Piston Hunt Loop A
- 地図・ツリー: Subterranean Hunt B
- 通常ボスの基準曲: Forge of Breakpoints B
- エンディング: Core of Dawn A

## Phase 3 — Character and story presentation

Status: FIRST PASS IMPLEMENTED / TONE REVIEW WAITING

Codex:

- クリック操作を止めない通信ウィンドウを実装する。
- 戦闘前、敵ギミック、コア取得、ボス形態変化、エンディングの発話トリガーを作る。
- 日本語・英語の会話データ構造、スキップ、表示時間、再表示制御を実装する。
- 主人公VOLT NOMAD、支援システム、機械魔獣の口調案を作る。

User:

- 主人公の人格と支援者の距離感を3案から選ぶ。
- 会話全文の最終トーンを確認する。

## Phase 4 — Ending and credits

Status: IMPLEMENTED / CREDIT NAME REVIEW WAITING

Codex:

- 通常エンド用の短い余韻演出を作る。
- 真エンド用のフルエンドロールを作る。
- スキップ、早送り、結果画面、タイトルへ戻る導線を実装する。
- Godot、PixelLab、Suno、OpenAI Codex、フォントライセンスを含む制作表記を整える。

User:

- クレジットに表示する制作者名義を最終確認する。
- Special Thanksへ載せたい名前がある場合だけ共有する。

## Phase 5 — Final submission QA

Status: IN PROGRESS

Codex:

- セーブ互換、初回プレイ、再開、通常エンド、真エンドを検証する。
- キーボード、マウス、タッチ、ゲームパッドの主要導線を検証する。
- BGM/SFX設定、ミュート、画面効果軽減を検証する。
- 自動プレイ計測と人間プレイ記録を比較し、異常な停止・極端な待ち時間だけ修正する。
- Web書き出し、itch.io向けファイル、AI/素材クレジット、説明文を完成させる。

User:

- 最終候補を通常ルート1回、可能なら真ルート1回プレイする。
- 提出前の最終OKを出す。

## Tier III policy

Tier IIIの大きなインフレは、通常進行の延長ではなく「完成したビルドが世界の法則を壊す」報酬として維持する。数値を先に弱めず、解放演出、単位表示、専用音、会話によって意図した変化だと伝える。真ボスの曲や形態変化が体験できないほど短くなった場合のみ、フェーズ制御側を調整する。
