# 16. 現在の確認状況

この章は2026-10-19時点の保存資料監査であり、現在稼働中の端末へ新たに接続したという意味ではない。

- **6 GHz単独BH/L2:** 2026-08-23本人公開記事にT6A Controller/T6B Agent、距離0/1、6G medium、status 1/type 4、抜線後`apclix0` carrier維持、端末間通信・iperf3約350/330 Mbpsの実測報告。
- **5+6 GHz MLO:** 同記事の追記に2-link MLD、RSNE mismatch修正、通常reboot後自動復帰、342秒以上観測、Ethernet端末間約0.91〜0.94 Gbps。公開本人報告として確定し、生ログの独立再解析とは区別。
- **EHT320:** 保存スクリプト案は未転送/未実行。公開検索でも別のSBAT6 EHT320成功報告は見つからず（検索は網羅的証明ではない）。成功未確認。
- **root password:** KnOS静的コードにはsystem_mode条件でpasswd/shadow symlinkを差し替える処理がある。root passwordを変更後に再起動認証した実機記録は未取得。
- **Private archive:** 最新取得は2026-09-25/26選択データと2026-10-18オフライン解析。全partition dumpではない。
- **管理IP:** 成功記事のB `.223`、別snapshot `.247`、後日T6A STA候補`.13`は別の観測時期/状態。`.223`→`.247`の連続DHCP変遷かは未解決。
- **現機の状態:** 未確認。再現前に個体を再識別しread-only採取する。