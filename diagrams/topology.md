# 構成図

```text
             上位LAN / Router
                    |
           +--------+--------+
           | T6A / Controller|
           | Distance = 0    |
           +--------+--------+
                    )) 6 GHz EasyMesh BH ((
           +--------+--------+
           | T6B / Agent     |
           | Distance = 1    |
           +--------+--------+
                    |
              Ethernet / br-lan
                    |
              有線クライアント
```

概念図。子機側クライアントのDHCPなど全プロトコル透過を表すものではない。独立STA管理はこの構成のBHとは異なる。
