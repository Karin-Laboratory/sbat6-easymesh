# 6. Agent側（T6B）

## 確認された役割

**保存データから確認:** 2026-08-23の `mlo_apply_b.sh` は `mapd.mapd_cfg.DeviceRole=2` と `MapMode=1` をassertする。対象はB号機であり、同スクリプトは既存6 GHz BH profileを秘密値を表示せずに選び出そうとしている。

MLO段階でT6Bには、`apclii0 apclix0` のSTA MLD設定（group ID 1、primary `apclix0`）とSAE/PMF-required関連設定を加える差分が準備された。これはMLOの実験設定であって、6 GHz単独EasyMesh BHの全設定を示すものではない。秘密鍵とSSIDは実例から省き、再利用可能な実値は公開しない。

## 管理IP

T6Bに関連して `192.168.3.247` と補助経路 `192.168.3.1` が記録群に現れるが、役割/時期/hostname/MACの変更もあり、IPだけで同一状態を表さない。本書は歴史的IPを設定例に再利用しない。管理IPが消えた事象は [失敗記録](13-failures.md) と [復旧](14-recovery.md) を参照。
