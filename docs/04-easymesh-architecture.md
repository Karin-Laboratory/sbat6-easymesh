# 4. EasyMeshの構成要素と状態判定

## 観測された制御スタック

| 要素 | 役割の説明 | 根拠と範囲 |
|---|---|---|
| `mapd` / `mapd_cli` | Multi-AP/EasyMesh制御daemonとCLI | 実機採取スクリプト・実行履歴に現れる |
| `p1905_managerd` | IEEE 1905.1管理面daemon | firmware inventoryに存在。各メッセージ全体の生ログは公開しない |
| `wapp` | MediaTek Wi-Fi制御連携daemon | 実行中プロセス、MLO teardown時のread-only採取に現れる |
| `DeviceRole` | mapdのController/Agentロール設定 | A/B snapshotは1/2。vendor script診断文字列は0=Auto, 1=Controller, 2=Agentと示す |
| `MapMode` | ベンダーのMulti-AP動作モード | A/B snapshotと後続scriptは値1。vendor startup scriptが値を読んで生成config/network処理へ渡す |
| `map_root`, `map_agent` | driver/wapp側のEasyMesh role表現 | ログ/解析語として確認。daemon上の状態との完全な対応表は未公開 |

A/T6Aの保存設定 (`mlo-recon/A/etc/map/mapd_cfg`) は `DeviceRole=1`, `MapMode=1`、B/T6B (`mlo-recon/B/etc/map/mapd_cfg`) は `DeviceRole=2`, `MapMode=1`。vendor script自身の診断文字列はDeviceRole 0=Auto, 1=Controller, 2=Agentと明記する。2026-08-23のMLO後続スクリプトも同値をassertする。これらはスナップショット時点の値で、成功時の初期投入コマンド全体ではない。


2026-08-23本人公開記事では、`mapd_cli /tmp/mapd_ctrl getrole`、`agent_list`、`dump_topology`、`dump_topology_v1`、`bh_info`、`bh_conn_status`、`bh_conn_type`、`get_bh_ap`、`get_fh_ap`が診断に使われ、Controller distance 0 / Agent distance 1とEasyMesh R3互換の親子認識が報告されている。完全なIEEE 1905.1 packet traceや適合試験資料があるという意味ではない。

## 成功判定

実験時に `mapd_cli` から親子距離を確認し、Controller側Distance 0、Agent側Distance 1が記録された。IEEE 1905.1 discoveryやR3互換の全イベント・TLVのパケットキャプチャは公開証跡に含まれておらず、プロトコル内部の完全なonboarding過程は未再構成。

推奨する複数の独立確認点:

1. `mapd` と `p1905_managerd` が稼働している。
2. `mapd_cli` の topology/neighbor表示でAgentがController配下に現れる。
3. Controllerの距離0とAgentの距離1が対になっている。
4. BH link metric/associationが存在する。
5. Agent配下の端末についてL2/L3通信を別途試験する。

正確なCLI subcommandはFWビルドで異なる可能性がある。保全されたコマンド断片は `show_bh_link_metric` を示すが、構成取得時の全コマンド列は存在せず、汎用レシピとして固定しない。
