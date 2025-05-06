/*
 * Copyright (C) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
 
import {
  Any,
  FlutterPlugin,
  FlutterPluginBinding,
  Log,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import { webview } from '@kit.ArkWeb';
import { List } from '@kit.ArkTS';

const TAG: string = "WebviewCookieManagerPlugin";

/** WebviewCookieManagerPlugin **/
export default class WebviewCookieManagerPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;
  private cookieController: webview.WebviewController | null = null;
  private tempDomain: string | null = null;

  getUniqueClassName(): string {
    return "WebviewCookieManagerPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "webview_cookie_manager");
    this.channel.setMethodCallHandler(this)
    this.cookieController = new webview.WebviewController();
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
    }
  }

  clearCookies(result: MethodResult): void {
    webview.WebCookieManager.clearAllCookies();

    result.success(null);
  }

  hasCookies(result: MethodResult): void {
    let hasCookie: boolean = webview.WebCookieManager.existCookie();

    result.success(hasCookie);
  }

  getCookies(call: MethodCall, result: MethodResult): void {
    let url: string = call.argument('url');
    // Update webURL
    let resultMap: Array<Map<string, Any>> = new Array<Map<string, Any>>();
    try {
      let originCookie = webview.WebCookieManager.fetchCookieSync(url);
      let cookieArray: Array<string> = originCookie.split(';');
      const regex = /^https?:\/\/([^/?#]+)/i;
      const match = regex.exec(url);
      this.tempDomain = match ? match[1] : null;
      cookieArray.forEach((cookie: string) => {
        if (cookie) {
          let cookieMap: Map<string, Any> = this.parseCookie(cookie)

          resultMap.push(cookieMap);
        }
      })
    } catch (err) {
      Log.e(TAG, 'Failed to fetch cookie from url' + err.code + err.message);
    }
    result.success(resultMap);
  }

  setCookies(call: MethodCall, result: MethodResult): void {
    let cookieArrayMap: Array<Map<string, Any>> = call.args;
    if (!cookieArrayMap) {
      result.error('Invalid arguments. Excepted Map<string, string>', null, null);
      return;
    }

    cookieArrayMap.forEach((cookieMap: Map<string, Any>) => {
      let origin = cookieMap.get('origin') as string;
      let domain = cookieMap.get('domain') as string;
      let domainString = ((origin !== null) && (origin !== undefined)) ? origin : domain;
      if (domainString) {
        if (!domainString.startsWith('http')) {
          domainString = `https://${domainString}`;
        }
        const asString = cookieMap.get('asString') as string;
        webview.WebCookieManager.configCookieSync(domainString, asString);
      }
    })

    result.success(null)
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case "clearCookies":
        this.clearCookies(result);
        break;
      case "hasCookies":
        this.hasCookies(result);
        break;
      case "getCookies":
        this.getCookies(call, result);
        break;
      case "setCookies":
        this.setCookies(call, result);
        break;
      default:
        result.notImplemented();
    }
  }

  private parseCookie(cookie: string): Map<string, Any> {
    let resultMap: Map<string, Any> = new Map<string, Any>();
    try {
      if (cookie.indexOf('=') != -1) {
        // Split the original cookie string
        let parts = cookie.split('=');
        let rawName = parts[0].trim(); 
        let rawValue = parts.slice(1).join('='); 

        let name = this.removeInvalidCharacters(rawName);
        let value = this.removeInvalidCharacters(rawValue);

        let lowName = name.toLowerCase();
        switch (lowName) {
          case 'path':
            resultMap.set('path', value);
            break;
          case 'domain':
            resultMap.set('domain', value);
            break;
          case 'secure':
            resultMap.set('secure', value.toLowerCase() === 'true'); // 明确转换为布尔值
            break;
          case 'httponly':
            resultMap.set('httpOnly', value.toLowerCase() === 'true');
            break;
          case 'expires':
            resultMap.set('expires', value);
            break;
          default:
            resultMap.set('name', name);
            resultMap.set('value', value);
            break;
        }
      }
    } catch (err) {
      Log.e(TAG, "Failed to parse cookie: " + err.message);
    }

    if (!resultMap.has('domain') || resultMap.get('domain') == null) {
      resultMap.set('domain', this.tempDomain);
    }
    resultMap.set('path', resultMap.get('path') || '/');
    resultMap.set('httpOnly', resultMap.get('httpOnly') || false);
    resultMap.set('secure', resultMap.get('secure') || false);

    return resultMap;
  }

  // Filter illegal characters
  private removeInvalidCharacters(input: string): string {
    if (!input) return '';

    //Permitted character range: ASCII printable characters (0x21-0x7E), excluding control characters and separators
    //Remove illegal characters (such as spaces, semicolons, commas, etc.)
    return input.replace(/[^\x21-\x7E]/g, '');
  }
}