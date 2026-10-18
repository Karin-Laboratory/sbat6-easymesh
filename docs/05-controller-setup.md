# 5. Controller側（T6A）

## 確認された役割

**実機確認済み:** 実験構成のA号機をController/親機とし、保存設定snapshotで `DeviceRole=1`, `MapMode=1`。vendor scriptの表示定義も `DeviceRole=1` をControllerと対応づける。対向Agentが距離1だったという当時の観測と合わせて役割を判定した。

## 保存された設定差分の一部

後続MLOステージでT6Aは5 GHz radio `MT7990_1_2` をEHT160にし、BH用AP MLDを `rai2 rax2` のAPとして構成、MLD group ID 2を割り当てるスクリプトが存在する。これはEasyMesh親子化後の**追加実験**であり、最初に6 GHz BHを成立させた設定と同一とは限らない。実機成功を示すログ・証跡範囲はMLO章を参照。

## 再現時に記録する値

公開可能な値だけを現物から記録し、PSK・固有BSSID・固有MACは伏せる: `DeviceRole`, `MapMode`, radio/VIF対応、band、channel/width、mapd topology、BH link state、br-lan port membership。Private archive由来の設定ファイルをそのまま転記しない。
