//
// UIApplication+ZXToolbox.h
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

@interface UIApplication (ZXToolbox)
/// for iOS 13
@property (class, nonatomic, readonly, nullable) UIWindow *keyWindow;
/// 安全区域
@property (class, nonatomic, readonly) UIEdgeInsets safeAreaInsets;

/// 打开应用设置界面，成功则返回YES，否则为NO
- (BOOL)openSettingsURL;

/// 重置APP角标数量，并且保留系统通知栏内的推送通知
/// 注意：iOS8之后，必须在使用前注册用户通知 -[UIApplication registerUserNotificationSettings:]
- (void)resetBageNumber;

/// 退出应用，有挂起动画，如果不需要动画，请直接调用exit(0)
/// @param code 退出代码
/// @param delay 为挂起动画预留的延迟时间，推荐0.5秒
- (void)exitWithCode:(int)code afterDelay:(double)delay;

/// 状态栏网络活动指示器数量，大于0显示，小于等于0隐藏
@property (nonatomic, assign) NSUInteger networkActivityIndicatorCount;

/// 设置为真自动锁屏，假则保持常亮，应用不活跃时重置为原有值
@property (nonatomic, assign) BOOL idleTimerEnabled;

@end

NS_ASSUME_NONNULL_END
