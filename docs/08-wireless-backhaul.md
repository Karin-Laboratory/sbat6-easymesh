# 8. 6 GHz無線バックホール

## 成功時の観測（2026-08-23本人公開記事）

Ethernetでonboardingした後、Controller/Agent topologyとBH状態を確かめてからEthernetを外し、6 GHz無線BHを確認した。報告値はController distance 0、Agent distance 1、Backhaul Medium Type 6G、Agent `bh_conn_status=1`、`bh_conn_type=Type 4`。

APCLI対応は`apcli0`=2.4 GHz、`apclii0`=5 GHz、`apclix0`=6 GHz。ケーブル切断後、`apclix0` carrier=1/LOWER_UPでbytes counterが増え、他APCLIはdownだった。記事ではchannel 21、6055 MHz、160 MHz、4addr onを観測値として記録する。

AgentのEthernet端末から上位LAN側へのL2延長も確認したと記事は報告する。ここでの成功判定は、Mesh topologyだけでなく、無線BH状態・ケーブル抜線・Agent配下端末間のL2通信を組み合わせる。

## 優先順位とfallback

Controller設定の記録値は6 GHz priority 1、5 GHz low/high priority 2、2.4 GHz priority 3、`AutoBHSwitching=1`。実際に6 GHz BHを確認したが、2.4/5/6 GHz全ての障害条件別fallback順、DFS/遮蔽時の長時間自動再接続は未確認。APCLIが存在するだけでBH成立と判定しない。

## 証拠範囲

ここに記した実測値はQiita本人公開記事の報告。原始的なradio captureを公開資料として独立再解析したものではない。秘密SSID/PSK/BSSIDを転載しない。