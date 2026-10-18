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

2026-10-19にQiitaとGitHub公開資料を`SBAT6 EHT320`等で検索したが、別のSBAT6 EHT320成功公表は見つからなかった。これは検索範囲内の結果で、存在しないことの網羅的証明ではない。

**取得できなかった/独立照合できない資料:** 5ch投稿の元スレッド生ログ、2026-08 MLO全captureの公開可能な生ログ、投稿者の現在端末での実行時trace、root passwordの再起動認証結果、EHT320の後続オンエア測定。公開Qiitaに記載された実績を否定する意味ではなく、証拠形態を分けるため記載する。
