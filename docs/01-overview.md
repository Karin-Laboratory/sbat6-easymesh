# 01. 概要と確認範囲

| 到達点 | 証拠状態 | 主な条件/限界 |
|---|---|---|
| T6A Controller / T6B Agent | 実機確認済み（本人の公開当時報告）、保存設定と整合 | DeviceRole 1/2、MapMode 1 |
| 6 GHz単独EasyMesh BH | 実機確認済み（本人公開報告） | Controller distance 0、Agent distance 1、6G medium、Agent status 1/type 4 |
| Ethernet抜線後のL2延長 | 実機確認済み（本人公開報告） | APCLI 6 GHz維持、端末間通信 |
| 5+6 GHz MLO | 実機確認済み（本人公開報告） | MLD ref_cnt 2、5/6 GHz link、両counter増加 |
| MLO後のiperf3 | 実機確認済み（本人公開報告） | Ethernet端末間約0.91–0.94 Gbps。生ログ独立再検証は未実施 |
| root password永続性 | 未検証 | SSH鍵による復旧成功と区別 |
| EHT320 | 未確認 | 2026-08-24案は未実行 |

実験の時系列・手順は[再現ガイド](15-reproduction-guide.md)および[root取得後からの中心ガイド](21-from-root-to-easymesh.md)を参照。証拠の種類は、本人公開の当時実測、保存ログ、保存スクリプト、静的解析を分けて表記する。