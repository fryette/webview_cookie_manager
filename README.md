# Webview Cookie Manager
[![pub package](https://img.shields.io/pub/v/webview_cookie_manager.svg)](https://pub.dartlang.org/packages/webview_cookie_manager)

A flutter library to manager your web cookies for Android(API level 9) and iOS(11+).

## Get started iOS
Set minimum version for iOS to 11.0

## How to use
The WebCookieManager can be used directly or together with [webview_flutter](https://pub.dev/packages/webview_flutter).

Get cookies:
```dart
final cookieManager = WebviewCookieManager();

final gotCookies = await cookieManager.getCookies('https://youtube.com');
for (var item in gotCookies) {
  print(item);
}
 ```

 Set cookie
 ```dart
await cookieManager.setCookies([
              Cookie('cookieName', 'cookieValue')
                ..domain = 'youtube.com'
                ..expires = DateTime.now().add(Duration(days: 10))
                ..httpOnly = false
            ]);
 ```
 Clear cookies
 ```dart
await cookieManager.clearCookies();
 ```

 For more examples check example folder.
 
 ## Troubleshooting
 If you are using Objective C, check that PodFile have a flag use_frameworks ([why you need to do it](https://github.com/amag2511/webview_cookie_manager/issues/4#issuecomment-665508540))
 ```
target 'Runner' do
  use_frameworks!
  use_modular_headers!
  ..........
end
```

## How it works
The cookies stores and retrieves using the [httpCookieStore](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/2881956-httpcookiestore) for iOS and [CookieManager](https://developer.android.com/reference/java/net/CookieManager) for Android.
