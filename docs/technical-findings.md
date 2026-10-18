# 技術的知見と証拠強度

1. **Mesh階層とIP疎通は独立した状態。** 親子Distance、BH link、管理IP、Agent配下転送を別々に測る。
2. **役割設定は、コマンド前提とruntime topologyの両方で確認する。** `DeviceRole=1/2`, `MapMode=1` は後続スクリプトに記録される。値だけでController/Agent接続成立とはいえない。
3. **MediaTekのEasyMeshはLinuxの通常wireless toolsだけでは全状態を見られない。** `mapd_cli`, `wapp`, vendor private ioctl/driver側情報が関係する。
4. **APCLIは役割・周波数ごとに識別する。** 存在、UP、carrier、association、Mesh BHとしての利用は別の判定段階。
5. **実験の主成果は6 GHz BHでの有線なしL2到達。** throughput・帯域fallback・DHCP完全透過の全仕様まで示す資料ではない。
6. **設定には生成/復元actorがある。** UCI→mapd config変換や起動処理を含めて確認し、再起動をまたいだreadbackを取る。
7. **MLO項目の存在はMLO成立を意味しない。** 設定、MLD peer、各link state/counter、データ転送を段階的に示す。
8. **EHT320は未実施扱い。** 設計案と成功ログを混同しない。

原ログにないIEEE 1905.1 TLV、R3認証交換、SSID/PSK、実測channel/width、DHCP sequence、速度を補作しない。
