# Controller (親機) の確認・再現手順

## 実験時の状態

2026-08-23公開成功記事のT6A AがControllerだった。確認値は`DeviceRole=1`, `MapMode=1`、`knos.network.easymesh=1`、`knos.flags.mesh=1`。Controller自身のtopology distanceは0。成功記事でController側に記録されたbackhaul値は次のとおり。

```ini
BhPriority6G=1
BhPriority5GL=2
BhPriority5GH=2
BhPriority2G=3
AutoBHSwitching=1
NtwrkOptMldBhPriority=1
```

これらは取得された実験時runtime値。全firmware用の推奨設定や、すべてを投入する完全な初期値セットではない。

## 設定値が有効になるまで

選定rootfs Bank A/Bの`EasyMesh_openwrt.sh`と記事内の生成関係を照合すると、構造は次のとおり。

```text
/etc/mapd.uci --default入力--> /etc/config/mapd (UCI; uci2map.lua)
                                      │
/etc/map/mapd_default.cfg ────────────┤
/etc/map/mapd_user.cfg (override) ────┴─> prepare_mapd_config()
                                             │
                                             ├─> /etc/map/mapd_cfg (runtime)
                                             └─> /etc/map/1905d.cfg (role/interface/bridge)
                                                      │
                         Wi-Fi profile / bridge / DHCP準備
                                                      │
                                      wapp → p1905_managerd → mapd
```

保存rootfsの`prepare_uci2map_files()`はdefault modeで`/etc/mapd.uci`を`/etc/config/mapd`へcopy後`/etc/uci2map.lua`を呼ぶ。続く`prepare_mapd_config()`はdefault cfgとuser overrideからruntime cfgを作り、`prepare_1905_config()`はroleを読んで`map_root`/`map_agent`、LAN/WAN/bridge情報をruntime `1905d.cfg`へ反映する。MapMode=1のbranchはbridge modeとしてWAN interfaceをbridgeへ加える処理を持つ。従って起動後に生成された`mapd_cfg`や`1905d.cfg`だけを変更しても、次の起動で元の入力から戻ることがある。

procdが`kn_meshd`を起動し、OEM scriptがこれらの生成とradio/network準備を行う。個別daemonを手作業で起動したり、`EasyMesh_openwrt.sh`を直接再実行したりしない。scriptにはinterface、bridge、daemon、firewall等への副作用がある。

## 事前確認

```sh
uci -q get mapd.mapd_cfg.DeviceRole
uci -q get mapd.mapd_cfg.MapMode
uci -q get knos.network.easymesh
uci -q get knos.flags.mesh
grep -E '^(DeviceRole|MapMode|BhPriority2G|BhPriority5GL|BhPriority5GH|BhPriority6G|AutoBHSwitching|NtwrkOptMldBhPriority)=' /etc/map/mapd_user.cfg /etc/map/mapd_cfg 2>/dev/null
ps w | grep -E '[m]apd|[p]1905_managerd|[w]app'
```

期待値はrole 1/mode 1、KnOS flags 1。公開したのは必要keyのみの表示で、`uci show mapd`や`cat mapd_user.cfg`の全出力はprofile情報を含み得るので共有しない。

## Writer探索結果と再現手順の境界

| 設定 | 成功値 | writer / 書込先 | 永続化・上書き | 実験での実行実績 |
|---|---|---|---|---|
| `DeviceRole` | `1` | 保存rootfsの`map_cert_script.sh`に`Role=1`かつOpenWrt SDK branchがあり、`datconf -f /etc/map/mapd_user.cfg set DeviceRole 1`を記述。これは認定用scriptのwriter候補 | `mapd_user.cfg`からOEM生成処理が`mapd_cfg`へ反映し、`1905d.cfg`に`map_root=1`, `map_agent=0`を生成 | 成功値は記事で確認。認定script writerが本実験で実行された証拠なし。`datconf`と記事中の`wificonf`が同一の動作とは未確認 |
| `MapMode` | `1` | 保存rootfs `99-zknos-default-setting-official-0201.mesh`の`change_mapd()`が`knos.network.easymesh=1`時に`mapd.mapd_cfg.MapMode`と`mapd.mapd_user.MapMode`を`1`へ設定し、scriptは`uci commit mapd`を呼ぶ | この特定のKnOS初期化経路ではUCI commit。EasyMesh起動scriptはruntime設定を生成し、MapMode 1でbridge/network処理を行う | 静的コード経路を確認。成功実験でその初期化経路を実行した正確な時系列は未取得 |
| `knos.network.easymesh` | `1` | 成功記事でreadback値。探索したrootfs本文ではpositive writerを特定できず。`uci-revert` scriptに`0`へ戻すwriterは存在 | UCI値をEasyMesh起動scriptが読む。KnOS revertで0に戻る可能性 | 成功値のみ確認。設定を1にした実験コマンドは未復元 |
| `knos.flags.mesh` | `1` | default-setting scriptは前回設定からdefaultを引き継ぐが、1へ設定するwriterは対象rootfsテキスト検索で未発見 | KnOS UCIの初期化/restore経路に依存。EasyMesh scriptが読む直接値としては確認できていない | 成功値のみ確認。writer/commit/再起動後readbackは未復元 |

### 何を追跡し、何が残ったか

オフラインで選定Bank A/Bの`/usr/bin/EasyMesh_openwrt.sh`, `/etc/init.d/kn_meshd`, `/usr/bin/kn_meshd`, `/etc/uci2map.lua`, `/etc/mapd.uci`, `/etc/config/mapd`, `/etc/map/{mapd_default.cfg,mapd_user.cfg,mapd_cfg,1905d.cfg}`、UCI defaults/revert、`map_cert_script.sh`を調査した。`prepare_mapd_config()`は設定入力からruntime `mapd_cfg`を作り、`prepare_1905_config()`はruntime roleを読み`map_root`/`map_agent`とbridge/interface値を生成する。procd管理の`kn_meshd`からOEM sequenceが起動される。

Controller用`DeviceRole=1`を実験で最初に書いたコマンドと時刻は残っていない。認定scriptにwriter候補は存在するが、別の検証用scriptであり、成功実験の操作列に結び付けられないため、実行手順には採用しない。KnOS flagのpositive writerもファイル検索で未発見。足りない証拠は実験者の当時shell history/console log、対象build上のKnOS UI/API writer、再起動前後の該当UCI readbackである。

### 所有者向けの未実機検証手順

この節は**静的解析から導いた検証計画**で、未実機検証である。現在の対象個体を確認し、独立復旧路、個体専用backupとrollbackを準備した後、所有者が別途明示的に許可した場合だけ実機で行う。ここではrole/MapMode/flagを一括変更する実行コマンドを提示しない。

1. 対象buildのUCI schemaと実際のKnOS writerを特定し、上表のwriterと一致することを確認。
2. `uci -q get mapd.mapd_cfg.DeviceRole`, `uci -q get mapd.mapd_user.DeviceRole`, 同MapMode両値、`uci -q get knos.network.easymesh`, `uci -q get knos.flags.mesh`を変更前に採取。
3. root-only backupを取得し、別consoleから設定を戻す具体的な操作を確認。
4. 一項目ずつ、対象buildで確認したwriterを通して変更。変更直後に入力UCIと`uci commit`後のreadbackを確認。
5. OEM起動処理後に`mapd_cfg`/`1905d.cfg`のrole反映を確認。daemonを直接起動しない。
6. 独立経路を保った状態で再起動し、全入力値・runtime値・topologyの保持を再確認。
7. 差分が期待と異なるか管理路が失われたら追加変更を中止し、backupから対象個体だけ復旧。

これは正常な設定を確認するための計画であり、今回の作業では実機に変更を加えていない。判定は[coverage表](26-reproduction-coverage.md)と[Controller検証計画](28-controller-writer-validation.md)に整理する。

設定を永続化するMLO段階でも、`wireless` UCIの値だけではprovisioningにより書き戻される事象を確認した。入力sourceと生成runtimeを照合してから一項目ずつ扱う。

## 起動後のController確認

有線onboarding後、A側でread-only確認:

```sh
mapd_cli /tmp/mapd_ctrl getrole
mapd_cli /tmp/mapd_ctrl agent_list
mapd_cli /tmp/mapd_ctrl dump_topology
mapd_cli /tmp/mapd_ctrl dump_topology_v1
```

本人記事で報告された要約はController role 01/distance 0、Agent role 02/distance 1。これはIEEE 1905.1全packet traceではない。出力のMAC/BSSIDを公開する前に匿名化する。

保存rootfsのController branchは`DeviceRole=1`の場合に`map_agent=0`, `map_root=1`を`1905d.cfg`へ書き、`p1905_managerd -r0`を起動する。Agent branchでは`map_agent=1`, `map_root=0`, `p1905_managerd -r1`。`-r0`はこのOEM script内でController roleに対応しているが、daemonだけを単独起動する指示ではない。

## 失敗時

1. topologyにAgentがなければBのDeviceRole/MapModeとdaemonを確認。
2. topologyは正常だがSSH/IPv4不可ならDHCP/bridge/IPを別調査。
3. Ethernet中にwireless BH metricが出ない場合、Ethernet優先状態か確認。
4. Controller設定値が起動後に戻る場合、runtime cfgではなく`/etc/mapd.uci`, `/etc/config/mapd`, default/user cfgとKnOS writerのどれが生成入力か特定。
5. firewallやSSHが変化した場合、[SSH/KnOS診断](18-ssh-firewall-persistence.md)へ。Topology失敗と即断しない。

この章にないController初期投入・完全Wi-Fi profile・port割当を復元した設定として扱わない。再現の実行順は[クイックスタート](24-easymesh-quickstart.md)、証拠の網羅性は[coverage表](26-reproduction-coverage.md)。
