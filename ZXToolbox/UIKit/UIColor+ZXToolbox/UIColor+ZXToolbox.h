//
// UIColor+ZXToolbox.h
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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Make color from HEX string in RGB order
/// Return black color if the color string is invalid.
/// @param string The HEX string, eg. @"0xRRGGBB", @"#RRGGBB", @"RRGGBB"
/// @param alpha The alpha value, value between 0.0 and 1.0.
UIKIT_EXTERN UIColor * UIColorFromHEXString(NSString *string, CGFloat alpha);

/// Make color from integer in RGB order
/// @param value An integer value, value between 0x000000 and 0xFFFFFF
/// @param alpha The alpha value, value between 0.0 and 1.0.
UIKIT_EXTERN UIColor * UIColorFromRGBInteger(NSInteger value, CGFloat alpha);

/// Make a HEX string in RGB order from UIColor without alpha value
/// @param color The UIColor
UIKIT_EXTERN NSString * NSStringFromUIColor(UIColor *color);

/// Make a integer in RGB order from UIColor without alpha value
/// @param color The UIColor
UIKIT_EXTERN NSInteger NSIntegerFromUIColor(UIColor *color);

/// The color components
typedef struct UIColorComponents {
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
} UIColorComponents;

/// UIColor category
@interface UIColor (ZXToolbox)

#ifdef UIColorWithHEXString
/// Make color from HEX string in RGB order
/// @param string The HEX string, eg. @"0xRRGGBB", @"#RRGGBB", @"RRGGBB"
+ (instancetype)UIColorWithHEXString:(NSString *)string;

/// Make color from HEX string in RGB order and alpha value
/// @param string The HEX string, eg. @"0xRRGGBB", @"#RRGGBB", @"RRGGBB"
/// @param alpha The alpha value, value between 0.0 and 1.0.
+ (instancetype)UIColorWithHEXString:(NSString *)string alpha:(CGFloat)alpha;
#else
/// Make color from HEX string in RGB order
/// @param string The HEX string, eg. @"0xRRGGBB", @"#RRGGBB", @"RRGGBB"
/// @attention: If the method name conflicts with another categories, PLEASE add macro definition UIColorWithHEXString to your project
+ (instancetype)colorWithHEXString:(NSString *)string;

/// Make color from HEX string in RGB order and alpha value
/// @param string The HEX string, eg. @"0xRRGGBB", @"#RRGGBB", @"RRGGBB"
/// @param alpha The alpha value, value between 0.0 and 1.0.
/// @attention: If the method name conflicts with another categories, PLEASE add macro definition UIColorWithHEXString to your project
+ (instancetype)colorWithHEXString:(NSString *)string alpha:(CGFloat)alpha;
#endif

#ifdef UIColorWithRGBInteger
/// Make color from integer in RGB order
/// @param value An integer value, value between 0x000000 and 0xFFFFFF
+ (instancetype)UIColorWithRGBInteger:(NSInteger)value;

/// Make color from integer in RGB order
/// @param value An integer value, value between 0x000000 and 0xFFFFFF
/// @param alpha The alpha value, value between 0.0 and 1.0.
+ (instancetype)UIColorWithRGBInteger:(NSInteger)value alpha:(CGFloat)alpha;

#else
/// Make color from integer in RGB order
/// @param value An integer value, value between 0x000000 and 0xFFFFFF
/// @attention: If the method name conflicts with another categories, PLEASE add macro definition UIColorWithRGBInteger to your project
+ (instancetype)colorWithRGBInteger:(NSInteger)value;

/// Make color from integer in RGB order
/// @param value An integer value, value between 0x000000 and 0xFFFFFF
/// @param alpha The alpha value, value between 0.0 and 1.0.
+ (instancetype)colorWithRGBInteger:(NSInteger)value alpha:(CGFloat)alpha;
/// @attention: If the method name conflicts with another categories, PLEASE add macro definition UIColorWithRGBInteger to your project
#endif

/// Get a random color
+ (UIColor *)randomColor;

/// Get the inverse color
- (UIColor *)inverseColor;

/// Get a HEX string in RGB order without alpha value
- (NSString *)NSStringValue;

/// Get a integer in RGB order without alpha value
- (NSInteger)NSIntegerValue;

/// Returns the grayscale components
- (UIColorComponents)grayscaleComponents;

/// Returns the components that form the color in the HSB color space.
- (UIColorComponents)HSBComponents;

/// Returns the components that form the color in the RGB color space.
- (UIColorComponents)RGBComponents;

@end

NS_ASSUME_NONNULL_END
