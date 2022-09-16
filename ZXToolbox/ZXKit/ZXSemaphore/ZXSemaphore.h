//
// ZXSemaphore.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// @Brief 信号量队列
/// @Discussion Semaphore queue
@interface ZXSemaphore : NSObject

/// @Brief 信号量数量
/// @Discussion The starting value for the semaphore.
@property (nonatomic, readonly) NSInteger count;

/// @Brief 创建信号量队列
/// @Discussion Creates new counting semaphore queue with an initial value.
/// @param count The starting value for the semaphore.
- (instancetype)initWithCount:(NSInteger)count;

/// @Brief 增加或减少信号量
/// @Discussion Signal (increment or decrement) for the semaphore.
/// @param count The signal value for the semaphore.
/// @param checkValue Check value for the semaphore.
- (void)signal:(NSInteger)count checkValue:(BOOL)checkValue;

/// @Brief 增加或减少信号量
/// @Discussion Signal (increment or decrement) for the semaphore.
/// @Discussion The parameter checkValue is YES.
/// @param count The signal value for the semaphore.
- (void)signal:(NSInteger)count;

/// @Brief 等待信号量，直到超时或信号量为0
/// @Discussion Wait for a semaphore, until timeout or the semaphore is 0 (barrier )
/// @param timeout When to timeout (see dispatch_time).
/// @param queue The queue for completion handler.
/// @param handler The handler when completion.
- (void)wait:(dispatch_time_t)timeout queue:(dispatch_queue_t)queue completion:(void (^)(intptr_t result))handler;

/// @Brief 等待信号量，直到超时或信号量为0
/// @Discussion The timeout is DISPATCH_TIME_FOREVER, queue is dispatch_get_main_queue().
/// @param handler The handler when completion.
- (void)wait:(void (^)(intptr_t result))handler;

@end

NS_ASSUME_NONNULL_END
