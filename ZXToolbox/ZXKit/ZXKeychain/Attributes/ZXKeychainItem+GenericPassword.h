//
// ZXKeychainItem+GenericPassword.h
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

/**
@see kSecClassGenericPassword

@abstract
The value that indicates a generic password item.

@discussion
The following keychain item attributes apply to an item of this class:

kSecAttrAccess (macOS only)

kSecAttrAccessControl

kSecAttrAccessGroup (iOS; also macOS if kSecAttrSynchronizable specified)

kSecAttrAccessible (iOS; also macOS if kSecAttrSynchronizable specified)

kSecAttrCreationDate

kSecAttrModificationDate

kSecAttrDescription

kSecAttrComment

kSecAttrCreator

kSecAttrType

kSecAttrLabel

kSecAttrIsInvisible

kSecAttrIsNegative

kSecAttrAccount

kSecAttrService

kSecAttrGeneric

kSecAttrSynchronizable
*/
@interface ZXKeychainItem (GenericPassword)

/**
 @see kSecAttrAccessControl
 
 @abstract
 A key whose value in an access control instance indicating access control settings for the item.
 
 @discussion
 The corresponding value is a SecAccessControlRef instance, created with the SecAccessControlCreateWithFlags method, containing access control conditions for the item. See Restricting Keychain Item Accessibility for more details.
 
 Important
 
 This attribute is mutually exclusive with the kSecAttrAccess attribute.
 */
@property (nonatomic, assign, nullable) SecAccessControlRef accessControl;

/**
 @see kSecAttrService
 
 @abstract
 A key whose value is a string indicating the item's service.
 
 @discussion
 The corresponding value is a string of type CFStringRef that represents the service associated with this item. Items of class kSecClassGenericPassword have this attribute.
 */
@property (nonatomic, strong, nullable) NSString *service;

/**
 @see kSecAttrGeneric
 
 @abstract
 A key whose value indicates the item's user-defined attributes.
 
 @discussion
 The corresponding value is of type CFDataRef and contains a user-defined attribute. Items of class kSecClassGenericPassword have this attribute.
 */
@property (nonatomic, strong, nullable) NSData *generic;

@end

NS_ASSUME_NONNULL_END
