# 10. 5 GHz＋6 GHz MLO

## 証拠の整理

**実機確認済み（当時の公開本人報告）:** 2026-08-23のQiita記事には、SBAT6 2台のEasyMesh構成上で5 GHz/6 GHzの2-link MLOを成立させた記録がある。MLO設定項目が存在するだけの話ではなく、STA MLDの`mld_sta257`で`ref_cnt=2`、link別`band_idx=1`（5 GHz）/`2`（6 GHz）、4-way handshake、両帯域の転送カウンター増加を観測したという報告である。[出典](../SOURCES.md#公開一次報告)

**保存スクリプトでも照合:** `mlo_apply_a.sh` / `mlo_apply_b.sh`はA/BにAP MLDとSTA MLDを構成し、5 GHz・6 GHzの設定を準備する。`mlo_stability_sampler.sh`は各APCLIのcarrier/bytesとMLD情報を採取する設計。公開記事の設定・観測説明と整合する。スクリプトそのものやキャプチャ原本は秘密値・個体情報を含むため公開していない。

**生ログの限界:** 2026-08-23付の`mlo-stability-success`等の圧縮キャプチャは保存されているが、本公開資料では生ログを再配布せず、全行を独立して再検証したとは主張しない。従ってMLO成立・再起動復帰・性能値は「公開済み本人の当時の実測報告」、設定差分と観測用スクリプトは「保存スクリプトで確認」と区別する。

## RSNE mismatchから2-link成立まで

Qiita記録では、MLO設定適用後に約100 msの切断が繰り返され、`wpa_supplicant`がRSNE mismatchを報告した。原因は、5 GHz側のWPA2系設定と6 GHz側のSAE/PMF必須設定の不一致、およびEasyMesh runtime provisioningが5 GHz側BSS profile設定を書き戻すことだった。

修正ではBSS profileの生成元を調整し、両リンクの認証条件をSAE/PMF requiredに揃えた。その後、4-way handshake成功、MLD参照数2、5/6 GHzの両band indexを確認したと記事は記録する。個々のSSID、鍵、BSSIDを含む生設定は公開しない。

## 再起動後の復帰

公開記事では、`sync`後に通常の`reboot`を行い、2-link MLOが自動復帰し、DHCPは約170秒後、EasyMesh再参加は約173秒後、MLOは少なくとも342秒継続して観測された。これは「再起動後も最終的に復帰した」という成功報告であり、起動直後から無停止で通信できたことを意味しない。

別のローカルB再起動snapshot（ファイル名に`20260721`、ホストmtime 2026-08-23、端末epochとも不一致）では`192.168.3.247`、role 2、MapMode 1と関連設定hashが前後一致する一方、採取時にUPだったSTA interfaceが`apclix0`から`apclii0`へ変化していた。これをMLO成功報告の否定や同一試験の失敗とは扱わない。時刻・試験コンテキストが確定せず、リンク選択の別観測として残す。

## 確認出力の読み方

確認に使ったread-onlyコマンドと観測点:

```sh
cat /sys/kernel/debug/mtk_hwifi/wsys/mld_sta/mld_sta257
# 5 GHz側: /sys/class/net/apclii0/statistics/{rx_bytes,tx_bytes}
# 6 GHz側: /sys/class/net/apclix0/statistics/{rx_bytes,tx_bytes}
```

記事が報告する主要な観測値:

```text
mld_sta257: ref_cnt = 2
link: band_idx = 1 (5 GHz)
link: band_idx = 2 (6 GHz)
apclii0 (5 GHz): byte counter increases during transfer
apclix0 (6 GHz): byte counter increases during transfer
```

この要約は本人の公開報告を短く整理したもので、完全な機器出力の転載ではない。MLOの強い確認は設定名ではなく、peer/MLD状態、2 linkの同時association、両linkの転送counter、端末間のデータ転送を組み合わせること。

## 160+160とEHT320

2026-08-24のEHT320試験READMEは、160+160を既知の成功ベースラインとして記し、EHT320試験案は未転送・未実行としている。後日の公開Qiitaに5+6 GHz 2-link MLOの成功報告はあるが、それをEHT320実機試験の証拠へ読み替えない。EHT320のオンエア幅・中心周波数・EHT Operation IEを確認できる実測記録は本監査では取得できず、**EHT320成功は未確認**。
