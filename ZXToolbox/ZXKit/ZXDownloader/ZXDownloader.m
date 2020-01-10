//
// ZXDownloader.m
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2019-2020 Zhao Xin
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

#import "ZXDownloader.h"
#import <UIKit/UIKit.h>

@interface ZXDownloader () <NSURLSessionDataDelegate, NSURLSessionDownloadDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableDictionary *downloadTasks;

@property (nonatomic, strong) NSMutableArray *runningTasks;
@property (nonatomic, strong) NSMutableArray *waitingTasks;

/// Whether or not  a background downloader
@property (nonatomic, assign) BOOL isBackgroundDownloader;

@property (nonatomic, weak) id didBecomeActiveObserver;
@property (nonatomic, weak) id willResignActiveObserver;

@end

@implementation ZXDownloader

+ (instancetype)defaultDownloader {
    static ZXDownloader *downloader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloader = [[ZXDownloader alloc] init];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        downloader.session = [NSURLSession sessionWithConfiguration:config delegate:downloader delegateQueue:nil];
    });
    return downloader;
}

+ (instancetype)backgroundDownloader {
    static ZXDownloader *downloader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloader = [[ZXDownloader alloc] init];
        downloader.isBackgroundDownloader = YES;
        id identifier = @"com.github.xinyzhao.ZXToolbox.ZXDownloader";
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
        config.discretionary = YES;
        downloader.session = [NSURLSession sessionWithConfiguration:config delegate:downloader delegateQueue:nil];
    });
    return downloader;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _downloadTasks = [[NSMutableDictionary alloc] init];
        _downloadPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:NSStringFromClass([self class])];
        _allowInvalidCertificates = YES;
        _autoResumeNextDownloadTask = YES;
    }
    return self;
}

- (void)dealloc
{
    if (_willResignActiveObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:_willResignActiveObserver];
        _willResignActiveObserver = nil;
    }
    if (_didBecomeActiveObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:_didBecomeActiveObserver];
        _didBecomeActiveObserver = nil;
    }
}

- (void)setSession:(NSURLSession *)session {
    _session = session;
    //
    __weak typeof(self) weakSelf = self;
    if (_isBackgroundDownloader) {
        [_session getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
            for (NSURLSessionDownloadTask *task in downloadTasks) {
                [weakSelf downloadTaskWithTask:task];
            }
        }];
    } else {
        _runningTasks = [[NSMutableArray alloc] init];
        _waitingTasks = [[NSMutableArray alloc] init];
        //
        if (_willResignActiveObserver == nil) {
            _willResignActiveObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
                for (ZXDownloadTask *task in weakSelf.downloadTasks.allValues) {
                    if (task.state == NSURLSessionTaskStateRunning) {
                        [weakSelf.runningTasks addObject:task];
                    } else {
                        [weakSelf.waitingTasks addObject:task];
                    }
                }
                [weakSelf cancelAllTasks];
            }];
        }
        //
        if (_didBecomeActiveObserver == nil) {
            _didBecomeActiveObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
                for (ZXDownloadTask *obj in weakSelf.runningTasks) {
                    ZXDownloadTask *task = [weakSelf downloadTaskWithURL:obj.task.URL];
                    id observers = [obj valueForKey:@"observers"];
                    [task setValue:observers forKey:@"observers"];
                    [task resume];
                }
                for (ZXDownloadTask *obj in weakSelf.runningTasks) {
                    ZXDownloadTask *task = [weakSelf downloadTaskWithURL:obj.task.URL];
                    id observers = [obj valueForKey:@"observers"];
                    [task setValue:observers forKey:@"observers"];
                }
                [weakSelf.runningTasks removeAllObjects];
                [weakSelf.waitingTasks removeAllObjects];
            }];
        }
    }
}

#pragma mark Concurrency

- (NSInteger)maxConcurrentDownloadCount {
    return _session.configuration.HTTPMaximumConnectionsPerHost;
}

- (NSInteger)currentConcurrentDownloadCount {
    NSInteger count = 0;
    for (ZXDownloadTask *task in _downloadTasks.allValues) {
        if (task.state == NSURLSessionTaskStateRunning) {
            count++;
        }
    }
    return count;
}

#pragma mark Tasks

- (ZXDownloadTask *)downloadTaskForURL:(NSURL *)URL {
    return [_downloadTasks objectForKey:URL.taskIdentifier];
}

- (ZXDownloadTask *)downloadTaskWithURL:(NSURL *)URL {
    ZXDownloadTask *task = [self downloadTaskForURL:URL];
    if (task == nil) {
        task = [[ZXDownloadTask alloc] initWithURL:URL path:_downloadPath];
        if (self == [ZXDownloader backgroundDownloader]) {
            NSData *data = [NSData dataWithContentsOfFile:task.filePath];
            if (data) {
                task.task = [_session downloadTaskWithResumeData:data];
            }
            if (task.task == nil) {
                task.task = [_session downloadTaskWithURL:URL];
            }
        } else {
            // Range
            // bytes=x-y ==  x byte ~ y byte
            // bytes=x-  ==  x byte ~ end
            // bytes=-y  ==  head ~ y byte
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
            [request setValue:[NSString stringWithFormat:@"bytes=%lld-", task.totalBytesWritten] forHTTPHeaderField:@"Range"];
            task.task = [_session dataTaskWithRequest:request];
        }
        [_downloadTasks setObject:task forKey:task.taskIdentifier];
    }
    return task;
}

- (ZXDownloadTask *)downloadTaskWithTask:(NSURLSessionTask *)obj {
    ZXDownloadTask *task = [self downloadTaskForURL:obj.URL];
    if (task == nil) {
        task = [[ZXDownloadTask alloc] initWithURL:obj.URL path:_downloadPath];
        task.task = obj;
        [_downloadTasks setObject:task forKey:task.taskIdentifier];
    }
    return task;
}

#pragma mark Resume

- (void)resumeTask:(ZXDownloadTask *)task {
    if (task.state == NSURLSessionTaskStateSuspended) {
        if ((self.maxConcurrentDownloadCount <= 0) ||
            (self.maxConcurrentDownloadCount > self.currentConcurrentDownloadCount)) {
            [task resume];
        }
    } else if (task.state == NSURLSessionTaskStateCompleted) {
        [task resume];
        [_downloadTasks removeObjectForKey:task.taskIdentifier];
    }
}

- (void)resumeNextTask:(ZXDownloadTask *)currentTask {
    if (_autoResumeNextDownloadTask) {
        for (ZXDownloadTask *task in [_downloadTasks allValues]) {
            if (task != currentTask) {
                [self resumeTask:task];
                break;
            }
        }
    }
}

- (void)resumeAllTasks {
    for (ZXDownloadTask *task in [self.downloadTasks allValues]) {
        [self resumeTask:task];
    }
}

#pragma mark Suspend

- (void)suspendTask:(ZXDownloadTask *)task {
    [task suspend];
    [self resumeNextTask:task];
}

- (void)suspendAllTasks {
    for (ZXDownloadTask *task in [self.downloadTasks allValues]) {
        [task suspend];
    }
}

#pragma mark Cancel

- (void)cancelTask:(ZXDownloadTask *)task {
    if (task) {
        [task cancel];
        [self.downloadTasks removeObjectForKey:task.taskIdentifier];
        [self resumeNextTask:nil];
    }
}

- (void)cancelAllTasks {
    for (ZXDownloadTask *task in [self.downloadTasks allValues]) {
        [task cancel];
    }
    [self.downloadTasks removeAllObjects];
}

#pragma mark <NSURLSessionDelegate>

/* If an application has received an
* -application:handleEventsForBackgroundURLSession:completionHandler:
* message, the session delegate will receive this message to indicate
* that all messages previously enqueued for this session have been
* delivered.  At this time it is safe to invoke the previously stored
* completion handler, or to begin any internal updates that will
* result in invoking the completion handler.
*/
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.backgroundCompletionHandler) {
            weakSelf.backgroundCompletionHandler();
        }
    });
}

#pragma mark <NSURLSessionTaskDelegate>

/* The task has received a request specific authentication challenge.
* If this delegate is not implemented, the session specific authentication challenge
* will *NOT* be called and the behavior will be the same as using the default handling
* disposition.
*/
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
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

/* Sent as the last message related to a specific task.  Error may be
* nil, which implies that no error occurred and this task is complete.
*/
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    ZXDownloadTask *obj = [self downloadTaskForURL:task.URL];
    if (obj) {
        [obj URLSession:session task:task didCompleteWithError:error];
        [self.downloadTasks removeObjectForKey:obj.taskIdentifier];
        [self resumeNextTask:nil];
    }
}

#pragma mark <NSURLSessionDataDelegate>

/* The task has received a response and no further messages will be
* received until the completion block is called. The disposition
* allows you to cancel a request or to turn a data task into a
* download task. This delegate message is optional - if you do not
* implement it, you can get the response as a property of the task.
*
* This method will not be called for background upload tasks (which cannot be converted to download tasks).
*/
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
                                 didReceiveResponse:(NSURLResponse *)response
                                  completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    ZXDownloadTask *task = [self downloadTaskForURL:dataTask.URL];
    if (task) {
        [task URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
    }
    completionHandler(NSURLSessionResponseAllow);
}

/* Sent when data is available for the delegate to consume.  It is
* assumed that the delegate will retain and not copy the data.  As
* the data may be discontiguous, you should use
* [NSData enumerateByteRangesUsingBlock:] to access it.
*/
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
                                     didReceiveData:(NSData *)data {
    ZXDownloadTask *task = [self downloadTaskForURL:dataTask.URL];
    if (task) {
        [task URLSession:session dataTask:dataTask didReceiveData:data];
    }
}

#pragma mark <NSURLSessionDownloadDelegate>

/* Sent when a download task that has completed a download.  The delegate should
* copy or move the file at the given location to a new location as it will be
* removed when the delegate message returns. URLSession:task:didCompleteWithError: will
* still be called.
*/
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                              didFinishDownloadingToURL:(NSURL *)location
{
    ZXDownloadTask *task = [self downloadTaskWithTask:downloadTask];
    if (task) {
        [task URLSession:session downloadTask:downloadTask didFinishDownloadingToURL:location];
    }
}

/* Sent periodically to notify the delegate of download progress. */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                                           didWriteData:(int64_t)bytesWritten
                                      totalBytesWritten:(int64_t)totalBytesWritten
                              totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    ZXDownloadTask *task = [self downloadTaskWithTask:downloadTask];
    if (task) {
        [task URLSession:session downloadTask:downloadTask didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

/* Sent when a download has been resumed. If a download failed with an
 * error, the -userInfo dictionary of the error will contain an
 * NSURLSessionDownloadTaskResumeData key, whose value is the resume
 * data.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                                      didResumeAtOffset:(int64_t)fileOffset
                                     expectedTotalBytes:(int64_t)expectedTotalBytes
{
    ZXDownloadTask *task = [self downloadTaskWithTask:downloadTask];
    if (task) {
        [task URLSession:session downloadTask:downloadTask didResumeAtOffset:fileOffset expectedTotalBytes:expectedTotalBytes];
    }
}

@end
