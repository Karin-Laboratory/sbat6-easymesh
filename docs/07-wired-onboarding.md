# 7. Ethernetによる初期オンボーディング

有線接続から始めた理由は、IEEE 1905.1 discovery/onboardingと無線BH切替を分けて診断するため。2026-08-23本人記事では、ControllerからAgentがrole 02/distance 1で見えることを確認した後にEthernetを外している。

## 記事に記録された確認コマンド

これらは記事で実際に使われたdiagnostic CLIで、firmware buildにより対応差があり得る。

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

同記事は`mapd_cli /tmp/mapd_ctrl onboarding 0`をEthernet onboarding機能として説明する。ただし、成功時はまず自動認識とtopologyを調べ、必要時だけCLI操作を追加したと記録しているため、このコマンドを常に実行した成功コマンドとは扱わない。

## 判定

Controller distance 0、Agent distance 1、DeviceRole 1/2を確認し、topologyにAgentが現れた時点で制御面の認識を確認する。次にBH mediumとstatus、APCLI、Agent配下Ethernet端末の通信を別段階で確認する。IPv4管理IPへpingできないだけでonboarding失敗とは決めない。

完全な1905.1 packet trace、全成功時command transcript、初期全設定は公開可能資料として取得できていない。