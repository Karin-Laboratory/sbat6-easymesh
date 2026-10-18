# 12. 設定永続化と起動時の上書き

設定変更後に再起動で期待値が消える/別値へ戻る可能性が、復旧スクリプトや後日のPrivate archiveで問題として扱われている。静的解析で `/etc/config/mapd` をvendor Lua (`uci2map.lua`) がmapd向け設定へ変換することが確認でき、無線UCIとKNOS backup source等の複数層を扱う記録もある。

`MapMode`変更はMesh daemonやnetwork helperの起動時処理を通じてネットワークIFやbridge構成に影響し得る。ただし、全変更ケースでの因果を実機ログで確定できない。単一設定ファイルを直接編集して再起動する方法は安全な再現手順ではない。

後続のMLO/EHT320試験では、事前snapshot、commit後のreadback、rollback/failsafeを設計している。EHT320のfailsafeは案の段階であり、実機の永続性証明には使えない。

再現時は、変更前後に関係する全UCI値と生成ファイルのhash、起動symlink、起動後daemonの実行結果を保存し、再起動後にも再取得する。秘密を含むsnapshotは公開しない。
