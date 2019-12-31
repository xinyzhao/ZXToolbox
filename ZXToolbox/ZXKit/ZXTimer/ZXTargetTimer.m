//
// ZXTargetTimer.m
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

#import "ZXTargetTimer.h"

@interface ZXTargetTimer ()
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;

@end

@implementation ZXTargetTimer
@synthesize timer = _timer;

+ (instancetype)timerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo {
    ZXTargetTimer *timer = [[[self class] alloc] init];
    timer.target = aTarget;
    timer.selector = aSelector;
    timer.timer = [NSTimer timerWithTimeInterval:ti target:timer selector:@selector(onTimer:) userInfo:userInfo repeats:yesOrNo];
    return timer;
}

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo {
    ZXTargetTimer *timer = [[[self class] alloc] init];
    timer.target = aTarget;
    timer.selector = aSelector;
    timer.timer = [NSTimer scheduledTimerWithTimeInterval:ti target:timer selector:@selector(onTimer:) userInfo:userInfo repeats:yesOrNo];
    return timer;
}

- (void)onTimer:(NSTimer *)timer {
    if (_target && _selector) {
        IMP imp = [_target methodForSelector:_selector];
        void (*func)(id, SEL, id) = (void *)imp;
        func(_target, _selector, timer);
    }
}

- (void)invalidate {
    if (self.timer.isValid) {
        [self.timer invalidate];
    }
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
