//
// UIColor+ZXToolbox.h
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

#import <UIKit/UIKit.h>

/**
 Make color from HEX string, RGB format
 eg. @"0xRRGGBB", @"#RRGGBB", @"RRGGBB"
 
 @param string HEX color string
 @param alpha Alpha value
 @return UIColor
 */
UIKIT_EXTERN UIColor* UIColorFromHEX(NSString *string, CGFloat alpha);

/**
 Make color from integer value, RGB format
 eg. 0xRRGGBB
 
 @param value Integer color value
 @param alpha Alpha value
 @return UIColor
 */
UIKIT_EXTERN UIColor* UIColorFromRGB(NSInteger value, CGFloat alpha);

/**
 Return the HEX string of the color with prefix
 
 @param color UIColor
 @param prefix Prefix of color string, eg '#'
 @return HEX string of the color with prefix
 */
UIKIT_EXTERN NSString *UIColorToHEX(UIColor *color, NSString *prefix);

/**
 UIColor category
 */
@interface UIColor (ZXToolbox)

/**
 Make color from HEX string, RGB format
 eg. @"0xRRGGBB", @"#RRGGBB", @"RRGGBB"
 
 @param string HEX string, RGB format
 @return UIColor
 */
+ (instancetype)colorWithString:(NSString *)string;

/**
 Make color from HEX string, RGB format
 eg. @"0xRRGGBB", @"#RRGGBB", @"RRGGBB"

 @param string HEX string, RGB format
 @param alpha alpha value
 @return UIColor
 */
+ (instancetype)colorWithString:(NSString *)string alpha:(CGFloat)alpha;

/**
 Make color from integer value, RGB format
 eg. 0xRRGGBB
 
 @param value Integer value
 @return UIColor
 */
+ (instancetype)colorWithInteger:(NSInteger)value;

/**
 Make color from integer value, RGB format
 eg. 0xRRGGBB
 
 @param value Integer value
 @return UIColor
 */
+ (instancetype)colorWithInteger:(NSInteger)value alpha:(CGFloat)alpha;

/**
 Gen random color

 @return UIColor
 */
+ (UIColor *)randomColor;

/**
 Return the inverse color
 
 @return UIColor
 */
- (UIColor *)inverseColor;

/**
 Return the HEX string of the color
 
 @return HEX string of the color
 */
- (NSString *)stringValue;

/**
 Return the HEX string of the color with prefix

 @param prefix Prefix of color
 @return HEX string of the color with prefix
 */
- (NSString *)stringValueWithPrefix:(NSString *)prefix;

/**
 Return the integer value of the color
 
 @return NSInteger
 */
- (NSInteger)integerValue;

/**
 Return the integer value of the color

 @param alpha Whether or not include alpha value
 @return NSInteger
 */
- (NSInteger)integerValueWithAlpha:(BOOL)alpha;

/**
 Return the alpha value of the color

 @return Alpha value
 */
- (CGFloat)alpha;

/**
 Return the red value of the color

 @return Red value
 */
- (CGFloat)red;

/**
 Return the green value of the color
 
 @return Green value
 */
- (CGFloat)green;

/**
 Return the blue value of the color
 
 @return Blue value
 */
- (CGFloat)blue;

/**
 Return the hue value of the color
 
 @return Hue value
 */
- (CGFloat)hue;

/**
 Return the saturation value of the color
 
 @return Saturation value
 */
- (CGFloat)saturation;

/**
 Return the brightness value of the color
 
 @return Brightness value
 */
- (CGFloat)brightness;

@end
