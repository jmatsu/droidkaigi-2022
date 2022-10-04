# Visualize final-rules of R8/Proguard

## 1. Modify your proguard configruation

Specify the following option to print the final result of the proguard/r8 rules to a file.

```txt
-printconfiguration proguard-merged-config.txt
```

## 2. Apply `patch-r8-rules.gradle` to your app module

This patch will erace user-specific values from the merged proguard/r8 rules.

## 3. Check the diff of the merged rules file

If your app's proguard/r8 rules have been changed, the merged rules file will be dirty.

# Use the specific version of R8

```gradle
// Groovy
buildscript {
    repositories {
        maven {
            url 'https://storage.googleapis.com/r8-releases/raw'
        }
    }

    dependencies {
        // Must be before AGP
        classpath "com.android.tools:r8:$r8Version"
        classpath "com.android.tools.build:gradle:$agpVersion"
    }
}
```