//
// ZXKeychainItem+Class.h
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

/// Values you use with the kSecClass key.
typedef NS_ENUM(NSInteger, ZXKeychainItemClass) {
    /// The value that indicates the item is unspecified.
    ZXKeychainItemClassUnspecified,
    /// The value that indicates a generic password item.
    ZXKeychainItemClassGenericPassword,
    /// The value that indicates an Internet password item.
    ZXKeychainItemClassInternetPassword,
    /// The value that indicates a certificate item.
    ZXKeychainItemClassCertificate,
    /// The value that indicates a cryptographic key item.
    ZXKeychainItemClassKey,
    /// The value that indicates an identity item.
    ZXKeychainItemClassIdentity,
};

/**
Specify the class of a keychain item.

Keychain items come in a variety of classes according to the kind of data they hold, such as passwords, cryptographic keys, and certificates. The item's class dictates which attributes apply and enables the system to decide whether or not the data should be encrypted on disk. For example, passwords require encryption, but certificates don't because they are not secret.

Use the key and one of the corresponding values listed here to specify the class for a new item you create with a call to the SecItemAdd function by placing the key/value pair in the attributes dictionary.

Later, use this same pair in the query dictionary when searching for an item with one of the SecItemCopyMatching, SecItemUpdate, or SecItemDelete functions.
*/
@interface ZXKeychainItem (Class)

/**
@see kSecClass

@abstract
A dictionary key whose value is the item's class.

@discussion
Possible values for this key are listed in Item Class Values. Default is ZXKeychainItemClassUnspecified
*/
@property (nonatomic, assign) ZXKeychainItemClass itemClass;

@end

NS_ASSUME_NONNULL_END
