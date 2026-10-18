# SBAT6 root取得後からEasyMesh親子化までの実践ガイド

対象は所有するSBAT6で正規にroot権限を取得し、管理経路を持つ人。初期侵入/RCE手順は扱わない。設定変更はSSH・管理IP・無線接続を失う可能性があるため、診断から始め、別の復旧経路がない作業は実施しない。

実作業の入口には[6 GHzクイックスタート](24-easymesh-quickstart.md)を使い、工程別の証拠不足は[再現性coverage](26-reproduction-coverage.md)、症状の切り分けは[トラブルシューティング](25-easymesh-troubleshooting.md)を参照する。この章は仕組みと判断順を説明する要約で、未復元writerを補完するものではない。

## Step 1: SSH断の層を判定

まず[診断章](20-ssh-loss-troubleshooting.md)のread-only観測を記録する。uptime、管理IP、実daemonとlisten socket、procd状態、runtime firewall、UCI設定hash、直近network/hotplugログを同じ時刻軸で比較する。TCP接続不可をMesh脱落と同一視しない。

## Step 2: SSH/firewallの永続性

一時的な`iptables -I`は再起動やfirewall reloadを越える設定ではない。保存rootfsではiface hotplugやWAN/LAN再構成によるreload経路を確認したが、掲示板投稿者の切断を直接起こした一つのcallerは特定できていない。[KnOS解析](17-knos-configuration-reset.md)、[永続化方式](18-ssh-firewall-persistence.md)を参照。

優先順位は、別経路を確保し、Dropbear/OpenSSHの実体とprocd/UCI管理状態、firewallの設定層、overlay復元条件を分けて確認すること。過去T6AのSSH鍵復旧成功はroot password永続化の証拠ではない。固定IPや過去スクリプトをそのまま投入しない。

## Step 3: 2台でEasyMeshを構成

### 役割と設定生成

実験時のControllerはT6A A、AgentはT6B B。`DeviceRole=1`がController、`2`がAgent、両方`MapMode=1`。記事にある実行値確認は`uci -q get knos.network.easymesh`、`uci -q get knos.flags.mesh`。成功時は双方`1`。OEM例のAgent設定writerは`wificonf -f /etc/map/mapd_user.cfg set DeviceRole 2`（一部フローではruntime cfgにも書く）と記事にある。これは設定変更コマンドの記録であり、現在の機器でそのまま実行する指示ではない。変更前にprofile生成経路・rollbackを確認する。Controllerでは`BhPriority6G=1`、5 GHz優先値2、2.4 GHz値3、`AutoBHSwitching=1`、`NtwrkOptMldBhPriority=1`を確認した。

`/etc/map/mapd_default.cfg`と`mapd_user.cfg`等を入力にOEMのUCI変換/起動スクリプトがruntime `/etc/map/mapd_cfg`や`1905d.cfg`を生成し、`mapd`、`p1905_managerd`、`wapp`等が起動する。runtime生成物を恒久設定の入力元と誤認しない。役割起動ではOEM scriptの`map_agent`/`map_root`と`p1905_managerd -r`が連動する。保存値の完全な実行可能設定は公開していない。

### Ethernet onboardingから6 GHz無線BHへ

まずEthernetを接続したのは、IEEE 1905.1 discovery/onboardingと無線BH確立を分けて診断するため。記事では`mapd_cli /tmp/mapd_ctrl getrole`、`agent_list`、`dump_topology`、`bh_info`等で状態確認している。`onboarding 0`はEthernet onboardingのCLI能力として記載されたもので、成功時に必ず手動実行したコマンドと混同しない。

成功時の観測はController distance 0、Agent distance 1、Backhaul Medium Type 6G、Agent `bh_conn_status=1`、`bh_conn_type=Type 4`。APCLIは`apcli0`=2.4 GHz、`apclii0`=5 GHz、`apclix0`=6 GHz。Ethernetを抜いた後も`apclix0`がcarrier=1/LOWER_UPでcounter増加、他APCLIはdown。報告された実測では6 GHz channel 21 / 6055 MHz / 160 MHz、4addr on。Ethernet抜線状態でT6B Ethernet端末のL2延長を確認した。

管理IPはモード/DHCPにより変化する。2026-08-23成功記事のT6A Controllerは`.2`、T6B Agentは`.223`。別の再起動snapshotではB `.247`。`.1`は補助管理アドレスとして設定資料に現れ、後日のT6A単独STA管理候補`.13`は別時期・別モード。IPだけで個体を同定しない。

## Step 4: MLOへの拡張

6 GHz単独BHを第一到達点にしてから5+6 GHz MLOを別段階として扱う。本人公開記事では初回に約100 ms切断とRSNE mismatchが発生。5 GHz WPA2系と6 GHz SAE/PMF requiredの不一致、runtime provisioningによるprofile書戻しを修正し、両側のBSS profileをSAE/PMF requiredに揃えた後、4-way handshake、`mld_sta257 ref_cnt=2`、band_idx 1/2を確認したと報告する。

再起動後、約170秒でDHCP、約173秒でEasyMesh再参加、少なくとも342秒のMLO継続を報告。両band driver counter増加中のEthernet端末間iperf3は約0.91〜0.94 Gbps。これは公開本人の当時の測定記録で、保存した生ログを独立再解析した値ではない。EHT320試験案は未実行であり、MLO成功と混ぜない。[MLO](10-mlo.md) · [性能](11-performance.md)

## Step 5: 失敗時の戻し方

変更前に設定hash・役割・管理IP・topology・現在linkを記録する。設定変更は一項目ずつ行い、変更後すぐにmanagement pathとMesh stateの両方を見る。接続が切れたら無関係な設定を追加せず、別管理経路でuptime/IP/listener/firewall/topologyを採取する。自動factory reset、iptables flush、service一括停止、古いwatchdog scriptの実行を標準復旧にしない。

実験成功の設定一式、全秘密値を除いた復元可能snapshot、EHT320のオンエア結果、root password永続性は未取得/未検証である。記録された値から不足分を推測して再構成しない。
