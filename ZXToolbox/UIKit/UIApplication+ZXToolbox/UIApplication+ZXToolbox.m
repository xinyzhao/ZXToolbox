//
// UIApplication+ZXToolbox.m
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

#import "UIApplication+ZXToolbox.h"
#import <objc/runtime.h>

@interface UIApplication ()
@property (nonatomic, assign) NSNumber *idleTimerDisabledSaved;
@property (nonatomic, strong) id willResignActiveObserver;
@property (nonatomic, strong) id didEnterBackgroundObserver;
@property (nonatomic, strong) id willEnterForegroundObserver;
@property (nonatomic, strong) id didBecomeActiveObserver;

@end

@implementation UIApplication (ZXToolbox)

+ (UIWindow *)keyWindow {
    UIWindow *window = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindow *win in [UIApplication sharedApplication].windows) {
            if (win.isKeyWindow) {
                window = win;
                break;
            }
        }
    } else {
        window = [UIApplication sharedApplication].keyWindow;
    }
    return window;
}

+ (UIEdgeInsets)safeAreaInsets {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    UIViewController *vc = UIApplication.keyWindow.rootViewController;
    if (vc) {
        if (@available(iOS 11.0, *)) {
            insets = vc.view.safeAreaInsets;
        } else {
            insets.top = vc.topLayoutGuide.length;
            insets.bottom = vc.bottomLayoutGuide.length;
        }
    }
    return insets;
}

- (BOOL)openSettingsURL {
    NSURL *url = nil;
    if(@available(iOS 8.0, *)) {
        url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    } else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"prefs:root==%@", [NSBundle mainBundle].infoDictionary[@"CFBundleIdentifier"]]];
    }
    if([self canOpenURL:url]) {
        return [self openURL:url];
    }
    return NO;
}

- (void)resetBageNumber {
    if(@available(iOS 11.0, *)) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = -1;
    } else {
        UILocalNotification *clearEpisodeNotification = [[UILocalNotification alloc] init];
        clearEpisodeNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:(0.3)];
        clearEpisodeNotification.timeZone = [NSTimeZone defaultTimeZone];
        clearEpisodeNotification.applicationIconBadgeNumber = -1;
        [[UIApplication sharedApplication] scheduleLocalNotification:clearEpisodeNotification];
    }
}

- (void)exitWithCode:(int)code afterDelay:(double)delay {
    [[UIApplication sharedApplication] performSelector:@selector(suspend)];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        exit(0);
    });
}

#pragma mark NetworkActivityIndicator

- (void)setNetworkActivityIndicatorCount:(NSUInteger)networkActivityIndicatorCount {
    objc_setAssociatedObject(self, @selector(networkActivityIndicatorCount), @(networkActivityIndicatorCount), OBJC_ASSOCIATION_ASSIGN);
    self.networkActivityIndicatorVisible = networkActivityIndicatorCount > 0;
}

- (NSUInteger)networkActivityIndicatorCount {
    NSNumber *number = objc_getAssociatedObject(self, @selector(networkActivityIndicatorCount));
    return [number integerValue];
}

#pragma mark IdleTimer

- (NSNumber *)idleTimerDisabledSaved {
    return objc_getAssociatedObject(self, @selector(idleTimerDisabledSaved));
}

- (void)setIdleTimerDisabledSaved:(NSNumber *)idleTimerDisabledSaved {
    objc_setAssociatedObject(self, @selector(idleTimerDisabledSaved), idleTimerDisabledSaved, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)willResignActiveObserver {
    return objc_getAssociatedObject(self, @selector(willResignActiveObserver));
}

- (void)setWillResignActiveObserver:(id)willResignActiveObserver {
    objc_setAssociatedObject(self, @selector(willResignActiveObserver), willResignActiveObserver, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)didEnterBackgroundObserver {
    return objc_getAssociatedObject(self, @selector(didEnterBackgroundObserver));
}

- (void)setDidEnterBackgroundObserver:(id)didEnterBackgroundObserver {
    objc_setAssociatedObject(self, @selector(didEnterBackgroundObserver), didEnterBackgroundObserver, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)willEnterForegroundObserver {
    return objc_getAssociatedObject(self, @selector(willEnterForegroundObserver));
}

- (void)setWillEnterForegroundObserver:(id)willEnterForegroundObserver {
    objc_setAssociatedObject(self, @selector(willEnterForegroundObserver), willEnterForegroundObserver, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)didBecomeActiveObserver {
    return objc_getAssociatedObject(self, @selector(didBecomeActiveObserver));
}

- (void)setDidBecomeActiveObserver:(id)didBecomeActiveObserver {
    objc_setAssociatedObject(self, @selector(didBecomeActiveObserver), didBecomeActiveObserver, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)idleTimerEnabled {
    NSNumber *number = objc_getAssociatedObject(self, @selector(idleTimerEnabled));
    return [number boolValue];
}

- (void)setIdleTimerEnabled:(BOOL)idleTimerEnabled {
    if (self.idleTimerDisabledSaved == nil) {
        self.idleTimerDisabledSaved = @(self.idleTimerDisabled);
    }
    //
    objc_setAssociatedObject(self, @selector(idleTimerEnabled), @(idleTimerEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.idleTimerDisabled = !idleTimerEnabled;
    //
    __weak typeof(self) weakSelf = self;
    if (self.willResignActiveObserver == nil) {
        self.willResignActiveObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            BOOL idleTimerDisabled = [weakSelf.idleTimerDisabledSaved boolValue];
            if (weakSelf.idleTimerDisabled != idleTimerDisabled) {
                weakSelf.idleTimerDisabled = idleTimerDisabled;
            }
            weakSelf.idleTimerDisabledSaved = nil;
        }];
    }
    if (self.didEnterBackgroundObserver == nil) {
        self.didEnterBackgroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            BOOL idleTimerDisabled = [weakSelf.idleTimerDisabledSaved boolValue];
            if (weakSelf.idleTimerDisabled != idleTimerDisabled) {
                weakSelf.idleTimerDisabled = idleTimerDisabled;
            }
            weakSelf.idleTimerDisabledSaved = nil;
        }];
    }
    if (self.willEnterForegroundObserver == nil) {
        self.willEnterForegroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if (weakSelf.idleTimerDisabledSaved == nil) {
                weakSelf.idleTimerDisabledSaved = @(weakSelf.idleTimerDisabled);
            }
            if (weakSelf.idleTimerDisabled == weakSelf.idleTimerEnabled) {
                weakSelf.idleTimerDisabled = !weakSelf.idleTimerEnabled;
            }
        }];
    }
    if (self.didBecomeActiveObserver == nil) {
        self.didBecomeActiveObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if (weakSelf.idleTimerDisabledSaved == nil) {
                weakSelf.idleTimerDisabledSaved = @(weakSelf.idleTimerDisabled);
            }
            if (weakSelf.idleTimerDisabled == weakSelf.idleTimerEnabled) {
                weakSelf.idleTimerDisabled = !weakSelf.idleTimerEnabled;
            }
        }];
    }
}

@end
