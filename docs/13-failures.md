# 13. 失敗・誤認・原因の切り分け

以下は保存された作業痕跡から作れる範囲の順序である。詳細な全試行の時刻や完全な失敗ログは存在せず、イベント列の細部を推測で埋めていない。

| 順 | 現象/試行 | 観測・判断 | 対応と状態 |
|---:|---|---|---|
| 1 | B号機の管理SSHが使えない | BのWeb UI経由コマンド実行は確認されたが、初期はSSH listener経路が整っていなかった | T6B専用の診断・Dropbear起動・限定firewall作業へ進んだ。試行中の管理経路不安定はEasyMesh失敗ではない |
| 2 | BからのHTTP取得を誤認するリスク | raspi2側HTTP 200だけでは、接続元がBだと証明できない | source IPでB由来を確認する診断方針に訂正 |
| 3 | Agent側のSSH/管理IPを失う | B向けMLO/daemon再起動・network状態変化の間、遠隔管理が不安定になった形跡が残る。IPと機器対応は時期で変化 | root経路の事前確認、限定管理firewall、snapshot/rollbackスクリプトを追加。Mesh topology自体は別途判定が必要 |
| 4 | MLO/RSNE変更後のmapd/wapp動作が不明 | `mlo-leave-*` capture群にstrace・logreadが複数段階で採取されている | daemonを含むteardown/設定再生成の調査へ移った。ログの全結論は未公開 |
| 5 | 起動後に期待設定が変わり得る | mapd設定のUCI→生成ファイル変換と複数復旧層の存在を確認 | 再起動前の一時状態だけで永続成功としない方針へ変更 |
| 6 | EHT320候補 | 安全ガード付き試験案は存在するが、READMEで未転送・未実行 | EHT320を成功扱いしない。160+160 baselineへrollbackする設計案のみ |

### DHCP競合・br-lan・DHCP IPの確定範囲

DHCP競合、`br-lan`再構成、管理IP変化は今回の依頼に含まれた歴史的論点だが、2026-08の該当一次ログ一式を取得できず、各現象の順序・IP lease・具体的原因を再監査できなかった。したがって表に確定イベントとして追加せず、未解決事項に残した。

**判断の訂正:** SSH不能、ping不能、HTTP取得不能をMesh参加失敗と同一視しない。個別にcontrol-plane topology、BH radio state、management reachability、client forwardingを観測する。
