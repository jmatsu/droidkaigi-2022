# get-metrics.rb

各種値を取り出す Ruby スクリプトです。これらの値を new version と最新リリースとで比較してください。

```bash
export BUNDLETOOL_JAR_PATH=/path/to/bundletool.jar
./get-metrics <bundle.aab>
```

```json
{
  "manifest": {
    "package_name": "io.github.jmatsu.droidkaigi2022example",
    "target_sdk_version": "31",
    "min_sdk_version": "26",
    "version_code": "1",
    "version_name": "1.0.0",
    "use_permissions": [
      {
        "name": "android.permission.INTERNET"
      },
      {
        "name": "android.permission.CAMERA"
      },
      {
        "name": "android.permission.WAKE_LOCK"
      },
      {
        "name": "com.google.android.finsky.permission.BIND_GET_INSTALL_REFERRER_SERVICE"
      }
    ],
    "required_features": [
      {
        "name": "android.hardware.camera",
        "required": "true"
      }
    ]
  },
  "persistent": {
    "MIN": "2848259",
    "MAX": "2919113"
  },
  "universal": {
    "MIN": "3054456",
    "MAX": "3054456"
  }
}
```

---

- bundletool 1.11.2 をベースに記載しています。
- 全てのコマンド・オプションを網羅しているわけではないことに注意してください。

# 基本構成

`--bundle <*.aab>` は全てのコマンドで必要です。

```bash
java -jar bundletool.jar <command> [subcommand] --bundle <bundle.aab> [opts...]
```

help はあまり実装されていないので、https://github.com/google/bundletool を読む方が早いです。

# build-apks command

```bash
java -jar bundletool.jar build-apks --bundle <bundle.aab> --output <output.apks> [--mode <universal|system|archive|persistent|instant>]
```

- `--overwrite` をつけないと出力先にファイルがあるときに異常終了します。
- mode 指定なし OR `universal`, `persistent` 以外の apks を手元で作成することは一般用途だとありません。
  - 指定なし(default): 端末別最適やfeature delivery対応のsplits + instant
  - universal: 全部入り APK
  - system: system image に入れる用APK
  - archive: archive のときにインストールされている APK 
    - ref: https://android-developers.googleblog.com/2022/03/freeing-up-60-of-storage-for-apps.html
  - instant: Instant Apps のみの APK
  - persistent: default - instant

# get-size command

AAB ではなく APKS に対して実行するコマンドです。

## subcommand

- total

### total

```bash
java -jar bundletool.jar get-size total --apks <apks.apks> [--human-readable-sizes] [device-spec <spec.json>] [--modules <module>,...] [--instant] [--dimensions <dimension>,...]
```

- 考えられる組み合わせの最小サイズと最大サイズが表示されます。
- device-specなどを指定した場合はその端末に対する最適化APKのサイズが表示されます。
- defualt で生成した apks の MAX は universal の MAX とは異なり、universal の方がほぼ全てのケースで大きくなります。

### 無引数のとき

`java -jar bundletool.jar get-size total --apks <apks.apks>`

```
MIN,MAX
2848259,2919113
```

#### MB, GB などの表示

`java -jar bundletool.jar get-size total --apks <apks.apks> --human-readable-sizes`

```
MIN,MAX
2.85 MB,2.92 MB
```

##

# dump command

## subcoomand

- config
- resources
- manifest
- runtime-enabled-sdk-config

### config

```bash
java -jar bundletool.jar dump config --bundle <bundle.aab>
```

`java -jar bundletool.jar dump config --bundle <bundle.aab>`

```
{
  "bundletool": {
    "version": "<version>"
  },
  "optimizations": {
    "splitsConfig": {
        // プロジェクト依存
    },
    "uncompressNativeLibraries": {
      "enabled": true|false
    }
  },
  "compression": {
    "uncompressedGlob": ["**.3[gG]2", "**.3[gG][pP]", "**.3[gG][pP][pP]", "**.3[gG][pP][pP]2", "**.[aA][aA][cC]", "**.[aA][mM][rR]", "**.[aA][wW][bB]", "**.[gG][iI][fF]", "**.[iI][mM][yY]", "**.[jJ][eE][tT]", "**.[jJ][pP][eE][gG]", "**.[jJ][pP][gG]", "**.[mM]4[aA]", "**.[mM]4[vV]", "**.[mM][iI][dD]", "**.[mM][iI][dD][iI]", "**.[mM][kK][vV]", "**.[mM][pP]2", "**.[mM][pP]3", "**.[mM][pP]4", "**.[mM][pP][eE][gG]", "**.[mM][pP][gG]", "**.[oO][gG][gG]", "**.[oO][pP][uU][sS]", "**.[pP][nN][gG]", "**.[rR][tT][tT][tT][lL]", "**.[sS][mM][fF]", "**.[tT][fF][lL][iI][tT][eE]", "**.[wW][aA][vV]", "**.[wW][eE][bB][mM]", "**.[wW][eE][bB][pP]", "**.[wW][mM][aA]", "**.[wW][mM][vV]", "**.[xX][mM][fF]"]
  }
}
```

### resources

```bash
java -jar bundletool.jar dump resources --bundle <bundle.aab> [--values[=true|=false]] [--resource <type>/<name>]
```

### 無引数のとき

`java -jar bundletool.jar dump resources --bundle <bundle.aab>`

```
Package 'io.github.jmatsu.droidkaigi2022example':
...
0x7f11000a - styleable/AppCompatEmojiHelper
        (default)
0x7f11000b - styleable/AppCompatImageView
        (default)
...
```

#### 値表示

`java -jar bundletool.jar dump resources --bundle <bundle.aab> --values`

```
Package 'io.github.jmatsu.droidkaigi2022example':
...
0x7f11000a - styleable/AppCompatEmojiHelper
        (default) - [STYLEABLE] []
0x7f11000b - styleable/AppCompatImageView
        (default) - [STYLEABLE] [@android:attr/src, @attr/srcCompat, @attr/tint, @attr/tintMode]
...
```

#### 値表示 + リソース絞り込み 例1

`java -jar bundletool.jar dump resources --bundle <bundle.aab> --values --resource styleable/AppCompatImageView`

```
Package 'io.github.jmatsu.droidkaigi2022example':
0x7f11000b - styleable/AppCompatImageView
        (default) - [STYLEABLE] [@android:attr/src, @attr/srcCompat, @attr/tint, @attr/tintMode]
```

#### 値表示 + リソース絞り込み 例2

`java -jar bundletool.jar dump resources --bundle <bundle.aab> --values --resource string/app_name`

```
Package 'io.github.jmatsu.droidkaigi2022example':
0x7f0f0024 - string/app_name
        (default) - [STR] "DroidKaigi 2022 Example"
        locale: "ja" - [STR] "DroidKaigi 2022 サンプル"
```

### manifest

```bash
java -jar bundletool.jar dump manifest --bundle <bundle.aab> [--xpath <xpath>]
```

### 無引数のとき

`java -jar bundletool.jar dump manifest --bundle <bundle.aab>`

```
<manifest xmlns:android="http://schemas.android.com/apk/res/android" android:compileSdkVersion="31" android:compileSdkVersionCo
dename="12" android:versionCode="1" android:versionName="1.0.0" package="io.github.jmatsu.droidkaigi2022example" platformBuildVersionCode="3
1" platformBuildVersionName="12">

  <uses-sdk android:minSdkVersion="26" android:targetSdkVersion="31"/>
  ...

  <application android:allowBackup="false" android:appComponentFactory="androidx.core.app.CoreComponentFactory" android:icon="@
mipmap/ic_launcher" android:label="@string/app_name" android:name="io.github.jmatsu.droidkaigi2022example.App" android:roundIcon="@mipmap/ic_launcher_r
ound" android:theme="@style/AppTheme">
    ...
  </application>
</manifest>
```

#### Xpath 指定

> ノードレベルでは取れないので、複雑なことをしたい場合は xpath 指定をしない方がいいです。

`java -jar bundletool.jar dump manifest --bundle <bundle.aab> --xpath '/manifest/@package'`

```
io.github.jmatsu.droidkaigi2022example
```

# validate コマンド

`java -jar bundletool.jar validate --bundle <bundle.aab>`

各feature moduleの中身が出力されます。不正な app bundle だと異常終了します。

```
App Bundle information
------------
Feature modules:
        Feature module: base
                File: assets/...
                File: dex/classes.dex
                ...
```
