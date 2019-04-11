//
// ZXPlayerViewController.m
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

#import "ZXPlayerViewController.h"
#import "UIViewController+ZXToolbox.h"
#import "NSObject+ZXToolbox.h"

@implementation ZXPlayerViewController

- (instancetype)initWithURL:(NSURL *)URL {
    self = [super init];
    if (self) {
        self.player = [ZXPlayer playerWithURL:URL];
        [self.player attachToView:self.view];
    }
    return self;
}

- (void)dealloc {
    [self.player stop];
    [self.player detach];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _shouldAutorotate = YES;
    _supportedInterfaceOrientations = UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Orientation

- (BOOL)shouldAutorotate {
    return _shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return _supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
    if (_supportedInterfaceOrientations & UIInterfaceOrientationMaskPortrait) {
        orientation = UIInterfaceOrientationPortrait;
    } else if (_supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeLeft) {
        orientation = UIInterfaceOrientationLandscapeLeft;
    } else if (_supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeRight) {
        orientation = UIInterfaceOrientationLandscapeRight;
    } else if (_supportedInterfaceOrientations & UIInterfaceOrientationMaskPortraitUpsideDown) {
        orientation = UIInterfaceOrientationPortraitUpsideDown;
    }
    //
    if (_shouldAutorotate) {
        switch ([UIDevice currentDevice].orientation) {
            case UIDeviceOrientationPortrait:
                if (_supportedInterfaceOrientations & UIInterfaceOrientationMaskPortrait) {
                    orientation = UIInterfaceOrientationPortrait;
                }
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                if (_supportedInterfaceOrientations & UIInterfaceOrientationMaskPortraitUpsideDown) {
                    orientation = UIInterfaceOrientationPortraitUpsideDown;
                }
                break;
            case UIDeviceOrientationLandscapeLeft:
                if (_supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeLeft) {
                    orientation = UIInterfaceOrientationLandscapeLeft;
                }
                break;
            case UIDeviceOrientationLandscapeRight:
                if (_supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeRight) {
                    orientation = UIInterfaceOrientationLandscapeRight;
                }
                break;
            default:
                break;
        }
    }
    //
    return orientation;
}

@end

#pragma mark - UIApplication (ZXPlayerViewController)

@interface UIApplication (ZXPlayerViewController)

@end

@implementation UIApplication (ZXPlayerViewController)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleMethod:@selector(supportedInterfaceOrientationsForWindow:) with:@selector(supportedInterfaceOrientationsForPlayerViewController:)];
    });
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientationsForPlayerViewController:(nullable UIWindow *)window {
    if ([window.rootViewController.topmostViewController isKindOfClass:[ZXPlayerViewController class]]) {
        return window.rootViewController.topmostViewController.supportedInterfaceOrientations;
    }
    return [self supportedInterfaceOrientationsForPlayerViewController:window];
}

@end
