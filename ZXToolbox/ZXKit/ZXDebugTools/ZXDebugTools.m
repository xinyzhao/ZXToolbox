//
// ZXDebugTools.m
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

#import "ZXDebugTools.h"

@implementation ZXDebugTools

+ (void)blockTheQueue:(dispatch_queue_t)queue duration:(NSTimeInterval)duration repeat:(BOOL)repeat interval:(NSTimeInterval)interval {
    dispatch_async(queue, ^{
        // Block the queue temporarily using a semaphore
        [ZXDebugTools lowCostSemaphoreWait:duration];

        // Queue up another blocking attempt to happen shortly
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC);
        dispatch_after(delayTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [ZXDebugTools blockTheQueue:queue duration:duration repeat:repeat interval:interval];
        });
    });
}

+ (void)lowCostSemaphoreWait:(NSTimeInterval)seconds {
    // Use a semaphore to set up a low cost (non-polling) delay on whatever thread we are currently running
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC);

    dispatch_after(delayTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_signal(semaphore);
    });

    NSLog(@"[ZXDebugTools] DELAYING...");
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"[ZXDebugTools] END of delay\n\n");
}

@end
