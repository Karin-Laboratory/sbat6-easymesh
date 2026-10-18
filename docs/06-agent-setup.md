# Agent (子機) の確認・再現手順

## 成功時の状態

2026-08-23の本人公開記事ではT6B BがAgent、`DeviceRole=2`, `MapMode=1`。Controller topologyはDevice role `02`, distance `1`。6 GHz単独BH成功後のAgent報告は`bh_conn_status=1`, `bh_conn_type=Type 4`、6 GHz `apclix0` carrier up。

## 記録されたrole変更

記事に記録されたAgent側writer:

```sh
wificonf -f /etc/map/mapd_user.cfg set DeviceRole 2
```

このコマンドは`mapd_user.cfg`へrole overrideを書き込む変更操作。実行前に[Step 4 backup](24-easymesh-quickstart.md#step-4--変更前設定をroot-onlyで保全)と独立復旧経路を用意し、対象がBであることをラベル/hostname等で照合する。

```sh
grep -E '^(DeviceRole|MapMode)=' /etc/map/mapd_user.cfg
uci -q get mapd.mapd_cfg.DeviceRole
uci -q get mapd.mapd_cfg.MapMode
```

**期待状態:** user input/起動後runtimeの双方で`DeviceRole=2`, `MapMode=1`。最初のコマンド直後には生成runtime cfgがまだ古いままでもあり得る。記事では永続値を整えた後に通常rebootしてOEM起動sequenceを使った。

Agent役割を作る正確なMapMode=1 writerは残っていない。異なる値の場合はroleだけ変えて続行せず停止する。

## DHCP、bridgeと管理IP変化

OEMの`EasyMesh_openwrt.sh`はruntime `DeviceRole`/`MapMode`を読み、`1905d.cfg`のroleとnetwork/bridge情報を作る。MapMode 1のbridge branchでは`wan_iface`をbridgeへ加える処理がある。後続Agent runtime snapshotでは`network.wan.proto=none`, `dhcp.lan.ignore=1`, `br-lan`を使う状態が記録されるが、これら全てが8月の最初の6 GHz成功時に同一設定だった完全証拠はない。

### 変更前に記録する (各機でローカル確認)

```sh
ip -br addr
ip route
brctl show 2>/dev/null || bridge link
uci -q get network.wan.proto
uci -q get dhcp.lan.ignore
```

IPを共有する場合はmaskし、管理経路とdefault gatewayをローカル保全する。DHCP serverの位置は上位router/Controllerのどちらかを実験配線で明示する。

### DHCP/管理IPが見えなくなったとき

- 旧IPv4 ping失敗はAgent化失敗を意味しない。
- topology distance 1、BH medium/type、Agent bridge、DHCP leaseを別々に見る。
- 成功記事のB `.223`、別snapshot `.247`、T6A補助`.1`、後日STA`.13`はそれぞれ別文脈。固定設定として流用しない。
- DHCP lease server、bridge membership、ARP/neighborが保存されていない範囲は追試で記録する。
- console/別管理がなくなった場合に`MapMode`やnetworkを追加変更しない。

## Agent daemon/roleの判定

```sh
ps w | grep -E '[m]apd|[p]1905_managerd|[w]app'
mapd_cli /tmp/mapd_ctrl getrole
mapd_cli /tmp/mapd_ctrl bh_conn_status
mapd_cli /tmp/mapd_ctrl bh_conn_type
mapd_cli /tmp/mapd_ctrl bh_info
```

保存rootfs上ではAgent role branchが`map_agent=1`, `map_root=0`と`p1905_managerd -r1`を選ぶ。これはOEM起動scriptがruntime configから作る結果であって、直接`p1905_managerd -r1`を起動するコマンドではない。

| 観測 | 読み方 |
|---|---|
| Role 2、Controller topologyにdistance 1 | 親子のcontrol-plane認識を確認 |
| `bh_conn_status=1`, `Type 4` | BH state/typeが報告された。mediumも併せて調べる |
| `br-lan` IPなし/旧IP無応答 | DHCP/bridge管理面の問題候補。topologyは別判定 |
| `apclix0`が存在 | interfaceがあるだけ。associationや通信の証明ではない |

## MLO段階の差分

5+6 GHz MLOで追加したSTA MLDは`apclii0 apclix0`, primary `apclix0`, MLD group 1。成功したprofileではSAE/PMF requiredを用いた。これは6 GHz単独BHを作る初期設定ではない。既存provisioned BH profileの秘密をローカルで引き継いだため、PSK/SSIDは公開しない。詳しくは[MLO章](10-mlo.md)。

完全なwireless credentials、UCI section IDの個体差、初回Agent onboardingの全変更ログがないため、role変更以外のnetwork設定をこの章で一括投入しない。
