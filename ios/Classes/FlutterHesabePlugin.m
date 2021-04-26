#import "FlutterHesabePlugin.h"
#import <flutter_hesabe_payment/flutter_hesabe_payment-Swift.h>

@implementation FlutterHesabePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterHesabePlugin registerWithRegistrar:registrar];
}
@end