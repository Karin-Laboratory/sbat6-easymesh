# 12. 設定・SSH・Meshの永続性

別々に検証する対象は (1) UCI/KnOS設定、(2) runtime firewall table、(3) Dropbear/OpenSSH lifecycle、(4) EasyMesh role/profile、(5) DHCP/管理IP、(6) MLO link association。ある層の保存hash一致は他層の動作保証ではない。

2026-08公開記事はEasyMesh MLO後の通常rebootで約170秒後DHCP、約173秒後Mesh再参加、342秒以上のMLO観測を報告する。これはMesh/MLOの報告であり、SSH・iptables永続化を示さない。

別の2026-09 T6A復旧記録では`/data/sbat6-ssh-overlay.tgz`をseedとし、`/data/sysupgrade.tgz`経由のoverlay復元、毎分seed再配置、20秒周期watchdogで鍵SSHを復帰させた。再起動2回後に接続を確認した一方、起動時の復元後に通常3〜4分待った。これは特定の過去T6A復旧手法で、8月の2台Mesh構成・root password永続性の証拠ではない。

B再起動snapshotはrole/modeと一部設定hash保持を示したが、採取時UPのAPCLIは入れ替わった。ファイル名・host mtime・端末epochがずれるため実験時系列は限定的。