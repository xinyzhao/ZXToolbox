//
// UIApplication+ZXToolbox.h
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2018 Zhao Xin
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
/// 兼容 iOS 13/15 多窗口
@property (class, nonatomic, readonly, nullable) UIWindow *keyWindow;
/// 安全区域
@property (class, nonatomic, readonly) UIEdgeInsets safeAreaInsets;
/// 状态栏高度
@property (class, nonatomic, readonly) CGFloat statusBarHeight;

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

/**
 @brief 检查两个方向掩码是否兼容
 @discussion Check the two masks are compatible or not.
 @param mask1 UIInterfaceOrientationMask
 @param mask2 UIInterfaceOrientationMask
 @note 应用案例：解决 iOS 13 竖屏 viewController  push 横屏 viewController 出现的问题
 @code
 /// 竖屏 UIViewController，supportedInterfaceOrientations 包含 UIInterfaceOrientationMaskPortrait/UIInterfaceOrientationMaskPortraitUpsideDown
 UIViewController *pvc = [[UIViewController alloc] init];
 /// 横屏 UIViewController，supportedInterfaceOrientations 包含 UIInterfaceOrientationMaskLandscapeLeft/UIInterfaceOrientationMaskLandscapeRight
 UIViewController *hvc = [[UIViewController alloc] init];
 /// iOS 13 竖屏 Push 横屏 UIViewController，如果双方支持的方向不兼容，会在返回竖屏时出现无法消失的问题，改用present的方式
 double ver = UIDevice.currentDevice.systemVersion.doubleValue;
 if (ver >= 13.0 && ver < 14.0 && !UIInterfaceOrientationMaskCompatible(pvc.supportedInterfaceOrientations, hvc.supportedInterfaceOrientations) {
    [pvc presentViewController:hvc animated:YES completion:nil];
 } else {
    [pvc.navigationController pushViewController:hvc animated:YES];
 }
 @endcode
*/
UIKIT_EXTERN BOOL UIInterfaceOrientationMaskCompatible(UIInterfaceOrientationMask mask1, UIInterfaceOrientationMask mask2);

NS_ASSUME_NONNULL_END
