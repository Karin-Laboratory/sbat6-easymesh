# 実験タイムライン

> ホスト側のworktree更新時刻とファイルの相互関係で日付を整理した。内部capture名の年月日や端末epochには不整合があるため、細かい時刻は確定できない。根拠ファイルは [SOURCES.md](../SOURCES.md) に記載。

## 2026-08-23前後（管理経路の準備）

- **目的:** B号機にも独立した管理経路を作り、二台の検証を可能にする。
- **変更/試行:** Web UI経由のコマンド実行とSSH開通用のbootstrap/Dropbear/限定firewallスクリプト群を準備・改訂。
- **結果:** 管理SSHが最初から存在したAと異なりBのroot SSH確立が別タスクになった。該当スクリプト群のホスト側更新時刻は8月23日。全SSH確立手順・失敗順序のログは未取得。
- **判定:** 部分的成功。Meshの成否ではない。

## 2026-08-23（EasyMesh後のMLO調査と復旧準備・再起動追跡）

- **目的:** A/BのMesh BHに関連する5/6 GHz MLO設定を検討し、状態遷移を追う。
- **変更:** T6A側 `DeviceRole=1`, `MapMode=1`、T6B側 `DeviceRole=2`, `MapMode=1` を前提としてassert。T6A BH AP MLD (`rai2 rax2`) とT6B BH STA MLD (`apclii0 apclix0`) の設定差分を用意し、5 GHz側を`EHT160`とする。
- **観測:** `mapd`/`wapp`/`wpa_supplicant` の状態・strace・logreadのcapture群、stability samplerが保存された。生ログは秘匿性/個体識別のため公開していない。
- **結果:** MLO関連作業と観測が行われたことは保存データから確認。安定した二帯域MLO実データリンク/改善性能の範囲は確定できない。
- **再起動後の追跡:** B snapshotで `192.168.3.247/24`, role 2, mode 1 とwireless/mapd関連の保存hashは再起動前後で一致した。一方、起動中のSTAはpreで`apclix0`、postで`apclii0`がUP。これはMLO関連状態の変化を示すが、元の6 GHz BH成功構成が切れた証拠とは限らない。ファイル名は`2026-07-21`を含む一方、ホスト更新日時は8月23日で、端末epochも不一致のため、厳密な実験日と前後順は確定しない。
- **次:** 設定永続性とdaemonのteardown/再生成の挙動を調査。

## 2026-08-24前後（6 GHz BHとL2延長成功、EHT320案）

- **目的:** 有線オンボーディング後に無線BHへ移し、ケーブルを外してもAgent配下通信を保てるか確認。
- **変更:** 6 GHz EasyMesh BHへ移行し、T6B Ethernet配下クライアントを接続。
- **観測:** Controller Distance 0、Agent Distance 1。Ethernet切断後も6 GHz BHおよびクライアントから上位LANへの通信が維持された。
- **結果:** 実験の主要成功。具体的なCLI全文、lease表、全link metricは公開資料から回収できず、実値を補わない。
- **追加:** EHT320の安全なsnapshot/apply/rollback/failsafe案を作成。READMEで実機未転送・未実行と明示。

## 2026-08-25（L2の短時間測定）

- **目的:** L2延長経路に独自frame sender/receiverを流す。
- **観測:** max試行のTX 87,094 frames/130,641,000 bytes/348 Mbit/sと、別のbatchfix試行のTX/RX各29,120 frames/43,680,000 bytes/349 Mbit/sを保存。
- **結果:** tool-reported payload rate。TCP/iperf3、遅延、長時間安定性の値ではない。

## 2026-08-31以降（T6A個別管理・受動調査）

- **目的:** EasyMesh実験後のT6Aについてセルラー・daemon・無線管理を別途調査。
- **変更:** 受動調査や独立STA管理経路の設定を行った記録が後日アーカイブされた。
- **注意:** 後日の単独STA接続や管理IPは、8月のController/Agent/L2延長状態と混在させない。

## 2026-09-25〜26（Private archive snapshot）

- EasyMesh実験ではなく、選択ファイル/partitionのoffline snapshot。全43 partitionの完全dumpではない。

## 2026-10-18（管理経路に関する後日記録）

- Private archiveにWindowsからの新管理IP候補pingと旧raspi2リンク状態が記録される。これは現在の個体身份や8月のMesh状態を証明しない。
