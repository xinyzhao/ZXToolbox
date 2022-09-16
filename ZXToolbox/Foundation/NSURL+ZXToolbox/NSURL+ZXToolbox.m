//
// NSURL+ZXToolbox.m
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2022 Zhao Xin
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

#import "NSURL+ZXToolbox.h"

@implementation NSURL (ZXToolbox)

+ (nullable instancetype)URLWithString:(NSString *)URLString scheme:(nullable NSString *)scheme user:(nullable NSString *)user password:(nullable NSString *)password host:(nullable NSString *)host port:(nullable NSNumber *)port path:(nullable NSString *)path query:(nullable id)query fragment:(nullable NSString *)fragment {
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:URLString];
    if (scheme != nil && scheme.length > 0) {
        components.scheme = scheme;
    }
    if (user != nil && user.length > 0) {
        components.user = user;
    }
    if (password != nil && password.length > 0) {
        components.password = password;
    }
    if (host != nil && host.length > 0) {
        components.host = host;
    }
    if (port != nil) {
        components.port = port;
    }
    if (path != nil && path.length > 0) {
        components.path = path;
    }
    if (query != nil) {
        if ([query isKindOfClass:NSString.class]) {
            NSString *queryStr = (NSString *)query;
            if (queryStr.length > 0) {
                components.query = queryStr;
            }
        } else if ([query isKindOfClass:NSDictionary.class]) {
            NSDictionary *dict = (NSDictionary *)query;
            NSMutableArray *items = [[NSMutableArray alloc] init];
            for (NSString *key in dict.allKeys) {
                NSString *value = dict[key];
                if ([key isKindOfClass:NSString.class] && [value isKindOfClass:NSString.class]) {
                    NSURLQueryItem *item = [[NSURLQueryItem alloc] initWithName:key value:value];
                    [items addObject:item];
                }
            }
            components.queryItems = [items copy];
        }
    }
    if (fragment != nil && fragment.length > 0) {
        components.fragment = fragment;
    }
    return components.URL;
}

+ (nullable instancetype)URLWithString:(NSString *)URLString path:(nullable NSString *)path query:(nullable id)query {
    return [self URLWithString:URLString scheme:nil user:nil password:nil host:nil port:nil path:path query:query fragment:nil];
}

+ (nullable instancetype)URLWithString:(NSString *)URLString path:(nullable NSString *)path {
    return [self URLWithString:URLString path:path query:nil];
}

+ (nullable instancetype)URLWithString:(NSString *)URLString query:(nullable id)query {
    return [self URLWithString:URLString path:nil query:query];
}

- (nullable NSURLComponents *)URLComponents {
    return [[NSURLComponents alloc] initWithURL:self resolvingAgainstBaseURL:NO];
}

- (nullable NSString *)URLString {
    return [[NSURLComponents alloc] initWithURL:self resolvingAgainstBaseURL:NO].string;
}

- (nullable NSDictionary<NSString *, NSString *> *)queryItems {
    NSArray *items = [self URLComponents].queryItems;
    if (items.count > 0) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:items.count];
        for (NSURLQueryItem *item in items) {
            [dict setObject:(item.value ? item.value : @"") forKey:item.name];
        }
        return [dict copy];
    }
    return nil;
}

@end
