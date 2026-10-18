# 2026-08-25 L2 payload試験の要約

Private作業領域の `l2bench-max-tx.out` から、TX 87,094 frames / 130,641,000 bytes / 0 errors / 約3.006秒 / 348 Mbit/sの出力を確認した。別のbatchfix試行では、RXとTXそれぞれ29,120 frames / 43,680,000 bytes / 約1秒 / 349 Mbit/sを記録する。これはmax TX記録との同一試行ではない。

これはツールのpayload値であり、TCP/iperf3、遅延、複数回統計、MLO効果を示さない。元ログ本文は公開せず、測定目的に関係する集計値だけ転記した。
