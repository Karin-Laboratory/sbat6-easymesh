# 17. KnOSの設定復元と起動時処理

## 何が「戻る」のかを分ける

SSH切断は単一の「KnOSリセット」では説明できない。保存済み2026-09 Bank B rootfsの静的解析では、次の別経路が見つかった。対象端末の現在動作や2026-10-18の個別イベントを直接観測したものではない。

| 層 | 保存rootfsで確認したもの | 10/18事象との因果 |
|---|---|---|
| UCI設定 | `knos_config`、`auto_adapt`、`ql_wwan_config.sh`、`ql_lan_config.sh`等にset/commit | 当該切断時に書き換えたか未確定 |
| UCI revert | `knos_uci_revert.sh`に複数revert、firewall対象も存在 | 直接caller・発火時刻未特定 |
| runtime firewall | iface hotplug hookと複数のfirewall reload経路 | 手動iptablesがreloadで消える実装経路を確認 |
| SSH daemon | Dropbear init/procd管理とnetwork trigger。`knos_config`はsystem modeに応じDropbear UCI enableを変更 | 当該時点に実行された証拠なし |
| password database | `knos_config`の条件分岐に`/etc/passwd`・`/etc/shadow`を削除し、`/etc/knos/$system_mode/`配下を指すsymlinkへ置換する処理 | 条件分岐の静的存在は確認。10/18に発火したか、選択modeは未確認 |
| overlay | `/data`から起動時overlay復元する過去T6A手順 | 8月EasyMesh・10月個別切断との同一性なし |
| reboot/bank | procd起動状態遷移、A/B bank解析 | SSH切断だけでは再起動やbank切替を示さない |

## 起動・再構成の関連箇所

保存Bank Bでは`/etc/hotplug.d/iface/20-firewall`がinterfaceイベントを受けてfirewall serviceを呼ぶ。`ql_wwan_config.sh`にfirewall reload、`ql_lan_config.sh`にもfirewall UCI変更・commit・reloadがある。`ql_mipc.sh`、`mipc_wan.init`、`auto_adapt`はnetwork設定やinterface適応に関係する。これは可能な実装経路の静的確認で、特定のイベントがいつ発火したかの実機traceではない。

`knos_config`は起動init script内にUCI変更処理を持つ。選択されたコードには、`system_mode`が空か`run_mode=factory`の条件で`/etc/passwd`と`/etc/shadow`を消し、`/etc/knos/$system_mode/passwd`および`shadow`へのsymlinkを作り直す分岐がある。また`system_mode=factory`の場合はDropbearをenable、それ以外でdisableにするUCI設定分岐もある。これはroot password databaseとSSH daemon設定の初期化候補を具体化する静的証拠だが、実機で条件が成立したか、10/18に実行されたか、実効password hashがどうなったかは確認できない。`knos_uci_revert.sh`の存在だけからSSH切断原因と断定してはならない。個別トリガーの直接callerは未特定とPrivate archiveの評価に記録されている。

別の保存済みprocd解析では、`/etc/inittab`のsysinitからrcS runqueue完了時に状態3→4へ遷移し、完了flagを立てる経路をBank A/B両方で確認した。120秒timerはflag未成立ならrebootする設計だった。ただし「どの起動scriptが遅かったか」は未特定であり、SSH/firewall切断の原因と混同しない。

## 証拠範囲

ここでいうベンダーコード解析は非公開の歴史的rootfsに対する静的調査である。メーカー由来コードやrootfsは公開していない。対象個体・現在bankと内容一致を保証しない。調査ファイル、archive commit SHA、解析結果の取得範囲は[出典表](../SOURCES.md)を参照。
