#import "FlutterStarPrntPlugin.h"
#if __has_include(<flutter_star_prnt/flutter_star_prnt-Swift.h>)
#import <flutter_star_prnt/flutter_star_prnt-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_star_prnt-Swift.h"
#import <StarIO/SMPortSwift.h>
#import <StarIO_Extension/StarIoExt.h>
#import <StarIO_Extension/StarIoExtManager.h>
#endif

@implementation FlutterStarPrntPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterStarPrntPlugin registerWithRegistrar:registrar];
}
@end
