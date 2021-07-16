//
// ZXTextAttributes.m
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

#import "ZXTextAttributes.h"
#import <objc/runtime.h>

@interface ZXTextAttributes ()
@property (nonatomic, weak, nullable) id hostObject;
@property (nonatomic, strong) NSMutableDictionary *oldValues;

@end

@implementation ZXTextAttributes : NSObject

- (instancetype)init {
    self = [super init];
    if (self) {
        _oldValues = [[NSMutableDictionary alloc] init];
        _paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    }
    return self;
}

@end

@implementation ZXTextAttributes (Conveniences)

- (instancetype)initWithHost:(id)object {
    self = [self init];
    if (self) {
        _hostObject = object;
    }
    return self;
}

- (NSDictionary<NSAttributedStringKey, id> *)attributes {
    NSMutableDictionary<NSAttributedStringKey, id> *dict = [[NSMutableDictionary alloc] init];
    if (_font) {
        dict[NSFontAttributeName] = _font;
    }
    if (_paragraphStyle) {
        dict[NSParagraphStyleAttributeName] = _paragraphStyle;
    }
    if (_foregroundColor) {
        dict[NSForegroundColorAttributeName] = _foregroundColor;
    }
    if (_backgroundColor) {
        dict[NSBackgroundColorAttributeName] = _backgroundColor;
    }
    if (_ligature) {
        dict[NSLigatureAttributeName] = @(_ligature);
    }
    if (_kern) {
        dict[NSKernAttributeName] = @(_kern);
    }
    if (_tracking) {
        if (@available(iOS 14.0, *)) {
            dict[NSTrackingAttributeName] = @(_tracking);
        }
    }
    if (_strikethroughStyle) {
        dict[NSStrikethroughStyleAttributeName] = @(_strikethroughStyle);
    }
    if (_underlineStyle) {
        dict[NSUnderlineStyleAttributeName] = @(_underlineStyle);
    }
    if (_strokeColor) {
        dict[NSStrokeColorAttributeName] = _strokeColor;
    }
    if (_strokeWidth) {
        dict[NSStrokeWidthAttributeName] = @(_strokeWidth);
    }
    if (_shadow) {
        dict[NSShadowAttributeName] = _shadow;
    }
    if (_textEffect) {
        dict[NSTextEffectAttributeName] = _textEffect;
    }
    if (_attachment) {
        dict[NSAttachmentAttributeName] = _attachment;
    }
    if (_link && ([_link isKindOfClass:NSURL.class] || [_link isKindOfClass:NSString.class])) {
        dict[NSLinkAttributeName] = _link;
    }
    if (_baselineOffset) {
        dict[NSBaselineOffsetAttributeName] = @(_baselineOffset);
    }
    if (_underlineColor) {
        dict[NSUnderlineColorAttributeName] = _underlineColor;
    }
    if (_strikethroughColor) {
        dict[NSStrikethroughColorAttributeName] = _strikethroughColor;
    }
    if (_obliqueness) {
        dict[NSObliquenessAttributeName] = @(_obliqueness);
    }
    if (_expansion) {
        dict[NSExpansionAttributeName] = @(_expansion);
    }
    if (_writingDirection) {
        dict[NSWritingDirectionAttributeName] = @(_writingDirection);
    }
    if (_verticalGlyphForm) {
        dict[NSVerticalGlyphFormAttributeName] = @(_verticalGlyphForm);
    }
    return [dict copy];
}

- (NSAttributedString *)attributedString:(NSString *)string {
    return [[NSAttributedString alloc] initWithString:string attributes:self.attributes];
}

- (void)setAttributedString:(NSString *)string forKey:(NSString *)key {
    [self removeAttributedStringForKey:key];
    NSAttributedString *oldValue = [_hostObject valueForKey:key];
    if (oldValue) {
        _oldValues[key] = oldValue;
    }
    [_hostObject setValue:[self attributedString:string] forKey:key];
}

- (void)removeAttributedStringForKey:(NSString *)key {
    NSAttributedString *oldValue = _oldValues[key];
    if (oldValue) {
        [_hostObject setValue:oldValue forKey:key];
    }
    [_oldValues removeObjectForKey:key];
}

@end

@implementation NSObject (ZXTextAttributes)

- (ZXTextAttributes *)textAttributes {
    ZXTextAttributes *obj = objc_getAssociatedObject(self, @selector(textAttributes));
    if (obj == nil) {
        obj = [[ZXTextAttributes alloc] initWithHost:self];
        objc_setAssociatedObject(self, @selector(textAttributes), obj, OBJC_ASSOCIATION_RETAIN);
    }
    return obj;
}

- (void)setTextAttributes:(ZXTextAttributes *)att {
    objc_setAssociatedObject(self, @selector(textAttributes), att, OBJC_ASSOCIATION_RETAIN);
}

@end
