//
// ZXURLRouter.h
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2022 Zhao Xin
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// A router with URL
@interface ZXURLRouter : NSObject

/// Default shared router
+ (instancetype)sharedRouter;

/// If YES, a URL or global can be only one handler or target/aciton, add multiple handler or target/action will failed.
/// Otherwise, you can add multiple handlers or target/aciton for a URL/global. Default is NO.
@property (nonatomic, assign, getter=isExclusiveRoute) BOOL exclusiveRoute;

/// Add handler for URL
/// @param handler The handler for URL
/// @param url The URL, add a global handler if pass in nil.
/// @return Return a no zero integer value if add succeeds, otherwise is 0.
- (NSUInteger)addHandler:(id _Nullable(^)(NSURL *url, id _Nullable data))handler forURL:(nullable NSURL *)url;

/// Remove handler for URL
/// @param handler The handler id
/// @param url The URL, remvoe the global handler if pass in nil.
- (void)removeHandler:(NSUInteger)handler forURL:(nullable NSURL *)url;

/// Add target and action for URL
/// @param target The target
/// @param action If the selector has parameters, the first is the URL and the second is userData.
/// @param url The URL, add a global target/action if pass in nil.
- (BOOL)addTarget:(id)target action:(SEL)action forURL:(nullable NSURL *)url;

/// remove the target/action for a set of URL.
/// @param target The target
/// @param action If pass in NULL for the action to remove all actions for that target
/// @param url The URL, remvoe the global target/action if pass in nil.
- (void)removeTarget:(id)target action:(nullable SEL)action forURL:(nullable NSURL *)url;

/// Return a Boolean value that indicates whether this router is available to handle a URL.
/// @param url The URL
- (BOOL)canOpenURL:(NSURL *)url;

/// Open the URL with data
/// @param url The URL
/// @param data The data, eg. params etc.
/// @param completionHandler The handler for completion
- (int)openURL:(NSURL *)url withData:(nullable id)data completionHandler:(void (^ _Nullable)(NSURL *url, id _Nullable data, id _Nullable response, NSString * _Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
