# root password databaseとSSH認証の参照経路

## 判明した範囲

2026-09に保存されたSBAT6 rootfs Bank A/Bを静的解析した範囲では、`/etc/passwd`と`/etc/shadow`は`/etc/knos/site/`配下を参照するsymlinkだった。`/etc/init.d/knos_config`には条件付きで両ファイルを削除し、`/etc/knos/$system_mode/passwd`および`shadow`へsymlinkを作り直す処理がある。条件は`system_mode`が空、または`run_mode=factory`であり、factory modeを選ぶ別分岐ではDropbear UCI enableを設定し、それ以外ではdisableにする処理を確認した。

このため、データベースの参照元は`/etc/shadow`という表層パスだけではなく、起動時点で選ばれたKnOS modeとsymlinkの実targetで決まる。パスワード変更コマンドがsymlinkを辿って更新する設計でも、そのtargetが後の起動で再選択/置換されれば、変更値を次回起動後に使う保証にはならない。rootfs内のsite/factoryファイルにどのhashが含まれるかは公開せず、hash文字列は表示・転記しない。

## 参照元、書込先、次回bootの関係

| 段階 | 保存rootfsから確認した事実 | 実機で未確認の点 |
|---|---|---|
| 初期配置 | `/etc/passwd`、`/etc/shadow`がKnOS配下へのsymlinkとして存在 | 現行端末でのmode/targetが保存Bankと同一か |
| mode選択 | `knos_config`に空`system_mode`または`run_mode=factory`条件でpasswd/shadowを再生成する分岐 | 条件が通常起動で発火する実際の入力値・分岐ログ |
| 書込 | 通常のLinux pathname解決では、通常ファイルへの書込はsymlink targetへ到達する | BusyBox `passwd`の実装、mount/overlay状態、KnOS同期処理を含む実機write destination |
| 再起動 | init scriptが条件成立時にsymlinkを作り直す実装 | 変更後hashが選ばれるか、別データへ戻るか |
| Dropbear認証 | `-s`等が有効ならpassword loginを禁止できる。KnOS mode分岐はUCI enableも変更 | 実際の起動引数、listener、認証方式は端末ごとに確認が必要 |
| overlay seed | 2026-09 seedにpasswd/shadowは含まれない | seed方式によるpassword database保持は実証されていない |

したがって「`passwd`を実行すれば通常起動後も保存される」「`/etc/shadow`を書き換えれば解決」とは結論できない。更新先を確認する目的でもhash本文を公開ログへ出さず、対象所有者が権限・symlink・mode・ファイル属性だけを記録する。

## 秘密を表示しない確認方法

対象端末の管理権限を持つ人が、端末上で出力をローカル確認する。次は状態確認の例で、`passwd`、編集、再起動は実行しない。

```sh
readlink /etc/passwd; readlink /etc/shadow
ls -ld /etc/passwd /etc/shadow /etc/knos/site /etc/knos/factory 2>/dev/null
uci -q get knos.knos.system_mode
uci -q get knos.knos.run_mode
ps w | grep '[d]ropbear'
uci -q get dropbear.@dropbear[0].enable
```

`ls -l`のlink target/pathだけを記録し、`cat`, `grep`, `awk`等でpasswd/shadowの行やhashを出力しない。`passwd -S root`はBusyBox実装差があるため、対応と出力形式を確認し、hashが混入する場合は使わない。Dropbear引数中に鍵パス等がある場合はマスクする。

## 過去の実機検証と未検証事項

- **確認済み:** 2026-09のT6Aでoverlay seed方式を用いて、再起動後にDropbear鍵認証が2回連続で復帰した記録。
- **確認済み:** seedに`/etc/passwd`/`/etc/shadow`が含まれないこと。従って上記は鍵認証とdaemon復旧の確認。
- **静的解析:** Bank A/Bにおけるsymlink配置、`knos_config`の条件付き張替え、factory時と通常時のDropbear enable分岐。
- **未確認:** root password変更後のファイル書込先、同じsystem modeでの通常reboot後に有効hashが維持されること、factory/empty mode分岐のruntime発火、Dropbear password loginの実機成功。

## 永続性を実証するために必要な記録

実機で試験する場合は、別管理経路とrollbackを確保し、所有者が保護されたローカル記録に限って実施する。公開するのは以下の非秘密メタデータと成否だけでよく、hash値は不要。

1. firmware/bankと日時、`system_mode`/`run_mode`の値、passwd/shadowのsymlink target・inode/mtimeを変更前に記録。
2. 選択modeが起動時に決めるrootfs/source pathを静的コードと実行ログで対応付ける。
3. 管理経路を維持した検証で、変更前後に実際のpathname targetが同じか、対象filesystemが書込可能かを確認する。秘密ファイル本文やhashを記録しない。
4. 変更後の通常再起動でsymlink target/modeが変わらないこと、root password認証成否を端末上で確認する。認証値をコマンド引数・ログ・チャットへ残さない。
5. 複数回の再起動後も同じ結果であり、KnOS reset/revertやfactory pathが介在していないことを確認する。

本調査ではその試験記録を得ていないため、root password永続化は**未検証**のままとする。詳細なSSH復旧方式は[SSH・firewall永続化](18-ssh-firewall-persistence.md)、KnOS起動処理は[設定復元](17-knos-configuration-reset.md)を参照。
