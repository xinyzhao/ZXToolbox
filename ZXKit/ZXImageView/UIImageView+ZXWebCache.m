//
// UIImageView+ZXWebCache.m
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

#import "UIImageView+ZXWebCache.h"
#import <objc/runtime.h>
#import "ZXCommonCrypto.h"
#import "ZXURLSession.h"

@implementation UIImageView (ZXWebCache)

+ (NSCache *)imageCache {
    static NSCache *imageCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageCache = [[NSCache alloc] init];
    });
    return imageCache;
}

#pragma mark Task

- (void)setDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    objc_setAssociatedObject(self, @selector(downloadTask), downloadTask, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSURLSessionDownloadTask *)downloadTask {
    return objc_getAssociatedObject(self, @selector(downloadTask));
}

#pragma mark URL

- (void)zx_setImageWithURL:(NSURL *)imageURL {
    [self zx_setImageWithURL:imageURL placeholder:nil];
}

- (void)zx_setImageWithURL:(NSURL *)imageURL placeholder:(UIImage *)image {
    [self zx_setImageWithURL:imageURL placeholder:image completion:nil];
}

- (void)zx_setImageWithURL:(NSURL *)imageURL placeholder:(UIImage *)image completion:(void(^)(UIImage *image, NSError *error, NSURL *imageURL))completion {
    self.image = image;
    //
    if (self.downloadTask) {
        [self.downloadTask cancel];
        self.downloadTask = nil;
    }
    // 从缓存中加载
    NSString *key = [[[ZXCommonDigest alloc] initWithString:imageURL.absoluteString] MD5String];
    __block NSData *data = [[UIImageView imageCache] objectForKey:key];
    // 从本地加载
    if (data == nil) {
        NSString *file = [NSTemporaryDirectory() stringByAppendingPathComponent:key];
        data = [NSData dataWithContentsOfFile:file];
        if (data) {
            [[UIImageView imageCache] setObject:data forKey:key];
        }
    }
    // 加载图片
    if (data) {
        UIImage *image = [UIImage imageWithData:data];
        if (image) {
            self.image = image;
            if (completion) {
                completion(image, nil, imageURL);
            }
        } else {
            data = nil;
        }
    }
    // 从网络加载
    if (data == nil) {
        __weak typeof(self) weakSelf = self;
        self.downloadTask = [[ZXURLSession URLSession] downloadTaskWithRequest:[NSURLRequest requestWithURL:imageURL] completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (location) {
                //
                NSString *file = [NSTemporaryDirectory() stringByAppendingPathComponent:key];
                NSURL *fileURL = [NSURL fileURLWithPath:file];
                [[NSFileManager defaultManager] copyItemAtURL:location toURL:fileURL error:nil];
                //
                data = [NSData dataWithContentsOfURL:location];
                if (data) {
                    [[UIImageView imageCache] setObject:data forKey:key];
                }
                //
                __strong typeof(weakSelf) strongSelf = weakSelf;
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *image = [UIImage imageWithData:data];
                    if (image) {
                        strongSelf.image = image;
                    }
                    if (completion) {
                        completion(image, error, imageURL);
                    }
                    strongSelf.downloadTask = nil;
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(nil, error, imageURL);
                    }
                });
            }
        }];
        [self.downloadTask resume];
    }
}

- (void)zx_cancelImageLoad {
    [self.downloadTask cancel];
}

@end
