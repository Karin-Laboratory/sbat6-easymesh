# 変更履歴

## 2026-10-19

- ローカルのPrivate archive、SBAT6作業ディレクトリ、`sbat6-tools` と `sbat6-usb-nic` の公開履歴を調査して初版を作成。
- 8月の成功要約、後続MLO作業、L2短時間測定、EHT320未実施案を分離して記録。
- 一次ログ/設定の丸ごと転載を避け、公開用の要約証跡だけを追加。
- 公開範囲: 日本語文書と権利確認済みの本リポジトリ独自文章。生データ/firmware/スクリプト転載なし。
- 検証: 出典、日付、役割、秘密情報、主張強度の監査を実施。監査の詳細は公開push後に追記。
- Rollback: Git commitで復元可能。実機変更なし。

## 公開後監査（2026-10-19）

- `Karin-Laboratory/sbat6-easymesh` を新規Publicで作成し、`main`へpush。
- GitHub APIで公開範囲・README取得・default branchを確認。remote mainは `46713e9ed807aeceded14e7c7a49d45ac9720c63` 時点で一致。
- 31 tracked filesを再監査。秘密鍵/token/PSK形式/MAC/IMEIのpattern scanは0件、binary/non-text 0件、Markdown内部リンク切れ0件。
- `git diff --check` 成功。実機には接続・変更していない。
- 公開後再監査で、EHT320 rollback資料が160+160を既知成功ベースラインと記している点を反映。実験者記録上の成功と未取得のオンエア詳細を区別。
