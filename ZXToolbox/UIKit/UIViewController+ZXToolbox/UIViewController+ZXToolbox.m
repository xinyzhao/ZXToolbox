//
// UIViewController+ZXToolbox.m
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

#import "UIViewController+ZXToolbox.h"
#import <objc/runtime.h>

@implementation UIViewController (ZXToolbox)

- (void)setZx_topLayoutView:(UIView *)topLayoutView {
    objc_setAssociatedObject(self, @selector(zx_topLayoutView), topLayoutView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)zx_topLayoutView {
    UIView *view = objc_getAssociatedObject(self, @selector(zx_topLayoutView));
    if (view == nil) {
        view = [[UIView alloc] initWithFrame:CGRectZero];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:view];
        //
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [self.view addConstraints:@[left, right, top, bottom]];
        //
        self.zx_topLayoutView = view;
    }
    return view;
}

- (void)setZx_bottomLayoutView:(UIView *)bottomLayoutView {
    objc_setAssociatedObject(self, @selector(zx_bottomLayoutView), bottomLayoutView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)zx_bottomLayoutView {
    UIView *view = objc_getAssociatedObject(self, @selector(zx_bottomLayoutView));
    if (view == nil) {
        view = [[UIView alloc] initWithFrame:CGRectZero];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:view];
        //
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.bottomLayoutGuide attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [self.view addConstraints:@[left, right, top, bottom]];
        //
        self.zx_bottomLayoutView = view;
    }
    return view;
}

#pragma mark View Controller

- (UIViewController *)zx_topViewController {
    UIViewController *vc = self;
    if ([self isKindOfClass:[UITabBarController class]]) {
        vc = ((UITabBarController *)self).selectedViewController;
        vc = [vc zx_topViewController];
    } else if ([self isKindOfClass:[UINavigationController class]]) {
        vc = ((UINavigationController *)self).topViewController;
        vc = [vc zx_topViewController];
    } else if (self.presentingViewController) {
        vc = self.presentingViewController;
        vc = [vc zx_topViewController];
    }
    return vc;
}

- (UIViewController *)zx_visibleViewController {
    UIViewController *vc = self;
    if ([self isKindOfClass:[UITabBarController class]]) {
        vc = ((UITabBarController *)self).selectedViewController;
        vc = [vc zx_visibleViewController];
    } else if ([self isKindOfClass:[UINavigationController class]]) {
        vc = ((UINavigationController *)self).topViewController;
        vc = [vc zx_visibleViewController];
    } else if (self.presentedViewController) {
        if ([self.presentedViewController isBeingDismissed] ||
            [self.presentedViewController isMovingFromParentViewController]) {
            return self;
        }
        vc = self.presentedViewController;
        vc = [vc zx_visibleViewController];
    }
    return vc;
}

#pragma mark Target Actions

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    return NO; // 显示/隐藏 状态栏
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}*/

@end
