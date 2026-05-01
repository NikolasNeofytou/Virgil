//
//  SwiftTryCatch.h — vendored from williamFalcon/SwiftTryCatch (MIT)
//  with NS_SWIFT_NAME added so the +try:catch:finally: method is
//  visible to Swift (the keyword `try` is otherwise dropped by the
//  Obj-C → Swift importer). This vendor exists because the trunk
//  CocoaPod points to github.com/cfr/SwiftTryCatch which is dead, and
//  flutter_dynamic_icon_plus depends on it. See app/ios/Podfile.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SwiftTryCatch : NSObject

+ (void)try:(__attribute__((noescape))  void(^ _Nullable)(void))try
      catch:(__attribute__((noescape)) void(^ _Nullable)(NSException* _Nullable exception))catch
    finally:(__attribute__((noescape)) void(^ _Nullable)(void))finally
NS_SWIFT_NAME(try(_:catch:finally:));

+ (void)throwString:(NSString*)s;
+ (void)throwException:(NSException*)e;

@end

NS_ASSUME_NONNULL_END
