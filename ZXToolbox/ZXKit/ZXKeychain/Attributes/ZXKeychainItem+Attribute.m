//
// ZXKeychainItem+Attribute.m
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

#import "ZXKeychainItem+Attribute.h"

@implementation ZXKeychainItem (Attribute)

#if TARGET_OS_OSX

- (void)setAccessRef:(SecAccessRef)accessRef {
    [self setObject:(__bridge id)accessRef forKey:(__bridge id)kSecAttrAccess];
}

- (SecAccessRef)accessRef {
    return (__bridge SecAccessRef)[self objectForKey:(__bridge id)kSecAttrAccess];
}

#endif

- (void)setAccessGroup:(NSString *)accessGroup {
    [self setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
}

- (NSString *)accessGroup {
    return [self objectForKey:(__bridge id)kSecAttrAccessGroup];
}

- (void)setAccessible:(ZXKeychainItemAttrAccessible)accessible {
    id obj = nil;
    switch (accessible) {
        case ZXKeychainItemAttrAccessibleWhenPasscodeSetThisDeviceOnly:
            obj = (__bridge id)kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly;
            break;
        case ZXKeychainItemAttrAccessibleWhenUnlockedThisDeviceOnly:
            obj = (__bridge id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly;
            break;
        case ZXKeychainItemAttrAccessibleWhenUnlocked:
            obj = (__bridge id)kSecAttrAccessibleWhenUnlocked;
            break;
        case ZXKeychainItemAttrAccessibleAfterFirstUnlockThisDeviceOnly:
            obj = (__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;
            break;
        case ZXKeychainItemAttrAccessibleAfterFirstUnlock:
            obj = (__bridge id)kSecAttrAccessibleAfterFirstUnlock;
            break;
        case ZXKeychainItemAttrAccessibleAlwaysThisDeviceOnly:
            obj = (__bridge id)kSecAttrAccessibleAlwaysThisDeviceOnly;
            break;
        case ZXKeychainItemAttrAccessibleAlways:
            obj = (__bridge id)kSecAttrAccessibleAlways;
            break;
        default:
            break;
    }
    [self setObject:obj forKey:(__bridge id)kSecAttrAccessible];
}

- (ZXKeychainItemAttrAccessible)accessible {
    ZXKeychainItemAttrAccessible accessible = ZXKeychainItemAttrAccessibleUnspecified;
    id obj = [self objectForKey:(__bridge id)kSecAttrAccessible];
    if (obj == (__bridge id)kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly) {
        accessible = ZXKeychainItemAttrAccessibleWhenPasscodeSetThisDeviceOnly;
    } else if (obj == (__bridge id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly) {
        accessible = ZXKeychainItemAttrAccessibleWhenUnlockedThisDeviceOnly;
    } else if (obj == (__bridge id)kSecAttrAccessibleWhenUnlocked) {
        accessible = ZXKeychainItemAttrAccessibleWhenUnlocked;
    } else if (obj == (__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly) {
        accessible = ZXKeychainItemAttrAccessibleAfterFirstUnlockThisDeviceOnly;
    } else if (obj == (__bridge id)kSecAttrAccessibleAfterFirstUnlock) {
        accessible = ZXKeychainItemAttrAccessibleAfterFirstUnlock;
    } else if (obj == (__bridge id)kSecAttrAccessibleAlwaysThisDeviceOnly) {
        accessible = ZXKeychainItemAttrAccessibleAlwaysThisDeviceOnly;
    } else if (obj == (__bridge id)kSecAttrAccessibleAlways) {
        accessible = ZXKeychainItemAttrAccessibleAlways;
    }
    return accessible;
}

- (void)setLabel:(NSString *)label {
    [self setObject:label forKey:(__bridge id)kSecAttrLabel];
}

- (NSString *)label {
    return [self objectForKey:(__bridge id)kSecAttrLabel];
}

@end
