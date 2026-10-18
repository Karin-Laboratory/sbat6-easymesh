# 9. Agent側EthernetへのL2延長

**実機確認済み（実験要約）:** T6Bの有線LAN portに接続したクライアントが、T6A側上位LANへ通信できることを、Ethernetケーブルを外したMesh構成で確認した。概念上の経路は次の通り。

```text
上位LAN ─ T6A br-lan ─ 6 GHz BH ─ T6B br-lan ─ 有線クライアント
```

この結果は、T6Bに対する単独STA管理接続 (`apclix0` にIPを付ける構成) とは異なる。後日T6Aを `192.168.3.13` の無線STA管理経路に変更した記録はEasyMesh成功時のネットワーク構成ではない。

公開可能な記録にDHCP lease全体、ARP表、VLAN ID、全bridge member出力、iperf3の完全な結果セットはなく、同一broadcast domainの全機能（DHCP、ARP、未知unicast、multicast、VLAN透過）の網羅試験を主張しない。今回確かなのは当時の疎通確認である。
