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
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, nullable, copy) id _Nullable (^handler)(NSURL *url, id _Nullable data);
@property (nonatomic, nullable, weak) id target;
@property (nonatomic, nullable, assign) SEL action;

@end

@implementation ZXURLHandler

- (instancetype)initWithURL:(NSURL *)url handler:(id _Nullable (^)(NSURL *url, id _Nullable data))handler {
    self = [super init];
    if (self) {
        self.url = url;
        self.handler = handler;
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)url target:(id)target action:(SEL)action {
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
        _routes = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSUInteger)addHandler:(id (^)(NSURL *url, id _Nullable data))handler forURL:(NSURL *)url {
    ZXURLHandler *obj = [[ZXURLHandler alloc] initWithURL:url handler:handler];
    BOOL added = YES;
    AT_SYNCHRONIZED_SELF_BEGIN
    NSMutableSet *set = [_routes objectForKey:url];
    if (set == nil) {
        set = [[NSMutableSet alloc] init];
        [_routes setObject:set forKey:url];
    }
    if (self.isExclusiveURL) {
        if (set.count > 0) {
            added = NO;
        }
    }
    if (added) {
        [set addObject:obj];
    }
    AT_SYNCHRONIZED_SELF_END
    return added ? obj.hash : 0;
}

- (void)removeHandler:(NSUInteger)handler forURL:(NSURL *)url {
    AT_SYNCHRONIZED_SELF_BEGIN
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
    AT_SYNCHRONIZED_SELF_END
}

- (BOOL)addTarget:(id)target action:(SEL)action forURL:(NSURL *)url {
    ZXURLHandler *obj = [[ZXURLHandler alloc] initWithURL:url target:target action:action];
    BOOL added = YES;
    AT_SYNCHRONIZED_SELF_BEGIN
    NSMutableSet *set = [_routes objectForKey:url];
    if (set == nil) {
        set = [[NSMutableSet alloc] init];
        [_routes setObject:set forKey:url];
    }
    if (self.isExclusiveURL) {
        if (set.count > 0) {
            added = NO;
        }
    }
    if (added) {
        [set addObject:obj];
    }
    AT_SYNCHRONIZED_SELF_END
    return added;
}

- (void)removeTarget:(id)target action:(SEL _Nullable)action forURL:(NSURL *)url {
    AT_SYNCHRONIZED_SELF_BEGIN
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
    AT_SYNCHRONIZED_SELF_END
}

- (nullable NSArray<ZXURLHandler *> *)handlersForURL:(NSURL *)url {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    AT_SYNCHRONIZED_SELF_BEGIN
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
    NSArray *list = [self handlersForURL:url];
    return list.count > 0 ? YES : NO;
}

- (int)openURL:(NSURL*)url withData:(id _Nullable)data completionHandler:(void (^ _Nullable)(NSURL *url, id _Nullable data, id _Nullable response, NSString * _Nullable error))completionHandler {
    int matched = 0;
    NSArray *handlers = [self handlersForURL:url];
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
        if (completionHandler) {
            completionHandler(url, data, response, nil);
        }
    }
    if (matched <= 0 && completionHandler) {
        completionHandler(url, data, nil, @"404 Not Found");
    }
    return matched;
}

@end
