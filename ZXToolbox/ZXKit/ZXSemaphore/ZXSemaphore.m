//
// ZXSemaphore.m
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2021 Zhao Xin
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

#import "ZXSemaphore.h"

@interface ZXSemaphore ()
/// 等待队列
@property (nonatomic, strong) dispatch_queue_t queue;
/// 信号量0，同步多个操作
@property (nonatomic, strong) dispatch_semaphore_t semaphore_0;
/// 信号量1，保证线程安全
@property (nonatomic, strong) dispatch_semaphore_t semaphore_1;

@end

@implementation ZXSemaphore
@synthesize count = _count;

- (instancetype)init {
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create("ZXSemaphore", NULL);
        _semaphore_0 = dispatch_semaphore_create(0);
        _semaphore_1 = dispatch_semaphore_create(1);
    }
    return self;
}

- (instancetype)initWithCount:(NSInteger)count {
    self = [self init];
    if (self) {
        _count = count;
    }
    return self;
}

- (NSInteger)count {
    NSInteger count = 0;
    dispatch_semaphore_wait(_semaphore_1, DISPATCH_TIME_FOREVER);
    count = _count;
    dispatch_semaphore_signal(_semaphore_1);
    return count;
}

- (void)signal:(NSInteger)count {
    dispatch_semaphore_wait(_semaphore_1, DISPATCH_TIME_FOREVER);
    _count += count;
    if (_count == 0) {
        dispatch_semaphore_signal(_semaphore_0);
    }
    dispatch_semaphore_signal(_semaphore_1);
}

- (void)wait:(dispatch_time_t)timeout queue:(dispatch_queue_t)queue completion:(void (^)(intptr_t result))handler {
    dispatch_async(_queue, ^{
        intptr_t result = dispatch_semaphore_wait(self.semaphore_0, timeout);
        dispatch_async(queue, ^{
            if (handler) {
                handler(result);
            }
        });
    });
}

- (void)wait:(void (^)(intptr_t result))handler {
    [self wait:DISPATCH_TIME_FOREVER queue:dispatch_get_main_queue() completion:handler];
}

@end
