//
// ZXURLProtocol.m
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

#import "ZXURLProtocol.h"

@interface ZXURLProtocol ()
@property (nonatomic, copy) NSArray *schemes;
@property (nonatomic, copy) BOOL (^customRequest)(NSURLRequest *request);
@property (nonatomic, copy) NSURLRequest * (^canonicalRequest)(NSURLRequest *request);
@property (nonatomic, copy) void (^didStartLoading)(ZXURLProtocol *protocol);
@property (nonatomic, copy) void (^didStopLoading)(ZXURLProtocol *protocol);

+ (instancetype)URLProtocol;

@end

@implementation ZXURLProtocol

#define ZXURLProtocolHandledKey @"ZXURLProtocolHandledKey"

+ (instancetype)URLProtocol {
    static ZXURLProtocol *protocol;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        protocol = [[ZXURLProtocol alloc] init];
    });
    return protocol;
}

+ (void)registerSchemes:(NSArray *)schemes customRequest:(BOOL (^)(NSURLRequest *))customRequest canonicalRequest:(NSURLRequest *(^)(NSURLRequest *))canonicalRequest startLoading:(void (^)(ZXURLProtocol *))startLoading stopLoading:(void (^)(ZXURLProtocol *))stopLoading {
    //
    [NSURLProtocol registerClass:[self class]];
    //
    Class cls = NSClassFromString(@"WKBrowsingContextController");
    SEL sel = NSSelectorFromString(@"registerSchemeForCustomProtocol:");
    if ([(id)cls respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        for (id obj in schemes) {
            [(id)cls performSelector:sel withObject:obj];
        }
#pragma clang diagnostic pop
    }
    //
    [ZXURLProtocol URLProtocol].schemes = schemes;
    [ZXURLProtocol URLProtocol].customRequest = customRequest;
    [ZXURLProtocol URLProtocol].canonicalRequest = canonicalRequest;
    [ZXURLProtocol URLProtocol].didStartLoading = startLoading;
    [ZXURLProtocol URLProtocol].didStopLoading = stopLoading;
}

+ (void)unregisterSchemes {
    [NSURLProtocol unregisterClass:[self class]];
    //
    Class cls = NSClassFromString(@"WKBrowsingContextController");
    SEL sel = NSSelectorFromString(@"unregisterSchemeForCustomProtocol:");
    if ([(id)cls respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        for (id obj in [ZXURLProtocol URLProtocol].schemes) {
            [(id)cls performSelector:sel withObject:obj];
        }
#pragma clang diagnostic pop
    }
    //
    [ZXURLProtocol URLProtocol].schemes = nil;
    [ZXURLProtocol URLProtocol].customRequest = nil;
    [ZXURLProtocol URLProtocol].canonicalRequest = nil;
    [ZXURLProtocol URLProtocol].didStartLoading = nil;
    [ZXURLProtocol URLProtocol].didStopLoading = nil;
}

#pragma mark Overrides

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if ([ZXURLProtocol URLProtocol].customRequest) {
        return [ZXURLProtocol URLProtocol].customRequest(request);
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    if ([ZXURLProtocol URLProtocol].canonicalRequest) {
        return [ZXURLProtocol URLProtocol].canonicalRequest(request);
    }
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [a isEqual:b];
}

- (void)startLoading {
    if ([ZXURLProtocol URLProtocol].didStartLoading) {
        [ZXURLProtocol URLProtocol].didStartLoading(self);
    } else {
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:@{NSLocalizedDescriptionKey:@"Request failed: not found (404)"}];
        [self.client URLProtocol:self didFailWithError:error];
    }
}

- (void)stopLoading {
    if ([ZXURLProtocol URLProtocol].didStopLoading) {
        [ZXURLProtocol URLProtocol].didStopLoading(self);
    }
}

#pragma mark Functions

+ (NSString *)mimeTypeWithExtension:(NSString *)extension {
    NSString *mime = nil;
    CFStringRef ext = (__bridge_retained CFStringRef)extension;
    CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext, NULL);
    CFRelease(ext);
    if (type) {
        mime = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
        CFRelease(type);
    }
    return mime;
}

- (void)loadDataWithFile:(NSString *)path cacheStoragePolicy:(NSURLCacheStoragePolicy)policy {
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSString *ext = [[path lastPathComponent] pathExtension];
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:self.request.URL
                                                            MIMEType:[ZXURLProtocol mimeTypeWithExtension:ext]
                                               expectedContentLength:-1
                                                    textEncodingName:nil];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:policy];
        [self.client URLProtocol:self didLoadData:data];
        [self.client URLProtocolDidFinishLoading:self];
    } else {
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:@{NSLocalizedDescriptionKey:@"Request failed: not found (404)"}];
        [self.client URLProtocol:self didFailWithError:error];
    }
}

@end
