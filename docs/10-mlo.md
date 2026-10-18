# 10. MLOとMLDの後続調査

## MLOの設定と実動作を区別する

2026-08-23付の独自スクリプトは、5 GHzと6 GHzを用いるAP MLD/STA MLDを組み立てるUCI差分を持つ。`mlo_stability_sampler.sh` は `apclii0` / `apclix0` のcarrierとbytes、`/sys/kernel/debug/mtk_hwifi/wsys/mld_sta/*`、`logread` を一秒周期で採取する設計で、MLO状態を観測しようとしたことが分かる。

保存物には `mlo-stability-success` と名付けたキャプチャ、radio counters、AP/STA MLD設定、`EHT160`設定がある。しかし公開可能な一次資料だけでは、MLD peer identityと各link associationの持続時間を完全には読み取れない。よって**「MLO設定を適用した」「関連統計を採取した」**は確認できるが、全試験時間を通じた安定MLO、同時二帯域の実データ転送、速度改善は未検証として扱う。

MLO制御コードや `ApcliMloDisable` の設定項目が見つかることはMLOリンク成立の証拠ではない。

## teardown時の追跡

保存アーカイブには `wapp`, `mapd`, `wpa_supplicant` のstrace、`logread`, timelineが複数回分ある。これはMLO/RSNE関連変更後の状態遷移を調査していた根拠になる。ただしこれらの圧縮生ログには識別子や設定値が含まれる可能性があるので、再配布しない。

## 160+160とEHT160

MLO設定スクリプトで両側の5 GHz設定を `EHT160` に揃えている。これは「160+160 MHzの実装幅でオンエア成立」を示すのとは異なる。中心周波数、EHT Operation IE、per-link widthの原証拠が不足しているため、160+160成功とは結論できない。

## EHT320

2026-08-24の `eht320-test/` はsnapshot、適用、確認、160+160 rollback、boot failsafeの**試験案**であり、READMEはスクリプトが実機へ未転送・未実行と明記する。EHT320の実機成功記録ではない。候補の `EHT320-2` channel 33 / center 63は仮説に留まり、再現コマンドとして掲載しない。
