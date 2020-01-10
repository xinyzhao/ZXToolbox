//
// ZXKeychainItem+Password.m
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

#import "ZXKeychainItem+Password.h"

@implementation ZXKeychainItem (Password)

- (NSDate *)creationDate {
    return [self objectForKey:(__bridge id)kSecAttrCreationDate];
}

- (NSDate *)modificationDate {
    return [self objectForKey:(__bridge id)kSecAttrCreationDate];
}

- (void)setDesc:(NSString *)desc {
    [self setObject:desc forKey:(__bridge id)kSecAttrDescription];
}

- (NSString *)desc {
    return [self objectForKey:(__bridge id)kSecAttrDescription];
}

- (void)setComment:(NSString *)comment {
    [self setObject:comment forKey:(__bridge id)kSecAttrComment];
}

- (NSString *)comment {
    return [self objectForKey:(__bridge id)kSecAttrComment];
}

- (void)setCreator:(NSNumber *)creator {
    [self setObject:creator forKey:(__bridge id)kSecAttrCreator];
}

- (NSNumber *)creator {
    return [self objectForKey:(__bridge id)kSecAttrCreator];
}

- (void)setType:(NSNumber *)type {
    [self setObject:type forKey:(__bridge id)kSecAttrType];
}

- (NSNumber *)type {
    return [self objectForKey:(__bridge id)kSecAttrType];
}

- (void)setIsInvisible:(BOOL)isInvisible {
    CFBooleanRef ref = isInvisible ? kCFBooleanTrue : kCFBooleanFalse;
    [self setObject:(__bridge id)ref forKey:(__bridge id)kSecAttrIsInvisible];
}

- (BOOL)isInvisible {
    CFBooleanRef ref = (__bridge CFBooleanRef)[self objectForKey:(__bridge id)kSecAttrIsInvisible];
    return ref ? CFBooleanGetValue(ref) : false;
}

- (void)setIsNegative:(BOOL)isNegative {
    CFBooleanRef ref = isNegative ? kCFBooleanTrue : kCFBooleanFalse;
    [self setObject:(__bridge id)ref forKey:(__bridge id)kSecAttrIsNegative];
}

- (BOOL)isNegative {
    CFBooleanRef ref = (__bridge CFBooleanRef)[self objectForKey:(__bridge id)kSecAttrIsNegative];
    return ref ? CFBooleanGetValue(ref) : false;
}

- (void)setAccount:(NSString *)account {
    [self setObject:account forKey:(__bridge id)kSecAttrAccount];
}

- (NSString *)account {
    return [self objectForKey:(__bridge id)kSecAttrAccount];
}

- (void)setSynchronizable:(ZXKeychainItemAttrSync)synchronizable {
    id obj = nil;
    switch (synchronizable) {
        case ZXKeychainItemAttrSyncTrue:
            obj = (__bridge id)kCFBooleanTrue;
            break;
        case ZXKeychainItemAttrSyncFalse:
            obj = (__bridge id)kCFBooleanFalse;
            break;
        case ZXKeychainItemAttrSyncAny:
            obj = (__bridge id)kSecAttrSynchronizableAny;
            break;
        default:
            break;
    }
    [self setObject:obj forKey:(__bridge id)kSecAttrSynchronizable];
}

- (ZXKeychainItemAttrSync)synchronizable {
    id obj = [self objectForKey:(__bridge id)kSecAttrSynchronizable];
    if (obj) {
        if (obj == (__bridge id)kSecAttrSynchronizableAny) {
            return ZXKeychainItemAttrSyncAny;
        } else {
            CFBooleanRef ref = (__bridge CFBooleanRef)obj;
            return CFBooleanGetValue(ref) ? ZXKeychainItemAttrSyncTrue : ZXKeychainItemAttrSyncFalse;
        }
    }
    return ZXKeychainItemAttrSyncUnspecified;
}

@end
