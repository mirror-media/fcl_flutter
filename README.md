# fcl_flutter

A new Flutter plugin project that implementation code for Android with [fcl-android](https://github.com/portto/fcl-android) and iOS with [fcl-swift](https://github.com/portto/fcl-swift) to support blocto SDK.

## Requirements

Android: 
- Min SDK 22 or newer

iOS: 
- Swift version >= 5.6
- iOS version >= 13

<br>

## Getting Started

### Install package
Add below section to your project's `pubspec.yaml`
```yaml
fcl_flutter:
    git:
      url: https://github.com/mirror-media/fcl_flutter.git
      ref: master
```
and run
```
flutter pub get
```

<br>

### Preset of package
There have serveral presets for specific platform to make package run correctly.
#### Android
- Add ``maven { url 'https://jitpack.io' }`` to your project's ``build.gradle``.
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

- Add FCL content provider and webview activity to ``AndroidManifest.xml``.
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

- Add themes for package's webview activity.

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

<br>

#### iOS

- Setting Universal Links & Custom URL Scheme for your app.
See this [documentation](https://docs.blocto.app/blocto-sdk/ios-sdk/prerequest) to know how to set.

<br>

- Open your project's `Info.plist`, and add the following.
This make your app know whether user install Blocto app.
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>blocto-staging</string>
    <string>blocto</string>
</array>
```
<br>

- Open your projects's `AppDelegate.swift`, and add the following.
This make Blocto can open your app after user authorized in Blocto app.
```swift
override func application(
    _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        fcl.application(open: url)
        return true
    }
        
override func application(
    _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        fcl.continueForLinks(userActivity)
        return true
    }
```