#import "FclFlutterPlugin.h"
#if __has_include(<fcl_flutter/fcl_flutter-Swift.h>)
#import <fcl_flutter/fcl_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "fcl_flutter-Swift.h"
#endif

@implementation FclFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFclFlutterPlugin registerWithRegistrar:registrar];
}
@end
