# 出典対応表

公開した資料は一次資料を直接ミラーせず、ローカル/Private資料の所在とSHAを記録し、根拠と評価を新たに要約したもの。パスは収集環境 `/home/masataka` からの相対パス。Privateリポジトリや機器内キャプチャへ公開リンクは張らない。

| 出典 | commit / 日付 | 使用箇所 | 公開可否・注記 |
|---|---|---|---|
| `projects/SBAT6A-Offline-Archive/AGENTS.md`, `README.md`, `docs/source-map.md` | archive HEAD `77a959bea965bf9bd079d739c3c1893d37dfa48c` | 02, 03, 16, timeline | Privateの保存範囲・新旧管理経路確認。文章転載なし |
| `projects/SBAT6A-Offline-Archive/src/t6a/T6A_RECOVERY_RUNBOOK_FOR_AI.md` | archive HEAD同上。後日STA管理状態を含む | 03, 08, 09, 16 | 秘密/現在IPは使わず、EasyMesh成功状態との区別に使用 |
| `projects/sbair6-rce/work/mlo_apply_a.sh` | host mtime 2026-08-23; private work area（Git SHAなし） | 04, 05, 10, timeline | 内容要約。公開コピーなし |
| `projects/sbair6-rce/work/mlo_apply_b.sh` | host mtime 2026-08-23 | 04, 06, 10 | PSK読み出し部分を除き役割とMLD差分のみ使用。転載なし |
| `projects/sbair6-rce/work/mlo_stability_sampler.sh` | host mtime 2026-08-23 | 10, 11 | read-only観測設計を要約。device固有パスを含むので転載なし |
| `projects/sbair6-rce/work/captures/*.tar.gz` (mlo-leave, mlo-rsne, mlo-stability) | host mtime 2026-08-23 | 10, 12, 13, timeline | 生log/straceは個体識別・設定漏えい懸念で非公開。`meta`の収集存在のみ監査 |
| `projects/sbair6-rce/work/reboot-persistence/t6b-reboot-persistence-20260721-124656-{baseline,post}-B.txt` と `captures/t6b-reboot-persistence-20260721-124656.tar.gz` | ファイル名日付は2026-07-21、ホストmtime 2026-08-23、端末epochとも不一致 | 06, 10, 12, 13, timeline | Bのrole/mode、br-lan、interface状態、hash一致だけを比較。元データ非公開 |
| `projects/sbair6-rce/work/eht320-test/README.md`, `apply-eht320.sh`, `verify-eht320.sh`, `rollback-eht160.sh`, `eht320-failsafe.init` | host mtime 2026-08-24 | 10, 12, 14, unresolved | READMEの未実行記述を確認。実行しない、公開転記なし |
| `projects/sbair6-rce/work/l2bench-max-tx.out`, `l2bench-batchfix-{rx,tx}.out` | host mtime 2026-08-25; private work area（Git SHAなし） | 09, 11, timeline | 各ファイルの試行値を区別して要約。完全ログ/環境情報は非公開 |
| Current user-provided experiment brief | 2026-10-19 | 01, 04, 07–09, timeline | Distance 0/1、6 GHz BH/L2 success、日付枠を指示文由来の観測要約として明記。個別CLI原ログは未取得 |
| `projects/sbair6-rce/work/l2bench/` | host mtime 2026-08-25 | 09, 11 | 独自測定用ソースの存在を確認。権利/機密を別途確認していないため転載なし |
| `projects/sbat6-tools/audits/sbat6a-20260925/generated/services.tsv`, `generated/executables.tsv` | repo HEAD `595880df1527b041f416cdcf6d67b50ec74aa698` | 02, 04 | 公開repo内のfile inventoryからdaemon/pathの存在を参照 |
| `projects/sbat6-tools/docs/BOOT_AND_CONNECTIVITY_FAILURES.md`, `PERSISTENT_OVERLAY_RESTORE.md` | repo HEAD同上 | 02, 12, 14, 16 | 別時期のboot/network事象。8月EasyMesh成功ログとは明確に分離 |
| `projects/sbat6-tools` GitHub branches/PR/issues | 2026-10-19照会。mainのみ。PR/issuesにEasyMesh実験なし | unresolved | 指定リポジトリの公開開発履歴調査 |
| `Karin-Laboratory/sbat6-usb-nic` PR/issues | 公開側PR #8/#9とIssues #1–9。EasyMeshに関するものなし | unresolved | USB NIC別実験。EasyMesh出典として使わない |
| `projects/SBAT6A-Offline-Archive` Git history | HEAD `77a959bea965bf9bd079d739c3c1893d37dfa48c` | 03, 16 | 収集範囲/出所を照合。全partition像なし |

`projects/sbair6-rce` と `projects/butlerx` はこの作業のprivate/local work areaで、公開Git履歴として追えるcommit SHAがありません。実験用source/log群はホストファイル時刻で照合しています。butlerxの公開repoは機器固有EasyMesh実験資料を含まないため、本文出典には使っていません。
