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

@implementation UIApplication (BadgeNumber)

- (BOOL)openSettingsURL {
    NSURL *url = nil;
    if(@available(iOS 8.0, *)) {
        url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    } else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"prefs:root==%@", [NSBundle mainBundle].infoDictionary[@"CFBundleIdentifier"]]];
    }
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        return [[UIApplication sharedApplication] openURL:url];
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

- (void)setIdleTimerDisabledState:(BOOL)idleTimerDisabledState {
    objc_setAssociatedObject(self, @selector(idleTimerDisabledState), @(idleTimerDisabledState), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)idleTimerDisabledState {
    NSNumber *number = objc_getAssociatedObject(self, @selector(idleTimerDisabledState));
    return [number boolValue];
}

- (void)setDidBecomeActiveObserver:(id)didBecomeActiveObserver {
    objc_setAssociatedObject(self, @selector(didBecomeActiveObserver), didBecomeActiveObserver, OBJC_ASSOCIATION_ASSIGN);
}

- (id)didBecomeActiveObserver {
    return objc_getAssociatedObject(self, @selector(didBecomeActiveObserver));
}

- (void)setWillResignActiveObserver:(id)willResignActiveObserver {
    objc_setAssociatedObject(self, @selector(willResignActiveObserver), willResignActiveObserver, OBJC_ASSOCIATION_ASSIGN);
}

- (id)willResignActiveObserver {
    return objc_getAssociatedObject(self, @selector(willResignActiveObserver));
}

- (void)setIdleTimerEnabled:(BOOL)idleTimerEnabled {
    objc_setAssociatedObject(self, @selector(idleTimerEnabled), @(idleTimerEnabled), OBJC_ASSOCIATION_ASSIGN);
    //
    __weak typeof(self) weakSelf = self;
    if (self.didBecomeActiveObserver == nil) {
        self.didBecomeActiveObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            weakSelf.idleTimerDisabledState = weakSelf.idleTimerDisabled;
            if (weakSelf.idleTimerDisabled == weakSelf.idleTimerEnabled) {
                weakSelf.idleTimerDisabled = !weakSelf.idleTimerEnabled;
            }
        }];
    }
    if (self.willResignActiveObserver == nil) {
        self.willResignActiveObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if (weakSelf.idleTimerDisabled != weakSelf.idleTimerDisabledState) {
                weakSelf.idleTimerDisabled = weakSelf.idleTimerDisabledState;
            }
        }];
    }
}

- (BOOL)idleTimerEnabled {
    NSNumber *number = objc_getAssociatedObject(self, @selector(idleTimerEnabled));
    return [number boolValue];
}

@end
