//
// NSString+Base64Encoding.m
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2019-2020 Zhao Xin
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

#import "NSString+Base64Encoding.h"

@implementation NSString (Base64Encoding)

- (NSData *)base64EncodedDataWithOptions:(NSDataBase64EncodingOptions)options {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedDataWithOptions:options];
}

- (NSString *)base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)options {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedStringWithOptions:options];
}

- (NSData *)base64DecodedDataWithOptions:(NSDataBase64DecodingOptions)options {
    return [[NSData alloc] initWithBase64EncodedString:self options:options];
}

- (NSString *)base64DecodedStringWithOptions:(NSDataBase64DecodingOptions)options {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:self options:options];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
