//
// ZXDownloadManager.m
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

#import "ZXDownloadManager.h"
#import "ZXCommonCrypto.h"

@interface ZXDownloadManager () <NSURLSessionDelegate, NSURLSessionDataDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableDictionary *downloadTasks;

@end

@implementation ZXDownloadManager

+ (instancetype)sharedManager {
    static ZXDownloadManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[ZXDownloadManager alloc] init];
    });
    return _sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                     delegate:self
                                                delegateQueue:[[NSOperationQueue alloc] init]];
        self.downloadTasks = [[NSMutableDictionary alloc] init];
        self.localPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:NSStringFromClass([self class])];
        self.maximumConcurrent = 0;
        self.resumeBrokenEnabled = YES;
        self.allowInvalidCertificates = YES;
    }
    return self;
}

- (ZXDownloadTask *)downloadTaskWithURL:(NSURL *)URL {
    return [self downloadTaskWithURL:URL inDirectory:self.localPath inBackground:NO];
}

- (ZXDownloadTask *)downloadTaskWithURL:(NSURL *)URL inDirectory:(NSString *)path inBackground:(BOOL)backgroundMode {
    ZXDownloadTask *task = [self downloadTaskForURL:URL];
    if (task == nil) {
        task = [[ZXDownloadTask alloc] initWithURL:URL path:(path ? path : self.localPath)];
        if (task.state != ZXDownloadStateCompleted) {
            // Range
            // bytes=x-y ==  x byte ~ y byte
            // bytes=x-  ==  x byte ~ end
            // bytes=-y  ==  head ~ y byte
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
            if (self.resumeBrokenEnabled) {
                [request setValue:[NSString stringWithFormat:@"bytes=%lld-", task.totalBytesWritten] forHTTPHeaderField:@"Range"];
            }
            task.dataTask = [self.session dataTaskWithRequest:request];
        }
        //
        [self.downloadTasks setObject:task forKey:task.taskIdentifier];
    }
    return task;
}

- (ZXDownloadTask *)downloadTaskForURL:(NSURL *)URL {
    NSString *taskIdentifier = [[[ZXCommonDigest alloc] initWithString:URL.absoluteString] SHA1String];
    return [self.downloadTasks objectForKey:taskIdentifier];
}

#pragma mark Suspend

- (void)suspendDownloadForURL:(NSURL *)URL {
    ZXDownloadTask *task = [self downloadTaskForURL:URL];
    [self suspendDownloadTask:task];
}

- (void)suspendDownloadTask:(ZXDownloadTask *)task {
    if (task) {
        task.state = ZXDownloadStateSuspended;
        [self resumeNextDowloadTask];
    }
}

- (void)suspendAllDownloads {
    for (ZXDownloadTask *task in [self.downloadTasks allValues]) {
        task.state = ZXDownloadStateSuspended;
    }
}

#pragma mark Resume

- (BOOL)resumeDownloadTask:(ZXDownloadTask *)task {
    if (task.state == ZXDownloadStateRunning ||
        task.state == ZXDownloadStateCancelled ||
        task.state == ZXDownloadStateCompleted) {
        task.state = task.state;
        //
        if (task.state == ZXDownloadStateCancelled ||
            task.state == ZXDownloadStateCompleted) {
            [self.downloadTasks removeObjectForKey:task.taskIdentifier];
        }
        return NO;
    }
    //
    if (self.maximumConcurrent > 0) {
        __block NSUInteger count = 0;
        [self.downloadTasks enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            ZXDownloadTask *task = obj;
            if (task.state == ZXDownloadStateRunning) {
                ++count;
            }
        }];
        if (count >= self.maximumConcurrent) {
            task.state = ZXDownloadStateWaiting;
            return NO;
        }
    }
    //
    if (task) {
        task.state = ZXDownloadStateRunning;
    }
    //
    return YES;
}

- (void)resumeNextDowloadTask {
    for (ZXDownloadTask *task in [self.downloadTasks allValues]) {
        if (task.state == ZXDownloadStateWaiting) {
            [self resumeDownloadTask:task];
            break;
        }
    }
}

- (void)resumeDownloadForURL:(NSURL *)URL {
    ZXDownloadTask *task = [self downloadTaskForURL:URL];
    if (task) {
        [self resumeDownloadTask:task];
    }
}

- (void)resumeAllDownloads {
    for (ZXDownloadTask *task in [self.downloadTasks allValues]) {
        [self resumeDownloadTask:task];
    }
}

#pragma mark Cancel

- (void)cancelDownloadForURL:(NSURL *)URL {
    ZXDownloadTask *task = [self downloadTaskForURL:URL];
    [self cancelDownloadTask:task];
}

- (void)cancelDownloadTask:(ZXDownloadTask *)task {
    if (task) {
        task.state = ZXDownloadStateCancelled;
        [self.downloadTasks removeObjectForKey:task.taskIdentifier];
        [self resumeNextDowloadTask];
    }
}

- (void)cancelAllDownloads {
    for (ZXDownloadTask *task in [self.downloadTasks allValues]) {
        task.state = ZXDownloadStateCancelled;
    }
    [self.downloadTasks removeAllObjects];
}

#pragma mark <NSURLSessionDataDelegate>

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    ZXDownloadTask *task = [self downloadTaskForURL:dataTask.originalRequest.URL];
    if (task) {
        [task URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
    }
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    ZXDownloadTask *task = [self downloadTaskForURL:dataTask.originalRequest.URL];
    if (task) {
        [task URLSession:session dataTask:dataTask didReceiveData:data];
    }
}

#pragma mark <NSURLSessionTaskDelegate>

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if (self.allowInvalidCertificates) {
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            disposition = NSURLSessionAuthChallengeUseCredential;
        } else {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
    } else {
        if (challenge.previousFailureCount == 0) {
            if (self.credential) {
                credential = self.credential;
                disposition = NSURLSessionAuthChallengeUseCredential;
            } else {
                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
            }
        } else {
            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        }
    }
    
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
        return;
    }
    ZXDownloadTask *obj = [self downloadTaskForURL:task.originalRequest.URL];
    if (obj) {
        if ([obj respondsToSelector:@selector(URLSession:task:didCompleteWithError:)]) {
            [obj URLSession:session task:task didCompleteWithError:error];
        }
        [self.downloadTasks removeObjectForKey:obj.taskIdentifier];
        [self resumeNextDowloadTask];
    }
}

@end
