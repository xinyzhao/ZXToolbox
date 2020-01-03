//
// ZXDownloadTask.m
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

#import "ZXDownloadTask.h"
#import "ZXDownloader.h"
#import "ZXCommonCrypto.h"
#import <UIKit/UIKit.h>

/// ZXDownloadObserver
@interface ZXDownloadObserver : NSObject

/// The observer
@property (nonatomic, weak) id observer;

/// The progress block
@property (nonatomic, copy) void(^progress)(int64_t receivedSize, int64_t expectedSize, float progress);

/// The state block
@property (nonatomic, copy) void(^state)(NSURLSessionTaskState state, NSString *finalFilePath, NSError *error);

@end

@implementation ZXDownloadObserver

@end

@interface ZXDownloadTask ()
@property (nonatomic, strong) NSMutableArray *observers;

@property (nonatomic, strong) NSString *cacheFilePath;
@property (nonatomic, strong) NSString *finalFilePath;

@property (nonatomic, strong) NSOutputStream *outputStream;

@property (nonatomic, assign) int64_t totalBytesWritten;
@property (nonatomic, assign) int64_t totalBytesExpectedToWrite;

@property (nonatomic, assign) NSURLSessionTaskState state;

@property (nonatomic, weak) id didBecomeActiveObserver;

@end

@implementation ZXDownloadTask

- (instancetype)initWithURL:(NSURL *)URL path:(NSString *)path {
    self = [super init];
    if (self) {
        //
        BOOL isDirectory = NO;
        if (path == nil) {
            path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        }
        BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
        if (!isExists || !isDirectory) {
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
        //
        _observers = [[NSMutableArray alloc] init];
        _taskIdentifier = URL.taskIdentifier;
        _cacheFilePath = [path stringByAppendingPathComponent:_taskIdentifier];
        _finalFilePath = [path stringByAppendingPathComponent:[URL lastPathComponent]];
        _totalBytesWritten = [self fileSizeAtPath:_cacheFilePath];
        _totalBytesExpectedToWrite = [self fileSizeAtPath:_finalFilePath];
        if (_totalBytesExpectedToWrite > 0) {
            _state = NSURLSessionTaskStateCompleted;
        } else {
            _state = NSURLSessionTaskStateSuspended;
        }
    }
    return self;
}

- (void)dealloc
{
    if (_didBecomeActiveObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:_didBecomeActiveObserver];
        _didBecomeActiveObserver = nil;
    }
}

- (void)setTask:(NSURLSessionTask *)task {
    _task = task;
    //
    __weak typeof(self) weakSelf = self;
    if (_didBecomeActiveObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:_didBecomeActiveObserver];
        _didBecomeActiveObserver = nil;
    }
    if ([_task isKindOfClass:NSURLSessionDownloadTask.class]) {
        _didBecomeActiveObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if (weakSelf.state == NSURLSessionTaskStateRunning) {
                [weakSelf.task suspend];
                [weakSelf.task resume];
            }
        }];
    }
}

#pragma mark Observer

- (void)addObserver:(id)observer
              state:(void(^)(NSURLSessionTaskState state, NSString *filePath, NSError *error))state
           progress:(void(^)(int64_t receivedSize, int64_t expectedSize, float progress))progress {
    ZXDownloadObserver *taskObserver = [[ZXDownloadObserver alloc] init];
    taskObserver.observer = observer;
    taskObserver.state = state;
    taskObserver.progress = progress;
    [_observers addObject:taskObserver];
}

- (void)removeObserver:(id)observer {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (ZXDownloadObserver *obj in _observers) {
        if (obj.observer == observer) {
            [array addObject:obj];
        }
    }
    [self.observers removeObjectsInArray:array];
}

#pragma mark Files

- (NSString *)filePath {
    if (_state == NSURLSessionTaskStateCompleted) {
        return _finalFilePath;
    }
    return _cacheFilePath;
}

- (uint64_t)fileSizeAtPath:(NSString *)path {
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        if (attributes) {
            return [attributes[NSFileSize] longLongValue];
        }
    }
    return 0;
}

#pragma mark State

- (void)cancel {
    if (_state == NSURLSessionTaskStateRunning ||
        _state == NSURLSessionTaskStateSuspended) {
        if ([_task isKindOfClass:NSURLSessionDownloadTask.class]) {
            __weak typeof(self) weakSelf = self;
            [((NSURLSessionDownloadTask *)_task) cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                [weakSelf writeResumeData:resumeData];
            }];
        } else {
            [_task cancel];
        }
    }
}

- (void)suspend {
    if (_state == NSURLSessionTaskStateRunning) {
        [_task suspend];
        [self setState:NSURLSessionTaskStateSuspended withError:nil];
    }
}

- (void)resume {
    if (_state == NSURLSessionTaskStateSuspended) {
        [_task resume];
        [self setState:NSURLSessionTaskStateRunning withError:nil];
    } else if (_state == NSURLSessionTaskStateCompleted) {
        [self setState:NSURLSessionTaskStateCompleted withError:nil];
    }
}

- (void)setState:(NSURLSessionTaskState)state withError:(NSError *)error {
    _state = state;
    //
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *path = weakSelf.filePath;
        for (ZXDownloadObserver *observer in weakSelf.observers) {
            if (observer.observer && observer.state) {
                observer.state(state, path, error);
            }
        }
    });
}

- (BOOL)writeResumeData:(NSData *)resumeData {
    if (_cacheFilePath) {
        [[NSFileManager defaultManager] removeItemAtPath:_cacheFilePath error:nil];
    } else {
        NSLog(@"The cacheFilePath is not be nil");
        return false;
    }
    if (resumeData) {
        [resumeData writeToFile:_cacheFilePath atomically:YES];
    }
    return true;
}

#pragma mark Progress

- (void)setTotalBytesWritten:(int64_t)totalBytesWritten {
    if (_totalBytesWritten != totalBytesWritten) {
        [self setTotalBytesWritten:totalBytesWritten
         totalBytesExpectedToWrite:_totalBytesExpectedToWrite];
    }
}

- (void)setTotalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    if (_totalBytesExpectedToWrite != totalBytesExpectedToWrite) {
        [self setTotalBytesWritten:_totalBytesWritten
         totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

- (void)setTotalBytesWritten:(int64_t)totalBytesWritten
   totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    _totalBytesWritten = totalBytesWritten;
    _totalBytesExpectedToWrite = totalBytesExpectedToWrite;
    //
    float progress = 0.f;
    if (_totalBytesExpectedToWrite > 0) {
        progress = (float)_totalBytesWritten / _totalBytesExpectedToWrite;
    }
    //
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        for (ZXDownloadObserver *observer in weakSelf.observers) {
            if (observer.observer && observer.progress) {
                observer.progress(totalBytesWritten, totalBytesExpectedToWrite, progress);
            }
        }
    });
}

#pragma mark Output Stream

- (void)openOutputStreamWithAppend:(BOOL)append {
    if (_outputStream == nil) {
        _outputStream = [NSOutputStream outputStreamToFileAtPath:_cacheFilePath append:append];
        [_outputStream open];
    }
}

- (void)closeOutputStream {
    if (_outputStream) {
        if (_outputStream.streamStatus > NSStreamStatusNotOpen &&
            _outputStream.streamStatus < NSStreamStatusClosed) {
            [_outputStream close];
        }
        _outputStream = nil;
    }
}

#pragma mark <NSURLSessionTaskDelegate>

/* Sent as the last message related to a specific task.  Error may be
* nil, which implies that no error occurred and this task is complete.
*/
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error
{
    if ([task isKindOfClass:NSURLSessionDataTask.class]) {
        [self closeOutputStream];
        if (error == nil && task.state == NSURLSessionTaskStateCompleted) {
            [[NSFileManager defaultManager] removeItemAtPath:_finalFilePath error:nil];
            [[NSFileManager defaultManager] moveItemAtPath:_cacheFilePath
                                                    toPath:_finalFilePath
                                                     error:&error];
        }
        [self setState:task.state withError:error];
    } else if (error) {
        NSData *resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
        [self writeResumeData:resumeData];
        [self setState:task.state withError:error];
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
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    BOOL append = NO;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *http = (NSHTTPURLResponse *)response;
        append = http.statusCode == 206;
    }
    //
    if (append) {
        self.totalBytesExpectedToWrite = response.expectedContentLength + _totalBytesWritten;
    } else {
        self.totalBytesExpectedToWrite = response.expectedContentLength;
    }
    [self openOutputStreamWithAppend:append];
}

/* Sent when data is available for the delegate to consume.  It is
* assumed that the delegate will retain and not copy the data.  As
* the data may be discontiguous, you should use
* [NSData enumerateByteRangesUsingBlock:] to access it.
*/
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    if (data) {
        [_outputStream write:data.bytes maxLength:data.length];
        self.totalBytesWritten += data.length;
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
    NSError *error = nil;
    NSURL *toURL = [NSURL fileURLWithPath:_finalFilePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL:toURL error:NULL];
    [fileManager copyItemAtURL:location toURL:toURL error:&error];
    [self setState:downloadTask.state withError:error];
}


/* Sent periodically to notify the delegate of download progress. */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                                           didWriteData:(int64_t)bytesWritten
                                      totalBytesWritten:(int64_t)totalBytesWritten
                              totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    [self setTotalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    //NSLog(@"didWriteData:%lld/%lld/%lld", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
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
    //NSLog(@"didResume:%lld/%lld", fileOffset, expectedTotalBytes);
}

@end

@implementation NSURL (ZXDownloadTask)

- (nullable NSString *)taskIdentifier {
    NSMutableString *url = [[NSMutableString alloc] init];
    if (self.scheme) {
        [url appendFormat:@"%@://", self.scheme];
    }
    if (self.host) {
        [url appendString:self.host];
    }
    if (self.port) {
        [url appendFormat:@":%d", self.port.intValue];
    }
    if (self.path) {
        [url appendFormat:@"/%@", self.path];
    }
    if (url.length) {
        return [[[ZXCommonDigest alloc] initWithString:url] SHA1String];
    }
    return nil;
}

@end

@implementation NSURLSessionTask (ZXDownloadTask)

- (nullable NSURL *)URL {
    return self.originalRequest.URL ?: self.currentRequest.URL;
}

@end
