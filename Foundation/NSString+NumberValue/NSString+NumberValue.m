//
// NSString+NumberValue.m
//
// Copyright (c) 2018 Zhao Xin (https://github.com/xinyzhao/ZXToolbox)
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

@end
