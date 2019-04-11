//
// ZXDownloadTask.m
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

#import "ZXDownloadTask.h"
#import "ZXCommonCrypto.h"

@interface ZXDownloadObserver : NSObject
@property (nonatomic, weak) NSObject *observer;
@property (nonatomic, copy) void(^progress)(int64_t receivedSize, int64_t expectedSize, CGFloat progress);
@property (nonatomic, copy) void(^state)(ZXDownloadState state, NSString *localFilePath, NSError *error);

@end

@implementation ZXDownloadObserver

@end

@interface ZXDownloadTask ()
@property (nonatomic, strong) NSMutableDictionary *observers;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) NSString *streamFilePath;
@property (nonatomic, strong) NSOutputStream *outputStream;

@end

@implementation ZXDownloadTask

- (instancetype)initWithURL:(NSURL *)URL {
    return [self initWithURL:URL path:nil];
}

- (instancetype)initWithURL:(NSURL *)URL path:(NSString *)path {
    self = [super init];
    if (self) {
        _observers = [[NSMutableDictionary alloc] init];
        _taskURL = [URL copy];
        _taskIdentifier = [[[ZXCommonDigest alloc] initWithString:URL.absoluteString] SHA1String];
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
        _state = ZXDownloadStateUnknown;
        _totalBytesWritten = 0;
        _totalBytesExpectedToWrite = 0;
        _localFilePath = [path stringByAppendingPathComponent:[URL lastPathComponent]];
        _streamFilePath = [path stringByAppendingPathComponent:_taskIdentifier];
        if ([[NSFileManager defaultManager] fileExistsAtPath:_localFilePath]) {
            self.state = ZXDownloadStateCompleted;
        } else {
            self.totalBytesWritten = [self fileSizeAtPath:_streamFilePath];
        }
    }
    return self;
}

- (void)addObserver:(NSObject *)observer
              state:(void(^)(ZXDownloadState state, NSString *filePath, NSError *error))state
           progress:(void(^)(int64_t receivedSize, int64_t expectedSize, CGFloat progress))progress {
    ZXDownloadObserver *taskObserver = [[ZXDownloadObserver alloc] init];
    taskObserver.observer = observer;
    taskObserver.state = state;
    taskObserver.progress = progress;
    [self.observers setObject:taskObserver forKey:@(observer.hash)];
}

- (void)removeObserver:(NSObject *)observer {
    [self.observers removeObjectForKey:@(observer.hash)];
}

#pragma mark Files

- (uint64_t)fileSizeAtPath:(NSString *)path {
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        if (attributes) {
            return [attributes[NSFileSize] longLongValue];
        }
    }
    return 0;
}

#pragma mark Properties

- (void)setState:(ZXDownloadState)state {
    [self setState:state withError:nil];
}

- (void)setState:(ZXDownloadState)state withError:(NSError *)error {
    _state = state;
    //
    switch (_state) {
        case ZXDownloadStateUnknown:
            return;
        case ZXDownloadStateWaiting:
            break;
        case ZXDownloadStateRunning:
            [self.dataTask resume];
            break;
        case ZXDownloadStateSuspended:
            [self.dataTask suspend];
            break;
        case ZXDownloadStateCancelled:
            [self.dataTask cancel];
            [self closeOutputStream];
            break;
        case ZXDownloadStateCompleted:
            [self closeOutputStream];
            break;
    }
    //
    NSArray *observers = [self.observers allValues];
    NSString *path = state == ZXDownloadStateCompleted ? self.localFilePath : nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        for (ZXDownloadObserver *observer in observers) {
            if (observer.state) {
                observer.state(state, path, error);
            }
        }
    });
}

- (void)setTotalBytesWritten:(int64_t)totalBytesWritten {
    _totalBytesWritten = totalBytesWritten;
    if (_totalBytesExpectedToWrite > 0) {
        self.progress = (float)_totalBytesWritten / _totalBytesExpectedToWrite;
    } else {
        self.progress = 0.f;
    }
}

- (void)setTotalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    _totalBytesExpectedToWrite = totalBytesExpectedToWrite;
    if (_totalBytesExpectedToWrite > 0) {
        self.progress = (float)_totalBytesWritten / _totalBytesExpectedToWrite;
    } else {
        self.progress = 0.f;
    }
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    //
    __weak typeof(self) weakSelf = self;
    NSArray *observers = [self.observers allValues];
    dispatch_async(dispatch_get_main_queue(), ^{
        for (ZXDownloadObserver *observer in observers) {
            if (observer.progress) {
                observer.progress(weakSelf.totalBytesWritten, weakSelf.totalBytesExpectedToWrite, weakSelf.progress);
            }
        }
    });
}

#pragma mark Output Stream

- (void)openOutputStreamWithAppend:(BOOL)append {
    _outputStream = [NSOutputStream outputStreamToFileAtPath:_streamFilePath append:append];
    [_outputStream open];
}

- (void)closeOutputStream {
    if (_outputStream) {
        if (_outputStream.streamStatus > NSStreamStatusNotOpen && _outputStream.streamStatus < NSStreamStatusClosed) {
            [_outputStream close];
        }
        _outputStream = nil;
    }
}

#pragma mark <NSURLSessionDataDelegate>

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    //
    BOOL append = NO;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *http = (NSHTTPURLResponse *)response;
        append = http.statusCode == 206;
    }
    //
    _totalBytesExpectedToWrite = response.expectedContentLength;
    if (append) {
        _totalBytesExpectedToWrite += _totalBytesWritten;
    }
    //
    [self openOutputStreamWithAppend:append];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if (data) {
        [_outputStream write:data.bytes maxLength:data.length];
        self.totalBytesWritten += (int64_t)data.length;
    }
}

#pragma mark <NSURLSessionTaskDelegate>

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    if (error == nil && (self.totalBytesExpectedToWrite < 0 || (self.totalBytesWritten == self.totalBytesExpectedToWrite))) {
        [[NSFileManager defaultManager] moveItemAtPath:_streamFilePath
                                                toPath:_localFilePath
                                                 error:(error == nil ? &error : nil)];
    }
    [self setState:ZXDownloadStateCompleted withError:error];
}

@end
