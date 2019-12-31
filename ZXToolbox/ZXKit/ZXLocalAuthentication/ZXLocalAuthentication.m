//
// ZXLocalAuthentication.m
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2019-2020 Zhao Xin
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "ZXLocalAuthentication.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@implementation ZXLocalAuthentication

+ (LABiometryType)biometryType {
    if (@available(iOS 11.0, *)) {
        NSError *error = nil;
        LAContext *context = [[LAContext alloc] init];
        LAPolicy policy = LAPolicyDeviceOwnerAuthenticationWithBiometrics;
        if ([context canEvaluatePolicy:policy error:&error]) {
            if (error == nil) {
                return context.biometryType;
            }
        }
    }
    if (@available(iOS 11.2, *)) {
        return LABiometryTypeNone;
    }
    return LABiometryNone;
}

+ (BOOL)canEvaluatePolicy:(LAPolicy)policy {
    if (@available(iOS 8.0, *)) {
        NSError *error = nil;
        LAContext *context = [[LAContext alloc] init];
        if ([context canEvaluatePolicy:policy error:&error]) {
            return error == nil;
        }
    }
    return NO;
}

+ (void)evaluatePolicy:(LAPolicy)policy reason:(NSString *)reason reply:(void(^)(BOOL success, NSError * __nullable error))reply {
    NSError *error = nil;
    //
    if (@available(iOS 8.0, *)) {
        LAContext *context = [[LAContext alloc] init];
        if ([context canEvaluatePolicy:policy error:&error]) {
            if (error == nil) {
                [context evaluatePolicy:policy localizedReason:reason reply:^(BOOL success, NSError * _Nullable error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (reply) {
                            reply(success, error);
                            return;
                        }
                    });
                }];
                return;
            }
        }
    }
    //
    if (error == nil) {
        NSInteger code = LAErrorTouchIDNotAvailable;
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"Authentication could not start, because Touch ID is not available on the device."};
        if (@available(iOS 11.0, *)) {
            code = LAErrorBiometryNotAvailable;
            userInfo = @{NSLocalizedDescriptionKey:@"Authentication could not start, because biometry is not available on the device."};
        }
        if (@available(iOS 8.3, *)) {
            error = [NSError errorWithDomain:LAErrorDomain code:code userInfo:userInfo];
        } else {
            error = [NSError errorWithDomain:@"com.apple.LocalAuthentication" code:code userInfo:userInfo];
        }
    }
    //
    if (reply) {
        reply(NO, error);
    }
}

@end

#pragma clang diagnostic pop
