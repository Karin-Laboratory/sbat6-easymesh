# 実験タイムライン

日付は公開記事、ファイル名、mtime、端末時刻を区別する。証拠が揃わない日付は範囲で示す。

## 実験準備（2026年8月以前・日付特定不能）

- **目的:** root管理経路と純正EasyMesh機能を調査し、2台の役割を決める。
- **変更/試行:** Web UI経由のコマンド実行、root/SSH補助スクリプト、daemon/config探索。初期侵入過程は本リポジトリの再現対象外。
- **結果:** T6A/T6B各rootfsにMediaTek独自driverと`mapd`、`p1905_managerd`、`wapp`等があることを資料から把握。
- **根拠:** SOURCES.mdの保存スクリプト・archive記録。

## 2026-08-23（公開記事の日付）EasyMeshと6 GHz BH

- **目的:** 2台をController/Agentにし、無線BHへ移行。
- **役割:** T6A Controller (`DeviceRole=1`, `.2`)、T6B Agent (`DeviceRole=2`, 成功記事時`.223`)、双方`MapMode=1`。
- **確認コマンド:** `mapd_cli /tmp/mapd_ctrl getrole`、`agent_list`、`dump_topology`、`dump_topology_v1`、`bh_info`、`bh_conn_status`、`bh_conn_type`、`get_bh_ap`、`get_fh_ap`。`onboarding 0`はCLI機能として記録されたが、常に手動実行したものではない。
- **手順:** Ethernetを使ってonboarding/IEEE 1905.1 discoveryを成立させ、topology/BH情報を確認。その後、Ethernetを外して6 GHz APCLIでの維持を確認。
- **実測報告:** Controller距離0、Agent距離1、Backhaul Medium Type 6G、Agent `bh_conn_status=1`、`bh_conn_type=Type 4`。6 GHz APCLI carrierとcounterが維持。
- **性能コマンド:** T6B `iperf3 -s -B 192.168.3.223`。T6A `iperf3 -c 192.168.3.223 -B 192.168.3.2 -P 4 -t 20`、逆方向は`-R`を追加。結果はA→B約350 Mbps、逆方向約330 Mbps。
- **次:** 成立した6 GHz BHに5+6 GHz MLOを追加。
- **根拠:** Qiita本人公開記事、`mlo_apply_a/b.sh`等保存スクリプト。公開記事の値と生ログ独立再検証は区別する。

## 2026-08-23（記事追記）5+6 GHz MLO

- **初期失敗:** MLO適用後約100 msで切断、wpa_supplicant RSNE mismatch。
- **原因/修正（記事報告）:** 5 GHz WPA2系と6 GHz SAE/PMF必須のprofile不一致、およびEasyMesh runtime provisioningの5 GHz側profile書戻し。profile生成元を直し、SAE/PMF requiredへ統一。
- **成功判定（記事報告）:** 4-way handshake、`mld_sta257 ref_cnt=2`、band_idx 1 (5 GHz)と2 (6 GHz)。両APCLI driver byte counterが転送中に増加。
- **再起動試験（記事報告）:** `sync`→通常`reboot`。DHCP約170秒、EasyMesh再参加約173秒、少なくとも342秒MLO継続。設定変更/Wi-Fi再起動をせず復帰したと報告。
- **性能:** T6本体endpointでは約330〜380 Mbps程度。T6を通るEthernet PC間で`iperf3.exe -c <server> -t 20 -P 10`（逆方向は`-R`）等を測り、1 stream約936/909 Mbps、10 stream約941/908 Mbps（正/逆方向）。両band counter増加を報告。
- **根拠:** 公開Qiita本人報告と、role/MLD設定を含む保存スクリプト。キャプチャ原本は非公開で、公開資料作成時に全ログの独立再解析は行っていない。

## 2026-08-23ホスト保存snapshot（試験日未確定）

- B再起動前後ファイル名に`20260721`を含むが、mtimeは8月23日、端末epochも不整合。厳密な採取日時/順序は未確定。
- `.247/24`、role 2、MapMode 1、wireless/mapd hash一致を比較。一方、UP interfaceは`apclix0`から`apclii0`へ変化。
- これは別snapshotでの保存状態・稼働interface観測。8月23日のMLO成功報告を否定しない。

## 2026-08-24 EHT320試験案

- **目的:** 既知成功ベースラインと記述された160+160からEHT320候補へ試験する案。
- **結果:** README上、未転送・未実行。後日のQiita MLO成功はEHT320の証拠ではない。

## 2026-08-25 別L2 payload測定

- **結果:** 独自payload試験で約348–349 Mbit/s。TCP iperf3とは異なる測定。遅延・長時間安定性の統計値は未取得。

## 2026-09-25/26保存T6A復旧記録

- `/data`のseed archiveと`/data/sysupgrade.tgz`によるoverlay復元、cron/watchdogを使った鍵SSH復旧方式を記録。再起動2回後のSSH復帰を確認した記録がある。起動中の復元が遅く通常3〜4分待った。これは8月EasyMesh成功構成ではなく、別時期のT6A管理復旧。root password永続化の検証ではない。

## 2026-10-18 オフラインKnOS/SSH解析

- Private archiveの歴史的Bank A/Bを静的解析。interface hotplug/WAN再構成からfirewall reloadする経路、`knos_config`のsystem_mode条件付きpasswd/shadow symlink再設定とDropbear enable切替を確認。`knos_uci_revert`のfirewall revert箇所はあるが直接caller不明。
- procdのrcS runqueue完了からboot success flagへ進む経路を逆解析。120秒監視の対象flagを確認したが、遅延script特定は未完了。
- 実機変更なし。掲示板投稿者の個別SSH断を発火したプロセスは未特定。

## 後日管理状態（2026-10）

- `.13`は後日のT6A単独STA管理候補で、EasyMesh成功時`.2`とは別モード/時期。Windows ping報告だけでは現在のCodex到達性、SSH listener、個体同一性を示さない。
