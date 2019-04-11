//
// NSString+Base64Encoding.h
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

#import <Foundation/Foundation.h>

@interface NSString (Base64Encoding)

/**
 Create an NSString from a Base-64, UTF-8 encoded NSString

 @param base64String a Base-64, UTF-8 encoded NSString
 @param options NSDataBase64DecodingOptions
 @return Decoded NSString
 */
+ (instancetype)stringWithBase64EncodedString:(NSString *)base64String options:(NSDataBase64DecodingOptions)options;

/**
 Create an NSString from a Base-64, UTF-8 encoded NSString

 @param options NSDataBase64DecodingOptions
 @return Decoded NSString
 */
- (NSString *)base64DecodedStringWithOptions:(NSDataBase64DecodingOptions)options;

/**
 Create a Base-64, UTF-8 encoded NSString

 @param options NSDataBase64EncodingOptions
 @return Encoded NSString
 */
- (NSString *)base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)options;

/**
 Create an NSString from a Base-64, UTF-8 encoded NSData

 @param base64Data a Base-64, UTF-8 encoded NSData
 @param options NSDataBase64DecodingOptions
 @return Decoded NSString
 */
+ (instancetype)stringWithBase64EncodedData:(NSData *)base64Data options:(NSDataBase64DecodingOptions)options;

/**
 Create an NSData from a Base-64, UTF-8 encoded NSString

 @param options NSDataBase64DecodingOptions
 @return Decoded NSData
 */
- (NSData *)base64DecodedDataWithOptions:(NSDataBase64DecodingOptions)options;

/**
 Create a Base-64, UTF-8 encoded NSData

 @param options NSDataBase64EncodingOptions
 @return Encoded NSData
 */
- (NSData *)base64EncodedDataWithOptions:(NSDataBase64EncodingOptions)options;

@end
