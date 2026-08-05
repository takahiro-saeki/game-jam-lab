# PROJECT CHARGE Art Review

PixelLabで生成した候補を、ファイル一覧ではなく「制作意図と比較理由が付いた提案」として確認するためのローカル専用レビュー画面です。

## 起動

```bash
cd events/2026-ai-browser-game-jam-4/tools/art-review
npm start
```

ブラウザで <http://127.0.0.1:6670> を開きます。外部へ公開せず、レビュー結果は `data/review-manifest.json` に保存されます。

バッチIDをURLで直接開けます。v5追加素材の確認は `http://127.0.0.1:6670/?batch=v5-protagonist` から始め、上部のバッチ選択で5ギアと3背景を順番に切り替えます。

27案の暫定本命と確認順は [`docs/V5_PIXEL_ASSET_REVIEW.md`](../../docs/V5_PIXEL_ASSET_REVIEW.md) にまとめています。

`npm start` は最新のGodot Web buildも自動で書き出します。「Godot組み合わせ比較」を開くと、原子炉、背景、6セル、GRID WRAITH、エネルギー片、CHARGE、DISCHARGE、AUTO OFFの全候補を、固定したボス戦状態の実ゲームUI、発光リング、整数倍表示と重ねて切り替えられます。プレビューモードではゲーム進行を停止し、セーブも読み書きしません。

統合済み地域の実戦背景は `game/?game=project-charge&art_preview=1&encounter=pyre_wyrm` のように `encounter` を指定して確認できます。6体の通常魔獣、2体の通常ボス、真ボスのIDに対応しています。

## 生成

PixelLab APIシークレットを環境変数として渡し、バッチ単位で生成します。シークレットはこのリポジトリへコピーしません。

```bash
node --env-file=/absolute/path/to/.env.local \
  scripts/generate-batch.mjs --batch phase2-reactor
```

利用できる主なオプション:

- `--batch <id>`: 生成するバッチID（必須）
- `--dry-run`: APIを呼ばず、予定されている生成内容だけ表示
- `--force`: 生成済み候補も再生成（generationsを再消費するため通常は使わない）

生成画像は `godot/assets/charge_clicker/pixellab/source/` 以下へ保存され、プロンプト、モデル、サイズ、日時、API usageが素材台帳へ記録されます。

## レビュールール

1. Codexが1バッチ4〜8案を生成する（スタイル確定前は少数）。
2. 透過、輪郭、構図、実寸、ゲームUIとの競合を機械・目視で一次確認する。
3. 明らかな破綻を除き、上位2〜3案へ順位、推奨理由、懸念を付ける。
4. ユーザーはレビュー画面で「採用」「保留」「不採用」を選ぶ。
5. 採用案をGodotへ仮組みし、1280×720のゲーム画面で最終承認する。

生成数ではなく、ゲーム内で承認済みになった素材数を進捗として扱います。
