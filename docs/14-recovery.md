# 14. 復旧の考え方

保存されたスクリプト群には、設定変更前のbackup、UCI状態のassert、rollback scriptの存在確認、MLO採取を止めるcleanup処理がある。後続のEHT320案はper-device snapshotと遅延rollbackを設計しているが、実機適用済みとは確認できない。

## 安全な復旧優先順位

1. MeshとIPの状態を別々に観測し、稼働中の別管理経路を特定する。
2. 再起動前の設定snapshotと現在値を比較する。PSK/鍵を出力しない。
3. 過去の適用スクリプトをそのまま再実行せず、対象機・前提条件 (`DeviceRole`, `MapMode`, rollback bundle) を確認する。
4. 既知のbackupから変更したUCI値・network設定だけを戻す。
5. 現場に復旧経路があることを確認してから、必要時のみ通常再起動する。
6. 起動後にSSH、EasyMesh topology、BH、`br-lan`、クライアント通信を個別に再検証する。

公開用の自動rollback scriptは収録しない。過去のRCE/bootstrap/Dropbear/firewallスクリプトは資格情報や実機固有のtargetを含む可能性があるため、公開不適格。データ初期化・factory resetや不可逆なsecurity setting変更は本実験の標準復旧ではない。
