//
// CALayer+ZXToolbox.m
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2023 Zhao Xin
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

#import "CALayer+ZXToolbox.h"
#import "NSObject+ZXToolbox.h"
#import "ZXKeyValueObserver.h"
#import <UIKit/UIKit.h>

static char boundsObserverKey;

@implementation CALayer (ZXToolbox)

- (ZXKeyValueObserver *)boundsObserver {
    ZXKeyValueObserver *kvo = [self getAssociatedObject:&boundsObserverKey];
    if (kvo == nil) {
        kvo = [[ZXKeyValueObserver alloc] init];
        [self setAssociatedObject:&boundsObserverKey value:kvo policy:OBJC_ASSOCIATION_RETAIN];
    }
    return kvo;
}

- (void)setCornerRadius:(CGFloat)radius mask:(CALayerCornerMask)mask{
    if (@available(iOS 11.0, *)) {
        self.cornerRadius = radius;
        self.maskedCorners = (CACornerMask)mask;
    } else if (mask == CALayerCornerMaskNone) {
        [self.boundsObserver invalidate];
        self.mask = nil;
    } else {
        __weak typeof(self) weakSelf = self;
        void (^setCornerLayer)(void) = ^{
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:weakSelf.bounds byRoundingCorners:(UIRectCorner)mask cornerRadii:CGSizeMake(radius, radius)];
            CAShapeLayer *mask = [[CAShapeLayer alloc] init];
            mask.frame = weakSelf.bounds;
            mask.path = path.CGPath;
            weakSelf.mask = mask;
        };
        [self.boundsObserver observe:self keyPath:@"bounds" options:NSKeyValueObservingOptionNew context:NULL changeHandler:^(NSDictionary<NSKeyValueChangeKey,id> * _Nullable change, void * _Nullable context) {
            setCornerLayer();
        }];
        setCornerLayer();
    }
}

@end
