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
 Check is any cookie available
 ```dart
await cookieManager.hasCookies();
 ```

 Remove cookie

 ```dart
 await cookieManager.removeCookie();
 ```

 Clear cookies
 ```dart
await cookieManager.clearCookies();
 ```
 
  **IMPORTANT NOTE**: Domain attribute is not required according to [RFC](https://tools.ietf.org/html/rfc6265#section-5.2.3), but it is important to remember that empty domain causes undefined behavior. So it is highly reccommended to specify it this this way:
```(Dart)
final cookie = Cookie('cookieName', 'cookieValue')..domain = 'youtube.com';
```

 For more examples check example folder.
 
 ## Troubleshooting
 
 
 1) Set minimum target iOS version to 11([why](https://github.com/fryette/webview_cookie_manager/issues/17#issuecomment-682382429))
 2) If you are using Objective C, check that PodFile have a flag use_frameworks ([why you need to do it](https://github.com/amag2511/webview_cookie_manager/issues/4#issuecomment-665508540))
 ```
target 'Runner' do
  use_frameworks!
  use_modular_headers!
  ..........
end
```

## How it works
The cookies stores and retrieves using the [httpCookieStore](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/2881956-httpcookiestore) for iOS and [CookieManager](https://developer.android.com/reference/java/net/CookieManager) for Android.
