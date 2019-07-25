//
// NSNumberFormatter+ZXToolbox.m
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

#import "NSNumberFormatter+ZXToolbox.h"

@implementation NSNumberFormatter (ZXToolbox)

- (NSString *)stringFromNumber:(NSNumber *)number
                 integerFormat:(NSString *)integerFormat
                minimumDecimal:(NSUInteger)minimumDecimal
                maximumDecimal:(NSUInteger)maximumDecimal
                  paddingZeros:(BOOL)paddingZeros {
    NSString *string = nil;
    NSString *positiveFormat = self.positiveFormat;
    //
    NSInteger limit = 1;
    NSInteger value = ABS([number integerValue]);
    NSInteger digit = minimumDecimal;
    for (NSInteger i = 0; i < maximumDecimal; i++) {
        limit *= 10;
        if (value <= limit) {
            digit = MAX(minimumDecimal, maximumDecimal - i > 0 ? maximumDecimal - i : 0);
            break;
        }
    }
    if (digit > 0) {
        NSString *format = integerFormat ? integerFormat : @"0";
        format = [format stringByAppendingString:self.decimalSeparator];
        for (NSInteger j = 0; j < digit; j++) {
            format = [format stringByAppendingString:paddingZeros ? @"0" : @"#"];
        }
        self.positiveFormat = format;
    }
    //
    string = [self stringFromNumber:number];
    self.positiveFormat = positiveFormat;
    return string;
}

@end
