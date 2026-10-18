# Controller設定writerの所有者向け検証計画

**状態: 未実機検証。** この文書は選定rootfsの静的解析結果を所有者が安全に検証するための計画であり、今回の作業で端末へ接続・変更していない。実機での変更には対象個体の確認、独立したUART/console等の復旧路、個体専用backup/rollback、所有者による個別の明示的許可が必要である。

## 静的解析で見つかったこと

| 値 | 保存時のwriter | 保存先 | 確認/後続処理 | 実験との関係 |
|---|---|---|---|---|
| `DeviceRole=1` | 選定rootfsの`/usr/bin/map_cert_script.sh`にはRole=1/OpenWrt分岐のwriter候補`datconf -f /etc/map/mapd_user.cfg set DeviceRole 1`がある | `/etc/map/mapd_user.cfg` | OEM起動scriptが`mapd_cfg`へmergeし`prepare_1905_config()`がController flagを生成 | 認定用scriptのwriter候補。記事の成功実験で使用した証拠なし。実機投入用に採用しない |
| `MapMode=1` | `/etc/uci-defaults/99-zknos-default-setting-official-0201.mesh`の`change_mapd()`はEasyMesh=1時に`mapd_cfg`と`mapd_user`の値を1へ代入後`uci commit mapd` | `/etc/config/mapd`のUCI sections | EasyMesh起動scriptがruntime profile/networkを準備 | 静的な初期化経路。成功実験での発火/保持は未確認 |
| `knos.network.easymesh=1` | 選定rootfsのテキスト上、positive writerを発見できず。`uci-revert`には0へ戻す処理がある | KnOS UCI | EasyMesh scriptが値を読み、MapMode branch等を選ぶ | 成功readbackのみ。書込み操作未復元 |
| `knos.flags.mesh=1` | default-setting scriptが前回設定からdefaultを引き継ぐ呼出しは確認、1へのpositive writerは未発見 | KnOS UCI | このflagを読んで機能分岐する箇所の関係は個体/build依存 | 成功readbackのみ。書込み操作未復元 |

追跡対象は選定Bank A/Bの`EasyMesh_openwrt.sh`, `kn_meshd`起動経路, `uci2map.lua`, `/etc/mapd.uci`, `mapd` UCI sections, mapd default/user/runtime cfg, `1905d.cfg`, UCI defaults/revert, roleを含むcertification helper。ファイル群はPrivate/local解析資料であり、本公開repoへメーカーコードは収録していない。ソースSHAのない抽出rootfsは[SOURCES.md](../SOURCES.md)に由来と制約を記録する。

MapModeの保存source内writerは、条件成立時に次の2 sectionへ値を設定してからUCI packageをcommitする処理である。これはKnOS scriptの**静的なコード経路を説明するだけ**で、手動実行コマンドではない。

```text
uci set mapd.mapd_cfg.MapMode='1'
uci set mapd.mapd_user.MapMode='1'
uci commit mapd
```

実験時に`knos.network.easymesh`を1へ設定したwriterが不明であるため、この断片だけでは条件を安全に成立させられず、owner向けの実機操作手順にもそのまま含めない。

## 検証前の条件

次を全て満たさない場合は状態確認だけにする。

- 対象が所有者のSBAT6で、A=Controller候補の個体を本体ラベル、hostname等から識別済み。
- model、firmware/bank、UCI schema、`wificonf`/`datconf`の実装が静的解析対象と一致する。
- UART/consoleなどSSHとは別の管理路が動作し、別経路からnetwork/overlayを復旧する方法が具体化済み。
- 変更前の必要ファイルをroot-onlyでbackupし、checksumと復元コマンドを確認済み。
- backupに秘密値が含まれるため、公開ログやGitへ出さない。
- 実機変更に対する所有者の個別明示的許可を得ている。

## readbackと段階検証

まず全てを読み取り、値と設定sourceの対応を記録する。実行先を間違えないため、変更はA一台ずつに限定する。

```sh
uci -q get mapd.mapd_cfg.DeviceRole
uci -q get mapd.mapd_user.DeviceRole
uci -q get mapd.mapd_cfg.MapMode
uci -q get mapd.mapd_user.MapMode
uci -q get knos.network.easymesh
uci -q get knos.flags.mesh
grep -E '^(DeviceRole|MapMode)=' /etc/map/mapd_user.cfg /etc/map/mapd_cfg
```

最後の`grep`はrole/mode keysだけを表示する。認定scriptの`datconf` writer候補と、記事に記録されたAgent `wificonf` writerが同じコマンド実装・同じ意味であるとは仮定しない。

### 所有者が実機検証する場合の順序

1. 上記のreadback、role/mode flags、daemon/topology、管理IP/bridge/DHCPを変更前状態として保全する。
2. target buildで確認した公式/KnOS writerと呼出元・条件を特定する。静的候補しかない場合、候補script全体を直接実行せず、安全な最小writerを所有者がレビューする。
3. backup復元とconsole復帰を別経路から再確認する。
4. `DeviceRole`、`MapMode`、KnOS flagsをそれぞれ独立した変更単位として扱い、値を書き込む手段、commitの有無、設定の生成元を先に確定する。writer不明のflagは変更せず中断する。
5. 各変更直後に、同じ入力元へのreadbackと差分を確認。期待外の値、runtime rewrite、IP/SSH変化があれば次の値を変更しない。
6. OEM起動処理後に`mapd_cfg`/`1905d.cfg`、daemon role、topologyを読み取り確認する。daemonの直接手動起動はしない。
7. 独立管理路を維持した状態で通常再起動後の入力・生成値の保持を記録する。再起動後に一定時間待つだけで成功判定せず、各readbackを取り直す。
8. 変更前状態に戻す場合は対象buildのbackup/restore手順だけを使い、role/modeだけの戻しでbridge/DHCP状態も元に戻ると決めつけない。

この計画は再現用コマンド列ではない。Controller roleの保存記録が新たに見つかっても、実験時に実行した証拠と静的実装確認を分ける。
