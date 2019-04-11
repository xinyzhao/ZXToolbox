//
// NSString+Unicode.m
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

#import "NSString+Unicode.h"
#import "NSObject+ZXToolbox.h"

@implementation NSString (Unicode)

+ (NSString *)stringByReplacingUnicodeString:(NSString *)origin {
    NSMutableString *string = [origin mutableCopy];
    if (string.length > 0) {
        [string replaceOccurrencesOfString:@"\\U" withString:@"\\u" options:0 range:NSMakeRange(0, string.length)];
        CFStringRef transform = CFSTR("Any-Hex/Java");
        CFStringTransform((__bridge CFMutableStringRef)string, NULL, transform, YES);
    }
    return string;
}

- (NSUInteger)lengthOfUnicode {
    return [self lengthOfBytesUsingEncoding:NSUTF32StringEncoding] / 4;
}

@end

@implementation NSArray (Unicode)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleMethod:@selector(description) with:@selector(unicode_description)];
        [self swizzleMethod:@selector(descriptionWithLocale:) with:@selector(unicode_descriptionWithLocale:)];
        [self swizzleMethod:@selector(descriptionWithLocale:indent:) with:@selector(unicode_descriptionWithLocale:indent:)];
    });
}

- (NSString *)unicode_description {
    return [NSString stringByReplacingUnicodeString:[self unicode_description]];
}

- (NSString *)unicode_descriptionWithLocale:(nullable id)locale {
    return [NSString stringByReplacingUnicodeString:[self unicode_descriptionWithLocale:locale]];
}

- (NSString *)unicode_descriptionWithLocale:(nullable id)locale indent:(NSUInteger)level {
    return [NSString stringByReplacingUnicodeString:[self unicode_descriptionWithLocale:locale indent:level]];
}

@end

@implementation NSDictionary (Unicode)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleMethod:@selector(description) with:@selector(unicode_description)];
        [self swizzleMethod:@selector(descriptionWithLocale:) with:@selector(unicode_descriptionWithLocale:)];
        [self swizzleMethod:@selector(descriptionWithLocale:indent:) with:@selector(unicode_descriptionWithLocale:indent:)];
    });
}

- (NSString *)unicode_description {
    return [NSString stringByReplacingUnicodeString:[self unicode_description]];
}

- (NSString *)unicode_descriptionWithLocale:(nullable id)locale {
    return [NSString stringByReplacingUnicodeString:[self unicode_descriptionWithLocale:locale]];
}

- (NSString *)unicode_descriptionWithLocale:(nullable id)locale indent:(NSUInteger)level {
    return [NSString stringByReplacingUnicodeString:[self unicode_descriptionWithLocale:locale indent:level]];
}

@end

@implementation NSSet (Unicode)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleMethod:@selector(description) with:@selector(unicode_description)];
        [self swizzleMethod:@selector(descriptionWithLocale:) with:@selector(unicode_descriptionWithLocale:)];
        [self swizzleMethod:@selector(descriptionWithLocale:indent:) with:@selector(unicode_descriptionWithLocale:indent:)];
    });
}

- (NSString *)unicode_description {
    return [NSString stringByReplacingUnicodeString:[self unicode_description]];
}

- (NSString *)unicode_descriptionWithLocale:(nullable id)locale {
    return [NSString stringByReplacingUnicodeString:[self unicode_descriptionWithLocale:locale]];
}

- (NSString *)unicode_descriptionWithLocale:(nullable id)locale indent:(NSUInteger)level {
    return [NSString stringByReplacingUnicodeString:[self unicode_descriptionWithLocale:locale indent:level]];
}

@end
