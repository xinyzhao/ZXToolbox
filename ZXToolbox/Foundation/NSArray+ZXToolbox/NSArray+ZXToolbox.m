//
// NSArray+ZXToolbox.m
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2019-2020 Zhao Xin
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
#import "ZXToolbox+Macros.h"
#import <objc/runtime.h>

@implementation NSArray (ZXToolbox)

static int const _nsarray_methods_count = 10;
static Method _nsarray_methods[_nsarray_methods_count];
static inline void nsarray_swizzle_method(Class old_class, SEL old_selector, Class new_class, SEL new_selector) {
    Method old_method = class_getInstanceMethod(old_class, old_selector);
    Method new_method = class_getInstanceMethod(new_class, new_selector);
    if (old_method && new_method) {
        for(int i = 0; i < _nsarray_methods_count; i++) {
            if (_nsarray_methods[i]) {
                if (_nsarray_methods[i] == old_method) {
                    break;
                }
            } else {
                method_exchangeImplementations(old_method, new_method);
                _nsarray_methods[i] = old_method;
                break;
            }
        }
    }
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        memset(&_nsarray_methods, 0, sizeof(Method) * _nsarray_methods_count);
        // -[NSArray objectAtIndex:]
        nsarray_swizzle_method(objc_getClass("__NSArrayI"), @selector(objectAtIndex:), objc_getClass("NSArray"), @selector(objectAtIndexI:));
        nsarray_swizzle_method(objc_getClass("__NSArray0"), @selector(objectAtIndex:), objc_getClass("NSArray"), @selector(objectAtIndex0:));
        nsarray_swizzle_method(objc_getClass("__NSSingleObjectArrayI"), @selector(objectAtIndex:), objc_getClass("NSArray"), @selector(objectAtIndex1:));
        nsarray_swizzle_method(objc_getClass("__NSArrayM"), @selector(objectAtIndex:), objc_getClass("NSArray"), @selector(objectAtIndexM:));
        nsarray_swizzle_method(objc_getClass("__NSFrozenArrayM"), @selector(objectAtIndex:), objc_getClass("NSArray"), @selector(objectAtIndex2:));
        // -[NSArray objectAtIndexedSubscript:]
        nsarray_swizzle_method(objc_getClass("__NSArrayI"), @selector(objectAtIndexedSubscript:), objc_getClass("NSArray"), @selector(objectAtIndexedSubscriptI:));
        nsarray_swizzle_method(objc_getClass("__NSArray0"), @selector(objectAtIndexedSubscript:), objc_getClass("NSArray"), @selector(objectAtIndexedSubscript0:));
        nsarray_swizzle_method(objc_getClass("__NSSingleObjectArrayI"), @selector(objectAtIndexedSubscript:), objc_getClass("NSArray"), @selector(objectAtIndexedSubscript1:));
        nsarray_swizzle_method(objc_getClass("__NSArrayM"), @selector(objectAtIndexedSubscript:), objc_getClass("NSArray"), @selector(objectAtIndexedSubscriptM:));
        nsarray_swizzle_method(objc_getClass("__NSFrozenArrayM"), @selector(objectAtIndexedSubscript:), objc_getClass("NSArray"), @selector(objectAtIndexedSubscript2:));
    });
}

- (id)objectAtIndexI:(NSUInteger)index {
    if (index < self.count) {
        return [self objectAtIndexI:index];
    } else if (self.count > 0) {
        NSLogA(@"index %d beyond bounds [0...%d]\n%@", (int)index, (int)self.count - 1, [NSThread callStackSymbols]);
    } else {
        NSLogA(@"index %d beyond bounds for empty array\n%@", (int)index, [NSThread callStackSymbols]);
    }
    return nil;
}

- (id)objectAtIndex0:(NSUInteger)index {
    if (index < self.count) {
        return [self objectAtIndex0:index];
    } else if (self.count > 0) {
        NSLogA(@"index %d beyond bounds [0...%d]\n%@", (int)index, (int)self.count - 1, [NSThread callStackSymbols]);
    } else {
        NSLogA(@"index %d beyond bounds for empty array\n%@", (int)index, [NSThread callStackSymbols]);
    }
    return nil;
}

- (id)objectAtIndex1:(NSUInteger)index {
    if (index < self.count) {
        return [self objectAtIndex1:index];
    } else if (self.count > 0) {
        NSLogA(@"index %d beyond bounds [0...%d]\n%@", (int)index, (int)self.count - 1, [NSThread callStackSymbols]);
    } else {
        NSLogA(@"index %d beyond bounds for empty array\n%@", (int)index, [NSThread callStackSymbols]);
    }
    return nil;
}

- (id)objectAtIndexM:(NSUInteger)index {
    if (index < self.count) {
        return [self objectAtIndexM:index];
    } else if (self.count > 0) {
        NSLogA(@"index %d beyond bounds [0...%d]\n%@", (int)index, (int)self.count - 1, [NSThread callStackSymbols]);
    } else {
        NSLogA(@"index %d beyond bounds for empty array\n%@", (int)index, [NSThread callStackSymbols]);
    }
    return nil;
}

- (id)objectAtIndex2:(NSUInteger)index {
    if (index < self.count) {
        return [self objectAtIndex2:index];
    } else if (self.count > 0) {
        NSLogA(@"index %d beyond bounds [0...%d]\n%@", (int)index, (int)self.count - 1, [NSThread callStackSymbols]);
    } else {
        NSLogA(@"index %d beyond bounds for empty array\n%@", (int)index, [NSThread callStackSymbols]);
    }
    return nil;
}

- (id)objectAtIndexedSubscriptI:(NSUInteger)index {
    if (index < self.count) {
        return [self objectAtIndexedSubscriptI:index];
    } else if (self.count > 0) {
        NSLogA(@"index %d beyond bounds [0...%d]\n%@", (int)index, (int)self.count - 1, [NSThread callStackSymbols]);
    } else {
        NSLogA(@"index %d beyond bounds for empty array\n%@", (int)index, [NSThread callStackSymbols]);
    }
    return nil;
}

- (id)objectAtIndexedSubscript0:(NSUInteger)index {
    if (index < self.count) {
        return [self objectAtIndexedSubscript0:index];
    } else if (self.count > 0) {
        NSLogA(@"index %d beyond bounds [0...%d]\n%@", (int)index, (int)self.count - 1, [NSThread callStackSymbols]);
    } else {
        NSLogA(@"index %d beyond bounds for empty array\n%@", (int)index, [NSThread callStackSymbols]);
    }
    return nil;
}

- (id)objectAtIndexedSubscript1:(NSUInteger)index {
    if (index < self.count) {
        return [self objectAtIndexedSubscript1:index];
    } else if (self.count > 0) {
        NSLogA(@"index %d beyond bounds [0...%d]\n%@", (int)index, (int)self.count - 1, [NSThread callStackSymbols]);
    } else {
        NSLogA(@"index %d beyond bounds for empty array\n%@", (int)index, [NSThread callStackSymbols]);
    }
    return nil;
}

- (id)objectAtIndexedSubscriptM:(NSUInteger)index {
    if (index < self.count) {
        return [self objectAtIndexedSubscriptM:index];
    } else if (self.count > 0) {
        NSLogA(@"index %d beyond bounds [0...%d]\n%@", (int)index, (int)self.count - 1, [NSThread callStackSymbols]);
    } else {
        NSLogA(@"index %d beyond bounds for empty array\n%@", (int)index, [NSThread callStackSymbols]);
    }
    return nil;
}

- (id)objectAtIndexedSubscript2:(NSUInteger)index {
    if (index < self.count) {
        return [self objectAtIndexedSubscript2:index];
    } else if (self.count > 0) {
        NSLogA(@"index %d beyond bounds [0...%d]\n%@", (int)index, (int)self.count - 1, [NSThread callStackSymbols]);
    } else {
        NSLogA(@"index %d beyond bounds for empty array\n%@", (int)index, [NSThread callStackSymbols]);
    }
    return nil;
}

@end
