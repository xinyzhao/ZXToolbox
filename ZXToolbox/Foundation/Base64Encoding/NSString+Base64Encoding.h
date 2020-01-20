//
// NSString+Base64Encoding.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// NSString (Base64Encoding)
@interface NSString (Base64Encoding)

/// Creates a Base64, UTF-8 encoded data object from the string using the given options.
/// @param options A mask that specifies options for Base64 encoding the data. Possible values are given in NSDataBase64EncodingOptions.
/// @return A Base64, UTF-8 encoded data object.
- (NSData *)base64EncodedDataWithOptions:(NSDataBase64EncodingOptions)options;

/// Create a Base-64 encoded NSString from the receiver's contents using the given options.
/// @param options A mask that specifies options for Base-64 encoding the data. Possible values are given in NSDataBase64EncodingOptions.
/// @return A Base64 encoded string.
- (NSString *)base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)options;

/// Create an NSData from a Base-64 encoded NSString using the given options.
/// @param options A mask that specifies options for Base-64 decoding the data. Possible values are given in NSDataBase64DecodingOptions.
/// @return A data object built by Base64 decoding the provided string. Returns nil if the data object could not be decoded.
- (nullable NSData *)base64DecodedDataWithOptions:(NSDataBase64DecodingOptions)options;

/// Create an NSString from a Base-64 encoded NSString using the given options.
/// @param options A mask that specifies options for Base64 decoding the string. Possible values are given in NSDataBase64DecodingOptions.
/// @return A string object built by Base64 decoding the provided string. Returns nil if the data object could not be decoded.
- (nullable NSString *)base64DecodedStringWithOptions:(NSDataBase64DecodingOptions)options;

@end

NS_ASSUME_NONNULL_END
