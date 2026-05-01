//
//  SwiftTryCatch.m — vendored from williamFalcon/SwiftTryCatch (MIT).
//  See SwiftTryCatch.h for why this lives in-tree.
//

#import "SwiftTryCatch.h"

@implementation SwiftTryCatch

+ (void)try:(__attribute__((noescape)) void(^ _Nullable)(void))try
      catch:(__attribute__((noescape)) void(^ _Nullable)(NSException* _Nullable exception))catch
    finally:(__attribute__((noescape)) void(^ _Nullable)(void))finally {
    @try {
        if (try != NULL) try();
    }
    @catch (NSException *exception) {
        if (catch != NULL) catch(exception);
    }
    @finally {
        if (finally != NULL) finally();
    }
}

+ (void)throwString:(NSString*)s {
    @throw [NSException exceptionWithName:s reason:s userInfo:nil];
}

+ (void)throwException:(NSException*)e {
    @throw e;
}

@end
