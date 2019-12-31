//
// ZXLocalAuthentication.h
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

#import <LocalAuthentication/LocalAuthentication.h>

NS_ASSUME_NONNULL_BEGIN

NS_CLASS_AVAILABLE(10_10, 8_0) __WATCHOS_AVAILABLE(3.0) __TVOS_AVAILABLE(10.0)
@interface ZXLocalAuthentication : NSObject

/// Indicates the type of the biometry supported by the device.
@property (class, readonly) LABiometryType biometryType API_AVAILABLE(macos(10.13.2), ios(11.0)) API_UNAVAILABLE(watchos, tvos);

/**
 Determines if a particular policy can be evaluated.

 @param policy Policy for which the preflight check should be run.
 @return YES if the policy can be evaluated, NO otherwise.
 */
+ (BOOL)canEvaluatePolicy:(LAPolicy)policy;

/**
 Evaluates the specified policy.

 @param policy Policy to be evaluated.
 @param reason Application reason for authentication.
 @param reply Reply block that is executed when policy evaluation finishes.
 @warning Applications should also supply NSFaceIDUsageDescription key in the Info.plist.
 */
+ (void)evaluatePolicy:(LAPolicy)policy reason:(NSString *)reason reply:(void(^)(BOOL success, NSError * __nullable error))reply;

@end

NS_ASSUME_NONNULL_END
