//
// UIViewController+ZXToolbox.m
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

#import "UIViewController+ZXToolbox.h"

@implementation UIViewController (ZXToolbox)

- (UIViewController *)topVisibleViewController {
    if (self.presentedViewController) {
        return [self.presentedViewController topVisibleViewController];
    } else if ([self isKindOfClass:[UITabBarController class]]) {
        UIViewController *vc = ((UITabBarController *)self).selectedViewController;
        if (vc) {
            return [vc topVisibleViewController];
        }
    } else if ([self isKindOfClass:[UINavigationController class]]) {
        UIViewController *vc = ((UINavigationController *)self).topViewController;
        if (vc) {
            return [vc topVisibleViewController];
        }
    }
    return self;
}

/**
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 动画显示/隐藏 状态栏
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
        [self setNeedsStatusBarAppearanceUpdate];
    }];
    // 显示/隐藏 导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    // 自定导航栏颜色
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    // 导航栏透明并取消分隔线
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    // 设置设备方向
    //[UIApplication sharedApplication].delegate.supportedInterfaceOrientations = UIInterfaceOrientationMaskLandscape;
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInt:UIDeviceOrientationUnknown] forKey:@"orientation"];
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInt:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
    // 同步设备方向
    [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
    [UIViewController attemptRotationToDeviceOrientation];
}

#pragma mark - Status Bar

- (BOOL)prefersStatusBarHidden {
    return NO; // 显示/隐藏 状态栏
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

#pragma mark - Orientations

- (BOOL)shouldAutorotate {
    // 1) [UIApplication sharedApplication].delegate.supportedInterfaceOrientations = UIInterfaceOrientationMaskLandscape;
    // 2) [other presentViewController:this animated:YES completion:nil];
    // 3) return NO;
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    // 4) supported orientations
    return UIInterfaceOrientationMaskLandscape;
}
*/

@end
