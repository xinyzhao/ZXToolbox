//
// JSONObject.m
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

#import "JSONObject.h"

@implementation JSONObject

+ (BOOL)isValidJSONObject:(id)obj {
    return [NSJSONSerialization isValidJSONObject:obj];
}

+ (NSData *)dataWithJSONObject:(id)obj {
    return [JSONObject dataWithJSONObject:obj options:kNilOptions];
}

+ (NSData *)dataWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:opt error:&error];
    if (error) {
        NSLog(@"%s %@", __func__, error.localizedDescription);
    }
    return data;
}

+ (NSString *)stringWithJSONObject:(id)obj {
    return [JSONObject stringWithJSONObject:obj options:kNilOptions];
}

+ (NSString *)stringWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt {
    NSData *data = [JSONObject dataWithJSONObject:obj options:opt];
    if (data) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

+ (id)JSONObjectWithData:(NSData *)data {
    return [JSONObject JSONObjectWithData:data options:NSJSONReadingAllowFragments];
}

+ (id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt {
    NSError *error;
    id object = [NSJSONSerialization JSONObjectWithData:data options:opt error:&error];
    if (error) {
        NSLog(@"%s %@", __func__, error.localizedDescription);
    }
    return object;
}

+ (id)JSONObjectWithString:(NSString *)str {
    return [JSONObject JSONObjectWithString:str options:NSJSONReadingAllowFragments];
}

+ (id)JSONObjectWithString:(NSString *)str options:(NSJSONReadingOptions)opt {
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    return [JSONObject JSONObjectWithData:data options:opt];
}

@end
