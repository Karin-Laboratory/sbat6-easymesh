# SBAT6 EasyMesh 6 GHzクイックスタート

対象: 自分が所有し、root SSHが既に使えるSBAT6を2台。root取得前の手順は含めない。ここは2026-08の成功記録に沿った追試用の段階確認表で、完全設定を一括適用するスクリプトではない。

> **中止条件:** UART/console等の独立した復旧経路がない、現在IP・装置個体・firmwareを確認できない、または設定差分とrollback手順を用意できない場合は、変更せず観測だけにする。特にAgent化、MapMode変更、Wi-Fi再構成、rebootはSSHを失う可能性がある。

## 配線の考え方

物理LAN/WANポート番号やケーブルを挿した実ポート名は保存資料から特定できない。各個体のラベルと現在のbridge memberを確認し、WAN/LANを推測で指定しない。

### 1. 設定準備

```text
             ┌── 管理PC (SSH / console)
共通管理L2 ──┤
             ├── SBAT6 A (Controller候補)
             └── SBAT6 B (Agent候補)
```

両機が同じ初期管理IPv4を持つ場合は共通switchへ同時接続せず、1台ずつ隔離して個体識別する。上位DHCP serverの位置とsubnetを先に記録する。

### 2. Ethernet onboarding

```text
上位LAN / DHCP server
          │
    SBAT6 A (Controller)
          │ Ethernet (実験時のport番号は未復元)
    SBAT6 B (Agent)
```

これは論理接続図。実験では有線での自動discoveryを先に観測し、必要な場合のみonboarding CLIを検討した。`onboarding 0`を毎回実行したとは記録されていない。

### 3. 無線BH完成

```text
上位LAN / DHCP server
          │
    SBAT6 A (Controller)
          ))) 6 GHz EasyMesh BH (((
    SBAT6 B (Agent)
          │ Ethernet
    有線クライアント
```

## Step 1 — 機器・firmwareを確認

**目的:** 2台とも対象系列で、実験記録と大きく異なるbuildでないことを把握する。

**コマンド (各機):**

```sh
id
uname -a
cat /etc/openwrt_release 2>/dev/null
for f in /tmp/sysinfo/model /tmp/sysinfo/board_name; do
    [ ! -r "$f" ] || { printf '%s: ' "$f"; cat "$f"; }
done
```

**記録上の期待:** root (`id -u`が`0`)、Linux 5.4系列、OpenWrt 21.02系を示す保存データ。T6A rootfsに`MediaTek evb6990_cpe_mt7990_emmc`の機種表示がある。純正firmware revisionとA/B bankの完全な共通manifestはない。

**成功判定:** 本体ラベル/外観、model/board、build/bank、hostname、接続経路を手元で対照し、A/BをIPだけで識別しない。

**失敗時:** 情報源がない値を推測しない。vendor firmware・SoC・driverが記録と異なる場合はこの手順を適用せず、診断だけで止める。

## Step 2 — A/Bの役割を識別

**目的:** Controller候補とAgent候補を固定する。

**コマンド:** Step 1のmodel/hostname/board確認を使う。必要なmac/serialは公開ログへ出さず、所有者のローカル表で本体ラベル・接続ポートと照合する。

**期待状態:** 2026-08成功記事ではT6A A=Controller、T6B B=Agent。

**成功判定:** A/B、電源、LANケーブル、管理経路を装置の横にラベル表示できる。

**失敗時:** IPが`.2`/`.223`/`.247`だから同一機と決めない。各IPは異なる時期の履歴値である([履歴表](03-root-access.md#管理ipと個体識別の変遷))。

## Step 3 — SSH・管理経路を確認

**目的:** 設定変更後のSSH断をMesh障害と誤認しないよう、管理面を先に測る。

**コマンド (各機):**

管理PC上でまずrepoのscriptを検査する。端末へ置いて実行する場合は、現在の管理IPを確認して一時領域へ転送する（`<現在の管理IP>`は所有者が特定した値に置換）。

```sh
sh -n scripts/sbat6-diagnose.sh
scp scripts/sbat6-diagnose.sh root@<現在の管理IP>:/tmp/sbat6-diagnose.sh
ssh root@<現在の管理IP> 'sh /tmp/sbat6-diagnose.sh'
```

このscriptは読み取り専用で、IP/MAC/SSIDを隠す。転送した一時ファイルは診断後に削除してよい。共有ログへ端末内の未匿名化出力を貼らない。

**期待状態:** SSH daemon/procd、listen port、管理interface、DeviceRole/MapMode、mapd process、APCLI状態が`unknown`でなく採取できる。6 GHz BH未成立なら`apclix0`がdownでも異常ではない。

**成功判定:** SSHとは別の管理経路と、両機それぞれの現在IP/hostname識別方法を確認。

**失敗時:** `unknown`は不通やMesh失敗を意味しない。SSH、DHCP、bridge、topologyを[トラブルシューティング](25-easymesh-troubleshooting.md)に従い別々に調べる。別経路がない場合、次の書込み操作へ進まない。

## Step 4 — 変更前設定をroot-onlyで保全

**目的:** 記事に実際に記録されたEasyMesh関連ファイルを変更前に保存する。

**記事記載のbackupコマンド (各機で実行する場合):**

```sh
umask 077
stamp=$(date +%Y%m%d-%H%M%S)
backup="/root/easymesh-backup-$stamp"
mkdir -p "$backup"
cp -a /etc/config/mapd /etc/map/mapd_default.cfg \
    /etc/map/mapd_user.cfg /etc/map/mapd_cfg /etc/map/1905d.cfg \
    "$backup"/
```

これは記事の`/root/easymesh-backup` + `cp -a`対象を、衝突しない日時名にした記録ベースの退避例。wifi profileや追加MLOファイルには秘密があるため、必要な場合は追加でroot-onlyに保管する。退避物をPC/issue/Gitへコピーしない。

**期待状態:** backup path内に対象ファイルがあり、owner/modeが維持される。

**成功判定:** 別経路から対象機の復旧ができ、各ファイルのbefore checksumをローカル記録する。復元コマンドは機器世代・KnOS writerに依存するため、実験開始前に現行backupから戻す方法を個別検証する。

**失敗時:** ファイル不存在やdisk full、復旧方法不明なら設定を変えず終了。

## Step 5 — 変更前のrole/mesh値を確認

**目的:** 永続入力とruntime値のずれを発見する。

```sh
uci -q get mapd.mapd_cfg.DeviceRole
uci -q get mapd.mapd_cfg.MapMode
uci -q get knos.network.easymesh
uci -q get knos.flags.mesh
grep -E '^(DeviceRole|MapMode|BhPriority2G|BhPriority5GL|BhPriority5GH|BhPriority6G|AutoBHSwitching|NtwrkOptMldBhPriority)=' /etc/map/mapd_user.cfg /etc/map/mapd_cfg 2>/dev/null
```

**記事にある成功時値:** A `DeviceRole=1`, B `DeviceRole=2`, 両方`MapMode=1`、双方`knos.network.easymesh=1`と`knos.flags.mesh=1`。Controller成功時のpriorityは6 GHz=1、5 GHz low/high=2、2.4 GHz=3、`AutoBHSwitching=1`。MLO追加時は`NtwrkOptMldBhPriority=1`も保存設定で確認。

**成功判定:** A/B役割とMapModeが一致し、KnOS flagが既に1。`mapd_user.cfg`と生成済み`mapd_cfg`の差を理解した。

**失敗時:** flagやMapModeが違う場合に推定の`uci set`をしない。priority値は成功構成の確認値で、未確認firmwareへ無条件に書かない。writerが未復元のController設定を変えるなら終了する。

## Step 6 — Controllerを確認

**目的:** AがControllerとして起動する永続設定を確認する。

**コマンド:** Step 5のread-only UCI/限定grepをAで確認。

**期待状態:** `DeviceRole=1`, `MapMode=1`, KnOS flags=`1`。Controllerの実験時priority値はStep 5のとおり。

**成功判定:** `DeviceRole=1`と生成runtime `mapd_cfg`が再起動後も同値になる入力が確認できた。

**失敗時:** 本人記事はController成功値を示すが、Controller roleを初期導入した正確なwriter commandは復元できていない。勝手にAgent向け`wificonf` commandを`1`へ置換して実行せず、ここで止める。

詳しくは[Controller設定](05-controller-setup.md)。

## Step 7 — Agentを設定

**目的:** Bの永続user overrideをAgentにする。これは設定を書き、管理経路を変える工程。

**成功記事に明記されたコマンド (B上):**

```sh
wificonf -f /etc/map/mapd_user.cfg set DeviceRole 2
```

**作用:** `/etc/map/mapd_user.cfg`の`DeviceRole`を2へ書く。OEM scriptは起動時に`mapd_user.cfg`を`mapd_cfg`へmergeし、生成した`DeviceRole`からAgent用`map_agent=1`, `map_root=0`、`p1905_managerd -r1`の起動分岐を選ぶ。

**直後の確認:**

```sh
grep -E '^(DeviceRole|MapMode)=' /etc/map/mapd_user.cfg
```

**期待状態:** `DeviceRole=2`, `MapMode=1`。記事に記録されたOEM実装はruntime cfgにもroleを書いていたが、手作業で生成物だけ直すと次のbootで上書きされ得る。本手順はuser cfgのコマンドだけを示す。

**成功判定:** Bの復旧経路が維持され、user overrideにrole2が保存された。

**失敗時:** 書込エラー、MapMode不一致、SSH断は処理成功扱いにせず、別経路からbackup/role/topology/networkを確認。管理IPが見えなくてもMesh roleとは別に判定。

詳細は[Agent設定](06-agent-setup.md)。

## Step 8 — OEM起動シーケンスとEthernet onboarding

**目的:** 1905 discovery/onboardingをBH radio切替から分離する。

実験ではrole設定後に通常rebootを行い、個別daemonを手動起動せずOEM boot sequenceを使用した。再起動は復旧経路が使える場合だけ実行する。

```sh
# 独立復旧経路とrollbackを確認した所有者が、対象B上でのみ実行
sync
reboot
```

**正常状態:** `mapd`, `p1905_managerd`, `wapp`が起動。Controller上で`mapd_cli /tmp/mapd_ctrl agent_list`と`dump_topology`を確認。公開記事の報告表記はController distance 0、Agent `Device role: 02`, `Distance from controller: 1`。

```sh
mapd_cli /tmp/mapd_ctrl getrole
mapd_cli /tmp/mapd_ctrl agent_list
mapd_cli /tmp/mapd_ctrl dump_topology
mapd_cli /tmp/mapd_ctrl dump_topology_v1
```

CLI出力は秘密identifierを含む可能性があるため共有前にMAC/IP/SSIDを除く。これらはread-only診断。`mapd_cli /tmp/mapd_ctrl onboarding 0`は状態変更し得る操作で、成功時必須だった実行記録がなく、自動実行しない。

**成功判定:** Controller topologyにAgent、距離0/1。Interface/ip pingだけでは代用しない。

**失敗時:** daemon/role/MapMode/Ethernet linkとDHCPを調べる。`agent_list`に出ない場合は6 GHz設定へ進まない。

手順/CLI説明は[有線onboarding](07-wired-onboarding.md)。

## Step 9 — 6 GHz BHを確認

**目的:** Ethernet接続中の親子認識から無線backhaulへ自動移行できる状態を確認。

実験成功時のpriority、radio/profile、SSID/security値をStep 5で照合する。秘密のSSID/PSK/BSSIDは共有しない。完全なwireless profileと初期生成コマンドは保存されていないため、同じprofileがない場合はここで止める。`apclix0`という名前だけで6 GHzと決めない。

**Ethernet接続中の観測コマンド:**

```sh
mapd_cli /tmp/mapd_ctrl bh_info
mapd_cli /tmp/mapd_ctrl bh_conn_status
mapd_cli /tmp/mapd_ctrl bh_conn_type
mapd_cli /tmp/mapd_ctrl show_bh_link_metric
```

Ethernetがprimaryの間は、`show_bh_link_metric`が`No Bh link Info as this device is connected via Ethenet.`を返した保存例がある。これはその時点でwireless BH link metricが出ないことと整合し、onboarding失敗を意味しない。

**成功判定は抜線後のStep 10で行う。** 実験時にchannel 21 / 6055 MHz / 160 MHz / 4addr onを観測したが、地域規制・firmware差をまたぐ推奨値ではない。

詳しくは[6 GHz BH手順](08-wireless-backhaul.md)。

## Step 10 — Ethernetを抜き、無線BHを確認

**目的:** 無線バックホールがprimary pathになった状態を識別する。

独立の管理経路から、Agentの以下を採取する。

```sh
mapd_cli /tmp/mapd_ctrl bh_conn_status
mapd_cli /tmp/mapd_ctrl bh_conn_type
mapd_cli /tmp/mapd_ctrl dump_topology
for i in apcli0 apclii0 apclix0; do
    printf '%s ' "$i"
    cat "/sys/class/net/$i/operstate" "/sys/class/net/$i/carrier" 2>/dev/null
    cat "/sys/class/net/$i/statistics/rx_bytes" "/sys/class/net/$i/statistics/tx_bytes" 2>/dev/null
done
```

**当時報告された期待状態:** `bh_conn_status=1`, `bh_conn_type=Type 4`; topologyのAgent `Distance from controller: 1`, `Backhaul Medium Type: 6G`; `apcli0`/`apclii0` down、`apclix0` carrier 1/LOWER_UPかつbytes増加。

**成功判定:** topology + BH status/type/medium + APCLI traffic + Agent側Ethernet clientの疎通が全部確認できる。carrier=1だけでは成功としない。

**失敗時:** Ethernetを戻せる独立経路を維持し、APCLI association/profile/security/channelとBH statusを比較。接続不可だけでtopology失敗としない。

## Step 11 — Agent側EthernetでL2 trafficを確認

**目的:** management SSH/pingを超えて、Agent Ethernet配下から上位側へのdata planeを確認する。

```text
PC-A -- Controller A ))) 6 GHz BH ((( Agent B -- PC-B
```

**汎用iperf3確認:** PC-Bで`iperf3 -s`、PC-Aから`iperf3 -c <PC-Bの現在IP> -t 20`、逆方向は`iperf3 -c <PC-Bの現在IP> -t 20 -R`。実験当時のPC IPや管理IPを流用しない。テスト前後にAgent APCLI RX/TX bytesが増えることも確認。

**期待状態:** PC端末からのEthernet抜線中のL2/L3到達。本人公開記事は有線client間のping/iperf3を報告するが、全VLAN/multicast/MTU網羅試験はない。

**性能値の区別:** SBAT6本体をiperf3 endpointにすると6 GHz単独/後続MLOとも約330–380 Mbps域。MLO後のPC↔PC 1GbE端末は1 streamで936/909 Mbps、10 streamで941/908 Mbps。後者はこの1GbE構成での測定で、無線最大能力ではない。

詳細は[L2検証](09-l2-bridge.md)と[性能結果](11-performance.md)。

## Step 12 — reboot後を別に確認

**目的:** 最終的に成功した状態が通常bootから復帰するか確かめる。

先に管理SSH/serial/rollbackの両方を確保してから、変更を行った個体で通常の`sync; reboot`を手動実行する。再起動は自動診断scriptから実行しない。

**実測されたMLO復帰:** DHCP再取得約170秒、EasyMesh再参加約173秒、SSH復帰直後から`mld_sta257 ref_cnt=2`/`band_idx=1,2`、さらに342秒以上維持。起動直後から通信無停止という意味ではない。

**6 GHz単独BHについて:** 6 GHz BHの再接続成功とMLO設定保持の実測を混同しない。全個体の通常再起動後L2試験を再現可能な独立logで証明できていないため、自分の試験で同様に確認する。

**失敗時:** 旧IPへのSSH不可だけでresetしない。DHCP lease/FDB/topology/BHを別々に見て、[復旧章](14-recovery.md)と[トラブルシューティング](25-easymesh-troubleshooting.md)へ進む。

## 追試で埋める必要がある情報

SSID/PSKを含む無線profile、正確なport pair、初回Controller設定writer、Agent DHCP/bridge完全snapshot、全成功時command transcript、full IEEE 1905 packet traceは公開可能な根拠が揃っていない。したがって実験を始める条件が揃わなければroleを変えず、観測だけで終了する。
