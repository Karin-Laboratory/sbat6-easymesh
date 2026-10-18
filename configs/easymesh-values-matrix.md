# EasyMesh設定値の比較表

この表は再現可能な記録を作るための照合表です。完全な機器設定ではなく、秘密を含む無線プロファイルも収録しません。値の由来が異なる場合は同じ欄に混ぜていません。

判定: **実機確認**=公開された当時の実機報告、**保存データ**=保存rootfs/設定スナップショット、**不明**=役割別の成功時値を確定できない。

| 設定/項目 | Controller (T6A A) | Agent (T6B B) | 入力/実行時の区別 | 根拠・再現上の注意 |
|---|---|---|---|---|
| `DeviceRole` | `1` 実機確認 | `2` 実機確認 | `mapd_user.cfg`等を入力にOEM生成処理がruntime cfgへ反映 | `wificonf -f /etc/map/mapd_user.cfg set DeviceRole N`は歴史的writerの記録。無条件投入用ではない |
| `MapMode` | `1` 実機確認 | `1` 実機確認 | user/default cfgからruntime `/etc/map/mapd_cfg`等へ生成 | MapMode変更はbridge/DHCPを再構成し管理IPを失う可能性あり |
| `knos.network.easymesh` | `1` 実機確認報告 | `1` 実機確認報告 | KnOS UCI | 値確認例は`uci -q get`。設定変更例ではない |
| `knos.flags.mesh` | `1` 実機確認報告 | `1` 実機確認報告 | KnOS UCI | EasyMesh daemonが存在するだけでは有効化を意味しない |
| `BhPriority2G` | `3` Controller成功時確認 | 成功時の値は不明。保存rootfs既定`3` | default/user/runtime値を区別する | 保存rootfsのdefaultは実験成功時のAgent値を証明しない |
| `BhPriority5GL`, `BhPriority5GH` | `2` Controller成功時確認 | 成功時の値は不明。保存rootfs既定`1` | 同上 | 5 GHz優先度の意味は同一機器の実装・profileを確認する |
| `BhPriority6G` | `1` Controller成功時確認 | 成功時の値は不明。保存rootfs既定`1` | 同上 | 6 GHz BH成功は報告済み。Agent個別優先値を推定しない |
| `AutoBHSwitching` | `1` Controller成功時確認 | 不明 | 保存rootfs defaultにも`1` | Agent成功時値は確定できない |
| `NtwrkOptMldBhPriority` | `1` Controller成功時確認 | 不明 | mapd config | MLO後続試験に関する値。6 GHz単独BH成功要件と混同しない |
| mapd設定生成 | default + user入力からruntime cfgをOEM scriptが生成 | 同左の設計 | `/etc/map/mapd_default.cfg`, `mapd_user.cfg` → runtime `mapd_cfg`/1905設定 | runtime生成物のみを永続入力元と誤認しない。完全な相互対応表は未取得 |
| role起動 | `map_root`系 | `map_agent`系 | OEM起動scriptと`p1905_managerd`、`mapd`、`wapp` | exact argv/起動順は機器・ビルド依存 |
| IEEE 1905.1 / topology | Controller distance `0` | Agent distance `1` | 実行状態 | EasyMesh R3相互認識、Ethernet onboarding後の親子認識を報告 |
| BH medium/status/type | Controller側から6 GHzを観測 | Agent `status=1`, `type=4` | runtime | `Backhaul Medium Type 6G`。距離・BH・IP・SSHを独立して判定 |
| APCLI | local AP群 | `apcli0`=2.4GHz, `apclii0`=5GHz, `apclix0`=6GHz | driver runtime interface | cable removal後`apclix0`がcarrier/trafficを維持、他APCLI downと報告 |
| SSID / PSK / BSSID | 非公開 | 非公開 | 無線profile | 共有資料・Gitに実値を置かない。再現時は同一の対応profileをローカルで設定 |
| security (MLO試験) | 5/6GHz BSSをSAE + PMF requiredへ統一 | 同一条件へ修正 | source profileとruntime provisioningの両方 | 初回不一致は約100ms切断/RSNE mismatch。キーは非公開 |
| bridge / DHCP | Controller側がLAN/DHCP側 | `br-lan`をL2延長。Agent DHCP client等を使用 | KnOS/UCI/runtime network | Agent `wan.proto=none`, `dhcp.lan.ignore=1`を含む履歴。完全な設定snapshotなし |
| Ethernet onboarding | 有線でAgent発見を確認 | Controllerへ有線接続してから無線BHへ | runtime topology | discoveryとwireless BHを切り分ける段階。`onboarding 0`が必須だったとは言えない |
| 6GHz radio | ch 21 / 6055 MHz / 160 MHz、4addr | 同じBH linkとして観測 | runtime radio | 実機報告に基づく。地域・規制・firmware差に注意 |
| MLO link | `rai2` + `rax2`, MLD group 2 | `apclii0` + `apclix0`, MLD group 1 | runtime/driver | `mld_sta257 ref_cnt=2`, band_idx 1/2報告。コード/設定存在だけで成立としない |

## 成功判定に使った観測

- Controller/Agent roleとtopology distanceは`mapd_cli`のruntime出力。
- BH medium/type/statusはEasyMesh runtime状態。
- Ethernetを外した後の6GHz APCLI carrier/counterと配下Ethernet端末間通信を併せて確認。
- L2延長の記録は対象端末間の通信実測であり、VLAN、全multicast、全MTUの透過保証ではない。
- 公開記事に記録された値と保存済み生ログの独立再解析は区別する。完全な再現設定セットは存在しない。
