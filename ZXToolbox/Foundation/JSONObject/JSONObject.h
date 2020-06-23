//
// JSONObject.h
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

/**
 JSONObject
 */
@interface JSONObject : NSObject

/**
 The object can be converted to JSON data or not
 
 @param obj JSON object (NSDictionary/NSArray)
 @return Return YES can be converted, NO otherwise
 */
+ (BOOL)isValidJSONObject:(id)obj;

/**
 Generate JSON data from a JSON object
 
 @param obj JSON object (NSDictionary/NSArray)
 @return Return NSData if converted, nil otherwise
 */
+ (nullable NSData *)dataWithJSONObject:(id)obj;

/**
 Generate JSON data from a JSON object with options
 
 @param obj JSON object (NSDictionary/NSArray)
 @param opt Writing options, see NSJSONWritingOptions
 @return Return NSData if converted, nil otherwise
 */
+ (nullable NSData *)dataWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt;

/**
 Generate JSON data from a JSON object with options
 
 @param obj JSON object (NSDictionary/NSArray)
 @param opt Writing options, see NSJSONWritingOptions
 @param error If an internal error occurs, upon return contains an NSError object with code NSPropertyListWriteInvalidError that describes the problem.
 @return Return NSData if converted, nil otherwise
 */
+ (nullable NSData *)dataWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error;

/**
 Generate JSON string from a JSON object
 
 @param obj JSON object (NSDictionary/NSArray)
 @return Return NSString if converted, nil otherwise
 */
+ (nullable NSString *)stringWithJSONObject:(id)obj;

/**
 Generate JSON data from a JSON object  with options
 
 @param obj JSON object (NSDictionary/NSArray)
 @param opt Writing options, see NSJSONWritingOptions
 @return Return NSString if converted, nil otherwise
 */
+ (nullable NSString *)stringWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt;

/**
 Generate JSON data from a JSON object  with options
 
 @param obj JSON object (NSDictionary/NSArray)
 @param opt Writing options, see NSJSONWritingOptions
 @param error If an internal error occurs, upon return contains an NSError object with code NSPropertyListWriteInvalidError that describes the problem.
 @return Return NSString if converted, nil otherwise
 */
+ (nullable NSString *)stringWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error;

/**
 Create a JSON object from JSON data
 
 @param data JSON data
 @return Return NSDictionary/NSArray if converted, nil otherwise
 */
+ (nullable id)JSONObjectWithData:(NSData *)data;

/**
 Create a JSON object from JSON data with options
 
 @param data JSON data
 @param opt Reading options, see NSJSONReadingOptions
 @return Return NSDictionary/NSArray if converted, nil otherwise
 */
+ (nullable id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt;

/**
 Create a JSON object from JSON data with options
 
 @param data JSON data
 @param opt Reading options, see NSJSONReadingOptions
 @param error If an error occurs, upon return contains an NSError object with code NSPropertyListReadCorruptError that describes the problem.
 @return Return NSDictionary/NSArray if converted, nil otherwise
 */
+ (nullable id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error;

/**
 Create a JSON object from JSON string
 
 @param str JSON string
 @return Return NSDictionary/NSArray if converted, nil otherwise
 */
+ (nullable id)JSONObjectWithString:(NSString *)str;

/**
 Create a JSON object from JSON string with options
 
 @param str JSON string
 @param opt Reading options, see NSJSONReadingOptions
 @return Return NSDictionary/NSArray if converted, nil otherwise
 */
+ (nullable id)JSONObjectWithString:(NSString *)str options:(NSJSONReadingOptions)opt;

/**
 Create a JSON object from JSON string with options
 
 @param str JSON string
 @param opt Reading options, see NSJSONReadingOptions
 @param error If an error occurs, upon return contains an NSError object with code NSPropertyListReadCorruptError that describes the problem.
 @return Return NSDictionary/NSArray if converted, nil otherwise
 */
+ (nullable id)JSONObjectWithString:(NSString *)str options:(NSJSONReadingOptions)opt error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
