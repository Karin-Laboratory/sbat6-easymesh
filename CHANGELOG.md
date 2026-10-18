# Changelog

## 2026-10-19 再現マニュアル全面補強

- 6 GHz EasyMeshクイックスタートと段階判定付き詳細再現ガイドを追加。保存資料から復元できないController writer/profile列は未復元と明記。
- Controller/Agent、有線onboarding、6 GHz BH、L2検証、MLOの手順・期待状態・証拠限界を補強。
- 19症状のトラブルシューティングと工程別A/B/C再現coverageを追加。
- 診断scriptに数値role、distance、BH medium/status/type、APCLI counters、SSH listener port観測と記事由来fixture self-testを追加。
- 公開記事転記fixtureはraw実機logではないことを明記。文書/出典/READMEを更新。
- unittest 6件、shell syntax、diagnostic self-test、Markdown link/artifact/read-only契約、git diff checkを確認。機器アクセス/変更なし。

## 2026-10-19 再現性・診断補強

- `docs/18`と`docs/19`を復旧記録・KnOSのpasswd/shadow参照経路まで拡充し、一般OpenWrtの説明、SBAT6静的解析、過去実機確認を区別。
- Controller/Agent値の根拠と不明点を示す`configs/easymesh-values-matrix.md`を追加。
- 秘密値を読まず、IP/MAC/SSIDをマスクしてstdoutへ表示する読み取り専用`scripts/sbat6-diagnose.sh`を追加。
- Markdownリンク、禁止artifact、shell syntax、diagnostic read-only契約とCI secret scanを追加。
- テスト、secret/history scan、差分・リンク・スクリプト安全性を監査。実機アクセス/変更なし。

## 2026-10-19

- SBAT6 EasyMeshの日本語技術記録を新規公開。
- 有線オンボーディング、Controller/Agent、6 GHz BHとL2延長、MLO後続検証、失敗/復旧、未解決点を分離して記録。
- 原ログ/firmware/秘密情報/実機固有スクリプトを含めず、設定値と測定値の必要最小限要約を収録。
- source/time/role/secret audit実施。実機変更なし。
- GitHub Public `Karin-Laboratory/sbat6-easymesh` を作成して `main` へpush。APIから公開設定とREADMEを確認。
- EHT320試験案に記された既知成功の160+160ベースラインを追記し、オンエア証跡の限界を明記。

- Qiita成功報告を一次資料として反映し、MLO二帯域成立・RSNE修正・reboot復帰・Ethernet間iperf3実測を訂正/追記。
- KnOS firewall/Dropbear/password sourceの静的経路とT6A SSH overlay復旧方式を証拠レベル別に追加。root password永続性は未検証と明記。
- 成功記事の`.223`と別snapshot`.247`を日付/文脈で分離し、DHCP履歴不足を記録。
- 5ch向け回答、root取得後実践ガイド、診断/復旧/監査章を追加。
- 公開前後のリンク、secret pattern、Git履歴、変更差分を検査。実機変更なし。
