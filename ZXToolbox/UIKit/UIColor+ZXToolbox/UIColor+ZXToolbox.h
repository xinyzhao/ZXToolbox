//
// UIColor+ZXToolbox.h
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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#ifndef _UIColorFromHEXString_
/// Make color from HEX string in RGB order
/// Return black color if the color string is invalid.
/// @param string The HEX string, eg. @"0xRRGGBB", @"#RRGGBB", @"RRGGBB"
/// @param alpha The alpha value, value between 0.0 and 1.0.
/// @return Return black color with alpha If the color string is invalid
/// @attention If the method name has conflicts, PLEASE add macro definition _UIColorFromHEXString_ to your project "Build Settings" -> "Preprocessor Macros"
UIKIT_EXTERN UIColor * UIColorFromHEXString(NSString *string, CGFloat alpha);
#endif//_UIColorFromHEXString_

#ifndef _UIColorFromRGBInteger_
/// Make color from integer in RGB order
/// @param value An integer value, value between 0x000000 and 0xFFFFFF
/// @param alpha The alpha value, value between 0.0 and 1.0.
/// @attention If the method name has conflicts, PLEASE add macro definition _UIColorFromRGBInteger_ to your project "Build Settings" -> "Preprocessor Macros"
UIKIT_EXTERN UIColor * UIColorFromRGBInteger(NSInteger value, CGFloat alpha);
#endif//_UIColorFromRGBInteger_

#ifndef _NSStringFromUIColor_
/// Make a HEX string in RGB order from UIColor without alpha value
/// @param color The UIColor
/// @attention If the method name has conflicts, PLEASE add macro definition _NSStringFromUIColor_ to your project "Build Settings" -> "Preprocessor Macros"
UIKIT_EXTERN NSString * NSStringFromUIColor(UIColor *color);
#endif//_NSStringFromUIColor_

#ifndef _NSIntegerFromUIColor_
/// Make a integer in RGB order from UIColor without alpha value
/// @param color The UIColor
/// @attention If the method name has conflicts, PLEASE add macro definition _NSIntegerFromUIColor_ to your project "Build Settings" -> "Preprocessor Macros"
UIKIT_EXTERN NSInteger NSIntegerFromUIColor(UIColor *color);
#endif//_NSIntegerFromUIColor_

#ifndef _ZXColorComponents_
#define _ZXColorComponents_
/// The color components
typedef struct ZXColorComponents {
    CGFloat alpha;
    union {
        /// The grayscale components
        struct {
            CGFloat white;
        };
        /// The components that form the color in the HSB color space.
        struct {
            CGFloat hue;
            CGFloat saturation;
            CGFloat brightness;
        };
        /// The components that form the color in the RGB color space.
        struct {
            CGFloat red;
            CGFloat green;
            CGFloat blue;
        };
    };
} ZXColorComponents;
#endif//_ZXColorComponents_

#ifndef _UIColorComponents_
typedef ZXColorComponents UIColorComponents;
#endif//_UIColorComponents_

/// Make color from HEX string in RGB order
/// Return black color if the color string is invalid.
/// @param string The HEX string, eg. @"0xRRGGBB", @"#RRGGBB", @"RRGGBB"
/// @param alpha The alpha value, value between 0.0 and 1.0.
UIKIT_EXTERN UIColor * ZXColorFromHEXString(NSString *string, CGFloat alpha);

/// Make color from integer in RGB order
/// @param value An integer value, value between 0x000000 and 0xFFFFFF
/// @param alpha The alpha value, value between 0.0 and 1.0.
UIKIT_EXTERN UIColor * ZXColorFromRGBInteger(NSInteger value, CGFloat alpha);

/// Make a HEX string in RGB order from UIColor without alpha value
/// @param color The UIColor
UIKIT_EXTERN NSString * ZXStringFromUIColor(UIColor *color);

/// Make a integer in RGB order from UIColor without alpha value
/// @param color The UIColor
UIKIT_EXTERN NSInteger ZXIntegerFromUIColor(UIColor *color);

/// UIColor category
@interface UIColor (ZXToolbox)

#ifndef _UIColorWithHEXString_
/// Make color from HEX string in RGB order
/// @param string The HEX string, eg. @"0xRRGGBB", @"#RRGGBB", @"RRGGBB"
/// @attention If the method name conflicts with another categories, PLEASE add macro definition _UIColorWithHEXString_ to your project "Build Settings" -> "Preprocessor Macros"
+ (instancetype)colorWithHEXString:(NSString *)string;

/// Make color from HEX string in RGB order and alpha value
/// @param string The HEX string, eg. @"0xRRGGBB", @"#RRGGBB", @"RRGGBB"
/// @param alpha The alpha value, value between 0.0 and 1.0.
/// @attention If the method name conflicts with another categories, PLEASE add macro definition _UIColorWithHEXString_ to your project "Build Settings" -> "Preprocessor Macros"
+ (instancetype)colorWithHEXString:(NSString *)string alpha:(CGFloat)alpha;
#endif//_UIColorWithHEXString_

#ifndef _UIColorWithRGBInteger_
/// Make color from integer in RGB order
/// @param value An integer value, value between 0x000000 and 0xFFFFFF
/// @attention If the method name conflicts with another categories, PLEASE add macro definition _UIColorWithRGBInteger_ to your project "Build Settings" -> "Preprocessor Macros"
+ (instancetype)colorWithRGBInteger:(NSInteger)value;

/// Make color from integer in RGB order
/// @param value An integer value, value between 0x000000 and 0xFFFFFF
/// @param alpha The alpha value, value between 0.0 and 1.0.
/// @attention If the method name conflicts with another categories, PLEASE add macro definition _UIColorWithRGBInteger_ to your project "Build Settings" -> "Preprocessor Macros"
+ (instancetype)colorWithRGBInteger:(NSInteger)value alpha:(CGFloat)alpha;
#endif//_UIColorWithRGBInteger_

/// Get a random color
+ (UIColor *)randomColor;

/// Get the inverse color
- (UIColor *)inverseColor;

/// Get a HEX string in RGB order without alpha value
- (NSString *)NSStringValue;

/// Get a integer in RGB order without alpha value
- (NSInteger)NSIntegerValue;

/// Returns the grayscale components
- (ZXColorComponents)grayscaleComponents;

/// Returns the components that form the color in the HSB color space.
- (ZXColorComponents)HSBComponents;

/// Returns the components that form the color in the RGB color space.
- (ZXColorComponents)RGBComponents;

@end

NS_ASSUME_NONNULL_END
