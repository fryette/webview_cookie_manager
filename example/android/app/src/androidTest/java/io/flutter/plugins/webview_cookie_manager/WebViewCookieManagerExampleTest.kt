package io.flutter.plugins.webview_cookie_manager

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.junit.Test
import java.lang.Error

class WebViewCookieManagerExampleTest {
    @Test
    fun onMethodCall_withoutDomainAttribute() {
        val plugin = WebviewCookieManagerPlugin()
        val arguments = listOf(mapOf("cookie_name" to "name", "cookie_value" to "value"))
        val methodCall = MethodCall("setCookies", arguments)
        plugin.onMethodCall(methodCall, object : MethodChannel.Result {
            override fun success(result: Any?) {}
            override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
                throw Error("Code: ${errorCode ?: "null"}\nMessage: ${errorMessage ?: "null"}")
            }
            override fun notImplemented() {}
        })
    }
}