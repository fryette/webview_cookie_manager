import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class WebviewCookieManager {
  static const MethodChannel _channel =
      const MethodChannel('webview_cookie_manager');

  /// Creates a [CookieManager] -- returns the instance if it's already been called.
  factory WebviewCookieManager() {
    return _instance ??= WebviewCookieManager._();
  }

  WebviewCookieManager._();

  static WebviewCookieManager _instance;

  /// Check some cookies web view cookies
  Future<bool> hasCookies() {
    return _channel
        .invokeMethod<bool>('hasCookies')
        .then<bool>((dynamic result) => result);
  }

  /// Clear all web view cookies
  Future<bool> clearCookies() {
    return _channel
        .invokeMethod<bool>('clearCookies')
        .then<bool>((dynamic result) => result);
  }

  /// Read out all cookies, or all cookies for a [currentUrl] when provided
  Future<List<Cookie>> getCookies([String currentUrl]) {
    return _channel.invokeListMethod<Map<dynamic, dynamic>>(
        'getCookies', <dynamic, dynamic>{
      'url': currentUrl
    }).then<List<Cookie>>((List<Map<dynamic, dynamic>> results) {
      return results.map((Map<dynamic, dynamic> result) {
        final Cookie c = Cookie(result['name'], result['value']);
        // following values optionally work on iOS only
        c.path = result['path'];
        c.domain = result['domain'];
        c.secure = result['secure'];
        c.httpOnly = result['httpOnly'];

        if (result['expires'] != null) {
          c.expires = DateTime.fromMillisecondsSinceEpoch(
              (result['expires'] * 1000).toInt());
        }

        return c;
      }).toList();
    });
  }

  /// Set [cookies] into the web view
  Future<void> setCookies(List<Cookie> cookies) {
    final List<Map<String, dynamic>> transferCookies = cookies.map((Cookie c) {
      final Map<String, dynamic> output = <String, dynamic>{
        'name': c.name,
        'value': c.value,
        'path': c.path,
        'domain': c.domain,
        'secure': c.secure,
        'httpOnly': c.httpOnly,
        'asString': c.toString(),
      };

      if (c.expires != null) {
        output['expires'] = c.expires.millisecondsSinceEpoch ~/ 1000;
      }

      return output;
    }).toList();
    return _channel.invokeMethod<void>('setCookies', transferCookies);
  }
}
