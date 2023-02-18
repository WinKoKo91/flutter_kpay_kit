#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_kpay_kit.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_kpay_kit'
  s.version          = '0.0.1'
  s.summary          = 'KBZ mobile payment plugin.'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'KwinLab' => 'winkoko.dev@gmail.com' }
  s.source           = { :path => '.' }
  s.ios.vendored_frameworks = 'Frameworks/KBZPayAPPPay.framework'
  s.vendored_frameworks = 'KBZPayAPPPay.framework'
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
