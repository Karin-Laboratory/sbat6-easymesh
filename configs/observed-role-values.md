# 観測されたrole/mode値（限定抜粋）

2026-08-23前後のMLO作業スナップショットとvendor script診断定義で確認した値。これはRunnableな完全設定ではなく、BH profileやnetwork設定を含まない。

```ini
# T6A / Controller snapshot
DeviceRole=1
MapMode=1

# T6B / Agent snapshot
DeviceRole=2
MapMode=1
```

保存元はPrivate work area内の `mlo-recon/{A,B}/etc/map/mapd_cfg`。`DeviceRole`の定義は同時期の `EasyMesh_openwrt.sh` 内の診断文字列（0=Auto, 1=Controller, 2=Agent）で照合した。PSK/SSID/BSSIDや他の設定項目は公開していない。
