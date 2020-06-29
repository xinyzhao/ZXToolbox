//
// UINavigationController+ZXToolbox.h
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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (ZXToolbox)

/// The previous viewController
@property(nonatomic, readonly, nullable) UIViewController *prevViewController;

/// The root viewController
@property(nonatomic, readonly, nullable) UIViewController *rootViewController;

/// Pops view controllers until the specified class of view controller is at the top of the navigation stack.
/// @param aClass The view controller class that you want to be at the top of the stack.
/// @param animated Set this value to YES to animate the transition. Pass NO if you are setting up a navigation controller before its view is displayed.
- (nullable NSArray<__kindof UIViewController *> *)popToViewControllerForClass:(Class)aClass animated:(BOOL)animated;

/// Get first view controller for specified class in the navigation stack.
/// @param aClass The view controller class that you want to be remove of the stack.
- (nullable __kindof UIViewController *)firstViewControllerForClass:(Class)aClass;

/// Get last view controller for specified class in the navigation stack.
/// @param aClass The view controller class that you want to be remove of the stack.
- (nullable __kindof UIViewController *)lastViewControllerForClass:(Class)aClass;

@end

NS_ASSUME_NONNULL_END
