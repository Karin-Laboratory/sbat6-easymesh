# 27. 証拠資料の日付と時系列

この章は実験日、ファイル名、端末内部timestamp、作業hostのmtime、Git commit日を分けて記録する。コピー時にmtimeが変わる可能性や機器時計のずれはあり得るが、裏付けのない原因説明はしない。日本時間はJST（UTC+09:00）。保存rootfsやPrivate資料の本文は公開していない。

| 資料 | filename / document date | internal timestamp | host mtime / Git | 推定時期・信頼度 | 他資料との関係 |
|---|---|---|---|---|---|
| MLO leave/RSNE/stability capture群 (`mlo-*-20260228-*.tar.gz`) | filenamesは2026-02-28のdevice-local時刻表記 | capture metadataの`start_epoch`も2026-02-28のJST換算。例: stability start `23:40:08 JST`。artifact名末尾`234815`と内部start`234008`は8分差 | local host mtimeは2026-08-23、例: stability 22:45 JST | device-local clock上の時刻と相対順は明確。NTP/外部clock offset記録がなく絶対calendar dateの信頼度は低〜中。artifact名末尾の意味は未確定 | device clock上では2/28–3/1付近のcapture、後日8/23に保存/整理された可能性。RUNBOOK見出し/記事日付を実験日に転用しない |
| `mlo-stability-success`内部記録 | archive filename `...20260228-234815`、内包directory `...20260228-234008` | start epoch `1772289608`はdevice clock上で2026-02-28 23:40:08 JST相当。RUNBOOK記載の安定時間は464秒 | host mtime 2026-08-23 22:45 JST | start epochは記録されたdevice timestampとして確定、絶対wall clockは未検証。464秒の相対経過は高信頼 | RUNBOOKの「464秒」記述と技術状態は整合するが、日付見出しが異なるため同時記録かは未確定 |
| MLO RUNBOOK sections 18–22 (`projects/sbair6-rce/RUNBOOK.md`) | 各section見出しに2026-08-23 | 本文内で参照する複数captureは2026-02-28名/epoch。section内の実験メモ自体に全ての独立clock evidenceがあるわけではない | host mtime 2026-08-23 23:10 JST。公開Git commit SHAなし | 文書の保存/編集時期は高信頼。全記載イベントの実験日は同じとは言えない | 2/28 raw capture解析と8/23に追記・再試験/整理された記録が混在し得る。eventごとの確定は保留 |
| reboot persistence snapshot filenames `t6b-reboot-persistence-20260721-124656-{baseline,post}-B.txt` | filenameは2026-07-21 `124656`を含む。timezoneの記録なし | baseline/post内に共通の連続machine timestampは確認できず。postの一箇所のepoch `1772291511`はdevice clock上で2026-03-01 00:11:51 JST相当 | 両ファイルhost mtime 2026-08-23 23:09 JST。Git SHAなし | filename・device epoch・mtimeが異なる。絶対実験日・正確な前後順の信頼度は低い | `.247`を含む別snapshotとして扱う。成功記事の`.223`からのDHCP変遷とは断定しない |
| 本人執筆Qiita記事 | 公開/更新日2026-08-23 | Web記事に機器時計の生timestampはない | Web公開日。記事内容は後日取得 | 公開日は確定、本文中の各実験日時は独立して確定できない | 8/23は成功報告が公開された日であり、すべてのMLO試験が同日に実施された証明ではない |
| T6A SSH recovery runbook (`T6A_RECOVERY_RUNBOOK_FOR_AI.md`) | 本文の更新記載2026-09-26 | SSH鍵認証/overlay recoveryの実験記録は9月時期として記述 | Private archive HEAD commit `2725c5487a818e4b655bb868326f973c4d9e14ba`は2026-10-18。file blob SHAは[SOURCES.md](../SOURCES.md)に記載 | 内容の記載日は中〜高信頼、正確な実機timestampは完全には独立確認できない | 2–3月MLO captureや8月EasyMesh成功と別の管理復旧作業。MLO runbookと同一視しない |
| Private archive収録/更新 | Git historyで2026-10-18の更新が確認できる | commit日時が保存される | Private archive commit date 2026-10-18 JST | Gitに記録された収録/文書更新日は確定 | 収録日は本文の実験日ではない |
| EHT320案とL2 payload測定 | 保存README/filenameは2026-08-24/25 | 独立した機器timestampを伴う全測定captureなし | local host mtimeは各日の作業記録 | 日付はファイル記述/mtime由来。EHT320は未実行 | MLO成功や別payload値と混ぜない |

## IP addressの非連続性

`.223`は2026-08-23公開記事のT6B成功report、`.247`はfilename日付・内部epoch・host mtimeが一致しない別のreboot snapshotである。連続した同一DHCP lease変更を証明するtimestamp/MAC対応が不足しているため、別資料・別状態として保つ。`.2`, `.1`, `.13`も異なる時期/役割/管理用途として[公開監査](23-publication-audit.md)に分けた。IPを端末identityや現在の接続先に使わない。

## 出典と次に必要な証拠

Private/local work areaの主要な`sbair6-rce`ファイルにGit commit SHAはない。file path、filename、host mtime、archive metadataを併記し、保存Git SHAがある場合のみ[SOURCES.md](../SOURCES.md)に記す。日付を確定するには当時のconsole capture、同期済みhost/device clockのoffset記録、raw capture metadata、作業者のshell history/commitなど、同一eventへ紐づく独立timestampが必要。欠けた時刻を推定値で埋めない。
