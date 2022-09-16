//
// NSObject+JSONObject.m
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

#import "NSObject+JSONObject.h"
#import "JSONObject.h"

@implementation NSObject (JSONObject)

- (BOOL)isValidJSONObject {
    return [JSONObject isValidJSONObject:self];
}

- (NSData *)JSONData {
    return [JSONObject JSONDataWithObject:self];
}

- (NSData *)JSONDataWithOptions:(NSJSONWritingOptions)opt {
    return [JSONObject JSONDataWithObject:self options:opt];
}

- (NSData *)JSONDataWithOptions:(NSJSONWritingOptions)opt error:(NSError **)error {
    return [JSONObject JSONDataWithObject:self options:opt error:error];
}

- (NSString *)JSONString {
    return [JSONObject JSONStringWithObject:self];
}

- (NSString *)JSONStringWithOptions:(NSJSONWritingOptions)opt {
    return [JSONObject JSONStringWithObject:self options:opt];
}

- (NSString *)JSONStringWithOptions:(NSJSONWritingOptions)opt error:(NSError **)error {
    return [JSONObject JSONStringWithObject:self options:opt error:error];
}

@end
