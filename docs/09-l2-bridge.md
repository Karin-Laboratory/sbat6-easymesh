# Agent Ethernet側へのL2延長の確認

## 成功報告と証拠範囲

本人公開記事は、6 GHz wireless BH状態でT6B側Ethernet portに接続したclientから上位LANへ実IP trafficが通ったと報告する。概念構成:

```text
DHCP server / 上位LAN
        │
  T6A Controller (LAN/bridge)
        ))) 6 GHz EasyMesh BH (((
  T6B Agent (br-lan)
        │ Ethernet port
  PC-B / client
```

当時のLAN/WAN port番号、full `brctl show`, DHCP lease list, ARP table, VLAN IDは公開できる状態で保存されていない。従って具体的なphysical port mappingや全L2機能透過を保証しない。

## 試験前に調べる

Agent側でread-onlyに現在bridgeとaddressを記録する。識別子を共有する時はmaskする。

```sh
brctl show 2>/dev/null || bridge link
ip -br addr
ip route
ip neigh show
```

bridgeが`br-lan`でも、Agent Ethernet portが実際のmemberであることをlink/interfaceで確認する。保存rootfsのMapMode 1 init pathはbridge構成を再生成し、`wan_iface`をbridgeへ追加する処理を含む。設定名からport functionを推測しない。

DHCP serverは上位LANにどの機器がいるか実配線で特定する。mapd roleを変えるとvendor boot pathがDHCP/network serviceを調整し得る。Agentの管理IPが変化してもL2 BH状態とは別問題。

## data-plane検証順

### 1. Cableありbaseline

Agent Ethernet clientから現在のDHCP lease、subnet、default gateway、ARP neighborをローカル記録する。DHCP server leaseとAgent `br-lan` addressを同じ時刻に採る。IPは履歴値を流用せず現在のleaseから取得。

### 2. EasyMesh/BH control-plane

Controller topology、Agent role/distance、Agent `bh_conn_status/type`を記録してからEthernet cableを抜く。6 GHzだけの条件が必要な場合、他Ethernet pathが残っていないことを確認する。

### 3. Cableなしclient traffic

Agent側clientから上位側clientへ両方向で疎通を確認。`ping`はIP到達の一指標であり、必要ならDHCP renewalを行ったclient lease、ARP entry、gateway、subnet、TCP applicationを個別に確かめる。DHCP client/serverに新規設定を書き込む試験は現行networkを理解し、別復旧経路がある時だけ行う。

### 4. radio counter

```sh
for i in apcli0 apclii0 apclix0; do
    printf '%s ' "$i"
    cat "/sys/class/net/$i/operstate" "/sys/class/net/$i/carrier" 2>/dev/null
    cat "/sys/class/net/$i/statistics/rx_bytes" "/sys/class/net/$i/statistics/tx_bytes" 2>/dev/null
done
```

期待状態は成功記事時の6 GHz単独BHなら`apclix0`のcarrier/linkとbytesの増加。他APCLIも同様にupなら自動的に失敗という意味ではなく、実際のBH medium/topologyで使用radioを確認する。

## iperf3の方法と解釈

本体endpoint測定と外部PC間測定を分離する。

### SBAT6自身がendpoint

公開記事の例ではB側server、A側clientを使い、4 stream / 20秒で双方向を測った。管理IPはその記事時点の値を使用していたため、別の追試ではcurrent lease/routeでserverを特定する。測定結果は6 GHz単独でA→B約350 Mbps、B→A約330 Mbps、別記録では約300 Mbpsの回がある。後続MLO実験でのrouter endpointはおよそ330–380 Mbpsだった。

### Ethernet PC間

MLO成功後の別試験は、両SBAT6の外側に1GbE PCを接続し、PC間で測った。結果は1 stream 936/909 Mbps、10 stream 941/908 Mbps。これはWi-Fiだけの上限でなく1GbE/CPU/TCPを含むこの経路の値。

一般的な再測定の形:

```sh
# PC-B (Agent側)
iperf3 -s

# PC-A (Controller側)
PC_SERVER_IP=''
: "${PC_SERVER_IP:?PC-Bの現在IPを確認して設定する}"
iperf3 -c "$PC_SERVER_IP" -t 20 -P 1
iperf3 -c "$PC_SERVER_IP" -t 20 -P 1 -R
iperf3 -c "$PC_SERVER_IP" -t 20 -P 10
iperf3 -c "$PC_SERVER_IP" -t 20 -P 10 -R
```

PC-Bのserverを起動し、PC-A側で実環境のIPを`PC_SERVER_IP`へ手動設定してから測る。空値のままでは中止する。これらは一般的なiperf3再測定例で保存した成功時フルcommand transcriptではない。起動中のiperf3 serverは実験後停止し、試験portを外部/WANへ公開しない。

## L2成功の限界と失敗時

- **実機確認報告:** cableなしでAgent配下clientから上位LANへ通信、radio counter/BH statusと合わせて成功。
- **追加実測が必要:** 全VLAN tag、broadcast/multicast、DHCP relay全条件、MTU/Jumbo frame、長時間/障害復旧。
- BH control状態は正常だがDHCPなしならserver/lease/subnet/bridge memberを確認。
- DHCP成功だがpeer TCP不通ならARP、route/gateway、firewall、bridge FDBを確認。
- Ethernet抜線後にBH/topologyも消えるなら[wireless BH章](08-wireless-backhaul.md)へ戻る。
- ping/SSHだけ失敗するなら[Agent管理IP](06-agent-setup.md)と[トラブル表](25-easymesh-troubleshooting.md)でcontrol/data planeを分ける。
