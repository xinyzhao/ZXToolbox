//
// ZXKeychainItem+Key.m
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

#import "ZXKeychainItem+Key.h"

@implementation ZXKeychainItem (Key)

- (void)setKeyClass:(ZXKeychainItemAttrKeyClass)keyClass {
    id obj = nil;
    switch (keyClass) {
        case ZXKeychainItemAttrKeyClassPublic:
            obj = (__bridge id)kSecAttrKeyClassPublic;
            break;
        case ZXKeychainItemAttrKeyClassPrivate:
            obj = (__bridge id)kSecAttrKeyClassPrivate;
            break;
        case ZXKeychainItemAttrKeyClassSymmetric:
            obj = (__bridge id)kSecAttrKeyClassSymmetric;
            break;
        default:
            break;
    }
    [self setObject:obj forKey:(__bridge id)kSecAttrKeyClass];
}

- (ZXKeychainItemAttrKeyClass)keyClass {
    ZXKeychainItemAttrKeyClass keyClass = ZXKeychainItemAttrKeyClassUnspecified;
    id obj = [self objectForKey:(__bridge id)kSecAttrKeyClass];
    if (obj == (__bridge id)kSecAttrKeyClassPublic) {
        keyClass = ZXKeychainItemAttrKeyClassPublic;
    } else if (obj == (__bridge id)kSecAttrKeyClassPrivate) {
        keyClass = ZXKeychainItemAttrKeyClassPrivate;
    } else if (obj == (__bridge id)kSecAttrKeyClassSymmetric) {
        keyClass = ZXKeychainItemAttrKeyClassSymmetric;
    }
    return keyClass;
}

- (void)setApplicationLabel:(NSString *)applicationLabel {
    [self setObject:applicationLabel forKey:(__bridge id)kSecAttrApplicationLabel];
}

- (NSString *)applicationLabel {
    return [self objectForKey:(__bridge id)kSecAttrApplicationLabel];
}

- (void)setIsPermanent:(BOOL)isPermanent {
    CFBooleanRef ref = isPermanent ? kCFBooleanTrue : kCFBooleanFalse;
    [self setObject:(__bridge id)ref forKey:(__bridge id)kSecAttrIsPermanent];
}

- (BOOL)isPermanent {
    CFBooleanRef ref = (__bridge CFBooleanRef)[self objectForKey:(__bridge id)kSecAttrIsPermanent];
    return CFBooleanGetValue(ref);
}

- (void)setApplicationTag:(NSData *)applicationTag {
    [self setObject:applicationTag forKey:(__bridge id)kSecAttrApplicationTag];
}

- (NSData *)applicationTag {
    return [self objectForKey:(__bridge id)kSecAttrApplicationTag];
}

- (void)setKeyType:(ZXKeychainItemAttrKeyType)keyType {
    id obj = nil;
    switch (keyType) {
        case ZXKeychainItemAttrKeyTypeRSA:
            obj = (__bridge id)kSecAttrKeyTypeRSA;
            break;
#if TARGET_OS_OSX
        case ZXKeychainItemAttrKeyTypeDSA:
            obj = (__bridge id)kSecAttrKeyTypeDSA;
            break;
        case ZXKeychainItemAttrKeyTypeAES:
            obj = (__bridge id)kSecAttrKeyTypeAES;
            break;
        case ZXKeychainItemAttrKeyTypeDES:
            obj = (__bridge id)kSecAttrKeyTypeDES;
            break;
        case ZXKeychainItemAttrKeyType3DES:
            obj = (__bridge id)kSecAttrKeyType3DES;
            break;
        case ZXKeychainItemAttrKeyTypeRC4:
            obj = (__bridge id)kSecAttrKeyTypeRC4;
            break;
        case ZXKeychainItemAttrKeyTypeRC2:
            obj = (__bridge id)kSecAttrKeyTypeRC2;
            break;
        case ZXKeychainItemAttrKeyTypeCAST:
            obj = (__bridge id)kSecAttrKeyTypeCAST;
            break;
        case ZXKeychainItemAttrKeyTypeECDSA:
            obj = (__bridge id)kSecAttrKeyTypeECDSA;
            break;
        case ZXKeychainItemAttrKeyTypeEC:
            obj = (__bridge id)kSecAttrKeyTypeEC;
            break;
#endif
        case ZXKeychainItemAttrKeyTypeECSECPrimeRandom:
            if (@available(iOS 10.0, *)) {
                obj = (__bridge id)kSecAttrKeyTypeECSECPrimeRandom;
            }
            break;
        default:
            break;
    }
    [self setObject:obj forKey:(__bridge id)kSecAttrKeyType];
}

- (ZXKeychainItemAttrKeyType)keyType {
    ZXKeychainItemAttrKeyType keyType = ZXKeychainItemAttrKeyTypeUnspecified;
    id obj = [self objectForKey:(__bridge id)kSecAttrKeyType];
    if (obj == (__bridge id)kSecAttrKeyTypeRSA) {
        keyType = ZXKeychainItemAttrKeyTypeRSA;
#if TARGET_OS_OSX
    } else if (obj == (__bridge id)kSecAttrKeyTypeDSA) {
        keyType = ZXKeychainItemAttrKeyTypeDSA;
    } else if (obj == (__bridge id)kSecAttrKeyTypeAES) {
        keyType = ZXKeychainItemAttrKeyTypeAES;
    } else if (obj == (__bridge id)kSecAttrKeyTypeDES) {
        keyType = ZXKeychainItemAttrKeyTypeDES;
    } else if (obj == (__bridge id)kSecAttrKeyType3DES) {
        keyType = ZXKeychainItemAttrKeyType3DES;
    } else if (obj == (__bridge id)kSecAttrKeyTypeRC4) {
        keyType = ZXKeychainItemAttrKeyTypeRC4;
    } else if (obj == (__bridge id)kSecAttrKeyTypeRC2) {
        keyType = ZXKeychainItemAttrKeyTypeRC2;
    } else if (obj == (__bridge id)kSecAttrKeyTypeCAST) {
        keyType = ZXKeychainItemAttrKeyTypeCAST;
    } else if (obj == (__bridge id)kSecAttrKeyTypeECDSA) {
        keyType = ZXKeychainItemAttrKeyTypeECDSA;
    } else if (obj == (__bridge id)kSecAttrKeyTypeEC) {
        keyType = ZXKeychainItemAttrKeyTypeEC;
#endif
    } else if (@available(iOS 10.0, *)) {
        if (obj == (__bridge id)kSecAttrKeyTypeECSECPrimeRandom) {
            keyType = ZXKeychainItemAttrKeyTypeECSECPrimeRandom;
        }
    }
    return keyType;
}

#if TARGET_OS_OSX

- (void)setPRF:(ZXKeychainItemAttrPRF)PRF {
    id obj = nil;
    switch (PRF) {
        case ZXKeychainItemAttrPRFHmacAlgSHA1:
            obj = (__bridge id)kSecAttrPRFHmacAlgSHA1;
            break;
        case ZXKeychainItemAttrPRFHmacAlgSHA224:
            obj = (__bridge id)kSecAttrPRFHmacAlgSHA224;
            break;
        case ZXKeychainItemAttrPRFHmacAlgSHA256:
            obj = (__bridge id)kSecAttrPRFHmacAlgSHA256;
            break;
        case ZXKeychainItemAttrPRFHmacAlgSHA384:
            obj = (__bridge id)kSecAttrPRFHmacAlgSHA384;
            break;
        case ZXKeychainItemAttrPRFHmacAlgSHA512:
            obj = (__bridge id)kSecAttrPRFHmacAlgSHA512;
            break;
        default:
            break;
    }
    [self setObject:obj forKey:(__bridge id)kSecAttrPRF];
}

- (ZXKeychainItemAttrPRF)PRF {
    ZXKeychainItemAttrPRF PRF = ZXKeychainItemAttrPRFUnspecified;
    id obj = [self objectForKey:(__bridge id)kSecAttrPRF];
    if (obj == (__bridge id)kSecAttrPRFHmacAlgSHA1) {
        PRF = ZXKeychainItemAttrPRFHmacAlgSHA1;
    } else if (obj == (__bridge id)kSecAttrPRFHmacAlgSHA224) {
        PRF = ZXKeychainItemAttrPRFHmacAlgSHA224;
    } else if (obj == (__bridge id)kSecAttrPRFHmacAlgSHA256) {
        PRF = ZXKeychainItemAttrPRFHmacAlgSHA256;
    } else if (obj == (__bridge id)kSecAttrPRFHmacAlgSHA384) {
        PRF = ZXKeychainItemAttrPRFHmacAlgSHA384;
    } else if (obj == (__bridge id)kSecAttrPRFHmacAlgSHA512) {
        PRF = ZXKeychainItemAttrPRFHmacAlgSHA512;
    }
    return PRF;
}

- (void)setSalt:(NSData *)salt {
    [self setObject:salt forKey:(__bridge id)kSecAttrSalt];
}

- (NSData *)salt {
    return [self objectForKey:(__bridge id)kSecAttrSalt];
}

- (void)setRounds:(NSData *)rounds {
    [self setObject:rounds forKey:(__bridge id)kSecAttrRounds];
}

- (NSData *)rounds {
    return [self objectForKey:(__bridge id)kSecAttrRounds];
}

#endif

- (void)setKeySizeInBits:(NSNumber *)keySizeInBits {
    [self setObject:keySizeInBits forKey:(__bridge id)kSecAttrKeySizeInBits];
}

- (NSNumber *)keySizeInBits {
    return [self objectForKey:(__bridge id)kSecAttrKeySizeInBits];
}

- (void)setEffectiveKeySize:(NSNumber *)effectiveKeySize {
    [self setObject:effectiveKeySize forKey:(__bridge id)kSecAttrEffectiveKeySize];
}

- (NSNumber *)effectiveKeySize {
    return [self objectForKey:(__bridge id)kSecAttrEffectiveKeySize];
}

- (void)setCanEncrypt:(BOOL)canEncrypt {
    CFBooleanRef ref = canEncrypt ? kCFBooleanTrue : kCFBooleanFalse;
    [self setObject:(__bridge id)ref forKey:(__bridge id)kSecAttrCanEncrypt];
}

- (BOOL)canEncrypt {
    CFBooleanRef ref = (__bridge CFBooleanRef)[self objectForKey:(__bridge id)kSecAttrCanEncrypt];
    return ref ? CFBooleanGetValue(ref) : false;
}

- (void)setCanDecrypt:(BOOL)canDecrypt {
    CFBooleanRef ref = canDecrypt ? kCFBooleanTrue : kCFBooleanFalse;
    [self setObject:(__bridge id)ref forKey:(__bridge id)kSecAttrCanDecrypt];
}

- (BOOL)canDecrypt {
    CFBooleanRef ref = (__bridge CFBooleanRef)[self objectForKey:(__bridge id)kSecAttrCanDecrypt];
    return ref ? CFBooleanGetValue(ref) : true;
}

- (void)setCanDerive:(BOOL)canDerive {
    CFBooleanRef ref = canDerive ? kCFBooleanTrue : kCFBooleanFalse;
    [self setObject:(__bridge id)ref forKey:(__bridge id)kSecAttrCanDerive];
}

- (BOOL)canDerive {
    CFBooleanRef ref = (__bridge CFBooleanRef)[self objectForKey:(__bridge id)kSecAttrCanDerive];
    return ref ? CFBooleanGetValue(ref) : true;
}

- (void)setCanSign:(BOOL)canSign {
    CFBooleanRef ref = canSign ? kCFBooleanTrue : kCFBooleanFalse;
    [self setObject:(__bridge id)ref forKey:(__bridge id)kSecAttrCanSign];
}

- (BOOL)canSign {
    CFBooleanRef ref = (__bridge CFBooleanRef)[self objectForKey:(__bridge id)kSecAttrCanSign];
    return ref ? CFBooleanGetValue(ref) : true;
}

- (void)setCanVerify:(BOOL)canVerify {
    CFBooleanRef ref = canVerify ? kCFBooleanTrue : kCFBooleanFalse;
    [self setObject:(__bridge id)ref forKey:(__bridge id)kSecAttrCanVerify];
}

- (BOOL)canVerify {
    CFBooleanRef ref = (__bridge CFBooleanRef)[self objectForKey:(__bridge id)kSecAttrCanVerify];
    return ref ? CFBooleanGetValue(ref) : false;
}

- (void)setCanWrap:(BOOL)canWrap {
    CFBooleanRef ref = canWrap ? kCFBooleanTrue : kCFBooleanFalse;
    [self setObject:(__bridge id)ref forKey:(__bridge id)kSecAttrCanWrap];
}

- (BOOL)canWrap {
    CFBooleanRef ref = (__bridge CFBooleanRef)[self objectForKey:(__bridge id)kSecAttrCanWrap];
    return ref ? CFBooleanGetValue(ref) : false;
}

- (void)setCanUnwrap:(BOOL)canUnwrap {
    CFBooleanRef ref = canUnwrap ? kCFBooleanTrue : kCFBooleanFalse;
    [self setObject:(__bridge id)ref forKey:(__bridge id)kSecAttrCanUnwrap];
}

- (BOOL)canUnwrap {
    CFBooleanRef ref = (__bridge CFBooleanRef)[self objectForKey:(__bridge id)kSecAttrCanUnwrap];
    return ref ? CFBooleanGetValue(ref) : true;
}

@end
