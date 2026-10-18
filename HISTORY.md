# 変更履歴

## 2026-10-19 v1.0完成監査

- README/Quickstartに読者前提と停止判定を追加。診断scriptをSSH標準入力から実行可能にし、target IPを空変数で扱う。
- Controller role/MapMode writerとKnOS flag経路を再調査し、静的候補と実験実行証拠を分離。Controllerの実機変更は未検証。
- 安全なprofile構造仕様を追加し、完全profile templateは非公開。SSH overlay方式は案Bとして一般向け実行手順を出さない方針に決定。
- MLO capture、host mtime、RUNBOOK、記事、reboot snapshotの日付不整合を新章とtimelineに整理。
- 診断script/fixture/tests/CIを強化し、30 shell code fenceのPOSIX/BusyBox構文、SSH stdin quote mock、10 testsを確認。実機変更なし。

## 2026-10-19 再現マニュアル全面補強

- 6 GHzクイックスタート、詳細再現ガイド、19症状のトラブルシューティング、工程別A/B/C coverageを追加。
- mapd/1905設定の入力・runtime生成経路とMLO初回RSNE失敗の原因訂正を追記。
- role/distance/BH形式を解析する診断scriptと公開記事由来の正規化fixtureを追加。raw実機CLI logではない証拠限界を明記。
- unittest、script構文/自己テスト、リンク・秘密・artifact監査を実施。実機変更なし。

## 2026-10-19 再現性・診断補強

- SSH/firewall永続化をDropbear+procd、UCI、overlay seed/cron、KnOS再構成の4方式で再整理し、変更前から失敗時復旧までの確認順を追加。
- root passwordのKnOS symlink参照元と再起動時の再選択を説明。password persistenceは引き続き未検証と明記。
- Controller/Agentの実測値、保存rootfs default、未確定値を分離したEasyMesh設定比較表を追加。
- stdout専用・読み取り専用・IP/MAC/SSIDをマスクするBusyBox sh診断scriptを追加。
- Markdown/artifact/read-only contractテストとGitHub Actions secret scanを追加。
- 5ch返信の詳しい記録URLをそのまま共有できる絶対URLに修正。実機変更なし。

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


## 全面事実監査・加筆（2026-10-19）

- Qiita本人公開記事を照合し、旧版にあったMLO成功未確認の誤った含意を訂正。5+6 GHz 2-link成立、RSNE mismatch修正、通常reboot後の自動復帰、342秒以上の観測、Ethernet端末iperf3 0.91〜0.94 Gbpsを証拠区分付きで追加。
- 6 GHz単独BHのchannel/width、APCLI対応、role/MapMode、優先値、EasyMesh診断CLIとiperf3条件を追記。T6本体endpointとEthernet端末endpointの性能差を明示。
- `.223`成功記事と`.247`別snapshotの時刻を照合。DHCP変遷の連続証拠がないため、同一試験内のIP変更とは断定しない。`.1`、`.13`も別時期/管理用途に分離。
- Private archive remote HEAD `2725c5487a818e4b655bb868326f973c4d9e14ba`のKnOS/SSH報告とBank A/B選定rootfsを再調査。firewall reload経路、Dropbear管理、`knos_config`のpasswd/shadow参照先・Dropbear enable切替、procd起動完了条件を要約。10/18個別発火は未確定と明記。
- `/data` seed/one-shot restore/cron/watchdogの過去T6A鍵SSH復旧、待ち時間、2回連続復帰を別時期の実績として記載。root passwordは未検証。
- 5ch回答章、root取得後の実践ガイド、KnOS/SSH各章、監査レポートを追加。RCE、vendor原本、生ログ、認証情報、復旧scriptは非公開。
- worktreeとGit全履歴のsecret-pattern scan、Markdownリンク/anchor検査、`git diff --check`を実施。個別監査記録は[公開前監査](docs/23-publication-audit.md)。実機変更なし。
