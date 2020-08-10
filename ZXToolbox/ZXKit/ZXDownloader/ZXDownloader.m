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
#import "ZXKVObserver.h"
#import <UIKit/UIKit.h>

@interface ZXDownloader () <NSURLSessionDataDelegate>
@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSMutableDictionary *currentTasks;
@property (nonatomic, strong) NSMutableArray *runningTasks;
@property (nonatomic, strong) NSMutableArray *waitingTasks;

@property (nonatomic, assign) BOOL isActive;

@property (nonatomic, weak) id willResignActiveObserver;
@property (nonatomic, weak) id didEnterBackgroundObserver;
@property (nonatomic, weak) id willEnterForegroundObserver;
@property (nonatomic, weak) id didBecomeActiveObserver;

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

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentTasks = [[NSMutableDictionary alloc] init];
        _downloadPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:NSStringFromClass([self class])];
        _allowInvalidCertificates = YES;
        _resumeBrokenEnabled = YES;
        _isActive = YES;
    }
    return self;
}

- (void)dealloc {
    if (_willResignActiveObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:_willResignActiveObserver];
        _willResignActiveObserver = nil;
    }
    if (_didEnterBackgroundObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:_didEnterBackgroundObserver];
        _didEnterBackgroundObserver = nil;
    }
    if (_willEnterForegroundObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:_willEnterForegroundObserver];
        _willEnterForegroundObserver = nil;
    }
    if (_didBecomeActiveObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:_didBecomeActiveObserver];
        _didBecomeActiveObserver = nil;
    }
}

#pragma mark Session

- (void)setSession:(NSURLSession *)session {
    _session = session;
    //
    __weak typeof(self) weakSelf = self;
    _runningTasks = [[NSMutableArray alloc] init];
    _waitingTasks = [[NSMutableArray alloc] init];
    //
    if (_willResignActiveObserver == nil) {
        _willResignActiveObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [weakSelf enterBackground];
        }];
    }
    if (_didEnterBackgroundObserver == nil) {
        _didEnterBackgroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [weakSelf enterBackground];
        }];
    }
    //
    if (_willEnterForegroundObserver == nil) {
        _willEnterForegroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [weakSelf enterForeground];
        }];
    }
    if (_didBecomeActiveObserver == nil) {
        _didBecomeActiveObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [weakSelf enterForeground];
        }];
    }
}

#pragma mark Background && Foreground

- (void)enterBackground {
    if (_isActive) {
        _isActive = NO;
        //
        for (ZXDownloadTask *task in _currentTasks.allValues) {
            if (task.state == NSURLSessionTaskStateRunning) {
                [_runningTasks addObject:task];
            } else {
                [_waitingTasks addObject:task];
            }
        }
        //
        [self cancelAllTasks];
    }
}

- (void)enterForeground {
    if (!_isActive) {
        _isActive = YES;
        //
        for (ZXDownloadTask *obj in _runningTasks) {
            ZXDownloadTask *task = [self downloadTaskWithURL:obj.URL];
            id observers = [obj valueForKey:@"observers"];
            [task setValue:observers forKey:@"observers"];
            [task resume];
        }
        [_runningTasks removeAllObjects];
        //
        for (ZXDownloadTask *obj in _waitingTasks) {
            ZXDownloadTask *task = [self downloadTaskWithURL:obj.URL];
            id observers = [obj valueForKey:@"observers"];
            [task setValue:observers forKey:@"observers"];
        }
        [_waitingTasks removeAllObjects];
    }
}

#pragma mark Concurrency

- (NSInteger)maxConcurrentDownloadCount {
    return _session.configuration.HTTPMaximumConnectionsPerHost;
}

- (NSInteger)currentConcurrentDownloadCount {
    NSInteger count = 0;
    for (ZXDownloadTask *task in _currentTasks.allValues) {
        if (task.state == NSURLSessionTaskStateRunning) {
            count++;
        }
    }
    return count;
}

#pragma mark Tasks

- (void)addTask:(ZXDownloadTask *)task {
    if (task) {
        [self addTaskObserver:task];
        [_currentTasks setObject:task forKey:task.taskIdentifier];
    }
}

- (void)removeTask:(ZXDownloadTask *)task {
    if (task) {
        [self removeTaskObserver:task];
        [_currentTasks removeObjectForKey:task.taskIdentifier];
    }
}

- (ZXDownloadTask *)downloadTaskForURL:(NSURL *)URL {
    return [_currentTasks objectForKey:URL.taskIdentifier];
}

- (ZXDownloadTask *)downloadTaskWithURL:(NSURL *)URL {
    ZXDownloadTask *task = [self downloadTaskForURL:URL];
    if (task == nil && _isActive) {
        task = [[ZXDownloadTask alloc] initWithURL:URL path:_downloadPath session:_session resumeBroken:_resumeBrokenEnabled];
        [self addTask:task];
    }
    return task;
}

#pragma mark Resume

- (void)resumeTask:(ZXDownloadTask *)task {
    [task resume];
}

- (void)resumeAllTasks {
    for (ZXDownloadTask *task in _currentTasks.allValues) {
        [self resumeTask:task];
    }
}

#pragma mark Suspend

- (void)suspendTask:(ZXDownloadTask *)task {
    [task suspend];
}

- (void)suspendAllTasks {
    for (ZXDownloadTask *task in _currentTasks.allValues) {
        [task suspend];
    }
}

#pragma mark Cancel

- (void)cancelTask:(ZXDownloadTask *)task {
    [task cancel];
}

- (void)cancelAllTasks {
    for (ZXDownloadTask *task in _currentTasks.allValues) {
        [task cancel];
    }
}

#pragma mark <NSKeyValueObserving>

- (void)addTaskObserver:(ZXDownloadTask *)task {
    if (task) {
        [self removeTaskObserver:task];
        ZXKVObserver *taskStateObserver = [task valueForKey:@"taskStateObserver"];
        //
        __weak typeof(self) weakSelf = self;
        [taskStateObserver addObserver:task forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:NULL observeValue:^(NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
            NSURLSessionTaskState state = [change[NSKeyValueChangeNewKey] integerValue];
            switch (state) {
                case NSURLSessionTaskStateCanceling:
                case NSURLSessionTaskStateCompleted:
                    [weakSelf removeTask:task];
                    break;
                default:
                    break;
            }
        }];
    }
}

- (void)removeTaskObserver:(ZXDownloadTask *)task {
    if (task) {
        ZXKVObserver *taskStateObserver = [task valueForKey:@"taskStateObserver"];
        [taskStateObserver removeObserver];
    }
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
        [self.currentTasks removeObjectForKey:obj.taskIdentifier];
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

@end
