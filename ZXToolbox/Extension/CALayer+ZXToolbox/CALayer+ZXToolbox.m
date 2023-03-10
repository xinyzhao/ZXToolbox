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
#import <UIKit/UIKit.h>

static char cornerLayerKey;
static char cornerMasksKey;

@implementation CALayer (ZXToolbox)
- (void)setCornerLayer:(CAShapeLayer *)layer {
    [self setAssociatedObject:&cornerLayerKey value:layer policy:OBJC_ASSOCIATION_RETAIN];
}

- (CAShapeLayer *)cornerLayer {
    return [self getAssociatedObject:&cornerLayerKey];
}

- (void)setCornerMasks:(CALayerCornerMask)cornerMasks {
    [self setAssociatedObject:&cornerMasksKey value:@(cornerMasks) policy:OBJC_ASSOCIATION_RETAIN];
    if (@available(iOS 11.0, *)) {
        self.maskedCorners = (CACornerMask)cornerMasks;
    } else {
        [self.cornerLayer removeFromSuperlayer];
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:(UIRectCorner)cornerMasks cornerRadii:CGSizeMake(self.cornerRadius, self.cornerRadius)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = path.CGPath;
        self.mask = maskLayer;
    }
}

- (CALayerCornerMask)cornerMasks {
    NSNumber *value = [self getAssociatedObject:&cornerMasksKey];
    return [value unsignedIntValue];
}

@end
