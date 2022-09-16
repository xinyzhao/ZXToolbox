//
// ZXDebugTools.h
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

@interface ZXDebugTools : NSObject
/// Repeatedly block and unblock the queue
/// @param queue The queue
/// @param duration Blocked time
/// @param repeat Whether repeatedly block and unblock
/// @param interval Repeat interval time
/// @ref https://stackoverflow.com/questions/20083276/cant-add-self-as-subview
+ (void)blockTheQueue:(dispatch_queue_t)queue duration:(NSTimeInterval)duration repeat:(BOOL)repeat interval:(NSTimeInterval)interval;
+ (void)lowCostSemaphoreWait:(NSTimeInterval)seconds;
@end

NS_ASSUME_NONNULL_END
