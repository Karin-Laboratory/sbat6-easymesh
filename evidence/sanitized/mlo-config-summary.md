# MLO設定差分の要約

2026-08-23前後のT6A/T6B用スクリプトから確認できる設定意図:

- A/T6Aは `DeviceRole=1`, `MapMode=1` を事前確認する。
- B/T6Bは `DeviceRole=2`, `MapMode=1` を事前確認する。
- AのBH AP MLDは5 GHz/6 GHz VIF名 `rai2 rax2`、group ID 2を指定する。
- BのBH STA MLDは `apclii0 apclix0`、primaryは `apclix0`、group ID 1。設定は既存BH profileから秘密値を取得する作り。
- 両方で5 GHz configを `EHT160` とする。

これはスクリプトの静的内容の要約。実機上で全linkが同時接続したことや160+160成立を直接示さない。PSK/SSID/MAC、シェルスクリプトは転載していない。
