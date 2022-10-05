# 前提

- ライブラリのバージョンが固定されている
- Gradle プロジェクトである

# proguard/r8 のルールの可視化

## 1. proguard/r8 の設定をする

次のオプションで proguard/r8 の最終ルールがファイルに保存されます。場所は app module を root とした相対位置です。

```txt
-printconfiguration proguard-merged-config.txt
```

## 2. ユーザー実行環境依存の文字列を最終ルールファイルから削除する

`patch-r8-rules.gradle` または相当の処理を app module に適用してください。

## 3. コードレビューの対象にする

もしどこかの依存ライブラリでルールの変更があった場合、差分として表示されます。またローカルで minification を実行していないと意味がないため、CI サービスでは差分がコミットされていない場合に落とす必要があります。

> 同時に、.gitattributes などで generated になっていないことを確認してください。


# R8 の breaking changes / bug をキャッチできるようにする

## 1. proguard/r8 の設定をする

次のオプションで proguard/r8 の結果に関するファイルが保存されます。

```txt
-printseeds <file path>
-printusage <file path>
```

> VCS で管理する必要はありません。

## 2. バージョンの定義ファイルの変更などを見ることで AGP の更新をフックする

そのときに minification を行い、printseeds/printusage で指定したファイルに変化があれば breaking changes/bug と判断してよいです。

> 同時にコードを変更するとレビューが複雑になるため、独立したPRとして作成することをオススメします。

## 3. 特定バージョンの R8 を使って、修正・回避策を考える

実例: Kotlin と R8 の相性問題 - https://github.com/jmatsu/using-moshi-for-bugs-of-r8-with-kotlin-1.6.0

```gradle
// Groovy
buildscript {
    repositories {
        maven {
            url 'https://storage.googleapis.com/r8-releases/raw'
        }
    }

    dependencies {
        // AGP より先に適用してください
        classpath "com.android.tools:r8:$r8Version"
        classpath "com.android.tools.build:gradle:$agpVersion"
    }
}
```