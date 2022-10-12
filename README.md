# fcl_flutter

A new Flutter plugin project that implementation code for Android with [fcl-android](https://github.com/portto/fcl-android) and iOS with [fcl-swift](https://github.com/portto/fcl-swift) to support blocto SDK.

## Requirements

Android: 
- Min SDK 22 or newer

iOS: 
- Swift version >= 5.6
- iOS version >= 13

---

## Getting Started

### Install package
Add below section to your project's pubspec.yaml
```yaml
fcl_flutter:
    git:
      url: 
      ref: master
```
and run
```
flutter pub get
```

<br>

### Preset of package
There have serveral presets for specific platform to use package correctly.
#### Android
Add ``maven { url 'https://jitpack.io' }`` to your project's ``build.gradle``.
> This is required by [flow-jvm-sdk](https://github.com/onflow/flow-jvm-sdk#gradle).
```groovy
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://jitpack.io' }
    }
}
```
<br>

Add FCL content provider and webview activity to ``AndroidManifest.xml``.
```xml
<application>
    ...
    <activity
        android:name="com.portto.fcl.webview.WebViewActivity"
        android:theme="@style/FCLTheme"
        android:launchMode="singleTop"/>

    <provider android:authorities="com.portto.fcl.context"
        android:name="com.portto.fcl.lifecycle.FCLContentProvider" android:exported="false" />
    ...
</application>
```
<br>

Add themes for package's webview activity.
In ``(your project)/android/app/src/main/res/values/styles.xml``
```xml
<resources>
    ...
    <!-- Theme applied to the package's webview while login when the OS's Dark Mode setting is off -->
    <style name="FCLTheme" parent="Theme.AppCompat.Light.NoActionBar">
       <item name="android:windowBackground">?android:colorBackground</item>
    </style>
    ...
</resources>
```
In ``(your project)/android/app/src/main/res/values-night/styles.xml``
```xml
<resources>
    ...
    <!-- Theme applied to the package's webview while login when the OS's Dark Mode setting is on -->
    <style name="FCLTheme" parent="Theme.AppCompat.DayNight.NoActionBar">
       <item name="android:windowBackground">?android:colorBackground</item>
    </style>
    ...
</resources>
```
