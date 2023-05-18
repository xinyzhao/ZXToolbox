//
// NSString+NumberValue.m
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
    return [self.numberValue charValue];
}

- (unsigned char)unsignedCharValue {
    return [self.numberValue unsignedCharValue];
}

- (short)shortValue {
    return [self.numberValue shortValue];
}

- (unsigned short)unsignedShortValue {
    return [self.numberValue unsignedShortValue];
}

- (unsigned int)unsignedIntValue {
    return [self.numberValue unsignedIntValue];
}

- (long)longValue {
    return [self.numberValue longValue];
}

- (unsigned long)unsignedLongValue {
    return [self.numberValue unsignedLongValue];
}

- (unsigned long long)unsignedLongLongValue {
    return [self.numberValue unsignedLongLongValue];
}

- (NSUInteger)unsignedIntegerValue {
    return [self.numberValue unsignedIntegerValue];
}

- (NSArray<NSNumber *> *)numberComponents {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:self.length];
    for (NSUInteger i = 0; i < self.length; i++) {
        NSString *str = [self substringWithRange:NSMakeRange(i, 1)];
        array[i] = [NSString numberFromString:str];
    }
    return array.count > 0 ? [array copy] : nil;
}

- (NSNumber *)numberValue {
    return [NSString numberFromString:self];
}

+ (NSString *)defaultAlphabet {
    return @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ !\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~";
}

+ (NSString *)stringWithValue:(id)value baseIn:(int)baseIn baseOut:(int)baseOut alphabet:(nullable NSString *)alphabet {
    // String
    NSString *str = nil;
    if ([value isKindOfClass:NSNumber.class]) {
        str = [[((NSNumber *)value) stringValue] uppercaseString];
    } else if ([value isKindOfClass:NSString.class]) {
        str = [value uppercaseString];
    } else {
        return nil;
    }
    // Alphabet
    if (alphabet == nil) {
        alphabet = [self defaultAlphabet];
    }
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
        int j = [arr[i - 1] intValue];
        if (j >= 0 && j < ALPHABET.count) {
            [strOut appendString:ALPHABET[j]];
        }
    }
    return [strOut copy];
}

+ (NSString *)stringWithValue:(id)value radix:(int)radix {
    return [NSString stringWithValue:value baseIn:radix baseOut:10 alphabet:nil];
    
}

- (NSString *)stringByRadix:(int)radix {
    return [NSString stringWithValue:self baseIn:10 baseOut:radix alphabet:nil];
}

- (NSString *)stringByReversed {
    NSMutableString *str = [[NSMutableString alloc] initWithCapacity:self.length];
    for (NSInteger i = self.length; i > 0; i--) {
        [str appendString:[self substringWithRange:NSMakeRange(i - 1, 1)]];
    }
    return [str copy];
}

@end
