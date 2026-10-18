# 13. 失敗・現象と修正

| 順 | 現象 | 原因/判定 | 対応・結果 | 証拠状態 |
|---|---|---|---|---|
| 1 | 初期SSH管理経路がない/不安定 | EasyMesh状態とは独立した管理経路の問題 | 管理手段を整えてから構成 | 保存記録。初期侵入手順は非掲載 |
| 2 | EasyMesh discovery/onboardingを確認できない | Ethernetで物理/IP経路とwireless BHを分ける必要 | 有線でonboardingしtopology確認後に無線へ移行 | 本人公開記事 |
| 3 | Ethernet抜線後、旧管理IPへの到達性が変わる | `MapMode=1`のDHCP/bridge変更でAgentの管理IPv4が移る場合がある。特定のDHCP競合発生は公開根拠で確認できていない | APCLI carrier/BH topology/L2 endpointとDHCP/bridgeを個別確認 | 管理面変化と6G BH成功を別判定 |
| 4 | MLO適用後約100ms切断、RSNE mismatch | 5G WPA2系/6G SAE+PMF required不整合。runtime provisioningがprofileを戻す | BSS profile生成元を修正、SAE/PMF required統一 | 本人公開記事 |
| 5 | 起動後のMLO/管理復帰に時間 | DHCP/Mesh参加が起動完了直後ではない | 約170秒DHCP、173秒Mesh再参加、342秒以上MLO観測を報告 | 本人公開記事 |
| 6 | T6A SSHが接続中に切れる（10月掲示板状況） | firewall reload、daemon、IP、設定変更、reboot候補を分離。特定caller未確定 | read-only差分比較が必要 | 保存rootfs静的解析。個別因果は未確定 |
| 7 | B snapshotで稼働APCLIが変化 | role/mode/hash保持とactive bandは別。時刻/文脈も不確定 | 元の6GHz BH成功の失敗とは断定しない | 保存snapshot |
| 8 | 設定hashが同じでも実効挙動が違う | MLO時はEasyMesh runtime provisioningがBSS profileを戻し、BSS生成元の修正が必要だったと報告 | 生成元を揃え、SAE/PMF required化後に4-way handshake成功を報告 | 本人公開記事 |
| 9 | reboot後設定/firmware自動復元の疑い | `/data/sysupgrade.tgz`のoverlay復元は過去T6Aで確認。一方、EasyMesh/今回SSH断に対するfirmware bank自動復元の発火証拠は未取得 | overlay復元とbank切替を分離して確認 | 未解決 |
| 10 | DHCP競合やbridge再構成が疑われる | `MapMode=1`のOEM処理にDHCP/bridge変更が存在。個別の競合パケットや失敗したbridge状態は公開可能資料で未確認 | IP lease、`br-lan` member、Mesh topologyを個別採取 | 静的解析/未検証 |
| 11 | EHT320を成功扱いできない | 保存案は未実行と明記 | 実験案として分離 | 静的資料確認 |

通信断のみでEasyMesh脱落と決めず、`mapd_cli` topology/BHを別に見る。