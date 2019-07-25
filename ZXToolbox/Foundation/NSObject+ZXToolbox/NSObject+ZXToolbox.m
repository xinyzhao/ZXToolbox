
// NSObject+ZXToolbox.m
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

#import "NSObject+ZXToolbox.h"
#import <objc/runtime.h>

@implementation NSObject (ZXToolbox)

+ (void)swizzleClassMethod:(SEL)originalSelector with:(SEL)swizzledSelector {
    // When swizzling a class method, use the following:
    // Class class = object_getClass((id)self);
    // ...
    // Method originalMethod = class_getClassMethod(class, originalSelector);
    // Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
    Class class = object_getClass((id)self);
    
    Method originalMethod = class_getClassMethod(class, originalSelector);
    Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(class,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (void)swizzleMethod:(SEL)originalSelector with:(SEL)swizzledSelector {
    Class class = self;
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(class,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)swizzleMethod:(SEL)originalSelector with:(SEL)swizzledSelector class:(Class)originalClass {
    Class swizzledClass = [self class];
    
    Method originalMethod = class_getInstanceMethod(originalClass, originalSelector);
    Method replacedMethod = class_getInstanceMethod(swizzledClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(swizzledClass, swizzledSelector);
    
    if (originalMethod) {
        BOOL didAddMethod = class_addMethod(originalClass,
                                            swizzledSelector,
                                            method_getImplementation(swizzledMethod),
                                            method_getTypeEncoding(swizzledMethod));
        if (didAddMethod) {
            Method exchangeMethod = class_getInstanceMethod(originalClass, swizzledSelector);
            method_exchangeImplementations(originalMethod, exchangeMethod);
        }
    } else {
        BOOL didAddMethod = class_addMethod(originalClass,
                                            originalSelector,
                                            method_getImplementation(replacedMethod),
                                            method_getTypeEncoding(replacedMethod));
        if (didAddMethod) {
            // Nothing
        }
    }
}

- (BOOL)respondsToMethod:(SEL)selector {
    return selector && [self respondsToSelector:selector];
}

- (void)performMethod:(SEL)selector {
    if ([self respondsToMethod:selector]) {
        IMP imp = [self methodForSelector:selector];
        void (*func)(id, SEL) = (void *)imp;
        func(self, selector);
    }
}

- (void)performMethod:(SEL)selector withObject:(id)object {
    if ([self respondsToMethod:selector]) {
        IMP imp = [self methodForSelector:selector];
        void (*func)(id, SEL, id) = (void *)imp;
        func(self, selector, object);
    }
}

- (void)performMethod:(SEL)selector withObject:(id)object1 withObject:(id)object2 {
    if ([self respondsToMethod:selector]) {
        IMP imp = [self methodForSelector:selector];
        void (*func)(id, SEL, id, id) = (void *)imp;
        func(self, selector, object1, object2);
    }
}

@end
