//
// ZXTextAttributes.h
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2021 Zhao Xin
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

@interface ZXTextAttributes : NSObject
/// UIFont, default Helvetica(Neue) 12
@property (nonatomic, strong, nullable) UIFont *font;
/// NSParagraphStyle, default defaultParagraphStyle
@property (nonatomic, strong, nullable) NSMutableParagraphStyle *paragraphStyle;
/// UIColor, default blackColor
@property (nonatomic, strong, nullable) UIColor *foregroundColor;
/// UIColor, default nil: no background
@property (nonatomic, strong, nullable) UIColor *backgroundColor;
/// Integer, default 1: default ligatures, 0: no ligatures
@property (nonatomic, assign) NSInteger ligature;
/// Floating point value, in points; amount to modify default kerning. 0 means kerning is disabled.
@property (nonatomic, assign) CGFloat kern;
/// Floating point value, in points; amount to modify default tracking. 0 means tracking is disabled.
@property (nonatomic, assign) CGFloat tracking;
/// Integer, default 0: no strikethrough
/// @see NSUnderlineStyle
@property (nonatomic, assign) NSUnderlineStyle strikethroughStyle;
/// Integer, default 0: no underline
/// @see NSUnderlineStyle
@property (nonatomic, assign) NSUnderlineStyle underlineStyle;
/// UIColor, default nil: same as foreground color
@property (nonatomic, strong, nullable) UIColor *strokeColor;
/// Floating point value, in percent of font point size, default 0: no stroke; positive for stroke alone, negative for stroke and fill (a typical value for outlined text would be 3.0)
@property (nonatomic, assign) CGFloat strokeWidth;
/// NSShadow, default nil: no shadow
@property (nonatomic, strong, nullable) NSShadow *shadow;
/// NSString, default nil: no text effect
@property (nonatomic, strong, nullable) NSString *textEffect;
/// NSTextAttachment, default nil
@property (nonatomic, strong, nullable) NSTextAttachment *attachment;
/// NSURL (preferred) or NSString
@property (nonatomic, strong, nullable) id link;
/// Floating point value, in points; offset from baseline, default 0
@property (nonatomic, assign) CGFloat baselineOffset;
/// UIColor, default nil: same as foreground color
@property (nonatomic, strong, nullable) UIColor *underlineColor;
/// UIColor, default nil: same as foreground color
@property (nonatomic, strong, nullable) UIColor *strikethroughColor;
/// Floating point value; skew to be applied to glyphs, default 0: no skew
@property (nonatomic, assign) CGFloat obliqueness;
/// Floating point value; log of expansion factor to be applied to glyphs, default 0: no expansion
@property (nonatomic, assign) CGFloat expansion;
/// NSArray of NSNumbers representing the nested levels of writing direction overrides as defined by Unicode LRE, RLE, LRO, and RLO characters.
/// @see NSWritingDirectionFormatType
@property (nonatomic, assign) NSInteger writingDirection;
/// An NSNumber containing an integer value.  0 means horizontal text.  1 indicates vertical text.  If not specified, it could follow higher-level vertical orientation settings.  Currently on iOS, it's always horizontal.  The behavior for any other value is undefined.
@property (nonatomic, assign) NSInteger verticalGlyphForm;
@end

@interface ZXTextAttributes (Conveniences)
/// Initialization with host object
/// @param object The host object
- (instancetype)initWithHost:(id)object;

/// The attributes
@property (nonatomic, readonly) NSDictionary<NSAttributedStringKey, id> *attributes;

/// Creates an attributed string with the specified string and attributes.
/// @param string The string
- (NSAttributedString *)attributedString:(NSString *)string;

/// Creates and sets the attributed string for the NSKeyValueCoding key to the host object
/// @param string The string
/// @param key The specified key
- (void)setAttributedString:(NSString *)string forKey:(NSString *)key;

/// Remove the attributed string for the NSKeyValueCoding key from the host object
/// @param key The specified key
- (void)removeAttributedStringForKey:(NSString *)key;

@end

@interface NSObject (ZXTextAttributes)
/// A convenience property for attributed string
@property (nonatomic, strong) ZXTextAttributes *textAttributes;

@end

NS_ASSUME_NONNULL_END
