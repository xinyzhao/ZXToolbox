//
// UIApplication+ZXToolbox.m
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

#import "UIApplication+ZXToolbox.h"
#import "NSObject+ZXToolbox.h"

static char networkActivityIndicatorCountKey;
static char idleTimerDisabledSavedKey;
static char willResignActiveObserverKey;
static char didEnterBackgroundObserverKey;
static char willEnterForegroundObserverKey;
static char didBecomeActiveObserverKey;
static char idleTimerEnabledKey;

@interface UIApplication ()
@property (nonatomic, assign) NSNumber *idleTimerDisabledSaved;
@property (nonatomic, strong) id willResignActiveObserver;
@property (nonatomic, strong) id didEnterBackgroundObserver;
@property (nonatomic, strong) id willEnterForegroundObserver;
@property (nonatomic, strong) id didBecomeActiveObserver;

@end

@implementation UIApplication (ZXToolbox)

+ (UIWindow *)keyWindow {
    UIApplication *app = [UIApplication sharedApplication];
    if (@available(iOS 15.0, *)) {
        NSArray<UIScene *> *scenes = app.connectedScenes.allObjects;
        /// Active and keyWindow
        for (UIScene *scene in scenes) {
            if ([scene isKindOfClass:UIWindowScene.class]) {
                UIWindowScene *ws = (UIWindowScene *)scene;
                if (ws.activationState == UISceneActivationStateForegroundActive) {
                    if (ws.keyWindow) {
                        return ws.keyWindow;
                    }
                }
            }
        }
        /// The keyWindow
        for (UIScene *scene in scenes) {
            if ([scene isKindOfClass:UIWindowScene.class]) {
                UIWindowScene *ws = (UIWindowScene *)scene;
                if (ws.keyWindow) {
                    return ws.keyWindow;
                }
            }
        }
        /// The last window
        for (UIScene *scene in scenes) {
            if ([scene isKindOfClass:UIWindowScene.class]) {
                UIWindowScene *ws = (UIWindowScene *)scene;
                if (ws.windows.count > 0) {
                    return ws.windows.lastObject;
                }
            }
        }
    } else if (@available(iOS 13.0, *)) {
        /// The keyWindow
        for (UIWindow *win in app.windows) {
            if (win.isKeyWindow) {
                return win;
            }
        }
        /// The first window
        return app.windows.firstObject;
    } else {
        if (app.keyWindow) {
            return app.keyWindow;
        }
        return app.windows.firstObject;
    }
    return nil;
}

+ (UIEdgeInsets)safeAreaInsets {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    UIWindow *window = UIApplication.keyWindow;
    if (window) {
        if (@available(iOS 11.0, *)) {
            insets = window.safeAreaInsets;
        } else {
            UIViewController *vc = window.rootViewController;
            if (vc) {
                insets.top = vc.topLayoutGuide.length;
                insets.bottom = vc.bottomLayoutGuide.length;
            }
        }
    }
    return insets;
}

- (CGFloat)statusBarHeight {
    if (@available(iOS 13.0, *)) {
        UIScene *scene = [UIApplication sharedApplication].connectedScenes.anyObject;
        if ([scene isKindOfClass:UIWindowScene.class]) {
            UIWindowScene *ws = (UIWindowScene *)scene;
            if (ws) {
                return ws.statusBarManager.statusBarFrame.size.height;
            }
        }
    } else {
        return [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    return 0;
}

- (BOOL)openSettingsURL {
    NSURL *url = nil;
    if(@available(iOS 8.0, *)) {
        url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    } else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"prefs:root==%@", [NSBundle mainBundle].infoDictionary[@"CFBundleIdentifier"]]];
    }
    if([self canOpenURL:url]) {
        if(@available(iOS 10.0, *)) {
            [self openURL:url options:@{} completionHandler:^(BOOL success) {
                //return success;
            }];
            return YES;
        } else {
            return [self openURL:url];
        }
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
    [self setAssociatedObject:&networkActivityIndicatorCountKey value:@(networkActivityIndicatorCount) policy:OBJC_ASSOCIATION_RETAIN];
    self.networkActivityIndicatorVisible = networkActivityIndicatorCount > 0;
}

- (NSUInteger)networkActivityIndicatorCount {
    NSNumber *number = [self getAssociatedObject:&networkActivityIndicatorCountKey];
    return [number integerValue];
}

#pragma mark IdleTimer

- (NSNumber *)idleTimerDisabledSaved {
    return [self getAssociatedObject:&idleTimerDisabledSavedKey];
}

- (void)setIdleTimerDisabledSaved:(NSNumber *)idleTimerDisabledSaved {
    [self setAssociatedObject:&idleTimerDisabledSavedKey value:idleTimerDisabledSaved policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (id)willResignActiveObserver {
    return [self getAssociatedObject:&willResignActiveObserverKey];
}

- (void)setWillResignActiveObserver:(id)willResignActiveObserver {
    [self setAssociatedObject:&willResignActiveObserverKey value:willResignActiveObserver policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (id)didEnterBackgroundObserver {
    return [self getAssociatedObject:&didEnterBackgroundObserverKey];
}

- (void)setDidEnterBackgroundObserver:(id)didEnterBackgroundObserver {
    [self setAssociatedObject:&didEnterBackgroundObserverKey value:didEnterBackgroundObserver policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (id)willEnterForegroundObserver {
    return [self getAssociatedObject:&willEnterForegroundObserverKey];
}

- (void)setWillEnterForegroundObserver:(id)willEnterForegroundObserver {
    [self setAssociatedObject:&willEnterForegroundObserverKey value:willEnterForegroundObserver policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (id)didBecomeActiveObserver {
    return [self getAssociatedObject:&didBecomeActiveObserverKey];
}

- (void)setDidBecomeActiveObserver:(id)didBecomeActiveObserver {
    [self setAssociatedObject:&didBecomeActiveObserverKey value:didBecomeActiveObserver policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (BOOL)idleTimerEnabled {
    NSNumber *number = [self getAssociatedObject:&idleTimerEnabledKey];
    return [number boolValue];
}

- (void)setIdleTimerEnabled:(BOOL)idleTimerEnabled {
    if (self.idleTimerDisabledSaved == nil) {
        self.idleTimerDisabledSaved = @(self.idleTimerDisabled);
    }
    //
    [self setAssociatedObject:&idleTimerEnabledKey value:@(idleTimerEnabled) policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
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
