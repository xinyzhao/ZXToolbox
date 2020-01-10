//
// ZXKeychainItem+Password.h
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

/// Indicating whether the item is synchronized through iCloud.
typedef NS_ENUM(NSInteger, ZXKeychainItemAttrSync) {
    ZXKeychainItemAttrSyncTrue,
    ZXKeychainItemAttrSyncFalse,
    ZXKeychainItemAttrSyncAny,
    ZXKeychainItemAttrSyncUnspecified,
};

/// The value that indicates a password item.
@interface ZXKeychainItem (Password)

/**
 @see kSecAttrCreationDate
 
 @abstract kSecAttrCreationDate
 A key whose value indicates the item's creation date.
 
 @discussion
 The corresponding value is of type CFDateRef and represents the date the item was created. Read only.
 */
@property (nonatomic, readonly, nullable) NSDate *creationDate;

/**
 @see kSecAttrModificationDate
 
 @abstract kSecAttrModificationDate
 A key whose value indicates the item's last modification date.
 
 @discussion
 The corresponding value is of type CFDateRef and represents the last time the item was updated. Read only.
 */
@property (nonatomic, readonly, nullable) NSDate *modificationDate;

/**
 @see kSecAttrDescription
 
 @abstract
 A key whose value is a string indicating the item's description.
 
 @discussion
 The corresponding value is of type CFStringRef and specifies a user-visible string describing this kind of item (for example, "Disk image password").
 */
@property (nonatomic, strong, nullable) NSString *desc;

/**
 @see kSecAttrComment
 
 @abstract
 A key whose value is a string indicating a comment associated with the item.
 
 @discussion
 The corresponding value is of type CFStringRef and contains the user-editable comment for this item.
 */
@property (nonatomic, strong, nullable) NSString *comment;

/**
 @see kSecAttrCreator
 
 @abstract
 A key whose value indicates the item's creator.
 
 @discussion
 The corresponding value is of type CFNumberRef and represents the item's creator. This number is the unsigned integer representation of a four-character code (for example, 'aCrt').
 */
@property (nonatomic, strong, nullable) NSNumber *creator;

/**
 @see kSecAttrType
 
 @abstract
 A key whose value indicates the item's type.
 
 @discussion
 The corresponding value is of type CFNumberRef and represents the item's type. This number is the unsigned integer representation of a four-character code (for example, 'aTyp').
 */
@property (nonatomic, strong, nullable) NSNumber *type;

/**
 @see kSecAttrIsInvisible
 
 @abstract
 A key whose value is a Boolean indicating the item's visibility.
 
 @discussion
 The corresponding value is of type CFBooleanRef and is kCFBooleanTrue if the item is invisible (that is, should not be displayed).
 */
@property (nonatomic, assign) BOOL isInvisible;

/**
 @see kSecAttrIsNegative
 
 @abstract
 A key whose value is a Boolean indicating whether the item has a valid password.
 
 @discussion
 The corresponding value is of type CFBooleanRef and indicates whether there is a valid password associated with this keychain item. This is useful if your application doesn't want a password for some particular service to be stored in the keychain, but prefers that it always be entered by the user.
 */
@property (nonatomic, assign) BOOL isNegative;

/**
 @see kSecAttrAccount
 
 @abstract
 A key whose value is a string indicating the item's account name.
 
 @discussion
 The corresponding value is of type CFStringRef and contains an account name. Items of class kSecClassGenericPassword and kSecClassInternetPassword have this attribute.
 */
@property (nonatomic, strong, nullable) NSString *account;

/**
 @see kSecAttrSynchronizable
 
 @abstract
 A key whose value is a string indicating whether the item is synchronized through iCloud.
 
 @discussion
 The corresponding value is of type CFBooleanRef and indicates whether the item in question is synchronized to other devices through iCloud. To add a new synchronizable item, or to obtain synchronizable results from a query, supply this key with a value of kCFBooleanTrue. If the key is not supplied, or has a value of kCFBooleanFalse, then no synchronizable items are added or returned. Use kSecAttrSynchronizableAny to query for both synchronizable and non-synchronizable results.

 A keychain item created in macOS with this attribute behaves like an iOS keychain item. For example, you share the item between apps using Access Groups instead of Access Control Lists. To create a keychain item in macOS that behaves like an iOS keychain item without making it synchronizable, use kSecUseDataProtectionKeychain instead.

 The following caveats apply when you specify the kSecAttrSynchronizable key:

 * Updating or deleting items using the kSecAttrSynchronizable key will affect all copies of the item, not just the one on your local device. Be sure that it makes sense to use the same password on all devices before making a password synchronizable.

 * Only password items can be synchronized. Keychain syncing is not supported for certificates or cryptographic keys.

 * Items stored or obtained using the kSecAttrSynchronizable key cannot specify SecAccessRef-based access control with kSecAttrAccess. If a password is intended to be shared between multiple applications, the kSecAttrAccessGroup key must be specified, and each application using this password must have the Keychain Access Groups Entitlement enabled, and a common access group specified.

 * Items stored or obtained using the kSecAttrSynchronizable key may not also specify a kSecAttrAccessible value that is incompatible with syncing (namely, those whose names end with ThisDeviceOnly.)

 * Items stored or obtained using the kSecAttrSynchronizable key cannot be specified by reference. Use only kSecReturnAttributes and/or kSecReturnData to retrieve results.

 * Do not use persistent references to synchronizable items. They cannot be moved between devices, and may not resolve if the item is modified on some other device.

 * When specifying a query that uses the kSecAttrSynchronizable key, search keys are limited to the item's class and attributes. The only search constant that may be used is kSecMatchLimit; other constants using the kSecMatch prefix are not supported.
 */
@property (nonatomic, assign) ZXKeychainItemAttrSync synchronizable;

@end

NS_ASSUME_NONNULL_END
