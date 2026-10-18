# 公開証跡索引

## 方針

公開できる一次記録の要約だけを文章として掲載した。Private archiveやdevice snapshotの原文は変更せず保持し、ここへコピーしない。メーカー著作物、SSID/PSK、MAC/BSSID、秘密鍵、SIM/IMEI、内部ホスト情報を含み得る生データも収録しない。

| 公開証跡 | 状態 | 内容 |
|---|---|---|
| [測定値要約](sanitized/l2bench-summary.md) | 公開 | 2026-08-25の短時間payloadカウンター値と限界 |
| [構成とMLO変更の要約](sanitized/mlo-config-summary.md) | 公開 | スクリプトから読み取れるrole/MLD差分。認証情報なし。成功実測は本人公開記事を出典として別章に整理 |
| [本人執筆Qiita公開記事](https://qiita.com/masataka55/items/70222d4e64319c0989d3) | 外部公開一次報告 | 6 GHz BH、MLO、RSNE修正、reboot復帰、端末間iperf3。SOURCES.mdで証拠区分を明記 |
| Private KnOS/SSH vendor analysis | 非公開 | 過去rootfsの静的解析のみを要約。メーカーコード/原本は公開しない |
| capture/strace/logread archive | 非公開 | 存在・対象プロセスは `SOURCES.md` に記録。識別子/秘匿設定を含み得る |
| firmware/rootfs/partition snapshot | 非公開 | メーカー著作物・端末固有情報。再配布しない |
| B reboot persistence pre/post summary | 非公開原本・公開要約のみ | role/mode・bridge IP・設定hash保持とactive STA IF変化。日付に不整合あり |
| EHT320 proposal scripts | 非公開 | device paths/rollback targetを含み、実機未実行。要約のみ |

公開コピーは実験原本ではなく、必要最小限の編集要約である。SHA256はPrivate原本に対する追跡用で、公開資料に秘密値のhashを含めない。
