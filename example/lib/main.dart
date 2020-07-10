import 'dart:io';

import 'package:flutter/material.dart';

import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final String _url = 'https://youtube.com';
  final String cookieValue = 'some-cookie-value';
  final String domain = 'youtube.com';
  final String cookieName = 'some_cookie_name';

  @override
  void initState() {
    super.initState();
    WebviewCookieManager.clearCookies();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: WebView(
          initialUrl: _url,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (controller) async {
            await WebviewCookieManager.setCookies([
              Cookie(cookieName, cookieValue)
                ..domain = domain
                ..expires = DateTime.now().add(Duration(days: 10))
            ]);
          },
          onPageFinished: (_) async {
            final gotCookies = await WebviewCookieManager.getCookies(_url);
            for (var item in gotCookies) {
              print(item);
            }
          },
        ),
      ),
    );
  }
}
