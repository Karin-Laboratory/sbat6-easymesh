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

## 永続設定の変更について

- Controller成功値`DeviceRole=1`の確認はあるが、Aを初めてrole 1へした正確なwriter command/順序は復元できていない。
- BのAgent化については[Agent章](06-agent-setup.md)に記録された`wificonf -f /etc/map/mapd_user.cfg set DeviceRole 2`が記事にある。
- Controller priority値の完全な変更コマンド列と、各値の成功時永続入力ファイルの対応は未復元。値を見て`wificonf`/`uci set` commandを創作しない。
- EasyMesh UCI flagsは成功時すでに1。falseをtrueに変える正確な作業・rollback記録がないため、異なる機器で0なら止めてbuild-specific writerを調べる。

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
