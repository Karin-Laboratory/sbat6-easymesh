# 8. 6 GHz無線バックホール

## 実機確認された移行

有線で親子関係を確認した後、AgentのBHが無線で稼働する状態にし、Ethernetを抜いても親子接続が残ることを確認した。実験の最終記録は6 GHz BHを明示しており、T6B Ethernetから上位LANへ到達するL2延長も確認された。

**保存データから確認:** MediaTek側の代表IF名は親側6 GHz AP `rax2`、Agent側STA `apclix0`。5 GHz側候補は `rai2`/`apclii0`。APCLIが存在することだけでは接続状態の証明にならない。

## 成功条件として記録できる範囲

- EasyMesh Controller/Agentのrole設定とTopologyが成立している。
- 6 GHz BH profileを両機が共有している。認証値は公開しない。
- 6 GHz radio/VIFが起動し、BH link stateと無線統計が動いている。
- AgentのEthernet portは `br-lan` に属し、上位側と同一L2 domainとして転送される。
- Ethernet切断後もMesh topologyとBHが残り、Agent配下クライアントの疎通が続く。

プロファイルの実SSID、PSK、BSSID、実験時の最終チャンネル・チャネル幅は取得可能な公開資料で確定できなかった。2.4/5/6 GHzの「優先順位」や自動fallbackの確実な順序も不明。2.4/5 GHzを先に試した全試行列を作れる資料もないため、実測済みの6 GHz成立だけを記載した。

## Ethernet切断後の再接続

当時はEthernetを物理的に切断しても6 GHz BHが維持された。長時間・再起動をまたぐ自動再接続の統計、遮蔽/DFS等の条件でのfallback実測は未確認。
