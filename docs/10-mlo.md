# 10. MLOとMLDの後続調査

## MLOの設定と実動作を区別する

2026-08-23付の独自スクリプトは、5 GHzと6 GHzを用いるAP MLD/STA MLDを組み立てるUCI差分を持つ。`mlo_stability_sampler.sh` は `apclii0` / `apclix0` のcarrierとbytes、`/sys/kernel/debug/mtk_hwifi/wsys/mld_sta/*`、`logread` を一秒周期で採取する設計で、MLO状態を観測しようとしたことが分かる。

保存物には `mlo-stability-success` と名付けたキャプチャ、radio counters、AP/STA MLD設定、`EHT160`設定がある。しかし公開可能な一次資料だけでは、MLD peer identityと各link associationの持続時間を完全には読み取れない。よって**「MLO設定を適用した」「関連統計を採取した」**は確認できるが、全試験時間を通じた安定MLO、同時二帯域の実データ転送、速度改善は未検証として扱う。

MLO制御コードや `ApcliMloDisable` の設定項目が見つかることはMLOリンク成立の証拠ではない。

## teardown時の追跡

保存アーカイブには `wapp`, `mapd`, `wpa_supplicant` のstrace、`logread`, timelineが複数回分ある。これはMLO/RSNE関連変更後の状態遷移を調査していた根拠になる。ただしこれらの圧縮生ログには識別子や設定値が含まれる可能性があるので、再配布しない。

## 160+160とEHT160

2026-08-24のEHT320試験案READMEと `rollback-eht160.sh` は、元に戻す対象を「known-success 160+160 persistent sources」と記録している。したがって当時の実験者記録上、160+160構成は既知の成功ベースラインとして扱われていた（**保存データから確認**）。MLO設定スクリプトでは両側5 GHzを `EHT160` とする構成も保存されている。Bの再起動前後snapshotでは、5/6 GHz STA IFのどちらか一方がUPとなり、稼働側が`apclix0`から`apclii0`へ入れ替わった。これはband/link選択または状態変化の観測であり、2 link同時動作の証明ではない。ただし、本公開監査で参照できた資料にはベースライン成功時の無線capture、EHT Operation IE、中心周波数、per-link width出力が残っていない。よって160+160の正確な無線実現条件やlinkごとの持続性は再検証できず、後日の再現でオンエア確認が必要である。

## EHT320

2026-08-24の `eht320-test/` はsnapshot、適用、確認、160+160 rollback、boot failsafeの**試験案**であり、READMEはスクリプトが実機へ未転送・未実行と明記する。EHT320の実機成功記録ではない。候補の `EHT320-2` channel 33 / center 63は仮説に留まり、再現コマンドとして掲載しない。
