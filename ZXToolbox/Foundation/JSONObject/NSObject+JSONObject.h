//
// NSObject+JSONObject.h
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2021 Zhao Xin
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

@interface NSObject (JSONObject)

/**
 The object can be converted to JSON data or not
 
 @return Return YES can be converted, NO otherwise
 */
- (BOOL)isValidJSONObject;

/**
 Generate JSON data from a JSON object
 
 @return Return NSData if converted, nil otherwise
 */
- (nullable NSData *)JSONData;

/**
 Generate JSON data from a JSON object with options
 
 @param opt Writing options, see NSJSONWritingOptions
 @return Return NSData if converted, nil otherwise
 */
- (nullable NSData *)JSONDataWithOptions:(NSJSONWritingOptions)opt;

/**
 Generate JSON data from a JSON object with options
 
 @param opt Writing options, see NSJSONWritingOptions
 @param error If an internal error occurs, upon return contains an NSError object with code NSPropertyListWriteInvalidError that describes the problem.
 @return Return NSData if converted, nil otherwise
 */
- (nullable NSData *)JSONDataWithOptions:(NSJSONWritingOptions)opt error:(NSError **)error;

/**
 Generate JSON string from a JSON object
 
 @return Return NSString if converted, nil otherwise
 */
- (nullable NSString *)JSONString;

/**
 Generate JSON data from a JSON object  with options
 
 @param opt Writing options, see NSJSONWritingOptions
 @return Return NSString if converted, nil otherwise
 */
- (nullable NSString *)JSONStringWithOptions:(NSJSONWritingOptions)opt;

/**
 Generate JSON data from a JSON object  with options
 
 @param opt Writing options, see NSJSONWritingOptions
 @param error If an internal error occurs, upon return contains an NSError object with code NSPropertyListWriteInvalidError that describes the problem.
 @return Return NSString if converted, nil otherwise
 */
- (nullable NSString *)JSONStringWithOptions:(NSJSONWritingOptions)opt error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
