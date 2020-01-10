//
// ZXKeychainItem+Class.m
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

#import "ZXKeychainItem+Class.h"

@implementation ZXKeychainItem (Class)

- (void)setItemClass:(ZXKeychainItemClass)itemClass {
    id obj = nil;
    switch (itemClass) {
        case ZXKeychainItemClassGenericPassword:
            obj = (__bridge id)kSecClassGenericPassword;
            break;
        case ZXKeychainItemClassInternetPassword:
            obj = (__bridge id)kSecClassInternetPassword;
            break;
        case ZXKeychainItemClassCertificate:
            obj = (__bridge id)kSecClassCertificate;
            break;
        case ZXKeychainItemClassKey:
            obj = (__bridge id)kSecClassKey;
            break;
        case ZXKeychainItemClassIdentity:
            obj = (__bridge id)kSecClassIdentity;
            break;
        default:
            break;
    }
    [self setObject:obj forKey:(__bridge id)kSecClass];
}

- (ZXKeychainItemClass)itemClass {
    ZXKeychainItemClass itemClass = ZXKeychainItemClassUnspecified;
    id obj = [self objectForKey:(__bridge id)kSecClass];
    if (obj == (__bridge id)kSecClassGenericPassword) {
        itemClass = ZXKeychainItemClassGenericPassword;
    } else if (obj == (__bridge id)kSecClassInternetPassword) {
        itemClass = ZXKeychainItemClassInternetPassword;
    } else if (obj == (__bridge id)kSecClassCertificate) {
        itemClass = ZXKeychainItemClassCertificate;
    } else if (obj == (__bridge id)kSecClassKey) {
        itemClass = ZXKeychainItemClassKey;
    } else if (obj == (__bridge id)kSecClassIdentity) {
        itemClass = ZXKeychainItemClassIdentity;
    }
    return itemClass;
}

@end
