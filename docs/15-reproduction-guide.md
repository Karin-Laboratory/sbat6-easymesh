# 15. 詳細再現マニュアル

## このガイドの適用範囲

対象は正当にroot管理できるSBAT6を2台用意し、EasyMesh Controller/Agent、Ethernet onboarding、6 GHz無線backhaul、Agent Ethernet側へのL2延長を段階的に追試する人である。root取得前の侵入、メーカーfirmware配布、秘密profileの共有は扱わない。記録は当時の機器/firmwareに対するもので、完全な成功時設定snapshotとControllerのrole変更コマンドは残っていない。したがって各段階は観測で分岐し、未復元箇所を推測で埋めない。

## 配線と役割

準備時は各機器を個別に管理できる接続を維持する。設定切替で管理IPやbridgeが変わる可能性があるため、作業用PCを唯一の復旧路にしない。

```text
準備:       管理PC ─ LAN ─ A             管理PC ─ LAN ─ B
有線参加:   上位LAN/Router ─ A(Controller) ─ Ethernet ─ B(Agent)
完成:       上位LAN/Router ─ A ))) 6 GHz BH ((( B ─ Ethernet ─ client
```

図は論理接続例。実験時の正確な物理LAN/WAN port番号は未復元。Controller側が上位LAN/DHCP側、Agentの有線側が延長先である。実際に配線する前に個体ごとのbridge membership、DHCP server位置、port roleを確認する。

## 設定が生成される場所

保存rootfs静的解析で確認した大枠は次の通り。

```text
/etc/mapd.uci ─ OEM uci2map conversion ─ /etc/config/mapd
/etc/map/mapd_default.cfg + mapd_user.cfg ─ prepare_mapd_config ─ mapd_cfg
                           └ prepare_1905_config ─ 1905d.cfg
kn_meshd (procd, START=99) → OEM preparation → wapp / p1905_managerd / mapd
```

`/etc/init.d/kn_meshd`は`/usr/bin/kn_meshd`をprocdで起動する。生成処理はroleに応じて`map_agent`/`map_root`や`p1905_managerd -r0`（Controller）/`-r1`（Agent）を構成する。ここで示すのは静的解析の生成関係で、利用者がdaemonや内部生成scriptを手動起動する手順ではない。`MapMode=1`ではWAN側interfaceをbridgeへ加える等のnetwork再構成があり、DHCP/管理IPが変化しうる。

入力側の編集・保存値と生成物・現在動作中の値を分ける。`mapd_cfg`や`1905d.cfg`だけの編集は次回daemon起動時に上書きされる可能性がある。生成元の完全な変更列は未復元。設定値一覧は[比較表](../configs/easymesh-values-matrix.md)を参照。

## 作業前の記録

1. 機器ラベル、hostname、型番、MAC末尾を手元の台帳で対応づけ、A=Controller候補、B=Agent候補を固定する。IPだけで個体を識別しない。
2. model、kernel、firmware/bank、radio/interface名、既存role/MapMode、bridge/route/DHCP状態を採取する。[診断script](../scripts/sbat6-diagnose.sh)は匿名化した読み取り専用レポートを作る。
3. A/B双方のSSH管理経路、root login、再接続可能な現在IPを確認する。historical `.2`, `.223`, `.247`, `.1`, `.13`は現在値ではない。
4. 設定退避をroot-onlyのローカル領域に作る。Qiitaに記録された対象は`/etc/config/mapd`, `/etc/map/mapd_default.cfg`, `mapd_user.cfg`, `mapd_cfg`, `1905d.cfg`。実験個体に存在するものだけを秘密保護された場所へコピーする。公開リポジトリや共有ログへ退避しない。
5. UART等、SSHと独立した復旧経路を確認する。なければrole/MapMode変更を開始しない。

## Controller/Agentの設定

当時の成功報告はA=Controller `DeviceRole=1`, B=Agent `DeviceRole=2`、両方`MapMode=1`。KnOS側`knos.network.easymesh=1`, `knos.flags.mesh=1`も成功時に観測された。値の読み取り例:

```sh
uci -q get knos.network.easymesh
uci -q get knos.flags.mesh
uci -q get mapd.mapd_user.DeviceRole
uci -q get mapd.mapd_user.MapMode
grep -E '^(DeviceRole|MapMode)=' /etc/map/mapd_user.cfg /etc/map/mapd_cfg
```

これらはread-only readback。保存記録で確認できた実験writerはAgent側の`wificonf -f /etc/map/mapd_user.cfg set DeviceRole 2`。Controller roleの認定script候補とMapModeのKnOS初期化writerは静的解析で見つかったが、成功実験で実行した証拠がない。KnOS flagを1にするwriterも未復元。詳細は[Controller](05-controller-setup.md)、[Agent](06-agent-setup.md)。

role/MapMode変更はネットワークを再構成しSSHを切る可能性がある。復旧経路を先に確保し、片側ずつ変更して状態を再採取する。変更後の管理IPが不明ならMesh失敗と判断せず、物理管理路、DHCP lease、neighbor table、consoleからIP/bridge状態を調べる。

## Ethernet onboardingと親子認識

両機をEthernetでつなぎ、OEM管理下のEasyMesh service起動を待つ。`wapp`, `p1905_managerd`, `mapd`の開始とIEEE 1905.1 discoveryを確認し、次の読み取りCLIをController上で実行する。CLI socketが存在する場合の照会例:

```sh
mapd_cli /tmp/mapd_ctrl getrole
mapd_cli /tmp/mapd_ctrl agent_list
mapd_cli /tmp/mapd_ctrl dump_topology
mapd_cli /tmp/mapd_ctrl dump_topology_v1
mapd_cli /tmp/mapd_ctrl bh_info
mapd_cli /tmp/mapd_ctrl bh_conn_status
mapd_cli /tmp/mapd_ctrl bh_conn_type
mapd_cli /tmp/mapd_ctrl get_bh_ap
mapd_cli /tmp/mapd_ctrl get_fh_ap
```

公開記事由来の成功観測はController distance 0、Agent distance 1、Agent role `02`、BH status 1/type 4、medium 6G。これは記事中の観測を要約した期待値で、fixtureも転記・正規化したもので生端末出力ではない。コマンド一覧と意味は[有線onboarding章](07-wired-onboarding.md)。`onboarding 0`等の状態変更CLIはこの手順では自動実行しない。

## 6 GHz backhaulへ移行

有線で親子認識した後に無線profileが生成される段階へ進む。SSID/PSKはローカルで秘匿管理し、実験当時の秘密値を公開資料から復元しようとしない。記事記録ではControllerの優先値は6G=1、5GL/5GH=2、2G=3、AutoBH=1。これは当時の値で、規制地域や別firmwareへの推奨ではない。

Agent側の`apcli0`=2.4 GHz、`apclii0`=5 GHz、`apclix0`=6 GHzという対応を確認する。報告された6 GHz観測はchannel 21、6055 MHz、160 MHz、4addr on、`apclix0` carrier=1、BH medium 6G、status 1/type 4。帯域やチャネルは地域規制と装置の現在状態に従う。

Ethernetを外す前後で topology、BH status/medium、APCLI carrierとRX/TX counterを記録し、さらにAgent Ethernet側clientのDHCP/ARP/gateway/疎通を確認する。carrier単独ではsuccessではない。[詳細手順](08-wireless-backhaul.md)、[L2検証](09-l2-bridge.md)。

## 再起動、戻し方、MLO

公開記事では`sync; reboot`後にEasyMesh/MLOが戻るまで約173秒を要した記録がある。再起動後の確認は同じtopology/BH/L2判定を取り直す。もしroleや設定が消えたら、runtime cfgと入力cfg、起動後の値を比較し、管理経路を復旧する。書き込み前に保存した個体の設定だけを用いて戻す。一般化したfactory resetやfirmware復旧手順はこの実験記録から安全に指定できない。

MLOは6 GHz単独BHの成功後に行う上級追加試験である。2-link成立条件、RSNE mismatchの訂正、security profile修正の限界は[MLO章](10-mlo.md)と[トラブルシューティング](25-easymesh-troubleshooting.md)を参照。EHT320は未検証。

## 再現範囲

根拠が揃っている観測手順と、完全な操作列が残っていない構築工程を分けた判定は[再現性coverage](26-reproduction-coverage.md)に記載する。Controller writerの静的所見と所有者向け未実機検証計画は[専用章](28-controller-writer-validation.md)、profileは[構造仕様](../configs/templates/README.md)、証拠の時間不整合は[chronology](27-evidence-chronology.md)を参照する。全工程をA（手順復元済み）と評価していない。
