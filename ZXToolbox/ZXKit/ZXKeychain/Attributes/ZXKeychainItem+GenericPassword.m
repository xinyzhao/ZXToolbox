//
// ZXKeychainItem+GenericPassword.m
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2020 Zhao Xin
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

#import "ZXKeychainItem+GenericPassword.h"

@implementation ZXKeychainItem (GenericPassword)

- (void)setAccessControl:(SecAccessControlRef)accessControl {
    [self setObject:(__bridge id)accessControl forKey:(__bridge id)kSecAttrAccessControl];
}

- (SecAccessControlRef)accessControl {
    return (__bridge SecAccessControlRef)[self objectForKey:(__bridge id)kSecAttrAccessControl];
}

- (void)setService:(NSString *)service {
    [self setObject:service forKey:(__bridge id)kSecAttrService];
}

- (NSString *)service {
    return [self objectForKey:(__bridge id)kSecAttrService];
}

- (void)setGeneric:(NSData *)generic {
    [self setObject:generic forKey:(__bridge id)kSecAttrGeneric];
}

- (NSString *)generic {
    return [self objectForKey:(__bridge id)kSecAttrGeneric];
}

@end
