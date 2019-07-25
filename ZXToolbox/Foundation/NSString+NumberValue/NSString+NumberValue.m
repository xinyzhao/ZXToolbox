//
// NSString+NumberValue.m
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

#import "NSString+NumberValue.h"

@implementation NSString (NumberValue)

+ (NSNumberFormatter *)numberFormatter {
    static NSNumberFormatter *numberFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        numberFormatter = [[NSNumberFormatter alloc] init];
    });
    numberFormatter.positiveFormat = nil;
    return numberFormatter;
}

+ (NSNumber *)numberFromString:(NSString *)string {
    return [[NSString numberFormatter] numberFromString:string];
}

+ (NSString *)stringWithNumber:(NSNumber *)number {
    return [[NSString numberFormatter] stringFromNumber:number];
}

+ (NSString *)stringWithNumber:(NSNumber *)number format:(NSString *)format {
    NSNumberFormatter *nf = [NSString numberFormatter];
    nf.positiveFormat = format;
    return [nf stringFromNumber:number];
}

- (NSString *)stringWithNumberFormat:(NSString *)format {
    NSNumberFormatter *nf = [NSString numberFormatter];
    NSNumber *number = [nf numberFromString:self];
    nf.positiveFormat = format;
    return [nf stringFromNumber:number];
}

- (char)charValue {
    return [[[NSString numberFormatter] numberFromString:self] charValue];
}

- (unsigned char)unsignedCharValue {
    return [[[NSString numberFormatter] numberFromString:self] unsignedCharValue];
}

- (short)shortValue {
    return [[[NSString numberFormatter] numberFromString:self] shortValue];
}

- (unsigned short)unsignedShortValue {
    return [[[NSString numberFormatter] numberFromString:self] unsignedShortValue];
}

- (unsigned int)unsignedIntValue {
    return [[[NSString numberFormatter] numberFromString:self] unsignedIntValue];
}

- (long)longValue {
    return [[[NSString numberFormatter] numberFromString:self] longValue];
}

- (unsigned long)unsignedLongValue {
    return [[[NSString numberFormatter] numberFromString:self] unsignedLongValue];
}

- (unsigned long long)unsignedLongLongValue {
    return [[[NSString numberFormatter] numberFromString:self] unsignedLongLongValue];
}

- (NSUInteger)unsignedIntegerValue {
    return [[[NSString numberFormatter] numberFromString:self] unsignedIntegerValue];
}

+ (NSString *)stringWithValue:(id)value baseIn:(int)baseIn baseOut:(int)baseOut uppercase:(BOOL)uppercase {
    // String
    NSString *str = nil;
    if ([value isKindOfClass:NSNumber.class]) {
        str = [((NSNumber *)value) stringValue];
    } else if ([value isKindOfClass:NSString.class]) {
        str = value;
    } else {
        return nil;
    }
    str = uppercase ? [str uppercaseString] : [str lowercaseString];
    // Alphabet
    NSString *alphabet = uppercase ? @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ" : @"0123456789abcdefghijklmnopqrstuvwxyz";
    NSMutableArray *ALPHABET = [[NSMutableArray alloc] initWithCapacity:alphabet.length];
    for (int i = 0; i < alphabet.length; i++) {
        [ALPHABET addObject:[alphabet substringWithRange:NSMakeRange(i, 1)]];
    }
    // Base
    if (baseIn == baseOut) {
        return str;
    }
    if (baseIn < 2 || baseIn > alphabet.length ||
        baseOut < 2 || baseOut > alphabet.length) {
        return nil;
    }
    // Array
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i = 0; i < str.length; i++) {
        for (int l = (int)arr.count - 1; l >= 0; l--) {
            arr[l] = @([arr[l] intValue] * baseIn);
        }
        if (arr.count == 0) {
            [arr addObject:@(0)];
        }
        arr[0] = @([arr[0] intValue] + (int)[ALPHABET indexOfObject:[str substringWithRange:NSMakeRange(i, 1)]]);
        for (int j = 0; j < arr.count; j++) {
            if ([arr[j] intValue] > baseOut - 1) {
                if (j + 1 >= arr.count) {
                    [arr addObject:@(0)];
                }
                arr[j + 1] = @([arr[j + 1] intValue] + ([arr[j] intValue] / baseOut | 0));
                arr[j] = @([arr[j] intValue] % baseOut);
            }
        }
    }
    // Reverse
    NSMutableString *strOut = [[NSMutableString alloc] initWithCapacity:arr.count];
    for (int i = (int)arr.count; i > 0; i--) {
        [strOut appendString:ALPHABET[[arr[i - 1] intValue]]];
    }
    return [strOut copy];
}

+ (NSString *)stringWithValue:(id)value radix:(int)radix uppercase:(BOOL)uppercase {
    return [NSString stringWithValue:value baseIn:radix baseOut:10 uppercase:uppercase];
    
}

- (NSString *)stringByRadix:(int)radix uppercase:(BOOL)uppercase {
    return [NSString stringWithValue:self baseIn:10 baseOut:radix uppercase:uppercase];
}

- (NSString *)stringByReversed {
    NSMutableString *str = [[NSMutableString alloc] initWithCapacity:self.length];
    for (NSInteger i = self.length; i > 0; i--) {
        [str appendString:[self substringWithRange:NSMakeRange(i - 1, 1)]];
    }
    return [str copy];
}

@end
