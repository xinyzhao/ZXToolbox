//
// ZXKeychainItem+Value.h
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

/// These keys appear in the result dictionary when you specify more than one search result key.
@interface ZXKeychainItem (Value)

/**
 @see kSecValueData
 
 @abstract
 A key whose value is the item's data.
 
 @discussion
 The corresponding value is of type CFDataRef.  For keys and password items, the data is secret (encrypted) and may require the user to enter a password for access.
 */
@property (nonatomic, strong, nullable) NSData *valueData;

/**
 @see kSecValueRef
 
 @abstract
 A key whose value is a reference to the item.
 
 @discussion
 The corresponding value, depending on the item class requested, is of type SecKeychainItemRef, SecKeyRef, SecCertificateRef, or SecIdentityRef.
 */
@property (nonatomic, assign, nullable) id valueRef;

/**
 @see kSecValuePersistentRef
 
 @abstract
 A key whose value is a persistent reference to the item.
 
 @discussion
 The corresponding value is of type CFDataRef. The bytes in this object can be stored by the caller and used on a subsequent invocation of the application (or even a different application) to retrieve the item referenced by it.
 */
@property (nonatomic, strong, nullable) NSData *valuePersistentRef;

@end

NS_ASSUME_NONNULL_END
