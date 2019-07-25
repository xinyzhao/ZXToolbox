//
// NSData+Base64Encoding.m
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

#import "NSData+Base64Encoding.h"

@implementation NSData (Base64Encoding)

+ (instancetype)dataWithBase64EncodedString:(NSString *)base64String options:(NSDataBase64DecodingOptions)options {
    if (base64String) {
        return [[NSData alloc] initWithBase64EncodedString:base64String options:options];
    }
    return nil;
}

- (NSString *)base64DecodedStringWithOptions:(NSDataBase64DecodingOptions)options {
    NSData *data = [self base64DecodedDataWithOptions:options];
    if (data) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

+ (instancetype)dataWithBase64EncodedData:(NSData *)base64Data options:(NSDataBase64DecodingOptions)options {
    return [base64Data base64DecodedDataWithOptions:options];
}

- (NSData *)base64DecodedDataWithOptions:(NSDataBase64DecodingOptions)options {
    return [[NSData alloc] initWithBase64EncodedData:self options:options];
}

@end
