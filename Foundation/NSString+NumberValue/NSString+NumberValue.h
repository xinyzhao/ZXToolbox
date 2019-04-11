//
// NSString+NumberValue.h
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

@interface NSString (NumberValue)

+ (NSNumber *)numberFromString:(NSString *)string;

+ (NSString *)stringWithNumber:(NSNumber *)number;
+ (NSString *)stringWithNumber:(NSNumber *)number format:(NSString *)format;

- (NSString *)stringWithNumberFormat:(NSString *)format;

@property (readonly) char charValue;
@property (readonly) unsigned char unsignedCharValue;
@property (readonly) short shortValue;
@property (readonly) unsigned short unsignedShortValue;
@property (readonly) unsigned int unsignedIntValue;
@property (readonly) long longValue;
@property (readonly) unsigned long unsignedLongValue;
@property (readonly) unsigned long long unsignedLongLongValue;
@property (readonly) NSUInteger unsignedIntegerValue;

/**
 Convert a numeric string of baseIn to a numeric string of baseOut.
 Reference https://github.com/MikeMcl/bignumber.js/blob/master/bignumber.js
 
 Eg. [NSString stringWithValue:@"255" baseIn:10 baseOut:16 uppercase:NO] returns @"ff".
 Eg. [NSString stringWithValue:@"ff" baseIn:16 baseOut:10 uppercase:NO] returns @"255".
 
 @param value The numeric value, a NSNumber or NSString object
 @param baseIn from base
 @param baseOut to base
 @param uppercase Pass true to use uppercase letters to represent numerals greater than 9, or false to use lowercase letters.
 @return The string of base baseOut
 */

+ (NSString *)stringWithValue:(id)value baseIn:(int)baseIn baseOut:(int)baseOut uppercase:(BOOL)uppercase;


/**
 Convert a numeric string from baseIn to base 10.

 @param value The numeric value, a NSNumber or NSString object
 @param radix The base to use for the string representation. radix must be at least 2 and at most 36.
 @param uppercase Pass true to use uppercase letters to represent numerals greater than 9, or false to use lowercase letters.
 @return The string of base radix
 */
+ (NSString *)stringWithValue:(id)value radix:(int)radix uppercase:(BOOL)uppercase;

/**
 Converting from base 10 to baseOut.

 @param radix The base to use for the string representation. radix must be at least 2 and at most 36.
 @param uppercase Pass true to use uppercase letters to represent numerals greater than 9, or false to use lowercase letters.
 @return The string of base radix
 */
- (NSString *)stringByRadix:(int)radix uppercase:(BOOL)uppercase;

/**
 Reverse the string

 @return NSString
 */
- (NSString *)stringByReversed;

@end
