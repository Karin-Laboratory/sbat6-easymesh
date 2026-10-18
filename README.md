# SBAT6 EasyMesh 親子化と6 GHzバックホールの実験記録

SoftBank Air Terminal 6（SBAT6 / SBAT6A相当）2台で、EasyMesh Controller/Agent の親子関係を作り、Ethernetでの初期オンボーディングから6 GHz無線バックホール、子機側EthernetへのL2延長までを実機で確認した記録です。成功条件だけでなく、管理経路断、設定の再生成、復旧策、追加のMLO成功報告と後続検証も、確認できる範囲で時系列にまとめています。

## 実現した構成

```text
上位LAN / ルーター
        |
   T6A Controller  (距離0)
        |
   6 GHz EasyMesh無線バックホール
        |
   T6B Agent       (距離1)
        |
   T6B Ethernet / br-lan
        |
   有線クライアント
```

**本人公開記事による実機確認:** 2026-08-23の記事に、Ethernetを外した状態で6 GHz BHが維持され、T6B Ethernet側に接続した端末から上位LANへ通信できるL2延長を確認した。成功記事では6 GHz channel 21 / 6055 MHz / 160 MHz / 4addr onを報告。同記事の6 GHz単独BH TCP測定はA→B約350 Mbps、B→A約330 Mbps。別日の独自L2 payload測定は約348–349 Mbit/sで、TCP値とは別測定です。5+6 GHz MLO後のEthernet端末間iperf3は約0.91〜0.94 Gbpsと報告されています。数値はいずれも当時の条件に限り、長時間性能保証ではありません。

## 重要な読み方

証拠区分と公開前の項目別監査結果は[監査章](docs/23-publication-audit.md)にまとめています。

各主張に証拠レベルを付けています。**実機確認済み**は実験当時の観測、**保存データから確認**は保存物の内容、**静的解析による推定**はソース・設定・バイナリ解析、**未検証**は根拠が足りない事項、**失敗**は期待結果に届かなかった試行です。ログに記録のない値やコマンドを成功手順として創作していません。

この実験は純正ファームウェア内部のMediaTek/メーカー独自コンポーネントを利用しています。本リポジトリは非公式な実験記録であり、メーカー製バイナリ、rootfs、設定バックアップ、実機の生ログ、秘密情報は含みません。

## 章構成

- [全体像と確認範囲](docs/01-overview.md) · [ハードウェア](docs/02-hardware.md) · [管理経路](docs/03-root-access.md)
- [EasyMesh構成](docs/04-easymesh-architecture.md) · [Controller](docs/05-controller-setup.md) · [Agent](docs/06-agent-setup.md)
- [有線オンボーディング](docs/07-wired-onboarding.md) · [無線バックホール](docs/08-wireless-backhaul.md) · [L2延長](docs/09-l2-bridge.md)
- [MLO](docs/10-mlo.md) · [性能試験](docs/11-performance.md) · [永続化](docs/12-persistence.md)
- [失敗と復旧](docs/13-failures.md) · [復旧手順](docs/14-recovery.md) · [再現ガイド](docs/15-reproduction-guide.md) · [現在の確認状況](docs/16-current-status.md)
- **掲示板向け中心章:** [root取得後からEasyMesh親子化まで](docs/21-from-root-to-easymesh.md) · [5ch投稿866〜868への回答](docs/22-5ch-866-868-answer.md)
- [KnOS設定復元](docs/17-knos-configuration-reset.md) · [SSH/firewall永続化](docs/18-ssh-firewall-persistence.md) · [root password](docs/19-root-password-and-authentication.md) · [SSH切断診断](docs/20-ssh-loss-troubleshooting.md)
- [時系列](docs/timeline.md) · [技術的知見](docs/technical-findings.md) · [未解決事項](docs/unresolved-issues.md) · [公開前監査](docs/23-publication-audit.md)
- [公開証跡索引](evidence/INDEX.md) · [出典対応表](SOURCES.md) · [変更履歴](HISTORY.md)

## 安全上の注意

設定変更はSSHや管理IPを失わせることがあります。実験の再現には、対象の所有権、復旧可能なバックアップ、UARTまたは別の管理経路、現在の個体識別が必要です。ここに示す情報は2026年当時の機器・ファームウェアで得た記録で、他個体への適用を保証しません。未確定の設定を機械的に投入しないでください。

## License

文書と本リポジトリ独自の記述は [CC BY 4.0](LICENSE) です。第三者のメーカーソフトウェアを含みません。
