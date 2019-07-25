//
// UIViewController+ZXToolbox.m
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2019 Zhao Xin
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

- (void)setTopLayoutView:(UIView *)topLayoutView {
    objc_setAssociatedObject(self, @selector(topLayoutView), topLayoutView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)topLayoutView {
    UIView *view = objc_getAssociatedObject(self, @selector(topLayoutView));
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
        self.topLayoutView = view;
    }
    return view;
}

- (void)setBottomLayoutView:(UIView *)bottomLayoutView {
    objc_setAssociatedObject(self, @selector(bottomLayoutView), bottomLayoutView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)bottomLayoutView {
    UIView *view = objc_getAssociatedObject(self, @selector(bottomLayoutView));
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
        self.bottomLayoutView = view;
    }
    return view;
}

#pragma mark - Back Bar Button Item

- (void)setBackItemImage:(UIImage *)image {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image
                                                                             style:self.navigationItem.backBarButtonItem.style
                                                                            target:self
                                                                            action:@selector(onBack:)];
}

- (void)setBackItemImage:(UIImage *)image title:(NSString *)title {
    //
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.tintColor = self.navigationController.navigationBar.tintColor;
    button.titleLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName:button.titleLabel.font}];
    button.frame = CGRectMake(0, 0, size.width + image.size.width, self.navigationController.navigationBar.frame.size.height);
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:button.tintColor forState:UIControlStateNormal];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    [button setImage:image forState:UIControlStateNormal];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    [button addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    //
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)setBackItemTitle:(NSString *)title {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title
                                                                             style:self.navigationItem.backBarButtonItem.style
                                                                            target:self
                                                                            action:@selector(onBack:)];
}

- (void)setBackItemTarget:(id)target action:(SEL)action {
    if ([self.navigationItem.leftBarButtonItem.customView isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)self.navigationItem.leftBarButtonItem.customView;
        [button.allTargets enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
            id target = obj;
            NSArray *actions = [button actionsForTarget:obj forControlEvent:UIControlEventTouchUpInside];
            [actions enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                SEL action = NSSelectorFromString(obj);
                [button removeTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
            }];
        }];
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    } else {
        self.navigationItem.leftBarButtonItem.target = target;
        self.navigationItem.leftBarButtonItem.action = action;
    }
}

- (void)setBackItemTintColor:(UIColor *)color {
    if ([self.navigationItem.leftBarButtonItem.customView isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)self.navigationItem.leftBarButtonItem.customView;
        button.tintColor = color;
        [button setTitleColor:button.tintColor forState:UIControlStateNormal];
    } else {
        self.navigationItem.leftBarButtonItem.tintColor = color;
    }
}

- (void)setBackItemTitleFont:(UIFont *)font {
    if ([self.navigationItem.leftBarButtonItem.customView isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)self.navigationItem.leftBarButtonItem.customView;
        button.titleLabel.font = font;
    }
}

#pragma mark - Title

- (void)setTitleFont:(UIFont *)font {
    NSMutableDictionary *attributes = [self.navigationController.navigationBar.titleTextAttributes mutableCopy];
    if (font) {
        if (attributes == nil) {
            attributes = [NSMutableDictionary dictionary];
        }
        [attributes setObject:font forKey:NSFontAttributeName];
    } else if (attributes) {
        [attributes removeObjectForKey:NSFontAttributeName];
    }
    self.navigationController.navigationBar.titleTextAttributes = attributes;
}

- (void)setTitleColor:(UIColor *)color {
    NSMutableDictionary *attributes = [self.navigationController.navigationBar.titleTextAttributes mutableCopy];
    if (color) {
        if (attributes == nil) {
            attributes = [NSMutableDictionary dictionary];
        }
        [attributes setObject:color forKey:NSForegroundColorAttributeName];
    } else if (attributes) {
        [attributes removeObjectForKey:NSForegroundColorAttributeName];
    }
    self.navigationController.navigationBar.titleTextAttributes = attributes;
}

#pragma mark View Controller

- (UIViewController *)topViewController {
    return [self endViewController];
}

- (UIViewController *)visibleViewController {
    return [self topmostViewController];
}

- (UIViewController *)endViewController {
    UIViewController *vc = self;
    if ([self isKindOfClass:[UITabBarController class]]) {
        vc = ((UITabBarController *)self).selectedViewController;
        vc = [vc endViewController];
    } else if ([self isKindOfClass:[UINavigationController class]]) {
        vc = ((UINavigationController *)self).topViewController;
        vc = [vc endViewController];
    } else if (self.presentingViewController) {
        vc = self.presentingViewController;
        vc = [vc endViewController];
    }
    return vc;
}

- (UIViewController *)topmostViewController {
    UIViewController *vc = self;
    if ([self isKindOfClass:[UITabBarController class]]) {
        vc = ((UITabBarController *)self).selectedViewController;
        vc = [vc topmostViewController];
    } else if ([self isKindOfClass:[UINavigationController class]]) {
        vc = ((UINavigationController *)self).topViewController;
        vc = [vc topmostViewController];
    } else if (self.presentedViewController) {
        if ([self.presentedViewController isBeingDismissed] ||
            [self.presentedViewController isMovingFromParentViewController]) {
            return self;
        }
        vc = self.presentedViewController;
        vc = [vc topmostViewController];
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
    // 显示/隐藏 状态栏
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
    // 只显示文字
    [self setBackItemTitle:@"返回"];
    // 只显示图标
    [self setBackItemImage:[UIImage imageNamed:@"返回按钮"]];
    // 显示图标和文字
    [self setBackItemImage:[UIImage imageNamed:@"返回按钮"] title:@"返回"];
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

@implementation UINavigationController (ZXToolbox)

- (UIViewController *)prevViewController {
    if (self.topViewController) {
        NSInteger index = [self.viewControllers indexOfObject:self.topViewController] - 1;
        if (index >= 0) {
            return self.viewControllers[index];
        }
    }
    return nil;
}

- (UIViewController *)rootViewController {
    return [self.viewControllers firstObject];
}

@end
