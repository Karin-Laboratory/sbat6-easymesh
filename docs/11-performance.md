# 11. 性能・遅延・安定性

## SBAT6本体をiperf3 endpointにした測定

6 GHz単独BH時、T6B serverとT6A clientで4 stream/20秒のTCP測定を実施したと本人記事は記録する。記事記載例:

```sh
# 現在の検証用endpointを実環境で確認して設定する。空値のままでは中止。
SERVER_IP=''
CLIENT_BIND_IP=''
: "${SERVER_IP:?現在のserver IPを確認して設定する}"
: "${CLIENT_BIND_IP:?現在のclient側bind IPを確認して設定する}"
# T6B上でserver
iperf3 -s -B "$SERVER_IP"
# T6AからT6Bへ
iperf3 -c "$SERVER_IP" -B "$CLIENT_BIND_IP" -P 4 -t 20
# 逆方向
iperf3 -c "$SERVER_IP" -B "$CLIENT_BIND_IP" -P 4 -R -t 20
```

IP変数は空の例なので、手入力確認せず実行すると中断する。記事のhistorical commandではT6B server=`192.168.3.223`、T6A client bind=`192.168.3.2`だった。これは測定記録であり現在値ではない。報告値はA→B約350 Mbps、B→A約330 Mbps。MLO後もT6A/T6B本体をendpointにした4 stream測定はA→B約330〜350 Mbps、B→A約350〜380 Mbps程度で、6 GHz単独と大きな差が見えなかった。

## Ethernet端末間のMLO測定

記事のPC間測定は1GbEで接続した有線PCを使い、1 stream測定、10 stream測定、および逆方向測定を行う。再測定は両PCの現在IPを確認して`iperf3.exe -c "$PC_SERVER_IP" -t 20`、`-P 10`、`-R`を組み合わせる。historical articleの一時subnet/IPは再利用しない。変数が空/不明なら実行せず止める。

本体CPU/TCP endpointがボトルネックの可能性を調べるため、PCを各T6のEthernetへ接続して測定した。Qiitaには次の結果が記録される。

| 試験 | 結果（記事記載） |
|---|---:|
| 1 stream 正方向 | 936 Mbps |
| 1 stream 逆方向 (`-t 20 -R`) | 909 Mbps |
| 10 stream 正方向 (`-t 20 -P 10`) | 941 Mbps |
| 10 stream 逆方向 (`-t 20 -P 10 -R`) | 908 Mbps |

試験中、5 GHz (`apclii0`)と6 GHz (`apclix0`)双方のdriver byte counter増加を報告。2-link MLD状態（`mld_sta257`, ref_cnt 2, band_idx 1/2）と併せて、Ethernet端末間約0.91〜0.94 GbpsをMLO構成の実測値として扱う。1GbE Ethernetがこの試験の上限で、無線BH自体の最大値を測った試験ではない。これは本人公開記事の報告であり、保存生ログの独立再解析値ではない。[一次報告](../SOURCES.md#公開一次報告)

PC間pingは10送信/10受信、loss 0%、RTT min 3 ms / max 6 ms / avg 4 msと記事にある。体系的な遅延系列ではない。

## 他の短時間測定

2026-08-25の独自L2 payload試験は約348〜349 Mbit/s。TCP iperf3とは異なるフレーム/ツールの値であり、同じ指標として比較しない。

## 解釈と再測定

MLO性能比較はT6本体endpointとEthernet client endpointを混ぜない。測定時のlink state、相手端末、方向、stream数、時間を併記する。記事の結果は当該個体・配置・firmwareの結果で、複数回統計、長時間負荷、混雑/干渉環境の保証ではない。
