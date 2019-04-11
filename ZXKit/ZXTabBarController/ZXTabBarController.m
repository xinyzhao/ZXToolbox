//
// ZXTabBarController.m
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

#import "ZXTabBarController.h"

@interface ZXTabBarController ()

@end

@implementation ZXTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // view controllers
    NSMutableArray *viewControllers = [NSMutableArray array];
    [self.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIViewController *vc = obj;
        if ([obj isKindOfClass:[ZXTabBarItemController class]]) {
            ZXTabBarItemController *item = obj;
            if (item.storyboardName) {
                UIStoryboard *sb = [UIStoryboard storyboardWithName:item.storyboardName bundle:nil];
                if (item.storyboardID) {
                    vc = [sb instantiateViewControllerWithIdentifier:item.storyboardID];
                } else {
                    vc = [sb instantiateInitialViewController];
                }
                vc.tabBarItem = item.tabBarItem;
            }
        }
        [viewControllers addObject:vc];
    }];
    [self setViewControllers:viewControllers animated:NO];
    
    // tabBar
    if (_selectedItemColor) {
        self.tabBar.tintColor = _selectedItemColor;
    }
    
    // tabBar items
    if (_originalItemImage) {
        [self.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.image = [obj.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            obj.selectedImage = [obj.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@implementation ZXTabBarItemController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


@implementation UITabBarController (SetSelectedAnimated)

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated {
    if (animated && selectedIndex != self.selectedIndex) {
        NSTimeInterval duration = 0.5f;
        NSUInteger options = UIViewAnimationOptionTransitionCrossDissolve;
        if (self.selectedIndex < selectedIndex) {
            options = UIViewAnimationOptionTransitionFlipFromLeft;
        } else if (self.selectedIndex > selectedIndex) {
            options = UIViewAnimationOptionTransitionFlipFromRight;
        }
        [self setSelectedIndex:selectedIndex duration:duration options:options completion:nil];
    } else {
        [self setSelectedIndex:selectedIndex];
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options completion:(void (^)(BOOL finished))completion {
    if (duration > 0.f && selectedIndex != self.selectedIndex) {
        __weak typeof(self) weakSelf = self;
        UIView *fromView = [self.selectedViewController view];
        UIView *toView = [[self.viewControllers objectAtIndex:selectedIndex] view];
        [UIView transitionFromView:fromView toView:toView duration:duration options:options completion:^(BOOL finished) {
            if (finished) {
                [weakSelf setSelectedIndex:selectedIndex];
            }
            if (completion) {
                completion(finished);
            }
        }];
    } else {
        [self setSelectedIndex:selectedIndex];
        if (completion) {
            completion(YES);
        }
    }
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController animated:(BOOL)animated {
    if (animated && selectedViewController != self.selectedViewController) {
        __block NSUInteger selectedIndex = self.selectedIndex;
        [self.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj == selectedViewController) {
                selectedIndex = idx;
                *stop = YES;
            }
        }];
        NSTimeInterval duration = 0.5f;
        NSUInteger options = UIViewAnimationOptionTransitionCrossDissolve;
        if (self.selectedIndex < selectedIndex) {
            options = UIViewAnimationOptionTransitionFlipFromLeft;
        } else if (self.selectedIndex > selectedIndex) {
            options = UIViewAnimationOptionTransitionFlipFromRight;
        }
        [self setSelectedViewController:selectedViewController duration:duration options:options completion:nil];
    } else {
        [self setSelectedViewController:selectedViewController];
    }
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options completion:(void (^)(BOOL finished))completion {
    if (duration > 0.f && selectedViewController != self.selectedViewController) {
        __weak typeof(self) weakSelf = self;
        UIView *fromView = [self.selectedViewController view];
        UIView *toView = [selectedViewController view];
        [UIView transitionFromView:fromView toView:toView duration:duration options:options completion:^(BOOL finished) {
            if (finished) {
                [weakSelf setSelectedViewController:selectedViewController];
            }
            if (completion) {
                completion(finished);
            }
        }];
    } else {
        [self setSelectedViewController:selectedViewController];
        if (completion) {
            completion(YES);
        }
    }
}

@end
