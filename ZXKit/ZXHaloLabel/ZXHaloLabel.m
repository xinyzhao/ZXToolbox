//
// ZXHaloLabel.m
//
// Copyright (c) 2018 Zhao Xin (https://github.com/xinyzhao/ZXToolbox)
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

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _haloBlur = 4;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _haloBlur = 4;
    }
    return self;
}

- (UIColor *)haloColor {
    if (_haloColor == nil) {
        _haloColor = [UIColor whiteColor];
    }
    return _haloColor;
}

- (void)drawTextInRect: (CGRect)rect {
    CGFloat r,g,b,a;
    [self.haloColor getRed:&r green:&g blue:&b alpha:&a];
    CGFloat colors[] = {r, g, b, a};
    CGSize shadowOffest = CGSizeMake(0, 0);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef textColor = CGColorCreate(colorSpace, colors);

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextSetShadow(ctx, shadowOffest, self.haloBlur);
    CGContextSetShadowWithColor(ctx, shadowOffest, self.haloBlur, textColor);
    
    [super drawTextInRect:rect];

    CGColorRelease(textColor);
    CGColorSpaceRelease(colorSpace);
    CGContextRestoreGState(ctx);
}

@end
