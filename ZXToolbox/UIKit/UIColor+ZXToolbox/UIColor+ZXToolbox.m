//
// UIColor+ZXToolbox.m
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

#import "UIColor+ZXToolbox.h"

UIColor * UIColorFromHEXString(NSString *string, CGFloat alpha) {
    return ZXColorFromHEXString(string, alpha);
}

UIColor * UIColorFromRGBInteger(NSInteger value, CGFloat alpha) {
    return ZXColorFromRGBInteger(value, alpha);
}

NSString * NSStringFromUIColor(UIColor *color) {
    return ZXStringFromUIColor(color);
}

NSInteger NSIntegerFromUIColor(UIColor *color) {
    return ZXIntegerFromUIColor(color);
}

UIColor * ZXColorFromHEXString(NSString *string, CGFloat alpha) {
    NSRange range = [string rangeOfString:@"[a-fA-F0-9]{6}" options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        unsigned int hex = 0;
        NSString *str = [string substringWithRange:range];
        [[NSScanner scannerWithString:str] scanHexInt:&hex];
        return ZXColorFromRGBInteger(hex, alpha);
    }
    return [UIColor colorWithWhite:0 alpha:alpha];
}

UIColor * ZXColorFromRGBInteger(NSInteger value, CGFloat alpha) {
    CGFloat r = ((value & 0x00ff0000) >> 16) / (double)255.f;
    CGFloat g = ((value & 0x0000ff00) >> 8) / (double)255.f;
    CGFloat b = (value & 0x000000ff) / (double)255.f;
    return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
}

NSString * ZXStringFromUIColor(UIColor *color) {
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    return [NSString stringWithFormat:@"%02X%02X%02X",
            (int)roundf(r * 255),
            (int)roundf(g * 255),
            (int)roundf(b * 255)];
}

NSInteger ZXIntegerFromUIColor(UIColor *color) {
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    //
    NSString *str = [NSString stringWithFormat:@"%02X%02X%02X",
                     (int)roundf(r * 255),
                     (int)roundf(g * 255),
                     (int)roundf(b * 255)];
    //
    unsigned int hex = 0;
    [[NSScanner scannerWithString:str] scanHexInt:&hex];
    return hex;
}

@implementation UIColor (ZXToolbox)

+ (instancetype)colorWithHEXString:(NSString *)string {
    return ZXColorFromHEXString(string, 1.f);
}

+ (instancetype)colorWithHEXString:(NSString *)string alpha:(CGFloat)alpha {
    return ZXColorFromHEXString(string, alpha);
}

+ (instancetype)colorWithRGBInteger:(NSInteger)value {
    return ZXColorFromRGBInteger(value, 1.f);
}

+ (instancetype)colorWithRGBInteger:(NSInteger)value alpha:(CGFloat)alpha {
    return ZXColorFromRGBInteger(value, alpha);
}

+ (UIColor *)randomColor {
    CGFloat r = (arc4random() % 256) / 255.f;
    CGFloat g = (arc4random() % 256) / 255.f;
    CGFloat b = (arc4random() % 256) / 255.f;
    return [UIColor colorWithRed:r green:g blue:b alpha:1.f];;
}

- (UIColor *)inverseColor {
    ZXColorComponents cc = [self RGBComponents];
    return [UIColor colorWithRed:(1.f - cc.red) green:(1.f - cc.green) blue:(1.f - cc.blue) alpha:cc.alpha];
}

- (NSString *)NSStringValue {
    return ZXStringFromUIColor(self);
}

- (NSInteger)NSIntegerValue {
    return ZXIntegerFromUIColor(self);
}

- (ZXColorComponents)grayscaleComponents {
    ZXColorComponents cc;
    [self getWhite:&cc.white alpha:&cc.alpha];
    return cc;
}

- (ZXColorComponents)HSBComponents {
    ZXColorComponents cc;
    [self getHue:&cc.hue saturation:&cc.saturation brightness:&cc.brightness alpha:&cc.alpha];
    return cc;
}

- (ZXColorComponents)RGBComponents {
    ZXColorComponents cc;
    [self getRed:&cc.red green:&cc.green blue:&cc.blue alpha:&cc.alpha];
    return cc;
}

@end
