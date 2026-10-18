# 5. Controller側（T6A）

## 実験時の役割と確認値

2026-08-23本人公開記事ではA/T6AがController/親機。`DeviceRole=1`、`MapMode=1`。KnOS側EasyMesh有効flagとして`knos.network.easymesh=1`、`knos.flags.mesh=1`が記録される。Controller側topologyはdistance 0。

記事に記録されたControllerのbackhaul優先値は`BhPriority6G=1`、`BhPriority5GL=2`、`BhPriority5GH=2`、`BhPriority2G=3`、`AutoBHSwitching=1`、`NtwrkOptMldBhPriority=1`。この値は成功時観測として紹介するもので、全firmwareで有効な推奨設定ではない。

## 設定の生成とdaemon

`/etc/map/mapd_default.cfg`、user overrideの`mapd_user.cfg`等をOEM変換scriptが読み、runtime `/etc/map/mapd_cfg`や`1905d.cfg`を生成してから`mapd`、`p1905_managerd`、`wapp`などを起動する。runtime出力だけを編集しても、再生成時に失われ得る。Controller側role起動は`map_root`/`map_agent`と`p1905_managerd -r0`が連動する。原設定・全profileは秘密情報を含み得るため公開していない。

## MLO追加設定との区別

後続MLO実験には5 GHz `MT7990_1_2` EHT160、BH用AP MLD (`rai2`/`rax2`)、MLD group ID 2を組む差分がある。これは最初の6 GHz単独BHの設定一式ではない。[MLO](10-mlo.md)参照。