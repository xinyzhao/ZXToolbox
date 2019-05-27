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

static inline void nsarray_swizzle_method(SEL old_selector, SEL new_selector, SEL new_selector_0, SEL new_selector_1, SEL new_selector_2) {
    // __NSArrayI
    Method old_method = class_getInstanceMethod(objc_getClass("__NSArrayI"), old_selector);
    Method new_method = class_getInstanceMethod(objc_getClass("NSArray"), new_selector);
    method_exchangeImplementations(old_method, new_method);
    // __NSArray0
    Method old_method_0 = class_getInstanceMethod(objc_getClass("__NSArray0"), old_selector);
    Method new_method_0 = class_getInstanceMethod(objc_getClass("NSArray"), new_selector_0);
    if (old_method_0 && new_method_0) {
        if (old_method_0 != old_method) {
            method_exchangeImplementations(old_method_0, new_method_0);
        }
    }
    // __NSSingleObjectArrayI
    Method old_method_1 = class_getInstanceMethod(objc_getClass("__NSSingleObjectArrayI"), old_selector);
    Method new_method_1 = class_getInstanceMethod(objc_getClass("NSArray"), new_selector_1);
    if (old_method_1 && new_method_1) {
        if (old_method_1 != old_method && old_method_1 != old_method_0) {
            method_exchangeImplementations(old_method_1, new_method_1);
        }
    }
    // __NSArrayM
    Method old_method_2 = class_getInstanceMethod(objc_getClass("__NSArrayM"), old_selector);
    Method new_method_2 = class_getInstanceMethod(objc_getClass("NSArray"), new_selector_2);
    if (old_method_2 && new_method_2) {
        if (old_method_2 != old_method && old_method_2 != old_method_1 && old_method_2 != old_method_0) {
            method_exchangeImplementations(old_method_2, new_method_2);
        }
    }
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        nsarray_swizzle_method(@selector(objectAtIndex:), @selector(objectByIndex:), @selector(objectByIndex0:), @selector(objectByIndex1:), @selector(objectByIndex2:));
        nsarray_swizzle_method(@selector(objectAtIndexedSubscript:), @selector(objectByIndexedSubscript:), @selector(objectByIndexedSubscript0:), @selector(objectByIndexedSubscript1:), @selector(objectByIndexedSubscript2:));
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

- (id)objectByIndex2:(NSUInteger)index {
    if (index < self.count) {
        return [self objectByIndex2:index];
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

- (id)objectByIndexedSubscript2:(NSUInteger)index {
    if (index < self.count) {
        return [self objectByIndexedSubscript2:index];
    } else if (self.count > 0) {
        NSLog(@"%s: index %d beyond bounds [0...%d]", __func__, (int)index, (int)self.count - 1);
    } else {
        NSLog(@"%s: index %d beyond bounds for empty array", __func__, (int)index);
    }
    return nil;
}

@end
