# 未解決・未取得の資料

- 2026-08-23〜24の成功時点を含む完全なT6A/T6B command transcript、mapd topology出力、`show_bh_link_metric`原出力。
- IEEE 1905.1 discovery/onboarding全packet、EasyMesh R3 interoperabilityの詳細な適合根拠。
- 成功時の全UCI設定と起動後生成ファイルの公開可能なredacted copy。
- 6 GHz成功時のchannel 21 / 6055 MHz / 160 MHz / 4addr onは本人公開記事に記録される。再現に必要な秘密を除いた完全なprofile設定は未取得。
- 設定上の帯域優先値（6 GHz=1、5 GHz=2、2.4 GHz=3）とAutoBHSwitching=1は記事に記録されるが、障害条件別fallback順・長時間再接続挙動は未検証。
- 失敗イベント全体の順番、DHCP競合・bridge再構成・管理IP消失の個々の原因と厳密な復旧所要時間。
- 6 GHz無線BH時のEthernetクライアント側DHCP/ARP/VLAN/multicast全項目の検証ログ。
- 後日のT6A独立STA管理構成がEasyMesh構成を置き換えた正確な日付・理由、およびT6B単独STA/別モードへの移行時期。
- 起動時の自動firmware/config restoreがEasyMesh設定に影響した実機証拠。
- 160+160はEHT320案のrollback資料で既知成功ベースラインと記述されるが、その設定のlink別幅・EHT operation IEの独立記録は未取得。
- EHT320の実機試験。保存されているスクリプトは未転送/未実行案。
- 公開記事の6 GHz単独4-stream 20秒iperf3約350/330 MbpsとMLO Ethernet間約0.91〜0.94 Gbps以外の再現可能なTCP/UDP、RTT/jitter、反復統計、長時間安定性データ。
- T6A/T6Bの正確なhardware revision・純正firmware hashを紐付けた実験manifest。

これらは利用可能な公開・ローカル作業ツリーから確認できなかった。補完推測はしていない。原証拠が後日見つかった場合、個体情報/秘密を再監査した後に追補する。

- Qiita成功記事でT6Bは`.223`、別snapshotで`.247`。DHCP lease連続記録がなく、IP変更が同一稼働期間の変遷か別試験かは未解決。
- MLO公開記事の詳しい当時生ログ全行は公開資料として独立再解析していない。記事の成功報告を未成功扱いするものではない。
- root passwordの変更後再起動認証記録は未取得。
- 2026-10-18 SSH切断の個別発火プロセス、UCI書換え/daemon stop/rebootいずれが発生したかの同時刻実機traceは未取得。
