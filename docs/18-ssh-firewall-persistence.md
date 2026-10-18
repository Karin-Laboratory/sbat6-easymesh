# SSH・firewall永続化の診断と過去の復旧記録

## 最初に分けて確認する

SSH不可には、管理IPの変化、経路/L2障害、runtime firewall、daemon/listener停止、認証設定、起動中の一時状態がある。これらを区別し、EasyMesh topologyも別に確認する。通信できないことだけでMesh失敗とは判定しない。

調査順序は、(1) 対象個体と現在の管理経路、(2) IPとinterface、(3) daemon・procd・listen socket、(4) runtime firewallと永続UCI、(5) KnOS再構成経路、(6) 起動時overlayを確認する。リポジトリの[`sbat6-diagnose.sh`](../scripts/sbat6-diagnose.sh)は値をマスクするread-only補助であり、出力は必ず実機の状態や時刻と照合する。

## 4方式の比較

| 方式 | 役割 | SBAT6での根拠と限界 |
|---|---|---|
| Dropbear + procd | daemon lifecycle、respawn、network trigger | 保存rootfsのinit scriptにprocd/respawn等を静的確認。別の`knos_config`分岐がDropbear UCI enableを変更する。OpenSSHにはそのまま当てはまらない |
| UCI firewall | firewall serviceがruntime ruleを生成 | 標準OpenWrt/fw3での一般的な管理方法。SBAT6/KnOSがあとから値を書換え/revertするか実機検証が必要 |
| firewall include | firewall再構築時に独自ruleを含める | 保存rootfsに`/usr/share/knos/firewall.include`を確認。実機でincludeされる条件と安全な差込位置は未確認 |
| `/data` overlay seed + cron | one-shot archiveを次回起動向けに再配置 | 2026-09 T6Aの過去runbookで2回連続reboot後に鍵SSH復帰。password DBの永続化ではない |

## Dropbear + procdを調べる

設定ファイルだけでなく、実プロセスとsocketを同じ時点で確認する。秘密のhost keyやauthorized keyの内容は表示しない。

```sh
ps w | grep -E '[d]ropbear|[s]shd|[p]rocd'
command -v dropbear; command -v sshd
ss -lntp 2>/dev/null || netstat -lntp 2>/dev/null
/etc/init.d/dropbear status 2>/dev/null
uci -q get dropbear.@dropbear[0].enable
```

Dropbearは通常`/etc/init.d/dropbear`がprocdへservice定義・起動条件を渡す。procd管理外で`rc.local`から別Dropbearを起動すると、重複bind、異なる引数/host key、procdによる監視対象外を招く。保存rootfsではprocd respawn/network triggerを確認した一方、KnOS設定初期化がUCIのenableを切り替える条件も見つかった。`status`、process、socket、UCI値を揃えて観測する。OpenSSHの場合はunit/init、設定ファイル、起動管理が別実装である。

## UCI firewallとruntime ruleを比べる

`iptables -I`はruntime kernel tableへの一時変更で、`/etc/config/firewall`には保存されない。fw3/firewall serviceのreloadはUCI/includeからtableを再生成するため、手動ruleだけが消えることがある。通常のOpenWrtでは許可ruleをUCI管理下に置くのが一般的だが、KnOSのvendor処理やrevertが後から上書きする可能性は別途調べる。

読み取り時はUCIの秘密・内部アドレスをそのまま共有せず、必要なsection/type/有効状態だけをローカルで比較する。保存rootfsの静的解析では次の経路を確認した。10/18の個別SSH断でどれが実行されたかは立証できていない。

| 経路 | 保存コードから確認したこと | 確度 |
|---|---|---|
| `/etc/hotplug.d/iface/20-firewall` | interface eventからfirewall service呼出し | 静的実装確認 |
| `ql_wwan_config.sh` | WWAN再構成の中にfirewall reload | 静的実装確認、当該時の実行不明 |
| `ql_lan_config.sh` | UCI変更/commitとfirewall reload | 静的実装確認、当該時の実行不明 |
| `ql_mipc.sh`, `mipc_wan.init`, `auto_adapt` | network/interface再構成に関係する処理候補 | 静的候補。個別イベントのcaller/実行時刻は未確定 |
| `knos_config` | system modeに応じたUCI変更を含む | 静的実装確認。10/18の発火は未確認 |
| `knos_uci_revert.sh` | firewallを含むrevert処理 | 静的実装確認。直接caller未特定 |

## 2026-09 T6A `/data`復旧方式

### 公開方針: 案B（実行手順は非公開、一般向け再現対象外）

過去のT6AでSSH鍵認証経路を2回連続再起動後に復帰させた実機記録はある。一方、この方式は当該機器のKnOS overlay boot flow、`/data`の保持、one-shot `sysupgrade.tgz`消費順、Dropbear/firewall実装に依存する。rootfs/build/個体へ安全に移植できる実行手順、archiveを作る正確な最終manifest、独立rollbackを公開資料だけで保証できないため、実行可能なseed作成・cron/watchdog scriptや手順は公開しない。

公開するのは構造、成功条件、明確な制約までとする。秘密鍵・authorized_keys本文、端末固有IP/識別値、メーカー秘匿ファイルは非公開。root passwordの再起動後認証は未検証で、鍵認証成功から推定しない。

保存されたprivate runbookの記録では、`/data`は再起動をまたいで残る領域で、`/data/sysupgrade.tgz`は通常起動時にoverlayへ展開された後に消費されるone-shot入力だった。復元対象をそこへ一度置くだけでは次のbootで消えるため、同じ内容のseed `/data/sbat6-ssh-overlay.tgz`を永続領域に保持し、root cronが毎分seedから`/data/sysupgrade.tgz`を再配置した。起動時にはone-shot archiveが展開され、Dropbear関連ファイルと起動補助物がoverlayへ戻る。20秒間隔のwatchdogがruntime SSH listener/firewallを観測・復旧する構成も記録されている。

```text
/data/sbat6-ssh-overlay.tgz (persistent seed)
            │ cron: 約60秒ごとに再配置
            ▼
/data/sysupgrade.tgz (one-shot boot input)
            │ normal boot: overlayへ展開し消費
            ▼
/overlay/etc/... (Dropbear / authorized key / init / cron等)
            │ 起動後watchdogがlistener/firewall状態を確認
            ▼
SSH鍵認証の管理経路が復帰
```

runbookではSSH復帰まで約3〜4分待ち、2回連続の再起動でも鍵認証を確認した。300秒delay variantは存在するが独立成功は確認されていない。seedに`/etc/passwd`と`/etc/shadow`は含まれず、この結果はpassword persistenceの証拠ではない。

| 保存variant | 記録から言える範囲 | 公開判断 |
|---|---|---|
| `t6a_persistent_ssh_seed.sh` | seed archiveを準備するscript variantとして保存 | 詳細実行列・archive内容は非公開 |
| `t6a_persistent_ssh_seed_cron.sh` | cronからone-shot archiveをおよそ60秒間隔で再配置するvariant。**runbook上の2 reboot成功設計**と最もよく一致 | runbookでの成功は記録、完全scriptとarchiveのhash対応は公開しない |
| `t6a_persistent_ssh_seed_delay.sh` | 300秒待機する版が存在 | 独立成功記録なし。成功版と呼ばない |
| `t6a_ssh_keepalive_v2_install.sh` | 後続keepalive installer variant。保存runbookは約20秒間隔でSSH listener/firewall conditionを観測するwatchdogを説明 | このinstaller単体の独立成功、runbook最終archiveとの厳密な同一性は未確定。条件・script原本は非公開 |

最終の成功実証として採用するのはPrivate archiveの`T6A_RECOVERY_RUNBOOK_FOR_AI.md`にあるseed+minute cron+listener/firewall watchdogの構成記述であり、delay variantではない。成功条件はSSH鍵認証listenerが戻るまで約3〜4分待つこと、同じT6Aで連続2 reboot後にも戻ること。正確な単一script revisionとarchive payloadを独立artifact hashへ結び付けられないため、構造の実機成功と一般再現可能性は分ける。

この方式は通常の設定変更手順として推奨するものではない。cronとwatchdogの競合、誤ったoverlayによるロックアウト、起動時のKnOS再生成との競合、永続seedの改ざんリスクがある。私有runbook/scriptを本repoへ転載せず、履歴・ファイルhashは[SOURCES.md](../SOURCES.md)に記録する。復旧用途であっても、対象個体の一致、別経路、archive内容、overlayの復元対象、停止手段を先に検証する必要がある。

## 変更前から再起動後までの安全な確認順

以下は確認順序であり、変更を自動適用するscriptではない。再起動を伴う検証は、対象所有者が物理/別管理経路を確保した環境でのみ計画する。

1. **適用条件:** hostname/serial相当のローカル識別、firmware/bank、役割、現在IPと接続interfaceを照合する。過去の`.2`/`.223`/`.247`を現行接続先と仮定しない。
2. **変更前の確認:** uptime、daemon実体/引数、listener、procd status、Dropbear UCI enabled、firewall runtime summary、UCI設定状態、`/etc/passwd`/`shadow`のsymlink先を秘密本文なしで記録する。
3. **バックアップ:** 対象UCIと関連ファイルの権限を維持したローカル退避を所有者の復旧媒体へ取り、checksumを記録する。秘密鍵、shadow、PSKを共有場所/Gitへ置かない。
4. **復旧経路:** 別interface/console/物理復帰手段、正しい端末向けの復旧データ、作業中止条件を先に確かめる。SSH一経路しかない状態でnetwork/firewall/MapModeを変更しない。
5. **設定方式:** DropbearはprocdとUCI、firewallはUCI/includeの実装を確認してから一項目ずつ変更する。SBAT6ではKnOS writer/revertとの競合を考慮する。overlay seedは過去復旧の特殊方式であり、汎用設定例として再作成しない。
6. **変更直後:** SSHを張ったまま、listener、既存セッション、runtime firewall、UCI値、別管理経路からの新規接続を確認する。通信断時に別の設定を重ねない。
7. **再起動後:** reboot前に停止条件/復旧方法を再確認し、同じ識別項目を再取得する。過去seed方式での目安は3〜4分。SSH、firewall、認証、Mesh topologyを別々に判定する。
8. **失敗時:** console/別経路から変更直前のバックアップへ戻す。pingやSSHが戻らないだけでMesh設定を初期化しない。復旧経路が失われたら無関係な再起動・resetを試さず物理手順へ移る。

具体的な再現用変更コマンドは、この公開資料が対象にする端末状態/KnOS条件と一致する保証がないため、固定IPや無条件の投入例として示さない。成功時のEasyMesh値は[設定比較表](../configs/easymesh-values-matrix.md)を参照。
