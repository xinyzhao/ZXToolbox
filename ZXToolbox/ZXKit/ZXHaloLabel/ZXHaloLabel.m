//
// ZXHaloLabel.m
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

#import "ZXHaloLabel.h"

@implementation ZXHaloLabel
@synthesize haloColor = _haloColor;

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.layer.shadowRadius = 2;
        self.layer.shadowColor = [UIColor whiteColor].CGColor;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowOpacity = 1.0;
        self.shadowOffset = CGSizeZero;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.shadowRadius = 2;
        self.layer.shadowColor = [UIColor whiteColor].CGColor;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowOpacity = 1.0;
        self.shadowOffset = CGSizeZero;
    }
    return self;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = [borderColor copy];
    [self setNeedsDisplay];
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    [self setNeedsDisplay];
}

- (void)setHaloColor:(UIColor *)haloColor {
    self.layer.shadowColor = haloColor.CGColor;
}

- (UIColor *)haloColor {
    UIColor *color = nil;
    if (self.layer.shadowColor) {
        color = [UIColor colorWithCGColor:self.layer.shadowColor];
    }
    return color;
}

- (void)setHaloRadius:(CGFloat)haloRadius {
    self.layer.shadowRadius = haloRadius;
}

- (CGFloat)haloRadius {
    return self.layer.shadowRadius;
}

- (void)drawTextInRect: (CGRect)rect {
    if (self.borderWidth > 0.0 || self.haloRadius > 0.0) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        UIColor *textColor = self.textColor;
        // Drawing border
        if (self.borderColor) {
            CGContextSetLineWidth(context, self.borderWidth);
            CGContextSetLineJoin(context, kCGLineJoinRound);
            CGContextSetTextDrawingMode(context, kCGTextStroke);
            self.textColor = self.borderColor;
            [super drawTextInRect:rect];
        }
        // Drawing text
        CGContextSetTextDrawingMode(context, kCGTextFill);
        self.textColor = textColor;
        [super drawTextInRect:rect];
    } else {
        [super drawTextInRect:rect];
    }
}

@end
