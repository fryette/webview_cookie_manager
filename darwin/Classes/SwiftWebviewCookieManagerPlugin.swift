#if os(iOS)
import Flutter
import UIKit
#else
import FlutterMacOS
#endif

import WebKit

@available(iOS 11.0, macOS 10.13, *)
public class SwiftWebviewCookieManagerPlugin: NSObject, FlutterPlugin {
    static var httpCookieStore: WKHTTPCookieStore?

    public static func register(with registrar: FlutterPluginRegistrar) {
        httpCookieStore = WKWebsiteDataStore.default().httpCookieStore

        #if os(iOS)
        let channel = FlutterMethodChannel(name: "webview_cookie_manager", binaryMessenger: registrar.messenger())
        #else
        let channel = FlutterMethodChannel(name: "webview_cookie_manager", binaryMessenger: registrar.messenger)
        #endif

        let instance = SwiftWebviewCookieManagerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getCookies":
            guard let arguments = call.arguments as? NSDictionary,
                  let url = arguments["url"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for getCookies", details: nil))
                return
            }
            SwiftWebviewCookieManagerPlugin.getCookies(urlString: url, result: result)

        case "setCookies":
            guard let cookies = call.arguments as? Array<NSDictionary> else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for setCookies", details: nil))
                return
            }
            SwiftWebviewCookieManagerPlugin.setCookies(cookies: cookies, result: result)

        case "hasCookies":
            SwiftWebviewCookieManagerPlugin.hasCookies(result: result)

        case "clearCookies":
            SwiftWebviewCookieManagerPlugin.clearCookies(result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public static func setCookies(cookies: Array<NSDictionary>, result: @escaping FlutterResult) {
        guard let store = httpCookieStore else {
            result(FlutterError(code: "COOKIE_STORE_UNAVAILABLE", message: "HTTP cookie store is not available", details: nil))
            return
        }

        for cookie in cookies {
            _setCookie(cookie: cookie, store: store)
        }
        result(true)
    }

    public static func clearCookies(result: @escaping FlutterResult) {
        guard let store = httpCookieStore else {
            result(FlutterError(code: "COOKIE_STORE_UNAVAILABLE", message: "HTTP cookie store is not available", details: nil))
            return
        }

        store.getAllCookies { (cookies) in
            for cookie in cookies {
                store.delete(cookie, completionHandler: nil)
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
        guard let store = httpCookieStore else {
            result(FlutterError(code: "COOKIE_STORE_UNAVAILABLE", message: "HTTP cookie store is not available", details: nil))
            return
        }

        store.getAllCookies { (cookies) in
            var isEmpty = cookies.isEmpty
            if isEmpty {
                // If it is empty, check whether the HTTPCookieStorage cookie is also empty.
                isEmpty = HTTPCookieStorage.shared.cookies?.isEmpty ?? true
            }
            result(!isEmpty)
        }
    }

    private static func _setCookie(cookie: NSDictionary, store: WKHTTPCookieStore) {
        guard let name = cookie["name"] as? String,
              let value = cookie["value"] as? String else {
            print("Error: Cookie must have 'name' and 'value' properties")
            return
        }

        let domain = cookie["domain"] as? String
        let expiresDate = cookie["expires"] as? Double
        let isSecure = cookie["secure"] as? Bool
        let isHttpOnly = cookie["httpOnly"] as? Bool
        let origin = cookie["origin"] as? String

        var properties: [HTTPCookiePropertyKey: Any] = [:]
        properties[.name] = name
        properties[.value] = value
        properties[.path] = cookie["path"] as? String ?? "/"

        if let domain = domain {
            properties[.domain] = domain
        }
        if let origin = origin {
            properties[.originURL] = origin
        }
        if let expiresDate = expiresDate {
            properties[.expires] = Date(timeIntervalSince1970: expiresDate)
        }
        if let isSecure = isSecure, isSecure {
            properties[.secure] = "TRUE"
        }
        if let isHttpOnly = isHttpOnly, isHttpOnly {
            properties[.init("HttpOnly")] = "YES"
        }

        if let httpCookie = HTTPCookie(properties: properties) {
            store.setCookie(httpCookie)
        } else {
            print("Error: Failed to create cookie with properties: \(properties)")
        }
    }

    public static func getCookies(urlString: String?, result: @escaping FlutterResult) {
        guard let store = httpCookieStore else {
            result(FlutterError(code: "COOKIE_STORE_UNAVAILABLE", message: "HTTP cookie store is not available", details: nil))
            return
        }

        // map empty string and nil to "", indicating that no filter should be applied
        let url = urlString.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } ?? ""

        // ensure passed in url is parseable, and extract the host
        let host = URL(string: url)?.host

        // fetch and filter cookies from WKHTTPCookieStore
        store.getAllCookies { (wkCookies) in

            func matches(cookie: HTTPCookie) -> Bool {
                // nil host means unparseable url or empty string
                let containsHost = host.map { cookie.domain.contains($0) } ?? false
                let containsDomain = host?.contains(cookie.domain) ?? false
                return url == "" || containsHost || containsDomain
            }

            var cookies = wkCookies.filter { matches(cookie: $0) }

            // If the cookie value is empty in WKHTTPCookieStore,
            // get the cookie value from HTTPCookieStorage
            if cookies.count == 0 {
                if let httpCookies = HTTPCookieStorage.shared.cookies {
                    cookies = httpCookies.filter { matches(cookie: $0) }
                }
            }

            let cookieList: NSMutableArray = NSMutableArray()
            cookies.forEach { cookie in
                cookieList.add(_cookieToDictionary(cookie: cookie))
            }
            result(cookieList)
        }
    }

    public static func _cookieToDictionary(cookie: HTTPCookie) -> NSDictionary {
        let result: NSMutableDictionary = NSMutableDictionary()

        result.setValue(cookie.name, forKey: "name")
        result.setValue(cookie.value, forKey: "value")
        result.setValue(cookie.domain, forKey: "domain")
        result.setValue(cookie.path, forKey: "path")
        result.setValue(cookie.isSecure, forKey: "secure")
        result.setValue(cookie.isHTTPOnly, forKey: "httpOnly")

        if let expiresDate = cookie.expiresDate {
            let expiredDate = expiresDate.timeIntervalSince1970
            result.setValue(Int(expiredDate), forKey: "expires")
        }

        return result
    }
}
