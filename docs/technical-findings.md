# 技術的知見と証拠強度

1. **Mesh階層とIP疎通は独立した状態。** 本人公開記事の6 GHz成功はdistance 0/1、6G medium、Agent status 1/type 4、抜線後の6 GHz APCLIと実トラフィックで判定されている。
2. **役割設定だけで親子成立とはいえない。** `DeviceRole=1/2`, `MapMode=1`、KnOS enable flag、daemon起動とtopologyを合わせる。
3. **設定には生成actorがある。** user overrideからruntime `mapd_cfg`/`1905d.cfg`生成とOEM起動処理を追う。生成ファイル編集だけを永続変更とみなさない。
4. **APCLIは帯域別に見る。** `apcli0`=2.4 GHz、`apclii0`=5 GHz、`apclix0`=6 GHz。存在、carrier、association、Mesh BH利用は別の段階。
5. **6 GHz単独BHと5+6 GHz MLOの両方に成功報告がある。** MLOは初期RSNE mismatchをSAE/PMF profile統一とruntime profile生成元の修正で解消したと本人記事は記録する。
6. **MLOの成立確認は複数観測で行う。** 公開報告ではMLD ref_cnt 2、band_idx 1/2、両link counter増加、Ethernet端末iperf3。制御コードだけの静的確認とは区別。
7. **性能値はendpointで変わる。** Router本体で約330〜380 Mbps、PC-to-PC Ethernet endpointでは最大約0.94 Gbps。後者は1GbEで頭打ちし、無線上限ではない。
8. **SSH断はfirewall/daemon/IP/UCI/rebootに分離。** 保存rootfsにhotplug/WAN firewall reload、KnOSの認証database参照先変更分岐を確認。ただし個別10/18イベントの発火者は未確定。
9. **鍵SSH復帰とroot password持続は別。** 過去overlay seedは鍵・Dropbear関連物を含むがshadow/password databaseは対象外。root password再起動検証は未取得。
10. **EHT320は未実施。** 設計案とMLO成功を混同しない。

本人公開の当時実測、保存スクリプト/ログ、Private rootfs静的解析、未検証を章ごとに区別する。