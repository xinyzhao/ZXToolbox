//
// NSString+URLEncoding.m
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

#import "NSString+URLEncoding.h"

@implementation NSString (URLEncoding)

- (NSString *)stringByURLEncoding:(NSStringURLEncoding)component {
    NSCharacterSet *set = nil;
    switch (component) {
        case NSStringURLEncodingUser:
            set = NSCharacterSet.URLUserAllowedCharacterSet;
            break;
        case NSStringURLEncodingPassword:
            set = NSCharacterSet.URLPasswordAllowedCharacterSet;
            break;
        case NSStringURLEncodingHost:
            set = NSCharacterSet.URLHostAllowedCharacterSet;
            break;
        case NSStringURLEncodingPath:
            set = NSCharacterSet.URLPathAllowedCharacterSet;
            break;
        case NSStringURLEncodingQuery:
            set = NSCharacterSet.URLQueryAllowedCharacterSet;
            break;
        case NSStringURLEncodingFragment:
            set = NSCharacterSet.URLFragmentAllowedCharacterSet;
            break;
        default:
            break;
    }
    if (set) {
        return [self stringByAddingPercentEncodingWithAllowedCharacters:set];
    }
    return nil;
}

- (NSString *)stringByURLDecoding {
    return [self stringByRemovingPercentEncoding];
}

@end
