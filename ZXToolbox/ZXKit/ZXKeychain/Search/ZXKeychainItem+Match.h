//
// ZXKeychainItem+Match.h
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

#import "ZXKeychainItem.h"

NS_ASSUME_NONNULL_BEGIN

/// Use these values with the kSecMatchLimit key.
typedef NS_ENUM(NSInteger, ZXKeychainItemMatchLimit) {
    /// A value that corresponds to matching an unlimited number of items.
    ZXKeychainItemMatchLimitAll,
    /// A value that corresponds to matching exactly one item.
    ZXKeychainItemMatchLimitOne,
    /// Unspecified.
    ZXKeychainItemMatchLimitUnspecified,
};

/// Filter a keychain item search.
@interface ZXKeychainItem (Match)

/**
 @see kSecMatchPolicy
 
 @abstract
 A key whose value indicates a policy with which a matching certificate or identity must verify.
 
 @discussion
 The corresponding value is of type SecPolicyRef.
 */
@property (nonatomic, assign, nullable) SecPolicyRef matchPolicyRef;

/**
 @see kSecMatchItemList
 
 @abstract
 A key whose value indicates a list of items to search.
 
 @discussion
 To provide your own set of items to be filtered by a search query rather than searching the keychain, specify this search key in a call to the SecItemCopyMatching function with a value that consists of an object of type CFArrayRef where the array contains either SecKeychainItemRef, SecKeyRef, SecCertificateRef, SecIdentityRef, or CFDataRef items. The objects in the provided array must all be of the same type.

 To convert from persistent item references to normal item references, specify this search key in a call to the SecItemCopyMatching function with a value of type CFArrayRef where the array contains one or more CFDataRef elements (the persistent references), and a return-type key of kSecReturnRef whose value is kCFBooleanTrue.

 To delete an item identified by a transient reference, specify the kSecMatchItemList search key in a call to the SecItemDelete function with a reference returned by using the kSecReturnRef return type key in a previous call to the SecItemCopyMatching or SecItemAdd functions.

 To delete an item identified by a persistent reference, specify the kSecMatchItemList search key in a call to the SecItemDelete function with a persistent reference returned by using the kSecReturnPersistentRef return type key to the SecItemCopyMatching or SecItemAdd functions.
 */
@property (nonatomic, strong, nullable) NSArray *matchItemList;

/**
 @see kSecMatchSearchList
 
 @abstract
 A key whose value indicates a list of items to search.
 
 @discussion
 The value is a CFArrayRef of SecKeychainRef items. If provided, the search will be limited to the keychain items contained in this list.
 */
@property (nonatomic, strong, nullable) NSArray *matchSearchList;

/**
 @see kSecMatchIssuers
 
 @abstract
 A key whose value is a string to match against a certificate or identity's issuers.
 
 @discussion
 The corresponding value is of type CFArrayRef, where the array consists of X.500 names of type CFDataRef. If provided, returned certificates or identities are limited to those whose certificate chain contains one of the issuers provided in this list.
 */
@property (nonatomic, strong, nullable) NSArray *matchIssuers;

/**
 @see kSecMatchEmailAddressIfPresent
 
 @abstract
 A key whose value is a string to match against a certificate or identity's email address.
 
 @discussion
 The corresponding value is of type CFStringRef and contains an RFC822 email address. If provided, returned certificates or identities are limited to those that either contain the address or do not contain any email address.
 */
@property (nonatomic, strong, nullable) NSString *matchEmailAddressIfPresent;

/**
 @see kSecMatchSubjectContains
 
 @abstract
 A key whose value is a string to look for in a certificate or identity's subject.
 
 @discussion
 The corresponding value is of type CFStringRef. If provided, returned certificates or identities are limited to those whose subject contains this string.
 */
@property (nonatomic, strong, nullable) NSString *matchSubjectContains;

/**
 @see kSecMatchSubjectStartsWith
 
 @abstract
 A key whose value is a string to match against the beginning of a certificate or identity's subject.
 
 @discussion
 The corresponding value is of type CFStringRef. If provided, returned certificates or identities are limited to those whose subject starts with this string.
 */
@property (nonatomic, strong, nullable) NSString *matchSubjectStartsWith API_AVAILABLE(macos(10.7), ios(NA));

/**
 @see kSecMatchSubjectEndsWith
 
 @abstract
 A key whose value is a string to match against the end of a certificate or identity's subject.
 
 @discussion
 The corresponding value is of type CFStringRef. If provided, returned certificates or identities are limited to those whose subject ends with this string.
 */
@property (nonatomic, strong, nullable) NSString *matchSubjectEndsWith API_AVAILABLE(macos(10.7), ios(NA));

/**
 @see kSecMatchSubjectWholeString
 
 @abstract
 A key whose value is a string to exactly match a certificate or identity's subject.
 
 @discussion
 The corresponding value is of type CFStringRef. If provided, returned certificates or identities are limited to those whose subject is exactly equal to this string.
 */
@property (nonatomic, strong, nullable) NSString *matchSubjectWholeString API_AVAILABLE(macos(10.7), ios(NA));

/**
 @see kSecMatchCaseInsensitive
 
 @abstract
 A key whose value is a Boolean indicating whether case-insensitive matching is performed.
 
 @discussion
 The corresponding value is of type CFBooleanRef. If this value is kCFBooleanFalse, or if this attribute is not provided, then case-sensitive string matching is performed.
 */
@property (nonatomic, assign) BOOL matchCaseInsensitive;

/**
 @see kSecMatchDiacriticInsensitive
 
 @abstract
 A key whose value is a Boolean indicating whether diacritic-insensitive matching is performed.
 
 @discussion
 The corresponding value is of type CFBooleanRef. If this value is kCFBooleanFalse, or if this attribute is not provided, then diacritic-sensitive string matching is performed.
 */
@property (nonatomic, assign) BOOL matchDiacriticInsensitive API_AVAILABLE(macos(10.7), ios(NA));

/**
 @see kSecMatchWidthInsensitive
 
 @abstract
 A key whose value is a Boolean indicating whether width-insensitive matching is performed.
 
 @discussion
 The corresponding value is of type CFBooleanRef. If this value is kCFBooleanFalse, or if this attribute is not provided, then width-sensitive string matching is performed (for example, the ASCII character a does not match the UTF-8 full-width letter a (U+FF41).
 */
@property (nonatomic, assign) BOOL matchWidthInsensitive API_AVAILABLE(macos(10.7), ios(NA));

/**
 @see kSecMatchTrustedOnly
 
 @abstract
 A key whose value is a Boolean indicating whether untrusted certificates should be returned.
 
 @discussion
 The corresponding value is of type CFBooleanRef. If this attribute is provided with a value of kCFBooleanTrue, only certificates that can be verified back to a trusted anchor are returned. If this value is kCFBooleanFalse or the attribute is not provided, then both trusted and untrusted certificates may be returned.
 */
@property (nonatomic, assign) BOOL matchTrustedOnly;

/**
 @see kSecMatchValidOnDate
 
 @abstract
 A key whose value indicates the validity date.
 
 @discussion
 The corresponding value is of type CFDateRef. If provided, returned keys, certificates or identities are limited to those that are valid for the given date. Pass a value of kCFNull to indicate the current date.
 */
@property (nonatomic, strong, nullable) NSDate *matchValidOnDate;

/**
 @see kSecMatchLimit
 
 @abstract
 A key whose value indicates the match limit.
 
 @discussion
 The corresponding value is of type CFNumberRef. If provided, this value specifies the maximum number of results to return or otherwise act upon. For a single item, specify kSecMatchLimitOne. To specify all matching items, specify kSecMatchLimitAll. The default behavior is function-dependent.
 */
@property (nonatomic, assign) ZXKeychainItemMatchLimit matchLimit;

@end

NS_ASSUME_NONNULL_END
