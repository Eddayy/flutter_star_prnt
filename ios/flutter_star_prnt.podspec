#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_star_prnt.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_star_prnt'
  s.version          = '0.0.1'
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
  s.static_framework = true
  s.platform = :ios, '8.0'
  s.preserve_paths = 'Frameworks/*.framework'
  s.vendored_frameworks = 'Frameworks/*.framework'
  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'NO', 
  }
  s.xcconfig = { "OTHER_LDFLAGS" => '$(inherited) -framework "ExternalAccessory" -framework "CoreBluetooth" -framework "StarIO" -framework "StarIO_Extension"' }
  s.swift_version = '5.0'
end
