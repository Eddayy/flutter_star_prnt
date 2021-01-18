#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_star_prnt.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_star_prnt'
  s.version          = '0.0.2'
  s.summary          = 'Flutter plugin for star printers.'
  s.description      = <<-DESC
  Flutter plugin for star printers.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Edmund Tay' => 'edmundtay96@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'StarIO' ,'2.8.2' 
  s.dependency 'StarIO_Extension' , '1.15.0'
  s.static_framework = true
  s.platform = :ios, '9.0'
  s.preserve_path = 'Classes/**/*.modulemap'
  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' ,
    'SWIFT_INCLUDE_PATHS' => '$(PODS_TARGET_SRCROOT)/Classes/**/ $(PODS_TARGET_SRCROOT)/Classes'
  }
  s.swift_version = '5.0'
end
