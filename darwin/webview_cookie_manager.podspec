#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint webview_cookie_manager.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'webview_cookie_manager'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin for managing cookies in WebView.'
  s.description      = <<-DESC
A Flutter plugin for managing cookies in WebView on iOS and macOS platforms.
                       DESC
  s.homepage         = 'https://github.com/fryette/webview_cookie_manager'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'webview_cookie_manager' => 'https://github.com/fryette/webview_cookie_manager' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'

  # Platform support
  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.13'

  # Dependencies - Flutter tools will resolve the correct dependency based on platform
  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
