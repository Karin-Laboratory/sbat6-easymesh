# 出典対応表

公開した資料は一次資料を直接ミラーせず、ローカル/Private資料の所在とSHAを記録し、根拠と評価を新たに要約したもの。パスは収集環境 `/home/masataka` からの相対パス。Privateリポジトリや機器内キャプチャへ公開リンクは張らない。

| 出典 | commit / 日付 | 使用箇所 | 公開可否・注記 |
|---|---|---|---|
| `projects/SBAT6A-Offline-Archive/AGENTS.md`, `README.md`, `docs/source-map.md` | local archive HEADは旧版。Private remote HEAD `2725c5487a818e4b655bb868326f973c4d9e14ba` (2026-10-18) | 02, 03, 16, timeline | Privateの保存範囲・管理経路確認。文章転載なし |
| `projects/SBAT6A-Offline-Archive/src/t6a/T6A_RECOVERY_RUNBOOK_FOR_AI.md` | Private remote HEAD `2725c5487a818e4b655bb868326f973c4d9e14ba`; blob `0a05c5be1529428a6adb6c5922b97f05b9740d5e`; updated 2026-09-26 | 03, 08, 09, 14, 16 | Private remoteとlocal file一致。秘密/現在IPを公開せず、SSH復旧との区別に使用 |
| `projects/sbair6-rce/work/mlo-recon/{A,B}/` (selected historical filesystem extraction; includes EasyMesh scripts/config) | source files without a public Git SHA; 2026-09 archived firmware extraction | 04–08, 17, 19, 21 | role reader/writer, bridge path, password/shadow symlink behavior; vendor contents not reproduced |
| `projects/sbair6-rce/work/mlo_apply_a.sh` | host mtime 2026-08-23; private work area（Git SHAなし） | 04, 05, 10, timeline | 内容要約。公開コピーなし |
| `projects/sbair6-rce/work/mlo_apply_b.sh` | host mtime 2026-08-23 | 04, 06, 10 | PSK読み出し部分を除き役割とMLD差分のみ使用。転載なし |
| `projects/sbair6-rce/work/mlo_stability_sampler.sh` | host mtime 2026-08-23 | 10, 11 | read-only観測設計を要約。device固有パスを含むので転載なし |
| `projects/sbair6-rce/work/captures/*.tar.gz` (mlo-leave, mlo-rsne, mlo-stability) | host mtime 2026-08-23 | 10, 12, 13, timeline | 生log/straceは個体識別・設定漏えい懸念で非公開。`meta`の収集存在のみ監査 |
| `projects/sbair6-rce/work/reboot-persistence/t6b-reboot-persistence-20260721-124656-{baseline,post}-B.txt` と `captures/t6b-reboot-persistence-20260721-124656.tar.gz` | ファイル名日付は2026-07-21、ホストmtime 2026-08-23、端末epochとも不一致 | 06, 10, 12, 13, timeline | Bのrole/mode、br-lan、interface状態、hash一致だけを比較。元データ非公開 |
| `projects/sbair6-rce/work/eht320-test/README.md`, `apply-eht320.sh`, `verify-eht320.sh`, `rollback-eht160.sh`, `eht320-failsafe.init` | host mtime 2026-08-24 | 10, 12, 14, unresolved | READMEの未実行記述を確認。実行しない、公開転記なし |
| `projects/sbair6-rce/work/l2bench-max-tx.out`, `l2bench-batchfix-{rx,tx}.out` | host mtime 2026-08-25; private work area（Git SHAなし） | 09, 11, timeline | 各ファイルの試行値を区別して要約。完全ログ/環境情報は非公開 |
| Current user-provided experiment brief | 2026-10-19 | 01, 03, 04, 07–09, timeline | Distance 0/1、6 GHz BH/L2 success、歴史的IPの一覧は指示文由来の観測要約として明記。個別CLI原ログは未取得 |
| `projects/sbair6-rce/work/l2bench/` | host mtime 2026-08-25 | 09, 11 | 独自測定用ソースの存在を確認。権利/機密を別途確認していないため転載なし |
| `projects/sbat6-tools/audits/sbat6a-20260925/generated/services.tsv`, `generated/executables.tsv` | repo HEAD `595880df1527b041f416cdcf6d67b50ec74aa698` | 02, 04 | 公開repo内のfile inventoryからdaemon/pathの存在を参照 |
| `projects/sbat6-tools/docs/BOOT_AND_CONNECTIVITY_FAILURES.md`, `PERSISTENT_OVERLAY_RESTORE.md` | repo HEAD同上 | 02, 12, 14, 16 | 別時期のboot/network事象。8月EasyMesh成功ログとは明確に分離 |
| `projects/sbat6-tools` GitHub branches/PR/issues | 2026-10-19照会。mainのみ。PR/issuesにEasyMesh実験なし | unresolved | 指定リポジトリの公開開発履歴調査 |
| `Karin-Laboratory/sbat6-usb-nic` PR/issues | 公開側PR #8/#9とIssues #1–9。EasyMeshに関するものなし | unresolved | USB NIC別実験。EasyMesh出典として使わない |
| `projects/SBAT6A-Offline-Archive` Git history | HEAD `77a959bea965bf9bd079d739c3c1893d37dfa48c` | 03, 16 | 収集範囲/出所を照合。全partition像なし |

`projects/sbair6-rce` と `projects/butlerx` はこの作業のprivate/local work areaで、公開Git履歴として追えるcommit SHAがありません。実験用source/log群はホストファイル時刻で照合しています。butlerxの公開repoは機器固有EasyMesh実験資料を含まないため、本文出典には使っていません。


## 公開一次報告

| 出典 | 日付/取得 | 使用箇所 | 証拠の扱い |
|---|---|---|---|
| [本人執筆Qiita: 速い！安い！ウマい！２台のソフトバンクAir ターミナル６で６GHzEasyMeshを構築する](https://qiita.com/masataka55/items/70222d4e64319c0989d3) | 公開/更新 2026-08-23。2026-10-19監査で本文、追記、実行例と測定結果を検索/確認 | 01, 05–11, 21, 22, timeline | 本人の当時実測報告。6 GHz BH、MLO 2-link、RSNE修正、reboot復帰、iperf3を記事記載として採用。生ログ独立再解析とは表記しない |

## Private archiveの追加解析資料（非公開・内容非転載）

| 出典 | commit / source SHA | 使用箇所 | 公開上の扱い |
|---|---|---|---|
| `SBAT6A-Offline-Archive/docs/vendor/SSH-LOSS-CULPRIT-ASSESSMENT-20261018.md` | remote commit `2725c5487a818e4b655bb868326f973c4d9e14ba`; file blob `7d79ae0364715311b4d6d62407c759dd14bac206` | 17–20, 22 | Bank B静的解析の結論を要約。vendorコード非転載 |
| `docs/vendor/VENDOR-SSH-FIREWALL-RESET-ATTRIBUTION.md` | blob `7c11158f59454303b1a05d8db7b692b7b73fd9a1` | 17–18, 20, 22 | rewrite候補調査。発火実体の断定には使用しない |
| `docs/vendor/VENDOR-SSH-FIREWALL-TRIGGER-TRACE.md` | blob `310f6ca24f6b1437e14a1fd82bd5950b3f8eb53d` | 17–18, 20 | trigger/caller参照の静的解析要約 |
| `docs/vendor/V01-RCS-COMPLETION-VERIFIED-20261018.md` | blob `47a09707a48e65efd6a0f0cd54422b02e9f3a11f` | 17, timeline | procd rcS queue完了とboot flagの静的解析。slow script未特定 |
| `docs/vendor/RESEARCH-INDEX.md` | blob `a8d03546783dde5357f7569a2068245e82bffece` | 17–20, timeline | archive範囲・証拠境界・未解決事項を追跡 |
| `src/t6a/scripts/t6a_persistent_ssh_seed.sh` / `_cron.sh` / `_delay.sh` / `t6a_ssh_keepalive_v2_install.sh` | archive HEAD `2725c5487a818e4b655bb868326f973c4d9e14ba`; blobs `d709834ff7f8fef653b5155b6bca5cd68a005f3e`, `e405ba0c34df14f5c927e78be299e0a6c7a1d64b`, `55c3e25a1103cf4f38dcb3a3a2a90badad50b0df`, `3e625529b2e27706360521add510afde344f24d3` | 14, 18–19, 22 | Private remoteとlocal file一致。独自歴史scriptを解析。固定IP/鍵/副作用のため転載せず、実行手順として公開しない |
| `src/t6a/T6A_RECOVERY_RUNBOOK_FOR_AI.md` | archive HEAD `2725c5487a818e4b655bb868326f973c4d9e14ba`, 2026-09-26 | 14, 18–19 | 2 reboot後の鍵SSH復帰とoverlay seed方式を歴史記録として要約 |

## 再現性・診断補強（2026-10-19）

| 公開用資料 | 根拠 | 利用範囲 | 注記 |
|---|---|---|---|
| `configs/easymesh-values-matrix.md` | 上記Qiita本人記事、`projects/sbair6-rce/work/mlo_apply_a.sh`/`mlo_apply_b.sh`、保存rootfsのdefault/user/runtime設定と2026-09 snapshot | 役割別DeviceRole/MapMode、BH優先値、daemon、BH/APCLI、bridge/DHCP、MLOの比較 | 秘密値を含む完全設定ではない。Agent成功時に不明な値を既定値から推定していない |
| `docs/18-ssh-firewall-persistence.md` | Private archive recovery runbook、seed/cron/delay/watchdog script群とSSH/firewall vendor分析（上表参照） | Dropbear/procd、UCI firewall、overlay one-shot/cron復旧記録、確認順 | script原本は転載なし。一般的OpenWrt動作とSBAT6静的解析/実機復旧記録を分離 |
| `docs/19-root-password-and-authentication.md` | 選定Bank A/B rootfsのpasswd/shadow symlinkと`knos_config`条件分岐の保存解析（2026-09、前掲sbair6-rce source） | 参照元/書込先/起動時再選択の静的評価 | hash/秘密値を収録せず、password persistenceは未検証 |
| `scripts/sbat6-diagnose.sh` | 本作業で新規作成したPOSIX shの読み取り専用コード | IP/MAC/SSIDを隠したpoint-in-time診断 | 独自著作。設定変更、認証ファイル内容取得、targetへの書込なし |
| `tests/test_repo_audit.py`, `.github/workflows/docs-audit.yml` | 本作業で新規作成 | shell syntax、Markdown内部参照、binary artifact、diagnostic read-only contract、CI secret scan | CI/テストは開発環境でのみ実行。実機未接続 |

## 再現マニュアル補強（2026-10-19）

| 公開用資料 | 調査根拠 | 内容/制約 |
|---|---|---|
| `docs/24-easymesh-quickstart.md`, `docs/15-reproduction-guide.md` | 公開Qiita（上記）、保存rootfsの`/etc/init.d/kn_meshd`, `/usr/bin/kn_meshd`, `/etc/uci2map.lua`, `/etc/map/`設定群とEasyMesh生成処理 | 成功値と実行可能writerを区別。選定rootfs静的解析で、Controller writerや完全なprofile投入列は未取得 |
| `docs/25-easymesh-troubleshooting.md`, `docs/26-reproduction-coverage.md` | Qiita、`projects/sbair6-rce/work/mlo-recon/{A,B}`、MLO captureとRUNBOOK、既存公開docs | 19症状をMesh/control/data planeで分離。工程ごとのA/B/C評価。復旧経路や一意原因が不明な項目を明記 |
| `tests/fixtures/mapd-success-report.txt` | Qiita成功記事のrole/distance/BH観測例 | **保存済み実機raw CLI logではない。** 公開記事記述から識別情報を除いて正規化したparser test fixture。生CLI transcriptはローカルcapture検索で取得できず |
| `scripts/sbat6-diagnose.sh` parser/self-test enhancements | 上記記事の表記、既存診断script | 数値/文字列role、distance、BH medium/status/typeに対応。匿名fixtureによるparser testであり、実機互換性の実地試験ではない |

作業環境上の`projects/sbair6-rce`は対象資料がGit commitで追跡されないprivate/local work areaであり、2026-10-19時点でファイルpathと保存capture名を照合した。公開可能なcommit SHAはないため、該当箇所はその旨を明示し、ファイル内容を転載していない。MLOの一部capture名（2026-02-28）とRUNBOOK見出し/記事日付（2026-08-23）は一致せず、同一日時の証拠として扱っていない。

## v1.0完成監査・追加解析（2026-10-19）

| 解析資料 | Source path / revision | 利用範囲と限界 |
|---|---|---|
| Controller role writer候補 | Private/local選定rootfs `projects/sbair6-rce/analysis/vendor-backup/rootfs-a/usr/bin/map_cert_script.sh`, host archive set (Git SHAなし) | certification helperのOpenWrt branchで`DeviceRole=1`を`/etc/map/mapd_user.cfg`へ書く`datconf`経路を静的確認。成功記事の実験でこのhelperを実行した証拠なし。コード転載なし |
| MapMode/KnOS flag初期化 | `analysis/vendor-backup/rootfs-{a,b}/etc/uci-defaults/99-zknos-default-setting-official-0201.mesh`, `...0000.system`, `etc/uci-revert/99-zknos-default-revert-official-0201.mesh` (Git SHAなし) | EasyMesh flagを読む条件分岐からMapModeをmapd UCI sectionsへ書きcommitする経路、mesh flag default carry-forward、EasyMesh=0へのrevertを静的確認。EasyMesh/mesh flag positive writerは選定rootfsテキスト検索で未発見 |
| MLO capture群 | `projects/sbair6-rce/work/captures/mlo-*-20260228-*.tar.gz`; file metadata internally preserved, local host mtime 2026-08-23 | filenamesとmetadata `start_epoch`はdevice-local clock上で2026-02-28 23:40:08 JST相当。外部clock offset/NTP記録なし、絶対dateは未検証。内容/個体識別を公開せず日時由来のみ使用 |
| Reboot snapshot | `work/reboot-persistence/t6b-reboot-persistence-20260721-124656-{baseline,post}-B.txt`; local host mtime 2026-08-23 | filenameとmtime、postに残るdevice-local epoch（2026-03-01 00:11:51 JST相当）が不一致。外部clock sync未確認。`.223`との連続IP変化を証明しない |
| SSH復旧runbook | Private archive HEAD `2725c5487a818e4b655bb868326f973c4d9e14ba`; file/blob SHAは上段参照 | 2026-09 T6A recoveryと2026-02/08 EasyMesh/MLO evidenceを分離。実行手順を公開しない方針を決定 |
| Profile構造仕様 | public `configs/templates/README.md` | 秘密/機器固有値を除き、実際の入力位置、確認済みfield tokenとschema不足のみを要約。適用可能なprofile例ではない |

日時不整合と信頼度の評価は[docs/27-evidence-chronology.md](docs/27-evidence-chronology.md)、Controller writerの調査過程は[docs/05-controller-setup.md](docs/05-controller-setup.md)および[docs/28-controller-writer-validation.md](docs/28-controller-writer-validation.md)。

| 公開用追加物 | 根拠/実装 | 制約 |
|---|---|---|
| `docs/27-evidence-chronology.md`, `docs/timeline.md` | local file metadata、capture内部`start_epoch`、Private archive Git history、Qiita公開日 | 機器/host時計の不一致を表として記録。日付原因を推測しない |
| `docs/28-controller-writer-validation.md` | 上記rootfs UCI init、`map_cert_script.sh`のwriter候補、既存RUNBOOK/記事 | statically-derived owner validation plan。端末でのwriter実行・保持は未検証 |
| `configs/templates/README.md` | 保存`mapd_user.cfg`/runtime profileのkey・WTS id 6 authmode差分、MLO RSNE trace | vendorファイルの完全なpositional schema/秘密profileを掲載しない。適用可能なtemplateではない |
| `tests/test_ssh_stdin_example.py` | 本repoのdiagnostic scriptを仮SSH executableへstdin送信するmock | 実SSHや機器接続は行わず、quoted target/`sh -s`/stdin redirectionだけ検証 |
| `.github/workflows/docs-audit.yml` BusyBox step; `tests/test_repo_audit.py` | local `/usr/bin/busybox` ashで同じ構文とfixture self-testを確認 | scriptの実機SBAT6互換性/設定変更動作を保証しない |

2026-10-19にQiitaとGitHub公開資料を`SBAT6 EHT320`等で検索したが、別のSBAT6 EHT320成功公表は見つからなかった。これは検索範囲内の結果で、存在しないことの網羅的証明ではない。

**取得できなかった/独立照合できない資料:** 5ch投稿の元スレッド生ログ、2026-08 MLO全captureの公開可能な生ログ、投稿者の現在端末での実行時trace、root passwordの再起動認証結果、EHT320の後続オンエア測定。公開Qiitaに記載された実績を否定する意味ではなく、証拠形態を分けるため記載する。
