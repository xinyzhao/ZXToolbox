//
// JSONObject.m
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2018 Zhao Xin
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

#import "JSONObject.h"

@implementation JSONObject

+ (BOOL)isValidJSONObject:(id)obj {
    return [NSJSONSerialization isValidJSONObject:obj];
}

#pragma mark JSONData

+ (NSData *)JSONDataWithObject:(id)obj {
    return [self JSONDataWithObject:obj options:kNilOptions];
}

+ (NSData *)JSONDataWithObject:(id)obj options:(NSJSONWritingOptions)opt {
    NSError *error;
    NSData *data = [self JSONDataWithObject:obj options:opt error:&error];
    if (error) {
        NSLog(@"%s %@\n>>Object: %@", __func__, error.localizedDescription, obj);
    }
    return data;
}

+ (NSData *)JSONDataWithObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error {
    if ([self isValidJSONObject:obj]) {
        return [NSJSONSerialization dataWithJSONObject:obj options:opt error:error];
    }
    return nil;
}

#pragma mark JSONObject

+ (NSString *)JSONStringWithObject:(id)obj {
    return [self JSONStringWithObject:obj options:kNilOptions];
}

+ (NSString *)JSONStringWithObject:(id)obj options:(NSJSONWritingOptions)opt {
    return [self JSONStringWithObject:obj options:opt error:nil];
}

+ (NSString *)JSONStringWithObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error {
    NSData *data = [self JSONDataWithObject:obj options:opt error:error];
    if (data) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

#pragma mark JSONObject

+ (id)JSONObjectWithData:(NSData *)data {
    return [self JSONObjectWithData:data options:NSJSONReadingAllowFragments];
}

+ (id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt {
    NSError *error;
    id object = [self JSONObjectWithData:data options:opt error:&error];
    if (error) {
        NSLog(@"%s %@>>Data: %@", __func__, error.localizedDescription, data);
    }
    return object;
}

+ (id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error {
    return [NSJSONSerialization JSONObjectWithData:data options:opt error:error];
}

+ (id)JSONObjectWithString:(NSString *)str {
    return [self JSONObjectWithString:str options:NSJSONReadingAllowFragments];
}

+ (id)JSONObjectWithString:(NSString *)str options:(NSJSONReadingOptions)opt {
    return [self JSONObjectWithString:str options:opt error:nil];
}

+ (id)JSONObjectWithString:(NSString *)str options:(NSJSONReadingOptions)opt error:(NSError **)error {
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    return [self JSONObjectWithData:data options:opt error:error];
}

@end

@implementation JSONObject (DEPRECATED)

+ (NSData *)dataWithJSONObject:(id)obj {
    return [self JSONDataWithObject:obj];
}

+ (NSData *)dataWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt {
    return [self JSONDataWithObject:obj options:opt];
}

+ (NSData *)dataWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error {
    return [self JSONDataWithObject:obj options:opt error:error];
}

+ (NSString *)stringWithJSONObject:(id)obj {
    return [self JSONStringWithObject:obj options:kNilOptions];
}

+ (NSString *)stringWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt {
    return [self JSONStringWithObject:obj options:opt];
}

+ (NSString *)stringWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error {
    return [self JSONStringWithObject:obj options:opt error:error];
}

@end
