//
// ZXDispatchQueue.h
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2020 Zhao Xin
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

/// ZXDispatchQueue
@interface ZXDispatchQueue : NSObject

/// 主队列单例
+ (instancetype)main;

/// 全局队列单例
+ (instancetype)global;

/// 初始化自定义队列
/// @param queue 自定义队列
- (instancetype)initWithQueue:(dispatch_queue_t)queue;

/// 异步延迟执行事件
/// @param event 事件名称
/// @param delayInSeconds 延迟时间，秒
/// @param execute 执行回调
- (void)asyncAfter:(NSString *)event deadline:(NSTimeInterval)delayInSeconds execute:(void(^)(NSString *event))execute;

/// 取消延迟执行事件
/// @param event 事件名称
- (void)cancelAfter:(NSString *)event;

@end

NS_ASSUME_NONNULL_END
