#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint webview_cookie_manager.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'webview_cookie_manager'
  s.version          = '2.0.7'
  s.summary          = 'A Flutter plugin for managing WebView cookies.'
  s.description      = <<-DESC
Have you been turned into a cookie management problem? This package can help.
It has all of the cookie management functionality you have been looking for.
                       DESC
  s.homepage         = 'https://github.com/fryette/webview_cookie_manager'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'fryette' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'webview_cookie_manager/Sources/webview_cookie_manager/**/*.swift'
  s.resource_bundles = {'webview_cookie_manager_privacy' => ['webview_cookie_manager/Sources/webview_cookie_manager/PrivacyInfo.xcprivacy']}
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
