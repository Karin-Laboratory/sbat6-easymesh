# 11. 性能・遅延・安定性

## 保存された短時間カウンター試験

2026-08-25のl2bench作業記録に、独自payload sender/receiverの出力がある。

| 記録 | 値 | 解釈 |
|---|---:|---|
| `l2bench-max-tx.out` TX, 約3秒 | 87,094 frames / 130,641,000 bytes / 348 Mbit/s | tool-reported payload rate |
| `l2bench-batchfix-rx.out` RX, 約1秒 | 29,120 frames / 43,680,000 bytes / 349 Mbit/s | 別試行のtool-reported payload rate |
| `l2bench-batchfix-tx.out` TX, 約1秒 | 29,120 frames / 43,680,000 bytes / 349 Mbit/s | 別試行のtool-reported payload rate |

これらは短時間の実験値であり、TCP throughput、両方向同時性能、中央値/分散、遅延、再送、長時間安定性、MLOによる改善を示さない。事前・事後interface countersにはradio/bridge上のerror counterが含まれるが、比較条件・累積開始点が一定とは限らないため成功性能指標にしない。

正式な再測定では、ツールのソースとframe format、MTU、方向、試験時間、CPU負荷、radio/channel/width、試行回数、RSSI、再送数を保存し、ベースラインと変数を一つずつ変える。

遅延（RTT/jitter）と安定性の数値系列は、公開可能な作業ファイルから確認できなかった。
