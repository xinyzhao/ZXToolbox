//
// ZXTabBar.m
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

#import "ZXTabBar.h"

@implementation ZXTabBar

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize s = [super sizeThatFits:size];
    if (_customHeight > 0.f) {
        s.height += _customHeight - 49.f;
    }
    return s;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.isUserInteractionEnabled || self.isHidden || self.alpha <= 0.01) {
        return nil;
    }
    if ([self pointInside:point withEvent:event]) {
        return [self zx_hitTest:point withEvent:event];
    } else {
        CGFloat width = self.bounds.size.width / self.items.count;
        for (id obj in self.items) {
            if ([obj isKindOfClass:ZXTabBarItem.class]) {
                ZXTabBarItem *item = obj;
                NSInteger index = [self.items indexOfObject:obj];
                CGFloat left = index * width;
                CGFloat right = (index + 1) * width;
                //
                if (point.x < right && point.x > left) {
                    CGPoint overPoint = CGPointMake(point.x, point.y + item.overtopHeight);
                    UIView *view = [self zx_hitTest:overPoint withEvent:event];
                    if (view) {
                        return view;
                    }
                }
            }
        }
    }
    return nil;
}

- (UIView *)zx_hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *subview in [self.subviews reverseObjectEnumerator]) {
        CGPoint pt = [subview convertPoint:point fromView:self];
        UIView *hitTestView = [subview hitTest:pt withEvent:event];
        if (hitTestView) {
            return hitTestView;
        }
    }
    return nil;
}

@end
