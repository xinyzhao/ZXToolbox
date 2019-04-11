//
// NSArray+ZXToolbox.m
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

#import "NSArray+ZXToolbox.h"
#import <objc/runtime.h>

@implementation NSArray (ZXToolbox)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = objc_getClass("__NSArrayI");
        Method originalMethod = class_getInstanceMethod(class, @selector(objectAtIndex:));
        Method swizzledMethod = class_getInstanceMethod(class, @selector(objectByIndex:));
        method_exchangeImplementations(originalMethod, swizzledMethod);
        //
        if (@available(iOS 11.0, *)) {
            Method originalMethod = class_getInstanceMethod(class, @selector(objectAtIndexedSubscript:));
            Method swizzledMethod = class_getInstanceMethod(class, @selector(objectByIndexedSubscript:));
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (id)objectByIndex:(NSUInteger)index {
    if (index < self.count) {
        return [self objectByIndex:index];
    }
    return nil;
}

- (id)objectByIndexedSubscript:(NSUInteger)idx {
    if (idx < self.count) {
        return [self objectByIndexedSubscript:idx];
    }
    return nil;
}

@end

@implementation NSMutableArray (ZXToolbox)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = objc_getClass("__NSArrayM");
        Method originalMethod = class_getInstanceMethod(class, @selector(objectAtIndex:));
        Method swizzledMethod = class_getInstanceMethod(class, @selector(objectByIndex:));
        method_exchangeImplementations(originalMethod, swizzledMethod);
        //
        if (@available(iOS 11.0, *)) {
            Method originalMethod = class_getInstanceMethod(class, @selector(objectAtIndexedSubscript:));
            Method swizzledMethod = class_getInstanceMethod(class, @selector(objectByIndexedSubscript:));
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (id)objectByIndex:(NSUInteger)index {
    if (index < self.count) {
        return [self objectByIndex:index];
    }
    return nil;
}

- (id)objectByIndexedSubscript:(NSUInteger)idx {
    if (idx < self.count) {
        return [self objectByIndexedSubscript:idx];
    }
    return nil;
}

@end
