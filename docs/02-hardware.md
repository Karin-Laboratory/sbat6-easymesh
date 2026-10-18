# 2. ハードウェアとソフトウェア構成

## 観測された構成

- **保存データから確認:** T6A rootfsの機種情報は `MediaTek evb6990_cpe_mt7990_emmc`、OpenWrt 21.02系を示す記録がある。Linux kernelは5.4系列。
- **保存データから確認:** Wi-FiプラットフォームはMediaTek独自 `mt_wifi`/`mtk`系スタックで、3バンドradioを扱う名前として2.4 GHz (`ra*`)、5 GHz (`rai*`)、6 GHz (`rax*`) が現れる。実験時の代表的なBH AP/STA VIFは6 GHzの `rax2`/`apclix0`、5 GHz側は `rai2`/`apclii0`。
- **保存データから確認:** ベンダー制御に `mapd`, `mapd_cli`, `p1905_managerd`, `wapp`, `EasyMesh_openwrt.sh` が存在する。
- **静的解析による推定:** OpenWrt風のUCI設定からLua変換 (`uci2map.lua`) を介してmapd用ファイルを生成する。設定ファイルを手編集しても起動処理に再生成される場合がある。

この公開記録には純正イメージ、rootfs、SoCの不確かな型番、製品固有の校正データは掲載しない。各個体の製造差や純正FW revisionを固定する完全な公開manifestも作成できなかった。

## インターフェース名の注意

`apcli0`, `apclii0`, `apclix0` はSTA仮想IFとして現れるが、名称の末尾から周波数を断定せず、対象個体のwireless config、radio対応表、実行時 `iw`/`mwctl` 情報を照合する。Linuxの `iw` がベンダードライバ情報を全て公開するとは限らない。
