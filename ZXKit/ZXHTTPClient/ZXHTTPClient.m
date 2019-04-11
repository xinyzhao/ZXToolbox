//
// ZXHTTPClient.m
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2019 Zhao Xin
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

#import "ZXHTTPClient.h"
#import <sys/utsname.h>

@interface ZXHTTPClient ()

+ (NSURLSession *)URLSession;

@end

#pragma mark - ZXHTTPClient

@implementation ZXHTTPClient

+ (NSURLSession *)URLSession {
    static NSURLSession *_urlSession = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.maxConcurrentOperationCount = 1;
        _urlSession = [NSURLSession sessionWithConfiguration:configuration
                                                   delegate:[ZXHTTPClient securityPolicy]
                                              delegateQueue:operationQueue];
    });
    return _urlSession;
}

+ (ZXHTTPSecurity *)securityPolicy {
    static ZXHTTPSecurity *_securityPolicy = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _securityPolicy = [[ZXHTTPSecurity alloc] init];
    });
    return _securityPolicy;
}

#pragma mark HTTP Request

+ (NSURLSessionDataTask *)requestWithURLString:(NSString *)URLString method:(NSString *)method params:(NSDictionary *)params body:(NSData *)body requestHandler:(void(^)(NSMutableURLRequest *request))requestHandler completionHandler:(void(^)(NSURLSessionDataTask *task, NSData *data, NSError *error))completionHandler {
    // parameters
    if (params.count > 0) {
        NSMutableArray *pairs = [[NSMutableArray alloc] init];
        [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *pair = [NSString stringWithFormat:@"%@=%@", key, obj];
            [pairs addObject:pair];
        }];
        // query string
        NSString *query = [pairs componentsJoinedByString:@"&"];
        if (query) {
            URLString = [URLString stringByAppendingFormat:@"?%@", query];
        }
    }
    // URL request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    request.HTTPMethod = method;
    request.HTTPBody = body;
    //
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *userAgent = [NSString stringWithFormat:@"%@/%@/%@ (%@, %@ %@)"
                           , [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][@"CFBundleName"]
                           , [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"]
                           , [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"]
                           , [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding] ?: [[UIDevice currentDevice] model]
                           , [[UIDevice currentDevice] systemName]
                           , [[UIDevice currentDevice] systemVersion]
                           ];
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    // URL request handler
    if (requestHandler) {
        requestHandler(request);
    }
    // data task
    __block NSURLSessionDataTask *task = [[ZXHTTPClient URLSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionHandler) {
                completionHandler(task, data, error);
            }
        });
    }];
    [task resume];
    // return
    return task;
}

+ (NSURLSessionDataTask *)requestWithURLString:(NSString *)URLString method:(NSString *)method params:(NSDictionary *)params formData:(NSArray<ZXHTTPFormData *> *)formData requestHandler:(void(^)(NSMutableURLRequest *request))requestHandler completionHandler:(void(^)(NSURLSessionDataTask *task, NSData *data, NSError *error))completionHandler {
    // boundary
    static NSString *boundary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        boundary = [NSString stringWithFormat:@"Boundary+%08X%08X", arc4random(), arc4random()];
    });
    // form data
    NSMutableData *bodyData = [NSMutableData data];
    [formData enumerateObjectsUsingBlock:^(ZXHTTPFormData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // new boundary
        NSString *newBoundary = [NSString stringWithFormat:@"\r\n--%@\r\n", boundary];
        [bodyData appendData:[newBoundary dataUsingEncoding:NSUTF8StringEncoding]];
        // content disposition
        if (obj.fileName) {
            NSString *str = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", obj.name, obj.fileName];
            [bodyData appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            NSString *str = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", obj.name];
            [bodyData appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
        }
        // content type
        if (obj.mimeType) {
            NSString *str = [NSString stringWithFormat:@"Content-Type: %@\r\n", obj.mimeType];
            [bodyData appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
        }
        // content data
        [bodyData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        if (obj.data) {
            [bodyData appendData:obj.data];
        }
    }];
    // end boundary
    if (bodyData.length > 0) {
        NSString *endBoundary = [NSString stringWithFormat:@"\r\n--%@--\r\n", boundary];
        [bodyData appendData:[endBoundary dataUsingEncoding:NSUTF8StringEncoding]];
    }
    // HTTP request
    return [ZXHTTPClient requestWithURLString:URLString method:method params:params body:bodyData requestHandler:^(NSMutableURLRequest *request) {
        [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%llu", (uint64_t)bodyData.length] forHTTPHeaderField:@"Content-Length"];
        if (requestHandler) {
            requestHandler(request);
        }
    } completionHandler:completionHandler];
}

+ (NSURLSessionDataTask *)requestWithURLString:(NSString *)URLString method:(NSString *)method params:(NSDictionary *)params jsonObject:(id)jsonObject requestHandler:(void(^)(NSMutableURLRequest *request))requestHandler completionHandler:(void(^)(NSURLSessionDataTask *task, NSData *data, NSError *error))completionHandler {
    // JSON data
    NSError *error = nil;
    NSData *bodyData = nil;
    if (jsonObject) {
        bodyData = [NSJSONSerialization dataWithJSONObject:jsonObject options:kNilOptions error:&error];
    }
    // HTTP request
    return [ZXHTTPClient requestWithURLString:URLString method:method params:params body:bodyData requestHandler:^(NSMutableURLRequest *request) {
        [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%llu", (uint64_t)bodyData.length] forHTTPHeaderField:@"Content-Length"];
        if (requestHandler) {
            requestHandler(request);
        }
    } completionHandler:completionHandler];
}

#pragma mark HTTP Methods

+ (NSURLSessionDataTask *)GET:(NSString *)URLString params:(NSDictionary *)params requestHandler:(void(^)(NSMutableURLRequest *request))requestHandler completionHandler:(void(^)(NSURLSessionDataTask *task, NSData *data, NSError *error))completionHandler {
    return [ZXHTTPClient requestWithURLString:URLString method:@"GET" params:params body:nil requestHandler:requestHandler completionHandler:completionHandler];
}

+ (NSURLSessionDataTask *)POST:(NSString *)URLString params:(NSDictionary *)params formData:(NSArray<ZXHTTPFormData *> *)formData requestHandler:(void(^)(NSMutableURLRequest *request))requestHandler completionHandler:(void(^)(NSURLSessionDataTask *task, NSData *data, NSError *error))completionHandler {
    return [ZXHTTPClient requestWithURLString:URLString method:@"POST" params:params formData:formData requestHandler:requestHandler completionHandler:completionHandler];
}

+ (NSURLSessionDataTask *)POST:(NSString *)URLString params:(NSDictionary *)params jsonObject:(id)jsonObject requestHandler:(void(^)(NSMutableURLRequest *request))requestHandler completionHandler:(void(^)(NSURLSessionDataTask *task, NSData *data, NSError *error))completionHandler {
    return [ZXHTTPClient requestWithURLString:URLString method:@"POST" params:params jsonObject:jsonObject requestHandler:requestHandler completionHandler:completionHandler];
}

@end

#pragma mark - ZXHTTPFormData

@implementation ZXHTTPFormData

- (instancetype)initWithData:(NSData *)data name:(NSString *)name {
    self = [super init];
    if (self) {
        self.data = data;
        self.name = name;
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType {
    self = [super init];
    if (self) {
        self.data = data;
        self.name = name;
        self.fileName = fileName;
        self.mimeType = mimeType;
    }
    return self;
}

@end
