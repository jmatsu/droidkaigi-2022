# AAB

## ファイル構成

AAB は zip ファイルなので、unzip で閲覧できます。

- APK と異なり、リソースパスの remapping はされていません(調査環境に依存する可能性有り)
- XML はエンコードされています
- 画像(vector drawableを除く)であればファイルを取り出すだけで参照可能です

```
/
 - BundleConfig.pb # aab の構成ファイル(dump config で参照可能)
 - BUNDLE-METADATA/
   - assets.dexopt/
     - # baseline profile 用のファイル同梱(binary)
   - com.android.tools.build.obfuscation/
     - # proguard mapping ファイル同梱
   - com.android.tools.build.gradle/
     - # ビルドしたときの AGP のメタデータ(versionなど)同梱
   - com.android.tools.build.libraries/
     - # 依存ライブラリ(protobuf)
 - base/
 - <module1>
   ...
 - <moduleN>
 - META-INF/
   - # aab の署名情報など
```

## Google 謹製

- [bundletool-cheatsheet.md](./bundletool-cheatsheet.md)

## 3rd party tools

見つかりませんでした。

# APK

## build-tools 同梱

- aapt (deprecated)
- aapt2

## Google 謹製

- https://github.com/google/android-classyshark
- https://github.com/google/android-arscblamer

## 3rd party tools

- https://github.com/iBotPeaches/Apktool
- https://github.com/skylot/jadx
- https://github.com/androguard/androguard
- https://github.com/ytsutano/axmldec