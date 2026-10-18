# 23. 公開前の事実・安全監査

監査日: 2026-10-19
対象: `Karin-Laboratory/sbat6-easymesh` の公開内容と、その根拠資料
実機接続・変更: なし

## 主要な訂正と証拠区分

| 主張 | 判定 | 根拠 | 公開時の限定 |
|---|---|---|---|
| T6A Controller / T6B Agent、role 1/2、MapMode 1 | 実機確認済み（本人公開報告）、保存スクリプト整合 | 2026-08-23 Qiita、`mlo_apply_a/b.sh` | 役割の識別はIPだけで行わない |
| Ethernet onboarding後、6 GHz単独EasyMesh BH | 実機確認済み（本人公開報告） | topology distance 0/1、6G medium、BH status 1/type 4、APCLI、iperf3 | IEEE 1905.1の全packet traceは未取得 |
| ケーブルなしL2延長 | 実機確認済み（本人公開報告） | Ethernet抜線後のAPCLI状態と配下端末通信の報告 | VLAN/multicast等全機能の透過保証ではない |
| 5+6 GHz 2-link MLO | 実機確認済み（本人公開報告） | RSNE修正後の4-way handshake、MLD ref_cnt=2、band_idx 1/2、双方counter | 保存スクリプトは設定を補強するが、生ログ全行の独立再解析とは区別 |
| MLO通常reboot復帰 | 実機確認済み（本人公開報告） | `sync`後`reboot`、約170秒DHCP、173秒Mesh再参加、342秒以上観測 | 起動直後無停止ではない |
| MLO Ethernet端末間性能 | 実機確認済み（本人公開報告） | 1 stream 936/909 Mbps、10 stream 941/908 Mbps、両帯域counter増加 | 1GbEに制限された当該構成値 |
| EHT320 | 未確認 | 2026-08-24試験案READMEは未転送/未実行 | MLO成功をEHT320証拠へ転用しない |
| SSH断とfirewall reload | 静的解析で実装経路確認 | Private historical Bank B、hotplug/WWAN/LAN scripts | 2026-10-18の実際の発火者・時刻は未特定 |
| KnOS password database切替 | 静的解析で条件付き実装確認 | `knos_config`のsystem_mode分岐と`/etc/knos/...` symlink | 分岐の実行時条件、実効hash、投稿者端末の発火は未確認 |
| overlay seedによるroot SSH復帰 | 保存runbookの過去実機確認 | 2026-09 T6A、2回連続再起動後に鍵SSH listenerとseed確認 | `/etc/shadow`を含まず、password認証成功ではない |

## IPと個体/時期の照合

| IP | 記録上の意味 | 根拠・時期 | 扱い |
|---|---|---|---|
| `192.168.3.2` | T6A Controller / 後日の旧管理経路 | 8月成功記事、9月T6A復旧runbook | Mesh成功時のController値として明記 |
| `192.168.3.223` | T6B Agent | 8月成功記事とiperf3例 | 成功記事時点の値 |
| `192.168.3.247` | T6Bと識別された別再起動snapshotの`br-lan` | host mtime 8/23、ファイル名は7/21、端末epoch不整合 | `.223`からのDHCP変遷か、別試験か確定不能 |
| `192.168.3.1` | 過去T6A復旧の補助管理アドレス | 9月runbook・復旧script | A/B識別や成功時Agent IPに使用しない |
| `192.168.3.13` | 後日のT6A単独STA管理候補 | 10月Private archive記録 | 8月EasyMesh構成とは別モード/時期 |

IPが同じ・異なることだけから端末同一性、DHCP競合、EasyMesh脱落を断定しない。

## KnOS/SSH調査の追跡範囲

Private `SBAT6A-Offline-Archive` remote HEAD `2725c5487a818e4b655bb868326f973c4d9e14ba` の`RESEARCH-INDEX.md`と関連vendor分析文書を確認した。選定rootfsのBank A/Bで、以下の動作を公開用に要約した。

- `20-firewall` interface hotplugからfirewall serviceを呼ぶ経路。
- `ql_wwan_config.sh` / `ql_lan_config.sh`内のUCI変更およびfirewall reload。
- `ql_mipc.sh`、`mipc_wan.init`、`auto_adapt`のnetwork再構成候補。
- `knos_uci_revert.sh`にfirewall revertがあるが直接caller不明。
- Dropbearのprocd、network/hotplug trigger、respawn設定。
- `knos_config`のsystem_mode/factory条件付きpasswd/shadow symlink張替えとDropbear enable制御。
- procdのrcS queue完了からboot success flagへ進む静的control-flow。120秒待ちの原因scriptは未特定。

復旧script群は原本のままPrivate archiveに保持し、本公開リポジトリへコピーしていない。seed tar対象は鍵認証・Dropbear・init/cron/watchdog等で、password databaseではない。300秒delay版の独立成功記録は確認できず、最終runbookの方式は毎分cron再配置。

## 失敗、修正、復旧を混同しない

- **MLO初回失敗:** 約100 msで切断、RSNE mismatch。5 GHz WPA2系と6 GHz SAE/PMF requiredの不整合、およびruntime BSS profile書戻しを特定。BSS profile生成元と両linkのsecurity条件を揃え、4-way handshake以降の成功を報告。
- **管理IPv4断:** `MapMode=1`のDHCP/bridge処理でAgent管理IPが変わることがある。旧IPのping失敗だけではMesh失敗と判断しない。特定の同一subnet DHCP conflict発生は公開資料で確認できていない。
- **SSH断:** interface/firewall reload、Dropbear listener、UCI rewrite/revert、IP変化、rebootを分ける。10/18事象を一つの犯人へ結び付けるruntime証拠は未取得。
- **T6A復旧:** one-shot `/data/sysupgrade.tgz`は起動時に消費されるため、永続seedと毎分cron再配置を追加。watchdogはPIDでなくlistenerを確認し、起動後3〜4分の復帰待ちを考慮。2回連続で鍵SSH復帰を確認。

## 公開物の監査

- Private archive、メーカーrootfs/firmware、機器原ログ、復旧script、Wi-Fi設定、鍵/password hashを複製していない。
- 公開Qiita記事は本人執筆の当時記録としてURLを示し、記事報告と生ログ独立再検証を明示的に分けた。
- worktreeおよびGit全履歴を秘密鍵、credential assignment、Wi-Fi key、64桁hex等のパターンで走査。検出0件。
- 追加ファイルにbinaryはなく、`git diff --check`成功。
- Markdown内リンク/anchorを検査。失敗0件。
- EHT320およびSBAT6 MLO後続公開物を検索したが、EHT320成功の別公表は見つからず。検索結果は網羅的不存在証明ではない。
- 元5chスレッド866〜868の直接取得はできておらず、状況説明は依頼文を根拠に回答文を構成した。
- `sbat6-tools`にPR/Issueなし。`sbat6-usb-nic`のPR #8/#9とIssue #1〜#7はUSB NIC関連で本件の根拠には使用しない。Private archiveのdraft PR #1は独立OpenWrt porting案でEasyMeshとは無関係。対象repoに既存PR/Issueなし。

監査の出典パス・commit/blob SHAは[SOURCES.md](../SOURCES.md)を参照する。

## v1.0完成監査（2026-10-19）

- READMEに読者別の前提、完全一括設定が未公開であること、CIと実機確認の違いを明記。
- Quickstart先頭にYes/No停止条件を追加。diagnosticはSSH stdinで実行可能とし、リモート端末へ一時script fileを書かない。
- Controller writerを再探索。認定script内の`datconf` role 1候補、EasyMesh=1条件でMapMode UCIをcommitする静的処理を確認。一方、成功実験での実行証拠とKnOS flag positive writerは未取得。Controller作業はB判定のまま。
- profileの部分項目とschema限界を`configs/templates/README.md`に記載。これは適用可能な設定ファイルではなく、完全なprofile投入手順未復元。
- SSH鍵復旧の公開方針を案Bに決定。過去のT6A鍵SSH復帰と2回再起動条件を説明し、script/再現用archive作成方法は非公開。root password persistenceと混同しない。
- MLO captureのfilename/internal device-clock epoch（2/28–3/1 JST相当、絶対wall clock未検証）とhost mtime/RUNBOOK見出し/記事公開日（8/23）を`docs/27-evidence-chronology.md`とtimelineで分離。`.223`と`.247`を別snapshotとして維持。
- 実行例から歴史IPを除去し、現在値を手動設定する空のshell変数を利用。historical値は監査・性能結果の説明文だけに残した。
- 診断parserのrole形式、複数distance、mediumラベル限定、BH status/type、MLO band/ref count、無関係な6G、numeric noise、空応答をfixtureで確認。hostname等を出力せず、listener不明を停止と断定しない。iptables INPUT rule数は`-A INPUT`行のみ集計。
- POSIX shとBusyBox ashで30件のshell code fenceと診断script構文/fixture、SSH stdin quoting mock test、10 unittest、link/artifact/read-only checksが成功。GitHub ActionsにはBusyBox検査を追加。
- 残る未解決: Controller writerの実機readback、KnOS flag positive writer、適用可能な完全profile、MLO長時間/全firmware検証、EHT320。これはv1.0で過大主張しないための明示的境界。

### v1.0判定

公開記録は、再現可能な観測、静的な構造解析、実機設定変更の未検証箇所、証拠の日付不整合を分離して提示できる状態になった。全端末向けの一括手順やController設定の実機検証は未達であり、ユーザー定義のv1.0では未解決として許容された範囲である。

- **v1.0文書監査判定: PASS。** この判定は証拠・適用条件・再現範囲・未検証事項が明確な公開資料としての完成判定で、全SBAT6の設定変更成功を意味しない。
- `main` commit `b5860ccec9ae657c976f8f81eeb0f66a386f2527` の [GitHub Actions run 39172892855](https://github.com/Karin-Laboratory/sbat6-easymesh/actions/runs/39172892855) は成功。POSIX/BusyBox shell、文書/fixture tests、read-only契約、履歴を含むGitleaks scanが完了した。
- GitHub ActionsからNode.js/runner移行の警告が出たが、jobは成功し、今回の監査失敗ではない。
- v1.0.0のGit tag/releaseは、監査記録を含む最終main commitに付与する。
