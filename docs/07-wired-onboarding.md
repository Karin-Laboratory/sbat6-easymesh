# Ethernet onboardingとIEEE 1905.1親子認識

## 有線から始めた理由

まずEthernet上でController/Agentのdiscoveryとtopologyを確認し、その後に無線backhaulへ移行すれば、IEEE 1905.1 control-plane発見とWi-Fi association/BHの問題を分離できる。成功記事では有線接続時にT6BがAgentとして認識された後、Ethernetを外している。物理port番号と上位routerを含む完全な配線写真は保存されていないため、WAN/LAN名やport番号を推測しない。

## CLI確認コマンドと出力の扱い

次のコマンドは記事が診断用途で列挙したCLIで、いずれも状態変更コマンドと区別する。CLI版によって未実装のsubcommandがあれば`unknown`/usage表示として扱い、別名を推測で連続実行しない。

| Command | 実行対象 | 記録上の用途/期待 | 出力・失敗時 |
|---|---|---|---|
| `mapd_cli /tmp/mapd_ctrl getrole` | A/B各local control socket | local device role確認。記事の数値表記は`dev_role 2`; vendor表示は`DeviceRole (0: Auto 1:Controller 2:Agent)` | 0=Auto,1=Controller,2=Agentの対応は保存scriptの文字列で確認。成功記事ではController1/Agent2 |
| `... agent_list` | Controller | 認識済Agent一覧 | 保存された要約はAgentが現れると報告。完全な個体出力は公開なし。空ならAgent role/daemon/ethernetを照合 |
| `... dump_topology` | Controller | 親子distance、role、BH medium | 本人記事の報告形式: `Device role: 02`, `Distance from controller: 1`, `Backhaul Medium Type: 6G`; Controller distance 0 |
| `... dump_topology_v1` | Controller | topologyの別version表示 | commandの利用は記事にあるが、独立した完全出力例は未保存。出力は要約扱い |
| `... bh_info` | local device | backhaul情報 | queryは使われたが成功時の全行・各機での実行先は未確定。status/typeと併せて確認 |
| `... bh_conn_status` | Agent | BH接続status | 成功記事: `backhaul connection status 1` |
| `... bh_conn_type` | Agent | BH種別 | 成功記事: `backhaul connection Type 4` |
| `... get_bh_ap` | local device | BH AP情報 | query名のみ復元。個体識別値を含む可能性があり、完全出力・実行側は不明 |
| `... get_fh_ap` | local device | front-haul AP情報 | query名のみ復元。完全出力・実行側は不明 |

完全なCLI transcriptはない。上記quoted outputは本人の成功報告を必要箇所だけ転記した値で、匿名化fixture [`mapd-success-report.txt`](../tests/fixtures/mapd-success-report.txt)は raw capture ではない。生値をIssue/公開ログへ貼らない。

## 実行順

1. A/BそれぞれでEasyMesh role/mode、knos flags、daemon状態をread-only確認する。
2. `DeviceRole=1` Controller / `2` Agent、両方`MapMode=1`が正しいことを確認する。
3. Ethernet linkを接続し、必要なら既存の正規DHCP/LAN構成を維持する。新しいbridge変更を足さない。
4. Aから`getrole`, `agent_list`, `dump_topology`、必要時`dump_topology_v1`を確認する。Bでもlocal `getrole`, `bh_conn_status`, `bh_conn_type`を照合する。
5. Controller role/distance 0とAgent role02/distance1が同一topology状態の対になることを確認する。
6. ここが通ったら無線BHは別章で検証する。Ethernet中にwireless link metricがないだけでonboarding failureとはしない。

**成功判定:** topology上の親子認識が明示され、Controller distance0/Agent distance1である。Ethernetクライアントから通信できるだけではEasyMesh認識を証明しない。

**失敗判定:** Controllerの`agent_list`/topologyにBが現れない、roleがAuto/逆向き、`mapd`または`p1905_managerd`停止、Ethernet link自体なし等。管理IPv4の旧アドレスへ届かないことだけは失敗判定に使わない。

## IEEE 1905.1イベント順の証拠境界

保存ログはEthernet link確立、T6Aログ中の`New Ethernet connection`、Agent追加、topology確認を支える。discovery packet、autoconfiguration/WPS message、TLVの全sequenceは保存/publicationできる形で取得されておらず、認証/onboarding protocol内部の完全なpacket-level順序は復元不能。

## `onboarding 0`は別扱い

記事はhelp/実装を基に`mapd_cli /tmp/mapd_ctrl onboarding 0`がEthernet onboardingを要求する操作と説明する。自動Ethernet discoveryが動く場合があり、成功時に毎回このcommandを実行した証拠はない。これは単純なqueryでなくstate-changing可能性があるため、この再現手順では自動実行しない。topology/daemon/link確認で解決しないときだけ、対象FWで引数の意味・副作用・rollbackを確認した上で別途判断する。

## 次に進む条件

Ethernetでrole/distanceが確認できた場合だけ[6 GHz BHへの切替](08-wireless-backhaul.md)へ。SSH/IPv4だけ問題なら[Agent DHCP/bridge](06-agent-setup.md)および[トラブル表](25-easymesh-troubleshooting.md)を先に見る。
