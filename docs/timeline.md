# 実験・記録タイムライン

実験イベント時刻、capture内端末clock、ファイル名、host mtime、Web公開日を分けて並べる。イベント日時が未確定のものは、公開/整理された日で代用しない。詳細な日付比較は[証拠chronology](27-evidence-chronology.md)。

## EasyMesh 2台構成・6 GHz BH・L2延長（イベント日時は未確定）

- **目的:** SBAT6 A/BをController/Agentにして、有線onboardingから6 GHz無線backhaulへ移行し、Agent Ethernet側へL2延長。
- **公開報告:** 本人Qiita記事の公開/更新日は2026-08-23。記事内の実験イベントの独立timestampは確認できない。
- **役割/成功値:** T6A A Controller `DeviceRole=1`; T6B B Agent `DeviceRole=2`; 両方`MapMode=1`; KnOS flagsは双方1と報告。
- **手順/確認:** 先にEthernetでonboarding/IEEE 1905.1 discoveryを確認し、`mapd_cli` topology/BH状態を観測。その後Ethernetを外して6GHz APCLI、BH、配下端末通信を確認。
- **観測報告:** Controller距離0、Agent距離1、Backhaul Medium Type 6G、Agent `bh_conn_status=1`, `bh_conn_type=Type 4`。報告された無線値はchannel 21 / 6055 MHz / 160 MHz / 4addr on。Ethernet抜線後APCLI counterとL2通信を確認したと記事にある。
- **性能:** 本体endpointの6GHz単独TCP測定はA→B約350 Mbps、逆方向約330 Mbps。歴史的endpoint値は[監査表](23-publication-audit.md)に掲載し、汎用コマンド例では使用しない。[性能章](11-performance.md)では空の設定変数を使う。
- **根拠:** Qiita本人公開記事。生のCLI output/captureによる独立全行再解析とは区別する。

## MLO capture群（device-local clock表記: 2026-02-28〜03-01 JST相当）

MLO capture群はfilename内日付と内部`start_epoch`がdevice-local clock上で2/28〜3/1 JSTに整合する。clock offset/NTP記録がないため絶対calendar dateは確定しない。local host mtimeとRUNBOOK見出しは8月23日。後日まとめた文書日付をcaptureの実験日としない。

- **19:02頃から23:40頃まで複数capture:** MLO leave/RSNE/security修正試験。初期2-linkが約109 msで解体し、M3時点RSNE mismatch/ reason 1 deauthを保存traceが示す。初期の`DISABLE_NETWORK`仮説は後続syscall traceで否定。
- **原因:** 5GHz BH BSSのWPA2/PSK・PMF optionalと、6GHz SAE・PMF requiredのRSNEが不一致。UCIだけの変更はEasyMesh runtime profileで戻った。
- **修正:** EasyMesh側のprofile元/WTS BSS info id=6 authmodeを合わせ、実効5GHz/6GHz条件をSAE/PMF requiredへ統一した後、M3/4-way handshake成功とconnectedを記録。hex authmodeを一般設定値としては公開しない。
- **安定確認:** `mlo-stability-success`内包metaのstart epochはdevice-local clock上で2026-02-28 23:40:08 JST相当、captureは464秒の安定観測を報告。外側archive名`234815`は開始時刻`234008`と異なる。wall-clockの絶対日付は未検証。
- **判定:** MLD `ref_cnt=2`, `band_idx=1/2`、両link counterの増加を確認した記録。日付由来は[chronology](27-evidence-chronology.md)参照。

## post snapshot内のdevice-local epoch（2026-03-01 00:11:51 JST相当）

- reboot persistence filenameには`20260721-124656`が含まれるが、timezone未記録、host mtimeは2026-08-23。
- post fileの一箇所にepoch `1772291511`（2026-03-01 00:11:51 JST）がある。baseline/postの一貫した時刻軸や、2月MLO安定captureとの関係は未確定。
- `.247`等の値は別snapshotの観測として扱う。8月記事の`.223`から連続したDHCP変化とは断定しない。

## 2026-08-23 (Web記事公開/更新、RUNBOOK見出し・host mtime)

- 本人QiitaでEasyMesh/6GHz BH/MLO成功を報告。これは公開日であり、全実験の実施日を証明しない。
- Private/local `sbair6-rce/RUNBOOK.md`のMLO sectionsは同日見出し、host mtimeも同日。この文書が2月metadataのcaptureを参照するため、実験記録と後日編集を区別する。
- Qiitaは通常reboot後のMLO復帰を報告: DHCP約170秒、EasyMesh再参加約173秒、少なくとも342秒MLO継続。再起動後の成功報告を保持するが、capture日時の不整合を解決したものとは扱わない。

## 2026-08-24/25 (host work記録)

- **8/24 EHT320案:** READMEでは160+160を既知成功baselineと記載。EHT320 test scriptは未転送/未実行。320 MHzのオンエア成立は未確認。
- **8/25 L2 payload:** 独自payload試験約348–349 Mbit/s。iperf3 TCPと別方式。遅延・長時間安定統計なし。

## 2026-09-25/26 (T6A SSH管理経路復旧)

- `/data` seedと起動時one-shot overlay復元、cron/watchdogを用いたSSH鍵認証の復旧を保存runbookが記録。2 reboot後に鍵SSHが戻った実機報告。
- 8月EasyMesh/MLO構成とは別の復旧作業。root password永続化成功の証拠ではなく、一般向けに実行手順を公開しない。

## 2026-10-18 (Private archive commit / source整理)

- Private archive HEAD `2725c5487a818e4b655bb868326f973c4d9e14ba`。commit日は資料の収録/編集時刻であって元の機器実験日ではない。
- KnOS/SSHの静的解析資料と復旧runbookをarchive historyから照合。10/18個別SSH断の発火sourceは確定できていない。

## 2026-10-19 (公開版v1.0監査)

- Controller writer候補、MapMode初期化経路、KnOS flagの未発見範囲を静的解析から記載。
- 公開profile templateの代わりに、秘密値や未復元schemaを含まない構造仕様を作成。
- capture/host/document dateを分け、A/B IP履歴を現在の接続手順から排除。機器接続・変更なし。
