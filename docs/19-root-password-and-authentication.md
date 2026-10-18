# 19. rootパスワードとSSH認証

## SSH鍵が戻ったこととroot passwordは別

2026-09のT6A復旧runbookで確認できる成功は、overlay復元でDropbear・authorized key・管理補助物を戻し、鍵認証によるroot SSHを再度利用できたこと。過去のDropbear起動引数`-s -g`はpassword login禁止を意味する。過去復旧seedはauthorized_keysとDropbear関連fileを含むが、`/etc/passwd`・`/etc/shadow`をseed対象に含めていない。これはrootパスワードの設定・保存・再起動後の認証を証明しない。

Linuxのローカルアカウントpassword verifierは通常`/etc/shadow`に保存される。保存Bank A/Bの`/etc/passwd`と`/etc/shadow`は`/etc/knos/site/`配下を指すsymlinkとして存在した。また`knos_config`には条件により両ファイルを削除し、`/etc/knos/$system_mode/`配下へのsymlinkを作り直すコードがある。`system_mode=factory`側の処理ではDropbear UCI enableも設定し、それ以外ではdisableにする分岐があった。これはKnOSによる認証データ参照先/Dropbear状態変更の**静的実装確認**である。

`passwd`変更が実機上でどの層に記録され、その変更したmode/sourceが通常起動で選ばれるかは別途確認が必要。本件でroot passwordを変更して再起動後に認証試験した記録、10/18の条件分岐発火を示すruntime log、実効password databaseの永続性証拠は取得できなかった。したがって**root passwordの永続化は未検証**。秘密値やhashは公開していない。

## 秘密を表示せず確認する

対象の所有者が管理経路を確保した上で、秘密値を出力せず次の状態だけ確認する。

- `passwd -S root`が対応していればアカウント状態だけを見る（出力仕様はbusybox版依存）。
- `/etc/passwd`と`/etc/shadow`は表示・コピーせず、`readlink`で参照先のパスだけ、`stat`でmode/変更時刻のみ記録する。KnOSのsystem modeと参照先パスの対応も秘密値を出さずに確認する。
- `uci show dropbear`は認証関連optionだけを確認し、出力に鍵・秘密が混ざらないか確認する。
- Dropbear実プロセス引数とservice設定から`-s`等のpassword login禁止を確認する。
- 再起動を伴う検証は別管理経路・物理復旧手段を確保して計画する。認証値やhashをIssue・ログ・チャット・Gitへ貼らない。

SSH鍵認証は強いランダム鍵を端末外で安全に保管し、root passwordをネットワーク越しに入力する必要を避けられる。秘密鍵流出やauthorized_keys改変の対策は別途必要。古いT6A管理鍵の秘密鍵はraspi2上に保管され、本公開記録にも転載しない。どちらの方式でも管理LANに限定し、WAN公開を避ける。
