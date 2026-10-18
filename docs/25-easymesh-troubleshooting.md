# 25. EasyMesh / backhaul / MLO トラブルシューティング

最初に「管理通信」「EasyMesh topology」「backhaul link」「DHCP/L2 data plane」を別々に記録する。SSH不能はMesh離脱の証拠ではなく、Mesh表示が正常でもclientのDHCP/L2が通る保証はない。ログ採取時はSSID、PSK、MAC、IP、鍵やtokenを公開しない。

| # | 症状 | 観測・判定 | 確認済み原因 / 候補 | 過去の対応・復旧 | 参照 |
|---:|---|---|---|---|---|
| 1 | SSH接続できない | IP/route/neighbor、sshd/dropbear listener、別管理経路を確認。Mesh CLIを別途照会 | KnOS/firewall/管理IP変化の保存記録あり。SSH不能だけでrole失敗とは判定不可 | [SSH診断](20-ssh-loss-troubleshooting.md)、console/既知の管理路で復旧。再起動を連打しない | 18,20 |
| 2 | root SSH後に切断 | firewall rule/listenerと接続時刻、procd logを分けて採取 | 起動時復元とiptables更新候補。発火した全経路は未特定 | [永続化章](18-ssh-firewall-persistence.md)のread-only確認順。復旧路なしなら設定変更前に中止 | 18 |
| 3 | iptablesルールが消える | `iptables-save`相当の匿名化snapshot、service/boot時刻を比較 | ruleset再生成/KnOS管理候補。個別実験での全発火条件は不明 | 変更前に別管理経路と保存済み復旧策を準備。個体固有の公開scriptを流用しない | 18,20 |
| 4 | Controllerが認識されない | A role、MapMode、KnOS flags、daemon/socket、IEEE 1905 discoveryを確認 | DeviceRole不整合/daemon未起動/有線経路候補。全失敗時の単一原因は未確認 | まず有線で各面を確認。role writerが未復元なら値だけ見て変更を捏造しない | 05,07 |
| 5 | Agentが認識されない | B role、service、Controller `agent_list`/topology、Ethernet link | role/MapModeまたは1905到達性候補 | Agent writerの履歴値と実状態を照合し、socketと配線を確認 | 06,07 |
| 6 | Distanceが期待値でない | topology両端、Controller=0/Agent=1、role、link medium | discovery/topology未成立候補。Distanceの生CLI transcriptは未保存 | 有線参加に戻りCLI read-only照会、daemonとroleを確認 | 07,26 |
| 7 | Ethernetではつながるが無線へ移行しない | BH medium、status/type、APCLI、profile source/runtimeを照合 | profile未生成/priority/security不整合候補 | 優先値は成功報告の値と現在機器値を比較。SSID/PSKはローカルで照合 | 08, matrix |
| 8 | 6 GHz APCLIがUPしない | `apclix0` link/operstate/carrier、driver log、channel/regulatory状態 | association/profile/地域設定候補。carrierだけでは判定不可 | 2.4/5/6 APCLI対応を再確認。実験channelを固定推奨として流用しない | 08 |
| 9 | BH statusが成立しない | `bh_conn_status`, `bh_conn_type`, medium, topologyを併記 | associationまたはEasyMesh BH選択候補 | Ethernet親子認識と無線BHを別工程にして差分を記録 | 07,08 |
| 10 | Ethernet抜線で通信断 | 抜線前後のtopology/BH/countersとclient DHCP/ARP | BH未成立、bridge経路、client側いずれか。現象だけでは確定不可 | ケーブルを戻し有線診断へ。管理通信とMesh状態を別採取 | 08,09 |
| 11 | Mesh成立後DHCP不可 | DHCP server位置、lease、Agent bridge、VLAN、packet path | MapModeのnetwork再構成/bridge/DHCP設定候補 | 物理管理路を保持し、DHCPとtopologyを別判定 | 09,17 |
| 12 | Agent管理IPが変わる | 新旧IP、DHCP lease、ARP、hostname/MAC台帳、console | MapMode 1でbridge/DHCP再構成する挙動と整合 | 過去IPを固定値として扱わず、lease/consoleから現在値を特定 | 06,09 |
| 13 | L2通信できない | bridge member、DHCP/ARP/subnet/gateway、APCLI counter | bridge membership/VLAN/client経路候補 | Agent Ethernet clientでDHCPから順に検証。ping単独で結論を出さない | 09 |
| 14 | MLOが約100 msで切れる | M3/RSNE/deauth reason、MLD ref count、band indices | 保存captureではM3のRSNE mismatch後reason 1 deauthを確認 | 5/6 GHz security profileを生成元から照合。UCIだけ直すと戻った履歴あり | 10 |
| 15 | RSNE mismatch | 5 GHz/6 GHz Beacon/Probe RSNE AKM/PMF、M3 trace | 初回5 GHz WPA2/PSK + PMF optionalと6 GHz SAE/requiredの不一致 | MLO章の歴史的修正値を参照。元profileとruntimeを両方確認 | 10 |
| 16 | runtime provisioningで設定が戻る | source UCI/profile、generated cfg、hostapd/DAT値を起動後比較 | OEM EasyMesh生成処理がruntime BSS値を再構成 | 生成元を特定し、live radio状態をground truthとして記録。未復元writerを創作しない | 04,10 |
| 17 | 再起動後MLOが戻らない | boot後のrole/topology/BH/MLD、時刻ごとの状態 | 起動順/生成設定/認証profile候補。全原因は未確定 | Qiita成功報告では再参加約173秒。十分待って各層を再判定し、設定hashを比較 | 10,12 |
| 18 | iperf3が遅い | endpoint位置、stream数、方向、1GbE link、CPU、BH counters | SBAT6本体endpoint CPUとPC間Ethernet測定を混同していないか | 約350/330 Mbpsは本体endpoint、約0.91–0.94 GbpsはPC間MLO経由の別条件 | 09,11 |
| 19 | ブートループ | console起動段階、bank/overlay、直前変更を保存 | このEasyMesh記録から特定のブートループ原因は確認できない | 繰り返し電源断やflash操作を避け、[復旧記録](14-recovery.md)を参照。device固有の安全な戻し方を優先 | 14,16 |

## 変更前に必要な復旧条件

DeviceRole/MapMode、bridge、DHCP、Wi-Fi securityの変更は管理経路を失う可能性がある。設定退避、個体の識別、独立したconsole/UARTまたは同等の復旧路がない場合は実行しない。保存されたA/B固有のIP、鍵、scriptを別端末にそのまま適用しない。復旧経路がなくなった場合のfactory resetやfirmware書き換えを、この資料だけで安全と判断できる根拠はない。
