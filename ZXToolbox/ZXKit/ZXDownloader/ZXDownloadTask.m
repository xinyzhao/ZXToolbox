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
#import "ZXKVObserver.h"
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

@property (nonatomic, strong) NSURLSessionTask *task;

@property (nonatomic, strong) NSMutableArray *observers;

@property (nonatomic, strong) NSString *cacheFilePath;
@property (nonatomic, strong) NSString *finalFilePath;

@property (nonatomic, strong) NSOutputStream *outputStream;

@property (nonatomic, assign) int64_t totalBytesWritten;
@property (nonatomic, assign) int64_t totalBytesExpectedToWrite;

@property (nonatomic, assign) NSURLSessionTaskState state;

@property (nonatomic, strong) ZXKVObserver *taskStateObserver;

@end

@implementation ZXDownloadTask

- (instancetype)initWithURL:(NSURL *)URL path:(NSString *)path session:(NSURLSession *)session {
    return [self initWithURL:URL path:path session:session resumeBroken:YES];
}

- (instancetype)initWithURL:(NSURL *)URL path:(NSString *)path session:(NSURLSession *)session resumeBroken:(BOOL)resumeBroken {
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
        if (URL) {
            _URL = [URL copy];
            _taskIdentifier = _URL.taskIdentifier;
            _cacheFilePath = [path stringByAppendingPathComponent:_taskIdentifier];
            _finalFilePath = [path stringByAppendingPathComponent:[_URL lastPathComponent]];
            _totalBytesWritten = [self fileSizeAtPath:_cacheFilePath];
            _totalBytesExpectedToWrite = 0;
            _observers = [[NSMutableArray alloc] init];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
            if (resumeBroken && _totalBytesWritten > 0) {
                // Range
                // bytes=x-y ==  x byte ~ y byte
                // bytes=x-  ==  x byte ~ end
                // bytes=-y  ==  head ~ y byte
                [request setValue:[NSString stringWithFormat:@"bytes=%lld-", _totalBytesWritten] forHTTPHeaderField:@"Range"];
            }
            // State
            _state = NSURLSessionTaskStateSuspended;
            _task = [session dataTaskWithRequest:[request copy]];
        }
        //
        _taskStateObserver = [[ZXKVObserver alloc] init];
    }
    return self;
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
        [_task cancel];
    }
}

- (void)suspend {
    if (_state == NSURLSessionTaskStateRunning) {
        [_task suspend];
        [self setState:NSURLSessionTaskStateSuspended withError:nil];
    }
}

- (void)resume {
    BOOL isDir = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:_finalFilePath isDirectory:&isDir] && !isDir) {
        id userInfo = @{NSLocalizedFailureReasonErrorKey:@"Could not perform an operation because the destination file already exists."};
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteFileExistsError userInfo:userInfo];
        [self setState:NSURLSessionTaskStateCompleted withError:error];
    } else if (_state == NSURLSessionTaskStateSuspended) {
        [_task resume];
        [self setState:NSURLSessionTaskStateRunning withError:nil];
    } else if (_state == NSURLSessionTaskStateCompleted) {
        [self setState:NSURLSessionTaskStateCompleted withError:nil];
    }
}

- (void)setState:(NSURLSessionTaskState)state {
    [self willChangeValueForKey:@"state"];
    _state = state;
    [self didChangeValueForKey:@"state"];
}

- (void)setState:(NSURLSessionTaskState)state withError:(NSError *)error {
    if (state == NSURLSessionTaskStateCompleted) {
        if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
            state = NSURLSessionTaskStateCanceling;
            error = nil;
        }
    }
    //
    self.state = state;
    //
    NSString *path = self.filePath;
    for (ZXDownloadObserver *observer in self.observers) {
        if (observer.observer && observer.state) {
            dispatch_async(dispatch_get_main_queue(), ^{
                observer.state(state, path, error);
            });
        }
    }
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
        if (progress > 1.0) {
            progress = 1.0;
        }
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
    [self closeOutputStream];
    if (error == nil && task.state == NSURLSessionTaskStateCompleted) {
        [[NSFileManager defaultManager] removeItemAtPath:_finalFilePath error:nil];
        [[NSFileManager defaultManager] moveItemAtPath:_cacheFilePath
                                                toPath:_finalFilePath
                                                 error:&error];
    }
    [self setState:task.state withError:error];
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
        switch (http.statusCode) {
            case 200: // OK
                break;
            case 206: // Partial Content
                append = YES;
                break;
            default:
            {
                id userInfo = @{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"%ld %@", (long)http.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:http.statusCode]]};
                NSError *error = [NSError errorWithDomain:@"HTTPStatusCode" code:http.statusCode userInfo:userInfo];
                [self setState:NSURLSessionTaskStateCompleted withError:error];
                return;
            }
        }
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
        [url appendFormat:@"%@", self.path];
    }
    if (url.length) {
        return [[[[ZXCommonDigest alloc] initWithString:url] SHA1String] lowercaseString];
    }
    return nil;
}

@end

@implementation NSURLSessionTask (ZXDownloadTask)

- (nullable NSURL *)URL {
    return self.originalRequest.URL ?: self.currentRequest.URL;
}

@end
