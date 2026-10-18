# 6. Agent側（T6B）

## 実験時の役割と確認値

2026-08-23本人公開記事のB/T6BはAgent。`DeviceRole=2`、`MapMode=1`、Controllerからdistance 1。`mlo_apply_b.sh`もrole/modeをassertする。成功記事でAgent BHは`bh_conn_status=1`、`bh_conn_type=Type 4`、Backhaul Medium Type 6G。

後続MLO用差分には`apclii0 apclix0`のSTA MLD（group ID 1、primary `apclix0`）とSAE/PMF-required設定がある。これはMLO段階の追加内容であり、単独6 GHz BHの完全な初期設定ではない。

## DHCPと管理IP

成功記事のT6B Agentは`192.168.3.223`。別のB再起動snapshotには`.247/24`が現れる。ファイル名日付、ホストmtime、端末epochが一致しないため、両者のDHCP変遷を連続記録で証明できてはいない。どちらも実験時点の別観測として扱い、固定値として再利用しない。`.1`は補助管理アドレス、後日のT6A単独STA管理`.13`は別モード/時期。

`MapMode=1`のAgentでIPv4管理だけ失われる場合はDHCP/bridgeを確認し、EasyMesh topologyを独立して確認する。