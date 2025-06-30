ruby
Pod::Spec.new do |s|
  s.name             = 'receipt_scanner_plugin'
  s.version          = '0.0.1'
  s.summary          = 'A plugin for scanning receipts using VisionKit'
  s.description      = <<-DESC
A plugin for scanning receipts using VisionKit on iOS and ML Kit on Android.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '10.0'
  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'
end