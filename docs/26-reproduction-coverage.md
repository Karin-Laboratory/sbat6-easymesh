# 26. 再現性の工程別判定

判定は文書の詳しさではなく、前提・操作・期待結果・保持確認・復旧・出典が揃っているかで付ける。Aは読み取り確認や限定操作の再現手順が揃う項目を意味し、2台のcommissioning全体がAという意味ではない。

| 工程 | 判定 | そろっている証拠 | 不足・境界 |
|---|:---:|---|---|
| model/radio/interface識別 | A（read-only確認） | 所有者root端末で採取する診断script、匿名fixture/parser test | 型番・firmwareの個体差、root取得手順は対象外 |
| 公開成功記事のrole/MapMode値照合 | A（read-only確認） | A role 1/B role 2、両MapMode 1の報告、確認対象 | Controller設定writer、MapMode変更writerは不明 |
| Agent role writer | B | `wificonf -f /etc/map/mapd_user.cfg set DeviceRole 2`の履歴 | 実験全体の前状態/復旧/全個体での保持を示す独立ログなし |
| Controller role設定 | B | DeviceRole 1の成功値、`map_cert_script.sh`にあるOpenWrt branchの`datconf` writer候補、生成daemon roleの静的解析 | certification scriptが実験で実行された証拠なし。記事のwriter/初期実行列は未復元 |
| MapMode=1設定 | B | 成功値、KnOS UCI defaultsの`change_mapd()`がEasyMesh=1時にmapd_cfg/mapd_userを設定してcommitするコード | 当該処理を実験個体で実行した証拠なし。再起動保持は未実機検証 |
| KnOS EasyMesh flags | B | 成功時readbackが両方1。EasyMesh値を読む/0へ戻すsource経路、mesh flag default引継ぎを静的確認 | positive writer不明、成功実験の書込み時系列/保持証拠なし |
| 設定生成経路の理解 | A（静的解析） | `/etc/mapd.uci`, UCI, default/user/runtime、1905d生成の対応 | 個体上での再現操作ではなく、全ビルド差を検証していない |
| Ethernet onboarding | B | topology distance 0/1、Agent認識の本人公開報告 | 取得可能な完全なIEEE1905イベント順/raw CLI出力と全操作列なし |
| 6 GHz BH状態の読み取り | A（read-only確認） | BH status/type/medium、APCLI対応と期待条件 | 公開fixtureは記事を転記・正規化したもので実端末のraw logではない |
| 6 GHz BH構成・Ethernet抜線 | B | cable removal後の6G、carrier/counter、client通信の成功報告 | profile投入コマンド、秘密を除いた完全設定、同時刻の全生ログなし |
| Agent Ethernet L2検証 | B | DHCP/L2延長成功報告、測定値、検証章 | 完全なlease/ARP/bridge/raw packet証跡なし。VLAN全条件未確認 |
| reboot後EasyMesh/MLO | B | 記事の`sync; reboot`、約173秒再参加と342秒以上観測 | 別captureとの日付不整合、全構成のboot logは未公開 |
| 5+6 GHz MLO read-only判定 | A（read-only確認） | MLD ref count/band index/counterのコマンドと実測報告 | debugfs pathはfirmware依存、fixtureは記事由来 |
| MLO security修正 | B | RSNE失敗/成功差分、profile修正値、handshake完了報告 | 実行可能な完全変更列・秘密を除いた全profileなし |
| EHT320 | C | 試験script/READMEの存在 | 実機実行・320 MHz on-air確認なし |
| 160+160 | B | EHT320 README内の成功baseline記述 | 本監査で独立した同時刻実測captureを確認できず |
| ブートループ復旧 | C（この実験の手順として） | 関連する別の復旧資料への参照 | EasyMesh実験変更が原因のloop再現/完全な復旧列は未確認 |

## 公開済み診断artifactの由来

`tests/fixtures/mapd-success-report.txt`はQiita成功記事の観測値を匿名化・正規化して作成したfixtureで、生の保存済みCLI transcriptではない。ローカルcapture検索では`Device role`/distance/mediumの該当raw transcriptを確認できなかった。テストはparser互換性を確認し、保存capture自体を証明するものではない。`scripts/sbat6-diagnose.sh`はread-onlyで、値を取得できないとunknown/unavailableを返す。

## A判定に含める限定

Aとして掲載したのは端末状態の読み取り・診断方法、設定生成経路の静的解析、MLO状態の観測方法である。Role変更、無線profile更新、抜線・再起動を含む全体の手順は、実行writerや完全なraw evidenceが欠けるためB/Cとして残す。これは追試を禁止するものではなく、未復元部分を成功済みの操作列として偽装しないための証拠境界である。

今回のController writer調査では別のvendor certification script内の静的候補と、KnOSのMapMode設定経路まで確認できた。ただし、成功実験の操作記録と結び付くwriterやKnOS flagを1にする経路は確定しなかった。したがってController設定手順をAへ上げていない。所有者向けの実機検証設計は[Controller writer検証計画](28-controller-writer-validation.md)に分けた。
