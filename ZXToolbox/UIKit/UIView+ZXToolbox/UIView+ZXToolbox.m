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
#import "NSObject+ZXToolbox.h"

#define ZXToolboxSubclass @"_ZXToolbox_Subclass"

static char extrinsicContentSizeKey;

@implementation UIView (ZXToolbox)

+ (instancetype)loadNibNamed:(NSString *)name {
    return [self loadNibNamed:name inBundle:nil];
}

+ (instancetype)loadNibNamed:(NSString *)name inBundle:(NSBundle *)bundle {
    return [self loadNibNamed:name inBundle:bundle owner:nil options:nil];
}

+ (instancetype)loadNibNamed:(NSString *)name inBundle:(NSBundle *)bundle owner:(id)owner options:(NSDictionary<UINibOptionsKey,id> *)options {
    if (bundle == nil) {
        bundle = [NSBundle mainBundle];
    }
    NSArray *list = [bundle loadNibNamed:name owner:owner options:options];
    for (UIView *view in list) {
        if ([view isKindOfClass:[self class]]) {
            return view;
        }
    }
    return nil;
}

- (void)setExtrinsicContentSize:(CGSize)size {
    Class clsA = [self class];
    NSString *strA = NSStringFromClass(clsA);
    if (![strA hasSuffix:ZXToolboxSubclass]) {
        NSString *strB = [strA stringByAppendingString:ZXToolboxSubclass];
        Class clsB = NSClassFromString(strB);
        if (clsB == nil) {
            clsB = objc_allocateClassPair(clsA, strB.UTF8String, 0);
            objc_registerClassPair(clsB);
            //
            [clsB swizzleMethod:@selector(intrinsicContentSize) with:@selector(zx_intrinsicContentSize)];
        }
        object_setClass(self, clsB);
    }
    //
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self setAssociatedObject:&extrinsicContentSizeKey value:[NSValue valueWithCGSize:size] policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
    [self invalidateIntrinsicContentSize];
}

- (CGSize)extrinsicContentSize {
    NSValue *value = [self getAssociatedObject:&extrinsicContentSizeKey];
    return value ? [value CGSizeValue] : CGSizeZero;;
}

- (CGSize)zx_intrinsicContentSize   {
    CGSize size = [self zx_intrinsicContentSize];
    CGSize offset = [self extrinsicContentSize];
    size.width += offset.width;
    size.height += offset.height;
    return size;
}

- (UIImage *)captureImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)snapshotImage {
    return [self captureImage];
}

- (id)subviewForTag:(NSInteger)tag {
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

- (id)subviewForTag:(NSInteger)tag isKindOfClass:(Class)aClass {
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

- (id)subviewForTag:(NSInteger)tag isMemberOfClass:(Class)aClass {
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
