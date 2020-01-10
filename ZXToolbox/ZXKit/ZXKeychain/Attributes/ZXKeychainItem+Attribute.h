//
// ZXKeychainItem+Attribute.h
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

/// Values you use with the kSecAttrAccessible attribute key, listed from most to least restrictive.
typedef NS_ENUM(NSInteger, ZXKeychainItemAttrAccessible) {
    /// The data in the keychain can only be accessed when the device is unlocked. Only available if a passcode is set on the device.
    ZXKeychainItemAttrAccessibleWhenPasscodeSetThisDeviceOnly,
    /// The data in the keychain item can be accessed only while the device is unlocked by the user.
    ZXKeychainItemAttrAccessibleWhenUnlockedThisDeviceOnly,
    /// The data in the keychain item can be accessed only while the device is unlocked by the user.
    ZXKeychainItemAttrAccessibleWhenUnlocked,
    /// The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
    ZXKeychainItemAttrAccessibleAfterFirstUnlockThisDeviceOnly,
    /// The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
    ZXKeychainItemAttrAccessibleAfterFirstUnlock,
    /// The data in the keychain item can always be accessed regardless of whether the device is locked.
    ZXKeychainItemAttrAccessibleAlwaysThisDeviceOnly API_DEPRECATED("Use an accessibility level that provides some user protection, such as kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly", macos(10.9, 10.14), ios(4.0, 12.0)),
    /// The data in the keychain item can always be accessed regardless of whether the device is locked.
    ZXKeychainItemAttrAccessibleAlways API_DEPRECATED("Use an accessibility level that provides some user protection, such as kSecAttrAccessibleAfterFirstUnlock", macos(10.9, 10.14), ios(4.0, 12.0)),
    /// Unspecified
    ZXKeychainItemAttrAccessibleUnspecified
};

/// Specify the attributes of keychain items.
@interface ZXKeychainItem (Attribute)

/**
 @see kSecAttrAccess (macOS only)
 
 @abstract
 A key whose value in an access instance indicating access control list settings for this item.
 
 @discussion
 The corresponding value is a SecAccessRef instance describing the access control settings for this item. Create an access instance by calling the SecAccessCreate method. See Access Control Lists for more information.
 
 Important
 
 This attribute is mutually exclusive with the kSecAttrAccessControl attribute. Also, it only applies to keychain items stored in macOS that don’t have one or both of the kSecAttrSynchronizable or kSecUseDataProtectionKeychain keys set to true.
 */
@property (nonatomic, assign, nullable) SecAccessRef accessRef API_AVAILABLE(macos(10.7), ios(NA));

/**
 @see kSecAttrAccessGroup (iOS; also macOS if kSecAttrSynchronizable specified)
 
 @abstract
 A key whose value in an access control instance indicating access control settings for the item.
 
 @discussion
 The corresponding value is of type CFStringRef and indicates the item’s one and only access group.
 
 For an app to access a keychain item, one of the groups to which the app belongs must be the item’s group. The list of an app’s access groups consists of the following string identifiers, in this order:
 
 The strings in the app’s Keychain Access Groups Entitlement
 
 The app ID string
 
 The strings in the App Groups Entitlement
 
 Two or more apps that are in the same access group can share keychain items. For more details, see Sharing Access to Keychain Items Among a Collection of Apps.
 
 Specify which access group a keychain item belongs to when you create it by setting the kSecAttrAccessGroup attribute in the query you send to the SecItemAdd method. Naming a group that’s not among the creating app’s access groups—including the empty string, which is always an invalid group—generates an error. If you don’t explicitly set a group, keychain services defaults to the app’s first access group, which is either the first keychain access group, or the app ID when the app has no keychain groups. In the latter case, the item is only accessible to the app creating the item, since no other app can be in that group.
 
 By default, the SecItemUpdate, SecItemDelete, and SecItemCopyMatching methods search all the app’s access groups. Add the kSecAttrAccessGroup attribute to the query to limit the search to a particular group.
 
 Important
 
 This attribute applies to macOS keychain items only if you also set a value of true for the kSecUseDataProtectionKeychain key, the kSecAttrSynchronizable key, or both.
 */
@property (nonatomic, strong, nullable) NSString *accessGroup;

/**
 @see kSecAttrAccessible (iOS; also macOS if kSecAttrSynchronizable specified)
 
 @abstract
 A key whose value indicates when a keychain item is accessible.
 
 @discussion
 The corresponding value, one of those found in Accessibility Values, indicates when your app needs access to the data in a keychain item. Choose the most restrictive option that meets your app’s needs so that the system can protect that item to the greatest extent possible. For more information, see Restricting Keychain Item Accessibility.
 
 Important
 
 You can use this attribute for macOS keychain items only if you also set a value of true for the kSecUseDataProtectionKeychain key, the kSecAttrSynchronizable key, or both. For any item marked as synchronizable, the value for the kSecAttrAccessible key may only be one whose name does not end with ThisDeviceOnly, as those cannot sync to another device.
 
 Note
 
 The app must provide the contents of the keychain item (kSecValueData) when changing this attribute in iOS 4 and earlier.
 */
@property (nonatomic, assign) ZXKeychainItemAttrAccessible accessible;

/**
 @see kSecAttrLabel
 
 @abstract
 A key whose value is a string indicating the item's label.
 
 @discussion
 The corresponding value is of type CFStringRef and contains the user-visible label for this item.

 On key creation, if not explicitly specified, this attribute defaults to NULL.
 */
@property (nonatomic, strong, nullable) NSString *label;

@end

NS_ASSUME_NONNULL_END
