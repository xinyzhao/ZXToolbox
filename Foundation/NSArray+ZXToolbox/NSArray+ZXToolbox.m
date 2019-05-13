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

static inline void static_swizzle_method(Class class, SEL old, SEL new) {
    Method oldMethod = class_getInstanceMethod(class, old);
    Method newMethod = class_getInstanceMethod(class, new);
    method_exchangeImplementations(oldMethod, newMethod);
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        static_swizzle_method(objc_getClass("__NSArrayI"), @selector(objectAtIndex:), @selector(objectByIndex:));
        static_swizzle_method(objc_getClass("__NSArray0"), @selector(objectAtIndex:), @selector(objectByIndex0:));
        static_swizzle_method(objc_getClass("__NSSingleObjectArrayI"), @selector(objectAtIndex:), @selector(objectByIndex1:));
        static_swizzle_method(objc_getClass("__NSArrayI"), @selector(objectAtIndexedSubscript:), @selector(objectByIndexedSubscript:));
        static_swizzle_method(objc_getClass("__NSArray0"), @selector(objectAtIndexedSubscript:), @selector(objectByIndexedSubscript0:));
        static_swizzle_method(objc_getClass("__NSSingleObjectArrayI"), @selector(objectAtIndexedSubscript:), @selector(objectByIndexedSubscript1:));
    });
}

- (id)objectByIndex:(NSUInteger)index {
    if (index < self.count) {
        return [self objectByIndex:index];
    } else if (self.count > 0) {
        NSLog(@"%s: index %d beyond bounds [0...%d]", __func__, (int)index, (int)self.count - 1);
    } else {
        NSLog(@"%s: index %d beyond bounds for empty array", __func__, (int)index);
    }
    return nil;
}

- (id)objectByIndex0:(NSUInteger)index {
    if (index < self.count) {
        return [self objectByIndex0:index];
    } else if (self.count > 0) {
        NSLog(@"%s: index %d beyond bounds [0...%d]", __func__, (int)index, (int)self.count - 1);
    } else {
        NSLog(@"%s: index %d beyond bounds for empty array", __func__, (int)index);
    }
    return nil;
}

- (id)objectByIndex1:(NSUInteger)index {
    if (index < self.count) {
        return [self objectByIndex1:index];
    } else if (self.count > 0) {
        NSLog(@"%s: index %d beyond bounds [0...%d]", __func__, (int)index, (int)self.count - 1);
    } else {
        NSLog(@"%s: index %d beyond bounds for empty array", __func__, (int)index);
    }
    return nil;
}

- (id)objectByIndexedSubscript:(NSUInteger)index {
    if (index < self.count) {
        return [self objectByIndexedSubscript:index];
    } else if (self.count > 0) {
        NSLog(@"%s: index %d beyond bounds [0...%d]", __func__, (int)index, (int)self.count - 1);
    } else {
        NSLog(@"%s: index %d beyond bounds for empty array", __func__, (int)index);
    }
    return nil;
}

- (id)objectByIndexedSubscript0:(NSUInteger)index {
    if (index < self.count) {
        return [self objectByIndexedSubscript0:index];
    } else if (self.count > 0) {
        NSLog(@"%s: index %d beyond bounds [0...%d]", __func__, (int)index, (int)self.count - 1);
    } else {
        NSLog(@"%s: index %d beyond bounds for empty array", __func__, (int)index);
    }
    return nil;
}

- (id)objectByIndexedSubscript1:(NSUInteger)index {
    if (index < self.count) {
        return [self objectByIndexedSubscript1:index];
    } else if (self.count > 0) {
        NSLog(@"%s: index %d beyond bounds [0...%d]", __func__, (int)index, (int)self.count - 1);
    } else {
        NSLog(@"%s: index %d beyond bounds for empty array", __func__, (int)index);
    }
    return nil;
}

@end

@implementation NSMutableArray (ZXToolbox)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = objc_getClass("__NSArrayM");
        // objectAtIndex
        Method objectAtIndex = class_getInstanceMethod(class, @selector(objectAtIndex:));
        Method objectByIndex = class_getInstanceMethod(class, @selector(objectByIndex:));
        method_exchangeImplementations(objectAtIndex, objectByIndex);
        // objectAtIndexedSubscript
        Method objectAtIndexedSubscript = class_getInstanceMethod(class, @selector(objectAtIndexedSubscript:));
        Method objectByIndexedSubscript = class_getInstanceMethod(class, @selector(objectByIndexedSubscript:));
        method_exchangeImplementations(objectAtIndexedSubscript, objectByIndexedSubscript);
        // insertObject:atIndex
        Method insertObjectAtIndex = class_getInstanceMethod(class, @selector(insertObject:atIndex:));
        Method insertObjectByIndex = class_getInstanceMethod(class, @selector(insertObject:byIndex:));
        method_exchangeImplementations(insertObjectAtIndex, insertObjectByIndex);
    });
}

- (id)objectByIndex:(NSUInteger)index {
    if (index < self.count) {
        return [self objectByIndex:index];
    } else if (self.count > 0) {
        NSLog(@"%s: index %d beyond bounds [0...%d]", __func__, (int)index, (int)self.count - 1);
    } else {
        NSLog(@"%s: index %d beyond bounds for empty array", __func__, (int)index);
    }
    return nil;
}

- (id)objectByIndexedSubscript:(NSUInteger)index {
    if (index < self.count) {
        return [self objectByIndexedSubscript:index];
    } else if (self.count > 0) {
        NSLog(@"%s: index %d beyond bounds [0...%d]", __func__, (int)index, (int)self.count - 1);
    } else {
        NSLog(@"%s: index %d beyond bounds for empty array", __func__, (int)index);
    }
    return nil;
}

- (void)insertObject:(id)anObject byIndex:(NSUInteger)index {
    if (anObject) {
        [self insertObject:anObject byIndex:index];
    } else {
        NSLog(@"%s: object cannot be nil", __func__);
    }
}

@end
