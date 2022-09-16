//
// UITableViewCell+ZXToolbox.m
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2018 Zhao Xin
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

#import "UITableViewCell+ZXToolbox.h"
#import "NSObject+ZXToolbox.h"

static char separatorColorKey;
static char separatorInsetKey;

@implementation UITableViewCell (ZXToolbox)

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //
    if (self.separatorInset.top > 0.f) {
        CGPoint points[2];
        points[0] = CGPointMake(self.separatorInset.left, 0);
        points[1] = CGPointMake(self.frame.size.width - self.separatorInset.right, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, self.separatorInset.top);
        CGContextSetStrokeColorWithColor(context, self.separatorColor.CGColor);
        CGContextAddLines(context, points, 2);
        CGContextDrawPath(context, kCGPathStroke);
    }
    //
    if (self.separatorInset.bottom > 0.f) {
        CGPoint points[2];
        points[0] = CGPointMake(self.separatorInset.left, self.frame.size.height);
        points[1] = CGPointMake(self.frame.size.width - self.separatorInset.right, self.frame.size.height);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, self.separatorInset.bottom);
        CGContextSetStrokeColorWithColor(context, self.separatorColor.CGColor);
        CGContextAddLines(context, points, 2);
        CGContextDrawPath(context, kCGPathStroke);
    }
}

#pragma mark Getter & Setter

- (void)saveSeparatorColor:(UIColor *)separatorColor {
    [self setAssociatedObject:&separatorColorKey value:separatorColor policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (UIColor *)separatorColor {
    UIColor *color = [self getAssociatedObject:&separatorColorKey];
    if (color == nil) {
        color = [[UITableView alloc] init].separatorColor;
        self.separatorColor = color;
    }
    return color;
}

- (void)setSeparatorInset:(UIEdgeInsets)separatorInset {
    NSValue *value = [NSValue valueWithUIEdgeInsets:separatorInset];
    [self setAssociatedObject:&separatorInsetKey value:value policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (UIEdgeInsets)separatorInset {
    UIEdgeInsets inset = UIEdgeInsetsZero;
    NSValue *value = [self getAssociatedObject:&separatorInsetKey];
    if (value) {
        inset = [value UIEdgeInsetsValue];
    } else {
        inset = [[UITableView alloc] init].separatorInset;
        self.separatorInset = inset;
    }
    return inset;
}

@end
