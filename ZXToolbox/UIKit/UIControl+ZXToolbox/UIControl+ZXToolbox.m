//
// UIControl+ZXToolbox.m
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

#import "UIControl+ZXToolbox.h"
#import "NSObject+ZXToolbox.h"

#define kTimeIntervalForControlEvents0 @"onTimeIntervalForControlEvents_"
#define kTimeIntervalForControlEvents1 @"onTimeIntervalForControlEvents:"

static char timeIntervalModeKey;
static char timeIntervalForControlEventsKey;

@implementation UIControl (ZXToolbox)

void onTimeIntervalForControlEvents(id obj, SEL sel) {
    NSString *cmd = NSStringFromSelector(sel);
    NSString *str = [[cmd componentsSeparatedByString:@"_"] lastObject];
    UIControlEvents controlEvents = [str integerValue];
    SEL selector = NSSelectorFromString(kTimeIntervalForControlEvents1);
    IMP imp = [obj methodForSelector:selector];
    if (imp) {
        void (*func)(id, SEL, UIControlEvents) = (void *)imp;
        func(obj, selector, controlEvents);
    }
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    NSString *str = NSStringFromSelector(sel);
    if ([str hasPrefix:kTimeIntervalForControlEvents0]) {
        class_addMethod([self class], sel, (IMP)onTimeIntervalForControlEvents, "v@:"); // 动态添加实例方法
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

- (SEL)selectorForControlEvents:(UIControlEvents)controlEvents {
    NSString *str = [NSString stringWithFormat:@"%@%lu", kTimeIntervalForControlEvents0, (unsigned long)controlEvents];
    return NSSelectorFromString(str);
}

#pragma mark timeIntervalByUserInteractionEnabled

- (void)setTimeIntervalByUserInteractionEnabled:(BOOL)timeIntervalByUserInteractionEnabled {
    self.timeIntervalMode = timeIntervalByUserInteractionEnabled ? UIControlTimeIntervalModeEvent : UIControlTimeIntervalModeState;
}

- (BOOL)timeIntervalByUserInteractionEnabled {
    return self.timeIntervalMode == UIControlTimeIntervalModeEvent;
}

#pragma mark timeIntervalMode

- (void)setTimeIntervalMode:(UIControlTimeIntervalMode)timeIntervalMode {
    [self setAssociatedObject:&timeIntervalModeKey value:@(timeIntervalMode) policy:OBJC_ASSOCIATION_RETAIN];
}

- (UIControlTimeIntervalMode)timeIntervalMode {
    id obj = [self getAssociatedObject:&timeIntervalModeKey];
    return obj ? [obj integerValue] : UIControlTimeIntervalModeState;
}

#pragma mark timeIntervalForControlEvents

- (void)setTimeIntervalForControlEvents:(NSMutableDictionary *)timeIntervalForControlEvents {
    [self setAssociatedObject:&timeIntervalForControlEventsKey value:timeIntervalForControlEvents policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (NSMutableDictionary *)timeIntervalForControlEvents {
    id obj = [self getAssociatedObject:&timeIntervalForControlEventsKey];
    if (obj == nil) {
        obj = [[NSMutableDictionary alloc] init];
        self.timeIntervalForControlEvents = obj;
    }
    return obj;
}

#pragma mark timeIntervalForControlEvents

- (void)setTimeInteval:(NSTimeInterval)timeInterval forControlEvents:(UIControlEvents)controlEvents {
    [self removeTimeIntevalForControlEvents:controlEvents];
    if (timeInterval > UIControlTimeIntervalMinimum) {
        [self.timeIntervalForControlEvents setObject:@(timeInterval) forKey:@(controlEvents)];
        SEL sel = [self selectorForControlEvents:controlEvents];
        [self addTarget:self action:sel forControlEvents:controlEvents];
    }
}

- (void)removeTimeIntevalForControlEvents:(UIControlEvents)controlEvents {
    SEL sel = [self selectorForControlEvents:controlEvents];
    [self removeTarget:self action:sel forControlEvents:controlEvents];
    [self.timeIntervalForControlEvents removeObjectForKey:@(controlEvents)];
}

- (void)onTimeIntervalForControlEvents:(UIControlEvents)controlEvents {
    NSTimeInterval timeInterval = [[self.timeIntervalForControlEvents objectForKey:@(controlEvents)] doubleValue];
    if (timeInterval > UIControlTimeIntervalMinimum) {
        // Disabled
        switch (self.timeIntervalMode) {
            case UIControlTimeIntervalModeState:
                self.enabled = NO;
                break;
            case UIControlTimeIntervalModeEvent:
                self.userInteractionEnabled = NO;
                break;
        }
        // Delay enabled
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            switch (self.timeIntervalMode) {
                case UIControlTimeIntervalModeState:
                    self.enabled = YES;
                    break;
                case UIControlTimeIntervalModeEvent:
                    self.userInteractionEnabled = YES;
                    break;
            }
        });
    }
}

@end
