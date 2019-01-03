//
// NSNumberFormatter+Extra.m
//
// Copyright (c) 2019 Zhao Xin (https://github.com/xinyzhao/ZXToolbox)
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

#import "NSNumberFormatter+Extra.h"

@implementation NSNumberFormatter (Extra)

- (NSString *)stringFromNumber:(NSNumber *)number integerFormat:(NSString *)integerFormat decimalDigits:(int)decimalDigits paddingZeros:(BOOL)paddingZeros {
    NSString *string = nil;
    NSString *positiveFormat = self.positiveFormat;
    //
    NSInteger limit = 1;
    NSInteger value = ABS([number intValue]);
    for (int i = 0; i < decimalDigits; i++) {
        limit *= 10;
        if (value < limit) {
            NSString *format = integerFormat ? integerFormat : @"#";
            format = [format stringByAppendingString:self.decimalSeparator];
            int digits = decimalDigits - i > 0 ? decimalDigits - i : 0;
            for (int j = 0; j < digits; j++) {
                format = [format stringByAppendingString:@"#"];
            }
            self.positiveFormat = format;
            if (paddingZeros) {
                self.minimumFractionDigits = digits;
            }
            break;
        }
    }
    //
    string = [self stringFromNumber:number];
    self.positiveFormat = positiveFormat;
    return string;
}

@end
