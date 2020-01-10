//
// ZXKeychainItem+Match.m
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

#import "ZXKeychainItem+Match.h"

@implementation ZXKeychainItem (Match)

- (void)setMatchPolicyRef:(SecPolicyRef)matchPolicyRef {
    [self setObject:(__bridge id)matchPolicyRef forKey:(__bridge id)kSecMatchPolicy];
}

- (SecPolicyRef)matchPolicyRef {
    return (__bridge SecPolicyRef)[self objectForKey:(__bridge id)kSecMatchPolicy];
}

- (void)setMatchItemList:(NSArray *)matchItemList {
    [self setObject:matchItemList forKey:(__bridge id)kSecMatchItemList];
}

- (NSArray *)matchItemList {
    return [self objectForKey:(__bridge id)kSecMatchItemList];
}

- (void)setMatchSearchList:(NSArray *)matchSearchList {
    [self setObject:matchSearchList forKey:(__bridge id)kSecMatchSearchList];
}

- (NSArray *)matchSearchList {
    return [self objectForKey:(__bridge id)kSecMatchSearchList];
}

- (void)setMatchIssuers:(NSArray *)matchIssuers {
    [self setObject:matchIssuers forKey:(__bridge id)kSecMatchIssuers];
}

- (NSArray *)matchIssuers {
    return [self objectForKey:(__bridge id)kSecMatchIssuers];
}

- (void)setMatchEmailAddressIfPresent:(NSString *)matchEmailAddressIfPresent {
    [self setObject:matchEmailAddressIfPresent forKey:(__bridge id)kSecMatchEmailAddressIfPresent];
}

- (NSString *)matchEmailAddressIfPresent {
    return [self objectForKey:(__bridge id)kSecMatchEmailAddressIfPresent];
}

- (void)setMatchSubjectContains:(NSString *)matchSubjectContains {
    [self setObject:matchSubjectContains forKey:(__bridge id)kSecMatchSubjectContains];
}

- (NSString *)matchSubjectContains {
    return [self objectForKey:(__bridge id)kSecMatchSubjectContains];
}

#if TARGET_OS_OSX

- (void)setMatchSubjectStartsWith:(NSString *)matchSubjectStartsWith {
    [self setObject:matchSubjectStartsWith forKey:(__bridge id)kSecMatchSubjectStartsWith];
}

- (NSString *)matchSubjectStartsWith {
    return [self objectForKey:(__bridge id)kSecMatchSubjectStartsWith];
}

- (void)setMatchSubjectEndsWith:(NSString *)matchSubjectEndsWith {
    [self setObject:matchSubjectEndsWith forKey:(__bridge id)kSecMatchSubjectEndsWith];
}

- (NSString *)matchSubjectEndsWith {
    return [self objectForKey:(__bridge id)kSecMatchSubjectEndsWith];
}

- (void)setMatchSubjectWholeString:(NSString *)matchSubjectWholeString {
    [self setObject:matchSubjectWholeString forKey:(__bridge id)kSecMatchSubjectWholeString];
}

- (NSString *)matchSubjectWholeString {
    return [self objectForKey:(__bridge id)kSecMatchSubjectWholeString];
}

#endif

- (void)setMatchCaseInsensitive:(BOOL)matchCaseInsensitive {
    CFBooleanRef ref = matchCaseInsensitive ? kCFBooleanTrue : kCFBooleanFalse;
    [self setObject:(__bridge id)ref forKey:(__bridge id)kSecMatchCaseInsensitive];
}

- (BOOL)matchCaseInsensitive {
    CFBooleanRef ref = (__bridge CFBooleanRef)[self objectForKey:(__bridge id)kSecMatchCaseInsensitive];
    return ref ? CFBooleanGetValue(ref) : false;
}

#if TARGET_OS_OSX

- (void)setMatchDiacriticInsensitive:(BOOL)matchDiacriticInsensitive {
    CFBooleanRef ref = matchDiacriticInsensitive ? kCFBooleanTrue : kCFBooleanFalse;
    [self setObject:(__bridge id)ref forKey:(__bridge id)kSecMatchDiacriticInsensitive];
}

- (BOOL)matchDiacriticInsensitive {
    CFBooleanRef ref = (__bridge CFBooleanRef)[self objectForKey:(__bridge id)kSecMatchDiacriticInsensitive];
    return ref ? CFBooleanGetValue(ref) : false;
}

- (void)setMatchWidthInsensitive:(BOOL)matchWidthInsensitive {
    CFBooleanRef ref = matchWidthInsensitive ? kCFBooleanTrue : kCFBooleanFalse;
    [self setObject:(__bridge id)ref forKey:(__bridge id)kSecMatchWidthInsensitive];
}

- (BOOL)matchWidthInsensitive {
    CFBooleanRef ref = (__bridge CFBooleanRef)[self objectForKey:(__bridge id)kSecMatchWidthInsensitive];
    return ref ? CFBooleanGetValue(ref) : false;
}

#endif

- (void)setMatchTrustedOnly:(BOOL)matchTrustedOnly {
    CFBooleanRef ref = matchTrustedOnly ? kCFBooleanTrue : kCFBooleanFalse;
    [self setObject:(__bridge id)ref forKey:(__bridge id)kSecMatchTrustedOnly];
}

- (BOOL)matchTrustedOnly {
    CFBooleanRef ref = (__bridge CFBooleanRef)[self objectForKey:(__bridge id)kSecMatchTrustedOnly];
    return ref ? CFBooleanGetValue(ref) : false;
}

- (void)setMatchValidOnDate:(NSDate *)matchValidOnDate {
    [self setObject:matchValidOnDate forKey:(__bridge id)kSecMatchValidOnDate];
}

- (NSDate *)matchValidOnDate {
    return [self objectForKey:(__bridge id)kSecMatchValidOnDate];
}

- (void)setMatchLimit:(ZXKeychainItemMatchLimit)matchLimit {
    id obj = nil;
    switch (matchLimit) {
        case ZXKeychainItemMatchLimitAll:
            obj = (__bridge id)kSecMatchLimitAll;
            break;
        case ZXKeychainItemMatchLimitOne:
            obj = (__bridge id)kSecMatchLimitOne;
            break;
        default:
            break;
    }
    [self setObject:obj forKey:(__bridge id)kSecMatchLimit];
}

- (ZXKeychainItemMatchLimit)matchLimit {
    ZXKeychainItemMatchLimit limit = ZXKeychainItemMatchLimitUnspecified;
    id obj = [self objectForKey:(__bridge id)kSecMatchLimit];
    if (obj == (__bridge id)kSecMatchLimitAll) {
        limit = ZXKeychainItemMatchLimitAll;
    } else if (obj == (__bridge id)kSecMatchLimitOne) {
        limit = ZXKeychainItemMatchLimitOne;
    }
    return limit;
}

@end
