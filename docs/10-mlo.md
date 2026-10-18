# 10. 5 GHz＋6 GHz MLO（上級編）

この章は、6 GHz単独EasyMesh backhaulが成立した後の追加実験を扱う。MLO設定項目やコードが存在することと、複数リンクが同時に成立したことは別である。以下は2026-08-23公開記事の成功報告と、filename/internal epochがdevice-local clock上で2026-02-28を示す保存capture、8/23見出しのRUNBOOKを分けてまとめたもの。外部clock offsetがないため絶対実験日は未検証。公開日・文書見出しを全試験の実施日とは扱わず、再現用の無条件投入スクリプトも提示しない。

## 成立を確認した証拠

公開記事は5 GHz/6 GHzの2-link MLOについて、STA側`mld_sta257`の`ref_cnt=2`、`band_idx=1`と`band_idx=2`、4-way handshake完了、両linkの転送counter増加を報告する。再起動試験では通常の`sync; reboot`後にDHCP約170秒、EasyMesh再参加約173秒、MLOが少なくとも342秒維持された。起動直後からの無停止を意味しない。

保存済み安定性captureの記録は464秒の安定観測と両band indexを含み、内部start epochはdevice-local clock上で2026-02-28 23:40:08 JST相当。外部clock offset/NTP記録はなく絶対日付は未検証。artifact filename末尾は`234815`、内包directory/start epochは`234008`である。保存host mtimeとRUNBOOK見出し、Qiita公開日は2026-08-23。artifact作成時刻、実験event、文書作成日が一致するとは断定せず、詳細は[証拠chronology](27-evidence-chronology.md)に分けた。capture中は物理APCLIの一方のcarrier表示がdownでもMLD配下linkが成立している場合があり、APCLI単体carrierだけでMLO状態を判定しない。

## 初回失敗から修正まで

| 項目 | 初回失敗時 | 修正後に確認した状態 | 根拠/強さ |
|---|---|---|---|
| 5 GHz BH BSS | WPA2/PSK、AKM `00-0f-ac-02`、PMF optional、RSNE capability `8c00` | WPA2/SAE profileへ変更、実行時`wpa=2`, `key_mgmt=SAE`, `ieee80211w=2`, CCMP | capture解析と記事。SSID/鍵は非公開 |
| 6 GHz BH BSS | SAE、PMF required、AKM `00-0f-ac-08`、capability `cc00` | 5 GHzとSAE/PMF条件を一致 | capture解析 |
| 切断 | M3受信後、supplicantがRSNE差異を検出しreason 1 deauth。約109 msで2-linkが解体 | 4-way handshake 4/4、key negotiation、`CTRL-EVENT-CONNECTED` | syscall/RSNE traceと記事 |
| 最初の原因仮説 | `mapd`/`wapp`の`DISABLE_NETWORK`を疑った | 後続syscall時系列では直前のdisable命令を確認できず、仮説を撤回。M3 RSNE mismatchが直接原因 | 保存traceによる訂正 |
| 設定の戻り | UCIの`rai2`暗号設定を変更してもruntime provisioningが再生成 | EasyMesh側BSS元profileも変更。`mapd.6.authmode`を`0x0022`から`0x0040`へ、`/etc/map/wts_bss_info_config`のid 6も整合 | 保存rootfs/RUNBOOK。汎用値としては未検証 |
| 維持 | UCI値のみでは再起動/daemon起動後に戻る | source profileと実際のhostapd/DAT/on-air条件を揃えた後に成立 | 保存記録 |

ログ中には修正後もscan結果に見つからないlinkやRSNE比較に関する非致命的メッセージが残ることがある。成功判定は特定警告文字列の消失ではなく、M3 deauthが止まり、handshake完了、MLD 2 linkとデータ転送が同時に確認できること。

## 設定経路と再現上の注意

MLO用のAP側MLDは`rai2`（5 GHz）と`rax2`（6 GHz）、STA側は`apclii0`と`apclix0`を束ねる構成が保存スクリプトの静的解析で確認できる。保存案にはAP group 2、STA group 1、EHT160、`mapd.8.mld_groupID=2`がある。これらはそのまま投入できる完全な手順ではなく、端末・firmware固有の保存値である。`mlo_apply_a.sh`/`mlo_apply_b.sh`の実行成功は確認できていないため、公開用の実行レシピとして転載しない。

EasyMeshは起動時にBSS profileを生成/適用する。無線UCI値だけを直してもdaemon後に戻ることがあり、実際に動作中のhostapd/DAT設定とBeacon/Probe ResponseのRSNEを確認する必要がある。SAE/PMF変更は管理や無線接続を失わせ得るため、独立した有線/console復旧路と設定退避がない状態では実行しない。記録にないSSID、PSK、BSSIDやprofile生成コマンドは補わない。

## read-only確認

次は観測例であり、機器の全バージョンに同じdebugfs pathがある保証はない。

```sh
cat /sys/kernel/debug/mtk_hwifi/wsys/mld_sta/mld_sta257
cat /sys/class/net/apclii0/statistics/rx_bytes
cat /sys/class/net/apclii0/statistics/tx_bytes
cat /sys/class/net/apclix0/statistics/rx_bytes
cat /sys/class/net/apclix0/statistics/tx_bytes
```

| 観測 | 成功を示す条件 | この証拠だけでは言えないこと |
|---|---|---|
| MLD debugfs | `ref_cnt=2`、link `band_idx=1`と`2` | その瞬間にアプリ通信が正常とは限らない |
| 5/6 GHz counters | 同一の転送中に両方のbyte数が増える | 個別linkの実効速度や公平な負荷配分 |
| 4-way handshake | 4/4とconnectedイベント | 長時間安定性 |
| 端末間転送 | Ethernet PC間で通信できる | VLAN/multicast/MTU全条件の透過保証 |

初回失敗を調べる場合は、supplicant/driver logでM3時点のRSNE、deauth reason、2-link teardown時刻を比較する。UCI表示だけでruntime状態を断定しない。

## 性能、160+160、EHT320

公開記事のルーター端点MLO測定は概ねA→B 334/315 Mbps、逆方向359/340 Mbps（sender/receiver）。Ethernet PC間iperf3では1 stream約936/909 Mbps、10 stream約941/908 Mbpsであり、1GbE端点上限に近い別の測定である。これらを無線理論速度と解釈しない。

保存されたEHT320 READMEは160+160を過去の成功baselineとして挙げるが、EHT320用scriptは準備物で未実行。EHT320成立、320 MHz実幅、EHT Operation IEは未確認である。

関連: [6 GHz単独backhaul](08-wireless-backhaul.md)、[L2測定](09-l2-bridge.md)、[障害診断](25-easymesh-troubleshooting.md)、[再現範囲](26-reproduction-coverage.md)。
