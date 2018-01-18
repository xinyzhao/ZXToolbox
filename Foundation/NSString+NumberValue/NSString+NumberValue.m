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

- (char)charValue {
    return [[[[NSNumberFormatter alloc] init] numberFromString:self] charValue];
}

- (unsigned char)unsignedCharValue {
    return [[[[NSNumberFormatter alloc] init] numberFromString:self] unsignedCharValue];
}

- (short)shortValue {
    return [[[[NSNumberFormatter alloc] init] numberFromString:self] shortValue];
}

- (unsigned short)unsignedShortValue {
    return [[[[NSNumberFormatter alloc] init] numberFromString:self] unsignedShortValue];
}

- (unsigned int)unsignedIntValue {
    return [[[[NSNumberFormatter alloc] init] numberFromString:self] unsignedIntValue];
}

- (long)longValue {
    return [[[[NSNumberFormatter alloc] init] numberFromString:self] longValue];
}

- (unsigned long)unsignedLongValue {
    return [[[[NSNumberFormatter alloc] init] numberFromString:self] unsignedLongValue];
}

- (unsigned long long)unsignedLongLongValue {
    return [[[[NSNumberFormatter alloc] init] numberFromString:self] unsignedLongLongValue];
}

- (NSUInteger)unsignedIntegerValue {
    return [[[[NSNumberFormatter alloc] init] numberFromString:self] unsignedIntegerValue];
}

@end
