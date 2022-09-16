//
// ZXKeyValueObserver.m
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

#import "ZXKeyValueObserver.h"

@interface ZXKeyValueObserver ()
@property (nonatomic, weak) NSObject *object;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, assign) void *context;
@property (nonatomic, copy) ZXKeyValueChangeHandler changeHandler;

@end

@implementation ZXKeyValueObserver

- (void)observe:(NSObject *)object keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context changeHandler:(ZXKeyValueChangeHandler)changeHandler {
    [self invalidate];
    self.object = object;
    self.keyPath = keyPath;
    self.context = context;
    self.changeHandler = changeHandler;
    [self.object addObserver:self forKeyPath:self.keyPath options:options context:self.context];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context {
    if (object == self.object && [keyPath isEqualToString:self.keyPath]) {
        if (self.changeHandler) {
            self.changeHandler(change, context);
        }
    }
}

- (void)invalidate {
    [self.object removeObserver:self forKeyPath:self.keyPath context:self.context];
    self.object = nil;
    self.keyPath = nil;
    self.context = NULL;
    self.changeHandler = nil;
}

@end
