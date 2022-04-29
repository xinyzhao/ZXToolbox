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
    NSRange range = [string rangeOfString:@"[a-fA-F0-9]{6}" options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        unsigned int hex = 0;
        NSString *str = [string substringWithRange:range];
        [[NSScanner scannerWithString:str] scanHexInt:&hex];
        return UIColorFromRGBInteger(hex, alpha);
    }
    return [UIColor colorWithWhite:0 alpha:alpha];
}

UIColor * UIColorFromRGBInteger(NSInteger value, CGFloat alpha) {
    CGFloat r = ((value & 0x00ff0000) >> 16) / (double)255.f;
    CGFloat g = ((value & 0x0000ff00) >> 8) / (double)255.f;
    CGFloat b = (value & 0x000000ff) / (double)255.f;
    return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
}

NSString * NSStringFromUIColor(UIColor *color) {
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    return [NSString stringWithFormat:@"%02X%02X%02X",
            (int)roundf(r * 255),
            (int)roundf(g * 255),
            (int)roundf(b * 255)];
}

NSInteger NSIntegerFromUIColor(UIColor *color) {
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

#ifdef UIColorWithHEXString
+ (instancetype)UIColorWithHEXString:(NSString *)string {
    return UIColorFromHEXString(string, 1.f);
}

+ (instancetype)UIColorWithHEXString:(NSString *)string alpha:(CGFloat)alpha {
    return UIColorFromHEXString(string, alpha);
}
#else
+ (instancetype)colorWithHEXString:(NSString *)string {
    return UIColorFromHEXString(string, 1.f);
}

+ (instancetype)colorWithHEXString:(NSString *)string alpha:(CGFloat)alpha {
    return UIColorFromHEXString(string, alpha);
}
#endif

#ifdef UIColorWithRGBInteger
+ (instancetype)UIColorWithRGBInteger:(NSInteger)value {
    return UIColorFromRGBInteger(value, 1.f);
}

+ (instancetype)UIColorWithRGBInteger:(NSInteger)value alpha:(CGFloat)alpha {
    return UIColorFromRGBInteger(value, alpha);
}
#else
+ (instancetype)colorWithRGBInteger:(NSInteger)value {
    return UIColorFromRGBInteger(value, 1.f);
}

+ (instancetype)colorWithRGBInteger:(NSInteger)value alpha:(CGFloat)alpha {
    return UIColorFromRGBInteger(value, alpha);
}
#endif

+ (UIColor *)randomColor {
    CGFloat r = (arc4random() % 256) / 255.f;
    CGFloat g = (arc4random() % 256) / 255.f;
    CGFloat b = (arc4random() % 256) / 255.f;
    return [UIColor colorWithRed:r green:g blue:b alpha:1.f];;
}

- (UIColor *)inverseColor {
    UIColorComponents cc = [self RGBComponents];
    return [UIColor colorWithRed:(1.f - cc.red) green:(1.f - cc.green) blue:(1.f - cc.blue) alpha:cc.alpha];
}

- (NSString *)NSStringValue {
    return NSStringFromUIColor(self);
}

- (NSInteger)NSIntegerValue {
    return NSIntegerFromUIColor(self);
}

- (UIColorComponents)grayscaleComponents {
    UIColorComponents cc;
    [self getWhite:&cc.white alpha:&cc.alpha];
    return cc;
}

- (UIColorComponents)HSBComponents {
    UIColorComponents cc;
    [self getHue:&cc.hue saturation:&cc.saturation brightness:&cc.brightness alpha:&cc.alpha];
    return cc;
}

- (UIColorComponents)RGBComponents {
    UIColorComponents cc;
    [self getRed:&cc.red green:&cc.green blue:&cc.blue alpha:&cc.alpha];
    return cc;
}

@end
