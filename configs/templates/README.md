# EasyMesh / MLO profileの構造仕様（安全な部分のみ）

このディレクトリは**実行可能な端末設定templateを提供しない**。保存されたprofileはSSID、BSSID、credential等の秘密/個体情報を含み、WTSの完全な列schemaも確認できなかったためである。部分値を空欄置換しただけの設定はOEM generatorが要求する整合性を満たさず、投入できない。

## 確認できた入力と生成先

| profile要素 | 保存値/形 | 用途・確度 | 適用状態 |
|---|---|---|---|
| EasyMesh role | `mapd_user.cfg`内の`DeviceRole`, `MapMode` key/value行 | Agent role writerは公開記事に記録。Controller role writer候補は別certification scriptの静的所見 | 部分的。完全templateではない |
| Backhaul priority | `BhPriority6G`, `BhPriority5GL`, `BhPriority5GH`, `BhPriority2G`, `AutoBHSwitching` keys | Controller成功時readback値 | 当時の成功値。別firmwareへの推奨値ではない |
| 6 GHz AP BSS | `/etc/map/mapd_user.cfg`由来のprofile slot、保存解析でradio token `11x` | 特定MLO調査snapshotにある。初期6 GHz単独BHの完全値とは確認できない | 実機再投入未検証 |
| 5 GHz/6 GHz MLO security | 初回5 GHz runtime WPA2/PSK+PMF optional、6 GHz SAE+PMF required。修正時の5GHz runtimeはSAE+PMF required | RSNE/M3 traceとruntime hostapd/DAT観測 | 修正実績はあるがtemplate適用は未検証 |
| Auth mode | profile slot `mapd.6.authmode`相当で`0x0022`から`0x0040`へ変更。WTS BSS info row id=6のauthmode fieldも合わせた | その試験での観測値と修正関係 | bitfield一般仕様や他slotへの意味は未検証 |
| WTS BSS info | `id=6`のauthmode fieldを更新。設定はpositional row | rowの全field schema、逃し値、参照関係は未復元 | 行templateを公開しない |
| AP MLD | MLO用`rai2` (5 GHz)+`rax2` (6 GHz)、保存案のgroup ID 2 | 保存スクリプト解析 | 6 GHz単独BHと別工程。再投入未検証 |
| STA MLD | `apclii0`+`apclix0`、保存案のgroup ID 1、primary `apclix0` | 保存スクリプト解析、実機2-link成功報告と整合 | 6 GHz単独BHと別工程。再投入未検証 |

## 生成・適用関係

`mapd_default.cfg`と`mapd_user.cfg`をOEM処理がmergeしてruntime `mapd_cfg`を生成し、`prepare_1905_config()`が`1905d.cfg`を生成する。KnOS EasyMesh起動ではこの処理がradio/BSSとnetworkを再構成する。MLOでは`wireless` UCIを変更しただけではprofileが戻る事象があり、入力profile、WTS BSS info、runtime `hostapd`/DAT、Beacon/Probe ResponseのRSNE、4-way handshakeをそれぞれ照合する必要がある。

## 6 GHz単独BHとMLOを分ける

- **初期6 GHz単独BH:** 成功報告はあるが、秘密を除いた全profileと初期writerが未復元。本ページは配置・暗号方式の完成templateではない。
- **MLO追加:** 5 GHz BH BSSの認証/PMF条件を6 GHz条件に合わせ、profile generator/WTS entry/runtime stateを直した後に2-link成功を報告。MLO group/hostapd settingを伴う別工程である。
- **失敗/修正:** 失敗時5GHz=`WPA2/PSK`, PMF optional, AKM `00-0f-ac-02`; 6GHz=`SAE`, PMF required, AKM `00-0f-ac-08`。修正後は両側がSAE/PMF requiredとなり4-way handshake成功を報告。RSNE/wpa_supplicantが実効値を示す根拠で、authmode hexadecimal値の一般解釈とは区別する。`0x0022`/`0x0040`のbit単位の定義は保存資料から復元できていない。

このspecは保存項目の位置と証拠境界を説明するだけで、端末へ貼り付ける設定例ではない。SSID/PSK/BSSID、DPP鍵、機器MAC、vendor元ファイル内容は公開しない。
