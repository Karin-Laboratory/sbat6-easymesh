# 20. SSHが消えたときの診断

まず接続先IPと端末同一性を確認する。ping失敗、TCP/22失敗、SSH daemon停止、Mesh脱落は別の事象である。接続が残っているうちにread-only情報を採取し、接続断後は別管理経路で比較する。

## read-only採取例

BusyBox搭載版ではoptionが異なる場合がある。使えるコマンドだけ実行し、ログ/設定本文を公開しない。

```sh
 date -Is 2>/dev/null || date
 uptime
 ip -br addr 2>/dev/null || ip addr
 ps w | grep -E '[d]ropbear|[s]shd|[p]rocd'
 ss -lntp 2>/dev/null || netstat -lntp 2>/dev/null
 /etc/init.d/dropbear status 2>/dev/null
 uci show dropbear 2>/dev/null
 iptables -S INPUT 2>/dev/null
 iptables-save 2>/dev/null | sha256sum
 sha256sum /etc/config/firewall /etc/config/network /etc/config/dropbear 2>/dev/null
 logread 2>/dev/null | tail -n 200
```

`logread`は認証・ネットワーク識別情報を含み得る。外部共有前に必要箇所だけ抜き出し、アドレス、MAC、SSID、PSK、token等をマスクする。`iptables-save`の全出力も無条件で貼らず、hashや必要なchain差分を使う。

## 観測からの切り分け

| 観測 | 疑う経路 | 次に照合するもの |
|---|---|---|
| daemon稼働、22番listenerあり、接続元から到達不可 | firewall、経路、接続元制限 | runtime chain、UCI設定、route、接続元IP |
| firewall設定hashは同じ、runtime ruleだけ差 | firewall reload/再構築 | hotplug、firewall/netifdログ、WAN/LAN再構成時刻 |
| listener消失 | Dropbear/OpenSSH停止・再生成・bind失敗 | procd状態、起動引数、network event、ログ |
| UCI hash/値が変化 | vendor/KnOS設定書換え、UCI revert | `knos_config`、`auto_adapt`、`ql_*`の時刻・処理 |
| `/etc/passwd`/`shadow`参照先が変化、Dropbear enable変化 | KnOS system_mode/factory分岐 | readlink先、該当UCI値、起動ログを秘密情報なしで照合 |
| uptimeがリセット | reboot、watchdog、procd timeout等 | boot log、boot bank、再起動時刻 |
| Mesh topology正常、管理IPv4だけ不通 | DHCP・bridge・IP変化 | mapd topologyとagent IP、`br-lan`、DHCP lease |

Topologyが保たれているかは`mapd_cli /tmp/mapd_ctrl agent_list`、`dump_topology`、`bh_info`等で独立確認する。通信不可だけからEasyMesh失敗と結論しない。
