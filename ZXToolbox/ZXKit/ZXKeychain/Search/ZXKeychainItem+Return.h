//
// ZXKeychainItem+Return.h
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

/// Specify how you want returned keychain item data formatted.
@interface ZXKeychainItem (Return)

/**
 @see kSecReturnData
 
 @abstract
 A key whose value is a Boolean indicating whether or not to return item data.
 
 @discussion
 The corresponding value is of type CFBooleanRef. A value of kCFBooleanTrue indicates that the data of an item should be returned in the form of a CFDataRef object.

 For keys and password items, data is secret (encrypted) and may require the user to enter a password for access. For key items, the resulting data has the same format as the return value of the function SecKeyCopyExternalRepresentation.
 */
@property (nonatomic, assign) BOOL returnData;

/**
 @see kSecReturnAttributes
 
 @abstract
 A key whose value is a Boolean indicating whether or not to return item attributes.
 
 @discussion
 The corresponding value is of type CFBooleanRef. A value of kCFBooleanTrue indicates that a dictionary of the (unencrypted) attributes of an item should be returned in the form of a CFDictionaryRef using the keys and values defined in Item Attribute Keys and Values.
 */
@property (nonatomic, assign) BOOL returnAttributes;

/**
 @see kSecReturnRef
 
 @abstract
 A key whose value is a Boolean indicating whether or not to return a reference to an item.
 
 @discussion
 The corresponding value is of type CFBooleanRef. A value of kCFBooleanTrue indicates that a reference should be returned. Depending on the item class requested, the returned references may be of type SecKeychainItemRef, SecKeyRef, SecCertificateRef, SecIdentityRef, or CFDataRef.
 */
@property (nonatomic, assign) BOOL returnRef;

/**
 @see kSecReturnPersistentRef
 
 @abstract
 A key whose value is a Boolean indicating whether or not to return a persistent reference to an item.
 
 @discussion
 The corresponding value is of type CFBooleanRef. A value of kCFBooleanTrue indicates that a persistent reference to an item should be returned as a CFDataRef object. Unlike normal references, a persistent reference may be stored on disk or passed between processes.
 */
@property (nonatomic, assign) BOOL returnPersistentRef;

@end

NS_ASSUME_NONNULL_END
