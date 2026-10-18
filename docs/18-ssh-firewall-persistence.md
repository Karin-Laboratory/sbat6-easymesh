# 18. SSH daemonとfirewallの永続化

## `rc.local`と手動iptablesの限界

`rc.local`から一度Dropbearを起動するのは、daemonの起動要求にすぎず、procdによる監視・再起動管理や正しいlisten設定を保証しない。また`iptables -I`はkernelのruntime tableを書き換えるだけで、UCI設定には保存されない。後からfirewall serviceがreloadするとruntime tableはUCI/include等から再生成され、手動ruleが消える。UCIファイルのhashが変わらなくても起こり得る。

保存Bank Bの解析では`20-firewall` iface hotplug、`ql_wwan_config.sh`のreload、`ql_lan_config.sh`のUCI更新/reloadが確認された。これは強い原因候補となる実装証拠だが、10/18のイベントでどれが実行されたかは不明。

## SSH実装の識別

投稿中の「sshd」は一般名として扱う。OpenSSHと断定しない。読み取り専用で、`ps w`、`command -v dropbear sshd`、`readlink /proc/<PID>/exe`、`ss -lntp`または`netstat -lntp`、`uci show dropbear`、`/etc/init.d/dropbear status`を照合する。バイナリ名、procd service、listen port、起動引数から実体を確認し、PIDだけでlistenerの健全性を判断しない。

保存rootfsのDropbear initはprocd service、network/hotplug trigger、respawn等を扱う。別の`knos_config`分岐はsystem modeに応じてDropbearのUCI enableを切り替えるため、procd service定義があるだけでは実際の起動を保証しない。`rc.local`から別プロセスを起動すると、init-managed instanceと重複する可能性もある。設定変更やnetwork eventでlistener/socketが再生成・消失する経路を切り分ける。

host keyは通常`/etc/dropbear/`等、authorized_keysはroot home配下に置かれることが多いが、対象端末の実際のパスとoverlayへの保存条件をread-onlyで確認する。秘密鍵・host private key・authorized_keys本文を公開ログへ貼らない。

## 永続化方式の比較

| 方式 | 役割 | 実証範囲・注意 |
|---|---|---|
| procd管理＋Dropbear UCI | daemon lifecycle、listen/認証設定を標準管理 | 保存rootfsの仕組み確認。投稿者端末での永続動作は未検証 |
| UCI firewall | 許可ruleを設定層で管理 | OpenWrt標準的な永続方式。KnOSによる書換え/revertの有無を再起動前に確認 |
| firewall include | firewall再構築時にruleを組み込む | `/usr/share/knos/firewall.include`は静的確認。実機でのinclude有効化・安全な差込位置は未確認 |
| `/data` seed→`sysupgrade.tgz` | 起動時overlay復元に必要なファイルを戻す | 2026-09のT6A過去復旧記録でSSH鍵アクセスが2回の再起動後に復帰。seed対象はauthorized_keys、Dropbear host keys/config、init/cron/watchdog等で、`/etc/passwd`・`/etc/shadow`は含めない。root password固定成功の証拠ではない |
| cron seed＋watchdog | 復元物を再配置し、runtime listener/firewallを監視 | 過去の独自復旧方式。20秒listener確認、毎分seed再配置、再起動後3〜4分待ち、2回連続復帰記録。唯一の推奨方式ではなく、侵襲・競合・ロックアウトリスクがある |

永続性を確認するなら、まず別管理経路とバックアップを確保し、現在IP/設定hash/runtime rule/listenerを記録してから、変更を一種類ずつ行う。固定IP `.2`、`.223`、`.247`等を現行端末へ流用しない。WANへSSHを公開せず、許可された管理LANと接続元へ限定する。

過去には300秒delayでseedを再配置するscript variantもあるが、最終runbookの検証方式はcronで、delay variant独立の成功結果は確認できない。本リポジトリには装置に変更を加えるseed/watchdogスクリプトを収録しない。歴史的スクリプトはPrivate archiveに残し、実行可能な手順として転載していない。
