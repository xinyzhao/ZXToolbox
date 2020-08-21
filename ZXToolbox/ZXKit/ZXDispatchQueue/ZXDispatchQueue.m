//
// ZXDispatchQueue.m
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

#import "ZXDispatchQueue.h"

@interface ZXDispatchQueue ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *events;
@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation ZXDispatchQueue

+ (instancetype)main {
    static ZXDispatchQueue *main;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        main = [[ZXDispatchQueue alloc] initWithQueue:dispatch_get_main_queue()];
    });
    return main;
}

+ (instancetype)global {
    static ZXDispatchQueue *global;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        global = [[ZXDispatchQueue alloc] initWithQueue:dispatch_get_global_queue(0, 0)];
    });
    return global;
}

- (instancetype)initWithQueue:(dispatch_queue_t)queue {
    self = [super init];
    if (self) {
        self.queue = queue;
        self.events = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)asyncAfter:(NSString *)event deadline:(NSTimeInterval)delayInSeconds execute:(void(^)(NSString *event))execute {
    NSString *uuid = [NSUUID UUID].UUIDString;
    self.events[event] = uuid;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), self.queue, ^{
        if ([self.events[event] isEqualToString:uuid]) {
            if (execute) {
                execute(event);
            }
        }
    });
}

- (void)cancelAfter:(NSString *)event {
    [self.events removeObjectForKey:event];
}

@end
