//
// ZXKeychain.h
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

#import "ZXKeychainItem+Class.h"

#import "ZXKeychainItem+Attribute.h"
#import "ZXKeychainItem+Certificate.h"
#import "ZXKeychainItem+GenericPassword.h"
#import "ZXKeychainItem+Identity.h"
#import "ZXKeychainItem+InternetPassword.h"
#import "ZXKeychainItem+Key.h"
#import "ZXKeychainItem+Password.h"

#import "ZXKeychainItem+Match.h"
#import "ZXKeychainItem+Return.h"
#import "ZXKeychainItem+Value.h"

NS_ASSUME_NONNULL_BEGIN

/// ZXKeychain
@interface ZXKeychain : NSObject

/// An access control instance indicating access control settings for the item.
@property (nonatomic, strong, nullable) NSString *accessGroup;

/// Indicating whether the item is synchronized through iCloud.
@property (nonatomic, assign) BOOL synchronizable;

/// Nil if the last operation was successfully.
@property (nonatomic, readonly) NSError *lastError;

/// The default keychain instance
+ (instancetype)defaultKeychain;

/// Stores the data value in the keychain item under the given key.
/// @param value Data to be written to the keychain.
/// @param key Key under which the value is stored in the keychain.
/// @param accessible  Indicates when a keychain item is accessible.
/// @return True if the value was successfully written to the keychain, otherwise, lastError is not nil.
- (BOOL)setData:(NSData *_Nullable)value forKey:(NSString *)key withAccessible:(ZXKeychainItemAttrAccessible)accessible;

/// Stores the data value in the keychain item under the given key. Accessible is ZXKeychainItemAttrAccessibleWhenUnlocked.
/// @param value Data to be written to the keychain.
/// @param key Key under which the value is stored in the keychain.
/// @return True if the value was successfully written to the keychain, otherwise, lastError is not nil.
- (BOOL)setData:(NSData *_Nullable)value forKey:(NSString *)key;

/// Retrieves the data from the keychain that corresponds to the given key.
/// @param key The key that is used to read the keychain item.
/// @return The data value from the keychain. Returns nil maybe unable to read the item, and lastError is not nil.
- (nullable NSData *)dataForKey:(NSString *)key;

/// Stores the text string in the keychain item under the given key.
/// @param value Text string to be written to the keychain.
/// @param key Key under which the value is stored in the keychain.
/// @param accessible Indicates when a keychain item is accessible.
/// @return True if the value was successfully written to the keychain, otherwise, lastError is not nil.
- (BOOL)setString:(NSString *_Nullable)value forKey:(NSString *)key withAccessible:(ZXKeychainItemAttrAccessible)accessible;

/// Stores the text string in the keychain item under the given key. Accessible is ZXKeychainItemAttrAccessibleWhenUnlocked.
/// @param value Text string to be written to the keychain.
/// @param key Key under which the value is stored in the keychain.
/// @return True if the value was successfully written to the keychain, otherwise, lastError is not empty.
- (BOOL)setString:(NSString *_Nullable)value forKey:(NSString *)key;

/// Retrieves the text string from the keychain that corresponds to the given key.
/// @param key The key that is used to read the keychain item.
/// @return The string value from the keychain. Returns nil if maybe to read the item, and lastError is not nil.
- (nullable NSString *)stringForKey:(NSString *)key;

/// Return all keys from keychain.
/// @return The all item keys from the keychain. Returns nil if unable to read the item, and lastError is not nil.
- (nullable NSArray<NSString *> *)allKeys;

/// Deletes the single keychain item specified by the key.
/// @param key The key that is used to delete the keychain item.
/// @return True if the item was successfully deleted, otherwise, lastError is not nil.
- (BOOL)removeItemForKey:(NSString *)key;

/// Deletes all Keychain items used by the app.
/// @return True if the item was successfully deleted, otherwise, lastError is not nil.
- (BOOL)removeAllItems;

@end

/// ZXKeychain (Error)
@interface ZXKeychain (Error)

/// Crate a NSError with OSStatus
/// @param status OSStatus
+ (NSError *)errerWithStatus:(OSStatus)status;

@end

NS_ASSUME_NONNULL_END
