//
// ZXKeychainItem.m
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

@interface ZXKeychainItem ()
/// Item data
@property (nonatomic, strong) NSMutableDictionary *data;

@end

@implementation ZXKeychainItem

- (instancetype)initWithData:(NSDictionary *)data {
    self = [super init];
    if (self) {
        self.data = [data mutableCopy];
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ZXKeychainItem *item = [[[self class] allocWithZone:zone] init];
    item.data = [self.data mutableCopy];
    return item;
}

- (NSMutableDictionary *)data {
    if (_data == nil) {
        _data = [[NSMutableDictionary alloc] init];
    }
    return _data;
}

- (NSDictionary *)query {
    return [self.data copy];
}

- (void)setObject:(id _Nullable)obj forKey:(id)key {
    if (obj && key) {
        [self.data setObject:obj forKey:key];
    } else if (key) {
        [self.data removeObjectForKey:key];
    }
}

- (nullable id)objectForKey:(id)key {
    if (key) {
        return self.data[key];
    }
    return nil;
}

- (void)removeObjectForKey:(id)key {
    if (key) {
        [self.data removeObjectForKey:key];
    }
}

@end

