# 14. 復旧と作業中止基準

## 変更前

- 管理LAN上のIP、hostname、機器ラベル、role、uptime、`br-lan`、listener、firewall rule、Mesh topologyを記録する。
- 設定差分のbackupと別管理経路（有線/console等）が確保できない変更は進めない。
- 一度に一種類だけ変更し、変更後に管理面とMesh面を独立確認する。

## 接続を失ったとき

1. 同一IPへのping失敗とTCP/22不可を分ける。DHCP leaseや管理IP変化を確認する。
2. 別経路があればuptime、address、daemon/listener、runtime firewall、UCI hash、log、`mapd_cli` topologyを読み取る。
3. Mesh topologyが正常ならSSH/firewall/DHCPの管理面問題として扱い、EasyMeshを再設定しない。
4. Listenerがあるのに外部から届かない場合はfirewall/routeを切り分ける。listener不在ならservice状態と起動ログを確認する。
5. 原因不明のままiptables flush、FW停止、一括kill、`knos_uci_revert`、factory resetを行わない。

## 過去のT6A SSH復旧方式

2026-09 runbookに`/data` seed→`/data/sysupgrade.tgz`→起動時overlay restore→cron/watchdogの構成が記録される。runbookでは`/data`をext4のp43永続領域として確認し、起動時の`sysupgrade.tgz`は一回消費・削除された。watchdogは20秒周期のlistener/firewall確認、cronは毎分seedをrestore archiveへ再配置。`rc.local`側の起動とboot後に3〜4分かかったnetwork復帰が重なり、最初の1〜2分のtimeoutは復旧失敗と誤判定しないようrunbookに記される。PID存在だけでは実際の`0.0.0.0:22` listen socketを保証しないため、PID-only確認からlistener確認を優先する改訂があった。復旧は起動後通常3〜4分かかり、2回の再起動後に鍵SSHを確認した。これは過去の所有機器上の復旧実績で、現在の別個体へ安全に適用できる汎用手順ではない。詳細な変更scriptは非公開かつ掲載しない。

root password永続性は未検証。
