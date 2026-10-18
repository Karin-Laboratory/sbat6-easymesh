# Ethernetから6 GHz EasyMesh backhaulへ移行

## 同一試験で組み合わせた成功証拠

2026-08-23本人公開記事の6 GHz単独BH成功は、次の各層の観測を組み合わせる。

| 層 | 当時の報告値 | 成功判定上の意味 |
|---|---|---|
| EasyMesh topology | Controller distance 0 / Agent distance 1 / `Backhaul Medium Type: 6G` | ControllerからAgentが6 GHz BHとして認識された |
| Agent BH CLI | `bh_conn_status=1`, `bh_conn_type=Type 4` | mapd runtimeがBH接続を報告 |
| Agent APCLI | `apcli0`/`apclii0` down; `apclix0` UP/LOWER_UP, carrier=1 | 実験FWでは6 GHz STA VIFに対応 |
| radio情報 | channel 21 / 6055 MHz / 160 MHz / 4addr on | 本人記事の同一成功記述にあるradio条件 |
| data plane | Ethernetを抜いた後もAgent Ethernet配下clientから上位LANへ通信、T6 endpoint iperf3数百Mbps | BH linkだけでなく実通信を確認 |

これらは同じ記事内の成功要約で、公開独立raw RF captureはない。READMEや技術章で「実測報告」として引用する。channel/widthはこの実験時の値であり、読者の国・規制・firmwareを超えて固定設定に使わない。

## 実験順の復元

### 1. 有線BH/親子認識を先に作る

[有線onboarding](07-wired-onboarding.md)に従い、AgentがController topologyに出てdistance 1になることを確認。ここで失敗したらwireless APCLI設定へ進まない。

### 2. profileと優先値を照合する

設定ファイル本文を共有せず、以下の個別キーだけを確認する。

```sh
grep -E '^(BhPriority2G|BhPriority5GL|BhPriority5GH|BhPriority6G|AutoBHSwitching)=' /etc/map/mapd_user.cfg /etc/map/mapd_cfg 2>/dev/null
```

成功時Controller runtime記録は2.4G=3、5G low/high=2、6G=1、`AutoBHSwitching=1`。profileのSSID/PSK/BSSID、無線profileを生成した全操作列は公開/保存確認できていない。既存provisioned profileとController/Agent間のcredential整合が確認できない場合は抜線しない。

### 3. Ethernetが残った状態のbaseline

```sh
mapd_cli /tmp/mapd_ctrl show_bh_link_metric
mapd_cli /tmp/mapd_ctrl bh_conn_status
mapd_cli /tmp/mapd_ctrl bh_conn_type
```

保存した後日Agent救出ではEthernet中に`No Bh link Info as this device is connected via Ethenet.`が返り、APCLIがdownだった。この状態はEthernet primaryである可能性があり、それ単独で失敗ではない。

### 4. Ethernetを切断し、自動fallbackを見る

変更前にserial/別管理経路、現在のDHCP/管理経路、戻せるLAN cableを用意する。Cable cut自体はEasyMesh CLIより物理Ethernet pathを変える。無線へ移るまで待ち、途中でrole/MapMode/firewallを追加変更しない。

Agent上のread-only採取:

```sh
mapd_cli /tmp/mapd_ctrl getrole
mapd_cli /tmp/mapd_ctrl bh_conn_status
mapd_cli /tmp/mapd_ctrl bh_conn_type
mapd_cli /tmp/mapd_ctrl bh_info
mapd_cli /tmp/mapd_ctrl dump_topology
for i in apcli0 apclii0 apclix0; do
    printf '%s: ' "$i"
    cat "/sys/class/net/$i/operstate" "/sys/class/net/$i/carrier" 2>/dev/null
    cat "/sys/class/net/$i/statistics/rx_bytes" "/sys/class/net/$i/statistics/tx_bytes" 2>/dev/null
done
```

現行[診断ツール](../scripts/sbat6-diagnose.sh)もこれらのstatusを必要最小限で出す。期待値はAgent role2、status1、type4、topology distance1/6G、`apclix0` carrier1とcounterの増加。APCLI carrierだけ、またはSSIDが見えるだけでは不足。

### 5. L2/data-planeを確認

Agent側Ethernet clientからController側上位L2への疎通を検証する。DHCP/ARP/neighbor/gatewayの確認手順は[L2章](09-l2-bridge.md)。別方向も測る。client communicationが切れても、serial/Agentでtopology/BHを別確認し、management IPのみの変化か見分ける。

## 帯域fallbackと再接続

保存優先順位はController側で6 GHz優先、5 GHz次、2.4 GHz最後。6 GHz障害時にどの時間/DFS/遮蔽条件で各帯域へfallbackするか、長期自動reconnect、channel changeからの復帰は網羅試験されていない。`AutoBHSwitching=1`だけで全条件の切替保証としない。

## 観測差の読み方

後日保存された別試験では、Ethernet BH中に`show_bh_link_metric`がnoneを返す。保存runbookは物理ケーブル抜線後の6GHz failoverを「未実施」と記す。この後日救出状態を、8月記事の成功証拠に転用しない。各結果の時期とmodeは[時系列](timeline.md)を照合する。

## 失敗時

- Agentなし/distance不正: [onboarding](07-wired-onboarding.md)に戻りrole/daemon/wired linkを確認。
- role/topology維持、APCLI/medium不正: profile/security/radio priorityを調査。完全なcredentialsはここにないため値を推測しない。
- BH状態正常、管理SSH/IP不可: DHCP/bridgeを分離して確認。
- 端末間data不通: Agent portのbridge membership、DHCP server/lease、ARP/neighbor、APCLI counterを記録。
- 無線を戻せない/管理経路消失: Ethernetを再接続し、独立管理経路で復旧。factory resetやdaemon手動killは行わない。
