//
// UIColor+ZXToolbox.m
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

#import "UIColor+ZXToolbox.h"

UIColor* UIColorFromHEX(NSString *string, CGFloat alpha) {
    NSRange range = [string rangeOfString:@"[a-fA-F0-9]{6}" options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        unsigned int hex = 0;
        NSString *str = [string substringWithRange:range];
        [[NSScanner scannerWithString:str] scanHexInt:&hex];
        return UIColorFromRGB(hex, alpha);
    }
    return nil;
}

UIColor* UIColorFromRGB(NSInteger value, CGFloat alpha) {
//    CGFloat a = 1.f;
//    if ((value & 0xff000000)) {
//        a = ((value & 0xff000000) >> 24) / 255.f;
//    }
    CGFloat r = ((value & 0x00ff0000) >> 16) / (double)255.f;
    CGFloat g = ((value & 0x0000ff00) >> 8) / (double)255.f;
    CGFloat b = (value & 0x000000ff) / (double)255.f;
    return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
}

NSString *UIColorToHEX(UIColor *color, NSString *prefix) {
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    return [NSString stringWithFormat:@"%@%02x%02x%02x", prefix ? prefix : @"",
            (int)roundf(r * 255),
            (int)roundf(g * 255),
            (int)roundf(b * 255)];
}

NSInteger UIColorToRGB(UIColor *color, BOOL alpha) {
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    //
    NSString *str = [NSString stringWithFormat:@"%02x%02x%02x%02x",
                     alpha ? (int)roundf(a * 255) : 0x00,
                     (int)roundf(r * 255),
                     (int)roundf(g * 255),
                     (int)roundf(b * 255)];
    //
    unsigned int hex = 0;
    [[NSScanner scannerWithString:str] scanHexInt:&hex];
    return hex;
}

@implementation UIColor (ZXToolbox)

+ (instancetype)colorWithString:(NSString *)string {
    return UIColorFromHEX(string, 1.f);
}

+ (instancetype)colorWithString:(NSString *)string alpha:(CGFloat)alpha {
    return UIColorFromHEX(string, alpha);
}

+ (instancetype)colorWithInteger:(NSInteger)value {
    return UIColorFromRGB(value, 1.f);
}

+ (instancetype)colorWithInteger:(NSInteger)value alpha:(CGFloat)alpha {
    return UIColorFromRGB(value, alpha);
}

+ (UIColor *)randomColor {
    CGFloat r = (arc4random() % 256) / 255.f;
    CGFloat g = (arc4random() % 256) / 255.f;
    CGFloat b = (arc4random() % 256) / 255.f;
    return [UIColor colorWithRed:r green:g blue:b alpha:1.f];;
}

- (UIColor *)inverseColor {
    CGFloat r,g,b,a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    return [UIColor colorWithRed:(1.f - r) green:(1.f - g) blue:(1.f - b) alpha:a];
}

- (NSString *)stringValue {
    return UIColorToHEX(self, nil);
}

- (NSString *)stringValueWithPrefix:(NSString *)prefix {
    return UIColorToHEX(self, prefix);
}

- (NSInteger)integerValue {
    return UIColorToRGB(self, NO);
}

- (NSInteger)integerValueWithAlpha:(BOOL)alpha {
    return UIColorToRGB(self, alpha);
}

- (CGFloat)alpha {
    return CGColorGetAlpha(self.CGColor);
}

- (CGFloat)red {
    CGFloat r,g,b,a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    return r;
}

- (CGFloat)green {
    CGFloat r,g,b,a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    return g;
}

- (CGFloat)blue {
    CGFloat r,g,b,a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    return b;
}

- (CGFloat)hue {
    CGFloat h,s,b,a;
    [self getHue:&h saturation:&s brightness:&b alpha:&a];
    return h;
}

- (CGFloat)saturation {
    CGFloat h,s,b,a;
    [self getHue:&h saturation:&s brightness:&b alpha:&a];
    return s;
}

- (CGFloat)brightness {
    CGFloat h,s,b,a;
    [self getHue:&h saturation:&s brightness:&b alpha:&a];
    return b;
}

@end
