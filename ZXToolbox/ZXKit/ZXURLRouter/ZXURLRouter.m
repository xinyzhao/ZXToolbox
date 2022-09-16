//
// ZXURLRouter.m
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

#import "ZXURLRouter.h"
#import "ZXToolbox+Macros.h"
#import "NSURL+ZXToolbox.h"

@interface ZXURLHandler : NSObject
@property (nonatomic, nullable, copy) NSURL *url;
@property (nonatomic, nullable, copy) id (^handler)(NSURL *url, id _Nullable data);
@property (nonatomic, nullable, weak) id target;
@property (nonatomic, nullable, assign) SEL action;

@end

@implementation ZXURLHandler

- (instancetype)initWithURL:(nullable NSURL *)url handler:(id _Nullable (^)(NSURL *url, id _Nullable data))handler {
    self = [super init];
    if (self) {
        self.url = url;
        self.handler = handler;
    }
    return self;
}

- (instancetype)initWithURL:(nullable NSURL *)url target:(id)target action:(SEL)action {
    self = [super init];
    if (self) {
        self.url = url;
        self.target = target;
        self.action = action;
    }
    return self;
}

@end

@interface ZXURLRouter ()
@property (nonatomic, strong) NSMutableArray<ZXURLHandler *> *global;
@property (nonatomic, strong) NSMutableDictionary<NSURL *, NSMutableSet<ZXURLHandler *> *> *routes;

@end

@implementation ZXURLRouter

+ (instancetype)sharedRouter {
    static ZXURLRouter *sharedRoter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedRoter = [[ZXURLRouter alloc] init];
    });
    return sharedRoter;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _global = [[NSMutableArray alloc] init];
        _routes = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSUInteger)addHandler:(id _Nullable(^)(NSURL *url, id _Nullable data))handler forURL:(nullable NSURL *)url {
    ZXURLHandler *obj = [[ZXURLHandler alloc] initWithURL:url handler:handler];
    BOOL added = YES;
    AT_SYNCHRONIZED_SELF_BEGIN
    if (url == nil) {
        if (self.isExclusiveRoute) {
            if (_global.count > 0) {
                added = NO;
            }
        }
        if (added) {
            [_global addObject:obj];
        }
    } else {
        NSMutableSet *set = [_routes objectForKey:url];
        if (set == nil) {
            set = [[NSMutableSet alloc] init];
            [_routes setObject:set forKey:url];
        }
        if (self.isExclusiveRoute) {
            if (set.count > 0) {
                added = NO;
            }
        }
        if (added) {
            [set addObject:obj];
        }
    }
    AT_SYNCHRONIZED_SELF_END
    return added ? obj.hash : 0;
}

- (void)removeHandler:(NSUInteger)handler forURL:(nullable NSURL *)url {
    AT_SYNCHRONIZED_SELF_BEGIN
    if (url == nil) {
        for (ZXURLHandler *obj in _global) {
            if (obj.hash == handler) {
                [_global removeObject:obj];
                break;
            }
        }
    } else {
        NSMutableSet *set = [_routes objectForKey:url];
        if (set) {
            NSArray *list = [set allObjects];
            for (ZXURLHandler *obj in list) {
                if (obj.hash == handler) {
                    [set removeObject:obj];
                    break;
                }
            }
        }
    }
    AT_SYNCHRONIZED_SELF_END
}

- (BOOL)addTarget:(id)target action:(SEL)action forURL:(nullable NSURL *)url {
    ZXURLHandler *obj = [[ZXURLHandler alloc] initWithURL:url target:target action:action];
    BOOL added = YES;
    AT_SYNCHRONIZED_SELF_BEGIN
    if (url == nil) {
        if (self.isExclusiveRoute) {
            if (_global.count > 0) {
                added = NO;
            }
        }
        if (added) {
            [_global addObject:obj];
        }
    } else {
        NSMutableSet *set = [_routes objectForKey:url];
        if (set == nil) {
            set = [[NSMutableSet alloc] init];
            [_routes setObject:set forKey:url];
        }
        if (self.isExclusiveRoute) {
            if (set.count > 0) {
                added = NO;
            }
        }
        if (added) {
            [set addObject:obj];
        }
    }
    AT_SYNCHRONIZED_SELF_END
    return added;
}

- (void)removeTarget:(id)target action:(nullable SEL)action forURL:(nullable NSURL *)url {
    AT_SYNCHRONIZED_SELF_BEGIN
    if (url == nil) {
        NSArray *list = [_global copy];
        for (ZXURLHandler *obj in list) {
            if (obj.target == target) {
                if (obj.action == action || action == nil) {
                    [_global removeObject:obj];
                }
            }
        }
    } else {
        NSMutableSet *set = [_routes objectForKey:url];
        if (set) {
            NSArray *list = [set allObjects];
            for (ZXURLHandler *obj in list) {
                if (obj.target == target) {
                    if (obj.action == action || action == nil) {
                        [set removeObject:obj];
                    }
                }
            }
        }
    }
    AT_SYNCHRONIZED_SELF_END
}

- (nullable NSArray<ZXURLHandler *> *)routesForURL:(NSURL *)url {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    AT_SYNCHRONIZED_SELF_BEGIN
    // 全局路由
    if (_global.count > 0) {
        [list addObjectsFromArray:_global];
    }
    // 全量匹配
    NSSet *set = [_routes objectForKey:url];
    if (set) {
        NSLogD(@"#match succeeds: %@", url);
        [list addObjectsFromArray:[set allObjects]];
    }
    // 拆分url
    NSURLComponents *uc = [url URLComponents];
    // 去除path后的内容
    uc.fragment = nil;
    uc.query = nil;
    uc.queryItems = nil;
    // 继续匹配
    set = [_routes objectForKey:uc.URL];
    if (set) {
        NSLogD(@"#match succeeds: %@", uc.URL);
        [list addObjectsFromArray:[set allObjects]];
    }
    // 拆分path
    NSMutableArray *pathes = [[url.path componentsSeparatedByString:@"/"] mutableCopy];
    while (pathes.count > 1) {
        uc.path = [pathes componentsJoinedByString:@"/"];
        // 继续匹配
        set = [_routes objectForKey:uc.URL];
        if (set) {
            NSLogD(@"#match succeeds: %@", uc.URL);
            [list addObjectsFromArray:[set allObjects]];
        }
        // 移除最后的path
        [pathes removeLastObject];
    }
    // 匹配根路径
    uc.path = @"/";
    set = [_routes objectForKey:uc.URL];
    if (set) {
        NSLogD(@"#match succeeds: %@", uc.URL);
        [list addObjectsFromArray:[set allObjects]];
    }
    // 去除path
    uc.path = nil;
    // 继续匹配
    set = [_routes objectForKey:uc.URL];
    if (set) {
        NSLogD(@"#match succeeds: %@", uc.URL);
        [list addObjectsFromArray:[set allObjects]];
    }
    AT_SYNCHRONIZED_SELF_END
    return list.count > 0 ? [list copy] : nil;
}

- (BOOL)canOpenURL:(NSURL *)url {
    AT_SYNCHRONIZED_SELF_BEGIN
    if (_global.count > 0) {
        return YES;
    }
    AT_SYNCHRONIZED_SELF_END
    NSArray *list = [self routesForURL:url];
    if (list.count > 0) {
        return YES;
    }
    return NO;
}

- (int)openURL:(NSURL*)url withData:(nullable id)data completionHandler:(void (^ _Nullable)(NSURL *url, id _Nullable data, id _Nullable response, NSString * _Nullable error))completionHandler {
    int matched = 0;
    NSArray *handlers = [self routesForURL:url];
    for (ZXURLHandler *obj in handlers) {
        id response = nil;
        if (obj.handler) {
            ++matched;
            response = obj.handler(url, data);
        } else if ([obj.target respondsToSelector:obj.action]) {
            ++matched;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            response = [obj.target performSelector:obj.action withObject:url withObject:data];
#pragma clang diagnostic pop
        }
        if (matched > 0 && completionHandler) {
            completionHandler(url, data, response, nil);
        }
    }
    if (matched <= 0 && completionHandler) {
        completionHandler(url, data, nil, @"404 Not Found");
    }
    return matched;
}

@end
