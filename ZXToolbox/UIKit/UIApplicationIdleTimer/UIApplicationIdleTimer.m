//
// UIApplicationIdleTimer.m
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

#import "UIApplicationIdleTimer.h"

@interface UIApplicationIdleTimer ()
@property(nonatomic, getter=isDisabled) BOOL disabled;

@end

@implementation UIApplicationIdleTimer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _disabled = [UIApplication sharedApplication].idleTimerDisabled;
        _enabled = !_disabled;
        //
        [[UIApplication sharedApplication] addObserver:self forKeyPath:@"idleTimerDisabled" options:NSKeyValueObservingOptionNew context:NULL];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setEnabled:(BOOL)enabled {
    if (_enabled != enabled) {
        _enabled = enabled;
    }
    if ([UIApplication sharedApplication].idleTimerDisabled == _enabled) {
        [UIApplication sharedApplication].idleTimerDisabled = !_enabled;
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if ([UIApplication sharedApplication].idleTimerDisabled == _enabled) {
        [UIApplication sharedApplication].idleTimerDisabled = !_enabled;
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    if ([UIApplication sharedApplication].idleTimerDisabled != _disabled) {
        [UIApplication sharedApplication].idleTimerDisabled = _disabled;
    }
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context {
    if ([keyPath isEqualToString:@"idleTimerDisabled"]) {
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            if ([UIApplication sharedApplication].idleTimerDisabled == _enabled) {
                [UIApplication sharedApplication].idleTimerDisabled = !_enabled;
            }
        }
    }
}

@end

@implementation UIApplication (IdleTimer)

+ (UIApplicationIdleTimer *)sharedIdleTimer {
    static UIApplicationIdleTimer *sharedIdleTimer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedIdleTimer = [[UIApplicationIdleTimer alloc] init];
    });
    return sharedIdleTimer;
}

@end
