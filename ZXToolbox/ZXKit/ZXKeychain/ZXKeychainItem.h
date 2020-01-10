//
// ZXKeychainItem.h
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

#import <Foundation/Foundation.h>
#import <Security/Security.h>

NS_ASSUME_NONNULL_BEGIN

/// The keychain item.
@interface ZXKeychainItem : NSObject <NSCopying>

/// Create a item with data.
/// @param data The item data.
- (instancetype)initWithData:(NSDictionary *)data;

/// Set value for specify key, unless the value is nil, in which case send -removeObject:forKey:.
/// @param obj The value for aKey. A strong reference to the object is maintained by the dictionary.
/// @param key The key for value.
- (void)setObject:(id _Nullable)obj forKey:(id)key;

/// Returns the value associated with a given key.
/// @param key The key for which to return the corresponding value.
/// @return The value associated with aKey, or nil if no value is associated with aKey.
- (nullable id)objectForKey:(id)key;

/// Removes a given key and its associated value from the data.
/// @param key The key to remove.
- (void)removeObjectForKey:(id)key;

/// The query dictionary.
- (nullable NSDictionary *)query;

@end

NS_ASSUME_NONNULL_END
