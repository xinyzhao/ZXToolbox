//
// UIView+ZXToolbox.m
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

#import "UIView+ZXToolbox.h"
#import <objc/runtime.h>

@implementation UIView (ZXToolbox)

- (void)setIntrinsicContentInset:(UIEdgeInsets)inset {
    UIEdgeInsets oldInset = [self intrinsicContentInset];
    BOOL isExchanged = !UIEdgeInsetsEqualToEdgeInsets(oldInset, UIEdgeInsetsZero);
    BOOL isUnchanged = UIEdgeInsetsEqualToEdgeInsets(inset, UIEdgeInsetsZero);
    // 保存数值
    const void *key = @selector(intrinsicContentInset);
    NSValue *value = nil;
    if (!isUnchanged) {
        value = [NSValue valueWithUIEdgeInsets:inset];
    }
    objc_setAssociatedObject(self, key, nil, OBJC_ASSOCIATION_RETAIN);
    // 新旧不同
    if (!UIEdgeInsetsEqualToEdgeInsets(inset, oldInset)) {
        Method intrinsic = class_getInstanceMethod(self.class, @selector(intrinsicContentSize));
        Method extrinsic = class_getInstanceMethod(self.class, @selector(extrinsicContentSize));
        // 还原方法
        if (isUnchanged) {
            if (isExchanged) {
                method_exchangeImplementations(intrinsic, extrinsic);
            }
        } else {
            // 设置新值
            CGSize size = [self intrinsicContentSize];
            if (isExchanged) {
                size = [self extrinsicContentSize];
            }
            size.width += inset.left + inset.right;
            size.height += inset.top + inset.bottom;
            [self setExtrinsicContentSize:size];
            // 交换方法
            if (!isExchanged) {
                method_exchangeImplementations(intrinsic, extrinsic);
            }
        }
    }
}

- (UIEdgeInsets)intrinsicContentInset {
    NSValue *value = objc_getAssociatedObject(self, @selector(intrinsicContentInset));
    if (value) {
        return value.UIEdgeInsetsValue;
    }
    return UIEdgeInsetsZero;
}

- (void)setExtrinsicContentSize:(CGSize)size {
    const void *key = @selector(extrinsicContentSize);
    NSValue *value = nil;
    if (!CGSizeEqualToSize(size, CGSizeZero)) {
        value = [NSValue valueWithCGSize:size];
    }
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN);
}

- (CGSize)extrinsicContentSize {
    NSValue *value = objc_getAssociatedObject(self, @selector(extrinsicContentSize));
    if (value) {
        return value.CGSizeValue;
    }
    return [self intrinsicContentSize];
}

- (nullable UIImage *)captureImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (nullable UIImage *)snapshotImage {
    return [self captureImage];
}

- (nullable id)subviewForTag:(NSInteger)tag {
    UIView *subview = nil;
    for (UIView *view in self.subviews) {
        if (view.tag == tag) {
            subview = view;
            break;
        }
        //
        subview = [view subviewForTag:tag];
        if (subview) {
            break;
        }
    }
    return subview;
}

- (nullable id)subviewForTag:(NSInteger)tag isKindOfClass:(Class)aClass {
    UIView *subview = nil;
    for (UIView *view in self.subviews) {
        if (view.tag == tag && [view isKindOfClass:aClass]) {
            subview = view;
            break;
        }
        //
        subview = [view subviewForTag:tag isKindOfClass:aClass];
        if (subview) {
            break;
        }
    }
    return subview;
}

- (nullable id)subviewForTag:(NSInteger)tag isMemberOfClass:(Class)aClass {
    UIView *subview = nil;
    for (UIView *view in self.subviews) {
        if (view.tag == tag && [view isMemberOfClass:aClass]) {
            subview = view;
            break;
        }
        //
        subview = [view subviewForTag:tag isMemberOfClass:aClass];
        if (subview) {
            break;
        }
    }
    return subview;
}

@end
