import Flutter
import UIKit
import WebKit

@available(iOS 11.0, *)
public class SwiftWebviewCookieManagerPlugin: NSObject, FlutterPlugin {
    static var httpCookieStore: WKHTTPCookieStore?
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    httpCookieStore = WKWebsiteDataStore.default().httpCookieStore
    
    let channel = FlutterMethodChannel(name: "webview_cookie_manager", binaryMessenger: registrar.messenger())
    let instance = SwiftWebviewCookieManagerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
        case "getCookies":
            let arguments = call.arguments as! NSDictionary
            let url = arguments["url"] as? String
            SwiftWebviewCookieManagerPlugin.getCookies(url: url, result: result)
            break
        case "setCookies":
            let cookies = call.arguments as! Array<NSDictionary>
            SwiftWebviewCookieManagerPlugin.setCookies(cookies: cookies, result: result)
            break
        case "hasCookies":
            SwiftWebviewCookieManagerPlugin.hasCookies(result: result)
            break
        case "clearCookies":
            SwiftWebviewCookieManagerPlugin.clearCookies(result: result)
            break
        default:
            result(FlutterMethodNotImplemented)
            break
    }
  }
    
    public static func setCookies(cookies: Array<NSDictionary>, result: @escaping FlutterResult) {
        for cookie in cookies {
            _setCookie(cookie: cookie, result: result)
        }
    }
    
    public static func clearCookies(result: @escaping FlutterResult) {
        httpCookieStore!.getAllCookies { (cookies) in
            for cookie in cookies {
                httpCookieStore!.delete(cookie, completionHandler: nil)
            }
            // delete HTTPCookieStorage all cookies
            if let cookies = HTTPCookieStorage.shared.cookies {
                for cookie in cookies {
                    HTTPCookieStorage.shared.deleteCookie(cookie)
                }
            }
            result(nil)
        }
    }
    
    public static func hasCookies(result: @escaping FlutterResult) {
        httpCookieStore!.getAllCookies { (cookies) in
            result(!cookies.isEmpty)
        }
    }
    
    private static func _setCookie(cookie: NSDictionary, result: @escaping FlutterResult) {
        let expiresDate = cookie["expires"] as? Double
        let isSecure = cookie["secure"] as? Bool
        let isHttpOnly = cookie["httpOnly"] as? Bool
        
        var properties: [HTTPCookiePropertyKey: Any] = [:]
        properties[.name] = cookie["name"] as! String
        properties[.value] = cookie["value"] as! String
        properties[.domain] = cookie["domain"] as! String
        properties[.path] = cookie["path"] as? String ?? "/"
        if expiresDate != nil {
            properties[.expires] = Date(timeIntervalSince1970: expiresDate!)
        }
        if isSecure != nil && isSecure! {
            properties[.secure] = "TRUE"
        }
        if isHttpOnly != nil && isHttpOnly! {
            properties[.init("HttpOnly")] = "YES"
        }
        
        let cookie = HTTPCookie(properties: properties)!
        
        httpCookieStore!.setCookie(cookie, completionHandler: {() in
            result(true)
        })
    }
    
    public static func getCookies(url: String?, result: @escaping FlutterResult) {
        let cookieList: NSMutableArray = NSMutableArray()
        httpCookieStore!.getAllCookies { (cookies) in
            for cookie in cookies {
                if url == nil {
                    cookieList.add(_cookieToDictionary(cookie: cookie))
                }
                else if cookie.domain.contains(URL(string: url!)!.host!) {
                    cookieList.add(_cookieToDictionary(cookie: cookie))
                }
            }
            // If the cookie value is empty in WKHTTPCookieStore,
            // get the cookie value from HTTPCookieStorage
            if cookieList.count == 0 {
                if let cookies = HTTPCookieStorage.shared.cookies {
                    for cookie in cookies {
                        if url == nil {
                            cookieList.add(_cookieToDictionary(cookie: cookie))
                        }
                        else if cookie.domain.contains(URL(string: url!)!.host!) {
                            cookieList.add(_cookieToDictionary(cookie: cookie))
                        }
                    }
                }
            }
            result(cookieList)
        }
    }
    
    public static func _cookieToDictionary(cookie: HTTPCookie) -> NSDictionary {
        let result : NSMutableDictionary =  NSMutableDictionary()
        
        result.setValue(cookie.name, forKey: "name")
        result.setValue(cookie.value, forKey: "value")
        result.setValue(cookie.domain, forKey: "domain")
        result.setValue(cookie.path, forKey: "path")
        result.setValue(cookie.isSecure, forKey: "secure")
        result.setValue(cookie.isHTTPOnly, forKey: "httpOnly")
        
        if cookie.expiresDate != nil {
            let expiredDate = cookie.expiresDate?.timeIntervalSince1970
            result.setValue(Int(expiredDate!), forKey: "expires")
        }
        
        return result;
    }
}
