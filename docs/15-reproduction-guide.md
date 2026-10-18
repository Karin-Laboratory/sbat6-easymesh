# 15. 再現ガイド（記録から安全に言える範囲）

完全な成功時スナップショットと全コマンドログがないため、ここでは未確認値を埋めた自動投入レシピではなく、段階別の検証計画を示す。

## 前提

所有する同一系列の二台、電源、予備LAN、シリアル/UART等の独立した復旧経路、バックアップ先を用意する。メーカー/回線固有の資格情報は別管理し、ログに出さない。純正ファームウェアの再配布はしない。

## 段階

1. **識別と採取:** hostname/model/kernel、MAC、firmware revision、radio/VIF map、UCIのrole/mode、bridge/routeを保存する。IP単独でA/Bを識別しない。
2. **管理路:** A/B双方に個別の安全な管理手段があり、片方の再起動中に他方から状態を取れることを確認する。
3. **有線参加:** 現状のvendor network/bridgeを保って有線接続し、`mapd`/`p1905_managerd`、topology距離0/1を確認する。
4. **BH無線:** 実験時の保全されたprofileを現物から確認し、秘密を表示せず6 GHz BHを構成。実機で観測したroleを確認し、推測したチャネルや暗号方式を流用しない。
5. **ケーブル抜去:** topologyとBH metricを観測しながらEthernetを切断する。管理通信とMesh状態を別記録する。
6. **L2:** Agent Ethernet側のクライアントからARP/DHCP/疎通を確認。成功判定をpingだけにせず、DHCP server/leaseとbridge memberも記録する。
7. **永続性:** 変更前後のUCI/生成設定hashを比較し、許可された通常再起動後に全段階を再確認する。
8. **追加検証:** MLOはlink単位のpeer/width/counterを明示確認してから性能測定。EHT320は別試験として実施する。

## 成功条件

Controller Distance 0 / Agent Distance 1、6 GHz BH link、ケーブルなし、Agent Ethernet配下端末の上位L2到達が**同じ試験期間内に**揃うこと。再起動後も再現できた場合に初めて永続成功とする。

各段階で管理路が失われたら変更を止め、console/別経路から復旧する。ファームウェアの書換え、factory reset、初期化を手順に含めない。
