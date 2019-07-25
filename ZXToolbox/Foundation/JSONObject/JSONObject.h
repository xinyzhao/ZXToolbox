//
// JSONObject.h
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
+ (NSData *)dataWithJSONObject:(id)obj;

/**
 Generate JSON data from a JSON object with options

 @param obj JSON object (NSDictionary/NSArray)
 @param opt Writing options, see NSJSONWritingOptions
 @return Return NSData if converted, nil otherwise
 */
+ (NSData *)dataWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt;

/**
 Generate JSON string from a JSON object

 @param obj JSON object (NSDictionary/NSArray)
 @return Return NSString if converted, nil otherwise
 */
+ (NSString *)stringWithJSONObject:(id)obj;

/**
 Generate JSON data from a JSON object  with options
 
 @param obj JSON object (NSDictionary/NSArray)
 @param opt Writing options, see NSJSONWritingOptions
 @return Return NSString if converted, nil otherwise
 */
+ (NSString *)stringWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt;

/**
 Create a JSON object from JSON data

 @param data JSON data
 @return Return NSDictionary/NSArray if converted, nil otherwise
 */
+ (id)JSONObjectWithData:(NSData *)data;

/**
 Create a JSON object from JSON data with options

 @param data JSON data
 @param opt Reading options, see NSJSONReadingOptions
 @return Return NSDictionary/NSArray if converted, nil otherwise
 */
+ (id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt;

/**
 Create a JSON object from JSON string
 
 @param string JSON data
 @return Return NSDictionary/NSArray if converted, nil otherwise
 */
+ (id)JSONObjectWithString:(NSString *)string;

/**
 Create a JSON object from JSON string with options

 @param string JSON string
 @param opt Reading options, see NSJSONReadingOptions
 @return Return NSDictionary/NSArray if converted, nil otherwise
 */
+ (id)JSONObjectWithString:(NSString *)string options:(NSJSONReadingOptions)opt;

@end
