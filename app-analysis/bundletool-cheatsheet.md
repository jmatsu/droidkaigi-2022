

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